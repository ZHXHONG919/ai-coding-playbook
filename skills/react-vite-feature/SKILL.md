---
name: react-vite-feature
description: Implement or review React + Vite frontend features, including API integration, routing, state, forms, and UX states.
---

# React + Vite Feature

## 实现前先看

- 路由结构。
- API client 封装。
- 组件库 / UI primitives。
- 状态管理：TanStack Query / Zustand / local state。
- 现有 loading / empty / error 模式。

## 配套规则

- 做页面方案或功能设计时，先读取 `references/stages/plan.md` 和 `references/plan/*`。
- 涉及 API、DTO、ViewModel、权限、审核动作或后端状态时，读取 `references/scenarios/nest-react-postgres.md`。
- 涉及 pnpm workspace 构建/测试范围时，读取 `references/scenarios/pnpm-monorepo.md`。
- 如果页面只是复杂方案的一部分，必须让 ViewModel、操作态、加载态、空态、错误态和验收标准对应到整体领域抽象和流程图。

## Checklist

- 页面入口、权限入口和返回路径完整。
- API 请求有 loading、error、empty、success 状态。
- 表单有同步校验和服务端错误展示。
- mutation 成功后刷新相关 query 或更新缓存。
- 移动端 / 桌面端布局不溢出、不遮挡。
- 不把业务常量散落在多个组件里。
- 不在组件中硬编码生产 API 地址。
- 新增可复用组件时确认至少两个真实使用场景，否则先内聚在页面内。

## 验证

- `pnpm --filter <web> build`
- `pnpm --filter <web> test`
- 浏览器 smoke：关键路径点击、表单、错误态。
