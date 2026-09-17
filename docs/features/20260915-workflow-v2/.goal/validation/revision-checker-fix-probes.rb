require '/Users/xiaohong.zhxh/projectInfo/luseek/ai-coding-playbook-workflow-v2/scripts/test-check-goal'

class RevisionFixReviewerProbes < GoalCheckerTest
  def self.runnable_methods
    public_instance_methods(false).grep(/^test_/).map(&:to_s).sort
  end

  def prepare_shared_dependency
    @slice['review_boundary'] = 'before_dependents'
    @slices['review_batches'][0]['kind'] = 'foundation'
    add_independent_batch(dependencies: ['S01'])
    prepare_accepted
    @status['slices']['S02'] = 'accepted'
    self_check('S02')
    accept('B02')
  end

  def test_shared_acceptance_survives_complete_revalidation_lifecycle
    prepare_shared_dependency
    File.write(File.join(@repo, 'base.txt'), 'foundation fix')
    @status['slices'].merge!('S01'=>'implemented', 'S02'=>'awaiting_revalidation')
    @status['review_batches']['B01']['state'] = 'pending'
    @status['review_batches']['B02']['state'] = 'pending'
    @status['acceptance']['A01'] = 'pending'
    @status['execution']['next_slice'] = 'S02'
    ok, error = check
    assert ok, error
    @status['acceptance']['A01'] = 'passed'
    ok, error = check
    refute ok
    assert_includes error, '没有其他当前有效'
    @status['slices']['S01'] = 'accepted'
    accept('B01')
    ok, error = check
    assert ok, "Restored foundation must prove shared A01 while S02 is still awaiting: #{error}"
    @status['slices']['S02'] = 'in_progress'
    @status['execution'].merge!('current_slice'=>'S02', 'next_slice'=>nil)
    ok, error = check
    assert ok, error
    @status['slices']['S02'] = 'implemented'
    @status['execution']['current_slice'] = nil
    ok, error = check
    assert ok, error
    @status['slices']['S02'] = 'accepted'
    accept('B02')
    accept('FINAL')
    @status['execution']['state'] = 'complete'
    @status['delivery']['code_complete'] = true
    ok, error = check
    assert ok, error
  end

  def test_every_shared_acceptance_requires_its_own_valid_source
    add_independent_batch
    @slices['review_batches'].find { |b| b['id'] == 'B02' }['acceptance_ids'] << 'A02'
    @status['acceptance']['A02'] = 'passed'
    prepare_accepted
    @status['slices']['S02'] = 'awaiting_revalidation'
    self_check('S02')
    @status['execution']['next_slice'] = 'S02'
    ok, error = check
    refute ok
    assert_includes error, 'S02 待复验的 A02 仍为 passed'
    @status['acceptance']['A02'] = 'pending'
    ok, error = check
    assert ok, error
  end

  def test_in_review_source_is_not_an_accepted_source
    add_independent_batch
    prepare_accepted
    @status['slices']['S01'] = 'implemented'
    @status['review_batches']['B01']['state'] = 'in_review'
    @status['slices']['S02'] = 'awaiting_revalidation'
    self_check('S02')
    @status['execution']['next_slice'] = 'S02'
    ok, error = check
    refute ok
    assert_includes error, '没有其他当前有效'
  end

  def test_valid_shared_source_does_not_allow_goal_completion_with_awaiting_task
    prepare_shared_dependency
    @status['slices']['S02'] = 'awaiting_revalidation'
    @status['review_batches']['B02']['state'] = 'pending'
    accept('FINAL')
    @status['execution'].merge!('state'=>'complete', 'current_slice'=>nil, 'next_slice'=>nil)
    @status['delivery']['code_complete'] = true
    ok, error = check
    refute ok
    assert_includes error, '完成前所有任务必须 accepted'
  end
end
