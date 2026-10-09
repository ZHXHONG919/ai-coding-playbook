---
name: nest-api-design
description: 设计或审查 NestJS 接口、数据传输对象、守卫、Swagger 文档和服务边界。
---

# NestJS API Design

## 适用场景

- 新增 Controller / endpoint。
- 修改请求或响应 DTO。
- 调整鉴权、分页、错误码、Swagger 文档。

## 配套规则

- 做方案或功能设计时，按 `references/stages/plan.md` 判断风险；新增或改变业务概念、共享规则及字段归属时读取 `references/plan/domain-design.md`、`references/plan/field-ownership.md`，其余参考按需读取。
- 涉及 NestJS + React + PostgreSQL 项目时，读取 `references/scenarios/nest-react-postgres.md`。
- 涉及 pnpm workspace 多包影响面时，读取 `references/scenarios/pnpm-monorepo.md`。
- 新共享状态、权限或高影响未知按方案入口做相应详细设计与审查；复用成熟 DB/API 的普通改动不自动升级完整方案。
- 有确认原型的全栈工作按 `references/plan/task-breakdown.md` 安排前端先行。先定领域/API 契约并准备服务端开发态 Mock API，供前端真实请求；本组前端体验完成后，再逐项替换为真实业务实现。接口准备不等待前端完成；必要基础核验和有限探针遵守该页例外。

## 设计检查

1. URL 使用资源名，动作型操作用清晰动词。
2. Controller 只做协议层：参数、鉴权、响应，不堆业务逻辑。
3. DTO 使用 class-validator / class-transformer 表达约束。
4. Response DTO 不直接暴露 Entity 中的敏感字段。
5. 分页接口明确 page/pageSize 或 cursor/limit，不混用。
6. 修改旧 DTO 时保持兼容：不直接删字段、不改字段类型；新增字段替代，必要时兼容读取。
7. 错误返回稳定：业务错误可被前端区分，日志保留排查信息。
8. Swagger / API docs 与代码一致。
9. 新增业务能力先映射到已有领域职责，按能力及依赖实现；明确共同规则的承载位置和消费者，避免按按钮重复校验或把长流程都堆进 Controller/Service。复用现有合理边界，不为普通接口新建整套分层。

## 输出

- API 列表。
- DTO 变更。
- 鉴权策略。
- 兼容性风险。
- 测试建议。
