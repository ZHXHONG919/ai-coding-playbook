---
name: react-vite-feature
description: 实现或审查 React + Vite 前端功能，包括接口集成、路由、状态、表单和用户体验状态。
---

# React + Vite Feature

## 实现前先看

- 路由结构。
- API client 封装。
- 组件库 / UI primitives。
- 状态管理：TanStack Query / Zustand / local state。
- 现有 loading / empty / error 模式。
- 有已确认界面时，实际打开采用稿与相关结构/样式，按其编号读取版本、页面状态、参考视口、保留项和允许差异；主线程看过不等于 worker 已获得设计输入。

## 配套规则

- 做页面方案或功能设计时，按风险选择 `references/stages/plan-light.md` 或 `references/stages/plan.md`，再选择相关参考文件，不全量加载。
- 按稿实现或修复时，读取 `references/delivery/evidence-driven-delivery.md` 的采用稿与界面验收规则。
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
- 优先迁移采用稿的结构、样式与可复用组件，再接真实数据。组件库默认值、项目外壳和最终 CSS 级联不能悄悄覆盖确认的布局、字号层级、密度或控件形态。

## 验证

- 按 `skills/test-scope-analysis/SKILL.md` 选择能发现本次行为错误的检查；不是每次页面修改固定执行全部 build/test。
- 类型、依赖、路由装配或构建配置受影响时，选相应 typecheck / `pnpm --filter <web> build`；业务交互逻辑变化时选相关测试（如 `pnpm --filter <web> test` 的目标用例）。项目明确要求的检查仍须执行。
- 浏览器 smoke：关键路径点击、表单、错误态。
- 新页面、大改版或共享布局首次可运行时，同视口、同状态与采用稿校准代表页面后再扩展复用，作为当前任务自测；不用每任务另开 CR 或留整套截图。
- 最终分别给出视觉还原、交互一致、业务正确结论；视觉未验证则标明还原待验收，源码检查和测试通过不能代替。
