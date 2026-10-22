const fs=require('fs'), path=require('path');
const base=__dirname;
const runtime=process.env.DIAGRAM_NODE_MODULES;
if(!runtime) throw new Error('Set DIAGRAM_NODE_MODULES to a directory containing @viz-js/viz and playwright');
const {instance}=require(path.join(runtime,'@viz-js/viz/dist/viz.cjs'));
const {chromium}=require(path.join(runtime,'playwright'));
const head=`digraph G { graph [bgcolor="#ffffff",pad="0.35",nodesep="0.5",ranksep="0.65",fontname="Heiti SC",fontsize=20]; node [shape=box,style="rounded,filled",fillcolor="#F3F6FA",color="#BCC9D7",fontname="Heiti SC",fontsize=16,margin="0.20,0.15"]; edge [color="#64748B",fontname="Heiti SC",fontsize=12,arrowsize=0.7];`;
const diagrams={
architecture:head+`rankdir=TB; label="系统设计概览｜在既有单体中增加批量审核"; labelloc=t;
subgraph cluster_front {label="管理端 · 浏览器";color="#CBD5E1";web[label="审核页面\n新增：批量提交、进度与结果",fillcolor="#E6F0FB"];}
subgraph cluster_app {label="审核服务 · 单体部署边界";color="#94B8DC";style=rounded;api[label="HTTP API 模块\n鉴权、创建批次、查询结果",fillcolor="#E6F0FB"];worker[label="后台 Worker 模块\n轮询、租约、有限重试",fillcolor="#E6F0FB"];domain[label="既有内容审核规则\n状态校验、审核记录"];{rank=same;api;worker;}worker->domain[label="调用领域能力"];}
db[shape=cylinder,label="PostgreSQL\n既有：content、review_record\n新增：review_batch、review_batch_item",fillcolor="#E6F0FB"];
web->api[label="HTTPS · 提交 / 查询"];api->db[label="SQL · 保存批次 / 读取结果"];worker->db[label="SQL · 轮询 / 获取租约"];domain->db[label="单项事务 · 内容 + 记录 + 结果"];
legend[shape=plaintext,label="蓝底：本次新增或修改    灰底：既有能力",fontsize=12];db->legend[style=invis];}`,
'use-cases':head+`rankdir=LR;label="用例总览｜参与者与系统能力";labelloc=t;actor[shape=plaintext,label="«参与者»\n审核人员\n（具备审核权限）"];subgraph cluster_system {label="内容审核系统";color="#94B8DC";uc1[shape=ellipse,label="UC-01\n批量通过内容",fillcolor="#E6F0FB"];uc2[shape=ellipse,label="UC-02\n查看处理进度与结果",fillcolor="#E6F0FB"];}actor->uc1[dir=none];actor->uc2[dir=none];}`,
domain:head+`rankdir=TB;label="领域对象｜业务职责与关系";labelloc=t;
graph[ranksep="0.55"];edge[fontsize=15];
batch[label="审核批次 ReviewBatch\n一次提交的身份与进度\n请求去重、结果汇总"];
item[label="批次项 ReviewBatchItem\n一条内容的处理结果\n执行信息与终态结果"];
content[label="内容 Content\n内容当前审核状态\n约束合法状态变化"];
record[label="审核记录 ReviewRecord\n已发生的审核动作\n操作者与发生时间"];
batch->item[label="1 个批次包含 1..100 个条目"];
item->content[label="每项保存内容ID\n内容目标当前为 0..1 条"];
content->record[dir=back,label="每条记录保存内容ID\n内容目标当前为 0..1 条"];
note[shape=plaintext,label="逻辑关联保存目标ID；目标可能不存在或已清理。\n历史ID及结果继续保留，不要求目标记录仍存在。",fontsize=14];
record->note[style=invis];}`,
'execution-state':head+`rankdir=TB;labelloc=t;label="批次项执行状态机｜领取、重试与终态";
graph[nodesep="0.35",ranksep="0.65",splines=polyline];
edge[fontsize=15];
node[width=2.1,height=0.75];
initial[shape=point,label="",width=0.14,height=0.14,fillcolor="#334155",color="#334155"];
pending[label="PENDING\n待执行 / 等待重试",fillcolor="#E6F0FB",group="main"];
running[label="RUNNING\n已领取执行",fillcolor="#E6F0FB",group="main"];
success[label="SUCCEEDED\n成功 · 终态",fillcolor="#E8F4ED",color="#9DBEAA",peripheries=2];
business[label="BUSINESS_FAILED\n业务拒绝 · 终态",fillcolor="#FFF3DB",color="#D5BB82",peripheries=2];
failed[label="SYSTEM_FAILED\n系统故障终止 · 终态",fillcolor="#FBE9E9",color="#D6A8A8",peripheries=2];
{rank=same;success;business;failed;}
retryTop[shape=point,label="",width=0,height=0,style=invis,group="retry"];
retryBottom[shape=point,label="",width=0,height=0,style=invis,group="retry"];
{rank=same;retryTop;pending;}
{rank=same;retryBottom;running;}
retryTop->pending[style=invis,weight=100];
retryBottom->running[style=invis,weight=100];
retryTop->retryBottom[style=invis,weight=100];
initial->pending[label="新建"];
pending->running[label="[到期且次数 < 3]\n/ 次数 +1，换凭证与租约"];
running->success[label="[凭证有效\n且业务合法]\n/ 同事务提交成功"];
running->business[label="[凭证有效\n且业务拒绝]\n/ 写入业务失败"];
running->failed[label="[系统故障或租约到期\n且次数已满]\n/ 回滚后保存系统失败"];
running:e->running:e[label="[租约到期且次数 < 3]\n/ 换凭证，次数 +1"];
running:w->retryBottom[constraint=false,arrowhead=none];
retryBottom->retryTop[constraint=false,arrowhead=none,xlabel="[系统故障且次数 < 3]\n/ 回滚后设重试时间\n并清除租约"];
retryTop->pending:w[constraint=false];
}`
};
const table=(name,title,rows)=>`< <TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0" CELLPADDING="7" COLOR="#BBC9D8"><TR><TD COLSPAN="4" BGCOLOR="#DCEAF8"><B>${name} · ${title}</B></TD></TR><TR><TD>键</TD><TD>字段名</TD><TD>类型</TD><TD>中文含义</TD></TR>${rows.map(r=>'<TR>'+r.map((x,i)=>'<TD ALIGN="LEFT"'+(i===0?' PORT="left_'+r[1]+'"':i===3?' PORT="right_'+r[1]+'"':'')+'>'+x+'</TD>').join('')+'</TR>').join('')}</TABLE> >`;
const batch=[['PK','id','uuid','批次ID'],['UK¹','requester_id','uuid','提交人'],['UK¹','request_key','uuid','请求标识'],['','request_hash','varchar(64)','请求摘要'],['','action','varchar(16)','审核操作'],['','created_at','timestamptz','创建时间'],['','completed_at','timestamptz?','完成时间']];
const item=[['PK / L','batch_id','uuid','批次ID'],['PK / L','content_id','uuid','内容ID'],['','status','varchar(24)','处理状态'],['','attempts','smallint','尝试次数'],['','lease_token','uuid?','领取凭证'],['','lease_until','timestamptz?','租约截止'],['','next_attempt_at','timestamptz','下次执行时间'],['','error_code','varchar(32)?','失败错误码'],['','processed_at','timestamptz?','终态时间']];
diagrams.schema=head+`rankdir=TB;label="库表结构｜新增表完整字段，既有表仅相关字段";labelloc=t;node[shape=plain];batch[label=${table('review_batch','审核批次 · 新增',batch)}];item[label=${table('review_batch_item','批次项 · 新增',item)}];content[label=${table('content','内容 · 既有',[['PK','id','uuid','内容ID'],['','review_status','varchar(16)','审核状态']])}];record[label=${table('review_record','审核记录 · 既有增列',[['PK','id','uuid','记录ID'],['L','content_id','uuid','内容ID'],['L','batch_id','uuid?','批次ID · 新增'],['','operator_id','uuid','操作者'],['','action','varchar(16)','审核动作'],['','occurred_at','timestamptz','发生时间']])}];{rank=same;batch;item;}{rank=same;record;content;}batch:right_id:e->item:left_batch_id:w[style=dashed,label="1 : 多 · 逻辑关联"];item:right_content_id:e->content:right_id:e[style=dashed,label="多 : 0..1 · 逻辑关联"];record:right_content_id:e->content:left_id:w[style=dashed,label="多 : 0..1 · 逻辑关联"];record:left_batch_id:w->batch:left_id:w[style=dashed,label="多 : 0..1 · 逻辑关联"];legend[shape=plaintext,label="PK 主键 / L 逻辑关联 / ? 可空\n关联ID由业务逻辑维护，无数据库外键\n0..1：目标可不存在或已清理，历史ID保留\n条目存续期间所属批次必须存在\nUK¹ = UNIQUE(requester_id, request_key)\n批次项联合主键：(batch_id, content_id)",fontsize=12];item->legend[style=invis];}`;
diagrams['schema-batch']=head+'node[shape=plain];batch[label='+table('review_batch','审核批次 · 新增',batch)+'];}';
diagrams['schema-item']=head+'node[shape=plain];item[label='+table('review_batch_item','批次项 · 新增',item)+'];}';
const esc=s=>s.replaceAll('&','&amp;').replaceAll('<','&lt;');
function swim(){const xs=[30,360,690],ys=[110,220,330,440,550,660,770],w=310;let a=['<svg xmlns="http://www.w3.org/2000/svg" width="1050" height="950" viewBox="0 0 1050 950"><defs><marker id="arrow" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto"><path d="M0,0 L8,4 L0,8" fill="#64748b"/></marker></defs><rect width="1050" height="950" fill="white"/><style>text{font-family:"Heiti SC",sans-serif;fill:#203047;font-size:15px}.title{font-size:22px;font-weight:bold}.lane{fill:#f7f9fc;stroke:#cbd5e1}.step{fill:#e8f1fb;stroke:#adc3dc}.link{fill:none;stroke:#64748b;stroke-width:1.5;marker-end:url(#arrow)}</style><text x="525" y="36" text-anchor="middle" class="title">UC-01 泳道图｜异步执行与单项事务</text>'];['管理端','HTTP API 模块','Worker 模块'].forEach((n,i)=>a.push(`<rect class="lane" x="${xs[i]}" y="60" width="${w}" height="810" rx="8"/><text x="${xs[i]+w/2}" y="87" text-anchor="middle">${n}</text>`));const step=(lane,row,lines)=>{let x=xs[lane]+15,y=ys[row];a.push(`<rect class="step" x="${x}" y="${y}" width="280" height="76" rx="7"/>`);lines.forEach((t,i)=>a.push(`<text x="${x+140}" y="${y+25+i*20}" text-anchor="middle">${esc(t)}</text>`));};const line=(x1,y1,x2,y2,t)=>{a.push(`<path class="link" d="M${x1},${y1} L${x2},${y2}"/>`);if(t)a.push(`<text x="${(x1+x2)/2}" y="${(y1+y2)/2-7}" text-anchor="middle">${t}</text>`);};step(0,0,['确认提交','生成请求标识']);step(1,1,['检查权限、参数与请求去重','短事务保存批次及待处理项']);step(0,2,['收到 202 与批次 ID','查询进度与逐条结果']);step(2,2,['轮询并领取到期项','行锁、领取凭证、30 秒租约']);step(2,3,['单项事务：锁项并校验凭证','检查状态及剩余租约']);step(2,4,['事务执行：成功 / 业务失败写终态','系统异常回滚，不保留部分写入']);step(2,5,['暂时故障：2秒 / 5秒后重试','最多3次，超限记系统失败']);step(2,6,['所有条目终态后','补写批次完成时间']);line(325,148,375,258);line(375,296,325,368);line(655,258,705,368,'异步发现');line(845,406,845,440);line(845,516,845,550);line(845,626,845,660);a.push('<text x="860" y="648">系统异常</text>');line(845,736,845,770);a.push('<text x="860" y="758">重试耗尽</text>');a.push('<path class="link" d="M705,588 L695,588 L695,808 L705,808"/><text x="690" y="753" text-anchor="end">成功 / 业务失败</text>');a.push('<path class="link" d="M985,698 L1015,698 L1015,368 L985,368"/><text x="1005" y="535" text-anchor="end">到期 / 重领</text>');a.push('<rect x="30" y="890" width="970" height="42" rx="6" fill="#f2f5f9"/><text x="48" y="916">说明：成功、业务失败及重试耗尽均进入终态；业务写入与成功结果同事务提交。</text></svg>');return a.join('');}

(async()=>{const viz=await instance();for(const [name,src] of Object.entries(diagrams)){fs.writeFileSync(path.join(base,name+'.dot'),src);fs.writeFileSync(path.join(base,name+'.svg'),viz.renderString(src,{format:'svg'}).replace(/font-size="([0-9.]+)"/g, (_,n)=>'font-size="'+(Number(n)*0.76)+'"'));}fs.writeFileSync(path.join(base,"sequence.svg"),swim());const browser=await chromium.launch({executablePath:process.env.CHROME_PATH||undefined,headless:true});const page=await browser.newPage({deviceScaleFactor:2});for(const name of [...Object.keys(diagrams),"sequence"]){await page.goto('file://'+path.join(base,name+'.svg'));const svg=page.locator('svg');await svg.screenshot({path:path.join(base,name+'.png')});}await browser.close();})();
