PARCA 5: SORUNLU (1 koşu)

# Parça 5/10 özeti

- Koşu sayısı: beklenen 41 (LIST çıktısı) / her biri için `AUTOTEST PASS` satırı bulundu (41/41; çıktıda toplam 52 PASS satırı var, fazlası arena/ladder/traversal/journey alt denetimleri). Eksik PASS yok.
- AUTOTEST FAIL: 0, AUTOTEST TIMEOUT: 0, SCRIPT ERROR: 0, Parse Error: 0.
- Toplam süre: 1992 sn (~33 dk). Son satır: `SHARD 5/10 BITTI fail=0`. Betik çıkış kodu: 0.

## Sorunlu koşular

| Komut | İlk sonuç | 3 yeniden koşu | İlgili satırlar | Sınıf |
|---|---|---|---|---|
| `--chapter=18 --autotest=crooked` | PASS ama yasak satır `WARN_FREE_NO_OBJECTIVE scene=chapter18.tscn` | 3/3 aynı uyarı, 3/3 PASS | `WARN_FREE_NO_OBJECTIVE scene=chapter18.tscn` / `AUTOTEST PASS chapter=18 variant=crooked outcome=18.2 built=6 misses=12 taped=0 twins=false captive=false next=` | KALICI |

(Kök neden aranmadı, kod değiştirilmedi. run_tests.sh bu uyarıyı fail saymadı: fail=0.)

## Python / ön denetim satırları
- `PARSECHECK PASS scripts=251`
- `INLINECHECK PASS (725 anahtar, 0 sorun)`
- `VOICERULES PASS (9786 anahtar, 0 sorun)`
- `EXPORTREFS PASS`
- `VOICEGAIN: 0 seslendirilmiş replik seviye tablosunda yok`
- bayrak denetimi: sorun 0; kuşatma sonucu: 76 okunan, 0 okunmayan; `JOURNEY ok: 68 kart`; `JOURNEY cards=68 ... final=sealed_garage`
- SPEAKERCHECK / VISAUDIT / WALKTHRU / HELDAUDIT / ARMAUDIT satırı bu parçada çıkmadı.
