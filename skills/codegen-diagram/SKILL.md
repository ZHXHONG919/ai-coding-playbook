---
name: codegen-diagram
description: Generate maintainable engineering diagrams from project code or documents. Use for architecture diagrams, module maps, data flow diagrams, state diagrams, ER diagrams, API flow diagrams, or Mermaid/Draw.io diagram drafts based on repository facts.
---

# Codegen Diagram

## 使用时机

- 根据当前项目、代码、数据库、接口或方案生成图。
- 用户提到架构图、模块图、数据流图、状态图、ER 图、表关系图、调用链路图。
- 方案阶段需要把领域抽象、流程、状态或数据产物流图补齐。

## 默认输出格式

优先输出 Mermaid，原因是适合方案文档、PR、Markdown 和后续维护。

只有用户明确要求 Draw.io、Excalidraw 或可编辑图文件时，才输出对应格式草稿。

## 图类型路由

| 用户意图 | 建议图 |
| --- | --- |
| 系统整体、模块边界 | `flowchart` 或 C4 风格 Mermaid |
| 调用流程、登录/支付/审核链路 | `sequenceDiagram` 或流程图 |
| 状态字段、任务状态、审核状态 | `stateDiagram-v2` |
| 表、Entity、聚合关系 | `erDiagram` |
| LLM / 异步 / 审核 / 同步链路 | 数据流图或产物流图 |
| 发布、回滚、任务编排 | 流程图 |

## 生成流程

1. 先读项目事实：README、AGENTS、相关代码、Entity、DTO、API、migration 或方案文档。
2. 建立证据清单，区分代码事实、文档事实、推断和待确认项。
3. 抽取节点和关系：
   - 节点：模块、实体、任务、外部系统、用户角色、产物。
   - 关系：调用、拥有、依赖、读写、状态迁移、触发。
4. 选择最小可读图类型，避免一张图塞进所有细节。
5. 输出图前先说明抽象口径和省略项。
6. 校验 Mermaid 语法、节点命名、方向、是否有孤立关键节点。

## 质量要求

- 图中只写有证据或明确标注为推断的内容。
- 节点名称用业务/工程里已有词汇，不临时发明同义词。
- 状态图必须覆盖初始、成功、失败、取消/失效等关键状态。
- ER 图区分对象自身字段、关系字段、任务上下文和计算结果。
- 大图优先拆成多张：业务结构图、核心流程图、状态图、数据流图。

## 输出

```markdown
## 图表口径

## 证据来源

## Mermaid

## 待确认
```
