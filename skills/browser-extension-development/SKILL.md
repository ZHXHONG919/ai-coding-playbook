---
name: browser-extension-development
description: Build or review Chrome Extension features, permissions, content scripts, background workers, and API reporting.
---

# Browser Extension Development

## 使用时机

- 设计或实现 Chrome Extension 的 manifest、permissions、content script、background/service worker、popup 或 options。
- 设计网页采集、DOM 解析、任务同步、本地队列、后端上报或扩展端 smoke。
- Review 插件权限、注入边界、消息通信、采集频率和失败恢复。

## 非适用场景

- 只需要用浏览器打开页面、点击、截图或验证普通 Web UI，优先使用浏览器控制工具。
- 只是在实现常规 React/Vite 管理后台页面，优先使用 `react-vite-feature`。
- 只是在分析后端 API 契约，优先使用 `nest-api-design` 或对应 Review 规则。

## 配套规则

- 做方案或功能设计时，先读取 `references/stages/plan.md` 和 `references/plan/*`。
- 涉及网页采集、content script、background、popup、任务同步或上报链路时，必须读取 `references/scenarios/chrome-extension.md`。
- 方案必须区分插件端、目标网页、后端 API、采集原始快照、解析结果和审核结果。

## Checklist

- `manifest.json` 权限最小化。
- content script 避免重复注入和全局污染。
- DOM 采集逻辑对结构变化有容错，但不要无限扫描。
- background/service worker 考虑生命周期和消息超时。
- 与后端通信的 API base URL 可配置，不硬编码生产地址。
- 失败上报可见，必要时保留本地队列或重试。
- 采集任务有频率限制和停止机制。

## 验证

- build 通过。
- 加载扩展产物。
- 检查 popup/content/background console。
- 用最小授权样本完成一次端到端上报。
