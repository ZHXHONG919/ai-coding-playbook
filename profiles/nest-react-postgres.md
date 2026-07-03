# Profile: NestJS + React + PostgreSQL

适用项目画像：

- pnpm workspace / monorepo
- NestJS server
- TypeORM 0.3+
- PostgreSQL
- React + Vite 前端
- Vitest / Jest / Supertest 测试
- 脚本化部署

## AI 默认判断

- API 改动优先查 Controller、DTO、Service、Guard、Swagger。
- DB 改动必须同时考虑 Entity 和 SQL migration。
- 前端改动必须考虑 API client、loading、empty、error、权限、移动端适配。
- 异步任务必须考虑幂等、重试、并发、状态可观测。
- 外部 provider 必须考虑 timeout、retry、fallback、quota、成本和 mock。

## 常见验证命令占位

```bash
pnpm --filter <server-package> build
pnpm --filter <server-package> test
pnpm --filter <web-package> build
pnpm --filter <web-package> test
```
