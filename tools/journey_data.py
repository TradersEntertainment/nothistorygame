#!/usr/bin/env python3
"""Final yolculuğu verisi: oyun bitince oynatılan Detroit tarzı akış şeması (scripts/ui/journey.gd) bu dosyayı okur.

Kaynak, tanıtım sitesinin hikâye haritasıyla aynıdır (tools/story_map.py): bölüm kartları, satırlar ve şeritler, bölümler
arası geçişler, her bölümün sonuç düğümleri. Metinler TR/EN hazır gelir; kapak küçük resimleri (assets/art/journey/)
oyunun bölüm kapaklarından (assets/art/covers/) küçültülür.

    python3 tools/journey_data.py           yaz (assets/data/journey.json + eksik küçük resimler)
    python3 tools/journey_data.py --check   dosya güncel mi (test paketi; değilse çıkış 1)
"""
import json, os, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import story_map as sm  # noqa: E402  (modül yüklenince bütün harita kurulur)

ROOT = sm.ROOT
OUT = os.path.join(ROOT, "assets", "data", "journey.json")
THUMBS = os.path.join(ROOT, "assets", "art", "journey")
THUMB_SIZE = (384, 216)


def cover_of(cid):
    """Kartın kapağı (assets/art/covers/<id>.png). Büro kartı kendi sahnesinin (17) değil, kapaksız; 15y 15'in kapağını kullanır."""
    name = {"ch15y": "ch15"}.get(cid, cid)
    return name if os.path.exists(os.path.join(ROOT, "assets", "art", "covers", name + ".png")) else None


def build():
    edges, lanes = sm.layout()
    chapters = {}
    for cid, c in sm.CHAPTERS.items():
        outs = []
        for n in c["nodes"]:
            if not n["outcome"]:
                continue
            o = [n["id"], n["label"]]
            if n.get("label_o"):
                o.append(n["label_o"])          # Osmanlı tarafındaki etiket (aynı düğüm, öbür taraf)
            outs.append(o)
            if n.get("alt_id"):
                outs.append([n["alt_id"], n["label_o"]])
        e = {"title": c["title"], "num": c.get("num", {}), "outs": outs}
        if c.get("side"):
            e["side"] = c["side"]
        if c.get("tag"):
            e["tag"] = c["tag"]
        cov = cover_of(cid)
        if cov:
            e["cover"] = cov
        chapters[cid] = e
    rows = []
    for r in sm.ROWS:
        if r["t"] == "act":
            rows.append({"act": r["act"]})
        else:
            rows.append({"cells": r["cells"]})
    acts = {k: {"kicker": a["kicker"], "title": a["title"]} for k, a in sm.ACTS.items()}
    out_ch = {}
    for cid, c in sm.CHAPTERS.items():
        for n in c["nodes"]:
            if n["outcome"]:
                out_ch.setdefault(n["id"], cid)
                if n.get("alt_id"):
                    out_ch.setdefault(n["alt_id"], cid)
    out_ch["26.1"] = "ch26"
    out_ch["26.2"] = "ch26"
    es = []
    for e in edges:
        x = {"from": e["from"], "to": e["to"], "la": e["la"], "lr": e["lr"], "lb": e["lb"]}
        for k in ("via", "side", "skip"):
            if k in e:
                x[k] = e[k]
        es.append(x)
    return {"lanes": lanes, "rows": rows, "acts": acts, "chapters": chapters, "edges": es,
            "outcome_chapter": out_ch, "sides": {sd: [sm.cid(sm.scene_for(ch, sd)) for ch in sm.SIDE_LIST[sd]] for sd in ("B", "O")}}


def thumbs(data, write):
    """Eksik ya da kapaktan eski küçük resimler (yazılmaz, yalnız sayılır: --check)."""
    stale = []
    for c in data["chapters"].values():
        cov = c.get("cover")
        if not cov:
            continue
        src = os.path.join(ROOT, "assets", "art", "covers", cov + ".png")
        dst = os.path.join(THUMBS, cov + ".jpg")
        if os.path.exists(dst) and os.path.getmtime(dst) >= os.path.getmtime(src):
            continue
        stale.append(cov)
        if write:
            from PIL import Image
            os.makedirs(THUMBS, exist_ok=True)
            im = Image.open(src).convert("RGB")
            im.thumbnail((THUMB_SIZE[0] * 2, THUMB_SIZE[1] * 2))
            im = im.resize(THUMB_SIZE, Image.LANCZOS)
            im.save(dst, quality=86, optimize=True)
    return stale


def main():
    data = build()
    text = json.dumps(data, ensure_ascii=False, separators=(",", ":"), sort_keys=True)
    if "--check" in sys.argv:
        old = open(OUT, encoding="utf-8").read() if os.path.exists(OUT) else ""
        missing = [c["cover"] for c in data["chapters"].values() if c.get("cover")
                   and not os.path.exists(os.path.join(THUMBS, c["cover"] + ".jpg"))]
        if old != text or missing:
            print("JOURNEY FAIL: assets/data/journey.json eski%s — python3 tools/journey_data.py"
                  % ((" (küçük resim yok: %s)" % ", ".join(missing)) if missing else ""))
            sys.exit(1)
        print("JOURNEY ok: %d kart" % len(data["chapters"]))
        return
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    open(OUT, "w", encoding="utf-8").write(text)
    made = thumbs(data, True)
    print("%d kart, %d geçiş, %d şerit -> %s (%d küçük resim yazıldı)" % (len(data["chapters"]), len(data["edges"]),
                                                                       data["lanes"], OUT, len(made)))


if __name__ == "__main__":
    main()
