# Eval: 前端实现必须检查是否偏离原型

## Prompt

```text
原型确认了，开始实现这个后台审核页面。实现完以后直接继续下一个任务。
```

## Expected Route

- 触发 `ai-coding-playbook` 的实现阶段。
- 读取 `references/stages/implementation.md`。
- 如果任务涉及前端页面、后台工具、审核流、表单、表格或复杂 UI 状态，定位已确认的 `ui-flow.md` / `prototype/`；如果 UI 基线来自 Open Design，同时定位 projectId、studioUrl/previewUrl、entryFile 或 artifact bundle。
- 如果目标项目存在 `.agents/skills/impeccable/SKILL.md`，读取 impeccable 并进入 UI Drift Gate。
- 默认按 `impeccable audit` 做技术质量检查；若主要风险是信息架构、主次操作、视觉层级或清晰度偏离原型，再按 `impeccable critique` 补设计审查。
- 如果是在 CR 后修复前端问题，默认按 `impeccable polish` 修复视觉、布局、文案和状态细节；修完再按 `impeccable audit` 复验。

## Must Include

- 对照 `ui-flow.md` / `prototype/` / Open Design artifact 检查实现是否偏离原型。
- 明确本次使用的 impeccable 命令或说明为何跳过。
- 输出或记录 `UI Drift: Passed / Fixed / Blocking / Skipped` 之一。
- 视觉、布局、文案或 UI 状态缺口应在当前任务内修复并复验。
- CR 后的 fix 若改到前端页面或 UI 状态，必须重新执行 UI Drift Gate。
- 若发现主用户路径、审核对象、操作矩阵、状态流、权限或 API/ViewModel 契约变化，必须回到 UI Flow / 方案阶段做 Change Sync。

## Must Not

- 实现页面后不检查原型偏差就标记任务 Done。
- 用 impeccable 的视觉建议覆盖已确认的业务路径、权限或状态流。
- 把主路径或审核对象变化当作普通 UI 微调直接改代码。
- 不得因目标项目未安装 impeccable 而阻塞实现；应记录 skipped 并按原型要求和浏览器 smoke 自审。

## Regression Notes

如果 agent 在前端实现后直接进入下一个任务，优先检查：

- `references/stages/implementation.md` 的 UI Drift Gate。
- `skills/fullstack-ui-prototype/SKILL.md` 的 Impeccable 接入边界。
- `AGENTS.md` 的关键门禁。
