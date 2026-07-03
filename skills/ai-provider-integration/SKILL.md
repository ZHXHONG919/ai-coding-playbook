---
name: ai-provider-integration
description: Design or review AI provider integrations, fallback chains, cost guards, retries, and smoke tests.
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

- 做方案或链路设计时，先读取 `references/stages/plan.md`、`references/plan/*`。
- 涉及生图、生文、生视频、笔记草稿、媒体产物或审核发布链路时，必须读取 `references/scenarios/ai-media-pipeline.md`。
- 涉及 LLM 分析、样本学习、批量归纳或结构化输出时，必须读取 `references/scenarios/llm-analysis.md`。
- 方案必须区分需求、任务、产物、审核和发布/同步；任务状态和产物状态不要混为一个字段。

## 验证顺序

1. 单元测试 provider client 的参数组装和错误分类。
2. mock smoke 跑完整 workflow。
3. 真实 provider 最小 case，说明成本风险。
4. 检查日志、DB 状态、产物存储。
