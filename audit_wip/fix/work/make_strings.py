import csv
SRC = "/home/user/nothistorygame/i18n/strings.csv"
OUT = "/tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit/fix/F12_ses_metin_strings.csv"
rows = list(csv.reader(open(SRC, encoding="utf-8", newline="")))
cur = {r[0]: (r[1], r[2]) for r in rows[1:] if len(r) >= 3}

Q75 = """D22O_N_01 D19O_N_01 D19O_R_01 D19O_R_02 D19O_T_NOTICE D19O_T_TELL D19O_R_TELL D19O_R_SILENT D19O_R_PASS D19O_N_GONE D19O_R_BACK D19O_T_BACK D19O_R_CLOSE D19O_T_END D19O_N_END D24O_N_01 D24O_K_01 D24O_T_01 D24O_D_01 D24O_S_1 D24O_S_2 D24O_S_3 D24O_T_SCIENCE D24O_T_SOUP D24O_T_JOKE D24O_S_1_SCIENCE D24O_S_1_SOUP D24O_S_1_JOKE D24O_S_2_SCIENCE D24O_S_2_SOUP D24O_S_2_JOKE D24O_S_3_SCIENCE D24O_S_3_SOUP D24O_S_3_JOKE D24O_D_ALL D24O_D_REST D24O_T_MOON D24O_K_STORM D24O_K_LOST_2 D24O_K_END D24O_T_END D24O_N_END SIEGE_NOTE_24O_1 SIEGE_NOTE_24O_2 D26O_N_IN SIEGE_NOTE_26O_1 SIEGE_NOTE_26O_2 D18B_N_01 D18B_G_01 D18B_G_END_HIT D18B_G_END_MISS D18B_T_END D18B_N_END SIEGE_NOTE_18B_1 SIEGE_NOTE_18B_2 D23O_N_01 D23O_I_01 D23O_I_END D23O_T_END D25O_N_VIGIL D25O_H_1 D25O_H_2 D25O_T_LEB D25O_H_WATER D25O_H_SIT D25O_H_3 D25O_T_END D25O_N_END D26_N_ENTRY D26_T_ENTRY D26_N_ENTRY_2 D26_F_ENTRY D26_T_ENTRY_2 D_ARENA_N_B D_ARENA_N_O""".split()
assert len(Q75) == 75

def inner_fix(s):
    out = []
    for i, ch in enumerate(s):
        if ch == '"':
            prev = s[i-1] if i > 0 else " "
            out.append("‘" if prev.isspace() or prev in "(" else "’")
        else:
            out.append(ch)
    return "".join(out)

new = {}
for k in Q75:
    tr, en = cur[k]
    assert en.startswith('"') and en.endswith('"')
    new[k] = (tr, inner_fix(en[1:-1]))

# Sahne notları: anlatım parantez içine alınır; konuşma değişmez. Değişen yerler: "Niko:" etiketi (EMPEROR_COLOGNE'da
# Niko'nun repliği İmparator'un sesiyle okunuyordu).
new.update({
 "REACT_GUARDS_SELFIE": (
  '(Tolga fotoğraf çeker.) Hasan: "Ruhumu mu aldın?" Hüseyin: "Senin ruhun yok ki Hasan." Hasan: "Ben Hüseyin\'im!"',
  '(Tolga takes a photo.) Hasan: "Did you steal my soul?" Hüseyin: "You haven\'t got one, Hasan." Hasan: "I\'m Hüseyin!"'),
 "REACT_GUARDS_CUBE": (
  '(İkisi küpü kapar.) "Sen çevir." "Hayır sen." (Küp giderek daha çok karışır.)',
  '(They both grab it.) "You turn it." "No, you." (The cube gets progressively worse.)'),
 "REACT_GUARDS_THERMOS": (
  '(İkisi birden.) "Bu ne, otlu sıcak su mu?" (Bir yudum. Uzun bir sessizlik.) "...Beş dakika mola."',
  '(Both, at once.) "What\'s this, hot leaf water?" (A sip. A long silence.) "...Five minute break."'),
 "REACT_URBAN_BOOK": (
  '(Tolga sayfayı gösterir.) "Büyük top çatladı." Urban: "Kitabı yazan topçu mu? Değil. O zaman sussun."',
  '(Tolga shows the page.) "The great cannon cracked." Urban: "Was the author a gunner? No? Then he can keep quiet."'),
 "REACT_FATIH_COLOGNE": (
  '(Elini uzatır.) "Limon. Güzel bir âdet. Sizin zamanınızda herkes bunu mu yapıyor?" Tolga: "Bayramlarda."',
  '(Holds out his hands.) "Lemon. A pleasant custom. Is this done by everyone in your time?" Tolga: "On holidays."'),
 "REACT_NIKO_SELFIE": (
  '(Niko poz verir, tavuk Sinerji de kadraja girer.) "Tavuğu da çek. Tavuk Bizanslı."',
  '(Niko strikes a pose; Sinerji the chicken wanders in.) "Get the chicken in. The chicken is Byzantine."'),
 "REACT_EMPEROR_BOOK": (
  '(Kitabı kapatır ve tek kelime etmeden geri verir.) Tolga: "...Özür dilerim."',
  '(He closes the book and hands it back without a word.) Tolga: "...I\'m sorry."'),
 "REACT_EMPEROR_COLOGNE": (
  '(Konstantinos elini uzatmaz. Niko elini uzatır.) Niko: "İmparator elini vermez. Ben veririm."',
  '(The Emperor does not offer his hand. Niko offers his.) Niko: "The Emperor doesn\'t do hands. I do."'),
 "REACT_GIUST_BOOK": (
  '(Tolga 29 Mayıs sayfasını gösterir.) Giustiniani: "Adım yazıyor mu? ...Yazıyor mu?"',
  '(Tolga shows the page for 29 May.) Giustiniani: "Is my name in there? ...Is it?"'),
 # Yere düşme: Nihat "siz" diye hitap eder; "evlât" Hikmet'in ağzı.
 "D_DOWNED_N_1": (
  "(Telsiz) Kalkın Tolga Bey! Tarih sizi bekliyor, ben de mesaimi bitireyim.",
  cur["D_DOWNED_N_1"][1]),
 "D_DOWNED_N_2": (
  "(Telsiz) Yerde yatmak yönetmelikte yok, Tolga Bey.",
  "(Radio) Lying on the floor isn't in the regulations, Mr Tolga."),
})
order = [r[0] for r in rows[1:] if r and r[0] in new]
with open(OUT, "w", encoding="utf-8", newline="\n") as f:
    for k in order:
        tr, en = new[k]
        q = lambda s: '"' + s.replace('"', '""') + '"'
        f.write(f"{k},{q(tr)},{q(en)}\n")
print("rows", len(order), "missing", set(new) - set(order))
