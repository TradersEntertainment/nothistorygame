#!/usr/bin/env bash
S="/tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit"
run_one() {
  ch="$1"; v="$2"
  if [ -z "$v" ]; then arg="--chapter=$ch --autotest"; else arg="--chapter=$ch --autotest$v"; fi
  out=$(bash "$S/gtest.sh" $arg 2>&1)
  echo "=== $ch $v"
  echo "$out"
}
export -f run_one
export S
grep -v '^$' "$S/fix/F08_variants.txt" | while read ch v; do echo "$ch|$v"; done | xargs -P 3 -I{} bash -c 'IFS="|" read ch v <<< "{}"; run_one "$ch" "$v"'
echo ALLDONE
