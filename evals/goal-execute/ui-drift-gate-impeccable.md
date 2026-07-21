# Eval: Goal 前端切片必须执行 UI Drift Gate

## Prompt

```text
继续 Goal，从 status.yaml 的 next_slice 跑这个后台审核页面切片。CR 后如果有 UI 问题也一起修掉。
```

## Expected Route

- 触发 `goal-execute`。
- 读取 `.goal/status.yaml`、`.goal/slices.yaml`、`.goal/design-handoff.md`、`.goal/acceptance.md` 和当前 slice 的 required docs。
- 如果当前 slice 涉及前端页面、后台工具、审核流、表单、表格或复杂 UI 状态，必须执行 UI Drift Gate。
- 如果目标项目存在 `.agents/skills/impeccable/SKILL.md`，默认实现后按 `impeccable audit`；偏离原型风险高时补 `impeccable critique`；CR 后前端 fix 默认按 `impeccable polish`，修完再按 `impeccable audit` 复验。

## Must Include

- `.goal/validation/<slice>-ui-drift-<n>.md` 或等价 validation report。
- 如果 UI 基线来自 Open Design，validation report 记录 projectId、studioUrl/previewUrl、entryFile 或 artifact bundle。
- 使用的 impeccable 命令或 skipped 原因。
- `UI Drift: Passed / Fixed / Blocking / Skipped`。
- CR 输入包含 UI Drift validation report。
- CR 后 fix 若改到前端页面或 UI 状态，重新执行 UI Drift Gate。
- UI Drift 默认只在首轮 CR 前一次，以及 UI fix 后复审前一次；不要每个中间 fixer 全量重跑。

## Must Not

- 只跑普通测试或 UI smoke，就把前端 slice 标记 done。
- 用 worker report 或 CR report 代替 UI Drift validation report。
- 用 impeccable 建议直接改变主用户路径、审核对象、权限、状态流或 API/ViewModel 契约。
- 不得因目标项目未安装 impeccable 而阻塞 Goal；应记录 skipped 并按 `ui-flow.md` / `prototype/` / Open Design artifact 自审。
- 不得把“每个 fixer 都全量 ui-drift”当成默认质量手段。

## Regression Notes

如果复杂 Goal 前端切片绕过 UI Drift，优先检查：

- `skills/goal-execute/SKILL.md` 的 UI Drift Gate 验证要求。
- `templates/goal/slices.yaml` 的 `ui-drift` validator。
- `templates/goal/validation-report.md` 和 `templates/goal/cr-template.md` 的 UI Drift 证据字段。
