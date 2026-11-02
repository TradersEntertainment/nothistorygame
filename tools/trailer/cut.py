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

# Kanca: ilk saniyede okunan, merak uyandıran tek cümle (espriyi ele vermez). [tr, en]
# beats: fragman bölümleri (trailer.gd _b_*); seg: montaj kesiti (montage.gd SHORT_CLIPS id); x: kare kesitin
# merkezden kayması (piksel, 1920 genişlikte; + sağa); trim: [baştan, sondan] atılan saniye.
SHORTS = [
    {"id": "01_bu_benim", "beats": ["cold"], "hook": ["Muhtemelen 1453'e nasıl düştüğümü merak ediyorsunuz",
                                                     "You're probably wondering how I ended up in 1453"]},
    {"id": "02_tekme_lazim", "beats": ["garage"], "hook": ["Zaman makinesi takıldı. Amcamın çözümü:",
                                                          "The time machine is stuck. My uncle's solution:"]},
    {"id": "03_sigortaci_ne", "beats": ["world", "slipway"], "hook": ["Osmanlı ordusuna mesleğimi anlatmaya çalıştım",
                                                                      "I tried explaining my job to the Ottoman army"]},
    {"id": "04_sali_gunu", "beats": ["otag"], "hook": ["Fatih Sultan Mehmed bana kuşatmanın sonucunu sordu",
                                                       "Sultan Mehmed asked me how the siege ends"]},
    {"id": "05_buro_ucuyor", "beats": ["flight"], "hook": ["Zaman Bürosu denetçisi 1453 İstanbul'unun üstünde",
                                                           "A Time Bureau inspector over 1453 Constantinople"]},
    {"id": "06_kusatma", "beats": ["siege"], "hook": ["Kuşatmada iş kazası poliçeye dahil mi?",
                                                      "Does my policy cover a siege?"]},
    {"id": "07_buyuk_top", "beats": ["boom"], "hook": ["Dünyanın en büyük topu ateşlenmeden önce tek bir soru",
                                                       "One question before the world's biggest cannon fires"]},
    {"id": "08_vlad_kasko", "seg": "vlad_kasko", "hook": ["Kazıklı Voyvoda'ya kale sigortası satmaya çalıştım",
                                                          "I tried to sell castle insurance to Vlad the Impaler"]},
    {"id": "09_kusatma_haric", "seg": "giust_kusatma_haric", "hook": ["Surların komutanına savaş sigortası teklif ettim",
                                                                      "I offered war insurance to the wall commander"]},
    {"id": "10_gecici_tanik", "seg": "buro_madde9", "hook": ["Zaman Bürosu bana bir aylık iş teklif etti",
                                                             "The Time Bureau offered me a one-month job"]},
    {"id": "11_model_z0", "seg": "buro_kamera", "hook": ["Zaman Bürosu'nun resmî fotoğraf makinesi",
                                                         "The Time Bureau's official camera"]},
    {"id": "12_ters_kurek", "seg": "kayik_ters", "hook": ["Venedik kadırgasında kürek çektim. Bir sorun var.",
                                                          "I rowed a Venetian galley. One problem."]},
    {"id": "13_hikmet_1977", "seg": "hikmet_1977", "hook": ["1977'de genç amcama ilk poliçesini yazdım",
                                                            "In 1977 I wrote my young uncle his first policy"]},
    {"id": "14_iki_tunel", "seg": "tunel_police", "hook": ["İki düşman lağım, toprağın altında karşılaştı",
                                                           "Two enemy tunnels met underground"]},
    {"id": "16_oynanis_savas", "segs": ["duel", "cannon", "matchlock"], "hook": ["1453 kuşatmasında birinci şahıs: kılıç, top, tüfek",
                                                                               "First person in the 1453 siege: sword, cannon, matchlock"]},
    {"id": "17_oynanis_dunya", "segs": ["rowing", "flight", "city"], "hook": ["Haliç'te kürek çek, şehrin üstünde uç, 1453'ü gez",
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
    with open(log_path, encoding="utf-8", errors="replace") as f:
        for raw in f:
            raw = raw.rstrip("\n")
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


def sub_text(s, name_size, text_size):
    name = s["spk"].strip()
    body = esc(s["text"])
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


def make_trailer(raw, data, out):
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
    run(["ffmpeg", "-v", "error", "-y", "-i", raw, "-vf", "subtitles='%s':fontsdir='%s'" % (esc_path(ass), esc_path(FONTS)),
         "-af", "loudnorm=I=-14:TP=-1.5:LRA=11,aresample=48000",
         "-c:v", "libx264", "-preset", "medium", "-crf", "18", "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "192k",
         "-movflags", "+faststart", out])
    os.unlink(ass)


def make_short(raw, data, spec, ranges, out, lang):
    """ranges: [(t0, t1), ...] ham kayıtta art arda eklenen pencereler (montaj kesitleri ayrık olabilir)."""
    trim = spec.get("trim", [0.0, 0.0])
    ranges = [list(r) for r in ranges]
    ranges[0][0] += trim[0]
    ranges[-1][1] -= trim[1]
    # Ham zaman → kısadaki zaman: her pencerenin başı, öncekilerin toplam süresine kayar
    offs, acc = [], 0.0
    for r0, r1 in ranges:
        offs.append((r0, r1, acc - r0))
        acc += r1 - r0
    dur = acc
    total = dur + END_CARD
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
    lines.append(ev(0.0, dur, "Hook", esc(hook)))
    lines.append(ev(0.0, dur, "Brand", "Gerçek Tarih Bu Değil" if lang == "tr" else "Not a History Game"))
    for r0, r1, sh in offs:
        for s in data["subs"]:
            a, b = max(s["t0"], r0), min(s["t1"], r1)
            if b - a > 0.15:
                lines.append(ev(a + sh, b + sh, "Cap", sub_text(s, 40, 58)))
        for o in data["overs"]:
            a, b = max(o["t0"], r0), min(o["t1"], r1)
            if b - a > 0.15:
                lines.append(ev(a + sh, b + sh, "Over", o["text"] if "\\N" in o["text"] else esc(o["text"])))
    tag, cta = END_TEXT[lang]
    lines.append(ev(dur, total, "EndTag", esc(tag)))
    lines.append(ev(dur + 0.25, total, "EndCta", esc(cta)))
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
        "[cata]afade=t=out:st=%.2f:d=0.35,apad=whole_dur=%.2f[a0];"
        "[MUS:a]atrim=0:%.2f,afade=t=in:d=0.25,afade=t=out:st=%.2f:d=0.4,adelay=%d|%d,volume=0.85[a1];"
        "[a0][a1]amix=inputs=2:duration=first:normalize=0,loudnorm=I=-14:TP=-1.5:LRA=11,aresample=48000[aout]"
    ) % (END_CARD, H, W, H, SQ, SQ, crop_x, TOP, W, H, total, dur, dur, esc_path(ass), esc_path(FONTS),
         max(dur - 0.35, 0.0), total, END_CARD, END_CARD - 0.4, int(dur * 1000), int(dur * 1000))
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
    a = ap.parse_args()
    data = parse(a.log)
    lang = "en" if data["en"] or a.log.endswith("_en.log") else "tr"
    if a.list:
        for s in data["segs"]:
            print("%-22s %7.2f → %s" % (s["name"], s["t0"], "%.2f" % s["t1"] if s["t1"] else "son"))
        return
    if a.mode == "trailer":
        make_trailer(a.raw, data, a.out)
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
            ranges = [(segs[n]["t0"], segs[n]["t1"]) for n in names]
        out = os.path.join(a.out, "%s_%s.mp4" % (spec["id"], lang))
        make_short(a.raw, data, spec, ranges, out, lang)
        print("kısa: %s (%.1f sn)" % (out, sum(r1 - r0 for r0, r1 in ranges) + END_CARD))
        made += 1
    print("toplam %d kısa" % made)


if __name__ == "__main__":
    main()
