# AGENTS.md Template

> 复制到业务项目根目录后使用。
> 本文件约束 AI Agent 在项目中的默认行为。项目事实请在复制后补充，不要在 playbook 中写死。

## 语言与沟通

- PR 标题、PR 正文、变更摘要、风险说明默认使用中文。
- 代码标识、命令、文件路径、接口名、错误日志、第三方专有名词保留英文。
- 当需求存在多种解释时，先列出理解和假设；高风险改动先确认再动手。

## 默认工程纪律

- 优先阅读项目根目录 README、AGENTS、CLAUDE、docs/dev-guide，再改代码。
- 修改范围要外科手术式收敛：只碰与需求直接相关的文件。
- 不做顺手重构，不格式化无关文件，不删除自己没引入的旧代码。
- 发现无关问题可以在总结里提示，但不要擅自修。
- 改接口、DB、鉴权、发布脚本、环境变量时，必须同步文档或说明为什么不需要。
- Git 写操作先确认分支和工作区；默认只允许 `git status`、`git diff`、`git log`、`git fetch` 等只读/取远端引用动作。

## 安全边界

- 不提交 `.env`、密钥、service account、cookie、token、生产数据库 dump。
- 不把真实用户数据写进测试、文档或日志示例。
- 不绕过项目标准发布脚本，不手写一整段临时发布命令替代 SOP。
- 不在 feature 分支或脏工作区直接做生产发布。
- 不自动执行 `git pull`、`git merge origin/main`、`git rebase origin/main` 或 `--autostash` 来同步主干；如项目要求 PR-only，只能提示到 PR 页面 / merge queue 更新 base。
- 不在本地把功能分支合进 `main` / `master`，不直接推送受保护主干；主干合并走 PR 页面或项目 SOP。

## 发布默认规则

> 复制到具体项目后，在这里写明标准发布入口。

- 标准发布入口：`<fill project release command>`
- 默认先 dry-run，再 apply。
- 默认先部署测试 / staging 环境并完成 smoke；没有明确人工通知，不部署生产。
- 即使用户说明已经 merge main，也只代表代码状态，不代表生产发布授权。
- 未指定环境的“部署 / 部署下 / 上线 / 发版”默认只允许测试 / staging；没有测试发布入口时必须停下说明阻塞项。
- 生产发布必须同时满足：已有测试 / staging 发布结果，且用户明确说“确认发生产 / 可以部署生产 / 继续生产发布”等生产授权语。
- 发布前确认：分支、工作区、HEAD、migration、target、env、健康检查、回滚方式。
- 只改前端时，不应重启无关后端或 H5 服务。
- 涉及 DB migration 时，必须显式列出本次要执行的 SQL。

## 验证默认规则

> 复制到具体项目后，把命令补齐。

- 后端改动：`<fill backend build/test command>`
- 前端改动：`<fill frontend build/test command>`
- 部署脚本改动：`<fill shellcheck/bash -n command>`
- AI provider / 外部平台改动：优先跑 mock smoke，再跑真实 provider 最小 case。

## 前端 / UI 质量

- 涉及后台页面、运营流程、审核流、表单、表格或复杂 UI 状态时，优先维护 `ui-flow.md` / `prototype/` 作为交互基线。
- Open Design 只在新页面 / 大改版、多版视觉方向、复杂交互路径或需要用户看图确认时作为可选设计探索工作台；单按钮、字段、文案、间距和局部样式微调不要默认使用。使用后记录 projectId、studioUrl/previewUrl、entry file 或 artifact bundle、采用版本和跳过/阻塞原因。
- 如果项目安装了 `.agents/skills/impeccable`，按阶段使用其 `shape / critique / audit / polish` 等命令；未安装时不阻塞实现，改用浏览器 smoke 和原型对照自审。
- impeccable 只能改进视觉、布局、文案、状态覆盖和可访问性；不得擅自改变已确认的主用户路径、审核对象、权限、状态流或 API/ViewModel 契约。
