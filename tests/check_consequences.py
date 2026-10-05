#!/usr/bin/env python3
"""Yazılan her hikâye bayrağı bir yerde okunuyor mu (docs/BRANCHING_V2.md §6, M4).
   Bir seçim ya da eylem bayrağa yazılıp hiçbir yerde okunmuyorsa oyuncunun yaptığı şeyin sonucu yok demektir.
   python3 tests/check_consequences.py        (çıkış kodu: izin listesinde olmayan okunmayan bayrak varsa 1)
   python3 tests/check_consequences.py -v     (her bayrağın yazıldığı ve okunduğu yerler)"""
import glob, os, re, sys

# Bilerek yalnız yazılan bayraklar: başka bir düzenek (görev listesi, karne, test) onları kendi yolundan okur
# ya da bölüm içinde tek seferlik bir kilit. Buraya ekleme yapmadan önce bayrağa bir sonuç bağlamayı dene.
ALLOW = {
    # Bölüm sonucunun kopyası: sonraki bölümler sonucu (chapter_outcomes) okur
    "backup_remote": "5.2: makineye el konulduysa yedek Telsiz-Kumanda bulunur",
    "machine_hidden": "5.1: parçalar bodrum kapağına saklandı",
    "ch2_sneaked": "2.2",
    "fell_quay": "4b.3",
    "depot_plan": "8.3",
    "ch8_reason": "8.2 (başarısızlığın nedeni yalnız akış şemasında)",
    "route_ch12": "10O.2",
    "hn_rel_locked": "11.5",
    "ch23_deviation": "23.2 (sapma > 0)",
    "final": "15'in sonucu (set_outcome(15, final))",
    # Başka bir göstergenin kopyası: o gösterge okunur
    "ch2_radio_answered": "telsiz_bag",
    "ch7_delayed": "sadakat (Nihat'ın kural sadakati)",
    "ch7_report": "sadakat ve 7.x",
    "ch8_called": "hn_rel (Hikmet ↔ Nihat)",
    "ch10h_truth": "byz_letter (doğruluk ≥ 1 → İmparator'un mektubu)",
    "ch10b_risk": "10B.3 (Büyük Patlama) ve big_bang",
    "guards_fez": "given_to(spare_fez) ve guards_like_tolga",
    "niko_friend_6b": "niko_friend",
    "dawn_warned": "26'da hemen uygulanır: dinlenen uyarı 26.3, siege_held ve world10",
    # İstatistik ya da tek seferlik kilit
    "ch2_route": "2'nin akış şeması istatistiği",
    "ch2_stumbles": "2'nin akış şeması istatistiği",
    "ch10_tries": "10'un istatistiği (yanlış cevap)",
    "labyrinth_mistakes": "6b'nin istatistiği (labirent)",
    "ch12_idk": "merak +1 bir kez (replik kilidi)",
    # Oyunun son kararı: sonrası yok
    "act4_answer": "15'te müdürün sorusuna cevap; ondan sonra oynanan sahne yok",
}

SRC = sorted(glob.glob('scripts/**/*.gd', recursive=True))
KEY = r'"([A-Za-z][A-Za-z0-9_]*)"'
ASSIGN = r'\s*(?:=(?!=)|\+=|-=|\*=)'


def aliases(text):
    """GameState.flags'e verilen kısa adlar (var f := GameState.flags)."""
    out = {'flags'}
    for m in re.finditer(r'var\s+(\w+)\s*(?::\s*Dictionary\s*)?:?=\s*GameState\.flags[ \t]*(?:#.*)?$', text, re.M):
        out.add(m.group(1))
    return out


writes, reads, tables, LINES = {}, {}, {}, {}
for p in SRC:
    lines = open(p, encoding='utf-8').read().split('\n')
    LINES[p] = lines
    al = '|'.join(sorted(aliases('\n'.join(lines))))
    w_pat = re.compile(r'\b(?:%s)\[\s*%s\s*\]%s' % (al, KEY, ASSIGN))
    r_pat = re.compile(r'\b(?:%s)(?:\.(?:get|has)\(\s*%s|\[\s*%s\s*\](?!%s))' % (al, KEY, KEY, ASSIGN))
    for i, ln in enumerate(lines):
        code = ln.split('#', 1)[0] if not ln.lstrip().startswith('##') else ''
        for m in w_pat.finditer(code):
            writes.setdefault(m.group(1), []).append((p, i + 1))
        for m in r_pat.finditer(code):
            k = m.group(1) or m.group(2)
            reads.setdefault(k, []).append((p, i + 1))
        # Veri tabloları: {"flag": "x"} ya da "flags": ["x", "y"] (görevler, karne, final rotaları)
        if re.search(r'"flags?"\s*:', code):
            for m in re.finditer(KEY, code):
                tables.setdefault(m.group(1), []).append((p, i + 1))


GUARD = re.compile(r'^\s*(?:el)?if\s+not\b')


def real_reads(k):
    """Kendi yazımıyla aynı satırdaki okuma (sayaç artırma) ve yazımın hemen üstündeki "if not" kilidi
       (bir kez söylensin) sonuç sayılmaz."""
    same = set(writes.get(k, []))
    guard = {(p, n - d) for p, n in writes.get(k, []) for d in (1, 2)}
    out = []
    for p, n in reads.get(k, []):
        if (p, n) in same:
            continue
        if (p, n) in guard and GUARD.match(LINES[p][n - 1]):
            continue
        out.append((p, n))
    return out + tables.get(k, [])


verbose = '-v' in sys.argv
dead, local = [], []
for k in sorted(writes):
    rr = real_reads(k)
    files_w = {p for p, _ in writes[k]}
    if not rr:
        dead.append(k)
    elif all(p in files_w for p, _ in rr):
        local.append(k)
    if verbose:
        print(k, 'YAZ', ' '.join('%s:%d' % (os.path.basename(p), n) for p, n in writes[k]),
              '| OKU', ' '.join('%s:%d' % (os.path.basename(p), n) for p, n in rr) or '-')
bad = [k for k in dead if k not in ALLOW]
for k in bad:
    p, n = writes[k][0]
    print('OKUNMUYOR %s %s:%d' % (k, p, n))
for k in sorted(ALLOW):
    if k not in writes:
        print('IZIN_FAZLA %s (artık yazılmıyor, izin listesinden çıkar)' % k)
        bad.append(k)
    elif k not in dead:
        print('IZIN_FAZLA %s (artık okunuyor, izin listesinden çıkar)' % k)
        bad.append(k)
print('bayrak:', len(writes), 'yalnız kendi bölümünde okunan:', len(local), 'okunmayan:', len(dead),
      'izinli:', len([k for k in dead if k in ALLOW]), 'sorun:', len(bad))
sys.exit(1 if bad else 0)
