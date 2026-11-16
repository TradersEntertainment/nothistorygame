#!/bin/bash
# toplu.sh <liste_dosyasi> [paralel=3]   liste: her satır "<cikti> <godot argümanları...>"
P="${2:-3}"
D="$(cd "$(dirname "$0")" && pwd)"
xargs -P "$P" -L 1 "$D/kos1.sh" < "$1"
