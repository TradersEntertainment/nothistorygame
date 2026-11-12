PARCA 3: SORUNLU (2 koşu)

# Parça 3/10 özeti (Godot 4.4.1, MAXFPS=20)

- Toplam süre: ~2160 sn (36 dk). Son satır: `SHARD 3/10 BITTI fail=1`. run_tests.sh çıkış kodu: 1.
- Koşu sayısı: beklenen 41 (`LIST=1`), `AUTOTEST PASS` ile eşleşen 41. Eksik PASS yok, FAIL/TIMEOUT/SCRIPT ERROR/Parse Error yok.
  (Ham çıktıda toplam 52 `AUTOTEST PASS` satırı var; fazlası arena/ladder/traversal vb. ek denetimlerden.)
- `fail=1` nedeni: yasak sayılan `VISAUDIT` satırları (aşağıdaki iki koşu).

## Sorunlu koşular

| Koşu | İlk sonuç | Tekrar 1 | Tekrar 2 | Tekrar 3 | Hüküm |
|---|---|---|---|---|---|
| `--chapter=44b --autotest=kid` | PASS + `VISAUDIT overlap scene=chapter44b.tscn a=Chapter44b(SPK_KID) b=Chapter44b(SPK_YAKOVOS) at=(-9.2, 0.0, -51.6)` | aynı VISAUDIT, PASS | aynı VISAUDIT, PASS | aynı VISAUDIT, PASS | KALICI (3/3) |
| `--chapter=26 --autotest=hold_box` | PASS + `VISAUDIT overlap scene=chapter26.tscn a=Garrison b=Garrison at=(11.6, 8.0, 14.7)` | temiz PASS | temiz PASS | temiz PASS | TEK SEFERLİK (0/3) |

Not: chapter 26 satırının hangi koşuya ait olduğu ham çıktının sırasından (hold_box PASS satırından hemen önce) çıkarıldı; `council_bad` değil `hold_box` yeniden koşuldu. Kök neden aranmadı, kod değiştirilmedi.

## Ön denetim / python satırları
PARSECHECK PASS scripts=251; INLINECHECK PASS (725 anahtar, 0 sorun); VOICERULES PASS (9786 anahtar, 0 sorun); EXPORTREFS PASS; VOICEGAIN: 0 eksik; SPEAKERCHECK çıktı yok (PASS); bayrak sorun: 0; kuşatma sonucu okunmayan: 0; JOURNEY ok: 68 kart, JOURNEY_MISS/OVERLAP yok.
Diğer: FXCHECK, CAMCHECK, PORTRAITCHECK, PLAYTESTCHECK, SMOOTHCHECK, UIFIT, PLAYCHECK, ACHCHECK, ROUTECHECK, SNAPCHECK, WORLDCHECK, FLIGHTCHECK, WALKCHECK, MAPCHECK, QUIPCHECK, CREATORCHECK PASS.
Yasak olmayan ama kayda geçen: `WARN_PORTRAIT_STUDIO` x4 (SPK_KADRI D12_K_01/D12_K_03 chapter12; SPK_SOLDIER D28O_S_BALL chapter28o; SPK_LOOKOUT D20_L_WARN_1 arena); `MAPCHECK su uyuşmuyor: piksel (633, 1433)` bilgi satırı (MAPCHECK PASS). WALKTHRU/HELDAUDIT/ARMAUDIT yok.

Yeniden koşu çıktıları ham halde: bu özetle birlikte `docs/_test119/tekrar_3.txt`.
