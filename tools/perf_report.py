#!/usr/bin/env python3
"""tests/perf_run.sh çıktısından (tests/out/perf/*.txt, RINFO satırları) docs/PERF.md tablosunu kurar.
Sahne başına: çizim çağrısı ve üçgen (ana görüntü + gölge) için ortanca ve en yüksek değer. Bütçe: 6.000 çizim, 5 M üçgen.
"Örnekli üçgen": RTRI satırlarından (perf_run.sh sarmalayıcısı) çoklu ağların örnek sayısıyla çarpılmış gerçek üçgeni;
RINFO sayacı çoklu ağda çizim başına ağı bir kez sayar. Bütçe kararı RINFO'ya göre kalır (karşılaştırılabilirlik).
Kullanım: perf_report.py [ölçüm klasörü] [çıktı .md, varsayılan docs/PERF.md]"""
import glob, os, re, statistics, sys

BUDGET_DRAWS, BUDGET_TRIS = 6000, 5000
src = sys.argv[1] if len(sys.argv) > 1 else "tests/out/perf"
dst = sys.argv[2] if len(sys.argv) > 2 else "docs/PERF.md"
rows = {}
real = {}
for path in glob.glob(os.path.join(src, "*.txt")):
    for line in open(path, encoding="utf-8", errors="replace"):
        q = re.match(r"RTRI scene=(\S+) t=(\d+) real=(\d+)k", line)
        if q and int(q.group(2)) >= 1:
            real.setdefault(q.group(1), []).append(int(q.group(3)))
            continue
        m = re.match(r"RINFO scene=(\S+) t=(\d+) draws=(\d+) objs=\d+ prims=(\d+)k(?: vis=(\d+)k shadow=(\d+)k)?", line)
        if not m or int(m.group(2)) < 1:
            continue
        r = rows.setdefault(m.group(1), {"draws": [], "tris": [], "vis": [], "shadow": []})
        r["draws"].append(int(m.group(3))); r["tris"].append(int(m.group(4)))
        if m.group(5):
            r["vis"].append(int(m.group(5))); r["shadow"].append(int(m.group(6)))
out = ["# Çizim bütçesi", "",
       "tests/perf_run.sh ile ölçülür (varsayılan kalite, 1280×720, test botu). Bütçe: karede %d çizim, %.0f M üçgen."
       % (BUDGET_DRAWS, BUDGET_TRIS / 1000), "Ortanca: sahnenin olağan hâli; en yüksek: en ağır an. Üçgenler bin (k).", "",
       "Örnekli üçgen: çoklu ağların (kalabalık) her örneği sayılarak, seçilen LOD ile (RINFO bunları saymaz; yaklaşık).", "",
       "| Sahne | Ölçüm | Çizim ort. | Çizim en yüksek | Üçgen ort. (k) | Üçgen en yüksek (k) | Örnekli üçgen ort. (k) | Örnekli üçgen en yüksek (k) | Gölge payı | Bütçe |",
       "|---|---:|---:|---:|---:|---:|---:|---:|---:|---|"]
over = 0
for name in sorted(rows, key=lambda n: -max(rows[n]["tris"])):
    r = rows[name]
    md, xd = statistics.median(r["draws"]), max(r["draws"])
    mt, xt = statistics.median(r["tris"]), max(r["tris"])
    sh = ""
    if r["shadow"] and sum(r["tris"]) > 0:
        sh = "%d%%" % round(100.0 * sum(r["shadow"]) / max(1, sum(r["vis"]) + sum(r["shadow"])))
    bad = md > BUDGET_DRAWS or mt > BUDGET_TRIS
    over += bad
    rl = real.get(name, [])
    rm, rx = ("%d" % statistics.median(rl), "%d" % max(rl)) if rl else ("-", "-")
    out.append("| %s | %d | %d | %d | %d | %d | %s | %s | %s | %s |" % (name, len(r["draws"]), md, xd, mt, xt, rm, rx, sh, "AŞIYOR" if bad else "tamam"))
out += ["", "%d sahne ölçüldü, %d tanesi bütçeyi (ortancada) aşıyor." % (len(rows), over)]
os.makedirs(os.path.dirname(dst) or ".", exist_ok=True)
open(dst, "w", encoding="utf-8").write("\n".join(out) + "\n")
print("PERF %d sahne, %d bütçe aşımı -> %s" % (len(rows), over, dst))
