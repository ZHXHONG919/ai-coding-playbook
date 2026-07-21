# Resume

> 目标：上下文压缩后在当前线程恢复执行。不主动新开替代线程。

## Policy

- New thread allowed: no
- Controlled worker subagents allowed: yes
- Checkpoint commit allowed: no
- Resume source of truth: `.goal/status.yaml`
- Supporting evidence: `.goal/runs/`、`.goal/validation/`、`.goal/cr/`

## Resume Steps

```text
1. Read .goal/status.yaml (source of truth).
2. Read this Current Snapshot; if it disagrees with status.yaml, rewrite this file immediately.
3. Read .goal/slices.yaml[current_slice or next_slice] only.
4. Read latest current-slice reports in `.goal/runs/`, `.goal/validation/`, `.goal/cr/`.
5. Read only the slice `required_docs` that are needed for the next action.
6. Run git status and git log.
7. If requirement_delta.pending, freeze orthogonal fixers and sync docs before more code.
8. If current_slice has uncommitted changes, continue that slice.
9. If previous slice reached safe commit boundary, continue next_slice.
```

## Current Snapshot

| Field | Value |
| --- | --- |
| Branch | |
| Current slice | |
| Next slice | |
| Execution state | |
| Implementation owner | |
| Last commit | |
| Worktree status | |
| Last tests | |
| Last implementation report | |
| Last validation report | |
| Last CR | |
| Open blocking findings | |
| Non-blocking follow-ups | |
| Worker fixer rounds | |
| Requirement delta pending | |
| Open human intervention | |

## Notes

- Do not commit half-finished work because of context pressure.
- Commit only after implementation, validation, CR blocking findings closure, and status update.
- Sync this snapshot after every implementer / fixer / validator / reviewer step.
- Implementation or validator summaries are supporting evidence, not the source of truth.
- Do not reread the entire Goal package on every resume; prefer status + current slice + latest reports.
