# AI Coding Playbook

> 这个仓库用于沉淀跨项目可复用的 AI coding 工作流、Agent 规则、文档模板和 Skills。
> 它不是业务项目，不包含任何业务代码、生产凭据、内部平台地址或具体客户信息。

## 这个项目解决什么

旧项目里沉淀了大量 AI coding 实践：分阶段设计、Code Review、测试范围分析、黑白盒验证、发布前检查等。
新项目 `lumeseed` / `lume-tuber` 的技术栈已经切换为 pnpm monorepo、NestJS、React、Vite、TypeORM、PostgreSQL、Chrome Extension 和 AI provider 集成。

本项目的目标是把这些经验抽象成通用资产：

- 让 AI 先理解、计划、验证，再改代码。
- 让 feature 设计、测试、发布和回滚有固定检查点。
- 让新需求从分支、方案文档、任务列表到单任务 CR 都可追踪。
- 让不同项目共享同一套基础 Skills，而项目细节仍留在业务仓库自己的 `AGENTS.md` 中。
- 避免把历史公司的业务、平台、Java 技术栈、内部工具绑定到新项目。

## 推荐目录结构

```text
ai-coding-playbook/
├── README.md
├── agents/                 # 可复制到业务项目根目录的 Agent 行为规则模板
├── references/             # 新版活规则：阶段、方案、review-kit、场景专项
├── workflows/              # 旧版工作流说明，保留兼容已有引用
├── templates/              # Feature 方案模板：复杂 feature-design、轻量 plan-light、PR、migration
├── skills/                 # 可安装到 ~/.codex/skills、~/.cursor/skills、~/.claude/skills 的通用 Skills
├── evals/                  # 规则、skill 路由和输出门禁的人工/脚本评测样例
├── platforms/              # 各工具 overlay 与安装 manifest（Codex / Cursor / Claude Code）
├── profiles/               # 旧版技术栈 profile，逐步迁移到 references/scenarios
└── scripts/                # 安装、同步、检查脚本
```

## 最轻使用方式

不需要安装、不需要复制模板，也不需要改业务项目。日常使用时，不必反复说长提示；在业务项目上下文里直接说阶段意图即可：

```text
梳理需求
做方案
拆任务
执行任务
继续 Goal
做 CR
测试范围
发布检查
```

如果当前窗口有多个项目，第一次加目标项目即可：

```text
目标项目 lume-tuber，做方案。
```

AI 应该自动读取目标业务项目自己的 README / AGENTS / CLAUDE / docs，再把本 playbook 当作通用方法论使用。项目事实永远优先于 playbook 默认规则。

更详细的对话用法见 [`docs/conversation-usage.md`](docs/conversation-usage.md)。

## 如何使用

### 方式一：只作为参考库

直接阅读：

```bash
cd /Users/xiaohong.zhxh/projectInfo/luseek/ai-coding-playbook
less README.md
```

适合还在打磨规则阶段。

### 方式二：把通用 Agent 规则复制到业务项目

```bash
# 例：复制到某个业务项目，复制后请人工补充项目特有内容
cp agents/AGENTS.template.md /path/to/project/AGENTS.md
cp agents/CLAUDE.template.md /path/to/project/CLAUDE.md
```

复制后应补充业务项目自己的：

- 本地启动命令
- 测试命令
- 发布脚本
- 生产域名和端口
- 数据库迁移规则
- 不允许 AI 擅自触碰的目录或流程

### 方式三：安装通用 Skills

```bash
bash scripts/install-skills.sh --target codex
bash scripts/install-skills.sh --target cursor
bash scripts/install-skills.sh --target claude
```

- 默认 Codex 目标：`~/.codex/skills/`
- 有平台差异的 skill（如 `ai-coding-playbook`）会合并 `platforms/<tool>/overlays/` 后软链
- 旧副本目录用 `--force` 替换为软链

工具专用说明：

- [`docs/codex-usage.md`](docs/codex-usage.md)
- [`docs/cursor-usage.md`](docs/cursor-usage.md)
- [`docs/claude-usage.md`](docs/claude-usage.md)

```bash
AI_CODING_SKILLS_DIR=/path/to/skills bash scripts/install-skills.sh --target cursor
```

脚本只安装本仓库 `skills/` 下的通用 skill，不修改业务项目。

## 资产分层

| 层级 | 放在哪里 | 是否跨项目共用 | 说明 |
| --- | --- | --- | --- |
| AI 行为边界 | `agents/` | 高 | 不乱改、不越权发布、先验证后收尾 |
| 活规则 | `references/` | 高 | 阶段路由、kickoff、方案门禁、review-kit、场景专项 |
| 工作流 | `workflows/` | 高 | 旧版 feature、review、test、release、incident，保留兼容 |
| 文档模板 | `templates/` | 高 | 复杂方案 `feature-design.md`、轻量方案 `plan-light.md`、PR、migration |
| Skills | `skills/` | 高 | Code Review、测试范围、设计 CR、Nest API、React feature 等 |
| 评测样例 | `evals/` | 高 | 验证 skill 路由、输出门禁和规则遵守是否可回归 |
| 平台适配 | `platforms/` | 高 | Codex / Cursor / Claude 的 frontmatter overlay 与安装 manifest |
| 技术栈画像 | `profiles/` | 中 | Nest/React/Postgres、Chrome Extension、AI pipeline |
| 业务事实 | 业务项目自身 | 低 | 域名、端口、模块名、凭据、发布机、具体数据表 |

## 维护原则

1. 这里沉淀“跨项目原则”，不要写业务专属逻辑。
2. 任何示例都使用占位符，不出现真实凭据、真实客户数据。
3. Skill 要描述判断标准和执行流程，不要绑定某个公司内部工具。
4. 如果某条规则只适合一个项目，放回那个项目的 `AGENTS.md`，不要放到这里。
5. 修改工作流或模板后，优先用一个真实小需求回放验证。
6. 修改 skill description、阶段路由或门禁后，补充 `evals/` 样例，确保能复查“规则是否真生效”。

## 当前通用 Skills

| Skill | 用途 |
| --- | --- |
| `ai-coding-playbook` | 入口路由 skill，触发后读取本仓库 `AGENTS.md` 与活规则 |
| `design-review` | 方案 / 需求 / UI flow 设计 CR，进入实现前门禁 |
| `goal-execute` | 按 `.goal/status.yaml` 编排复杂 feature 的 worker / validator / reviewer 切片执行 |
| `ts-code-review` | TypeScript / NestJS / React 代码 Review |
| `test-scope-analysis` | 从 diff 或方案推导测试范围 |
| `release-safety-review` | 发布前安全检查、回滚和 smoke 计划 |
| `nest-api-design` | NestJS API、DTO、Guard、Swagger 设计与评审 |
| `react-vite-feature` | React + Vite 页面、状态、表单和 API 集成 |
| `fullstack-ui-prototype` | 全栈功能的 UI flow、页面原型和静态流程验证 |
| `typeorm-postgres-migration` | TypeORM Entity 与 PostgreSQL migration 设计/评审 |
| `ai-provider-integration` | AI provider、fallback、成本保护和 smoke |
| `browser-extension-development` | Chrome 插件、content script、background 和采集链路 |
| `skill-maintenance` | 创建、维护、评审和沉淀多工具 Agent skill |
| `skill-prompt-convert` | Prompt / AGENTS / SKILL.md 互转 |
| `codegen-diagram` | 基于项目事实生成 Mermaid 架构图、ER 图、状态图、数据流图 |
| `codegen-doc` | 基于项目事实生成项目文档、模块说明和交接材料 |

## 规则生效诊断与评测

`references/stages/rule-diagnostics.md` 用于排查“规则配置了但 agent 没照做”的问题。诊断时先区分四层：

- 关联：文件、skill 或工具是否存在于可发现位置。
- 加载：本轮上下文是否实际读到入口或元数据。
- 读到：agent 当前步骤是否把规则纳入判断。
- 遵守：输出或动作是否符合可检查门禁。

`evals/` 保存可复查样例，用来验证 skill 路由和输出门禁。它不是替代真实项目验证，而是给 playbook 自身提供回归基线。


## 新版全站规则结构

`references/` 是当前优先维护的规则入口：

```text
references/
├── stages/       # 需求、需求确认、kickoff、方案、实现、Review、Bugfix、发布阶段
├── plan/         # 技术方案质量门禁：证据、角色视角、领域抽象、图表、细节、任务
├── review-kit/   # 通用 Review 流程和专项检查清单
└── scenarios/    # LLM 分析、AI 媒体、Chrome 插件、Nest/React/Postgres、pnpm monorepo 等
```

需求到方案的核心原则：复杂需求进入方案前必须先做需求确认，把多轮讨论里的已确认口径、非目标、待确认阻塞项和文档冲突收口；需求阶段提出的问题必须在需求阶段处理，方案阶段只基于已确认需求做论证、建模和工程设计。涉及复杂后台、运营、审核或批量操作时，按“需求分析 -> 需求确认 -> 页面流/审核对象草图 -> 技术方案草案 -> 静态原型/UI Flow -> 方案回写 -> 设计 CR -> 方案定稿 -> 任务拆解 -> 实现”的顺序推进。

方案阶段的核心原则：先用业务、领域、架构、交付和 Review 视角补齐盲区，再做轻量领域抽象，不套完整 DDD；复杂方案在任务拆解或实现前做 scoped design CR；涉及复杂后台页面、运营流程、审核流或批量操作时先补 UI flow，必要时用静态原型验证页面风格和业务流程；最后用图表和细节把方案落到可编码、可测试、可评审。复杂长链路方案通过 Design CR 后，必须进入 Goal Handoff，把方案和 `tasks.md` 转成 `.goal/` 执行契约，并通过 Goal Gate 后才能实现。

实现阶段的核心原则：按 `tasks.md` 小步推进；每个任务完成前先补必要测试并运行最小有效验证，再做 scoped CR，主 agent 吸收 CR 结论后才能继续后续任务。若 feature 已有 `.goal/status.yaml`，执行阶段以 `goal-execute` 续跑，状态只认 `.goal/status.yaml`。复杂 Goal 默认采用主 agent 编排模型：主 agent 派发 worker / validator / reviewer，子 agent 输出文件化报告，主 agent 审计证据、更新状态、合并和提交。
