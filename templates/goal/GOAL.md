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
- 默认 `run_mode: continuous`；每个 slice 达到安全边界后自动进入下一 slice，直到 Goal 完成、真正阻塞、需要人工介入、用户打断或工具上限。只有用户明确要求“只跑一片 / 先停在当前 slice”才使用 `single_slice`。
- 主 agent 是技术负责人 / final integrator，负责读取契约、判定实现所有者、派发 worker / validator / reviewer、审计证据、更新状态、合并和提交。
- 实现可以由 `main_thread`、`worker` 或 `hybrid` 完成；核心领域、状态机、DTO / Entity / migration、provider、并发、用户最新口径同步优先由主线程或混合模式承担。
- 子 agent、worker session 或 worktree worker 负责授权范围内的局部实现、验证、CR 和修复，输出必须文件化，不能替代 `.goal/status.yaml`。
- Codex app goal 如可用，只作为 UI 进度条镜像；详细执行进度仍以 `.goal/status.yaml` 为准。
- 每个 slice 必须实现、验证、CR、修复、更新状态后才能 commit。
- 可验功能应尽早验证；validator report 必须进入 CR 输入。
- 代码改动默认必须生成 `.goal/cr/<slice>-round-<n>.md`；P0/P1/Blocker/Should-Fix 必须关闭。普通开发 slice 的 P2/Nit 可登记为 non-blocking follow-up；release gate 或用户要求“零 Nit”时全部关闭。
- 每个 slice 必须声明 `implementation_owner`、`max_fix_rounds_per_finding`、`max_pre_cr_validation_rounds`；高风险并发 / 状态 / provider slice 默认 `main_thread` 或 `hybrid`。
- 切片必须通过 Slice Size Gate：不要把 Job、生命周期、预算结算、identity 失效塞进同一开发片。
- 只有 `.goal/human-intervention.md` 登记的人为介入项可以遗留；存在遗留时 Goal 不能标 `Complete`。
- 所有 mock、pending API、fixture-only 读路径必须登记到 `.goal/mock-ledger.md`，并有清理 slice 或书面 waiver。
- 局部待确认、需求优化、交互建议、契约优化和技术债登记到 `.goal/todo-ledger.md`；默认不阻塞下一 slice，Goal 完成或阶段 checkpoint 时集中和人对齐。
- worktree 并行必须先写入 `.goal/worktree-plan.md`，说明 ownership、merge order 和冲突策略。
- Deferred 默认禁止；例外必须写入 `.goal/risks-deferred.md`。
- 不主动新开替代线程；上下文压缩后按 `.goal/status.yaml`、`.goal/resume.md` 和文件化 worker / validation / CR 报告恢复。
- 不为了上下文压缩提交半成品 checkpoint commit。
- 最后一片必须满足 global exit，不能只用 build 绿替代验收。

## 3.1 Orchestration Boundary

| 角色 | 允许做什么 | 禁止做什么 | 输出 |
| --- | --- | --- | --- |
| Main agent | 判定 owner、实现主线程范围、派发任务、审计报告、更新 status、合并、commit | 跳过独立验证/CR、扩大未声明范围、用自测冒充门禁 | `.goal/status.yaml`、`.goal/runs/<slice>-main-thread-<n>.md`、commit、最终总结 |
| Implementer / Fixer | 当前 slice 授权 scope 内实现和修复 | 扩大 scope、推进 status、提交 commit | `.goal/runs/<slice>-<role>-<n>.md` |
| Validator | 运行测试、contract、smoke、mock 清理检查 | 用验证报告代替 CR、擅自改业务逻辑 | `.goal/validation/<slice>-<kind>-<n>.md` |
| Reviewer | scoped CR、多角色风险检查 | 继续开发、替代 validator | `.goal/cr/<slice>-round-<n>.md` |
| Worktree worker | 在授权 ownership 内并行开发 | 修改共享契约、绕过 merge order | worker report + worktree plan 更新 |

## 4. 允许停止条件

- `run_mode: single_slice` 下当前 slice 已 commit / blocked / needs_human_intervention / 可恢复，并已向用户汇报。
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
| CR findings | `open_blocking_findings = 0`; release gate closes or waives all findings | pending | `.goal/cr/` |
| Human Intervention | `open_human_intervention = 0` 或最终状态为 `needs_human_intervention` | pending | `.goal/human-intervention.md` |
| Mock ledger | 无未登记 mock / pending API，open 项为 0 或有 waiver | pending | `.goal/mock-ledger.md` |
| TODO ledger | open 项已汇总给人对齐；只有破坏验收 / 数据 / 权限 / 状态正确性的 TODO 才阻塞 | pending | `.goal/todo-ledger.md` |
| Worktree merge | 所有 worker worktree 已合并或登记阻塞 | pending | `.goal/worktree-plan.md` |
| Smoke A | 本地或手点 smoke | pending | |
| Smoke B | 预发或发布前 smoke | pending | |

## 6. Run Mode / Implementation Owner

默认不允许主 agent 自评代替 CR。主线程是否实现由每个 slice 的 `implementation_owner` 决定，而不是把主 agent 固定成纯调度员。

```yaml
run_control:
  default_mode: continuous
  single_slice_requires_explicit_user_request: true
  release_gate_requires_explicit_release_context: true

implementation_owner_policy:
  default_for_core_domain: main_thread
  default_for_mechanical_changes: worker
  hybrid_allowed: true
  main_thread_report_pattern: ".goal/runs/<slice>-main-thread-{n}.md"
  independent_validation_required: true
  independent_cr_required: true
```

如当前环境没有子 agent / 外部 CR 能力，是否允许 self review：

- self_review_allowed: false
- Reason:
