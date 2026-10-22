#!/usr/bin/env python3
"""验证方案上下文读取器的可观察输出和只读边界。"""
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).with_name('read-plan-context.py')
FULL = ['AGENTS.md', 'references/stages/plan.md',
        'references/plan/plan-writing-guide.md', 'references/plan/evidence-first.md',
        'references/plan/role-lens.md', 'templates/feature-design.md']
LIGHT = ['AGENTS.md', 'references/stages/plan.md', 'references/stages/plan-light.md',
         'references/plan/plan-light-writing-guide.md',
         'references/plan/evidence-first.md', 'templates/plan-light.md']


def parse_output(raw):
    def line(prefix):
        nonlocal raw
        head, raw = raw.split(b'\n', 1)
        if not head.startswith(prefix):
            raise AssertionError('缺少预期 frame：' + repr(head))
        return json.loads(head[len(prefix):])
    context = line(b'@@PLAN_CONTEXT ')
    docs = []
    for declared in context['files']:
        meta = line(b'@@PLAN_FILE ')
        if meta != declared:
            raise AssertionError('文件声明与 frame 不同')
        body, raw = raw[:meta['bytes']], raw[meta['bytes']:]
        if not raw.startswith(b'\n'):
            raise AssertionError('正文边界不完整')
        raw = raw[1:]
        if line(b'@@PLAN_END ') != meta:
            raise AssertionError('文件结束信息不同')
        docs.append((meta, body))
    end = line(b'@@PLAN_CONTEXT_END ')
    if raw or end != {'phase': context['phase'], 'files': len(docs)}:
        raise AssertionError('上下文结束不完整或有额外输出')
    return context, docs


def reassemble(docs):
    """独立消费片段：拒绝缺段、乱序、换版和被截断的正文。"""
    first = docs[0][0]
    position, bodies = 1, []
    for meta, body in docs:
        for key in ['path', 'file_sha256', 'file_bytes', 'total_lines']:
            if meta[key] != first[key]:
                raise AssertionError('片段来源或版本不一致')
        if meta['start_line'] != position or meta['lines'] != len(body.splitlines()):
            raise AssertionError('片段行范围不连续')
        if hashlib.sha256(body).hexdigest() != meta['sha256'] or len(body) != meta['bytes']:
            raise AssertionError('片段内容不完整')
        position = meta['end_line'] + 1
        bodies.append(body)
    body = b''.join(bodies)
    if position != first['total_lines'] + 1 or len(body) != first['file_bytes']:
        raise AssertionError('全文缺段')
    if hashlib.sha256(body).hexdigest() != first['file_sha256']:
        raise AssertionError('全文哈希不一致')
    return body


class ReaderTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='方案 上下文 ')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)

    def put(self, relative, body):
        path = self.root / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(body)

    def run_reader(self, *args):
        return subprocess.run([sys.executable, str(SCRIPT), *args], capture_output=True)

    def fill_rules(self):
        for relative in set(FULL + LIGHT):
            self.put(relative, ('# 中文约定\n' + relative + '\n\n').encode())

    def test_project_optional_docs_and_no_detail_reads(self):
        self.put('README.md', '项目入口\n'.encode())
        self.put('AGENTS.md', '规则根由调用者采用。'.encode())
        self.put('src/contracts.ts', b'DETAIL_MUST_NOT_APPEAR')
        result = self.run_reader('project', '--project', str(self.root))
        self.assertEqual(result.returncode, 0, result.stderr)
        context, docs = parse_output(result.stdout)
        self.assertEqual(context['missing_optional'], ['CLAUDE.md'])
        self.assertEqual([meta['relative'] for meta, _ in docs], ['README.md', 'AGENTS.md'])
        self.assertEqual({entry['name'] for entry in context['entries']}, {'README.md', 'AGENTS.md', 'src'})
        self.assertNotIn(b'DETAIL_MUST_NOT_APPEAR', result.stdout)
        for meta, body in docs:
            self.assertEqual(body, (self.root / meta['relative']).read_bytes())
            self.assertEqual(hashlib.sha256(body).hexdigest(), meta['sha256'])

    def test_full_light_scope_order_and_read_only(self):
        self.fill_rules()
        self.put('unrelated.sql', b'NEVER_READ')
        before = {str(path.relative_to(self.root)): path.read_bytes()
                  for path in self.root.rglob('*') if path.is_file()}
        for mode, expected in [('full', FULL), ('light', LIGHT)]:
            with self.subTest(mode=mode):
                result = self.run_reader('method', '--root', str(self.root), '--mode', mode)
                self.assertEqual(result.returncode, 0, result.stderr)
                context, docs = parse_output(result.stdout)
                self.assertEqual(context['root'], str(self.root.resolve()))
                self.assertEqual([meta['relative'] for meta, _ in docs], expected)
                for meta, body in docs:
                    self.assertEqual(body, before[meta['relative']])
                    self.assertEqual(meta['bytes'], len(body))
                    self.assertEqual(meta['lines'], len(body.splitlines()))
                    self.assertTrue(meta['complete'])
                    self.assertEqual(reassemble([(meta, body)]), body)
                self.assertNotIn(b'NEVER_READ', result.stdout)
        after = {str(path.relative_to(self.root)): path.read_bytes()
                 for path in self.root.rglob('*') if path.is_file()}
        self.assertEqual(before, after)

    def test_missing_required_or_bad_utf8_returns_no_partial_context(self):
        self.fill_rules()
        target = self.root / FULL[-1]
        target.unlink()
        result = self.run_reader('method', '--root', str(self.root), '--mode', 'full')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, b'')
        target.write_bytes(b'\xff')
        result = self.run_reader('method', '--root', str(self.root), '--mode', 'full')
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, b'')

    def test_single_file_reread_exact_bytes_and_invalid_selection(self):
        self.fill_rules()
        body = ('长行 中文\r\n' * 10000 + '@@PLAN_END 这也是正文').encode()
        self.put(FULL[2], body)
        result = self.run_reader('method', '--root', str(self.root), '--mode', 'full', '--file', FULL[2])
        self.assertEqual(result.returncode, 0, result.stderr)
        _, docs = parse_output(result.stdout)
        self.assertEqual(len(docs), 1)
        self.assertEqual(docs[0][1], body)
        self.assertEqual(hashlib.sha256(body).hexdigest(), docs[0][0]['sha256'])
        result = self.run_reader('method', '--root', str(self.root), '--mode', 'light', '--file', FULL[2])
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(result.stdout, b'')

    def test_root_symlink_and_method_file_cannot_escape_selected_root(self):
        self.fill_rules()
        with tempfile.TemporaryDirectory() as other:
            link = Path(other) / 'selected root'
            try:
                link.symlink_to(self.root, target_is_directory=True)
            except OSError:
                self.skipTest('此环境无创建软链权限')
            result = self.run_reader('method', '--root', str(link), '--mode', 'light')
            self.assertEqual(result.returncode, 0, result.stderr)
            context, _ = parse_output(result.stdout)
            self.assertEqual(context['root'], str(self.root.resolve()))
            outside = Path(other) / 'external.md'
            outside.write_text('external', encoding='utf-8')
            (self.root / 'AGENTS.md').unlink()
            (self.root / 'AGENTS.md').symlink_to(outside)
            result = self.run_reader('method', '--root', str(self.root), '--mode', 'light')
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(result.stdout, b'')

    def test_contiguous_segments_recover_original_and_reject_missing_or_reordered(self):
        self.fill_rules()
        body = '甲\r\n乙\n\r\n丁\r\n末行无换行'.encode()
        self.put(FULL[2], body)
        docs = []
        for start, end in [(1, 2), (3, 4), (5, 5)]:
            result = self.run_reader('method', '--root', str(self.root), '--mode', 'full',
                                     '--file', FULL[2], '--start-line', str(start), '--end-line', str(end))
            self.assertEqual(result.returncode, 0, result.stderr)
            context, chunk = parse_output(result.stdout)
            self.assertIn('--start-line N --end-line M', context['reread_syntax'])
            self.assertEqual((chunk[0][0]['start_line'], chunk[0][0]['end_line']), (start, end))
            self.assertFalse(chunk[0][0]['complete'])
            docs += chunk
        self.assertEqual(reassemble(docs), body)
        self.assertEqual(hashlib.sha256(body).hexdigest(), docs[0][0]['file_sha256'])
        for invalid in [docs[:1] + docs[2:], list(reversed(docs))]:
            with self.assertRaises(AssertionError):
                reassemble(invalid)
        self.assertEqual(docs[-1][1], '末行无换行'.encode())

    def test_actual_truncation_has_no_complete_frame(self):
        self.fill_rules()
        result = self.run_reader('method', '--root', str(self.root), '--mode', 'full')
        for boundary in [len(result.stdout) // 2, len(result.stdout) - 1]:
            with self.subTest(boundary=boundary):
                with self.assertRaises((ValueError, AssertionError)):
                    parse_output(result.stdout[:boundary])

    def test_bad_ranges_fail_without_partial_output_and_empty_file_is_valid(self):
        self.fill_rules()
        base = ['method', '--root', str(self.root), '--mode', 'full']
        for extra in [
            ['--start-line', '1', '--end-line', '2'],
            ['--file', FULL[2], '--start-line', '1'],
            ['--file', FULL[2], '--end-line', '2'],
            ['--file', FULL[2], '--start-line', '0', '--end-line', '1'],
            ['--file', FULL[2], '--start-line', '2', '--end-line', '1'],
            ['--file', FULL[2], '--start-line', '1', '--end-line', '999'],
        ]:
            with self.subTest(extra=extra):
                result = self.run_reader(*(base + extra))
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(result.stdout, b'')
        self.put(FULL[2], b'')
        for extra in [[], ['--start-line', '1', '--end-line', '0']]:
            result = self.run_reader(*(base + ['--file', FULL[2]] + extra))
            self.assertEqual(result.returncode, 0, result.stderr)
            _, docs = parse_output(result.stdout)
            self.assertEqual(reassemble(docs), b'')
            self.assertEqual(docs[0][0]['total_lines'], 0)
            self.assertTrue(docs[0][0]['complete'])


if __name__ == '__main__':
    unittest.main()
