PARCA 1: SORUNLU (1 koşu)

# Parça 1/10 özeti

- Godot 4.4.1 stable (linux x86_64), `--import` bir kez koşuldu.
- Komut: `SHARD=1 SHARDS=10 MAXFPS=20 bash tests/run_tests.sh`
- Koşu sayısı: beklenen 42 / PASS 42 (liste ile tek tek eşleşti; üç `next` zinciri koşusu 6a, 11, 14 PASS satırı verdi; 44b → `chapter=44 variant=blab`). Çıktıda ayrıca arena (9), ladder, traversal PASS satırları var (koşu listesi dışı ek denetimler, hepsi PASS). Toplam AUTOTEST PASS satırı: 53.
- AUTOTEST FAIL / TIMEOUT / SCRIPT ERROR / Parse Error: 0
- Toplam süre (import dahil, koşu+yeniden koşular öncesi): 2303 sn (yaklaşık, süreler ölçüm anına kadar). Çıkış kodu: 0. Son satır: `SHARD 1/10 BITTI fail=0`

## Sorunlu koşular

| Komut | İlk sonuç | 3 yeniden koşu | İlgili satır |
|---|---|---|---|
| `--chapter=28o --autotest=lose` | AUTOTEST PASS ama yasak satır WARN_ | 3/3 aynı WARN_ (kalıcı), 3/3 PASS | `WARN_PORTRAIT_STUDIO speaker=SPK_SOLDIER key=D28O_S_BALL scene=chapter28o.tscn` |

Kök neden aranmadı, kod değiştirilmedi.

## Python / ön denetim satırları
- PARSECHECK PASS scripts=251
- EXPORTREFS PASS
- INLINECHECK PASS (725 anahtar, 0 sorun)
- VOICERULES PASS (9786 anahtar, 0 sorun)
- VOICEGAIN: 0 seslendirilmiş replik seviye tablosunda yok
- SPEAKERCHECK, VISAUDIT, WALKTHRU, HELDAUDIT, ARMAUDIT, JOURNEY_: bu parçada çıktıda satır yok
- `PEOPLE PF_GIUST ...` satırı bilgi amaçlı (WARN değil)

Not: Godot yan dosyaları (.import/.uid/.translation) kayda eklenmedi.
