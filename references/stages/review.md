# Review 阶段

> 目标：基于证据审查风险，问题优先，严重程度排序。

## 角色视角

Review 阶段默认站在 Staff Reviewer、专项 Reviewer 和发布风险负责人视角：

- Staff Reviewer：优先找正确性、契约破坏、数据破坏、安全漏洞和发布阻断问题。
- 专项 Reviewer：按变更类型检查 DB、权限、前端状态、异步任务、provider、发布脚本等专项风险。
- 发布风险负责人：判断迁移、配置、兼容性、回滚和 smoke 是否足够。

复杂 Review 必须读取 `references/plan/role-lens.md`。

## 触发

- 用户要求 review、检查代码、看看风险。
- 高风险变更：DB、权限、安全、异步任务、外部 provider、公共 API、发布脚本。

## 流程

1. 明确审查范围：本地 diff、指定文件、PR、方案文档。
2. 收集证据：diff、测试结果、项目约束、相关设计文档。
3. 预检：优先运行项目已有 lint / typecheck / test / build；不能运行要说明。
4. 按角色视角和维度审查：正确性、安全、性能、并发、数据一致性、可维护性、测试充分性、发布风险。
5. 如果 review 范围涉及前端页面、后台工具、审核流、任务流、表单、表格或复杂 UI 状态，必须执行 UI Drift Review。
6. 输出问题清单，按严重程度排序。

## UI Drift Review

当前 diff 涉及前端页面、后台工具、审核流、任务流、表单、表格或复杂 UI 状态时：

- 定位已确认的 `ui-flow.md` / `prototype/`；如果 UI 基线来自 Open Design，同时定位 projectId、studioUrl/previewUrl、entryFile 或 artifact bundle，必要时用 `get_artifact` 拉取 entry file 和依赖文件。检查实现是否偏离主用户路径、审核对象、操作矩阵、状态映射、权限和错误态。
- 如果没有已确认 UI baseline，纯文案、样式、单字段或局部组件状态小 diff 可以记录 `UI Drift: Skipped(no confirmed baseline, scope=small)`；涉及主用户路径、审核对象、操作矩阵、权限、状态流或 API/ViewModel 契约时必须标为 Blocking，回 UI Flow / 方案阶段补 baseline。
- 如果目标项目存在 `.agents/skills/impeccable/SKILL.md`，默认按 `impeccable audit` 检查可访问性、响应式、性能、溢出和状态覆盖；若主要风险是信息架构、主次操作、视觉层级或清晰度偏离原型，再按 `impeccable critique` 补设计审查。
- Review 输出必须记录使用的 impeccable 命令或 skipped 原因，以及 `UI Drift: Passed / Fixed / Blocking / Skipped`。
- impeccable 只能作为 UI/UX 质量增强层；不得用视觉建议覆盖已确认的主用户路径、审核对象、权限、状态流或 API/ViewModel 契约。
- 目标项目未安装 impeccable 时，不阻塞 Review；按 `ui-flow.md` / `prototype/` 和浏览器 smoke 证据自审，并记录 skipped。

## 分级

| 级别 | 含义 |
| --- | --- |
| P0 | 功能错误、安全漏洞、数据破坏、发布阻断 |
| P1 | 高概率风险、缺关键测试、边界不完整 |
| P2 | 可维护性、可读性、后续优化 |

## 输出要求

- 发现问题时：文件/位置、问题、风险、建议修复。
- 没有发现阻塞问题时：明确说明，并列剩余验证缺口。
- 不要把个人风格偏好写成必须修改。
- 对高风险变更，必须说明是否存在 P0/P1 风险、是否缺少关键测试或 smoke。
