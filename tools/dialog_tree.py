#!/usr/bin/env python3
"""Diyalog ağacı: oyundaki bütün repliklerin bölüm bölüm, dallanarak (koşul, seçim, başarı/başarısızlık) dökümü.

Tanıtım sitesinin diyalog sayfası (dialog.html) bu dosyayı okur. Her bölümün betiği kodun kendisinden okunur:
  - bölüm _run()'dan (yoksa _ready()'den) başlayarak oynanış sırasıyla gezilir; çağrılan alt sahneler (fonksiyonlar)
    yerinde açılır, başlıkları ve tarifleri fonksiyonun üstündeki ## yorumlarından gelir,
  - if / elif / else ve match kolları dal olur (koşul okunur hâle getirilir), hud.choose seçim olur,
  - replik: satırda geçen ve docs/voice/VOICE_MAP.csv'de bulunan anahtar; konuşmacı haritadan,
  - yalnız testte çalışan kollar (GameState.autotest) ve ekran görüntüsü betikleri atlanır,
  - bölümün başlık yorumu (betiğin başındaki ## blok) sahnenin tarifidir.
Ağaca girmeyen replikler (başka dosyalardan, seviye betiklerinden çağrılanlar) bölümlerine göre sonda listelenir.

    python3 tools/dialog_tree.py [çıktı.json]      (varsayılan: ../nothistorygamedemo/data/dialog.json)
"""
import csv, datetime, json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "..", "nothistorygamedemo", "data", "dialog.json")
STORY = os.path.join(os.path.dirname(OUT), "story.json")
# Oyun anından görüntüler (--dialogshots ile alınır): img/dlg/ANAHTAR.jpg varsa sözün üstünde gösterilir
IMG_DIR = os.path.join(os.path.dirname(os.path.dirname(OUT)), "img", "dlg")
IMGS = {f[:-4] for f in os.listdir(IMG_DIR)} if os.path.isdir(IMG_DIR) else set()

S = {r[0]: (r[1], r[2]) for r in csv.reader(open(os.path.join(ROOT, "i18n/strings.csv"), encoding="utf-8")) if r and len(r) >= 3}
VM = {r["anahtar"]: r for r in csv.DictReader(open(os.path.join(ROOT, "docs/voice/VOICE_MAP.csv"), encoding="utf-8"))}
STR_RE = re.compile(r'"((?:[^"\\]|\\.)*)"')
used = set()


def L(key):
    tr_, en = S.get(key, (key, key))
    return {"tr": tr_, "en": en}


def spk_name(spk):
    if not spk or spk == "?":
        return {"tr": "?", "en": "?"}
    return L(spk)


def keys_in(literal):
    """Bir dize sabitinden replik anahtarları: tam anahtar ya da %d/%s ile kurulan kalıp."""
    if literal in VM:
        return [literal]
    if "%" in literal and re.match(r"^[A-Z0-9_%sd]+$", literal):
        rx = re.compile("^" + re.escape(literal).replace("%d", r"\d+").replace("%s", r"[A-Z0-9_]+") + "$")
        return sorted(k for k in VM if rx.match(k))
    return []


def strip_comment(line):
    out, q = [], False
    for i, ch in enumerate(line):
        if ch == '"' and (i == 0 or line[i - 1] != "\\"):
            q = not q
        if ch == "#" and not q:
            break
        out.append(ch)
    return "".join(out).rstrip()


HUMAN = [
    (r'GameState\.chapter_outcomes\.get\((\d+)\s*,\s*""\)', r"Bölüm \1 sonucu"),
    (r'Siege\.outcome\((\d+)\)', r"Bölüm \1 sonucu"),
    (r'GameState\.flags\.get\("([a-z0-9_]+)"(?:\s*,\s*[^)]*)?\)', r"bayrak[\1]"),
    (r'GameState\.flags\.has\("([a-z0-9_]+)"\)', r"bayrak[\1] var"),
    (r'GameState\.in_pocket\("([a-z_]+)"\)', r"cepte: \1"),
    (r'GameState\.has_item\("([a-z_]+)"\)', r"çantada: \1"),
    (r'GameState\.given_to\("([a-z_]+)"\)', r"\1 kime verildi"),
    (r'\bnot\b', "değil"), (r'\band\b', "ve"), (r'\bor\b', "veya"),
    (r'==', "="), (r'\bString\(|\bint\(|\bfloat\(|\bstr\(', "("),
]


def human(cond):
    c = cond.strip()
    for a, b in HUMAN:
        c = re.sub(a, b, c)
    return c


class Line:
    def __init__(self, no, ind, text, doc):
        self.no, self.ind, self.text, self.doc = no, ind, text, doc


def logical_lines(src):
    """Yorumları atar, açık parantezle süren satırları birleştirir; her satırın girintisi ve üstündeki ## yorumu."""
    out, buf, depth, start_ind, start_no, doc = [], "", 0, 0, 0, []
    for no, raw in enumerate(src.split("\n"), 1):
        s = raw.lstrip("\t")
        if not buf:
            if s.startswith("##"):
                doc.append(s[2:].strip())
                continue
            if not s.strip() or s.strip().startswith("#"):
                if not s.strip():
                    doc = doc if doc else []
                continue
            start_ind, start_no = len(raw) - len(s), no
        code = strip_comment(s)
        buf += (" " if buf else "") + code.strip()
        depth += sum(code.count(c) for c in "([{") - sum(code.count(c) for c in ")]}")
        if depth > 0 or buf.endswith("\\"):
            buf = buf.rstrip("\\")
            continue
        out.append(Line(start_no, start_ind, buf, doc))
        buf, depth, doc = "", 0, []
    return out


def parse_funcs(lines):
    funcs, cur = {}, None
    for ln in lines:
        m = re.match(r"^(?:static\s+)?func\s+([A-Za-z0-9_]+)\s*\(", ln.text)
        if ln.ind == 0 and m:
            cur = m.group(1)
            funcs[cur] = {"doc": ln.doc, "body": [], "no": ln.no}
            continue
        if ln.ind == 0:
            cur = None
            continue
        if cur:
            funcs[cur]["body"].append(ln)
    return funcs


SKIP_FUNCS = re.compile(r"^(_run_shots|_shot.*|_autotest_report|_bot.*|_auto|_make_chart|_capture_mouse)$")


def is_test_cond(cond):
    c = cond.replace(" ", "")
    return ("GameState.autotest" in c and not c.startswith("not") and "notGameState.autotest" not in c) or "shots_dir" in c


class Builder:
    def __init__(self, funcs):
        self.funcs = funcs
        self.has = {}
        self.done = set()

    def has_dialog(self, name, stack=()):
        if name in self.has:
            return self.has[name]
        if name in stack or name not in self.funcs or SKIP_FUNCS.match(name):
            return False
        r = False
        for ln in self.funcs[name]["body"]:
            if self.line_keys(ln.text) or "choose(" in ln.text:
                r = True
                break
            for c in self.calls(ln.text):
                if self.has_dialog(c, stack + (name,)):
                    r = True
                    break
            if r:
                break
        self.has[name] = r
        return r

    def calls(self, text):
        return [m for m in re.findall(r"(?<![\w.])([A-Za-z_][A-Za-z0-9_]*)\s*\(", text) if m in self.funcs]

    def line_keys(self, text):
        ks = []
        for lit in STR_RE.findall(text):
            for k in keys_in(lit):
                if k not in ks:
                    ks.append(k)
        return ks

    def emit_line(self, text):
        out = []
        ks = self.line_keys(text)
        if "choose(" in text:
            opts = [k for k in STR_RE.findall(text.split("choose(", 1)[1]) if k in S and not k in VM]
            if opts:
                out.append({"t": "choice", "opts": [L(k) for k in opts]})
        if ks:
            bark = "bark(" in text
            alts = []
            for k in ks:
                used.add(k)
                r = VM[k]
                alts.append({"k": k, "s": r["konusmaci"], "sn": spk_name(r["konusmaci"]), "tr": S.get(k, ("", ""))[0], "en": S.get(k, ("", ""))[1]})
            img = next((a["k"] for a in alts if a["k"] in IMGS), "")
            out.append({"t": "line", "alts": alts, "bark": bark, "img": img, "cond": human(text.split(" if ", 1)[1].split(" else ")[0]) if len(alts) == 2 and " if " in text else ""})
        for c in self.calls(text):
            if SKIP_FUNCS.match(c) or not self.has_dialog(c):
                continue
            if c in self.done:
                out.append({"t": "ref", "name": c, "title": self.title(c)})
                continue
            self.done.add(c)
            out.append({"t": "scene", "name": c, "title": self.title(c), "desc": " ".join(self.funcs[c]["doc"]), "body": self.block(self.funcs[c]["body"])})
        return out

    def title(self, name):
        doc = self.funcs[name]["doc"]
        if doc:
            first = re.split(r"(?<=[.:])\s", doc[0])[0].rstrip(".:")
            return first[:90]
        return name.strip("_").replace("_", " ")

    def block(self, lines):
        """Aynı girintideki satırlar: düz satırlar, if/elif/else zincirleri, match ve döngüler."""
        if not lines:
            return []
        base = lines[0].ind
        out, i = [], 0
        while i < len(lines):
            ln = lines[i]
            if ln.ind != base:
                i += 1
                continue
            j = i + 1
            while j < len(lines) and lines[j].ind > base:
                j += 1
            child = lines[i + 1:j]
            t = ln.text
            m_if = re.match(r"^if\s+(.*):$", t)
            if m_if:
                arms = [(m_if.group(1), child)]
                k = j
                while k < len(lines) and lines[k].ind == base and re.match(r"^(elif\s+.*|else):$", lines[k].text):
                    e = k + 1
                    while e < len(lines) and lines[e].ind > base:
                        e += 1
                    hdr = lines[k].text
                    arms.append((hdr[5:-1] if hdr.startswith("elif") else None, lines[k + 1:e]))
                    k = e
                node = self.if_node(arms)
                out.extend(node)
                i = k
                continue
            m_match = re.match(r"^match\s+(.*):$", t)
            if m_match:
                arms = []
                if child:
                    cb = child[0].ind
                    a = 0
                    while a < len(child):
                        e = a + 1
                        while e < len(child) and child[e].ind > cb:
                            e += 1
                        case = child[a].text
                        mc = re.match(r"^(.*?):\s*(.*)$", case)
                        body = child[a + 1:e]
                        if mc and mc.group(2):
                            body = [Line(child[a].no, cb + 1, mc.group(2), [])] + body
                        arms.append({"cond": (mc.group(1) if mc else case), "body": self.block(body)})
                        a = e
                arms = [x for x in arms if x["body"]]
                if arms:
                    out.append({"t": "match", "cond": human(m_match.group(1)), "arms": [{"cond": human(x["cond"]), "body": x["body"]} for x in arms]})
                i = j
                continue
            out.extend(self.emit_line(t))
            if child:
                inner = self.block(child)
                if inner:
                    m_loop = re.match(r"^(for|while)\s+(.*):$", t)
                    if m_loop:
                        out.append({"t": "loop", "cond": human(m_loop.group(2)), "body": inner})
                    else:
                        out.extend(inner)
            i = j
        return out

    def if_node(self, arms):
        res = []
        kept = []
        for cond, body in arms:
            if cond is not None and is_test_cond(cond):
                continue
            b = self.block(body)
            kept.append({"cond": human(cond) if cond is not None else None, "body": b})
        # Yalnız testi atlanan 'if autotest: ... else: X' → X düz akar
        if len(kept) == 1 and kept[0]["cond"] is None:
            return kept[0]["body"]
        if not any(k["body"] for k in kept):
            return res
        res.append({"t": "if", "arms": kept})
        return res


def chapter_tree(script):
    src = open(script, encoding="utf-8").read()
    lines = logical_lines(src)
    head = []
    for raw in src.split("\n")[1:]:
        if raw.startswith("##"):
            t = raw[2:].strip()
            # Test ve komut satırı notları sahnenin tarifi değil
            if re.search(r"autotest|--shots|--chapter|Komut satırı|GameState\)|res://|^Test", t):
                continue
            head.append(t)
        elif raw.strip():
            break
    funcs = parse_funcs(lines)
    b = Builder(funcs)
    entry = "_run" if "_run" in funcs else "_ready"
    tree = []
    if entry in funcs:
        b.done.add(entry)
        tree = b.block(funcs[entry]["body"])
    # Ana akıştan çağrılmayan replikli fonksiyonlar (etkileşim, _process içindeki sesler, sinyaller)
    rest = []
    for name in funcs:
        if name in b.done or SKIP_FUNCS.match(name) or not b.has_dialog(name):
            continue
        b.done.add(name)
        rest.append({"t": "scene", "name": name, "title": b.title(name), "desc": " ".join(funcs[name]["doc"]), "body": b.block(funcs[name]["body"])})
    if rest:
        tree.append({"t": "extra", "body": rest})
    return head, tree


def count(nodes):
    n = 0
    for x in nodes:
        if x["t"] == "line":
            n += 1
        for k in ("body",):
            if k in x:
                n += count(x[k])
        for a in x.get("arms", []):
            n += count(a["body"])
    return n


def main():
    story = json.load(open(STORY, encoding="utf-8"))
    order = []
    for row in story["rows"]:
        for cell in row.get("cells", []):
            if cell[0] not in order:
                order.append(cell[0])
    for cid in story["chapters"]:
        if cid not in order:
            order.append(cid)
    chapters = {}
    for cid in order:
        ch = story["chapters"][cid]
        if not ch.get("scene"):
            continue
        scene = os.path.join(ROOT, "scenes", ch["scene"] + ".tscn")
        if not os.path.exists(scene):
            # 4a/4b, 6a/6b: iki yol tek sahnede (bölüm betiği yolu kendisi seçer)
            scene = os.path.join(ROOT, "scenes", ch["scene"].rstrip("abcdefghijklmnopqrstuvwxyz") + ".tscn")
        if not os.path.exists(scene):
            continue
        m = re.search(r'path="res://(scripts/[^"]+\.gd)"', open(scene, encoding="utf-8").read())
        if not m:
            continue
        head, tree = chapter_tree(os.path.join(ROOT, m.group(1)))
        chapters[cid] = {"id": cid, "title": ch["title"], "sub": ch["sub"], "num": ch.get("num", {}), "side": ch.get("side"),
                         "desc": " ".join(head), "tree": tree, "lines": count(tree)}
    # Ağaca girmeyenler: bölümüne göre
    by_ch = {}
    for k, r in VM.items():
        if k in used:
            continue
        by_ch.setdefault(r["bolum"] or "?", []).append({"k": k, "s": r["konusmaci"], "sn": spk_name(r["konusmaci"]), "tr": r["tr"], "en": r["en"]})
    data = {"meta": {"version": open(os.path.join(ROOT, "VERSION")).read().strip(), "date": datetime.date.today().isoformat(),
                     "total": len(VM), "in_tree": len(used)},
            "order": [c for c in order if c in chapters], "chapters": chapters, "other": by_ch}
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    json.dump(data, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))
    print("diyalog: %d replik, ağaçta %d, ağaç dışı %d, bölüm %d → %s" % (len(VM), len(used), len(VM) - len(used), len(chapters), OUT))


if __name__ == "__main__":
    main()
