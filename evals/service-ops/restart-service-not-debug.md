# Eval: 重启本地服务不自动进入排障

## Prompt

```text
重启下 server 和 admin-web，给我端口和 URL。
```

## Expected Route

- 可以触发 `ai-coding-playbook` 的通用工程上下文，按目标项目本地 README / AGENTS / CLAUDE 查启动命令。
- 不进入发布阶段，不触发 `release-safety-review`。
- 不进入 Bugfix / 排障阶段，除非启动命令失败、端口或 health 检查失败，或用户后续明确要求“排查 / 看报错 / 为什么失败”。

## Must Include

- 只执行服务生命周期操作：停止旧进程、启动指定服务、检查端口和 health。
- 回报最小结果：服务名、PID、端口、URL、health 状态或明确失败点。
- 如果正常启动耗时超过预期，应说明当前卡在哪一步，而不是继续扩展分析范围。

## Must Not

- 主动读取大段历史日志并展开业务原因分析。
- 把旧日志、采集任务输出或无关报错混入“重启服务”的结果说明。
- 修改代码、改配置、跑数据库迁移或执行测试 / staging / 生产发布命令。
- 输出发布 Go / No-Go、回滚方案或生产授权门禁。

## Regression Notes

如果该 case 误进入排障或发布，优先检查：

- `AGENTS.md` 的不触发场景是否保留本地服务生命周期操作边界。
- `references/stages/release.md` 是否明确本地启动 / 停止 / 重启服务不是发布请求。
- `skills/release-safety-review/SKILL.md` 非适用场景是否覆盖本地服务操作。
- 目标项目本地文档是否把启动命令、端口、health 写清楚，避免 Agent 通过读日志猜测。
