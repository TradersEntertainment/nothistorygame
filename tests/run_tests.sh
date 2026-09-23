#!/usr/bin/env bash
# Bölüm 1'i üç yoldan kendi kendine oynatır (ekransız).
# Kullanım: GODOT=/path/to/godot tests/run_tests.sh
set -u
GODOT="${GODOT:-godot}"
cd "$(dirname "$0")/.."
"$GODOT" --headless --path . --import >/dev/null 2>&1
fail=0
for v in "" "=kick" "=red"; do
  out=$("$GODOT" --headless --path . -- --autotest$v 2>&1)
  echo "$out" | grep -E "AUTOTEST|SCRIPT ERROR"
  echo "$out" | grep -q "AUTOTEST PASS" || fail=1
  echo "$out" | grep -q "SCRIPT ERROR" && fail=1
done
exit $fail
