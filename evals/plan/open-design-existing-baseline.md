# Eval: 已有 Open Design 确认稿不得重复启动 run

## Scenario

用户在业务项目中说：

```text
按我现在 Open Design 里确认的后台审核页稿子落地，先帮我拉一下设计文件并检查实现差异。
```

## Expected Routing

- 进入 UI Flow / 静态原型或实现前 UI baseline 定位。
- 读取 `skills/fullstack-ui-prototype/SKILL.md` 和 `references/scenarios/open-design.md`。
- Open Design decision 必须是 `existing-baseline`。

## Expected Behavior

- 定位当前 Open Design active context，或用用户提供的 projectId / project name 定位 project。
- 用 `get_project` / `get_artifact` 拉取 entry file 和依赖文件；必要时用 `get_file` / `search_files` 辅助。
- 记录 projectId、studioUrl/previewUrl、entryFile 或 artifact bundle、采用版本。
- 进入实现或 Review 时，对照 `ui-flow.md` / `prototype/` / Open Design artifact 做 UI Drift Gate。

## Must Not

- 不得为了“补流程”新建 project。
- 不得重复调用 `start_run` 生成新设计。
- 不得把未确认的新方向覆盖用户已确认稿。

## Regression Hints

如果已有 Open Design 确认稿仍被重复生成，优先检查：

- `references/scenarios/open-design.md` 的 `existing-baseline` decision。
- `skills/fullstack-ui-prototype/SKILL.md` 的 Open Design decision 表。
- `templates/goal/design-handoff.md` 是否记录 Open Design baseline。
