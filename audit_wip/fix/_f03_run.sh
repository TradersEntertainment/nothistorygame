#!/usr/bin/env bash
S=/tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit
OUT=$S/fix/_f03_run.txt
: > $OUT
run_one() {
  args="$1"
  res=$(bash $S/gtest.sh $args 2>&1)
  {
    echo "=== $args"
    echo "$res" | grep -E "AUTOTEST|SCRIPT ERROR|VISAUDIT|FAIL|WARN_SAY_ON_FADE|TIMEOUT" | head -12
  } >> $OUT
}
export -f run_one
export S OUT
cat $S/fix/_f03_jobs.txt | xargs -d '\n' -P 3 -I{} bash -c 'run_one "$@"' _ {}
echo DONE >> $OUT
