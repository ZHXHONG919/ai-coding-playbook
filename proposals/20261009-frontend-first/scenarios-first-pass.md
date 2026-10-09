# 候选规则批量场景推演原始回答

本文件是同一 Agent 未读取答案的批量场景推演，只提供计划，不执行真实开发或业务操作，也不验证成本效果。仅主动读取下列候选文件；未读取 expected.json、其他案例、补丁、审查记录或已发布根目录规则；未修改规则、Git 或安装状态。

## 21-frontend-group-sequence

我按实现阶段安排：先复用已确认领域职责，为 A、B 补齐请求/响应字段、校验、错误、权限和分页契约及页面映射；再按功能组在 API 边界模拟，正式页面走正常请求入口。首个代表界面对照原型后，补齐本组全部约定交互和状态，不把列表展示当作完整体验。
A 的查询、编辑、校验、保存、删除及全部已约定状态均可操作、自测通过后，即可正式实现 A 服务端；无须等 B，也不新增用户确认或固定 CR。
在给定截点：执行者一按领域能力实现 A 后端，能力具备即替换对应模拟，尽早校准首条真实路径；执行者二继续 B 的筛选、分页、详情及异常状态，完整自测通过后再推进 B 后端。共享契约与运行资源由明确负责人收口。
A 的模拟自测只证明前端体验；真实权限、持久化、保存/删除副作用及再次读取尚未验收。B 的完整前端及真实能力均未验收。各组形成真实完整使用过程后，固定范围合并独立验收与 CR；最终核对两组全部约定及最后增量，必要缺口关闭才可整体完成。

## 22-server-domain-boundaries

我按实现阶段安排两条用户路径及一项共享基础：申请人提交/撤回，管理员确认/拒绝；共享基础为预约迁移的并发正确性与确认幂等性。
先把新规则映射到 ReservationService，补齐状态、副作用和冲突响应契约，失败方收到当前状态。PermissionService 继续负责身份权限；现有控制器处理协议，预约服务统一执行状态判断、迁移及资源占用。共享契约和状态实现由一人收口，页面执行者负责各自完整交互与集成。
新规则可在前端完成前做最小真实基础实现及定向独立验证、CR：经真实入口重复确认，读取同一存储确认只占用一次；并发撤回/确认仅一个合法迁移成功，失败响应反映当前状态。它必须在真实消费者依赖前通过；已明确并经必要核验的协议可支持前端模拟，无依赖界面工作继续。
两组各自完成原型规定的全部模拟交互和状态、自测通过，再推进对应常规后端能力，逐项替换模拟；不借共享核验提前展开全部后端。接通后按两角色连续操作合批验收与 CR，核对真实权限、状态、资源及返回，缺口关闭才完成。
不采用按页面各建服务并复制状态判断：两条路径必须共用同一规则。不采用通用审批引擎：当前单体模块足够，没有通用复用需求；职责清楚即可，无须新增分层框架。

## 23-probe-and-mock-replacement

第一项先做有限技术探针：在测试环境用无敏感文件，观测取消请求、实际任务状态及回调，回答取消成功后是否仍有完成回调、乱序或重复，以及应用如何保持取消终态。预先限定样本、调用范围和停止条件；证据足以确定接口与回调处理即可停止，未收到回调不能证明永远不会收到。未知仍未解决则保留缺口，只继续不依赖它的工作，不用假响应固化状态语义，不展开全部正式后端。
收口状态与错误契约，必要基础在被真实依赖前定向独立核验；前端补全上传校验、进度、重试、取消、下载及相关状态，实际操作自测通过后，再按领域能力实现后端。每项能力就绪即在原请求入口替换模拟、校准首条真实路径，不等全部后端完成。模拟范围、替换点、清理条件记在现有记录，生产禁用成功替身；契约变化同步各消费者并复查。
第二项直接复用真实查询契约实现筛选，无须新建模拟阶段；用含多种状态的数据从页面检查请求参数、筛选结果、分页及原权限约束。
完成证据须含运行页面交互、真实接口与同存储读回、取消与迟到回调竞争时仍不可下载、真实供应方转换和下载路径，以及适用的独立验收、CR和最终差异覆盖。探针只证明有限样本，模拟只证明体验，构建只证明可构建；目前无真实调用和端到端结果，两项均不能因本计划宣称完成，也不能推断生产可靠性或成本改善。

## 实际读取文件列表

以下为去重清单；其中 agent-delivery-flow.md 和 task-breakdown.md 的被截断部分做过补读。

- `<candidate>/skills/ai-coding-playbook/SKILL.md`
- `<candidate>/evals/delivery-behavior/21-frontend-group-sequence/input.md`
- `<candidate>/evals/delivery-behavior/22-server-domain-boundaries/input.md`
- `<candidate>/evals/delivery-behavior/23-probe-and-mock-replacement/input.md`
- `<candidate>/AGENTS.md`
- `<candidate>/references/stages/implementation.md`
- `<candidate>/references/git-safety.md`
- `<candidate>/references/plan/task-breakdown.md`
- `<candidate>/references/delivery/agent-delivery-flow.md`
- `<candidate>/references/stages/review.md`
- `<candidate>/references/plan/role-lens.md`
- `<candidate>/references/plan/domain-design.md`
- `<candidate>/skills/test-scope-analysis/SKILL.md`
- `<candidate>/references/delivery/evidence-driven-delivery.md`
