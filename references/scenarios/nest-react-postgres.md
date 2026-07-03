# 场景规则：NestJS / React / PostgreSQL

## 后端

- Controller 负责协议和参数，Service/UseCase 负责业务流程。
- DTO、Entity、ViewModel 不混用。
- TypeORM migration 必须和 Entity 变化一致。
- Job/worker 的输入输出、状态和重试策略要明确。

## 前端

- 页面 ViewModel 要来自 API 契约，不直接复刻数据库结构。
- 操作态、加载态、空态、错误态、权限态要明确。
- 审核、重试、同步等动作要有确认和失败反馈。

## 数据库

- PostgreSQL 时间字段优先可读时间类型，遵循项目现有约定。
- 索引来自查询路径，不是凭字段名猜。
- 审计字段用于排查，流程字段用于业务状态，不要混淆。
