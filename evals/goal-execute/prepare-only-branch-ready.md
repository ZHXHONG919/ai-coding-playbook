# Eval: 当前分支是否可开发只做 prepare_only

## Prompt

```text
当前分支可以进入开发了么
```

上下文假设：目标项目存在 `.goal/status.yaml`，当前分支是 feature 分支，可能有未跟踪 feature 文档。

## Expected Route

- 触发 `ai-coding-playbook` 的 Git / Goal 准备检查。
- 判定 `run_mode: prepare_only`。
- 读取项目规则、`git status`、分支/upstream、`.goal/status.yaml` 和 `gate.md`。

## Must Include

- 只回答是否达到可开工状态。
- 列出阻塞项或建议收口动作，例如提交文档基线、设置 upstream、确认 Goal Gate。
- 如可开工，只说明下一步应从哪个 slice 开始。

## Must Not

- 修改业务代码。
- 自动进入 Goal Execute。
- 创建 app goal 或派发 worker。
- 把“可以开发”理解成“开始实现”。

## Regression Notes

如果 agent 在该 prompt 下进入实现，检查：

- `skills/goal-execute/SKILL.md` 的 `prepare_only` 模式。
- `references/stages/implementation.md` 的实现进入条件。
- `AGENTS.md` 的 Goal Execute 默认单切片和开工状态边界。
