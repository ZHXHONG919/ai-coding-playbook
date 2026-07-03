# Review Kit：安全审查

## 检查项

- 输入校验：API、CLI、Job payload、provider callback。
- 权限边界：读取、修改、审核、发布、重试是否有权限控制。
- 敏感信息：token、key、用户隐私、原始内容是否泄露到日志或前端。
- 注入风险：SQL、模板、prompt、HTML、shell command。
- 外部系统：请求超时、重试、签名、幂等、错误降级。

## 输出

安全问题默认至少 P1；涉及数据破坏、越权、凭据泄露时为 P0。
