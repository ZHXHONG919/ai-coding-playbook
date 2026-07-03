# 方案规则：任务拆解

Priority: HIGH

## 规则

任务拆解必须能独立开发、独立验证。不能只写一句“实现分析任务”。

任务顺序优先按用户路径和依赖图生成，而不是按前端、后端、数据库等技术层横切堆列表。复杂全栈任务默认采用：

```text
契约冻结
→ mock 可见闭环
→ 基础依赖
→ 被依赖业务逻辑
→ 主链路真实化
→ 无共享依赖任务并行
→ 集成收敛
```

核心目标是先让用户路径可见、可验证，再按依赖关系逐步清理 mock 和真实化实现。

## 任务格式

| ID | 类型 | 状态 | 任务 | 输入 | 输出 | 涉及模块/文件 | 依赖 | 并行组 | Mock 策略 | 验收标准 | 验证 | CR |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

类型：

- `CONTRACT`：契约冻结，例如 API / DTO / ViewModel / 状态码 / mock policy。
- `MOCK`：可见闭环，例如前端页面 + 服务端接口壳 + mock 数据。
- `INF`：基建能力，例如 provider client、调用日志、JSON schema 校验、runner。
- `BIZ`：业务能力，例如主题、内容池、审核、同步。
- `FE`：前端页面和交互。
- `INTEGRATION`：真实化与集成，例如清理 mock、接真实 DB / service / job、跨端联调。
- `QA`：测试、smoke、验收脚本。

## 拆分原则

- 先冻结契约：API、DTO、ViewModel、状态枚举、错误码和 mock policy 没有明确前，不进入并行实现。
- 先做 mock 可见闭环：复杂前后端链路应先完成“页面 + 接口壳 + mock 返回 + 浏览器 smoke”，用它验证 UI flow 和主用户路径。
- 再做基础依赖：migration、Entity、Repository、共享 service、权限 guard、状态机等被依赖能力应在并行分支前完成。
- 再按依赖真实化：逐步把 mock 替换成真实 DB、service、job 或 provider；每清理一类 mock，就跑对应 contract / smoke。
- 无共享写依赖的任务才允许 worktree 并行；共享契约、migration、Entity、状态枚举、核心 DTO 和公共 service 默认不并行改。
- 基建任务不能依赖具体业务 UI。
- 业务任务可以依赖基建接口，但要能 mock。
- 前端任务要明确页面、ViewModel、接口依赖。
- 每个任务的验收标准必须可执行。
- 任务顺序要能表达依赖关系，不要把所有任务并列堆起来。

## Mock Ledger

任何 mock、pending API、fixture-only 读路径都必须登记：

| Mock ID | 创建任务 | 依赖契约 | 允许存在到 | 清理任务 | 用户可见影响 | 状态 |
| --- | --- | --- | --- | --- | --- | --- |
| M-001 | T02 | GET /api/example | T05 | 页面读路径未接真实数据 | open / closed |

规则：

- mock 必须有清理任务，不能只写“后面替换”。
- mock 清理任务必须绑定验收路径和验证命令。
- 最终集成任务必须确认 mock ledger 为 0，或有书面 waiver。

## 并行与 Worktree

并行任务必须显式写清：

| Parallel Group | Worktree Allowed | Ownership | Merge Order | 冲突策略 |
| --- | --- | --- | --- | --- |
| P1 | yes/no | 文件 / 模块边界 | after T03 | 共享契约冲突回主线收敛 |

允许 worktree 并行的典型任务：

- 独立页面区块或独立表单，不改共享 ViewModel。
- 独立测试、smoke、文档或验证脚本。
- 独立 provider adapter，且契约已经冻结。
- 不共享写同一批 DTO / Entity / migration / 状态机 / 核心 service 的业务分支。

禁止 worktree 并行的典型任务：

- 同时修改同一张表、同一组 migration、同一组 Entity。
- 同时修改公共 DTO、状态枚举、路由契约或核心接口抽象。
- 契约仍在 Pending，或任务之间存在未收口的强依赖。

## 完成标准

任务不能只因为代码写完就标记完成。进入 `Done` 前必须满足：

- 实现符合已确认方案或已记录方案偏差。
- 必要的单测、集成测试、E2E、contract test 或 smoke 已补齐；如果不补测试，必须说明原因。
- 最小有效验证已运行并记录结果；可验功能不要积压到最后。
- scoped CR 已完成；阻塞问题已修复，非阻塞问题已记录。
- 若任务创建或依赖 mock，mock ledger 已更新；若任务负责清理 mock，必须证明对应 mock 已关闭。

任务状态建议：

- `Todo`
- `In Progress`
- `Blocked`
- `Code Done`
- `Test Failed`
- `CR Pending`
- `CR Changes Requested`
- `Done`
- `Skipped`
