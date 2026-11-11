#!/usr/bin/env python3
"""Hikâye fragmanının kurgusu (montage.gd "-- set=story" kayıtları): seçilen çekimleri sırayla sert kesmeyle birleştirir,
oyunun replik kayıtlarından (MONTAGE line on/off) altyazıyı, üst yazıları (MONTAGE cap) ASS ile basar; oyunun müzik yolu
kayıtta susturulduğu için alta tek parça müzik yatırır (replik sırasında kısılır), sesi -14 LUFS'a getirir.

  python3 tools/trailer/story_cut.py CIKTI.mp4 HAM.avi:HAM.log:çekim_id[:baş_kırp[:son_kırp]] ... [--music theme.ogg]

Aynı ham kayıttan birden çok çekim ve ayrı kayıtlardan çekimler karıştırılabilir. Kırpma saniye (pencerenin başından/
sonundan atılan); son çekimin kartı (MONTAGE card) çekim kimliği "card" ile alınır. Kırpılan yerde başlayan/biten
replik altyazısı pencereyle kesilir; repliği yarıda kesmemek kurgucunun işi (--dry replik sınırlarını yazar).
"""
import argparse
import os
import re
import subprocess
import sys
import tempfile

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from cut import ass_color, ass_time, esc, header, ev, esc_path, strip_stage, FONTS, ROOT  # noqa: E402

FPS = 30.0
LEAD = 0.034   # pencerenin ilk karesi 3B yeniden açılırken gri çıkabiliyor (bir kare atılır)


def parse(log_path):
    segs, open_in, ids, lines, caps = {}, {}, {}, [], []
    cur = None
    card = None
    with open(log_path, encoding="utf-8", errors="replace") as f:
        for raw in f:
            raw = raw.rstrip("\n")
            m = re.match(r"MONTAGE seg=(\d+) .* ok=(\w+) .*id=(\S*)", raw)
            if m:
                ids[int(m.group(1))] = m.group(3)
                continue
            m = re.match(r"MONTAGE card seg=(\d+)", raw)
            if m:
                card = int(m.group(1))
                continue
            m = re.match(r"MONTAGE (in|out) seg=(\d+) frame=(\d+)", raw)
            if m:
                n, fr = int(m.group(2)), int(m.group(3)) / FPS
                if m.group(1) == "in":
                    open_in[n] = fr
                elif n in open_in:
                    segs[n] = (open_in.pop(n), fr)
                if cur and m.group(1) == "out":
                    cur["t1"] = fr
                    lines.append(cur)
                    cur = None
                continue
            m = re.match(r"MONTAGE line on frame=(\d+) key=(\S*) col=(\S+) spk=(.*?) text=(.*)$", raw)
            if m:
                if cur:
                    cur["t1"] = int(m.group(1)) / FPS
                    lines.append(cur)
                cur = {"t0": int(m.group(1)) / FPS, "t1": None, "key": m.group(2), "col": m.group(3),
                       "spk": m.group(4).strip(), "text": m.group(5).strip()}
                continue
            m = re.match(r"MONTAGE line off frame=(\d+)", raw)
            if m and cur:
                cur["t1"] = int(m.group(1)) / FPS
                lines.append(cur)
                cur = None
                continue
            m = re.match(r"MONTAGE cap seg=(\d+) frame=(\d+) text=(.*)$", raw)
            if m and m.group(3).strip():
                caps.append({"t0": int(m.group(2)) / FPS, "t1": int(m.group(2)) / FPS + 2.85,
                             "text": m.group(3).strip().replace("|", "\\N")})
    out = {}
    for n, (a, b) in segs.items():
        name = "card" if n == card else ids.get(n, "seg%d" % n)
        out[name] = (a, b)
    return out, lines, caps


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("out")
    ap.add_argument("shots", nargs="+")
    ap.add_argument("--music", default=os.path.join(ROOT, "assets", "audio", "music", "theme.ogg"))
    ap.add_argument("--music_db", type=float, default=-15.0)
    ap.add_argument("--dry", action="store_true")
    a = ap.parse_args()
    cache = {}
    parts = []          # (ham, t0, t1)
    subs, overs = [], []
    t = 0.0
    for spec in a.shots:
        f = spec.split(":")
        raw, log, sid = f[0], f[1], f[2]
        k0 = float(f[3]) if len(f) > 3 and f[3] else 0.0
        k1 = float(f[4]) if len(f) > 4 and f[4] else 0.0
        if log not in cache:
            cache[log] = parse(log)
        segs, lines, caps = cache[log]
        if sid not in segs:
            sys.exit("%s: çekim yok (%s)" % (sid, ", ".join(segs)))
        s0, s1 = segs[sid]
        r0 = s0 + (LEAD if sid != "card" else 0.0) + k0
        r1 = s1 - k1
        sh = t - r0
        print("%-18s %6.2f-%6.2f  %.2f sn  (kurguda %.2f)" % (sid, r0, r1, r1 - r0, t))
        for L in lines:
            if L["t1"] is None:
                continue
            x0, x1 = max(L["t0"], r0), min(L["t1"], r1)
            if x1 - x0 > 0.2:
                cut = " [KESİK]" if (L["t0"] < r0 - 0.05 or L["t1"] > r1 + 0.05) else ""
                if a.dry:
                    print("      %5.2f-%5.2f %-10s %s%s" % (L["t0"] - r0, L["t1"] - r0, L["spk"][:10], L["text"][:70], cut))
                subs.append({"t0": x0 + sh, "t1": x1 + sh, "spk": L["spk"], "col": L["col"], "text": L["text"]})
        for c in caps:
            x0, x1 = max(c["t0"], r0), min(c["t1"], r1)
            if x1 - x0 > 0.3:
                overs.append({"t0": x0 + sh, "t1": x1 + sh, "text": c["text"]})
        parts.append((raw, r0, r1))
        t += r1 - r0
    print("toplam %.2f sn, %d çekim" % (t, len(parts)))
    if a.dry:
        return
    ass_lines = header(1920, 1080, [
        "Cap,Comfortaa,46,&H00FFFFFF,&H00FFFFFF,&H00000000,&H64000000,1,0,0,0,100,100,0,0,1,4,1,2,160,160,64,1",
        "Over,Alfa Slab One,64,&H00C9E6F2,&H00FFFFFF,&H00000000,&H00000000,0,0,0,0,100,100,0,0,1,6,0,7,90,90,70,1",
    ])
    for s in subs:
        name = s["spk"].strip()
        body = esc(strip_stage(s["text"]))
        txt = ("{\\fs32\\c%s}%s\\N{\\fs46\\c&HFFFFFF&}%s" % (ass_color(s["col"]), esc(name), body)) if name else body
        ass_lines.append(ev(s["t0"], s["t1"], "Cap", txt))
    for o in overs:
        ass_lines.append(ev(o["t0"], o["t1"], "Over", esc(o["text"]) if "\\N" not in o["text"] else o["text"]))
    with tempfile.NamedTemporaryFile("w", suffix=".ass", delete=False, encoding="utf-8") as f:
        f.write("\n".join(ass_lines) + "\n")
        ass = f.name
    ins, fc = [], ""
    n = len(parts)
    for i, (raw, r0, r1) in enumerate(parts):
        ins += ["-ss", "%.3f" % r0, "-t", "%.3f" % (r1 - r0), "-i", raw]
        # Kesimde tık olmasın: parça uçlarında çok kısa ses geçişi
        fc += ("[%d:v]fps=30,setpts=PTS-STARTPTS[v%d];[%d:a]aresample=48000,asetpts=PTS-STARTPTS,"
               "afade=t=in:d=0.04,afade=t=out:st=%.3f:d=0.05[a%d];") % (i, i, i, max(r1 - r0 - 0.05, 0.0), i)
    fc += "".join("[v%d][a%d]" % (i, i) for i in range(n)) + "concat=n=%d:v=1:a=1[cv][ca];" % n
    fc += "[cv]subtitles='%s':fontsdir='%s',format=yuv420p[vout];" % (esc_path(ass), esc_path(FONTS))
    # Tek parça müzik: baştan sona, replik/efekt sesi geldikçe kısılır (sidechain), sonda söner
    fc += "[ca]asplit=2[g1][g2];"
    fc += ("[%d:a]aresample=48000,atrim=0:%.3f,asetpts=PTS-STARTPTS,volume=%.1fdB,afade=t=in:d=0.4,"
           "afade=t=out:st=%.3f:d=1.2[mus];") % (n, t, a.music_db, max(t - 1.2, 0.0))
    fc += "[mus][g1]sidechaincompress=threshold=0.04:ratio=5:attack=20:release=350[duck];"
    fc += "[g2][duck]amix=inputs=2:duration=first:normalize=0,loudnorm=I=-14:TP=-1.5:LRA=11,aresample=48000[aout]"
    cmd = ["ffmpeg", "-v", "error", "-y"] + ins + ["-stream_loop", "-1", "-i", a.music, "-filter_complex", fc,
           "-map", "[vout]", "-map", "[aout]", "-t", "%.3f" % t, "-r", "30", "-c:v", "libx264", "-preset", "medium",
           "-crf", "18", "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "192k", "-movflags", "+faststart", a.out]
    r = subprocess.run(cmd, capture_output=True, text=True)
    os.unlink(ass)
    if r.returncode != 0:
        sys.stderr.write(r.stderr[-3000:])
        sys.exit("ffmpeg hatası")
    print("fragman:", a.out)


if __name__ == "__main__":
    main()
