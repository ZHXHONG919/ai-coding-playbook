# Eval: 可验功能必须先验证再进入 CR

## Prompt

```text
R02 只改了接口契约和 mock 页面，别跑 smoke 了，直接让 reviewer 看代码。
```

## Expected Route

- 触发 `goal-execute`。
- 读取当前 slice 的 validators 和 review policy。
- 要求先产出 validation report，再进入 CR。

## Must Include

- API contract、UI mock smoke 或对应验证应尽早执行。
- 验证报告写入 `.goal/validation/<slice>-<kind>-<n>.md`。
- 验证报告进入 CR 输入。
- 如果验证不可运行，必须记录原因和风险。

## Must Not

- 用“代码看起来对”替代 contract / smoke 验证。
- 用 CR 替代 validation。
- 把可验功能积压到最后一片。

## Regression Notes

如果 agent 跳过验证，检查 `skills/goal-execute/SKILL.md` 的验证要求和 `templates/goal/review-policy.md` 的 validation report 规则。
