# Conversation Usage

> 最轻使用方式：不用安装，不用复制，不用改业务项目。
> 你可以说“参考 ai-coding-playbook”，也可以直接说“梳理需求 / 做方案 / 执行任务 / 继续 Goal”。复杂规则由 AI 内部读取和执行，不需要用户背提示词。

## 日常短指令

绝大多数时候不用说完整提示，也不用反复写“参考 playbook”。在业务项目上下文里，直接说阶段意图即可：

| 你说 | AI 应该做 |
| --- | --- |
| 梳理需求 | 进入需求分析，先读项目事实，不改代码 |
| 确认需求 | 收口 Confirmed / Pending / Assumed 和非目标 |
| 做方案 | 进入方案阶段，判断轻量 / 复杂，复杂需求先确认需求 |
| 做 UI Flow / 做原型 | 进入页面流 / 静态原型阶段，完成后停下等确认 |
| 拆任务 | 按依赖图、mock ledger、并行边界拆 `tasks.md` |
| 执行任务 | 按已确认方案和任务实现、验证、CR |
| 继续 Goal / 续跑 | 从 `.goal/status.yaml` 恢复执行 |
| 做 CR / review | 按风险优先做代码或方案 Review |
| 测试范围 | 推导需要测什么和最小有效验证 |
| 发布检查 | 做 Go / No-Go、回滚、smoke 检查 |
| 排查问题 | 进入 bugfix / incident 排障 |

如果当前窗口有多个项目，第一次加一句目标即可：

```text
目标项目 lume-tuber，梳理需求。
```

之后可以直接说：

```text
做方案。
执行任务。
继续 Goal。
做 CR。
```

只有在你想覆盖默认行为时，才需要补充限制：

```text
做方案，先别写代码。
执行任务，但不要提交。
继续 Goal，使用子 agent 做实现、验证和 CR。
```

## 进阶说法

下面这些完整句式适合跨项目、首次进入上下文、或需要明确约束时使用。

### 新需求开工

```text
参考 ai-coding-playbook，按规范启动这个需求：检查分支，建方案和任务目录，然后先写方案。
```

AI 应该执行：

- 检查当前分支、工作区和项目本地规则。
- 在安全边界内处理主干拉取和功能分支创建；有未提交改动或分支意图不明确时先询问。
- 创建 `docs/features/YYYYMMDD-short-topic/`。
- 初始化 `requirements.md`、`plan.md`、`tasks.md`、`notes.md`。
- 复杂需求先进入需求分析 / 需求确认阶段，确认后再进入方案阶段；不直接改业务代码。

### 技术方案

```text
参考 /Users/xiaohong.zhxh/projectInfo/luseek/ai-coding-playbook，帮我为这个需求写技术方案。
```

AI 应该输出：

- 目标 / 非目标
- 当前上下文与假设
- 方案设计
- API / DB / 前端 / 异步任务影响
- 风险和边界
- 测试策略
- 发布与回滚

复杂需求如果还没有需求确认，AI 应该先停在需求确认阶段：

```text
参考 ai-coding-playbook，先根据前面多轮讨论整理需求确认稿，确认后再进入方案设计。
```

AI 应该输出：

- 已确认需求口径
- 非目标 / 反需求
- 关键输入、输出、产物消费者和审核对象
- 状态、异步、LLM、同步、权限、数据写入时机等复杂边界
- `Confirmed / Pending / Assumed`
- 文档内部冲突和待确认阻塞项

需求阶段提出的问题必须在需求阶段处理。方案阶段只基于已确认需求做论证、建模和工程设计。

进入 feature 文档管理时，需求确认稿默认写到同目录 `requirements.md`，技术方案写到同目录 `plan.md`。`plan.md` 必须引用需求基线；复杂需求没有 `requirements.md` 或等价确认记录，不进入方案设计。

方案讨论阶段采纳反馈时，AI 应该输出并执行同步修改清单：需求变化同步 `requirements.md`，方案结构同步 `plan.md`，字段/API/任务变化同步 `tasks.md`，页面流程变化同步 `ui-flow.md` 和必要的 `prototype/`。如果只改一个文件，需要说明其它文件不需要同步的理由。

复杂后台、运营、审核或批量操作需求推荐完整流程：

```text
需求分析
-> 需求确认
-> 页面流 / 审核对象草图
-> 技术方案草案
-> 静态原型 / UI Flow
-> 方案回写与一致性同步
-> 设计 CR
-> 方案定稿
-> 任务拆解
-> 实现
```

原型不必早于所有技术方案，但必须早于方案定稿和任务拆解。

复杂方案在任务拆解或定稿前应做设计 CR。用户可以明确授权：

```text
这个方案比较复杂，允许你唤起子 agent 做领域、架构和交付 CR，再汇总进 plan.md。
```

AI 应该执行：

- 主 agent 先形成方案草案和证据来源。
- scoped design CR 子 agent 分别检查领域抽象、架构边界、交付和测试风险。
- 主 agent 整合 CR 结论，更新决策表、任务拆解和待确认问题。
- 如果子 agent 不可用，则按角色视角自审并标记 `Design CR: self-reviewed`。

### 实现逻辑

```text
按 ai-coding-playbook 的思路，帮我拆一下实现逻辑，先不写代码。
```

AI 应该输出：

- 模块边界
- 主流程
- 状态变化
- 错误处理
- 测试点

### 按任务实现

```text
按 tasks.md 从 T01 开始实现，每完成一个任务都补测试、跑测试、做 CR，再继续下一个。
```

AI 应该执行：

- 按任务依赖顺序小步修改。
- 每个任务完成后补必要测试并运行最小有效测试。
- 唤起 scoped CR 子 agent；不可用时按 Review 姿态自审并记录。
- 修复阻塞 CR 问题，必要时复审。
- 更新 `tasks.md` 的状态、验证结果和 CR 记录。

### 测试范围

```text
参考 playbook，看看这次改动需要测什么。
```

AI 应该输出：

- 从 diff / 方案推导出的行为变化
- 单测 / E2E / smoke / 手动验证
- 缺失用例
- 建议命令或操作步骤

### Code Review

```text
按 playbook review 我当前改动。
```

AI 应该输出：

- 按严重程度排序的问题
- 文件和位置
- 为什么是风险
- 建议修复
- 剩余测试缺口

### 发布检查

```text
按 playbook 帮我做发布前检查。
```

AI 应该输出：

- Go / No-Go
- 分支、工作区、migration、env、targets、备份、回滚、健康检查
- 阻塞项和建议发布命令

## 什么时候才需要安装 skills

只有当你希望 AI 工具自动发现这些技能时，才运行：

```bash
bash scripts/install-skills.sh
```

否则不需要。

默认安装到 `~/.codex/skills`。如果要安装到其他工具：

```bash
bash scripts/install-skills.sh --target claude
bash scripts/install-skills.sh --target cursor
AI_CODING_SKILLS_DIR=/path/to/skills bash scripts/install-skills.sh
```

### Skill 维护

```text
参考 playbook，帮我把这段 prompt 沉淀成一个 Codex skill。
```

AI 应该输出或落地：

- skill 触发边界
- `SKILL.md` frontmatter 和正文
- 是否需要拆 `references/`
- 需要同步更新的路由、自检脚本和文档

### 项目图表和文档

```text
参考 playbook，根据当前项目画一张模块架构图。
```

AI 应该先读项目事实，再输出 Mermaid 图、证据来源和待确认项。

## 和业务项目的关系

- playbook 负责通用方法论。
- 业务项目负责事实：端口、命令、域名、数据库名、发布脚本、模块结构。
- AI 回答时应先读业务项目事实，再套用 playbook 的思考框架。

## 内化为 Codex Skill

已经可以用“薄 skill + 活规则目录”的方式接入：

- 仓库来源：`skills/ai-coding-playbook/SKILL.md`
- 安装后位置：`/Users/xiaohong.zhxh/.codex/skills/ai-coding-playbook/SKILL.md`
- 活规则位置：`/Users/xiaohong.zhxh/projectInfo/luseek/ai-coding-playbook`

这个 skill 只负责触发和路由，不复制规则内容。真正的规则仍在 playbook 目录里。

轻量触发边界：

- 研发方案、实现、测试、Review、发布、排障会触发。
- 简单命令输出、纯事实问答、闲聊、翻译润色默认不触发，除非内容本身是研发规则、方案或代码 Review。

因此后续维护方式是：

1. 修改 `ai-coding-playbook` 下的规则文件。
2. 不需要同步 skill。
3. 下次对话触发 `ai-coding-playbook` skill 时，AI 会重新读取最新规则。

只有当你想修改“触发范围”本身，比如新增一种请求也要自动触发 playbook，才需要改 `skills/ai-coding-playbook/SKILL.md` 的 description，然后重新运行安装脚本或保持软链接安装。
