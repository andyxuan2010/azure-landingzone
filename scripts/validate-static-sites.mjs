import { readFile, readdir, stat } from 'node:fs/promises';
import { dirname, resolve, relative, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(fileURLToPath(new URL('../static-web-apps/', import.meta.url)));
const errors = [];
let count = 0;
async function walk(directory) {
  for (const entry of await readdir(directory, { withFileTypes: true })) {
    const path = resolve(directory, entry.name);
    if (entry.isSymbolicLink()) { errors.push(`${relative(root, path)}: symbolic links are not deployable`); continue; }
    if (entry.isDirectory()) { await walk(path); continue; }
    if (entry.name === 'staticwebapp.config.json') {
      const config = JSON.parse(await readFile(path, 'utf8'));
      const headers = config.globalHeaders ?? {};
      for (const [key, value] of Object.entries({ 'X-Content-Type-Options': 'nosniff', 'X-Frame-Options': 'DENY' })) {
        if (headers[key] !== value) errors.push(`${relative(root, path)}: require ${key}=${value}`);
      }
      if (!headers['Content-Security-Policy']?.includes("object-src 'none'")) errors.push(`${relative(root, path)}: missing CSP`);
    }
    if (!entry.name.endsWith('.html')) continue;
    count++;
    const html = await readFile(path, 'utf8');
    const label = relative(root, path);
    if (!/<title>[^<]+<\/title>/i.test(html)) errors.push(`${label}: missing title`);
    if (!/<meta\b[^>]*name=["']viewport["']/i.test(html)) errors.push(`${label}: missing viewport`);
    const ids = [...html.matchAll(/\bid=["']([^"']+)["']/g)].map(match => match[1]);
    if (ids.length !== new Set(ids).size) errors.push(`${label}: duplicate IDs`);
    for (const match of html.matchAll(/\b(?:href|src)=["']([^"']+)["']/g)) {
      const url = match[1];
      if (/^(?:javascript|vbscript):/i.test(url.trim())) { errors.push(`${label}: unsafe URL`); continue; }
      if (url.startsWith('#')) {
        if (url.length > 1 && !ids.includes(url.slice(1))) errors.push(`${label}: missing anchor ${url}`);
        continue;
      }
      if (/^(?:[a-z][a-z0-9+.-]*:|\/\/)/i.test(url)) continue;
      const clean = decodeURIComponent(url.split(/[?#]/)[0]);
      if (!clean) continue;
      let deploymentRoot = dirname(path);
      while (deploymentRoot !== root) {
        try { await stat(resolve(deploymentRoot, 'staticwebapp.config.json')); break; } catch { deploymentRoot = dirname(deploymentRoot); }
      }
      const target = clean.startsWith('/') ? resolve(deploymentRoot, `.${clean}`) : resolve(dirname(path), clean);
      const rel = relative(root, target);
      if (rel === '..' || rel.startsWith(`..${sep}`)) { errors.push(`${label}: reference escapes site root: ${url}`); continue; }
      try { await stat(target); } catch { errors.push(`${label}: missing local reference ${url}`); }
    }
  }
}
await walk(root);
if (count === 0) errors.push('No static HTML files found');
if (errors.length) { console.error(errors.join('\n')); process.exit(1); }
console.log(`Validated ${count} static HTML files and deployment security headers.`);
