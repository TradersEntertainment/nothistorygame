#!/usr/bin/env python3
"""Hikâye akışı verisi: tanıtım sitesinin yukarıdan aşağı kaydırılan akış sayfası (story.html) bu dosyayı okur.

Oyunun kendi kodundan ve metinlerinden çıkarılanlar:
  - her bölümün oyun içi akış şeması (düğümler, konumları, bağlantılar, sonuç etiketleri; i18n/strings.csv),
  - kuşatmanın sırası ve iki tarafın bölüm listesi (scripts/siege.gd ORDER + scenes/ altındaki sahneler),
  - ekrandaki bölüm ve sonuç numaraları (Siege.number_of / GameState.display_outcome ile aynı kural),
  - bölüm başlıkları, alt başlıklar ve tarihler, final adları.
Elle özetlenenler (kod dağınık; o dosyalar değişirse buradaki tablo da güncellenmeli):
  - bölümler arası geçişler (EDGES), sonuçların sonrası (EFFECTS), finallerin koşulları (FINALS, chapter15._named_final),
  - eşya ve müttefik izleri (THREADS, docs/BRANCHING_V2.md).

    python3 tools/story_map.py [çıktı.json]      (varsayılan: ../nothistorygamedemo/data/story.json)
"""
import csv, datetime, json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "..", "nothistorygamedemo", "data", "story.json")

S = {r[0]: r for r in csv.reader(open(os.path.join(ROOT, "i18n/strings.csv"), encoding="utf-8")) if r and len(r) >= 3}
SCENES = {f[:-5] for f in os.listdir(os.path.join(ROOT, "scenes")) if f.startswith("chapter") and f.endswith(".tscn")}


def L(tr_, en):
    return {"tr": tr_, "en": en}


def t(key):
    r = S.get(key)
    return L(r[1], r[2]) if r else L(key, key)


# Akış şemasındaki sonuç etiketlerinin başında eski bir ekran numarası duruyor olabilir ("22.1 Son kare çekildi",
# "G.1 Düğme gagalandı → 24.6"): site numarayı kendisi hesaplar, etiketteki eski numaralar atılır.
NUM_PREFIX = re.compile(r"^(?:\d+[A-Za-z]?|[A-Z])\.\d+[a-z]?\s+")
NUM_ARROW = re.compile(r"\s*→\s*(?:\d+[A-Za-z]?\.\d+[a-z]?|\{o:[^}]+\})$")


def label(key):
    v = t(key)
    return {k: NUM_ARROW.sub("", NUM_PREFIX.sub("", s)) for k, s in v.items()}


def cap(s):
    # "OTAĞ KAPISI" -> "Otağ Kapısı" (Türkçe büyük/küçük harf; rakamlı kelimeler olduğu gibi)
    out = []
    for w in s.split():
        if any(ch.isdigit() for ch in w):
            out.append(w); continue
        pre = "(" if w.startswith("(") else ""
        low = w[len(pre):].replace("I", "ı").replace("İ", "i").lower()
        first = low[:1]
        first = "İ" if first == "i" else ("I" if first == "ı" else first.upper())
        out.append(pre + first + low[1:])
    return " ".join(out)


SMALL = {"of", "the", "in", "a", "an", "and", "on", "to"}


def cap_en(s):
    out = []
    for i, w in enumerate(s.split()):
        if any(ch.isdigit() for ch in w):
            out.append(w); continue
        lw = w.lower()
        pre = "(" if lw.startswith("(") else ""
        lw = lw[len(pre):]
        out.append(pre + (lw if (i > 0 and lw in SMALL) else "-".join(p[:1].upper() + p[1:] for p in lw.split("-"))))
    return " ".join(out)


def title(key):
    r = S[key]
    return L(cap(r[1].split("—")[-1].strip()), cap_en(r[2].split("—")[-1].strip()))


# ------------------------------------------------------------------ oyun içi akış şeması

NODE_RE = re.compile(r'\{"id": (?:"([^"]+)"|(\w+)), "key": "([^"]+)"(?: if (.+?) else "([^"]+)")?, "pos": Vector2\(([-\d.]+), ([-\d.]+)\)([^}]*)\}')


def flow(script):
    """Bölüm betiğindeki akış şeması: düğümler (konum, sonuç mu) ve bağlantılar. Tarafa göre değişen etiket
    ('"key": A if byz else B') iki etiket olarak döner: label (Bizans / ilk), label_o (Osmanlı / ikinci)."""
    s = open(os.path.join(ROOT, "scripts", script), encoding="utf-8").read()
    nodes = []
    for m in NODE_RE.finditer(s):
        nid, var, key, cond, key2, x, y, rest = m.groups()
        if nid is None:
            continue            # değişken kimlikli düğüm (Bölüm 7'nin tanık düğümü): aşağıda elle
        n = {"id": nid, "label": label(key), "pos": [round(float(x), 3), round(float(y), 3)],
             "outcome": '"outcome": true' in rest}
        if cond and key2:
            n["label_o"] = label(key2)
            if '== "O"' in cond or cond.strip().startswith("not byz"):
                n["label"], n["label_o"] = n["label_o"], n["label"]     # koşul Osmanlı tarafını soruyor: ilk anahtar Osmanlı'nın
        nodes.append(n)
    edges = []
    i = s.find("c.edges = [")
    if i >= 0:
        block = s[i:s.find("\n\n", i)]
        edges = [list(e) for e in re.findall(r'\["([^"]+)", "([^"]+)"\]', block)]
    return nodes, edges


# ------------------------------------------------------------------ kuşatma: sıra, taraflar, ekran numaraları

_SIEGE = open(os.path.join(ROOT, "scripts", "siege.gd"), encoding="utf-8").read()
ORDER = [int(x) for x in re.search(r"const ORDER := \[([^\]]+)\]", _SIEGE).group(1).split(",")]
NUMBER_BASE = int(re.search(r"const NUMBER_BASE := (\d+)", _SIEGE).group(1))
AFTER = [int(x) for x in re.search(r"const AFTER := \[([^\]]+)\]", _SIEGE).group(1).split(",")]


def scene_for(ch, side):
    """Siege.scene_path: bu tarafın kendi sahnesi (chapterNo / chapterNb), yoksa ortak chapterN, o da yoksa None."""
    own = "chapter%d%s" % (ch, "o" if side == "O" else "b")
    if own in SCENES:
        return own
    return "chapter%d" % ch if "chapter%d" % ch in SCENES else None


SIDE_LIST = {sd: [ch for ch in ORDER if scene_for(ch, sd)] for sd in ("B", "O")}


def number_of(ch, side):
    lst = SIDE_LIST[side]
    if ch in lst:
        return NUMBER_BASE + lst.index(ch) + 1
    if ch in AFTER:
        return NUMBER_BASE + len(lst) + AFTER.index(ch) + 1
    return 0


def cid(scene):
    return "ch" + scene[len("chapter"):]


# ------------------------------------------------------------------ bölümler

# Kuşatmadan önceki bölümler: [kimlik, betik, başlık, alt başlık, not (TR, EN)]
PRE = [
    ["ch0", None, None, None, ["Soğuk açılış: 29 Mayıs 1453, gedik. Kare donar, beş hafta geri sarılır.",
                               "Cold open: 29 May 1453, the breach. The frame freezes and rewinds five weeks."]],
    ["ch1", "chapter1.gd", "UI_CH1_TITLE", "UI_CH1_SUB", None],
    ["ch2", "chapter2.gd", "UI_CH2_TITLE", "UI_CH2_SUB", None],
    ["ch3", "chapter3.gd", "UI_CH3_TITLE", "UI_CH3_SUB",
     ["Bölüm 4'ün hangi yarısının oynanacağına Bölüm 2 karar verir: zincire ulaştıysan (2.3) 4b, yoksa 4a.",
      "Chapter 2 decides which half of Chapter 4 you play: 4b if you reached the chain (2.3), otherwise 4a."]],
    ["ch4a", "chapter4.gd", "UI_CH4_TITLE", "UI_CH4_SUB_4A", ["Bölüm 2'de kıyıya çıktıysan.", "If you made it to the shore in Chapter 2."]],
    ["ch4b", "chapter4.gd", "UI_CH4_TITLE", "UI_CH4_SUB_4B", ["Bölüm 2'de zincire ulaştıysan (2.3).", "If you reached the chain in Chapter 2 (2.3)."]],
    ["ch5", "chapter5.gd", "UI_CH5_TITLE", "UI_CH5_SUB",
     ["Yol kendini sürdürür: 4a'dan gelen 6a'ya (ordugâh), 4b'den gelen 6b'ye (surlar) gider.",
      "The route carries on: from 4a to 6a (the camp), from 4b to 6b (the walls)."]],
    ["ch6a", "chapter6.gd", "UI_CH6A_TITLE", "UI_CH6A_SUB", ["Ordugâh yolu (4a).", "The camp route (4a)."]],
    ["ch6b", "chapter6.gd", "UI_CH6B_TITLE", "UI_CH6B_SUB", ["Surlar yolu (4b).", "The walls route (4b)."]],
    ["ch7", "chapter7.gd", "UI_CH7_TITLE", "UI_CH7_SUB",
     ["İki sürüm: 6a'dan gelince ordugâhta (7a), 6b'den gelince Bizans şehrinde (7b).",
      "Two versions: in the camp (7a) after 6a, in the Byzantine city (7b) after 6b."]],
    ["ch8", "chapter8.gd", "UI_CH8_TITLE", "UI_CH8_SUB", None],
    ["ch9", "chapter9.gd", "UI_CH9_TITLE", "UI_CH9_SUB",
     ["Yedi teklif, yedi dal bölümü. Hepsini reddedersen Otağ Kapısı.", "Seven offers, seven branch chapters. Turn them all down and it's the Tent Gate."]],
    ["ch10z", "chapter10z.gd", "UI_CH10Z_TITLE", "UI_CH10Z_SUB", ["Kadri'nin teklifi (9.1).", "Kadri's offer (9.1)."]],
    ["ch10b", "chapter10b.gd", "UI_CH10B_TITLE", "UI_CH10B_SUB", ["Urban'ın teklifi (9.2).", "Urban's offer (9.2)."]],
    ["ch10g", "chapter10g.gd", "UI_CH10G_TITLE", "UI_CH10G_SUB", ["Çandarlı'nın mektubu (9.3).", "Çandarlı's letter (9.3)."]],
    ["ch10h", "chapter10h.gd", "UI_CH10H_TITLE", "UI_CH10H_SUB",
     ["Lütfi'nin heyeti (9.4). Bizans'a yapılan her yardım Direniş'i artırır; kuşatmanın şafağı buna bakar.",
      "Lütfi's embassy (9.4). Every bit of help to Byzantium raises Resistance; the siege's dawn looks at it."]],
    ["ch10a", "chapter10a.gd", "UI_CH10A_TITLE", "UI_CH10A_SUB", ["Theodoros'un arşivi (9.5).", "Theodoros's archive (9.5)."]],
    ["ch10l", "chapter10l.gd", "UI_CH10L_TITLE", "UI_CH10L_SUB", ["Dragan'ın lağımı (9.7).", "Dragan's tunnel (9.7)."]],
    ["ch10", "chapter10.gd", "UI_CH10O_TITLE", "UI_CH10O_SUB", ["Hepsini reddettiysen (9.6).", "If you turned everyone down (9.6)."]],
    ["ch11", "chapter11.gd", "UI_CH11_TITLE", "UI_CH11_SUB",
     ["Sonra: huzur (12); 10H'de Bizans'a yardım ettiysen Son Akşam (12B); dal bölümü dünyayı yazdıysa ya da Tolga tutuklandıysa doğrudan Büro.",
      "Next: the audience (12); the Last Evening (12B) if you helped Byzantium in 10H; straight to the Bureau if a branch chapter wrote the world or Tolga was arrested."]],
    ["ch12", "chapter12.gd", "UI_CH12_TITLE", "UI_CH12_SUB",
     ["Fatih'in huzuru. Dünya burada yazılır. 12.1, 12.2, 12.4 ve 12.6'da Sultan'ın tezkiresi Tolga'nın cebine girer.",
      "Before Mehmed. The world is written here. In 12.1, 12.2, 12.4 and 12.6 the Sultan's pass goes into Tolga's pocket."]],
    ["ch12b", "chapter12b.gd", "UI_CH12B_TITLE", "UI_CH12B_SUB",
     ["Heyette Bizans'a yardım ettiysen (Direniş ≥ 1). İmparator sorar: 'Yetecek mi?' Cevabı kuşatma verir.",
      "If you helped Byzantium during the embassy (Resistance ≥ 1). The Emperor asks: 'Will it be enough?' The siege answers."]],
]

# Kuşatmadan sonra: [kimlik, betik, başlık, alt başlık, not]
POST = [
    ["ch13", "chapter13.gd", "UI_CH13_TITLE", "UI_CH13_SUB",
     ["Hikmet'in dönüş penceresi: frekans, kol, kırmızı düğme. 11.1'de tutuklanan Tolga için bu bölüm atlanır.",
      "Hikmet's return window: frequency, lever, red button. Skipped if Tolga was arrested in 11.1."]],
    ["ch16", "chapter16.gd", "UI_CH16_TITLE", "UI_CH16_SUB",
     ["Gizli bölüm: pencere kaçtı (13.2), ama 4b'de Tolga'ya takılan tavuk Sinerji her şeyi gördü.",
      "Secret chapter: the window was missed (13.2), but Synergy, the chicken that latched onto Tolga in 4b, saw everything."]],
    ["ch14", "chapter14.gd", "UI_CH14_TITLE", "UI_CH14_SUB",
     ["Nihat'ın son formu. Tutuklanan Tolga (11.1) kuşatmadan sonra doğrudan buraya gelir.",
      "Nihat's final form. An arrested Tolga (11.1) comes straight here after the siege."]],
    ["ch15", None, "UI_CH15_TITLE", "UI_CH15_SUB",
     ["Garaj, Nihat'ın masası, pazartesi toplantısı; sonra Eşyaların Akıbeti, İnsanların Akıbeti ve final kartı.",
      "The garage, Nihat's desk, the Monday meeting; then the Fate of Things, the Fate of People and the ending card."]],
]

# Kuşatma bölümlerinin notları
SIEGE_NOTES = {
    "ch36b": ["Bizans tarafının ilk sayfası: 9 Nisan, surun dışına huruç. Yalnız Bizans tarafı.",
              "The first page on the Byzantine side: 9 April, a sortie beyond the walls. Byzantine side only."],
    "ch29": ["20 Nisan: zincirin önünde deniz savaşı, surlardan.",
             "20 April: the sea battle at the chain, seen from the walls."],
    "ch33o": ["Osmanlı tarafının ilk sayfası: kuşatmadan sekiz ay önce, Boğazkesen'in son taşları.",
              "The first page on the Ottoman side: eight months before the siege, the last stones of Boğazkesen."],
    "ch34o": ["Yalnız Osmanlı tarafı.", "Ottoman side only."],
    "ch35o": ["Yalnız Osmanlı tarafı.", "Ottoman side only."],
    "ch28o": ["Yalnız Osmanlı tarafı.", "Ottoman side only."],
    "ch37o": ["Yalnız Osmanlı tarafı.", "Ottoman side only."],
    "ch32o": ["Yalnız Osmanlı tarafı. 20o'daki çatlaklar ve 10B'de topa konan ad burada okunur.",
              "Ottoman side only. The cracks from 20o and the name given to the cannon in 10B are read here."],
    "ch23": ["İki taraf da: Bizans'ta saray tercümanı, Osmanlı'da elçinin tercümanı.",
             "Both sides: the palace interpreter for Byzantium, the envoy's interpreter for the Ottomans."],
    "ch25": ["İki taraf da: Bizans'ta Ayasofya'da son ayin, Osmanlı'da ordugâhta meclis.",
             "Both sides: the last liturgy in Hagia Sophia for Byzantium, the council in the camp for the Ottomans."],
    "ch26": ["Şafak. Bizans'a yardım ettiysen (Direniş) ve İmparator'un güveni sendeyse Giustiniani'yi uyarıp hücumu püskürtebilirsin (26.3): şehir o sabah düşmez.",
             "Dawn. If you helped Byzantium (Resistance) and have the Emperor's trust, you can warn Giustiniani and throw back the assault (26.3): the city does not fall that morning."],
    "ch26o": ["Şafak, hendeğin önünden. Osmanlı tarafında şafak hep düşer.", "Dawn, from the ditch. On the Ottoman side the dawn always falls."],
    "ch38o": ["Yalnız Osmanlı tarafı.", "Ottoman side only."],
    "ch39o": ["Yalnız Osmanlı tarafı.", "Ottoman side only."],
    "ch31o": ["Yalnız Osmanlı tarafı: fethin ertesi, ilk cuma.", "Ottoman side only: the day after the conquest, the first Friday."],
    "ch27": ["Kuşatmanın son sayfası, iki taraf da. Şehir şafakta düşmediyse (26.3) yazılmaz.",
             "The siege's last page, both sides. Not written if the city held at dawn (26.3)."],
}

COVERS_EXTRA = {"bureau": "img/ch/bureau.jpg", "ret": None, "fin": None, "ch15y": "img/ch/ch15.jpg"}


def who_of(sub):
    if not sub or " · " not in sub["tr"]:
        return None
    head = sub["tr"].split(" · ")[0]
    if head in ("Tolga", "Nihat", "Hikmet", "Denetçi Nihat", "Nihat ve Tolga", "Sinerji"):
        return L(head, sub["en"].split(" · ")[0])
    return None


# Aynı betiği paylaşan varyant bölümler: hangi düğümler hangisine ait
VARIANT_NODES = {
    "ch4a": {"4a", "sneak", "confront"}, "ch4b": {"4b", "chain", "niko"},
    "ch6a": {"morning", "A", "B", "C", "Y", "6a"}, "ch6b": {"maze", "6b", "giust", "emperor"},
}


def chapter_entry(id_, script, tkey, skey, note, side=None, num=None):
    nodes, edges = flow(script) if script else ([], [])
    if id_ in VARIANT_NODES:
        keep = VARIANT_NODES[id_]
        nodes = [n for n in nodes if n["id"] in keep or any(n["id"].startswith(p + ".") for p in keep)]
        ids = {n["id"] for n in nodes}
        edges = [e for e in edges if e[0] in ids and e[1] in ids]
    if id_ == "ch7":
        # Tanığın yanındaki sonuç düğümü kola göre değişir (7a: nöbetçilerle çay, 7b: Theodoros)
        nodes.insert(2, {"id": "7.4", "label": label("FLOW_7_4"), "label_o": label("FLOW_7_3"), "pos": [0.82, 0.28],
                         "outcome": True, "alt_id": "7.3"})
        edges.insert(1, ["witness", "7.4"])
    sub = t(skey) if skey else L("29 Mayıs 1453 · gece 01.30", "29 May 1453 · 1:30 AM")
    tt = title(tkey) if tkey else L("Soğuk Açılış", "Cold Open")
    if id_ == "ch16":
        tt = L(cap(S[tkey][1].split("—")[-1].strip()), cap_en(S[tkey][2].split("—")[-1].strip()))
    e = {
        "id": id_, "scene": ("chapter" + id_[2:]) if id_ != "ch10" else "chapter10",
        "title": tt, "sub": sub, "who": who_of(sub), "side": side,
        "cover": "img/ch/%s.jpg" % id_,
        "note": L(note[0], note[1]) if note else None,
        "nodes": nodes, "edges": edges,
    }
    if num is not None:
        e["num"] = num
    return e


CHAPTERS = {}
for id_, script, tkey, skey, note in PRE:
    m = re.match(r"ch(\d+)", id_)
    CHAPTERS[id_] = chapter_entry(id_, script, tkey, skey, note, num={"all": m.group(1)})

# Aynı numarayı paylaşan dal bölümleri sitede sonuç kimliklerindeki adla ayrılır (4a/4b, 10Z…, 12B)
TAGS = {"ch4a": "4a", "ch4b": "4b", "ch6a": "6a", "ch6b": "6b", "ch10z": "10Z", "ch10b": "10B", "ch10g": "10G",
        "ch10h": "10H", "ch10a": "10A", "ch10l": "10L", "ch12b": "12B"}
for id_, tag in TAGS.items():
    CHAPTERS[id_]["tag"] = tag

# Kuşatma: iki tarafın sahneleri; ortak sahne (23, 25, 27) tek bölümdür, iki numarası vardır
SIEGE_ROWS = []
for ch in ORDER:
    b, o = scene_for(ch, "B"), scene_for(ch, "O")
    row = {"key": ch}
    for sd, sc in (("B", b), ("O", o)):
        if not sc:
            continue
        id_ = cid(sc)
        if id_ not in CHAPTERS:
            suffix = sc[len("chapter%d" % ch):].upper()
            tkey, skey = "UI_CH%d%s_TITLE" % (ch, suffix), "UI_CH%d%s_SUB" % (ch, suffix)
            note = SIEGE_NOTES.get(id_)
            CHAPTERS[id_] = chapter_entry(id_, sc + ".gd", tkey, skey, note, side=sd, num={})
        CHAPTERS[id_]["num"][sd] = str(number_of(ch, sd))
        CHAPTERS[id_]["key"] = ch
        row[sd] = id_
    for id_ in {row.get("B"), row.get("O")} - {None}:
        c = CHAPTERS[id_]
        c["side"] = "both" if row.get("B") == row.get("O") else c["side"]
    SIEGE_ROWS.append(row)

# Ortak bölümün Bizans tarafı başka yerden başlar: Bölüm 25'te sur, sonra Ayasofya (başlık kartı iki tarafta aynı)
_w, _a = t("UI_CH25B_WALL"), t("UI_CH25_AYA")
CHAPTERS["ch25"]["sub_b"] = L(_w["tr"] + " → " + _a["tr"], _w["en"] + " → " + _a["en"])

for id_, script, tkey, skey, note in POST:
    ch = int(re.match(r"ch(\d+)", id_).group(1))
    num = {"all": "G"} if id_ == "ch16" else {"B": str(number_of(ch, "B")), "O": str(number_of(ch, "O"))}
    CHAPTERS[id_] = chapter_entry(id_, script, tkey, skey, note, num=num)
    CHAPTERS[id_]["key"] = ch

# Bölüm 15'in 1977 yarısı (yanlış yıl, T3): ayrı bir sahne zinciri, kendi iki finali
CHAPTERS["ch15y"] = {
    "id": "ch15y", "scene": "chapter15", "title": L("Pazartesi · 1977", "Monday · 1977"), "sub": t("UI_CH15_S3_1977"),
    "who": L("Tolga", "Tolga"), "side": None, "cover": "img/ch/ch15.jpg", "key": 15,
    "num": dict(CHAPTERS["ch15"]["num"]),
    "note": L("Yanlış yıl (13.3): Tolga 1977'de, düğünün ertesi sabahı. Hikmet garajda frekansı tutmaya çalışır; telsiz kahvehanede cızırdar. Kırmızı düğmeye basarsa geri çağrılır, basmazsa kalır.",
              "Wrong year (13.3): Tolga is in 1977, the morning after the wedding. Hikmet tries to hold the frequency from the garage; the radio crackles in the coffeehouse. Press the red button and he's called back; don't and he stays."),
    "nodes": [], "edges": [],
}
CHAPTERS["bureau"] = {
    "id": "bureau", "scene": "chapter17", "title": L("Büro · Taraf Seçimi", "The Bureau · Choose a Side"), "sub": t("UI_CH17_PRO"),
    "who": L("Nihat ve Tolga", "Nihat and Tolga"), "side": None, "cover": "img/ch/bureau.jpg", "num": {"all": ""},
    "note": L("Her yol kuşatmadan önce bir kez Büro'ya uğrar. Nihat, Tolga'yı Hasar Tespit'in geçici tanığı yapar: taraf seçilir (Bizans kayıtları ya da Osmanlı kayıtları). Büro zamanın dışındadır: Tolga bir ay tanıklık eder ve ayrıldığı ana (26 Nisan öğlesi; 12B'de gün batımı) geri bırakılır.",
              "Every route stops at the Bureau once before the siege. Nihat makes Tolga a temporary witness for Damage Assessment: you pick a side (the Byzantine records or the Ottoman records). The Bureau is outside time: Tolga witnesses a month and is dropped back at the moment he left (noon, 26 April; sunset in 12B)."),
    "nodes": [], "edges": [],
}
CHAPTERS["ret"] = {
    "id": "ret", "scene": None, "title": L("Dosya Kapanır", "The File Closes"), "sub": t("UI_ACT4_END"),
    "who": None, "side": None, "cover": None, "num": {"all": ""},
    "note": L("Hasar Tespit Dosyası kapanır, Tolga 26 Nisan'a döner. Şafak tuttuysa (26.3) dosya açık kalır. Tutuklanan Tolga (11.1) Dönüş Penceresi'ni görmez, doğrudan Son Form'a.",
              "The Damage Assessment File closes and Tolga returns to 26 April. If the dawn held (26.3) the file stays open. An arrested Tolga (11.1) never sees the Return Window and goes straight to the Final Form."),
    "nodes": [], "edges": [],
}
CHAPTERS["fin"] = {
    "id": "fin", "scene": None, "title": L("Final", "The Ending"), "sub": L("27 final · biri tutarsa üstteki kazanır", "27 endings · if several apply, the higher one wins"),
    "who": None, "side": None, "cover": None, "num": {"all": ""}, "note": None, "nodes": [], "edges": [],
}

# ------------------------------------------------------------------ satırlar (yukarıdan aşağı) ve şeritler

ACTS = {
    "cold": {"title": L("Soğuk Açılış", "Cold Open"), "sub": L("29 Mayıs 1453 · gece 01.30", "29 May 1453 · 1:30 AM"),
             "kicker": L("Önsöz", "Prologue"), "img": "img/shots/donan_kare.jpg",
             "text": L("Kuşatmanın son gecesi. Gedikte fesli bir sigortacı. Kare donar.", "The last night of the siege. A man in a fez at the breach. The frame freezes.")},
    "I": {"title": L("Düşüş", "The Fall"), "sub": L("Pazar gecesi 03:12 → 22 Nisan 1453", "Sunday night 3:12 AM → 22 April 1453"),
          "kicker": L("Perde I", "Act I"), "img": "img/shots/zamanator.jpg",
          "text": L("Garaj, Zamanatör, yağlı kızaklar. Zaman Bürosu'nda bir dosya açılır.", "The garage, the Chrono-Matic, the greased slipways. A file opens at the Time Bureau.")},
    "II": {"title": L("1453'te Dört Gün", "Four Days in 1453"), "sub": L("22–25 Nisan 1453 · 2026, pazar gecesi", "22–25 April 1453 · 2026, Sunday night"),
           "kicker": L("Perde II", "Act II"), "img": "img/shots/ordugah.jpg",
           "text": L("Ordugâh ya da surlar. Hikmet garajda, Nihat sahada. Yedi teklif.", "The camp or the walls. Hikmet in the garage, Nihat in the field. Seven offers.")},
    "III": {"title": L("Huzur", "The Audience"), "sub": L("26 Nisan 1453", "26 April 1453"),
            "kicker": L("Perde III", "Act III"), "img": "img/shots/huzur.jpg",
            "text": L("Fatih'in otağı ya da surlarda gün batımı. Dünya burada yazılır... ya da kuşatmaya kalır.",
                      "Mehmed's tent or sunset on the walls. The world is written here... or left to the siege.")},
    "IV": {"title": t("UI_ACT4_TITLE"), "sub": L("Ağustos 1452 – 1 Haziran 1453 · iki taraf", "August 1452 – 1 June 1453 · two sides"),
           "kicker": L("Perde IV", "Act IV"), "img": "img/shots/ordu.jpg",
           "text": L("Büro'nun geçici tanığı. Bizans tarafı %d, Osmanlı tarafı %d sayfa. Tarih aynı kalır, Tolga'nın sayfası değişir."
                     % (len(SIDE_LIST["B"]), len(SIDE_LIST["O"])),
                     "The Bureau's temporary witness. %d pages on the Byzantine side, %d on the Ottoman side. History stays, Tolga's page changes."
                     % (len(SIDE_LIST["B"]), len(SIDE_LIST["O"])))},
    "V": {"title": L("Pazartesi", "Monday"), "sub": L("2026, pazartesi 07:15 · servise 15 dakika", "2026, Monday 7:15 AM · 15 minutes until the bus"),
          "kicker": L("Perde V", "Act V"), "img": "img/shots/yatak_oda.jpg",
          "text": L("Dönüş penceresi, Nihat'ın son formu, pazartesi toplantısı. Ya da 1977.", "The return window, Nihat's final form, the Monday meeting. Or 1977.")},
}

# Satır: {"t": "act", "act": ...} ya da {"t": "row", "cells": [[bölüm, şerit] ...]} (aynı satırdaki kartlar yan yana)
ROWS = [
    {"t": "act", "act": "cold"}, {"t": "row", "cells": [["ch0", 0]]},
    {"t": "act", "act": "I"},
    {"t": "row", "cells": [["ch1", 0]]}, {"t": "row", "cells": [["ch2", 0]]}, {"t": "row", "cells": [["ch3", 0]]},
    {"t": "row", "cells": [["ch4a", 0], ["ch4b", 1]]}, {"t": "row", "cells": [["ch5", 0]]},
    {"t": "act", "act": "II"},
    {"t": "row", "cells": [["ch6a", 0], ["ch6b", 1]]}, {"t": "row", "cells": [["ch7", 0]]},
    {"t": "row", "cells": [["ch8", 0]]}, {"t": "row", "cells": [["ch9", 0]]},
    {"t": "row", "cells": [["ch10z", 0], ["ch10b", 1]]}, {"t": "row", "cells": [["ch10g", 2], ["ch10h", 3]]},
    {"t": "row", "cells": [["ch10a", 4], ["ch10l", 5]]}, {"t": "row", "cells": [["ch10", 6]]},
    {"t": "row", "cells": [["ch11", 0]]},
    {"t": "act", "act": "III"},
    {"t": "row", "cells": [["ch12", 0], ["ch12b", 1]]},
    {"t": "act", "act": "IV"},
    {"t": "row", "cells": [["bureau", 0]]},
]
for r in SIEGE_ROWS:
    b, o = r.get("B"), r.get("O")
    if b and b == o:
        ROWS.append({"t": "row", "siege": r["key"], "cells": [[b, [0, 1]]]})
    else:
        ROWS.append({"t": "row", "siege": r["key"], "cells": [[b, 0]] if b else [], "cells_o": [[o, 1]] if o else []})
for r in ROWS:
    if "cells_o" in r:
        r["cells"] = r["cells"] + r.pop("cells_o")

# Yalnız Osmanlı sayfası olan satır dizileri: Bizans sütunu boş kalır, orada ne olduğunu söyleyen bir not durur
# (dizinin ilk bölümüne göre; sıra değişip yeni bir dizi çıkarsa aşağıdaki denetim bunu yakalar)
GHOSTS = {
    "ch33o": L("Bizans tarafında henüz sayfa yok. Bizans kayıtları 9 Nisan 1453'te, surun dışına huruçla açılır ({c:ch36b}). "
               "Osmanlı kayıtları sekiz ay önce başlar: hisar, tunç, yol.",
               "No Byzantine page yet. The Byzantine records open on 9 April 1453, with a sortie beyond the walls ({c:ch36b}). "
               "The Ottoman records start eight months earlier: the fortress, the bronze, the road."),
    "ch28o": L("Huruçlar yasaklandı: Bizans tarafı ilk atışı ve ilk hücumu surun içinden bekler. Sıradaki Bizans sayfası "
               "20 Nisan'da, zincirin önünde ({c:ch29}).",
               "Sorties are forbidden: the Byzantine side waits out the first shot and the first assault behind the walls. "
               "The next Byzantine page is 20 April, at the chain ({c:ch29})."),
    "ch32o": L("Bizans tarafı 28 Mayıs'ı Son Akşam'ın içinde yaşar: surdan Ayasofya'ya, son ayine ({c:ch25}).",
               "The Byzantine side lives 28 May inside the Last Evening: from the wall to Hagia Sophia, to the last liturgy ({c:ch25})."),
    "ch38o": L("Bizans tarafının kuşatma sayfaları şafakla biter ({c:ch26}). Osmanlı tarafı fethin gününü ve ertesini yazar; "
               "iki taraf Ahitname'de yeniden buluşur ({c:ch27}).",
               "The Byzantine siege pages end with the dawn ({c:ch26}). The Ottoman side writes the day of the conquest and after; "
               "both sides meet again at the Charter ({c:ch27})."),
}
_run = None
for r in ROWS:
    only_o = r.get("siege") is not None and len(r["cells"]) == 1 and r["cells"][0][1] == 1
    if only_o and _run is None:
        _run = r
        assert r["cells"][0][0] in GHOSTS, "Bizans sütunu boş kalan yeni dizi: " + r["cells"][0][0]
        r["ghost"] = GHOSTS[r["cells"][0][0]]
        r["span"] = 1
    elif only_o:
        _run["span"] += 1
    else:
        _run = None
assert {r["cells"][0][0] for r in ROWS if "ghost" in r} == set(GHOSTS), "kullanılmayan Bizans notu"
ROWS += [
    {"t": "row", "cells": [["ret", 0]]},
    {"t": "act", "act": "V"},
    {"t": "row", "cells": [["ch13", 0]]}, {"t": "row", "cells": [["ch16", 1]]}, {"t": "row", "cells": [["ch14", 0]]},
    {"t": "row", "cells": [["ch15", 0], ["ch15y", 1]]},
    {"t": "row", "cells": [["fin", 0]]},
]

# ------------------------------------------------------------------ geçişler

C = lambda tr_, en: L(tr_, en)
EDGES = [
    # [kaynak, hedef, sonuçlar (boşsa hepsi), koşul, taraf]
    ["ch0", "ch1", [], None, None],
    ["ch1", "ch2", ["1.1", "1.2"], None, None],
    ["ch2", "ch3", ["2.1", "2.2", "2.3", "2.4"], None, None],
    ["ch3", "ch4a", [], C("Bölüm 2'de kıyıya çıktıysan", "If you made it ashore in Chapter 2"), None],
    ["ch3", "ch4b", [], C("Bölüm 2'de zincire ulaştıysan (2.3)", "If you reached the chain in Chapter 2 (2.3)"), None],
    ["ch4a", "ch5", [], None, None], ["ch4b", "ch5", [], None, None],
    ["ch5", "ch6a", [], C("4a'dan", "From 4a"), None], ["ch5", "ch6b", [], C("4b'den", "From 4b"), None],
    ["ch6a", "ch7", [], None, None], ["ch6b", "ch7", [], None, None],
    ["ch7", "ch8", [], None, None], ["ch8", "ch9", [], None, None],
    ["ch9", "ch10z", ["9.1"], None, None], ["ch9", "ch10b", ["9.2"], None, None], ["ch9", "ch10g", ["9.3"], None, None],
    ["ch9", "ch10h", ["9.4"], None, None], ["ch9", "ch10a", ["9.5"], None, None], ["ch9", "ch10l", ["9.7"], None, None],
    ["ch9", "ch10", ["9.6"], None, None],
    ["ch10z", "ch11", [], None, None], ["ch10b", "ch11", [], None, None],
    ["ch10g", "ch11", ["10G.2"], None, None],
    ["ch10g", "bureau", ["10G.1"], C("Mektup Venedik gemisine yetişti: Bölüm 11 ve 12 atlanır", "The letter made the Venetian ship: Chapters 11 and 12 are skipped"), None],
    ["ch10h", "ch11", [], None, None],
    ["ch10a", "ch11", ["10A.2"], None, None],
    ["ch10a", "bureau", ["10A.1"], C("Form Z-1 imzalandı: Bölüm 11 ve 12 atlanır", "Form Z-1 was signed: Chapters 11 and 12 are skipped"), None],
    ["ch10l", "ch11", [], None, None], ["ch10", "ch11", [], None, None],
    ["ch11", "ch12", [], C("Huzura çıkılır: dal bölümü dünyayı yazmadı, Direniş yok", "To the audience: no branch wrote the world, no Resistance"), None],
    ["ch11", "ch12b", [], C("10H'de Bizans'a yardım ettiysen (Direniş ≥ 1)", "If you helped Byzantium in 10H (Resistance ≥ 1)"), None],
    ["ch11", "bureau", ["11.1"], C("Tutuklandıysa (11.1) ya da dal bölümü dünyayı yazdıysa (10B, 10Z.1, 10L.1): Bölüm 12 atlanır",
                                  "If arrested (11.1) or a branch chapter wrote the world (10B, 10Z.1, 10L.1): Chapter 12 is skipped"), None],
    ["ch12", "bureau", [], None, None], ["ch12b", "bureau", [], None, None],
]
for sd in ("B", "O"):
    lst = SIDE_LIST[sd]
    first = cid(scene_for(lst[0], sd))
    EDGES.append(["bureau", first, [], C("Bizans kayıtları", "The Byzantine records") if sd == "B" else C("Osmanlı kayıtları", "The Ottoman records"), sd])
    for a, b in zip(lst, lst[1:]):
        ia, ib = cid(scene_for(a, sd)), cid(scene_for(b, sd))
        via = []
        cond = None
        if ia == "ch26" and ib == "ch27":
            via = ["26.1", "26.2"]
            cond = C("Şehir düştüyse", "If the city fell")
        EDGES.append([ia, ib, via, cond, sd])
    EDGES.append([cid(scene_for(lst[-1], sd)), "ret", [], None, sd])
EDGES += [
    ["ch26", "ret", ["26.3"], C("Şafak tuttu: şehir düşmedi, Ahitname yazılmaz", "The dawn held: the city did not fall, the Charter is never written"), "B"],
    ["ret", "ch13", [], None, None],
    ["ret", "ch14", ["11.1"], C("Tutukluysa (11.1): Dönüş Penceresi yok", "If arrested (11.1): no Return Window"), None],
    ["ch13", "ch14", ["13.1", "13.2", "13.3", "13.4", "13.5"], None, None],
    ["ch13", "ch16", ["13.2"], C("Pencere kaçtı ve Sinerji Tolga'yla (4b)", "The window was missed and Synergy is with Tolga (4b)"), None],
    ["ch16", "ch14", ["16.1", "16.2"], None, None],
    ["ch14", "ch15", [], C("Tolga 1977'de değilse", "Unless Tolga is in 1977"), None],
    ["ch14", "ch15y", ["13.3"], C("Yanlış yıl (13.3)", "Wrong year (13.3)"), None],
    ["ch15", "fin", [], None, None], ["ch15y", "fin", [], None, None],
]

# Bölüm içinde biten yollar (erken son)
ENDS = {"1.3": "red_button", "2.5": "red_button"}

# Bölüm atlayan geçişler (kesik çizgi)
SKIPS = {("ch10g", "bureau"), ("ch10a", "bureau"), ("ch11", "bureau"), ("ch26", "ret"), ("ret", "ch14")}

# ------------------------------------------------------------------ şerit yerleşimi (git grafiği gibi)


def layout():
    """Her bağlantıya bir koşu şeridi verir: iki ucun arasındaki satırlarda o şeritte düğüm ya da başka bir bağlantı
    yoksa düz iner; yoksa önce hedefin, sonra kaynağın şeridine, en son boş bir şeride döner."""
    row_of, lanes_of, node_rows = {}, {}, []
    ri = 0
    for r in ROWS:
        if r["t"] != "row":
            continue
        occ = set()
        for id_, ln in r["cells"]:
            row_of[id_] = ri
            ls = ln if isinstance(ln, list) else [ln]
            lanes_of[id_] = ls
            occ |= set(ls)
        node_rows.append(occ)
        ri += 1
    busy = {}     # şerit -> [(başlangıç satırı, bitiş satırı, kaynak)]
    out = []
    for src, dst, via, cond, side in EDGES:
        a, b = row_of[src], row_of[dst]
        assert a < b, (src, dst)

        def end_lane(id_):
            ls = lanes_of[id_]
            return (1 if side == "O" else 0) if len(ls) == 2 else ls[0]

        la, lb = end_lane(src), end_lane(dst)

        def free(l):
            # Aradaki satırlarda o şeritte kart yok; başka kaynaktan gelen bir bağlantı o şeridin aynı aralığında değil;
            # dönüş kaynağın satırında ya da hedefin satırında başka bir kartın noktasına çarpmıyor
            if any(l in node_rows[r] for r in range(a + 1, b)):
                return False
            if l != la and l in node_rows[a]:
                return False
            if l != lb and l in node_rows[b]:
                return False
            return all(not (max(s0, a) < min(s1, b)) or owner == src for s0, s1, owner in busy.get(l, []))

        cands = ([la] if la == lb else []) + [la, lb] + list(range(0, 12))
        run = next(l for l in cands if free(l))
        busy.setdefault(run, []).append((a, b, src))
        e = {"from": src, "to": dst, "la": la, "lr": run, "lb": lb}
        if via:
            e["via"] = via
        if cond:
            e["cond"] = cond
        if side:
            e["side"] = side
        if (src, dst) in SKIPS:
            e["skip"] = True
        out.append(e)
    lanes = max(max(e["lr"], e["la"], e["lb"]) for e in out) + 1
    return out, lanes


# ------------------------------------------------------------------ sonuçların sonrası (metindeki {c:..} bölüm, {o:..} sonuç, {f:..} final bağlantısıdır)

EFFECTS = {
    "1.3": C("Kırmızı düğme: garanti içinde garaja dönüş, oyun erken biter.", "Red button: back to the garage under warranty, the game ends early."),
    "2.5": C("Kırmızı düğme: garanti içinde garaja dönüş, oyun erken biter.", "Red button: back to the garage under warranty, the game ends early."),
    "2.3": C("Bölüm 4, 6 ve 7 surların içinde, Bizans tarafında geçer.", "Chapters 4, 6 and 7 take place inside the walls, on the Byzantine side."),
    "2.4": C("Haliç'e düşen Tolga {c:ch4a}'da çadırda hâlâ ıslak.", "Having fallen into the Golden Horn, Tolga is still wet in the tent in {c:ch4a}."),
    "3.1": C("Makineye el konuldu: pencere de kaçarsa garaj mühürlenir ({f:sealed_garage}).", "The machine is confiscated: if the window is also missed, the garage gets sealed ({f:sealed_garage})."),
    "6a.1": C("Kadri'ye iyilik: kuşatmada Kadri ve yamakları yardıma gelir ({c:ch17o}, {c:ch26o}).", "A kindness to Kadri: in the siege Kadri and his kitchen boys come to help ({c:ch17o}, {c:ch26o})."),
    "10Z.1": C("Dünya: Sultan'ın Sofrası (W7). Bölüm 12 atlanır. Kadri dost kalır.", "World: The Sultan's Table (W7). Chapter 12 is skipped. Kadri stays a friend."),
    "10Z.2": C("Mutfak Tolga yüzünden yandı: kuşatmada Kadri yardıma gelmez.", "The kitchen burned because of Tolga: Kadri won't come to help in the siege."),
    "10B.1": C("Dünya: Topçubaşı (W5). Bölüm 12 atlanır.", "World: Master Gunner (W5). Chapter 12 is skipped."),
    "10B.2": C("Dünya: Topçubaşı (W5). Bölüm 12 atlanır.", "World: Master Gunner (W5). Chapter 12 is skipped."),
    "10B.3": C("Dünya: Büyük Patlama (W5B). Bölüm 12 atlanır.", "World: The Big Bang (W5B). Chapter 12 is skipped."),
    "10G.1": C("Dünya: Venedik'e Elçi (W6). Bölüm 11 ve 12 atlanır, doğrudan Büro'ya.", "World: Envoy to Venice (W6). Chapters 11 and 12 are skipped, straight to the Bureau."),
    "10A.1": C("Dünya: Büronun Kuruluşu (W8). Bölüm 11 ve 12 atlanır, doğrudan Büro'ya.", "World: The Founding of the Bureau (W8). Chapters 11 and 12 are skipped, straight to the Bureau."),
    "10L.1": C("Dünya: Tünel Sulhu (W13). Bölüm 12 atlanır.", "World: The Tunnel Truce (W13). Chapter 12 is skipped."),
    "10H.1": C("Bizans'a yardım ettiysen (Direniş ≥ 1) Son Akşam'a (12B) gidilir. Fethin ertelenip ertelenmeyeceğine kuşatmanın şafağı karar verir ({c:ch26}).",
               "If you helped Byzantium (Resistance ≥ 1) you go on to the Last Evening (12B). The siege's dawn decides whether the Conquest is delayed ({c:ch26})."),
    "11.1": C("Tolga tutuklandı: kuşatmadan sonra doğrudan {c:ch14}. Büro'ya katılmazsa ({o:14.3}) dönüş penceresi kaçar: {f:empty_desk}.",
              "Tolga is arrested: after the siege, straight to {c:ch14}. Unless he joins the Bureau ({o:14.3}), the return window is lost: {f:empty_desk}."),
    "12.1": C("Dünya: Tarih yerinde (W1).", "World: History intact (W1)."),
    "12.2": C("Dünya: Leblebipolis (W2).", "World: Chickpeapolis (W2)."),
    "12.3": C("Dünya: İki Hükümdar (W3).", "World: Two Rulers (W3)."),
    "12.4": C("Dünya: Sultan'ın Tamiri (W4).", "World: The Sultan's Repair (W4)."),
    "12.5": C("Mutfağa gönderildi: dünya değişmez (W1).", "Sent to the kitchen: the world stays the same (W1)."),
    "12.6": C("Dünya: Sultan'ın Tamiri (W4).", "World: The Sultan's Repair (W4)."),
    "12B.1": C("Dünya burada yazılmaz: cevabı kuşatmanın şafağı verir ({c:ch26}).", "The world isn't decided here: the siege's dawn answers ({c:ch26})."),
    "12B.2": C("Dünya burada yazılmaz: cevabı kuşatmanın şafağı verir ({c:ch26}).", "The world isn't decided here: the siege's dawn answers ({c:ch26})."),
    "12B.3": C("Dünya burada yazılmaz: cevabı kuşatmanın şafağı verir ({c:ch26}).", "The world isn't decided here: the siege's dawn answers ({c:ch26})."),
    "17.1": C("Kurtarılanlardan biri: {o:24.1} ve {o:27.1} ile birlikte {f:eaves_child}. Kurtarılan bir denizci {c:ch19}'da tayfadadır.",
              "One of the rescues: together with {o:24.1} and {o:27.1}, {f:eaves_child}. A rescued sailor is in the crew in {c:ch19}."),
    "17O.1": C("Askerlere su ve yardım: {o:22O.1} ve {o:24O.1} ile birlikte {f:water_bearer}.", "Water and help for the soldiers: together with {o:22O.1} and {o:24O.1}, {f:water_bearer}."),
    "19.1": C("Brigantinin kaptanı {c:ch27}'de Galata'da kalır ve kalanlara sayılır.", "The brigantine's captain stays in Galata in {c:ch27} and counts among those who stay."),
    "19.2": C("Kaptan {c:ch27}'de gemiye biner.", "The captain boards a ship in {c:ch27}."),
    "19O.1": C("Reis {c:ch38o}'da hatırlar: 'Bu gece ne görürsen söyle, dinlerim.'", "The captain remembers in {c:ch38o}: 'Tell me whatever you see tonight, I'll listen.'"),
    "20.1": C("Gedik şafaktan önce kapandı. Şafak tutarsa lağım ({o:21.1}) ve kuleyle ({o:22.1}) birlikte {f:long_wait}.", "The breach closed before dawn. If the dawn holds, together with the mine ({o:21.1}) and the tower ({o:22.1}): {f:long_wait}."),
    "20.2": C("Gedik kapandı ve bantlandı. Şafak tutarsa lağım ({o:21.1}) ve kuleyle ({o:22.1}) birlikte {f:long_wait}.", "The breach closed and taped. If the dawn holds, together with the mine ({o:21.1}) and the tower ({o:22.1}): {f:long_wait}."),
    "21.1": C("Lağımı Tolga'nın kabı buldu: şafak tutarsa gedik ve kuleyle birlikte {f:long_wait}.", "Tolga's bowl found the mine: if the dawn holds, together with the breach and the tower, {f:long_wait}."),
    "22.1": C("Kule Tolga'nın fıçısıyla yandı: şafak tutarsa gedik ve lağımla birlikte {f:long_wait}.", "Tolga's barrels burned the tower: if the dawn holds, together with the breach and the mine, {f:long_wait}."),
    "22O.1": C("Askerlere su ve yardım: {o:17O.1} ve {o:24O.1} ile birlikte {f:water_bearer}.", "Water and help for the soldiers: together with {o:17O.1} and {o:24O.1}, {f:water_bearer}."),
    "23.2": C("Yaratıcı tercüme: şafak tutarsa teslim teklifi evrakta kaybolur: {f:missing_paperwork}.", "Creative translation: if the dawn holds, the surrender offer gets lost in the paperwork: {f:missing_paperwork}."),
    "24.1": C("Kurtarılanlardan biri: {o:17.1} ve {o:27.1} ile birlikte {f:eaves_child}. Marco {c:ch25}'te annesiyle mumluğun yanında.",
              "One of the rescues: together with {o:17.1} and {o:27.1}, {f:eaves_child}. Marco is by the candle stand with his mother in {c:ch25}."),
    "24O.1": C("Askerlere su ve yardım: {o:17O.1} ve {o:22O.1} ile birlikte {f:water_bearer}.", "Water and help for the soldiers: together with {o:17O.1} and {o:22O.1}, {f:water_bearer}."),
    "26.1": C("Şehir düştü. Bizans'a yardım ettiysen: {f:one_evening}.", "The city fell. If you had helped Byzantium: {f:one_evening}."),
    "26.2": C("Şehir düştü. Bizans'a yardım ettiysen: {f:one_evening}.", "The city fell. If you had helped Byzantium: {f:one_evening}."),
    "26.3": C("Giustiniani ayakta kaldı, hücum püskürtüldü: şehir o sabah düşmedi. Erteleme tercümeye, gedik, lağım ve kuleye göre: {f:missing_paperwork}, {f:long_wait} ya da {f:one_more_year}. {c:ch27} yazılmaz.",
              "Giustiniani stayed on his feet, the assault was thrown back: the city did not fall that morning. The delay depends on the translation and on the breach, the mine and the tower: {f:missing_paperwork}, {f:long_wait} or {f:one_more_year}. {c:ch27} is never written."),
    "27.1": C("Kurtarılanlardan biri: {o:17.1} ve {o:24.1} ile birlikte {f:eaves_child}.", "One of the rescues: together with {o:17.1} and {o:24.1}, {f:eaves_child}."),
    "13.1": C("Tolga 2026'ya döndü (T1).", "Tolga made it back to 2026 (T1)."),
    "13.2": C("Tolga 1453'te kaldı (T2). Hikmet de oradaysa {f:two_neighbours}; makineye el konulduysa {f:sealed_garage}; Sinerji varsa gizli bölüm {c:ch16}.",
              "Tolga stays in 1453 (T2). If Hikmet is there too: {f:two_neighbours}; if the machine was confiscated: {f:sealed_garage}; with Synergy: secret {c:ch16}."),
    "13.3": C("Tolga 1977'de uyandı (T3). Pazartesi 1977'de geçer; finalde karar: telsize cevap verip dönmek ({f:late_by_49_years}) ya da kalıp sigortacı olmak ({f:another_year}).",
              "Tolga woke up in 1977 (T3). Monday happens in 1977; in the finale he decides: answer the radio and come back ({f:late_by_49_years}) or stay and become an insurance man ({f:another_year})."),
    "13.4": C("Hikmet pijamasıyla gelip Tolga'yı kurtardı: {f:pyjama_rescue}.", "Hikmet came in his pyjamas and rescued Tolga: {f:pyjama_rescue}."),
    "13.5": C("Tolga döndü, Hikmet 1453'te kaldı (H3): garaj boş. Bu yolun kendine ait finali yok; final dünyaya göre belirlenir.",
              "Tolga made it back, Hikmet stays in 1453 (H3): the garage is empty. This path has no ending of its own; the world decides."),
    "16.1": C("Sinerji düğmeyi gagaladı: pencere kurtuldu, Tolga döner (T1).", "Synergy pecked the button: the window is saved, Tolga makes it back (T1)."),
    "16.2": C("Leblebi kazandı: pencere kaçtı (T2).", "The chickpeas won: the window is lost (T2)."),
    "14.1": C("Tarih düzeltildi: dünya neredeyse normale döner.", "History is fixed: the world goes almost back to normal."),
    "14.2": C("Nihat raporu tahrif etti (N2).", "Nihat forged the report (N2)."),
    "14.3": C("Tolga gece Büro'da çalışmaya başlar (T4).", "Tolga starts working night shifts at the Bureau (T4)."),
    "14.4": C("Nihat istifa etti (N4).", "Nihat resigned (N4)."),
    "14.5": C("Nihat'ın yerine yeni model geldi (N3), tarih düzeltildi.", "Nihat is replaced by a new model (N3), history is fixed."),
}

# ------------------------------------------------------------------ finaller (chapter15._named_final sırası: biri tutarsa üstteki kazanır)

FINALS = [
    ["two_neighbours", "Hikmet'le 1453'teyken pencere kaçtı: ikisi de kaldı", "The window was missed with Hikmet in 1453: both stay", ["13.2"]],
    ["sealed_garage", "Makineye el konuldu ve pencere kaçtı", "The machine was confiscated and the window was missed", ["3.1", "13.2"]],
    ["empty_desk", "Tolga dönüş penceresini kaçırdı (ya da tutuklandı ve Büro'ya katılmadı)", "Tolga missed the return window (or was arrested and didn't join the Bureau)", ["13.2", "11.1", "16.2"]],
    ["late_by_49_years", "Tolga yanlış yıla (1977) döndü, Hikmet onu geri çağırdı", "Tolga came back to the wrong year (1977) and Hikmet called him back", ["13.3"]],
    ["another_year", "Tolga yanlış yıla (1977) döndü ve orada kaldı: sigortacı oldu", "Tolga came back to the wrong year (1977) and stayed: he became an insurance man", ["13.3"]],
    ["founding_member", "Büronun Kuruluşu + Tolga Büro'ya katıldı", "The Bureau was founded + Tolga joined it", ["10A.1", "14.3"]],
    ["night_shift", "Tolga Büro'ya katıldı", "Tolga joined the Bureau", ["14.3"]],
    ["sultans_repair", "Fatih makineyi istedi, tarih düzeltilmedi", "Mehmed asked for the machine, history left unfixed", ["12.4", "12.6"]],
    ["missing_paperwork", "Bizans'a yardım + yaratıcı tercüme + şafakta şehir düşmedi", "Helped Byzantium + creative translation + the city held at dawn", ["10H.1", "23.2", "26.3"]],
    ["long_wait", "Bizans'a yardım + gedik, lağım, kule Tolga'nın eliyle + şafakta şehir düşmedi", "Helped Byzantium + the breach, the mine and the tower by Tolga's hand + the city held at dawn", ["10H.1", "20.1", "20.2", "21.1", "22.1", "26.3"]],
    ["one_more_year", "Bizans'a yardım + şafakta şehir düşmedi", "Helped Byzantium + the city held at dawn", ["10H.1", "26.3"]],
    ["one_evening", "Bizans'a yardım ama şehir şafakta düştü: fetih 1453'te", "Helped Byzantium but the city fell at dawn: the Conquest in 1453", ["10H.1", "26.1", "26.2"]],
    ["sultans_table", "Ziyafet başarılı, tarih düzeltilmedi", "The feast succeeded, history left unfixed", ["10Z.1"]],
    ["envoy_to_venice", "Mektup Venedik gemisine yetişti", "The letter made the Venetian ship", ["10G.1"]],
    ["bureau_founding", "Form Z-1'in aslı imzalandı", "The original Form Z-1 was signed", ["10A.1"]],
    ["tunnel_truce", "İki lağım karanlıkta barıştı", "The two tunnels made peace in the dark", ["10L.1"]],
    ["big_bang", "Urban'ın topu patladı", "Urban's cannon blew up", ["10B.3"]],
    ["master_gunner", "Top döküldü ve atıldı", "The cannon was cast and fired", ["10B.1", "10B.2"]],
    ["time_repair", "Nihat istifa etti", "Nihat resigned", ["14.4"]],
    ["new_model", "Nihat'ın yerine yeni model geldi", "Nihat was replaced by a new model", ["14.5"]],
    ["pyjama_rescue", "Hikmet pijamasıyla kurtarmaya geldi", "Hikmet came to the rescue in his pyjamas", ["13.4"]],
    ["nobody_noticed", "Dünya değişti (Leblebipolis ya da İki Hükümdar), düzeltilmedi", "The world changed (Chickpeapolis or Two Rulers) and wasn't fixed", ["12.2", "12.3"]],
    ["eaves_child", "Bizans tarafında kimseyi bırakmadı: üç denizci, seldeki çocuk, Galata'da 'kal'", "Left no one behind on the Byzantine side: three sailors, the child in the flood, 'stay' in Galata", ["17.1", "24.1", "27.1"]],
    ["water_bearer", "Osmanlı tarafında askerlere su ve yardım: kadırga yangını, kuledeki marangozlar, kanlı ay çorbası", "Water and help for the soldiers on the Ottoman side: the galley fire, the carpenters on the tower, the blood-moon soup", ["17O.1", "22O.1", "24O.1"]],
    ["off_the_books", "Nihat raporu tahrif etti (dünya değişmediyse)", "Nihat forged the report (world unchanged)", ["14.2"]],
    ["fixed_mostly", "Tarih düzeltildi... neredeyse", "History was fixed... mostly", ["14.1"]],
    ["ordinary_monday", "Hiçbiri olmadıysa: tarih yerinde", "If none of the above: history intact", ["12.1", "12.5", "13.1", "16.1"]],
]

# ------------------------------------------------------------------ eşya ve müttefik izleri (docs/BRANCHING_V2.md)
# Her adım: [bölüm, TR, EN, sonuçlar (isteğe bağlı)]

THREADS = [
    {"id": "tape", "icon": "📦", "color": "#c9a34e", "name": L("Koli bandı · 3 şerit", "Duct tape · 3 strips"), "steps": [
        ["ch4a", "Nöbetçiler sırt sırta bantlanır.", "The guards get taped back to back."],
        ["ch6a", "Urban'ın topunun çatlağına bir şerit (topa iz kalır).", "A strip on the crack in Urban's cannon (it leaves a mark on the gun)."],
        ["ch10b", "Çatlak bantsızsa risk artar, Büyük Patlama yakınlaşır.", "Without tape on the crack the risk rises and the Big Bang draws closer.", ["10B.3"]],
        ["ch10h", "Barikata bir şerit.", "A strip on the barricade."],
        ["ch18", "Kaçan bağ bantla sarılır: köprü doğrulur.", "The slipping lashing gets taped: the bridge straightens.", ["18.1"]],
        ["ch20", "Gedik bantlanır (son şerit gerekiyorsa).", "The breach gets taped (if a strip is left).", ["20.2"]],
        ["ch20o", "6a'daki eski şerit ilk çatlağı tutar; çantada bant varsa yeni çatlak da sarılır.", "The old strip from 6a holds the first crack; with tape in the bag the new crack gets wrapped too."],
        ["ch32o", "Topçubaşı Ali: 'Belinde hâlâ senin şeridin.' Bantsız iki çatlakta büyük top o gün susar.", "Master gunner Ali: 'Your strip is still round its waist.' With two untaped cracks the great gun falls silent that day."],
    ]},
    {"id": "chickpeas", "icon": "🥜", "color": "#d8a25e", "name": L("Leblebi · 4 avuç", "Roasted chickpeas · 4 handfuls"), "steps": [
        ["ch4a", "Nöbetçilere bir avuç.", "A handful for the guards."],
        ["ch6a", "Kadri'ye bir avuç.", "A handful for Kadri."],
        ["ch6b", "Martıya bir avuç.", "A handful for the gull."],
        ["ch10h", "Zincir nöbetçilerine: {c:ch17}'de fenerli kayıkla gelirler, kurtarma süresi uzar.", "For the chain guards: they come with a lantern boat in {c:ch17}, the rescue clock gets longer."],
        ["ch10z", "Gizli malzeme.", "The secret ingredient."],
        ["ch10l", "Tünel Sulhu leblebiyle olur; yoksa yalnız poliçe.", "The Tunnel Truce needs chickpeas; otherwise just the policy.", ["10L.1"]],
        ["ch11", "İkna +15.", "Persuasion +15."],
        ["ch21", "Mirko'ya sus işareti.", "A hush sign for Mirko."],
        ["ch32o", "Hasan'ın ateşinin başında.", "At Hasan's campfire."],
    ]},
    {"id": "thermos", "icon": "☕", "color": "#d9774a", "name": L("Termos · 3 bardak", "Thermos · 3 cups"), "steps": [
        ["ch4a", "İkizlere mola: termosun tamamı gider, {c:ch9}'da bir bardağıyla döner.", "A break for the twins: the whole thermos goes, it comes back with one cup in {c:ch9}."],
        ["ch6a", "Kadri'yle kaftan takası: termos Kadri'de kalır.", "A kaftan swap with Kadri: the thermos stays with Kadri.", ["6a.4"]],
        ["ch10z", "Kadri'deyse taşan bir tabağı kurtarır.", "If Kadri has it, it saves an overflowing dish.", ["10Z.1"]],
        ["ch12", "Fatih'e bir bardak çay.", "A cup of tea for Mehmed."],
        ["ch21", "Kaplar bitince termosun kapağı beşinci kap olur.", "When the bowls run out, the thermos lid becomes the fifth bowl.", ["21.1"]],
        ["ch24o", "Ateş başlarında çay; Kadri'deyse çorba sıcak kalır, mutfağa en yakın ateş sakinleşir.", "Tea at the campfires; if Kadri has it the soup stays hot and the fire nearest the kitchen calms down.", ["24O.1"]],
    ]},
    {"id": "cologne", "icon": "🍋", "color": "#c7c95a", "name": L("Kolonya · 3 fıs", "Cologne · 3 splashes"), "steps": [
        ["ch4a", "Nöbetçilere bir fıs.", "A splash for the guards."],
        ["ch6a", "Lütfi'ye bir fıs.", "A splash for Lütfi."],
        ["ch22", "Fıçılara dökülür: erken bırakılan fıçı yanarak yuvarlanır.", "Poured on the barrels: a barrel let go too early rolls down burning.", ["22.1"]],
    ]},
    {"id": "powerbank", "icon": "🔋", "color": "#6fc3a0", "name": L("Powerbank · 2 dolum", "Power bank · 2 charges"), "steps": [
        ["ch10b", "İki katı barut.", "Double the powder."],
        ["ch10h", "Giustiniani'ye 'zırh ısıtıcısı' olarak verilir.", "Given to Giustiniani as an 'armour heater'."],
        ["ch21", "Deprem uygulaması lağımı dinler.", "The earthquake app listens for the mine.", ["21.1"]],
        ["ch26", "Isıtıcının kutusu şafakta kurşunu tutabilir: hücum püskürtülür.", "At dawn the heater's case can stop the bullet: the assault is thrown back.", ["26.3"]],
    ]},
    {"id": "fez", "icon": "🎩", "color": "#c8262e", "name": L("Yedek fes → Hüseyin", "Spare fez → Hüseyin"), "steps": [
        ["ch2", "Haliç'te yüzerken bulunur, cebe girer.", "Found while swimming in the Golden Horn, goes into the pocket."],
        ["ch4a", "Nöbetçilere verilir: yeni bir geçiş yolu.", "Given to the guards: a new way past them.", ["4a.2"]],
        ["ch7", "Hüseyin fesle görünür; ikizler artık kim kim biliyor.", "Hüseyin turns up in the fez; the twins can finally be told apart."],
        ["ch10", "Hüseyin kefil olur, Sorucu Ağa'nın ilk sorusu atlanır.", "Hüseyin vouches for Tolga, the Interrogating Agha's first question is skipped."],
        ["ch16", "Gıdak'ta da fesli.", "Still in the fez in Cluck."],
    ]},
    {"id": "cube", "icon": "🧊", "color": "#5aa8d8", "name": L("Küp → Hüseyin", "The cube → Hüseyin"), "steps": [
        ["ch4a", "Küp Hüseyin'de kalır.", "The cube stays with Hüseyin."],
        ["ch7", "Çözmeye çalışır.", "He tries to solve it."],
        ["ch9", "Kapıda bir yüzü çözülmüş geri gelir; gelmezse 10O'da hâlâ elinde.", "It comes back at the gate with one face solved; if not, he still has it in 10O."],
    ]},
    {"id": "lighter", "icon": "🔥", "color": "#e8703a", "name": L("Çakmak → Giustiniani ya da Urban", "The lighter → Giustiniani or Urban"), "steps": [
        ["ch6b", "Giustiniani: 'Ama alırım.'", "Giustiniani: 'But I'll take it.'"],
        ["ch20", "Topçuları onunla fitil yakar.", "His gunners light their fuses with it."],
        ["ch26", "Yaralanırsa çakmağı Tolga'nın avucuna bırakır (G harfi kazınmış).", "If wounded, he leaves the lighter in Tolga's palm (a G scratched into it)."],
        ["ch6a", "Ya da Urban: 'Fitil kutusu, bende kalsın.'", "Or Urban: 'A fuse box, I'll keep it.'"],
        ["ch10b", "Urban fitili Tolga'nın çakmağıyla yakar.", "Urban lights the fuse with Tolga's lighter."],
        ["ch20o", "Osmanlı tarafında Urban hâlâ onunla çakar.", "On the Ottoman side Urban still strikes it."],
    ]},
    {"id": "book", "icon": "📖", "color": "#9a7bd0", "name": L("Tarih kitabı → Giustiniani", "History book → Giustiniani"), "steps": [
        ["ch6b", "'Sende kalsın. Oku.'", "'Keep it. Read it.'"],
        ["ch12", "Kitap gidince huzurdaki anahtar sahnesi kitapsız oynanır.", "Without the book, the key scene at the audience plays out bookless."],
        ["ch20", "Bir sayfası uykusunu kaçırır.", "One of its pages keeps him awake."],
        ["ch26", "Şafakta 29 Mayıs'ı bilerek konuşur.", "At dawn he speaks knowing what 29 May means."],
    ]},
    {"id": "guestpass", "icon": "📜", "color": "#7f6cc6", "name": L("Misafir İzni (Theodoros)", "Guest Pass (Theodoros)"), "steps": [
        ["ch6b", "Theodoros'un tek mühürlü izni cebe girer.", "Theodoros's single-sealed pass goes into the pocket."],
        ["ch10h", "Theodoros kendi mührünü tanır, Frenk'e kefil olur.", "Theodoros recognises his own seal and vouches for the Frank."],
        ["ch23", "Bizans'ta ikinci mührü basar: 'saray tercümanı'.", "On the Byzantine side he adds a second seal: 'palace interpreter'."],
        ["ch25", "Son ayinde Tolga saray halkının arasında; İmparator helalliği ona ayrıca söyler.", "At the last liturgy Tolga stands among the court; the Emperor asks his forgiveness separately."],
        ["ch39o", "Petrion'daki Rum komşu mührü tanır, çavuşu kendisi getirir.", "The Greek neighbour in Petrion recognises the seal and fetches the sergeant himself."],
    ]},
    {"id": "tezkire", "icon": "🪶", "color": "#3f9a6b", "name": L("Sultan'ın tezkiresi", "The Sultan's pass"), "steps": [
        ["ch12", "Kâtibin uzattığı tuğralı kâğıt cebe girer.", "The tughra-stamped paper from the scribe goes into the pocket.", ["12.1", "12.2", "12.4", "12.6"]],
        ["ch19", "Devriyeye dördüncü cevap: tuğra fenere tutulur. Tayfa görür.", "A fourth answer for the patrol: the tughra is held to the lantern. The crew sees it."],
        ["ch25", "Osmanlı tarafında ilk yakalanışta nöbetçi tuğrayı görür.", "On the Ottoman side the guard sees the tughra at the first capture."],
        ["ch26", "Şehir düşünce Kardinal Isidoros'u esir kafilesinden 'kâtibim' diye çıkarır.", "When the city falls, Tolga pulls Cardinal Isidore out of the line of captives as 'my scribe'."],
        ["ch27", "Isidoros Galata rıhtımında teşekkür eder.", "Isidore thanks him on the Galata quay."],
        ["ch39o", "Baltalılara üçüncü kez gösterilir.", "Shown to the axemen for the third time."],
    ]},
    {"id": "kadri", "icon": "🍲", "color": "#e0a03a", "name": L("Aşçıbaşı Kadri", "Head cook Kadri"), "steps": [
        ["ch6a", "Yamaklık ya da termos takası.", "Working as his kitchen boy, or the thermos swap.", ["6a.1"]],
        ["ch10z", "Ziyafet; ya da Tolga yüzünden mutfak yanar (o zaman gelmez).", "The feast; or the kitchen burns because of Tolga (then he won't come).", ["10Z.1", "10Z.2"]],
        ["ch17o", "İki yamağıyla kovalarla gelir: yangın vaktinde söner.", "He comes with two kitchen boys and buckets: the fire is out in time.", ["17O.1"]],
        ["ch24o", "Kazanında Tolga'nın ziyafet çorbası.", "Tolga's feast soup in his cauldron.", ["24O.1"]],
        ["ch26o", "Sucuların başında; yamağı birinci bölüğü sular.", "At the head of the water-carriers; his boy waters the first company."],
    ]},
    {"id": "twins", "icon": "👬", "color": "#d0574e", "name": L("Hasan ile Hüseyin", "Hasan and Hüseyin"), "steps": [
        ["ch4a", "Nöbetçilerle dost olunur.", "Tolga makes friends with the guards."],
        ["ch10", "Hüseyin kefil olur.", "Hüseyin vouches for him."],
        ["ch18", "İkizler fıçıları tutar: bağın yeşil bandı genişler.", "The twins hold the barrels: the green band of the lashing widens.", ["18.1"]],
        ["ch22o", "Hüseyin de Hasan'ın yanında: yetişilemeyen ustayı o indirir.", "Hüseyin is beside Hasan too: he brings down the master Tolga couldn't reach.", ["22O.1"]],
        ["ch32o", "Sükût gecesi Hasan'ın ateşi.", "Hasan's fire on the night of silence."],
    ]},
    {"id": "niko", "icon": "🐔", "color": "#c7a6e8", "name": L("Niko", "Niko"), "steps": [
        ["ch6b", "Niko dost.", "Niko is a friend.", ["6b.4"]],
        ["ch10h", "Zincir nöbeti.", "The chain watch."],
        ["ch17", "Fenerli kayıkla gelir: kurtarma süresi 40 → 52 sn.", "He comes with the lantern boat: the rescue clock goes 40 → 52 s.", ["17.1"]],
        ["ch20", "Taşıyıcılardan biri: gediğe yük getirir.", "One of the carriers: he brings loads to the breach.", ["20.1"]],
        ["ch24", "Alayda sırığa omuz verir; selde saçağın önüne kapı kanadı yatırır.", "He shoulders the pole in the procession; in the flood he lays a door across in front of the eaves.", ["24.1"]],
    ]},
    {"id": "witnesses", "icon": "⚓", "color": "#4f8fc8", "name": L("Kuşatmanın tanıkları", "The siege's witnesses"), "steps": [
        ["ch17", "Sudan çekilen denizciler.", "The sailors pulled out of the water.", ["17.1"]],
        ["ch19", "Kurtarılan Venedikli tayfada: oylamada dönmekten yana konuşur.", "The rescued Venetian is in the crew: he speaks for turning back in the vote.", ["19.1"]],
        ["ch21", "Lağımcıbaşı Kasım'ın sorgusu: sözüne güvenilirse...", "Master miner Kasım's interrogation: if his word is trusted..."],
        ["ch26", "...Kasım kafileden Isidoros'u çıkarır (tezkiresiz ikinci yol).", "...Kasım pulls Isidore out of the line (the second way, without a pass)."],
        ["ch33o", "Boğazkesen'in Cenevizli tüccarı: şarap hediyesi.", "Boğazkesen's Genoese merchant: the gift of wine."],
        ["ch27", "Cenevizli Galata'da kalır ya da Sakız'a gider; kaptan kalır ya da biner.", "The Genoese stays in Galata or sails for Chios; the captain stays or boards.", ["27.1"]],
    ]},
]

# ------------------------------------------------------------------ çıktı


def main():
    edges, lanes = layout()
    finals = []
    for fid, ctr, cen, src in FINALS:
        k = "UI_CH15_FINAL_" + fid.upper()
        finals.append({"id": fid, "name": t(k), "sub": t(k + "_SUB"), "cond": L(ctr, cen), "from": src})
    threads = []
    for th in THREADS:
        threads.append({"id": th["id"], "icon": th["icon"], "color": th["color"], "name": th["name"],
                        "steps": [{"ch": s[0], "text": L(s[1], s[2]), **({"via": s[3]} if len(s) > 3 else {})} for s in th["steps"]]})
    # Sonuç kimliği -> bölüm (siteyi sonuçtan bölüme götürür)
    out_ch = {}
    for c in CHAPTERS.values():
        for n in c["nodes"]:
            if n["outcome"]:
                out_ch.setdefault(n["id"], c["id"])
                if n.get("alt_id"):
                    out_ch.setdefault(n["alt_id"], c["id"])
    out_ch["26.1"] = "ch26"; out_ch["26.2"] = "ch26"
    n_out = len({k for k in out_ch})
    version = open(os.path.join(ROOT, "VERSION")).read().strip()
    data = {
        "meta": {"version": version, "date": datetime.date.today().isoformat(),
                 "sides": {sd: [cid(scene_for(ch, sd)) for ch in SIDE_LIST[sd]] for sd in ("B", "O")},
                 "counts": {"scenes": len(SCENES), "siege_b": len(SIDE_LIST["B"]), "siege_o": len(SIDE_LIST["O"]),
                            "outcomes": n_out, "finals": len(finals), "threads": len(threads)}},
        "acts": ACTS, "rows": ROWS, "edges": edges, "lanes": lanes,
        "chapters": CHAPTERS, "outcome_chapter": out_ch, "ends": ENDS,
        "effects": EFFECTS, "finals": finals, "threads": threads,
    }
    # Denetim: bağlantıların, izlerin ve finallerin andığı her şey var mı
    ids = set(CHAPTERS)
    for e in edges:
        assert e["from"] in ids and e["to"] in ids, e
    for r in ROWS:
        for kind, x in re.findall(r"\{([cof]):([^}]+)\}", (r["ghost"]["tr"] + r["ghost"]["en"]) if "ghost" in r else ""):
            assert (x in ids) if kind == "c" else (x in out_ch), ("ghost", x)
    for th in threads:
        for s in th["steps"]:
            assert s["ch"] in ids, (th["id"], s["ch"])
            for o in s.get("via", []):
                assert o in out_ch, (th["id"], o)
            for kind, x in re.findall(r"\{([cof]):([^}]+)\}", s["text"]["tr"] + s["text"]["en"]):
                assert (x in ids) if kind == "c" else (x in out_ch), (th["id"], x)
    for f in finals:
        for o in f["from"]:
            assert o in out_ch, (f["id"], o)
    for k, v in EFFECTS.items():
        assert k in out_ch, k
        for ref in re.findall(r"\{([cof]):([^}]+)\}", v["tr"] + v["en"]):
            kind, x = ref
            if kind == "c":
                assert x in ids, (k, x)
            elif kind == "o":
                assert x in out_ch, (k, x)
            else:
                assert x in {f["id"] for f in finals}, (k, x)
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    json.dump(data, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))
    n = sum(len(c["nodes"]) for c in CHAPTERS.values())
    print(f"{len(CHAPTERS)} kart, {n} düğüm, {n_out} sonuç, {len(edges)} geçiş, {lanes} şerit, {len(finals)} final, {len(threads)} iz -> {OUT}")
    print("Bizans:", " ".join(data["meta"]["sides"]["B"]))
    print("Osmanlı:", " ".join(data["meta"]["sides"]["O"]))


if __name__ == "__main__":
    main()
