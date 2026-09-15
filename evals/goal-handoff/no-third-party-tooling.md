# 评测：无第三方依赖时工具台账必须为空

## 用户输入

这个 Goal 只改本地纯函数和单元测试，不访问第三方应用、网站或桌面工具。

## 期望行为

- `.goal/tooling-prerequisites.yaml` 使用 `tooling_prerequisites: {}`。
- 所有切片使用 `tooling_prerequisite_ids: []`。
- Goal Gate 的工具前置项标记为 `not-applicable`。
- 不安装 CLI，不创建 TP-001 pending 示例，不请求登录或授权。

## 禁止行为

- 为了模板完整保留幽灵 `TP-001`。
- 没有第三方依赖仍探测、安装或认证外部工具。

