# 实现落地阶段

> 目标：按已确认方案改代码，保持变更范围可控、可验证、可回滚。

## 角色视角

实现阶段默认站在 Senior Engineer、代码维护者和测试负责人视角：

- Senior Engineer：复用项目已有抽象，保持实现与方案里的领域模型一致。
- 代码维护者：控制改动半径，不制造孤立命名、重复逻辑或隐式副作用。
- 测试负责人：每个可验证单元都有最小检查，无法验证的部分明确说明。

复杂实现或发现方案不成立时，回读 `references/plan/role-lens.md` 和相关方案规则。

## 进入条件

满足任一条件才进入实现：

- 用户明确说“同意方案 / 开始实现 / 按这个落地 / 执行”。
- 紧急 bugfix 且用户明确要求直接修；即便如此，也要先说明最小修复思路和验证方式。

## 实现前检查

- 已确认方案版本或当前共识。
- 已明确本轮任务边界和非目标。
- 已知道涉及模块、文件、迁移、测试命令。
- 如果经过 feature kickoff，已定位 `plan.md` 和 `tasks.md`。
- 如果是复杂长链路方案（多切片、连续执行、跨会话续跑、异步/LLM/外部系统、前后端联调、smoke 或强 CR 门禁），必须先有 `.goal/status.yaml` 和 `gate.md: Ready`；否则回到 Goal Handoff，不能直接实现。
- 如果发现方案不成立，先回到方案阶段，不要静默改方向。

## 实现方式

1. 先读现有代码模式，优先复用项目已有抽象。
2. 按任务依赖顺序小步修改。
3. 数据模型、API、前端状态、Job 逻辑要与方案里的领域抽象一致。
4. 只做本轮需要的改动，不顺手重构无关代码。
5. 每完成一个可验证单元，运行最小有效检查；可提前验证的功能不要积压到最后。
6. 如果实现需要偏离方案，先说明偏差、原因和风险。

普通轻量任务可以由主 agent 直接实现、验证和自审。复杂 Goal 或多切片任务默认采用主 agent 编排模型：

```text
主 agent 读取任务 / slice 契约
→ 派发 implementer 子 agent / worker 完成局部实现
→ 派发 validator 子 agent 运行可验功能、contract test、smoke 或专项检查
→ 派发 reviewer 子 agent 做 scoped CR
→ 主 agent 审计报告和 diff，分派修复或亲自收口
→ 复验 / 复审
→ 主 agent 更新权威状态并提交
```

职责边界：

- 主 agent 是 orchestrator 和 final integrator，负责读取契约、拆执行包、审计证据、控制 scope、更新 `tasks.md` / `.goal/status.yaml`、合并和提交。
- implementer / fixer 子 agent 负责局部实现和局部修复；不得扩大 scope，不得修改权威状态源。
- validator 子 agent 负责验证可验功能，例如 UI mock smoke、API contract test、service unit test、mock 清理检查；验证报告必须进入 CR 输入。
- reviewer 子 agent 负责 scoped CR；不能用“worker 已验证”替代 CR。
- 如果没有可用子 agent，则主 agent 可以本地完成对应角色，但必须在任务记录中标明 `self-run` / `self-reviewed` 及原因。

## 单任务完成闸口

每个任务从 `Todo` 到 `Done` 必须经过：

```text
实现任务或派发 implementer
→ 写或补必要测试
→ 运行最小有效验证或派发 validator
→ scoped CR 或派发 reviewer
→ 修复 CR 阻塞问题或派发 fixer
→ 必要时重跑测试 / 复审
→ 更新 tasks.md
```

职责边界：

- 轻量任务中，主 agent 可以直接负责实现、补测、跑测试、修复问题和更新任务状态。
- CR 子 agent 负责 scoped review：只审本任务相关 diff、测试质量、方案偏差、回归风险。
- CR 子 agent 不直接继续后续开发；主 agent 必须吸收 CR 结论后再进入下一任务。
- 如果没有可用子 agent，则主 agent 按 Review 姿态自审，并在任务记录里标明 `CR: self-reviewed`。

复杂 Goal 下，以上职责改为主 agent 调度和审计，具体实现 / 验证 / CR / 修复可以由不同子 agent 承担；但只有主 agent 能更新 `.goal/status.yaml`、合并 worktree、提交 commit 或推进下一片。

CR 输入应包含：

```text
任务 ID
任务目标
涉及文件 / 模块
本次 diff
已运行测试和结果
方案文档路径
任务列表路径
要求：只 review 与当前任务相关的 bug、回归风险、遗漏测试、方案偏差。
```

CR 结果处理：

- P0/P1 或阻塞问题：必须修复并重新验证；核心逻辑变化后复审。
- P2/P3：按风险决定本轮修复或记录到 `tasks.md` / `notes.md`。
- 非本任务范围：记录 backlog，不阻塞后续任务，除非会导致当前任务不可用。
- 接受风险必须写清原因、影响和后续处理。

可以跳过 CR 的情况：

- 纯文档、注释、格式化或无运行时行为变化。
- 跳过时必须在任务记录中写明原因，例如：`CR skipped: docs-only change, no runtime behavior impact.`

## 任务状态回写

如果存在 `tasks.md`，每完成一个阶段都更新对应任务：

```markdown
| ID | Status | Task | Files / Modules | Validation | CR | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| T01 | Done | 实现 DTO 校验 | src/foo.dto.ts | Passed: pnpm test foo | Passed | - |
```

进度记录建议写到 `Progress`：

```markdown
## Progress

- 2026-06-17 T01 Code Done: 完成 DTO 和 service guard。
- 2026-06-17 T01 Test Passed: 通过相关单测。
- 2026-06-17 T01 CR Passed: 无阻塞问题，记录 1 个后续优化。
```

## 收尾

最终说明：

- 改了什么。
- 如何验证。
- 哪些任务已完成，测试和 CR 状态是什么。
- 哪些风险或测试缺口仍存在。
- 是否与方案有偏差；如果有，说明原因。
