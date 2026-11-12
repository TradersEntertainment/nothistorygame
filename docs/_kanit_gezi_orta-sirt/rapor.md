# İstanbul v2 gezi denetimi — `orta-sirt` (İLK GÖNDERİM, ara rapor)

> Durum: ilk gönderim. Izgara (B) ve gece (N) koşuları sürüyor; son rapor bu dosyanın üstüne yazılacak.
> Oyun kodu DEĞİŞTİRİLMEDİ (yalnız `tests/_ist/gezi_orta-sirt.*` ve bu klasör).

## 1. Bölge, kare sayıları, yürüyüş
- Bölge sınırı (gerçek m, Ayasofya=0,0): GB (-4000, 800) · GD (-1700, 800) · KD (-1700, 2350) · KB (-4000, 2350).
  İçindeki yapılar: Bozdoğan Kemeri (-2460,1000 → -1600,730), Havariyun (-2394,1156), Pantokrator (-2016,1212),
  Lips (-2604,878), Pammakaristos (-2730,2213), Aspar (-2705,1930) ve Aetios (-3335,1880) sarnıç bostanları.
- Bu ara raporda çekilen/bakılan: **A koşusu 149 / 149** (kemer boyunca 44, yapı halkaları 8+4 kare × 7 yer, 20 m/60 m çapraz ve
  tam tepe × 7 yer + 3×3 pafta hâlinde hepsine baktım; şüpheli ~6 kareyi tam boy açtım). Tam boy bakılanlar kare/ klasöründe.
- Yürüyüş (gerçek `player.gd`, başsız, `tests/_ist/gezi_orta-sirt.gd mod=yuru`): 6 rota, **1364 gerçek m (477 dünya m)**.
  Olay özeti (ham: `ham_yuruyus_olaylar.txt`): kemer altı 0 olay (475 m); Havariyun→Pantokrator TAKILMA (-2311,1138);
  Pammakaristos TAKILMA (-2711,2235),(-2704,2247); Aspar bostanı girişinde TAKILMA (-2780,1930); Aetios bostanı TAKILMA
  (-3255,1877); Lips sokağı TAKILMA (-2684,879),(-2643,876). Düşme/boşluk/su: 0. Takılmaların hepsi doğrultu çizgisi üstündeki
  bir yapıya/duvara çarpma; nedenleri C koşusu karelerinden (`takilma*`) çıkarılacak (son raporda).

## 2. GENEL NOT: 3/10
Sahibi bu bölgeyi gezse ilk Bozdoğan Kemeri'ne kızar: ayakları kâğıt levha, üst katı havada, ucu hiçbir yere çıkmayan basamak.
Sonra bostan/sarnıç alanlarındaki düz açık-yeşil levha tarhlara ("kare kare") ve her yerdeki beyaz/pembe-mor oyuncak ağaçlara,
üçüncü olarak toprak üstündeki keskin köşeli çim yamalarına ve somon-pembe/lacivert oyuncak renkli kiliselere kızar.

## 3. BULGU TABLOSU (ilk 21)
| no | tür | önem | yer adı | doğu, kuzey (kamera) | kare dosyası | ne görünüyor | kaynak | öneri |
|---|---|---|---|---|---|---|---|---|
| 1 | GÖRSEL/KUTU | 1 | Bozdoğan Kemeri (ayaklar) | -2125, 865 | kare/kemer_g06.jpg | Kemer ayaklarının yanlarında kalınlıksız, kıvrık/çapraz ince LEVHA kanatlar çıkıyor; ayak taş kütlesi değil kâğıt perde gibi okunuyor, kanatlar arada havada bitiyor (kemer_g01/g02/k02'de kıvrık levha uçları belirgin). | scripts/world/ist/kemer_su.gd:bay_mesh (yan duvar/payanda yüzeyi) + build_bozdogan tier1 MultiMesh | bay_mesh'te yan yüzleri kapalı, kalınlıklı payanda (kama) olarak kur; çıplak levha uçlarını kapat |
| 2 | GÖRSEL | 1 | Bozdoğan Kemeri (üstten/alttan) | -2123, 873 | kare/kemer_ust06.jpg | 20 m yükseklikten kemer ayakları TESTERE DİŞİ/basamaklı zikzak yığını gibi görünüyor, ayaklar düz sıra değil; kemer tonozları ayakların önünde yarım silindir levha olarak asılı duruyor. | kemer_su.gd:bay_mesh (segs=8 tonoz) + _deck | Ayak kesitini düz dikdörtgen tut; tonoz ile ayak aynı gövdeden çıksın |
| 3 | GÖRSEL | 1 | Bozdoğan Kemeri (üst kat) | -2411, 955 | kare/kemer_g01.jpg | İkinci kat kemerleri alt katın ÜSTÜNDE yana kaymış/ayrık duruyor; alt-üst kat arasında ve üstte eğik levhalar (döşeme) havada: yapı iki ayrı parça gibi. | kemer_su.gd:build_bozdogan (tier2 Transform3D(xc,h1,0)) ve _deck slab_x | Tier2 ayaklarını tier1 ayak eksenine hizala; döşeme levhasını kat taşıyıcısına otursun |
| 4 | GÖRSEL | 1 | Bozdoğan Kemeri (üst kat, alttan) | -2294, 927 | kare/kemer_ust03.jpg | Kemerin üstünden bakınca üst döşeme ve ayak yığını birbirinin içine girmiş, iki farklı yükseklikte kesişen levhalar; alt kemerler görünüyor, üstte beyazımsı döşeme parçaları kopuk. | kemer_su.gd:_deck, _ends | Döşeme ile ayak tepesini tek yüzey yap, levhaları birleştir |
| 5 | MANTIK | 2 | Bozdoğan Kemeri batı ucu | -2452, 1027 | kare/kemer_k00.jpg | Kemerin ucunda taş BASAMAK yığını: dik basamaklı, çıplak üçgen blok; hiçbir yere çıkmıyor, üstündeki döşeme yarım levha olarak havada. Yanında kutu gibi yığın. | kemer_su.gd:_ends / kemer.gd:climbs_bozdogan | Uca anlamlı çıkış (merdiven kapısı/ana kanal), ya da kemer yamaca gömülsün |
| 6 | GÖRSEL | 3 | Bozdoğan Kemeri (uzak katman) | -2016, 1212 | kare/pantokrator_tepe.jpg | Tam tepeden kemer saf krem-BEYAZ, dokusuz ince çubuk (uzak LOD); yanındaki yapılar renkli, bu çıplak düz şerit göze batıyor. | kemer_su.gd:_build_far (wall_mat/deck_mat, KIT.multi BoxMesh) | Uzak LOD'a şerit/taş rengi ver, çıplak kutu gövde yerine koyulaştır |
| 7 | KUTU | 1 | Aspar sarnıcı bostanı (tarhlar) | -2705, 2010 | kare/aspar_000.jpg | Bostan tarhları düz açık-YEŞİL LEVHA/DİLİM şeritleri: parlak, dokusuz, keskin köşeli; bitki değil beton kaldırım gibi. Sahibin 'kare kare' dediği şey. | scripts/world/ist/bitki_yama.gd:patch("bostan") / dunya.gd:_parsel (alt=bostan) | Tarhı toprak zemin + sıra sıra yuvarlak sebze/yaprak öbekleri yap; levha kaldır |
| 8 | KUTU | 1 | Aspar sarnıcı bostanı (tarh yakın) | -2648, 1873 | kare/aspar_135.jpg | Yakından tarhlar bir yığın düz yeşil BLOK sıra (basamak gibi), aralarda pembe toprak şeridi; kenarlar jilet gibi. | bitki_yama.gd:patch (bostan satırı) | aynı |
| 9 | ZEMİN/MANTIK (ŞÜPHELİ: sarnıç yorumu) | 2 | Aspar bostanı çevresi | -2705, 1866 | kare/aspar_h20.jpg | Havadan: sarnıç bostanı dikdörtgen yeşil çerçeve duvar + düz çizgili tarhlar; çevresinde çıplak dikdörtgen: şehrin ortasında 'cetvelle kesilmiş' kutu bahçe, sarnıç (su) hissi yok. | dunya.gd:~407 ('sarnic' → _parsel bostan) + bitki_yama.gd | Sarnıç = su yüzeyi/kapak + etrafa taş sıra; bostan ayrı küçük parsel |
| 10 | KUTU | 2 | Aetios sarnıcı bostanı (meyve) | -3399, 1816 | kare/aetios_225.jpg | Ağaçlar tek bir yassı yeşil DİSK/küre-lolipop (çubuk üstünde düz tepsi) sıralanmış; ızgara dizili aynı ağaç, doğal değil. | scripts/world/ist/bitki.gd:add_blob / tree_mesh (bağ/meyve) ; bitki_yama.gd | Ağaç tacı düzensiz çok-küre, boyu/rengi farklı, ızgara kırık |
| 11 | KUTU/GÖRSEL | 2 | Aetios sarnıcı | -3376, 1880 | kare/aetios_yakin_270.jpg | Toprak üstünde kenarı çizgi-çizilmiş (siyah kontur) yassı yeşil küreler + mavi su arığı düz şerit; sulama kanalı çıplak parlak mavi levha. | bitki_yama.gd:patch bostan (dere/kanal şeridi) | Kanal çamurlu kenarlı, koyu su; sebze bitkisi yaprak formu |
| 12 | KUTU | 2 | Lips (Fenari İsa) önü meydan | -2604, 913 | kare/lips_000.jpg | Ağaçlar BEYAZ, bembeyaz çokgen yığın (parlak, siyah konturlu): ağaç değil buruşmuş kâğıt; gövdesi de beyaz silindir. Aynı beyaz ağaç Pantokrator ve Havariyun karelerinde de. | bitki.gd:tree_mesh (badem/kiraz tacı rengi, add_blob) | Beyaz yerine soluk pembe-krem çiçek rengi, kümeli çiçek noktaları, yaprak dokusu, kontur kaldır |
| 13 | GÖRSEL (ŞÜPHELİ) | 3 | Lips meydanı | -2604, 850 | kare/lips_h20.jpg | Havadan beyaz, parlak 'sivri külah' ve sütun üstünde beyaz taç: ışık patlamış, dokusuz; çevredeki taş yapılarla uyumsuz. | scripts/world/ist/ayrinti_api.gd (sütun/anıt) – düğüm: beyaz külah | Anıta taş/mermer dokusu ve ton ver |
| 14 | KUTU | 2 | Havariyun, Pantokrator ve nekropol çalıları | -2394, 1201 | kare/havariyun_000.jpg | Yerde krem ve yeşil açılı KATLANMIŞ LEVHALAR (çalı/ot diye dizilmiş): kutu çalı, kâğıt kıvrımı gibi. | bitki.gd:add_box (çalı/çit) / bitki_yama.gd:cit | Çalıyı küre kümeleri + yaprak dokusu yap; add_box'ı çalıdan çıkar |
| 15 | KUTU | 2 | Havariyun nekropolü | -2450, 1080 | kare/nekropol_180.jpg | Zemin üstünde düz yeşil bloklar ve gri levha: bahçe/çalı yerine koyu yeşil kutular; mezar taşı yok. | bitki.gd:add_box | Mezar taşı/kemik ocağı gibi dönem ögeleri koy, bloklar kalksın |
| 16 | ZEMİN | 2 | Pammakaristos çevresi sokakları | -2755, 2188 | kare/pammakaristos_225.jpg | Kumlu toprak zemin üstünde yeşil çim YAMALARI keskin köşeli çokgen (poligon kesimi) ve çevresi düz düşmüş; kaldırım taş hattı da çokgen basamaklı. | scripts/world/ist/dunya.gd:_parsel / sehir.gd ZEMİN yama (sur_zemin.gd) | Yama kenarını gürültüyle yumuşat, ot-toprak geçişi serpiştir |
| 17 | ZEMİN | 2 | Pantokrator manastırı çevresi | -2061, 1212 | kare/pantokrator_270.jpg | Duvar dibinde yeşil-mavi dikdörtgen yamalar (koyu cam yeşili) taş duvarla zemin arasında; kumlu zemin üstünde açık bıçak-kenarlı lekeler. | dunya.gd:_parsel / sur_zemin.gd | aynı |
| 18 | GÖRSEL | 2 | Pammakaristos (yapı) | -2730, 2185 | kare/pammakaristos_h20.jpg | Manastır duvarı ve çatılar SOMON-PEMBE (oyuncak doygunluğu), kubbeler siyaha yakın lacivert; avlu dörtgen çerçeve: Bizans taşı/tuğlası değil. | scripts/world/ist/kuzeybati_kilise.gd:build_pammakaristos | Tuğla soluk kırmızı-kahve, kurşun kubbe gri-yeşil, taş şerit |
| 19 | GÖRSEL | 2 | Havariyun Kilisesi | -2401, 1199 | kare/nekropol_045.jpg | Kubbe gövdesinde kırmızı tuğla + somon-pembe pilastr şeritler, tepede GRİ üçgen LEVHA (huni gibi) dışarı fırlamış; kubbeler açık mavi-gri şemsiye gibi. | scripts/world/ist/kemer.gd:build_havariyun | Gri levhayı kaldır/payanda yap; kubbe kurşun grisi, pilastr tuğla tonu |
| 20 | GÖRSEL | 2 | Pantokrator manastırı | -2016, 1144 | kare/pantokrator_h60.jpg | Üç kubbeli yapı açık somon + pastel mavi: oyuncak, ahşap boyalı gibi; Pantokrator'un üç kilise kütlesi okunmuyor. | scripts/world/ist/kemer.gd:build_pantokrator (+kemer_harabe.gd:build_pantokrator_court) | aynı palet düzeltmesi |
| 21 | GÖRSEL | 2 | Pantokrator duvarları | -1971, 1212 | kare/pantokrator_090.jpg | Duvar dokusu aşırı gerilmiş: dikey ince şeritli sisli kare dilimler (mip bulanık), taş okunmuyor. | kemer_harabe.gd:build_pantokrator_court (duvar malzemesi, UV) | UV'yi duvar boyutuyla ölçekle |

## 4. Sayım
(son raporda)

## 5–7
(son raporda; kare/ ve pafta_A_* dosyaları bu gönderimde)
