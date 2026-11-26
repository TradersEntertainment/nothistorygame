# G22 durum: SÜRÜYOR

Dal `wip/saray22` (taban `wip/ist2-birlesik` 618521d7 = 6dec6901 + görev yazısı).

## Faz A: SÜRÜYOR
- ByzCity bölünmesi yazıldı: `saray_kok` (iç grup; yerel = bugünkü hub yereli), `_k` kurulum kökü, `BOLME_X` 18,
  `IC_RECT`/`SUR_RECT`, `ofs()` (v2: −7,6 / eski dünya: SiegeField.saray_y ≈ +5,65), `_kur_bolunmus`, nöbet yeri
  (`_build_nobet`, sabit su fıçısı `FICI_POS`), `_dress_bolunmus` (Dressing.auto `kok` seçeneği), çek-sonra-at dolgu.
- Eski dünya: `FAR_REGIONS` iki dikdörtgen, `far_hub` iki pişirme, `SiegeField.city_ground` saray düzlüğü (+26 m, 30 m şev).
- Anahtar: `ByzCity.BOLUNEN` (şimdilik boş → hub bölümleri eski yerde oynar), `--saray-eski` geri dönüş.
- Ölçüm (önce): LOADTIME 24 total 44555 ms, 23 total 42145 ms (taban kopyası, tek süreç).
- Hata bulundu/düzeltildi: iç grubun y'si dünyaya göre (43o v2 açıkken de eski dünya) — ilk "sonra" karesinde mahalle gömüktü.

## Faz B: SÜRÜYOR (kod yazıldı, anahtar kapalı)
- v2: `hub_sehir` + `hub_saray` (tek ByzCity, katman başına bir kez kurulur, iki tutucuya dağıtılır), saray düzlemesi
  (IstGeo.duzle), `oyun_alanlari` sona saray, IstBaglama iki temizlik alanı, `_saray_yolu` sokak ağzına.
- 10h, 12b, 23 geçişleri yazıldı.

## Faz C: SÜRÜYOR (6b kodu yazıldı, anahtar kapalı)

## Ara durum (testler sürüyor)
- Bütün hub bölümleri bölünmüş düzende (`BOLUNEN` = 6, 7, 10h, 12b, 13, 23, 24).
- Dünya bölümleri ×1 (6, 7, 8y, 9, 10, 10b, 10z, 11, 13, 16, 24o, 25 osm, 31o, 43o): 14/14 AUTOTEST PASS.
- Sözleşme altılısı aynı: SURSOZLESME PASS 13/8, SUROYUN 519/0/0/0, WALKTHRU 7/7/0/0, ESYATEST PASS,
  HALICSONDA 661/3854034809, MARMARASONDA 1837/2250736444. WORLDCHECK, FLIGHTCHECK, WALKCHECK PASS.
- Hub çeşitleri ×2 (38 × 2) sürüyor; CITYCHECK, STREETCHECK, menü dönüşü, ZFIGHT, harita pişirme + MAPCHECK sırada.
