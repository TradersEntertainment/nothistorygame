#!/usr/bin/env python3
"""Replik haritası: her diyalog satırının hangi karakterin ağzından çıktığını bulur.

Kaynaklar:
  1. Oyun kodundaki doğrudan çağrılar: _say("SPK_X", "ANAHTAR"), hud.say(...), hud.bark(...), _say_fmt(...)
  2. Yardımcılar: _t("..."), _h("..."), _n("..."), _m("...") — her dosyada tanımına bakılarak çözülür
  3. Kodda değişkenle kurulan anahtarlar (örn. "D6_%s_HELLO" % key): anahtar adındaki karakter kısaltmasından
Çıktı: docs/voice/VOICE_MAP.csv (anahtar, bölüm, konuşmacı, ton, ton_elle, TR, EN, kaynak) ve özet.
  ton: ElevenLabs v3 ses etiketi ([whispers], [panicked] ...). Elle değiştirdiğin satırda ton_elle=1 yap;
  script yeniden çalışınca o satırın tonu korunur.
Kullanım: python3 tools/voice_map.py
"""
import csv, glob, os, re, collections

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
rows = list(csv.reader(open(os.path.join(ROOT, "i18n/strings.csv"), encoding="utf-8")))
text = {r[0]: (r[1], r[2]) for r in rows[1:] if len(r) >= 3}

speaker = {}
source = {}
direct = re.compile(r'(?:_say|hud\.say|hud\.bark|_say_fmt)\(\s*"(SPK_[A-Z0-9_]+)"\s*,\s*"([A-Z0-9_]+)"')
helper_def = re.compile(r'^func (_[a-z]+)\(key: String\)[^\n]*\n(?:[^\n]*\n){0,3}?\s*await (?:hud\.say|_say)\("(SPK_[A-Z0-9_]+)", key\)', re.M)
for path in sorted(glob.glob(os.path.join(ROOT, "scripts/**/*.gd"), recursive=True)):
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
    "9": {"C": "SPK_CANDARLI", "MINER": "SPK_MINER"},
    "10A": {"N": "SPK_NIHAT", "TH": "SPK_THEODOROS"}, "10B": {"U": "SPK_URBAN"},
    "10G": {"W": "SPK_WINE", "N": "SPK_NOTARY", "D": "SPK_DOUBLE", "F": "SPK_FISHMONGER"},
    "10L": {"D": "SPK_MINER"}, "11": {"N": "SPK_NIHAT"}, "14": {"N": "SPK_NIHAT"}, "15": {"N": "SPK_NIHAT", "O": "SPK_MANAGER"},
}
# 12. bölüm sonları: chapter12.gd _end_speaker tablosu (1. ve 3. replik Fatih, 2. replik Tolga; 12.6'da Hikmet)
END12 = re.compile(r"^D12_END_(\d+)_(\d+)_(\d)$")
# 15. bölüm iş arkadaşları: D15_O_<dünya>_A / _B
CO15 = re.compile(r"^D15_O_W\d+B?_(A|B)$")
# Eşya replikleri (bölüm 0): eşya tepkileri (hud.gd REACT_CHARS), Tolga'nın eşya cümleleri, Hikmet'in çanta cümleleri
REACT_SPK = {"HIKMET": "SPK_HIKMET", "GUARDS": "SPK_HASAN", "KADRI": "SPK_KADRI", "LUTFI": "SPK_LUTFI", "URBAN": "SPK_URBAN",
             "AGA": "SPK_AGA", "FATIH": "SPK_FATIH", "NIHAT": "SPK_NIHAT", "NIKO": "SPK_NIKO", "EMPEROR": "SPK_EMPEROR",
             "GIUST": "SPK_GIUST", "THEODOROS": "SPK_THEODOROS", "TAILOR": "SPK_TAILOR", "PASHA": "SPK_PASHA",
             "DERVISH": "SPK_DERVISH", "CAMELEER": "SPK_CAMELEER", "MINER": "SPK_MINER", "SOLDIER": "SPK_SOLDIER",
             "CANDARLI": "SPK_CANDARLI", "CLERK": "SPK_CLERK", "WINE": "SPK_WINE", "NOTARY": "SPK_NOTARY",
             "DOUBLE": "SPK_DOUBLE", "FISHMONGER": "SPK_FISHMONGER", "CALLIGRAPHER": "SPK_CALLIGRAPHER",
             "PAINTER": "SPK_PAINTER", "KID": "SPK_KID"}
for key in text:
    if key in speaker:
        continue
    r = re.match(r"^REACT_([A-Z]+)_", key)
    if r and r.group(1) in REACT_SPK:
        speaker[key] = REACT_SPK[r.group(1)]; source[key] = "eşya"
    elif re.match(r"^ITEM_(SELF|SHOW)_", key):
        speaker[key] = "SPK_TOLGA"; source[key] = "eşya"
    elif key.startswith("HIKMET_ITEM_"):
        speaker[key] = "SPK_HIKMET"; source[key] = "eşya"
    elif re.match(r"^QUEST_[A-Z]+_DONE$", key) or key.startswith(("D_CHICKEN_CATCH_", "MG_HAG_T_")):
        speaker[key] = "SPK_TOLGA"; source[key] = "görev"
    elif key.startswith(("NPC_CALLIGRAPHER_", "NPC_PAINTER_", "NPC_KID_")):
        speaker[key] = {"C": "SPK_CALLIGRAPHER", "P": "SPK_PAINTER", "K": "SPK_KID"}[key[4]]; source[key] = "yan karakter"
    elif key.startswith(("D_EV_", "D_CAT_")):
        speaker[key] = "SPK_TOLGA"; source[key] = "görev"
    elif key.startswith("MG_CAUL_K_"):
        speaker[key] = "SPK_KADRI"; source[key] = "mini oyun"
    elif key.startswith("MG_MAN_E_"):
        speaker[key] = "SPK_EMPEROR"; source[key] = "mini oyun"
    elif key.startswith("MG_ARC_H_"):
        speaker[key] = "SPK_HASAN"; source[key] = "mini oyun"
    elif key.startswith("MG_CAUL_T_"):
        speaker[key] = "SPK_TOLGA"; source[key] = "mini oyun"
    elif re.match(r"^MG_HAG_(WINE|DOUBLE|URBAN|NIKO)_(OPEN|LOW|FAIR|SWEET|NOSWEET|WIN|DEAL|LOSE)$", key):
        speaker[key] = {"WINE": "SPK_WINE", "DOUBLE": "SPK_DOUBLE", "URBAN": "SPK_URBAN", "NIKO": "SPK_NIKO"}[key.split("_")[2]]
        source[key] = "mini oyun"

for key in text:
    e = END12.match(key)
    if e and key not in speaker:
        speaker[key] = "SPK_FATIH" if e.group(3) != "2" else ("SPK_HIKMET" if e.group(2) == "6" else "SPK_TOLGA")
        source[key] = "tablo"; continue
    o = CO15.match(key)
    if o and key not in speaker:
        speaker[key] = "SPK_COWORKER_" + o.group(1); source[key] = "tablo"; continue
    m = re.match(r"^D(\d+[A-Z]?)_([A-Z0-9]+)_", key)
    if not m or key in speaker:
        continue
    ch, tok = m.group(1), m.group(2)
    spk = PER_CHAPTER.get(ch, {}).get(tok) or PER_CHAPTER.get(re.sub(r"[A-Z]$", "", ch), {}).get(tok) or TOKENS.get(tok)
    if spk:
        speaker[key] = spk; source[key] = "ad"

# Ton (ElevenLabs v3 ses etiketi): önce elle yazılmış olan korunur, yoksa sahne notundan ve noktalamadan tahmin edilir.
TONE_RULES = [
    (r"fısıl|alçak sesle|kulağına", "[whispers]"), (r"bağır|haykır|gürle", "[shouting]"),
    (r"kahkaha|güler|gülümse|kıkır", "[laughs]"), (r"iç çek|of çek", "[sighs]"),
    (r"ağla|gözleri dol|hıçkır|sesi titre", "[sad]"), (r"panik|telaş|kekele", "[panicked]"),
    (r"kız[ae]r|öfke|sinir", "[angry]"), (r"alay|iğnele|ironi", "[sarcastic]"),
    (r"heyecan|coşku|sevin", "[excited]"), (r"kork|ürk|titre", "[scared]"),
    (r"yutkun|tereddüt|duraksa", "[hesitant]"), (r"esne|uykulu|mırıl", "[tired]"),
    (r"resmî|tören|mühür vur", "[formal]")
]
def guess_tone(tr: str) -> str:
    notes = " ".join(re.findall(r"\(([^)]*)\)", tr)).lower()
    for pat, tag in TONE_RULES:
        if re.search(pat, notes):
            return tag
    body = re.sub(r"\([^)]*\)", "", tr)
    if "!!" in body or "?!" in body or (body.count("!") >= 2 and len(body) < 90):
        return "[shouting]"
    if body.strip().endswith("!"):
        return "[excited]"
    if body.count("...") + body.count("…") >= 2:
        return "[hesitant]"
    return ""

out_dir = os.path.join(ROOT, "docs/voice")
os.makedirs(out_dir, exist_ok=True)
old_tone = {}
if os.path.exists(os.path.join(out_dir, "VOICE_MAP.csv")):
    for r in csv.DictReader(open(os.path.join(out_dir, "VOICE_MAP.csv"), encoding="utf-8")):
        if r.get("ton_elle") == "1":
            old_tone[r["anahtar"]] = r.get("ton", "")
lines = []
for key, (tr, en) in text.items():
    if not re.match(r"^D\d", key) and key not in speaker:
        continue
    if not key in speaker and not re.match(r"^D\d", key):
        continue
    ch = re.match(r"^D(\d+)", key)
    tone, manual = (old_tone[key], "1") if key in old_tone else (guess_tone(tr), "0")
    lines.append([key, ch.group(1) if ch else "", speaker.get(key, "?"), tone, manual, tr, en, source.get(key, "bulunamadı")])
lines.sort(key=lambda r: (int(r[1] or 0), r[0]))
with open(os.path.join(out_dir, "VOICE_MAP.csv"), "w", encoding="utf-8", newline="") as f:
    w = csv.writer(f)
    w.writerow(["anahtar", "bolum", "konusmaci", "ton", "ton_elle", "tr", "en", "kaynak"])
    w.writerows(lines)
per = collections.Counter(); chars = collections.Counter()
for r in lines:
    per[r[2]] += 1; chars[r[2]] += len(r[5])
print("Toplam replik:", len(lines), "· TR karakter:", sum(chars.values()), "· konuşmacısı bulunamayan:", per["?"])
for spk, n in per.most_common():
    print(f"  {spk:22s} {n:4d} replik  {chars[spk]:6d} karakter")
