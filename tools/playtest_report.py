#!/usr/bin/env python3
"""Oyun testi toplama aracı: oyuncuların gönderdiği oturumlardan bölüm bölüm tablo.

Girdi iki türlü olabilir (karışık da verilir):
- user://playtest/oturum_*.json dosyaları (ya da bunların klasörü),
- oyuncunun çıkış kartında "Kopyala" deyip WhatsApp/Discord/e-postayla yapıştırdığı metin: .txt dosyası ya da "-"
  ile standart girdi. Her oturum "GTBD-PT {json}" satırıdır; sohbet dışa aktarımındaki tarih/ad önekleri ve aradaki
  başka mesajlar atlanır.
Aynı oturum (id) birden çok gelirse en çok bölüm kaydı olanı sayılır (oyuncu iki kez kopyalayıp göndermiş olabilir).

Kullanım:  python3 tools/playtest_report.py KLASÖR_DOSYA_YA_DA_- ... [-o docs/OYUN_TESTI_SONUC.md]

Her bölüm için: oynayan sayısı, ortalama eğlence puanı (1-5; anketi geçenler sayılmaz), ortalama süre, bitiren /
yarıda bırakan, ortalama atlanan replik ve duraklatma, sık artan sayaçlar (ölüm, düşme, tekrar...), yarıda
bırakılanların son hedefleri, en komik ve en sıkıcı anlar (oyuncunun kendi cümlesi).
"""
import json, sys, os, re, glob, argparse, collections, statistics

TAG = re.compile(r"GTBD-PT (\{.*\})\s*$")


def _from_text(text, where):
    out = []
    for n, line in enumerate(text.splitlines(), 1):
        m = TAG.search(line)
        if not m:
            continue
        try:
            out.append(json.loads(m.group(1)))
        except ValueError as e:
            print(f"atlandı: {where}:{n} ({e})", file=sys.stderr)
    return out


def load(paths):
    files = []
    for p in paths:
        if os.path.isdir(p):
            files += sorted(glob.glob(os.path.join(p, "*.json")) + glob.glob(os.path.join(p, "*.txt")))
        else:
            files.append(p)
    sessions = []
    for f in files:
        try:
            text = sys.stdin.read() if f == "-" else open(f, encoding="utf-8").read()
        except OSError as e:
            print(f"atlandı: {f} ({e})", file=sys.stderr)
            continue
        try:
            d = json.loads(text)
            sessions.append(d if isinstance(d, dict) else {})
            continue
        except ValueError:
            pass
        got = _from_text(text, f)
        if not got:
            print(f"atlandı: {f} (oturum bulunamadı)", file=sys.stderr)
        sessions += got
    # Aynı oturum birden çok kez: en çok bölümlü kopya kalır
    by_id = {}
    for s in sessions:
        sid = s.get("id") or (s.get("started"), s.get("version"))
        sid = json.dumps(sid) if not isinstance(sid, str) else sid
        if sid in by_id and len(by_id[sid].get("chapters", [])) >= len(s.get("chapters", [])):
            continue
        by_id[sid] = s
    dup = len(sessions) - len(by_id)
    if dup:
        print(f"{dup} yinelenen oturum atlandı", file=sys.stderr)
    return list(by_id.values())


def report(sessions):
    by = collections.OrderedDict()
    for s in sessions:
        for seg in s.get("chapters", []):
            by.setdefault(seg.get("scene", "?"), []).append(seg)
    out = ["# Oyun testi sonuçları", "",
           f"{len(sessions)} oturum, {sum(len(v) for v in by.values())} bölüm kaydı. Puan 1-5 (anketi geçenler sayılmaz).", "",
           "| Bölüm | Oynayan | Puan | Süre (dk) | Bitiren / bırakan | Atlanan replik | Duraklatma | Sık sayaçlar |",
           "|---|---|---|---|---|---|---|---|"]
    notes = []
    for scene, segs in by.items():
        funs = [g["survey"]["fun"] for g in segs if isinstance(g.get("survey"), dict) and g["survey"].get("fun", 0) > 0]
        mins = [g.get("seconds", 0) / 60.0 for g in segs]
        done = sum(1 for g in segs if g.get("end") == "done")
        left = len(segs) - done
        skips = statistics.mean([g.get("skips", 0) for g in segs]) if segs else 0
        pauses = statistics.mean([g.get("pauses", 0) for g in segs]) if segs else 0
        cnt = collections.Counter()
        for g in segs:
            cnt.update(g.get("counters", {}))
        top = ", ".join(f"{k} {v / len(segs):.1f}" for k, v in cnt.most_common(3))
        fun = f"{statistics.mean(funs):.1f} ({len(funs)})" if funs else "-"
        out.append(f"| {scene} | {len(segs)} | {fun} | {statistics.mean(mins):.1f} | {done} / {left} | {skips:.1f} | {pauses:.1f} | {top} |")
        laughs = [g["survey"]["laugh"] for g in segs if isinstance(g.get("survey"), dict) and g["survey"].get("laugh")]
        bored = [g["survey"]["bored"] for g in segs if isinstance(g.get("survey"), dict) and g["survey"].get("bored")]
        quits = [g.get("last_objective", "") for g in segs if g.get("end") != "done" and g.get("last_objective")]
        if laughs or bored or quits:
            notes.append(f"## {scene}")
            notes += [f"- 😄 {t}" for t in laughs]
            notes += [f"- 😴 {t}" for t in bored]
            notes += [f"- 🚪 bırakıldı: {t}" for t in collections.Counter(quits)]
            notes.append("")
    return "\n".join(out + [""] + notes) + "\n"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("paths", nargs="+")
    ap.add_argument("-o", "--out")
    a = ap.parse_args()
    text = report(load(a.paths))
    if a.out:
        with open(a.out, "w", encoding="utf-8") as fh:
            fh.write(text)
        print(f"yazıldı: {a.out}")
    else:
        print(text)


if __name__ == "__main__":
    main()
