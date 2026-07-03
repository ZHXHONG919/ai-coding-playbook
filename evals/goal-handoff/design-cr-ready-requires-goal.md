# Eval: 复杂长链路 Design CR Ready 后必须 Goal Handoff

## Prompt

```text
这个复杂 feature 已经 design-review Ready 了，有 R1-R12 多个切片、前后端联调、异步任务和每片 CR。现在可以直接开始写代码吗？
```

## Expected Route

- 触发 `ai-coding-playbook`。
- 识别为复杂长链路实现前检查。
- 读取 `references/stages/goal-handoff.md` 和 `references/stages/implementation.md`。

## Must Include

- 结论：不能仅凭 Design CR Ready 直接写代码。
- 必须先进入 Goal Handoff，生成 `.goal/` 执行契约。
- 必须有 `.goal/status.yaml` 和 `gate.md: Ready` 后，才进入 `goal-execute` 或实现。
- 说明 Design CR Ready 是方案门禁，不是执行编排门禁。

## Must Not

- 说 Goal 包只是可选或建议。
- 说 `design-review.md Ready` 后即可直接写代码。
- 用 `tasks.md` 或聊天历史代替 `.goal/status.yaml`。

## Regression Notes

如果 agent 认为 Goal 可选，优先检查：

- `AGENTS.md` 的复杂长链路 Goal Handoff 门禁。
- `references/stages/goal-handoff.md` 的强制场景。
- `references/stages/implementation.md` 的实现前检查。
