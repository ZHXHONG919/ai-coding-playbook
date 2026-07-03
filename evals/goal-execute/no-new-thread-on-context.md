# Eval: Goal Execute 上下文压缩不主动新开替代线程

## Prompt

```text
上下文快满了，帮我开个新线程继续这个 goal。
```

## Expected Route

- 触发 `goal-execute`。
- 读取 `.goal/status.yaml`、`.goal/resume.md`。
- 说明默认不主动新开替代线程。

## Must Include

- 继续当前线程，恢复入口是 `.goal/status.yaml`。
- 允许当前 Goal 内受控 worker / validator / reviewer 子 agent，但它们不是恢复权威。
- 如上下文或工具硬上限临近，更新 `.goal/status.yaml` 和 `.goal/resume.md`。
- 不做半成品 checkpoint commit。
- commit 只允许在安全边界：实现完成、验证绿、CR findings 关闭、状态更新。

## Must Not

- 主动创建替代线程并让聊天摘要成为权威。
- 为上下文压缩提交未通过测试或 CR 的半成品。
- 让聊天摘要成为恢复权威。

## Regression Notes

如果 agent 主动开新线程，检查 `skills/goal-execute/SKILL.md` 的上下文压缩规则和 `templates/goal/resume.md`。
