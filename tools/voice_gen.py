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
    python3 tools/voice_gen.py fix             # docs/voice/FIX_LIST.txt: yanlış sesle üretilmişleri düzelt
    python3 tools/voice_gen.py fix --list docs/voice/REGEN_LIST.txt
                                               # ses denetiminin (voice_consistency.py) aykırı bulduklarını yeniden üret
  Robotik okuyan bir karakter için (aynı ses, dört farklı ayar):
    python3 tools/voice_gen.py try SPK_TOLGA              # docs/voice/try/index.html
    python3 tools/voice_gen.py tune SPK_TOLGA 3           # beğendiğin ayar
    python3 tools/voice_gen.py scene garaj --variants 1,6 # sahneyi sırayla, altyazılı dinle: docs/voice/try/scene_garaj.html
  Yeni ses seçmesi (tasarım + Türkçe kütüphane):
    python3 tools/voice_gen.py casting SPK_TOLGA          # docs/voice/casting/index.html
    python3 tools/voice_gen.py cast_pick SPK_TOLGA d4     # ya da l2 (kütüphane)
    python3 tools/voice_gen.py cast_set SPK_TOLGA <voice_id>  # sitede beğendiğin bir sesi doğrudan bağla
    python3 tools/voice_gen.py all --speaker SPK_TOLGA --force
  İngilizce dublaj (ayrı kadro, docs/voice/cast_en.json):
    python3 tools/voice_gen.py audition --lang en        # her karaktere 6 aday, ücretsiz önizleme: docs/voice/audition_en.html
    python3 tools/voice_gen.py pick auto --lang en         # herkese ilk uygun aday (sesler çakışmaz)
    python3 tools/voice_gen.py pick SPK_TOLGA 3 --lang en  # beğenmediğini tek tek değiştir
    python3 tools/voice_gen.py all --lang en --chapter 1 # önce bir bölüm dene, sonra hepsi
    python3 tools/voice_gen.py fix SPK_HUSEYIN # bir karakterin bütün repliklerini yeniden üret
    python3 tools/voice_gen.py redo D10B_U_B3_1 [--tone "[panicked]"]
                                               # tek repliği (istersen başka tonla) yeniden üret
    (eski yol) python3 tools/voice_gen.py cast # hazır kütüphaneden ses ara
Seçenekler: --model eleven_v3 (varsayılan; ton etiketlerini anlar), --force (var olanları yeniden üret)
"""
import argparse, base64, csv, html, json, os, re, sys, time, urllib.parse, urllib.request, urllib.error

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
API = "https://api.elevenlabs.io"
CAST = os.path.join(ROOT, "docs/voice/cast.json")
CAST_EN = os.path.join(ROOT, "docs/voice/cast_en.json")          # İngilizce dublaj kadrosu (ayrı sesler)
AUDITION_EN = os.path.join(ROOT, "docs/voice/audition_en.json")
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


def load_cast(lang="tr"):
    """tr: cast.json. en: cast_en.json'daki seçimler; seçilmemiş ana karakterin sesi yoktur (Türkçe sesle İngilizce
    okunmasın), yan karakterler Türkçedeki gibi same_as ile İngilizce seçimleri izler."""
    base = json.load(open(CAST, encoding="utf-8"))
    if lang != "en":
        return base
    en = json.load(open(CAST_EN, encoding="utf-8")) if os.path.exists(CAST_EN) else {}
    out = {}
    for spk, c in base.items():
        if spk.startswith("_"):
            continue
        if spk in en:
            out[spk] = en[spk]
        elif "same_as" in c or c.get("skip"):
            out[spk] = c
        else:
            out[spk] = {k: v for k, v in c.items() if k not in ("voice_id", "voice_name")}
    return out


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
    model = voice.get("model", model)  # karaktere özel model (tune ile seçilir)
    if model.startswith("eleven_v3"):
        # v3: ton etiketi metnin başına; stability yalnız 0 (yaratıcı) / 0.5 (doğal) / 1 (sabit)
        st = min((0.0, 0.5, 1.0), key=lambda x: abs(x - voice.get("v3_stability", voice.get("stability", 0.5))))
        body = {"text": (tone + " " + text).strip() if tone else text, "model_id": model,
                "voice_settings": {"stability": st}}
    else:
        body = {"text": text, "model_id": model,
                "voice_settings": {"stability": voice.get("stability", 0.5), "similarity_boost": voice.get("similarity", 0.8),
                                   "style": voice.get("style", 0.2), "use_speaker_boost": True}}
    data = call("POST", f"/v1/text-to-speech/{voice['voice_id']}?output_format=mp3_44100_128", body, raw=True)
    if out is None:
        return data
    os.makedirs(os.path.dirname(out), exist_ok=True)
    open(out, "wb").write(data)


# Çok kişili satırlar (ör. REACT_GUARDS_PHONE: 'Hasan: "..." Hüseyin: "..."'): her parça kendi sesiyle, tek dosyada birleşir.
NAME_SPK = {"Tolga": "SPK_TOLGA", "Hikmet": "SPK_HIKMET", "Hasan": "SPK_HASAN", "Hüseyin": "SPK_HUSEYIN", "Huseyin": "SPK_HUSEYIN",
            "Fatih": "SPK_FATIH", "Mehmed": "SPK_FATIH", "Kadri": "SPK_KADRI", "Urban": "SPK_URBAN", "Giustiniani": "SPK_GIUST",
            "Niko": "SPK_NIKO", "Nihat": "SPK_NIHAT", "Lütfi": "SPK_LUTFI", "Lutfi": "SPK_LUTFI"}
LABEL = re.compile(r'(?:^|(?<=[\s."!?…]))(' + "|".join(NAME_SPK) + r')(?: \([^)]*\))?:\s')


def segments(raw, default_spk):
    """[(konuşmacı, temiz metin), ...]; etiket yoksa tek parça."""
    parts, spk, pos = [], default_spk, 0
    for m in LABEL.finditer(raw):
        parts.append((spk, raw[pos:m.start()])); spk = NAME_SPK[m.group(1)]; pos = m.end()
    parts.append((spk, raw[pos:]))
    out = []
    for sp, t in parts:
        t = clean(t).strip(' "“”')
        if t:
            out.append((sp, t))
    return out


def speak(r, lang, out, model, cast, tone):
    """Satırı üretir; çok kişiliyse parçaları ayrı seslerle üretip MP3 olarak uç uca ekler. Harcanan karakteri döner."""
    segs = segments(r["tr" if lang == "tr" else "en"], r["konusmaci"])
    if len(segs) <= 1:
        text = segs[0][1] if segs else clean(r["tr" if lang == "tr" else "en"])
        tts(resolve(cast, r["konusmaci"]), text, out, model, tone)
        return len(text)
    data = b""
    for sp, t in segs:
        v = resolve(cast, sp)
        if not v.get("voice_id"):
            v = resolve(cast, r["konusmaci"])
        data += tts(v, t, None, model, tone if sp == r["konusmaci"] else "")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    open(out, "wb").write(data)
    return sum(len(t) for _, t in segs)


def rows(lang):
    for r in csv.DictReader(open(MAP, encoding="utf-8")):
        text = clean(r["tr" if lang == "tr" else "en"])
        if text and r["konusmaci"] != "?":
            yield r, text


def tone_of(r, cast):
    """Elle yazılmış ton > karakterin okuma modu (tune ile seçilen, repliğe göre) > karakterin sabit tonu."""
    if r.get("ton_elle") == "1" and r.get("ton"):
        return r["ton"]
    mode = resolve(cast, r["konusmaci"]).get("ton_mode", "")
    if mode:
        return scene_tone(clean(r.get("tr", "")), mode)
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


# Tasarlanan her sese eklenir: kayıt kalitesi ve doğal okuma (robotik / "kayıt gibi" duyulmasın)
DESIGN_QUALITY = (" Studio-quality voice: clean close-mic recording, no background noise, no room echo, no reverb, "
                  "full and warm tone. Natural, conversational, human delivery with lively intonation, never monotone or robotic.")


def design_previews(desc, text, model):
    desc = (desc.rstrip(". ") + "." + DESIGN_QUALITY)[:1000]
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
        prev = design_previews(args.desc or c["design"], text, args.design_model)
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
    """pick SPK_X N  ya da  pick rest N (seçilmemiş tüm karakterlere N. örneği ver).
    --lang en: audition sayfasındaki N. adayı İngilizce kadroya alır."""
    if args.lang == "en":
        if args.target == "auto":
            return pick_en_auto()
        return pick_en(args.target, int(args.n))
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
    cast = load_cast(args.lang); n = 0; chars = 0; missing = set()
    for r, text in rows(args.lang):
        if args.chapter and r["bolum"] != str(args.chapter):
            continue
        if args.upto and int(r["bolum"] or 0) > args.upto:
            continue
        if args.speaker and r["konusmaci"] != args.speaker:
            continue
        out = os.path.join(ROOT, "assets/audio/voice", args.lang, r["anahtar"] + ".mp3")
        if os.path.exists(out) and not args.force:
            continue
        v = resolve(cast, r["konusmaci"])
        if v.get("skip"):
            continue
        if not v.get("voice_id"):
            if r["konusmaci"] not in missing:
                hint = "audition --lang en + pick ... --lang en" if args.lang == "en" else "design + pick"
                print(f"ses yok (önce {hint}):", r["konusmaci"]); missing.add(r["konusmaci"])
            continue
        if args.budget and chars + len(text) > args.budget:
            print(f"Bütçe doldu ({chars} karakter). Kalanlar için komutu sonra tekrar çalıştır."); break
        chars += speak(r, args.lang, out, args.model, cast, tone_of(r, cast))
        n += 1
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
    cast = load_cast(args.lang)
    all_rows = list(csv.DictReader(open(MAP, encoding="utf-8")))
    r = next(x for x in all_rows if x["anahtar"] == args.target)
    if args.tone is not None:
        r["ton"] = args.tone; r["ton_elle"] = "1"
        with open(MAP, "w", encoding="utf-8", newline="") as fh:
            w = csv.DictWriter(fh, fieldnames=list(all_rows[0].keys())); w.writeheader(); w.writerows(all_rows)
    text = clean(r["tr" if args.lang == "tr" else "en"])
    speak(r, args.lang, os.path.join(ROOT, "assets/audio/voice", args.lang, r["anahtar"] + ".mp3"), args.model, cast,
          tone_of(r, cast))
    print("yeniden üretildi:", r["anahtar"], tone_of(r, cast))


def cmd_fix(args):
    """docs/voice/FIX_LIST.txt'teki (yanlış sesle üretilmiş) replikleri ses haritasındaki doğru sesle yeniden üretir."""
    cast = load_cast(args.lang)
    path = os.path.join(ROOT, args.list or "docs/voice/FIX_LIST.txt")
    keys = [k.strip() for k in open(path, encoding="utf-8") if k.strip() and not k.startswith("#")] if os.path.exists(path) else []
    if args.target.startswith("SPK_"):
        # fix SPK_X: o karakterin bütün repliklerini yeniden üret (ör. sesi değiştirildiyse)
        keys = [x["anahtar"] for x in csv.DictReader(open(MAP, encoding="utf-8")) if x["konusmaci"] == args.target
                and os.path.exists(os.path.join(ROOT, "assets/audio/voice/tr", x["anahtar"] + ".mp3"))]
    if args.only:
        keys = [k for k in keys if any(k.startswith(p) for p in args.only.split(","))]
    rows = {x["anahtar"]: x for x in csv.DictReader(open(MAP, encoding="utf-8"))}
    done_path = os.path.join(ROOT, "docs/voice/.fix_done" if not args.list else "docs/voice/.regen_done")
    done = set(open(done_path).read().split()) if os.path.exists(done_path) else set()
    todo = [k for k in keys if k in rows and k not in done]
    print(f"Yeniden üretilecek: {len(todo)} replik ({len(keys) - len(todo)} zaten yapıldı ya da haritada yok)")
    for i, k in enumerate(todo, 1):
        r = rows[k]
        speak(r, "tr", os.path.join(ROOT, "assets/audio/voice/tr", k + ".mp3"), args.model, cast, tone_of(r, cast))
        with open(done_path, "a") as f:
            f.write(k + "\n")
        print(f"  [{i}/{len(todo)}] {k}  ->  {r['konusmaci']}")
    print("Bitti.")


# ---------------------------------------------------------------- ses ayarı denemesi (robotik okuma)

TRY_DIR = os.path.join(ROOT, "docs/voice/try")
# Aynı ses, farklı okuma: model ve ayarlar. tune ile seçilen cast.json'a yazılır.
VARIANTS = [
    ("Şu anki (karşılaştırma için)", {}),
    ("v3 sahnede: repliğe göre durum etiketi (panik / şaşkın / tereddüt / yanındakine konuşur)",
     {"model": "eleven_v3", "v3_stability": 0.0, "ton_mode": "scene"}),
    ("v3 nefes nefese: koşturmaca, hızlı, kesik", {"model": "eleven_v3", "v3_stability": 0.0, "ton_mode": "[out of breath] [talking fast]"}),
    ("v3 doğal sohbet: karşısındakine, duraklamalı", {"model": "eleven_v3", "v3_stability": 0.5, "ton_mode": "[conversational] [natural pauses]"}),
    ("v3 yakın ve samimi: mikrofona yakın, rahat, anlatmıyor konuşuyor", {"model": "eleven_v3", "v3_stability": 0.0, "ton_mode": "[close to the mic] [casual] [talking to a friend]"}),
    ("v3 gergin komik: telaşlı; sinirli gülüş yer yer, ünlemde panik, soruda şaşkın", {"model": "eleven_v3", "v3_stability": 0.0, "ton_mode": "comic"}),
    ("Multilingual v2 çok canlı", {"model": "eleven_multilingual_v2", "stability": 0.2, "similarity": 0.75, "style": 0.8}),
    ("v3 sahnede + hızlı tempo", {"model": "eleven_v3", "v3_stability": 0.0, "ton_mode": "scene_fast"}),
]


def scene_tone(text, mode):
    """Okuma modu -> v3 ton etiketi. 'scene'/'scene_fast': replik tipine göre; 'comic': gergin komik
    (her replikte telaş, sinirli gülüş yaklaşık iki replikte bir: 400 replikte hep gülüş bıktırır); aksi: sabit etiket."""
    if mode == "comic":
        if "!" in text and "?" in text:
            return "[excited] [flustered]"
        if "!" in text and len(text) < 70:
            return "[flustered] [panicked]"
        if "?" in text:
            return "[flustered] [confused]"
        laugh = sum(ord(c) for c in text) % 2 == 0 or "…" in text or "..." in text
        return "[nervous laugh] [flustered]" if laugh else "[flustered]"
    if mode in ("scene", "scene_fast"):
        if "!" in text and "?" in text:
            t = "[panicked] [confused]"
        elif "!" in text:
            t = "[panicked]" if len(text) < 60 else "[excited] [urgent]"
        elif "?" in text:
            t = "[confused] [asking someone in front of him]"
        elif "…" in text or "..." in text:
            t = "[hesitant] [trailing off]"
        else:
            t = "[talking to someone right next to him]"
        return t + (" [talking fast]" if mode == "scene_fast" else "")
    return mode


def cmd_try(args):
    """try SPK_X: karakterin 4 farklı tipte repliğini (soru, ünlem, tereddüt, düz) 8 okumayla üretir
    (~2500 karakter). docs/voice/try/index.html"""
    spk = args.target
    cast = load_cast()
    base = resolve(cast, spk)
    if not base.get("voice_id"):
        sys.exit(f"{spk} için ses yok")
    picks = []
    for r, text in rows("tr"):
        if r["konusmaci"] != spk or not (40 <= len(text) <= 110):
            continue
        kind = "?" if "?" in text else "!" if "!" in text else "…" if "…" in text else "."
        if kind not in [k for k, _, _ in picks]:
            picks.append((kind, r, text))
        if len(picks) == 4:
            break
    os.makedirs(TRY_DIR, exist_ok=True)
    name = spk[4:].lower()
    page = ["<!doctype html><meta charset=utf-8><title>Ses ayarı</title><style>body{font:15px system-ui;background:#141824;"
            "color:#f2e6c9;max-width:1000px;margin:auto;padding:16px}td{padding:6px;vertical-align:top}audio{width:220px}"
            "code{color:#ffd24a}</style>", f"<h1>{spk[4:].title()}: aynı ses, {len(VARIANTS)} okuma</h1><p>Sütunlar okuma biçimi, satırlar farklı replik tipleri. Beğendiğin sütunun altındaki komutu çalıştır.</p><table><tr><td></td>"]
    page += [f"<td><b>{i + 1}. {html.escape(lbl)}</b><br><code>python tools/voice_gen.py tune {spk} {i + 1}</code></td>" for i, (lbl, _) in enumerate(VARIANTS)]
    page.append("</tr>")
    for j, (_, r, text) in enumerate(picks):
        page.append(f"<tr><td><i>{html.escape(text)}</i></td>")
        for i, (_, over) in enumerate(VARIANTS):
            v = dict(base); v.update(over)
            fn = f"{name}_{j + 1}_{i + 1}.mp3"
            tone = scene_tone(text, over["ton_mode"]) if over.get("ton_mode") else tone_of(r, cast)
            tts(v, text, os.path.join(TRY_DIR, fn), args.model, tone)
            page.append(f"<td><audio controls preload=none src='{fn}'></audio><br><small>{html.escape(tone)}</small></td>")
        page.append("</tr>")
        print(f"{j + 1}/{len(picks)}: {text[:60]}")
    page.append("</table>")
    open(os.path.join(TRY_DIR, "index.html"), "w", encoding="utf-8").write("\n".join(page))
    print("Dinle:", os.path.relpath(os.path.join(TRY_DIR, "index.html"), ROOT))


def cmd_tune(args):
    """tune SPK_X N: try sayfasındaki N. okuma ayarını karaktere kalıcı yazar (sonra: all --speaker SPK_X --force)."""
    raw = json.load(open(CAST, encoding="utf-8"))
    spk = args.target
    c = raw[spk]
    for k in ("model", "v3_stability", "ton_mode"):
        c.pop(k, None)
    c.update(VARIANTS[int(args.n) - 1][1])
    json.dump(raw, open(CAST, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(f"{spk}: {VARIANTS[int(args.n) - 1][0]}")


# ---------------------------------------------------------------- sahne provası

SCENES = {
    "garaj": ["D1_T_07", "D1_H_07B", "D1_T_07C", "D1_H_08", "D1_T_09"],
}
PREFIX_SPK = {"T": "SPK_TOLGA", "H": "SPK_HIKMET", "N": "SPK_NIHAT", "F": "SPK_FATIH", "K": "SPK_KADRI", "U": "SPK_URBAN"}


def cmd_scene(args):
    """scene garaj [--variants 1,6]: sahnedeki replikleri sırayla üretir ve altyazılı oynatan bir sayfa yapar
    (docs/voice/try/scene_<ad>.html). --variants: Tolga'nın replikleri için try sayfasındaki okuma numaraları;
    her okuma ayrı bir "çekim" olarak aynı sahnede dinlenir. Anahtarlar virgülle de verilebilir: scene D1_T_07,D1_H_07B"""
    keys = SCENES.get(args.target) or args.target.split(",")
    name = args.target if args.target in SCENES else "ozel"
    cast = load_cast()
    text = {r[0]: r[1] for r in csv.reader(open(os.path.join(ROOT, "i18n/strings.csv"), encoding="utf-8")) if len(r) > 1}
    spk_of = {r["anahtar"]: r["konusmaci"] for r in csv.DictReader(open(MAP, encoding="utf-8"))}
    takes = [int(x) for x in args.variants.split(",")] if args.variants else [0]
    os.makedirs(TRY_DIR, exist_ok=True)
    js_takes = []
    for tk in takes:
        lines = []
        for k in keys:
            spk = spk_of.get(k) or PREFIX_SPK.get(k.split("_")[1][:1], "SPK_TOLGA")
            t = clean(text.get(k, ""))
            if not t:
                continue
            v = dict(resolve(cast, spk))
            tone = tone_of({"konusmaci": spk, "tr": text.get(k, "")}, cast)
            if tk and spk == "SPK_TOLGA":
                over = VARIANTS[tk - 1][1]
                v.update(over)
                tone = scene_tone(t, over["ton_mode"]) if over.get("ton_mode") else tone
            fn = f"scene_{name}_{tk}_{k}.mp3"
            if not os.path.exists(os.path.join(TRY_DIR, fn)) or args.force:
                tts(v, t, os.path.join(TRY_DIR, fn), args.model, tone)
                print(f"  {k} ({spk[4:].title()}) {tone}")
            lines.append({"src": fn, "who": spk[4:].title(), "text": t, "tone": tone})
        label = "Şu anki ayarlar" if tk == 0 else f"Tolga okuma {tk}: {VARIANTS[tk - 1][0]}"
        js_takes.append({"label": label, "lines": lines})
    page = """<!doctype html><meta charset=utf-8><title>Sahne provası</title>
<style>body{font:16px system-ui;background:#141824;color:#f2e6c9;max-width:820px;margin:auto;padding:20px}
button{font:600 16px system-ui;padding:10px 16px;margin:4px;border-radius:10px;border:0;background:#c8262e;color:#fff;cursor:pointer}
#sub{margin-top:24px;min-height:90px;background:#23253a;border-radius:12px;padding:16px}#who{color:#ffd24a;font-weight:700}
small{color:#9a9aa8}</style><h1>Sahne provası: %s</h1><p>Bir çekim seç: replikler sırayla, aralarında kısa bir nefesle oynar.</p>
<div id=btns></div><div id=sub><div id=who></div><div id=txt></div><small id=tone></small></div>
<script>const TAKES=%s;let cur=null;
function play(t){if(cur)cur.pause();let i=0;const L=TAKES[t].lines;
 const next=()=>{if(i>=L.length){who.textContent='';txt.textContent='— son —';tone.textContent='';return}
  const l=L[i++];who.textContent=l.who;txt.textContent=l.text;tone.textContent=l.tone;
  cur=new Audio(l.src);cur.onended=()=>setTimeout(next,350);cur.onerror=()=>setTimeout(next,1200);cur.play()};next()}
TAKES.forEach((t,i)=>{const b=document.createElement('button');b.textContent='▶ '+t.label;b.onclick=()=>play(i);btns.appendChild(b)});
</script>""" % (html.escape(args.target), json.dumps(js_takes, ensure_ascii=False))
    out = os.path.join(TRY_DIR, f"scene_{name}.html")
    open(out, "w", encoding="utf-8").write(page)
    print("Dinle:", os.path.relpath(out, ROOT))


# ---------------------------------------------------------------- yeni ses seçmesi (Türkçe)

CASTING_DIR = os.path.join(ROOT, "docs/voice/casting")
CASTING_BRIEFS = {
    "SPK_TOLGA": [
        ("Vlog enerjisi", "Energetic Turkish man in his late twenties, speaks fast and animated, reacts in the moment like he is filming a vlog, "
         "voice jumps up when surprised, casual modern Istanbul Turkish. Absolutely not a narrator, not an audiobook voice."),
        ("Telaşlı plaza çalışanı", "Young Turkish office worker, 28, nervous and excitable, talks quickly with lots of energy, laughs mid-sentence, "
         "pitch rises when he panics, natural conversational delivery, sounds like he is talking to a friend standing right next to him."),
        ("Coşkulu yayıncı", "Bright, youthful Turkish male voice, around 25, playful and hyped, like a streamer reacting live to something amazing, "
         "expressive pitch, fast pacing, informal, comedic timing, breathy excitement."),
    ],
}


def casting_text(spk):
    """Adayların okuyacağı metin: sahnedeki gerçek replikler (Tolga için garaj anı)."""
    text = {r[0]: r[1] for r in csv.reader(open(os.path.join(ROOT, "i18n/strings.csv"), encoding="utf-8")) if len(r) > 1}
    keys = [k for k in SCENES["garaj"] if k.split("_")[1][:1] == "T"] if spk == "SPK_TOLGA" else []
    t = " ".join(clean(text[k]) for k in keys if k in text)
    return t if len(t) >= 100 else sample_text(spk)


def cmd_casting(args):
    """casting SPK_TOLGA: yeni ses adayları. 3 tarif x 3 tasarım (gerçek repliklerle) + Türkçe kütüphaneden genç, enerjik
    erkek sesleri (önizleme ücretsiz). Sayfa: docs/voice/casting/index.html. Seçmek için: cast_pick SPK_TOLGA d4 / l2"""
    spk = args.target or "SPK_TOLGA"
    os.makedirs(CASTING_DIR, exist_ok=True)
    path = os.path.join(CASTING_DIR, "state.json")
    state = json.load(open(path, encoding="utf-8")) if os.path.exists(path) else {}
    text = casting_text(spk)
    cands = []
    for bi, (label, desc) in enumerate(CASTING_BRIEFS.get(spk, [])):
        prev = design_previews(desc, text, args.design_model)
        for i, pv in enumerate(prev[:3]):
            fn = f"{spk[4:].lower()}_d{bi + 1}_{i + 1}.mp3"
            open(os.path.join(CASTING_DIR, fn), "wb").write(base64.b64decode(pv["audio_base_64"]))
            cands.append({"id": f"d{len(cands) + 1}", "kind": "design", "label": label, "desc": desc, "file": fn,
                          "generated_voice_id": pv["generated_voice_id"]})
        print(f"tasarım '{label}': {min(3, len(prev))} aday")
    q = {"page_size": 50, "language": "tr", "gender": "male", "age": "young", "sort": "usage_character_count_1y"}
    lib = call("GET", "/v1/shared-voices?" + urllib.parse.urlencode(q)).get("voices", [])
    words = ["energetic", "excited", "young", "casual", "conversational", "character", "playful", "lively", "upbeat", "animated", "fun"]
    blob = lambda v: " ".join(str(v.get(k) or "") for k in ("name", "description", "accent", "use_case", "descriptive")).lower()
    bad = ("narrat", "audiobook", "documentary", "news", "calm", "deep", "meditation")
    lib = [v for v in lib if not any(b in blob(v) for b in bad)]
    lib.sort(key=lambda v: sum(w in blob(v) for w in words), reverse=True)
    for v in lib[:8]:
        cands.append({"id": f"l{sum(c['kind'] == 'library' for c in cands) + 1}", "kind": "library", "label": v.get("name", ""),
                      "desc": blob(v)[:200], "preview": v.get("preview_url", ""), "voice_id": v["voice_id"],
                      "owner": v.get("public_owner_id", "")})
    print(f"kütüphane: {sum(c['kind'] == 'library' for c in cands)} aday")
    state[spk] = {"text": text, "candidates": cands}
    json.dump(state, open(path, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    out = ["<!doctype html><meta charset=utf-8><title>Ses seçmesi</title><style>body{font:15px system-ui;background:#141824;"
           "color:#f2e6c9;max-width:960px;margin:auto;padding:16px}.c{display:inline-block;width:290px;vertical-align:top;margin:8px;"
           "background:#23253a;border-radius:10px;padding:10px}audio{width:270px}code{color:#ffd24a;font-size:13px}small{color:#9a9aa8}"
           "</style>", f"<h1>{spk[4:].title()}: yeni ses adayları</h1>",
           f"<p><b>Tasarım adayları</b> sahnedeki gerçek replikleri okuyor: <i>{html.escape(text)}</i></p>"]
    for c in cands:
        if c["kind"] == "design":
            out.append(f"<div class=c><b>{c['id']} · {html.escape(c['label'])}</b><br><audio controls src='{c['file']}'></audio>"
                       f"<br><code>python tools/voice_gen.py cast_pick {spk} {c['id']}</code></div>")
    out.append("<p><b>Kütüphane adayları</b> (önizleme kendi örnek metinleri; Türkçe genç erkek sesleri):</p>")
    for c in cands:
        if c["kind"] == "library":
            out.append(f"<div class=c><b>{c['id']} · {html.escape(c['label'])}</b><br><audio controls src='{c['preview']}'></audio>"
                       f"<br><small>{html.escape(c['desc'][:120])}</small><br><code>python tools/voice_gen.py cast_pick {spk} {c['id']}</code></div>")
    open(os.path.join(CASTING_DIR, "index.html"), "w", encoding="utf-8").write("\n".join(out))
    print("Dinle:", os.path.relpath(os.path.join(CASTING_DIR, "index.html"), ROOT))


def cmd_cast_pick(args):
    """cast_pick SPK_TOLGA d4|l2: seçmedeki adayı karakterin sesi yapar (eski voice_id cast.json'da old_voice_id olarak saklanır)."""
    spk, cid = args.target, args.n
    st = json.load(open(os.path.join(CASTING_DIR, "state.json"), encoding="utf-8"))[spk]
    c = next(x for x in st["candidates"] if x["id"] == cid)
    raw = json.load(open(CAST, encoding="utf-8"))
    ch = raw[spk]
    name = f"NHG {spk[4:].title()} {cid}"
    if c["kind"] == "design":
        res = call("POST", "/v1/text-to-voice", {"voice_name": name, "voice_description": c["desc"][:1000],
                                                "generated_voice_id": c["generated_voice_id"]}, soft=True)
        if res is None:
            res = call("POST", "/v1/text-to-voice/create-voice-from-preview",
                       {"voice_name": name, "voice_description": c["desc"][:1000], "generated_voice_id": c["generated_voice_id"]})
        vid = res["voice_id"]
    else:
        mine = {v["voice_id"] for v in call("GET", "/v1/voices").get("voices", [])}
        if c["voice_id"] not in mine:
            call("POST", f"/v1/voices/add/{c['owner']}/{c['voice_id']}", {"new_name": name})
        vid = c["voice_id"]
    if ch.get("voice_id") and ch.get("voice_id") != vid:
        ch["old_voice_id"] = ch["voice_id"]
    ch["voice_id"] = vid
    ch["voice_name"] = name
    json.dump(raw, open(CAST, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(f"{spk} -> {name}. Dinlemek için: python tools/voice_gen.py scene garaj --force")


def cmd_cast_set(args):
    """cast_set SPK_TOLGA <voice_id>: ElevenLabs'ta beğenilen bir sesi doğrudan karaktere bağlar. Ses hesabında yoksa
    topluluk kütüphanesinde aranır ve hesaba eklenir. Eski ses old_voice_id olarak saklanır."""
    spk, vid = args.target, args.n
    mine = {v["voice_id"]: v for v in call("GET", "/v1/voices").get("voices", [])}
    name = mine.get(vid, {}).get("name", "")
    if vid not in mine:
        found = None
        for q in ({"search": vid}, {"search": vid, "language": "tr"}):
            for v in call("GET", "/v1/shared-voices?" + urllib.parse.urlencode(dict(q, page_size=30))).get("voices", []):
                if v.get("voice_id") == vid:
                    found = v
                    break
            if found:
                break
        if found:
            name = f"NHG {spk[4:].title()} ({found.get('name', '')})"
            call("POST", f"/v1/voices/add/{found['public_owner_id']}/{vid}", {"new_name": name})
            print("Kütüphaneden hesaba eklendi:", found.get("name", ""))
        elif call("GET", f"/v1/voices/{vid}", soft=True) is None:
            sys.exit("Bu ses hesabında da kütüphanede de bulunamadı. ElevenLabs sitesinde sesin sayfasında 'Add to My Voices' "
                     "(Seslerime ekle) deyip komutu tekrar çalıştır.")
    raw = json.load(open(CAST, encoding="utf-8"))
    ch = raw[spk]
    if ch.get("voice_id") and ch["voice_id"] != vid:
        ch["old_voice_id"] = ch["voice_id"]
    ch["voice_id"] = vid
    ch["voice_name"] = name or f"NHG {spk[4:].title()}"
    json.dump(raw, open(CAST, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(f"{spk} -> {ch['voice_name']} ({vid}). Dinlemek için: python tools/voice_gen.py scene garaj --variants 1,6 --force")


# ---------------------------------------------------------------- İngilizce dublaj: seçmeler

def _words(c):
    txt = (c.get("design", "") + " " + c.get("search", "")).lower()
    for ch in ",.;:()'\"":
        txt = txt.replace(ch, " ")
    stop = {"the", "a", "an", "and", "with", "of", "in", "his", "her", "to", "is", "from", "who", "but", "very", "slightly", "turkish", "istanbul", "accent", "ottoman", "byzantine"}
    return [w for w in txt.split() if len(w) > 3 and w not in stop]


def _score(words, blob):
    blob = blob.lower()
    return sum(1 for w in words if w in blob)


def cmd_audition(args):
    """Her ana karakter için 6 İngilizce aday: 2 hazır (premade, özel ses hakkı harcamaz) + 4 topluluk kütüphanesi.
    Önizlemeler ücretsizdir. Sayfa: docs/voice/audition_en.html"""
    tr_cast = load_cast("tr")
    only = set(args.only.split(",")) if args.only else None
    mine = call("GET", "/v1/voices").get("voices", [])
    premade = [v for v in mine if v.get("category") == "premade"]
    state = json.load(open(AUDITION_EN, encoding="utf-8")) if os.path.exists(AUDITION_EN) else {}
    for spk, c in tr_cast.items():
        if spk.startswith("_") or "same_as" in c or c.get("skip") or not c.get("gender"):
            continue
        if only and spk not in only:
            continue
        words = _words(c)
        gender, age = c.get("gender", ""), c.get("age", "")
        def pm_blob(v):
            l = v.get("labels", {}) or {}
            return " ".join(str(x) for x in l.values()) + " " + (v.get("description") or "") + " " + v.get("name", "")
        pms = [v for v in premade if (v.get("labels", {}) or {}).get("gender", gender) == gender]
        pms.sort(key=lambda v: (_score(words, pm_blob(v)) + (2 if (v.get("labels", {}) or {}).get("age", "").replace(" ", "_") == age else 0)), reverse=True)
        q = {"page_size": 40, "language": "en", "gender": gender, "age": age, "sort": "usage_character_count_1y"}
        lib = call("GET", "/v1/shared-voices?" + urllib.parse.urlencode(q)).get("voices", [])
        if len(lib) < 4:
            q.pop("age")
            lib = call("GET", "/v1/shared-voices?" + urllib.parse.urlencode(q)).get("voices", [])
        def lib_blob(v):
            return " ".join(str(v.get(k) or "") for k in ("name", "description", "accent", "use_case", "descriptive"))
        lib.sort(key=lambda v: _score(words, lib_blob(v)), reverse=True)
        cands = []
        for v in pms[:2]:
            cands.append({"voice_id": v["voice_id"], "name": v.get("name", ""), "kind": "premade",
                          "preview": v.get("preview_url", ""), "info": pm_blob(v).strip()[:160]})
        for v in lib[:4]:
            cands.append({"voice_id": v["voice_id"], "name": v.get("name", ""), "kind": "library", "owner": v.get("public_owner_id", ""),
                          "preview": v.get("preview_url", ""), "info": lib_blob(v).strip()[:160]})
        state[spk] = {"tarif": c.get("tarif", ""), "design": c.get("design", ""), "candidates": cands}
        print(f"{spk:18s} {len(cands)} aday")
    json.dump(state, open(AUDITION_EN, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    en = json.load(open(CAST_EN, encoding="utf-8")) if os.path.exists(CAST_EN) else {}
    rows_html = []
    for spk, st in state.items():
        chosen = en.get(spk, {}).get("voice_id")
        cells = []
        for i, cd in enumerate(st["candidates"], 1):
            mark = " ✓" if cd["voice_id"] == chosen else ""
            tag = "hazır (hak harcamaz)" if cd["kind"] == "premade" else "kütüphane"
            cells.append(f"<div class=c><b>{i}. {html.escape(cd['name'])}{mark}</b> <small>{tag}</small><br>"
                         f"<audio controls preload=none src='{html.escape(cd['preview'])}'></audio><br><small>{html.escape(cd['info'])}</small>"
                         f"<br><code>pick {spk} {i} --lang en</code></div>")
        rows_html.append(f"<section><h2>{spk[4:].title()} <small>{html.escape(st['tarif'])}</small></h2>"
                         f"<p>{html.escape(st['design'])}</p><div class=row>{''.join(cells)}</div></section>")
    page = ("<!doctype html><meta charset=utf-8><title>English cast</title><style>body{font:14px system-ui;background:#141824;"
            "color:#f2e6c9;max-width:1200px;margin:auto;padding:16px}section{border-top:1px solid #333;padding:10px 0}"
            ".row{display:flex;flex-wrap:wrap;gap:14px}.c{width:270px}audio{width:260px}small{color:#a9a390}code{color:#ffd24a}"
            "</style><h1>İngilizce dublaj seçmeleri</h1><p>Önizlemeler ücretsiz. Beğendiğin adayın komutunu çalıştır. "
            "Hazır sesler özel ses hakkı harcamaz; kütüphane sesleri bir hak kullanır.</p>" + "".join(rows_html))
    out = os.path.join(ROOT, "docs/voice/audition_en.html")
    open(out, "w", encoding="utf-8").write(page)
    print("Dinleme sayfası:", os.path.relpath(out, ROOT))


def pick_en_auto():
    """Seçilmemiş her karaktere ilk uygun adayı verir; başka karakterin aldığı sesi atlar (herkes farklı seslensin)."""
    state = json.load(open(AUDITION_EN, encoding="utf-8")) if os.path.exists(AUDITION_EN) else {}
    if not state:
        sys.exit("Aday yok: önce python tools/voice_gen.py audition --lang en")
    en = json.load(open(CAST_EN, encoding="utf-8")) if os.path.exists(CAST_EN) else {}
    used = {v.get("voice_id") for v in en.values()}
    for spk, st in state.items():
        if spk in en:
            continue
        for i, cd in enumerate(st["candidates"], 1):
            if cd["voice_id"] not in used:
                pick_en(spk, i)
                used.add(cd["voice_id"])
                break
        else:
            print(f"{spk}: bütün adaylar başkasında, elle seç")


def pick_en(spk, n):
    state = json.load(open(AUDITION_EN, encoding="utf-8")) if os.path.exists(AUDITION_EN) else {}
    if spk not in state:
        sys.exit(f"{spk} için aday yok: önce python tools/voice_gen.py audition --lang en")
    cd = state[spk]["candidates"][n - 1]
    en = json.load(open(CAST_EN, encoding="utf-8")) if os.path.exists(CAST_EN) else {}
    others = [k for k, v in en.items() if v.get("voice_id") == cd["voice_id"] and k != spk]
    if others:
        print("Uyarı: bu ses zaten", ", ".join(others), "için seçili.")
    if cd["kind"] == "library":
        mine = {v["voice_id"] for v in call("GET", "/v1/voices").get("voices", [])}
        if cd["voice_id"] not in mine:
            call("POST", f"/v1/voices/add/{cd['owner']}/{cd['voice_id']}", {"new_name": f"NHG EN {spk[4:].title()}"})
    tr = load_cast("tr").get(spk, {})
    en[spk] = {"voice_id": cd["voice_id"], "voice_name": cd["name"], "stability": tr.get("stability", 0.5),
               "similarity": tr.get("similarity", 0.8), "style": tr.get("style", 0.3), "tarif": tr.get("tarif", "")}
    json.dump(en, open(CAST_EN, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(f"{spk} (EN) -> {cd['name']} ({cd['kind']})")


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("cmd", choices=["cast", "design", "pick", "share", "samples", "all", "review", "redo", "check", "fix", "audition", "try", "tune", "scene", "casting", "cast_pick", "cast_set"])
    p.add_argument("target", nargs="?", default="")
    p.add_argument("n", nargs="?", default="1")
    p.add_argument("--only", default="")
    p.add_argument("--tone", default=None)
    p.add_argument("--design-model", default="eleven_ttv_v3")
    p.add_argument("--lang", default="tr", choices=["tr", "en"])
    p.add_argument("--chapter", type=int, default=0)
    p.add_argument("--desc", default="", help="design: tarif yerine bu İngilizce ses tarifi (tek karakterle)")
    p.add_argument("--speaker", default="", help="yalnız bu konuşmacının replikleri (ör. SPK_TOLGA)")
    p.add_argument("--limit", type=int, default=0)
    p.add_argument("--upto", type=int, default=0, help="bu bölüme kadar (dahil)")
    p.add_argument("--budget", type=int, default=0, help="en fazla bu kadar karakter harca")
    p.add_argument("--model", default="eleven_v3")
    p.add_argument("--force", action="store_true")
    p.add_argument("--variants", default="", help="scene: Tolga için denenecek okuma numaraları, ör. 1,6")
    p.add_argument("--list", default="", help="fix: FIX_LIST.txt yerine bu listedeki replikleri üret (ör. docs/voice/REGEN_LIST.txt)")
    a = p.parse_args()
    if a.cmd == "check":
        u = call("GET", "/v1/user/subscription")
        print(f"Paket: {u.get('tier')} · kullanılan {u.get('character_count')}/{u.get('character_limit')} karakter")
    else:
        {"cast": cmd_cast, "design": cmd_design, "pick": cmd_pick, "share": cmd_share, "samples": cmd_samples, "all": cmd_all,
         "review": cmd_review, "redo": cmd_redo, "fix": cmd_fix, "audition": cmd_audition, "try": cmd_try, "tune": cmd_tune, "scene": cmd_scene, "casting": cmd_casting, "cast_pick": cmd_cast_pick, "cast_set": cmd_cast_set}[a.cmd](a)
