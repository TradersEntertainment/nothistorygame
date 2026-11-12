# Düzeltme turu: havadan şehir (eski dünya, 0.99.119 için) — GELİŞTİRİCİ

Önce `docs/_ajan/gorev/_ortak2.md` dosyasını oku ve uy. Dalın: `wip/duzeltme-hava`. Kanıt klasörün: `docs/_kanit_dhava/`.
Bağımsız denetçinin raporu: `docs/_ajan/denetim/hava.md` (tamamını oku). Hükmü: "küçük düzeltmelerle kabul"; sondaki
Z1–Z4 bağlayıcı. Geliştiricinin ilk raporu: `docs/_ajan/rapor/hava.md`.

Düzenleyebileceğin dosyalar: `scripts/world/world1453.gd` (`bake`, `far_aya` ve yardımcıları), `scripts/level/byz_city.gd`
(yalnız `far_hub`), `scripts/world/horn_world.gd` (yalnız kıyı suru nöbet ateşlerinin yeri). Bölüm betikleri yok.

## Zorunlu
- **Z1:** hub evleri havadan (Bölüm 11 gece, 7a gündüz) yerdeki gibi terrakota kiremit çatılı görünsün; soluk/beyaz
  kutu ve gece beyaz eğik düzlem kalmasın. Denetçinin kestirdiği neden: `bake(..., max_tris = 300)` çatıyı prizma
  beşik çatıya çevirirken rengi `albedo_color × _avg(texture)` ile soluk hesaplıyor: doğrula, düzelt.
- **Z2:** Ayasofya yakınında (≤ 150 m) bütçe: denetçinin `aya_m25`, `aya_m60`, `band_aya_*` bakışlarının eşdeğerinde
  üçgen ÖNCE'ye (`e551de84`) göre en çok +%8, çizim artmaz. Görünüş bozulmadan (yerdeki modelle aynı kalır).
- **Z3:** Haliç ve Marmara kıyı surlarındaki nöbet ateşleri dört yönden 6 m'den görünür olsun (alev seçilsin).
- **Z4:** kendi raporunda ölçümleri aynı ana hizalı üçer örnekle, ÖNCE | SONRA tabloyla ver.

## Testler
3, 4 (hepsi), 6 (+`byz`), 7 (hepsi), 8, 8y, 9, 10, 11 (hepsi), 24, 25, 26, 27, 30, 31o + `flight_check`, `world_check`,
`city_check`, `parse_check`.
