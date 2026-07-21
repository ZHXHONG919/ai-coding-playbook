# Human Intervention

> 目标：登记 agent 无法独立解决、必须人类介入的问题。这里不是普通 TODO，也不是 Deferred 垃圾场。

## Open Items

No open human intervention items.

## Item Template

```yaml
id: HI-R01-001
source_slice: R01
source_cr: ".goal/cr/R01-round-2.md"
reason: "<why agent cannot resolve independently>"
user_visible_impact: "<what user or release owner should know>"
code_stub: "<file:line or module containing TODO(human-intervention:R01)>"
required_human_action: "<exact human action needed>"
status: open
```

## Rules

- All agent-solvable blocking findings must be fixed. P2/Nit can be non-blocking follow-up only when they do not affect correctness, data, security, release, or primary user paths.
- Code TODO must use `TODO(human-intervention:<slice>)` and explain the reason.
- `status.yaml.counters.open_human_intervention` must match this file.
- A Goal with open Human Intervention items cannot be `complete`; final state is `needs_human_intervention`.
