# Review Policy

> 目标：每个 slice 的关键环节和代码改动必须经过文件化 CR。当前 slice 的阻塞项必须关闭；不影响当前 slice 主链路的问题必须分类沉淀，避免 CR 无限循环吞掉连续执行节奏。

## Default Policy

```yaml
default_required: true
default_reviewer: ts-code-review-subagent
self_review_allowed: false
validation_report_required: true
worker_report_required_for_code_changes: true
pass_condition:
  blocking_findings: 0
  p0: 0
  p1: 0
  blocker: 0
  should_fix: 0
  non_blocking_follow_up_allowed: true
  all_findings_closed_required_in_release_gate: true
human_intervention_allowed: true
max_fix_rounds_per_finding: 2
max_pre_cr_validation_rounds: 1
ui_drift_timing: before_first_cr_and_after_ui_fix
legacy_nit_zero_on_dev_slice: false
```

## Review Matrix

| 环节 | 触发 | 推荐 Reviewer | 输入 | 输出 |
| --- | --- | --- | --- | --- |
| Contract CR | API / DTO / ViewModel / 状态 / mock policy 冻结 | Architecture / Backend / FE | `plan.md`、`slices.yaml`、契约草案 | `.goal/cr/<slice>-contract-round-<n>.md` |
| UI / Flow CR | UI flow、mock 可见闭环、操作矩阵、UI Drift Gate | FE / Product Flow / Delivery | `ui-flow.md`、prototype、Open Design artifact（如适用，含 projectId / studioUrl / entryFile）、UI Drift validation report、impeccable 命令记录 | `.goal/cr/<slice>-ui-round-<n>.md` |
| Foundation CR | migration、Entity、共享抽象、状态机 | DB / Backend / Architecture | worker report、diff、tests | `.goal/cr/<slice>-foundation-round-<n>.md` |
| Slice CR | 当前 slice 代码实现 | Backend / FE / AI Pipeline / Delivery | worker report、validation report、diff | `.goal/cr/<slice>-round-<n>.md` |
| Integration CR | mock 清理、worktree 合并、真实链路 | Delivery / Release | validation report、mock ledger、worktree plan | `.goal/cr/<slice>-integration-round-<n>.md` |
| Release CR | smoke、回滚、Deferred / Human Intervention | Release / SRE / Delivery | acceptance、status、risk files | `.goal/cr/<slice>-release-round-<n>.md` |

不要求每个 slice 都跑全矩阵；`slices.yaml` 必须声明当前 slice 需要哪些 reviewer roles。高风险环节可以多 reviewer 并行审，主 agent 负责汇总和裁决。

## Review Loop

```text
run validation (max 1 full pre-CR pass after implement; 1 more after pre-CR fix)
→ write .goal/validation/<slice>-<kind>-<n>.md
→ for job/concurrency slices: concurrency checklist must be covered before Pass
→ run CR subagent with worker + validation reports
→ write .goal/cr/<slice>-round-<n>.md
→ fix all findings that affect current slice correctness / data safety / release safety / state consistency / API contract / acceptance
→ classify non-current-slice findings into TODO ledger / follow-up / later slice gate / release gate / human intervention
→ reject false positives with evidence
→ rerun affected validation only
→ if UI changed, rerun UI Drift once before re-CR
→ rerun CR
→ repeat until current-slice blocking_findings = 0
```

Throughput rules:

- Do not start orthogonal fixers while current-slice blocking findings remain open.
- Do not rerun full migration + full suite by default after every fix; prefer affected tests.
- UI Drift runs once before first CR, and again only if a CR fix changes UI.
- Development slices must not require `nit: 0` unless the user explicitly asks for zero Nit.

If the same finding is still open after 2 worker fixer rounds, the main agent must escalate instead of silently looping:

- switch `implementation_owner` to `main_thread` or `hybrid` and close it in one main-thread pass; or
- `design_sync_required`: return to requirements / plan sync.
- `human_intervention`: register in `.goal/human-intervention.md`.
- `release_gate`: move to release slice / R10 when it is a production-environment concern.
- `later_slice_gate`: move to the affected future slice when it does not affect the current slice.
- `non_blocking_follow_up`: only for P2/Nit or discussion items with no current-slice correctness, data, security, release, contract, acceptance, or primary user-path impact.
- `todo_ledger`: use for local pending questions, demand improvements, UX suggestions, contract improvements, and tech debt that should be aligned with humans at Goal end or checkpoint but should not stop the next slice.

Only `design_sync_required`, `human_intervention`, stale state, unrecoverable worktree/status mismatch, or unresolved current-slice blocking findings may stop the continuous Goal. Follow-up, later-slice, and release-gate items should be recorded and the main chain should continue.

Local TODO items should not stop the continuous Goal unless they make current P0/P1 acceptance unjudgeable, create wrong data / permission / state, or block a later slice that cannot be isolated by mock / adapter / feature flag.

If an existing project Goal package still says `nit: 0` for development slices, apply this playbook throughput policy unless the user or `release_gate` requires zero Nit; record the override in the CR file and regenerate the Goal package at the next handoff.

## Evidence Rules

- Worker report does not replace validation.
- Validation report does not replace CR.
- Test/build green does not replace acceptance coverage.
- Only main agent can update `.goal/status.yaml`, merge worktrees, commit, or advance the next slice.
- CR input must include the relevant worker report, validation report, slice contract, acceptance items, and diff.

## Finding Closure

| Status | Meaning | Allowed for final pass |
| --- | --- | --- |
| `fixed` | Code/docs/tests updated and verified | yes |
| `rejected_false_positive` | Finding is wrong; CR file explains evidence | yes |
| `human_intervention` | Agent cannot resolve without human action | only if registered |
| `non_blocking_follow_up` | P2/Nit or discussion item that does not block current slice | yes for normal dev slices; no for release gate unless waived |
| `later_slice_gate` | Issue only affects a future slice and is recorded there | yes until that slice starts |
| `release_gate` | Real environment / production / provider smoke concern moved to release gate | yes until release gate |
| `open` | Not resolved | no |

## Human Intervention Boundary

Human Intervention is the only allowed unresolved outcome. It is allowed only when the issue requires a person, external environment, credential, production/preprod action, product decision, DBA, or third-party support.

It must be registered in `.goal/human-intervention.md`; otherwise it remains an open finding and blocks commit.
