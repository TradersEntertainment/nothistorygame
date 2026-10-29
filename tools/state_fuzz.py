#!/usr/bin/env python3
"""Rastgele başlangıç durumu (v0.99.68): bir bölümü, oyuncunun oraya gelebileceği farklı yollardan gelmiş gibi başlatır.

Test botu her bölümü tek bir geçmişle (varsayılan çanta, bayrak, önceki sonuç) oynuyordu; telefonsuz, leblebisiz,
fessiz, Bizans'tan gelmiş oyuncunun yolu ancak elle yazılan varyantlarla denenirdi. Bu araç bölümün betiğinde okunan
bayrakları (GameState.flags.get("ad", varsayılan)) ve önceki bölüm sonuçlarını (chapter_outcomes.get(N...)) bulur,
tohuma göre rastgele değer verir, çantayı rastgele doldurur (5 göze kadar). Çıktı: oyunun anladığı argümanlar
(--bag= --flag= --outcome=); tests/fuzz_run.sh bunları --chaos ile birlikte koşar. Aynı tohum aynı durumu verir.

    python3 tools/state_fuzz.py 26o 7      # -> --bag=phone,tape --flag=fez:false --outcome=25:25.2 ...
"""
import os, random, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ITEMS = ["phone", "lighter", "book", "chickpeas", "powerbank", "tape", "thermos", "selfie", "cologne", "cube"]
SKIP = {"dossier", "quests", "cur_scene", "bag_override"}     # sözlük/iç durum: rastgele değer anlamsız


def args_for(chapter: str, seed: int) -> list:
    rng = random.Random(f"{chapter}:{seed}")
    path = os.path.join(ROOT, "scripts", f"chapter{chapter}.gd")
    src = open(path, encoding="utf-8").read() if os.path.exists(path) else ""
    out = []
    bag = rng.sample(ITEMS, rng.randint(0, 5))
    out.append("--bag=" + (",".join(bag) if bag else "none"))
    seen = set()
    for m in re.finditer(r'flags\.get\("([a-z0-9_]+)",\s*([^)\n]{0,24})\)', src):
        name, default = m.group(1), m.group(2).strip()
        if name in seen or name in SKIP:
            continue
        seen.add(name)
        if default in ("true", "false"):
            val = rng.choice(["true", "false"])
        elif re.fullmatch(r"-?\d+", default):
            val = str(rng.randint(0, 3))
        elif default.startswith('"'):
            # Dize bayrağı: betikte karşılaştırıldığı değerlerden biri (ya da boş)
            lits = set(re.findall(r'flags\.get\("%s",[^)]*\)\s*(?:==|!=)\s*"([^"]*)"' % name, src))
            lits |= set(re.findall(r'"%s"\s*:\s*"([^"]*)"' % name, src))
            val = rng.choice(sorted(lits) + [""]) if lits else ""
            if val == "":
                continue
        else:
            continue
        out.append(f"--flag={name}:{val}")
    for n in sorted(set(re.findall(r"chapter_outcomes\.get\((\d+)", src))):
        # O bölümün sonuçlarından biri ("10.2"): betikte geçen sonuç adlarından seçilir
        opts = sorted(set(re.findall(r'"(%s\.\d)"' % n, src)))
        if opts:
            out.append(f"--outcome={n}:{rng.choice(opts)}")
    return out


if __name__ == "__main__":
    print(" ".join(args_for(sys.argv[1], int(sys.argv[2]) if len(sys.argv) > 2 else 1)))
