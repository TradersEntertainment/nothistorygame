#!/usr/bin/env python3
"""Replik haritası: her diyalog satırının hangi karakterin ağzından çıktığını bulur.

Kaynaklar:
  1. Oyun kodundaki doğrudan çağrılar: _say("SPK_X", "ANAHTAR"), hud.say(...), hud.bark(...), _say_fmt(...)
  2. Yardımcılar: _t("..."), _h("..."), _n("..."), _m("...") — her dosyada tanımına bakılarak çözülür
  3. Kodda değişkenle kurulan anahtarlar (örn. "D6_%s_HELLO" % key): anahtar adındaki karakter kısaltmasından
Çıktı: docs/voice/VOICE_MAP.csv (anahtar, bölüm, konuşmacı, TR, EN, kaynak) ve özet.
Kullanım: python3 tools/voice_map.py
"""
import csv, glob, os, re, collections

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
rows = list(csv.reader(open(os.path.join(ROOT, "i18n/strings.csv"), encoding="utf-8")))
text = {r[0]: (r[1], r[2]) for r in rows[1:] if len(r) >= 3}

speaker = {}
source = {}
direct = re.compile(r'(?:_say|hud\.say|hud\.bark|_say_fmt)\(\s*"(SPK_[A-Z0-9_]+)"\s*,\s*"([A-Z0-9_]+)"')
helper_def = re.compile(r'^func (_[a-z])\(key: String\).*?\n\s*await hud\.say\("(SPK_[A-Z0-9_]+)", key\)', re.M)
for path in sorted(glob.glob(os.path.join(ROOT, "scripts/*.gd"))):
    src = open(path, encoding="utf-8").read()
    helpers = dict(helper_def.findall(src))
    for spk, key in direct.findall(src):
        speaker.setdefault(key, spk); source.setdefault(key, "kod")
    # Listelerde [konuşmacı, anahtar] çiftleri ve aynı satırdaki "A" if x else "B" seçenekleri
    for spk, key in re.findall(r'\["(SPK_[A-Z0-9_]+)",\s*"([A-Z0-9_]+)"\]', src):
        speaker.setdefault(key, spk); source.setdefault(key, "kod")
    for line in src.splitlines():
        m = re.search(r'(?:_say|hud\.say|hud\.bark)\(\s*"(SPK_[A-Z0-9_]+)"\s*,(.*)', line)
        if m:
            for key in re.findall(r'"([A-Z][A-Z0-9_]+)"', m.group(2)):
                if key in text:
                    speaker.setdefault(key, m.group(1)); source.setdefault(key, "kod")
    for h, spk in helpers.items():
        for key in re.findall(re.escape(h) + r'\("([A-Z0-9_]+)"', src):
            speaker.setdefault(key, spk); source.setdefault(key, "kod")

# Anahtar adındaki kısaltmadan konuşmacı (bölüme göre anlamı değişenler ayrıca)
TOKENS = {
    "T": "SPK_TOLGA", "H": "SPK_HIKMET", "H2": "SPK_HIKMET", "KADRI": "SPK_KADRI", "LUTFI": "SPK_LUTFI",
    "URBAN": "SPK_URBAN", "GIUST": "SPK_GIUST", "GIUSTINIANI": "SPK_GIUST", "NIKO": "SPK_NIKO", "EMP": "SPK_EMPEROR",
    "EMPEROR": "SPK_EMPEROR", "THEO": "SPK_THEODOROS", "THEODOROS": "SPK_THEODOROS", "C": "SPK_CLERK",
    "HASAN": "SPK_HASAN", "HUSEYIN": "SPK_HUSEYIN", "GUARDS": "SPK_HASAN", "M": "SPK_MUFIDE", "R": "SPK_RIZA",
    "V": "SPK_VAN", "A1": "SPK_AGENT1", "A2": "SPK_AGENT2", "A": "SPK_AGENT1", "P": "SPK_PASHA", "S": "SPK_SOLDIER",
    "G": "SPK_HASAN", "K": "SPK_KADRI", "F": "SPK_FATIH", "CAMELEER": "SPK_CAMELEER", "DERVISH": "SPK_DERVISH",
    "TAILOR": "SPK_TAILOR", "CEMIL": "SPK_CEMIL", "B": "SPK_BUREAU_RADIO",
}
PER_CHAPTER = {  # bölüme özgü kısaltmalar
    "3": {"N": "SPK_NIHAT"}, "7": {"N": "SPK_NIHAT", "C": "SPK_CANDARLI"}, "6A": {"C": "SPK_CANDARLI"},
    "6B": {"N": "SPK_NIKO", "E": "SPK_EMPEROR", "G": "SPK_GIUST"}, "4B": {"N": "SPK_NIKO"}, "4": {"N": "SPK_NIKO"},
    "8": {"C": "SPK_CEMIL", "N": "SPK_NIHAT", "A": "SPK_AGENT1"}, "9": {"C": "SPK_CANDARLI"},
    "10O": {"A": "SPK_AGA", "G": "SPK_HASAN"},
}
for key in text:
    m = re.match(r"^D(\d+[A-Z]?)_([A-Z0-9]+)_", key)
    if not m or key in speaker:
        continue
    ch, tok = m.group(1), m.group(2)
    spk = PER_CHAPTER.get(ch, {}).get(tok) or PER_CHAPTER.get(re.sub(r"[A-Z]$", "", ch), {}).get(tok) or TOKENS.get(tok)
    if spk:
        speaker[key] = spk; source[key] = "ad"

out_dir = os.path.join(ROOT, "docs/voice")
os.makedirs(out_dir, exist_ok=True)
lines = []
for key, (tr, en) in text.items():
    if not re.match(r"^D\d", key) and key not in speaker:
        continue
    if not key in speaker and not re.match(r"^D\d", key):
        continue
    ch = re.match(r"^D(\d+)", key)
    lines.append([key, ch.group(1) if ch else "", speaker.get(key, "?"), tr, en, source.get(key, "bulunamadı")])
lines.sort(key=lambda r: (int(r[1] or 0), r[0]))
with open(os.path.join(out_dir, "VOICE_MAP.csv"), "w", encoding="utf-8", newline="") as f:
    w = csv.writer(f)
    w.writerow(["anahtar", "bolum", "konusmaci", "tr", "en", "kaynak"])
    w.writerows(lines)
per = collections.Counter(); chars = collections.Counter()
for r in lines:
    per[r[2]] += 1; chars[r[2]] += len(r[3])
print("Toplam replik:", len(lines), "· TR karakter:", sum(chars.values()), "· konuşmacısı bulunamayan:", per["?"])
for spk, n in per.most_common():
    print(f"  {spk:22s} {n:4d} replik  {chars[spk]:6d} karakter")
