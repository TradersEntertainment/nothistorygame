# İstanbul v2 gezi denetimi — `orta-sirt` (SON RAPOR)

Oyun kodu DEĞİŞTİRİLMEDİ: yalnız `tests/_ist/gezi_orta-sirt.gd/.tscn` (ızgara listesi, gerçek-oyuncu yürüyüşü, açık-zemin bulucu) ve bu klasör.

## 1. Bölge, kare ve yürüyüş sayıları
- **Sınır (gerçek m, Ayasofya 0,0):** GB (-4000, 800) · GD (-1700, 800) · KD (-1700, 2350) · KB (-4000, 2350).
  Yapılar: Bozdoğan Kemeri (-2460,1000→-1600,730), Havariyun (-2394,1156), Pantokrator (-2016,1212), Lips (-2604,878),
  Pammakaristos (-2730,2213), Aspar (-2705,1930) ve Aetios (-3335,1880) sarnıç bostanları, Lykos vadisi mahalleleri.
- **Çekilen 620 kare:** A yapı/kemer koşusu 149 (`liste_A_yerler_havadan.txt`), B ızgara + takılma 329 (150 m ızgara, 316 yer kare
  + 13 takılma karesi), D kaydırılmış 41 + hava 48 = 89, N gece 53. 
- **Bakılan:** A 149/149, B 329/329 (paftalarla; 316 ızgara karesinin hepsi 4×3 paftada açıldı, şüpheliler tam boy),
  D hava 48/48, D kaydırılmış **36/41** (5 kareye bakılmadı), N gece 53/53. Toplam bakılan 615/620.
- **Izgara adımı: 150 m** (görevdeki 60 m DEĞİL, 80 m de değil): bölge 2300×1550 m; 60 m ızgara ~1000 düğüm × 4 yön = 4000 kare
  = ~8 saat, süreye sığmaz. Ünlü yapılar çevresinde ayrıca 8+4 kare + 20/60 m + tam tepe yapıldı. Her ızgara düğümünde 2 yön
  (4 değil; sıra dönüşümlü K-G/D-B). Gece: her üçüncü düğümün yarısı, 1 yön. Bu yüzden "karış karış" kapsama TAM değil; raporu
  ona göre oku.
- **Yürüyüş (gerçek `player.gd`, başsız):** 6 rota, **1364 gerçek m** (≥ 1,2 km ✔). Ham: `ham_yuruyus_olaylar.txt`.
  Düşme 0, suya girme 0, havada kalma (boşluk) 0. **TAKILMA 46 kayıt, 7 ayrı nokta** (aynı noktada tekrar eden bekleme):
  (-2311,1138) Havariyun→Pantokrator, (-2711,2235) ve (-2704,2247) Pammakaristos, (-2780,1930) Aspar bostanı girişi,
  (-3255,1877) Aetios bostanı, (-2684,879) ve (-2643,876) Lips sokağı. Karelerinde (`takilma*`) hedef doğrultusunda ev/bostan
  duvarı görünüyor: düz çizgi yürüyüşü bina/duvara çarpıyor; "çıkılamayan basamak"/"görünmez duvar" AYIRT EDEMEDİM
  (kare ile doğrulayabildiğim: kapı/geçit görünmeyen bostan duvarı, bulgu 'Aspar bostanı batı yanı'). Kapalı cep: oyuncu ızgarada
  bina içine konulabiliyor (bulgu 'bina içleri'); cebi sayısal ölçmedim.
- **Performans (RINFO, 556 kare, `ham_rinfo_all.txt`):** yer 486 karede en çok çizim 1612 (bütçe 1 200 → 24 karede aşım),
  üçgen en çok 3,69 M (bütçe 2,5 M → **240 karede, %49 aşım**); uçuş/hava 70 karede aşım YOK (en çok 1 061 / 3,30 M).
  Kare süresi ~1,4–2,7 sn (yazılımla çizim; anlamlı değil). Kurulum 528–631 ms.
- **Kısıt:** `--import` süresi ve tek ekranlı koşu yüzünden: ızgara 60 m değil 150 m; havadan 20 m çapraz kare yalnız yapı
  halkalarında; 120 m'de bir çapraz ve ızgarasız gezgin kameralar YAPILMADI.

## 2. GENEL NOT: 3/10
Sahibi bu bölgeyi gezse ilk **bostan/sarnıç parsellerine** kızar: Aspar ve Aetios'ta yerden ufka kadar parlak mint-yeşil
şeritler, havadan kalın beyaz çerçeveli yeşil "dama tahtası" kutular: sahibin "kare kare"sinin tıpkısı.
İkincisi **Bozdoğan Kemeri**: ayaklar kâğıt levha kanatlı, üst kat yana kaymış ve havada eğik tahta bant, ucu hiçbir yere çıkmayan basamak.
Üçüncüsü **evlerin içi lacivert boşluk** ve **keskin köşeli çim/toprak yamaları, beyaz-mor-pembe oyuncak ağaçlar**; kiliseler somon-pembe/açık mavi.

## 3. BULGU TABLOSU (72 bulgu; ŞÜPHELİ işaretliler kaynak ya da yorum emin değil)
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
| 9 | ZEMİN/MANTIK | 2 | Aspar bostanı çevresi | -2705, 1866 | kare/aspar_h20.jpg | Havadan: sarnıç bostanı dikdörtgen yeşil çerçeve duvar + düz çizgili tarhlar; çevresinde çıplak dikdörtgen: şehrin ortasında 'cetvelle kesilmiş' kutu bahçe, sarnıç (su) hissi yok. | dunya.gd:~407 ('sarnic' → _parsel bostan) + bitki_yama.gd | Sarnıç = su yüzeyi/kapak + etrafa taş sıra; bostan ayrı küçük parsel |
| 10 | KUTU | 2 | Aetios sarnıcı bostanı (meyve) | -3399, 1816 | kare/aetios_225.jpg | Ağaçlar tek bir yassı yeşil DİSK/küre-lolipop (çubuk üstünde düz tepsi) sıralanmış; ızgara dizili aynı ağaç, doğal değil. | scripts/world/ist/bitki.gd:add_blob / tree_mesh (bağ/meyve) ; bitki_yama.gd | Ağaç tacı düzensiz çok-küre, boyu/rengi farklı, ızgara kırık |
| 11 | KUTU/GÖRSEL | 2 | Aetios sarnıcı | -3376, 1880 | kare/aetios_yakin_270.jpg | Toprak üstünde kenarı çizgi-çizilmiş (siyah kontur) yassı yeşil küreler + mavi su arığı düz şerit; sulama kanalı çıplak parlak mavi levha. | bitki_yama.gd:patch bostan (dere/kanal şeridi) | Kanal çamurlu kenarlı, koyu su; sebze bitkisi yaprak formu |
| 12 | KUTU | 2 | Lips (Fenari İsa) önü meydan | -2604, 913 | kare/lips_000.jpg | Ağaçlar BEYAZ, bembeyaz çokgen yığın (parlak, siyah konturlu): ağaç değil buruşmuş kâğıt; gövdesi de beyaz silindir. Aynı beyaz ağaç Pantokrator ve Havariyun karelerinde de. | bitki.gd:tree_mesh (badem/kiraz tacı rengi, add_blob) | Beyaz yerine soluk pembe-krem çiçek rengi, kümeli çiçek noktaları, yaprak dokusu, kontur kaldır |
| 13 | GÖRSEL | 3 | Lips meydanı | -2604, 850 | kare/lips_h20.jpg | Havadan beyaz, parlak 'sivri külah' ve sütun üstünde beyaz taç: ışık patlamış, dokusuz; çevredeki taş yapılarla uyumsuz. | scripts/world/ist/ayrinti_api.gd (sütun/anıt) – düğüm: beyaz külah | Anıta taş/mermer dokusu ve ton ver |
| 14 | KUTU | 2 | Havariyun, Pantokrator ve nekropol çalıları | -2394, 1201 | kare/havariyun_000.jpg | Yerde krem ve yeşil açılı KATLANMIŞ LEVHALAR (çalı/ot diye dizilmiş): kutu çalı, kâğıt kıvrımı gibi. | bitki.gd:add_box (çalı/çit) / bitki_yama.gd:cit | Çalıyı küre kümeleri + yaprak dokusu yap; add_box'ı çalıdan çıkar |
| 15 | KUTU | 2 | Havariyun nekropolü | -2450, 1080 | kare/nekropol_180.jpg | Zemin üstünde düz yeşil bloklar ve gri levha: bahçe/çalı yerine koyu yeşil kutular; mezar taşı yok. | bitki.gd:add_box | Mezar taşı/kemik ocağı gibi dönem ögeleri koy, bloklar kalksın |
| 16 | ZEMİN | 2 | Pammakaristos çevresi sokakları | -2755, 2188 | kare/pammakaristos_225.jpg | Kumlu toprak zemin üstünde yeşil çim YAMALARI keskin köşeli çokgen (poligon kesimi) ve çevresi düz düşmüş; kaldırım taş hattı da çokgen basamaklı. | scripts/world/ist/dunya.gd:_parsel / sehir.gd ZEMİN yama (sur_zemin.gd) | Yama kenarını gürültüyle yumuşat, ot-toprak geçişi serpiştir |
| 17 | ZEMİN | 2 | Pantokrator manastırı çevresi | -2061, 1212 | kare/pantokrator_270.jpg | Duvar dibinde yeşil-mavi dikdörtgen yamalar (koyu cam yeşili) taş duvarla zemin arasında; kumlu zemin üstünde açık bıçak-kenarlı lekeler. | dunya.gd:_parsel / sur_zemin.gd | aynı |
| 18 | GÖRSEL | 2 | Pammakaristos (yapı) | -2730, 2185 | kare/pammakaristos_h20.jpg | Manastır duvarı ve çatılar SOMON-PEMBE (oyuncak doygunluğu), kubbeler siyaha yakın lacivert; avlu dörtgen çerçeve: Bizans taşı/tuğlası değil. | scripts/world/ist/kuzeybati_kilise.gd:build_pammakaristos | Tuğla soluk kırmızı-kahve, kurşun kubbe gri-yeşil, taş şerit |
| 19 | GÖRSEL | 2 | Havariyun Kilisesi | -2401, 1199 | kare/nekropol_045.jpg | Kubbe gövdesinde kırmızı tuğla + somon-pembe pilastr şeritler, tepede GRİ üçgen LEVHA (huni gibi) dışarı fırlamış; kubbeler açık mavi-gri şemsiye gibi. | scripts/world/ist/kemer.gd:build_havariyun | Gri levhayı kaldır/payanda yap; kubbe kurşun grisi, pilastr tuğla tonu |
| 20 | GÖRSEL | 2 | Pantokrator manastırı | -2016, 1144 | kare/pantokrator_h60.jpg | Üç kubbeli yapı açık somon + pastel mavi: oyuncak, ahşap boyalı gibi; Pantokrator'un üç kilise kütlesi okunmuyor. | scripts/world/ist/kemer.gd:build_pantokrator (+kemer_harabe.gd:build_pantokrator_court) | aynı palet düzeltmesi |
| 21 | GÖRSEL | 2 | Pantokrator duvarları | -1971, 1212 | kare/pantokrator_090.jpg | Duvar dokusu aşırı gerilmiş: dikey ince şeritli sisli kare dilimler (mip bulanık), taş okunmuyor. | kemer_harabe.gd:build_pantokrator_court (duvar malzemesi, UV) | UV'yi duvar boyutuyla ölçekle |
| 22 | GÖRSEL/KUTU | 2 | Aspar bostanı (duvar ve tarh) | -2790, 1930 | kare/takilma3_aspar_ust.jpg | Bostan duvarının üstü geniş, parlak açık-YEŞİL düz levha kapak; içte tarhlar yeşil-pembe çizgili düz boya şerit. Kutu bahçe, toprak/bitki yok. | bitki_yama.gd:patch("bostan") (+ bahce_duvari) | Duvar kapağı taş/kiremit; tarhlar toprak yığını + bitki |
| 23 | MANTIK (ŞÜPHELİ) | 2 | Aspar bostanı batı yanı | -2784, 1930 | kare/takilma3_aspar_ileri.jpg | Gerçek oyuncu doğudan bostana yürürken (-2780,1930)'da takıldı; kareden duvar kesintisiz görünüyor, kapı/geçit YOK (üst karede de batı duvarında açıklık görmedim). | bitki_yama.gd:patch bostan çevre duvarı / dunya.gd:_parsel | Her bostan yanında kapı/boşluk ekle; ham olay: ham_yuruyus_olaylar.txt |
| 24 | KUTU | 2 | Lips meydanı (beyaz koni/ağaç) | -2652, 876 | kare/takilma5_lips_ust.jpg | ~20 m boyunda saf BEYAZ sivri koni (servi?) + beyaz çokgen ağaçlar, kâğıt parçası gibi beyaz benekli; yeşil olması gereken koni yanmış gibi. Aynı beyaz koni g_-3150_800_270'te de var. | bitki.gd:tree_mesh / add_blob (renk=beyaz tür) — ŞÜPHELİ (düğüm adı kesin değil) | Servi koyu yeşil, badem açık pembe-krem; beyaz tür paletini düşür |
| 25 | KUTU | 3 | Kuzeybatı mahalle (Lykos vadisi) | -3150, 800 | kare/g_-3150_800_090.jpg | Yakın ağaç tacı iri düz-gölgeli (flat) çokgen: her yüz tek renk, siyah kontur; oyuncak elmas gibi. | bitki.gd:add_blob (seg/rings düşük, jitter) | Yüz sayısını artır, kenar normallerini yumuşat, kontur kaldır |
| 26 | ZEMİN | 2 | Lykos vadisi sokakları | -3600, 1100 | kare/g_-3600_1100_000.jpg | Kumlu toprakla koyu çim arasında düz doğrusal 'cetvel' kenarlı yamalar; sokak üstünde poligon basamaklar. Yapı dibinde de zikzak kesim (g_-3900_1550_090, g_-3900_1400_180). | dunya.gd:_parsel / sur_zemin.gd (yama kenarı) | Yama kenarını gürültü + serpiştirmeyle karıştır, ot-toprak geçişi yumuşak |
| 27 | GÖRSEL | 3 | Bahçe duvarları (genel) | -3900, 1250 | kare/g_-3900_1250_270.jpg | Duvar tepesi kapağı mint/camgöbeği-yeşil levha (taş değil); gölgede camgöbeği. Pantokrator'da da aynı (pantokrator_045). | duvar kapağı malzemesi (bahçe duvarı) — kemer_harabe.gd / bitki_yama.gd:bahce_duvari | Kapak taş-krem, gölgesi sıcak |
| 28 | BOŞLUK | 2 | Aetios sarnıcı güneyi (sur dibi) | -3450, 2000 | kare/g_-3450_2000_090.jpg | Dümdüz nesnesiz çim: ağaç, çit, yapı, insan yok; ufukta sur ve birkaç ev. Sahibin 'boş alan istemiyorum'u. | dunya.gd:mahalle türü 'kir/cayir' (yoğunluk 0) | Tarla/bostan parseli, ağıl, kulübe, ağaç grupları ve insan ekle |
| 29 | BOŞLUK | 2 | Lykos vadisi sokakları (kişisiz) | -3750, 1550 | kare/g_-3750_1550_000.jpg | Sokak boş: ne insan ne hayvan; birden çok karede (g_-3750_1250_180, g_-3900_1100_000, g_-3600_1550_270) aynı. Yalnız bir kaç karede insan var (g_-3600_1700_000, g_-3900_1700_180). | dunya.gd / ayrinti_sokak.gd (yaşam yoğunluğu) | Sokak başına en az 3-4 kişi/hayvan, tezgâh |
| 30 | KUTU | 3 | Mahalle bahçeleri | -3300, 1700 | kare/g_-3300_1700_000.jpg | Yerde parlak sarı-yeşil çizgi levhalar (çalı/ot yerine yassı şerit); g_-3600_1550_090'da yeşil basamak kutular, takilma4_aetios_ust'ta V şeklinde sarı-yeşil katlanmış levhalar. | bitki.gd:add_box / bitki_yama.gd:cit | Çalı küre kümeleri |
| 31 | GÖRSEL | 2 | Kuzeybatı sur arası (peribolos) | -3900, 2300 | kare/g_-3900_2300_000.jpg | Sur arasında HAVADA duran siyah kalas zinciri ve yeşil yaprak/ot parçaları (sarmaşık?) duvardan kopuk uçuyor; zemin düz gri-beyaz dokusuz. | bitki_yama.gd:sarmasik (harabe duvarı) / sur_zemin.gd — ŞÜPHELİ kaynak | Parçaları duvara yapıştır; zemine toprak/çakıl dokusu |
| 32 | GÖRSEL | 3 | Pazar tezgâhları (Aetios kuzeyi, Lykos) | -3450, 2300 | kare/g_-3450_2300_090.jpg | Parlak turuncu-kiremit düz tente/levha; oyuncak doygunluğu (g_-3900_1550_270'te dev turuncu sütun-tente). | tezgâh/tente malzemesi — düğüm: pazar tentesi | Soluk kırmızı-kahve |
| 33 | GÖRSEL | 3 | Aetios bostanı | -3300, 1850 | kare/g_-3300_1850_270.jpg | Macenta/fuşya ve beyaz ağaçlar + parlak mavi kanal: palet oyuncak. | bitki.gd:tree_mesh (erguvan/badem renkleri) | Erguvan koyu mor-kahve, çiçek noktalı |
| 34 | GÖRSEL | 3 | Teras çatılar (genel) | -2652, 876 | kare/takilma5_lips_ust.jpg | Teras ev çatılarında parlak limon-yeşili düz levhalar (çardak/tente?): sağda üç adet. | ev çatı eki — düğüm: teras tentesi | Hasır/kamış doku, soluk renk |
| 35 | MANTIK (ŞÜPHELİ) | 3 | Havariyun nekropolü | -2401, 1199 | kare/nekropol_045.jpg | Nekropol (mezarlık) olarak tanımlı alanda mezar/stel görünmüyor; tezgâh ve döşeli meydan var. | geo.gd:MAH_OZEL 'Havariyun nekropolü' (alt=mezarlik) | Mezar taşı/sütun parçaları |
| 36 | KUTU/GÖRSEL | 2 | Havariyun doğusu (kırmızı tuğla kütleleri) | -2550, 1100 | kare/g_-2550_1100_090.jpg | Çatısız, basamaklı, çıplak KIRMIZI tuğla duvar blokları ve yerde koyu mor/bordo kutu; teal döşeme üstünde: yapı değil istif gibi okunuyor, ne olduğu belli değil. | scripts/world/ist/kemer_harabe.gd (Havariyun harabeleri) — ŞÜPHELİ düğüm | Harabe duvara çatlak/yıkık tonoz/sarmaşık; mor kutuyu kaldır/taş sanduka yap |
| 37 | GÖRSEL | 1 | Bozdoğan Kemeri (yandan) | -2400, 950 | kare/g_-2400_950_090.jpg | Yan görünüşte kemerin üst katı iki yana eğik tahta döşeme gibi çıkıntı yapıyor; ayaklar ile eğik levhalar birbirine bağlı değil, alt katın yanından kopuk bant. | kemer_su.gd:_deck (slab_x eğimli levha, DECK_W) / tier2 | Döşeme genişliği = ayak derinliği; kenar çıkıntısını kaldır |
| 38 | GÖRSEL | 3 | Fener/Petra sırtı | -2400, 2300 | kare/g_-2400_2300_000.jpg | Gri taş duvarda parlak turuncu yatay şerit (boya gibi); oyuncak doygunluğu. | ev/duvar şerit malzemesi (turuncu hatıl) — düğüm: duvar şeridi | Tuğla hatıl soluk kırmızı-kahve |
| 39 | MANTIK (ŞÜPHELİ) | 3 | Pammakaristos avlusu | -2850, 2300 | kare/g_-2850_2300_270.jpg | Kaldırım taşlı avluda tek başına duran turuncu kapı çerçevesi (iki direk + lento), duvarsız; ne kapısı belli değil. | kuzeybati_kilise.gd:build_pammakaristos (avlu kapısı) — ŞÜPHELİ | Duvar/kapı bağlantısı kur ya da kaldır |
| 40 | MANTIK/GÖRSEL | 1 | Bütün mahalle (bina içleri) | -2250, 800 | kare/g_-2250_800_090.jpg | Izgara noktasının ~%20'si bina İÇİNE düşüyor (g_-2850_1250_000, g_-2700_800_000, g_-2250_800_090 ...): içeride duvarlar boş koyu-LACİVERT yüzey (iç yüz kaplaması yok, ışık yok), tavan dokulu; kapı ağzından bakınca da kapılar lacivert boşluğa açılıyor. Oyuncu girerse kapkara/lacivert kutu odada kalır. | evler.gd / ayrinti_sokak.gd (ev gövdesi iç yüzleri: tek yüz kutu, arka yüz cull) — düğüm: ev gövdesi MeshInstance | Evin iç yüzüne düz sıva/ahşap malzemesi + sığ iç hacim, ya da girilemez evlerde kapıya kapalı kapı/panjur çiz; en azından arka yüz kaplaması |
| 41 | GÖRSEL | 2 | Lykos vadisi sokakları (genel) | -1950, 1400 | kare/g_-1950_1400_270.jpg | Kilise/yapı duvarı SOMON-pembe pilastrlı kırmızı tuğla (kubbeli büyük kütle): yakından oyuncak renk; tuğla düz, harç derzi tek ton. | kemer_harabe.gd / kiliseler (Pantokrator) — ŞÜPHELİ | Tuğla soluk kahve-kırmızı, taş şerit |
| 42 | KUTU | 2 | Zeugma yamacı bostan kenarı | -1950, 800 | kare/g_-1950_800_090.jpg | Yerde turuncu-bej ve parlak yeşil KÜP yığınları (üçgen kama + küp: çalı yerine); kemerin dibinde. | bitki.gd:add_box / bitki_yama.gd:cit | Çalı küre kümeleri |
| 43 | GÖRSEL | 2 | Bozdoğan Kemeri gölgesi/çatı | -1950, 800 | kare/g_-1950_800_270.jpg | Kemerin sağ yanında üst kat eğik ince levhalar tahta bant gibi dışa dönük; kemer üstü ince testere dişli kenar. | kemer_su.gd:_deck | bkz. kemer bulguları |
| 44 | KUTU | 2 | Havariyun yamacı | -2250, 1550 | kare/g_-2250_1550_000.jpg | Yakın çekimde mor ağaç tacı ŞEKİLSİZ düz yüzlü mor çokgenler; çubuk gövde (g_-2250_1550_180). | bitki.gd:add_blob (erguvan) | Çiçek kümeleri, yumuşak taç |
| 45 | GÖRSEL | 3 | Fener sırtı | -2250, 2150 | kare/g_-2250_2150_000.jpg | Surun üstünde BAYRAK sarı-kırmızı (renkli): Bizans sur kulesinde — dönem: hangi bayrak? (sarı-kırmızı-çift). Belgeyle karşılaştır; yakın karede Osmanlı bayrağı değil. | sur kule bayrağı — surlar*.gd (bayrak) | Belgede Palaiologos amblemi (sarı zemin çift başlı kartal) olmalı; ŞÜPHELİ |
| 46 | ZEMİN | 2 | Havariyun yamacı | -2250, 2150 | kare/g_-2250_2150_180.jpg | Yamaçta toprak yol çizgi-çizgi ince basamaklı yatay şeritler (teras basamak gibi sığ çizgi), kenarları keskin; yol patikası olmayan şeritler. | dunya.gd:_parsel / sur_zemin.gd (yol yaması) | Yol düz eğimli patika, kenarı yumuşak |
| 47 | GÖRSEL | 3 | Fener/Petra pazarı | -2550, 2300 | kare/g_-2550_2300_090.jpg | Tezgâh üstünde parlak kırmızı-turuncu, kenarı siyah konturlu yassı OVAL tabaklar (ürün) — kare dışı: çizgi film kontur; yerde parlak limon-yeşili. | tezgâh eşyası — ayrinti_set.gd / ayrinti_sokak.gd tezgâh malı | Soluk gerçekçi ürün, kontursuz |
| 48 | GÖRSEL | 3 | Pazar tentesi | -2550, 2300 | kare/g_-2550_2300_270.jpg | Tentenin altı dev düz parlak turuncu levha: tavan gibi; ışık sızması yok ama oyuncak renk (diğer tenteler de). | ayrinti_sokak.gd:tente | Soluk kırmızı-kahve/kumaş doku |
| 49 | KUTU | 1 | Aspar sarnıcı bostanı (iç) | -2700, 1850 | kare/g_-2700_1850_090.jpg | Bostan içi: ufka kadar uzanan, ışın gibi yayılan parlak NANE-YEŞİLİ / pembe-bej düz ŞERİT levhalar (tarla değil, halı/çizgili kumaş); bitki yok, derinlik yok; ağaç tek top. Sahibin 'kare kare' dediği şeyin tam kendisi. | bitki_yama.gd:patch("bostan") (tarh şerit mesh'i); dunya.gd:~407 | Tarh = kabarık toprak + sıra sıra yuvarlak sebze/yaprak, renk toprak-yeşil, şerit yerine sıra |
| 50 | KUTU | 1 | Aspar sarnıcı bostanı (iç, ikinci yön) | -2700, 2000 | kare/g_-2700_2000_180.jpg | Aynı bostan: yere inşa edilmiş açık yeşil basamaklı dikdörtgen şerit blokları (merdiven gibi) ortada toprak patika; blok kenarları jilet. | bitki_yama.gd:patch bostan | aynı |
| 51 | KUTU | 2 | Aspar bostanı (çam/servi) | -2700, 1850 | kare/g_-2700_1850_270.jpg | Üç servi/çam düz YEŞİL KONİ (silindir gövde üstüne tek koni) çizgi-film; dokusuz, siyahsız ama oyuncak. | bitki.gd:tree_mesh('servi') / add_frustum | Servi dar çok katmanlı, koyu yeşil, düzensiz |
| 52 | GÖRSEL | 2 | Aspar bostanı duvarı | -2700, 1850 | kare/g_-2700_1850_090.jpg | Bostan çevre duvarının üstü tekrarlayan koyu-açık dikey ŞERİTLİ mazgal/pano dizisi (parmaklık gibi) ve altında düz tuğla-taş bant; duvar üstü yapay. | bitki_yama.gd:bahce_duvari / patch çevre duvarı | Mazgal yerine düzgün kapak, taşta düzensiz kırık |
| 53 | GÖRSEL | 2 | Aspar bostanı güney duvarı | -2700, 2000 | kare/g_-2700_2000_000.jpg | Duvar dibinde BEYAZ yassı dikdörtgen parçalar (çit/kapı?) zemine gömülü-yarı havada, kenarı yeşil; z-fighting gibi. | bitki_yama.gd:patch (kapı/çit parçası) — ŞÜPHELİ | Parçayı duvara oturt ya da kaldır |
| 54 | KUTU | 2 | Zeugma/Kemer önü meydanı | -2240, 800 | kare/kay_g_-2250_800_270_k.jpg | Döşeli meydanda açık krem KÜP/blok sandıklar (çıplak, dokusuz, ~1 m) rastgele duruyor; ne olduğu belli değil (tezgâh? taş?). | ayrinti_sokak.gd / ayrinti_set.gd (meydan öğesi) — ŞÜPHELİ düğüm | Küpü taş kaide/sütun gövdesi/ sandık dokusuna çevir ya da kaldır |
| 55 | MANTIK | 3 | Evlerin yan duvarı (merdiven) | -2833, 810 | kare/kay_g_-2850_800_270_k.jpg | Duvar üstü BASAMAKLI diş (merdiven gibi yükselen tuğla-taş kenar) bitişik yapıya çıkmıyor; kuru dilimli duvar kenarı, yan yan kopya. Aynı biçim kay_g_-3450_950_000_k'da. | evler.gd (dış merdiven / sıva basamağı) — ŞÜPHELİ | Merdiven ya da kuş-dişi duvarı tek tipten çeşitlendir, bir kata/çatıya çıksın |
| 56 | GÖRSEL | 3 | Aetios kuzeyi | -2990, 2317 | kare/kay_g_-3000_2300_000_k.jpg | Çimde düz gri LEVHA dikdörtgenler (taş sıra?) yarı gömülü; kenarı keskin. | ayrinti_set.gd (bostan kenarı/sulama levhası) — ŞÜPHELİ | Taş oluk ya da toprak kenar |
| 57 | KUTU | 3 | Fener yamacı | -2385, 2150 | kare/kay_g_-2400_2150_090_k.jpg | Yerde çok sayıda parlak limon-yeşili ince basamak levhalar (merdiven gibi yan yana) ve çevresinde düz yeşil çokgen ağaçlar. | bitki.gd:add_box / patch cit | Çalı yap |
| 58 | KUTU | 1 | Aspar sarnıcı bostanı (60 m) | -3000, 1740 | kare/hava60_-3000_1740.jpg | 60 m'den: tarla yerine kalın KREM-BEYAZ çerçeveli dikdörtgen kutu, içinde parlak yeşil zemin ve 6 açık-yeşil kare: şehrin ortasında dev 'dama tahtası'; uzak/orta katmanda bostan hiç bostan değil. Bu kare sahibin 'kare kare'sinin havadan hâli. | bitki_yama.gd:patch("bostan", lod≥1) + dunya.gd:~407 (_parsel bostan) — düğüm: bostan/sarnıç yaması | Orta/uzak LOD'a toprak-yeşil doku, ince taş duvar, tarh çizgileri; beyaz kalın çerçeveyi kaldır |
| 59 | KUTU | 1 | Aspar bostanı (60 m, bir daha) | -3000, 1460 | kare/hava60_-3000_1460.jpg | Aynı beyaz çerçeve + yeşil kareler uzaktan da: ufuktaki Haliç surundan daha çok dikkat çekiyor. | aynı | aynı |
| 60 | GÖRSEL | 2 | Pammakaristos avlusu (60 m) | -3000, 2300 | kare/hava60_-3000_2300.jpg | Manastır avlusu etrafı BEYAZ-pembe düz duvar çerçevesi, içi gri dama döşeme; duvar kutu gibi, tuğla/taş yok; yanında dev beyaz küreli ağaçlar. | kuzeybati_kilise.gd:build_pammakaristos (avlu duvarı) | Avlu duvarı taş/tuğla şeritli, kapılı |
| 61 | GÖRSEL | 2 | Fener/Haliç yamacı sur dibi | -3600, 2300 | kare/hava60_-3600_2300.jpg | Kuzeydeki avlulu yapı (Kariye?) beyaz çerçeve + kırmızı eşkenar damalı kapak, çevresinde beyaz ağaçlar; sur parçası tek renk taş-pembe çıplak dilimler. | kuzeybati.gd / kuzeybati_kilise.gd — ŞÜPHELİ | Aynı palet düzeltmesi |
| 62 | KUTU | 3 | Havariyun/Lykos koyun ağılı (yakın) | -3600, 900 | kare/hava60_-3600_900.jpg | Ağılda beyaz çit çubukları ve BEYAZ KÜBİK koyunlar: koyun kutu/küre yığını (CANLI, biliniyor); ağıl kenarı havada kalan beyaz direk. | hayvan modelleri (ayrinti_* koyun) — biliniyor (CANLI) | Yuvarlak yünlü koyun gövdesi |
| 63 | GÖRSEL | 3 | Kuzeybatı sur (60 m) | -3900, 2300 | kare/hava60_-3900_2300.jpg | Sur kuleleri BEYAZ KÜP (iç iç kutu), kırmızı bayrak tek nokta; sur dilimleri kesik; biliniyor (kara suru beyaz küpler). | surlar*.gd (kule) — biliniyor | SUR-5 |
| 64 | PERFORMANS | 2 | Batı kenarı (kara suruna bakan yönler) | -3900, 2150 | kare/g_-3900_2150_270.jpg | Yer karesinde çizim=1612 (bütçe 1 200): sur/ordugâh yönüne bakan karelerde en yüksek; g_-3900_1850_270=1392, g_-3750_2000_270=1442. Ham: ham_rinfo_all.txt. | dunya.gd / sehir.gd (sur + ordugâh katmanı çizim sayısı) | Sur MultiMesh birleştirme, LOD/frustum bölütleme |
| 65 | PERFORMANS | 2 | Lykos vadisi batısı | -3600, 800 | kare/g_-3600_800_000.jpg | Yer karesinde üçgen=3,69 M (bütçe 2,5 M); bölgenin 486 yer karesinin 240'ında (%49) üçgen > 2,5 M, 24'ünde çizim > 1 200. Uçuş karelerinde (70) aşım yok (en çok 3,30 M / 1 061). | dunya.gd (ev/doku katmanı; ISTDOKU3) — ölçüm: RINFO gezi | Yer LOD'unu sıkılaştır; ağaç/ev MultiMesh |
| 66 | GÖRSEL | 2 | Pantokrator manastırı (60 m) | -2100, 1180 | kare/hava60_-2100_1180.jpg | Üç kubbeli manastır SOMON-PEMBE gövde + AÇIK MAVİ kubbeler: pastel oyuncak; çevresinde düz kum daire meydan. Lips/Fenari İsa da aynı pembe-turuncu (hava60_-2400_900 solda, hava60_-2700_900). | kemer.gd:build_pantokrator / build_lips (renk paleti) | Tuğla soluk kırmızı-kahve, kubbe kurşun gri |
| 67 | GÖRSEL | 2 | Haliç yakası sur (60 m) | -1800, 1460 | kare/hava60_-1800_1460.jpg | Sur kuleleri BEYAZ KÜP, beden gri düz şerit: kuleler bedenle aynı hatta oturmuyor, Haliç boyunca kutu sırası (biliniyor: SUR). Haliç tarafında da aynı: hava60_-2100_1740, -2400_1740. | surlar*.gd / halic*.gd (kule) — biliniyor | SUR-5 |
| 68 | KUTU | 2 | Aspar bostanı (60 m, doğu yaması) | -2700, 1740 | kare/hava60_-2700_1740.jpg | Aspar/Aetios çevresindeki dikdörtgen: parlak mint-yeşil çerçeve duvar, içinde iki açık yeşil dikdörtgen basamaklı zemin; sarnıç değil düz kutu parsel. Diğer bostan (hava60_-2700_1460, -2700_1180) beyaz çerçeve + yeşil dama. | bitki_yama.gd:patch bostan lod≥1 | LOD'a bostan dokusu |
| 69 | GÖRSEL (ŞÜPHELİ) | 3 | Lykos vadisi | -3600, 1460 | kare/hava60_-3600_1460.jpg | Mahallede KIRMIZI kutu (araba? sandık?) tek başına duruyor ve havada yarım; kırmızı oyuncak doygunluğu; hava60_-2100_1460'ta da kırmızı uzun yapı. Ne olduğu anlaşılmıyor. | kaynak bilinmiyor (düğüm adı çıkarılamadı) | Ne olduğunu belirle |
| 70 | GÖRSEL (GECE) | 1 | Lykos vadisi / Aetios arası | -3450, 2150 | kare/gece_-3450_2150_090.jpg | Geceleyin beyaz/açık ağaç tacı ve çevresi KENDİ KENDİNE AYDINLIK açık mavi parlıyor (diğer her şey kapkaranlık): ağaç malzemesi ışıktan bağımsız (unshaded/emisyon) görünüyor. Aynı: gece_-3600_2300_090. | bitki.gd:mat() (ağaç malzemesi shading/emission) — ŞÜPHELİ | Ağaç malzemesi gece gölgelendirmesine uysun |
| 71 | GÖRSEL (GECE) | 2 | Lykos vadisi sokakları | -3300, 1100 | kare/gece_-3300_1100_090.jpg | Kapı yanındaki dik silindir/kapı direkleri gece açık mavi NEON gibi parlıyor (gece_-3600_950_000'da iki mavi parlak direk de); duvar kapkaranlıkken yalnız bunlar ışıyor. | ev kapı pervazı/sütun — evler.gd / ayrinti_sokak.gd (kapı sütunu) — ŞÜPHELİ | Sütun malzemesi gece matlaşsın |
| 72 | GÖRSEL (GECE) | 2 | Mahalle sokakları (genel) | -3150, 1400 | kare/gece_-3150_1400_000.jpg | Bir çok gece karesi neredeyse TAM SİYAH: sokak ışığı/mum yok, yalnız birkaç sarı pencere ve nadir bir mum (gece_-3300_1100_090, gece_-3600_1100... ) ; sokaklar kapalı, yaşam yok, kimsenin görünmediği karanlık koridorlar (gece_-3750_2000_000, gece_-3600_1850_000). | gece aydınlatma — dunya.gd (gece ışıkları/ayrinti_sokak.gd:lamba) | Sokak başına mum/kandil, pencere ışığı sıklığını artır, ay ışığını güçlendir |

## 4. Sayım
Tür başına (ilk sözcük): 
- GÖRSEL: 33
- KUTU: 20
- MANTIK: 5
- ZEMİN: 4
- GÖRSEL/KUTU: 2
- KUTU/GÖRSEL: 2
- BOŞLUK: 2
- PERFORMANS: 2
- ZEMİN/MANTIK: 1
- MANTIK/GÖRSEL: 1

Önem: 1 (kritik) 13 · 2 (belirgin) 39 · 3 (küçük) 20.
**KUTU kalan=24** (hedef 0; tür alanında 'KUTU' geçen bulgu). (koyun kutusu 'biliniyor/CANLI' sınıfında); ŞÜPHELİ işaretli 15.
"Biliniyor, düzeltiliyor" kapsamında yazılanlar: 3 bulgu (sur kuleleri beyaz küp, koyun kutu).
**ÖNCE'de var mıydı?** Karşılaştırma YAPILMADI (tabanı `e551de84` ile kurmadım): bulgular yalnız mevcut taban `wip/ist2-gezi-taban` içindir.

## 5. En kötü 12 kare
1. `kare/hava60_-3000_1740.jpg`: şehrin ortasında beyaz kalın çerçeveli yeşil dama kutu (Aspar bostanı, 60 m).
2. `kare/g_-2700_1850_090.jpg`: bostan içi ufka uzanan düz mint-yeşil şeritler, ışın gibi.
3. `kare/g_-2700_2000_180.jpg`: aynı bostan, basamaklı jilet kenarlı yeşil bloklar.
4. `kare/kemer_g06.jpg`: kemer ayakları kâğıt kanatlı levhalar.
5. `kare/kemer_ust06.jpg`: kemer üstten testere dişi/zikzak, tonoz levha.
6. `kare/g_-2250_800_090.jpg` (+ g_-2850_1250_000): bina içi kapkara lacivert boşluk.
7. `kare/aspar_135.jpg`: bostan tarhları yeşil blok sıra.
8. `kare/g_-2400_950_090.jpg`: kemerin yan görünüşü eğik tahta bant.
9. `kare/gece_-3450_2150_090.jpg`: ağaç geceleyin kendi başına açık mavi parlıyor.
10. `kare/lips_000.jpg`: beyaz çokgen ağaçlar, kâğıt buruşukluğu.
11. `kare/g_-3900_2300_000.jpg`: sur arasında havada kalas zinciri/parçalar.
12. `kare/hava60_-3000_2300.jpg`: Pammakaristos avlusu beyaz-pembe çerçeve, tuğla/taş yok.

## 6. İYİ olan 5 kare (korunacaklar; ham kare klasörde yok, paftalarda var: `pafta_*`)
1. `g_-3150_2000_270` (pafta_B): döşeli çarşı sokağı, tezgâh, kemerli kapılar, kişiler (opus mixtum duvar).
2. `g_-2400_1100_000` (pafta_B): Havariyun döşeli meydan, yaşam var.
3. `g_-2250_950_000` (pafta_B): taş duvarlı sokak + tezgâh + insan.
4. `hava60_-1800_1180` (pafta_D_hava60): Haliç, filo, ufuk ve sur silüeti.
5. `g_-2550_1250_000` (pafta_B): insan, ağaç, döşeme, evler: iyi ölçek ve boy.

## 7. Bakamadıklarım / yapmadıklarım
- 60 m ızgara (150 m yapıldı), 4 yön (çoğu yerde 2 yön), 15 m'de bir yol yürüyüşü kareleri (yapılmadı; yerine 6 gerçek-oyuncu rotası),
  120 m çapraz kareler (yapılmadı), her ünlü yapıya kapı kapı giriş (yapılmadı, Pantokrator/Pammakaristos içi görülmedi).
- 5 kaydırılmış kare (kay_g_…) açılmadı. Kapılar, merdivenler, basamak çıkılabilirliği yürüyüş olayı olarak ölçülmedi.
- Dönem (belge karşılaştırması): `docs/ISTANBUL_1453.md` bu oturumda OKUNMADI; dönem bulguları yalnız görüntüden (bayrak, renk).
- Kaynak (dosya:işlev) sütunu: kemer_su.gd, kemer.gd, kemer_harabe.gd, kuzeybati_kilise.gd, bitki.gd, bitki_yama.gd, dunya.gd için
  dosyaları açıp kısa grep ile doğruladım; ŞÜPHELİ yazılanlar adı bulunamayan düğümlerdir. Pammakaristos/Havariyun renk
  bulgularının işlevi tahmindir.
- Önceki 21 bulgu ilk gönderimdeki 'kemer_*' vs. paftalarda; ilk gönderimin paftaları silinip yenileriyle değişti (aynı kareler).

## Ham dosyalar
`liste_A_yerler_havadan.txt`, `liste_C_takilma.txt`, `ham_yuruyus_olaylar.txt`, `ham_rinfo_all.txt`; paftalar `pafta_*.jpg` (16).
