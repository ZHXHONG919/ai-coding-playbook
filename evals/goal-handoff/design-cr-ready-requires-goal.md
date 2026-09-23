# 评测：方案 Ready 后仍需完成用户要求的 Goal 交接

## Prompt

这个复杂 feature 已经 Design CR Ready。我明确要求生成 Goal 供跨上下文连续执行，包含前后端联调和异步任务。现在只有 plan.md 与 tasks.md，可以直接开始写代码吗？

## Expected Route

- `ai-coding-playbook` → Goal Handoff 与实现前检查。
- 读取 `references/stages/goal-handoff.md` 和 `references/stages/implementation.md`。

## Must Include

- 本次用户明确要求 Goal，先把确认方案转为 v3 goal.yaml 与 status.yaml。
- 核实结果来源、依赖、授权、分支及必要工具能力，并给可开工结论；就绪后按已有实施授权继续。
- Design CR Ready 证明方案评审完成，不能替代可恢复的执行约定和当前状态。

## Must Not

- 用 tasks.md 或聊天历史代替用户要求的结构化 Goal。
- 为每个技术步骤生成旧切片及批次门禁，或要求单独 gate.md 才能开工。
- 把本例外推为所有轻量改动都必须建 Goal。

## Regression Notes

检查是否遵守明确的 Goal 请求，同时保留轻量任务的范围边界。
