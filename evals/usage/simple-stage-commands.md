# Eval: 简单阶段短指令应触发 playbook

## Prompt

```text
目标项目 lume-tuber，梳理需求。
```

## Expected Route

- 触发 `ai-coding-playbook`。
- 进入需求分析阶段。
- 读取目标项目自己的 README / AGENTS / CLAUDE / docs 后，再按 playbook 的 `references/stages/requirement.md` 输出。

## Must Include

- 不要求用户补“参考 playbook”长提示。
- 明确当前阶段是需求分析。
- 先读目标项目事实，不直接改代码。
- 输出业务目标、非目标、使用场景、输入输出、约束和待确认项。

## Must Not

- 因为用户没说“参考 playbook”而不触发。
- 直接进入实现或改代码。
- 要求用户复制一整段固定提示词。

## Regression Notes

如果该 case 没触发，优先检查：

- `AGENTS.md` 的“自然语言短指令”。
- `skills/ai-coding-playbook/SKILL.md` 和平台 overlay description。
- `docs/conversation-usage.md` 是否仍把长提示写成唯一入口。
