# Eval: Goal Execute 同步 Codex app goal 进度条镜像

## Prompt

```text
按项目 .goal 执行，并创建 app goal 进度条跟踪。
```

上下文假设：当前项目已有 `.goal/GOAL.md`、`.goal/slices.yaml`、`.goal/status.yaml`，`status.yaml.execution.next_slice` 指向 `R03`，且运行环境提供 Codex app goal 工具。

## Expected Route

- 触发 `goal-execute`。
- 先读取 `.goal/status.yaml`、`.goal/slices.yaml[next_slice]` 和 `.goal/GOAL.md`。
- 调用 `get_goal` 检查 Codex app 当前是否已有 active goal。
- 没有匹配 active goal 时调用 `create_goal` 创建 app-level goal；objective 来自 `.goal/GOAL.md`、feature id 和当前 `next_slice`。

## Must Include

- 明确 `.goal/status.yaml` 仍是唯一执行状态源。
- Codex app goal 只是 UI 可视化镜像，不替代 `.goal/status.yaml`、`.goal/resume.md`、worker report、validation report 或 CR report。
- 每个 slice 的详细进度继续写入 `.goal/status.yaml`。
- Goal 完成时按 app 工具契约调用 `update_goal` 同步 complete；阻塞或人工介入时只有在工具规则允许时同步 blocked，否则在最终回复和 `status.yaml` 中说明。

## Must Not

- 在读取项目 `.goal` 之前先创建 app goal。
- 因为 app goal 存在，就跳过 `.goal/status.yaml`、`.goal/slices.yaml` 或 `.goal/GOAL.md`。
- 把 app goal 当作新的执行 SSOT。
- 用自然语言进度条替代 `status.yaml` 更新。
- 没有用户明确要求或 `codex_app_goal.enabled: true` 时，为普通轻量任务自动创建 app goal。

## Regression Notes

如果该 case 只维护仓库 `.goal` 而没有创建 app goal，检查：

- `skills/goal-execute/SKILL.md` 的 Codex App Goal 镜像规则。
- `templates/goal/status.yaml` 是否包含 `codex_app_goal.enabled`。
- `docs/codex-usage.md` 和 `docs/conversation-usage.md` 是否给出“按项目 .goal 执行，并创建 app goal 进度条跟踪”口令。
