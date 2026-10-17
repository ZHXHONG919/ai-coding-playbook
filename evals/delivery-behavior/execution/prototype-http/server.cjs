const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
const { randomUUID } = require('node:crypto');
const directories = [{ id: randomUUID(), name: `目录-${randomUUID().slice(0, 8)}` }];
let item = null;
let rejectSave = false;
const requests = [];
const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, 'http://localhost');
  const json = (status, value) => { res.writeHead(status, { 'content-type': 'application/json' }); res.end(JSON.stringify(value)); };
  if (url.pathname === '/api/directories') return json(200, { items: directories });
  if (url.pathname === '/api/info') return json(200, { name: '现有服务' });
  // 以下控制接口只供隔离场景的验收者使用，不属于产品 API。
  if (url.pathname === '/__control' && req.method === 'POST') {
    let body = ''; for await (const chunk of req) body += chunk;
    const control = JSON.parse(body);
    if (control.directoryName) directories[0].name = control.directoryName;
    if (typeof control.rejectSave === 'boolean') rejectSave = control.rejectSave;
    return json(200, { ok: true });
  }
  if (url.pathname === '/__inspect') return json(200, { item, requests });
  if (url.pathname === '/api/item') {
    requests.push({ method: req.method, path: url.pathname });
    // TODO: 实现已确认的开发态保存与读回，使用上面的隔离内存状态。
    return json(501, { message: '本路由尚未实现' });
  }
  const files = { '/': 'app.html', '/settings': 'settings.html', '/prototype': 'prototype.html', '/prototype-final.js': 'prototype-final.js', '/api.js': 'api.js' };
  const file = files[url.pathname];
  if (!file) return json(404, { message: '不存在' });
  res.writeHead(200, { 'content-type': file.endsWith('.js') ? 'text/javascript; charset=utf-8' : 'text/html; charset=utf-8' });
  res.end(fs.readFileSync(path.join(__dirname, file)));
});
server.listen(Number(process.env.PORT || 0), '127.0.0.1', () => console.log(JSON.stringify({ port: server.address().port })));
