PARCA 7: SORUNLU (1 koşu)

# Parça 7/10 özeti (Godot 4.4.1 resmi linux x86_64)

- Komut: `SHARD=7 SHARDS=10 MAXFPS=20 GODOT=$HOME/is/godot/godot bash tests/run_tests.sh`
- Toplam süre: 2091 sn (~35 dk); bunun dışında `--import` ~4 dk.
- Son satır: `SHARD 7/10 BITTI fail=1` — betik çıkış kodu 1.
- Koşu sayısı: beklenen 41 (LIST çıktısı) / çıktıda hepsi için AUTOTEST PASS satırı var (41/41; eksik yok). Ayrıca ladder/arena/traversal vb. ek PASS satırları var; çıktıda toplam 52 `AUTOTEST PASS`. FAIL/TIMEOUT/SCRIPT ERROR/Parse Error/VISAUDIT/WALKTHRU/HELDAUDIT yok.

## Sorunlu koşular

| Koşu | İlk sonuç | Yeniden koşu 1 / 2 / 3 | Sınıf |
|---|---|---|---|
| `--chapter=26 --autotest=hold_lose` | PASS satırı var ama `ARMAUDIT unarmed scene=chapter26.tscn foe_dist=2.0 duel_active=false` satırı çıktı (betik bunu fail=1 sayar; fail=1'in tek nedeni bu) | PASS, ARMAUDIT yok / PASS, yok / PASS, yok (gunner=0/3, 0/3, 0/1; ilk koşuda 0/1) | tek seferlik (0/3) |

Not (hata sayılmayan, bilgi): `WARN_FREE_NO_OBJECTIVE scene=chapter18.tscn` (`--chapter=18 --autotest=near`) ilk koşuda ve 3 yeniden koşunun 3'ünde de çıktı (kalıcı). Betik bu satırı fail saymıyor; PASS ile bitiyor. Ayrıca `MAPCHECK su uyuşmuyor: piksel (633, 1433)...` bilgi satırı var, MAPCHECK PASS.

## Python / ön denetim satırları
PARSECHECK PASS scripts=251; bayrak sorun 0; INLINECHECK PASS (725 anahtar, 0 sorun); VOICERULES PASS (9786 anahtar, 0 sorun); EXPORTREFS PASS; kuşatma sonucu 76/76; JOURNEY ok 68 kart; VOICEGAIN 0 eksik. Diğer: FXCHECK, CAMCHECK, PORTRAITCHECK, PLAYTESTCHECK, SMOOTHCHECK, UIFIT, PLAYCHECK, ACHCHECK, ROUTECHECK, SNAPCHECK, WORLDCHECK, FLIGHTCHECK, WALKCHECK, MAPCHECK, QUIPCHECK, CREATORCHECK, CITYCHECK, STREETCHECK, FOCUSCHECK hepsi PASS.

Yeniden koşu ham çıktıları: ch26 üç koşu temiz; ch18 üç koşu aynı WARN_FREE_NO_OBJECTIVE + PASS. Kök neden aranmadı, kod değiştirilmedi.
