# Design Handoff

> 目标：把已通过 Design CR 的方案结论交给执行阶段。执行期不得静默改变范围；发现方案不成立时，回到方案阶段。

## Design Verdict

- Design CR: Ready / Not Ready
- Ready 条件：
- 未关闭 P0：
- 可接受 P1：

## Key Decisions

| ID | 决策 | 来源 | 执行影响 |
| --- | --- | --- | --- |
| D-01 | | `plan.md` | |

## Contract Pointers

| 契约 | 路径 | 执行期用途 |
| --- | --- | --- |
| API | | |
| DTO / ViewModel | | |
| State machine | | |
| Data flow / Job | | |
| UI flow / prototype | | |
| Release / smoke | | |

## Execution Boundaries

- 执行期不得新增范围：
- 执行期允许的实现取舍：
- 发现以下情况必须 blocked 并回到方案阶段：

## Orchestration Boundaries

| Boundary | Rule | Owner |
| --- | --- | --- |
| Status source | Only main agent updates `.goal/status.yaml` | Main agent |
| Shared contracts | DTO / Entity / migration / status enum changes return to main agent | Main agent |
| Worker scope | Worker may only edit assigned ownership | Worker + Main agent audit |
| Validation | Validator report is required before CR when slice has runnable checks | Validator |
| CR | Reviewer report is required before commit | Reviewer |
| Mock cleanup | Mock ledger must be updated when mock is created or closed | Main agent |

## Change Sync

| 来源 | 影响 | 已同步文件 | 状态 |
| --- | --- | --- | --- |
