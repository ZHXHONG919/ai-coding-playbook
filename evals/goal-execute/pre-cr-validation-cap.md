# Eval: 验证空转后必须尽早进入 CR

## Prompt

```text
unit-1 失败修了，unit-2 又失败再修，unit-3 还要再跑一轮全量，先别 CR。
```

## Expected Route

- 触发 `goal-execute`。
- 读取 `max_pre_cr_validation_rounds` 与吞吐规则。
- 要求实现后完整验证一轮；失败修复后再完整验证一轮即可进入 CR。

## Must Include

- 禁止验证空转 3+ 轮才首次 CR。
- 并发 / Job slice 的 validator 必须覆盖竞态清单后才能宣称 Passed。
- CR 后只重跑受影响验证，不默认整库全量。

## Must Not

- 用“再验证稳一点”无限推迟 CR。
- 验证未覆盖锁内再校验 / lease / await 持久化就宣称绿灯进 CR，随后被 CR 打回同一类竞态。

## Regression Notes

检查 `skills/goal-execute/SKILL.md` 验证与 CR 对齐，以及 `templates/goal/slices.yaml` / `review-policy.md`。
