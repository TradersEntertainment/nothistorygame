# GEZİ — `ordugah-merkez` (2. GÖNDERİM: gündüz + gece + yürüyüş)

Denetçi: bağımsız gezgin. Oyun kodu DEĞİŞTİRİLMEDİ (yalnız `tests/_ist/gezi_ordugah-merkez.*` sonda dosyaları). Taban: `wip/ist2-gezi-taban`.

## 1. Bölge, kare sayıları
- Bölge (gerçek doğu, kuzey, m): KB (−6100, 2000) · KD (−5000, 2000) · GD (−5000, 700) · GB (−6100, 700). İçinde: otağ (−5611, 1490), Şahi (−5098, 1280), bataryalar 5–8, mescit (−5604, 1163), pazar (−5529, 913), Halil Paşa (−5950, 1157), kazanlar (−5191, 1807), at/deve bağı (−5220, 2119), öküz ağılı (−6298, 1771), dökümhane (−6451, 475), barut (−5328, 1310), esir (−5473, 2485), tercüman (−5779, 1848), siper hattı. Koordinatlar `IstOrdugah.plan()` + `IstGeo.real` ile sondadan alındı (`tests/_ist/gezi_ordugah-merkez.gd`).
- **Çekilen kare: 203** (gündüz pilot 55 + gündüz ızgara/ek 116 + gece 32), 1280×720, `sur4_kare --set=liste` (şehir kuyruğu boşaltılarak). Yazılımla çizimde ~11 sn/kare → madde 2'deki 60 m / 4 yön ızgara (≈1 800 kare) bu sürede MÜMKÜN DEĞİL; yerine **180 m ızgara (42 düğüm × K,D = 84 kare)** + 11 yapıda 5'er kare (4 yön + havadan) + 32 elle yakın/uzak/havadan/tepeden kare + gece (her 3. düğümden K,D = 28 + 4 yapı/hava).
- **Bakılan kare: 177 / 203** (3×3 paftalarda; şüpheli olanların tam boyu ayrıca açıldı: g41_D, g38_D). BAKILMADI: pafta g_07, g_09 (12 kare), gece paftaları 01 ve 02 (14 kare).
- **Yürüyüş: 849 m** (6 güzergâh, gerçek `player.gd`, başsız; hedef 1,2 km'nin ALTINDA, ağır CPU yüzünden süre 60 sn/rota ile kesildi). Ham olaylar `ham/olay_yuruyus.txt`.

## 2. GENEL NOT: 3 / 10
Sahibi buraya yerden bakınca ilk **hayvanlara** kızar: öküz ve develer hâlâ sandık + dört kazık (kutu yasağı 32 ihlali, `k2_agil_otag_yakin`, `k2_hayvan_ahir_yakin`). Hemen ardından **kırmızı fesli askerler** (döneme aykırı, `k1_sahi_G`) ve **elmas gibi gülle yığınları** gelir. Yukarıdan çadır denizi iyi okunuyor, ama yerden bakınca çadır içi dümdüz lacivert/karanlık, zemin tekrar eden koyu çizgi damgasıyla dolu ve bataryaların önü bomboş çayır.

## 3. BULGU TABLOSU
Kare dosyaları `kare/` altında (`k1_` = pilot koşu, `k2_` = ızgara/ek koşu). "ÖNCE'de var mıydı" sorusu bu görevde sorulmadı (taban tek dal).

| no | tür | önem | yer | doğu, kuzey | kare | ne görünüyor | kaynak | öneri |
|---|---|---|---|---|---|---|---|---|
| 1 | KUTU | 1 | Öküz ağılı | −6298, 1771 | k2_agil_otag_yakin, k2_agil_otag_uzak | öküzler kutu gövde + kutu baş + kazık bacak: "kare kare öküz" | ordugah_yapi.gd:_okuz; ordugah_yerleske.gd:build_agil | yuvarlak kesitli gövde/boyun/baş/bacak (kural 32) |
| 2 | KUTU | 1 | At ve deve bağı | −5220, 2119 | k2_hayvan_ahir_yakin, k2_hayvan_ahir_uzak | develer dikdörtgen sandık gövde, kutu bacak, kutu semer; uzaktan da "ayaklı sandık" | ordugah_yapi2.gd:_at (deve=true) | aynı: örgü/kapsül gövde, kıvrık boyun |
| 3 | KUTU | 1 | Şahi/batarya gülle yığını | −5098, 1280 / −5200, 951 | k2_sahi_yakin, k1_bat06_K, k1_sahi_G | gülleler 5 kenarlı küre → "elmas/oktahedron" yığını, altında düz kutu | ordugah_yapi.gd:_gulle_piramit (b.sph(...,5), solid_box) | en az 10–12 kenarlı küre, piramit düzeni gevşek |
| 4 | DÖNEM | 1 | Pazar, batarya, Şahi (her yer) | −5529, 913 / −5098, 1280 | k1_pazar_K, k1_sahi_G, k1_bat06_K | azap askerlerinin başında parlak kırmızı kesik koni = modern fes (kural 7c "fes yok"; kod yorumu "Modern fes YOK" diyor ama görünüş fes) | scripts/npc/person.gd hat "azap"; ordugah_kisi.gd:BASLIK["azap"] (a8281f) | keçe üsküf/kalpak: sarkık, krem-gri kenarlı, ucu yuvarlak; kırmızıyı kaldır |
| 5 | KUTU | 1 | Esir, mutfak, dökümhane: orta/yakın figürler | −5473, 2485 / −5191, 1807 / −6451, 475 | k2_esir, k2_mutfak_yakin, k2_dokum_yakin | esir ve işçiler prizma gövde + küp baş + düz kolla "oyuncak"; yan yana aynı figür | ordugah_kisi.gd:figur (govde/bas = cyl 6 kenar + box kollar); lod1 | lod 1 figürü de yuvarlak kesitli; baş küre |
| 6 | KUTU | 2 | Otağ avlusu | −5611, 1490 | k2_otag_dis_D, k2_otag_tepe, k2_otag_hava_cap | divan/hazine çadırları düz KIRMIZI hangar kutusu + levha çatı, bir de beyaz uzun sandık | scripts/world/ist/ordugah_otag.gd:build | çadır biçimi (çatma/konik), kenar sarkması, kumaş |
| 7 | ZEMİN | 2 | Çadır kümeleri (tepeden) | −5600, 1100 / −5600, 1700 | k2_hava_merkez_tepe, k2_tepe_genis, k2_tepe_genis2 | oba altındaki "çiğnenmiş zemin" koyu kahverengi çokgen yamalar: köşeli, cetvelle kesilmiş, çevre çimle bıçak çizgisi | ordugah_oba.gd (zem.done "zemin", leke işlevi ~388) | yumuşak kenar, doku geçişi, vertex rengiyle erit |
| 8 | GÖRSEL | 2 | Çadır kumaşı (heryer) | −5400, 1700 | k2_g28_K, k1_siper1380_B | çadır kumaşı üstünde rastgele kırmızı-turuncu benek: pas/küf gibi, her çadırda aynı | ordugah_kit.gd:tent_mesh (doku) | benekleri kaldır; yama/solma, ip dikişi |
| 9 | ZEMİN | 2 | Batarya önü ve çadır arası çimen | −5300, 1000 – −5200, 1400 | k2_g29_D, k2_g30_D, k2_g32_D, k1_otag_K | düz açık yeşil çimde tekrar eden koyu kısa çizgi/damga sıraları (düzenli!), el çizimi gibi | arazi detay damgası (şehir/arazi malzemesi; kaynak ŞÜPHELİ: IstGeo/arazi) | rastgele, sık otlu, çamurlu karışım |
| 10 | BOŞLUK | 2 | Batarya–çadır arası ateş alanı | −5330, 1000 | k2_g29_D, k2_g31_D, k2_bat08_uzak | yüzlerce metre bomboş çayır; siper+hendek arasında insan, top, ateş yok | ordugah.gd:plan (batarya aralığı) | ara batarya, nöbet çiftleri, gülle arabası |
| 11 | MANTIK | 2 | Çadır içleri | −5610, 1300 / −5779, 1848 | k2_g15_D, k2_g15_K, k2_tercuman, k2_otag_dis_K, k1_halil_D | kamera çadırın içine düşünce iç yüz düz koyu lacivert (iç dokusu yok), tepe/dikişlerde gökyüzü sızıyor; kapıda siyah dikdörtgen | ordugah_kit.gd:tent_mesh (içi çizilmemiş yüzler); ŞÜPHELİ: oyuncu içeri girebilir mi (yürüyüş sınaması yok) | çarpışma + iç yüz kumaşı ya da girişi kapat |
| 12 | GÖRSEL | 2 | Siper hattı | −5084, 1151 | k1_siper1380_D, k1_siper1380_K | siperin içi dev düz kahverengi levha yol; gölgede çapraz çizgi ağı; ahşap perde dik kutu | ordugah_yapi2.gd:build_siper | toprak/çamur, fıçı sırası, kazık çiti |
| 13 | DÖNEM | 2 | Siper çevresi, batarya önü | −5136, 889 / −5200, 1000 | k1_siper1380_D, k2_bat08_uzak, k2_hava_batarya_hat | açık mavi, pembe ve parlak beyaz çadırlar: "karnaval" (kural 7c: renkli/parlak beyaz çadır yok) | ordugah_oba.gd palet / ordugah_kit.gd renk tablosu | krem-bej-kıl rengi; pembe/mavi yok |
| 14 | KUTU | 2 | Çimde tek ağaçlar | −5130, 1180 / −5290, 1000 | k1_siper1380_D, k2_g29_D, k1_siper1380_hava | ağaç tacı yeşil oktahedron (elmas) | scripts/world/ist/bitki.gd:tree_mesh | yuvarlak, dağınık yaprak kümesi |
| 15 | KUTU | 3 | Ordu çadırları | −5400, 1700 | k2_g28_D, k2_ahir_yakin2 | beşik çatılı kulübe gibi çadırlar, siyah kapı kutusu, bacalı (BİLİNİYOR; yine de sayıldı) | ordugah_kit.gd:tent_mesh | – |
| 16 | KUTU | 2 | Mescit | −5604, 1163 | k1_mescit_K, k1_mescit_D | düz koyu yeşil levha çatı, duvar düz gri benekli panel; cemaat aynı kafa/aynı poz | ordugah_yapi.gd:build_mescit | kumaş mescit çadırı |
| 17 | KUTU | 3 | Pazar tezgâhları | −5529, 913 | k1_pazar_D, k1_pazar_G | levha çatılı kutu tezgâh, çatıda beyaz dikdörtgen leke dizisi (ışık yuvası gibi) | ordugah_yapi.gd:build_pazar | – |
| 18 | GÖRSEL | 3 | Otağ zokağı | −5611, 1580 | k2_otag_dis_B | düz beyaz duvar, kırmızı benek dokusu (kumaş değil sıva gibi) | ordugah_otag.gd:_zokak | kumaş dokusu, mazgallı üst |
| 19 | KUTU | 2 | Dökümhane | −6451, 475 | k1_dokum_G, k1_dokum_K | siyah düz levha çatılar (gölgesi gibi siyah) | ordugah_yerleske.gd:build_dokumhane | – |
| 20 | PERFORMANS | 1 | Her yer | – | ham/rinfo_*.txt (en kötü: k1_dokum_D 1861 çizim / 5,03 M) | 171 karenin **108'i** yer bütçesini (1 200 çizim / 2,5 M) aşıyor; ort. 2,72 M üçgen | IstOrdugah* + şehir | MultiMesh/LOD |
| 21 | KUTU | 3 | Koyun sürüsü | −6298, 1771 | k2_agil_otag_hava | koyunlar küçük kutu (ŞÜPHELİ, yalnız tepeden bakıldı) | ordugah_yerleske.gd:build_agil, ordugah_oba.gd:_koyun | yakın kare gerekir |
| 22 | GÖRSEL | 3 | Top namlusu | −5200, 951 | k1_bat06_G | namlu düz kereste/boru, yatak kutu; ŞÜPHELİ (yakın tam boy bakılmadı) | ordugah_yapi.gd:_top | – |
| 23 | DÖNEM | 1 | Pembe çadır üstünde | −5100, 1600 | k2_g41_D | **KIRMIZI ZEMİN ÜSTÜNDE BEYAZ AY-YILDIZ (Türk bayrağı) dalgalanıyor**; ordugâhta hilal/yıldız YASAK (§7c) | scripts/world/ist/hayat_veri.gd:622, :623 (otağ iki sancağı) ve :665 (ordugâh çevresi, her kümede 3 sancak): `sancak(..., 0, 1, 3, ...)` stil 3 = hilalli bayrak; `sur4_kare --set=hilal` çıktısı `ISTHILAL sayi=3 hayat_veri.gd:622 hayat_veri.gd:623 hayat_veri.gd:665` (ordugah_oba.gd hilalsiz, sorun orada değil) | bayrağı kaldır, flama düz kırmızı |
| 24 | KUTU | 2 | Siper/sepet duvarı | −5100, 1060 | k2_g38_D, k2_g38_K | kameranın yanında ~5 m yüksekliğinde dikdörtgen kahverengi dev levhalar, tepesinde lacivert kontur çıkıntısı: kutu sütun gibi, ölçeği siperin dışına taşmış | KAYNAK ŞÜPHELİ (ordugah_yapi2.gd:build_siper / ordugah_cephe.gd sepet-tomruk istifi) | sepet (gabion) örgülü silindir, 1–1,5 m |
| 25 | GÖRSEL | 2 | Çadır arası | −5820, 1060 | k2_g10_K | havada yeşil elmas ağaç tacı, gövde yok (gövde çadırın arkasında olabilir; ŞÜPHELİ) | scripts/world/ist/bitki.gd:tree_mesh | taç+gövde birlikte |
| 26 | OYNANIŞ | 2 | Halil Paşa çadırı | −5951, 1158 | k1_halil_K, k1_halil_D (çadır içi) | oyuncu bu noktada önce 12,9 m düştü, sonra araziden 1,75 m ALTTA durdu; 40 takılma, yürüyüş 0 m: kapalı cep (başlangıç noktasını ben çadır içine koydum; gerçek oyuncu girerse aynı) | ordugah_yerleske.gd:build_pasa (zemin/çarpışma) | çadırın içini yürünebilir yap ya da girişi kapat |
| 27 | OYNANIŞ | 3 | Rota boyunca takılmalar | −5704,1491 · −5545,913 · −5078,1153 · −4980,774 · −6290,1750 | ham/olay_yuruyus.txt | otağ zokağı, pazar, siper, ağıl çiti önünde yürüyüş durdu (engel çarpması olabilir; görünmez duvar mı gerçek engel mi ŞÜPHELİ) | ordugah_otag.gd:_zokak, ordugah_yapi.gd:build_pazar, ordugah_yerleske.gd:build_agil | geçit/kapı aç |
| 28 | BOŞLUK | 2 | Gece çadır arası | −5640–−5100, 700–1900 | k3_n_mutfak, k3_n_bat_hava, pafta_gece_00 | gece oba aralarında ateş yok, çadırlar siyah levha; yalnız mutfak ve otağ çevresinde birkaç ateş (BİLİNİYOR: ORDUGÂH-5) | ordugah_oba.gd:K.ateslar çağrısı | her obada ocak + parıltı |
| 29 | GÖRSEL | 2 | Gece pembe/açık mavi çadırlar | −5700, 900 | k3_n_otag_dis, pafta_gece_00 (ilk kare) | açık mavi-beyaz çadır gece kendi kendine parlıyor (ışıyan yanlış yüzey) | ordugah_kit.gd renk/palet (gece materyal) | gece koyulaşan matlık |

## 4. Sayım
KUTU 12 · GÖRSEL 6 · ZEMİN 2 · MANTIK 1 · DÖNEM 3 · BOŞLUK 2 · OYNANIŞ 2 · PERFORMANS 1 = 29 bulgu (ŞÜPHELİ işaretliler: 9 kaynak, 11, 21, 22, 24 kaynak, 25, 26, 27). **KUTU kalan=12** (hedef 0). Hedef 40 bulguya ulaşılamadı: yeterli ızgara/yürüyüş koşulamadı (§7).

## 5. En kötü 12 kare
1 k2_agil_otag_yakin (kutu öküz) · 2 k2_hayvan_ahir_yakin (kutu deve) · 3 k1_sahi_G (fes + elmas gülle) · 4 k1_bat06_K (fes + gülle) · 5 k2_esir (kutu insan) · 6 k2_otag_dis_D (kırmızı hangar) · 7 k2_g15_D (çadır içi düz lacivert) · 8 k2_hava_merkez_tepe (çokgen yamalar) · 9 k2_g29_D (damga + boş çayır) · 10 k1_siper1380_D (dev levha yol + elmas ağaç) · 11 k2_bat08_uzak (pembe/mavi çadır) · 12 k1_mescit_K.

## 6. İYİ olan 5 kare
k1_pazar_D (tezgâhlar, insanlı, canlı) · k1_barut_hava / k1_bat06_hava (hat boyu siper ve nöbetçiler yaşam dolu) · k2_ateş_yakin (kazan sırası, alev, taş kaide) · k2_tepe_genis (sur karşısı bütün çadır denizi + bataryalar: siluet iyi) · k1_siper1380_K (sur+kazık+nöbetçi).

## 7. Bakamadıklarım / YAPILMADI (dürüst liste)
- 60 m ızgara / 4 yön YAPILMADI (180 m, 2 yön); 15 m'de bir yol karesi YOK; 120 m'de bir çapraz hava karesi YOK (hava 12 kare kadar).
- Yürüyüş 849 m (<1,2 km); düşme/takılma/kapalı cep sayıları yaklaşık; "duvardan geçme" ve "görünmez duvar" ayrımı kareyle doğrulanmadı.
- Paftalar g_07, g_09 ve gece_01, gece_02 incelenmedi.
- Bulgu 9 (zemin damgası) ve 24 (levha) için kaynak dosya kanıtsız; düğüm adı `--set=kim` ile alınmadı.
- Gece karelerinde ateş sayımı yapılmadı; yalnız görsel.
- Bu rapor oyun kodunu değiştirmez; `git status` yalnız Godot'un ürettiği .import/.uid/.translation dosyalarını gösterir (kaydedilmedi).
