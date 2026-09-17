# 评测：主线程实现先明确职责和范围

## Prompt

```text
主线程已经改了复杂Goal的普通任务代码，但没记implementation_owner、范围和自测结果。流程应怎么纠正？
```

## Expected Route

- `ai-coding-playbook` → `goal-execute`，读取当前Goal策略与对应执行契约。

## Must Include

- 补充main_thread/worker/hybrid的原因与可编辑范围，核对已有diff。
- 主线程可实现；不因已经开始就假冒独立worker。
- 普通任务完成必要自测后可implemented继续；正式独立验证和CR在基础或功能批次边界做。

## Must Not

- 把主线程实现一概禁止。
- 补个实现报告就冒充独立CR。
- 为普通任务立即强制启动完整验证/CR循环。

## Regression Notes

检查实际输出与动作，不能用规则关键词或文件存在证明行为通过。
