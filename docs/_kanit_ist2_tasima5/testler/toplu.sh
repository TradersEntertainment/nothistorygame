#!/bin/bash
# toplu.sh <klasor> <ek_arg|-> <cesit...> : Bölüm çeşitlerini en çok 3 paralel koşar (kos1.sh); ek_arg ör. --eskisur ya da -
d="$1"; ek="$2"; shift 2
mkdir -p "$d"
for c in "$@"; do echo "$c"; done | xargs -P 3 -I{} bash ~/is/kos1_tek.sh "$d" "$ek" {}
