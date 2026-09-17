require '/Users/xiaohong.zhxh/projectInfo/luseek/ai-coding-playbook-workflow-v2/scripts/test-check-goal'

class RevisionReviewerProbes < GoalCheckerTest
  # Reuse fixture/setup/acceptance helpers only, not inherited test cases.
  def self.runnable_methods
    public_instance_methods(false).grep(/^test_/).map(&:to_s).sort
  end

  def test_review_strategy_migration_changes_existing_evidence
    @status['review_strategy'] = 'per_slice'
    prepare_accepted
    @status['review_strategy'] = 'functional_batch'
    ok, error = check
    assert ok, error
  end

  def test_declared_contract_deleted_invalidates
    File.write(File.join(@repo, 'rules.md'), 'stable contract')
    @slices['review_batches'][0]['snapshot_scope']['contracts'] << 'rules.md'
    prepare_accepted
    File.delete(File.join(@repo, 'rules.md'))
    ok, error = check
    refute ok
    assert_includes error, 'rules.md'
  end

  def test_unrelated_contract_edit_does_not_invalidate
    File.write(File.join(@repo, 'rules02.md'), 'other contract')
    add_independent_batch
    @slices['review_batches'].find { |b| b['id'] == 'B02' }['snapshot_scope']['contracts'] = ['rules02.md']
    prepare_accepted
    File.write(File.join(@repo, 'rules02.md'), 'other contract changed')
    @slices['slices'].last['scope'] = ['unrelated modified scope']
    ok, error = check
    assert ok, error
  end

  def test_recursively_related_batch_changes_invalidate
    @slice['review_boundary'] = 'before_dependents'
    @slices['review_batches'][0]['kind'] = 'foundation'
    add_independent_batch(dependencies: ['S01'])
    prepare_accepted
    @status['slices']['S02'] = 'accepted'
    self_check('S02')
    accept('B02')
    third = Marshal.load(Marshal.dump(@slices['slices'].last)).merge('id'=>'S03', 'task_ids'=>['T03'], 'review_batch'=>'B03', 'dependencies'=>['S02'])
    @slices['slices'] << third
    @slices['review_batches'] << {'id'=>'B03', 'kind'=>'functional', 'slice_ids'=>['S03'], 'acceptance_ids'=>['A01'], 'earliest_real_path'=>'third consumer', 'snapshot_scope'=>{'paths'=>['consumer03'], 'contracts'=>['.goal/acceptance.md']}}
    @status['slices']['S03'] = 'accepted'
    @status['review_batches']['B03'] = @status['review_batches']['B02'].dup
    self_check('S03')
    accept('B03')
    File.write(File.join(@repo, 'base.txt'), 'changed grandparent')
    accept('B01')
    accept('B02')
    ok, error = check
    refute ok
    assert_includes error, 'B03 accepted 快照已过时'
  end

  def test_committed_code_added_after_scope_capture_invalidates
    prepare_accepted
    FileUtils.mkdir_p(File.join(@repo, 'src'))
    File.write(File.join(@repo, 'src/committed.rb'), 'new committed')
    git('add', 'src/committed.rb')
    git('-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '-qm', 'new file')
    ok, error = check
    refute ok
    assert_includes error, 'src/committed.rb'
  end

  def test_template_cannot_prefill_passed_acceptance
    @status['acceptance']['A01'] = 'passed'
    write_docs
    checker = GoalCheck::Checker.new(@goal, template: true)
    refute checker.run, 'Template prefilled acceptance=passed was allowed'
  end

  def test_reopened_consumer_must_reset_passed_acceptance
    prepare_accepted
    @status['slices']['S01'] = 'awaiting_revalidation'
    @status['review_batches']['B01']['state'] = 'pending'
    @status['execution']['next_slice'] = 'S01'
    ok, error = check
    refute ok, "Revalidation preserved passed acceptance: #{error}"
  end

  def test_shared_acceptance_pending_requires_reopening_other_accepted_batch
    @slice['review_boundary'] = 'before_dependents'
    @slices['review_batches'][0]['kind'] = 'foundation'
    add_independent_batch(dependencies: ['S01'])
    prepare_accepted
    @status['slices']['S02'] = 'awaiting_revalidation'
    self_check('S02')
    @status['acceptance']['A01'] = 'pending'
    @status['execution']['next_slice'] = 'S02'
    ok, error = check
    refute ok
    assert_includes error, 'B01 accepted 但验收未 passed'
  end

  def test_distinct_acceptance_ids_allow_revalidation_then_dependency_resume
    @slice['review_boundary'] = 'before_dependents'
    @slices['review_batches'][0]['kind'] = 'foundation'
    add_independent_batch(dependencies: ['S01'])
    @slices['review_batches'].find { |b| b['id'] == 'B02' }['acceptance_ids'] = ['A02']
    @status['acceptance']['A02'] = 'pending'
    prepare_accepted
    @status['slices']['S02'] = 'awaiting_revalidation'
    self_check('S02')
    @status['execution']['next_slice'] = 'S02'
    ok, error = check
    assert ok, error
    @status['slices']['S02'] = 'in_progress'
    @status['execution'].merge!('current_slice'=>'S02', 'next_slice'=>nil)
    ok, error = check
    assert ok, error
  end

  def test_scoped_executable_bit_change_invalidates
    File.write(File.join(@repo, 'src.rb'), 'puts 1')
    File.chmod(0o644, File.join(@repo, 'src.rb'))
    prepare_accepted
    File.chmod(0o755, File.join(@repo, 'src.rb'))
    ok, error = check
    refute ok
    assert_includes error, 'src.rb'
  end

  def test_contract_content_restored_to_baseline_still_invalidates_batch
    File.write(File.join(@repo, 'business.md'), 'original')
    git('add', 'business.md')
    git('-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '-qm', 'contract baseline')
    @status['execution']['baseline_commit'] = git('rev-parse', 'HEAD').strip
    @slices['review_batches'][0]['snapshot_scope']['contracts'] << 'business.md'
    File.write(File.join(@repo, 'business.md'), 'reviewed new contract')
    prepare_accepted
    File.write(File.join(@repo, 'business.md'), 'original')
    ok, error = check
    refute ok
    assert_includes error, 'business.md'
  end

end
