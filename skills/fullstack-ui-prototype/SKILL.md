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

Product Flow Gate：

- UI Flow / 静态原型完成后，必须停下来让用户确认。
- 未收到明确指令前，不进入详细技术方案设计，不写表/API/DTO/任务拆解，不生成 Goal。
- 明确指令示例：`原型确认，进入详细技术方案`、`按这个原型写 plan.md`、`同意 UI Flow，开始方案设计`。
- 模糊指令如“继续看看”“再往下”不足以越过该门禁；应先请用户确认是否认可原型和主用户路径。

时机要求：

- 需求确认阶段：至少有页面流 / 审核对象草图，用来确认用户看什么、审什么、改什么。
- Product Flow Gate 前：补 `ui-flow.md` 初版和必要的静态原型，用页面路径反推 ViewModel、API、状态、权限和错误态。
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
- Product Flow Gate 结论：等待确认 / 已确认进入详细方案。
- 对 `plan.md` 的回写：补齐 UI flow 发现的 API、DTO、状态、权限、任务或测试缺口。
- 对 `tasks.md` 的回写：新增或细化 FE / API / QA 任务，确保原型暴露的问题有落地任务。

Review 阶段输出：

- 页面流程是否覆盖主链路和异常链路。
- ViewModel / API / 状态机是否一致。
- 权限、错误态、空态和批量操作是否有遗漏。
- 原型暴露的方案缺口和阻塞项。
