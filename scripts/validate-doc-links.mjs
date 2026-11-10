import { readFile, stat } from 'node:fs/promises';
import { spawnSync } from 'node:child_process';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = fileURLToPath(new URL('../', import.meta.url));
const result = spawnSync('git', ['ls-files', '--cached', '--others', '--exclude-standard', '-z'], { cwd: root, encoding: 'utf8' });
if (result.status !== 0) throw new Error('Cannot enumerate repository documentation');
const documents = [...new Set(result.stdout.split('\0'))].filter(path => path.toLowerCase().endsWith('.md'));
const failures = [];
for (const document of documents) {
  const path = resolve(root, document);
  const markdown = (await readFile(path, 'utf8')).replace(/```[\s\S]*?```/g, '');
  for (const match of markdown.matchAll(/\[[^\]]*\]\(([^)]+)\)/g)) {
    const url = match[1].trim().replace(/^<|>$/g, '');
    if (/^(?:javascript|vbscript|data):/i.test(url)) { failures.push(`${document}: unsafe URL`); continue; }
    if (/^(?:[a-z][a-z0-9+.-]*:|#|\/\/)/i.test(url)) continue;
    const target = decodeURIComponent(url.split(/[?#]/)[0]);
    if (!target) continue;
    try { await stat(resolve(dirname(path), target)); } catch { failures.push(`${document}: missing ${target}`); }
  }
}
if (failures.length) { console.error(failures.join('\n')); process.exit(1); }
console.log(`Validated relative links in ${documents.length} Markdown files.`);
