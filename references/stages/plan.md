# 方案设计阶段

> 目标：站在业务架构师、技术架构师、交付负责人和资深 Reviewer 视角，先做好轻量领域抽象，再落到足够细的工程设计。方案阶段默认不改代码。

## 阶段门禁

- 用户说“写方案 / 设计一下 / 先讨论 / 先别写代码”时，只能停在方案阶段。
- 只有用户明确说“同意方案 / 按这个落地 / 开始实现 / 执行”时，才能进入实现阶段。
- 多轮讨论必须维护当前共识、已确认决策、待确认问题。
- 复杂需求进入方案设计前，必须完成需求确认；没有需求确认稿或等价确认记录时，先读取 `references/stages/requirement-confirmation.md` 并回到需求确认阶段。
- 如果存在 `docs/features/YYYYMMDD-short-topic/` 目录，`plan.md` 必须与 `requirements.md` 同目录；如果项目规则不同，必须在 `plan.md` 里引用需求确认稿路径。
- 需求阶段提出且会影响方案结构的问题，不能在方案阶段才决定；方案阶段只做论证、建模、工程映射和取舍说明。
- 关键决策表只记录业务 / 领域 / 架构决策，不能直接把字段名、表字段、DTO 字段或任务项写成已确认结论；字段必须经过 `references/plan/field-ownership.md` 的归属判断后，才能进入数据模型、API 和 `tasks.md`。
- 方案讨论中采纳用户反馈时，必须执行变更同步协议；不能只改 `plan.md` 而漏掉 `requirements.md`、`tasks.md`、`ui-flow.md` 或原型。
- 用户提出“最新要求 / 改方案并修逻辑 / 口径调整”时，必须先通过 Latest Requirement Delta Gate；若最新业务规则与旧方案、UI flow、任务或 `.goal` 契约冲突，先标 Blocking，不进入实现。
- 复杂方案在进入任务拆解或实现前，必须经过设计 CR；如果用户授权使用子 agent 且当前环境支持，优先唤起 scoped design CR 子 agent。

## 业务规则冲突门禁

### 原始业务规则优先级

用户原话、最新确认业务规则和需求确认基线优先于工程直觉。尤其是影响按钮可用、数量、额度、人工动作边界、审核对象或运营权限的规则，不能被“更严格 / 更安全 / 防 worker 压力 / input max”等工程限制静默覆盖。

如果出现以下情况，必须标为 Blocking 并回到需求确认或方案同步，而不是自行选择实现：

- 同一业务动作同时出现两个互斥约束，例如“手动新增固定 1 篇且不受 6 篇限制”与“本轮总 generation 不超过 6”。
- 业务规则说“不占额度 / 不读预算信号 / 不受上限约束”，工程方案或 UI flow 又把额度、预算或上限作为 action gate。
- 方案中的“安全 gate / provider readiness / worker 压力”会改变用户确认过的可用按钮、数量、人工动作边界或运营流程。
- 子 agent、CR 或实现者倾向于选择“看起来更保守”的实现，但该实现会降低业务可用性或改变产品口径。

### Latest Requirement Delta Gate

用户给出最新口径、推翻旧口径，或要求“按最新要求改方案并修逻辑”时，先输出并执行 Delta Gate：

| 最新口径 | 覆盖的旧口径 | 受影响文件 | 受影响代码 / 契约 | 冲突状态 |
| --- | --- | --- | --- | --- |
| 用户原话或需求确认结论 | 旧 requirements / plan / ui-flow / tasks / .goal 中的相反约束 | 必须同步的文档 | API / DTO / ViewModel / action gate / tests | Done / Blocking / Pending |

Delta Gate 通过标准：

- 最新口径已经写入 `requirements.md` 或等价需求基线。
- `plan.md`、`tasks.md`、`ui-flow.md`、原型说明和 `.goal/*` 没有旧口径残留。
- 对关键动作的按钮可用、数量、额度、状态 gate、人工动作边界有唯一解释。
- 所有仍存在的冲突都被列为 `Blocking`，等待用户确认，不能被实现阶段自行裁决。

### Cross-doc Consistency Scan

复杂方案进入实现前，必须围绕最新口径提取关键业务词和互斥约束，跨文档扫描：

```text
requirements.md
plan.md
tasks.md
ui-flow.md
design-review.md
.goal/GOAL.md
.goal/slices.yaml
.goal/acceptance.md
.goal/cr/*
```

推荐扫描词包括：业务动作名、按钮名、字段名、状态名、数量上限、额度、预算、manual / auto、provider readiness、blocked reason、action gate。扫描发现旧口径时，必须回到 Change Sync 或需求确认。

## 复杂 vs 轻量方案

先判断方案类型，再选模板和门禁：

| 类型 | 规则 | 模板 | 需求确认 | design CR | ui-flow |
| --- | --- | --- | --- | --- | --- |
| **轻量** | `references/stages/plan-light.md` | `templates/plan-light.md` | 可选一句范围 | 不强制 | 通常不需要 |
| **复杂** | 本文件 + `references/plan/*` | `templates/feature-design.md` | 复杂需求必填 | 必填 | 后台/审核/批量时必填 |

判断口径见本文件「默认不算复杂方案」与 AGENTS.md 复杂方案定义。不确定时按复杂方案处理。

## 必读规则

方案阶段必须按需读取：

- `references/stages/requirement-confirmation.md`（复杂需求或多轮需求讨论后）
- `references/plan/evidence-first.md`
- `references/plan/role-lens.md`
- `references/plan/domain-design.md`
- `references/plan/diagram-required.md`
- `references/plan/detail-gate.md`
- `references/plan/decision-table.md`
- `references/plan/field-ownership.md`
- `references/plan/task-breakdown.md`

涉及 LLM、AI 媒体、Chrome 插件、Nest/React/Postgres 时，再读取 `references/scenarios/*` 对应文件。

涉及后台页面、运营流程、审核流、批量操作或复杂前端状态时，再读取 `skills/fullstack-ui-prototype/SKILL.md` 和 `skills/react-vite-feature/SKILL.md`。

## 复杂需求端到端流程

复杂需求，尤其是后台页面、运营流程、审核流、批量操作、LLM/异步链路，默认按以下顺序推进：

```text
1. 需求分析
   -> requirements.md 草稿：业务目标、非目标、场景、输入输出、待确认

2. 需求确认
   -> requirements.md 基线：Confirmed / Pending Blocking / Pending Non-blocking / Assumed / No Longer Re-ask

3. UI Flow / 审核对象 / 静态原型
   -> 明确有哪些页面、用户从哪里进入、审核对象是什么、通过/打回/编辑在哪里发生
   -> ui-flow.md 和必要的 prototype/：页面地图、ViewModel、操作矩阵、状态映射、错误态、浏览器 smoke

4. Product Flow Gate
   -> 原型 / UI Flow 完成后必须停下，等待用户明确确认
   -> 只有收到“原型确认，进入详细技术方案 / 按这个原型写 plan.md / 同意 UI Flow，开始方案设计”等明确指令，才进入下一步

5. 详细技术方案设计
   -> plan.md 草案：领域抽象、业务结构图、核心流程、状态、数据流、字段归属、初版表/API/Job
   -> 技术方案只能基于已确认的 requirements + UI Flow / prototype

6. 方案回写与一致性同步
   -> Change Sync：把原型和讨论暴露的问题同步回 requirements.md / plan.md / tasks.md / ui-flow.md

7. 设计 CR
   -> Design Review Notes：领域、架构、交付、测试、专项风险

8. 方案定稿
   -> plan.md 无 Blocking，需求基线、UI flow、任务边界一致

9. 任务拆解
   -> tasks.md：依赖、验收、验证、CR

10. 实现
   -> 按 tasks.md 小步实现，每个任务经过测试和 CR
```

门禁：

- 没有需求确认，不进入技术方案。
- 没有页面流 / 审核对象草图，不进入 UI Flow / 原型阶段。
- 涉及后台页面、运营流程、审核流、批量操作或复杂前端状态时，没有 UI Flow / 静态原型，不进入详细技术方案设计。
- UI Flow / 静态原型完成后必须停下；没有用户明确确认原型并授权进入详细方案设计，不写详细 `plan.md`、不拆 `tasks.md`、不生成 Goal。
- 没有 Change Sync，不进入任务拆解。
- 没有 Design CR，不进入实现。

## 推荐推导顺序

```text
用户目标 / 旧方案 / 当前项目事实
→ 需求确认基线：Confirmed / Pending / Assumed、非目标、阻塞项、文档一致性
→ 证据来源表
→ 角色视角判断：业务 / 领域 / 架构 / 交付 / Review
→ 业务问题与非目标
→ 系统用例
→ 轻量领域抽象
→ 业务结构图
→ 流程图 / 状态图 / 数据流图
→ 工程映射
→ 字段归属表：资产侧 / 关系侧 / 任务侧 / 结果侧，生产者和消费者
→ 表 / Entity / API / DTO / ViewModel / Job
→ 决策表
→ 任务拆解
→ 测试与验收
→ 本轮待确认问题
```

## 方案变更同步协议

多轮方案讨论中，只要采纳用户反馈、CR 发现或新证据，就先判断影响面，再改文档。默认需要维护一张 `Change Sync` 表：

| 来源 | 判断 | 必改文件 | 可能联动 | 状态 |
| --- | --- | --- | --- | --- |
| 用户反馈 / CR / 新证据 | 需求口径 / 方案决策 / 字段归属 / 页面流程 / 任务边界 / 测试发布 | requirements.md / plan.md / tasks.md / ui-flow.md / prototype | API / DTO / migration / ViewModel / smoke | Done / Pending / Blocked |

同步规则：

- 改了需求口径、非目标、验收或待确认状态：必须同步 `requirements.md`。
- 改了领域抽象、关键决策、状态流、数据流、字段、表、API、DTO、ViewModel、Job：必须同步 `plan.md` 对应章节。
- 改了字段、表、API、DTO 或实现边界：必须同步 `tasks.md`；如果字段仍是 `Pending`，任务只能写“确认字段归属后落地”。
- 改了页面入口、审核对象、用户路径、操作按钮、状态映射或错误态：必须同步 `ui-flow.md`，必要时同步 `prototype/`。
- 改了测试、发布、回滚或 provider 开关：必须同步 `plan.md` 测试 / 发布章节和 `tasks.md` QA / Release 任务。
- 改了业务动作的可用条件、数量、额度、人工/自动边界或按钮文案：必须同步 `requirements.md`、`plan.md`、`tasks.md`、`ui-flow.md` 和 `.goal/*` 中对应验收、slice、CR 条目；不能只同步代码文件。
- 如果只改一个文件，必须在回复或文档中说明其它文件不需要同步的理由。

方案定稿前必须检查 `Change Sync` 没有 `Pending Blocking`；否则不能进入实现。

## 设计 CR 闸口

普通小改可以由主 agent 按 `references/plan/role-lens.md` 自审。复杂方案必须做设计 CR。

复杂方案不是看工作量大小，而是看不确定性、风险面和跨边界程度。命中任一强触发项，或命中两个及以上累积触发项，就按复杂方案处理。

强触发项：

- 涉及数据模型、表、Entity、migration、索引或唯一约束。
- 涉及状态字段、状态流转、审核、失效、重算。
- 涉及异步任务、LLM、AI provider、媒体产物、同步链路。
- 涉及权限、安全、计费、发布、回滚或数据补偿。
- 涉及不可逆数据操作，或需要明确发布、回滚、补偿方案。
- 涉及两个以上端或运行单元：后端、前端、插件、worker、admin、脚本、外部系统。
- 涉及复杂后台页面、运营流程、审核流、批量操作，或需要先看静态页面验证业务路径。
- 用户明确要求“把方案想透 / 多角度评审 / 唤起子 agent 讨论”。

累积触发项：

- 改动超过 3 个模块或 5 个文件。
- 涉及新 API、DTO、ViewModel、Job、页面之一。
- 有新业务概念，或旧概念职责发生变化。
- 有兼容旧数据、历史任务、旧接口或旧 UI 的要求。
- 有人工审核、运营动作、批量操作、导入导出。
- 有明显异常分支，例如失败重试、取消、超时、部分成功。
- 需要新增测试策略，而不是只跑现有测试。
- 方案里出现“先这样，后面再说”的待确认风险。
- 任务拆解超过 5 个任务，或任务之间存在依赖链。
- 新增或重构页面超过 1 个，或页面包含审核、发布、同步、重试、批量操作、状态驱动按钮之一。

默认不算复杂方案：

- 单纯文案、样式、布局微调。
- 单文件小 bugfix。
- 已有接口增加一个展示字段，且不改 DB、不改权限、不改状态。
- README、注释、日志文案调整。
- 只改测试，不改业务行为。

不确定时按复杂方案处理，但输出可以轻量；复杂不等于长，关键是证据、领域、流程/状态/数据流、任务和 CR 门禁要过。

设计 CR 节点：

```text
需求与证据收集后
→ 领域抽象初稿后
→ 表 / Entity / API / 任务拆解前
→ 方案定稿前
```

子 agent 角色建议：

- Domain Reviewer：检查核心概念、职责边界、生命周期、字段归属。
- Architecture Reviewer：检查模块边界、接口契约、异步链路、兼容性和扩展性。
- Delivery Reviewer：检查任务拆解、依赖顺序、测试范围、发布和回滚风险。
- Database Reviewer：仅在 DB / migration 复杂时使用，检查约束、索引、兼容数据和回滚策略。
- AI Pipeline Reviewer：仅在 LLM / AI 媒体链路复杂时使用，检查 fallback、成本保护、重试、幂等、产物状态和 smoke。

子 agent 输入应包含：

```text
用户目标
目标业务项目事实和证据来源
方案草案或 plan.md 路径
核心领域抽象
关键流程图 / 状态图 / 数据流图
拟定表 / Entity / API / DTO / ViewModel / Job
任务拆解草案
要求：只 review 当前方案的领域错误、架构风险、交付风险、测试缺口和实现前阻塞项。
```

主 agent 负责整合 CR 结论，而不是简单投票：

- Accepted：吸收到方案，并更新决策表或任务拆解。
- Rejected：记录拒绝原因，例如业务效率、交付成本、项目事实不支持。
- Deferred：记录到后续优化或风险跟踪，不阻塞本轮。
- Blocking：必须先修改方案，再进入实现。

如果当前环境不支持子 agent，或用户未授权使用子 agent，则主 agent 按 Domain / Architecture / Delivery / Review 视角自审，并在方案中标明 `Design CR: self-reviewed`。

方案文档建议记录：

```markdown
## Design Review Notes

| Reviewer | Finding | Severity | Decision | Reason |
| --- | --- | --- | --- | --- |
| Domain |  |  | Accepted / Rejected / Deferred / Blocking |  |
```

## 输出标准

方案不是一次性终稿。复杂需求第一版应是可评审草案，后续根据用户反馈迭代版本。

正式进入实现前，方案必须能回答：

- 各关键角色视角下，最需要防止的错误是什么。
- 为什么这样抽象。
- 哪些概念稳定，哪些只是一次任务上下文。
- 数据如何产生、流转、审核、失效、重算。
- 每个字段、状态、接口、任务的用途和验收标准。
- 图里的节点和边是否能对应到工程实现。
- 为什么不是其他方案，以及当前取舍牺牲了什么。
- 设计 CR 的阻塞项是否已处理；未处理项是否有明确的接受风险或后续安排。
- 涉及复杂前端时，UI flow 是否覆盖页面地图、ViewModel、操作矩阵、状态映射、权限、错误态和浏览器 smoke；必要的静态原型是否已验证业务路径。
