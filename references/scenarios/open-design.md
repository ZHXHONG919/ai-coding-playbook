# Open Design 场景规则

> 目标：把 Open Design 用在真正需要设计探索的地方，并把产物稳定接回 AI coding 工作流。

## 定位

Open Design 是本地优先的设计工作台。它适合生成或细化可预览的设计 artifact，例如 HTML/JSX/CSS 原型、设计稿、deck、媒体或项目文件；不适合替代需求确认、业务建模、权限/状态/API 契约设计，也不适合每个小 UI 改动都强制使用。

在 Codex / Cursor / Claude 通过 MCP 使用时，Open Design 通常依赖正在运行的本地 daemon。MCP 不是离线设计库；它通过 Open Design 项目和 run 来读写设计文件、委托 Open Design 生成设计、再把结果拉回 coding agent。

## 使用判定

先判断本轮需要哪一种 Open Design 处理方式，不要把所有前端任务都升级成新建 run：

| Decision | 何时选择 | 后续动作 |
| --- | --- | --- |
| `skip` | 局部字段、按钮、文案、间距、颜色、组件状态；或已有明确设计系统内的小改 | 不启动 Open Design；记录简短跳过原因，继续用 `ui-flow.md` / 静态原型 / impeccable 自审 |
| `existing-baseline` | 用户已经在 Open Design 中有确认稿，或本轮只是按已有 Open Design 设计实现 / Drift | 定位 project、确认被采用版本，必要时 `get_artifact` 拉取源码；不启动新的 `start_run` |
| `run` | 需要生成或比较新的设计方向、复杂交互路径、跨角色流程，且文字 / 简单原型不足以确认 | 走 project -> `start_run` -> `get_run` -> `get_artifact` |
| `blocked` | 用户明确要求必须用 Open Design 但 daemon / MCP / agent 不可用；或业务规则 Blocking 会让设计稿掩盖未确认问题 | 停下说明阻塞；前者等待工具恢复，后者回需求确认 / 方案同步 |

## 何时启动新 run

命中以下任一场景时，可以选择 `run`：

- 新页面、新信息架构、大改版，且用户需要先看设计方向。
- 同一需求需要比较 2 个以上视觉方向、布局方向或交互路径。
- 后台、运营、审核、批量操作、任务流等页面涉及多角色、多状态、多异常分支，单靠文字难以确认路径。
- 用户明确要求 “用 Open Design”、“先看设计稿”、“让 AI 设计交互”。
- 已有 Open Design 项目但需要基于当前确认稿继续生成新方向或大幅细化。

选择 `existing-baseline` 而不是新 run：

- 用户当前正在 Open Design 中查看某个已确认设计，需要 Codex 拉取文件、继续按稿实现或做 UI Drift Gate。
- 已有确认的 Open Design 项目、截图、导出稿或 entry file，本轮只是实现、Review 或 Drift。

选择 `skip`：

- 单字段、单按钮、文案、间距、颜色、局部组件状态。
- 已有确认的 Figma/设计稿/原型，本轮只是按稿实现或做 UI Drift Gate。

选择 `blocked`：

- 用户明确要求必须使用 Open Design，但 daemon、MCP 或可用 agent 不可用。
- 业务规则、权限、状态流、API/ViewModel 契约仍 Blocking，且设计稿会掩盖这些未确认问题。

## MCP 实际工作流

优先使用真实 project/run/artifact 链路，不要只在文档里泛泛写 “使用 Open Design”。

1. 定位上下文：
   - 用户指向当前 Open Design 页面时，优先用 active context；必要时 `get_active_context` / `get_project` 确认项目和文件。
   - 用户要新设计时，先 `create_project(name)`，再发起生成。
   - 需要选择 Open Design 内置 recipe 或插件时，用 `list_skills` / `list_plugins` 发现；不要臆造 skill/plugin id。
   - 需要指定执行 agent 时，用 `list_agents`；不要臆造 `claude` / `codex` / `opencode` 是否可用。
   - 已有确认稿时，先把它作为 `existing-baseline` 拉取，不要为了“走流程”重复启动新 run。

2. 委托生成：
   - 用 `start_run(prompt, skill?, plugin?, inputs?, agent?, model?)` 委托 Open Design 生成或细化设计。
   - Prompt 必须带上当前项目事实、业务目标、页面范围、已确认/未确认边界、品牌/设计系统约束、必须覆盖的状态和非目标。
   - Open Design 会启动自己的 agent；当前 Codex 不应把它当作同一个上下文里的同步函数调用。

3. 等待完成：
   - `start_run` 只返回 `runId`，必须用 `get_run(runId)` 轮询到 `succeeded / failed / canceled`。
   - Open Design 生成通常需要 5-30 分钟。`status: running` 且文件 mtime 没变化是内部 agent 在思考，不是卡死。
   - 每 30-60 秒轮询一次，并向用户简短说明仍在运行。
   - 不要因为等待久就 `cancel_run`，也不要绕过 Open Design pipeline 直接用 `write_file` 伪造结果；只有用户明确要求取消时才取消。
   - 如果 run 超出当前会话可承受窗口，记录 projectId、runId、studioUrl 和下一步恢复方式；不要丢失上下文，也不要把未完成 run 当成通过。

4. 拉取结果：
   - 成功后优先把 `studioUrl` 给用户，它能同时看到渲染结果和 Open Design 内部对话。
   - 需要实现或做 UI Drift Gate 时，用 `get_artifact({ project })` 拉取 entry file 和依赖文件；优先于逐个 `get_file`。
   - `artifact bundle` 必须可追溯到一次 `get_artifact` 结果：至少记录 projectId、entry file、包含的关键依赖文件清单，或保存后的 bundle 路径 / 摘要。
   - 只读单文件时才用 `get_file`；查找文案、类名、组件时用 `search_files`；看文件元数据时用 `list_files`。
   - Review / Implementation 阶段只拉取已确认 baseline；除非用户明确要求重新探索，否则不要在这些阶段启动新设计 run。

5. 写回或迭代：
   - `create_artifact` 用于创建新的正常 artifact entry file。
   - `write_file` 用于迭代 Open Design 项目里已经存在或明确要覆盖的文件，不用于替代 `start_run` 的设计探索。
   - `delete_project` 是不可逆操作，必须有明确 project 和 `confirm:true`；普通工作流不要清理用户项目。

## 记录要求

只要本轮进入 UI Flow / 原型阶段并做过 Open Design 判定，`ui-flow.md`、原型说明、设计交接或 Goal handoff 中必须记录 decision。其余证据按 decision 分层记录，避免为 `skip` / `blocked` 编造不存在的 project 信息：

| Decision | 必填证据 |
| --- | --- |
| `skip` | reason、替代验证方式（如 `ui-flow.md` / 静态原型 / impeccable 自审 / 浏览器 smoke） |
| `existing-baseline` | projectId / project name、studioUrl 或 previewUrl、entry file、artifact bundle 关键文件清单或路径、采用版本 |
| `run` | projectId / project name、runId、studioUrl 或 previewUrl、entry file、artifact bundle 关键文件清单或路径、采用版本、拒绝版本和拒绝原因、inner agent 关键结论或 agentMessage 摘要 |
| `blocked` | blocker 类型（tooling / business）、阻塞原因、恢复条件、需要用户确认的问题 |

所有 decision 都要记录待确认问题，以及是否需要回到需求 / 方案 Change Sync。

## 与 impeccable 的关系

Open Design 负责探索和呈现设计方向；impeccable 负责设计质量、实现质量和 UI Drift Gate。

- Open Design 通过不等于 impeccable 通过。
- Open Design 产物进入 Product Flow Gate 前，如目标项目安装 impeccable，应做 `impeccable critique` 或等价视角检查。
- 实现完成后仍按 UI Drift Gate 对照 `ui-flow.md` / `prototype/` / Open Design artifact 检查。
- impeccable 或 Open Design 发现主用户路径、审核对象、操作矩阵、权限、状态流或 API/ViewModel 契约变化时，必须回到 UI Flow / 方案阶段做 Change Sync。

## 输出口径

方案 / 原型阶段输出：

- Open Design: `skip` / `existing-baseline` / `run` / `blocked`。
- Evidence: 按 decision 记录 reason / blocker，或 projectId、runId、studioUrl/previewUrl、entryFile/artifact bundle。
- Adopted design: 采用版本和理由。
- Rejected alternatives: 拒绝版本和理由。
- Gate: 等待用户确认 / 已确认进入详细方案 / Blocking 回需求或方案。

实现 / Review 阶段输出：

- UI baseline: `ui-flow.md` / `prototype/` / Open Design project + entry file。
- UI Drift: Passed / Fixed / Blocking / Skipped。
- Impeccable command 或 skipped 原因。
