# Goal 执行交接

> 把已确认的成功场景、任务依赖和验证方式转成可恢复执行包。复用方案决定，不重新发明产品规则，也不为每个节点复制一份文档。

## 何时使用

用户要求生成/执行/恢复 Goal，或任务有明显跨上下文恢复需求、多个相互依赖的交付批次时使用。轻量修改直接进入实现阶段；不是碰到 DB、API 或异步调用就强制建 Goal。

先读 `references/plan/task-breakdown.md` 和 `references/delivery/agent-delivery-flow.md`。涉及界面/用户可见结果追加 `references/delivery/evidence-driven-delivery.md`；确需第三方工具追加 `references/delivery/tooling-prerequisites.md`。

## 进入条件

- 用户已授权落地，成功场景、不能改变的行为和非目标明确。
- 沿用中央节点规则的交接与自主推进约定，记录必需结果、已约定可延期范围和已知时间约束；缺省不将必需结果降成可延期。
- 当前要执行任务所需的事实、契约和高影响未知已有结论；未来局部能力未就绪时有稳定边界、owner 与回收点，不阻塞可执行工作。不能用 mock 代替未确定的权限/状态语义。
- 需要复杂方案时已有 design CR，阻塞实际实现或依赖的问题已关闭；已有授权不重复询问。
- `tasks.md` 或等价任务来源定义依赖、功能批次、最小自测、最早真实路径及验收。涉及界面时有适合范围的确认基线。
- 按 Git 安全规则在功能分支写文件；候选规则不得误写到用户要求暂不应用的实时安装源。

## 最小执行包

放在项目既有 feature 文档目录下的 `.goal/`。默认核心文件：

| 文件 | 保存什么 | 避免重复 |
| --- | --- | --- |
| `GOAL.md` | 范围、非目标、来源、交付边界与策略例外 | 引用需求决定，不重抄业务规则 |
| `acceptance.md` | 验收编号、成功/失败场景、真实入口和证据 | 已有完整验收可引用原文和编号 |
| `slices.yaml` | 任务、批次、依赖、自测与执行所有者 | 从 tasks 继承，不另按技术层重排 |
| `status.yaml` | 唯一进度索引、基线、批次证据、下一动作 | 不同时回写 tasks 的第二份状态 |
| `gate.md` | 是否可开工、策略来源和遗留影响 | 记录实际检查结论，不以模板已填完代替 Ready |
| `resume.md` | 恢复动作、最新约束来源、未完成修改与 worker 核实入口 | 恢复时必须读取，不复制所有计数和状态 |

按需要建立 runs / validation / cr / snapshots。mock、待办、人工介入、工具准备、并行工作树和延期风险只在存在对应事项时建台账，或指向项目已有台账。`review-policy.md` 只写项目策略和例外；默认细则引用 `references/stages/review.md`。`design-handoff.md` 在确实需要集中契约索引时使用。

Goal 的执行选择、返工和证据引用沿用现有记录；没有合适载体时用一份 `execution-log.md`，见 `references/delivery/execution-evidence.md` 与 `templates/execution-log.md`。它是历史证据索引，不是第七份必需开工文件，也不替代 status。

## v2 任务与批次映射

`schema_version: 2`；`review_strategy: functional_batch` 为新包默认，执行 `run_control.mode: continuous`。两个选择独立；`per_slice` 保留给用户/项目明确要求的逐片审查。

- 每个任务有 `review_batch`、`review_boundary`、scope、non_goals、依赖、所有者、最小自测和必要文档。
- 普通任务 `review_boundary: batch`。一个批次覆盖一条完整用户路径，范围由验收决定，不按固定任务数量切分。
- 共享规则改变且后续任务依赖其正确性时，用 `before_dependents`，把该有限范围独立成 `kind: foundation` 批次；验收通过后才启动依赖。不要对整片大功能做部分验收，也不要把所有 DTO / API 任务都当基础变更。
- `per_slice` 策略每任务一个批次，`review_boundary: task`（基础任务仍保留 `before_dependents`）。
- 普通依赖在同一批次内可以依赖已 `implemented` 的任务；跨批次或基础依赖必须等前批次 `accepted`。
- 并行实现按 goal-execute 的写入责任约定初始化；current_slice 是主线程焦点，其他实际进行中任务关联 active_workers。模板空列表不是禁止并行，也不是预设已有 worker；不得为了启动 worker 跳过依赖。
- 已有全部或部分改动因前置变化/执行中断暂停时用 `awaiting_revalidation`，记录实际进展、未验证项和恢复条件，不冒充已完成，也不能满足依赖；恢复后补完实现并定向复验，细则见 goal-execute。
- 同一验收编号在不同批次必须指同一个完整断言，不能把不同局部结果混用同一编号。返修使唯一通过证据失效时将验收改为 pending；若另一有效非最终批次仍完整证明它，可引用该证据保留 passed，但不能把待复验任务算作已验收。
- 每个功能批次写清 `earliest_real_path`：实际入口、观测点、可替换的外部边界、安排在哪项任务。纯文档/基础批次可说明不适用原因。
- 继承前端先 mock 的 lane，但在同一功能批次尽早进入一条小的 SERVER_CAPABILITY → MOCK_REPLACEMENT → INTEGRATION 路径，再扩展更多界面和能力；不能以 lane 为由延后真实读写到全局末尾。
- 任务不过大：一个自测能覆盖的责任范围；共享身份、预算、生命周期和异步租约若各自规则复杂，应分清所有者和先后依赖，不堆成一个大修复任务。
- 最后单列 `kind: final` 批次，核对完整差异与验收覆盖。最后一片负责收口，不承担第一次真实链路验证；不默认等于发布 slice。

字段模板见 `templates/goal/slices.yaml` 和 `status.yaml`。snapshot 是包含代码与相关需求/契约内容哈希的清单路径；仅记 HEAD 不能识别未提交改动。批次正式验证与 CR 引用同一份清单。

非最终批次显式声明 `snapshot_scope.paths`（仓库相对文件/目录前缀，不用 glob）及 `contracts`（相关需求/原型等契约），检查新增/修改/删除并纳入前置输入；无关任务追加不使已验收范围失效。最终批次不能限定 paths，仍覆盖全部差异。采集命令及限制见 `evals/workflow-v2/checker.md`；范围与真实业务依赖仍需主线程核对。

## Gate Ready 判断

1. 成功标准能从真实入口观察，不是只写“build/test通过”；影响当前启动任务的高影响未知已解决或有经核实的隔离边界，后续回收与真实集成仍在计划中。
2. 所有任务均有可执行自测与唯一批次，任务与批次等待均无环；同一基础批次内不设置互相等待验收的依赖，可合并任务或拆批次。基础依赖前审范围明确。
3. 最早真实路径已排入功能批次，mock 清理与验收责任明确。
4. 当前必要工具已 ready；未来认证、用户动作及最晚准备点已登记，无工具依赖时映射为空。工具台账仅记录脱敏状态。
5. 所有者/并行文件归属明确，审查输入可冻结；独立验证/CR 能力和例外有依据。
6. `status.yaml` 初始化未完成状态，基线真实可解析；最终覆盖与代码交付/发布边界明确。

可以运行 `ruby <playbook-root>/scripts/check-goal.rb <goal-dir>` 检查 v2 结构与证据引用。脚本不证明 Gate 的业务结论；必须读实际需求、代码和验证策略。

## 旧包迁移与执行

旧包继续遵守原项目契约，不能自动取消每片 CR、零 Nit 或发布要求。采用 v2 时在 gate 记录原策略、改后策略、授权依据、任务映射和尚未审查/验证的工作，再逐项核对历史证据的实际版本。缺失字段从已确认事实推导，不能用模板默认值伪造验证通过。

Gate Ready 后按 `skills/goal-execute/SKILL.md`：实现→自测→到基础/功能批次边界独立验证和 CR→主线程裁决/修复→验收→继续。普通任务可以先到 implemented；没有审查和验收不能到 accepted。项目发布另按明确授权执行。
