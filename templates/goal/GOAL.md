# Goal：<feature-name>

> Feature：`<feature-id>`
> 分支：`<branch-name>`
> Goal 包状态：Draft / Gate Ready / In Progress / Complete / Blocked / Needs Human Intervention
> 权威状态：`.goal/status.yaml`

## 1. 范围

### In Scope

- <本 Goal 必须交付的能力>

### Non-goals

- <本 Goal 明确不做的能力>

## 2. 来源文档

| 类型 | 路径 | 版本 / 结论 |
| --- | --- | --- |
| Requirements | `requirements.md` | |
| Plan | `plan.md` | |
| Tasks | `tasks.md` | |
| Design CR | `design-review.md` | Ready / Not Ready |
| API / UI / Release | | |

## 3. 执行原则

- 执行阶段只认 `.goal/status.yaml` 和 `.goal/slices.yaml`，聊天历史不是权威来源。
- 主 agent 是 orchestrator / final integrator，只负责读取契约、派发 worker / validator / reviewer、审计证据、更新状态、合并和提交。
- 子 agent、worker session 或 worktree worker 可以负责局部实现、验证、CR 和修复，但输出必须文件化，不能替代 `.goal/status.yaml`。
- 每个 slice 必须实现、验证、CR、修复、更新状态后才能 commit。
- 可验功能应尽早验证；validator report 必须进入 CR 输入。
- 代码改动默认必须生成 `.goal/cr/<slice>-round-<n>.md`；所有 CR findings 必须关闭，包括 Nit/P2。
- 只有 `.goal/human-intervention.md` 登记的人为介入项可以遗留；存在遗留时 Goal 不能标 `Complete`。
- 所有 mock、pending API、fixture-only 读路径必须登记到 `.goal/mock-ledger.md`，并有清理 slice 或书面 waiver。
- worktree 并行必须先写入 `.goal/worktree-plan.md`，说明 ownership、merge order 和冲突策略。
- Deferred 默认禁止；例外必须写入 `.goal/risks-deferred.md`。
- 不主动新开替代线程；上下文压缩后按 `.goal/status.yaml`、`.goal/resume.md` 和文件化 worker / validation / CR 报告恢复。
- 不为了上下文压缩提交半成品 checkpoint commit。
- 最后一片必须满足 global exit，不能只用 build 绿替代验收。

## 3.1 Orchestration Boundary

| 角色 | 允许做什么 | 禁止做什么 | 输出 |
| --- | --- | --- | --- |
| Main agent | 派发任务、审计报告、更新 status、合并、commit | 长期携带所有实现细节、跳过文件化证据 | `.goal/status.yaml`、commit、最终总结 |
| Implementer / Fixer | 当前 slice scope 内实现和修复 | 扩大 scope、推进 status、提交 commit | `.goal/runs/<slice>-<role>-<n>.md` |
| Validator | 运行测试、contract、smoke、mock 清理检查 | 用验证报告代替 CR、擅自改业务逻辑 | `.goal/validation/<slice>-<kind>-<n>.md` |
| Reviewer | scoped CR、多角色风险检查 | 继续开发、替代 validator | `.goal/cr/<slice>-round-<n>.md` |
| Worktree worker | 在授权 ownership 内并行开发 | 修改共享契约、绕过 merge order | worker report + worktree plan 更新 |

## 4. 允许停止条件

- `status.yaml.execution.next_slice: null` 且 global exit 全绿或有书面 waiver。
- `status.yaml.execution.state: blocked`，且写明不可恢复原因和下一步责任人。
- `status.yaml.execution.state: needs_human_intervention`，且所有 agent 可处理事项已关闭。
- 用户明确要求停止。
- 工具或上下文硬上限；停止前必须更新 `status.yaml` 和 `.goal/resume.md` 到可恢复状态，不新开替代线程。

## 5. Global Exit

| 项 | 要求 | 状态 | 证据 |
| --- | --- | --- | --- |
| P0 acceptance | 全部通过或书面 waiver | pending | `.goal/acceptance.md` |
| Deferred | `open_deferred = 0` | pending | `.goal/status.yaml` |
| Blocker | `open_blocker = 0` | pending | `.goal/cr/` |
| CR findings | `open_cr_findings = 0` | pending | `.goal/cr/` |
| Human Intervention | `open_human_intervention = 0` 或最终状态为 `needs_human_intervention` | pending | `.goal/human-intervention.md` |
| Mock ledger | 无未登记 mock / pending API，open 项为 0 或有 waiver | pending | `.goal/mock-ledger.md` |
| Worktree merge | 所有 worker worktree 已合并或登记阻塞 | pending | `.goal/worktree-plan.md` |
| Smoke A | 本地或手点 smoke | pending | |
| Smoke B | 预发或发布前 smoke | pending | |

## 6. Self Review 例外

默认不允许主 agent 自评代替 CR。

如当前环境没有子 agent / 外部 CR 能力，是否允许 self review：

- Allowed: no
- Reason:
