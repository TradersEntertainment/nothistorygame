#!/usr/bin/env bash
out=/tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit/fix/F01_test_results.txt
: > $out
for a in "--chapter=1 --autotest" "--chapter=2 --autotest" "--chapter=8 --autotest" "--chapter=20 --autotest" "--chapter=20 --autotest=lose" "--chapter=22o --autotest" "--chapter=22o --autotest=lose" "--chapter=26 --autotest" "--chapter=29 --autotest" "--chapter=29 --autotest=lose"; do
  echo "=== $a" >> $out
  bash /tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit/gtest.sh $a >> $out 2>&1
done
echo ALLDONE >> $out
