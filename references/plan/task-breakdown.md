# 方案规则：任务拆解

Priority: HIGH

## 规则

任务拆解必须能独立开发、独立验证。不能只写一句“实现分析任务”。

任务顺序优先按用户路径和依赖图生成，而不是按前端、后端、数据库等技术层横切堆列表。涉及前端项目和 API 交互时，必须采用**前端优先的模拟联调阶段**：

```text
契约冻结
→ 前端 mock 可见闭环
→ 服务端能力实现
→ 逐步替换 mock
→ 集成收敛 / QA
```

核心目标是先让用户路径可见、可验证、可确认，再按依赖关系逐步清理模拟数据和真实化实现。Goal 交接只能继承 `tasks.md` 的阶段和依赖图，不重新按功能点发明切片顺序。

任务涉及界面或可观察业务结果时，同时读取 `references/delivery/evidence-driven-delivery.md`，在任务拆解阶段确定期望基线、证据等级和证据门禁，不能等实现完成后临时决定是否截图。

任务依赖第三方应用、网站或桌面工具时，同时读取 `references/delivery/tooling-prerequisites.md`，在 `tasks.md` 增加“工具前置清单”。任务只引用清单 ID，不要在每个任务或切片重复安装、登录和授权。

## 工具前置清单

| ID | 能力 | 首选 CLI | 等价结构化方式 | 安装状态 | 认证状态 | 需要用户配合 | 界面控制是否必要 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| TP-001 |  |  |  | ready / missing | ready / pending | none / login / scan / code / permission | no / visual-only / blocked |

若没有前端用户路径，仍按普通依赖图拆解：契约 / 基础依赖 / 被依赖业务逻辑 / 集成收敛。

## 任务格式

| ID | 类型 | 状态 | 任务 | 输入 | 输出 | 涉及模块/文件 | 依赖 | 并行组 | 模拟策略 | 工具前置 ID | 证据等级 | 界面基线 | 证据门禁 | 验收标准 | 验证 | 代码审查 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |

类型：

- `CONTRACT`：契约冻结，例如 API / DTO / ViewModel / 状态码 / mock policy。
- `FE_MOCK_LOOP`：前端 mock 可见闭环，例如前端页面 + 交互状态 + 接口壳或 mock handler + mock 数据 + 浏览器 smoke。
- `INF`：基建能力，例如 provider client、调用日志、JSON schema 校验、runner。
- `BIZ`：业务能力，例如主题、内容池、审核、同步。
- `FE`：前端页面和交互。
- `SERVER_CAPABILITY`：服务端真实能力，例如 DB / Entity / Repository / service / permission / job。
- `MOCK_REPLACEMENT`：逐步替换 mock，接真实读写路径并关闭对应 mock ledger。
- `INTEGRATION`：真实化与集成，例如清理 mock、接真实 DB / service / job、跨端联调。
- `QA`：测试、smoke、验收脚本。

## 拆分原则

- 先冻结契约：API、DTO、ViewModel、状态枚举、错误码和 mock policy 没有明确前，不进入并行实现。
- 涉及前端项目 + API 交互时，`CONTRACT` 后必须先有 `FE_MOCK_LOOP`；它必须覆盖页面入口、交互、ViewModel、接口 mock、loading / empty / error / permission 状态、浏览器 smoke 和必要 UI Drift / impeccable 记录。
- `SERVER_CAPABILITY` 只能依赖已冻结契约，不能抢在 `FE_MOCK_LOOP` 前改变产品路径、ViewModel 形态或主操作矩阵；如果后端约束反推要改用户路径，登记 TODO / Change Sync，而不是静默重拆任务。
- `MOCK_REPLACEMENT` 必须逐步关闭 mock ledger，每替换一类 mock 就跑对应 contract / browser smoke；不能把全部真实化和 mock 清零默认堆到最后。
- 无共享写依赖的任务才允许 worktree 并行；共享契约、migration、Entity、状态枚举、核心 DTO 和公共 service 默认不并行改。
- 基建任务不能依赖具体业务 UI。
- 业务任务可以依赖基建接口，但要能 mock。
- 前端任务要明确页面、ViewModel、接口依赖。
- 每个任务必须填写证据等级；前端或用户可见任务还必须填写界面基线和证据门禁。纯后端任务明确填写“界面基线：无”，并选择接口、测试、日志或数据证据。
- 每个任务必须填写工具前置 ID；无第三方工具依赖时填 `[]`。切片的 `tooling_prerequisite_ids` 必须等于其 `task_ids` 引用 ID 的去重并集。
- 证据门禁要写清关键角色、关键端和必须留证的状态，不得只写“截图”。
- 多个任务共用同一页面、角色和状态时，合并为一个 `QA` 或 `INTEGRATION` 任务集中做原型对比、截图和多端验证，避免重复启动环境和重复留证。
- 每个任务的验收标准必须可执行。
- 任务顺序要能表达依赖关系，不要把所有任务并列堆起来。

## TODO Ledger

任务拆好并进入实现或 Goal 后，局部待确认默认不阻塞下一任务 / slice。CR、实现或验证中发现的新需求、交互优化、字段命名建议、契约优化或未来扩展，若不影响当前 P0/P1 验收，不改变数据安全、权限、状态正确性，且后续任务可通过 mock / adapter 隔离，应登记 TODO 后继续推进。

| TODO ID | 来源 | 类型 | 当前影响 | 最晚对齐点 | 建议处理 | 状态 |
| --- | --- | --- | --- | --- | --- | --- |
| TD-001 | CR / 实现 / 用户反馈 | 需求待确认 / 交互优化 / 契约优化 / 技术债 | 不阻塞当前任务 / 阻塞原因 | Goal 完成前 / R99 / 下个 kickoff | follow-up slice / backlog / 放弃 | open / closed |

只有以下情况才允许阻塞当前任务或下一 slice：

- 当前 P0/P1 验收无法判断或无法成立。
- 继续推进会制造错误数据、错误权限或错误状态。
- 后续 slice 直接依赖未确认契约，且无法通过 mock、adapter 或 feature flag 隔离。
- 用户明确要求先停下确认。

Goal 或阶段性开发结束时必须汇总 TODO Ledger，与人集中对齐；不要在局部 CR 中无限扩大当前任务 scope。

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
- 已按任务声明的界面基线和证据门禁完成验证；共享证据已逐条映射到对应任务。
- 若 CR 或实现产生局部待确认，TODO ledger 已登记；只要不命中阻塞条件，不影响当前任务进入 `Done` 或后续任务推进。

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
