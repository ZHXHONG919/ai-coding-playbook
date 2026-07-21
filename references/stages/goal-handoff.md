# Goal Handoff 阶段

> 目标：在复杂方案通过 Design CR 后，把 `plan.md` / `tasks.md` 转成可恢复、可检查、可连续执行的 `.goal/` 执行契约。Goal Handoff 是方案到实现之间的交接阶段，不重新讨论需求，不直接改业务代码。

## 使用时机

- 复杂 feature 已完成需求确认、方案、任务拆解和 Design CR，用户准备进入连续实现。
- 用户要求“生成 goal / 执行契约 / 按 goal 执行”。Goal 默认 continuous，除非用户明确要求只跑单片或只做状态检查。
- 任务包含多切片、多模块、异步任务、LLM/外部系统、前后端联调、smoke、CR 门禁或发布验收。
- 既有 `tasks.md` 无法稳定支撑上下文恢复、CR 审计或最终验收闭环。

Goal Handoff 必须同时读取 `references/plan/task-breakdown.md`。Goal 是 `tasks.md` 的执行契约化，不重新发明交付顺序。

## 强制场景

命中以下任一条件，Design CR Ready 后不能直接进入代码实现，必须先完成 Goal Handoff 并通过 Goal Gate：

- 用户要求按 slice 实现、每片 CR / commit、跨会话续跑，或明确要求连续执行。
- 任务需要 5 个以上切片，或任务之间存在明显依赖链。
- 涉及异步任务、LLM / AI provider、外部系统、审核流、同步链路或发布 smoke。
- 涉及前后端联调，且 P0 用户路径需要写 API、读 API、页面可见结果闭环。
- 需要 Deferred / Human Intervention / 多轮 CR / 全局验收门禁。

满足强制场景时，`design-review.md Ready` 只代表方案门禁通过，不代表可以直接写代码；实现前还必须有 `.goal/status.yaml` 和 `gate.md: Ready`。

## 非适用场景

- 单文件 bugfix、文案样式、小范围测试补充。
- 1 到 3 步内能完成，且没有跨切片依赖或最终 smoke 的轻量需求。
- 需求仍有 Blocking Pending，或 Design CR 结论不是 Ready。

## 进入条件

必须先满足：

- `requirements.md` 或等价需求基线已区分 Confirmed / Pending / Assumed。
- `plan.md` 已定稿或有明确当前方案版本。
- `tasks.md` 已覆盖字段、状态、接口、任务、验证和 CR；涉及前端项目 + API 交互时，已采用 Frontend-first Mock Lane。
- 复杂方案 Design CR 无未关闭 P0；P1 不阻塞首轮实现。
- 相关 `ui-flow.md`、API 契约、状态图、数据流或发布/smoke 文档已同步。

如果任一条件不满足，回到需求确认、方案或设计 CR，不生成 Goal 包。

## 产物位置

默认在 feature 文档目录下生成：

```text
docs/features/<feature>/.goal/
├── GOAL.md
├── acceptance.md
├── slices.yaml
├── status.yaml
├── review-policy.md
├── mock-ledger.md
├── todo-ledger.md
├── worktree-plan.md
├── human-intervention.md
├── resume.md
├── risks-deferred.md
├── design-handoff.md
├── gate.md
├── runs/
├── validation/
└── cr/
```

如果业务项目已有目录规范，遵循项目规范，但必须保留同等语义。

## Goal 包职责

| 文件 | 职责 |
| --- | --- |
| `GOAL.md` | 范围、非目标、分支、来源文档、全局完成标准、允许停止条件 |
| `acceptance.md` | 按用户路径写 P0/P1 验收，绑定写 API、读 API、页面可见结果和失败态 |
| `slices.yaml` | 每个切片的 scope、non-goals、必读文档、测试命令、Exit 清单和 CR 要求 |
| `status.yaml` | 唯一执行状态源：next slice、当前状态、active workers、last reports、open blocker/deferred、last CR、global exit；可包含 Codex app goal UI 镜像策略 |
| `review-policy.md` | CR 审核流程、角色矩阵、轮次、通过条件和所有 findings 的关闭规则 |
| `mock-ledger.md` | 记录 mock / pending API / fixture-only 读路径的创建、到期、清理和 waiver |
| `todo-ledger.md` | 记录局部待确认、需求优化、交互建议、契约优化和技术债；默认不阻塞下一 slice，Goal 结束或阶段 checkpoint 集中和人对齐 |
| `worktree-plan.md` | 记录允许并行的 worktree worker、ownership、merge order 和冲突策略 |
| `human-intervention.md` | 唯一允许遗留给人的事项；必须说明 agent 无法独立解决的原因 |
| `resume.md` | 上下文压缩后的同线程恢复提示；不用于主动新开线程 |
| `risks-deferred.md` | 允许的 Deferred 例外；默认 none |
| `design-handoff.md` | 方案结论、关键决策、契约指针、禁止执行期重辩论的边界 |
| `gate.md` | Goal Gate 检查结果：Ready / Not Ready，以及进入执行前必须修复的问题 |
| `runs/` | implementer / fixer worker 的文件化报告 |
| `validation/` | validator 的文件化验证报告 |
| `cr/` | 每个切片的文件化 CR 结果，禁止只在进度表中手写 Blocker=0 |

## 核心原则

- `.goal/status.yaml` 是执行阶段唯一状态源；不要同时维护 `execution-progress.md`、`tasks.md` 状态表和自然语言 goal 三本账。
- Codex app goal 进度条可以作为 UI 可视化镜像，但不是第二状态源；生成 Goal 包时应在 `status.yaml.codex_app_goal` 写明是否启用，非 Codex 环境可忽略该字段。
- `tasks.md` 是设计阶段的任务来源，Goal Handoff 后执行进度只回写 `status.yaml`。
- Goal slice 必须继承 `tasks.md` 的 lane、依赖和 mock ledger；不得在 Handoff 阶段重新按独立功能点拆成“每片前后端混做”的顺序。
- 切片按用户路径和 task lane 拆，不按纯技术层拆；涉及前端 + API 的 P0 路径必须先有 `CONTRACT` 和 `FE_MOCK_LOOP` 可见闭环，再逐步进入服务端真实化和 mock replacement。
- Goal 包只写执行契约，不把业务事实从业务项目搬到 playbook。
- Goal Handoff 不能绕过 Design CR；如果生成 Goal 包时发现方案缺口，回到方案阶段。
- Goal 不主动新开替代线程；上下文压缩后仍在当前线程按 `status.yaml` 恢复。允许主 agent 在同一 Goal 内调度受控子 agent、worker session 或 worktree worker，但它们不能替代主线程权威状态。
- Goal 默认 run mode 是 `continuous`：每个 slice 达到安全边界后自动进入下一 slice，直到 Goal 完成、真正阻塞、需要人工介入、用户打断或工具上限。只有用户明确要求只跑一片时，才使用 `single_slice`。
- 主 agent 是技术负责人 / final integrator：负责读取契约、判定实现所有者、派发 worker / validator / reviewer、审计证据、更新 `status.yaml`、合并和提交。实现可以是 `main_thread`、`worker` 或 `hybrid`；核心领域、状态、migration、provider、并发和用户最新口径同步优先由主线程或混合模式承担。
- 子 agent 输出必须文件化到 `runs/`、`validation/` 或 `cr/`；聊天回复、子线程摘要或 worker 自述不能替代 `status.yaml`。
- CR 阻塞项必须关闭；普通开发 slice 的 P2/Nit 可登记为 non-blocking follow-up，release gate 或用户明确要求“零 Nit”时才强制全部关闭。

## Goal Gate

`gate.md` 为 Ready 前，禁止进入 `goal-execute`。

Ready 条件：

- P0 acceptance 每条都写清入口、写动作、读接口、用户可见结果、关键失败态。
- 涉及前端项目 + API 交互时，`tasks.md` 必须包含 `CONTRACT → FE_MOCK_LOOP → SERVER_CAPABILITY → MOCK_REPLACEMENT → INTEGRATION / QA` 或等价 lane；若缺失，`gate.md` 必须为 `Not Ready`。
- 每个 slice 都有明确 `scope`、`non_goals`、`workers`、`validators`、`cr.reviewer_roles`、`tests`、`exit` 和 CR 要求。
- 每个 slice 都有 `lane` / `task_type` 标记，并能追溯到 `tasks.md` 的任务 ID；Goal 不得把未完成的 `FE_MOCK_LOOP` 和真实化服务端实现合并成同一个大 slice，除非任务本身是 1 到 3 步轻量需求且无需 Goal。
- 每个 slice 都有 `implementation_owner` 默认建议：`main_thread` / `worker` / `hybrid`，并说明主线程可编辑范围、worker scope、独立验证和独立 CR。
- 每个 slice 的 Exit 至少包含：实现报告存在、验证报告存在或有理由、验证绿、CR 文件存在、阻塞 findings 已关闭、P2/Nit follow-up 已登记、状态已更新、无新增未登记 mock。
- `review-policy.md` 明确 CR 循环和预算：验证 -> CR -> 修复阻塞项 -> 复验 -> 复审；同一 finding 默认最多 2 轮 worker fixer，超过后升级主线程收口，再不行转人工、方案同步或 non-blocking follow-up。
- 切片通过 Slice Size Gate 与 Throughput Gate：不过大、开发 slice 不强制零 Nit、UI Drift / 验证轮次有上限、高风险 slice 默认 main_thread/hybrid。
- `mock-ledger.md` 已初始化；所有 mock / pending API 都有创建 slice、清理 slice、用户可见影响和状态。
- `TODO ledger` 已初始化或指定位置；CR / 实现发现的局部待确认默认登记后继续推进，除非它破坏当前 P0/P1 验收、数据/权限/状态正确性，或后续 slice 无法通过 mock / adapter 隔离。
- `worktree-plan.md` 已说明哪些任务允许并行、ownership、merge order 和共享契约冲突处理；共享 DTO / Entity / migration / 状态机默认不并行改。
- `human-intervention.md` 初始为空；如允许人为介入，必须写清触发条件、代码 TODO 规则和最终状态 `needs_human_intervention`。
- `resume.md` 明确上下文压缩后不新开线程、不做半成品 checkpoint commit。
- `status.yaml.codex_app_goal` 已写明 Codex app UI 镜像策略；启用时仍声明 `.goal/status.yaml` 为 source of truth。
- 最后一片有 global exit：`open_deferred=0`、`open_cr_findings=0`、HTTP mock 白名单为空或计数为 0、P0 acceptance 全绿或有书面 waiver、smoke A/B 状态明确。
- 开发 slice 与 release gate 已拆开：生产 SSH、线上系统包、真实 provider、日志/ACL/SELinux、回滚和发布后验证只能放入 release slice / R10 / `release_gate`，不得默认拖入早期开发 slice。
- Deferred 默认禁止；若允许，必须写入 `risks-deferred.md`，包含 `expires_at_slice`、`user_visible_impact`、`code_stub` 和处理责任。
- `status.yaml` 初始化为 `next_slice` 指向第一片，`open_blocker=0`，`open_cr_findings=0`，`open_deferred=0`。

## 切片设计规则

切片应该能独立实现、独立验证、独立 CR、独立提交。

每个切片必须回答：

- 本切片继承 `tasks.md` 的哪个 lane：`CONTRACT` / `FE_MOCK_LOOP` / `SERVER_CAPABILITY` / `MOCK_REPLACEMENT` / `INTEGRATION` / `QA`。
- 本切片服务哪条用户路径。
- 本切片的最小可见闭环是什么。
- 哪些 API / DTO / Job / 页面状态会被创建或改变。
- 哪些 worker 可以实现，哪些 validator 必须验证，哪些 reviewer 必须 CR。
- 当前 slice 的 implementation owner 是谁；主线程是否需要先写核心骨架 / 状态转移 / 伪代码，再交给 worker 补测试或局部实现。
- 哪些测试证明本切片完成。
- 哪些 mock 必须删除，哪些例外被允许到哪一片。
- 哪些 TODO / 局部待确认可以不阻塞下一 slice，最晚何时集中对齐。
- 是否允许 worktree 并行；如果允许，ownership 和 merge order 是什么。
- CR 应对照哪些方案、任务、决策和验收文档，以及每轮 findings 如何关闭。
- 若 CR 问题无法由 agent 独立解决，如何登记 Human Intervention TODO。
- 本切片的吞吐预算：`max_pre_cr_validation_rounds`、`max_fix_rounds_per_finding`、UI Drift 时机、是否 `gate_level: release_gate`。

### Slice Size Gate

Goal Handoff 必须主动控制切片大小；过大的 slice 是后续无限 CR/fixer 的主要来源。

默认：

- 一个开发 slice 只交付一条主用户路径的最小闭环。
- `task_ids` 建议 ≤ 2；并发关键子系统建议 ≤ 1。
- `required_docs` 只列本片 delta 必需文档，不要默认塞入整包 Goal 文档。
- `FE_MOCK_LOOP` slice 默认只负责前端可见闭环、接口 mock / 接口壳、浏览器 smoke 和 UI Drift；后端 DB / service / job 真实化应进入后续 `SERVER_CAPABILITY` 或 `MOCK_REPLACEMENT` slice。

命中以下任意两项，必须拆成多个 slice，不得合并：

- 新的异步 Job / lease / 锁
- 多维度 embedding / 生命周期写路径
- 预算 / provider 结算与审计
- identity 失效或级联重算
- 未冻结契约下的前后端同改

高风险 slice（状态机、migration、provider、并发）默认 `implementation_owner: main_thread|hybrid`，不要默认纯 worker。

### Throughput Gate

`review-policy.md` 与每个 slice 必须声明：

- 开发 slice：阻塞 findings = 0 才能过；P2/Nit 允许 non-blocking follow-up。
- `max_fix_rounds_per_finding: 2`；超过后升级主线程或分流，禁止 silent fixer 空转。
- `max_pre_cr_validation_rounds: 1`（实现后完整验证一轮；失败修复后再一轮即可进 CR）。
- UI Drift 默认在首轮 CR 前一次、CR 后改 UI 再一次；不在每个中间 fixer 全量重跑。
- 开发 slice 与 `release_gate` 分离。

禁止：

- 把“读路径真实化”“smoke”“Deferred 清零”默认留给最后一片。
- 跳过 `FE_MOCK_LOOP`，直接按后端功能点或 DB/service slice 开工，导致用户路径到后期才可见。
- Goal Handoff 重新按独立功能点拆 slice，覆盖 `tasks.md` 中已经确认的 Frontend-first Mock Lane。
- 用 build 绿替代用户路径验收。
- 用 worker report、validator report 或聊天摘要替代文件化 CR 和 `status.yaml`。
- 让子 agent 直接推进 `status.yaml`、合并 worktree、提交 commit 或决定下一片。
- 在契约未冻结时并行修改 DTO / Entity / migration / 状态枚举 / 核心 service。
- 把 Blocker 改写成 Deferred 而没有到期切片和用户可见影响。
- 遗留 P0/P1/Blocker/Should-Fix 或其他影响当前 slice 正确性的 agent 可解决问题。
- 为上下文压缩主动新开线程，或为了压缩提交未通过测试/CR 的半成品 checkpoint commit。
- 生成只有自然语言流程、没有结构化状态和 Exit 的 goal。
- 把 Job + embedding 生命周期 + 预算结算 + identity 失效塞进同一开发 slice。
- 在开发 slice 强制 `nit: 0` / 全部 findings 清零，除非用户明确要求。
- 因 CR 里的局部需求建议、交互优化或未来扩展默认停住 Goal；这类项应进入 TODO ledger，开发完成或阶段 checkpoint 时集中对齐。

## 与实现阶段关系

普通实现继续使用 `references/stages/implementation.md`。

当 feature 存在 `.goal/status.yaml` 且用户要求按 Goal 续跑时，进入 `skills/goal-execute/SKILL.md`：

```text
Goal Handoff Ready
→ goal-execute 只读 status.yaml + slices.yaml[next]
→ 主 agent 判定 run_mode 和 implementation_owner
→ 当前 slice 实现 / 验证 / CR / 修复 / 复验 / 复审 / 状态更新 / commit
→ continuous 默认继续下一切片；single_slice 才停下汇报
```

如果执行中发现方案不成立，必须把 `status.yaml.execution.state` 写为 `blocked`，说明原因，并回到方案阶段。
