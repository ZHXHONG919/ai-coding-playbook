---
name: ts-code-review
description: Review TypeScript, NestJS, and React changes for correctness, security, compatibility, and release risk. Use for code review, CR, 代码审查, PR review, diff review, or bug risk analysis.
---

# TypeScript Code Review

## Review 姿态

默认站在 Staff Reviewer、专项 Reviewer 和发布风险负责人视角：

- Staff Reviewer：优先找正确性、契约破坏、数据破坏、安全漏洞和发布阻断问题。
- 专项 Reviewer：按变更类型检查 NestJS、React、TypeORM、异步任务、AI provider、发布脚本等专项风险。
- 发布风险负责人：判断 migration、env、兼容性、回滚、smoke 和观测是否足够。

不要只评价代码风格。问题必须说明风险、触发条件和建议修复；风格偏好不能当成必须修改。

## 必读材料

1. `references/stages/review.md`。
2. `references/review-kit/review-flow.md` 和匹配的 `references/review-kit/*`。
3. 目标业务项目 `AGENTS.md` 与相关测试/发布说明。

## 输入

- 用户指定文件、代码片段，或当前 git diff。
- 未指定时，优先检查 `git diff HEAD`，再检查 staged diff。

## 审查维度

### 1. 正确性

- 输入输出是否符合现有契约。
- 空值、空数组、异常分支、状态迁移是否完整。
- 异步逻辑是否 await / return 正确。
- 并发、幂等、重复提交是否处理。

### 2. TypeScript 类型

- 是否滥用 `any`、类型断言或非空断言。
- DTO、Entity、前端 model 是否一致。
- union / enum 变更是否兼容旧数据。

### 3. NestJS / 后端

- Controller 是否有合适 Guard / Auth。
- DTO 是否有 class-validator。
- Service 是否承担过多职责。
- TypeORM 查询是否有 N+1、全表扫描、事务边界问题。
- 错误是否转成清晰业务异常。

### 4. React / 前端

- loading / empty / error 是否完整。
- useEffect 依赖是否正确。
- 表单校验、权限入口、移动端布局是否考虑。
- API 错误是否可见，不吞错。

### 5. 安全与运维

- 是否泄露凭据、token、真实用户数据。
- 是否引入危险日志。
- 是否需要 env example、文档、migration、release notes。

### 6. 发布与验证

- 是否有破坏旧数据、旧客户端或旧任务状态的风险。
- 是否需要灰度、开关、回滚或补偿脚本。
- 是否已有足够的 unit / e2e / smoke / manual 验证。
- 无法运行验证时，是否明确剩余风险。

## 严重程度示例

- **P0**：数据损坏、权限绕过、错误发布路径、不可回滚 migration、核心链路必现故障。
- **P1**：边界遗漏、错误契约、缺失关键测试、观测不足但可在发布前补上。
- **P2**：可维护性、命名、重复逻辑、非阻断风格问题。

## 输出格式

```markdown
## Findings

- [P0] ...
- [P1] ...
- [P2] ...

## Open Questions

## Verification Gaps
```

没有问题时明确说没有发现阻塞问题，并列出剩余风险。
