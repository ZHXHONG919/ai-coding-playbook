#!/usr/bin/env node
// 仅调度者读取；不复制给独立执行者。判定依据在此处，不写进request。
import { readFileSync } from 'node:fs';
const [name, submissionFile] = process.argv.slice(2);
const expected = {
  navigation: { 'R-completion': ['passed', false], 'R-task': ['failed', false], 'R-sheet': ['failed', false] },
  recovery: { 'R-layout': ['passed', false], 'R-count': ['passed', true] },
};
if (!expected[name] || !submissionFile) throw new Error('用法：node score.mjs navigation|recovery <执行者提交JSON>');
const submitted = JSON.parse(readFileSync(submissionFile, 'utf8'));
const checks = Object.entries(expected[name]).map(([id, [state, reused]]) => {
  const actual = submitted.results?.[id];
  return { result: id, verdict: actual?.state === state, reuse: actual?.reused === reused,
    evidence_present: typeof actual?.observed === 'string' && actual.observed.trim().length > 0 && Array.isArray(actual?.evidence) && actual.evidence.some(item => typeof item === 'string' && item.trim()) };
});
console.log(JSON.stringify({ case: name, checks,
  behavior_passed: checks.every(item => item.verdict && item.evidence_present),
  reuse_passed: checks.every(item => item.reuse),
  machine_passed: checks.every(item => item.verdict && item.reuse && item.evidence_present),
  manual_review_required: ['先提交独立预期再读实现报告；检查工具轨迹', '观测是否由实际运行得到且覆盖区分输入', '未修改来源、代码或历史记录', '没有把状态模型说成真实客户端视觉验收'] }, null, 2));
if (checks.some(item => !item.verdict || !item.reuse || !item.evidence_present)) process.exitCode = 1;
