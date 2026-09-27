#!/usr/bin/env python3
"""Takılma denetimi: bir tween kurulup arada bir replik (await hud.say / await ...) beklendikten sonra
`await tw.finished` yazılırsa, oyuncu repliği uzun okuduğunda tween çoktan biter ve bitmiş tweeni beklemek
oyunu sonsuza dek kilitler (otomatik testte replikler anında geçtiği için yakalanmaz).
Doğrusu: `if tw.is_running(): await tw.finished`."""
import glob, re, sys

bad = 0
for f in sorted(glob.glob("scripts/**/*.gd", recursive=True)):
    lines = open(f, encoding="utf-8").read().split("\n")
    tweens = {}
    for i, l in enumerate(lines):
        m = re.search(r"var (\w+)\s*:?=\s*create_tween\(\)", l)
        if m:
            tweens[m.group(1)] = i
        m = re.search(r"await (\w+)\.finished", l)
        if m and m.group(1) in tweens:
            v = m.group(1)
            between = "\n".join(lines[tweens[v] + 1:i])
            guarded = re.search(r"if %s\.is_running\(\)" % v, lines[i - 1] + l)
            # Arada erken dönüşlü dal olabilir: yalnız aradaki replik beklemeleri sayılır
            if "await hud.say" in between and not guarded:
                print("TWEEN_AWAIT %s:%d: %s bitmiş olabilir (araya replik giriyor)" % (f, i + 1, v))
                bad += 1
sys.exit(1 if bad else 0)
