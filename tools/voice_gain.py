#!/usr/bin/env python3
"""docs/voice/CONSISTENCY.csv (voice_consistency.py çıktısı) -> scripts/autoload/voice_gain.gd.

Her replik için bir seviye düzeltmesi (dB) üretir: kısık ya da bağıran kayıtlar konuşmacının kendi
ortancasına, konuşmacılar da oyunun genel seviyesine çekilir (sınırlı: replik ±6 dB, konuşmacı ±4 dB).
Oyun hud.say'de bu düzeltmeyi uygular.
"""
import csv, json, os, re, statistics, subprocess
from concurrent.futures import ThreadPoolExecutor

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


PEAK_CEIL = 1.0      # yükseltilen replik tepesi en çok +1 dBFS: çıkıştaki sınırlayıcı bu kadarını duyulmadan alır; fazlası
                     # (ses denetimi: D7_KADRI_HELLO +1,7) sınırlayıcıda ezilir. Daha sıkı sınır 1100 kısık repliği kısık bırakıyordu


def peaks(lang, keys_):
    """Dosyaların tepe düzeyi (dBFS); docs/voice/.peaks_<dil>.json'da boyut+zamanla önbelleklenir."""
    cache_p = os.path.join(ROOT, f"docs/voice/.peaks_{lang}.json")
    cache = json.load(open(cache_p)) if os.path.exists(cache_p) else {}
    def one(k):
        f = os.path.join(ROOT, "assets/audio/voice", lang, k + ".mp3")
        if not os.path.exists(f):
            return k, None, None
        sig = f"{os.path.getsize(f)}:{int(os.path.getmtime(f))}"
        if k in cache and cache[k][0] == sig:
            return k, sig, cache[k][1]
        e = subprocess.run(["ffmpeg", "-hide_banner", "-nostats", "-i", f, "-af", "volumedetect", "-f", "null", "-"],
                           capture_output=True, text=True).stderr
        m = re.search(r"max_volume: (-?[\d.]+)", e)
        return k, sig, float(m.group(1)) if m else None
    with ThreadPoolExecutor(os.cpu_count() or 4) as ex:
        res = list(ex.map(one, keys_))
    for k, sig, pk in res:
        if sig and pk is not None:
            cache[k] = [sig, pk]
    json.dump(cache, open(cache_p, "w"))
    return {k: pk for k, _s, pk in res if pk is not None}


def cap(gain, lang):
    """Yükseltmeyi dosyanın tepesine göre sınırla: tepe + düzeltme <= PEAK_CEIL."""
    up = [k for k, g in gain.items() if g > 0]
    pk = peaks(lang, up)
    n = 0
    for k in up:
        if k in pk and pk[k] + gain[k] > PEAK_CEIL:
            gain[k] = round(PEAK_CEIL - pk[k], 1)
            n += 1
            if abs(gain[k]) < 1.0:
                del gain[k]
    return n


gain, allmed = table("CONSISTENCY.csv")
gain_en, allmed_en = table("CONSISTENCY_EN.csv")
capped = cap(gain, "tr"), cap(gain_en, "en")

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
print(f"Tepe sınırı ({PEAK_CEIL} dBFS): {capped[0]} Türkçe, {capped[1]} İngilizce yükseltme kısıldı")
