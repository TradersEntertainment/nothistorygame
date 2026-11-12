#!/usr/bin/env python3
"""Çeviri kokusu taraması: metni on dilime böler. Kullanım: python3 docs/_ajan/gorev/ceviri_dilim.py [N]
N [a|b] verilirse o dilimin (a/b: ilk/ikinci yarısının) satırlarını (anahtar, konuşmacı, tr, en) sekmeyle basar; verilmezse dilim boyutlarını."""
import csv, re, sys, os
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
DILIM = [
    (1, r"^(D0|D1|D2|D3|D4A|D4B|D5|D6|D6B|NPC|ITEM|USE)_"),
    (2, r"^(D7|D8|D8Y|D9)_"),
    (3, r"^(D10[A-NP-Z]?|D11)_"),
    (4, r"^(D12[A-NP-Z]?|D13|D14|D15|D16|D17[A-NP-Z]?|D18[A-NP-Z]?|D|DSET)_"),
    (5, r"^D(19|[2-4][0-9])[A-NP-Z]?_"),
    (6, r"^D[0-9]+O_"),
    (7, r"^(BUR|QUEST)_"),
    (8, r"^(REACT|DST|MG)_"),
    (9, r"^(UI_[A-H]|ACH_|PHOTO_|PF)"),
    (10, r""),   # kalanların hepsi (UI_I-Z, LORE, SIEGE, FATE, FLOW, LM, SPK, ...)
]


def dilim(k):
    for n, pat in DILIM[:5] + DILIM[6:9]:
        if n != 6 and re.match(r"^D[0-9]+O_", k):
            return 6
        if re.match(pat, k):
            return n
    return 6 if re.match(r"^D[0-9]+O_", k) else 10


def main():
    spk = {r["anahtar"]: r["konusmaci"] for r in csv.DictReader(open(ROOT + "/docs/voice/VOICE_MAP.csv", encoding="utf-8", newline=""))}
    rows = list(csv.DictReader(open(ROOT + "/i18n/strings.csv", encoding="utf-8", newline="")))
    if len(sys.argv) < 2:
        say = {}
        for r in rows:
            d = dilim(r["keys"]); a = say.setdefault(d, [0, 0]); a[0] += 1; a[1] += len((r["tr"] or "").split())
        for d in sorted(say):
            print(f"dilim {d:2d}: {say[d][0]:5d} satır, {say[d][1]:6d} sözcük")
        return
    n = int(sys.argv[1])
    sec = [r for r in rows if dilim(r["keys"]) == n]
    if len(sys.argv) > 2:      # yarı: a = ilk yarı, b = ikinci yarı (dosya sırasıyla)
        h = len(sec) // 2
        sec = sec[:h] if sys.argv[2] == "a" else sec[h:]
    for r in sec:
        if True:
            print("\t".join([r["keys"], spk.get(r["keys"], ""), (r["tr"] or "").replace("\n", "\\n"), (r["en"] or "").replace("\n", "\\n")]))


main()
