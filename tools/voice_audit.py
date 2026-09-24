#!/usr/bin/env python3
"""Ses denetimi: oyunda gerçekten kimin hangi repliği söylediğini ses haritasıyla (VOICE_MAP.csv) karşılaştırır.

Oyun VOICE_AUDIT=1 ortam değişkeniyle çalışınca her replikte "VOICEAUDIT|SPK_X|ANAHTAR" yazar (hud.gd).
Bütün otomatik test yolları bu değişkenle oynatılıp çıktıları bir klasöre toplanır, sonra:

    python3 tools/voice_audit.py <log klasörü>

1. docs/voice/SPEAKERS_SEEN.csv: oyunda görülen gerçek konuşmacılar (voice_map.py bunu her şeyin önüne koyar)
2. docs/voice/FIX_LIST.txt: ses haritasındaki konuşmacısı yanlış olduğu için yanlış sesle üretilmiş replikler
   (python tools/voice_gen.py fix bunları doğru sesle yeniden üretir)
"""
import collections, csv, glob, json, os, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SEEN = os.path.join(ROOT, "docs/voice/SPEAKERS_SEEN.csv")
FIX = os.path.join(ROOT, "docs/voice/FIX_LIST.txt")
cast = json.load(open(os.path.join(ROOT, "docs/voice/cast.json"), encoding="utf-8"))


def voice_of(spk: str) -> str:
    """same_as zincirini izleyip sesin sahibini bulur (aynı sesi paylaşan karakterler birbirinin yerine geçebilir)."""
    seen = set()
    while spk in cast and cast[spk].get("same_as") and spk not in seen:
        seen.add(spk)
        spk = cast[spk]["same_as"]
    return spk


def main():
    if len(sys.argv) < 2:
        sys.exit(__doc__)
    said = collections.defaultdict(collections.Counter)
    for path in glob.glob(os.path.join(sys.argv[1], "*.log")):
        for line in open(path, encoding="utf-8", errors="ignore"):
            if line.startswith("VOICEAUDIT|"):
                _, spk, key = line.strip().split("|", 2)
                if " " not in key and key:
                    said[key][spk] += 1
    # Eski kayıtları koru (bu koşuda görülmeyen yollar), yenileri üstüne yaz
    truth = {}
    if os.path.exists(SEEN):
        for r in csv.DictReader(open(SEEN, encoding="utf-8")):
            truth[r["anahtar"]] = r["konusmaci"]
    multi = []
    for key, c in said.items():
        spk, _ = c.most_common(1)[0]
        truth[key] = spk
        if len({voice_of(s) for s in c}) > 1:
            multi.append((key, dict(c)))
    with open(SEEN, "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["anahtar", "konusmaci"])
        for k in sorted(truth):
            w.writerow([k, truth[k]])

    rows = list(csv.DictReader(open(os.path.join(ROOT, "docs/voice/VOICE_MAP.csv"), encoding="utf-8")))
    have = lambda k: os.path.exists(os.path.join(ROOT, "assets/audio/voice/tr", k + ".mp3"))
    wrong = []
    for r in rows:
        k = r["anahtar"]
        if k in truth and voice_of(truth[k]) != voice_of(r["konusmaci"]):
            wrong.append((k, r["konusmaci"], truth[k], have(k)))
    fix = sorted(k for k, _, _, h in wrong if h)
    with open(FIX, "w", encoding="utf-8") as f:
        f.write("\n".join(fix) + ("\n" if fix else ""))

    print(f"Görülen replik: {len(said)} (toplam kayıt {len(truth)}) · haritada yanlış konuşmacı: {len(wrong)} "
          f"· yeniden üretilecek ses dosyası: {len(fix)}")
    by = collections.Counter((m, t) for _, m, t, _ in wrong)
    for (m, t), n in by.most_common():
        print(f"  {n:4d}  haritada {m:18s} -> oyunda {t}")
    if multi:
        print("Aynı repliği farklı seslerle söyleyenler (koşula göre konuşmacı değişiyor):")
        for k, c in sorted(multi):
            print("   ", k, c)
    unseen = [r["anahtar"] for r in rows if r["anahtar"] not in truth and r.get("kaynak") == "ad"]
    print(f"Testlerde hiç duyulmayan, konuşmacısı addan tahmin edilen replik: {len(unseen)}")


if __name__ == "__main__":
    main()
