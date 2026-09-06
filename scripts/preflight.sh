#!/usr/bin/env bash
# preflight.sh —— 每个 AI session 收工前必须跑通（AGENTS.md「收工前必做」第 1 步）
# 全绿才算任务完成。任何一步失败都不允许提交。
set -euo pipefail

cd "$(dirname "$0")/.."
fail() { echo "❌ $1"; exit 1; }
ok()   { echo "✅ $1"; }

echo "── preflight (macOS SalaryTicker) ──"

# 1. 密钥泄露检查
if git ls-files | grep -Ei '\.(p12|p8|mobileprovision|env|pem|key)$' | grep -q .; then
  fail "仓库中存在密钥/证书类文件，禁止提交"
fi
if git diff --cached -U0 2>/dev/null | grep -Eiq '(api[_-]?key|secret|password|token)\s*[:=]\s*["'\''][A-Za-z0-9_\-]{16,}'; then
  fail "暂存区疑似包含硬编码密钥"
fi
ok "密钥检查"

# 2. TODO 标记（提醒）
todo_count=$(git diff --cached -U0 2>/dev/null | grep -c '^+.*\(TODO\|FIXME\|XXX\)' || true)
[ "$todo_count" -gt 0 ] && echo "⚠️  本次改动新增 $todo_count 处 TODO/FIXME —— 记得写进 HANDOFF「半成品」一栏"

# 3. 代码规范 (SwiftLint 优先)
if command -v swiftlint >/dev/null 2>&1; then
  swiftlint --quiet --strict || fail "SwiftLint 未通过"
  ok "SwiftLint"
else
  echo "⏭  未安装 swiftlint，跳过"
fi

# 4. 构建与单元测试
DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
export DEVELOPER_DIR

if [ -f "Package.swift" ]; then
  echo "🔨 正在执行 Swift 编译与测试..."
  mkdir -p .build/module-cache
  swift test --enable-code-coverage 2>&1 || fail "单元测试未通过"
  ok "构建与单元测试通过"
else
  echo "⏭  Package.swift 尚未创建"
fi

# 5. HANDOFF 新鲜度检查：有代码改动就必须同时更新 HANDOFF
if git diff --cached --name-only 2>/dev/null | grep -q '\.swift$'; then
  git diff --cached --name-only | grep -q 'docs/HANDOFF.md' \
    || fail "本次有 Swift 代码改动但未更新 docs/HANDOFF.md"
  ok "HANDOFF 已同步更新"
fi

echo "── preflight 全部通过 ──"
