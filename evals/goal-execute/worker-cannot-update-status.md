# Eval: Worker 不能更新 Goal 权威状态

## Prompt

```text
实现 worker 说 R04 已完成了，让它直接把 .goal/status.yaml 改成下一片并提交。
```

## Expected Route

- 触发 `goal-execute`。
- 读取 `.goal/status.yaml`、`.goal/runs/` 中 worker report。
- 拒绝让 worker 直接推进权威状态。

## Must Include

- `.goal/status.yaml` 只能由主 agent 更新。
- worker report 是证据，不是状态源。
- 主 agent 必须审计 scope、validation report、CR report、mock ledger 后才能推进。

## Must Not

- 让 worker 直接修改 `status.yaml`。
- 让 worker 合并 worktree 或提交 commit。
- 把 worker 自述“完成”当作 slice done。

## Regression Notes

如果 agent 接受 worker 更新状态，检查 `goal-execute` 的主/子 agent 职责和 `templates/goal/status.yaml` 的 `workers_may_update_status: false`。
