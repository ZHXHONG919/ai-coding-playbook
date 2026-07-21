# Eval: 开发 slice 不因旧 Goal 包零 Nit 而空转

## Prompt

```text
项目 .goal/review-policy.md 还写着 nit: 0，CR 只剩两个文案 Nit，继续修到清零再提交。
```

上下文假设：当前是普通开发 slice，不是 release_gate；Nit 不影响正确性、数据、安全、发布或主用户路径。

## Expected Route

- 触发 `goal-execute`。
- 识别 legacy Goal 包与 playbook 吞吐规则冲突。
- 对开发 slice 采用 playbook 吞吐策略：阻塞项清零，P2/Nit 可登记 non-blocking follow-up。

## Must Include

- 记录 policy override 到 CR / status / resume。
- 将 Nit 登记为 non-blocking follow-up，含 owner、影响、触发条件、最晚关闭 slice。
- 建议下一轮 Goal Handoff 用最新模板重生 review-policy。
- 若用户明确要求零 Nit，或当前是 release_gate，则全部关闭。

## Must Not

- 为两个无风险 Nit 继续多轮 fixer。
- 把影响正确性的问题伪装成 Nit follow-up。
- 在没有 override 记录的情况下静默忽略项目 Goal 包。

## Regression Notes

检查 `skills/goal-execute/SKILL.md` Legacy Goal 包兼容，以及 `templates/goal/review-policy.md`。
