# Eval: Open Design 只在合适的原型探索场景使用

## Scenario

用户在业务项目中说：

```text
这个后台审核页面想整体优化一下风格，最好给我两版方向看，再决定怎么落地。
```

## Expected Routing

- 进入 UI Flow / 静态原型阶段。
- 读取 `skills/fullstack-ui-prototype/SKILL.md` 和 `references/stages/plan.md`。
- 判断 Open Design decision：整体风格升级、多版视觉方向、需要用户看稿确认时为 `run`；已有确认稿时为 `existing-baseline`；局部小改为 `skip`；工具不可用且用户要求必须使用时为 `blocked`。
- 读取 `references/scenarios/open-design.md`，按真实 Open Design project/run/artifact 工作流执行。
- 如目标项目安装 `.agents/skills/impeccable`，Open Design 产物完成后仍要做 impeccable 视角的原型质量检查。

## Expected Behavior

- 使用当前项目事实和 `ui-flow.md` 草稿约束 Open Design，不让设计工具自行发明业务规则、权限、状态流或 API 字段。
- 如果使用 MCP，先定位或创建 Open Design project，再 `start_run`，轮询 `get_run` 到 succeeded / failed / canceled，成功后记录 studioUrl / previewUrl，并用 `get_artifact` 拉取 entry file 和依赖文件。
- 记录 Open Design decision；`run` 记录 projectId、runId、studioUrl/previewUrl、entryFile 或 artifact bundle、采用版本、拒绝版本和待确认问题；`skip` 记录 reason 和替代验证方式；`blocked` 记录 blocker 和恢复条件。
- Open Design run 处于 running 且文件未变化时，不得误判为卡死；按 30-60 秒轮询并向用户报告 still working。
- 停在 Product Flow Gate，等待用户明确确认采用版本后再进入详细技术方案、任务拆解或实现。
- 明确 Open Design 是设计输入；impeccable 是质量门禁。

## Negative Scenario

用户说：

```text
把这个表格里的状态列文案改清楚一点，按钮间距顺一下。
```

## Must Not

- 不得默认启动 Open Design。
- 不得因为没有 Open Design 产物而阻塞局部 UI 修复。
- 不得跳过 `start_run` / `get_run`，直接用 `write_file` 伪造 Open Design 设计探索结果。
- 不得为 `skip` / `blocked` 编造 projectId、studioUrl 或 entryFile。
- 不得用 Open Design 的建议覆盖已确认的主用户路径、审核对象、权限、状态流或 API/ViewModel 契约。

## Regression Hints

如果 agent 把所有前端任务都强制走 Open Design，优先检查：

- `skills/fullstack-ui-prototype/SKILL.md` 的 Open Design 适用 / 不适用边界。
- `references/stages/plan.md` 的 Open Design 非默认门禁。
- `docs/conversation-usage.md` 是否把 Open Design 写成可选设计探索工作台。
