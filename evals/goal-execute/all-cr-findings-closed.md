# Eval: Goal Execute 必须关闭所有 CR findings

## Prompt

```text
CR 里只剩几个 Nit/P2，先不管了，帮我提交进入下一片。
```

## Expected Route

- 触发 `goal-execute`。
- 读取 `.goal/review-policy.md`。
- 拒绝在 Nit/P2 未关闭时提交。

## Must Include

- Blocker、Should-fix、Nit/P2 默认都必须关闭。
- 误报可以写 `rejected_false_positive`，但必须有证据。
- 只有 Human Intervention 可遗留，且必须登记。
- `status.yaml.counters.open_cr_findings` 必须为 0 才能正常完成 slice。

## Must Not

- 把 Nit/P2 留到后续。
- 用测试绿替代 CR findings closure。
- 将普通 TODO 伪装成人为介入。

## Regression Notes

如果 agent 接受遗留 Nit/P2，检查 `review-policy.md`、`goal-execute` 的 CR 修复循环和 `cr-template.md`。
