#!/bin/bash
# kos.sh <is_listesi>  — her satır: "<ad> <argümanlar...>"; en çok 4 paralel
grep -v '^#' "$1" | grep -v '^$' | xargs -P ${P:-4} -L 1 bash ~/is/kos1.sh
echo "TOPLU BITTI $1"
