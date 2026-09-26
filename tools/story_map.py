#!/usr/bin/env python3
"""Hikâye haritası verisi: her bölümün akış şeması (düğümler, bağlantılar), bölümler arası geçişler ve
23 finalin koşulları, oyunun kendi kodundan ve metinlerinden çıkarılır. Tanıtım sitesinin etkileşimli
hikâye ağacı (story.html) bu dosyayı okur.

    python3 tools/story_map.py [çıktı.json]      (varsayılan: ../nothistorygamedemo/data/story.json)

Bölüm geçişleri ve kader kuralları kodda dağınık (chapter9 NEXT_SCENE, chapter11 _next_scene,
chapter15 _named_final...): burada elle özetlenir; o dosyalar değişirse bu tablo da güncellenmeli.
"""
import csv, json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "..", "nothistorygamedemo", "data", "story.json")

S = {r[0]: r for r in csv.reader(open(os.path.join(ROOT, "i18n/strings.csv"), encoding="utf-8")) if r and len(r) >= 3}


def t(key, strip_chapter=False):
    r = S.get(key)
    if not r:
        return {"tr": key, "en": key}
    tr_, en = r[1], r[2]
    if strip_chapter and "—" in tr_:
        tr_ = tr_.split("—")[-1].strip().title().replace("Ii", "II")
        en = en.split("—")[-1].strip().title()
    return {"tr": tr_, "en": en}


def cap(s):
    # "OTAĞ KAPISI" -> "Otağ Kapısı" (Türkçe büyük/küçük harf; rakamlı kelimeler olduğu gibi)
    out = []
    for w in s.split():
        if any(ch.isdigit() for ch in w):
            out.append(w); continue
        low = w.replace("I", "ı").replace("İ", "i").lower()
        first = low[:1]
        first = "İ" if first == "i" else ("I" if first == "ı" else first.upper())
        out.append(first + low[1:])
    return " ".join(out)


SMALL = {"of", "the", "in", "a", "an", "and", "on", "to"}


def cap_en(s):
    words = s.split()
    out = []
    for i, w in enumerate(words):
        if any(ch.isdigit() for ch in w):
            out.append(w); continue
        lw = w.lower()
        out.append(lw if (i > 0 and lw in SMALL) else "-".join(p[:1].upper() + p[1:] for p in lw.split("-")))
    return " ".join(out)


def title(key):
    r = S[key]
    return {"tr": cap(r[1].split("—")[-1].strip()), "en": cap_en(r[2].split("—")[-1].strip())}


def flow(script):
    """Bölüm betiğindeki akış şeması: düğümler ve bağlantılar."""
    s = open(os.path.join(ROOT, "scripts", script), encoding="utf-8").read()
    nodes = []
    for m in re.finditer(r'\{"id": "([^"]+)", "key": "([^"]+)"[^}]*?\}', s):
        whole = m.group(0)
        label = t(m.group(2))
        nodes.append({"id": m.group(1), "label": label, "outcome": '"outcome": true' in whole})
    edges = []
    i = s.find("c.edges")
    if i >= 0:
        block = s[i:s.find("\n\n", i)]
        edges = [list(e) for e in re.findall(r'\["([^"]+)", "([^"]+)"\]', block)]
    return nodes, edges


# Bölümler: [kimlik, sütun, başlık anahtarı, alt başlık anahtarı, kapak, betik, varyant notu (TR, EN)]
CHAPTERS = [
    ["ch1", 1, "UI_CH1_TITLE", "UI_CH1_SUB", "ch1", "chapter1.gd", None],
    ["ch2", 2, "UI_CH2_TITLE", "UI_CH2_SUB", "ch2", "chapter2.gd", None],
    ["ch3", 3, "UI_CH3_TITLE", "UI_CH3_SUB", "ch3", "chapter3.gd", None],
    ["ch4a", 4, "UI_CH4_TITLE", "UI_CH4_SUB_4A", "ch4a", "chapter4.gd", ["Bölüm 2'de kıyıya çıktıysan", "If you made it to the shore in Chapter 2"]],
    ["ch4b", 4, "UI_CH4_TITLE", "UI_CH4_SUB_4B", "ch4b", "chapter4.gd", ["Bölüm 2'de zincire ulaştıysan (2.3)", "If you reached the chain in Chapter 2 (2.3)"]],
    ["ch5", 5, "UI_CH5_TITLE", "UI_CH5_SUB", "ch5", "chapter5.gd", None],
    ["ch6a", 6, "UI_CH6A_TITLE", "UI_CH6A_SUB", "ch6a", "chapter6.gd", ["Ordugâh yolu (4a)", "The camp route (4a)"]],
    ["ch6b", 6, "UI_CH6B_TITLE", "UI_CH6B_SUB", "ch6b", "chapter6.gd", ["Surlar yolu (4b)", "The walls route (4b)"]],
    ["ch7", 7, "UI_CH7_TITLE", "UI_CH7_SUB", "ch7", "chapter7.gd", None],
    ["ch8", 8, "UI_CH8_TITLE", "UI_CH8_SUB", "ch8", "chapter8.gd", None],
    ["ch9", 9, "UI_CH9_TITLE", "UI_CH9_SUB", "ch9", "chapter9.gd", None],
    ["ch10z", 10, "UI_CH10Z_TITLE", "UI_CH10Z_SUB", "ch10z", "chapter10z.gd", ["Kadri'nin teklifi (9.1)", "Kadri's offer (9.1)"]],
    ["ch10b", 10, "UI_CH10B_TITLE", "UI_CH10B_SUB", "ch10b", "chapter10b.gd", ["Urban'ın teklifi (9.2)", "Urban's offer (9.2)"]],
    ["ch10g", 10, "UI_CH10G_TITLE", "UI_CH10G_SUB", "ch10g", "chapter10g.gd", ["Çandarlı'nın mektubu (9.3)", "Çandarlı's letter (9.3)"]],
    ["ch10h", 10, "UI_CH10H_TITLE", "UI_CH10H_SUB", "ch10h", "chapter10h.gd", ["Lütfi'nin heyeti (9.4)", "Lütfi's embassy (9.4)"]],
    ["ch10a", 10, "UI_CH10A_TITLE", "UI_CH10A_SUB", "ch10a", "chapter10a.gd", ["Theodoros'un arşivi (9.5)", "Theodoros's archive (9.5)"]],
    ["ch10l", 10, "UI_CH10L_TITLE", "UI_CH10L_SUB", "ch10l", "chapter10l.gd", ["Dragan'ın lağımı (9.7)", "Dragan's tunnel (9.7)"]],
    ["ch10", 10, "UI_CH10O_TITLE", "UI_CH10O_SUB", "ch10", "chapter10.gd", ["Hepsini reddettiysen (9.6)", "If you turned everyone down (9.6)"]],
    ["ch11", 11, "UI_CH11_TITLE", "UI_CH11_SUB", "ch11", "chapter11.gd", None],
    ["ch12", 12, "UI_CH12_TITLE", "UI_CH12_SUB", "ch12", "chapter12.gd", None],
    ["ch12b", 12, "UI_CH12B_TITLE", "UI_CH12B_SUB", "ch12b", "chapter12b.gd", ["Heyette Bizans'a yardım ettiysen", "If you helped Byzantium during the embassy"]],
    ["ch13", 13, "UI_CH13_TITLE", "UI_CH13_SUB", "ch13", "chapter13.gd", None],
    ["ch16", 13, "UI_CH16_TITLE", "UI_CH16_SUB", "ch16", "chapter16.gd", ["Gizli bölüm: pencere kaçtı, ama tavuk her şeyi gördü", "Secret chapter: the window was missed, but the chicken saw everything"]],
    ["ch14", 14, "UI_CH14_TITLE", "UI_CH14_SUB", "ch14", "chapter14.gd", None],
]

# Sonuç -> sonraki bölüm(ler). Listelenmeyen sonuç, "default" hedefine gider.
NEXT = {
    "ch1": {"default": ["ch2"], "1.3": ["early"]},
    "ch2": {"default": ["ch3"], "2.5": ["early"]},
    "ch3": {"default": ["ch4a", "ch4b"]},
    "ch4a": {"default": ["ch5"]}, "ch4b": {"default": ["ch5"]},
    "ch5": {"default": ["ch6a", "ch6b"]},
    "ch6a": {"default": ["ch7"]}, "ch6b": {"default": ["ch7"]},
    "ch7": {"default": ["ch8"]},
    "ch8": {"default": ["ch9"]},
    "ch9": {"9.1": ["ch10z"], "9.2": ["ch10b"], "9.3": ["ch10g"], "9.4": ["ch10h"], "9.5": ["ch10a"], "9.6": ["ch10"], "9.7": ["ch10l"]},
    "ch10z": {"10Z.1": ["ch11"], "10Z.2": ["ch11"]},
    "ch10b": {"default": ["ch11"]},
    "ch10g": {"10G.1": ["ch13"], "10G.2": ["ch11"]},
    "ch10h": {"default": ["ch11"]},
    "ch10a": {"10A.1": ["ch13"], "10A.2": ["ch11"]},
    "ch10l": {"default": ["ch11"]},
    "ch10": {"default": ["ch11"]},
    "ch11": {"11.1": ["ch14"], "default": ["ch12", "ch12b", "ch13"]},
    "ch12": {"default": ["ch13"]},
    "ch12b": {"default": ["ch13"]},
    "ch13": {"13.2": ["ch14", "ch16"], "default": ["ch14"]},
    "ch16": {"default": ["ch14"]},
    "ch14": {"default": ["final"]},
}

# Kaderi belirleyen sonuçlar (detay panelinde "sonrası")
EFFECTS = {
    "1.3": ["Kırmızı düğme: garanti içinde garaja dönüş, oyun erken biter.", "Red button: back to the garage under warranty, the game ends early."],
    "2.5": ["Kırmızı düğme: garanti içinde garaja dönüş, oyun erken biter.", "Red button: back to the garage under warranty, the game ends early."],
    "2.3": ["Bölüm 4 ve 6 surların içinde, Bizans tarafında geçer.", "Chapters 4 and 6 take place inside the walls, on the Byzantine side."],
    "3.1": ["Makineye el konuldu: pencere de kaçarsa garaj mühürlenir.", "The machine is confiscated: if the window is also missed, the garage gets sealed."],
    "10Z.1": ["Dünya: Sultan'ın Sofrası (W7). Bölüm 12 atlanır.", "World: The Sultan's Table (W7). Chapter 12 is skipped."],
    "10B.1": ["Dünya: Topçubaşı (W5). Bölüm 12 atlanır.", "World: Master Gunner (W5). Chapter 12 is skipped."],
    "10B.2": ["Dünya: Topçubaşı (W5). Bölüm 12 atlanır.", "World: Master Gunner (W5). Chapter 12 is skipped."],
    "10B.3": ["Dünya: Büyük Patlama (W5B). Bölüm 12 atlanır.", "World: The Big Bang (W5B). Chapter 12 is skipped."],
    "10G.1": ["Dünya: Venedik'e Elçi (W6). Doğrudan dönüş penceresine.", "World: Envoy to Venice (W6). Straight to the return window."],
    "10A.1": ["Dünya: Büronun Kuruluşu (W8). Doğrudan dönüş penceresine.", "World: The Founding of the Bureau (W8). Straight to the return window."],
    "10L.1": ["Dünya: Tünel Sulhu (W13). Bölüm 12 atlanır.", "World: The Tunnel Truce (W13). Chapter 12 is skipped."],
    "10H.1": ["Bizans'a verdiğin her yardım (gedik, Giustiniani, zincir) fethi erteler: Son Akşam'a gidilir.", "Every bit of help you gave Byzantium (the breach, Giustiniani, the chain) delays the Conquest: on to The Last Evening."],
    "11.1": ["Tolga tutuklandı: doğrudan Nihat'ın son formuna.", "Tolga is arrested: straight to Nihat's final form."],
    "12.1": ["Dünya: Tarih yerinde (W1).", "World: History intact (W1)."],
    "12.2": ["Dünya: Leblebipolis (W2).", "World: Chickpeapolis (W2)."],
    "12.3": ["Dünya: İki Hükümdar (W3).", "World: Two Rulers (W3)."],
    "12.4": ["Dünya: Sultan'ın Tamiri (W4).", "World: The Sultan's Repair (W4)."],
    "12.6": ["Dünya: Sultan'ın Tamiri (W4).", "World: The Sultan's Repair (W4)."],
    "13.1": ["Tolga 2026'ya döndü (T1).", "Tolga made it back to 2026 (T1)."],
    "13.2": ["Tolga 1453'te kaldı (T2).", "Tolga stays in 1453 (T2)."],
    "13.3": ["Tolga yanlış yılda uyandı (T3).", "Tolga woke up in the wrong year (T3)."],
    "13.4": ["Hikmet pijamasıyla gelip Tolga'yı kurtardı.", "Hikmet came in his pyjamas and rescued Tolga."],
    "13.5": ["Hikmet 1453'te kaldı (H3).", "Hikmet stays in 1453 (H3)."],
    "14.1": ["Tarih düzeltildi: dünya neredeyse normale döner.", "History is fixed: the world goes almost back to normal."],
    "14.2": ["Nihat raporu tahrif etti (N2).", "Nihat forged the report (N2)."],
    "14.3": ["Tolga gece Büro'da çalışmaya başlar (T4).", "Tolga starts working night shifts at the Bureau (T4)."],
    "14.4": ["Nihat istifa etti (N4).", "Nihat resigned (N4)."],
    "14.5": ["Nihat'ın yerine yeni model geldi (N3), tarih düzeltildi.", "Nihat is replaced by a new model (N3), history is fixed."],
}

# 23 final, oyundaki öncelik sırasıyla (chapter15._named_final): [kimlik, koşul TR, koşul EN, besleyen sonuçlar]
FINALS = [
    ["two_neighbours", "Tolga 1453'te kaldı ve Hikmet de orada", "Tolga stayed in 1453 and so did Hikmet", ["13.2", "13.5"]],
    ["empty_desk", "Tolga dönüş penceresini kaçırdı", "Tolga missed the return window", ["13.2"]],
    ["another_year", "Tolga yanlış yıla döndü", "Tolga came back to the wrong year", ["13.3"]],
    ["founding_member", "Büronun Kuruluşu + Tolga Büro'ya katıldı", "The Bureau was founded + Tolga joined it", ["10A.1", "14.3"]],
    ["night_shift", "Tolga Büro'ya katıldı", "Tolga joined the Bureau", ["14.3"]],
    ["sultans_repair", "Fatih makineyi istedi, tarih düzeltilmedi", "Mehmed asked for the machine, history left unfixed", ["12.4", "12.6"]],
    ["missing_paperwork", "Son Akşam: Bizans'a üç yardım", "The Last Evening: three kinds of help to Byzantium", ["ch12b"]],
    ["long_wait", "Son Akşam: Bizans'a iki yardım", "The Last Evening: two kinds of help to Byzantium", ["ch12b"]],
    ["one_more_year", "Son Akşam: Bizans'a bir yardım", "The Last Evening: one kind of help to Byzantium", ["ch12b"]],
    ["sultans_table", "Ziyafet başarılı, tarih düzeltilmedi", "The feast succeeded, history left unfixed", ["10Z.1"]],
    ["envoy_to_venice", "Mektup Venedik gemisine yetişti", "The letter made the Venetian ship", ["10G.1"]],
    ["bureau_founding", "Form Z-1'in aslı imzalandı", "The original Form Z-1 was signed", ["10A.1"]],
    ["tunnel_truce", "İki lağım karanlıkta barıştı", "The two tunnels made peace in the dark", ["10L.1"]],
    ["big_bang", "Urban'ın topu patladı", "Urban's cannon blew up", ["10B.3"]],
    ["master_gunner", "Top döküldü ve atıldı", "The cannon was cast and fired", ["10B.1", "10B.2"]],
    ["time_repair", "Nihat istifa etti", "Nihat resigned", ["14.4"]],
    ["new_model", "Nihat'ın yerine yeni model geldi", "Nihat was replaced by a new model", ["14.5"]],
    ["sealed_garage", "Makineye el konuldu, garaj mühürlendi", "The machine was confiscated, the garage sealed", ["3.1"]],
    ["pyjama_rescue", "Hikmet pijamasıyla kurtarmaya geldi", "Hikmet came to the rescue in his pyjamas", ["13.4"]],
    ["off_the_books", "Nihat raporu tahrif etti", "Nihat forged the report", ["14.2"]],
    ["fixed_mostly", "Tarih düzeltildi... neredeyse", "History was fixed... mostly", ["14.1"]],
    ["nobody_noticed", "Dünya değişti (Leblebipolis ya da İki Hükümdar)", "The world changed (Chickpeapolis or Two Rulers)", ["12.2", "12.3"]],
    ["ordinary_monday", "Hiçbiri olmadıysa: tarih yerinde", "If none of the above: history intact", ["12.1", "13.1"]],
]


# Aynı betiği paylaşan varyant bölümler: hangi düğümler hangisine ait ("4a" -> 4a.1, 4a.2...)
VARIANT_NODES = {
    "ch4a": {"4a", "sneak", "confront"}, "ch4b": {"4b", "chain", "niko"},
    "ch6a": {"morning", "A", "B", "C", "Y", "6a"}, "ch6b": {"maze", "6b", "giust", "emperor"},
}


def main():
    chapters = []
    for cid, col, tkey, skey, cover, script, note in CHAPTERS:
        nodes, edges = flow(script)
        if cid in VARIANT_NODES:
            keep = VARIANT_NODES[cid]
            nodes = [n for n in nodes if n["id"] in keep or any(n["id"].startswith(p + ".") for p in keep)]
            ids = {n["id"] for n in nodes}
            edges = [e for e in edges if e[0] in ids and e[1] in ids]
        num = re.search(r"\d+", cid).group(0)
        chapters.append({
            "id": cid, "col": col, "num": int(num),
            "title": title(tkey), "sub": t(skey),
            "cover": f"img/ch/{cover}.jpg",
            "note": {"tr": note[0], "en": note[1]} if note else None,
            "nodes": nodes, "edges": edges,
            "next": NEXT.get(cid, {}),
        })
    finals = []
    for fid, ctr, cen, src in FINALS:
        k = "UI_CH15_FINAL_" + fid.upper()
        finals.append({"id": fid, "name": t(k), "sub": t(k + "_SUB"), "cond": {"tr": ctr, "en": cen}, "from": src})
    effects = {k: {"tr": v[0], "en": v[1]} for k, v in EFFECTS.items()}
    data = {"chapters": chapters, "finals": finals, "effects": effects}
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    json.dump(data, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    n = sum(len(c["nodes"]) for c in chapters)
    print(f"{len(chapters)} bölüm, {n} düğüm, {len(finals)} final -> {OUT}")


if __name__ == "__main__":
    main()
