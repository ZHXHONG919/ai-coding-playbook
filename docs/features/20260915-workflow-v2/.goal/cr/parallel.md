# D10 独立定向审查与最终裁决

2026-09-17，候选 codex/workflow-v2。主线程据 parallel_contract_review 的实际消息整理；审查者只读，不是检查器或测试实现者。本轮复用此前讨论上下文，不能称冷启动盲审。

## 范围与发现

初次阅读检查器、并行测试、goal-execute、status/resume/worktree 模板、task-breakdown、goal-handoff 与中央流程。恢复入口、跨任务映射、写范围冲突、单片限制及旧串行兼容一致；临时 Git 夹具复现上游失效后，失联半成品既不能合法保留 in_progress，又没有完整自测可供旧定义的 awaiting_revalidation 使用。

首次尝试限定“非焦点且全部 worker stale”保留 in_progress；进一步检查交回终态发现，它不能在依赖未恢复时如实释放已停止 worker。主线程撤回特殊依赖放行，统一 awaiting_revalidation 为已有全部/部分改动暂停待恢复，必须保存真实记录，不能声称实现完成或自测通过。running 和主线程接管仍按原依赖检查。

## 最终独立结论

审查者核对下列当前版本，读了两个完整生命周期测试但未执行测试：无残留阻塞问题；部分实现记录→stale 保留范围→查实停止释放→等待前置→重新 in_progress→补完自测→implemented 表达完整。恢复入口读取 resume 和活动执行者，stale 不再特殊放行。

| SHA256 | 实际读取文件（仓库相对路径） |
| --- | --- |
| `45772928c65a6d720ead9451bd567e08f7beb7cdcae859dc2bf1a3066748ab21` | `scripts/check-goal.rb` |
| `5cf0815974eef8fd919c4b5136f22983c4fdb3d54d02a4da32f5a3011e173d09` | `scripts/test-check-goal.rb` |
| `44b2b98d60218646e9f352bb83dddb3262dedafecdd1f05cb9ae99c580e2f26c` | `skills/goal-execute/SKILL.md` |
| `4978ee27db26c00a56de64d3dfbd0a56f9d2190bbcde4ff278f65b3d88863907` | `templates/goal/status.yaml` |
| `0ea32430364d5f321b99eacb73661abb4051361c5357274de8a56ead709a7254` | `references/stages/goal-handoff.md` |
| `3fb1aa02c77234dfa849ad3285249eb19b63f5f900563ee10ac2549efe41c718` | `evals/workflow-v2/checker.md` |
| `289ebe7b5ccad73a8d4e9611f7aa20dc2316b633a0ac52188325b281e6c1a05e` | `evals/goal-execute/resume-from-status.md` |

## 主线程最终覆盖

本轮相对 autonomy-final 的 15 个来源/契约变化见 validation/parallel-delta.json。上述独立复核覆盖核心代码及修订语义；模板恢复/worktree、中央交接和任务拆解已在首轮审查覆盖，主线程核对调用关系与最终版本，其余四个本次 Goal 契约仅同步 D10。历史未变范围复用 autonomy-final 与更早实际证据，本轮范围绑定 snapshots/parallel-B01.json、parallel-B02.json、parallel-final.json。

A01：新独立反例与全套脚本通过；A02：调用方和中文规则一致，新增恢复场景仅准备，未声称执行该场景；A03：原 main 和安装来源未变，最终差异与历史证据覆盖已核对。当前无阻塞发现。结论不证明真实大需求效率或交付缺陷改善。
