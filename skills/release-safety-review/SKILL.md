---
name: release-safety-review
description: Review release readiness, deployment order, migration safety, env changes, deploy targets, backup, rollback, and smoke plans. Use for explicit release requests: release check, 发布前检查, Go/No-Go, rollback plan, 上线, 发版, 发测试, 发生产, deploy safety review before apply, or 部署/部署下 when the context already mentions merge main, release/hotfix branches, staging, production, or a concrete release command.
---

# Release Safety Review

## 使用时机

- 发布前检查、回滚方案评估、发布 Go / No-Go。
- 用户要求发布检查、回滚方案、Go / No-Go、上线、发版、发测试、发生产，或说已经 merge main / release 分支 / hotfix 分支后要求部署。
- 用户提到测试环境、staging、生产、发布窗口、`--apply` 或具体发布命令，并要求执行或评审发布安全。
- 评审 PR 中的 migration、env、deploy script、targets 变更。
- 用户提到 `--apply`、生产发布、备份恢复、健康检查。

## 非适用场景

- 只是在写功能代码，尚未进入发布窗口。
- 用户只要求解释项目发布文档，不涉及本次变更风险评估。
- 用户只是问“需要部署服务么 / 本地需不需要部署 / 部署哪个服务 / 只重启哪个 target / deploy 脚本参数是什么意思”；先回答本地运行、服务范围或命令解释，不默认推到测试 / staging / 生产。
- 用户只是要求启动、停止或重启本地服务，查看端口、URL 或 health；只做服务生命周期操作和最小健康检查，不自动升级成发布检查或排障。

## 必读材料

1. 目标业务项目 `AGENTS.md`、发布文档、deploy 脚本说明。
2. `references/stages/release.md`。
3. `references/git-safety.md`。
4. 如有 DB 变更：`references/review-kit/database.md`。
5. 本次 PR diff、migration 列表、env diff、target 列表、release plan。

## 检查清单

### 发布前置

- 当前代码是否在允许发布的分支；工作区是否干净；`HEAD` 是否满足项目要求。
- 发布检查不得为了同步主干本地执行 `git pull`、`git merge origin/main`、`git rebase origin/main` 或 `--autostash`；项目要求 PR-only 时只提示走 PR 页面 / merge queue。
- 默认发布顺序是否满足：读取项目发布 SOP -> 部署测试 / staging -> smoke / 验收 -> 等待人工通知 -> 生产发布。
- 未收到用户明确生产授权前，不执行生产发布命令，只输出生产发布计划、阻塞项和等待确认状态。
- 未指定环境的部署请求默认只允许测试 / staging；如果项目没有测试发布入口，停止并列阻塞项，不得回退到生产。
- 生产发布必须同时满足：已有测试 / staging 发布结果，且用户明确说“确认发生产 / 可以部署生产 / 继续生产发布”等生产授权语。
- `merge main`、`部署下吧`、`上线吧`、`发版吧` 只代表发布请求，不代表生产授权。
- 生产目标的 `--apply`、生产域名、生产主机或生产 DB 写操作，在生产门禁满足前不得执行。
- 是否先 dry-run，再 `--apply`。
- `targets` 是否最小化，避免重启无关服务。

### 数据与配置

- migration 是否显式列出、可重放、已本地验证。
- env 变更是否同步 example/docs；diff 是否脱敏。
- 是否存在不可逆 schema 变更；是否需要分阶段迁移或回填。

### 备份与回滚

- 备份目录、manifest、回滚入口是否明确。
- install 或健康检查失败时，脚本是否会自动恢复 dist / env。
- DB 默认不自动 restore；需要时是否由 release owner 明确执行。

### 验证与观测

- lint / typecheck / test / build 是否完成。
- 健康检查和关键路径 smoke 是否明确。
- 日志、错误码、任务状态、关键指标是否可排查发布后问题。

### 兼容与业务风险

- API / DB / 前端状态是否兼容旧数据和旧客户端。
- 是否需要灰度、开关、公告或人工运营动作。
- 业务 Owner 是否接受剩余风险。

## 输出格式

```markdown
## Go / No-Go

Go | No-Go

## Passed

## Blocking Issues

## Accepted Risks

## Irreversible Operations

## Suggested Release Commands

## Staging Result / Production Gate

## Rollback Notes

## Post-Release Watch
```

没有阻塞项时也要列出剩余风险和发布后观察项，不能只说「可以发」。

## 角色视角

- Release Manager：分支、目标、顺序、人工确认点。
- SRE：健康检查、回滚可执行性、观测。
- 数据负责人：migration、备份、补偿。
- 业务 Owner：可接受风险与运营动作。
