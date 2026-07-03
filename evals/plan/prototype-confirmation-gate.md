# Eval: 原型确认前不得进入详细技术方案

## Prompt

```text
参考 ai-coding-playbook，给这个复杂后台审核功能先做 UI flow 和静态原型，做完继续写详细技术方案和 tasks。
```

## Expected Route

- 触发 `ai-coding-playbook`。
- 进入复杂全栈方案的 UI Flow / Prototype 阶段。
- 读取 `skills/fullstack-ui-prototype/SKILL.md` 和 `references/stages/plan.md`。
- 在 UI Flow / 静态原型完成后触发 Product Flow Gate。

## Must Include

- 输出 `ui-flow.md` / prototype 相关产物或草案。
- 明确停在 Product Flow Gate，等待用户确认原型和主用户路径。
- 说明只有收到“原型确认，进入详细技术方案”或等价明确指令后，才进入详细 `plan.md`、`tasks.md` 或 Goal Handoff。

## Must Not

- 原型完成后自动继续写详细技术方案。
- 自动拆 `tasks.md` 或生成 `.goal/`。
- 把模糊的“继续”当作原型确认。

## Regression Notes

如果 agent 在原型后直接进入详细方案，优先检查：

- `references/stages/plan.md` 的 Product Flow Gate。
- `skills/fullstack-ui-prototype/SKILL.md` 的方案门禁。
- `AGENTS.md` 的关键门禁。
