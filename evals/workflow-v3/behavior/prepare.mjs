#!/usr/bin/env node
// 调度者使用；只向临时项目复制公开输入，不复制评分器。
import { cpSync, existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const root = resolve(here, '../../..');
const selection = process.argv[2];
const destination = process.argv[3] && resolve(process.argv[3]);
if (!['all', 'navigation', 'recovery'].includes(selection) || !destination) {
  throw new Error('用法：node prepare.mjs all|navigation|recovery <空的临时目录>');
}
if (existsSync(destination) && readdirSync(destination).length) throw new Error('目标必须为空，拒绝覆盖');
mkdirSync(destination, { recursive: true });
const json = (path, value) => writeFileSync(path, JSON.stringify(value, null, 2) + '\n');
const sha = path => createHash('sha256').update(readFileSync(path)).digest('hex');
const git = (cwd, ...args) => execFileSync('git', args, { cwd, encoding: 'utf8', stdio: ['ignore', 'pipe', 'pipe'] }).trim();
function api(method, ...args) {
  const ruby = 'a=JSON.parse(STDIN.read); print JSON.generate(GoalV3.public_send(a.fetch("method"), *a.fetch("args")))';
  return JSON.parse(execFileSync('ruby', ['-r', resolve(root, 'scripts/goal-v3.rb'), '-r', 'json', '-e', ruby], {
    input: JSON.stringify({ method, args }), encoding: 'utf8',
  }));
}
function result(expected, source, decision, extra = {}) {
  return { revision: 1, kind: 'user_result', owner: 'delivery-owner', expected,
    sources: [{ path: source, anchor: expected.entry }], decisions: [decision], depends_on: [], ...extra };
}
function navigation(baseline) {
  return {
    schema_version: 3, baseline_commit: baseline,
    decisions: { D1: { text: '采用 docs/behavior.md 中分别定义的三个入口行为；原型只约束局部交互。' } },
    results: {
      'R-completion': result({ entry: '全局完成条', action: '点击去查看', object: '本人待办', context: '同一人有多个任务', outcome: '进入运营首页', counterexample: '不能强行限定到某一任务' }, 'docs/behavior.md', 'D1'),
      'R-task': result({ entry: '任务卡', action: '点击查看成品', object: '所点任务的首个成品', context: '两任务各有两个结果', outcome: '打开所点任务首个成品详情并保留任务与成品编号', counterexample: '不能仅进入全局待办，也不能打开其他任务结果' }, 'docs/behavior.md', 'D1'),
      'R-sheet': result({ entry: '对象详情页', action: '打开生成再关闭', object: '当前对象', context: '详情已滚动到184且仍需作为背景', outcome: '同页弹层打开；关闭保留详情、对象和滚动位置', counterexample: '独立生成页面或关闭后滚动归零不满足要求' }, 'docs/behavior.md', 'D1'),
    },
    tasks: {
      T1: { owner: 'implementation-owner', results: ['R-completion', 'R-task', 'R-sheet'], work: '接通应用事件分发与状态更新', self_check: '运行已有测试并按结果操作应用', depends_on: [] },
    },
  };
}
function recovery(baseline) {
  return {
    schema_version: 3, baseline_commit: baseline,
    decisions: { 'D-layout': { text: '使用采用稿的分隔列表。' }, 'D-count': { text: '已完成数量只统计 done 任务。' } },
    results: {
      'R-layout': result({ entry: '管理页面', action: '打开任务集合', object: '三个任务', context: '当前采用稿为分隔列表', outcome: '列表布局，每任务一个row', counterexample: '不能遗漏任何任务' }, 'docs/layout.md', 'D-layout'),
      'R-count': result({ entry: '管理页面统计', action: '读取已完成数量', object: '三个任务', context: '两个done、一个queued', outcome: '已完成数量为2', counterexample: 'queued不能计入已完成' }, 'docs/count.md', 'D-count'),
    },
    tasks: { T1: { owner: 'implementation-owner', results: ['R-layout'], work: '实现任务集合渲染', self_check: 'node app.mjs', depends_on: [] }, T2: { owner: 'implementation-owner', results: ['R-count'], work: '接通统计函数', self_check: 'node app.mjs', depends_on: [] } },
  };
}
function prepare(name) {
  const target = resolve(destination, name);
  cpSync(resolve(here, 'cases', name), target, { recursive: true });
  git(target, 'init', '--initial-branch=fixture');
  git(target, 'add', '.');
  git(target, '-c', 'user.name=Workflow Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '-m', 'fixture baseline');
  const goalDir = resolve(target, '.goal');
  mkdirSync(resolve(goalDir, 'runs'), { recursive: true });
  const doc = (name === 'navigation' ? navigation : recovery)(git(target, 'rev-parse', 'HEAD'));
  const status = { schema_version: 3, state: 'active', tasks: Object.fromEntries(Object.keys(doc.tasks).map(id => [id, 'done'])), runs: [] };
  json(resolve(goalDir, 'goal.yaml'), doc); // JSON 是合法 YAML，无额外依赖。
  json(resolve(goalDir, 'status.yaml'), status);
  if (name === 'recovery') {
    const observation = execFileSync(process.execPath, ['app.mjs'], { cwd: target, encoding: 'utf8' });
    const evidencePath = resolve(goalDir, 'runs/prior-observation.txt');
    writeFileSync(evidencePath, '夹具中的历史观测：node app.mjs\n' + observation);
    const snapshot = api('capture', goalDir, 'prior');
    const ref = { path: snapshot.path, sha256: snapshot.sha256 };
    const changes = api('diff', goalDir, null, ref);
    const run = {
      from: null, to: ref, implementation_owners: ['prior-implementation'],
      review: { owner: 'prior-independent-reviewer', blocking_findings: 0, summary: '合成历史记录：按当时分隔列表来源检查现有输出与统计。只作恢复夹具，不是真实业务验收。' },
      changes: changes.map(path => ({ path, results: Object.keys(doc.results), disposition: 'behavior', reason: '登记当时结果约定并核验既有行为。' })),
      checks: Object.fromEntries(Object.keys(doc.results).map(id => [id, {
        contract_hash: snapshot.contract_hashes[id], state: 'passed',
        evidence: [{ path: 'runs/prior-observation.txt', sha256: sha(evidencePath) }], observed: observation.trim(),
      }])),
    };
    const runPath = resolve(goalDir, 'runs/prior.yaml');
    json(runPath, run);
    status.runs.push({ path: 'runs/prior.yaml', sha256: sha(runPath) });
    json(resolve(goalDir, 'status.yaml'), status);
    api('check', goalDir); // 注入变更前，历史引用必须实际有效。
    writeFileSync(resolve(target, 'docs/layout.md'), '# R-layout\n\n最新用户决定 U2：管理页任务集合已由用户改成卡片，请保留。每任务一个 card，任务内容和统计规则不变。此决定只替代旧原型的任务集合外观；prototype.mjs 仍保存旧稿，不能据它还原分隔列表。\n');
    writeFileSync(resolve(target, 'src/layout.mjs'), "export function renderTasks(tasks) {\n  return { layout: 'cards', items: tasks.map(task => ({ wrapper: 'card', id: task.id })) };\n}\n");
    doc.decisions['D-layout'].text = '用户决定 U2：保留用户改好的任务卡片；只替代旧原型的任务集合外观。';
    doc.results['R-layout'].revision = 2;
    doc.results['R-layout'].expected.context = '用户新决定U2已替代旧原型列表外观，统计规则不变';
    doc.results['R-layout'].expected.outcome = '卡片布局，每任务一个card';
    json(resolve(goalDir, 'goal.yaml'), doc);
  }
  return { name, path: target, request: resolve(target, 'request.md') };
}
cpSync(resolve(root, 'references/delivery/goal-v3.md'), resolve(destination, 'guide.md'));
const prepared = (selection === 'all' ? ['navigation', 'recovery'] : [selection]).map(prepare);
console.log(JSON.stringify({ guide: resolve(destination, 'guide.md'), cases: prepared }, null, 2));
