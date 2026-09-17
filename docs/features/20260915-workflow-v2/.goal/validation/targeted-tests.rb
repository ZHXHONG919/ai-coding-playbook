require '/Users/xiaohong.zhxh/projectInfo/luseek/ai-coding-playbook-workflow-v2/scripts/test-check-goal'

class GoalCheckerTest
  def test_targeted_unchanged_in_review_allows_independent_new_file
    File.write(File.join(@repo, 'src.rb'), 'reviewed input')
    @status['slices']['S01'] = 'implemented'
    self_check('S01')
    @status['execution']['next_slice'] = nil
    accept('B01')
    @status['review_batches']['B01']['state'] = 'in_review'
    File.write(File.join(@repo, 'independent.txt'), 'outside prior captured inputs')
    ok, error = check
    assert ok, error
  end

  def test_targeted_tracked_optional_contract_delete_covered_by_final
    git('add', '.goal/review-policy.md')
    git('-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '-qm', 'Track optional contract')
    @baseline = git('rev-parse', 'HEAD').strip
    @status['execution']['baseline_commit'] = @baseline
    prepare_accepted
    File.delete(File.join(@goal, 'review-policy.md'))
    @contracts.delete('.goal/review-policy.md')
    ok, error = check
    refute ok
    assert_includes error, '快照已过时'
    accept('FINAL')
    @status['execution']['state'] = 'complete'
    @status['delivery']['code_complete'] = true
    ok, error = check
    assert ok, error
    manifest = JSON.parse(File.read(File.join(@goal, 'snapshots/FINAL.json')))
    assert manifest['files'].key?('.goal/review-policy.md')
    assert_nil manifest['files']['.goal/review-policy.md']
  end

  def test_targeted_removing_executable_bit_invalidates_final
    git('config', 'core.filemode', 'true')
    File.write(File.join(@repo, 'base.txt'), 'reviewed script')
    File.chmod(0o755, File.join(@repo, 'base.txt'))
    complete
    File.chmod(0o644, File.join(@repo, 'base.txt'))
    ok, error = check
    refute ok
    assert_includes error, '最终审查快照未完整覆盖'
  end

  def test_targeted_regular_permission_change_does_not_invalidate
    File.write(File.join(@repo, 'base.txt'), 'reviewed input')
    File.chmod(0o644, File.join(@repo, 'base.txt'))
    complete
    File.chmod(0o600, File.join(@repo, 'base.txt'))
    ok, error = check
    assert ok, error
  end

  def test_targeted_independent_foundation_tasks_are_allowed
    @slice['review_boundary'] = 'before_dependents'
    @slices['review_batches'][0]['kind'] = 'foundation'
    @slices['slices'] << Marshal.load(Marshal.dump(@slice)).merge('id' => 'S02', 'task_ids' => ['T02'], 'dependencies' => [])
    @slices['review_batches'][0]['slice_ids'] << 'S02'
    @status['slices']['S02'] = 'todo'
    ok, error = check
    assert ok, error
  end

  def test_targeted_cross_batch_accepted_foundation_dependency_can_start
    @slice['review_boundary'] = 'before_dependents'
    @slices['review_batches'][0]['kind'] = 'foundation'
    @slices['slices'] << Marshal.load(Marshal.dump(@slice)).merge('id' => 'S02', 'task_ids' => ['T02'], 'review_batch' => 'B02', 'review_boundary' => 'batch', 'dependencies' => ['S01'])
    @slices['review_batches'] << {'id' => 'B02', 'kind' => 'functional', 'slice_ids' => ['S02'], 'acceptance_ids' => ['A01'], 'earliest_real_path' => 'Submit actual state'}
    @status['review_batches']['B02'] = @status['review_batches']['B01'].dup
    @status['slices']['S02'] = 'todo'
    ok, error = check
    assert ok, error
    prepare_accepted
    @status['slices']['S02'] = 'in_progress'
    @status['execution'].merge!('state' => 'in_progress', 'current_slice' => 'S02')
    ok, error = check
    assert ok, error
  end
end
