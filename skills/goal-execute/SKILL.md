---
name: goal-execute
description: Execute a prepared .goal package for complex features. Use when the user asks to run, resume, or continue a Goal, execute from .goal/status.yaml next_slice, orchestrate worker / validator / reviewer subagents, or enforce slice-by-slice implementation with validation, CR files, deferred controls, mock cleanup, and global exit checks.
---

# Goal Execute

Goal Execute 默认采用 **continuous 主线程负责制**：主 agent 是当前 slice 的技术负责人，必须掌握领域口径、实现策略、验证证据和 CR 结论。用户说“用 goal 开工 / 按 goal 执行 / 继续 Goal”时，默认从 `.goal/status.yaml` 的 current/next slice 连续推进；完成一个 slice 后自动进入下一 slice，直到 Goal 完成、真正阻塞、或需要人工介入。

## 使用时机

- 用户说“按 Goal 执行 / 用 goal 开工 / 续跑 goal / 从 status.yaml 的 next 继续”时，默认进入连续执行。
- 用户明确说“只跑一片 / 先做当前 slice / 先停在 Rxx / 不要继续下一片”时，才进入单切片执行。
- 目标 feature 已有 `.goal/GOAL.md`、`.goal/slices.yaml`、`.goal/status.yaml`。
- 复杂实现需要跨上下文恢复，并要求每个切片经过实现、验证、CR、修复、状态更新和 commit。

## 非适用场景

- 还没有通过 Goal Gate 的 feature；先读取 `references/stages/goal-handoff.md` 生成并检查 Goal 包。
- 轻量改动、单文件 bugfix 或不需要结构化恢复的短任务；使用 `references/stages/implementation.md`。
- 方案、需求或 Design CR 仍有 Blocking Pending；回到对应阶段。

## 必读输入

在执行任何代码改动前，按**最小恢复集**读取，避免每轮把整个 Goal 包重读一遍：

1. `.goal/status.yaml`（唯一状态源）。
2. `.goal/slices.yaml` 中 `current_slice` 或 `next_slice` 对应切片。
3. `.goal/resume.md` 的 Current Snapshot；若与 `status.yaml` 冲突，以 `status.yaml` 为准并立刻回写 `resume.md`。
4. 当前 slice 最近一份 `.goal/runs/`、`.goal/validation/`、`.goal/cr/` 报告（只读当前 slice，不回溯全部历史）。
5. 当前切片 `required_docs` 中与本轮改动直接相关的条目；`GOAL.md` / `acceptance.md` / `review-policy.md` 只在 slice 开工、口径变更、或 Exit 审计时全量核对。
6. `git status`、当前分支、最近 commit；按 `references/git-safety.md` 确认是否禁止本地 merge / rebase 主干。
7. 目标业务项目的 `README.md`、`AGENTS.md`、`CLAUDE.md`：仅在 Goal 首次开工、跨模块边界不清、或本地规则可能覆盖 playbook 时读取。
8. 当前 slice 涉及前端 + API 交互时，核对 `tasks.md` / `slices.yaml` 是否继承 Frontend-first Mock Lane；若本轮只发现局部待确认或 CR 建议，读取 TODO ledger 位置并按问题分流继续推进。

聊天历史不是权威来源。若聊天与 `.goal/status.yaml` 冲突，以 `status.yaml` 为准；若 `status.yaml` 与 git 明显冲突，先核对并回写状态。

## 执行模式

Goal Execute 必须先判定 `run_mode`，并写入本轮执行说明或 `.goal/status.yaml.run_control`：

| 模式 | 触发 | 允许动作 | 停止点 |
| --- | --- | --- | --- |
| `prepare_only` | 用户问“能否开工 / 当前状态 / 可以开发么” | 只读检查、状态判断、列下一步 | 不改代码、不推进 slice |
| `continuous` | 默认；“用 goal 开工 / 按 goal 执行 / 继续 goal” | 在每个安全边界后继续下一 slice | Goal 完成、真正阻塞、needs_human_intervention、用户打断、工具上限 |
| `single_slice` | 用户明确说“只跑一片 / 先停在当前 slice / 不要继续下一片” | 只执行 `current_slice` 或 `next_slice` | 当前 slice commit / blocked / needs_human_intervention / 可恢复状态后停下 |
| `release_gate` | 用户明确发布、上线、发测试/生产、真实 provider smoke、生产 SSH | 允许发布级检查和上线前置验证 | 发布门禁完成或阻塞 |

没有明确 `single_slice` 或 `prepare_only` 限制时，不得在普通安全边界停住等待用户确认；应继续下一 slice。Codex app goal 仍只是 UI 镜像，不能替代 `.goal/status.yaml`。

## Codex App Goal 镜像

Codex app goal 只作为 UI 可视化镜像，不能替代 `.goal/status.yaml`、`.goal/resume.md` 或文件化报告。详细切片进度仍写入项目 `.goal/status.yaml`。

当运行环境提供 Codex app goal 工具时：

1. 先读取项目 `.goal/status.yaml` 和 `.goal/GOAL.md`，再用 `get_goal` 检查 app 级 goal 状态。
2. Goal Execute 在 Codex app 中默认启用 UI 镜像；如果 `.goal/status.yaml` 没有 `codex_app_goal` 字段，按 `enabled: true` 处理。只有明确写 `codex_app_goal.enabled: false` 时才跳过 app goal 镜像。
3. 如果当前没有匹配的 active app goal，则调用 `create_goal` 创建 app-level goal，objective 应来自项目 `.goal/GOAL.md`、feature id 和当前 `next_slice`；不需要用户额外点名“创建 app goal 进度条”。
4. 如果已经存在匹配 app goal，复用它；如果存在不匹配的 active app goal，不要覆盖，继续以 `.goal/status.yaml` 执行，并在同步中说明冲突。
5. 每个 slice 的真实进度只更新 `.goal/status.yaml`；app goal 只同步线程级目标存在感和终态。
6. Goal 完成时按 app 工具契约调用 `update_goal` 标记 complete；若 `.goal/status.yaml` 进入 `blocked` 或 `needs_human_intervention`，只有在 app 工具规则允许时才标记 blocked，否则在最终回复和 `status.yaml` 中说明人工接手入口。

如果没有 app goal 工具，Goal Execute 仍正常运行；不要为了 UI 进度条阻塞 `.goal` 执行。

## 主 Agent 职责

主 agent 是技术负责人 / final integrator，必须做这些事：

- 读取 `.goal/status.yaml`、当前 slice 和执行契约。
- 为 implementer / fixer / validator / reviewer 生成最小执行包。
- 审计子 agent 输出：scope、diff、测试、验证证据、CR findings、mock ledger、worktree 状态。
- 判断问题归属：局部实现问题交给 implementer / fixer，验证脚本问题交给 validator，设计偏差回到方案阶段。
- 只有主 agent 可以更新 `.goal/status.yaml`、合并 worktree、提交 commit、推进下一片。
- 在当前 slice 开始前决定实现所有者：`main_thread`、`worker` 或 `hybrid`，并说明原因。

主 agent 不再默认降级为纯调度员。以下场景优先使用 `main_thread` 或 `hybrid`，因为实现质量依赖主线程的完整上下文：

- 核心领域模型、状态机、DTO / Entity / migration、预算 / 计费 / provider、锁 / 并发 / 幂等。
- 用户刚修正口径，或存在旧文档、当前代码、最新要求需要同步。
- 上一轮 worker 首版质量低、CR 多轮返修，或当前 slice 的主要风险是业务语义而非机械改动。
- 小而聚焦的 slice，主线程直接实现比派发 worker 更可控。

仍优先使用 `worker` 的场景：

- 大量机械改文件、重复测试补齐、UI 状态矩阵填充、低语义风险的局部实现。
- 明确需要隔离上下文或并行 worktree，且 ownership 不碰共享契约。

无论谁实现，validator 和 reviewer 必须保持独立；主线程实现不能替代验证或 CR。

主 agent 直接编辑当前 slice 的业务代码时，必须满足：

- 本轮 `implementation_owner.mode` 为 `main_thread` 或 `hybrid`，或用户明确授权主线程实现。
- 在 `.goal/runs/<slice>-main-thread-<n>.md` 或最终 slice 报告中写明原因、范围、改动、测试和风险。
- 后续仍有独立 `.goal/validation/` 和 `.goal/cr/` 报告。

允许的直接编辑范围包括：

- `.goal/status.yaml`、`.goal/resume.md`、`.goal/runs/`、`.goal/validation/`、`.goal/cr/`、`.goal/mock-ledger.md` 等执行状态和报告。
- 当前 slice 在 `implementation_owner` 中声明给主线程的业务代码、测试代码和文档。
- worker 输出后的合并冲突收口、报告索引、最终集成记录。
- 用户明确要求主线程修正的元数据、文档或状态文件。

如果没有可用子 agent / worker 工具，主 agent 可以按 `main_thread` 实现当前 slice，但必须保留独立验证和 CR；如果连独立验证 / CR 都不可用，则停止并写明缺口，不能用自测冒充完整门禁。

主 agent 不应把所有实现细节长期只留在聊天上下文里；它应依赖文件化报告恢复上下文。若已经在未判定 `implementation_owner` 的情况下编辑业务代码，必须立即停止继续扩展，把已产生 diff 收敛为 main-thread 报告或 worker 输入，并在报告中说明偏差和补救。只有能明确隔离为主 agent 本轮产生的 diff 且用户授权时，才允许回滚；不得回滚用户或其他 worker 的未提交改动。

## 子 Agent 职责

- implementer / fixer：只改当前 slice scope 内文件，输出 `.goal/runs/<slice>-<role>-<n>.md`。
- validator：运行可验功能、contract test、smoke、mock 清理检查，输出 `.goal/validation/<slice>-<kind>-<n>.md`。
- reviewer：做 scoped CR，输出 `.goal/cr/<slice>-round-<n>.md`。
- worktree worker：仅在 `worktree-plan.md` 允许时使用，必须遵守 ownership 和 merge order。

子 agent 禁止：

- 直接修改 `.goal/status.yaml` 推进状态。
- 合并 worktree、提交 commit 或决定下一片。
- 扩大 slice scope，或修改未授权的共享契约。
- 用聊天回复代替文件化报告。

## 实现所有者 Gate

每个 slice 执行前必须判定：

```yaml
implementation_owner:
  mode: main_thread | worker | hybrid
  reason: "<为什么这样更能保证质量>"
  main_thread_may_edit:
    - "<files/modules>"
  worker_scope:
    - "<files/modules or none>"
  independent_validation_required: true
  independent_cr_required: true
```

如果现有 Goal 包仍写 `self_run_allowed: false` 或 `main_agent_may_edit_business_code: false`，按新规则解释为“禁止无记录、无独立验证/CR 的主线程裸跑”，不等于禁止 `implementation_owner=main_thread|hybrid`。若项目 `.goal/gate.md` 明确硬性禁止主线程编辑，则遵循项目契约并标为需要 Goal 包更新。

## 吞吐与防空转

完整工作流必须保留：实现 → 验证 → CR → 修复 → Exit → commit。优化的是**空转**，不是砍门禁。

### Slice 粒度

- 一个开发 slice 只服务一条主用户路径的最小闭环。
- 涉及前端项目 + API 交互时，Goal 必须继承 `tasks.md` 的 Frontend-first Mock Lane：`CONTRACT → FE_MOCK_LOOP → SERVER_CAPABILITY → MOCK_REPLACEMENT → INTEGRATION / QA`。执行阶段不得重新按独立功能点重排 slice。
- `FE_MOCK_LOOP` slice 只要求前端功能、接口 mock / 接口壳、mock 数据、浏览器 smoke 和 UI Drift 跑通；后端 DB / service / job 真实化放到后续 `SERVER_CAPABILITY` / `MOCK_REPLACEMENT` slice 逐步替换。
- 命中任意两项以上时必须拆片，不得塞进同一开发 slice：异步 Job/lease、多维度 embedding/生命周期、预算/provider 结算、identity 失效/级联写、未冻结契约下的前后端同改。
- 默认建议：`task_ids ≤ 2`，并发关键子系统 ≤ 1。
- 若首轮 CR 已出现 ≥ 3 个 P1 竞态/一致性 finding，停止继续堆 fixer；先评估拆 follow-on slice 或切 `main_thread/hybrid` 收口骨架。

### 验证与 CR 对齐

- `max_pre_cr_validation_rounds: 1`：实现后最多完整验证一轮；验证失败修复后再完整验证一轮即可进入 CR，禁止验证空转 3+ 轮才首次 CR。
- CR 后只重跑**受影响**的 tests / probes，不默认重跑整库 migration + 全量 suite。
- 并发 / Job / lease / 审批竞态类 slice：validator 在宣称 Passed 前必须覆盖 CR 会审的竞态清单（锁内再校验、lease token、await 持久化、identity 迁移、approved-only 重读）。验证绿但未覆盖这些点，不算可进入 CR 的有效绿。
- 禁止在 CR 阻塞 findings 仍 open 时启动正交 fixer（例如无关口径小改、下一切片预研、发布 hardening）。

### UI Drift 时机

- 前端 slice：UI Drift Gate 默认在**进入首轮 CR 前跑一次**，以及 **CR 修复改到页面/UI 状态后、复审前再跑一次**。
- 禁止在每个中间 fixer 轮次重复跑完整 ui-drift / impeccable 审计，除非本轮 fix 明确改了 UI。

### Fixer 预算与 owner 升级

```text
同一 finding / finding class：
  fixer round 1 → fixer round 2
  → 仍未关闭：切换 implementation_owner=main_thread|hybrid，由主线程收口
  → 主线程一轮后仍未关闭：design_sync / human_intervention / blocked
  禁止 silent fixer-3+
```

- `max_fix_rounds_per_finding: 2`（worker fixer）。第 3 次同类修复必须由主线程承担或升级分流，不得继续派同质 fixer。
- 同一 slice 累计 worker fixer ≥ 3 且仍有阻塞项：强制切 `main_thread|hybrid`。

### Mid-slice TODO / Requirement Delta

Goal 是连续交付机器。任务拆好以后，局部待确认、CR 中的需求优化、交互建议、未来扩展或契约优化，默认写入 TODO ledger，不阻塞当前 slice 完成或下一 slice 推进。

只有以下情况才升级为 Blocking Delta：

- 当前 slice 的 P0/P1 验收无法判断或无法成立。
- 继续推进会制造错误数据、错误权限或错误状态。
- 后续 slice 直接依赖未确认契约，且无法通过 mock、adapter 或 feature flag 隔离。
- 用户明确要求先停下确认。

用户在 slice `in_progress` 期间给出最新口径时：

1. 先分类为 `todo_candidate` 或 `blocking_delta`。
2. `todo_candidate`：写入 TODO ledger / `.goal/risks-deferred.md` / 后续 slice gate，标清影响、owner、最晚对齐点；当前 slice 按原验收继续收口。
3. `blocking_delta`：把 `execution.state` 记为可恢复的 `requirement_delta_pending`（或在 `blocked.reason` / `resume.md` 写明），冻结新的正交 fixer。
4. 对 Blocking Delta 做 Cross-doc Consistency Scan，同步 `requirements.md` / `plan.md` / `acceptance.md` / 当前 slice acceptance。
5. 再二选一：修订当前 slice scope 并从头补验证/CR；或把未完成部分拆到 follow-on slice。
6. 不得在旧 CR findings 仍 open 时，用“顺手修 delta”打断 CR 闭环；也不得把非阻塞 TODO 当成停止 Goal 的理由。

### Legacy Goal 包兼容

旧 Goal 包若仍要求开发 slice `nit: 0` / 全部 findings 清零，或把主 agent 锁死为纯调度员：

- 普通开发 slice 默认采用本 playbook 吞吐规则：阻塞项清零，P2/Nit 可登记 non-blocking follow-up；主线程可按 `implementation_owner` 实现。
- 在本轮 CR / `status.yaml` / `resume.md` 记录 policy override 与原因。
- 仅当用户明确要求“零 Nit”或当前是 `release_gate` 时，才强制全部 findings 关闭。
- 建议在下一轮 Goal Handoff / Gate 刷新时用最新模板重生 `.goal/review-policy.md` 与 owner 字段。

### SSOT 同步

每个 implementer / fixer / validator / reviewer 步骤结束后，主 agent 必须在同轮更新：

- `status.yaml`：`last_*`、`counters`、`active_workers`、`implementation_owner`、`safe_to_commit`
- `resume.md` Current Snapshot

禁止留下“报告说已修完、status 仍 open_cr_findings>0、resume 仍停在上一片”的三本账。

## 执行循环

```text
读取 status.yaml + slices.yaml[next]
→ 若 Codex app goal 可用且未显式关闭，创建或复用 app-level goal
→ 若有未提交改动，收敛 current_slice；不得用 `--autostash` 自动 merge / rebase 主干
→ 判定 run_mode；默认 continuous
→ 判定 implementation_owner；主线程保留技术负责人职责
→ 主 agent 生成当前 slice 执行包
→ 主线程或 implementer / fixer 完成当前 slice.scope
→ 派发 validator 运行 slice.tests、contract、smoke 或 mock 清理检查
→ 派发 reviewer 生成 .goal/cr/<slice>-round-1.md
→ 主 agent 审计报告和 diff
→ 修复当前 slice 范围内的所有阻塞问题
→ 将非阻塞问题、局部待确认和需求优化分流到 TODO / discussion / deferred risks / 后续 slice gate
→ 复审直到当前 slice 阻塞项为 0，或确认主链路不可安全推进
→ 运行 Goal Exit 检查
→ 更新 status.yaml
→ commit
→ 若达到 Goal 终态，按 app goal 工具契约同步完成 / 阻塞终态
→ continuous 默认继续下一 slice；single_slice 才停下汇报
```

每个切片只能在 Exit 全部满足后标记 done。实现报告缺失、验证失败、CR 阻塞项未关闭、未登记 mock、status 未更新都不能 commit。若仅剩必须人工介入的问题，按 Human Intervention 规则登记；Goal 最终状态不能标 `complete`。

## 状态机

`status.yaml` 是唯一执行状态源。推荐状态：

- `ready`
- `in_progress`
- `requirement_delta_pending`
- `test_failed`
- `cr_pending`
- `cr_changes_requested`
- `blocked`
- `needs_human_intervention`
- `complete`

进入切片时：

- `execution.current_slice` = 当前 slice。
- `execution.state` = `in_progress`。

切片完成时：

- 当前 slice 状态改为 `done`。
- `execution.next_slice` 指向下一片；最后一片为 `null`。
- `execution.current_slice` 清空。
- `last_cr` 指向最后一轮 `.goal/cr/<slice>-round-<n>.md`。
- 更新 `counters.open_blocker`、`counters.open_cr_findings`、`counters.open_deferred`、`counters.open_human_intervention`、`counters.http_mock_count`。

执行中如果存在 active workers，`status.yaml` 应记录 worker id / role / slice / report path / state。worker 完成不代表 slice 完成；只有主 agent 完成 Exit 审计后才能推进。

active worker 必须可追踪。若 worker 在线程列表 / worker 管理器中不可见、长时间无报告、或 `status.yaml` 记录与实际工作区不一致，主 agent 必须将其标记为 `stale`，收敛当前 diff 和报告，停在 `blocked` 或可恢复状态；不得继续假装 worker 仍在执行。

## 问题分流

Goal 长链路默认不断流。验证、CR 或实现中发现的问题，先判断是否阻塞当前 slice 主链路：

| 类型 | 处理 |
| --- | --- |
| 当前 slice 范围内，影响正确性、数据安全、发布安全、状态一致性、接口契约或当前验收 | 当前 slice 必须修复，验证 / CR 复跑，阻塞 findings 为 0 后才能提交 |
| 不影响当前 slice 交付，但需要后续讨论或人工判断 | 写入 TODO / discussion / `.goal/risks-deferred.md`，标清影响、owner、触发条件、最晚对齐点，继续主链路 |
| 只影响后续 slice | 写入对应后续 slice 的前置检查、tasks 或 `.goal/design-handoff.md`，不阻塞当前 slice |
| 外部依赖、真实环境、生产验证、真实 provider smoke | 当前 slice 可用 local/mock 完成时，登记到 release / smoke / R09 / R10 gate，不阻塞当前 slice |
| 状态文件、工作区、worker 结果不一致到不可恢复，或无法保证主链路继续正确推进 | 进入 `blocked` 或 `needs_human_intervention` |

禁止把“后续讨论项、局部待确认、真实环境验证、P2/Nit、外部资源缺口”混入当前 slice 的无限返修循环；也禁止把当前 slice 正确性问题伪装成后续项。

## 开发 Gate 与发布 Gate

普通开发 slice 只做开发级验证：

- 本地 DB / disposable DB、migration replay、单测、集成测试、mock/local provider、contract、UI smoke。
- 不连接生产 / 测试 / 预发真实环境，不执行生产 SSH，不安装线上系统包，不做真实 provider 付费 smoke，除非当前 `run_mode=release_gate` 或 slice 明确属于发布前置。

发布级验证放入 release slice / R10 / `release_gate`：

- 生产或测试服务器 SSH、系统包安装、真实 provider smoke、凭据/日志/ACL/SELinux、回滚、灰度、备份、发布后验证。
- 如果开发 slice 发现发布风险，只记录到发布 gate 或 `risks-deferred.md`，不要把当前开发切片升级成生产演练。

## 验证要求

可验功能应尽早验证，不要积压到最后：

- UI mock smoke：验证页面、操作矩阵、loading / empty / error / 权限态。
- API contract test：验证 DTO、状态码、错误码、mock policy。
- Service / job test：验证被依赖业务逻辑、状态流、幂等、重试。
- Mock 清理检查：验证 mock ledger 对应项已关闭。
- Integration smoke：验证写 API、读 API、页面可见结果和失败态闭环。

当前 slice 涉及前端页面、后台工具、审核流、任务流、表单、表格或复杂 UI 状态时，验证必须包含 UI Drift Gate；时机遵循「吞吐与防空转 / UI Drift 时机」，不要每个中间 fixer 都全量重跑：

- 对照已确认的 `ui-flow.md` / `prototype/` 检查实现是否偏离主路径、操作矩阵、状态映射、权限和错误态；如果 UI 基线来自 Open Design，同时定位 projectId、studioUrl/previewUrl、entryFile 或 artifact bundle，必要时用 `get_artifact` 拉取 entry file 和依赖文件作为验证证据。
- 如果目标项目存在 `.agents/skills/impeccable/SKILL.md`，默认按 `impeccable audit` 做技术质量检查；若主要风险是信息架构、主次操作、视觉层级或清晰度偏离原型，再按 `impeccable critique` 补设计审查。
- 如果是在 CR 后修复前端问题，默认按 `impeccable polish` 做视觉、布局、文案和状态细节修复；修完再按 `impeccable audit` 复验，必要时补 `impeccable critique`。
- 验证报告必须记录使用的 impeccable 命令或 skipped 原因，以及 `UI Drift: Passed / Fixed / Blocking / Skipped`。
- 发现主用户路径、审核对象、状态流、权限或 API/ViewModel 契约变化时，不能在 slice 内静默修复，必须标为 Blocking 并回到 UI Flow / 方案阶段做 Change Sync。

验证报告必须写入 `.goal/validation/`，并作为 CR 输入。测试绿不能替代验证报告；验证报告也不能替代 CR。

## CR 要求

代码改动默认必须有文件化 CR。每轮 CR 独立落盘：

```text
.goal/cr/<slice>-round-<n>.md
```

CR 文件必须包含：

- reviewer kind：`subagent` / `external` / `self`。
- reviewer role：Domain / Architecture / FE / Backend / DB / AI Pipeline / Delivery / Release 等。
- 当前 slice 和任务范围。
- 输入的 worker report 和 validation report。
- 已运行测试命令及结果。
- acceptance 覆盖表。
- 前端 slice 的 UI Drift 结论、impeccable 命令或 skipped 原因。
- Findings：P0 / P1 / P2 / Nit，或 Blocker / Should-fix / Nit，并说明是否阻塞当前 slice。
- 每条 finding 的关闭状态：`fixed` / `rejected_false_positive` / `human_intervention`。
- 普通开发 slice：当前 slice 阻塞项必须为 0；P2/Nit 或后续讨论项可记录为 non-blocking follow-up，必须有 owner、影响、触发条件或后续 slice。
- 局部待确认 / 需求优化 / 交互建议如果不影响当前 P0/P1 验收，必须记录为 TODO ledger 项，不作为 CR 阻塞项。
- `release_gate` 或用户明确要求“零 Nit / 全部修完”时，所有 findings 必须关闭。

禁止：

- 主 agent 在 `status.yaml` 中直接写 `Blocker=0` 冒充 CR。
- 用“测试绿”“build 绿”“实现子 agent”代替 CR。
- 用 validator report 代替 CR。
- 用 worker report 代替验证或 CR。
- CR 文件不存在时 commit 代码改动。
- 遗留 P0/P1/Blocker/Should-fix 不处理。
- 把会影响正确性、数据、安全、发布或用户主路径的问题降级为 non-blocking P2/Nit。

如果环境不支持子 agent，只有在 `.goal/GOAL.md` 或 `.goal/gate.md` 明确允许 self review 时，才能写 `reviewer kind: self`，并必须标注原因。

## CR 修复循环

默认修复所有当前 slice 阻塞项；P2/Nit 和后续讨论项按问题分流处理：

```text
运行验证
→ 子 agent CR
→ 修复当前 slice 的 P0 / P1 / Blocker / Should-fix
→ P2 / Nit / 后续讨论项：不影响当前 slice 主链路时登记 non-blocking follow-up
→ 若修复改到前端页面 / UI 状态，重新执行 UI Drift Gate
→ 对误报写 rejected_false_positive 及理由
→ 重跑受影响验证
→ 再次 CR
→ 直到当前 slice 阻塞项 = 0，或主链路不可安全推进
```

同一 finding 默认最多经历 2 轮 worker fixer。第 3 轮不得继续派同质 fixer；主 agent 必须：

- 先切换 `implementation_owner=main_thread|hybrid` 由主线程收口一轮；或
- 需求 / 方案冲突：回到需求确认或 Change Sync；或
- 需要人类、外部环境或发布资源：登记 Human Intervention / release_gate；或
- 只是 P2/Nit 或后续讨论项且不影响当前 slice：登记 non-blocking follow-up，不继续耗时。

主线程收口后仍无法关闭当前 slice 阻塞项时，进入 `blocked` / `needs_human_intervention` / design sync，禁止 silent fixer-4+。

只有 agent 无法独立解决、必须人类介入的问题，才能登记为 Human Intervention TODO。它不是普通 Deferred，也不是 CR waiver。

Human Intervention 必须同时满足：

- 代码中有 `TODO(human-intervention:<slice>)` 注释，说明为什么 agent 不能解决。
- `.goal/human-intervention.md` 登记 `id`、`source_slice`、`reason`、`user_visible_impact`、`code_stub`、`required_human_action`。
- `status.yaml.counters.open_human_intervention > 0`。
- 最终 `execution.state` 只能是 `needs_human_intervention`，不能是 `complete`。

## Deferred 规则

默认不允许 Deferred。

仅当阻塞来自外部环境、第三方依赖、预发资源或用户明确接受的非本轮风险时，才能写入 `.goal/risks-deferred.md`。每条必须包含：

- `id`
- `source_slice`
- `expires_at_slice`
- `user_visible_impact`
- `code_stub`
- `owner_or_resolution`

最后一个 slice 禁止在 `open_deferred > 0` 时标记 done 或 complete。Deferred 必须关闭；如果风险仍需保留，Goal 应进入 `blocked` 或 `needs_human_intervention`，不能用 waiver 把 open Deferred 转成完成。

## Exit 检查

每个 slice commit 前必须确认：

- `slice.tests` 必跑项 exit 0，或失败原因已写入 `status.yaml.execution.state: blocked`。
- `.goal/runs/<slice>-*.md` 中必要实现报告存在，且 scope 未越界；若主线程实现，必须有 `.goal/runs/<slice>-main-thread-<n>.md` 或等价报告。
- `.goal/validation/<slice>-*.md` 中必要验证报告存在，或缺失原因已写入 slice exit / status。
- `.goal/cr/<slice>-round-<n>.md` 存在，且阻塞 findings 为 0；普通开发 slice 的 P2/Nit follow-up 已登记。
- 没有新增未登记 HTTP mock、fixture-only 读路径或 pending API。
- `.goal/mock-ledger.md` 与代码中的 mock / pending API 一致。
- 局部待确认、需求优化和交互建议已登记 TODO ledger；只要不破坏当前验收、数据/权限/状态正确性，不能阻塞下一 slice。
- worktree worker 已按 `.goal/worktree-plan.md` 合并或登记阻塞。
- 没有遗留未处理 P0/P1/Blocker/Should-fix 或普通 TODO；P2/Nit follow-up 已登记且不影响当前 slice。
- `status.yaml` 已更新为下一状态。
- commit message 包含 slice id 和主要 task id。

最后一片还必须确认：

- `execution.next_slice: null`。
- `counters.open_deferred: 0`。
- `counters.open_blocker: 0`。
- `counters.open_cr_findings: 0`。
- HTTP mock 计数为 0 或白名单有书面 waiver。
- P0 acceptance 全部通过或 waiver。
- `.goal/mock-ledger.md` 无 open 项，或所有 open 项都有书面 waiver。
- smoke A/B 状态明确。
- 若 `open_human_intervention > 0`，最终状态必须是 `needs_human_intervention`，并在最终回复列明人为介入项。

## 允许停止

只有以下情况允许结束执行：

- `next_slice: null` 且 global exit 全绿或有书面 waiver。
- `status.yaml.execution.state: blocked`，并写清不可恢复原因、证据和下一步需要谁处理。
- `status.yaml.execution.state: needs_human_intervention`，且自动可处理项已经全部完成。
- 用户明确要求停止或暂停。
- 工具/上下文硬上限；此时先尽量把当前 slice 收敛到可恢复状态，并更新 `status.yaml`。
- `run_mode: single_slice` 下当前 slice 已 commit / blocked / needs_human_intervention / 可恢复，并已向用户汇报。

普通切片边界默认不交还控制权：说明当前 slice 结果并继续下一 slice。只有 `run_mode: single_slice`、用户明确暂停、真正阻塞、needs_human_intervention 或工具上限时才停下。

## 上下文压缩

Goal Execute 不主动新开替代线程。上下文压缩不是停止理由，也不是开新线程理由。

允许主 agent 在当前 Goal 内调度受控子 agent、worker session 或 worktree worker 来降低主线程上下文压力；这些 worker 不是恢复权威，也不能替代当前 Goal 主线程。

恢复规则：

```text
读 .goal/status.yaml
→ 读 .goal/slices.yaml[next_slice 或 current_slice]
→ 读 .goal/resume.md
→ 读当前 slice 最近的 .goal/runs、.goal/validation、.goal/cr 报告
→ git status / git log
→ 继续当前 slice 或下一 slice
```

禁止为了上下文压缩提交半成品 checkpoint commit。只有达到安全边界才 commit：

```text
实现完成 → 验证绿 → CR open findings=0 或仅剩 Human Intervention → status 更新 → commit
```

如果上下文或工具硬上限临近但没有达到安全边界，只更新 `status.yaml` 和 `.goal/resume.md` 到可恢复状态，不 commit。

## 输出

执行中给用户的同步保持简短：

- 当前 slice。
- 已完成的验证。
- 下一步。

最终完成时汇报：

- 完成的 slices 和 commits。
- 关键 worker / validator / reviewer 报告。
- 关键测试 / smoke。
- CR 状态。
- Deferred / waiver / Human Intervention 清单。
- 与设计契约的偏差。
