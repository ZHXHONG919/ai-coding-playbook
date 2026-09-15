---
name: skill-maintenance
description: 创建、更新、审查或整理 Codex、Cursor 和 Claude Code 的 Agent Skill 与 playbook 规则。适用于新增 Skill、修改 SKILL.md、优化触发描述、拆分参考规则、审查触发边界和维护共享约定。
---

# Skill Maintenance

## 使用时机

- 新增、修改、合并或删除 `skills/*/SKILL.md`。
- 评审 skill 是否合理、是否该拆分 reference、是否触发过宽或过窄。
- 把跨项目经验沉淀为可复用 skill。
- 维护 Codex / Cursor / Claude Code 的安装与平台差异。

## 核心原则

- Skill 只放可跨项目复用的工作流、判断标准和输出要求。
- 业务事实、端口、凭据、发布机、客户信息留在业务项目文档中。
- `description` 是触发入口，必须写清「什么时候用」和「用来做什么」。
- `SKILL.md` 保持轻量；细节很多时拆到同目录 `references/`，由正文说明何时读取。
- 不为凑数创建 skill；只有触发场景稳定、可重复使用、与现有 skill 边界清晰时才新增。
- 阶段路由以 `AGENTS.md` 为唯一完整路由表；入口 skill 不维护一份过时副本。
- 修改 skill description、阶段路由或输出门禁时，补充 `evals/` 回归样例。
- 面向人阅读的标题、流程、判断条件、示例和 `description` 默认使用中文；非必要不混用英文。Skill 名称、目录名、代码标识、命令、文件路径、协议和稳定的 YAML/JSON 字段保留原值。
- 必须使用英文术语时，首次出现先用中文说明，再在括号中给出英文名或代码值；后文优先使用中文。不要为了翻译破坏脚本读取的枚举、字段和兼容契约。

## 资产分层

| 层级 | 位置 | 维护内容 |
| --- | --- | --- |
| 活规则 | `references/` | 阶段、门禁、review-kit、场景 |
| 通用 skill | `skills/` | 跨项目工作流正文（工具无关） |
| 平台差异 | `platforms/<tool>/overlays/` | 仅 frontmatter：description、触发词 |
| 回归样例 | `evals/` | 路由、输出门禁、禁止行为的可复查样例 |
| 业务事实 | 业务项目 | `AGENTS.md`、`.cursor/rules/`、发布 SOP |

## 多工具分工

### Skills（全局、按需）

- 安装到 `~/.codex/skills`、`~/.cursor/skills`、`~/.claude/skills`。
- 通过 `bash scripts/install-skills.sh --target <tool>` 软链生效。
- 有 overlay 的 skill（如 `ai-coding-playbook`）安装到 `platforms/.build/<tool>/`。

### Rules（项目或用户常驻）

- **Cursor**：User Rules + 项目 `.cursor/rules/*.mdc` + `AGENTS.md`。
- **Codex / Claude Code**：项目 `AGENTS.md`、`CLAUDE.md`。
- playbook 只提供 `agents/` 模板，不维护业务项目 Rule 实例。
- 不要把整份 `AGENTS.md` 路由表或 `references/` 塞进 User Rules。

详见 `docs/cursor-usage.md`、`docs/codex-usage.md`。

## 新增或修改流程

1. 先读本仓库 `AGENTS.md`、`README.md` 和已有相近 skill。
2. 判断是增强已有 skill，还是新增独立 skill。
3. 定义触发边界：关键词、适用场景、非适用场景。
4. 编写或更新 `skills/<name>/SKILL.md`：
   - YAML frontmatter：`name`、`description`。
   - `name` 使用小写字母、数字和短横线。
   - 正文包含使用时机、执行步骤、输出要求、注意事项。
   - 使用 playbook root 相对解析，不写用户机器绝对路径。
5. 若 Codex / Cursor / Claude 的触发描述不同，只改 `platforms/<tool>/overlays/<name>.md`。
6. 更新路由文档：
   - `AGENTS.md` 阶段路由。
   - `README.md` skill 列表。
   - `docs/adoption-guide.md` 或工具用法文档，仅当使用方式变化。
7. 若改动影响触发或输出门禁，新增或更新 `evals/` 样例。
8. 更新 `scripts/check-playbook.sh` 的必需文件列表。
9. 运行 `bash scripts/check-playbook.sh`。
10. 运行 `bash scripts/install-skills.sh --target codex --force` 和 `--target cursor --force`（按需）。

## Review Checklist

- 触发描述是否能被 Agent 自动识别。
- 是否和已有 skill 重复；如重复，优先合并。
- 是否混入单项目事实或敏感信息。
- 是否有清晰输出格式。
- 是否要求默认落盘；除非用户明确要求，否则不要强制写文件。
- 是否需要 reference 分层；超过一屏的细节优先拆分。
- 是否有 eval 覆盖关键触发、输出门禁和禁止行为。
- `AGENTS.md` 路由是否已同步。
- 各平台 overlay 是否仍然必要。

## 输出

- 变更范围。
- 新增或调整的触发边界。
- 需要同步更新的文档、overlay 和安装命令。
- 未覆盖的风险或后续建议。
