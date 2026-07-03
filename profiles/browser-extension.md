# Profile: Browser Extension

适用项目画像：

- Chrome Extension Manifest V3
- content script / background / popup / options
- Webpack 或 Vite 构建
- 与后端 API 通信
- 需要人工加载扩展做验证

## AI 默认判断

- 修改权限前检查 `manifest.json`。
- content script 注入逻辑要避免重复执行和污染页面全局。
- background/service worker 要考虑生命周期、消息传递、重试。
- 采集类功能要遵守授权边界和频率限制。
- API 上报失败要有可见错误和重试/跳过策略。

## 验证建议

- build 通过。
- Chrome 开发者模式加载产物。
- 检查 console、network、background service worker 日志。
- 用最小样本验证数据上报。
