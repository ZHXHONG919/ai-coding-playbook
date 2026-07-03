---
name: ai-coding-playbook
description: >
  Shared AI coding playbook for natural-language engineering commands such as 梳理需求,
  确认需求, 做方案, 写方案, 做 UI Flow, 做原型, 拆任务, 执行任务, 开始实现,
  继续 Goal, 续跑, 做 CR, review, 测试范围, 发布检查, and 排查问题.
  Covers requirement analysis, feature planning, technical design, implementation breakdown,
  code review, test scope, release safety, bug investigation,
  and NestJS/React/PostgreSQL/Chrome Extension/AI provider guidance.
  Use when the user is doing engineering planning, implementation, tests, review, release, or troubleshooting.
  Do not use for simple command output, pure factual Q&A, casual chat, or ordinary translation unless
  the content itself is about engineering rules, plans, or review.
---

# AI Coding Playbook

This is a thin routing skill. Rule bodies live in the playbook repository, not in this file.

## Playbook Root

Resolve the live rules directory before reading files:

1. Resolve the real path of this `SKILL.md`.
2. Walk up parent directories until you find a directory that contains both `AGENTS.md` and a `skills/` subdirectory.
3. That directory is `<playbook-root>`.
4. Entry routing table: `<playbook-root>/AGENTS.md`.

This works for direct symlinks to `skills/ai-coding-playbook/` and for platform build installs under `platforms/.build/`.

## Do Not Use For

- Simple command output.
- Pure factual Q&A.
- Casual chat or non-engineering questions.
- Ordinary translation, polishing, or formatting, unless the content itself is an engineering rule, plan, review, or skill.

## Default Flow

1. Resolve playbook root and read `<playbook-root>/AGENTS.md`.
2. Identify the target business project, if any.
3. If there is a target project, read its `README.md`, `AGENTS.md`, `CLAUDE.md`, and relevant docs first.
4. Follow the stage routing table in `AGENTS.md`; read only the referenced `references/*` or `skills/*` files needed for this request.
5. Prefer target project facts over playbook defaults. If they conflict, follow the project docs and briefly state the conflict.
6. Produce the requested output directly. Do not ask the user to install skills, copy templates, or initialize unless they explicitly ask.

## Observable Behavior

After triggering, say one short line naming the phase, for example:

- "我按 ai-coding-playbook 进入方案阶段，先不改代码。"
- "我按 ai-coding-playbook 做测试范围分析。"
- "我按 ai-coding-playbook 做 Review，先列风险。"

## Phase Control

Technical plans and feature designs are plan-phase work by default. Do not edit code in plan phase.

- "写方案 / 设计一下 / 先讨论 / 先别写代码": stay in exploration or planning.
- "同意方案 / 按这个落地 / 开始实现 / 执行": enter implementation.
- Complex requirements must pass requirement confirmation before planning.
- If implementation reveals a design problem, pause and return to plan phase.

## Routing Source

Do not rely on a partial route list in this file. Always use the full routing table in `<playbook-root>/AGENTS.md`.
