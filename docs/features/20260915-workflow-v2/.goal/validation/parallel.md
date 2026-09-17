# D10 实现与验证记录

2026-09-17，仅候选工作树。输入为 plan.md D10；输出对应 snapshots/parallel-B01.json、parallel-B02.json、parallel-final.json。主线程实现检查器与规则，workflow_architecture_discuss 独立负责测试文件和定向执行，parallel_contract_review 只读审查，主线程统一执行全量检查并裁决。

## 实现与自测

- R01：沿 current_slice / active_workers 表达跨任务并行，校验 owner、running/stale 与任务状态、范围冲突、single_slice 和完成边界；原依赖检查保持严格。19 个新回归含独立任务、同任务多 worker、无焦点协调、失联回收、部分实现恢复及错误启动负例。
- R02：恢复必读 resume 及活动 worker 对应任务；任务状态负责进展，worker 登记负责未交回写权限。暂停半成品如实记 awaiting_revalidation，查实停止后可释放 worker，前置恢复才继续。
- R03：同步状态/恢复/worktree 模板、中央交接/任务拆解/handoff 与恢复 eval。静态核对调用方，无“全部 stale 可跳依赖”的残留规则；新增恢复场景已准备，未运行 Agent 行为试验。
- R99：检查本轮 15 个来源/契约变化与独立报告版本，未变范围复用原证据；最终状态检查结果另见 parallel-goal-final.log。

## 实际验证

| 执行 | 结果 | 原始证据 |
| --- | --- | --- |
| 新增定向测试，测试 Agent 运行 | 19 项、103 断言，0 失败/错误/跳过 | parallel-focused-final.log |
| bash scripts/check-playbook.sh --repo-only，主线程运行 | 68 项、256 断言，0 失败/错误/跳过；模板/仓库结构通过 | parallel-structure.log |
| 行为样例格式检查 | 14 组结构通过，没有运行 Agent | 同上 |
| git diff --check | 通过 | 本次工具输出 |
| 原 checkout / 安装来源只读检查 | main，HEAD 8b59b6a2bfa41686128480fde3873cf122dee81b，工作区干净；两平台链接仍指向原 checkout | 本次工具输出 |

初始反例 2 项/20 断言中 1 失败，见 parallel-stale-initial.log；中间特殊放行设计 19 项/92 断言通过，见 parallel-focused.log，但后续完整生命周期分析推翻了该设计。最终用例和结果以上表为准，不能把中间通过当作最终依据。

## 限制

脚本核验状态、声明范围和证据引用，不能发现所有实际越界写入或判断报告语义。恢复规则经过定向审查，未模拟真实进程断联；尚未开始业务大需求，没有本轮完整耗时/token 或真实效率对照。候选未安装、推送、合并或发布到 Codex/Cursor。
