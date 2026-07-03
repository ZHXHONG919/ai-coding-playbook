# Incident Workflow

> 通用故障分析流程，不绑定具体告警平台。

## 输入类型

可能来自：

- 告警 ID
- trace ID / request ID
- Sentry / error tracking issue
- 日志片段
- 用户反馈截图
- 失败的 smoke / CI 日志

## 分析步骤

1. 识别输入类型和环境：local / test / prod。
2. 获取错误事实：堆栈、请求参数、响应、相关日志、时间窗口。
3. 对照近期变更：git log、PR、发布记录、migration。
4. 定位代码路径：Controller → Service → DB / external provider。
5. 判断影响面：单用户、单租户、全量、异步任务堆积、数据损坏。
6. 输出结论：原因、证据、短期止血、长期修复、验证方式。

## 输出模板

```markdown
## 结论

## 证据

## 影响面

## 止血方案

## 修复方案

## 验证方式

## 后续预防
```
