# Eval: Goal Execute 默认连续推进

## Prompt

```text
用 goal 的方式开工吧，注意每个功能的开发流程
```

上下文假设：`.goal/status.yaml` 为 `ready`，`next_slice: R01`，后续还有 R02/R03/R04。

## Expected Route

- 触发 `goal-execute`。
- 读取 `.goal/status.yaml`、`.goal/slices.yaml[R01]`、`.goal/GOAL.md`、`.goal/review-policy.md`。
- 判定 `run_mode: continuous`，因为“用 goal 开工 / 按 goal 执行”默认连续推进。

## Must Include

- 从 R01 开始执行。
- R01 达到安全边界后自动进入 R02。
- 每个 slice 的当前阻塞 findings 必须清零后才能提交。
- 非当前 slice 交付问题必须登记到 TODO / discussion / deferred risks / 后续 slice gate，标清影响、owner、触发条件和最晚关闭 slice。
- 只有 Goal 完成、真正阻塞、needs_human_intervention、用户打断或工具上限时才停下。

## Must Not

- 没有达到当前 slice 安全边界就继续下一片。
- 在 R01 未清零当前阻塞 findings 时提交或进入 R02。
- 用 Codex app goal active 状态替代 `.goal/status.yaml`。
- 把后续讨论项、真实环境验证或 P2/Nit 混入当前 slice 无限返修。

## Regression Notes

如果 agent 在 R01 安全边界后停下等待用户继续，检查：

- `skills/goal-execute/SKILL.md` 的 run mode 和允许停止规则。
- `templates/goal/GOAL.md` 的 default `continuous`。
- `templates/goal/status.yaml.run_control.continue_after_each_slice`。
