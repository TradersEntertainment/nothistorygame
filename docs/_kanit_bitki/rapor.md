# BİTKİ (4. tur) — rapor

Dal: `wip/ist2-bitki` (taban `wip/ist2-doku4`; son hâli `wip/ist2-zemin`, `-doku4`, `-cevre4`, `-baglama4`, `-ordugah5`,
`-sur5` ile birleşik, çakışmasız). Kit: `scripts/level/bitki_kit.gd` (**class_name YOK**; kullananlar
`const BitkiKit := preload("res://scripts/level/bitki_kit.gd")`).

## 1. ÖNCE | SONRA paftaları

Hepsi aynı kamera, aynı anda (gezi sahnesi `tests/_ist/gezi.tscn` ya da oynanış koşusunun aynı replik karesi).
ÖNCE = `wip/ist2-doku4` (depo dışı kopya), SONRA = bu dal (birleşimden önce; yalnız bitki değişikliği).

| Pafta | İçerik |
|---|---|
| `p01_bostan_surdibi.jpg` | sahip_11 bostan adası (tepeden), aynı bostan yerden 3 m, sahip_10 sur dibi mahallesi |
| `p02_manastir_ayasofya.jpg` | Pantokrator çevresi bahçe (çiçekli meyve ağaçları), sahip_07 Ayasofya meydanı çınarları |
| `p03_sur_disi_karsi.jpg` | sahip_03 sur dışı ateş alanı, sahip_13 karşı kıyı, sahip_12 Marmara yamacı |
| `p04_gece.jpg` | gece bostan (yer), gece Galata/Haliç |
| `p05_eski_b2_b7.jpg` | Bölüm 2 kızak kıyısı (`D2_T_01`), Bölüm 7 ordugâh (`D7_T_FAR_A`) |
| `p06_eski_b24_kutuk.jpg` | Bölüm 24 sokak servisi (`D24_M_01`); sur dışı ateş alanında ağacın yerine kütük |
| `sonda_p07/p08/p09_turler_*.jpg` | tür paftası: 16 tür + eski Scenery servi/çınar; her satır ÖNCE 5/30/150 m \| SONRA 5/30/150 m (nötr zemin; 5 m = katman 0, 30 m = katman 1, 150 m = katman 2, dar açı fov 18). ÖNCE'de olmayan türler gri |
| `ilk_01…`, `ilk_02…` | ilk ara gönderimin kareleri (kitin ilk hâli; tarihçe için) |

## 2. Kendi karelerime bakınca hâlâ kötü olanlar

Sahibinin gözüyle: **"ağaç beyaz mı?"** Hayır — hiçbir karede beyaz taç kalmadı (`ISTBITKI beyaz=0`; p02 Pantokrator ve
p04 gece Galata'daki bembeyaz bloklar gitti). **"Blok mu?"** Tek blok taç yok; ama:
- **Öbekler hâlâ düşük çokgenli (6–7 dilimli) ve yakında köşeli okunuyor.** 5 m'de taç, birbirine geçen 7–8 yuvarlakça
  kütle; "yumuşak yaprak bulutu" değil, "çok yüzlü brokoli" (p01 yer karesi, sonda 5 m). Üçgen bütçesi (+%8) yüzünden
  çözünürlüğü artıramadım. KISMEN.
- **Taçların gölge yüzü fazla koyu** (sonda 5 m'de alttan bakınca neredeyse siyah; oyunda koyu yeşil). Erguvan gölgede
  morumsu-siyaha kaçıyor (sonda_p08).
- **150 m katmanı soluk** (sonda karelerinde sis/gök rengine boğuluyor; çiçekli ağaçlar uzakta krem-pembe leke).
  Siluet gövde + iki kütle olarak okunuyor, ama küçük.
- **Bölüm 7 ordugâhında fark çok az** (p05 alt): uzak ağaçlar orta katmanda yine yuvarlak tepe gibi okunuyor.
- **Bölüm 12b'nin ilk 4 dakikasında karede ağaç yok**: 12b için kare kanıtı yok (KANITSIZ).
- **Marmara yamacında erguvan yok**: tür seçimi `sehir.gd`'de (benim dosyam değil); sahip_12 karesinde ağaçlar zaten
  seçilemeyecek kadar uzak (p03 alt). YAPILMADI (ORTAK İSTEK aşağıda).
- **Kütük çok küçük**: ateş alanı karesinde (p06 alt) kütük yalnızca bir nokta gibi; ÖNCE'deki parlak yeşil koni
  (karşı kıyı "agac") gitti, bu iyi. Not: p06 alttaki sur farkı benim işim değil (SONRA karesi birleşik kodla alındı; sur SUR-5'in).

`KUTU kalan=0` (bitki): kendi karelerimde kutu biçimli bitki saymadım. Kutu biçimli başka nesneler (sandık, tezgâh vb.)
benim konumda değil.

## 3. Maddeler

**A. Döküm ve ÖNCE kareleri — DÜZELDİ** (kareler: sonda_p07–p09 ÖNCE sütunları, p01–p06 ÖNCE).
Ağaç/çalı/sarmaşık kuran yerler (grep ile): `IstBitki.tree_mesh` (v2 şehir MultiMesh'leri, `bitki_yama` bahçe/mezarlık,
`mahalle_doku` avlu ve ağaç kümeleri), `sehir_eser` (Ayasofya çevresi, meydan, manastır), `kiliseler_ortak`
(servi, çınar, sarmaşık), `dunya._karsi_ag` (karşı kıyı), `guneybati`, `kemer_kit`, `kuzeybati_ortak`, `ayrinti_d`,
`forumlar` (Amastrianon), `Scenery` (eski bölümler: `cypress_mesh`, `cypress_slim_mesh`, `plane_tree_mesh`, `trees`),
`slipway`, `chapter31o`, `byz_city` (Scenery üzerinden), `outer_world` (Scenery üzerinden), `edirne_yard`
(kış çıplak ağaçları), `Nature` "bush" ayrıntısı, `bureau` palmiyesi (2026 ofisi).

**B. Ortak bitki kiti — KISMEN** (sonda_p07–p09).
- Gövde: incelen, eğri boru; kök çıkıntıları (yakın); 4–5 ana dal + dalcıklar; çok gövdeli türler (zeytin, incir,
  erguvan, nar, defne). Taç: zarf içinde birbirine geçen 7–8 öbek + iç kütle + yaprak/çiçek benekleri; yumuşak normal;
  öbek başına ton (üst açık, alt/iç koyu); sarım normale göre düzeltildi (önceki "kristal" yüz yüz ters gölge hatası).
- Türler (16): çınar, servi (tek parça iğ gövde, dikey yivli, tepesi eğik), fıstık çamı (şemsiye), zeytin (gümüşi),
  incir, dut, ıhlamur, nar, ayva (çiçekte), erguvan (pembe-mor), badem/erik/kiraz (çiçekte: dal görünür, kırık beyaz-pembe,
  gölgede gri-yeşil), defne, çalı (böğürtlen), kütük; ayrıca sarmaşık kümesi.
- Parlaklık tavanı: köşe rengi V ≤ 0,86, doygunluk ≤ 0,62 → `ISTBITKI beyaz=0` (sonda ve dünya).
- Rüzgâr: köşe alfası = salınım ağırlığı (gövde 0, taç 1), gölgelendiricide iki sinüs. Yaprak geçirgenliği EMISSION 0,1.
- YAPILMADI: asma çardağı, saz, bostan sıraları (lahana/soğan/bakla) kitte yeni değil; `bitki_yama` öğeleri
  (bağ, sazlık, bostan) olduğu gibi duruyor. `Nature` "bush" (eski bölüm zemin ayrıntısı, üç top) dönüştürülmedi.
- Kötü kalan: yukarıdaki 2. başlık (köşeli öbek, koyu gölge yüzü, soluk uzak katman).

Tür tablosu (sonda, `ISTBITKI tur=… ucgen=…`):

| tür | lod0 (≤900) | lod1 (≤180) | lod2 (≤40) |
|---|---|---|---|
| çınar, fıstık çamı, ıhlamur | 490 | 110 | 22 |
| servi | 258 | 100 | 30 |
| zeytin, nar, defne | 520 | 110 | 22 |
| incir | 572 | 110 | 22 |
| dut | 464 | 110 | 22 |
| ayva | 504 | 110 | 22 |
| erguvan | 560 | 110 | 22 |
| badem, erik, kiraz | 530 | 110 | 22 |
| çalı | 208 | 80 | 16 |
| kütük | 53 | 25 | 20 |
| sarmaşık (birim küme) | ≈40 | – | – |
| (eski) servi / çınar / kiraz | 163 / 932 / 468 | 159 / 143 / 107 | 32 / 72 / 52 |

**C. Uygula — DÜZELDİ (v2 şehir ve eski bölümlerdeki Scenery ağaçları), KISMEN (bazı eski bölüm yerel ağaçları)**
(p01, p02, p03, p04, p05 üst, p06 üst). İmza, konum, sayı aynı; rng çağrı sayısı korundu (`kiliseler_ortak.tree_plane`
eski 12 rng çağrısını aynen tüketir). Yeni ağaçlar aynı düğümde tek ağda toplanır ("BitkiToplu"; eser pişiricisi
gölgelendiricili ağı birleştirmediği için ağaç başına çizim olmasın). Dönüştürülmeyenler: `edirne_yard._trees` (kış,
çıplak dallı karlı ağaç: biçim zaten ağaç; bırakıldı), `bureau._ld_palm` (2026), `Nature` "bush".

**D. Yer mantığı — KISMEN** (p03 üst, p06 alt; `ISTBITKI` satırı).
- Ateş alanı: kara suruna 260 m'den (hendekten ~200 m) yakın sur dışı karşı kıyı ağaçları (175 adet) aynı yerde kütüğe
  döndü (`dunya._karsi_kiyilar` yerleştirme satırı). Birleşik sonda: `ISTBITKI agac=19156 cali=9425 yolda=1 evde=0
  suda=0 ates=0 kutuk_ates=175 beyaz=0`.
- `yolda=1`: Amastrianon meydanının köşe çınarı (`forumlar.gd`, ÇEVRE-4 konumu; birleşimden sonra meydan Mese sokak
  çizgisinin üstüne düşüyor; eski top-ağaç da aynı yerdeydi). Benim dalımda tek başına `yolda=0`. ORTAK İSTEK aşağıda.
- `evde=0` KANITSIZ: ev tespiti şehir ev MultiMesh örneklerinden yapılıyor ve dünyada yalnız 4 örnek buldu (evler
  çoğunlukla pişmiş ağ). Gerçek sayım değil.
- Sayılmayan: `mahalle_doku` avlu ağaçları pişmiş ağ olduğu için sondaya girmez.
- Ordugâhta seyrek / sur içi bostan-avlu-manastır-mezarlık-meydan dağılımı başkalarının yerleştirmesi; değiştirmedim.

**E. Çarpışma — DÜZELDİ** (kod; kare yok). Gövde katı (silindir), taç çarpışmasız: `guneybati._tree_cypress` (eskiden
bütün koni katıydı), `kemer_kit.tree` (eskiden taç da katıydı), `kuzeybati_ortak.cypress/olive`, `chapter31o._plane_tree`.
Ayasofya meydanı köşe çınarları eskiden çarpışmasızdı, öyle bırakıldı (oyun alanı). `byz_city` serviler
`Scenery.scatter(..., 0.5)` ile eskisi gibi AABB kutusu (davranış aynı). Tırmanma/konma noktaları değişmedi.

## 4. Dokunulan işlevler (dosya:satır)

- `scripts/level/bitki_kit.gd` (YENİ, bütün dosya) ve `tests/_ist/bitki_kit_sonda.*`, `tests/_ist/bitki_yer_sonda.*` (YENİ)
- `scripts/world/ist/bitki.gd:237-243` `tree_mesh` (kite yönlendirme), `:261` `_agac` gövde ölçüsü
- `scripts/level/scenery.gd:55` `scatter` (kit ağının kendi malzemesi), `:187-199` `cypress_mesh`, `cypress_slim_mesh`, `plane_tree_mesh`
- `scripts/world/ist/sehir_eser.gd:514-518` `manastir` (ağaç satırları), `:542-543` `meydan` (köşe çınarları), `:792` `_servi`, `:797` `_cinar`
- `scripts/world/ist/kiliseler_ortak.gd:443` `tree_cypress`, `:461-466` `tree_plane`, `:572` sarmaşık MultiMesh'i (flush)
- `scripts/world/ist/dunya.gd:581` `_karsi_kiyilar` (ateş alanında kütük), `:614` kütük malzemesi, `:621` `_ates_alani` (YENİ), `:633-645` `_karsi_ag` (ağaç/servi/çalı/kütük)
- `scripts/world/ist/guneybati.gd:138` `_tree_cypress`, `:146` `_tree_round`
- `scripts/world/ist/kemer_kit.gd:182` `tree`
- `scripts/world/ist/kuzeybati_ortak.gd:519` `cypress`, `:528` `olive`
- `scripts/world/ist/ayrinti_d.gd:177` `build_meyve_agaci`, `:183` `build_zeytin_agaci`, `:189` `build_selvi`, `:194` `build_cali`
- `scripts/world/ist/forumlar.gd:420` Amastrianon çınarları
- `scripts/level/slipway.gd:1276` `_cypress`; `scripts/chapter31o.gd:876-884` `_plane_tree`

## 5. Sayımlar, testler, performans

- Ayrıştırma: `PARSECHECK PASS scripts=336` (dal), `scripts=341` (birleşik).
- Başsız (birleşik kod, 17 bölüm): 0, 2, 4, 6, 7, 8, 8y, 9, 11, 12, 12b, 17, 24, 26, 35o, 43o, 31o → **17/17 AUTOTEST PASS,
  yasak satır 0**. (Dal tek başına da 17/17 PASS, yasak 0.) Not: birleşik kopyada ilk koşu `.godot` içe aktarılmadan
  yapılmıştı ve `zemin.gd` dokusu yüzünden SCRIPT ERROR verdi; `--import` sonrası temiz (test ortamı hatası, kod değil).
- RINFO (aynı kamera; yazılımla çizim, `kare_ms` yalnız göreli):

| kare | ÖNCE çizim / üçgen | SONRA çizim / üçgen | üçgen |
|---|---|---|---|
| sahip_02 Galata | 672 / 1 989 886 | 671 / 1 959 643 | −1,5 % |
| sahip_03 sur dışı 30 m | 1056 / 3 200 015 | 1060 / 3 220 452 | +0,6 % |
| sahip_04 sur dışı 70 m | 986 / 2 946 675 | 991 / 2 965 556 | +0,6 % |
| sahip_07 Ayasofya | 610 / 1 247 499 | 603 / 1 232 028 | −1,2 % |
| sahip_12 Marmara | 629 / 2 035 131 | 630 / 2 065 212 | +1,5 % |
| sahip_13 karşı kıyı | 520 / 1 954 326 | 517 / 1 954 017 | 0,0 % |
| bostan yer 3 m | 713 / 2 539 952 | 717 / 2 563 216 | +0,9 % |
| bostan gece (tepe) | 456 / 1 666 258 | 458 / 1 669 648 | +0,2 % |
| Pantokrator | 673 / 2 681 769 | 674 / 2 679 514 | −0,1 % |
| gece bostan yer | 736 / 2 620 972 | 732 / 2 597 472 | −0,9 % |
| gece Galata | 681 / 2 005 809 | 682 / 2 036 052 | +1,5 % |

  Üçgen her karede ≤ +1,5 %. **Çizim: KISMEN** — kimi karede +1…+5 (sur dışını gören karelerde kütük MultiMesh'i,
  bazı düğümlerde "BitkiToplu" ağı); kimi karede −2…−7. "Çizim artmaz" kuralı tam tutmuyor.
- Kare süresi (`kare_ms`, yazılımla çizim): ÖNCE 743–3962 ms, SONRA 524–3154 ms; aynı karelerde SONRA genelde kısa,
  ama bu ortamda güvenilir ölçü değil.

## 6. ORTAK DOSYA ÖNERİLERİ / İSTEKLER

1. ÇEVRE-4 (`forumlar.gd` Amastrianon): birleşik konumda köşe çınarı Mese sokak çizgisinin üstünde
   (gerçek −2356, 142). Çınar listesini meydan iç kenarına çekin ya da sokak bandını meydanda kesin.
2. ŞEHİR (`sehir.gd` ~1112, ağaç türü seçimi): Marmara kıyı yamacında erguvan (rng çağrısı değişmesin diye konumdan
   hash):
   ```gdscript
   var tur := String(AGAC_SIK[rng.randi() % AGAC_SIK.size()])
   if IstGeo.cizgi_uzak(Vector2(tp.x, tp.y), IstGeo.kiyi("yarimada")) < 250.0 and tp.y > 0.0 \
   		and fposmod(tp.x * 0.13 + tp.y * 0.07, 1.0) < 0.5:
   	tur = "erguvan"
   _add(g0, g1, g2, "ag|" + tur, ...)
   ```
   (`tp.y > 0` Marmara yanı için yaklaşık; kıyı adını ŞEHİR doğrulamalı.)
3. `mahalle_doku.gd` önbellek imzasına `res://scripts/level/bitki_kit.gd` eklenmeli; şimdilik kit değişince
   `bitki.gd` içindeki `KIT_SURUM` yorumu artırılarak önbellek bozuluyor.

## 7. Bakamadıklarım

- 14 sahip karesinin hepsini yeniden almadım (yalnız 02, 03, 04, 07, 10, 11, 12, 13, 14).
- 12b ve 8, 8y, 9, 11, 17, 26, 35o, 43o bölümlerinde ağaç karesi almadım (yalnız başsız test).
- Oynanışta oyuncunun gövdeye çarpması ve taçtan geçmesi kareyle doğrulanmadı.

## SAHİBİNE GÖSTERİLECEK 8 KARE

1. `p02_manastir_ayasofya.jpg` (üst) — Pantokrator bahçesi: bembeyaz bloklar yerine dalları görünen pembe-beyaz çiçekli ağaçlar.
2. `p01_bostan_surdibi.jpg` (orta) — bostan, yerden: gövdeli, dallı ağaçlar; yivli koyu servi.
3. `p01_bostan_surdibi.jpg` (üst) — bostan adası tepeden: beyaz/pastel topların yerini çeşitli türler aldı.
4. `p04_gece.jpg` (alt) — gece Galata: karanlıkta parlayan beyaz ağaç blokları gitti.
5. `p05_eski_b2_b7.jpg` (üst) — Bölüm 2 kızak kıyısı: fosforlu yeşil koniler yerine servi.
6. `p02_manastir_ayasofya.jpg` (alt) — Ayasofya meydanı: yeşil lolipop çınarlar yerine dallı çınarlar.
7. `sonda_p07_turler_a.jpg` — çınar, servi, fıstık çamı, zeytin, incir, dut: ÖNCE/SONRA, 5/30/150 m.
8. `sonda_p08_turler_b.jpg` — erguvan, badem, erik, ayva, nar, ıhlamur: çiçekli ağaçlar artık beyaz kütle değil.
