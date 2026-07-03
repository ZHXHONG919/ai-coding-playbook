---
name: release-safety-review
description: Review release readiness, migration safety, env changes, deploy targets, backup, rollback, and smoke plans. Use for release check, 发布前检查, Go/No-Go, rollback plan, or deploy safety review before apply.
---

# Release Safety Review

## 使用时机

- 发布前检查、回滚方案评估、发布 Go / No-Go。
- 评审 PR 中的 migration、env、deploy script、targets 变更。
- 用户提到 `--apply`、生产发布、备份恢复、健康检查。

## 非适用场景

- 只是在写功能代码，尚未进入发布窗口。
- 用户只要求解释项目发布文档，不涉及本次变更风险评估。

## 必读材料

1. 目标业务项目 `AGENTS.md`、发布文档、deploy 脚本说明。
2. `references/stages/release.md`。
3. 如有 DB 变更：`references/review-kit/database.md`。
4. 本次 PR diff、migration 列表、env diff、target 列表、release plan。

## 检查清单

### 发布前置

- 当前代码是否在允许发布的分支；工作区是否干净；`HEAD` 是否满足项目要求。
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

## Rollback Notes

## Post-Release Watch
```

没有阻塞项时也要列出剩余风险和发布后观察项，不能只说「可以发」。

## 角色视角

- Release Manager：分支、目标、顺序、人工确认点。
- SRE：健康检查、回滚可执行性、观测。
- 数据负责人：migration、备份、补偿。
- 业务 Owner：可接受风险与运营动作。
