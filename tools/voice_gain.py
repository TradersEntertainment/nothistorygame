#!/usr/bin/env python3
"""docs/voice/CONSISTENCY.csv (voice_consistency.py çıktısı) -> scripts/autoload/voice_gain.gd.

Her replik için bir seviye düzeltmesi (dB) üretir: kısık ya da bağıran kayıtlar konuşmacının kendi
ortancasına, konuşmacılar da oyunun genel seviyesine çekilir (sınırlı: replik ±6 dB, konuşmacı ±4 dB).
Oyun hud.say'de bu düzeltmeyi uygular.
"""
import csv, os, statistics

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
# Metni silinmiş replik (eski ses dosyası kalmış) tabloya girmez: anahtarı oyunda yok, check_keys onu eksik sayar
keys = {r[0] for r in csv.reader(open(os.path.join(ROOT, "i18n/strings.csv"), encoding="utf-8")) if r}


def table(csv_name):
    """Bir dilin ölçüm tablosundan replik başına düzeltme (dB)."""
    path = os.path.join(ROOT, "docs/voice", csv_name)
    if not os.path.exists(path):
        return {}, 0.0
    rows = [r for r in csv.DictReader(open(path, encoding="utf-8")) if r["anahtar"] in keys]
    by = {}
    for r in rows:
        by.setdefault(r["konusmaci"], []).append(float(r["seviye"]))
    allmed = statistics.median(float(r["seviye"]) for r in rows)
    gain = {}
    for r in rows:
        lv = float(r["seviye"])
        smed = statistics.median(by[r["konusmaci"]])
        g = max(-6.0, min(6.0, (smed - lv) * 0.8)) + max(-4.0, min(4.0, allmed - smed))
        if abs(g) >= 1.0:
            gain[r["anahtar"]] = round(g, 1)
    return gain, allmed


gain, allmed = table("CONSISTENCY.csv")
gain_en, allmed_en = table("CONSISTENCY_EN.csv")

lines = ["extends RefCounted", "class_name VoiceGain",
         "## Seslendirme seviye düzeltmesi (dB): tools/voice_consistency.py ölçümünden üretildi.",
         "## Kısık/bağıran kayıtlar konuşmacının ve oyunun genel seviyesine çekilir. Yeniden üretmek için:",
         "##     python3 tools/voice_consistency.py && python3 tools/voice_consistency.py --lang en && python3 tools/voice_gain.py",
         "## DB_EN: İngilizce kayıtların kendi ölçümü (İngilizce seslendirme ayrı üretildi; Tolga'nın EN kayıtları kısıktı).",
         "const DB := {"]
lines += ['\t"%s": %s,' % (k, gain[k]) for k in sorted(gain)]
lines += ["}", "const DB_EN := {"]
lines += ['\t"%s": %s,' % (k, gain_en[k]) for k in sorted(gain_en)]
lines.append("}")
lines += ["", "", "## Replik için düzeltme (dB), o anki dile göre.",
          "static func db(key: String) -> float:",
          "\tif TranslationServer.get_locale().begins_with(\"en\") and not DB_EN.is_empty():",
          "\t\treturn DB_EN.get(key, 0.0)",
          "\treturn DB.get(key, 0.0)"]
open(os.path.join(ROOT, "scripts/autoload/voice_gain.gd"), "w", encoding="utf-8").write("\n".join(lines) + "\n")
print(f"TR: genel ortanca {allmed:.1f} dB, {len(gain)} replik düzeltildi")
print(f"EN: genel ortanca {allmed_en:.1f} dB, {len(gain_en)} replik düzeltildi")
