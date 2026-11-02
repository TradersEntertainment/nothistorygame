#!/usr/bin/env python3
"""Fragman kurgusu: trailer.tscn ya da gameplay.tscn'in yazısız kaydından ("-- clean") 16:9 fragman ve dikey
(1080x1920; Instagram Reels, TikTok, YouTube Shorts) kısalar. Yazılar oyunun kayıttaki satırlarından (TRAILER_SUB,
TRAILER_OVER, MONTAGE line/cap) ASS altyazı olarak basılır; oyunun yazı tipleri (assets/fonts) kullanılır.

  # 16:9 fragman (altyazı altta, üst yazı sol üstte)
  python3 tools/trailer/cut.py trailer HAM.avi HAM.log CIKTI.mp4
  # Dikey kısalar: fragmanın bölümlerinden (TRAILER_BEAT) ya da montaj pencerelerinden (MONTAGE seg ... id=)
  python3 tools/trailer/cut.py shorts HAM.avi HAM.log KLASOR [--only id,id] [--list]

Dikey yerleşim: arka planda aynı görüntü bulanık ve koyu; ortada (y 420) 1080x1080 kare kesit (1920x1080 kaydın
ortası, "x" ile kaydırılır); üstte kanca cümlesi, altta konuşanın adı ve büyük altyazı, sonda 2,6 sn kapanış kartı
(logo, "27 final", "Steam'de istek listene ekle") ve credits müziği.
"""
import argparse
import os
import re
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
FONTS = os.path.join(ROOT, "assets", "fonts")
LOGO = os.path.join(ROOT, "store", "library_logo.png")
MUSIC_END = os.path.join(ROOT, "assets", "audio", "music", "credits.ogg")
FPS = 30.0
END_CARD = 2.6
HOLD = 0.4          # son replikten sonra donuk kare (kart ondan sonra gelir)
MAX_TOTAL = 30.0    # Instagram/Shorts: kart dahil en çok 30 sn

# Kanca: ilk saniyede okunan, merak uyandıran tek cümle (espriyi ele vermez). [tr, en]
# beats: fragman bölümleri (trailer.gd _b_*); seg: montaj kesiti (montage.gd SHORT_CLIPS id); x: kare kesitin
# merkezden kayması (piksel, 1920 genişlikte; + sağa); trim: [baştan, sondan] atılan saniye.
# nosubs: oynanış montajı; kısa kesitte yarım kalan oyun içi replikler yazılmaz (ses kalır), yalnız üst yazı.
# keep: [[ilk, son], ...] kesitin içindeki replik sıraları (0'dan); yalnız bu replik grupları art arda eklenir
# (repliğin ortasından kesilmez). Kart dahil MAX_TOTAL'ı aşan kısa son replikten geriye doğru kısaltılır.
SHORTS = [
    {"id": "01_bu_benim", "beats": ["cold"], "hook": ["Muhtemelen 1453'e nasıl düştüğümü merak ediyorsunuz",
                                                     "You're probably wondering how I ended up in 1453"]},
    {"id": "02_tekme_lazim", "beats": ["garage", "slipway"], "hook": ["Zaman makinesi takıldı. Amcamın çözümü:",
                                                          "The time machine is stuck. My uncle's solution:"]},
    {"id": "03_sigortaci_ne", "beats": ["slipway"], "trim": [1.1, 0.0], "hook": ["Osmanlı ordusuna mesleğimi anlatmaya çalıştım",
                                                                      "I tried explaining my job to the Ottoman army"]},
    {"id": "04_sali_gunu", "beats": ["otag"], "hook": ["Fatih Sultan Mehmed bana kuşatmanın sonucunu sordu",
                                                       "Sultan Mehmed asked me how the siege ends"]},
    {"id": "05_buro_ucuyor", "beats": ["flight"], "hook": ["Zaman Bürosu denetçisi 1453 İstanbul'unun üstünde",
                                                           "A Time Bureau inspector over 1453 Constantinople"]},
    {"id": "06_kusatma", "beats": ["siege"], "hook": ["Kuşatmada iş kazası poliçeye dahil mi?",
                                                      "Does my policy cover a siege?"]},
    {"id": "07_buyuk_top", "beats": ["boom"], "hook": ["Dünyanın en büyük topu ateşlenmeden önce tek bir soru",
                                                       "One question before the world's biggest cannon fires"]},
    {"id": "08_vlad_kasko", "seg": "vlad_kasko", "keep": [[0, 5]], "hook": ["Kazıklı Voyvoda'ya kale sigortası satmaya çalıştım",
                                                          "I tried to sell castle insurance to Vlad the Impaler"]},
    {"id": "09_kusatma_haric", "seg": "giust_kusatma_haric", "keep": [[0, 4]], "hook": ["Surların komutanına savaş sigortası teklif ettim",
                                                                      "I offered war insurance to the wall commander"]},
    {"id": "10_gecici_tanik", "seg": "buro_madde9", "keep": [[0, 1], [3, 4]], "hook": ["Zaman Bürosu bana bir aylık iş teklif etti",
                                                             "The Time Bureau offered me a one-month job"]},
    {"id": "11_model_z0", "seg": "buro_kamera", "keep": [[0, 1], [3, 4]], "hook": ["Zaman Bürosu'nun resmî fotoğraf makinesi",
                                                         "The Time Bureau's official camera"]},
    {"id": "12_ters_kurek", "seg": "kayik_ters", "keep": [[0, 3], [5, 5]], "hook": ["Venedik kadırgasında kürek çektim. Bir sorun var.",
                                                          "I rowed a Venetian galley. One problem."]},
    {"id": "13_hikmet_1977", "seg": "hikmet_1977", "keep": [[2, 5]], "hook": ["1977'de genç amcama ilk poliçesini yazdım",
                                                            "In 1977 I wrote my young uncle his first policy"]},
    {"id": "14_iki_tunel", "seg": "tunel_police", "hook": ["İki düşman lağım, toprağın altında karşılaştı",
                                                           "Two enemy tunnels met underground"]},
    {"id": "16_oynanis_savas", "nosubs": True, "segs": ["duel", "cannon", "matchlock"], "hook": ["1453 kuşatmasında birinci şahıs: kılıç, top, tüfek",
                                                                               "First person in the 1453 siege: sword, cannon, matchlock"]},
    {"id": "17_oynanis_dunya", "nosubs": True, "segs": ["rowing", "flight", "city"], "hook": ["Haliç'te kürek çek, şehrin üstünde uç, 1453'ü gez",
                                                                             "Row the Golden Horn, fly over the city, walk 1453"]},
    {"id": "15_bogaz_gumruk", "seg": "bogaz_gumruk", "hook": ["1452, Boğaz'da ilk gümrük kapısı",
                                                              "1452: the first customs gate on the Bosphorus"]},
]

END_TEXT = {
    "tr": ["27 final · kuşatma iki taraftan · tamamen seslendirilmiş", "Steam'de istek listene ekle"],
    "en": ["27 endings · the siege from both sides · fully voiced", "Wishlist it on Steam"],
}


# ---------------------------------------------------------------- kayıt okuma

def kv(line):
    """'a=1 b=x text=serbest metin' → dict; text (ve spk) satır sonuna kadar alınır."""
    out = {}
    m = re.search(r"\btext=(.*)$", line)
    if m:
        out["text"] = m.group(1).strip()
        line = line[:m.start()]
    m = re.search(r"\bspk=(.*)$", line)
    if m:
        out["spk"] = m.group(1).strip()
        line = line[:m.start()]
    for k, v in re.findall(r"(\w+)=(\S+)", line):
        out[k] = v
    return out


def parse(log_path):
    beats, subs, overs, segs, en = [], [], [], [], False
    seg_id = {}
    open_seg = {}
    line_on = None
    last_f = 0
    with open(log_path, encoding="utf-8", errors="replace") as f:
        for raw in f:
            raw = raw.rstrip("\n")
            m = re.search(r"\b(?:f|frame)=(\d+)", raw)
            if m and (raw.startswith("TRAILER") or raw.startswith("MONTAGE")):
                last_f = max(last_f, int(m.group(1)))
            if raw.startswith("TRAILER_START"):
                en = "en=true" in raw
            elif raw.startswith("TRAILER_BEAT"):
                d = kv(raw)
                beats.append((d["name"], int(d["f"]) / FPS))
            elif raw.startswith("TRAILER_SUB"):
                d = kv(raw)
                t = int(d["f"]) / FPS
                subs.append({"t0": t, "t1": t + float(d["d"]), "spk": d.get("spk", ""), "col": d.get("col", "ffd24a"),
                             "text": d.get("text", "")})
            elif raw.startswith("TRAILER_OVER"):
                d = kv(raw)
                t = int(d["f"]) / FPS
                overs.append({"t0": t, "t1": t + float(d["d"]), "text": d.get("text", "").replace("|", "\\N")})
            elif raw.startswith("MONTAGE seg=") and " ok=" in raw:
                d = kv(raw)
                seg_id[int(d["seg"])] = d.get("id", "") or "seg%s" % d["seg"]
            elif re.match(r"MONTAGE (in|out) seg=", raw):
                d = kv(raw)
                n, fr = int(d["seg"]), int(d["frame"]) / FPS
                if raw.startswith("MONTAGE in"):
                    open_seg[n] = fr
                elif n in open_seg:
                    segs.append({"name": seg_id.get(n, "seg%d" % n), "t0": open_seg.pop(n), "t1": fr})
            elif raw.startswith("MONTAGE cap"):
                d = kv(raw)
                t = int(d["frame"]) / FPS
                overs.append({"t0": t, "t1": t + 2.85, "text": d.get("text", "").replace("|", "\\N")})
            elif raw.startswith("MONTAGE line on"):
                d = kv(raw)
                if line_on:
                    line_on["t1"] = int(d["frame"]) / FPS
                    subs.append(line_on)
                line_on = {"t0": int(d["frame"]) / FPS, "t1": None, "spk": d.get("spk", ""), "col": d.get("col", "ffd24a"),
                           "text": d.get("text", "")}
            elif raw.startswith("MONTAGE line off"):
                d = kv(raw)
                if line_on:
                    line_on["t1"] = int(d["frame"]) / FPS
                    subs.append(line_on)
                    line_on = None
            elif raw.startswith("MONTAGE out") and line_on:
                pass
    # Kayıt yarıda kesildiyse (zaman sınırı) açık kesit, kayıttaki son olayda biter
    for n, t0 in open_seg.items():
        segs.append({"name": seg_id.get(n, "seg%d" % n), "t0": t0, "t1": last_f / FPS, "cut": True})
    # Kapanmamış replik: pencerenin sonunda biter
    if line_on:
        line_on["t1"] = line_on["t0"] + 4.0
        subs.append(line_on)
    for s in subs:
        if s["t1"] is None:
            s["t1"] = s["t0"] + 3.0
    # Fragman bölümleri: bir sonrakinin başına dek
    for i, (name, t) in enumerate(beats):
        if name.startswith("_"):
            continue
        t1 = beats[i + 1][1] if i + 1 < len(beats) else None
        segs.append({"name": name, "t0": t, "t1": t1})
    return {"segs": segs, "subs": subs, "overs": overs, "en": en}


# ---------------------------------------------------------------- ASS

def ass_color(hexrgb, alpha=0):
    h = hexrgb.lstrip("#")[:6]
    r, g, b = h[0:2], h[2:4], h[4:6]
    return "&H%02X%s%s%s" % (alpha, b, g, r)


def ass_time(t):
    t = max(0.0, t)
    h = int(t // 3600)
    m = int(t % 3600 // 60)
    s = t % 60
    return "%d:%02d:%05.2f" % (h, m, s)


def esc(text):
    return text.replace("{", "(").replace("}", ")").replace("\n", "\\N")


def header(w, h, styles):
    out = ["[Script Info]", "ScriptType: v4.00+", "PlayResX: %d" % w, "PlayResY: %d" % h, "WrapStyle: 0",
           "ScaledBorderAndShadow: yes", "", "[V4+ Styles]",
           "Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, "
           "Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, "
           "MarginR, MarginV, Encoding"]
    for st in styles:
        out.append("Style: " + st)
    out += ["", "[Events]", "Format: Layer, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text"]
    return out


def ev(t0, t1, style, text, layer=0):
    return "Dialogue: %d,%s,%s,%s,,0,0,0,,%s" % (layer, ass_time(t0), ass_time(t1), style, text)


def strip_stage(text):
    """Baştaki sahne notunu ('(Daktiloya yazar) O makine...') at; videoda görünüyor. Tümü parantezse (iç ses) dokunma."""
    m = re.match(r"^\s*\([^()]*\)\s*(.+)$", text)
    return m.group(1) if m else text


def sub_text(s, name_size, text_size):
    name = s["spk"].strip()
    body = esc(strip_stage(s["text"]))
    if name:
        return "{\\fs%d\\c%s}%s\\N{\\fs%d\\c&HFFFFFF&}%s" % (name_size, ass_color(s["col"]), esc(name), text_size, body)
    return body


# ---------------------------------------------------------------- kurgu

def run(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True)
    if r.returncode != 0:
        sys.stderr.write(r.stderr[-3000:])
        raise SystemExit("ffmpeg hatası: " + " ".join(cmd[:6]))


def esc_path(p):
    return p.replace("\\", "/").replace(":", "\\:").replace("'", "\\'")


def join(raw, data, app_raw, app_data):
    """Yarıda kalan kayıt + kalan bölümlerin ayrı kaydı (trailer.gd only=boom,end): ilk kayıt, ekin ilk bölümünün
    başladığı yerde kesilir; ek oradan devam eder. → (birleşik veri, [(ham, t0, t1|None), ...])"""
    first = min((x for x in app_data["segs"]), key=lambda x: x["t0"])
    cut = next((x["t0"] for x in data["segs"] if x["name"] == first["name"]), None)
    if cut is None:
        raise SystemExit("ek kaydın ilk bölümü (%s) ilk kayıtta başlamamış" % first["name"])
    b0, sh = first["t0"], cut - first["t0"]

    def mv(items, a, b, d):
        out = []
        for x in items:
            if a - 0.05 <= x["t0"] < (b if b is not None else 1e9):
                y = dict(x)
                y["t0"] += d
                if y.get("t1") is not None:
                    y["t1"] = (min(y["t1"], b) if b is not None else y["t1"]) + d
                out.append(y)
        return out
    merged = {
        "subs": mv(data["subs"], 0.0, cut, 0.0) + mv(app_data["subs"], b0, None, sh),
        "overs": mv(data["overs"], 0.0, cut, 0.0) + mv(app_data["overs"], b0, None, sh),
        "segs": [x for x in data["segs"] if x["t0"] < cut and x["name"] != first["name"]] + mv(app_data["segs"], b0, None, sh),
        "en": data["en"],
    }
    return merged, [(raw, 0.0, cut), (app_raw, b0, None)]


def make_trailer(parts, data, out):
    """parts: [(ham, t0, t1|None), ...] art arda eklenir (tek kayıtta [(ham, 0, None)])."""
    lines = header(1920, 1080, [
        "Cap,Comfortaa,46,&H00FFFFFF,&H00FFFFFF,&H00000000,&H64000000,1,0,0,0,100,100,0,0,1,4,1,2,160,160,64,1",
        "Over,Alfa Slab One,84,&H00C9E6F2,&H00FFFFFF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,7,0,7,90,90,70,1",
    ])
    for s in data["subs"]:
        lines.append(ev(s["t0"], s["t1"], "Cap", sub_text(s, 32, 46)))
    for o in data["overs"]:
        lines.append(ev(o["t0"], o["t1"], "Over", esc(o["text"]) if "\\N" not in o["text"] else o["text"]))
    with tempfile.NamedTemporaryFile("w", suffix=".ass", delete=False, encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
        ass = f.name
    ins, fc = [], ""
    for i, (raw, t0, t1) in enumerate(parts):
        ins += ["-ss", "%.3f" % t0] + (["-t", "%.3f" % (t1 - t0)] if t1 is not None else []) + ["-i", raw]
        # Ek yerinde tık olmasın: parçaların ucunda çok kısa ses geçişi
        fa = "afade=t=in:d=0.06" if i > 0 else "anull"
        if t1 is not None:
            fa += ",afade=t=out:st=%.3f:d=0.06" % max(t1 - t0 - 0.06, 0.0)
        fc += "[%d:v]fps=30,setpts=PTS-STARTPTS[v%d];[%d:a]asetpts=PTS-STARTPTS,%s[a%d];" % (i, i, i, fa, i)
    fc += "".join("[v%d][a%d]" % (i, i) for i in range(len(parts))) + "concat=n=%d:v=1:a=1[cv][ca];" % len(parts)
    fc += "[cv]subtitles='%s':fontsdir='%s',format=yuv420p[vout];" % (esc_path(ass), esc_path(FONTS))
    fc += "[ca]loudnorm=I=-14:TP=-1.5:LRA=11,aresample=48000[aout]"
    run(["ffmpeg", "-v", "error", "-y"] + ins + ["-filter_complex", fc, "-map", "[vout]", "-map", "[aout]",
         "-c:v", "libx264", "-preset", "medium", "-crf", "18", "-c:a", "aac", "-b:a", "192k",
         "-movflags", "+faststart", out])
    os.unlink(ass)


def lines_in(data, r0, r1):
    """Pencerede başlayan replikler (öncekinden taşan ve son anda başlayan sayılmaz), zamana göre."""
    return sorted([x for x in data["subs"] if r0 - 0.1 <= x["t0"] < r1 - 0.5], key=lambda x: x["t0"])


def keep_ranges(data, r0, r1, keep):
    """[[ilk, son], ...] replik grupları → ham kayıtta pencereler. Grup bir sonraki replik başlamadan biter."""
    L = lines_in(data, r0, r1)
    out = []
    for i, j in keep:
        if not (0 <= i <= j < len(L)):
            print("  uyarı: keep [%d, %d]: kesitte %d replik var; grup atlandı" % (i, j, len(L)))
            continue
        a = r0 if i == 0 else L[i]["t0"] - 0.03
        # Bir sonraki replik (pencerede sayılmayan son anda başlayan dahil) başlamadan bit
        nxt = [x["t0"] for x in data["subs"] if x["t0"] > L[j]["t0"] + 0.05]
        b = min([r1, L[j]["t1"] + 0.25] + [t - 0.03 for t in nxt])
        out.append((a, b))
    return out


def fit(data, ranges, limit):
    """İçerik limit'i aşarsa sondan kısalt: son pencereyi, sığan son repliğin bitişinde kes."""
    total = sum(b - a for a, b in ranges)
    if total <= limit:
        return ranges
    ranges = [list(r) for r in ranges]
    while ranges and sum(b - a for a, b in ranges) > limit:
        a, b = ranges[-1]
        room = limit - sum(y - x for x, y in ranges[:-1])
        if room <= 1.0:
            ranges.pop()
            continue
        cut = a + room
        ends = [min(x["t1"], b) for x in lines_in(data, a, b) if x["t1"] <= cut]
        ranges[-1][1] = (max(ends) - 0.03) if ends else cut
    return [tuple(r) for r in ranges]


def make_short(raw, data, spec, ranges, out, lang):
    """ranges: [(t0, t1), ...] ham kayıtta art arda eklenen pencereler (montaj kesitleri ayrık olabilir)."""
    trim = spec.get("trim", [0.0, 0.0])
    ranges = [list(r) for r in ranges]
    ranges[0][0] += trim[0]
    ranges[-1][1] -= trim[1]
    before = sum(b - a for a, b in ranges)
    ranges = [list(r) for r in fit(data, ranges, MAX_TOTAL - END_CARD - HOLD)]
    if sum(b - a for a, b in ranges) < before - 0.01:
        print("  uyarı: %s %.1f sn → %.1f sn (sondan kısaltıldı; keep ile seçmek daha iyi)"
              % (spec["id"], before, sum(b - a for a, b in ranges)))
    # Ham zaman → kısadaki zaman: her pencerenin başı, öncekilerin toplam süresine kayar
    offs, acc = [], 0.0
    for r0, r1 in ranges:
        offs.append((r0, r1, acc - r0))
        acc += r1 - r0
    dur = acc               # ses biter
    vis = acc + HOLD        # son kare donuk kalır
    total = vis + END_CARD
    W, H, SQ, TOP = 1080, 1920, 1080, 420
    lines = header(W, H, [
        "Hook,Alfa Slab One,74,&H00FFFFFF,&H00FFFFFF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,6,0,8,60,60,110,1",
        "Cap,Comfortaa,58,&H00FFFFFF,&H00FFFFFF,&H00000000,&H64000000,1,0,0,0,100,100,0,0,1,5,1,8,50,50,1545,1",
        "Over,Alfa Slab One,64,&H00C9E6F2,&H00FFFFFF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,6,0,7,50,50,450,1",
        "Brand,Comfortaa,34,&H004AD2FF,&H00FFFFFF,&H00000000,&H00000000,1,0,0,0,100,100,0,0,1,3,0,2,40,40,46,1",
        "EndTag,Comfortaa,46,&H00FFFFFF,&H00FFFFFF,&H00000000,&H00000000,1,0,0,0,100,100,0,0,1,3,0,8,60,60,1000,1",
        "EndCta,Alfa Slab One,72,&H004AD2FF,&H00FFFFFF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,6,0,8,60,60,1110,1",
    ])
    hook = spec["hook"][1 if lang == "en" else 0]
    lines.append(ev(0.0, vis, "Hook", esc(hook)))
    lines.append(ev(0.0, vis, "Brand", "Gerçek Tarih Bu Değil" if lang == "tr" else "Not a History Game"))
    for r0, r1, sh in offs:
        for s in ([] if spec.get("nosubs") else data["subs"]):
            a, b = max(s["t0"], r0), min(s["t1"], r1)
            # Pencerenin son anında başlayan replik (kesimin payında) yazılmaz
            # Öncekinden taşan replik kuyruğu (pencere başında kısa an) da yazılmaz
            if b - a > 0.15 and s["t0"] < r1 - 0.5 and not (s["t0"] < r0 - 0.3 and b - a < 1.0):
                # Son pencerenin son repliği donuk karede de okunur
                if b >= r1 - 0.05 and r1 == offs[-1][1]:
                    b += HOLD
                lines.append(ev(a + sh, b + sh, "Cap", sub_text(s, 40, 58)))
        for o in data["overs"]:
            a, b = max(o["t0"], r0), min(o["t1"], r1)
            if b - a > 0.15:
                lines.append(ev(a + sh, b + sh, "Over", o["text"] if "\\N" in o["text"] else esc(o["text"])))
    tag, cta = END_TEXT[lang]
    lines.append(ev(vis, total, "EndTag", esc(tag)))
    lines.append(ev(vis + 0.25, total, "EndCta", esc(cta)))
    with tempfile.NamedTemporaryFile("w", suffix=".ass", delete=False, encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
        ass = f.name
    x = float(spec.get("x", 0.0))
    crop_x = "min(max((iw-%d)/2+%d\\,0)\\,iw-%d)" % (SQ, int(x), SQ)
    n = len(ranges)
    cat = "".join("[%d:v]fps=30,setpts=PTS-STARTPTS[cv%d];[%d:a]asetpts=PTS-STARTPTS[ca%d];" % (i, i, i, i) for i in range(n))
    cat += "".join("[cv%d][ca%d]" % (i, i) for i in range(n)) + "concat=n=%d:v=1:a=1[catv][cata];" % n
    fc = cat + (
        "[catv]tpad=stop_mode=clone:stop_duration=%.2f,split=2[v1][v2];"
        "[v1]scale=-2:%d,crop=%d:%d,gblur=sigma=28,eq=brightness=-0.22:saturation=0.75[bg];"
        "[v2]crop=%d:%d:%s:0[sq];"
        "[bg][sq]overlay=0:%d[b1];"
        "color=c=0x0d0f14:s=%dx%d:d=%.2f[card];"
        "[b1][card]overlay=0:0:enable='gte(t,%.2f)'[b2];"
        "[LOGO:v]crop=1130:400:80:180,scale=1000:-1[logo];"
        "[b2][logo]overlay=(W-w)/2:560:enable='gte(t,%.2f)'[b3];"
        "[b3]subtitles='%s':fontsdir='%s',format=yuv420p[vout];"
        "[cata]afade=t=out:st=%.2f:d=0.12,apad=whole_dur=%.2f[a0];"
        "[MUS:a]atrim=0:%.2f,afade=t=in:d=0.25,afade=t=out:st=%.2f:d=0.4,adelay=%d|%d,volume=0.85[a1];"
        "[a0][a1]amix=inputs=2:duration=first:normalize=0,loudnorm=I=-14:TP=-1.5:LRA=11,aresample=48000[aout]"
    ) % (HOLD + END_CARD, H, W, H, SQ, SQ, crop_x, TOP, W, H, total, vis, vis, esc_path(ass), esc_path(FONTS),
         max(dur - 0.12, 0.0), total, END_CARD, END_CARD - 0.4, int(vis * 1000), int(vis * 1000))
    fc = fc.replace("[LOGO:v]", "[%d:v]" % n).replace("[MUS:a]", "[%d:a]" % (n + 1))
    ins = []
    for r0, r1 in ranges:
        ins += ["-ss", "%.3f" % r0, "-t", "%.3f" % (r1 - r0), "-i", raw]
    run(["ffmpeg", "-v", "error", "-y"] + ins + ["-loop", "1", "-i", LOGO, "-i", MUSIC_END, "-filter_complex", fc, "-map", "[vout]", "-map", "[aout]", "-t", "%.3f" % total,
         "-c:v", "libx264", "-preset", "medium", "-crf", "19", "-r", "30", "-c:a", "aac", "-b:a", "160k",
         "-movflags", "+faststart", out])
    os.unlink(ass)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("mode", choices=["trailer", "shorts"])
    ap.add_argument("raw")
    ap.add_argument("log")
    ap.add_argument("out")
    ap.add_argument("--only", default="")
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--append", nargs=2, metavar=("HAM2", "KAYIT2"),
                    help="fragman: yarıda kalan kaydın devamı (trailer.gd only=boom,end ile çekilmiş)")
    ap.add_argument("--dry", action="store_true", help="kesmeden kısa sürelerini ve kalan replikleri yaz")
    a = ap.parse_args()
    data = parse(a.log)
    lang = "en" if data["en"] or a.log.endswith("_en.log") else "tr"
    if a.list:
        for s in data["segs"]:
            print("%-22s %7.2f → %s" % (s["name"], s["t0"], "%.2f" % s["t1"] if s["t1"] else "son"))
        return
    if a.mode == "trailer":
        parts = [(a.raw, 0.0, None)]
        if a.append:
            data, parts = join(a.raw, data, a.append[0], parse(a.append[1]))
            for raw, t0, t1 in parts:
                print("  parça: %s %.2f → %s" % (os.path.basename(raw), t0, "son" if t1 is None else "%.2f" % t1))
        make_trailer(parts, data, a.out)
        print("fragman:", a.out)
        return
    os.makedirs(a.out, exist_ok=True)
    only = set(x for x in a.only.split(",") if x)
    segs = {s["name"]: s for s in data["segs"]}
    made = 0
    for spec in SHORTS:
        if only and spec["id"] not in only:
            continue
        names = spec.get("beats") or spec.get("segs") or [spec.get("seg")]
        if not all(n in segs and segs[n]["t1"] is not None for n in names):
            continue
        # Fragman bölümleri art arda (tek pencere); montaj kesitleri ayrı pencereler
        if spec.get("beats"):
            ranges = [(segs[names[0]]["t0"], segs[names[-1]]["t1"])]
        else:
            # Oynanış kesitinin ilk karesi 3B yeniden açılırken gri çıkabiliyor (montage disable_3d): 0,1 sn atılır
            lead = 0.1 if spec.get("segs") else 0.0
            ranges = [(segs[n]["t0"] + lead, segs[n]["t1"]) for n in names]
        if spec.get("keep"):
            if len(ranges) != 1:
                raise SystemExit("%s: keep yalnız tek kesitte" % spec["id"])
            ranges = keep_ranges(data, ranges[0][0], ranges[0][1], spec["keep"])
        out = os.path.join(a.out, "%s_%s.mp4" % (spec["id"], lang))
        if a.dry:
            r = fit(data, [list(x) for x in ranges], MAX_TOTAL - END_CARD - HOLD)
            print("%-20s %5.1f sn  %s" % (spec["id"], sum(y - x for x, y in r) + HOLD + END_CARD,
                                          " + ".join("%.1f-%.1f" % (x, y) for x, y in r)))
            for x, y in r:
                for l in lines_in(data, x, y):
                    print("      %-12s %s" % (l["spk"][:12], l["text"][:70]))
            continue
        make_short(a.raw, data, spec, ranges, out, lang)
        print("kısa: %s" % out)
        made += 1
    print("toplam %d kısa" % made)


if __name__ == "__main__":
    main()
