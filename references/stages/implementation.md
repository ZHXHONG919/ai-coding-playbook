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
- 已按 `references/git-safety.md` 检查当前分支和工作区；有未提交改动时不得自动 `pull`、`merge/rebase main` 或使用 `--autostash`。
- 如果经过 feature kickoff，已定位 `plan.md` 和 `tasks.md`。
- 如果是复杂长链路方案（多切片、连续执行、跨会话续跑、异步/LLM/外部系统、前后端联调、smoke 或强 CR 门禁），必须先有 `.goal/status.yaml` 和 `gate.md: Ready`；否则回到 Goal Handoff，不能直接实现。
- 如果用户只是问“能不能开发 / 当前分支是否可开工 / 达到可开发状态了吗”，只做 `prepare_only` 检查，不进入实现。
- 如果用户说“用 goal 开工 / 按 goal 执行 / 继续 goal”，默认进入 continuous，从 `.goal/status.yaml` 的 current/next slice 连续推进；只有用户明确说“只跑一片 / 先停在当前 slice / 只做状态检查”时，才使用 `single_slice` 或 `prepare_only`。
- 如果发现方案不成立，先回到方案阶段，不要静默改方向。
- 如果用户刚给出最新口径，或实现中发现同一业务动作存在互斥约束，先执行 Cross-doc Consistency Scan；未解决前不能以“更安全 / 更严格”的工程直觉替用户裁决。
- 若当前 feature 存在 `.goal/`，实现前必须确认最新口径已同步到 `.goal/acceptance.md`、`.goal/slices.yaml`、`.goal/cr/` 或说明无需同步的理由。
- 涉及前端页面、后台工具、审核流、任务流、表单、表格或复杂状态时，定位已确认的 `ui-flow.md` / `prototype/`；如果原型来自 Open Design，同时定位被用户确认的 projectId、studioUrl/previewUrl、entryFile 或 artifact bundle；如果目标项目已安装 `.agents/skills/impeccable`，实现后必须进入 UI Drift Gate。

## 实现方式

1. 先读现有代码模式，优先复用项目已有抽象。
2. 按任务依赖顺序小步修改。
3. 数据模型、API、前端状态、Job 逻辑要与方案里的领域抽象一致。
4. 只做本轮需要的改动，不顺手重构无关代码。
5. 每完成一个可验证单元，运行最小有效检查；可提前验证的功能不要积压到最后。
6. 如果实现需要偏离方案，先说明偏差、原因和风险。
7. 如果偏离原因是方案内部冲突、最新需求覆盖旧口径、按钮可用/数量/额度边界不一致，停止实现并回到方案同步或需求确认；不能自行选择一个看似保守的实现。
8. 不把“实现前同步主干”作为默认动作；需要更新 base 或处理主干冲突时，停下按 Git 安全边界和项目 PR 流程处理。

## UI Drift Gate

当前任务涉及前端页面、后台工具、审核流、任务流、表单、表格或复杂 UI 状态时，每个可验证页面完成后必须对照已确认的 `ui-flow.md` / `prototype/` / Open Design artifact 检查实现偏差。

如果 UI 基线来自 Open Design，UI Drift Gate 只检查实现是否忠实落地已确认版本；必要时用 `get_artifact` 拉取被确认项目的 entry file 和依赖文件作为对照。不要在实现阶段重新发散设计方向。需要新增设计方向、重排主路径或改变交互模型时，回到 UI Flow / 方案阶段。

如果没有已确认 UI baseline：

- 纯文案、样式、单字段或局部组件状态小改，可以记录 `UI Drift: Skipped(no confirmed baseline, scope=small)`，并用浏览器 smoke 或最小视觉自审替代。
- 涉及主用户路径、审核对象、操作矩阵、权限、状态流或 API/ViewModel 契约的改动，不能跳过；回到 UI Flow / 方案阶段补 baseline。

如果目标项目存在 `.agents/skills/impeccable/SKILL.md`：

1. 读取 impeccable。
2. 默认按 `impeccable audit` 检查可访问性、响应式、性能、溢出和状态覆盖；如果主要风险是页面偏离原型的信息架构、主次操作、视觉层级或清晰度，再按 `impeccable critique` 补设计审查。
3. 如果是在 CR 后修复前端问题，默认按 `impeccable polish` 做视觉、布局、文案和状态细节修复；修完再按 `impeccable audit` 复验，必要时补 `impeccable critique`。
4. 把结果记录到任务进度或 CR 输入：`UI Drift: Passed / Fixed / Blocking / Skipped`。

处理规则：

- 视觉、布局、间距、文案、loading / empty / error / permission / conflict / success 状态缺口：在当前实现任务内修复，并重跑 smoke 或最小验证。
- 主用户路径、审核对象、操作矩阵、状态流、权限或 API/ViewModel 契约变化：停止实现，回到 UI Flow / 方案阶段执行 Change Sync，并等待用户重新确认。
- 目标项目未安装 impeccable 时，不阻塞实现；按 `skills/fullstack-ui-prototype/SKILL.md` 的静态原型要求和浏览器 smoke 自审，并记录 `UI Drift: skipped, impeccable not installed`。

普通轻量任务可以由主 agent 直接实现、验证和自审。复杂 Goal 或多切片任务必须先判定实现所有者，避免主线程只当调度员、把质量问题全部后置给 CR：

```text
主 agent 读取任务 / slice 契约
→ 判定 implementation_owner: main_thread / worker / hybrid
→ 主线程或 implementer 子 agent / worker 完成局部实现
→ 派发 validator 子 agent 运行可验功能、contract test、smoke 或专项检查
→ 派发 reviewer 子 agent 做 scoped CR
→ 主 agent 审计报告和 diff，分派修复或亲自收口
→ 复验 / 复审
→ 主 agent 更新权威状态并提交
```

职责边界：

- 主 agent 是技术负责人和 final integrator，负责读取契约、确定实现所有者、审计证据、控制 scope、更新 `tasks.md` / `.goal/status.yaml`、合并和提交；当前 slice 若判定为 `main_thread` 或 `hybrid`，主 agent 可以直接实现已声明范围。
- implementer / fixer 子 agent 负责局部实现和局部修复；不得扩大 scope，不得修改权威状态源。
- validator 子 agent 负责验证可验功能，例如 UI mock smoke、API contract test、service unit test、mock 清理检查；验证报告必须进入 CR 输入。
- reviewer 子 agent 负责 scoped CR；不能用“worker 已验证”替代 CR。
- 如果复杂 Goal 没有可用子 agent / worker 工具，主 agent 可以按 `main_thread` 完成实现，但不能跳过独立验证和 CR；若独立验证 / CR 也不可用，必须停止并登记阻塞。

实现所有者默认判断：

| 场景 | 默认 owner | 原因 |
| --- | --- | --- |
| 核心领域模型、状态机、DTO / Entity / migration、预算 / provider、锁 / 并发 / 幂等 | `main_thread` 或 `hybrid` | 需要完整上下文和资深工程判断 |
| 用户刚修正口径、旧文档与当前代码冲突、Latest Requirement Delta 未完全同步 | `main_thread` | 先由主线程收口语义，避免 worker 猜实现 |
| 大量机械改文件、低语义风险测试补齐、重复 UI 状态矩阵 | `worker` | 可隔离执行，主线程审计即可 |
| 同一 slice 首轮 worker 被 CR 打回超过 2 次 | `main_thread` | 说明实现质量问题应前移到主线程处理 |

吞吐约束（复杂 Goal 同样适用）：

- 开发任务 / slice 只关阻塞项；P2/Nit 不影响正确性、数据、安全、发布或主用户路径时，登记 follow-up，不无限阻塞。
- 同一 finding 最多 2 轮 worker fixer，然后升级主线程收口或分流。
- 前端 UI Drift 默认在进入 CR 前一次；CR 后仅当修了 UI 再跑一次，不要每个中间 fixer 全量重跑。
- 用户中途改口径或 CR 提出需求优化时，先分类为局部 TODO 还是 Blocking Delta。默认写入 TODO ledger / follow-up 并继续当前任务；只有当前 P0/P1 验收无法判断、会产生错误数据/权限/状态，或后续任务无法通过 mock / adapter 隔离时，才冻结正交修复并做 Cross-doc Consistency Scan。

## 单任务完成闸口

每个任务从 `Todo` 到 `Done` 必须经过：

```text
实现任务或派发 implementer
→ 写或补必要测试
→ 运行最小有效验证或派发 validator
→ scoped CR 或派发 reviewer
→ 修复 CR 阻塞问题或派发 fixer
→ 若修复改到前端页面 / UI 状态，重新执行 UI Drift Gate
→ 必要时重跑测试 / 复审
→ 更新 tasks.md
```

职责边界：

- 轻量任务中，主 agent 可以直接负责实现、补测、跑测试、修复问题和更新任务状态。
- CR 子 agent 负责 scoped review：只审本任务相关 diff、测试质量、方案偏差、回归风险。
- CR 子 agent 不直接继续后续开发；主 agent 必须吸收 CR 结论后再进入下一任务。
- 如果没有可用子 agent，则主 agent 按 Review 姿态自审，并在任务记录里标明 `CR: self-reviewed`。

复杂 Goal 下，以上职责改为主 agent 技术负责和审计；实现可由 `main_thread` / `worker` / `hybrid` 承担，但验证和 CR 必须独立，且只有主 agent 能更新 `.goal/status.yaml`、合并 worktree、提交 commit 或推进下一片。

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
- P2/P3/Nit：普通开发任务默认按风险决定本轮修复或记录到 `tasks.md` / `notes.md`；不影响正确性、数据、安全、发布或主用户路径时，不应无限阻塞当前任务。
- 非本任务范围：记录 TODO ledger / backlog，不阻塞后续任务，除非会导致当前任务不可用、数据/权限/状态错误，或后续任务无法隔离。
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
