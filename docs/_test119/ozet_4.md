PARCA 4: TEMIZ

# Parça 4/10 özeti

- Godot 4.4.1.stable.official (linux x86_64), `~/is/godot/godot`; `--import` bir kez koşuldu (çıkış 0).
- Komut: `SHARD=4 SHARDS=10 MAXFPS=20 GODOT=$HOME/is/godot/godot bash tests/run_tests.sh`
- Koşu sayısı: beklenen 41 (`LIST=1` çıktısı), 41'inin karşılığında `AUTOTEST PASS` satırı var, eksik yok. (Çıktıda toplam 52 `AUTOTEST PASS` satırı var; fazlası ladder, arena x9, traversal gibi ek denetimlerden.)
  Eşleme notu: `--chapter=17 --autotest=osm` -> `chapter=33o`, `36b` -> `chapter=36`, `44b` -> `chapter=44`, `--chapter=8 --autotest=next` -> `chapter=9 variant=` (9.1), `--chapter=10g --autotest=next` -> `chapter=17 variant=` (17.1).
- Sayımlar: AUTOTEST FAIL 0, TIMEOUT 0, SCRIPT ERROR 0, Parse Error 0, WARN_ 0, VISAUDIT 0, WALKTHRU 0, HELDAUDIT 0, ARMAUDIT 0.
- Sorunlu koşu: yok (yeniden koşu gerekmedi).

| Koşu | İlk sonuç | 3 yeniden koşu |
|---|---|---|
| (yok) | - | - |

## Python / ön denetim satırları
PARSECHECK PASS scripts=251; bayrak sorun: 0; INLINECHECK PASS (725 anahtar, 0 sorun); VOICERULES PASS (9786 anahtar, 0 sorun); EXPORTREFS PASS; VOICEGAIN: 0 seviye tablosunda olmayan replik; JOURNEY ok 68 kart (3 final rotası); FXCHECK, CAMCHECK, PORTRAITCHECK, PLAYTESTCHECK, SMOOTHCHECK, UIFIT, PLAYCHECK, ACHCHECK, ROUTECHECK, SNAPCHECK, WORLDCHECK, FLIGHTCHECK, WALKCHECK, MAPCHECK, QUIPCHECK, CREATORCHECK hepsi PASS. SPEAKERCHECK satırı bu parçanın çıktısında yok. (Bilgi: WALKCHECK galata `aşağıda=1`, MAPCHECK tek "su uyuşmuyor" bilgi satırı; ikisi de PASS ile bitti.)

## Süre ve bitiş
- Toplam süre: 2052 sn (~34 dk), ikinci koşu. İlk koşu konteyner yeniden başlatması yüzünden yarıda kesildi (çıktısı kaydedilmedi); parça baştan koşuldu.
- Son satır: `SHARD 4/10 BITTI fail=0`; çıkış kodu 0.
- Not: Godot'nun ürettiği `.import` yan dosyaları kayda eklenmedi.
