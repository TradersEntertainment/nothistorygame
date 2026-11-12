PARCA 9: SORUNLU (1 koşu)

# Test paketi — parça 9/10 özeti

- Godot 4.4.1 stable (linux x86_64), `--import` çıkış kodu 0.
- Komut: `SHARD=9 SHARDS=10 MAXFPS=20 GODOT=$HOME/is/godot/godot bash tests/run_tests.sh`
- Çıkış kodu: 0 — son satır: `SHARD 9/10 BITTI fail=0`
- Toplam süre: ~2071 sn (~34,5 dk, import hariç)
- Koşu sayısı: beklenen 41 (`LIST=1`), her biri için çıktıda eşleşen PASS/geçiş satırı var, eksik yok.
  Toplam `AUTOTEST PASS` satırı: 52 (41 koşunun dışındaki PASS satırları: ladder, 9 arena, traversal ve zincirleme bölüm geçişleri; `3 next`, `11 next`, `13 wrong_next` koşuları ara `AUTOTEST chapter=X -> Y` satırları ve zincirin sonundaki PASS ile geçti).
- AUTOTEST FAIL 0, TIMEOUT 0, SCRIPT ERROR 0, Parse Error 0, VISAUDIT/WALKTHRU/HELDAUDIT/ARMAUDIT/JOURNEY_ (hata satırı) 0.

## Sorunlu koşular

| Koşu | İlk sonuç | 3 yeniden koşu | Sınıf |
|---|---|---|---|
| `--chapter=39o --autotest=late` | PASS, ama `WARN_PORTRAIT_STUDIO speaker=SPK_SAILOR key=D39O_SA_FLAG scene=chapter39o.tscn` satırı çıktı | 3/3 aynı WARN satırı + PASS (`timeout 300 godot --headless --max-fps 20 --path . -- --chapter=39o --autotest=late`) | Kalıcı (WARN) |

Notlar: `tests/run_tests.sh` bu WARN'ı başarısızlık saymıyor (yalnız WARN_FX_STUCK, WARN_FLY_ITEM, WARN_VOID_TELEPORT vb. `fail=1` yapıyor); koşu PASS. Görev tanımında `WARN_` yasak satır listesinde olduğu için sorunlu sayıldı. Kök neden aranmadı, kod değiştirilmedi.

## Python / ön denetim satırları

- PARSECHECK PASS scripts=251
- INLINECHECK PASS (725 anahtar, 0 sorun)
- VOICERULES PASS (9786 anahtar, 0 sorun)
- EXPORTREFS PASS
- VOICEGAIN: 0 seslendirilmiş replik seviye tablosunda yok
- JOURNEY ok: 68 kart (4 rota, overlap=0)
- FXCHECK, CAMCHECK, PORTRAITCHECK (speakers=140), WALKCHECK, MAPCHECK, QUIPCHECK, CREATORCHECK, CITYCHECK, STREETCHECK, FOCUSCHECK: hepsi PASS.
  (MAPCHECK'te bilgi satırı: `su uyuşmuyor: piksel (633, 1433)`; uyum %100,0, sonuç PASS.)

Ham çıktı: `docs/_test119/parca_9.txt`
