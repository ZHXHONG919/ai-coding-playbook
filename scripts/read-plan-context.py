#!/usr/bin/env python3
"""只读准备方案上下文；正文只输出到标准输出，不写项目或状态文件。"""
import argparse
import hashlib
import json
from pathlib import Path
import sys


PROJECT_DOCS = ('README.md', 'AGENTS.md', 'CLAUDE.md')
COMMON = ('AGENTS.md', 'references/stages/plan.md')
METHODS = {
    'full': (
        'references/plan/plan-writing-guide.md',
        'references/plan/evidence-first.md',
        'references/plan/role-lens.md',
        'templates/feature-design.md',
    ),
    'light': (
        'references/stages/plan-light.md',
        'references/plan/plan-light-writing-guide.md',
        'references/plan/evidence-first.md',
        'templates/plan-light.md',
    ),
}


def marker(name, value):
    return ('@@PLAN_' + name + ' ' + json.dumps(value, ensure_ascii=False,
                                               separators=(',', ':')) + '\n').encode('utf-8')


def read_docs(root, names, confined=False):
    """先取得全部内容，任何失败都不输出半套上下文。"""
    docs = []
    for name in names:
        path = root / name
        if confined:
            try:
                path.resolve().relative_to(root)
            except ValueError:
                raise ValueError('规则文件超出选定根：' + str(path)) from None
        body = path.read_bytes()
        body.decode('utf-8')
        checksum = hashlib.sha256(body).hexdigest()
        count = len(body.splitlines())
        meta = {'path': str(path), 'relative': name,
                'file_sha256': checksum, 'file_bytes': len(body), 'total_lines': count,
                'start_line': 1, 'end_line': count, 'complete': True,
                'sha256': checksum, 'bytes': len(body), 'lines': count}
        docs.append((meta, body))
    return docs


def prepare(args):
    root = Path(args.project if args.command == 'project' else args.root).resolve(strict=True)
    if not root.is_dir():
        raise ValueError('上下文根不是目录：' + str(root))
    context = {'phase': args.command, 'root': str(root)}
    if args.command == 'project':
        missing = [name for name in PROJECT_DOCS if not (root / name).exists()]
        names = [name for name in PROJECT_DOCS if name not in missing]
        context['missing_optional'] = missing
        context['entries'] = [
            {'name': path.name, 'kind': 'symlink' if path.is_symlink()
             else 'directory' if path.is_dir() else 'file'}
            for path in sorted(root.iterdir(), key=lambda item: item.name)
        ]
        docs = read_docs(root, names)
    else:
        names = COMMON + METHODS[args.mode]
        if args.file is not None and args.file not in names:
            raise ValueError('--file 必须是当前方式中的规则路径：' + ', '.join(names))
        ranged = args.start_line is not None or args.end_line is not None
        if ranged and (args.file is None or args.start_line is None or args.end_line is None):
            raise ValueError('分段须同时提供 --file、--start-line 和 --end-line')
        docs = read_docs(root, names, confined=True)
        context.update(mode=args.mode, required=list(names))
        if args.file is not None:
            docs = [doc for doc in docs if doc[0]['relative'] == args.file]
        if ranged:
            meta, body = docs[0]
            start, end, total = args.start_line, args.end_line, meta['total_lines']
            if not (start == 1 and end == 0 and total == 0) and not (1 <= start <= end <= total):
                raise ValueError('行范围无效；必须在 1..' + str(total) + ' 内，空文件使用 1..0')
            body = b''.join(body.splitlines(keepends=True)[start - 1:end])
            meta.update(start_line=start, end_line=end, complete=start == 1 and end == total,
                        sha256=hashlib.sha256(body).hexdigest(), bytes=len(body),
                        lines=len(body.splitlines()))
            docs = [(meta, body)]
        context['reread_syntax'] = ('method --root ROOT --mode ' + args.mode
                                    + ' --file REL --start-line N --end-line M')
    context['files'] = [meta for meta, _ in docs]
    return context, docs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    project = commands.add_parser('project', help='读取项目约定和根目录清单，不读取详细定义')
    project.add_argument('--project', required=True)
    method = commands.add_parser('method', help='读取选定规则根中的完整或轻量方案方法')
    method.add_argument('--root', required=True)
    method.add_argument('--mode', required=True, choices=METHODS)
    method.add_argument('--file', help='输出包截断时，只重读此相对路径的完整文件')
    method.add_argument('--start-line', type=int, help='片段首行，1起算；须与 --file、--end-line 同用')
    method.add_argument('--end-line', type=int, help='片段末行，含此行；空文件用首行1、末行0')
    args = parser.parse_args()
    try:
        context, docs = prepare(args)
    except (OSError, UnicodeError, ValueError) as exc:
        parser.exit(2, '方案上下文读取失败：' + str(exc) + '\n')
    output = sys.stdout.buffer
    output.write(marker('CONTEXT', context))
    for meta, body in docs:
        output.write(marker('FILE', meta))
        output.write(body)
        output.write(b'\n')
        output.write(marker('END', meta))
    output.write(marker('CONTEXT_END', {'phase': args.command, 'files': len(docs)}))
    output.flush()


if __name__ == '__main__':
    main()
