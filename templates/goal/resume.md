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
1. Read .goal/status.yaml.
2. Read .goal/slices.yaml[next_slice or current_slice].
3. Read this file.
4. Read latest worker report in `.goal/runs/` for current slice.
5. Read latest validation report in `.goal/validation/` for current slice.
6. Read latest CR report in `.goal/cr/` for current slice.
7. Run git status and git log.
8. If current_slice has uncommitted changes, continue that slice.
9. If previous slice reached safe commit boundary, continue next_slice.
```

## Current Snapshot

| Field | Value |
| --- | --- |
| Branch | |
| Current slice | |
| Next slice | |
| Last commit | |
| Worktree status | |
| Last tests | |
| Last worker report | |
| Last validation report | |
| Last CR | |
| Open findings | |
| Open human intervention | |

## Notes

- Do not commit half-finished work because of context pressure.
- Commit only after implementation, validation, CR findings closure, and status update.
- Worker or validator summaries are supporting evidence, not the source of truth.
