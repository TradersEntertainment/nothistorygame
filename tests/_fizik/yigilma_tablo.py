#!/usr/bin/env python3
"""Fizik-yığılma ÖNCE|SONRA tablosu: yigilma_tablo.py <klasör> <bölüm[:çeşit]>...
<klasör>/once_<b>.log ve sonra_<b>.log (yigilma_kos.sh) okunur; markdown tablolar yazılır."""
import sys, re, os

d = sys.argv[1]
runs = sys.argv[2:]
DEN = re.compile(r"VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|POSEAUDIT|WARN_FX|WARN_FLY|WARN_VOID")


def oku(kip, r):
    f = os.path.join(d, "%s_%s.log" % (kip, r.replace(":", "_")))
    if not os.path.exists(f):
        return None
    L = open(f, errors="replace").read().splitlines()
    res = "PASS" if any("AUTOTEST PASS" in l for l in L) else ("FAIL" if any("AUTOTEST FAIL" in l for l in L) else "YOK")
    err = sum(1 for l in L if "SCRIPT ERROR" in l)
    yig = [l for l in L if l.startswith("YIGILMAAUDIT")]
    den = len(set(l for l in L if DEN.search(l)))
    ayak = sum(1 for l in L if l.startswith("AYAKAUDIT yakin"))
    perf = []
    for l in L:
        if l.startswith("YIGPERF"):
            kv = dict(x.split("=", 1) for x in l.split()[1:])
            perf.append(kv)
    return dict(res=res, err=err, yig=yig, den=den, ayak=ayak, perf=perf)


print("| Bölüm | ÖNCE sonuç | ÖNCE YIGILMAAUDIT | SONRA sonuç | SONRA YIGILMAAUDIT | öteki denetim ÖNCE → SONRA | AYAKAUDIT yakın ÖNCE → SONRA |")
print("|---|---|---|---|---|---|---|")
top = [0, 0, 0, 0]
satirlar = []
for r in runs:
    o, s = oku("once", r), oku("sonra", r)
    if o is None or s is None:
        print("| %s | %s | | %s | | | |" % (r, "—" if o is None else o["res"], "—" if s is None else s["res"]))
        continue
    top[0] += len(o["yig"]); top[1] += len(s["yig"]); top[2] += o["ayak"]; top[3] += s["ayak"]
    print("| %s | %s%s | %d | %s%s | **%d** | %d → %d | %d → %d |" % (r, o["res"], " (%d hata)" % o["err"] if o["err"] else "", len(o["yig"]),
          s["res"], " (%d hata)" % s["err"] if s["err"] else "", len(s["yig"]), o["den"], s["den"], o["ayak"], s["ayak"]))
    for l in s["yig"]:
        satirlar.append((r, l))
print("| **toplam** | | **%d** | | **%d** | | %d → %d |" % (top[0], top[1], top[2], top[3]))
print()
print("SONRA satırları:")
for r, l in satirlar:
    print("- %s: `%s`" % (r, l))
print()
print("| Bölüm | ÖNCE işlem ms/kare | SONRA işlem ms/kare | fark | SONRA yığılma µs/kare (ort.) | en kalabalık an: yığılan | o karede yığılma µs | o karenin işlem ms | pay |")
print("|---|---|---|---|---|---|---|---|---|")
for r in runs:
    o, s = oku("once", r), oku("sonra", r)
    if not o or not s or not s["perf"]:
        continue
    def ort(pp, k):
        n = sum(int(p["kare"]) for p in pp)
        return sum(float(p[k]) * int(p["kare"]) for p in pp) / max(1, n)
    po = ort(o["perf"][1:] or o["perf"], "proc_ms") if o["perf"] else float("nan")
    ps = ort(s["perf"][1:] or s["perf"], "proc_ms")
    yu = ort(s["perf"], "yig_us")
    en = max(s["perf"], key=lambda p: (int(p["en_aktif"]), int(p["en_us"])))
    pay = int(en["en_us"]) / 1000.0 / max(0.001, float(en["en_proc_ms"])) * 100.0 if int(en["en_aktif"]) > 0 else 0.0
    print("| %s | %.1f | %.1f | %+.1f%% | %.0f | %s | %s | %.1f | %.1f%% |" % (r, po, ps, (ps / po - 1.0) * 100.0 if po == po and po > 0 else 0.0,
          yu, en["en_aktif"], en["en_us"], float(en["en_proc_ms"]), pay))
