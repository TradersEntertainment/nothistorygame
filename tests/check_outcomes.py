#!/usr/bin/env python3
"""Kuşatma sonuçlarının izi (docs/BRANCHING_V3.md): her kuşatma sonucu kendi bölümünün dışında bir yerde okunuyor mu.
   İyi iş de kötü iş de sonraki bir sayfada hatırlanmalı; okunmayan sonuç "ne yapsan aynı" demektir.
   Okunma yolları:
     - sonuç kimliği başka bir betikte geçer ("34O.2", 15'in finalleri, siege.gd'nin dünya seçimi)
     - başka bir betik o bölümün sonucunu sorar (chapter_outcomes.get(34, ...) ya da Siege.outcome(34))
     - bölüm bir bayrak kurar ve bayrak başka bir betikte okunur (bölüm düzeyinde sayılır)
   python3 tests/check_outcomes.py        (özet; izin listesi dışında okunmayan sonuç varsa çıkış kodu 1)
   python3 tests/check_outcomes.py -v     (her sonucun okunduğu yerler)"""
import glob, os, re, sys

# Bilerek sonraya taşınmayan sonuçlar ve nedeni. Buraya eklemeden önce sonuca bir iz bağlamayı dene.
ALLOW = {
    "26.3": "Şafak: şehir düşmedi. Siege.resolve(true) siege_held'i kurar; rota ve dünya ondan okunur",
    # Dallanma v3 §2.5: bayrakları sonraki sayfalarda okunuyor (met_isidore, siege_candle, petrion_word, emperor_answer);
    # sonuçları Bölüm 14'te sicile sayılır (Siege.sicil: her sayfa iyi ya da kötü iş)
    "25.2": "Son Akşam: met_isidore ve siege_candle 26'da ve Bölüm 15'te okunur; sonuç sicile sayılır",
    "38O.1": "Haliç surları: petrion_word 39o'da okunur; sonuç sicile sayılır",
    "38O.2": "Haliç surları: petrion_word 39o'da okunur; sonuç sicile sayılır",
    "39O.1": "Emanet: emperor_answer 31o'da okunur; sonuç sicile sayılır",
    "39O.2": "Emanet: emperor_answer 31o'da okunur; sonuç sicile sayılır",
}

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(ROOT)
SRC = sorted(glob.glob('scripts/**/*.gd', recursive=True))
TEXT = {p: open(p, encoding='utf-8').read() for p in SRC}
siege = TEXT['scripts/siege.gd']
ORDER = [int(x) for x in re.search(r'const ORDER := \[([^\]]*)\]', siege).group(1).split(',')]

# Kuşatma bölümlerinin betikleri (chapter17.gd, chapter17o.gd, chapter18b.gd ...)
chapters = {}
for p in SRC:
    m = re.match(r'scripts/chapter(\d+)([a-z]?)\.gd$', p)
    if m and int(m.group(1)) in ORDER:
        chapters[p] = int(m.group(1))

OUT_ID = re.compile(r'"(\d+[A-Za-z]?\.\d+)"')


def outcomes_of(p):
    """Bölümün kurduğu sonuçlar: _outcome atamalarındaki kimlikler (otomatik testin beklenen tablosu sayılmaz)."""
    out = set()
    for ln in TEXT[p].split('\n'):
        if re.search(r'\b_outcome\s*=(?!=)', ln):
            out.update(OUT_ID.findall(ln))
    return out


def flags_set(p):
    return set(re.findall(r'GameState\.flags\[\s*"([a-z0-9_]+)"\s*\]\s*=(?!=)', TEXT[p]))


def flag_readers(flag, skip):
    pat = re.compile(r'flags(?:\.get\(\s*|\.has\(\s*|\[\s*)"%s"(?!\s*\]\s*=(?!=))' % re.escape(flag))
    return [q for q in SRC if q != skip and pat.search(TEXT[q])]


def asks_chapter(q, ch):
    t = TEXT[q]
    if re.search(r'Siege\.outcome\(\s*%d\s*\)' % ch, t):
        return True
    if 'chapter_outcomes' in t and re.search(r'(?:chapter_outcomes|\bo\d?|\bco)\.get\(\s*%d\s*[,)]' % ch, t):
        return True
    return bool(re.search(r'chapter_outcomes\[\s*%d\s*\]' % ch, t))


IGNORE_READERS = ('scripts/ui/flowchart.gd', 'scripts/ui/final_review.gd', 'scripts/autoload/game_state.gd')
rows = []
for p, ch in sorted(chapters.items(), key=lambda kv: (ORDER.index(kv[1]), kv[0])):
    outs = sorted(outcomes_of(p))
    if not outs:
        continue
    others = [q for q in SRC if q != p and q not in IGNORE_READERS and not q.startswith('tests/')]
    by_chapter = [q for q in others if asks_chapter(q, ch)]
    fl = {}
    for f in sorted(flags_set(p)):
        rd = flag_readers(f, p)
        if rd:
            fl[f] = rd
    for o in outs:
        lit = [q for q in others if '"%s"' % o in TEXT[q]]
        rows.append((p, ch, o, lit, by_chapter, fl))

bad = 0
dead_ch = set()
for p, ch, o, lit, byc, fl in rows:
    used = bool(lit or byc)
    name = os.path.basename(p)
    if not used and not fl:
        dead_ch.add(name)
    if not used and o not in ALLOW:
        bad += 1
        print('OKUNMAYAN_SONUC %-8s %-16s%s' % (o, name, '  (bölümün bayrakları okunuyor: %s)' % ', '.join(fl) if fl else ''))
    elif '-v' in sys.argv:
        where = sorted({os.path.basename(q) for q in lit + byc})
        print('ok %-8s %-16s ← %s' % (o, name, ', '.join(where) or 'bayrak: ' + ', '.join(fl)))
total = len(rows)
print('kuşatma sonucu: %d  okunan: %d  okunmayan: %d  izinli: %d  hiç iz bırakmayan bölüm: %d (%s)' % (
    total, total - bad - sum(1 for r in rows if r[2] in ALLOW and not (r[3] or r[4])), bad,
    len(ALLOW), len(dead_ch), ', '.join(sorted(dead_ch))))
sys.exit(1 if bad else 0)
