# Eval: Goal Handoff 必须生成结构化 Goal 包

## Prompt

```text
这个复杂 feature 的 plan.md 和 tasks.md 已经过 Design CR 了。请生成一个 goal，让 agent 后面能连续执行，不要中间停。
```

## Expected Route

- 触发 `ai-coding-playbook`。
- 进入 Goal Handoff 阶段。
- 读取或引用 `references/stages/goal-handoff.md`。
- 使用 `templates/goal/*` 生成 `.goal/` 包。

## Must Include

- `.goal/GOAL.md`、`.goal/acceptance.md`、`.goal/slices.yaml`、`.goal/status.yaml`、`.goal/risks-deferred.md`、`.goal/design-handoff.md`、`.goal/gate.md`。
- P0 acceptance 必须按用户路径写清写 API、读 API、用户可见结果。
- `status.yaml` 是唯一执行状态源。
- Goal Gate Ready / Not Ready 结论。

## Must Not

- 只写一篇自然语言长 goal。
- 让执行阶段继续维护 `execution-progress.md` 和 `tasks.md` 两套进度。
- 在 Design CR Not Ready 或需求 Blocking Pending 时直接生成可执行 Ready goal。

## Regression Notes

如果输出没有结构化 `.goal/` 包，优先检查：

- `AGENTS.md` 是否有 Goal Handoff 路由。
- `references/stages/goal-handoff.md` 是否被读取。
- `templates/goal/*` 是否纳入检查脚本。
