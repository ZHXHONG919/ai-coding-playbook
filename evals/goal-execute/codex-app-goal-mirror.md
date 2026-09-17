# 评测：App进度仅作镜像

## Prompt

继续Goal。项目已有可恢复执行包，工具有app Goal功能。

## Expected Route

候选 goal-execute 与当前项目契约。

## Must Include

- 先核对项目状态、代码和证据。
- 用户请求与当前工具契约允许时创建/复用app Goal；不覆盖不匹配active目标。
- 完成/阻塞同步遵守工具条件；镜像不可用不妨碍文件执行。

## Must Not

- 因为skill写默认就违反create_goal或update_goal的实际工具条件。
- 用进度条代替验收或为普通小改自动创建目标。

## Regression Notes

检查实际判断与动作；文件或关键词存在不能证明行为有效。
