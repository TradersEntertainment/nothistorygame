#!/usr/bin/env python3
"""ElevenLabs Sound Effects ile kuşatmanın taraf ortam seslerini üretir: assets/audio/sfx/<ad>.ogg (döngülü çalınır).

Anahtar ortam değişkeninden okunur (dosyaya yazılmaz):
    export ELEVENLABS_API_KEY=...

    python3 tools/amb_gen.py list            # sesler ve nerede çaldıkları
    python3 tools/amb_gen.py gen             # hepsini üret (var olanları atlar)
    python3 tools/amb_gen.py gen amb_battle_o --force

Her ses 22 sn (API'nin üst sınırı) üretilir; uçları 1,5 sn çapraz geçişle birleştirilip kesintisiz döngü yapılır.
"""
import argparse, json, os, subprocess, sys, tempfile, urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets/audio/sfx")
API = "https://api.elevenlabs.io/v1/sound-generation"

# ad: (nerede, tarif)
SOUNDS = {
    "amb_battle_o": ("Osmanlı hücumu, surların önü (20O, 22O, 26O, 30O, 32O, 37O)",
        "Continuous ambience of a 15th-century siege seen from the attacking Ottoman army: thousands of soldiers shouting "
        "in the distance, a mehter military band drumming far away with kettledrums and zurnas, arrows whistling, swords "
        "clashing, occasional distant cannon booms, no music in the foreground, no speech you can understand."),
    "amb_battle_b": ("Bizans savunması, surun üstü (20, 22, 26, 30, 36B)",
        "Continuous ambience of defenders on a medieval city wall under siege at night: wind on the battlements, church "
        "bells ringing an alarm in the distance, the wooden semantron being struck, men shouting orders in the "
        "distance, arrows thudding into wood, fire crackling, a far-off enemy war drum."),
    "amb_sea_battle": ("Deniz çarpışması, kürek ve kadırga (17, 19, 19O, 29, 29O, 38O)",
        "Continuous ambience of a medieval galley at sea during a naval battle: oars splashing in rhythm, waves slapping "
        "the wooden hull, ropes and timbers creaking, sailors shouting in the distance, occasional far cannon fire "
        "across the water, seagulls."),
    "amb_camp_night_o": ("Osmanlı ordugâhı gece (17O, 22O, 24O, 25)",
        "Continuous night ambience of a huge 15th-century army camp: many campfires crackling, low murmuring voices, "
        "horses snorting, a distant ney flute, crickets, a lone dog barking far away, tent canvas in a light wind."),
}


def key():
    k = os.environ.get("ELEVENLABS_API_KEY", "")
    if not k:
        sys.exit("ELEVENLABS_API_KEY ortam değişkeni yok.")
    return k


def generate(text: str, out_mp3: str) -> None:
    body = json.dumps({"text": text, "duration_seconds": 22.0, "prompt_influence": 0.4}).encode()
    req = urllib.request.Request(API + "?output_format=mp3_44100_128", data=body, method="POST",
                                 headers={"xi-api-key": key(), "Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=180) as r, open(out_mp3, "wb") as f:
        f.write(r.read())


def loopify(src: str, dst: str, xfade: float = 1.5) -> None:
    """Sonun son xfade saniyesini başla karıştırır: döngünün eki duyulmaz."""
    dur = float(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", src]).strip())
    # Gövde xfade'den sona; sonu baştaki ilk xfade saniyesine çapraz geçer: çıkış, başladığı yere varıp biter
    af = (f"[0:a]atrim={xfade}:{dur},asetpts=PTS-STARTPTS[body];"
          f"[1:a]atrim=0:{xfade},asetpts=PTS-STARTPTS[head];"
          f"[body][head]acrossfade=d={xfade}:c1=tri:c2=tri[o]")
    wav = tempfile.mktemp(suffix=".wav")
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", src, "-i", src, "-filter_complex", af, "-map", "[o]", wav],
                   check=True)       # aynı dosya iki giriş: asplit + acrossfade boş çıkıyordu
    # Ses düzeyi ayrı geçişte (loudnorm çapraz geçişle aynı süzgeç zincirinde boş dosya yazıyordu)
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", wav, "-af", "loudnorm=I=-23:TP=-2", "-ar", "44100", "-ac", "2",
                    "-c:a", "libvorbis", "-q:a", "5", dst], check=True)
    os.remove(wav)


def main() -> None:
    p = argparse.ArgumentParser()
    p.add_argument("cmd", choices=["list", "gen"])
    p.add_argument("names", nargs="*")
    p.add_argument("--force", action="store_true")
    a = p.parse_args()
    if a.cmd == "list":
        for n, (where, _t) in SOUNDS.items():
            print(("[x] " if os.path.exists(os.path.join(OUT, n + ".ogg")) else "[ ] ") + n.ljust(18) + where)
        return
    for n in a.names or list(SOUNDS):
        dst = os.path.join(OUT, n + ".ogg")
        if os.path.exists(dst) and not a.force:
            print("var:", n)
            continue
        tmp = tempfile.mktemp(suffix=".mp3")
        generate(SOUNDS[n][1], tmp)
        loopify(tmp, dst)
        os.remove(tmp)
        print("üretildi:", n)


if __name__ == "__main__":
    main()
