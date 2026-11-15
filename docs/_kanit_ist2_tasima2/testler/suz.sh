#!/bin/bash
# suz.sh <dosya...> — tam süzgeç + KOSU satırı
for f in "$@"; do
  echo "== $(basename "$f")"
  grep -E 'AUTOTEST (PASS|FAIL)|SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|WARN_FLY|WARN_VOID|KOSU|WAVERUNNER' "$f" | cut -c1-400
done
