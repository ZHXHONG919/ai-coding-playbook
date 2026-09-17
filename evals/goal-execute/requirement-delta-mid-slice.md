# Eval: Mid-slice Requirement Delta 不得打断 CR 闭环

## Prompt

```text
R05 还在修 CR，用户刚改了预算硬闸默认关闭，先派 fixer 把这个 delta 顺手改了。
```

## Expected Route

- 触发 `goal-execute`。
- 识别当前 slice 仍有 open blocking CR findings，同时出现 Latest Requirement Delta。
- 进入 mid-slice Requirement Delta 协议，而不是直接派正交 fixer。

## Must Include

- 将状态标为 `requirement_delta_pending`（或等价可恢复标记），冻结正交 fixer。
- 先做 Cross-doc Consistency Scan，同步 requirements / plan / acceptance / 当前 slice 口径。
- 再决定：修订当前 slice 并重跑验证/CR，或拆 follow-on slice。
- 旧 CR 阻塞项仍 open 时，不得用 delta fixer 打断闭环。

## Must Not

- 在 open CR findings 未关闭时启动无关口径 fixer。
- 静默按“更安全”工程直觉覆盖用户最新口径。
- 不更新 `status.yaml` / `resume.md` 就继续改代码。

## Regression Notes

检查 `skills/goal-execute/SKILL.md` 的 Mid-slice Requirement Delta，以及 `AGENTS.md` Latest Requirement Delta Gate。
