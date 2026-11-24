#!/usr/bin/env bash
# Generic AI-durability audit. Run from project root. Writes .ai/metrics.json,
# exits 1 if any metric is worse than .ai/baseline.json (when present).
set -u
mkdir -p .ai
EX='--exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=build --exclude-dir=.venv --exclude-dir=.ai'
cnt() { grep -rEI $EX --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.py' -e "$1" . 2>/dev/null | wc -l | tr -d ' '; }
any_n=$(cnt ':\s*any\b|<any>|as any\b')
unk_n=$(cnt 'as unknown as')
tsig=$(cnt '@ts-ignore|@ts-expect-error')
pyig=$(cnt '# type: ignore')
esl=$(cnt 'eslint-disable')
skip=$(cnt '\.skip\(|\bxit\(|\bxdescribe\(|@pytest\.mark\.skip|\bit\.todo\(')
rules_sync="ok"
if [ -f AGENTS.md ] && [ -f CLAUDE.md ]; then
  cmp -s AGENTS.md CLAUDE.md || rules_sync="DIVERGED"
else rules_sync="MISSING"; fi
cfg_changed=$(git log --since='30 days ago' --name-only --pretty=format: 2>/dev/null \
  | grep -E 'tsconfig|eslint|ruff|mypy|pyright|\.github/workflows|dependency-cruiser|importlinter|CODEOWNERS' | sort -u | wc -l | tr -d ' ')
cat > .ai/metrics.json <<J
{"any":$any_n,"as_unknown_as":$unk_n,"ts_suppress":$tsig,"py_type_ignore":$pyig,"eslint_disable":$esl,"skipped_tests":$skip,"config_files_changed_30d":$cfg_changed,"rules_sync":"$rules_sync"}
J
cat .ai/metrics.json; echo
fail=0
[ "$rules_sync" != "ok" ] && { echo "FAIL: rules_sync=$rules_sync"; fail=1; }
if [ -f .ai/baseline.json ]; then
  for k in any as_unknown_as ts_suppress py_type_ignore eslint_disable skipped_tests; do
    cur=$(grep -o "\"$k\":[0-9]*" .ai/metrics.json | cut -d: -f2)
    base=$(grep -o "\"$k\":[0-9]*" .ai/baseline.json | cut -d: -f2)
    [ -n "$base" ] && [ "$cur" -gt "$base" ] && { echo "FAIL: $k rose $base -> $cur"; fail=1; }
  done
else echo "NOTE: no .ai/baseline.json; copy metrics.json to baseline.json to start the ratchet."; fi
exit $fail
