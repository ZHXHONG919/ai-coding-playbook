#!/usr/bin/env ruby
# frozen_string_literal: true

# v3：任务只记录进度，结果证据随实际增量更新。
# 校验覆盖、版本和记录一致性；不证明业务预期正确或实际执行过测试。
require 'yaml'
require 'json'
require 'digest'
require 'open3'
require 'pathname'
require 'fileutils'

module GoalV3
  class Invalid < StandardError; end
  EXPECTED_KEYS = %w[entry action object context outcome counterexample].freeze
  RUNTIME_DIRS = %w[runs snapshots blobs].freeze
  RUNTIME_FILES = %w[status.yaml].freeze

  def self.require!(condition, message)
    raise Invalid, message unless condition
  end

  def self.mapping(value, label)
    require!(value.is_a?(Hash) && value.keys.all? { |key| key.is_a?(String) }, "#{label} 必须是字符串键的对象")
    value
  end

  def self.string(value, label)
    require!(value.is_a?(String) && !value.strip.empty?, "#{label} 必须是非空字符串")
    value
  end

  def self.list(value, label)
    require!(value.is_a?(Array), "#{label} 必须是列表")
    value
  end

  def self.ids(value, allowed, label)
    values = list(value, label)
    require!(values.all? { |id| id.is_a?(String) } && values.uniq == values && (values - allowed).empty?, "#{label} 含重复或不存在的 ID")
    values
  end

  def self.canonical(value)
    case value
    when Hash then value.keys.sort.to_h { |key| [key, canonical(value[key])] }
    when Array then value.map { |item| canonical(item) }
    else value
    end
  end

  def self.digest(value)
    Digest::SHA256.hexdigest(JSON.generate(canonical(value)))
  end

  def self.relative(path)
    string(path, '路径')
    clean = Pathname.new(path).cleanpath.to_s
    require!(!Pathname.new(path).absolute? && clean == path && clean != '.' && clean != '..' && !clean.start_with?('../') && !clean.split('/').include?('.git'), "非法相对路径：#{path}")
    path
  end

  def self.safe_file(root, path, required: true)
    relative(path)
    current = root
    path.split('/').each do |part|
      current = File.join(current, part)
      require!(!File.symlink?(current), "v3不支持符号链接：#{path}")
    end
    require!(!required || File.file?(current), "文件不存在：#{path}")
    current
  end

  def self.nonsecret_path!(path)
    name = File.basename(path)
    # 只允许精确的脱敏示例名；备份、环境实值文件和任意 .env.* 仍拒绝。
    env_secret = name.start_with?('.env') && !%w[.env.example .env.local.example .env.sample .env.template].include?(name)
    require!(!env_secret && !%w[id_rsa id_ed25519].include?(name) && !name.end_with?('.pem', '.key'), "不能冻结可能含密钥的文件 #{path}；请引用项目批准的脱敏配置，并在验证证据记录环境标识")
  end

  def self.yaml_bytes(bytes, label)
    mapping(YAML.safe_load(bytes, aliases: false), label)
  rescue Psych::Exception => e
    raise Invalid, "#{label} YAML 无效：#{e.message}"
  end

  def self.git(repo, *args)
    out, err, status = Open3.capture3('git', '-C', repo, *args)
    require!(status.success?, "Git 只读检查失败 #{args.first}：#{err.strip}")
    out
  end

  def self.acyclic(items, label)
    visited, active = [], []
    walk = lambda do |id|
      return if visited.include?(id)
      require!(!active.include?(id), "#{label} 依赖成环：#{id}")
      active << id
      items[id].fetch('depends_on', []).each { |dep| walk.call(dep) }
      active.pop
      visited << id
    end
    items.keys.each { |id| walk.call(id) }
  end

  # 只检查模板结构，不把模板视为执行/验收证据。
  def self.validate_contract(doc)
    mapping(doc, 'goal.yaml')
    require!(doc['schema_version'] == 3, '不支持该 Goal schema；只接受 schema_version: 3，不迁移或回退旧包')
    require!((doc.keys - %w[schema_version baseline_commit decisions results tasks inputs]).empty?, 'goal.yaml 含不支持的字段；v3 不允许自定义范围或排除路径')
    string(doc['baseline_commit'], 'baseline_commit')
    decisions = mapping(doc['decisions'], 'decisions')
    decisions.each { |id, value| string(mapping(value, id)['text'], "#{id}.text") }
    results = mapping(doc['results'], 'results')
    require!(!results.empty?, 'results 不能为空')
    results.each do |id, value|
      result = mapping(value, id)
      require!(%w[user_result shared_foundation].include?(result['kind']), "#{id}.kind 无效")
      require!(result['revision'].is_a?(Integer) && result['revision'] > 0, "#{id}.revision 必须是正整数")
      string(result['owner'], "#{id}.owner")
      expected = mapping(result['expected'], "#{id}.expected")
      EXPECTED_KEYS.each { |key| string(expected[key], "#{id}.expected.#{key}") }
      sources = list(result['sources'], "#{id}.sources")
      require!(!sources.empty?, "#{id}.sources 不能为空")
      sources.each do |source|
        mapping(source, "#{id}.source")
        relative(source['path'])
        string(source['anchor'], "#{id}.source.anchor")
      end
      ids(result['decisions'], decisions.keys, "#{id}.decisions")
      ids(result['depends_on'], results.keys, "#{id}.depends_on")
    end
    tasks = mapping(doc['tasks'], 'tasks')
    tasks.each do |id, value|
      task = mapping(value, id)
      string(task['owner'], "#{id}.owner")
      string(task['work'], "#{id}.work")
      string(task['self_check'], "#{id}.self_check")
      ids(task['results'], results.keys, "#{id}.results")
      ids(task['depends_on'], tasks.keys, "#{id}.depends_on")
    end
    list(doc.fetch('inputs', []), 'inputs').each { |path| relative(path) }
    acyclic(results, '结果')
    acyclic(tasks, '任务')
    doc
  end

  def self.load_contract(goal_dir)
    path = safe_file(goal_dir, 'goal.yaml', required: false)
    require!(File.file?(path) || !File.file?(File.join(goal_dir, 'slices.yaml')), '不支持仅含 slices.yaml 的旧 Goal 包；必须使用 schema_version: 3 的 goal.yaml，不迁移或回退')
    validate_contract(yaml_bytes(File.binread(safe_file(goal_dir, 'goal.yaml')), 'goal.yaml'))
  end

  class Workspace
    attr_reader :goal, :repo, :prefix, :doc, :base

    def initialize(goal_dir)
      @goal = File.realpath(goal_dir)
      @doc = GoalV3.load_contract(@goal)
      status_path = GoalV3.safe_file(@goal, 'status.yaml', required: false)
      if File.file?(status_path)
        status = GoalV3.yaml_bytes(File.binread(status_path), 'status.yaml')
        GoalV3.require!(status['schema_version'] == 3, '不支持该 status.yaml schema；只接受 schema_version: 3，不迁移或回退旧包')
      end
      @repo = File.realpath(GoalV3.git(@goal, 'rev-parse', '--show-toplevel').strip)
      @prefix = Pathname.new(@goal).relative_path_from(Pathname.new(@repo)).to_s
      GoalV3.require!(@prefix != '..' && !@prefix.start_with?('../'), 'Goal 必须位于当前 Git 仓库内')
      @base = GoalV3.git(@repo, 'rev-parse', '--verify', "#{@doc['baseline_commit']}^{commit}").strip
      GoalV3.require!(@doc['baseline_commit'] == @base, 'baseline_commit 必须固定为完整 commit ID')
      @object_format = GoalV3.git(@repo, 'rev-parse', '--show-object-format').strip
      GoalV3.require!(%w[sha1 sha256].include?(@object_format), '不支持该 Git object format')
    end

    def repo_path(name)
      @prefix == '.' ? name : "#{@prefix}/#{name}"
    end

    def runtime?(path)
      RUNTIME_FILES.any? { |name| path == repo_path(name) } ||
        RUNTIME_DIRS.any? { |name| path == repo_path(name) || path.start_with?(repo_path(name) + '/') }
    end

    def baseline_files
      @baseline_files ||= GoalV3.git(@repo, 'ls-tree', '-r', '-z', @base).split("\0").to_h do |line|
        info, path = line.split("\t", 2)
        mode, type, oid = info.split(' ')
        GoalV3.relative(path)
        GoalV3.require!(type == 'blob' && %w[100644 100755].include?(mode), "v3不支持符号链接或 submodule：#{path}")
        [path, { 'mode' => mode, 'oid' => oid }]
      end.reject { |path, _entry| runtime?(path) }
    end

    def git_blob_id(bytes)
      content = "blob #{bytes.bytesize}\0".b + bytes
      @object_format == 'sha1' ? Digest::SHA1.hexdigest(content) : Digest::SHA256.hexdigest(content)
    end

    def write_once(path, bytes)
      full = GoalV3.safe_file(@goal, path, required: false)
      FileUtils.mkdir_p(File.dirname(full))
      File.open(full, File::WRONLY | File::CREAT | File::EXCL, 0o644) { |file| file.write(bytes) }
    rescue Errno::EEXIST
      raise Invalid, "不可覆盖已冻结文件：#{path}"
    end

    def store_blob(bytes)
      sha = Digest::SHA256.hexdigest(bytes)
      path = "blobs/#{sha}"
      full = GoalV3.safe_file(@goal, path, required: false)
      if File.exist?(full)
        GoalV3.require!(Digest::SHA256.file(full).hexdigest == sha, "冻结内容已损坏：#{path}")
      else
        write_once(path, bytes)
      end
      sha
    end

    def current(store: false)
      paths = GoalV3.git(@repo, 'ls-files', '-z', '--cached', '--others', '--exclude-standard').split("\0")
      paths += @doc['results'].values.flat_map { |result| result['sources'].map { |source| source['path'] } }
      paths += @doc.fetch('inputs', []) + [repo_path('goal.yaml')]
      paths = paths.uniq.reject { |path| runtime?(path) }.sort
      files = {}
      paths.each do |path|
        GoalV3.nonsecret_path!(path)
        full = GoalV3.safe_file(@repo, path, required: false)
        next unless File.exist?(full)
        GoalV3.require!(File.file?(full), "v3只捕获文件，不支持 submodule/目录输入：#{path}")
        bytes = File.binread(full)
        entry = { 'mode' => (File.stat(full).mode & 0o111).zero? ? '100644' : '100755', 'oid' => git_blob_id(bytes) }
        if entry != baseline_files[path]
          entry['blob'] = store ? store_blob(bytes) : Digest::SHA256.hexdigest(bytes)
        end
        files[path] = entry
      end
      snapshot = { 'schema_version' => 3, 'baseline_commit' => @base, 'goal_path' => repo_path('goal.yaml'), 'files' => files }
      read_current = ->(path) { File.binread(GoalV3.safe_file(@repo, path)) }
      snapshot['contract_hashes'] = contracts(@doc, snapshot, &read_current)
      snapshot
    end

    def contracts(contract, snapshot, &read)
      hashes = {}
      inputs = contract.fetch('inputs', []).to_h do |path|
        GoalV3.require!(!runtime?(path) && snapshot['files'].key?(path), "运行输入未被冻结：#{path}")
        [path, Digest::SHA256.hexdigest(read.call(path))]
      end
      compute = lambda do |id|
        return hashes[id] if hashes.key?(id)
        result = contract['results'].fetch(id)
        sources = result['sources'].to_h do |source|
          path = source['path']
          GoalV3.require!(!runtime?(path) && snapshot['files'].key?(path), "#{id} 来源未被冻结或位于执行记录中：#{path}")
          [path, Digest::SHA256.hexdigest(read.call(path))]
        end
        decisions = result['decisions'].to_h { |decision| [decision, contract['decisions'][decision]] }
        dependencies = result['depends_on'].to_h { |dependency| [dependency, compute.call(dependency)] }
        # owner 是交接信息；它仍进入完整差异审查，但不改变已验证的业务约定。
        semantic_result = result.reject { |key, _value| key == 'owner' }
        hashes[id] = GoalV3.digest('result' => semantic_result, 'sources' => sources, 'decisions' => decisions, 'dependencies' => dependencies, 'inputs' => inputs)
      end
      contract['results'].keys.each { |id| compute.call(id) }
      hashes
    end

    def ref_bytes(ref, directory)
      GoalV3.mapping(ref, '证据引用')
      path = GoalV3.relative(ref['path'])
      GoalV3.require!(path.start_with?(directory + '/'), "引用必须位于 #{directory}/：#{path}")
      sha = ref['sha256']
      GoalV3.require!(sha.is_a?(String) && sha.match?(/\A[0-9a-f]{64}\z/), "#{path} 缺少 SHA-256")
      bytes = File.binread(GoalV3.safe_file(@goal, path))
      GoalV3.require!(Digest::SHA256.hexdigest(bytes) == sha, "已冻结证据内容发生变化：#{path}")
      bytes
    end

    def frozen_bytes(snapshot, path)
      entry = snapshot['files'].fetch(path)
      if entry['blob']
        sha = entry['blob']
        GoalV3.require!(sha.is_a?(String) && sha.match?(/\A[0-9a-f]{64}\z/), "无效 blob 摘要：#{path}")
        bytes = File.binread(GoalV3.safe_file(@goal, "blobs/#{sha}"))
        GoalV3.require!(Digest::SHA256.hexdigest(bytes) == sha && git_blob_id(bytes) == entry['oid'], "冻结内容摘要不符：#{path}")
        bytes
      else
        GoalV3.require!(entry == baseline_files[path], "#{path} 不属于基线且缺少可恢复内容")
        GoalV3.git(@repo, 'cat-file', 'blob', entry['oid']).b
      end
    end

    def load_snapshot(ref)
      snapshot = GoalV3.mapping(JSON.parse(ref_bytes(ref, 'snapshots')), 'snapshot')
      GoalV3.require!(snapshot['schema_version'] == 3 && snapshot['baseline_commit'] == @base && snapshot['goal_path'] == repo_path('goal.yaml'), '快照 schema、基线或 Goal 归属不符')
      GoalV3.mapping(snapshot['files'], 'snapshot.files').each do |path, entry|
        GoalV3.relative(path)
        GoalV3.require!(!runtime?(path), "快照不得包含运行记录：#{path}")
        GoalV3.mapping(entry, path)
        GoalV3.require!(%w[100644 100755].include?(entry['mode']), "不支持的文件类型：#{path}")
        if entry['blob']
          frozen_bytes(snapshot, path)
        else
          GoalV3.require!(entry == baseline_files[path], "#{path} 不属于基线且缺少可恢复内容")
        end
      end
      GoalV3.require!(snapshot['files'].key?(repo_path('goal.yaml')), '快照遗漏 goal.yaml')
      contract = GoalV3.validate_contract(GoalV3.yaml_bytes(frozen_bytes(snapshot, repo_path('goal.yaml')), '冻结 goal.yaml'))
      GoalV3.require!(contract['baseline_commit'] == @base, '冻结契约基线不一致')
      actual = contracts(contract, snapshot) { |path| frozen_bytes(snapshot, path) }
      GoalV3.require!(snapshot['contract_hashes'] == actual, '快照的契约摘要与冻结来源不符')
      [snapshot, contract]
    rescue JSON::ParserError => e
      raise Invalid, "快照 JSON 无效：#{e.message}"
    end

    def baseline_snapshot
      { 'files' => baseline_files, 'contract_hashes' => {} }
    end
  end

  def self.changed_paths(before, after)
    (before['files'].keys | after['files'].keys).select do |path|
      # blob 只负责恢复；内容身份由 Git object ID 与执行位共同决定。
      left, right = before['files'][path], after['files'][path]
      left && right ? left.values_at('mode', 'oid') != right.values_at('mode', 'oid') : left != right
    end.sort
  end

  def self.capture(goal_dir, id)
    require!(id.is_a?(String) && id.match?(/\A[A-Za-z0-9][A-Za-z0-9_-]*\z/), '快照 ID 只允许字母、数字、下划线和短横线')
    workspace = Workspace.new(goal_dir)
    snapshot = workspace.current(store: true)
    path = "snapshots/#{id}.json"
    bytes = JSON.pretty_generate(snapshot) + "\n"
    workspace.write_once(path, bytes)
    { 'path' => path, 'sha256' => Digest::SHA256.hexdigest(bytes), 'contract_hashes' => snapshot['contract_hashes'] }
  end

  def self.diff(goal_dir, from_ref, to_ref)
    workspace = Workspace.new(goal_dir)
    before = from_ref ? workspace.load_snapshot(from_ref).first : workspace.baseline_snapshot
    after = workspace.load_snapshot(to_ref).first
    changed_paths(before, after)
  end

  def self.consumers(results, impacted)
    affected = impacted.dup
    loop do
      added = results.keys.select { |id| !(results[id]['depends_on'] & affected).empty? } - affected
      break if added.empty?
      affected.concat(added)
    end
    affected.uniq
  end

  def self.forward_contract!(before, after)
    return unless before
    removed = before['results'].keys - after['results'].keys
    require!(removed.empty?, "v3不允许删除结果以缩小完成范围：#{removed.join('、')}；需要显式迁移审查")
    before['results'].each do |id, result|
      require!(after['results'][id]['revision'] >= result['revision'], "#{id}.revision 不可回退")
    end
  end

  def self.ref_identity(ref)
    return nil if ref.nil?
    mapping(ref, '版本引用')
    ref.values_at('path', 'sha256')
  end

  def self.recovery_state(status, doc)
    string(status['next_action'], 'next_action') if status.key?('next_action')
    list(status.fetch('constraints', []), 'constraints').each { |constraint| string(constraint, 'constraint') }
    workers = list(status.fetch('active_workers', []), 'active_workers')
    worker_ids, scopes, resources = [], [], []
    workers.each do |worker|
      mapping(worker, 'worker')
      require!((worker.keys - %w[id task state write_scope resource_scope]).empty?, 'worker 包含未知字段；请核对文件与资源操作范围')
      worker_ids << string(worker['id'], 'worker.id')
      require!(doc['tasks'].key?(worker['task']), 'worker.task 不存在')
      require!(%w[running stale].include?(worker['state']), 'worker.state 必须为 running 或 stale')
      scope = list(worker['write_scope'], 'worker.write_scope').map { |path| relative(path) }
      resource_scope = list(worker.fetch('resource_scope', []), 'worker.resource_scope').map do |resource|
        name = string(resource, 'worker.resource_scope item')
        require!(name.match?(/\A[a-z][a-z0-9._:-]*\z/), '资源标识须为统一的小写名称，不使用 URL、凭据或路径')
        name
      end
      require!(resource_scope.uniq == resource_scope, 'worker.resource_scope 不得重复')
      require!(!scope.empty? || !resource_scope.empty?, 'worker 文件或资源操作范围至少一种非空')
      require!((resources & resource_scope).empty?, '活动或失联 worker 运行资源范围重叠；先核实释放')
      resources.concat(resource_scope)
      require!(scopes.none? { |other| scope.any? { |path| other.any? { |prior| path == prior || path.start_with?(prior + '/') || prior.start_with?(path + '/') } } }, '活动或失联 worker 写入范围重叠；先核实释放')
      scopes << scope
    end
    require!(worker_ids.uniq == worker_ids, 'worker.id 不得重复')
    gaps = list(status.fetch('open_gaps', []), 'open_gaps')
    gap_ids = gaps.map do |gap|
      mapping(gap, 'gap')
      string(gap['detail'], 'gap.detail')
      ids(gap['results'], doc['results'].keys, 'gap.results')
      require!([true, false].include?(gap.fetch('required', true)), 'gap.required 必须为布尔值')
      string(gap['id'], 'gap.id')
    end
    require!(gap_ids.uniq == gap_ids, 'gap.id 不得重复')
    [workers, gaps.select { |gap| gap.fetch('required', true) }]
  end

  def self.check(goal_dir, complete: false)
    workspace = Workspace.new(goal_dir)
    status = yaml_bytes(File.binread(safe_file(workspace.goal, 'status.yaml')), 'status.yaml')
    require!((status.keys - %w[schema_version state tasks runs next_action constraints active_workers open_gaps]).empty?, 'status.yaml 只保存进度、恢复索引和有序 runs；不允许人工 results 状态')
    require!(%w[active complete].include?(status['state']), 'status.state 必须为 active 或 complete')
    tasks = mapping(status['tasks'], 'status.tasks')
    require!(tasks.keys.sort == workspace.doc['tasks'].keys.sort, '任务进度与 goal.yaml 任务 ID 不一致')
    tasks.each { |id, state| require!(%w[todo in_progress done].include?(state), "#{id} 状态无效") }
    workers, required_gaps = recovery_state(status, workspace.doc)
    workspace.doc['tasks'].each do |id, task|
      next if tasks[id] == 'todo'
      require!(task['depends_on'].all? { |dep| tasks[dep] == 'done' }, "#{id} 的技术任务依赖尚未完成")
    end
    runs = list(status['runs'], 'status.runs')
    require!(runs.map { |ref| mapping(ref, 'run 引用')['path'] }.uniq.length == runs.length, 'runs 不能重复引用同一记录')
    previous_ref, previous_snapshot, previous_contract = nil, workspace.baseline_snapshot, nil
    passed = {}
    runs.each do |ref|
      run = yaml_bytes(workspace.ref_bytes(ref, 'runs'), ref['path'])
      require!(ref_identity(run['from']) == ref_identity(previous_ref), "#{ref['path']} 的 from 未衔接上一轮已审版本")
      target, contract = workspace.load_snapshot(run['to'])
      forward_contract!(previous_contract, contract)
      results = contract['results']
      owners = list(run['implementation_owners'], 'implementation_owners')
      require!(!owners.empty? && owners.all? { |owner| owner.is_a?(String) && !owner.strip.empty? }, 'implementation_owners 不能为空')
      review = mapping(run['review'], 'review')
      reviewer = string(review['owner'], 'review.owner')
      string(review['summary'], 'review.summary')
      blockers = review['blocking_findings']
      require!(blockers.is_a?(Integer) && blockers >= 0, 'review.blocking_findings 必须为非负整数')
      require!(!owners.include?(reviewer), '正式审查者必须独立于实现者')
      changes = list(run['changes'], 'changes')
      actual_paths = changed_paths(previous_snapshot, target)
      claimed_paths = changes.map { |change| relative(mapping(change, 'change')['path']) }
      require!(claimed_paths.uniq.length == claimed_paths.length && claimed_paths.sort == actual_paths, "#{ref['path']} changes 必须精确覆盖全部新增、删除和修改文件")
      impacted = []
      changes.each do |change|
        affected = ids(change['results'], results.keys, 'change.results')
        string(change['reason'], 'change.reason')
        require!(%w[behavior no_behavior].include?(change['disposition']), 'change.disposition 必须为 behavior 或 no_behavior')
        if change['disposition'] == 'behavior'
          require!(!affected.empty?, "行为改动必须归属结果：#{change['path']}")
          impacted.concat(affected)
        end
      end
      contract_changed = results.keys.select { |id| previous_snapshot['contract_hashes'][id] != target['contract_hashes'][id] }
      affected = consumers(results, impacted + contract_changed)
      affected.each { |id| passed.delete(id) }
      passed.delete_if { |id, hash| !results.key?(id) || target['contract_hashes'][id] != hash }
      checks = mapping(run['checks'], 'checks')
      ids(checks.keys, results.keys, 'checks')
      blocking_results = if review.key?('blocking_results')
        declared = ids(review['blocking_results'], results.keys, 'review.blocking_results')
        require!(blockers.zero? ? declared.empty? : !declared.empty?, '阻塞数量与结果范围不一致；不能用空范围绕过阻塞')
        declared
      else
        # 既有 v3 记录没有定向范围时保守处理，不猜测问题属于哪个结果。
        blockers.zero? ? [] : affected + checks.keys
      end
      require!(blockers.zero? || !blocking_results.empty?, '有阻塞的审查必须标明受影响结果或验证项')
      failed_results = checks.select { |_id, check| mapping(check, 'check')['state'] == 'failed' }.keys
      invalidated = consumers(results, failed_results + blocking_results)
      invalidated.each { |id| passed.delete(id) }
      checks.each do |id, check|
        mapping(check, "checks.#{id}")
        require!(%w[passed failed].include?(check['state']), "#{id}.state 必须为 passed 或 failed")
        require!(check['contract_hash'] == target['contract_hashes'][id], "#{id} 验证引用了旧决定、预期、来源或依赖")
        string(check['observed'], "#{id}.observed")
        evidence = list(check['evidence'], "#{id}.evidence")
        require!(!evidence.empty?, "#{id} 缺少实际观测证据")
        evidence.each { |item| workspace.ref_bytes(item, 'runs') }
        if check['state'] == 'passed' && !invalidated.include?(id)
          passed[id] = check['contract_hash']
        else
          passed.delete(id)
        end
      end
      previous_ref, previous_snapshot, previous_contract = run['to'], target, contract
    end
    forward_contract!(previous_contract, workspace.doc)
    current = workspace.current
    unreviewed = changed_paths(previous_snapshot, current)
    result_ids = workspace.doc['results'].keys
    passed.delete_if { |id, hash| current['contract_hashes'][id] != hash }
    pending = result_ids - passed.keys
    # 未审生产增量不擅自猜测影响；它阻止整体完成，不把历史结果全部打回。
    ready = !runs.empty? && pending.empty? && unreviewed.empty? && tasks.values.all? { |state| state == 'done' } && workers.empty? && required_gaps.empty?
    if complete || status['state'] == 'complete'
      require!(pending.empty?, "结果尚无当前有效证据：#{pending.join('、')}")
      require!(unreviewed.empty?, "审查后仍有未覆盖改动：#{unreviewed.first(8).join('、')}")
      require!(tasks.values.all? { |state| state == 'done' }, '完成前必需技术任务应完成')
      require!(!runs.empty?, '完成前必须有独立增量审查记录')
      require!(workers.empty?, '完成前必须核实并释放所有活动或失联 worker')
      require!(required_gaps.empty?, '完成前必须关闭必需缺口')
    end
    { 'schema_version' => 3, 'passed_results' => (result_ids & passed.keys), 'pending_results' => pending,
      'unreviewed_changes' => unreviewed, 'contract_hashes' => current['contract_hashes'], 'complete' => ready,
      'evidence_at_snapshot' => previous_ref, 'needs_impact_review' => !unreviewed.empty? }
  rescue KeyError, Errno::ENOENT, Errno::ENOTDIR => e
    raise Invalid, "v3 记录不完整：#{e.message}"
  end
  # 保留已发布的 v3 命令；旧格式不再有执行引擎或自动回退。
  def self.cli(argv)
    command, *args = argv
    case command
    when '--capture-v3'
      require!(args.length == 2, '用法：check-goal.rb --capture-v3 Goal目录 快照ID')
      puts JSON.pretty_generate(capture(*args))
    when '--delta-v3'
      require!(args.length == 2, '用法：check-goal.rb --delta-v3 Goal目录 已捕获快照ID')
      goal, id = args
      require!(id.match?(/\A[A-Za-z0-9][A-Za-z0-9_-]*\z/), '无效快照 ID')
      workspace = Workspace.new(goal)
      status = yaml_bytes(File.binread(safe_file(workspace.goal, 'status.yaml')), 'status.yaml')
      last_run = list(status['runs'], 'status.runs').last
      from = last_run && yaml_bytes(workspace.ref_bytes(last_run, 'runs'), 'run').fetch('to')
      path = "snapshots/#{id}.json"
      target = { 'path' => path, 'sha256' => Digest::SHA256.file(safe_file(workspace.goal, path)).hexdigest }
      changes = diff(goal, from, target).map do |name|
        { 'path' => name, 'results' => [], 'disposition' => 'pending', 'reason' => '待独立核对影响，不能直接用于通过记录' }
      end
      puts JSON.pretty_generate('from' => from, 'to' => target, 'changes' => changes)
    when '--template'
      require!(args.length == 1, '用法：check-goal.rb --template v3模板目录')
      load_contract(File.realpath(args.first))
      puts 'v3 模板契约结构检查通过；未检查运行状态或验收证据。'
    when '--snapshot', '--snapshot-batch', '--exclude', '--contract'
      raise Invalid, "不支持旧快照参数 #{command}；只支持 v3 的 --capture-v3 和 --delta-v3，不迁移或回退"
    else
      complete = command == '--complete'
      require!(complete ? args.length == 1 : argv.length == 1 && !command.start_with?('-'), '用法：check-goal.rb [--complete] Goal目录；或 --template v3模板目录、--capture-v3 Goal目录 快照ID、--delta-v3 Goal目录 快照ID')
      puts JSON.pretty_generate(check(complete ? args.first : command, complete: complete))
      puts 'v3 结构、差异与证据一致性检查通过；这不证明业务判断或审查语义正确。'
    end
    0
  rescue Invalid, SystemCallError, KeyError, TypeError => e
    warn e.message
    1
  end
end
