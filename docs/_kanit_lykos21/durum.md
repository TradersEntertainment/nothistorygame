# G21 durum: SÜRÜYOR

Dal `wip/lykos21` (taban `wip/ist2-birlesik` a09a28ed, 0.99.128).

## Kayıtlar
1. Ara kayıt: v2 şeridi kodu (geo `lykos_seridi`/`_serit_ada`, sokak savunma sıra evi kapalı + şerit meydanı + harap kilise +
   saray yolu/alanı, hayat_yakin şerit hedefi), harap kilise kurucusu (`kiliseler_harap.gd`), `SurHub.SARAY_OFS`/`saray_v2()`,
   ölçüm sahnesi `tests/_ist/lykos21_olc.tscn`. HENÜZ TEST EDİLMEDİ (önce ölçüm sürüyor).

2. Kayıt: eski dünya şeridi (WallRear.serit_derinlik/in_serit + ayrı rng'li `_serit_fill`, CityPlan `_serit_suz`
   son-süzgeci, SiegeField kilise dışlama, sehir.gd:1117 in_serit); v2 şeridinde ev seyreltme, dolgu sokağı yok, harap kilise
   yer arama (19 × 25 m, gerekirse 15 × 19), sonda sahneleri `lykos21_v2` (şerit sayımı) ve `lykos21_kare` (eski dünya kare).
   Ölçüm (v2, şerit içi): ev 640 → 101, doku yaması 2 → 26 (harap kilise 4), meydan 3 → 5 (+ saray alanı), ISTBOS şerit 0/66.
   Şehrin tamamı ISTEVLER2 ev 9156 → 8442 (9 binin altında: rapora yazılacak, zorla ev eklenmedi). doku2 ISTBOS %0.

## Sıradaki
- Önce ölçümleri (kareler, ISTBOS, ISTEVLER2, yükleme) tabanda al.
- Eski dünya şeridi (WallRear + CityPlan son-süzgeç + SiegeField kilise dışlama).
