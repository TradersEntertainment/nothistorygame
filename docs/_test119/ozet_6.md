PARCA 6: TEMIZ

# Test paketi — parça 6/10

- Godot 4.4.1.stable.official.49a5bc7b6 (linux x86_64), import çıkış kodu 0
- Komut: `SHARD=6 SHARDS=10 MAXFPS=20 GODOT=$HOME/is/godot/godot bash tests/run_tests.sh`
- Beklenen koşu: 41 (LIST=1 listesi). Eşleşen PASS: 41/41. Ham çıktıda toplam 52 `AUTOTEST PASS` satırı var (fazlası: arena koşuları 9, ladder 1, traversal 1, ve `8y next` → bölüm 9 `arch`, `10l next` → bölüm 11 zincirleme PASS'ları; 42b/43o koşuları `chapter=42/43` olarak yazılmış).
- `AUTOTEST FAIL` / `TIMEOUT` / `SCRIPT ERROR` / `Parse Error` / `WARN_`: 0
- Sorunlu koşu: yok (yeniden koşu gerekmedi)

## Ön / python denetim satırları
- PARSECHECK PASS scripts=251
- INLINECHECK PASS (725 anahtar, 0 sorun)
- VOICERULES PASS (9786 anahtar, 0 sorun)
- EXPORTREFS PASS
- VOICEGAIN: 0 seslendirilmiş replik seviye tablosunda yok
- bayrak denetimi sorun: 0; kuşatma sonucu okunmayan: 0
- JOURNEY ok: 68 kart; JOURNEY cards=68 overlap=0 final=sultans_repair
- CITYCHECK PASS, STREETCHECK PASS, FOCUSCHECK PASS, FXCHECK ok
- VISAUDIT / WALKTHRU / HELDAUDIT / ARMAUDIT / SPEAKERCHECK satırı bu parçanın çıktısında yok (bu parçada çalışmıyor)

## Süre ve sonuç
- Toplam koşu süresi: 1963 sn (~32,7 dk)
- Son satır: `SHARD 6/10 BITTI fail=0`
- Çıkış kodu: 0
