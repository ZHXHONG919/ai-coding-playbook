# 轻量方案阶段

> 目标：对小改、单点改动给出足够实现和 Review 的依据，不套完整复杂方案模板。

## 什么时候用轻量方案

默认用 `references/stages/plan-light.md` + `templates/plan-light.md`，当**不命中**复杂方案强触发项，且**累积触发项少于 2 个**。

典型场景：

- 单文件或小范围 bugfix。
- 已有接口增加一个展示字段，不改 DB、权限、状态。
- 文案、样式、布局微调。
- 单 API 或小页面改动，无新状态流、无 migration、无跨端联动。
- README、注释、日志、测试补充（不改业务行为）。

## 什么时候不能用轻量方案

命中 `references/stages/plan.md` 中任一**强触发项**，或**两个及以上累积触发项**，必须改用复杂方案流程：

- `references/stages/plan.md`
- `references/stages/requirement-confirmation.md`（多轮需求时）
- `templates/feature-design.md`
- 必要的 `ui-flow.md` / design CR

不确定时按复杂方案处理；复杂不等于冗长，关键是门禁项不能省。

## 阶段门禁

- 方案阶段默认不改代码。
- 轻量方案也要区分事实与推断；没有证据不写死。
- 若讨论中发现涉及 DB、状态流、跨端、审核流，**立即升级到复杂方案**，不要继续在 light 模板上硬写。
- 轻量方案通常不需要完整 `requirements.md`；一句范围说明即可。若已有 feature 目录，仍可写 `plan.md`。
- 轻量方案**不强制** design CR；但涉及发布、migration、权限时，建议主 agent 自审并记录风险。
- 用户明确说「开始实现 / 按这个落地」后才进入实现。

## 必读规则

- `references/plan/evidence-first.md`（简表即可）
- `references/plan/detail-gate.md`（改动范围内仍需可验收细节）

按需读取：

- `references/scenarios/*`（改动涉及 Nest/React/Chrome/AI 时）
- `skills/nest-api-design/SKILL.md` / `skills/react-vite-feature/SKILL.md`

不必读取（除非升级复杂方案）：

- `references/plan/domain-design.md` 全文展开
- `references/plan/field-ownership.md`（无新 DB 字段时）
- `skills/fullstack-ui-prototype/SKILL.md`（无新页面流时）

## 推荐推导顺序

```text
用户目标 / 项目事实
→ 简证据表
→ 改动范围
→ 方案说明（可选 1 图）
→ 变更清单（API / DB / UI）
→ 测试与验收
→ 发布注意
→ 待确认
```

## 输出标准

轻量 `plan.md` 应能回答：

- 改哪里、为什么这样改。
- 有没有破坏现有契约或行为。
- 怎么测、怎么发。
- 还有什么 Pending。

## 与 tasks.md 的关系

- 改动可在 1～3 步内完成：可直接实现，或在 `plan.md` 末尾列 3～5 条任务，不强制单独 `tasks.md`。
- 任务超过 5 条或出现依赖链：升级到复杂方案，补 `tasks.md` 并按 `references/plan/task-breakdown.md` 拆解。

## 模板

落盘时使用 `templates/plan-light.md`。
