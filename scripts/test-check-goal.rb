#!/usr/bin/env ruby
# frozen_string_literal: true

# 在临时仓库验证状态/快照误判；不修改候选仓库或真实业务数据。
require 'minitest/autorun'
require 'tmpdir'
require 'fileutils'
require_relative 'check-goal'

class GoalCheckerTest < Minitest::Test
  def setup
    @repo = Dir.mktmpdir('playbook-goal-check-')
    @goal = File.join(@repo, '.goal')
    FileUtils.mkdir_p(@goal)
    git('init', '-q')
    File.write(File.join(@repo, 'base.txt'), '基础')
    git('add', 'base.txt')
    git('-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '-qm', '测试基线')
    @baseline = git('rev-parse', 'HEAD').strip
    @slice = {
      'id' => 'S01', 'task_ids' => ['T01'], 'lane' => 'SERVER_CAPABILITY',
      'review_batch' => 'B01', 'review_boundary' => 'batch', 'dependencies' => [],
      'scope' => ['业务方法'], 'non_goals' => ['生产发布'],
      'implementation_owner' => { 'mode' => 'main_thread', 'reason' => '核心实现', 'ownership' => ['src.rb'] },
      'min_self_check' => [{ 'behavior' => '保存成功', 'risk' => '数据丢失', 'method' => '接口测试', 'expected' => '回读一致' }],
      'required_docs' => ['.goal/acceptance.md'], 'evidence' => { 'level' => 'E1' }, 'tooling_prerequisite_ids' => []
    }
    @slices = { 'schema_version' => 2, 'slices' => [@slice], 'review_batches' => [
      { 'id' => 'B01', 'kind' => 'functional', 'slice_ids' => ['S01'], 'acceptance_ids' => ['A01'], 'earliest_real_path' => '保存后回读', 'snapshot_scope' => { 'paths' => ['src.rb', 'base.txt', 'src'], 'contracts' => ['.goal/acceptance.md'] } },
      { 'id' => 'FINAL', 'kind' => 'final', 'slice_ids' => [], 'acceptance_ids' => ['A01'], 'earliest_real_path' => '完整功能验收', 'snapshot_scope' => { 'contracts' => [] } }
    ] }
    pending = { 'state' => 'pending', 'snapshot' => nil, 'validation_report' => nil, 'review_report' => nil, 'blocking_findings' => 0 }
    @status = { 'schema_version' => 2, 'review_strategy' => 'functional_batch', 'run_control' => { 'mode' => 'continuous' },
      'execution' => { 'state' => 'ready', 'current_slice' => nil, 'next_slice' => 'S01', 'baseline_commit' => @baseline },
      'slices' => { 'S01' => 'todo' }, 'review_batches' => { 'B01' => pending.dup, 'FINAL' => pending.dup },
      'acceptance' => { 'A01' => 'pending' }, 'reports' => {}, 'delivery' => { 'code_complete' => false, 'release_readiness' => 'not_requested' } }
    %w[GOAL.md acceptance.md review-policy.md].each { |name| File.write(File.join(@goal, name), '# 测试契约') }
    %w[runs validation cr snapshots].each { |name| FileUtils.mkdir_p(File.join(@goal, name)) }
    @exclusions = GoalCheck::RUNTIME_NAMES.map { |name| ".goal/#{name}" }
    @contracts = (GoalCheck::CORE_CONTRACTS + ['review-policy.md']).map { |name| ".goal/#{name}" }
    write_docs
  end

  def teardown
    FileUtils.remove_entry(@repo)
  end

  def git(*args)
    GoalCheck.git(@repo, *args)
  end

  def write_docs
    File.write(File.join(@goal, 'slices.yaml'), YAML.dump(@slices))
    File.write(File.join(@goal, 'status.yaml'), YAML.dump(@status))
  end

  def check
    write_docs
    checker = GoalCheck::Checker.new(@goal)
    [checker.run, checker.errors.join("\n")]
  end

  def accept(id)
    write_docs
    state = @status['review_batches'][id]
    state['state'] = 'accepted'
    state['snapshot'] = ".goal/snapshots/#{id}.json"
    state['validation_report'] = ".goal/validation/#{id}.md"
    state['review_report'] = ".goal/cr/#{id}.md"
    File.write(File.join(@goal, "validation/#{id}.md"), '独立验证记录')
    File.write(File.join(@goal, "cr/#{id}.md"), '独立审查记录')
    manifest = GoalCheck.capture_batch(@goal, id)
    File.write(File.join(@goal, "snapshots/#{id}.json"), JSON.pretty_generate(manifest))
  end

  def prepare_accepted
    @status['slices']['S01'] = 'accepted'
    self_check('S01')
    @status['acceptance']['A01'] = 'passed'
    @status['execution']['next_slice'] = nil
    accept('B01')
  end

  def self_check(id)
    @status['reports'][id] = ".goal/runs/#{id}.md"
    File.write(File.join(@goal, "runs/#{id}.md"), '实现范围与实际必要自测记录')
  end

  def complete
    prepare_accepted
    accept('FINAL')
    @status['execution']['state'] = 'complete'
    @status['delivery']['code_complete'] = true
  end

  def start_slices(*ids, current: nil)
    ids.each do |id|
      @status['slices'][id] = 'in_progress'
      @slices['slices'].find { |slice| slice['id'] == id }['implementation_owner']['mode'] = 'hybrid'
    end
    @status['execution'].merge!('state' => 'in_progress', 'current_slice' => current, 'next_slice' => nil)
  end

  def worker(id, slice_id, *paths, state: 'running')
    { 'id' => id, 'slice_id' => slice_id, 'state' => state, 'write_scope' => paths }
  end

  def assert_check(expected, context = '')
    ok, error = check
    assert_equal expected, ok, [context, error].reject(&:empty?).join("\n")
  end

  def test_parallel_independent_slices_can_run_with_main_focus
    add_independent_batch
    start_slices('S01', 'S02', current: 'S01')
    @status['active_workers'] = [worker('W02', 'S02', 'consumer')]
    assert_check true
  end

  def test_parallel_all_worker_slices_need_no_main_focus
    add_independent_batch
    start_slices('S01', 'S02')
    @status['active_workers'] = [worker('W01', 'S01', 'src'), worker('W02', 'S02', 'consumer')]
    assert_check true
  end

  def test_parallel_same_slice_workers_can_split_sibling_scopes
    start_slices('S01')
    @status['active_workers'] = [worker('W01', 'S01', 'src/api'), worker('W02', 'S01', 'src/api-client')]
    assert_check true, '名称有相同前缀的独立目录不应被误判为父子目录'
    @status['run_control']['mode'] = 'single_slice'
    assert_check true, 'single_slice 仍允许同一任务内部委派'
  end

  def test_parallel_legacy_serial_without_worker_registry_still_runs
    start_slices('S01', current: 'S01')
    assert_check true
    @status['active_workers'] = []
    assert_check true
  end

  def test_parallel_unowned_running_slice_is_rejected
    add_independent_batch
    start_slices('S01', 'S02', current: 'S01')
    assert_check false, '非焦点任务不能无负责人地运行'
    @status['slices']['S02'] = 'todo'
    @status['execution']['current_slice'] = nil
    assert_check false, '没有焦点时所有进行中的任务都需要 worker'
  end

  def test_parallel_worker_cannot_hide_running_work_as_todo
    start_slices('S01')
    @status['active_workers'] = [worker('W01', 'S01', 'src')]
    assert_check true
    @status['slices']['S01'] = 'todo'
    assert_check false, 'worker 正在实现时任务不能仍是 todo'
  end

  def test_parallel_worker_requires_declared_implementation_owner
    start_slices('S01')
    @status['active_workers'] = [worker('W01', 'S01', 'src')]
    @slice['implementation_owner']['mode'] = 'main_thread'
    assert_check false, '实际委派必须与任务所有者声明一致'
    @slice['implementation_owner']['mode'] = 'worker'
    assert_check true
  end

  def test_parallel_worker_cannot_bypass_cross_batch_or_foundation_dependency
    add_independent_batch(dependencies: ['S01'])
    @status['slices']['S01'] = 'implemented'
    self_check('S01')
    start_slices('S02')
    @status['active_workers'] = [worker('W02', 'S02', 'consumer')]
    %w[functional foundation].each do |kind|
      @slices['review_batches'][0]['kind'] = kind
      @slice['review_boundary'] = kind == 'foundation' ? 'before_dependents' : 'batch'
      ok, error = check
      refute ok, "#{kind} 不能由并行委派绕过验收"
      assert_includes error, '依赖 S01 尚未达到'
    end
  end

  def test_parallel_same_batch_consumer_waits_for_actual_self_check
    @slices['slices'] << Marshal.load(Marshal.dump(@slice)).merge('id' => 'S02', 'task_ids' => ['T02'], 'dependencies' => ['S01'])
    @slices['review_batches'][0]['slice_ids'] << 'S02'
    start_slices('S01', 'S02', current: 'S01')
    @status['active_workers'] = [worker('W02', 'S02', 'src/consumer.rb')]
    ok, error = check
    refute ok
    assert_includes error, '依赖 S01 尚未达到'
    @status['slices']['S01'] = 'implemented'
    self_check('S01')
    @status['execution']['current_slice'] = nil
    assert_check true, '同批次普通前置自测通过即可由 worker 继续'
  end

  def test_parallel_overlapping_worker_scopes_are_rejected
    start_slices('S01')
    [['src/api', 'src/api'], ['src', 'src/api/client.rb'], ['src/api/client.rb', 'src']].each do |left, right|
      @status['active_workers'] = [worker('W01', 'S01', left), worker('W02', 'S01', right)]
      assert_check false, "重叠写入范围：#{left} / #{right}"
    end
  end

  def test_parallel_invalid_worker_records_are_rejected
    start_slices('S01')
    invalid = [
      { 'id' => '' }, { 'id' => 1 }, { 'slice_id' => 'UNKNOWN' }, { 'slice_id' => nil },
      { 'state' => 'done' }, { 'state' => nil }, { 'write_scope' => nil }, { 'write_scope' => 'src' },
      { 'write_scope' => [] }, { 'write_scope' => [nil] }, { 'write_scope' => [''] },
      { 'write_scope' => ['/tmp/src'] }, { 'write_scope' => ['../outside'] }, { 'write_scope' => ['.'] },
      { 'write_scope' => ['src/../consumer'] }, { 'write_scope' => ['src/nested/../../consumer'] },
      { 'write_scope' => ['src/**'] }, { 'write_scope' => ['src/?.rb'] }, { 'write_scope' => ['src/[ab]'] }
    ]
    invalid.each do |change|
      @status['active_workers'] = [worker('W01', 'S01', 'src').merge(change)]
      assert_check false, "无效 worker 字段：#{change.inspect}"
    end
    [nil, {}, 'worker', [nil]].each do |registry|
      @status['active_workers'] = registry
      assert_check false, "无效 worker 清单：#{registry.inspect}"
    end
  end

  def test_parallel_worker_ids_must_be_unique_even_for_distinct_scopes
    start_slices('S01')
    @status['active_workers'] = [worker('W01', 'S01', 'src/api'), worker('W01', 'S01', 'src/ui')]
    assert_check false
  end

  def test_parallel_stale_worker_preserves_scope_until_explicit_replacement
    start_slices('S01')
    @status['active_workers'] = [worker('W01', 'S01', 'src', state: 'stale')]
    assert_check true, '失联半成品保留进行中状态'
    @status['active_workers'] << worker('W02', 'S01', 'src/recovery.rb')
    assert_check false, '失联不自动释放原写入范围'
    @status['active_workers'].shift
    assert_check true, '核实旧 worker 停止后可显式换人接手'
  end

  def test_parallel_stale_awaiting_revalidation_keeps_previous_evidence
    start_slices('S01')
    @status['slices']['S01'] = 'awaiting_revalidation'
    @status['active_workers'] = [worker('W01', 'S01', 'src', state: 'stale')]
    ok, error = check
    refute ok
    assert_includes error, '实现与必要自测记录'
    self_check('S01')
    assert_check true
    @status['active_workers'][0]['state'] = 'running'
    assert_check false, '待复验不能记作 worker 正在实现'
    @status['slices']['S01'] = 'in_progress'
    assert_check true, '恢复执行后继续沿用同一任务与 worker'
  end

  def prepare_stale_dependency
    add_independent_batch(dependencies: ['S01'])
    start_slices('S02')
    @status['active_workers'] = [worker('W02A', 'S02', 'consumer/a'), worker('W02B', 'S02', 'consumer/b')]
    prepare_accepted
    assert_check true, '前置已验收时消费者可正常开始，尚无完成报告'
    refute @status['reports'].key?('S02')
    @status['slices']['S01'] = 'awaiting_revalidation'
    @status['review_batches']['B01']['state'] = 'pending'
    @status['acceptance']['A01'] = 'pending'
    @status['active_workers'].each { |entry| entry['state'] = 'stale' }
  end

  def record_partial_consumer
    FileUtils.mkdir_p(File.join(@repo, 'consumer/a'))
    File.write(File.join(@repo, 'consumer/a/adapter.rb'), '# 消费者适配草稿，尚未接入真实入口')
    @status['reports']['S02'] = '.goal/runs/S02-partial.md'
    File.write(File.join(@goal, 'runs/S02-partial.md'), <<~REPORT)
      # 部分实现记录（测试夹具）
      已改：consumer/a/adapter.rb 草稿；未改：consumer/b 与真实入口装配。
      已测：仅核对草稿文件存在；未测：消费者行为、自测反例及真实集成。
      停止证据：两个夹具 worker 已标失联，尚未查实进程停止，写范围仍保留。
      恢复条件：查实旧会话停止，前置 S01 重新验收；当前不表示实现完成或自测通过。
    REPORT
  end

  def test_parallel_paused_partial_consumer_releases_workers_then_resumes
    prepare_stale_dependency
    ok, error = check
    refute ok, '依赖失效后不能用全部 stale 保留可继续执行的 in_progress'
    assert_includes error, '依赖 S01 尚未达到'
    @status['slices']['S02'] = 'awaiting_revalidation'
    ok, error = check
    refute ok, '暂停半成品也必须保存真实部分实现记录'
    assert_includes error, '实现与必要自测记录'
    record_partial_consumer
    assert_check true, '部分实现记录支持暂停，不伪装成自测已通过'
    @status['active_workers'] << worker('W03', 'S02', 'consumer/a/recovery.rb', state: 'stale')
    ok, error = check
    refute ok
    assert_includes error, '写范围重叠'
    @status['active_workers'].pop
    File.open(File.join(@goal, 'runs/S02-partial.md'), 'a') { |file| file.puts '停止核验：夹具旧会话已终止，已核对草稿；可释放旧 worker 写权限。' }
    @status['active_workers'] = []
    assert_check true, '查实停止后可释放 worker，部分实现仍合法暂停'
    @status['slices']['S02'] = 'in_progress'
    @status['execution']['current_slice'] = 'S02'
    ok, error = check
    refute ok, '移除失联 worker 不等于主线程现在可以接管执行'
    assert_includes error, '依赖 S01 尚未达到'
    @status['slices']['S02'] = 'awaiting_revalidation'
    @status['execution']['current_slice'] = nil
    assert_check true
    @status['slices']['S01'] = 'accepted'
    @status['acceptance']['A01'] = 'passed'
    accept('B01')
    @status['slices']['S02'] = 'in_progress'
    @status['execution']['current_slice'] = 'S02'
    assert_check true, '前置复验完成后才可由主线程接管原半成品'
    self_check('S02')
    @status['slices']['S02'] = 'implemented'
    @status['execution']['current_slice'] = nil
    assert_check true, '继续实现并完成自测后才进入 implemented'
  end

  def test_parallel_paused_consumer_cannot_waive_live_or_finished_task_dependencies
    prepare_stale_dependency
    @status['slices']['S02'] = 'awaiting_revalidation'
    record_partial_consumer
    assert_check true
    @status['slices']['S02'] = 'in_progress'
    @status['active_workers'][1]['state'] = 'running'
    ok, error = check
    refute ok, '只冻结部分 worker 仍表示消费者在继续运行'
    assert_includes error, '依赖 S01 尚未达到'
    @status['active_workers'][1]['state'] = 'stale'
    @status['execution']['current_slice'] = 'S02'
    ok, error = check
    refute ok, '主线程焦点不能利用 stale 登记跳过依赖'
    assert_includes error, '依赖 S01 尚未达到'
    @status['execution']['current_slice'] = nil
    @status['active_workers'] = []
    ok, error = check
    refute ok, '无 worker 的半成品不构成合法冻结登记'
    assert_includes error, '必须由 current_slice 或 active_workers 负责'
    self_check('S02')
    %w[implemented accepted].each do |state|
      @status['slices']['S02'] = state
      ok, error = check
      refute ok, "#{state} 不能把失效依赖当成仅冻结登记"
      assert_includes error, '依赖 S01 尚未达到'
    end
  end

  def test_parallel_finished_task_cannot_retain_stale_write_owner
    start_slices('S01')
    @status['active_workers'] = [worker('W01', 'S01', 'src', state: 'stale')]
    @status['slices']['S01'] = 'implemented'
    self_check('S01')
    assert_check false, '实现已通过时应先处理失联 worker 占用'
  end

  def test_parallel_single_slice_mode_cannot_run_two_slices
    add_independent_batch
    start_slices('S01', 'S02', current: 'S01')
    @status['active_workers'] = [worker('W02', 'S02', 'consumer')]
    @status['run_control']['mode'] = 'single_slice'
    assert_check false
    @status['slices']['S02'] = 'awaiting_revalidation'
    self_check('S02')
    @status['active_workers'][0]['state'] = 'stale'
    assert_check false, '失联待复验任务仍占用另一个切片的写权限'
    @status['slices']['S01'] = 'todo'
    @status['execution']['current_slice'] = nil
    assert_check true, '只保留一个失联待复验任务时符合 single_slice'
  end

  def test_parallel_complete_cannot_leave_worker_reservations
    @slice['implementation_owner']['mode'] = 'hybrid'
    complete
    assert_check true
    %w[running stale].each do |state|
      @status['active_workers'] = [worker('W01', 'S01', 'src', state: state)]
      assert_check false, "完成时不能仍保留 #{state} worker"
    end
    @status['active_workers'] = []
    assert_check true
  end

  def test_ready_valid
    ok, error = check
    assert ok, error
  end

  def test_ordinary_implemented_does_not_require_cr
    @status['slices']['S01'] = 'implemented'
    self_check('S01')
    @status['execution']['next_slice'] = nil
    ok, error = check
    assert ok, error
  end

  def test_foundation_must_be_accepted_before_dependents
    @slice['review_boundary'] = 'before_dependents'
    @slices['review_batches'][0]['kind'] = 'foundation'
    @slices['slices'] << Marshal.load(Marshal.dump(@slice)).merge('id' => 'S02', 'task_ids' => ['T02'], 'review_batch' => 'B02', 'review_boundary' => 'batch', 'dependencies' => ['S01'])
    @slices['review_batches'] << { 'id' => 'B02', 'kind' => 'functional', 'slice_ids' => ['S02'], 'acceptance_ids' => ['A01'], 'earliest_real_path' => '提交', 'snapshot_scope' => { 'paths' => ['consumer'], 'contracts' => ['.goal/acceptance.md'] } }
    @status['review_batches']['B02'] = @status['review_batches']['B01'].dup
    @status['slices'] = { 'S01' => 'implemented', 'S02' => 'in_progress' }
    self_check('S01')
    @status['execution'].merge!('state' => 'in_progress', 'current_slice' => 'S02', 'next_slice' => nil)
    ok, error = check
    refute ok
    assert_includes error, '依赖 S01 尚未达到'
  end

  def test_implemented_requires_actual_self_check_record
    @status['slices']['S01'] = 'implemented'
    @status['execution']['next_slice'] = nil
    ok, error = check
    refute ok
    assert_includes error, '实现与必要自测记录'
  end

  def test_current_slice_must_be_in_progress
    @status['execution']['current_slice'] = 'S01'
    ok, error = check
    refute ok
    assert_includes error, 'current_slice 不能指向'
  end

  def test_cross_batch_dependency_requires_accepted
    @slices['slices'] << Marshal.load(Marshal.dump(@slice)).merge('id' => 'S02', 'task_ids' => ['T02'], 'review_batch' => 'B02', 'dependencies' => ['S01'])
    @slices['review_batches'] << { 'id' => 'B02', 'kind' => 'functional', 'slice_ids' => ['S02'], 'acceptance_ids' => ['A01'], 'earliest_real_path' => '提交', 'snapshot_scope' => { 'paths' => ['consumer'], 'contracts' => ['.goal/acceptance.md'] } }
    @status['review_batches']['B02'] = @status['review_batches']['B01'].dup
    @status['slices'] = { 'S01' => 'implemented', 'S02' => 'in_progress' }
    self_check('S01')
    @status['execution'].merge!('state' => 'in_progress', 'current_slice' => 'S02', 'next_slice' => nil)
    ok, error = check
    refute ok
    assert_includes error, '依赖 S01 尚未达到'
  end

  def test_same_batch_dependency_allows_implemented
    @slices['slices'] << Marshal.load(Marshal.dump(@slice)).merge('id' => 'S02', 'task_ids' => ['T02'], 'dependencies' => ['S01'])
    @slices['review_batches'][0]['slice_ids'] << 'S02'
    @status['slices'] = { 'S01' => 'implemented', 'S02' => 'in_progress' }
    self_check('S01')
    @status['execution'].merge!('state' => 'in_progress', 'current_slice' => 'S02', 'next_slice' => nil)
    ok, error = check
    assert ok, error
  end

  def test_project_without_review_policy_can_accept
    File.delete(File.join(@goal, 'review-policy.md'))
    @contracts.delete('.goal/review-policy.md')
    complete
    ok, error = check
    assert ok, error
  end

  def test_missing_report_cannot_accept
    prepare_accepted
    File.delete(File.join(@goal, 'cr/B01.md'))
    ok, error = check
    refute ok
    assert_includes error, '文件不存在'
  end

  def test_stale_accepted_snapshot
    File.write(File.join(@repo, 'src.rb'), 'old')
    prepare_accepted
    File.write(File.join(@repo, 'src.rb'), 'new')
    ok, error = check
    refute ok
    assert_includes error, '快照已过时'
  end

  def test_current_final_covers_old_batch_changes
    File.write(File.join(@repo, 'src.rb'), 'old')
    prepare_accepted
    File.write(File.join(@repo, 'src.rb'), 'new')
    accept('FINAL')
    @status['execution']['state'] = 'complete'
    @status['delivery']['code_complete'] = true
    ok, error = check
    assert ok, error
  end

  def test_new_untracked_file_invalidates_final
    complete
    File.write(File.join(@repo, 'unreviewed.rb'), '未审改动')
    ok, error = check
    refute ok
    assert_includes error, '未完整覆盖'
  end

  def test_contract_change_invalidates_final
    complete
    File.write(File.join(@goal, 'acceptance.md'), '改变后的业务口径')
    ok, error = check
    refute ok
    assert_includes error, '未完整覆盖'
  end

  def test_unsafe_exclusion_is_rejected
    complete
    path = File.join(@goal, 'snapshots/FINAL.json')
    manifest = JSON.parse(File.read(path))
    manifest['excluded_paths'] << 'src'
    File.write(path, JSON.pretty_generate(manifest))
    ok, error = check
    refute ok
    assert_includes error, '不允许排除业务代码'
  end

  def test_wrong_batch_mapping_is_rejected
    @slices['review_batches'][0]['slice_ids'] = []
    ok, error = check
    refute ok
    assert_includes error, '映射不一致'
  end

  def test_complete_cannot_have_pending_acceptance
    complete
    @status['acceptance']['A01'] = 'pending'
    ok, error = check
    refute ok
    assert_includes error, '验收未 passed'
  end

  def test_legacy_schema_not_silently_migrated
    @status['schema_version'] = 1
    ok, error = check
    refute ok
    assert_includes error, '旧 Goal 必须显式迁移'
  end

  def test_snapshot_contains_deletions_and_untracked
    File.delete(File.join(@repo, 'base.txt'))
    File.write(File.join(@repo, 'new.txt'), '新增')
    snapshot = GoalCheck.capture(@repo, @baseline, @exclusions, @contracts)
    assert snapshot['files'].key?('base.txt')
    assert_nil snapshot['files']['base.txt']
    assert_match(/\A[0-9a-f]{64}\z/, snapshot['files']['new.txt'])
    File.write(File.join(@repo, 'new.txt'), '不同内容')
    updated = GoalCheck.capture(@repo, @baseline, @exclusions, @contracts)
    refute_equal snapshot['files']['new.txt'], updated['files']['new.txt']
  end
  def test_accepted_snapshot_requires_contract_digests
    prepare_accepted
    file = File.join(@goal, 'snapshots/B01.json')
    data = JSON.parse(File.read(file))
    data['files'] = {}
    File.write(file, JSON.pretty_generate(data))
    ok, error = check
    refute ok
    assert_includes error, '契约缺少内容摘要'
  end

  def test_in_review_snapshot_rejects_content_change
    File.write(File.join(@repo, 'base.txt'), '待审内容')
    @status['slices']['S01'] = 'implemented'
    self_check('S01')
    @status['execution']['next_slice'] = nil
    accept('B01')
    @status['review_batches']['B01']['state'] = 'in_review'
    File.write(File.join(@repo, 'base.txt'), '审查期间修改')
    ok, error = check
    refute ok
    assert_includes error, '在审快照已变化'
  end

  def test_executable_mode_change_invalidates_final_snapshot
    File.write(File.join(@repo, 'run.sh'), "exit 0\n")
    File.chmod(0o644, File.join(@repo, 'run.sh'))
    complete
    File.chmod(0o755, File.join(@repo, 'run.sh'))
    ok, error = check
    refute ok
    assert_includes error, '最终审查快照未完整覆盖'
  end

  def test_final_can_cover_removed_optional_contract
    prepare_accepted
    File.delete(File.join(@goal, 'review-policy.md'))
    @contracts.delete('.goal/review-policy.md')
    accept('FINAL')
    @status['execution']['state'] = 'complete'
    @status['delivery']['code_complete'] = true
    ok, error = check
    assert ok, error
  end

  def test_capture_does_not_accept_missing_current_contract
    File.delete(File.join(@goal, 'review-policy.md'))
    assert_raises(GoalCheck::Invalid) { GoalCheck.capture(@repo, @baseline, @exclusions, @contracts) }
  end

  def test_acyclic_tasks_cannot_form_cyclic_batches
    @slices['slices'] << Marshal.load(Marshal.dump(@slice)).merge('id' => 'S02', 'task_ids' => ['T02'], 'review_batch' => 'B02', 'dependencies' => ['S01'])
    @slices['slices'] << Marshal.load(Marshal.dump(@slice)).merge('id' => 'S03', 'task_ids' => ['T03'], 'dependencies' => ['S02'])
    @slices['review_batches'][0]['slice_ids'] << 'S03'
    @slices['review_batches'] << {'id' => 'B02', 'kind' => 'functional', 'slice_ids' => ['S02'], 'acceptance_ids' => ['A01'], 'earliest_real_path' => '第二批次', 'snapshot_scope' => { 'paths' => ['consumer'], 'contracts' => ['.goal/acceptance.md'] }}
    @status['review_batches']['B02'] = @status['review_batches']['B01'].dup
    @status['slices'].merge!('S02' => 'todo', 'S03' => 'todo')
    ok, error = check
    refute ok
    assert_includes error, '批次依赖存在循环'
  end

  def test_foundation_internal_accepted_dependency_is_rejected
    @slice['review_boundary'] = 'before_dependents'
    @slices['review_batches'][0]['kind'] = 'foundation'
    @slices['slices'] << Marshal.load(Marshal.dump(@slice)).merge('id' => 'S02', 'task_ids' => ['T02'], 'dependencies' => ['S01'])
    @slices['review_batches'][0]['slice_ids'] << 'S02'
    @status['slices']['S02'] = 'todo'
    ok, error = check
    refute ok
    assert_includes error, '同一基础批次内依赖'
  end

  def add_independent_batch(dependencies: [])
    @slices['slices'] << Marshal.load(Marshal.dump(@slice)).merge('id' => 'S02', 'task_ids' => ['T02'], 'review_batch' => 'B02', 'review_boundary' => 'batch', 'dependencies' => dependencies)
    @slices['review_batches'] << { 'id' => 'B02', 'kind' => 'functional', 'slice_ids' => ['S02'], 'acceptance_ids' => ['A01'], 'earliest_real_path' => '消费者回读',
      'snapshot_scope' => { 'paths' => ['consumer'], 'contracts' => ['.goal/acceptance.md'] } }
    @status['review_batches']['B02'] = { 'state' => 'pending', 'snapshot' => nil, 'validation_report' => nil, 'review_report' => nil, 'blocking_findings' => 0 }
    @status['slices']['S02'] = 'todo'
  end

  def test_independent_batch_draft_and_later_acceptance_do_not_stale_first_batch
    add_independent_batch
    FileUtils.mkdir_p(File.join(@repo, 'consumer'))
    File.write(File.join(@repo, 'consumer/a.rb'), '草稿')
    prepare_accepted
    snapshot = JSON.parse(File.read(File.join(@goal, 'snapshots/B01.json')))
    refute snapshot['files'].key?('consumer/a.rb')
    File.write(File.join(@repo, 'consumer/a.rb'), '完成')
    ok, error = check
    assert ok, error
    @status['slices']['S02'] = 'accepted'
    self_check('S02')
    accept('B02')
    ok, error = check
    assert ok, error
  end

  def test_adding_unrelated_task_definition_does_not_stale_first_batch
    prepare_accepted
    add_independent_batch
    ok, error = check
    assert ok, error
  end

  def test_foundation_new_file_invalidates_review_acceptance_and_dependent_start
    @slice['review_boundary'] = 'before_dependents'
    @slices['review_batches'][0]['kind'] = 'foundation'
    add_independent_batch(dependencies: ['S01'])
    prepare_accepted
    @status['slices']['S01'] = 'implemented'
    @status['review_batches']['B01']['state'] = 'in_review'
    FileUtils.mkdir_p(File.join(@repo, 'src/new-directory'))
    File.write(File.join(@repo, 'src/new-directory/new.rb'), '未审基础代码')
    ok, error = check
    refute ok
    assert_includes error, '在审快照已变化'
    @status['slices']['S01'] = 'accepted'
    @status['review_batches']['B01']['state'] = 'accepted'
    ok, error = check
    refute ok
    assert_includes error, '快照已过时'
    @status['slices']['S02'] = 'in_progress'
    @status['execution'].merge!('state' => 'in_progress', 'current_slice' => 'S02')
    ok, error = check
    refute ok
    assert_includes error, '快照已过时'
  end

  def test_deleted_scoped_file_invalidates_batch
    prepare_accepted
    File.delete(File.join(@repo, 'base.txt'))
    ok, error = check
    refute ok
    assert_includes error, 'base.txt'
  end

  def test_new_and_retargeted_scoped_symlink_invalidate_batch
    prepare_accepted
    FileUtils.mkdir_p(File.join(@repo, 'src'))
    File.symlink('../base.txt', File.join(@repo, 'src/link'))
    ok, error = check
    refute ok
    assert_includes error, 'src/link'
    accept('B01')
    File.delete(File.join(@repo, 'src/link'))
    File.symlink('../missing.txt', File.join(@repo, 'src/link'))
    ok, error = check
    refute ok
    assert_includes error, 'src/link'
  end

  def test_registered_unchanged_contract_change_invalidates_batch
    File.write(File.join(@repo, 'business.md'), '经认可的契约')
    @slices['review_batches'][0]['snapshot_scope']['contracts'] << 'business.md'
    prepare_accepted
    File.write(File.join(@repo, 'business.md'), '成功定义变更')
    ok, error = check
    refute ok
    assert_includes error, 'business.md'
  end

  def test_scope_configuration_change_invalidates_batch_even_without_file_changes
    prepare_accepted
    @slices['review_batches'][0]['snapshot_scope']['paths'] << 'future-module'
    ok, error = check
    refute ok
    assert_includes error, '审查范围或相关执行契约'
  end

  def test_own_task_definition_change_invalidates_batch
    prepare_accepted
    @slice['min_self_check'][0]['expected'] = '新的验收结果'
    ok, error = check
    refute ok
    assert_includes error, 'contract_projection'
  end

  def test_dependency_code_and_contracts_are_captured_for_consumer
    @slice['review_boundary'] = 'before_dependents'
    @slices['review_batches'][0]['kind'] = 'foundation'
    add_independent_batch(dependencies: ['S01'])
    prepare_accepted
    @status['slices']['S02'] = 'accepted'
    self_check('S02')
    accept('B02')
    File.write(File.join(@repo, 'base.txt'), '已修复的上游')
    accept('B01')
    ok, error = check
    refute ok
    assert_includes error, 'B02 accepted 快照已过时'
  end

  def test_reopened_foundation_preserves_consumer_implementation_while_waiting
    @slice['review_boundary'] = 'before_dependents'
    @slices['review_batches'][0]['kind'] = 'foundation'
    add_independent_batch(dependencies: ['S01'])
    prepare_accepted
    @status['slices']['S02'] = 'accepted'
    self_check('S02')
    accept('B02')
    File.write(File.join(@repo, 'base.txt'), '上游返修')
    @status['slices']['S01'] = 'implemented'
    @status['review_batches']['B01']['state'] = 'pending'
    @status['slices']['S02'] = 'awaiting_revalidation'
    @status['review_batches']['B02']['state'] = 'pending'
    @status['acceptance']['A01'] = 'pending'
    @status['execution']['next_slice'] = 'S02'
    ok, error = check
    assert ok, error
    @status['slices']['S02'] = 'in_progress'
    @status['execution'].merge!('current_slice' => 'S02', 'next_slice' => nil)
    ok, error = check
    refute ok
    assert_includes error, '依赖 S01 尚未达到'
    @status['slices']['S01'] = 'accepted'
    @status['acceptance']['A01'] = 'passed'
    accept('B01')
    ok, error = check
    assert ok, error
    @status['slices']['S02'] = 'implemented'
    @status['execution']['current_slice'] = nil
    ok, error = check
    assert ok, error
  end

  def test_awaiting_revalidation_cannot_satisfy_same_batch_dependency
    @slices['slices'] << Marshal.load(Marshal.dump(@slice)).merge('id' => 'S02', 'task_ids' => ['T02'], 'dependencies' => ['S01'])
    @slices['review_batches'][0]['slice_ids'] << 'S02'
    @status['slices'].merge!('S01' => 'awaiting_revalidation', 'S02' => 'in_progress')
    self_check('S01')
    @status['execution'].merge!('current_slice' => 'S02', 'next_slice' => nil)
    ok, error = check
    refute ok
    assert_includes error, '依赖 S01 尚未达到'
  end

  def test_awaiting_revalidation_requires_preserved_report_and_pending_batch
    prepare_accepted
    @status['slices']['S01'] = 'awaiting_revalidation'
    @status['review_batches']['B01']['state'] = 'in_review'
    ok, error = check
    refute ok
    assert_includes error, '所属批次必须 pending'
    @status['review_batches']['B01']['state'] = 'pending'
    @status['reports'].clear
    ok, error = check
    refute ok
    assert_includes error, '实现与必要自测记录'
  end

  def test_old_snapshot_is_not_silently_treated_as_scoped_review
    prepare_accepted
    File.write(File.join(@goal, 'snapshots/B01.json'), JSON.generate(GoalCheck.capture(@repo, @baseline, @exclusions, @contracts)))
    ok, error = check
    refute ok
    assert_includes error, '需核实旧报告范围并显式迁移'
  end

  def test_final_does_not_allow_narrow_scope
    @slices['review_batches'][1]['snapshot_scope']['paths'] = ['src']
    ok, error = check
    refute ok
    assert_includes error, '最终批次不能限定 paths'
  end

  def test_scope_globs_are_rejected_instead_of_silently_matching_nothing
    @slices['review_batches'][0]['snapshot_scope']['paths'] = ['src/**']
    ok, error = check
    refute ok
    assert_includes error, '不支持 glob'
  end

  def test_runtime_execution_log_does_not_invalidate_final_but_rule_file_does
    complete
    File.write(File.join(@goal, 'execution-log.md'), '实际记录一次返工')
    ok, error = check
    assert ok, error
    FileUtils.mkdir_p(File.join(@repo, 'templates/goal'))
    File.write(File.join(@repo, 'templates/goal/execution-log.md'), '留证规则模板')
    ok, error = check
    refute ok
    assert_includes error, '最终审查快照未完整覆盖'
  end

  def test_cli_captures_batch_and_refuses_output_outside_snapshots
    write_docs
    result = nil
    capture_io { result = GoalCheck.cli(['--snapshot-batch', @goal, 'B01', File.join(@goal, 'snapshots/B01.json')]) }
    assert_equal 0, result
    data = JSON.parse(File.read(File.join(@goal, 'snapshots/B01.json')))
    assert_equal 'B01', data['batch_id']
    assert_equal 'batch', data['snapshot_kind']
    capture_io { result = GoalCheck.cli(['--snapshot-batch', @goal, 'B01', File.join(@repo, 'wrong.json')]) }
    assert_equal 1, result
    refute File.exist?(File.join(@repo, 'wrong.json'))
  end

  def test_final_includes_registered_contract_unchanged_since_baseline
    File.write(File.join(@repo, 'business.md'), '基线已有业务契约')
    git('add', 'business.md')
    git('-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '-qm', '记录已有契约')
    @baseline = git('rev-parse', 'HEAD').strip
    @status['execution']['baseline_commit'] = @baseline
    @slices['review_batches'][0]['snapshot_scope']['contracts'] << 'business.md'
    complete
    snapshot = JSON.parse(File.read(File.join(@goal, 'snapshots/FINAL.json')))
    assert_match(/\A[0-9a-f]{64}\z/, snapshot['files']['business.md'])
    assert_includes snapshot['contract_paths'], 'business.md'
    ok, error = check
    assert ok, error
  end

  def test_missing_batch_scope_requires_explicit_migration
    @slices['review_batches'][0].delete('snapshot_scope')
    ok, error = check
    refute ok
    assert_includes error, '旧批次需显式核实审查范围后迁移'
  end

  def test_template_cannot_prefill_passed_acceptance
    @status['acceptance']['A01'] = 'passed'
    write_docs
    checker = GoalCheck::Checker.new(@goal, template: true)
    refute checker.run
    assert_includes checker.errors.join, '模板中验收只能是 pending'
  end

  def reopen_as_awaiting(id, batch)
    @status['slices'][id] = 'awaiting_revalidation'
    @status['review_batches'][batch]['state'] = 'pending'
    @status['execution']['next_slice'] = id
  end

  def test_awaiting_revalidation_cannot_keep_passed_acceptance_without_valid_source
    prepare_accepted
    reopen_as_awaiting('S01', 'B01')
    ok, error = check
    refute ok
    assert_includes error, '没有其他当前有效的非最终已验收批次'
    @status['acceptance']['A01'] = 'pending'
    ok, error = check
    assert ok, error
  end

  def test_shared_acceptance_can_remain_passed_when_another_current_batch_proves_it
    @slice['review_boundary'] = 'before_dependents'
    @slices['review_batches'][0]['kind'] = 'foundation'
    add_independent_batch(dependencies: ['S01'])
    prepare_accepted
    self_check('S02')
    reopen_as_awaiting('S02', 'B02')
    ok, error = check
    assert ok, error
    @status['slices']['S02'] = 'in_progress'
    @status['execution'].merge!('current_slice' => 'S02', 'next_slice' => nil)
    ok, error = check
    assert ok, error
  end

  def test_final_coverage_alone_cannot_keep_awaiting_acceptance_passed
    prepare_accepted
    accept('FINAL')
    reopen_as_awaiting('S01', 'B01')
    ok, error = check
    refute ok
    assert_includes error, '没有其他当前有效的非最终已验收批次'
  end

  def test_final_coverage_does_not_make_stale_batch_a_valid_shared_acceptance_source
    add_independent_batch
    FileUtils.mkdir_p(File.join(@repo, 'consumer'))
    File.write(File.join(@repo, 'consumer/code.rb'), '已审代码')
    prepare_accepted
    @status['slices']['S02'] = 'accepted'
    self_check('S02')
    accept('B02')
    reopen_as_awaiting('S01', 'B01')
    File.write(File.join(@repo, 'consumer/code.rb'), '变化后的代码')
    accept('FINAL')
    ok, error = check
    refute ok
    assert_includes error, '没有其他当前有效的非最终已验收批次'
  end

end
