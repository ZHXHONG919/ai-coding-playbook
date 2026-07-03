# Claude Code 使用说明

> 与 Codex、Cursor 共用同一份 playbook 源；安装目标不同。

## 安装

```bash
cd /path/to/ai-coding-playbook
bash scripts/install-skills.sh --target claude
```

目标目录：`~/.claude/skills/`。旧副本用 `--force` 覆盖。

## 分工

- **Skills**：`~/.claude/skills/` 软链自本仓库。
- **项目规则**：业务项目 `AGENTS.md`、`CLAUDE.md`。
- **活规则**：`references/`，由 skill 按需读取。

维护方式见 `docs/codex-usage.md` 与 `skills/skill-maintenance/SKILL.md`。
