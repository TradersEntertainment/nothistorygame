# Yerel Claude için: 1977 düğünü (müzik + ses)

Bu dosyayı yerel Claude Code'a şöyle ver:

> `git pull` yap, sonra `docs/voice/LOCAL_WEDDING.md` dosyasını oku ve adımları sırayla uygula.

`docs/voice/LOCAL_CLAUDE.md` içindeki **Kurallar** burada da geçerli (anahtar yalnız `ELEVENLABS_API_KEY` ortam
değişkeninde; dosyaya, commit'e, log'a yazılmaz; sesleri ve müziği kullanıcı seçer).

## 1. Müzik (iki yeni parça)
```
python3 tools/music_gen.py check
python3 tools/music_gen.py gen halay_1977 wedding_1977 --takes 3
python3 tools/music_gen.py review
```
`docs/music/review.html` sayfasını aç, kullanıcı her parça için bir deneme seçsin:
```
python3 tools/music_gen.py pick halay_1977 N
python3 tools/music_gen.py pick wedding_1977 N
```
- `halay_1977`: düğün açılırken çalan davul-zurna halayı.
- `wedding_1977`: "o düğünün şarkısı". Genç Hikmet ayağa kalkınca klarnetle başlar. Bölüm 15'teki Pijamalı
  Kurtarma finalinde radyoda da aynı şarkı çalar, yani kırk dokuz yıllık bir hatıra gibi duyulmalı.

Parçalar yokken oyun eskilerine düşer (`camp_day`, `tender`), yani bu adım atlanırsa oyun bozulmaz.

## 2. Ses (5 replik)
```
python3 tools/voice_gen.py fix --list docs/voice/REGEN_WEDDING.txt
python3 tools/voice_gen.py review --chapter 13
```
Genç Hikmet (`D13_H_1977_4`, `D13_H_1977_6`) aynı SPK_HIKMET sesiyle ama genç, utangaç okunmalı; beğenilmezse
`redo ANAHTAR --tone "[shy] [young]"`. `D13_H_1977_6` halayın başından bağırarak ve gülerek.

## 3. Commit
`assets/audio/music/halay_1977.mp3`, `assets/audio/music/wedding_1977.mp3`, `assets/audio/voice/`,
`docs/voice/VOICE_MAP.csv` dosyalarını commit'le (mesaj Türkçe) ve push'la.
