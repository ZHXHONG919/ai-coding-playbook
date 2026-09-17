---
name: ai-provider-integration
description: 设计或审查 AI 提供方集成、降级链、成本保护、重试和冒烟验证。
---

# AI Provider Integration

## 使用时机

- 设计或评审 AI provider client、模型调用、fallback、retry、timeout、成本保护或 smoke。
- 设计生图、生文、生视频、结构化分析、媒体产物生成等 AI 链路。
- 排查 provider 错误分类、任务恢复、日志观测或最小真实调用验证。

## 非适用场景

- 只是在写普通 prompt 文案，不涉及工程链路、provider 契约或成本风险。
- 只需要生成图片、视频、文案或笔记成品，优先使用具体生成工具或业务 CLI。
- 只是在总结 AI 行业信息或模型能力，除非要落到当前项目集成方案。

## 设计检查

- Provider 凭据来自 env/config，不写入代码。
- 支持 mock 模式，方便本地和 CI 验证。
- timeout 明确，不能无限等待。
- retry 有次数和退避，不对不可重试错误盲目重试。
- fallback chain 顺序清楚，记录实际命中的 provider。
- 成本和 quota 有上限保护。
- 日志记录 request id、model、latency、error category，但不记录敏感 prompt 或凭据。
- 失败状态可恢复：job 状态、错误原因、重试入口。

## 配套规则

- 做方案或链路设计时，先读取 `references/stages/plan.md`，按实际风险选择相关方案规则。
- 涉及生图、生文、生视频、笔记草稿、媒体产物或审核发布链路时，必须读取 `references/scenarios/ai-media-pipeline.md`。
- 涉及 LLM 分析、样本学习、批量归纳或结构化输出时，必须读取 `references/scenarios/llm-analysis.md`。
- 方案必须区分需求、任务、产物、审核和发布/同步；任务状态和产物状态不要混为一个字段。

## 按本次行为选择验证

- 参数组装、错误分类或降级变更，先通过真实应用入口观察请求和最终状态，复用相关测试；外部供应方可按固定输入/输出替换，不在替身里重写业务判断。
- 验证本地或跳过模式的合法结束路径，不因没有模型调用就误判失败；也不能以降级成功证明真实模型效果。
- 只有本次验收要求且已有授权时才做真实 provider 最小调用，明确成本与证明范围；不自动调用付费模型，不因暂未调用就伪称生成质量通过。
- 从被测应用写入的数据读回结果和产物。若真实检索/模型生成属于本次承诺而未验证，保留未验收状态，不能移到未来发布。
