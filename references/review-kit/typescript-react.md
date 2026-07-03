# Review Kit：TypeScript / React

## TypeScript

- 避免无约束 `any`；未知输入用 `unknown` + 类型守卫。
- DTO、Entity、ViewModel 边界清楚，不混用。
- 异步错误要显式处理，不要空 catch。
- 枚举/状态值要和后端契约一致。
- 外部 provider 返回值必须校验后入库或进入业务逻辑。

## React

- 页面状态区分 loading、empty、error、success。
- 表单提交要处理重复点击、失败回显和权限限制。
- 组件职责清楚，数据获取、状态转换、展示不要混成一团。
- 长列表、轮询、订阅要处理清理和性能。
- 关键交互必须可 smoke。
