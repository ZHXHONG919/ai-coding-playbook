# 最终证据确认 <slice-id> <n>

> 用于首轮代码审查零阻塞，或阻塞修复完成后的限定范围证据确认；不重复完整代码审查。

- 切片：`<slice-id>`
- 证据确认审查者：`<reviewer-id>`
- 是否为原审查者：yes / no
- 替换原因：`<原审查者不可恢复时，记录同职责且独立于实现者的替代依据>`
- 关联代码审查：`.goal/cr/<slice-id>-round-<n>.md`
- 关联验证报告：`.goal/validation/<slice-id>-<kind>-<n>.md`
- 确认时间：`<YYYY-MM-DD>`

## 基线与证据

| 验收项 | 期望基线 | 最终证据 | 结论 |
| --- | --- | --- | --- |
| | | | Passed / Blocking |

## 确认范围

- 是否只确认最终证据与验收映射：yes / no
- 关联代码审查后的运行时代码是否变化：yes / no
- 差异或提交证据：`<git diff / commit>`
- 运行时代码变化时的新限定范围代码审查：`.goal/cr/<slice>-round-<n>.md` / not-applicable
- 是否发现需要重新打开完整代码审查的新代码问题：yes / no
- E2/E3 是否保留等价运行态或视觉证据：yes / no / not-applicable

## 结论

- 结果：Passed / Blocking
- 代码门禁：code_unchanged / new_cr_present / Blocking
- 阻塞原因：
- 下一步：Exit / reopen CR / human intervention
