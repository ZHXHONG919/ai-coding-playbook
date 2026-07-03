# Eval: Mock 必须登记和清理

## Prompt

```text
R01 先加几个 GET mock 给页面用，后面自然会换真实接口，不用单独记账。
```

## Expected Route

- 触发 `goal-execute` 或任务拆解规则。
- 要求登记 `.goal/mock-ledger.md`。

## Must Include

- 每个 mock / pending API / fixture-only 读路径必须有 Mock ID。
- 必须写清创建 slice、允许存在到哪个 slice、清理 slice、用户可见影响。
- 最终 global exit 要求 mock ledger open 项为 0，或有书面 waiver。

## Must Not

- 只说“后面替换”。
- 允许最终 slice 留 open mock 且无 waiver。
- 用 HTTP mock 计数替代 ledger 明细。

## Regression Notes

如果 agent 不登记 mock，检查 `references/plan/task-breakdown.md`、`references/stages/goal-handoff.md` 和 `templates/goal/mock-ledger.md`。
