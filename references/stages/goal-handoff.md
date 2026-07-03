# Goal Handoff 阶段

> 目标：在复杂方案通过 Design CR 后，把 `plan.md` / `tasks.md` 转成可恢复、可检查、可连续执行的 `.goal/` 执行契约。Goal Handoff 是方案到实现之间的交接阶段，不重新讨论需求，不直接改业务代码。

## 使用时机

- 复杂 feature 已完成需求确认、方案、任务拆解和 Design CR，用户准备进入连续实现。
- 用户要求“生成 goal / 执行契约 / 按 goal 连续跑 / 不要中间停”。
- 任务包含多切片、多模块、异步任务、LLM/外部系统、前后端联调、smoke、CR 门禁或发布验收。
- 既有 `tasks.md` 无法稳定支撑上下文恢复、CR 审计或最终验收闭环。

## 强制场景

命中以下任一条件，Design CR Ready 后不能直接进入代码实现，必须先完成 Goal Handoff 并通过 Goal Gate：

- 用户要求连续执行、跨会话续跑、按 slice 实现、每片 CR / commit。
- 任务需要 5 个以上切片，或任务之间存在明显依赖链。
- 涉及异步任务、LLM / AI provider、外部系统、审核流、同步链路或发布 smoke。
- 涉及前后端联调，且 P0 用户路径需要写 API、读 API、页面可见结果闭环。
- 需要 Deferred / Human Intervention / 多轮 CR / 全局验收门禁。

满足强制场景时，`design-review.md Ready` 只代表方案门禁通过，不代表可以直接写代码；实现前还必须有 `.goal/status.yaml` 和 `gate.md: Ready`。

## 非适用场景

- 单文件 bugfix、文案样式、小范围测试补充。
- 1 到 3 步内能完成，且没有跨切片依赖或最终 smoke 的轻量需求。
- 需求仍有 Blocking Pending，或 Design CR 结论不是 Ready。

## 进入条件

必须先满足：

- `requirements.md` 或等价需求基线已区分 Confirmed / Pending / Assumed。
- `plan.md` 已定稿或有明确当前方案版本。
- `tasks.md` 已覆盖字段、状态、接口、任务、验证和 CR。
- 复杂方案 Design CR 无未关闭 P0；P1 不阻塞首轮实现。
- 相关 `ui-flow.md`、API 契约、状态图、数据流或发布/smoke 文档已同步。

如果任一条件不满足，回到需求确认、方案或设计 CR，不生成 Goal 包。

## 产物位置

默认在 feature 文档目录下生成：

```text
docs/features/<feature>/.goal/
├── GOAL.md
├── acceptance.md
├── slices.yaml
├── status.yaml
├── review-policy.md
├── mock-ledger.md
├── worktree-plan.md
├── human-intervention.md
├── resume.md
├── risks-deferred.md
├── design-handoff.md
├── gate.md
├── runs/
├── validation/
└── cr/
```

如果业务项目已有目录规范，遵循项目规范，但必须保留同等语义。

## Goal 包职责

| 文件 | 职责 |
| --- | --- |
| `GOAL.md` | 范围、非目标、分支、来源文档、全局完成标准、允许停止条件 |
| `acceptance.md` | 按用户路径写 P0/P1 验收，绑定写 API、读 API、页面可见结果和失败态 |
| `slices.yaml` | 每个切片的 scope、non-goals、必读文档、测试命令、Exit 清单和 CR 要求 |
| `status.yaml` | 唯一执行状态源：next slice、当前状态、active workers、last reports、open blocker/deferred、last CR、global exit |
| `review-policy.md` | CR 审核流程、角色矩阵、轮次、通过条件和所有 findings 的关闭规则 |
| `mock-ledger.md` | 记录 mock / pending API / fixture-only 读路径的创建、到期、清理和 waiver |
| `worktree-plan.md` | 记录允许并行的 worktree worker、ownership、merge order 和冲突策略 |
| `human-intervention.md` | 唯一允许遗留给人的事项；必须说明 agent 无法独立解决的原因 |
| `resume.md` | 上下文压缩后的同线程恢复提示；不用于主动新开线程 |
| `risks-deferred.md` | 允许的 Deferred 例外；默认 none |
| `design-handoff.md` | 方案结论、关键决策、契约指针、禁止执行期重辩论的边界 |
| `gate.md` | Goal Gate 检查结果：Ready / Not Ready，以及进入执行前必须修复的问题 |
| `runs/` | implementer / fixer worker 的文件化报告 |
| `validation/` | validator 的文件化验证报告 |
| `cr/` | 每个切片的文件化 CR 结果，禁止只在进度表中手写 Blocker=0 |

## 核心原则

- `.goal/status.yaml` 是执行阶段唯一状态源；不要同时维护 `execution-progress.md`、`tasks.md` 状态表和自然语言 goal 三本账。
- `tasks.md` 是设计阶段的任务来源，Goal Handoff 后执行进度只回写 `status.yaml`。
- 切片按用户路径拆，不按纯技术层拆；P0 页面主读接口必须在对应用户路径切片内真实化。
- Goal 包只写执行契约，不把业务事实从业务项目搬到 playbook。
- Goal Handoff 不能绕过 Design CR；如果生成 Goal 包时发现方案缺口，回到方案阶段。
- Goal 不主动新开替代线程；上下文压缩后仍在当前线程按 `status.yaml` 恢复。允许主 agent 在同一 Goal 内调度受控子 agent、worker session 或 worktree worker，但它们不能替代主线程权威状态。
- 主 agent 是 orchestrator / final integrator：只负责读取契约、派发 worker / validator / reviewer、审计证据、更新 `status.yaml`、合并和提交；实现、验证、CR 和局部修复可委派给子 agent。
- 子 agent 输出必须文件化到 `runs/`、`validation/` 或 `cr/`；聊天回复、子线程摘要或 worker 自述不能替代 `status.yaml`。
- CR findings 默认全部必须关闭，包括 Nit/P2；只有 `human-intervention.md` 登记的人为介入项可以遗留。

## Goal Gate

`gate.md` 为 Ready 前，禁止进入 `goal-execute`。

Ready 条件：

- P0 acceptance 每条都写清入口、写动作、读接口、用户可见结果、关键失败态。
- 每个 slice 都有明确 `scope`、`non_goals`、`workers`、`validators`、`cr.reviewer_roles`、`tests`、`exit` 和 CR 要求。
- 每个 slice 的 Exit 至少包含：worker report 存在、验证报告存在或有理由、验证绿、CR 文件存在、所有非人为介入 findings 已关闭、状态已更新、无新增未登记 mock。
- `review-policy.md` 明确 CR 循环：验证 -> 子 agent CR -> 修复 -> 复验 -> 复审，直到没有未关闭 findings。
- `mock-ledger.md` 已初始化；所有 mock / pending API 都有创建 slice、清理 slice、用户可见影响和状态。
- `worktree-plan.md` 已说明哪些任务允许并行、ownership、merge order 和共享契约冲突处理；共享 DTO / Entity / migration / 状态机默认不并行改。
- `human-intervention.md` 初始为空；如允许人为介入，必须写清触发条件、代码 TODO 规则和最终状态 `needs_human_intervention`。
- `resume.md` 明确上下文压缩后不新开线程、不做半成品 checkpoint commit。
- 最后一片有 global exit：`open_deferred=0`、`open_cr_findings=0`、HTTP mock 白名单为空或计数为 0、P0 acceptance 全绿或有书面 waiver、smoke A/B 状态明确。
- Deferred 默认禁止；若允许，必须写入 `risks-deferred.md`，包含 `expires_at_slice`、`user_visible_impact`、`code_stub` 和处理责任。
- `status.yaml` 初始化为 `next_slice` 指向第一片，`open_blocker=0`，`open_cr_findings=0`，`open_deferred=0`。

## 切片设计规则

切片应该能独立实现、独立验证、独立 CR、独立提交。

每个切片必须回答：

- 本切片服务哪条用户路径。
- 本切片的最小可见闭环是什么。
- 哪些 API / DTO / Job / 页面状态会被创建或改变。
- 哪些 worker 可以实现，哪些 validator 必须验证，哪些 reviewer 必须 CR。
- 哪些测试证明本切片完成。
- 哪些 mock 必须删除，哪些例外被允许到哪一片。
- 是否允许 worktree 并行；如果允许，ownership 和 merge order 是什么。
- CR 应对照哪些方案、任务、决策和验收文档，以及每轮 findings 如何关闭。
- 若 CR 问题无法由 agent 独立解决，如何登记 Human Intervention TODO。

禁止：

- 把“读路径真实化”“smoke”“Deferred 清零”默认留给最后一片。
- 用 build 绿替代用户路径验收。
- 用 worker report、validator report 或聊天摘要替代文件化 CR 和 `status.yaml`。
- 让子 agent 直接推进 `status.yaml`、合并 worktree、提交 commit 或决定下一片。
- 在契约未冻结时并行修改 DTO / Entity / migration / 状态枚举 / 核心 service。
- 把 Blocker 改写成 Deferred 而没有到期切片和用户可见影响。
- 遗留 Nit/P2、Should-fix 或其他 agent 可解决问题。
- 为上下文压缩主动新开线程，或为了压缩提交未通过测试/CR 的半成品 checkpoint commit。
- 生成只有自然语言流程、没有结构化状态和 Exit 的 goal。

## 与实现阶段关系

普通实现继续使用 `references/stages/implementation.md`。

当 feature 存在 `.goal/status.yaml` 且用户要求按 Goal 续跑时，进入 `skills/goal-execute/SKILL.md`：

```text
Goal Handoff Ready
→ goal-execute 只读 status.yaml + slices.yaml[next]
→ 主 agent 派发 worker / validator / reviewer
→ 单切片实现 / 验证 / CR / 修复 / 复验 / 复审 / 状态更新 / commit
→ 可恢复地继续下一切片
```

如果执行中发现方案不成立，必须把 `status.yaml.execution.state` 写为 `blocked`，说明原因，并回到方案阶段。
