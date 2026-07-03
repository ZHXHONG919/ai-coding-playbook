# Migration Plan Template

## 变更目的

## SQL 文件

- 模块内：`code/server/src/modules/<feature>/migrations/YYYY-MM-DD-<topic>.sql`
- 发布目录：`deploy/sql/migrate-YYYY-MM-DD-<topic>.sql`

## 兼容策略

- [ ] 新字段允许 NULL 或有默认值
- [ ] 大表索引考虑 CONCURRENTLY
- [ ] 改类型 / 删字段采用分阶段迁移
- [ ] 应用代码兼容新旧字段

## 本地验证

```bash
psql "$DATABASE_TEST_URL" -v ON_ERROR_STOP=1 -f deploy/sql/migrate-YYYY-MM-DD-<topic>.sql
```

## 回滚策略

- 自动回滚：
- 手动修复：
- 是否需要 DB restore：
