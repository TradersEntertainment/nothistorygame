#!/usr/bin/env python3
"""Seslendirme telaffuz denetimi: her ses dosyasını konuşma tanımayla yazıya döker ve replik metniyle
karşılaştırır. "tek madde" yerine "tok madde" gibi yanlış okunan, yarıda kesilen ya da başka bir
repliğin sesi konmuş dosyaları bulur.

Kurulum (bir kez):   pip install faster-whisper
Çalıştırma:          python tools/voice_asr_check.py [--lang tr] [--model small] [--only D10A_]
Çıktı:               docs/voice/ASR_CHECK.csv ve docs/voice/REGEN_ASR.txt (benzerliği düşük olanlar)
Yeniden üretim:      python tools/voice_gen.py fix --list docs/voice/REGEN_ASR.txt

İlk çalıştırmada model indirilir (small ≈ 500 MB). Ekran kartı yoksa da çalışır; 1900 replik birkaç saat
sürebilir: --only ile bölüm bölüm (ör. --only D10A_,D5_) çalıştırılabilir.
"""
import argparse, csv, difflib, os, re, sys, unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def norm(t: str) -> str:
    t = re.sub(r"\[[^\]]*\]|\([^)]*\)", " ", t)       # ton etiketleri ve sahne notları okunmaz
    t = t.replace("I", "ı").replace("İ", "i").lower()
    t = unicodedata.normalize("NFC", t)
    t = re.sub(r"[^\w\s]", " ", t)
    return re.sub(r"\s+", " ", t).strip()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--lang", default="tr")
    ap.add_argument("--model", default="small")
    ap.add_argument("--only", default="")
    ap.add_argument("--min", type=float, default=0.72, help="bu benzerliğin altı yeniden üretim listesine girer")
    a = ap.parse_args()
    try:
        from faster_whisper import WhisperModel
    except ImportError:
        sys.exit("Önce: pip install faster-whisper")
    text = {}
    for r in csv.reader(open(os.path.join(ROOT, "i18n/strings.csv"), encoding="utf-8")):
        if len(r) >= 3:
            text[r[0]] = r[1] if a.lang == "tr" else r[2]
    vdir = os.path.join(ROOT, "assets/audio/voice", a.lang)
    files = sorted(f for f in os.listdir(vdir) if f.endswith(".mp3"))
    if a.only:
        files = [f for f in files if any(f.startswith(p) for p in a.only.split(","))]
    model = WhisperModel(a.model, device="auto", compute_type="int8")
    out, bad = [], []
    for i, fn in enumerate(files, 1):
        key = fn[:-4]
        want = norm(text.get(key, ""))
        if not want:
            continue
        segs, _ = model.transcribe(os.path.join(vdir, fn), language=a.lang, beam_size=3, vad_filter=True)
        heard = norm(" ".join(s.text for s in segs))
        sim = difflib.SequenceMatcher(None, want, heard).ratio()
        out.append([key, f"{sim:.2f}", want, heard])
        if sim < a.min:
            bad.append(key)
        print(f"[{i}/{len(files)}] {key}  {sim:.2f}" + ("  <-- " + heard if sim < a.min else ""))
    with open(os.path.join(ROOT, "docs/voice/ASR_CHECK.csv"), "w", encoding="utf-8", newline="") as f:
        w = csv.writer(f)
        w.writerow(["anahtar", "benzerlik", "metin", "duyulan"])
        w.writerows(sorted(out, key=lambda r: float(r[1])))
    open(os.path.join(ROOT, "docs/voice/REGEN_ASR.txt"), "w", encoding="utf-8").write("\n".join(bad) + "\n")
    print(f"\n{len(bad)} replik şüpheli. Liste: docs/voice/REGEN_ASR.txt  Tablo: docs/voice/ASR_CHECK.csv")


if __name__ == "__main__":
    main()
