#!/usr/bin/env ruby
# frozen_string_literal: true

# 临时 Git 仓库上的协议回归；不把夹具观测当成真实业务验收。
require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require 'rbconfig'
require_relative 'goal-v3'

class GoalV3Test < Minitest::Test
  def setup
    @repo = Dir.mktmpdir('goal-v3-test-')
    @goal = File.join(@repo, '.goal')
    FileUtils.mkdir_p(@goal)
    GoalV3.git(@repo, 'init', '-q')
    write('src/shared.rb', "ALLOW = true\n")
    write('src/page.rb', "show_result\n")
    %w[F U V].each { |id| write("docs/#{id}.md", "#{id} 用户确认原文\n") }
    GoalV3.git(@repo, 'add', '.')
    GoalV3.git(@repo, '-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '-qm', 'fixture baseline')
    @doc = { 'schema_version' => 3, 'baseline_commit' => GoalV3.git(@repo, 'rev-parse', 'HEAD').strip,
      'decisions' => { 'D1' => { 'text' => '保留任务及结果上下文' } },
      'results' => { 'F' => result('F', 'shared_foundation', []), 'U' => result('U', 'user_result', ['F']), 'V' => result('V', 'user_result', ['U']) },
      'tasks' => { 'T1' => { 'owner' => 'worker', 'work' => '实现共享规则及入口', 'self_check' => '从真实入口核对允许与拒绝', 'results' => %w[F U V], 'depends_on' => [] } } }
    @status = { 'schema_version' => 3, 'state' => 'active', 'tasks' => { 'T1' => 'done' }, 'runs' => [] }
    @sequence = 0
    @last_snapshot = nil
    save
  end

  def teardown
    FileUtils.remove_entry(@repo)
  end

  def result(id, kind, dependencies)
    { 'kind' => kind, 'revision' => 1, 'owner' => 'main',
      'expected' => { 'entry' => '任务卡入口', 'action' => '查看成品', 'object' => '所选任务', 'context' => '两个任务各两个结果',
        'outcome' => '保留所选任务上下文', 'counterexample' => '不得显示其他任务结果' },
      'sources' => [{ 'path' => "docs/#{id}.md", 'anchor' => id }], 'decisions' => ['D1'], 'depends_on' => dependencies }
  end

  def write(path, text)
    full = File.join(@repo, path)
    FileUtils.mkdir_p(File.dirname(full))
    File.binwrite(full, text)
  end

  def save
    File.write(File.join(@goal, 'goal.yaml'), YAML.dump(@doc))
    File.write(File.join(@goal, 'status.yaml'), YAML.dump(@status))
  end

  def ref(path)
    { 'path' => path, 'sha256' => Digest::SHA256.file(File.join(@goal, path)).hexdigest }
  end

  def record(behavior: {}, checks: @doc['results'].keys, blockers: 0, failed: [], snapshot: nil)
    save
    @sequence += 1
    target = JSON.parse(JSON.generate(snapshot || GoalV3.capture(@goal, "S#{@sequence}").slice('path', 'sha256')))
    frozen = JSON.parse(File.read(File.join(@goal, target['path'])))
    evidence_path = "runs/evidence-#{@sequence}.txt"
    write(".goal/#{evidence_path}", '临时夹具：固定输入与实际输出可复查；不代表业务验收')
    run = { 'from' => @last_snapshot, 'to' => target, 'implementation_owners' => ['worker'],
      'review' => { 'owner' => 'reviewer', 'summary' => '检查完整差异及反例', 'blocking_findings' => blockers },
      'changes' => GoalV3.diff(@goal, @last_snapshot, target).map do |path|
        { 'path' => path, 'results' => behavior.fetch(path, []), 'disposition' => behavior.key?(path) ? 'behavior' : 'no_behavior',
          'reason' => behavior.key?(path) ? '改动影响指定用户结果' : '夹具中的文档或独立工具变更，审查已核实用途' }
      end,
      'checks' => checks.to_h do |id|
        [id, { 'contract_hash' => frozen['contract_hashes'][id], 'state' => failed.include?(id) ? 'failed' : 'passed',
          'observed' => '固定输入，实际得到预期输出；反例被拒绝', 'evidence' => [ref(evidence_path)] }]
      end }
    yield run if block_given?
    path = "runs/V#{@sequence}.yaml"
    write(".goal/#{path}", YAML.dump(run))
    @status['runs'] << ref(path)
    @last_snapshot = target
    save
    run
  end

  def check(complete: false)
    save
    GoalV3.check(@goal, complete: complete)
  end

  def rejects(pattern, &block)
    error = assert_raises(GoalV3::Invalid, &block)
    assert_match(pattern, error.message)
  end

  def resource_worker(id, resource, state: 'running', files: [])
    { 'id' => id, 'task' => 'T1', 'state' => state, 'write_scope' => files, 'resource_scope' => resource }
  end

  def test_resource_only_worker_is_active_but_cannot_complete
    record
    @status['active_workers'] = [resource_worker('runtime', ['local-api'])]
    refute check['complete']
    rejects(/worker|写权限|释放/) { check(complete: true) }
  end

  def test_distinct_files_do_not_hide_shared_runtime_conflict
    @status['active_workers'] = [resource_worker('api', ['local-api'], files: ['src/api']),
      resource_worker('ui', ['local-api'], files: ['src/ui'])]
    rejects(/运行资源范围重叠/) { check }
  end

  def test_stale_worker_retains_resource_until_explicit_release
    @status['active_workers'] = [resource_worker('old', ['local-jobs'], state: 'stale'),
      resource_worker('new', ['local-jobs'])]
    rejects(/运行资源范围重叠/) { check }
    @status['active_workers'].shift
    refute check['complete']
  end

  def test_distinct_runtime_resources_are_allowed_and_can_be_released
    record
    @status['active_workers'] = [resource_worker('api', ['local-api']), resource_worker('jobs', ['local-jobs'])]
    refute check['complete']
    @status['active_workers'] = []
    assert check(complete: true)['complete']
  end

  def test_invalid_or_empty_resource_ownership_is_rejected
    [[], ['local-api', 'local-api'], ['Local-API'], ['https://secret@example.invalid']].each do |resources|
      @status['active_workers'] = [resource_worker('worker', resources)]
      rejects(/操作范围至少|不得重复|资源标识/) { check }
    end
  end

  def test_misspelled_resource_scope_is_not_silently_ignored
    @status['active_workers'] = [resource_worker('api', [], files: ['src/api'])]
    @status['active_workers'][0]['resources_scope'] = ['local-api']
    rejects(/未知字段/) { check }
  end

  def test_scoped_blocker_does_not_reject_independent_result
    @doc['results']['V']['depends_on'] = ['F']
    record(blockers: 1) { |run| run['review']['blocking_results'] = ['V'] }
    assert_equal %w[F U], check['passed_results']
    assert_equal ['V'], check['pending_results']
    rejects(/V/) { check(complete: true) }
    record(checks: ['V'])
    assert check(complete: true)['complete']
  end

  def test_scoped_foundation_blocker_invalidates_transitive_consumers
    record
    record(blockers: 1, checks: []) { |run| run['review']['blocking_results'] = ['F'] }
    assert_empty check['passed_results']
    assert_equal %w[F U V], check['pending_results']
  end

  def test_scoped_blocker_preserves_prior_unrelated_evidence
    @doc['results']['V']['depends_on'] = ['F']
    record
    record(blockers: 1, checks: []) { |run| run['review']['blocking_results'] = ['V'] }
    assert_equal %w[F U], check['passed_results']
  end

  def test_invalid_blocker_scope_is_rejected
    record(blockers: 1) { |run| run['review']['blocking_results'] = [] }
    rejects(/空范围/) { check }
  end

  def test_unknown_blocker_result_is_rejected
    record(blockers: 1) { |run| run['review']['blocking_results'] = ['UNKNOWN'] }
    rejects(/blocking_results/) { check }
  end

  def test_zero_blockers_cannot_name_blocked_results
    record { |run| run['review']['blocking_results'] = ['U'] }
    rejects(/阻塞数量与结果范围/) { check }
  end

  def test_duplicate_blocker_scope_is_rejected
    record(blockers: 1) { |run| run['review']['blocking_results'] = %w[U U] }
    rejects(/重复/) { check }
  end

  def test_ordinary_task_progress_does_not_claim_acceptance
    state = check
    assert_equal %w[F U V], state['pending_results']
    assert_equal [], state['passed_results']
    refute state['complete']
    rejects(/尚无当前有效证据/) { check(complete: true) }
  end

  def test_first_complete_review_and_recoverable_snapshot
    write('src/new.rb', "puts 'new'\n")
    record(behavior: { 'src/new.rb' => ['U'] })
    state = check(complete: true)
    assert state['complete']
    assert_equal %w[F U V], state['passed_results']
    frozen = JSON.parse(File.read(File.join(@goal, @last_snapshot['path'])))
    entry = frozen['files']['src/new.rb']
    assert_equal "puts 'new'\n", File.binread(File.join(@goal, 'blobs', entry['blob']))
    assert frozen['files'].key?('.goal/goal.yaml')
    refute frozen['files'].key?('.goal/status.yaml')
  end

  def test_new_independent_test_does_not_rewrite_old_evidence
    record
    pinned = @status['runs'].first.dup
    old_snapshot = @last_snapshot.dup
    write('test/inspection.rb', "# standalone fixture\n")
    record(checks: [])
    assert check(complete: true)['complete']
    assert_equal pinned, @status['runs'].first
    assert_equal old_snapshot, YAML.safe_load(File.read(File.join(@goal, pinned['path'])))['to']
  end

  def test_same_baseline_cannot_hide_unreviewed_new_file
    record
    write('src/surprise.rb', "bypass_permissions\n")
    active = check
    assert active['needs_impact_review']
    assert_equal @last_snapshot, active['evidence_at_snapshot']
    assert_includes active['unreviewed_changes'], 'src/surprise.rb'
    rejects(/审查后仍有未覆盖改动/) { check(complete: true) }
  end

  def test_deleted_file_is_required_in_delta
    record
    File.unlink(File.join(@repo, 'src/page.rb'))
    record(checks: []) { |run| run['changes'] = [] }
    rejects(/精确覆盖全部新增、删除和修改/) { check }
  end

  def test_new_file_cannot_be_omitted_from_change_map
    record
    write('new-config.json', '{}')
    record(checks: []) { |run| run['changes'] = [] }
    rejects(/精确覆盖全部新增、删除和修改/) { check }
  end

  def test_shared_behavior_invalidates_transitive_consumers_until_checked
    record
    write('src/shared.rb', "ALLOW = false\n")
    record(behavior: { 'src/shared.rb' => ['F'] }, checks: ['F'])
    assert_equal %w[U V], check['pending_results']
    rejects(/尚无当前有效证据/) { check(complete: true) }
    record(checks: %w[U V], snapshot: @last_snapshot)
    assert check(complete: true)['complete']
  end

  def test_changed_user_decision_cannot_reuse_previous_passing_hash
    record
    old_hash = check['contract_hashes']['F']
    @doc['decisions']['D1']['text'] = '用户改为完整结果列表'
    record { |run| run['checks']['F']['contract_hash'] = old_hash }
    rejects(/旧决定、预期、来源或依赖/) { check }
  end

  def test_changed_decision_is_pending_even_without_revision_increment
    record
    @doc['decisions']['D1']['text'] = '改为当前任务全部图文'
    record(checks: [])
    assert_equal %w[F U V], check['pending_results']
  end

  def test_source_change_invalidates_only_its_result_and_consumers
    record
    write('docs/U.md', '新的任务入口规则')
    record(checks: [])
    state = check
    assert_equal ['F'], state['passed_results']
    assert_equal %w[U V], state['pending_results']
  end

  def test_unrelated_task_addition_keeps_result_evidence
    record
    @doc['tasks']['T2'] = { 'owner' => 'worker', 'work' => '整理开发说明', 'self_check' => '核对说明引用', 'results' => [], 'depends_on' => [] }
    @status['tasks']['T2'] = 'done'
    record(checks: [])
    assert check(complete: true)['complete']
  end

  def test_owner_only_handoff_keeps_reviewed_result_evidence
    record
    @doc['results']['F']['owner'] = 'new-owner'
    record(checks: [])
    assert_equal [], check['pending_results']
    assert check(complete: true)['complete']
  end

  def test_dependency_change_invalidates_prior_result_evidence
    record
    @doc['results']['V']['depends_on'] = ['F']
    record(checks: [])
    assert_equal ['V'], check['pending_results']
  end

  def test_result_removal_and_revision_rollback_are_rejected
    record
    @doc['results'].delete('V')
    @doc['tasks']['T1']['results'].delete('V')
    rejects(/不允许删除结果/) { check }
    @doc['results']['V'] = result('V', 'user_result', ['U'])
    @doc['tasks']['T1']['results'] << 'V'
    @doc['results']['V']['revision'] = 2
    record
    @doc['results']['V']['revision'] = 1
    rejects(/revision 不可回退/) { check }
  end

  def test_review_owner_must_differ_from_implementation_owner
    record { |run| run['review']['owner'] = 'worker' }
    rejects(/必须独立于实现者/) { check }
  end

  def test_blocking_review_keeps_results_pending_even_when_checks_pass
    record(blockers: 1)
    assert_equal %w[F U V], check['pending_results']
    rejects(/尚无当前有效证据/) { check(complete: true) }
    record(snapshot: @last_snapshot)
    assert check(complete: true)['complete']
  end

  def test_failed_recheck_invalidates_previous_pass
    record
    record(checks: ['U'], failed: ['U'], snapshot: @last_snapshot)
    assert_equal %w[U V], check['pending_results']
    rejects(/尚无当前有效证据/) { check(complete: true) }
  end

  def test_no_behavior_requires_reason_and_independent_review
    record { |run| run['changes'].first.delete('reason') }
    rejects(/change.reason/) { check }
  end

  def test_record_evidence_and_snapshot_tampering_are_detected
    record
    write('.goal/runs/evidence-1.txt', '改写成通过')
    rejects(/已冻结证据内容发生变化/) { check }
  end

  def test_run_file_cannot_be_silently_rewritten
    record
    write('.goal/runs/V1.yaml', 'checks: {}')
    rejects(/已冻结证据内容发生变化/) { check }
  end

  def test_snapshot_and_blob_cannot_be_silently_rewritten
    record
    manifest = JSON.parse(File.read(File.join(@goal, @last_snapshot['path'])))
    sha = manifest['files']['.goal/goal.yaml']['blob']
    write(".goal/blobs/#{sha}", 'corrupted')
    rejects(/冻结内容摘要不符/) { check }
    rejects(/冻结内容已损坏/) { GoalV3.capture(@goal, 'different-id') }
  end

  def test_snapshot_id_is_write_once
    GoalV3.capture(@goal, 'fixed')
    rejects(/不可覆盖已冻结文件/) { GoalV3.capture(@goal, 'fixed') }
  end

  def test_run_chain_cannot_skip_a_reviewed_version
    record
    write('src/page.rb', 'changed')
    record { |run| run['from'] = nil }
    rejects(/未衔接上一轮已审版本/) { check }
  end

  def test_empty_run_cannot_claim_unreviewed_current_files
    record
    write('src/page.rb', 'changed after review')
    record(checks: [], snapshot: @last_snapshot)
    rejects(/审查后仍有未覆盖改动/) { check(complete: true) }
  end

  def test_arbitrary_exclusions_and_manual_result_state_are_rejected
    @doc['exclude'] = ['src']
    rejects(/不允许自定义范围或排除/) { check }
    @doc.delete('exclude')
    @status['results'] = { 'F' => 'passed' }
    rejects(/不允许人工 results 状态/) { check }
  end

  def test_gitignored_sanitized_runtime_input_is_frozen_and_invalidates_checks
    write('.gitignore', "config/local.json\n")
    write('config/local.json', '{"environment":"fixture"}')
    @doc['inputs'] = ['config/local.json']
    record
    frozen = JSON.parse(File.read(File.join(@goal, @last_snapshot['path'])))
    assert frozen['files'].key?('config/local.json')
    write('config/local.json', '{"environment":"other-fixture"}')
    record(checks: [])
    assert_equal %w[F U V], check['pending_results']
  end

  def test_environment_secret_is_rejected_instead_of_copied
    write('.gitignore', ".env\n")
    write('.env', 'TOKEN=fixture-not-a-real-secret')
    @doc['inputs'] = ['.env']
    save
    rejects(/不能冻结可能含密钥/) { GoalV3.capture(@goal, 'secret') }
  end

  def test_symbolic_source_is_rejected
    File.symlink(File.join(@repo, 'docs/F.md'), File.join(@repo, 'alias.md'))
    @doc['results']['F']['sources'] = [{ 'path' => 'alias.md', 'anchor' => 'F' }]
    save
    rejects(/不支持符号链接/) { GoalV3.capture(@goal, 'link') }
  end

  def test_unreleased_worker_and_required_gap_block_completion
    record
    @status['next_action'] = '核实 worker 停止写入并补验真实能力'
    @status['constraints'] = ['goal.yaml#decisions.D1']
    @status['active_workers'] = [{ 'id' => 'W1', 'task' => 'T1', 'write_scope' => ['src/page.rb'], 'state' => 'stale' }]
    rejects(/释放所有活动或失联 worker/) { check(complete: true) }
    @status['active_workers'] = []
    @status['open_gaps'] = [{ 'id' => 'G1', 'results' => ['U'], 'detail' => '真实能力尚未接通', 'required' => true }]
    rejects(/关闭必需缺口/) { check(complete: true) }
    @status['open_gaps'] = []
    assert check(complete: true)['complete']
  end

  def test_stale_workers_keep_write_ownership
    @status['active_workers'] = [
      { 'id' => 'W1', 'task' => 'T1', 'write_scope' => ['src'], 'state' => 'stale' },
      { 'id' => 'W2', 'task' => 'T1', 'write_scope' => ['src/page.rb'], 'state' => 'running' }
    ]
    rejects(/写入范围重叠/) { check }
  end

  def test_v2_is_not_implicitly_migrated
    @doc['schema_version'] = 2
    rejects(/不支持该 Goal schema/) { check }
  end

  def test_public_template_matches_contract_schema
    path = File.expand_path('../templates/goal-v3/goal.yaml', __dir__)
    template = GoalV3.yaml_bytes(File.read(path), '公开模板')
    assert_equal 3, GoalV3.validate_contract(template)['schema_version']
  end

  def cli(*args)
    Open3.capture3(RbConfig.ruby, File.expand_path('check-goal.rb', __dir__), *args)
  end

  def test_cli_check_and_complete_check
    out, err, process = cli(@goal)
    assert process.success?, err
    assert_includes out, 'pending_results'
    record
    out, err, process = cli('--complete', @goal)
    assert process.success?, err
    assert_match(/"complete": true/, out)
  end

  def goal_contents
    Dir.glob(File.join(@goal, '**', '*'), File::FNM_DOTMATCH).sort.to_h do |path|
      [path, File.directory?(path) ? :directory : File.binread(path)]
    end
  end

  def rejects_cli_without_writes(pattern, *args)
    before = goal_contents
    out, err, process = cli(*args)
    refute process.success?, out
    assert_empty out
    assert_match pattern, err
    assert_equal before, goal_contents
  end

  def test_cli_rejects_old_or_unknown_contract_schemas_without_writes
    [nil, 1, 2, 4].each do |schema|
      @doc['schema_version'] = schema
      save
      [[@goal], ['--complete', @goal], ['--template', @goal],
       ['--capture-v3', @goal, 'unsupported'], ['--delta-v3', @goal, 'unsupported']].each do |args|
        rejects_cli_without_writes(/不支持该 Goal schema/, *args)
      end
    end
  end

  def test_cli_rejects_old_status_schema_before_snapshot_writes
    @status['schema_version'] = 2
    save
    [[@goal], ['--complete', @goal], ['--capture-v3', @goal, 'unsupported'],
     ['--delta-v3', @goal, 'unsupported']].each do |args|
      rejects_cli_without_writes(/不支持该 status.yaml schema/, *args)
    end
  end

  def test_cli_rejects_slices_only_packages_without_writes
    File.unlink(File.join(@goal, 'goal.yaml'))
    write('.goal/slices.yaml', YAML.dump('schema_version' => 2, 'slices' => []))
    [[@goal], ['--complete', @goal], ['--template', @goal],
     ['--capture-v3', @goal, 'unsupported'], ['--delta-v3', @goal, 'unsupported']].each do |args|
      rejects_cli_without_writes(/不支持仅含 slices.yaml 的旧 Goal 包/, *args)
    end
  end

  def test_cli_rejects_old_snapshot_options_without_writes
    rejects_cli_without_writes(/不支持旧快照参数/, '--snapshot', @repo, @doc['baseline_commit'],
                              File.join(@goal, 'snapshots/old.json'), '--exclude', '.goal/runs', '--contract', '.goal/goal.yaml')
    rejects_cli_without_writes(/不支持旧快照参数/, '--snapshot-batch', @goal, 'B01', File.join(@goal, 'snapshots/old.json'))
  end

  def test_cli_template_checks_only_contract_and_rejects_incomplete_template
    template_dir = File.expand_path('../templates/goal-v3', __dir__)
    out, err, process = cli('--template', template_dir)
    assert process.success?, err
    assert_match(/v3 模板契约结构检查通过/, out)
    @doc['results']['U']['expected'].delete('context')
    save
    rejects_cli_without_writes(/expected.context/, '--template', @goal)
  end

  def test_cli_invalid_arguments_do_not_start_execution
    [[], ['--complete'], ['--template'], ['--capture-v3', @goal], ['--unknown', @goal]].each do |args|
      rejects_cli_without_writes(/用法/, *args)
    end
  end

  def test_resume_file_is_reviewed_like_other_undeclared_files
    record
    write('.goal/resume.md', '额外文件不能隐藏在执行记录排除项中')
    assert_includes check['unreviewed_changes'], '.goal/resume.md'
    rejects(/审查后仍有未覆盖改动/) { check(complete: true) }
  end

  def test_cli_capture_and_delta_include_added_and_deleted_files
    record
    File.unlink(File.join(@repo, 'src/page.rb'))
    write('src/added.rb', 'replacement')
    out, err, process = cli('--capture-v3', @goal, 'cli-version')
    assert process.success?, err
    assert_equal 'snapshots/cli-version.json', JSON.parse(out)['path']
    out, err, process = cli('--delta-v3', @goal, 'cli-version')
    assert process.success?, err
    delta = JSON.parse(out)
    assert_equal @last_snapshot, delta['from']
    assert_equal %w[src/added.rb src/page.rb], delta['changes'].map { |change| change['path'] }.sort
    assert delta['changes'].all? { |change| change['disposition'] == 'pending' }
  end
end
