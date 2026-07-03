---
name: test-scope-analysis
description: Infer test scope and validation strategy from git diff, feature plans, task docs, or changed files for TypeScript pnpm monorepo projects. Use for test scope, 测试范围, 测试策略, what to test, or validation plan before merge.
---

# Test Scope Analysis

## 输入

- git diff / commit range / changed files。
- 可选：`plan.md`、`tasks.md`、feature design 或测试用例文档。

## 非适用场景

- 用户只是要求运行某条测试命令并返回结果。
- 用户要求完整实现测试代码，应进入对应实现或专项 skill。
- 发布前 Go / No-Go 检查优先使用 `release-safety-review`。

## 必读材料

1. 目标业务项目 `README.md`、`AGENTS.md`、测试相关文档。
2. 涉及 monorepo 命令时读取 `references/scenarios/pnpm-monorepo.md`。

## 分析步骤

1. 获取变更文件。
2. 过滤纯格式、注释、文档之外的行为变更。
3. 按影响面分类：server / web / extension / deploy / migration / AI provider。
4. 提取用户可观测行为变化。
5. 映射到测试：unit / e2e / smoke / manual。
6. 对照 `tasks.md` 或方案中的验收项，标出缺失覆盖。
7. 输出缺失测试建议和可执行命令。

## 行为变更识别

| 类型 | 例子 | 测试建议 |
| --- | --- | --- |
| API contract | path/request/response changed | e2e / supertest |
| Service logic | branch/state changed | unit/component |
| DB schema | entity/migration changed | migration replay |
| UI interaction | button/form/route changed | component/browser smoke |
| Provider integration | timeout/retry/fallback changed | mock + minimal real smoke |
| Release script | deploy behavior changed | shellcheck + dry-run |
| Shared package | types/utils changed | downstream package tests |

## pnpm monorepo 命令模板

先读项目文档确认包名；无项目事实时使用占位符：

```bash
# 单包测试
pnpm --filter <package> test

# 单包构建
pnpm --filter <package> build

# 根目录全量（较重，说明理由再用）
pnpm test
pnpm build
```

输出 `Commands To Run` 时：

- 优先最小相关 `--filter`。
- 说明每个命令覆盖什么风险。
- 无法确定包名时写待确认，不编造 filter。

## 输出

```markdown
## Suggested Test Scope

## Missing Coverage

## Commands To Run

## Manual Smoke Steps

## Mapping To Tasks / Acceptance
```
