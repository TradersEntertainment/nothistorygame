PARCA 8: SORUNLU (1 koşu)

# Parça 8/10 özeti (Godot 4.4.1 stable, MAXFPS=20)

- Süre: 1957 sn (~33 dk). İlk koşu konteyner yeniden başlatması yüzünden yarıda kaldı; parça baştan koşuldu, bu özet ikinci (tam) koşuya aittir.
- Son satır: `SHARD 8/10 BITTI fail=0`. Çıkış kodu: 0.
- Beklenen koşu (`LIST=1`): 41. PASS satırı eşleşen: 41/41 (38 bölüm koşusu + `2/10/13 next` koşularının 3/11/14 PASS satırları). Eksik PASS yok.
  Ek olarak liste dışı sabit adımlar: ladder 1, arena 9, traversal 1 PASS.
- Toplam `AUTOTEST PASS` satırı: 52. FAIL 0, TIMEOUT 0, SCRIPT ERROR 0, Parse Error 0.
- VISAUDIT/WALKTHRU/HELDAUDIT/ARMAUDIT/JOURNEY_: 0 satır (bu parçada çıkmıyor).

## Python / ön denetimler
- `PARSECHECK PASS scripts=251`
- `INLINECHECK PASS (725 anahtar, 0 sorun)`
- `VOICERULES PASS (9786 anahtar, 0 sorun)`
- `EXPORTREFS PASS`
- `VOICEGAIN: 0 seslendirilmiş replik seviye tablosunda yok`
- SPEAKERCHECK satırı bu parçanın çıktısında yok.

## Sorunlu koşular
| Koşu | İlk sonuç | 3 yeniden koşu | Durum |
|---|---|---|---|
| `res://scenes/arena.tscn -- --autotest=mods` | PASS, ama öncesinde `WARN_PORTRAIT_STUDIO speaker=SPK_LOOKOUT key=D20_L_WARN_1 scene=arena.tscn` basıldı | 3/3 aynı WARN + PASS (hp=100/100/75) | KALICI (uyarı) |

Komut: `timeout 300 ~/is/godot/godot --headless --max-fps 20 --path . res://scenes/arena.tscn -- --autotest=mods`
Uyarı `scripts/ui/hud.gd:2239` satırından geliyor (SPK_LOOKOUT için portre stüdyosu yok). Kök neden aranmadı, kod değiştirilmedi.
Not: İlk tekrar denemesini yanlışlıkla `=osm` ile koştum (3/3 WARN'sız PASS, `docs/_test119/tekrar_arena_osm.txt`); WARN `=mods` koşusuna ait olduğundan doğru koşu ayrıca yapıldı (`tekrar_arena_mods.txt`).
