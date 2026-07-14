---
name: fullstack-ui-prototype
description: Design or review full-stack feature UI flows and static prototypes before implementation, especially for admin pages, workflow tools, review/approval flows, task dashboards, batch operations, or features where frontend ViewModel, API contracts, backend status, and user operations must be validated together.
---

# Fullstack UI Prototype

## 使用时机

- 全栈功能设计涉及后台页面、运营工具、审核流、任务流、批量操作、导入导出、同步/发布动作。
- 方案里出现新页面、新路由、新 ViewModel、复杂表单、列表筛选、详情页、状态流转或人工确认动作。
- 用户要求先看页面风格、业务流程、静态页面、原型、交互路径或“能不能落地”。
- 技术方案已经有 DB/API/状态，但仍无法判断用户如何操作、何处审核、失败如何展示。

## 不适用

- 纯后端能力、CLI、Job、脚本或 provider 封装，且没有用户操作界面。
- 单个按钮、文案、样式或布局微调。
- 已有页面只增加一个展示字段，且不改状态、不改权限、不改操作链路。

## 必读上下文

1. 目标业务项目自己的 `README.md`、`AGENTS.md`、`CLAUDE.md` 和相关前端文档。
2. `references/stages/plan.md` 与 `references/plan/*`。
3. `skills/react-vite-feature/SKILL.md`。
4. 涉及 NestJS / React / PostgreSQL 时，读取 `references/scenarios/nest-react-postgres.md`。
5. 涉及权限、审核、发布、同步或敏感信息时，读取 `references/review-kit/security.md`。
6. 判断需要使用 Open Design 时，读取 `references/scenarios/open-design.md`。

## 目录约定

优先尊重目标项目已有结构。

- 如果项目已有顶层 `prototype/`，例如多端原型集中管理，优先放在 `prototype/<surface-or-feature>/`。
- 如果项目以 feature 文档目录管理需求，优先放在 `docs/features/YYYYMMDD-short-topic/prototype/`。
- 如果已经有 `docs/features/YYYYMMDD-short-topic/requirements.md`、`plan.md` 和 `tasks.md`，同目录补 `ui-flow.md`。
- 不要把通用 playbook 的示例业务写进目标项目；原型使用当前业务项目事实和 mock 数据。

推荐 feature 目录：

```text
docs/features/YYYYMMDD-short-topic/
  requirements.md
  plan.md
  tasks.md
  notes.md
  ui-flow.md
  prototype/
    index.html
    styles.css
    mock-data.js
```

推荐集中原型目录：

```text
prototype/<surface-or-feature>/
  README.md
  index.html
  styles.css
  mock-data.js
  app.jsx
```

## 方案门禁

复杂全栈方案进入详细技术方案前，必须先补 UI flow；如果页面流程不直观，必须补静态原型或明确说明为什么不需要。

## Open Design 接入

`Open Design` 是可选的设计探索工作台，用来生成或比较 UI flow、视觉方向、交互原型和可给用户确认的设计稿；它不替代本 skill 的业务流程、ViewModel、API、状态和权限推导，也不替代 impeccable 的质量检查。实际执行细节见 `references/scenarios/open-design.md`。

进入 UI Flow / 原型阶段时，先做 Open Design decision，而不是直接启动工具。decision 只允许 `skip / existing-baseline / run / blocked` 四种：

| Decision | 使用口径 |
| --- | --- |
| `skip` | 不需要 Open Design；适合小 UI 调整、已有设计系统内的微调、已有非 Open Design 确认稿 |
| `existing-baseline` | 已有 Open Design 确认稿；只定位项目和拉取 artifact，不新建 run |
| `run` | 需要新的设计探索、多版方向或复杂交互可视化确认 |
| `blocked` | 用户明确要求必须用 Open Design 但工具不可用，或业务规则未确认导致设计探索会误导 |

适用时机：

- 新页面、新信息架构、大改版或跨多个页面的主用户路径尚不直观。
- 后台/运营/审核/批量操作涉及多个角色、状态、异常分支，需要先用可视化稿确认“用户怎么走”。
- 用户明确要求“看设计稿 / 多给几个风格 / 用 Open Design / 先用 AI 设计交互”。
- 现有页面要做整体风格升级，需要比较 2 个以上视觉方向或先让用户确认调性。

不适用：

- 单个按钮、字段、文案、间距、颜色、局部组件状态或已有设计系统内的小改动。
- 业务规则、权限、状态流、API/ViewModel 契约仍未确认，且设计稿会掩盖这些 Blocking 问题。
- 已有明确 Figma/设计稿/确认原型，且本轮只是按稿实现或做 UI Drift 检查。

使用规则：

- 使用 Open Design 前，先用当前项目事实和 `ui-flow.md` 草稿约束范围；不要让设计工具自行发明业务规则、权限、状态流或 API 字段。
- 使用 MCP 时按真实工具链执行：`create_project` 或定位 active project -> `list_agents` / `list_skills` / `list_plugins`（按需）-> `start_run` -> `get_run` 轮询到终态 -> `get_artifact` 拉取源码包。不要跳过 run 直接用 `write_file` 伪造设计探索结果。
- 如果 decision 是 `existing-baseline`，只定位已确认项目 / 截图 / entry file 并拉取 artifact；不要为了补流程重复启动 `start_run`。
- Open Design 产物必须作为设计输入记录；`run` / `existing-baseline` 记录 projectId、studioUrl / previewUrl、entryFile 或 artifact bundle，`run` 还要记录采用版本、拒绝版本和待确认问题；`skip` 只记录 reason 和替代验证方式；`blocked` 记录 blocker 和恢复条件。
- Open Design 生成通常是异步长任务，预期 5-30 分钟；只有收益足以覆盖等待成本时才使用。`status:running` 且文件未变化不是卡死，按 30-60 秒轮询并向用户报进度。
- 如果 run 超出当前会话可承受窗口，记录 projectId、runId、studioUrl、当前状态和恢复方式；不能把 pending run 当成已确认设计。
- 如果 Open Design 产物改变主用户路径、审核对象、操作矩阵、状态流、权限或 API/ViewModel 契约，必须回到 UI Flow / 方案阶段做 Change Sync，并再次等待用户确认。
- Product Flow Gate 前仍要按 `impeccable critique` 或等价视角检查信息架构、视觉层级、清晰度、响应式和 AI UI 反模式；Open Design 通过不等于 impeccable 通过。
- 如果 Open Design daemon / MCP / 可用 agent 不可用，且用户没有明确要求必须用 Open Design，记录 skipped 原因并改用 `ui-flow.md` + 静态原型 + impeccable 自审；如果用户明确要求必须使用，则停下说明阻塞。

## Impeccable 接入

`impeccable` 是 UI/UX 质量增强层，不替代本 skill 的业务流程、ViewModel、API、状态和权限推导。

适用时机：

- 生成或评审静态原型前，如果目标项目存在 `.agents/skills/impeccable/SKILL.md`，先读取该 skill。
- 原型完成后，使用 impeccable 的 audit / critique / polish 视角检查信息层级、视觉层级、交互状态、响应式、可访问性和常见 AI UI 反模式。
- 实现阶段对照已确认的 `ui-flow.md` / `prototype/` 检查页面偏差时，进入 `references/stages/implementation.md` 的 UI Drift Gate。

默认命令映射：

- 新建或重构页面结构 / 交互路径：按 `impeccable shape` 读取对应流程，先设计页面结构和交互，再进入原型或实现。
- 原型完成后的设计审查：按 `impeccable critique` 检查视觉层级、信息架构、清晰度、情绪表达和 AI UI 反模式。
- 原型或实现后的技术质量检查：按 `impeccable audit` 检查可访问性、响应式、性能、溢出、状态覆盖等问题。
- CR 后的前端修复：按 `impeccable polish` 修视觉、布局、文案和状态细节；修完再按 `impeccable audit` 复验，若担心偏离已确认原型则补 `impeccable critique`。
- 上线前或任务收尾打磨：按 `impeccable polish` 处理视觉、布局、文案、状态和细节一致性。
- 风格方向不合适时：按问题选择 `impeccable bolder`、`impeccable quieter`、`impeccable colorize`、`impeccable layout`、`impeccable clarify` 等专项命令。

这些命令由 agent 按阶段自动选择；用户显式指定某个 impeccable 命令时，以用户指定为准。

边界：

- impeccable 发现的视觉、布局、文案、状态覆盖问题，可以同步回 `ui-flow.md`、`prototype/`、`tasks.md`。
- 如果发现主用户路径、审核对象、状态流、权限或操作矩阵需要变化，必须回到 UI Flow / 方案阶段做 Change Sync，并再次等待用户确认。
- 目标项目未安装 impeccable 时，不阻塞原型阶段；改用本 skill 的静态原型要求和浏览器 smoke 做自审。

Product Flow Gate：

- UI Flow / 静态原型完成后，必须停下来让用户确认。
- 未收到明确指令前，不进入详细技术方案设计，不写表/API/DTO/任务拆解，不生成 Goal。
- 明确指令示例：`原型确认，进入详细技术方案`、`按这个原型写 plan.md`、`同意 UI Flow，开始方案设计`。
- 模糊指令如“继续看看”“再往下”不足以越过该门禁；应先请用户确认是否认可原型和主用户路径。
- 如果本轮使用了 Open Design，确认口径必须指向被采用的设计版本或截图；不能只说“Open Design 做过了”就越过门禁。

时机要求：

- 需求确认阶段：至少有页面流 / 审核对象草图，用来确认用户看什么、审什么、改什么。
- Product Flow Gate 前：补 `ui-flow.md` 初版和必要的静态原型，用页面路径反推 ViewModel、API、状态、权限和错误态。
- Product Flow Gate 前：记录 Open Design decision；`run` 要记录 project/run/artifact、采用稿和拒绝稿，`existing-baseline` 要记录已确认 baseline，`skip` 要记录跳过原因和替代验证方式，`blocked` 要记录 blocker 并回到阻塞处理。
- Product Flow Gate 前：如目标项目已安装 impeccable，必须完成一次 impeccable 视角的原型质量检查，并记录采纳项、拒绝项和需要回到需求 / 方案确认的阻塞项。
- 详细技术方案前：核心静态原型或等价 UI flow 必须经用户确认；主链路页面、操作矩阵、状态映射和浏览器 smoke 路径不能再悬空。
- 详细技术方案阶段：如技术约束反推需要调整原型或主用户路径，回到 UI Flow / 原型阶段并再次确认，不要静默改方案。
- 实现阶段：可以微调视觉和布局，但不能再改审核对象、状态流或主操作路径；如需修改，回到方案讨论并执行 Change Sync。

UI flow 至少回答：

| 维度 | 要求 |
| --- | --- |
| 页面地图 | 页面、路由、入口、返回路径 |
| 用户路径 | 从进入到完成关键业务动作的步骤 |
| ViewModel | 页面字段来自哪个 API/DTO，哪些是计算字段 |
| 操作矩阵 | 按钮/菜单/批量操作、可用条件、禁用条件、确认弹窗 |
| 状态映射 | 后端状态、任务状态、资产状态如何映射到页面状态 |
| UI 状态 | loading、empty、error、permission、conflict、success |
| 错误反馈 | API 错误、校验错误、权限失败、异步失败如何展示 |
| 权限入口 | 谁能看、谁能改、谁能审核、谁能发布/同步/重试 |
| 验收路径 | 浏览器 smoke 的关键点击路径和预期结果 |

## 静态原型要求

静态原型用于验证页面风格、信息架构和业务流程，不等于提前实现正式前端。

- 使用 mock 数据覆盖正常态、空态、错误态、权限态和关键状态变化。
- 表格、详情、表单、审核、批量操作和危险操作要有可见入口。
- 页面文案必须贴近业务动作，不用解释“这个按钮怎么用”的说明性大段文字。
- ViewModel 不直接复刻数据库表；页面展示模型要对应 API 契约。
- 原型应能本地打开或通过项目已有 prototype dev server 预览。
- 如果目标项目已有品牌、布局、组件风格，原型应尽量复用或模仿，不新起一套视觉语言。

## 输出

方案阶段输出：

- `ui-flow.md`：页面地图、用户路径、ViewModel、操作矩阵、状态映射、权限和 smoke。
- 可选 `prototype/`：静态页面和 mock 数据。
- Open Design：`skip` / `existing-baseline` / `run` / `blocked`；按 decision 记录 reason / blocker，或 projectId、runId、studioUrl/previewUrl、entryFile 或 artifact bundle、采用版本、拒绝版本。
- Product Flow Gate 结论：等待确认 / 已确认进入详细方案。
- Impeccable Check：已执行 / 未安装跳过；采纳项、拒绝项、Blocking 项。
- 对 `plan.md` 的回写：补齐 UI flow 发现的 API、DTO、状态、权限、任务或测试缺口。
- 对 `tasks.md` 的回写：新增或细化 FE / API / QA 任务，确保原型暴露的问题有落地任务。

Review 阶段输出：

- 页面流程是否覆盖主链路和异常链路。
- ViewModel / API / 状态机是否一致。
- 权限、错误态、空态和批量操作是否有遗漏。
- 原型暴露的方案缺口和阻塞项。
