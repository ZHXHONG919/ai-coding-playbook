# Profile: AI Media Pipeline

适用项目画像：

- 文生图 / 图生图 / 视频 / TTS / Agent workflow
- 多 provider fallback
- OSS / 对象存储
- 异步 job / consumer
- 有成本和 quota 风险

## AI 默认判断

- 真实 provider 调用前优先 mock smoke。
- 真实 smoke 用最小 case，并说明成本风险。
- fallback chain 要明确顺序、重试次数、是否允许降级。
- 每次 provider 调用应记录 request id / model / latency / cost / error。
- 失败状态必须可恢复或可重试，不应静默丢任务。
- 并发上限要由配置控制，避免瞬时打爆 quota。
