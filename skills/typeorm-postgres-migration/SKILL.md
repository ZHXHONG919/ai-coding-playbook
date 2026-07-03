---
name: typeorm-postgres-migration
description: Guide and review TypeORM Entity plus PostgreSQL SQL migrations.
---

# TypeORM + PostgreSQL Migration

## 核心原则

- 生产 schema 演进以 SQL migration 为准，不依赖 TypeORM synchronize。
- Entity 和 SQL migration 必须同步。
- 已合并 migration 视为历史，不回改；修复用新 migration。
- migration 应可重放、幂等、失败后可恢复。

## 配套规则

- 任何 DB、Entity、migration、索引或唯一约束变更都按复杂方案处理，先读取 `references/stages/plan.md` 和 `references/plan/*`。
- 设计或 Review migration 时必须读取 `references/review-kit/database.md`。
- 表设计前必须完成领域抽象、业务结构图和字段归属判断，避免把任务上下文、关系字段或计算结果误写进核心资产表。

## SQL Checklist

- `CREATE TABLE IF NOT EXISTS`
- `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`
- `CREATE INDEX IF NOT EXISTS`
- 大表索引用 `CREATE INDEX CONCURRENTLY`，且不要放在事务里。
- 新增列允许 NULL 或给默认值，避免旧代码插入失败。
- 改字段类型、删字段、改枚举走分阶段迁移。
- 文件头写清原因、影响表、回滚策略。

## Review Checklist

- Entity 字段类型是否匹配 PostgreSQL 类型。
- nullable/default 是否一致。
- index/unique 是否既在 SQL 又在 Entity 表达。
- migration 是否同步到发布目录。
- 是否需要数据回填脚本。
- 是否有本地 replay 验证命令。
