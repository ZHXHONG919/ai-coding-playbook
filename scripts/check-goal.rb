#!/usr/bin/env ruby
# frozen_string_literal: true

# 只检查结构、状态关系、证据文件和快照新鲜度；不能证明测试或代码审查语义正确。
require 'yaml'
require 'json'
require 'digest'
require 'open3'
require 'pathname'
require 'time'

module GoalCheck
  class Invalid < StandardError; end
  TASK_STATES = %w[todo in_progress implemented awaiting_revalidation accepted].freeze
  BATCH_STATES = %w[pending in_review accepted].freeze
  BATCH_KINDS = %w[functional foundation final].freeze
  RUNTIME_NAMES = %w[status.yaml resume.md execution-log.md runs validation cr snapshots].freeze
  CORE_CONTRACTS = %w[GOAL.md acceptance.md slices.yaml].freeze

  def self.require_value(condition, message)
    raise Invalid, message unless condition
  end

  def self.git(repo, *args)
    out, err, status = Open3.capture3('git', '-C', repo.to_s, *args)
    require_value(status.success?, "Git 只读检查失败：#{args.first}：#{err.strip}")
    out
  end

  def self.relative_path(path)
    require_value(path.is_a?(String) && !path.empty?, '路径必须是非空字符串')
    clean = Pathname.new(path).cleanpath.to_s
    require_value(!Pathname.new(path).absolute? && clean != '..' && !clean.start_with?('../') && clean != '.', "路径必须在仓库内：#{path}")
    clean
  end

  def self.digest_file(repo, path)
    file = File.join(repo, relative_path(path))
    return nil unless File.exist?(file) || File.symlink?(file)
    return Digest::SHA256.hexdigest("symlink\0#{File.readlink(file)}") if File.symlink?(file)
    require_value(File.file?(file), "快照只支持文件和符号链接：#{path}")
    Digest::SHA256.hexdigest("file\0#{File.stat(file).mode & 0o111}\0#{Digest::SHA256.file(file).hexdigest}")
  end

  def self.excluded?(path, exclusions)
    exclusions.any? { |prefix| path == prefix || path.start_with?(prefix + '/') }
  end

  def self.capture(repo, baseline, exclusions, contracts, allow_missing_contracts: false, scope: nil)
    repo = File.realpath(repo)
    require_value(File.realpath(git(repo, 'rev-parse', '--show-toplevel').strip) == repo, 'repo_root 必须是 Git 仓库根目录')
    base = git(repo, 'rev-parse', '--verify', "#{baseline}^{commit}").strip
    exclusions = exclusions.map { |p| relative_path(p) }.uniq.sort
    contracts = contracts.map { |p| relative_path(p) }.uniq.sort
    require_value(!exclusions.empty?, '快照必须显式声明 --exclude 执行记录路径')
    require_value(!contracts.empty?, '快照必须显式声明 --contract 契约路径')
    contracts.each do |path|
      require_value(!excluded?(path, exclusions), "契约不能被排除：#{path}")
      require_value(allow_missing_contracts || File.file?(File.join(repo, path)), "契约文件不存在：#{path}")
    end
    if scope
      baseline_paths = git(repo, 'ls-tree', '-r', '--name-only', '-z', base).split("\0")
      working_paths = git(repo, 'ls-files', '-z', '--cached', '--others', '--exclude-standard').split("\0")
      candidates = (baseline_paths + working_paths).uniq.select { |path| excluded?(path, scope) }
    else
      changed = git(repo, 'diff', '--no-renames', '--name-only', '-z', base, '--').split("\0")
      untracked = git(repo, 'ls-files', '--others', '--exclude-standard', '-z').split("\0")
      candidates = changed + untracked
    end
    paths = (candidates + contracts).uniq.reject { |p| excluded?(p, exclusions) }.sort
    {
      'schema_version' => 1, 'repo_root' => repo, 'baseline_commit' => base,
      'excluded_paths' => exclusions, 'contract_paths' => contracts,
      'files' => paths.each_with_object({}) { |p, out| out[p] = digest_file(repo, p) }
    }
  end

  def self.scope_paths(value, label)
    require_value(value.is_a?(Array) && value.all? { |path| path.is_a?(String) }, "#{label} 必须是路径列表")
    paths = value.map do |path|
      clean = relative_path(path)
      require_value(!clean.match?(/[\*\?\[\]{}]/), "#{label} 使用文件或目录前缀，不支持 glob：#{path}")
      clean
    end
    require_value(paths.uniq.length == paths.length, "#{label} 不能有重复路径")
    paths.sort
  end

  def self.snapshot_scope(batch)
    scope = batch['snapshot_scope']
    require_value(scope.is_a?(Hash), "#{batch['id']} 缺少 snapshot_scope；旧批次需显式核实审查范围后迁移")
    paths = scope_paths(scope.fetch('paths', []), "#{batch['id']}.snapshot_scope.paths")
    contracts = scope_paths(scope.fetch('contracts', []), "#{batch['id']}.snapshot_scope.contracts")
    if batch['kind'] == 'final'
      require_value(paths.empty?, "#{batch['id']} 最终批次不能限定 paths，必须覆盖全部差异")
    else
      require_value(!paths.empty? && !contracts.empty?, "#{batch['id']} 必须声明代码范围 paths 和相关业务契约 contracts")
    end
    [paths, contracts]
  end

  def self.canonical(value)
    case value
    when Hash then value.keys.sort.each_with_object({}) { |key, result| result[key] = canonical(value[key]) }
    when Array then value.map { |item| canonical(item) }
    else value
    end
  end

  # 只投影本批次与其前置批次，避免无关任务定义使已有证据失效。
  # 前置批次是验收单元，整个批次的范围与契约都属于消费者的版本输入。
  def self.related_batches(doc, batch_id)
    batches = doc.fetch('review_batches').to_h { |batch| [batch.fetch('id'), batch] }
    slices = doc.fetch('slices').to_h { |slice| [slice.fetch('id'), slice] }
    require_value(batches.key?(batch_id), "不存在批次：#{batch_id}")
    selected, pending = [], [batch_id]
    until pending.empty?
      id = pending.shift
      next if selected.include?(id)
      require_value(batches.key?(id), "依赖引用了不存在的批次：#{id}")
      selected << id
      members = doc['slices'].select { |slice| slice['review_batch'] == id }
      members.each do |slice|
        slice.fetch('dependencies').each do |dep|
          require_value(slices.key?(dep), "依赖任务不存在：#{dep}")
          pending << slices[dep].fetch('review_batch')
        end
      end
    end
    [selected.sort.map { |id| batches[id] }, doc['slices'].select { |slice| selected.include?(slice['review_batch']) }.sort_by { |slice| slice['id'] }]
  end

  def self.capture_batch(goal_dir, batch_id, allow_missing_contracts: false)
    goal = File.realpath(goal_dir)
    repo = File.realpath(git(goal, 'rev-parse', '--show-toplevel').strip)
    prefix = Pathname.new(goal).relative_path_from(Pathname.new(repo)).to_s
    doc = YAML.safe_load(File.read(File.join(goal, 'slices.yaml')), aliases: false)
    status = YAML.safe_load(File.read(File.join(goal, 'status.yaml')), aliases: false)
    batch = doc.fetch('review_batches').find { |item| item['id'] == batch_id }
    require_value(batch, "不存在批次：#{batch_id}")
    exclusions = RUNTIME_NAMES.map { |name| "#{prefix}/#{name}" }
    snapshot_scope(batch)
    if batch['kind'] == 'final'
      contracts = doc['review_batches'].flat_map { |item| snapshot_scope(item).last }
      contracts += CORE_CONTRACTS.map { |name| "#{prefix}/#{name}" }
      contracts << "#{prefix}/review-policy.md" if File.file?(File.join(goal, 'review-policy.md'))
      manifest = capture(repo, status.fetch('execution').fetch('baseline_commit'), exclusions, contracts.uniq, allow_missing_contracts: allow_missing_contracts)
      return manifest.merge('schema_version' => 2, 'batch_id' => batch_id, 'snapshot_kind' => 'final', 'scope_paths' => [])
    end
    batches, slices = related_batches(doc, batch_id)
    scopes = batches.map { |item| snapshot_scope(item) }
    paths = scopes.flat_map(&:first).uniq.sort
    contracts = scopes.flat_map(&:last).uniq.sort
    contracts << "#{prefix}/review-policy.md" if File.file?(File.join(goal, 'review-policy.md'))
    manifest = capture(repo, status.fetch('execution').fetch('baseline_commit'), exclusions, contracts.uniq, allow_missing_contracts: allow_missing_contracts, scope: paths)
    projection = canonical('review_batches' => batches, 'slices' => slices)
    manifest.merge(
      'schema_version' => 2, 'batch_id' => batch_id, 'snapshot_kind' => 'batch', 'scope_paths' => paths,
      'contract_projection' => Digest::SHA256.hexdigest(JSON.generate(projection))
    )
  end

  class Checker
    attr_reader :errors

    def initialize(goal_dir, template: false)
      @goal = File.realpath(goal_dir)
      @template = template
      @errors = []
    end

    def ensure!(condition, message)
      GoalCheck.require_value(condition, message)
    end

    def load_yaml(name)
      file = File.join(@goal, name)
      ensure!(File.file?(file), "缺少 #{name}")
      data = YAML.safe_load(File.read(file), permitted_classes: [], permitted_symbols: [], aliases: false)
      ensure!(data.is_a?(Hash), "#{name} 必须是映射")
      data
    end

    def mapping(value, label)
      ensure!(value.is_a?(Hash), "#{label} 必须是映射")
      value
    end

    def array(value, label)
      ensure!(value.is_a?(Array), "#{label} 必须是列表")
      value
    end

    def string_array(value, label)
      items = array(value, label)
      items.each { |item| text(item, label) }
      ensure!(items.uniq == items, "#{label} 不能有重复项")
      items
    end

    def text(value, label)
      ensure!(value.is_a?(String) && !value.strip.empty?, "#{label} 必须是非空文本")
      value
    end

    def unique_ids(items, label)
      ids = items.map { |item| text(mapping(item, label)['id'], "#{label}.id") }
      ensure!(ids.uniq == ids, "#{label} 的 id 重复")
      ids
    end

    def report_file(path, label)
      text(path, label)
      rel = path.start_with?('.goal/') ? path.sub(%r{\A\.goal/}, '') : path
      rel = GoalCheck.relative_path(rel)
      full = File.expand_path(rel, @goal)
      ensure!(File.file?(full), "#{label} 文件不存在：#{path}")
      ensure!(File.size(full) > 0, "#{label} 文件为空：#{path}")
      ensure!(File.realpath(full).start_with?(@goal + '/'), "#{label} 必须位于当前 Goal 目录内")
      full
    end

    # 这里只登记尚未交回写权限的实现 worker；只读核验由批次报告管理。
    def validate_workers(status, execution, task_states, by_id, run_mode)
      workers = array(status.fetch('active_workers', []), 'active_workers')
      unique_ids(workers, 'active_workers')
      scopes = {}
      workers.each do |worker|
        id = worker['id']
        slice_id = text(worker['slice_id'], "worker #{id}.slice_id")
        ensure!(by_id.key?(slice_id), "worker #{id} 引用了不存在的任务：#{slice_id}")
        state = worker['state']
        ensure!(%w[running stale].include?(state), "worker #{id}.state 必须是 running 或 stale")
        allowed = state == 'running' ? %w[in_progress] : %w[in_progress awaiting_revalidation]
        ensure!(allowed.include?(task_states[slice_id]), "worker #{id} 与任务 #{slice_id} 状态不一致")
        owner = mapping(by_id[slice_id]['implementation_owner'], "#{slice_id}.implementation_owner")
        ensure!(%w[worker hybrid].include?(owner['mode']), "worker #{id} 的任务 #{slice_id} 必须声明 worker 或 hybrid 实现所有者")
        raw_paths = string_array(worker['write_scope'], "worker #{id}.write_scope")
        ensure!(raw_paths.none? { |path| path.split('/').include?('..') }, "worker #{id}.write_scope 不能包含父目录 ..")
        paths = GoalCheck.scope_paths(raw_paths, "worker #{id}.write_scope")
        ensure!(!paths.empty?, "worker #{id}.write_scope 不能为空")
        scopes.each do |other_id, other_paths|
          overlap = paths.any? do |path|
            other_paths.any? { |other| path == other || path.start_with?(other + '/') || other.start_with?(path + '/') }
          end
          ensure!(!overlap, "worker #{id} 与 #{other_id} 的写范围重叠；stale 范围也须查实释放")
        end
        scopes[id] = paths
        report_file(worker['report'], "worker #{id} 报告") if worker.key?('report') && !worker['report'].nil?
      end
      in_progress = task_states.select { |_id, state| state == 'in_progress' }.keys
      current = execution['current_slice']
      ensure!(current.nil? || in_progress.include?(current), 'current_slice 不能指向非 in_progress 任务')
      assigned = workers.map { |worker| worker['slice_id'] }
      unowned = in_progress - [current] - assigned
      ensure!(unowned.empty?, "进行中任务 #{unowned.join(', ')} 必须由 current_slice 或 active_workers 负责")
      if run_mode == 'single_slice'
        ensure!((in_progress + assigned).uniq.length <= 1, 'single_slice 模式不能同时执行或保留多个切片的写权限')
      end
      workers
    end

    def validate_snapshot(path, label, batch)
      manifest = JSON.parse(File.read(report_file(path, label)))
      ensure!(manifest.is_a?(Hash) && manifest['schema_version'] == 2, "#{label} 快照格式不支持；需核实旧报告范围并显式迁移，不能只重写哈希")
      ensure!(manifest['batch_id'] == batch['id'], "#{label} 快照批次不匹配")
      ensure!(manifest['snapshot_kind'] == (batch['kind'] == 'final' ? 'final' : 'batch'), "#{label} 快照范围类型不匹配")
      repo = text(manifest['repo_root'], "#{label}.repo_root")
      repo = File.realpath(repo)
      ensure!(@goal.start_with?(repo + '/'), "#{label} 不属于当前仓库")
      ensure!(GoalCheck.git(@goal, 'rev-parse', '--show-toplevel').strip == repo, "#{label} 仓库根目录不匹配")
      ensure!(manifest['baseline_commit'] == @baseline, "#{label} baseline_commit 与执行状态不一致")
      exclusions = array(manifest['excluded_paths'], "#{label}.excluded_paths")
      contracts = array(manifest['contract_paths'], "#{label}.contract_paths")
      files = mapping(manifest['files'], "#{label}.files")
      prefix = Pathname.new(@goal).relative_path_from(Pathname.new(repo)).to_s
      allowed = RUNTIME_NAMES.map { |name| "#{prefix}/#{name}" }
      exclusions.each do |exclusion|
        clean = GoalCheck.relative_path(exclusion)
        ensure!(allowed.any? { |base| clean == base || clean.start_with?(base + '/') }, "#{label} 不允许排除业务代码或契约：#{exclusion}")
      end
      if batch['kind'] == 'final'
        required_contracts = CORE_CONTRACTS.map { |name| "#{prefix}/#{name}" }
        required_contracts.each { |name| ensure!(contracts.include?(name), "#{label} 未覆盖核心契约：#{name}") }
      end
      contracts.each do |name|
        ensure!(files.key?(name) && files[name].is_a?(String), "#{label} 契约缺少内容摘要：#{name}")
      end
      files.each do |name, digest|
        GoalCheck.relative_path(name)
        ensure!(digest.nil? || (digest.is_a?(String) && digest.match?(/\A[0-9a-f]{64}\z/)), "#{label} 文件摘要无效：#{name}")
      end
      current = GoalCheck.capture_batch(@goal, batch['id'], allow_missing_contracts: true)
      changed = (files.keys | current['files'].keys).select { |name| current['files'][name] != files[name] || current['files'].key?(name) != files.key?(name) }
      %w[scope_paths contract_paths contract_projection excluded_paths].each do |key|
        changed << "#{key}（审查范围或相关执行契约）" unless manifest[key] == current[key]
      end
      [manifest, current, changed]
    end

    def run
      slices_doc = load_yaml('slices.yaml')
      status = load_yaml('status.yaml')
      ensure!(slices_doc['schema_version'] == 2 && status['schema_version'] == 2, '仅检查 schema_version: 2；旧 Goal 必须显式迁移，不能静默改策略')
      ensure!(%w[functional_batch per_slice].include?(status['review_strategy']), 'review_strategy 必须是 functional_batch 或 per_slice')
      slices = array(slices_doc['slices'], 'slices')
      batches = array(slices_doc['review_batches'], 'review_batches')
      ensure!(!slices.empty? && !batches.empty?, '任务和审查批次不能为空')
      ids = unique_ids(slices, 'slices')
      batch_ids = unique_ids(batches, 'review_batches')
      by_id = slices.each_with_object({}) { |s, h| h[s['id']] = s }
      by_batch = batches.each_with_object({}) { |b, h| h[b['id']] = b }
      task_states = mapping(status['slices'], 'status.slices')
      batch_states = mapping(status['review_batches'], 'status.review_batches')
      ensure!(task_states.keys.sort == ids.sort, '任务状态与任务定义不一致')
      ensure!(batch_states.keys.sort == batch_ids.sort, '批次状态与批次定义不一致')
      acceptance = mapping(status['acceptance'], 'status.acceptance')
      ensure!(!acceptance.empty? && acceptance.values.all? { |v| %w[pending passed].include?(v) }, '验收状态必须是 pending 或 passed，且不能为空')
      task_states.each { |id, state| ensure!(TASK_STATES.include?(state), "#{id} 任务状态无效") }
      reports = mapping(status['reports'], 'status.reports')
      task_states.each do |id, state|
        report_file(reports[id], "#{id} 实现与必要自测记录") if %w[implemented awaiting_revalidation accepted].include?(state)
      end
      execution = mapping(status['execution'], 'execution')
      ensure!(%w[ready in_progress blocked needs_human_intervention requirement_delta_pending complete].include?(execution['state']), 'execution.state 无效')
      @baseline = text(execution['baseline_commit'], 'execution.baseline_commit')
      unless @template
        ensure!(@baseline.match?(/\A[0-9a-f]{40,64}\z/), 'baseline_commit 必须是完整提交摘要')
        ensure!(GoalCheck.git(@goal, 'rev-parse', '--verify', "#{@baseline}^{commit}").strip == @baseline, 'baseline_commit 不存在或不精确')
      end
      run_mode = status['run_mode'] || mapping(status['run_control'], 'run_control')['mode']
      ensure!(%w[continuous single_slice prepare_only release_gate].include?(run_mode), 'run_mode 无效；审查频率须独立使用 review_strategy')
      if @template
        ensure!(task_states.values.all? { |v| v == 'todo' }, '模板中任务只能是 todo')
        ensure!(batch_states.values.all? { |v| v.is_a?(Hash) && v['state'] == 'pending' }, '模板中批次只能是 pending')
        ensure!(acceptance.values.all? { |value| value == 'pending' }, '模板中验收只能是 pending，不能预填 passed')
      end
      %w[current_slice next_slice].each do |key|
        ensure!(execution.key?(key) && (execution[key].nil? || ids.include?(execution[key])), "execution.#{key} 引用了不存在的任务")
      end
      workers = validate_workers(status, execution, task_states, by_id, run_mode)
      if execution['next_slice']
        ensure!(%w[todo in_progress awaiting_revalidation].include?(task_states[execution['next_slice']]), 'next_slice 不能指向已实现或已验收任务')
      end
      slices.each do |slice|
        id = slice['id']
        %w[task_ids dependencies scope non_goals required_docs tooling_prerequisite_ids].each { |key| string_array(slice[key], "#{id}.#{key}") }
        ensure!(!slice['task_ids'].empty? && !slice['scope'].empty?, "#{id} 必须声明任务和范围")
        text(slice['lane'], "#{id}.lane")
        ensure!(batch_ids.include?(slice['review_batch']), "#{id} 缺少有效 review_batch")
        ensure!(%w[batch before_dependents task].include?(slice['review_boundary']), "#{id} review_boundary 无效")
        owner = mapping(slice['implementation_owner'], "#{id}.implementation_owner")
        ensure!(%w[main_thread worker hybrid].include?(owner['mode']), "#{id} 实现者模式无效")
        text(owner['reason'], "#{id}.implementation_owner.reason")
        ensure!(!string_array(owner['ownership'], "#{id}.ownership").empty?, "#{id} 缺少 ownership")
        mapping(slice['evidence'], "#{id}.evidence")
        checks = array(slice['min_self_check'], "#{id}.min_self_check")
        ensure!(!checks.empty?, "#{id} 缺少必要自测")
        checks.each { |check| %w[behavior risk method expected].each { |key| text(mapping(check, "#{id} 自测")[key], "#{id} 自测 #{key}") } }
        slice['dependencies'].each do |dep|
          ensure!(ids.include?(dep) && dep != id, "#{id} 依赖无效：#{dep}")
          same_batch_foundation = by_id[dep]['review_boundary'] == 'before_dependents' && by_id[dep]['review_batch'] == slice['review_batch']
          ensure!(!same_batch_foundation, "#{id} 同一基础批次内依赖 #{dep} 会等待自身验收；请合并任务或拆成有先后关系的批次")
          next unless %w[in_progress implemented accepted].include?(task_states[id])
          cross_batch = by_id[dep]['review_batch'] != slice['review_batch']
          required = cross_batch || by_id[dep]['review_boundary'] == 'before_dependents' ? %w[accepted] : %w[implemented accepted]
          ensure!(required.include?(task_states[dep]), "#{id} 的依赖 #{dep} 尚未达到继续条件")
        end
        batch = by_batch[slice['review_batch']]
        if task_states[id] == 'awaiting_revalidation'
          ensure!(mapping(batch_states[batch['id']], "#{batch['id']} 批次状态")['state'] == 'pending', "#{id} 待复验时所属批次必须 pending")
        end
        ensure!(batch['kind'] == 'foundation', "#{id} 提前审查必须单列 foundation 批次") if slice['review_boundary'] == 'before_dependents'
        if batch['kind'] == 'foundation'
          ensure!(slice['review_boundary'] == 'before_dependents', "#{id} 基础批次必须声明 before_dependents")
        end
      end
      tooling_ids = slices.flat_map { |slice| slice['tooling_prerequisite_ids'] }.uniq
      tooling_path = File.join(@goal, 'tooling-prerequisites.yaml')
      if !tooling_ids.empty? || File.file?(tooling_path)
        catalog = mapping(load_yaml('tooling-prerequisites.yaml')['tooling_prerequisites'], 'tooling_prerequisites')
        ensure!((tooling_ids - catalog.keys).empty?, '任务引用了不存在的工具前置 ID')
        catalog.each do |id, raw|
          item = mapping(raw, "工具 #{id}")
          %w[capability selected_method cli authentication capability_boundary readiness].each { |key| ensure!(item.key?(key), "工具 #{id} 缺少 #{key}") }
          method = mapping(item['selected_method'], "工具 #{id}.selected_method")
          cli = mapping(item['cli'], "工具 #{id}.cli")
          if method['kind'] == 'cli'
            ensure!(cli['required'] == true && ![nil, '', 'not_applicable'].include?(cli['command']), "工具 #{id} CLI 配置不完整")
          else
            ensure!(cli['required'] != true, "工具 #{id} 未选择 CLI 却声明 CLI 必需")
          end
        end
      end
      visiting, visited = [], []
      visit = lambda do |id|
        ensure!(!visiting.include?(id), "依赖存在循环：#{(visiting + [id]).join(' → ')}")
        return if visited.include?(id)
        visiting << id
        by_id[id]['dependencies'].each { |dep| visit.call(dep) }
        visiting.pop
        visited << id
      end
      ids.each { |id| visit.call(id) }
      # 任务无环仍可能因跨批次等待 accepted 产生死锁。
      batch_dependencies = batch_ids.each_with_object({}) { |id, map| map[id] = [] }
      slices.each do |slice|
        slice['dependencies'].each do |dep|
          source, target = slice['review_batch'], by_id[dep]['review_batch']
          batch_dependencies[source] << target unless source == target
        end
      end
      batch_visiting, batch_visited = [], []
      visit_batch = lambda do |id|
        ensure!(!batch_visiting.include?(id), "批次依赖存在循环：#{(batch_visiting + [id]).join(' → ')}")
        return if batch_visited.include?(id)
        batch_visiting << id
        batch_dependencies[id].uniq.each { |dep| visit_batch.call(dep) }
        batch_visiting.pop
        batch_visited << id
      end
      batch_ids.each { |id| visit_batch.call(id) }
      final_batches = batches.select { |batch| batch['kind'] == 'final' }
      ensure!(final_batches.length == 1, '必须有且仅有一个最终覆盖审查批次 kind: final')
      snapshots = {}
      batches.each do |batch|
        id = batch['id']
        ensure!(BATCH_KINDS.include?(batch['kind']), "#{id} 批次 kind 无效")
        GoalCheck.snapshot_scope(batch)
        members = string_array(batch['slice_ids'], "#{id}.slice_ids")
        ensure!(members.uniq == members, "#{id} slice_ids 重复")
        expected_members = slices.select { |s| s['review_batch'] == id }.map { |s| s['id'] }
        ensure!(members.sort == expected_members.sort, "#{id} 与任务 review_batch 映射不一致")
        ensure!(batch['kind'] == 'final' || !members.empty?, "#{id} 非最终批次不能为空")
        acceptance_ids = string_array(batch['acceptance_ids'], "#{id}.acceptance_ids")
        ensure!(!acceptance_ids.empty? && acceptance_ids.uniq == acceptance_ids && (acceptance_ids - acceptance.keys).empty?, "#{id} 验收映射无效")
        text(batch['earliest_real_path'], "#{id}.earliest_real_path")
        if status['review_strategy'] == 'per_slice' && batch['kind'] != 'final'
          ensure!(members.length == 1, "#{id} per_slice 策略必须每任务独立批次")
        end
        state = mapping(batch_states[id], "#{id} 批次状态")
        ensure!(BATCH_STATES.include?(state['state']), "#{id} 批次状态无效")
        ensure!(state['blocking_findings'].is_a?(Integer) && state['blocking_findings'] >= 0, "#{id} blocking_findings 必须是非负整数")
        %w[snapshot validation_report review_report].each { |key| ensure!(state.key?(key), "#{id} 缺少 #{key}") }
        if state['state'] == 'accepted'
          ensure!(state['blocking_findings'] == 0, "#{id} 有阻塞问题不能 accepted")
          ensure!(members.all? { |member| task_states[member] == 'accepted' }, "#{id} accepted 但任务未 accepted")
          ensure!(acceptance_ids.all? { |a| acceptance[a] == 'passed' }, "#{id} accepted 但验收未 passed")
          report_file(state['validation_report'], "#{id}.validation_report")
          report_file(state['review_report'], "#{id}.review_report")
          snapshots[id] = validate_snapshot(state['snapshot'], "#{id}.snapshot", batch)
        else
          ensure!(members.none? { |member| task_states[member] == 'accepted' }, "#{id} 未验收但任务已 accepted")
          if state['state'] == 'in_review'
            ensure!(members.all? { |member| task_states[member] == 'implemented' }, "#{id} 审查前任务必须 implemented")
            _manifest, _current, changed = validate_snapshot(state['snapshot'], "#{id}.snapshot", batch)
            ensure!(changed.empty?, "#{id} 在审快照已变化：#{changed.first(5).join('、')}；需重新固定版本")
          end
        end
      end
      ensure!((acceptance.keys - batches.flat_map { |b| b['acceptance_ids'] }).empty?, '存在未归属任何审查批次的验收项')
      final_id = final_batches.first['id']
      final_current = snapshots[final_id] && snapshots[final_id][2].empty?
      if snapshots[final_id]
        ensure!(final_current, '最终审查快照未完整覆盖当前全部改动及契约，必须补审实际差异')
      end
      snapshots.each do |id, (_manifest, _current, changed)|
        ensure!(changed.empty? || final_current, "#{id} accepted 快照已过时：#{changed.first(5).join('、')}；需定向复验复审或由最新最终审查覆盖")
      end
      # 验收 ID 表示完整断言。共享 ID 可由其他仍有效批次证明，不能因一个
      # 消费者待复验便使已恢复的前置批次无法 accepted；最终覆盖不充当该来源。
      slices.select { |slice| task_states[slice['id']] == 'awaiting_revalidation' }.each do |slice|
        batch = by_batch[slice['review_batch']]
        batch['acceptance_ids'].each do |acceptance_id|
          next unless acceptance[acceptance_id] == 'passed'
          valid_source = batches.any? do |source|
            source['id'] != batch['id'] && source['kind'] != 'final' && source['acceptance_ids'].include?(acceptance_id) &&
              batch_states[source['id']]['state'] == 'accepted' && snapshots[source['id']] && snapshots[source['id']][2].empty?
          end
          ensure!(valid_source, "#{slice['id']} 待复验的 #{acceptance_id} 仍为 passed，但没有其他当前有效的非最终已验收批次证明该完整断言；应回到 pending")
        end
      end
      delivery = mapping(status['delivery'], 'delivery')
      ensure!([true, false].include?(delivery['code_complete']), 'delivery.code_complete 必须是布尔值')
      ensure!(%w[not_requested pending ready].include?(delivery['release_readiness']), 'delivery.release_readiness 无效')
      complete = execution['state'] == 'complete' || delivery['code_complete']
      if complete
        ensure!(execution['state'] == 'complete' && delivery['code_complete'] == true, '执行完成与代码交付完成状态不一致')
        ensure!(task_states.values.all? { |v| v == 'accepted' }, '完成前所有任务必须 accepted')
        ensure!(batch_states.values.all? { |v| v['state'] == 'accepted' && v['blocking_findings'] == 0 }, '完成前所有审查批次必须 accepted 且阻塞为零')
        ensure!(acceptance.values.all? { |v| v == 'passed' }, '完成前所有验收项必须 passed')
        ensure!(execution['current_slice'].nil? && execution['next_slice'].nil?, '完成时 current_slice/next_slice 必须为空')
        ensure!(final_current, '完成前必须有覆盖当前全部改动及契约的最终审查快照')
        ensure!(workers.empty?, '完成时不能仍有活动 worker')
        counters = mapping(status.fetch('counters', {}), 'counters')
        %w[open_blocker open_blocking_findings open_deferred open_human_intervention open_mock_ledger_items].each do |key|
          ensure!(counters.fetch(key, 0) == 0, "完成时 #{key} 必须为零")
        end
      end
      true
    rescue Invalid, Psych::Exception, JSON::ParserError, SystemCallError, KeyError, TypeError => e
      @errors << e.message
      false
    end
  end

  def self.cli(argv)
    if argv.first == '--snapshot-batch'
      argv.shift
      require_value(argv.length == 3, '用法：check-goal.rb --snapshot-batch Goal目录 批次ID 输出JSON')
      goal, batch_id, output = argv
      manifest = capture_batch(goal, batch_id)
      absolute_output = File.join(File.realpath(File.dirname(File.expand_path(output))), File.basename(output))
      require_value(absolute_output.start_with?(File.realpath(goal) + '/snapshots/'), '批次快照必须输出到当前 Goal 的 snapshots/ 目录')
      require_value(!File.symlink?(absolute_output), '输出快照不能覆盖符号链接')
      File.write(output, JSON.pretty_generate(manifest) + "\n")
      puts "已记录 #{batch_id} 快照：#{manifest['files'].length} 个文件；未执行测试或代码审查。"
      return 0
    end
    if argv.first == '--snapshot'
      argv.shift
      repo, baseline, output = argv.shift(3)
      require_value(repo && baseline && output, '用法：check-goal.rb --snapshot 仓库根目录 基线提交 输出JSON --exclude 路径 --contract 路径')
      exclusions, contracts = [], []
      until argv.empty?
        option, value = argv.shift(2)
        require_value(value && %w[--exclude --contract].include?(option), '快照选项必须为 --exclude 路径 或 --contract 路径')
        (option == '--exclude' ? exclusions : contracts) << value
      end
      manifest = capture(repo, baseline, exclusions, contracts)
      absolute_output = File.expand_path(output)
      if absolute_output.start_with?(manifest['repo_root'] + '/')
        relative_output = Pathname.new(absolute_output).relative_path_from(Pathname.new(manifest['repo_root'])).to_s
        require_value(excluded?(relative_output, manifest['excluded_paths']), '输出快照必须位于显式排除路径，避免快照包含自身')
      end
      File.write(output, JSON.pretty_generate(manifest) + "\n")
      puts "已记录快照：#{manifest['files'].length} 个文件；未执行测试或代码审查。"
      return 0
    end
    template = argv.first == '--template'
    argv.shift if template
    require_value(argv.length == 1, '用法：ruby scripts/check-goal.rb [--template] Goal目录；或 --snapshot 仓库根目录 基线提交 输出JSON --exclude 路径 --contract 路径')
    checker = Checker.new(argv.first, template: template)
    if checker.run
      puts 'Goal 结构、状态与快照检查通过；这不证明验收行为或代码审查语义正确。'
      0
    else
      warn checker.errors.join("\n")
      1
    end
  rescue Invalid, SystemCallError, Psych::Exception, KeyError, TypeError => e
    warn e.message
    1
  end
end

exit GoalCheck.cli(ARGV) if $PROGRAM_NAME == __FILE__
