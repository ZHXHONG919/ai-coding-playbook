# Feature Workflow

> 通用 feature 开发流程。适合 NestJS + React + PostgreSQL 项目，也可以裁剪给其他项目。
> 该流程参考 conan-openspec 的核心思想：artifact 驱动、阶段检查点、设计先于实现、测试与方案互相校验；但不强制使用完整 OpenSpec 目录。

## 目标

让 AI 不直接从一句需求跳到改代码，而是经过：理解 → 设计 → 拆解 → 实现 → 验证 → 发布说明。

技术方案要同时服务两类读者：

- 人：用于评审方案、发现风险和确认取舍。
- AI：用于后续拆任务、写测试、做代码 Review。

## 流程

```text
需求输入
→ 读取项目上下文
→ 产出 feature design
→ 拆 implementation plan
→ 实现代码
→ 补测试 / smoke
→ 更新文档
→ 总结验证与风险
```

## 阶段控制

默认把一次需求协作分成 5 个阶段。除非用户明确指定阶段，否则按当前上下文自动判断；如果不确定，停在更早阶段。

| 阶段 | 目标 | AI 行为 | 是否改代码 | 进入下一阶段条件 |
| --- | --- | --- | --- | --- |
| 0. 探索 / 澄清 | 理解问题、补齐背景、识别未知 | 提问、列假设、梳理现状和可选方向 | 否 | 用户确认方向，或信息足够进入方案 |
| 1. 方案草案 | 给出可评审的技术方案 | 输出方案、模型设计、影响面、风险、测试和发布思路 | 否 | 用户反馈修改意见或认可方向 |
| 2. 方案定稿 | 多轮收敛，形成一致方案 | 根据反馈迭代方案，明确最终取舍和待办 | 否 | 用户明确说“同意方案”“按这个落地”“开始实现” |
| 3. 实现 | 按已确认方案改代码 | 拆任务、改代码、补测试、同步文档 | 是 | 实现完成并通过必要验证 |
| 4. 验证 / 收尾 | 验证实现与方案一致 | 跑测试、做 review、总结风险和后续 | 可改小修 | 用户接受结果或提出新反馈 |

### 阶段门禁

- 用户说“写方案”“设计一下”“先讨论”“先别写代码”时，只能停在阶段 0-2，不得改业务代码。
- 用户说“这个方案可以”“同意”“按方案落地”“开始实现”“执行”时，才能进入阶段 3。
- 如果用户在方案阶段提出修改意见，继续迭代方案，不进入实现。
- 如果实现中发现方案有明显问题，先暂停并回到阶段 2 说明偏差，不要静默改方向。
- 紧急 bugfix 或用户明确要求直接修时，可以跳过完整方案，但仍要先说明最小修复思路和验证方式。

### 方案阶段输出要求

方案阶段应优先产出可讨论内容，而不是最终答案。建议结构：

1. 我对需求的理解
2. 当前上下文 / 现状
3. 关键问题和假设
4. 方案 A / B / 推荐方案
5. 模型设计
6. API / DB / UI / 异步任务 / 外部 provider 影响
7. 风险与待确认
8. 测试与发布验证
9. 需要用户拍板的问题


## 阶段说明

### 1. 读取上下文

必读：

- `README.md`
- `AGENTS.md` / `CLAUDE.md`
- `docs/dev-guide/*` 或项目等价文档
- 相关模块代码
- 相关 feature 旧文档
- 涉及 DB / 发布 / AI provider 时，读取对应 SOP

### 2. Feature Design

新规则优先读取 `references/stages/plan.md` 和 `references/plan/*`。复杂方案、跨项目迁移、模型设计、AI/数据分析链路，必须满足证据优先、轻量领域设计、图表表达、细节门禁、字段归属和任务拆解规则。旧文件 `workflows/technical-plan-quality-gate.md`、`workflows/design-discussion-rules.md`、`workflows/formal-technical-plan-authoring.md` 保留兼容，但不得覆盖新版 `references/*` 的门禁。

设计阶段要回答：

- 用户目标是什么，非目标是什么。
- 领域名词、系统用例和核心概念边界是什么。
- 是否存在多个方案，为什么选择当前方案。
- 哪些端受影响：server / admin / ops / h5 / extension / cli。
- 业务结构图、核心流程图、必要的状态图 / 数据流图是否讲清楚整体结构。
- 模型怎么设计：轻量领域抽象、字段归属、对象关系、状态机、存储模型、API/DTO 模型、前端视图模型。
- 是否改 API、DB、状态机、异步任务、外部 provider。
- 功能主流程、异常流程、幂等、并发、可观测性如何处理。
- 测试和发布如何验证。

### 3. Implementation Plan

计划要能落到文件：

- 改哪个模块。
- 新增哪些 DTO / Entity / Service / Component。
- 新增哪些 migration。
- 哪些测试必须补。
- 哪些 smoke 或手动验证必须做。

### 4. Implementation

只按计划改。实现中发现计划错了，先更新计划或在总结中明确偏差。

### 5. Verification

按影响面选择最小但有效的验证：

| 改动类型 | 推荐验证 |
| --- | --- |
| NestJS service | unit/component test |
| Controller / API contract | e2e 或 supertest |
| React 页面 | build + component test + browser smoke |
| DB schema | migration replay + lint/migration sync |
| AI provider | mock smoke + real provider minimal smoke |
| Chrome Extension | build + 手动加载检查 + API 上报 smoke |
| release script | shellcheck + bash -n + dry-run |
