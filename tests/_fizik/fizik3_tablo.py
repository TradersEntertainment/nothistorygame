#!/usr/bin/env python3
"""Fizik-3 denetim tablosu: fizik3_tablo.py <günlük>... → markdown satırları
sonuç | VISAUDIT | AYAKAUDIT yakın | YIGILMAAUDIT | öteki (SCRIPT ERROR, WALKTHRU, HELDAUDIT, ARMAUDIT, WARN_FX/FLY/VOID)
KUMASPERF satırları varsa: on saniyelik pencerelerin ortancası (proc_ms, kumas_us, kumas_kisi) ve pay."""
import sys, re, os
print("| günlük | sonuç | VISAUDIT | AYAKAUDIT yakın | YIGILMAAUDIT | öteki | proc ms | kumaş µs | kumaşlı kişi | pay |")
print("|---|---|---|---|---|---|---|---|---|---|")
for f in sys.argv[1:]:
    t = open(f, errors="replace").read().splitlines()
    res = "—"
    for l in t:
        m = re.match(r"AUTOTEST (PASS|FAIL)", l)
        if m: res = m.group(1)
        if "AUTOTEST TIMEOUT" in l: res = "TIMEOUT"
    vis = sum(1 for l in t if l.startswith("VISAUDIT"))
    ay = sum(1 for l in t if l.startswith("AYAKAUDIT yakin"))
    yg = sum(1 for l in t if l.startswith("YIGILMAAUDIT"))
    ot = sum(1 for l in t if re.match(r"(SCRIPT ERROR|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|WARN_FLY|WARN_VOID)", l))
    pr = [l for l in t if l.startswith("KUMASPERF")]
    ps = us = ks = ""
    pay = ""
    if pr:
        P = [float(re.search(r"proc_ms=([\d.]+)", l).group(1)) for l in pr]
        U = [float(re.search(r"kumas_us=([\d.]+)", l).group(1)) for l in pr]
        K = [float(re.search(r"kumas_kisi=([\d.]+)", l).group(1)) for l in pr]
        # Ortanca (yükleme penceresinin dev kareleri ortalamayı bozuyordu); pay: pencere başına kumaş µs / işlem ms
        med = lambda a: sorted(a)[len(a) // 2]
        ps = "%.1f" % med(P); us = "%.0f" % med(U); ks = "%.1f" % med(K)
        pay = "%.2f%% (en çok %.2f%%)" % (med([100.0 * u / 1000.0 / max(0.001, q) for u, q in zip(U, P)]), max([100.0 * u / 1000.0 / max(0.001, q) for u, q in zip(U, P)]))
    print("| %s | %s | %d | %d | %d | %d | %s | %s | %s | %s |" % (os.path.basename(f).replace(".log", ""), res, vis, ay, yg, ot, ps, us, ks, pay))
