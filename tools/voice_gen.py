#!/usr/bin/env python3
"""ElevenLabs ile diyalogları seslendirir ve assets/audio/voice/<dil>/<ANAHTAR>.mp3 olarak kaydeder.

Anahtar ortam değişkeninden okunur (dosyaya yazılmaz):
    export ELEVENLABS_API_KEY=...        (Windows PowerShell: $env:ELEVENLABS_API_KEY="...")

Adımlar:
    python3 tools/voice_map.py                 # replik haritası (docs/voice/VOICE_MAP.csv)
    python3 tools/voice_gen.py cast            # her karaktere ses bul, docs/voice/cast.json'a yaz
    python3 tools/voice_gen.py samples         # her karakterden 3 örnek -> docs/voice/samples/
    python3 tools/voice_gen.py all [--chapter 3] [--lang en] [--limit 50]
                                               # hepsi (var olan dosyaları atlar)
Seçenekler: --model eleven_multilingual_v2 (varsayılan), --force (var olanları yeniden üret)
"""
import argparse, csv, json, os, re, sys, time, urllib.parse, urllib.request, urllib.error

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
API = "https://api.elevenlabs.io"
CAST = os.path.join(ROOT, "docs/voice/cast.json")
MAP = os.path.join(ROOT, "docs/voice/VOICE_MAP.csv")


def key() -> str:
    k = os.environ.get("ELEVENLABS_API_KEY", "")
    if not k:
        sys.exit("ELEVENLABS_API_KEY ortam değişkeni yok.")
    return k


def call(method, path, body=None, raw=False):
    req = urllib.request.Request(API + path, method=method, headers={"xi-api-key": key(), "Content-Type": "application/json"},
                                 data=json.dumps(body).encode() if body is not None else None)
    for attempt in range(4):
        try:
            with urllib.request.urlopen(req, timeout=120) as r:
                data = r.read()
                return data if raw else json.loads(data or b"{}")
        except urllib.error.HTTPError as e:
            msg = e.read().decode(errors="ignore")
            if e.code == 429 and attempt < 3:
                time.sleep(3 * (attempt + 1)); continue
            raise SystemExit(f"HTTP {e.code} {path}: {msg[:400]}")


def clean(text: str) -> str:
    """Sahne notlarını okumaz: (Telsiz), [Yunanca], (Gözleri dolar) vb."""
    t = re.sub(r"\[[^\]]*\]", "", text)
    t = re.sub(r"\([^)]*\)", "", t)
    t = t.replace("...", "… ").replace("’", "'")
    return re.sub(r"\s+", " ", t).strip(" ·")


def load_cast():
    return json.load(open(CAST, encoding="utf-8"))


def resolve(cast, spk):
    c = cast.get(spk) or {}
    while "same_as" in c:
        c = cast[c["same_as"]]
    return c


def cmd_cast(args):
    cast = load_cast()
    used = set(c.get("voice_id") for c in cast.values() if isinstance(c, dict) and c.get("voice_id"))
    mine = {v["voice_id"] for v in call("GET", "/v1/voices").get("voices", [])}
    for spk, c in cast.items():
        if spk.startswith("_") or "same_as" in c or (c.get("voice_id") and not args.force):
            continue
        q = {"page_size": 30, "language": "tr", "gender": c["gender"], "age": c["age"], "sort": "usage_character_count_1y"}
        found = call("GET", "/v1/shared-voices?" + urllib.parse.urlencode(q)).get("voices", [])
        if not found:
            q.pop("age"); found = call("GET", "/v1/shared-voices?" + urllib.parse.urlencode(q)).get("voices", [])
        words = c.get("search", "").lower().split()
        def score(v):
            d = (v.get("description") or "").lower() + " " + (v.get("name") or "").lower() + " " + " ".join(v.get("descriptive", "") or "")
            return sum(w in d for w in words)
        found.sort(key=score, reverse=True)
        pick = next((v for v in found if v["voice_id"] not in used), None)
        if not pick:
            print(f"{spk}: uygun ses bulunamadı"); continue
        if pick["voice_id"] not in mine:
            call("POST", f"/v1/voices/add/{pick['public_owner_id']}/{pick['voice_id']}", {"new_name": f"NHG {spk[4:].title()}"})
        c["voice_id"] = pick["voice_id"]; c["voice_name"] = pick.get("name", "")
        used.add(pick["voice_id"])
        print(f"{spk:18s} -> {pick.get('name')} ({pick['voice_id']})")
    json.dump(cast, open(CAST, "w", encoding="utf-8"), ensure_ascii=False, indent=1)


def tts(voice, text, out, model):
    body = {"text": text, "model_id": model,
            "voice_settings": {"stability": voice.get("stability", 0.5), "similarity_boost": voice.get("similarity", 0.8),
                               "style": voice.get("style", 0.2), "use_speaker_boost": True}}
    data = call("POST", f"/v1/text-to-speech/{voice['voice_id']}?output_format=mp3_44100_128", body, raw=True)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    open(out, "wb").write(data)


def rows(lang):
    for r in csv.DictReader(open(MAP, encoding="utf-8")):
        text = clean(r["tr" if lang == "tr" else "en"])
        if text and r["konusmaci"] != "?":
            yield r, text


def cmd_samples(args):
    cast = load_cast(); per = {}
    for r, text in rows(args.lang):
        spk = r["konusmaci"]
        if len(per.setdefault(spk, [])) < 3 and len(text) > 25:
            per[spk].append((r["anahtar"], text))
    for spk, items in per.items():
        v = resolve(cast, spk)
        if not v.get("voice_id"):
            print(f"{spk}: ses yok (önce 'cast')"); continue
        for k, text in items:
            tts(v, text, os.path.join(ROOT, "docs/voice/samples", args.lang, f"{spk[4:].lower()}_{k}.mp3"), args.model)
            print("örnek:", spk, k)


def cmd_all(args):
    cast = load_cast(); n = 0; chars = 0
    for r, text in rows(args.lang):
        if args.chapter and r["bolum"] != str(args.chapter):
            continue
        out = os.path.join(ROOT, "assets/audio/voice", args.lang, r["anahtar"] + ".mp3")
        if os.path.exists(out) and not args.force:
            continue
        v = resolve(cast, r["konusmaci"])
        if not v.get("voice_id"):
            print("ses yok:", r["konusmaci"]); continue
        tts(v, text, out, args.model)
        n += 1; chars += len(text)
        print(f"[{n}] {r['anahtar']} ({r['konusmaci']})")
        if args.limit and n >= args.limit:
            break
    print(f"Bitti: {n} dosya, {chars} karakter.")


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("cmd", choices=["cast", "samples", "all", "check"])
    p.add_argument("--lang", default="tr", choices=["tr", "en"])
    p.add_argument("--chapter", type=int, default=0)
    p.add_argument("--limit", type=int, default=0)
    p.add_argument("--model", default="eleven_multilingual_v2")
    p.add_argument("--force", action="store_true")
    a = p.parse_args()
    if a.cmd == "check":
        u = call("GET", "/v1/user/subscription")
        print(f"Paket: {u.get('tier')} · kullanılan {u.get('character_count')}/{u.get('character_limit')} karakter")
    else:
        {"cast": cmd_cast, "samples": cmd_samples, "all": cmd_all}[a.cmd](a)
