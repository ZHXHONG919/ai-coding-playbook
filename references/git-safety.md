# Git 安全边界

> 目标：避免 agent 为了“同步 main / 跟上主干 / 解决冲突”擅自改写分支关系、污染用户未提交改动，或绕过 PR 保护流程。

## 使用时机

只要本轮可能执行 Git 写操作，就先读本文件：

- feature kickoff、需求/方案文件落盘、实现、Goal Execute、bugfix、发布检查。
- 用户提到 `pull`、`merge main`、`merge origin/main`、`rebase main`、`同步主干`、`更新 base`、`解决冲突`、`force push`。
- 工作区有未提交改动、当前分支不明确、当前在 `main` / `master` / `release/*` / `hotfix/*`。

项目本地 `AGENTS.md` / `CLAUDE.md` / 发布 SOP 如果比这里更严格，优先遵守项目规则。

## 允许的只读动作

默认允许：

- `git status --short`
- `git branch --show-current`
- `git remote -v`
- `git fetch origin`
- `git log --oneline --decorate -n <N>`
- `git diff` / `git diff --stat`

`git fetch` 只更新远端引用，不改工作区；它可以用于观察 `origin/main` 状态。fetch 后若要合并、rebase、pull 或 push，仍必须重新经过写操作门禁。

## 禁止默认执行的动作

除非项目规则明确允许、本轮用户明确二次授权、且工作区干净，否则不得执行：

- `git pull`，包括会隐式触发 merge / rebase 的 pull。
- `git merge main`、`git merge origin/main`、`git merge upstream/main`。
- `git rebase main`、`git rebase origin/main`、`git pull --rebase`。
- `git merge --autostash ...`、`git rebase --autostash ...`，或任何自动暂存用户改动后继续合并的命令。
- `git push --force` / `--force-with-lease`。
- 在本地把功能分支合进 `main` / `master`，或把 `main` / `master` 直接推到远端。

如果项目规定“合并 main / 更新 base / merge queue 只能从 PR 页面或平台按钮完成”，agent 必须停止本地合并，只能给出 PR 页面操作建议或等待用户在平台完成。

## 写操作门禁

执行任何 Git 写操作前必须同时满足：

- 已读取项目本地分支规则。
- 已说明将执行的命令、影响的分支、是否会产生冲突、是否需要 push。
- `git status --short` 为空；若不为空，停止并说明有未提交改动，不使用 `--autostash` 绕过。
- 用户明确授权当前命令，而不是只说“看下 / 处理下 / 更新下”。
- 当前不在受保护主干上；如果在 `main` / `master`，只允许创建新分支或按项目 SOP 操作。

需求 / 方案文件写入也算需要分支保护的工作。只在聊天里讨论方案时不需要 Git 写操作；但一旦要写入业务项目的 `requirements.md`、`plan.md`、`ui-flow.md`、`tasks.md`、`prototype/`、`.goal/*`，不得直接写在 `main` / `master` 上。若当前在主干且工作区干净，先创建需求功能分支；若工作区不干净，先停止并说明风险。

不满足任一条件时，输出阻塞原因和可选路径，不继续执行。

## 推荐处理方式

当需要跟上主干或处理 PR 冲突时，优先建议：

1. 只做 `git fetch origin` 和只读差异检查。
2. 如果项目要求 PR-only，提示用户到 PR 页面点击 update branch / rebase / merge queue，或按项目平台解决冲突。
3. 如果项目允许本地处理，先要求用户确认本地 merge 还是 rebase，并要求工作区干净。
4. 发生冲突时只收口用户授权范围内的冲突文件；不顺手改无关文件。

## 输出要求

遇到被禁止或需要确认的 Git 操作时，直接说明：

- 当前分支和工作区状态。
- 被拦截的命令或风险。
- 项目规则或 playbook 规则依据。
- 可选下一步：PR 页面处理、提交 / stash 用户改动、或用户明确授权本地命令。
