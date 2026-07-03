---
name: skill-prompt-convert
description: Convert between prompts, AGENTS or CLAUDE rules, and SKILL.md files. Use when users ask to turn a prompt into a skill, convert a skill into a reusable chat prompt, extract skill rules from agent instructions, or normalize skill format.
---

# Skill Prompt Convert

## 使用时机

- Prompt 转 `SKILL.md`。
- `SKILL.md` 转聊天框可用 Prompt。
- 从 `AGENTS.md` / `CLAUDE.md` / 规则文档中提炼可复用 skill。
- 检查并修正 skill frontmatter、命名、触发描述和正文结构。

## 转换方向

| 输入 | 输出 | 重点 |
| --- | --- | --- |
| Prompt | `SKILL.md` | 提炼触发场景、执行步骤、输出格式 |
| `SKILL.md` | Prompt | 保留角色、任务、约束和工作流 |
| Agent 规则 | `SKILL.md` | 只抽跨项目可复用规则，剔除项目事实 |
| `SKILL.md` 草稿 | 标准化 skill | 修正 frontmatter、边界、结构和冗余 |

## 转换流程

1. 识别输入类型和目标格式；用户未说明时，从上下文推断。
2. 提取核心信息：
   - 任务目标。
   - 触发场景和关键词。
   - 必读材料或参考文件。
   - 执行步骤。
   - 输出格式。
   - 禁止事项和安全边界。
3. 生成目标格式：
   - Skill 必须包含 YAML frontmatter：`name`、`description`。
   - Prompt 应包含 Role / Task / Workflow / Constraints / Output Format。
4. 做信息完整性检查，确认没有丢失核心约束。
5. 如果目标是本仓库 skill，按 `skill-maintenance` 的流程同步路由和自检。

## 命名规则

- `name` 使用英文小写、数字和短横线。
- 名称表达能力边界，不使用泛词，例如 `helper`、`workflow`。
- `description` 要包含触发词和用途，不只写功能名。

## 输出

```markdown
## 转换说明

## 转换结果

## 需要人工确认
```
