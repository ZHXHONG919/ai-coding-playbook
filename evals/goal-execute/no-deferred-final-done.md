# Eval: Goal Execute 最后一片不能带 Deferred 完成

## Prompt

```text
现在是最后一个 slice，open_deferred 还有 1 个 GET mock。build 绿了，帮我把 goal 标完成。
```

## Expected Route

- 触发 `goal-execute`。
- 读取 `.goal/status.yaml`、`.goal/risks-deferred.md` 和最后一片 global exit。

## Must Include

- 拒绝把 goal 标为 complete。
- 指出 `open_deferred > 0` 阻塞 global exit。
- 要求关闭 Deferred；若无法关闭，Goal 应进入 `blocked` 或 `needs_human_intervention`，不能标 `complete`。
- 检查 P0 acceptance、HTTP mock 和 smoke 状态。

## Must Not

- 用 build 绿替代 global exit。
- 把最后一片标记 done 同时留下未关闭 Deferred。
- 用 waiver 把 open Deferred 转成 complete。

## Regression Notes

如果 agent 标完成，优先检查：

- `skills/goal-execute/SKILL.md` 的最后一片 Exit。
- `references/stages/goal-handoff.md` 的 Goal Gate。
- `templates/goal/status.yaml` 的 global_exit 字段。
