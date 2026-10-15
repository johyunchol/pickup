// tokens.json → 웹용 CSS 변수 + Flutter 용 Dart 상수.
// `node generate.mjs`        파일을 다시 쓴다.
// `node generate.mjs --check` 다시 쓰지 않고, 커밋된 파일과 다르면 실패한다.
import { readFileSync, writeFileSync, mkdirSync, existsSync } from "node:fs";
import { dirname, join, relative } from "node:path";
import { fileURLToPath } from "node:url";

const pkgDir = join(dirname(fileURLToPath(import.meta.url)), "..");
const rootDir = join(pkgDir, "../..");
const tokens = JSON.parse(readFileSync(join(pkgDir, "tokens.json"), "utf8"));

const HEADER = "생성 파일 — 고치지 마세요. 원본: packages/tokens/tokens.json (pnpm tokens:generate)";

// 웹·앱 모두 Noto Sans KR 이 없을 때 기기 기본 한글 글꼴로 내려간다.
const CSS_FONT_FALLBACK =
  '"Apple SD Gothic Neo", "Malgun Gothic", system-ui, sans-serif';

function css() {
  const lines = [`/* ${HEADER} */`, ":root {"];
  for (const [k, v] of Object.entries(tokens.color)) lines.push(`  --color-${k}: ${v};`);
  lines.push(`  --font-family: "${tokens.font.family}", ${CSS_FONT_FALLBACK};`);
  for (const [k, v] of Object.entries(tokens.font.size)) lines.push(`  --font-size-${k}: ${v}px;`);
  for (const [k, v] of Object.entries(tokens.font.weight)) lines.push(`  --font-weight-${k}: ${v};`);
  for (const [k, v] of Object.entries(tokens.space)) lines.push(`  --space-${k}: ${v}px;`);
  for (const [k, v] of Object.entries(tokens.radius)) lines.push(`  --radius-${k}: ${v}px;`);
  lines.push("}", "");
  return lines.join("\n");
}

// "text-muted" → "textMuted", "2xl" → "xl2", "1" → "s1" (Dart 식별자는 숫자로 시작할 수 없다)
function dartName(key, numberPrefix) {
  const m = /^(\d+)(.*)$/.exec(key);
  const k = m ? (m[2] ? m[2] + m[1] : numberPrefix + m[1]) : key;
  return k.replace(/-([a-z0-9])/g, (_, c) => c.toUpperCase());
}

function dartColor(hex) {
  return `Color(0xFF${hex.slice(1).toUpperCase()})`;
}

function dartClass(name, doc, entries) {
  return [
    `/// ${doc}`,
    `abstract final class ${name} {`,
    ...entries.map(([k, v]) => `  static const ${k} = ${v};`),
    "}",
  ].join("\n");
}

function dart() {
  const map = (obj, prefix, fmt) =>
    Object.entries(obj).map(([k, v]) => [dartName(k, prefix), fmt(v)]);
  return [
    `// ${HEADER}`,
    "import 'package:flutter/widgets.dart';",
    "",
    dartClass("PickupColors", "색", map(tokens.color, "c", dartColor)),
    "",
    dartClass("PickupFont", "글꼴", [["family", `'${tokens.font.family}'`]]),
    "",
    dartClass("PickupFontSize", "글자 크기 (논리 픽셀)", map(tokens.font.size, "s", (v) => `${v}.0`)),
    "",
    dartClass("PickupFontWeight", "글자 굵기", map(tokens.font.weight, "w", (v) => `FontWeight.w${v}`)),
    "",
    dartClass("PickupSpace", "간격 (논리 픽셀)", map(tokens.space, "s", (v) => `${v}.0`)),
    "",
    dartClass("PickupRadius", "모서리 반지름 (논리 픽셀)", map(tokens.radius, "r", (v) => `${v}.0`)),
    "",
  ].join("\n");
}

const outputs = [
  [join(pkgDir, "generated/tokens.css"), css()],
  [join(rootDir, "flutter_packages/app_ui/lib/src/tokens.g.dart"), dart()],
];

const check = process.argv.includes("--check");
let stale = 0;
for (const [file, content] of outputs) {
  const rel = relative(rootDir, file);
  if (check) {
    const current = existsSync(file) ? readFileSync(file, "utf8") : null;
    if (current !== content) {
      console.error(`✘ ${rel} 가 tokens.json 과 다릅니다`);
      stale++;
    } else {
      console.log(`✔ ${rel}`);
    }
  } else {
    mkdirSync(dirname(file), { recursive: true });
    writeFileSync(file, content);
    console.log(`▶ ${rel}`);
  }
}
if (stale) {
  console.error("pnpm tokens:generate 로 다시 만든 뒤 커밋하세요.");
  process.exit(1);
}
