#!/usr/bin/env bash
# $1 = chapter, $2 = variant suffix (may be empty)
S=/tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit
ch="$1"; v="$2"
name="c${ch}${v}"; name="${name//=/_}"; name="${name//--/}"
if [ "$v" = "=next" ]; then
  args="--chapter=$ch --autotest=next"
elif [ -z "$v" ]; then
  args="--chapter=$ch --autotest"
else
  args="--chapter=$ch --autotest$v"
fi
bash $S/gtest.sh $args > $S/fix/F04_runs/$name.log 2>&1
echo "rc=$?" >> $S/fix/F04_runs/$name.log
