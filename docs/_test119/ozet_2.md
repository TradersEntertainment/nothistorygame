PARCA 2: SORUNLU (2 koşu)

# Parça 2/10 özeti

- Godot 4.4.1.stable.official.49a5bc7b6, `--import` çıkış kodu 0.
- Koşu: `SHARD=2 SHARDS=10 MAXFPS=20 bash tests/run_tests.sh`; süre ≈ 1965 sn (~33 dk); çıkış kodu 0.
- Son satır: `SHARD 2/10 BITTI fail=0`
- Beklenen koşu: 42 (LIST=1). Her koşu için en az bir `AUTOTEST PASS` satırı var (eksik yok). Toplam 53 `AUTOTEST PASS` satırı (arena/ladder/traversal gibi ek satırlar dahil).
- FAIL / TIMEOUT / SCRIPT ERROR / Parse Error: yok.
- Yasak satır: `WARN_PORTRAIT_STUDIO` (aşağıda). Betik bunu fail saymadı (fail=0) ama talimata göre sorunlu.

## Sorunlu koşular

| Koşu | İlk sonuç | Yeniden koşu 1/2/3 | İlgili satırlar | Sınıf |
|---|---|---|---|---|
| `--chapter=12 --autotest=kitchen` | PASS + 2 WARN | hepsinde aynı (PASS + 2 WARN) | `WARN_PORTRAIT_STUDIO speaker=SPK_KADRI key=D12_K_01 scene=chapter12.tscn`; `... key=D12_K_03 ...` | kalıcı (3/3) |
| `--chapter=28o --autotest=edirne` | PASS + 1 WARN | hepsinde aynı (PASS + 1 WARN) | `WARN_PORTRAIT_STUDIO speaker=SPK_SOLDIER key=D28O_S_BALL scene=chapter28o.tscn` | kalıcı (3/3) |

Kök neden aranmadı, kod değiştirilmedi.

## Python / ön denetim satırları
- PARSECHECK PASS scripts=251
- INLINECHECK PASS (725 anahtar, 0 sorun)
- VOICERULES PASS (9786 anahtar, 0 sorun)
- EXPORTREFS PASS
- VOICEGAIN: 0 seslendirilmiş replik seviye tablosunda yok
- bayrak denetimi sorun: 0; kuşatma sonucu 76/76 okunan, iz bırakmayan bölüm 0
- JOURNEY ok: 68 kart; 5 JOURNEY yolu (overlap=0)
- WALKCHECK PASS, MAPCHECK PASS, QUIPCHECK PASS, CREATORCHECK PASS, CITYCHECK PASS, STREETCHECK PASS, FOCUSCHECK PASS
- Not: `MAPCHECK su uyuşmuyor: piksel (633, 1433) dünya (700, -0) doku=kara dünya=su` satırı var; ardından `su/kara uyumu 100.0%` ve `MAPCHECK PASS`.
- VISAUDIT / HELDAUDIT / ARMAUDIT / SPEAKERCHECK satırı bu parçada çıkmadı.
