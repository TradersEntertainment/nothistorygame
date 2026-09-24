#!/usr/bin/env python3
"""ElevenLabs ile diyalogları seslendirir ve assets/audio/voice/<dil>/<ANAHTAR>.mp3 olarak kaydeder.

Anahtar ortam değişkeninden okunur (dosyaya yazılmaz):
    export ELEVENLABS_API_KEY=...        (Windows PowerShell: $env:ELEVENLABS_API_KEY="...")

Adımlar:
    python3 tools/voice_map.py                 # replik haritası + ton etiketleri (docs/voice/VOICE_MAP.csv)
    python3 tools/voice_gen.py check           # anahtar ve kota kontrolü
    python3 tools/voice_gen.py design [--only SPK_TOLGA,SPK_NIHAT]
                                               # Voice Design: her karaktere 3 örnek ses -> docs/voice/design/index.html
    python3 tools/voice_gen.py pick SPK_TOLGA 2
                                               # beğenilen örneği kalıcı ses yap, cast.json'a yaz
    python3 tools/voice_gen.py pick rest 1     # seçilmemiş herkese 1. örneği ver
    python3 tools/voice_gen.py share SPK_MINER SPK_RIZA
                                               # özel ses sınırı dolunca: bir karakter başkasının sesini kullanır
    python3 tools/voice_gen.py samples         # her karakterden 3 replik -> docs/voice/samples/
    python3 tools/voice_gen.py all [--chapter 3] [--lang en] [--limit 50]
                                               # hepsi (var olan dosyaları atlar)
    python3 tools/voice_gen.py review [--chapter 10]
                                               # üretilen replikleri dinleme sayfası -> docs/voice/review.html
    python3 tools/voice_gen.py redo D10B_U_B3_1 [--tone "[panicked]"]
                                               # tek repliği (istersen başka tonla) yeniden üret
    (eski yol) python3 tools/voice_gen.py cast # hazır kütüphaneden ses ara
Seçenekler: --model eleven_v3 (varsayılan; ton etiketlerini anlar), --force (var olanları yeniden üret)
"""
import argparse, base64, csv, html, json, os, re, sys, time, urllib.parse, urllib.request, urllib.error

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
API = "https://api.elevenlabs.io"
CAST = os.path.join(ROOT, "docs/voice/cast.json")
MAP = os.path.join(ROOT, "docs/voice/VOICE_MAP.csv")
DESIGN_DIR = os.path.join(ROOT, "docs/voice/design")
DESIGN_JSON = os.path.join(DESIGN_DIR, "design.json")


def key() -> str:
    k = os.environ.get("ELEVENLABS_API_KEY", "")
    if not k:
        sys.exit("ELEVENLABS_API_KEY ortam değişkeni yok.")
    return k


def call(method, path, body=None, raw=False, soft=False):
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
            if soft and e.code in (400, 404, 405, 422):
                return None
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


def tts(voice, text, out, model, tone=""):
    if model.startswith("eleven_v3"):
        # v3: ton etiketi metnin başına; stability yalnız 0 (yaratıcı) / 0.5 (doğal) / 1 (sabit)
        st = min((0.0, 0.5, 1.0), key=lambda x: abs(x - voice.get("stability", 0.5)))
        body = {"text": (tone + " " + text).strip() if tone else text, "model_id": model,
                "voice_settings": {"stability": st}}
    else:
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


def tone_of(r, cast):
    return r.get("ton", "") or resolve(cast, r["konusmaci"]).get("ton", "")


# ---------------------------------------------------------------- Voice Design

def sample_text(spk, lang="tr"):
    """Karakterin kendi repliklerinden 100-600 karakterlik bir deneme metni."""
    parts, n = [], 0
    for r, text in rows(lang):
        if r["konusmaci"] == spk and len(text) > 20:
            parts.append(text); n += len(text) + 1
            if n > 110:
                break
    t = " ".join(parts)
    filler = " Evet, evet. Anladım. Peki şimdi ne yapacağız? Bir dakika, bir dakika... Tamam, hadi bakalım."
    while len(t) < 110:
        t += filler
    return t[:200]


def design_previews(desc, text, model):
    body = {"voice_description": desc, "text": text, "model_id": model}
    res = call("POST", "/v1/text-to-voice/design", body, soft=True)
    if res is None and model != "eleven_multilingual_ttv_v2":
        body["model_id"] = "eleven_multilingual_ttv_v2"
        res = call("POST", "/v1/text-to-voice/design", body, soft=True)
    if res is None:  # eski uç nokta
        res = call("POST", "/v1/text-to-voice/create-previews", {"voice_description": desc, "text": text})
    return res.get("previews", [])


def cmd_design(args):
    cast = load_cast()
    os.makedirs(DESIGN_DIR, exist_ok=True)
    state = json.load(open(DESIGN_JSON, encoding="utf-8")) if os.path.exists(DESIGN_JSON) else {}
    only = [x.strip() for x in args.only.split(",")] if args.only else None
    for spk, c in cast.items():
        if spk.startswith("_") or "same_as" in c or not c.get("design"):
            continue
        if only and spk not in only:
            continue
        if not only and (c.get("voice_id") or spk in state) and not args.force:
            continue
        text = sample_text(spk, args.lang)
        prev = design_previews(c["design"], text, args.design_model)
        ids = []
        for i, p in enumerate(prev[:3]):
            fn = f"{spk[4:].lower()}_{i + 1}.mp3"
            open(os.path.join(DESIGN_DIR, fn), "wb").write(base64.b64decode(p["audio_base_64"]))
            ids.append({"file": fn, "generated_voice_id": p["generated_voice_id"]})
        state[spk] = {"text": text, "previews": ids}
        json.dump(state, open(DESIGN_JSON, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
        print(f"{spk:18s} {len(ids)} örnek")
    write_design_page(cast, state)
    print("Dinle:", os.path.join(DESIGN_DIR, "index.html"))


def write_design_page(cast, state):
    out = ["<!doctype html><meta charset=utf-8><title>Ses seçimi</title>",
           "<style>body{font:15px system-ui;background:#141824;color:#f2e6c9;max-width:900px;margin:auto;padding:16px}"
           "section{border-bottom:1px solid #333;padding:12px 0}audio{width:260px}code{background:#222;padding:2px 6px}"
           ".row{display:flex;flex-wrap:wrap;gap:12px;align-items:center}small{opacity:.7}</style>",
           "<h1>Ses seçimi</h1><p>Her karakter için örnekleri dinle, beğendiğinin komutunu çalıştır.</p>"]
    for spk, st in state.items():
        c = cast.get(spk, {})
        chosen = " ✓ seçildi" if c.get("voice_id") else ""
        out.append(f"<section><h3>{spk[4:].title()}{chosen}</h3><small>{html.escape(c.get('tarif', ''))}</small>"
                   f"<p><i>{html.escape(st['text'][:200])}…</i></p><div class=row>")
        for i, p in enumerate(st["previews"]):
            out.append(f"<div><audio controls src='{p['file']}'></audio><br><code>python3 tools/voice_gen.py pick {spk} {i + 1}</code></div>")
        out.append("</div></section>")
    open(os.path.join(DESIGN_DIR, "index.html"), "w", encoding="utf-8").write("\n".join(out))


def cmd_pick(args):
    """pick SPK_X N  ya da  pick rest N (seçilmemiş tüm karakterlere N. örneği ver)."""
    if args.target == "rest":
        cast = load_cast()
        state = json.load(open(DESIGN_JSON, encoding="utf-8"))
        for spk in state:
            if not cast.get(spk, {}).get("voice_id"):
                pick_one(spk, int(args.n))
        return
    pick_one(args.target, int(args.n))


def pick_one(spk, n):
    cast = load_cast()
    state = json.load(open(DESIGN_JSON, encoding="utf-8"))
    p = state[spk]["previews"][n - 1]
    c = cast[spk]
    name = f"NHG {spk[4:].title()}"
    res = call("POST", "/v1/text-to-voice", {"voice_name": name, "voice_description": c["design"][:1000],
                                            "generated_voice_id": p["generated_voice_id"]}, soft=True)
    if res is None:
        res = call("POST", "/v1/text-to-voice/create-voice-from-preview",
                   {"voice_name": name, "voice_description": c["design"][:1000], "generated_voice_id": p["generated_voice_id"]})
    c["voice_id"] = res["voice_id"]; c["voice_name"] = name
    json.dump(cast, open(CAST, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    write_design_page(cast, state)
    print(f"{spk} -> {name} ({res['voice_id']})")


def cmd_samples(args):
    cast = load_cast(); per = {}
    for r, text in rows(args.lang):
        spk = r["konusmaci"]
        if len(per.setdefault(spk, [])) < 3 and len(text) > 25:
            per[spk].append((r["anahtar"], text, tone_of(r, cast)))
    for spk, items in per.items():
        v = resolve(cast, spk)
        if v.get("skip"):
            continue
        if not v.get("voice_id"):
            print(f"{spk}: ses yok (önce 'design' + 'pick')"); continue
        for k, text, tone in items:
            tts(v, text, os.path.join(ROOT, "docs/voice/samples", args.lang, f"{spk[4:].lower()}_{k}.mp3"), args.model, tone)
            print("örnek:", spk, k)


def cmd_all(args):
    cast = load_cast(); n = 0; chars = 0; missing = set()
    for r, text in rows(args.lang):
        if args.chapter and r["bolum"] != str(args.chapter):
            continue
        if args.upto and int(r["bolum"] or 0) > args.upto:
            continue
        out = os.path.join(ROOT, "assets/audio/voice", args.lang, r["anahtar"] + ".mp3")
        if os.path.exists(out) and not args.force:
            continue
        v = resolve(cast, r["konusmaci"])
        if v.get("skip"):
            continue
        if not v.get("voice_id"):
            if r["konusmaci"] not in missing:
                print("ses yok (önce design + pick):", r["konusmaci"]); missing.add(r["konusmaci"])
            continue
        if args.budget and chars + len(text) > args.budget:
            print(f"Bütçe doldu ({chars} karakter). Kalanlar için komutu sonra tekrar çalıştır."); break
        tts(v, text, out, args.model, tone_of(r, cast))
        n += 1; chars += len(text)
        print(f"[{n}] {r['anahtar']} ({r['konusmaci']})")
        if args.limit and n >= args.limit:
            break
    print(f"Bitti: {n} dosya, {chars} karakter.")


def cmd_share(args):
    """share SPK_A SPK_B: A karakteri B'nin sesini kullanır (özel ses sınırı dolunca)."""
    cast = load_cast()
    a, b = args.target, args.n
    if b not in cast:
        sys.exit(f"{b} kadroda yok")
    cast[a] = {"tarif": cast.get(a, {}).get("tarif", ""), "same_as": b}
    json.dump(cast, open(CAST, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(f"{a} -> {b} sesi")


def cmd_review(args):
    cast = load_cast(); out = ["<!doctype html><meta charset=utf-8><title>Seslendirme kontrolü</title>",
        "<style>body{font:14px system-ui;background:#141824;color:#f2e6c9;max-width:1000px;margin:auto;padding:16px}"
        "tr{border-bottom:1px solid #333}td{padding:6px;vertical-align:top}audio{width:220px}code{font-size:12px;opacity:.8}</style>",
        "<h1>Seslendirme kontrolü</h1><p>Beğenmediğin satırın komutunu kopyala; tonu değiştirip yeniden üret.</p><table>"]
    base = os.path.join(ROOT, "assets/audio/voice", args.lang)
    for r, text in rows(args.lang):
        if args.chapter and r["bolum"] != str(args.chapter):
            continue
        f = os.path.join(base, r["anahtar"] + ".mp3")
        if not os.path.exists(f):
            continue
        rel = os.path.relpath(f, os.path.join(ROOT, "docs/voice"))
        out.append(f"<tr><td><b>{r['konusmaci'][4:].title()}</b><br><code>{r['anahtar']}</code></td>"
                   f"<td>{html.escape(tone_of(r, cast))} {html.escape(text)}</td><td><audio controls preload=none src='{rel}'></audio>"
                   f"<br><code>python3 tools/voice_gen.py redo {r['anahtar']} --tone \"[...]\"</code></td></tr>")
    out.append("</table>")
    open(os.path.join(ROOT, "docs/voice/review.html"), "w", encoding="utf-8").write("\n".join(out))
    print("Dinle:", os.path.join(ROOT, "docs/voice/review.html"))


def cmd_redo(args):
    """Tek repliği yeniden üretir; --tone verilirse VOICE_MAP.csv'ye elle ton olarak yazılır (voice_map.py korur)."""
    cast = load_cast()
    all_rows = list(csv.DictReader(open(MAP, encoding="utf-8")))
    r = next(x for x in all_rows if x["anahtar"] == args.target)
    if args.tone is not None:
        r["ton"] = args.tone; r["ton_elle"] = "1"
        with open(MAP, "w", encoding="utf-8", newline="") as fh:
            w = csv.DictWriter(fh, fieldnames=list(all_rows[0].keys())); w.writeheader(); w.writerows(all_rows)
    text = clean(r["tr" if args.lang == "tr" else "en"])
    tts(resolve(cast, r["konusmaci"]), text, os.path.join(ROOT, "assets/audio/voice", args.lang, r["anahtar"] + ".mp3"),
        args.model, tone_of(r, cast))
    print("yeniden üretildi:", r["anahtar"], tone_of(r, cast))


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("cmd", choices=["cast", "design", "pick", "share", "samples", "all", "review", "redo", "check"])
    p.add_argument("target", nargs="?", default="")
    p.add_argument("n", nargs="?", default="1")
    p.add_argument("--only", default="")
    p.add_argument("--tone", default=None)
    p.add_argument("--design-model", default="eleven_ttv_v3")
    p.add_argument("--lang", default="tr", choices=["tr", "en"])
    p.add_argument("--chapter", type=int, default=0)
    p.add_argument("--limit", type=int, default=0)
    p.add_argument("--upto", type=int, default=0, help="bu bölüme kadar (dahil)")
    p.add_argument("--budget", type=int, default=0, help="en fazla bu kadar karakter harca")
    p.add_argument("--model", default="eleven_v3")
    p.add_argument("--force", action="store_true")
    a = p.parse_args()
    if a.cmd == "check":
        u = call("GET", "/v1/user/subscription")
        print(f"Paket: {u.get('tier')} · kullanılan {u.get('character_count')}/{u.get('character_limit')} karakter")
    else:
        {"cast": cmd_cast, "design": cmd_design, "pick": cmd_pick, "share": cmd_share, "samples": cmd_samples, "all": cmd_all,
         "review": cmd_review, "redo": cmd_redo}[a.cmd](a)
