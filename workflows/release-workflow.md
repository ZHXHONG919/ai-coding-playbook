# Release Workflow

> 通用发布纪律。具体命令留给业务项目 AGENTS.md 覆盖。

## 发布前检查

- 当前分支是否允许发布，通常必须是 `main`。
- 工作区是否干净。
- 本地 HEAD 是否等于最新远端 main。
- 是否明确本次 targets：api / admin / ops / h5 / extension / all。
- 是否明确 migration 列表。
- 是否需要下发 env；只改前端默认不下发 env。
- 是否有备份和回滚路径。
- dry-run 输出是否符合预期。

## 发布中

- 统一使用项目标准 release 脚本。
- 不手写临时 rsync / ssh / systemctl 串联命令替代 SOP。
- 每次 apply 前先 dry-run。
- 发布脚本输出 env diff 时必须脱敏。
- 健康检查失败时优先自动回滚到本次发布前备份。

## 发布后

- 记录发布 commit、targets、migration、备份目录。
- 验证健康检查和关键用户路径。
- 如果回滚，记录使用了哪份备份、哪些组件被恢复、DB 是否恢复。
