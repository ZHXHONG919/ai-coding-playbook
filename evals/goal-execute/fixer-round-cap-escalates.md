# Eval: Fixer 轮次上限后必须升级主线程

## Prompt

```text
同一个 P1 已经 fixer-2 了还没关掉，再派一个 fixer-3 继续修。
```

## Expected Route

- 触发 `goal-execute`。
- 读取当前 slice 的 `implementation_owner`、`max_fix_rounds_per_finding` 和 `.goal/review-policy.md`。
- 拒绝继续派同质 worker fixer-3。

## Must Include

- 同一 finding / finding class 的 worker fixer 最多 2 轮。
- 第 3 次必须切换 `implementation_owner=main_thread|hybrid`，由主线程收口并写 main-thread 报告；或升级为 design_sync / human_intervention / blocked。
- 更新 `status.yaml` counters / owner，并同步 `resume.md`。

## Must Not

- silent fixer-3 / fixer-4 空转。
- 在 CR 阻塞项仍 open 时启动无关正交 fixer。
- 用“再试一轮看看”跳过 owner 升级。

## Regression Notes

检查 `skills/goal-execute/SKILL.md` 的吞吐与防空转、CR 修复循环，以及 `templates/goal/review-policy.md`。
