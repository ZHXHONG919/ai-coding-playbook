// 仅评价者运行；执行者只接收夹具副本与选定任务，不提供本文件。
// PLAYWRIGHT_MODULE=<已有包路径> CHROMIUM_EXECUTABLE=<已有浏览器路径> node verify.cjs <A|B|C> <副本目录> <输出目录>
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { spawn } = require('node:child_process');
const { once } = require('node:events');
const crypto = require('node:crypto');
const [task, workspace, out] = process.argv.slice(2);
if (!['A', 'B', 'C'].includes(task) || !workspace || !out) throw new Error('用法: node verify.cjs <A|B|C> <workspace> <out>');
fs.mkdirSync(out, { recursive: true });
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const checks = [];
let browser, server;
async function check(name, fn) {
  try { const observation = await fn(); checks.push({ name, passed: true, observation }); }
  catch (error) { checks.push({ name, passed: false, error: error.message }); }
}
function sha(file) { return crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex'); }
(async () => {
  server = spawn(process.execPath, ['server.cjs'], { cwd: workspace, env: { ...process.env, PORT: '0' }, stdio: ['ignore', 'pipe', 'pipe'] });
  let stdout = '', stderr = '';
  server.stderr.on('data', data => stderr += data);
  const port = await new Promise((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error(`服务启动超时: ${stderr}`)), 10000);
    server.once('error', error => { clearTimeout(timer); reject(error); });
    server.once('exit', code => { clearTimeout(timer); reject(new Error(`服务提前退出 ${code}: ${stderr}`)); });
    server.stdout.on('data', data => {
      stdout += data;
      if (stdout.includes('\n')) { clearTimeout(timer); try { resolve(JSON.parse(stdout.split('\n')[0]).port); } catch(error) { reject(error); } }
    });
  });
  const base = `http://127.0.0.1:${port}`;
  browser = await chromium.launch({ headless: true, ...(process.env.CHROMIUM_EXECUTABLE ? { executablePath: process.env.CHROMIUM_EXECUTABLE } : {}) });
  const page = await browser.newPage({ viewport: { width: 390, height: 844 } });
  page.setDefaultTimeout(4000);
  const network = [];
  page.on('response', r => { if (new URL(r.url()).pathname.startsWith('/api/')) network.push({ method: r.request().method(), path: new URL(r.url()).pathname, status: r.status() }); });
  const shot = name => page.screenshot({ path: path.join(out, name), fullPage: true });
  const control = async value => { const r = await fetch(base + '/__control', { method: 'POST', body: JSON.stringify(value) }); assert.equal(r.status, 200); };
  if (task === 'A' || task === 'C') {
    if (task === 'C') await check('采用稿与历史入口保持', async () => {
      for (const file of ['prototype.html', 'prototype-final.js', 'api.js']) assert.equal(sha(path.join(workspace, file)), sha(path.join(__dirname, file)), `${file} 不得为迁就实现而改变`);
      const old = await fetch(base + '/prototype-v1');
      assert.equal(old.status, 200, '历史入口必须仍可打开');
      const historical = fs.readFileSync(path.join(__dirname, 'app.html'), 'utf8').replace('<title>产品</title>', '<title>产品原型 v1</title><meta name="prototype-version" content="v1">');
      assert.equal(fs.readFileSync(path.join(workspace, 'prototype-v1.html'), 'utf8'), historical, '不得改写历史采用稿消除过期入口');
      assert.equal(await old.text(), historical, '旧路由必须仍返回原v1内容');
      await page.goto(base + '/prototype-v1');
      await shot('historical.png');
      return '当前采用稿与请求层保持，旧版文件及路由内容仍是原v1；不是404恢复样例';
    });
    await page.goto(base + '/prototype');
    await page.getByRole('button', { name: '选择图片' }).first().waitFor();
    await shot('prototype.png');
    const ref = await page.locator('main').boundingBox();
    await check('最终采用稿与实际布局', async () => {
      await page.goto(base + '/');
      await page.getByRole('button', { name: '保存草稿' }).waitFor();
      const bounds = await page.locator('main').boundingBox();
      assert.ok(bounds && Math.abs(bounds.width - ref.width) <= 2, '内容宽度偏离采用稿');
      const name = page.getByLabel('名称', { exact: true });
      const dir = page.getByRole('combobox', { name: /^保存目录/ });
      const group = async loc => loc.evaluate(el => { let p = el.parentElement; while(p && p.tagName !== 'SECTION') p=p.parentElement; return p ? p.outerHTML : null; });
      const nameGroup = await group(name), directoryGroup = await group(dir);
      assert.ok(nameGroup && directoryGroup && nameGroup !== directoryGroup, '基础字段与保存目录应分组');
      assert.equal(Math.round((await name.boundingBox()).height), 44, '输入高度');
      const buttons = page.getByRole('button', { name: '选择图片', exact: true });
      assert.equal(await buttons.count(), 3);
      const sectionCount = await buttons.evaluateAll(nodes => new Set(nodes.map(el => el.closest('section'))).size);
      assert.equal(sectionCount, 1, '配套图片必须同组');
      const boxes = await buttons.all();
      for (const button of boxes) {
        const b = await button.boundingBox();
        assert.ok(b.x > bounds.x + bounds.width / 2, '图片操作应在右侧');
      }
      const y = await Promise.all(boxes.map(async b => (await b.boundingBox()).y));
      assert.ok(y[0] < y[1] && y[1] < y[2], '配套图片应为三行');
      const back = await page.getByRole('button', { name: '返回', exact: true }).boundingBox();
      const save = await page.getByRole('button', { name: '保存草稿', exact: true }).boundingBox();
      assert.ok(back.y > y[2] && Math.abs(back.y - save.y) <= 2, '底部返回与保存应同行');
      await shot('implementation.png');
      return '390×844下分组、输入、三行右侧操作和底部按钮符合结构检查；截图仍需人工查看';
    });
    await check('页面消费服务端变化', async () => {
      const label = `验收-${crypto.randomUUID().slice(0, 8)}`;
      await control({ directoryName: label });
      await page.goto(base + '/');
      await page.getByRole('option', { name: label, exact: true }).waitFor({ state: 'attached' });
      assert.ok(network.some(r => r.path === '/api/directories' && r.status === 200));
      return '服务端改变候选名称后，正常页面显示新名称';
    });
    await check('正常保存、重开与服务端读回', async () => {
      const name = `产品-${crypto.randomUUID().slice(0, 8)}`;
      const dir = page.getByRole('combobox', { name: /^保存目录/ });
      const options = await dir.locator('option').evaluateAll(nodes => nodes.map(n => ({ value:n.value, text:n.textContent })));
      const chosen = options.find(o => o.text.startsWith('验收-'));
      assert.ok(chosen, '缺少服务端候选');
      await page.getByLabel('名称', { exact: true }).fill(name);
      await dir.selectOption(chosen.value);
      const response = page.waitForResponse(r => new URL(r.url()).pathname === '/api/item' && r.request().method() === 'POST');
      await page.getByRole('button', { name: '保存草稿', exact: true }).click();
      assert.equal((await response).status(), 200);
      await page.waitForFunction(() => document.body.innerText.includes('保存成功'));
      const stored = await (await fetch(base + '/__inspect')).json();
      assert.deepEqual(stored.item, { name, directoryId: chosen.value });
      await page.reload();
      await page.waitForFunction(value => document.querySelector('input')?.value === value, name);
      assert.equal(await dir.inputValue(), chosen.value);
      assert.ok(network.filter(r => r.path === '/api/item' && r.method === 'GET' && r.status === 200).length >= 2);
      return '浏览器POST保存；同一服务内存读回及刷新后的GET和字段回显一致';
    });
    await check('重开消费服务端新值而非本地缓存', async () => {
      const directories = await (await fetch(base + '/api/directories')).json();
      const changed = { name: `外部更新-${crypto.randomUUID().slice(0, 8)}`, directoryId: directories.items[0].id };
      const response = await fetch(base + '/api/item', { method:'POST', headers:{'content-type':'application/json'}, body:JSON.stringify(changed) });
      assert.equal(response.status, 200);
      await page.reload();
      await page.waitForFunction(value => document.querySelector('input')?.value === value, changed.name);
      assert.equal(await page.getByRole('combobox', { name: /^保存目录/ }).inputValue(), changed.directoryId);
      return '浏览器外正常POST改变存储后，刷新采用新服务端值，不能靠上次输入或本地缓存通过';
    });
    await check('保存失败不假成功且保留输入', async () => {
      await control({ rejectSave: true });
      const before = (await (await fetch(base + '/__inspect')).json()).item;
      const name = `失败保留-${crypto.randomUUID().slice(0, 8)}`;
      await page.getByLabel('名称', { exact: true }).fill(name);
      const directoryId = await page.getByRole('combobox', { name: /^保存目录/ }).inputValue();
      const response = page.waitForResponse(r => new URL(r.url()).pathname === '/api/item' && r.request().method() === 'POST');
      await page.getByRole('button', { name: '保存草稿', exact: true }).click();
      assert.equal((await response).status(), 503);
      await page.waitForFunction(() => document.body.innerText.includes('保存暂不可用'));
      assert.ok(!(await page.locator('body').innerText()).includes('保存成功'));
      assert.equal(await page.getByLabel('名称', { exact: true }).inputValue(), name);
      assert.equal(await page.getByRole('combobox', { name: /^保存目录/ }).inputValue(), directoryId);
      assert.deepEqual((await (await fetch(base + '/__inspect')).json()).item, before);
      await shot('failure.png');
      return '服务端503，页面显示失败、保留名称与目录，存储仍为此前内容';
    });
    await check('底部返回实际可用', async () => {
      await page.goto(base + '/settings'); await page.goto(base + '/');
      await page.getByRole('button', { name: '返回', exact: true }).click();
      await page.waitForURL(base + '/settings');
      return '产品页返回到原设置页';
    });
  } else {
    await check('局部任务变更范围', async () => {
      const baseline = __dirname;
      for (const file of ['server.cjs', 'api.js', 'app.html', 'prototype.html', 'prototype-final.js']) {
        assert.equal(sha(path.join(workspace, file)), sha(path.join(baseline, file)), `${file} 不应改变`);
      }
      const allowed = new Set(['server.cjs', 'api.js', 'app.html', 'settings.html', 'prototype.html', 'prototype-final.js', 'request.md', 'rules']);
      // 夹具原目录用于基线负例时包含评价脚本；执行者副本不得有它。
      if (path.resolve(workspace) === path.resolve(__dirname)) allowed.add('verify.cjs');
      const extra = fs.readdirSync(workspace).filter(file => !allowed.has(file));
      assert.deepEqual(extra, [], '局部任务不应增加文档或其他文件');
      const rulesDir = path.join(workspace, 'rules');
      if (fs.existsSync(rulesDir)) {
        const sources = ['references/stages/implementation.md', 'references/plan/task-breakdown.md', 'references/delivery/evidence-driven-delivery.md'];
        assert.deepEqual(fs.readdirSync(rulesDir).sort(), sources.map(file => path.basename(file)).sort(), '规则副本不得增加文件或子目录');
        for (const source of sources) assert.equal(sha(path.join(rulesDir, path.basename(source))), sha(path.resolve(__dirname, '../../../..', source)), '规则副本不得修改');
      }
      return '仅settings.html允许改变；其他源码摘要保持且没有额外文件';
    });
    await check('成熟接口样式修改', async () => {
      await page.goto(base + '/settings');
      await page.getByText('现有服务', { exact: true }).waitFor();
      const save = await page.getByRole('button', { name: '保存设置', exact: true }).boundingBox();
      const cancel = await page.getByRole('button', { name: '取消', exact: true }).boundingBox();
      assert.equal(save.height, 44); assert.equal(cancel.height, save.height);
      assert.equal(cancel.y, save.y);
      assert.ok(network.some(r => r.path === '/api/info' && r.status === 200));
      await shot('settings.png');
      return '两按钮均44px且同行，原有/api/info实际请求和显示保持';
    });
  }
  fs.writeFileSync(path.join(out, 'network.json'), JSON.stringify(network, null, 2) + '\n');
})().catch(error => checks.push({ name:'执行环境', passed:false, error:error.stack })).finally(async () => {
  if (browser) await browser.close();
  if (server && server.exitCode === null) { const ended=once(server,'exit'); server.kill(); await ended; }
  const files = ['server.cjs','api.js','app.html','settings.html','prototype.html','prototype-final.js', ...(task === 'C' ? ['prototype-v1.html','README.md','runtime.md'] : [])];
  const result = { task, timestamp: new Date().toISOString(), workspace, environment: { node:process.version, playwright:require((process.env.PLAYWRIGHT_MODULE || 'playwright') + '/package.json').version, chromium:process.env.CHROMIUM_EXECUTABLE || 'package default' }, files:Object.fromEntries(files.map(f=>[f,sha(path.join(workspace,f))])), checks, passed:checks.length > 0 && checks.every(c=>c.passed) };
  fs.writeFileSync(path.join(out, 'result.json'), JSON.stringify(result,null,2)+'\n');
  console.log(JSON.stringify(result));
  process.exitCode = result.passed ? 0 : 1;
});
