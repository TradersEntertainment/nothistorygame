#!/usr/bin/env bash
# Bölüm 1 ve 2'yi bütün yollardan kendi kendine oynatır (ekransız).
# Kullanım: GODOT=/path/to/godot tests/run_tests.sh
set -u
GODOT="${GODOT:-godot}"
cd "$(dirname "$0")/.."
"$GODOT" --headless --path . --import >/dev/null 2>&1
fail=0
run() {
  out=$("$GODOT" --headless --path . -- "$@" 2>&1)
  echo "$out" | grep -E "AUTOTEST|SCRIPT ERROR|Parse Error"
  echo "$out" | grep -q "AUTOTEST PASS" || fail=1
  echo "$out" | grep -q "SCRIPT ERROR" && fail=1
}
for v in "" "=kick" "=red"; do run --autotest$v; done
for v in "" "=perfect" "=chain" "=chainfail" "=red"; do run --chapter=2 --autotest$v; done
# Bölüm 1 -> Bölüm 2 geçişi (çanta ve Telsiz Bağı taşınır)
run --autotest=next
exit $fail
