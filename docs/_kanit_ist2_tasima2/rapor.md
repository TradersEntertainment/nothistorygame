# TAŞIMA-2 — pilot kalanları (kazık çit, Bölüm 20) ve Bölüm 21 yeni Mesoteikhion surunda

> Dal `wip/ist2-tasima2`, taban `wip/ist2-birlesik` (28f42bb4). Makine: 4 çekirdek; ekransız testler `--max-fps 20`,
> kareler xvfb + Mesa llvmpipe (yazılımsal GL). Ham çıktılar `testler/`, kareler `kare/`. "ÖNCE" ölçümleri tabanın
> `git archive` kopyasında (ayrı klasör, aynı içe aktarma önbelleği) koşuldu. Dokunulmayanlar: sur görünüşü dosyaları
> (TUR 8), çatı dosyaları, `scripts/npc/`, `scripts/ui/`, `sur_sozlesme*`, `tests/run_tests.sh`, replik metni, ses,
> denge, süre, sayaç.

## Özet

| # | Madde | Durum | Kısa |
|---|---|---|---|
| 1 | Kazık çit "oyuncunun arkasına" | **TAMAM** | çit barikatın şehir tarafında (teslim yerinin 2,8 m gerisi, iki ucu açık); sırt dış yüz + 0,2; Bölüm 20 2. dalga medyan 27,2/49,8 → 8,8 sn (eski 22,7); 20o `=wide` 1. dalga 34–35,5 → 3,7–7,6 sn (eski 9,3) |
| 2a | `=hit` `VISAUDIT personhidden D20_G_ASSAULT` | **TAMAM** (bkz. ×10 tablosu) | kök: işçiler taşıyıcı şeridinin üstündeydi, itilerek komutanla oyuncunun arasına/barikatın içine giriyordu; konuşanın önünden çekilme işçileri kapsamıyordu. 0.99.121 `Unclip.clear_line` düzeltmesi aynı kök neden DEĞİL (bu replikten önce `clear_line` çağrılmıyor) |
| 2b | Gökte koyu köşeli biçim | **TAMAM** (doğrulama) | pilot kaydında var, bu dalda yok: kaynak kesimin birleşik sur ağı (`OyunDilimi/Mesoteikhion/@MeshInstance3D…`, kurucu `surlar*.gd`, tur 6 sürümü); tur 7 birleşimiyle kaybolmuş. TUR 8'e istek gerekmiyor |
| 3a | Bölüm 21 taşıması | **TAMAM** | bağdaştırıcı + `--eskisur`; yeni ×2 12/12, eski ×1 6/6 PASS, denetim 0; gerçek bot yürüyüşü iki sette temiz |
| 3b | Bölüm 0 | **YAPILMADI** | süre yetmedi (aşağıda "sonraki taşıyana") |
| 3c | Bölüm 25 (Bizans yarısı) | **YAPILMADI** | süre yetmedi |

(Ayrıntılı tablolar ve kareler aşağıda; "hâlâ kötü olanlar" sonda.)
