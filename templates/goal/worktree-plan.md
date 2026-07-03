# Worktree Plan

> 目标：只让无共享写冲突的任务并行开发，避免多个 worker 同时修改共享契约。

## Policy

- Main agent owns merge order, final integration, `.goal/status.yaml`, and commits.
- Workers may not merge worktrees or commit unless the project explicitly authorizes it.
- Shared DTO / Entity / migration / status enum / core service changes return to main agent.

## Parallel Groups

| Group | Worktree Allowed | Slices / Tasks | Ownership | Merge Order | Conflict Policy | Status |
| --- | --- | --- | --- | --- | --- | --- |
| P1 | yes / no | | | | shared contract conflicts return to main | planned |

## Active Worktrees

| Worker ID | Slice | Path | Ownership | State | Report |
| --- | --- | --- | --- | --- | --- |
| | | | | active / merged / blocked | |

## Merge Log

| Slice | Worker ID | Merged By | Validation After Merge | CR After Merge | Notes |
| --- | --- | --- | --- | --- | --- |
| | | main agent | pending | pending | |
