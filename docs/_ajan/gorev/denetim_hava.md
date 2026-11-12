# Bağımsız denetim: havadan şehir, ateşler, özel yapılar (tek harita P0) — DENETÇİ

Önce `docs/_ajan/gorev/_ortak2.md` dosyasını oku ve uy. Rapor dalın: `wip/denetim-hava`, klasör `docs/_kanit_denetim_hava/`.
Geliştirici raporu: `docs/_ajan/rapor/hava.md`; mimari: `docs/_ajan/tek_harita.md`. Denetlenen dosyalar
(`git diff e551de84 -- <dosya>`): `scripts/world/world1453.gd`, `horn_world.gd`, `landmarks1453.gd`, `city_plan.gd`,
`world_flight.gd`, `scripts/level/byz_city.gd`, `blachernae.gd` (`shell_parts`), `flame.gd`, `galata_view.gd`, `horn.gd`,
`sea_walls.gd`, `assets/shaders/flame.gdshader`.

Sahibin şikâyeti (Nihat'la uçarken): "haritalar ortak olacaktı hani? … ateşler neden küp küp? … özel binalar küp küp".
Motto: bütün İstanbul TEK harita; her bölüm aynı haritada; uzakken yüklenmez.

## Sına (Bölüm 11 gece uçuşu, 7 `=a` ve `=b` gündüz uçuşu; uçuş kamerasıyla serbest gez)
1. Ateşler: ordugâh, nöbet ateşleri, mutfak, kıyı surları, Blakherna: uzaktan / 15 m / 3 m / tam tepeden. Küp, düz
   levha, tepeden çizgi, kameraya dönerken zıplayan alev kaldı mı? Gece 4a ordugâhı yerden bozuldu mu?
2. Özel yapılar: Ayasofya, Blakherna, Konstantin Sütunu, Havariyun, Bozdoğan Kemeri, Hipodrom, Büyük Saray, kiliseler,
   Galata Kulesi, hub (Romanos Kapısı, kançılarya, saray avlusu): kutu / küre yığını kaldı mı? Her biri için havadan ve
   YERDEN aynı yer, aynı ölçü, aynı renk mi (yer karesi: 24/25/26/31o Ayasofya, 6b/7b/10h/12b/23 hub, 30 Blakherna)?
   Ayasofya çevresine göre ölçüsü inandırıcı mı (yerdeki model ~35 m)?
3. Uzaklık katmanları: yaklaşırken yapı kayboluyor / birden beliriyor / iki katman üst üste biniyor mu (geliştirici
   95 m'de bir "ölü bant" hatası düzeltti: 60–140 m arası 5 m adımla Ayasofya, Blakherna ve hub'a yaklaş)?
4. Zemin: Ayasofya bölgesi tepeye kaldırıldı: 24, 25, 26, 31o yerden oynanışta zemin, kişiler, eşyalar havada ya da
   gömülü mü? Hub'ın kenarında dünya ile birleşim (basamak, yarık, iç içe ev, yolun ortasında ev)?
5. Uçuşta çarpışma: yapıların içinden geçiliyor mu; Ayasofya kubbesine konma; görünmez duvar.
6. Açık kalanları doğrula ve ölç: iki ev üslubu yan yana, iki Konstantin Sütunu, Galata yoğunluğu, ovadaki dikdörtgen
   renk yamaları, kuzey kıyı çadırları. Her birine kare.
7. Performans: Bölüm 11 ve 7'de on bakışta RINFO ÖNCE | SONRA (çizim, üçgen), yükleme süresi (bölüm açılışından ilk
   kareye) ÖNCE | SONRA. Yerdeki bölümlerde (6, 8, 24, 30, 20) çizim/üçgen değişti mi?
8. Testler: 3, 4 (hepsi), 6 (+`byz`), 7 (hepsi), 8, 8y, 9, 10, 11 (hepsi), 17, 17o, 18, 19, 24, 24o, 25, 26, 27, 29, 30,
   31o, 32o, 39o, 43o + `tests/` altındaki uçuş denetim sahnesi (`flight_check`).
