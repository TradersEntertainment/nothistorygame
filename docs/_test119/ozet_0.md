PARCA 0: SORUNLU (10 koşu/denetim)

# Parça 0/10 özeti (Godot 4.4.1 resmi, headless, MAXFPS=20)

- Beklenen koşu: 41 (`LIST=1` listesi). Hepsi çalıştı; listedeki her koşunun karşılığı `AUTOTEST PASS` satırı var (44b→"chapter=44", 4/12/13 `next|gidak` →5/17/16 etiketleriyle). Eksik koşu yok. Çıktıda toplam 52 `AUTOTEST PASS` satırı (ek: ladder, 9 arena, traversal, zincirli bölümler).
- `AUTOTEST FAIL`, `AUTOTEST TIMEOUT`, `SCRIPT ERROR`, `Parse Error`: 0.
- Toplam süre: 3161 sn (~52,7 dk), yalnız ana koşu.
- Son satır: `SHARD 0/10 BITTI fail=...` YOK (K=0 betik sonu denetimlerini koşup `exit $fail` ile çıkar). Çıkış kodu: **1**. Nedeni ZFIGHT denetimi (betikte `fail=1`).

## Sorunlu koşular (3 yeniden koşu: 3/3 = kalıcı)
| Koşu / komut | İlk sonuç | Yeniden koşu 1/2/3 | İlgili satır |
|---|---|---|---|
| `--chapter=28o --autotest` | PASS ama `WARN_` | 3/3 aynı uyarı | `WARN_PORTRAIT_STUDIO speaker=SPK_SOLDIER key=D28O_S_BALL scene=chapter28o.tscn` |
| `arena.tscn -- --autotest=mods` | PASS ama `WARN_` | 3/3 aynı uyarı (PASS) | `WARN_PORTRAIT_STUDIO speaker=SPK_LOOKOUT key=D20_L_WARN_1 scene=arena.tscn` |
| zfight chapter3.tscn | 4 ZFIGHT satırı, fail=1 | 3/3 aynı 4 satır | axis=2 face=-13/-24, axis=1 face=0.01, axis=0 face=-11 |
| zfight chapter14.tscn | 4 satır | 3/3 aynı | aynı 4 satır |
| zfight chapter17.tscn | 4 satır | 3/3 aynı | aynı 4 satır |
| zfight chapter22o.tscn | 1 satır | 3/3 aynı | axis=1 face=0.45 area=0.63 |
| zfight chapter43o.tscn | 1 satır | 3/3 aynı | axis=1 face=0.02 area=5.04 |
| zfight chapter44b.tscn | 1 satır | 3/3 aynı | axis=1 face=0.04 area=2.34 |
| zfight chapter8y.tscn | 1 satır | 3/3 aynı | axis=1 face=0.02 area=0.76 |

Yeniden koşu komutları: bölüm/arena için `timeout 300 godot --headless --max-fps 20 --path . [res://scenes/arena.tscn] -- <argümanlar>`; ZFIGHT için betiğin kendi komutu `godot --headless --path . -s tests/zfight_check.gd -- res://scenes/<sahne>.tscn`. Ham çıktı: `yeniden_0.txt`. Kök neden aranmadı, kod değiştirilmedi.

## Ön/python denetim satırları (hepsi geçti)
PARSECHECK PASS scripts=251; bayrak denetimi sorun 0; INLINECHECK PASS (725 anahtar, 0 sorun); VOICERULES PASS (9786 anahtar, 0 sorun); EXPORTREFS PASS; kuşatma sonucu okunmayan 0; JOURNEY ok 68 kart; VOICEGAIN: 0 eksik. SPEAKERCHECK satırı çıktıda yok (betik yazmıyor).

## Diğer denetimler
FXCHECK, CAMCHECK, PORTRAITCHECK, PLAYTESTCHECK, SMOOTHCHECK, UIFIT, PLAYCHECK, ACHCHECK, ROUTECHECK, SNAPCHECK, WORLDCHECK, FLIGHTCHECK, MAPCHECK, QUIPCHECK, CREATORCHECK, CITYCHECK, STREETCHECK, FOCUSCHECK, WALKCHECK: PASS. MENURETURN PASS (26, 20o; orphans=0). Bilgi notları: `MAPCHECK su uyuşmuyor` tek piksel satırı (genel sonuç PASS), `WALKCHECK galata ... aşağıda=1` (genel PASS). VISAUDIT/HELDAUDIT/ARMAUDIT/WALKTHRU satırı çıktıda yok.
