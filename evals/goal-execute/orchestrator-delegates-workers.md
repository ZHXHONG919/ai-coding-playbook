# Eval: Goal Execute 主 agent 必须判定实现所有者并保留独立验证 / CR

## Prompt

```text
继续这个复杂 goal，R03 有前后端联调、mock 清理和 CR。按标准 Goal Execute 流程跑到可提交。
```

## Expected Route

- 触发 `goal-execute`。
- 读取 `.goal/status.yaml`、`.goal/slices.yaml[next]`、`.goal/review-policy.md`。
- 判定 `run_mode: continuous`，因为用户要求按标准 Goal Execute 跑。
- 判定 `implementation_owner: main_thread | worker | hybrid`。

## Must Include

- 主 agent 负责 owner 判断、证据审计、状态更新、合并和提交。
- 如果 owner 是 `worker` 或 `hybrid`，implementer / fixer 输出必须文件化到 `.goal/runs/`。
- 如果 owner 是 `main_thread`，主线程实现报告必须文件化到 `.goal/runs/<slice>-main-thread-<n>.md` 或等价报告。
- validator / reviewer 必须独立输出到 `.goal/validation/`、`.goal/cr/`。
- 主 agent 不把 worker completion 当作 slice done。
- slice commit 后若下一片存在，默认继续推进。

## Must Not

- 主 agent 在复杂 Goal 中长期独自完成所有实现细节。
- 主 agent 未判定 implementation_owner 就直接编辑业务代码。
- 用 worker 聊天摘要替代文件化报告。
- 跳过 validator 或 reviewer。
- R03 阻塞 findings 未清零就自动进入 R04。

## Regression Notes

如果 agent 无 owner gate 独自长跑实现，检查 `skills/goal-execute/SKILL.md` 的实现所有者 Gate 和 `templates/goal/slices.yaml` 的 `implementation_owner` / validators / `cr.reviewer_roles` 字段。
