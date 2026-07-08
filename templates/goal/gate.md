# Goal Gate

> 结论：Ready / Not Ready

## Checklist

| Gate | 状态 | 证据 / 修复项 |
| --- | --- | --- |
| Design CR Ready，无未关闭 P0 | pending | |
| P0 acceptance 写清写 API、读 API、用户可见结果 | pending | `.goal/acceptance.md` |
| 每个 slice 有 scope、non-goals、workers、validators、tests、exit、CR | pending | `.goal/slices.yaml` |
| Worker / validator / reviewer 输出路径明确 | pending | `.goal/slices.yaml` |
| CR policy 要求验证报告进入 CR，所有 findings 关闭，含 Nit/P2 | pending | `.goal/review-policy.md` |
| Mock ledger 已初始化，所有 mock 有清理 slice 或 waiver | pending | `.goal/mock-ledger.md` |
| Worktree plan 明确 ownership、merge order 和共享契约冲突策略 | pending | `.goal/worktree-plan.md` |
| Human Intervention 例外已收窄且有登记模板 | pending | `.goal/human-intervention.md` |
| `status.yaml` 初始化完成，只有一个执行 SSOT | pending | `.goal/status.yaml` |
| Codex app goal 镜像策略已声明，且不替代 `status.yaml` | pending | `.goal/status.yaml` |
| Self-run 默认关闭；如允许，已写明允许 slice、文件范围、原因和报告路径 | pending | `.goal/GOAL.md` / `.goal/status.yaml` |
| 上下文压缩恢复策略为同线程，不主动新开替代线程，可读取 worker / validation / CR 报告 | pending | `.goal/resume.md` |
| Deferred 默认 none，例外有 expires_at_slice | pending | `.goal/risks-deferred.md` |
| 最后一片包含 global exit | pending | `.goal/slices.yaml` |
| Self review 例外已明确 | pending | `.goal/GOAL.md` |

## Blocking Findings

- None

## Ready Conditions

- 只有本文件结论为 Ready，才能进入 `goal-execute`。
- Not Ready 时，回到需求确认、方案、任务拆解或 Design CR，而不是直接实现。
- Ready 不代表 worker 可以直接推进状态；执行期仍由主 agent 更新 `.goal/status.yaml`、合并和提交。
- Ready 不代表主 agent 可以直接实现；除非 `self_run_allowed: true` 且范围明确，否则主 agent 只能编排和最终集成。
