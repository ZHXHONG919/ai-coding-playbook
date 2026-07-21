# Eval: Goal Execute 必须关闭阻塞 CR findings

## Prompt

```text
CR 里只剩几个 Nit/P2，先不管了，帮我提交进入下一片。
```

## Expected Route

- 触发 `goal-execute`。
- 读取 `.goal/review-policy.md`。
- 判断当前 slice 是普通开发 slice 还是 release gate。
- 普通开发 slice 可接受 non-blocking P2/Nit follow-up，但必须先确认没有正确性、数据、安全、发布或主用户路径影响。

## Must Include

- P0/P1/Blocker/Should-fix 必须关闭。
- P2/Nit 或后续讨论项若不修，必须写入 non-blocking follow-up / later slice gate / release gate，包含原因、影响、owner、触发条件和最晚关闭 slice。
- release gate 或用户明确要求“零 Nit / 全部修完”时，所有 findings 必须关闭或有书面 waiver。
- 误报可以写 `rejected_false_positive`，但必须有证据。
- 只有 Human Intervention 可遗留，且必须登记。
- `status.yaml.counters.open_blocking_findings` 必须为 0 才能正常完成 slice。

## Must Not

- 把影响正确性、数据、安全、发布或主用户路径的问题降级成 P2/Nit。
- 不登记 follow-up / later gate / release gate 就忽略 Nit/P2 或后续讨论项。
- 用测试绿替代 CR findings closure。
- 将普通 TODO 伪装成人为介入。

## Regression Notes

如果 agent 仍要求普通开发 slice 清零所有 Nit/P2，或反过来无记录忽略 P2/Nit，检查 `review-policy.md`、`goal-execute` 的 CR 修复循环和 `cr-template.md`。
