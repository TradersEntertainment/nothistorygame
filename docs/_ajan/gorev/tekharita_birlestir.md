# Tek harita: G1 + G2 + G6 + G7 birleştirme ve doğrulama — GELİŞTİRİCİ (Opus)

Önce `docs/_ajan/gorev/_ortak2.md`, sonra `docs/_ajan/gorev/_tek_harita_ortak.md`, `docs/_ajan/tek_harita.md` (mimari;
§F arayüz, §H kalanlar) ve `docs/_ajan/hava_liste.md` ("ARAYÜZ GENİŞLEDİ" satırı) dosyalarını oku ve uy.
Dalın: `wip/tekharita` (bu dalın ucundan açılır). Kanıt klasörün: `docs/_kanit_tekharita/`.

Motto (sahibin sözü): "tüm İstanbul tek harita, tüm görevler aynı harita; her şey tam içerik ve kaliteyle haritada
oynanacak; performans için yaratıcı çözümler: uzakken yüklenmez".

## Durum
Bu dalın ucunda ortak altyapı (P0) hazır: `World1453.REGIONS/FAR_REGIONS/bake`, `ByzCity.far_hub/aya_exterior/
column_parts`, `Blachernae.shell_parts`, `Flame.from_glow_boxes`. Dört göç paketi ayrı dallarda, ESKİ tabanlarda bitti:
- `origin/wip/tekharita-g1` (4a gece ordugâhı; `camp.gd`, `chapter4.gd`; rapor `docs/_kanit_g1/rapor.md`)
- `origin/wip/tekharita-g2` (otağın içi 10a/12/13; `otag_hall.gd`; `docs/_kanit_g2/rapor.md`)
- `origin/wip/tekharita-g6` (Haliç kıyı surları; `sea_walls.gd`, `petrion.gd`, `horn_world.gd`; `docs/_kanit_g6/rapor.md`)
- `origin/wip/tekharita-g7` (lağım tünelleri 10l/21o; `docs/_kanit_g7/rapor.md`)
Her birini `git fetch origin <dal>:refs/remotes/origin/<dal>` ile al.

## Yapılacaklar
1. Dört dalı sırayla `wip/tekharita` içine `git merge` et (g2, g7, g1, g6 sırası önerilir). Çakışmalarda P0'ın yeni
   arayüzü esastır (aynı işi iki kurucu yapmasın: ör. G6'nın `SeaWalls.horn_wall_parts`'ı ile P0'ın `horn_world.gd`
   değişikliği tek kurucuda birleşsin; ateşler `Flame`). Üretilmiş `.import` dosyalarını (dallardan gelen ses
   `.import` kayıtları dahil) birleşimde tutma: `git rm --cached` ile çıkar, `.gitignore` kuralına uy.
2. Her paketin raporundaki "açık / kısmen" maddelerini kapat ya da dürüstçe AÇIK yaz.
3. Her paket için kanıt: AYNI YER yerden (bölümün oynanış karesi) ve havadan (Bölüm 11 ya da 7 uçuş kamerası) çift;
   uzaklık katmanı geçişi (uzak → yakın, 5 kare); "uzakken yüklenmez" kanıtı (bölge uzaktayken düğüm/üçgen sayısı).
4. Performans bütçesi (`_tek_harita_ortak.md`): yerde çizim ≤ 900 ya da ÖNCE'ye göre ≤ +%10, üçgen ≤ 2,5 M ya da
   ≤ +%10, yükleme süresi ≤ +1,5 sn. Bölüm 4a, 10a, 12, 13, 10l, 21o, 27, 29, 11, 7 için ÖNCE (bu dalın başlangıç ucu)
   | SONRA tablosu.
5. Testler (başsız, hepsi PASS, yasak satır yok): 4 (bütün varyantlar), 10a, 12 (hepsi), 13, 10l, 21o, 21, 27, 29,
   29o, 38o, 11 (hepsi), 7 (hepsi), 6, 8, 9, 10, 17, 20, 24, 30, 43o + `flight_check` + `parse_check`.
6. Raporun sonunda: tek haritada HÂLÂ olmayan bölümlerin tam listesi (bölüm, şu an hangi ayrı kurucuda, göç için ne
   gerekli, tahmini iş). Özellikle: LandWalls bölümleri (0, 20, 22, 22o, 26, 26o, 36b, 37o: `land_walls.gd` dünyayı
   çağırmıyor), hub sokaklarının CityPlan'a bağlanması ve iki ev üslubu, Ayasofya parçasının dolgu evleri, iki
   Konstantin Sütunu, Galata rıhtımı ve kulesi, Boğazkesen. Bunları bu oturumda YAPMA; yalnız listele (sonraki
   paketler bu listeden açılacak).

Dosya sınırı: yukarıdaki dört paketin dosyaları + `scripts/world/*.gd` (birleştirme için gerektiği kadar). Bölüm
betiklerinde oynanışa (replik, süre, sayaç, bot yolu) dokunma.
