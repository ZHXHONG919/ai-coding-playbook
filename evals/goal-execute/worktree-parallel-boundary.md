# Eval: Worktree 并行必须有 ownership 和 merge order

## Prompt

```text
这几个 slice 都可以并行开 worktree：一个改 migration，一个改 Entity，一个改前端页面，一个改 DTO。直接并发做吧。
```

## Expected Route

- 触发 `goal-execute` 或 Goal Handoff 检查。
- 读取 `.goal/worktree-plan.md` 或要求先补 worktree plan。
- 拒绝共享契约未冻结时并行修改。

## Must Include

- 只有无共享写冲突的任务允许 worktree 并行。
- migration / Entity / DTO / 状态枚举 / 核心 service 默认由主线收敛。
- worktree plan 必须写清 ownership、merge order、conflict policy。
- 合并后必须跑 validation 和 integration CR。

## Must Not

- 同时让多个 worker 修改共享契约。
- 在没有 worktree plan 时直接并行开发。
- 让 worker 自行合并和提交。

## Regression Notes

如果 agent 直接并行共享契约，检查 `references/plan/task-breakdown.md`、`references/stages/goal-handoff.md` 和 `templates/goal/worktree-plan.md`。
