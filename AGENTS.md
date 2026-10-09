# AI Coding Playbook 入口

> 跨项目复用的 AI coding 规则库。目标是在普通对话里稳定识别研发阶段，先做好抽象和方案，再进入实现、测试、Review 和发布。

## 默认行为

轻量使用 playbook。不要在帮助用户前要求安装、复制文件或做初始化。

处理业务项目时：

1. 先读目标项目自己的 `README.md`、`AGENTS.md`、`CLAUDE.md` 和相关文档。
2. playbook 只提供通用方法论。
3. 项目本地事实优先于 playbook 默认规则。
4. 如果 playbook 与项目文档冲突，遵循项目文档，并简短说明冲突。
5. 执行任何 Git 写操作前先遵守 `references/git-safety.md`；默认只允许只读检查和 `git fetch`，不得擅自 `pull`、`merge/rebase main`、`--autostash` 或本地合并受保护主干。
6. 任务需要访问第三方应用、网站或桌面工具时，先读 `references/delivery/tooling-prerequisites.md`：开工前列出所需 CLI、认证和权限，优先 CLI / 专用连接器 / API；缺失的必要 CLI 按可信来源安装并验证，浏览器或桌面控制只作为最后手段。

触发后用一句短话标明阶段，例如：“我按 ai-coding-playbook 进入方案阶段，先不改代码。”

## 自然语言短指令

用户不需要每次说“参考 playbook”。只要当前对话在业务项目或本 playbook 上下文中，下面这些短语就应按阶段路由自动触发：

| 用户短语 | 默认阶段 |
| --- | --- |
| 梳理需求 / 分析需求 / 看下这个需求 | 需求分析 |
| 确认需求 / 对齐口径 / 收口需求 | 需求确认 |
| 做方案 / 写方案 / 方案设计 / 技术设计 | 方案阶段 |
| 做 UI Flow / 画页面流 / 做原型 / 看页面路径 | UI Flow / 静态原型 |
| 拆任务 / 拆实现 / 拆 task | 任务拆解 |
| 执行任务 / 开始实现 / 按方案落地 / 落地这个需求 | 实现阶段 |
| 继续任务 / 继续 Goal / 续跑 / 按 status.yaml 继续 | Goal Execute |
| 做 CR / review / 检查风险 | Review 阶段 |
| 测什么 / 测试范围 / 测试策略 | 测试范围分析 |
| 发布检查 / 回滚方案 / Go No-Go / 上线 / 发版 / 发测试 / 发生产 / 已 merge 或明确发布上下文中的部署下 | 发布阶段 |
| 排查问题 / 看报错 / bugfix | Bugfix / 排障 |

如果当前窗口有多个项目或目标不明确，先轻问一句目标项目；如果用户已说“目标项目是 lume-tuber”或当前工作目录就是业务项目，就不要反复要求用户写长提示。

不触发场景：

- 简单命令输出、纯事实问答、闲聊或非研发问题。
- 用户只要求解释一个概念，且不涉及当前项目方案、实现、测试、Review、发布或排障。
- 单纯翻译、润色、格式整理，除非内容本身是研发规则、方案或代码 Review。
- 用户只是问“需要部署服务么 / 本地需不需要部署 / 部署哪个服务 / 只重启哪个 target / deploy 脚本参数是什么意思”时，不自动进入发布阶段；先按上下文回答本地运行、服务范围或命令解释，只有用户明确要发布到测试 / staging / 生产，或已处在 merge / release / hotfix 发布上下文时，才进入发布阶段。
- 用户只要求“启动 / 停止 / 重启本地服务、看端口、给 URL、查 health”时，只做服务生命周期操作和最小健康检查；不要自动读取历史日志、分析业务问题、修改代码或升级为排障。只有启动失败、health 失败，或用户明确说“排查 / 看报错 / 为什么失败”时，才进入 Bugfix / 排障。

## 阶段路由

| 用户请求 | 必读规则 |
| --- | --- |
| 需求分析 / 梳理需求 | `references/stages/requirement.md` |
| 复杂需求进入方案前 / 需求确认 / 对齐口径 | `references/stages/requirement-confirmation.md` + `references/stages/requirement.md` |
| 新需求开工 / kickoff / 建方案和任务目录 / 开始一个需求 | `references/stages/feature-kickoff.md` + `references/git-safety.md`；落盘不改变复杂度，按实际范围选择轻量或复杂方案规则 |
| 技术方案 / 功能设计 / 模型设计 / 架构设计 | 先判断轻量或复杂：轻量读 `references/stages/plan-light.md` + `templates/plan-light.md`；复杂先读 `references/stages/requirement-confirmation.md`，再读 `references/stages/plan.md`；按该阶段说明选择相关 `references/plan/` 规则 + 匹配 `references/scenarios/*`，落盘用 `templates/feature-design.md` |
| 方案评审 / 设计 CR / 设计评审 | `skills/design-review/SKILL.md` + `references/stages/plan.md`；按该阶段说明选择相关 `references/plan/` 规则 |
| 生成 Goal 包 / Goal Handoff / 执行契约 / 复杂方案转连续执行 | `references/stages/goal-handoff.md` + `references/plan/task-breakdown.md`；统一选择 `templates/goal-v3/` |
| 开始实现 / 按方案落地 | `references/stages/implementation.md` + `references/git-safety.md` + `references/plan/task-breakdown.md` |
| 按 Goal 执行 / 续跑 goal / 从 status.yaml next_action 继续 | `skills/goal-execute/SKILL.md` + `references/stages/implementation.md` + `references/git-safety.md` |
| Review / 检查代码 / 看风险 | `references/stages/review.md` + `skills/ts-code-review/SKILL.md`；按风险选择 `references/review-kit/` 对应专项 |
| bug / 报错 / 排障 / 事故分析 | `references/stages/bugfix.md` + `references/git-safety.md` + `workflows/incident-workflow.md` |
| 发布前检查 / 回滚方案 / Go No-Go / 上线 / 发版 / 发测试 / 发生产 / 已 merge 或明确发布上下文中的部署下 | `references/stages/release.md` + `references/git-safety.md` + `skills/release-safety-review/SKILL.md` |
| Git 分支 / pull / merge main / rebase main / 同步主干 / 更新 base / force push / 冲突处理 | `references/git-safety.md` |
| 测试范围 / 测试策略 | `skills/test-scope-analysis/SKILL.md` + `references/scenarios/pnpm-monorepo.md` |
| 规则不生效 / skill 没触发 / 知识库没约束 Agent | `references/stages/rule-diagnostics.md` + `skills/skill-maintenance/SKILL.md` |
| 业务项目 AI-Ready / 接入 AI-SDLC 前检查 | `references/scenarios/ai-ready.md` + `docs/adoption-guide.md` |
| NestJS API | `skills/nest-api-design/SKILL.md` + `references/scenarios/nest-react-postgres.md` + `references/scenarios/pnpm-monorepo.md` |
| TypeORM / PostgreSQL migration | `skills/typeorm-postgres-migration/SKILL.md` + `references/review-kit/database.md` |
| React / Vite 页面 | `skills/react-vite-feature/SKILL.md` + `references/scenarios/nest-react-postgres.md` + `references/scenarios/pnpm-monorepo.md` |
| 全栈页面方案 / UI flow / 静态原型 | `skills/fullstack-ui-prototype/SKILL.md` + `skills/react-vite-feature/SKILL.md` + `references/scenarios/nest-react-postgres.md`；命中 Open Design 使用门禁时追加 `references/scenarios/open-design.md` |
| AI provider / AI 媒体链路 | `skills/ai-provider-integration/SKILL.md` + `references/scenarios/ai-media-pipeline.md` |
| Chrome 插件 / 采集链路 | `skills/browser-extension-development/SKILL.md` + `references/scenarios/chrome-extension.md` |
| Skill 创建 / 维护 / 规则沉淀 | `skills/skill-maintenance/SKILL.md` |
| Prompt / AGENTS / SKILL.md 互转 | `skills/skill-prompt-convert/SKILL.md` |
| 根据项目生成架构图 / ER 图 / 数据流图 | `skills/codegen-diagram/SKILL.md` + 匹配的 `references/plan/*` |
| 根据项目生成文档 / 模块说明 / 交接材料 | `skills/codegen-doc/SKILL.md` |

旧的 `workflows/*`、`profiles/*`、`templates/*` 暂时保留，用于兼容已有引用；新规则优先读取 `references/*`。

## 方案阶段核心要求

方案阶段默认不改代码。复杂方案按以下依赖关系推导，按实际风险选择需要的图和细节，不机械补齐所有产物：

```text
用户目标 / 旧方案 / 当前项目事实
→ 需求确认：已确认口径 / 非目标 / 待确认阻塞项 / 文档一致性
→ 证据来源表
→ 业务问题与非目标
→ 系统用例
→ 轻量领域抽象
→ 业务结构图
→ 流程图 / 状态图 / 数据流图
→ 工程映射
→ 表 / Entity / API / DTO / ViewModel / Job
→ 决策表
→ 任务拆解
→ 测试与验收
→ 本轮待确认问题
```

### 决定流程轻重的规则

- 没有证据，不写成事实。用户最新确认的业务规则优先于工程直觉；不能用“更安全”或 reviewer 建议擅自替换用户行为。
- 方案复杂度按规则变化与影响判断：新的共享状态/权限/计费/身份规则、不可逆数据变化、跨端协作语义、失败恢复或高影响未知需要复杂方案；复用既有规则的普通 API、字段、样式、只读查询不因技术名词自动升级。细则见 `references/stages/plan-light.md`。
- 需求区分已确认、待确认和假设。只让影响当前验收或直接依赖的高影响未知阻塞；可隔离的局部建议记录处理点，其余工作继续。
- 业务决定集中在单一来源；方案、任务、验收引用编号及必要原文。新口径先更新来源，再同步受影响的派生契约，不逐字重抄整包文档。
- 复杂方案先核实实际入口、上游类型、消费者、数据归属及已有规则，再做领域与工程映射。图用于解释共同概念、状态和跨端流转，不按模板数量凑图；图清楚后才进入依赖这些规则的实现。
- 复杂方案需要 design CR；复用已有确认与授权，不因换节点重复询问。需要结构化跨上下文恢复或用户要求 Goal 时进入 Goal Handoff，Gate Ready 后执行；轻量改动不强制建 Goal。
- 写需求/方案文件也要检查分支；主干干净时创建功能分支，不直接写 main/master；脏工作区不自动 stash、merge 或 rebase。保存轻量方案只写所需文件，不因落盘升级为全套需求、方案、任务和日志。
- 有确认原型的前端/API 工作按 `references/plan/task-breakdown.md` 先定领域与接口契约，由服务端提供开发态 Mock API，前端通过真实请求完成本组完整体验；随后按领域能力实现真实业务并逐步替换服务端模拟。关键未知可提前有限验证，不等全 Goal 前端完成才做后端。交付按用户路径，服务端按领域职责组织；Goal 先列全结果，再滚动展开工程步骤。
- 涉及主用户路径、审核、批量操作或复杂状态时，任务拆解前给出 UI flow；已有确认基线复用。需要用户选择交互方向时展示后等待确认；已有明确确认与落地授权不重复暂停。
- Open Design 只在新页面/大改版、多方案视觉探索、复杂路径或用户明确要求时考虑，记录 `skip / existing-baseline / run / blocked` 和依据。已确认稿只作基线；小样式改动不默认新建 run。
- 已安装 impeccable 时按实际阶段与问题选择 `shape / critique / audit / polish`；界面实现对照确认基线。证据按功能批次合并、修复后复核受影响状态，不每次中间修改重复完整审计。

### 实现、验证与审查

- 节点、下一动作、接任与中文提示只按 `references/delivery/agent-delivery-flow.md`；核验触发只按 `references/stages/review.md`。专项参考命中当前风险才加载，不重复读取完整规则包。
- 默认当前目录与现有正常开发环境，不主动创建或切换 worktree，用户明确要求时才使用。分工同时覆盖文件与共享进程、端口、数据库、队列和配置；未分配者不操作，失联写入者不算释放。
- 当前接手者推进实现、集成和交付，不假设原线程常驻。依据明确需求关联继承当前状态；不能凭标题认领或自动控制其他会话。
- 已确认且获授权后自主推进，普通自测通过继续；结果清单防漏，相关连续使用过程合批核验。首条真实路径校准不自动 CR，新的高风险共享语义在扩散前定向独立核验。
- 自测针对改变的行为、判错样本和实际观测，build、mock 或手造结果不能代替功能成立；方法见 `skills/test-scope-analysis/SKILL.md`。独立验证先推导预期并观测，再读实现说明及 CR，可由同一独立 Agent 承担。
- 当前用户决定与采用稿优先；技术选择和 reviewer 偏好不能改变产品语义。修复按问题族及影响复核，现场与自测矛盾先查实际执行系统，未受影响证据复用。
- 局部缺口约定稳定协议、回收点与真实集成后继续无依赖工作，不反复重开产品问答；必需缺口不能改成可选项或用 TODO 宣布完成。
- Goal 创建和恢复统一 schema 3：`goal.yaml` 保存结果/依赖，`status.yaml` 保存任务/下一动作/参与者/缺口，正式核验才增量留证；普通任务仅 `todo / in_progress / done`。检查器用于创建/恢复、正式核验及收尾，不每步调用。
- 开工粗略安排主要时间/token 成本和集成余量，已有边界比较进展与消耗；减少无效委派、重复上下文和无新信息的检查。成本约束不降低必需质量或扩大授权；具体见 `references/delivery/execution-evidence.md`。
- 交付核对全部承诺结果、基线至最终差异、有效证据和相关运行事实。代码验收、测试发布和生产发布分别报告，发布、真实付费调用等按已有授权及项目 SOP；必需未验证项未关闭不能宣布完成。
- App Goal 只作可选 UI 镜像，遵守用户请求和工具契约，不凭空创建或设置预算。明确只检查/只执行一项时遵从范围，普通节点持续推进。

## 轻量领域设计口径

领域设计不是为了套完整 DDD，而是为了做好抽象。必须回答：

1. 核心概念是什么。
2. 每个概念负责什么、不负责什么。
3. 哪些属于对象自身，哪些属于对象关系，哪些只是某次任务上下文，哪些是计算结果。
4. 概念如何创建、修改、审核、失效、重算。
5. 哪些规则必须长期稳定。

## 角色视角口径

复杂研发任务必须使用 `references/plan/role-lens.md`：

- 需求：业务负责人、产品负责人、领域建模者。
- 方案：业务架构师、技术架构师、交付负责人、资深 Reviewer。
- 实现：Senior Engineer、代码维护者、测试负责人。
- Review：Staff Reviewer、专项 Reviewer、发布风险负责人。
- 排障：Incident Commander、Debug Owner、回归验证负责人。
- 发布：Release Manager、SRE、数据负责人、业务 Owner。

输出不必机械罗列角色，但必须体现这些角色负责发现的问题、做出的取舍和剩余风险。

## 输出风格

优先高信号，不要为了形式写很长的仪式化文档。用户要正式方案时才完整展开；普通讨论可先给当前结论、关键图、决策点和待确认问题。

- 默认用用户能直接理解的自然语言解释问题背景、判断和下一步，不要先甩一串抽象词、方法论词或内部黑话。
- 必须使用术语时，先用一句白话说明它是什么、为什么此处需要，再给英文名、代码名或缩写。
- 避免把“治理、闭环、链路、范式、抽象、编排、对齐、赋能、抓手”等泛化词当作解释本身；除非它们指向当前项目里的具体对象、流程或文件。
- 用户只是问一个判断或取舍时，优先给结论和理由，不要把回答扩写成背景综述或规则宣讲。
- 面向人阅读的规则、Skill 说明、阶段输出、模板标题和示例默认使用中文，非必要不混用英文。Skill 名称、目录、代码标识、命令、文件路径、协议和稳定机器字段保留原值；英文术语首次出现时先给中文含义，后文优先使用中文。

## 规则生效与回归

当用户质疑“规则为什么没生效”“skill 为什么没触发”“知识库是不是没读到”时，不要直接追加更多规则；先按 `references/stages/rule-diagnostics.md` 区分关联、加载、读到和遵守四层，再决定修入口、修 description、修路由、下沉到子 agent，还是补 eval。

修改 skill description、阶段路由、模板或门禁后，优先在 `evals/` 增加一个可复查样例。规则库的目标不是“文件越来越多”，而是关键行为可回归。
