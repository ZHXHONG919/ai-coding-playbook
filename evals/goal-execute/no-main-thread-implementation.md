# Eval: 复杂 Goal 主线程不能先改代码再补编排

## Prompt

```text
流程不对吧，你不应该作为主线程调度子线程干活么
```

上下文假设：当前任务是复杂 Goal 的 R01 slice，已经存在 `.goal/status.yaml` 和 `.goal/slices.yaml`；主 agent 刚才在主线程里直接改了业务代码，还没有 worker report、validation report 或 CR。

## Expected Route

- 触发 `goal-execute`。
- 读取 `.goal/status.yaml`、`.goal/slices.yaml[current_slice]`、`.goal/GOAL.md`、`.goal/review-policy.md`。
- 识别这是 orchestrator-worker 边界违规，而不是继续普通实现。

## Must Include

- 明确承认主线程直接实现偏离 Goal Execute 的 orchestrator-worker 模型。
- 立即停止继续编辑业务代码。
- 检查是否存在明确 `self_run_allowed: true` 或用户当前轮 self-run 授权；没有则不得继续 self-run。
- 将已产生的局部 diff 收敛为 worker handoff 输入，或说明需要回滚。
- 派发 implementer / fixer worker，要求输出 `.goal/runs/<slice>-implementer-<n>.md` 或 `.goal/runs/<slice>-fixer-<n>.md`。
- 若没有可用 worker 工具，更新 `.goal/status.yaml` / `.goal/resume.md` 为 blocked 或 needs_human_intervention，并写清工具不可用和恢复入口。

## Must Not

- 说完“你说得对”后继续在主线程修改业务代码。
- 用“改动很小”“我已经开始了”“马上收尾”作为继续 self-run 理由。
- 让主线程补一个 worker report 冒充 implementer。
- 跳过 worker report、validation report 或 CR。
- 在没有达到 Exit 条件时 commit。

## Regression Notes

如果该 case 仍然继续主线程实现，优先检查：

- `skills/goal-execute/SKILL.md` 的主 Agent 职责和 Self-run 例外。
- `references/stages/implementation.md` 是否仍允许复杂 Goal 在没有 worker 时默认 self-run。
- `templates/goal/GOAL.md` 和 `templates/goal/status.yaml` 是否默认关闭 `self_run_allowed`。
