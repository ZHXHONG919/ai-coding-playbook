---
name: nest-api-design
description: Design or review NestJS APIs, DTOs, Guards, Swagger docs, and service boundaries.
---

# NestJS API Design

## 适用场景

- 新增 Controller / endpoint。
- 修改请求或响应 DTO。
- 调整鉴权、分页、错误码、Swagger 文档。

## 配套规则

- 做方案或功能设计时，先读取 `references/stages/plan.md` 和 `references/plan/*`。
- 涉及 NestJS + React + PostgreSQL 项目时，读取 `references/scenarios/nest-react-postgres.md`。
- 涉及 pnpm workspace 多包影响面时，读取 `references/scenarios/pnpm-monorepo.md`。
- 涉及 DB、状态流、异步任务、权限或发布风险时，按复杂方案处理，补齐领域抽象、流程图、状态图、接口契约、任务拆解和设计 CR。

## 设计检查

1. URL 使用资源名，动作型操作用清晰动词。
2. Controller 只做协议层：参数、鉴权、响应，不堆业务逻辑。
3. DTO 使用 class-validator / class-transformer 表达约束。
4. Response DTO 不直接暴露 Entity 中的敏感字段。
5. 分页接口明确 page/pageSize 或 cursor/limit，不混用。
6. 修改旧 DTO 时保持兼容：不直接删字段、不改字段类型；新增字段替代，必要时兼容读取。
7. 错误返回稳定：业务错误可被前端区分，日志保留排查信息。
8. Swagger / API docs 与代码一致。

## 输出

- API 列表。
- DTO 变更。
- 鉴权策略。
- 兼容性风险。
- 测试建议。
