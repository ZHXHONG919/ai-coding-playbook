---
name: design-review
description: Review technical plans, requirements, UI flows, and architecture documents before implementation. Use for design CR, design review, 方案评审, 设计评审, scoped design review, or checking whether a plan is ready for task breakdown and coding.
---

# Design Review

## 使用时机

- 复杂方案进入 `tasks.md` 或实现前，需要做 scoped design CR。
- 用户要求评审 `plan.md`、`requirements.md`、`ui-flow.md`、原型或架构草案。
- 用户问「这个方案能不能开始写代码」「设计有没有漏」。

## 非适用场景

- 评审已写出的代码 diff → 使用 `ts-code-review`。
- 用户还在发散需求、口径未确认 → 先回到需求确认阶段。
- 发布前 Go / No-Go → 使用 `release-safety-review`。

## 必读材料

1. 目标业务项目 `README.md`、`AGENTS.md`、相关 docs。
2. `references/stages/plan.md` 与 `references/plan/*`。
3. `references/plan/role-lens.md`。
4. 当前 feature 的 `requirements.md`、`plan.md`、`ui-flow.md`、`prototype/`（如有）。
5. 涉及 DB / 状态流 / 异步 / 全栈页面时，读取匹配 `references/scenarios/*`。

## 审查维度

### 1. 需求基线

- 是否有已确认需求口径，区分 `Confirmed / Pending / Assumed`。
- 非目标是否写清。
- 需求文档之间是否互相冲突。
- 是否逐条对账用户原话和最新确认业务规则；影响按钮可用、数量、额度、人工动作边界的规则是否被工程安全直觉静默覆盖。

### 2. 证据与抽象

- 是否有证据来源表；没有证据的是否标注为推断或待确认。
- 是否完成轻量领域抽象：概念、职责边界、关系、生命周期。
- 有状态字段时是否有状态流转图；有异步/LLM/审核链路时是否有数据流或产物流图。

### 3. 工程细节

- 表 / Entity / API / DTO / ViewModel / Job 是否足够落到任务。
- 字段归属是否正确：对象自身、关系、任务上下文、计算结果。
- 兼容旧数据 / 旧接口 / 发布回滚是否考虑。

### 4. 全栈与 UI

- 后台、运营、审核、批量操作是否已有 `ui-flow.md` 或等价说明。
- ViewModel、操作矩阵、权限入口、错误态是否和 API/状态一致。
- 页面主路径是否能在 smoke 步骤中走通。

### 5. 可交付性

- 是否有决策表和本轮待确认问题。
- `tasks.md` 是否能从方案直接拆出，而不是实现时临时发明。
- 测试与验收标准是否覆盖主链路和关键异常。

### 6. 最新口径和跨文档一致性

- 用户最新口径是否已同步到 `requirements.md`、`plan.md`、`tasks.md`、`ui-flow.md` 和 `.goal/*`。
- 是否执行过 Cross-doc Consistency Scan，扫描词是否覆盖业务动作名、数量上限、额度、manual/auto、action gate、blocked reason。
- 同一动作若存在互斥约束，是否列为 Blocking，而不是选择“更严格 / 更安全”的实现。

## 角色视角

- 业务架构师：业务闭环和非目标是否清楚。
- 技术架构师：模块边界、扩展点、技术债是否可接受。
- 交付负责人：任务粒度、依赖链、阻塞项是否可执行。
- 资深 Reviewer：正确性风险、遗漏分支、发布/数据风险。

## 输出格式

```markdown
## Verdict

- Ready / Not Ready

## Blocking Findings

- [P0] ...

## Major Gaps

- [P1] ...

## Open Questions

## Ready Conditions

- 进入 tasks / 实现前必须满足的条件
```

`Ready` 仅当没有未关闭的 P0，且 P1 不阻塞首轮实现。用户授权且环境支持时，可拆给 scoped design CR 子 agent 分模块深挖，再由主 agent 汇总。

## 配套规则

- 复杂方案没有通过 design CR，不进入实现。
- 若评审中发现需求边界问题，回到需求确认，不在方案里偷偷改口径。
- 若评审中发现用户确认业务规则和工程限制冲突，必须列为 Blocking；不能用工程安全直觉替代产品口径。
