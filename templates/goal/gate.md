# Goal Gate

> 结论：Ready / Not Ready

## Checklist

| Gate | 状态 | 证据 / 修复项 |
| --- | --- | --- |
| Design CR Ready，无未关闭 P0 | pending | |
| P0 acceptance 写清写 API、读 API、用户可见结果 | pending | `.goal/acceptance.md` |
| 涉及前端 + API 时，tasks/slices 继承 Frontend-first Mock Lane | pending | `tasks.md` / `.goal/slices.yaml` |
| 每个 slice 有 scope、non-goals、implementation_owner、validators、tests、exit、CR | pending | `.goal/slices.yaml` |
| 每个 slice 有 lane / task type，可追溯到 tasks.md | pending | `.goal/slices.yaml` |
| Main-thread / worker / validator / reviewer 输出路径明确 | pending | `.goal/slices.yaml` |
| CR policy 要求验证报告进入 CR，阻塞 findings 关闭，P2/Nit follow-up 有边界 | pending | `.goal/review-policy.md` |
| Mock ledger 已初始化，所有 mock 有清理 slice 或 waiver | pending | `.goal/mock-ledger.md` |
| TODO ledger 已初始化，局部待确认默认不阻塞下一 slice 的规则已声明 | pending | `.goal/todo-ledger.md` |
| Worktree plan 明确 ownership、merge order 和共享契约冲突策略 | pending | `.goal/worktree-plan.md` |
| Human Intervention 例外已收窄且有登记模板 | pending | `.goal/human-intervention.md` |
| `status.yaml` 初始化完成，只有一个执行 SSOT | pending | `.goal/status.yaml` |
| Codex app goal 镜像策略已声明，且不替代 `status.yaml` | pending | `.goal/status.yaml` |
| Run mode 默认 continuous，single_slice / release_gate 需要显式触发 | pending | `.goal/GOAL.md` / `.goal/status.yaml` |
| Implementation owner policy 已声明，主线程实现范围和独立验证 / CR 已明确 | pending | `.goal/GOAL.md` / `.goal/status.yaml` / `.goal/slices.yaml` |
| Slice Size Gate：单片不过大，高风险片默认 main_thread/hybrid | pending | `.goal/slices.yaml` |
| Throughput Gate：fixer/验证轮次上限、开发片允许 P2/Nit follow-up、UI Drift 时机 | pending | `.goal/review-policy.md` / `.goal/slices.yaml` |
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
- Ready 表示可以按 continuous 执行；当前 slice 达到安全边界后默认进入下一 slice，除非用户指定 single_slice。
- Ready 允许主 agent 按 `implementation_owner=main_thread|hybrid` 实现声明范围，但不能跳过独立验证和 CR。
- Ready 不代表 TODO 清零；局部待确认和需求优化可以开放到 Goal 结束集中对齐，只要不破坏当前验收、数据/权限/状态正确性。
