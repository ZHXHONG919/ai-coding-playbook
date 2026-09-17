# 针对本轮规则的结构探针：合成契约/能力任务，不是业务验收证据。
require_relative '../../../../../scripts/test-check-goal'

class ContractIsolationProbe < GoalCheckerTest
  def setup
    super
    @slice['review_boundary'] = 'before_dependents'
    @slices['review_batches'][0]['kind'] = 'foundation'
    @slice['scope'] = ['仅接口协议；不包含真实存储能力']
    @slices['review_batches'][0]['earliest_real_path'] = '协议输入输出与错误语义检查（合成结构）'
    [['S02', 'B02', [], '真实存储能力'], ['S03', 'B03', ['S01'], '消费协议的界面开发'], ['S04', 'B04', ['S02', 'S03'], '真实集成']].each_with_index do |(sid, bid, deps, scope), idx|
      aid = "A#{idx + 2}"
      @slices['slices'] << Marshal.load(Marshal.dump(@slice)).merge('id' => sid, 'task_ids' => [sid], 'review_batch' => bid, 'review_boundary' => 'batch', 'dependencies' => deps, 'scope' => [scope])
      @slices['review_batches'] << { 'id' => bid, 'kind' => 'functional', 'slice_ids' => [sid], 'acceptance_ids' => [aid], 'earliest_real_path' => scope, 'snapshot_scope' => { 'paths' => [sid], 'contracts' => ['.goal/acceptance.md'] } }
      @status['slices'][sid] = 'todo'
      @status['review_batches'][bid] = @status['review_batches']['B01'].dup
      @status['acceptance'][aid] = 'pending'
    end
    prepare_accepted
    @status['execution'].merge!('state' => 'in_progress', 'current_slice' => 'S03', 'next_slice' => nil)
    @status['slices']['S03'] = 'in_progress'
  end

  def test_contract_probe_consumer_can_start_while_real_ability_todo
    ok, error = check
    assert ok, error
    assert_equal 'todo', @status['slices']['S02']
    assert_equal false, @status['delivery']['code_complete']
  end

  def test_contract_probe_integration_cannot_bypass_real_ability
    @status['slices']['S03'] = 'todo'
    @status['slices']['S04'] = 'in_progress'
    @status['execution']['current_slice'] = 'S04'
    ok, error = check
    refute ok
    assert_includes error, '依赖 S02 尚未达到'
  end
end
