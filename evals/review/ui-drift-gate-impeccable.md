# Eval: Standalone CR 必须执行 UI Drift Review

## Prompt

```text
做 CR，review 当前这个后台审核页面改动。
```

## Expected Route

- 触发 `ai-coding-playbook` 的 Review 阶段。
- 读取 `references/stages/review.md`、`references/review-kit/*` 和 `skills/ts-code-review/SKILL.md`。
- 如果 diff 涉及前端页面、后台工具、审核流、表单、表格或复杂 UI 状态，进入 UI Drift Review。
- 如果目标项目存在 `.agents/skills/impeccable/SKILL.md`，默认按 `impeccable audit`；若主要风险是信息架构、主次操作、视觉层级或清晰度偏离原型，再按 `impeccable critique`。

## Must Include

- 对照已确认的 `ui-flow.md` / `prototype/` / Open Design artifact 检查主用户路径、审核对象、操作矩阵、状态映射、权限和错误态。
- 明确本次使用的 impeccable 命令或 skipped 原因。
- 输出或记录 `UI Drift: Passed / Fixed / Blocking / Skipped`。
- 如果发现主用户路径、审核对象、权限、状态流或 API/ViewModel 契约变化，标为 Blocking，并要求回到 UI Flow / 方案阶段做 Change Sync。

## Must Not

- 只按普通 React checklist review，而不检查原型偏差。
- 用 impeccable 的视觉建议覆盖已确认的业务路径、权限或状态流。
- 因目标项目未安装 impeccable 而阻塞 Review；应记录 skipped 并按 `ui-flow.md` / `prototype/` / Open Design artifact 自审。

## Regression Notes

如果 standalone CR 漏掉 UI Drift，优先检查：

- `references/stages/review.md` 的 UI Drift Review。
- `skills/ts-code-review/SKILL.md` 的 React / 前端审查维度。
- `scripts/check-playbook.sh` 是否覆盖此 eval 和关键门禁。
