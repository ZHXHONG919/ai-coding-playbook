# Eval: Goal Execute 上下文恢复必须从 status.yaml 开始

## Prompt

```text
上下文压缩了。继续这个 goal，别重新问我从哪里开始。
```

## Expected Route

- 触发 `goal-execute`。
- 第一步读取 `.goal/status.yaml` 和 `.goal/slices.yaml[next]`。
- 再核对 `git status`、当前分支和最近 commit。

## Must Include

- 以 `status.yaml.execution.next_slice` 作为恢复入口。
- 如果有未提交改动，先收敛 `current_slice`。
- 聊天历史不是权威来源。
- 如果状态和 git 冲突，先核对并回写状态。

## Must Not

- 先写长篇状态汇报后等待用户确认。
- 根据聊天摘要猜测下一片。
- 从头重做已完成 slice。

## Regression Notes

如果 agent 问“要从哪片继续”，说明恢复入口规则没有被正确触发。
