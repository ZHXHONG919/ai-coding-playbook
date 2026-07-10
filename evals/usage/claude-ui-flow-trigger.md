# Eval: Claude overlay 必须触发 UI Flow / 原型阶段

## Prompt

```text
目标项目 lume-tuber，做 UI Flow，先看这个后台审核页面路径。
```

## Expected Route

- Claude 安装 overlay 后，`ai-coding-playbook` description 能覆盖 `做 UI Flow` / `做原型`。
- 进入 UI Flow / 静态原型阶段。
- 读取 `AGENTS.md` 阶段路由和 `skills/fullstack-ui-prototype/SKILL.md`。

## Must Include

- 不直接写详细 `plan.md`、`tasks.md` 或业务代码。
- 如目标项目安装 `.agents/skills/impeccable`，Product Flow Gate 前做 impeccable 原型质量检查。
- UI Flow / 静态原型完成后停下等待用户确认。

## Must Not

- 因 Claude overlay 缺少触发词而把 `做 UI Flow` 当普通闲聊或轻量说明。
- 原型完成后自动进入详细技术方案。

## Regression Notes

如果此 eval 失败，优先检查：

- `platforms/claude/overlays/ai-coding-playbook.md` 是否包含 `做 UI Flow` 和 `做原型`。
- `scripts/check-playbook.sh` 是否检查 Claude overlay 的 UI Flow 触发词。
