#!/bin/bash
# kos1_tek.sh <klasor> <ek_arg|-> <bolum:cesit:tekrar>
d="$1"; ek="$2"; IFS=: read b c r <<< "$3"
args="--chapter=$b --autotest"; [ -n "$c" ] && args="$args=$c"
[ "$ek" != "-" ] && args="$args $ek"
~/is/kos1.sh "$d/c${b}_${c:-def}_r${r:-1}" $args
