# Review Policy

> 目标：每个 slice 的关键环节和代码改动必须经过文件化 CR，并修到没有未关闭 findings。Nit/P2 也必须处理。

## Default Policy

```yaml
default_required: true
default_reviewer: ts-code-review-subagent
self_review_allowed: false
validation_report_required: true
worker_report_required_for_code_changes: true
pass_condition:
  open_findings: 0
  blocker: 0
  should_fix: 0
  nit: 0
human_intervention_allowed: true
```

## Review Matrix

| 环节 | 触发 | 推荐 Reviewer | 输入 | 输出 |
| --- | --- | --- | --- | --- |
| Contract CR | API / DTO / ViewModel / 状态 / mock policy 冻结 | Architecture / Backend / FE | `plan.md`、`slices.yaml`、契约草案 | `.goal/cr/<slice>-contract-round-<n>.md` |
| UI / Flow CR | UI flow、mock 可见闭环、操作矩阵、UI Drift Gate | FE / Product Flow / Delivery | `ui-flow.md`、prototype、UI Drift validation report、impeccable 命令记录 | `.goal/cr/<slice>-ui-round-<n>.md` |
| Foundation CR | migration、Entity、共享抽象、状态机 | DB / Backend / Architecture | worker report、diff、tests | `.goal/cr/<slice>-foundation-round-<n>.md` |
| Slice CR | 当前 slice 代码实现 | Backend / FE / AI Pipeline / Delivery | worker report、validation report、diff | `.goal/cr/<slice>-round-<n>.md` |
| Integration CR | mock 清理、worktree 合并、真实链路 | Delivery / Release | validation report、mock ledger、worktree plan | `.goal/cr/<slice>-integration-round-<n>.md` |
| Release CR | smoke、回滚、Deferred / Human Intervention | Release / SRE / Delivery | acceptance、status、risk files | `.goal/cr/<slice>-release-round-<n>.md` |

不要求每个 slice 都跑全矩阵；`slices.yaml` 必须声明当前 slice 需要哪些 reviewer roles。高风险环节可以多 reviewer 并行审，主 agent 负责汇总和裁决。

## Review Loop

```text
run validation
→ write .goal/validation/<slice>-<kind>-<n>.md
→ run CR subagent with worker + validation reports
→ write .goal/cr/<slice>-round-<n>.md
→ fix all Blocker / Should-fix / Nit
→ reject false positives with evidence
→ rerun affected validation
→ rerun CR
→ repeat until open_findings = 0
```

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
| `open` | Not resolved | no |

## Human Intervention Boundary

Human Intervention is the only allowed unresolved outcome. It is allowed only when the issue requires a person, external environment, credential, production/preprod action, product decision, DBA, or third-party support.

It must be registered in `.goal/human-intervention.md`; otherwise it remains an open finding and blocks commit.
