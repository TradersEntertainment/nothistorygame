#!/usr/bin/env bash
# Her satır bir koşu; gtest.sh kendi kilitleriyle en çok 3 Godot çalıştırır.
D=/tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit/fix/test_F06
i=0
while IFS= read -r line; do
  i=$((i+1))
  read -r -a args <<< "$line"
  name=$(printf "%02d_%s" $i "$(echo "$line" | tr ' =,-' '____')")
  ( bash /tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit/gtest.sh "${args[@]}" > "$D/$name.txt" 2>&1; echo "done $name" >> "$D/_progress.log" ) &
done < "$D/_list.txt"
wait
echo ALLDONE >> "$D/_progress.log"
