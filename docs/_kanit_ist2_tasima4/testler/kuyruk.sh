#!/bin/bash
# kuyruk.sh <liste_dosyasi>  — her satır: <cikti> <args...>; 4 paralel
xargs -P ${P:-4} -L 1 ~/is/kos1.sh < "$1"
echo KUYRUK_BITTI
