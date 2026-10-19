#!/usr/bin/env python3
"""Karakter ses kuralları (v0.99.21): konuşmacısına göre repliğin ağzına yakışmayan kelimeleri yakalar.

Konuşmacı docs/voice/VOICE_MAP.csv'den, metin i18n/strings.csv'den (tr) okunur.
  - Hristiyan karakterler (Rum, Ceneviz, Venedik, Macar, Sırp): İslami yemin ve dua yok (vallahi, inşallah, maşallah,
    Allah, helal olsun, hazretleri, mihrap, şükür (Tanrı'ya şükür hariç)...)
  - Niko "lan" demez; Fatih, İmparator, Halil, Zağanos "bre" demez (vakar)
  - Seçenekler (UI_C*) 60 karakteri geçmez
Kasıtlı istisnalar IZIN listesinde (gerekçesiyle).
"""
import csv, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

CHRISTIAN = {"SPK_NIKO", "SPK_EMPEROR", "SPK_GIUST", "SPK_THEODOROS", "SPK_GENOESE", "SPK_URBAN", "SPK_PRIEST",
             "SPK_ISIDORE", "SPK_GRANT", "SPK_TREVISANO", "SPK_BRIG", "SPK_DEFENDER", "SPK_COCO", "SPK_LOOKOUT",
             "SPK_RIZZO", "SPK_NOTARAS", "SPK_CATTANEO", "SPK_BAILO", "SPK_PODESTA", "SPK_HUNGARIAN", "SPK_MONK",
             "SPK_NOVOMINER", "SPK_MINER", "SPK_PAINTER", "SPK_WINE", "SPK_NOTARY", "SPK_TAILOR", "SPK_VLAD", "SPK_RADU"}
OATH = re.compile(r"\b(vallahi|valla|billahi|inşallah|maşallah|allah|elhamdülillah|bismillah|helal olsun|hakkını helal|"
                  r"hazretleri|hazretlerine|mihrap|vesselam|mübarek|şükür)\b", re.I)
SAFE = re.compile(r"tanrı'?ya şükür", re.I)
NO_BRE = {"SPK_FATIH", "SPK_EMPEROR", "SPK_HALIL", "SPK_ZAGANOS"}

# anahtar: gerekçe
IZIN = {
    "D19O_C_WISH": "Venedikli kaptan Türk kılığında; 'Allah razı olsun' kılığını korumak için söyleniyor",
}


def main() -> int:
    spk = {r["anahtar"]: r["konusmaci"] for r in csv.DictReader(open(os.path.join(ROOT, "docs/voice/VOICE_MAP.csv"), encoding="utf-8"))}
    rows = list(csv.DictReader(open(os.path.join(ROOT, "i18n/strings.csv"), encoding="utf-8")))
    bad = []
    for r in rows:
        k, t = r["keys"], r.get("tr", "")
        if k in IZIN or not t:
            continue
        s = spk.get(k, "")
        if s in CHRISTIAN:
            m = OATH.search(SAFE.sub("", t))
            if m:
                bad.append(f"{k} [{s}] '{m.group(0)}': {t[:90]}")
        if s == "SPK_NIKO" and re.search(r"\blan\b", t, re.I):
            bad.append(f"{k} [{s}] 'lan': {t[:90]}")
        if s in NO_BRE and re.search(r"\bbre\b", t, re.I):
            bad.append(f"{k} [{s}] 'bre': {t[:90]}")
        if re.match(r"UI_C\d", k) and len(t) > 60:
            bad.append(f"{k} seçenek {len(t)} karakter (en çok 60): {t}")
    for b in bad:
        print("VOICERULE", b)
    print(f"VOICERULES {'PASS' if not bad else 'FAIL'} ({len(rows)} anahtar, {len(bad)} sorun)")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
