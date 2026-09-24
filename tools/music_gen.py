#!/usr/bin/env python3
"""ElevenLabs Music ile oyunun bütün müziklerini üretir: assets/audio/music/<parça>.mp3

Anahtar ortam değişkeninden okunur (dosyaya yazılmaz):
    export ELEVENLABS_API_KEY=...        (Windows PowerShell: $env:ELEVENLABS_API_KEY="...")

Adımlar:
    python tools/music_gen.py check              # anahtar ve kalan kredi
    python tools/music_gen.py list               # parçalar, süreleri, nerede çaldıkları
    python tools/music_gen.py gen                # hepsini üret (var olanları atlar)
    python tools/music_gen.py gen theme chase    # yalnızca bunlar
    python tools/music_gen.py gen chase --takes 3 --force
                                                 # 3 farklı deneme üret; dinleyip seç:
    python tools/music_gen.py review             # dinleme sayfası -> docs/music/review.html
    python tools/music_gen.py pick chase 2       # 2. denemeyi oyuna koy
Seçenekler: --model music_v1 (varsayılan: sunucunun seçtiği), --force (var olanı yeniden üret)

Denemeler docs/music/takes/ içine yazılır (git'e girmez). Tek denemede doğrudan oyuna konur.
Oyun .mp3'ü .ogg'dan önce çalar; yeni bir parça henüz üretilmediyse eski parçaya düşer.
"""
import argparse, html, json, os, shutil, sys, time, urllib.error, urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
API = "https://api.elevenlabs.io"
OUT = os.path.join(ROOT, "assets/audio/music")
TAKES = os.path.join(ROOT, "docs/music/takes")
REVIEW = os.path.join(ROOT, "docs/music/review.html")

# Ortak çerçeve: hepsi aynı oyunun müzikleri gibi dursun
BASE = ("Instrumental soundtrack for a comedic time-travel adventure game about the 1453 siege of Constantinople. "
        "Playful rather than grim, high production quality, no vocals, no lyrics, no spoken words.")
# Kültüre göre çalgı ve makam paleti: Osmanlı tarafında Osmanlı, Bizans'ta Rum/Bizans, Galata'da Ceneviz, 2026'da modern
PALETTES = {
    "ottoman": ("Authentic 15th-century Ottoman sound: Turkish makam melodies (Hicaz, Rast, Ussak, Segah), ney flute, "
                "tanbur, oud, kanun, kemence, kudum, bendir, darbuka, and for outdoor/military scenes the mehter band "
                "(davul, zurna, kos kettledrums, cymbals). Ottoman court and folk character, with a light cinematic "
                "string bed underneath."),
    "byzantine": ("Authentic Byzantine Greek sound, clearly not Turkish: Byzantine chant modes (echoi), a sustained "
                  "ison drone, Byzantine lyra, santouri, psaltery, laouto, harp, low organ-like pads, church bells and "
                  "the wooden semantron; Orthodox liturgical and Greek medieval character with a light cinematic string bed."),
    "genoese": ("Italian Renaissance Genoese harbour sound: lute, mandolin, recorder, shawm, viola da gamba, tambourine "
                "and hand drums, Mediterranean dance rhythms (saltarello, tarantella)."),
    "modern": ("Modern-day Istanbul: contemporary production (lo-fi beats, electric piano, synth pads, subtle electronic "
               "percussion) with small touches of baglama or ney as a nod to the city."),
    "fusion": ("Fusion of the game's worlds: an Ottoman ney/oud melody answered by a Byzantine lyra phrase, over a warm "
               "cinematic orchestra with a shimmering clockwork/synth sparkle that hints at time travel."),
}
LOOP = (" Designed as a seamless background loop for a video game: starts immediately with the full arrangement "
        "(no intro, no fade-in), keeps a steady tempo and energy the whole time, and ends without a fade-out or final "
        "cadence so the end flows back into the start.")

# ad: (saniye, döngü mü, palet, nerede, tarif)
TRACKS = {
    "theme": (120, True, "fusion", "Ana menü arkası, final (Bölüm 15)",
        "Main theme. Memorable, hummable melody passed between ney/oud and Byzantine lyra over bouncing pizzicato "
        "strings and light darbuka. Adventurous, witty and warm, 100 BPM."),
    "menu": (90, True, "fusion", "Duraklatma menüsü",
        "Calm, gentle variation of the main theme: solo oud and soft kanun arpeggios, a distant lyra answer, a "
        "ticking clock-like percussion texture. Relaxed and inviting, 80 BPM."),
    "credits": (150, False, "fusion", "Jenerik",
        "Grand, heartfelt end-credits piece. Starts intimate with solo ney, a Byzantine lyra joins, builds to full "
        "orchestra with davul and kanun, a triumphant but tender reprise of the adventure theme, then settles to a "
        "warm ending."),
    "flowchart": (90, True, "fusion", "Bölüm sonu akış şeması",
        "Reflective, curious 'what could have happened' music: music box and kanun plucks, soft strings, gentle ney "
        "phrases, a slow ticking pulse. Thoughtful with a light smile, 75 BPM."),
    "garage": (120, True, "modern", "Hikmet'in garajı (Bölüm 1, 13)",
        "Quirky late-night inventor's garage: lo-fi beat with soft electric piano, plucked baglama riffs, ticking "
        "clocks, little mechanical clicks and whirs, a hint of retro synth. Mysterious and cosy, slightly comedic, "
        "88 BPM."),
    "tension": (120, True, "modern", "Garajda gece, sorgu ve şüphe (Bölüm 5), hırdavatçı (Bölüm 8)",
        "Nervous suspense in a modern Istanbul garage at night while an inspector asks questions: low string "
        "ostinato, ticking clock, muted synth pulses, bowed metal, slowly building unease with a comedic wink, 90 BPM."),
    "bureau": (120, True, "modern", "Zaman Bürosu (Bölüm 3, 7, 14)",
        "Comedic bureaucratic office music for a secret Time Bureau: typewriter-like rhythm, staccato pizzicato "
        "strings, muted trumpet and bassoon, rubber-stamp percussion hits, a stiff but silly march feel. Deadpan "
        "humour, 108 BPM."),
    "chase": (120, True, "ottoman", "Kovalamacalar (kızak kaçışı ve kovalama çubuğu çıkan her sahne)",
        "Frantic comedic chase: fast mehter davul and zurna riffs over driving orchestral strings and brass stabs, "
        "cymbal crashes, relentless 150 BPM energy, slapstick urgency."),
    "camp_day": (120, True, "ottoman", "Osmanlı ordugâhı gündüz (Bölüm 6, 9, 10)",
        "Bustling Ottoman army camp by day: light mehter march with davul, zurna and small cymbals, kudum and oud "
        "accompaniment, lively crowd energy, heroic but good-humoured, 112 BPM."),
    "stealth": (120, True, "ottoman", "Ordugâhta gizlenme, ilk gece (Bölüm 4a)",
        "Sneaky comedic stealth through an Ottoman camp at night: tiptoeing pizzicato and plucked tanbur, soft "
        "bendir taps, a sly ney motif, suspenseful pauses, tense but playful, 92 BPM."),
    "confrontation": (120, True, "ottoman", "Yüzleşme, ordugâhta gece (Bölüm 11)",
        "Dramatic night confrontation in the Ottoman camp: driving kos and davul, dark low strings, an anxious ney "
        "cry, kemence tremolo, cinematic tension with a hint of irony, 100 BPM."),
    "audience": (120, True, "ottoman", "Huzur: Fatih'in otağı (Bölüm 12)",
        "Audience with Sultan Mehmed II in his imperial tent: majestic slow Ottoman court music in makam Rast, "
        "kudum, noble ney and tanbur melody, kanun ornaments, rich low strings, awe mixed with quiet tension, 76 BPM."),
    "kitchen": (100, True, "ottoman", "Ordu mutfağı (Bölüm 10z)",
        "Chaotic comedic cooking in the Ottoman army kitchen: clarinet and zurna leading a fast 9/8 groove, "
        "wooden spoons percussion, pots-and-pans hits, pizzicato strings, frantic and funny, 132 BPM."),
    "foundry": (120, True, "ottoman", "Top dökümhanesi, Urban (Bölüm 10b)",
        "Epic comedic cannon foundry in the Ottoman camp: anvil and hammer percussion, heavy davul and kos, "
        "bellows-like low brass, a proud industrial mehter march with zurna flourishes, 104 BPM."),
    "tunnel": (120, True, "ottoman", "Lağım tüneli (Bölüm 10l)",
        "Claustrophobic siege tunnel dug by Ottoman sappers: dark low drones, dripping-water percussion, muffled "
        "distant davul thuds, sparse oud and ney harmonics, suspense in candlelight, 70 BPM."),
    "chicken": (100, True, "ottoman", "Tavuk Sinerji kovalamacası, ordugâh (Bölüm 16)",
        "Silly cartoon chase after a runaway chicken through the camp: bouncy Turkish folk kaval and zurna, "
        "clucking woodblocks, slide-whistle accents, fast darbuka, pure slapstick fun, 140 BPM."),
    "explosion_slowmo": (45, False, "ottoman", "Top patlaması ağır çekim (Bölüm 10b)",
        "Slow-motion explosion aftermath: a huge low kos boom fading into a suspended, dreamy orchestral swell, "
        "reversed cymbals, high string harmonics, heavy slow heartbeat drum, time stretched and surreal, then a "
        "comedic deflating trombone at the very end."),
    "countdown": (120, True, "modern", "Dönüş penceresi geri sayım (Bölüm 13)",
        "Race against the clock: urgent ticking and pulsing synth arpeggio, driving strings, darbuka and davul, "
        "rising tension, electronic-orchestral hybrid, 138 BPM."),
    "byzantium": (120, True, "byzantine", "Surların içi, Konstantinopolis (Bölüm 6b, 10a, 10h)",
        "Besieged Byzantine Constantinople: modal chant-like melody on lyra and santouri over a deep ison drone, "
        "slow tapping of the wooden semantron, distant bells, melancholic, sacred and anxious, 72 BPM."),
    "byzantium_evening": (120, True, "byzantine", "Bizans akşamı (Bölüm 12b)",
        "Intimate Byzantine evening: solo lyra and harp over a soft ison drone, distant bell tones, candlelit and "
        "wistful, a sense of an era ending, 64 BPM."),
    "walls_night": (120, True, "byzantine", "Bizans deniz surları, gece (Bölüm 4b)",
        "Night on the Byzantine sea walls with a nervous guide: tense lyra tremolo and low ison drone, plucked "
        "laouto ostinato, soft frame drum like footsteps, waves-like pads, secretive and uneasy with a comedic "
        "edge, 84 BPM."),
    "galata": (120, True, "genoese", "Galata, Ceneviz limanı (Bölüm 10g)",
        "Genoese harbour market in 15th-century Galata: a lively Renaissance dance on lute, mandolin and recorder, "
        "tambourine, bustling and playful, seagull-bright, 116 BPM."),
}


def key() -> str:
    k = os.environ.get("ELEVENLABS_API_KEY", "")
    if not k:
        sys.exit("ELEVENLABS_API_KEY ortam değişkeni yok.")
    return k


def request(method, path, body=None, raw=False):
    req = urllib.request.Request(API + path, method=method,
                                 headers={"xi-api-key": key(), "Content-Type": "application/json"},
                                 data=json.dumps(body).encode() if body is not None else None)
    for attempt in range(4):
        try:
            with urllib.request.urlopen(req, timeout=600) as r:
                data = r.read()
                return data if raw else json.loads(data or b"{}")
        except urllib.error.HTTPError as e:
            msg = e.read().decode(errors="ignore")
            if e.code in (429, 500, 502, 503) and attempt < 3:
                time.sleep(5 * (attempt + 1))
                continue
            raise SystemExit(f"HTTP {e.code} {path}: {msg[:500]}")
        except urllib.error.URLError as e:
            if attempt < 3:
                time.sleep(5 * (attempt + 1))
                continue
            raise SystemExit(f"Bağlantı hatası: {e}")


def credits() -> str:
    s = request("GET", "/v1/user/subscription")
    return f"{s.get('character_count', 0)}/{s.get('character_limit', 0)} kullanıldı ({s.get('tier', '?')})"


def prompt_for(name: str) -> tuple:
    secs, loop, pal, _, desc = TRACKS[name]
    return BASE + " " + PALETTES[pal] + " " + desc + (LOOP if loop else ""), secs


def compose(name: str, model: str) -> bytes:
    text, secs = prompt_for(name)
    body = {"prompt": text, "music_length_ms": secs * 1000, "force_instrumental": True}
    if model:
        body["model_id"] = model
    return request("POST", "/v1/music?output_format=mp3_44100_192", body, raw=True)


def cmd_check(_):
    print("Anahtar tamam. Kredi:", credits())


def cmd_list(_):
    for n, (secs, loop, pal, where, _) in TRACKS.items():
        have = "x" if os.path.exists(os.path.join(OUT, n + ".mp3")) else " "
        print(f"[{have}] {n:18} {secs:4d} sn {'döngü' if loop else 'tek   '} {pal:9}  {where}")


def cmd_gen(a):
    names = a.names or list(TRACKS)
    bad = [n for n in names if n not in TRACKS]
    if bad:
        sys.exit("Bilinmeyen parça: " + ", ".join(bad) + "   (liste: python tools/music_gen.py list)")
    os.makedirs(OUT, exist_ok=True)
    os.makedirs(TAKES, exist_ok=True)
    print("Başlangıç kredisi:", credits())
    for n in names:
        target = os.path.join(OUT, n + ".mp3")
        if os.path.exists(target) and not a.force:
            print(f"  {n}: var, atlandı (--force ile yeniden)")
            continue
        for t in range(1, a.takes + 1):
            print(f"  {n} ({t}/{a.takes}) üretiliyor... ", end="", flush=True)
            t0 = time.time()
            data = compose(n, a.model)
            path = os.path.join(TAKES, f"{n}_{t}.mp3")
            with open(path, "wb") as f:
                f.write(data)
            print(f"{len(data) // 1024} KB, {time.time() - t0:.0f} sn")
        if a.takes == 1:
            shutil.copyfile(os.path.join(TAKES, f"{n}_1.mp3"), target)
            print(f"    -> {os.path.relpath(target, ROOT)}")
        else:
            print(f"    Dinle: python tools/music_gen.py review   Seç: python tools/music_gen.py pick {n} <no>")
    print("Kalan kredi:", credits())
    cmd_review(a, quiet=True)


def cmd_pick(a):
    src = os.path.join(TAKES, f"{a.name}_{a.take}.mp3")
    if not os.path.exists(src):
        sys.exit("Böyle bir deneme yok: " + os.path.relpath(src, ROOT))
    shutil.copyfile(src, os.path.join(OUT, a.name + ".mp3"))
    print(f"{a.name}: {a.take}. deneme oyuna kondu.")


def cmd_review(_, quiet=False):
    os.makedirs(os.path.dirname(REVIEW), exist_ok=True)
    rows = []
    for n, (secs, loop, pal, where, desc) in TRACKS.items():
        cells = []
        cur = os.path.join(OUT, n + ".mp3")
        if os.path.exists(cur):
            cells.append(f"<div><b>Oyundaki</b><br><audio controls preload=none src='../../assets/audio/music/{n}.mp3'></audio></div>")
        t = 1
        while os.path.exists(os.path.join(TAKES, f"{n}_{t}.mp3")):
            cells.append(f"<div>Deneme {t}<br><audio controls preload=none src='takes/{n}_{t}.mp3'></audio>"
                         f"<br><code>pick {n} {t}</code></div>")
            t += 1
        rows.append(f"<section><h2>{html.escape(n)} <small>{secs} sn · {'döngü' if loop else 'tek'} · {pal} · "
                    f"{html.escape(where)}</small></h2><p>{html.escape(desc)}</p><div class=row>{''.join(cells) or '<i>henüz yok</i>'}</div></section>")
    page = ("<!doctype html><meta charset=utf-8><title>Müzikler</title><style>body{font:15px system-ui;max-width:1100px;"
            "margin:24px auto;padding:0 16px;background:#16181d;color:#e8e2d4}h2{margin:.2em 0}small{color:#9a958a;font-weight:400}"
            "section{border-top:1px solid #333;padding:12px 0}p{color:#b8b2a4;margin:.3em 0 .6em}.row{display:flex;gap:18px;flex-wrap:wrap}"
            "code{color:#ffd24a}</style><h1>Gerçek Tarih Bu Değil — müzikler</h1>" + "".join(rows))
    with open(REVIEW, "w", encoding="utf-8") as f:
        f.write(page)
    if not quiet:
        print("Dinleme sayfası:", os.path.relpath(REVIEW, ROOT))


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = p.add_subparsers(dest="cmd", required=True)
    sub.add_parser("check").set_defaults(fn=cmd_check)
    sub.add_parser("list").set_defaults(fn=cmd_list)
    g = sub.add_parser("gen")
    g.add_argument("names", nargs="*")
    g.add_argument("--takes", type=int, default=1)
    g.add_argument("--force", action="store_true")
    g.add_argument("--model", default="")
    g.set_defaults(fn=cmd_gen)
    k = sub.add_parser("pick")
    k.add_argument("name")
    k.add_argument("take", type=int)
    k.set_defaults(fn=cmd_pick)
    sub.add_parser("review").set_defaults(fn=cmd_review)
    a = p.parse_args()
    a.fn(a)


if __name__ == "__main__":
    main()
