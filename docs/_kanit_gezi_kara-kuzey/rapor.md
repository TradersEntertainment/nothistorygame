# GEZİ DENETİMİ — `kara-kuzey` — SON RAPOR

Dal `wip/gezi-kara-kuzey`, taban `wip/ist2-gezi-taban`. Oyun kodu değişmedi (`git status`).
Araç: `tests/_ist/gezi.tscn` (xvfb, yazılımla çizim, kare başına ~20 sn; bu yüzden 60 m ızgara tam taranamadı — bkz. 7).

## 1. Bölge ve kare sayıları
Bölge sınırı (gerçek m, doğu, kuzey): GB (-3840, 2220), GD (-2950, 2220), KB (-3840, 3560), KD (-2950, 3560);
asıl yer: Edirnekapı (-3646, 2564) → Eğrikapı (-3353, 2826) → Blakherna/Anemas (-3360, 3547), Haliç kıyısı; sur dışı 260 m şerit.
Izgara: 284 düğüm planlandı; 60 m yerine 120 m seyreltilmiş ızgara (77 düğüm × K ve D yönü = 154 kare) çekildi (`liste_B_izgara_K_D.txt`).
Çekilen: 232 (A: 11 simge yapı × 6 = 66; B: 154 ızgara; ilk deneme 12). Bakılan: 232 (hepsi pafta boyunda; şüpheli ve bulgu karelerinin ~40'ı tam boy). Tam boy açıp bakılmayan kare, bulgu yazılmadı.
Gerçek oyuncuyla yürüyüş: YAPILMADI (0 km; bkz. 7). Gece: 22 kare (bkz. 7); çekilen toplam 254. Performans: 220 kare RINFO (`ham_RINFO.txt`): çizim ≤ 1 972 (en çok lm_egrikapi_B_yer), 50 karede > 1 200 (yer bütçesi), üçgen ≤ 3,74 M, 29 karede > 2,5 M (yer bütçesi aşıldı). Kare süreleri yazılımla çizim olduğu için anlamsız. Kurulum 907 ms.

## 2. GENEL NOT (ilk izlenim): 4/10
Sahibi Kharisios'tan Tekfur'a yürüse önce sur dibine kızar: surun ARKASI ile ÖNÜ iki ayrı oyun gibi (içi döşeli, canlı pazar; dışı çıplak yeşil-kahverengi yama ve karanlık hendek duvarı).
Sonra kulelerin dev düz levha çatılarına ve kale üstündeki beyaz küplere, sonra yeşil kutu-sarmaşık/ağaç oyuncaklarına kızar.
Yer kareleri sur kapılarında kamerayı yapı içine sokuyor ve düz lacivert/siyah yüzeyler görünüyor.

## 3. BULGU TABLOSU (kısmî)
KARE yolu: `kare/<ad>.jpg`. K=kuzey, D=doğu bakışı.
| no | tür | önem | yer | doğu, kuzey | kare | görünen | kaynak | öneri |
|---|---|---|---|---|---|---|---|---|
| 1 | GÖRSEL | 1 | Edirnekapı kapı geçidi | -3646, 2564 | lm_edirnekapi_K_yer | geçit içi: düz turuncu tavan levhası, çapraz kalas, çıplak ahşap duvar levhası; kapı geçidi mağara gibi, kapı yapısı okunmuyor | surlar_kapi.gd (kharisios) | geçit tonoz/kemer + kapı kanadı dokusu; tavan taş |
| 2 | ŞÜPHELİ-MANTIK | 2 | Edirnekapı kapı geçidi | -3646, 2564 | lm_edirnekapi_K_yer (aynı noktanın D/G/B kareleri `pafta_edirnekapi`) | G/D karelerinde kamerayı dev ahşap levha duvar ve merdiven kaplıyor; yer kamerası yapı içinde (benim noktam; yürünür mü bakılmadı) | surlar_kapi.gd | oyuncuyla geçit yürüme sınaması |
| 3 | KUTU | 2 | Edirnekapı kuleleri | -3646, 2540 | lm_edirnekapi_h20 | kule kutu + düz mor-gri levha çatı, çatı kulenin her yanından taşıyor (BİLİNİYOR) | surlar.gd:_inner_tower | gerçek kule külahı/teras |
| 4 | KUTU | 2 | Edirnekapı sur üstü | -3646, 2540 | lm_edirnekapi_h20 | siper/mazgal üstünde iri açık bej küp bloklar (BİLİNİYOR) | surlar.gd:_parapet_x/_roof_ring | mazgal küçült, taş dokusu |
| 5 | ZEMİN | 1 | Edirnekapı sur dışı hendek | -3680, 2600 | lm_edirnekapi_h60 | hendek ve set: keskin kenarlı yeşil/toprak çokgen yamalar, çizgi gibi ince koyu hendek ağzı, yol gibi uzayan şerit (BİLİNİYOR SUR-5; hâlâ kötü) | sur_zemin.gd:hendek_dibi, :set_ | yama kenarı yumuşat, hendek kesiti |
| 6 | KUTU | 2 | ordugâh (kuzeybatı) | -3750, 2640 | lm_edirnekapi_h60 | sur dışı yüzlerce krem kulübe benzeri çadır, sürekli aynı biçim; ateş/duman görünmüyor (BİLİNİYOR) | ordugah (OBA) | — |
| 7 | KUTU | 2 | Kharisios ikinci kapı sur dibi | -3545, 2413 | lm_edirnekapi_kap2_K_yer | sol altta basamaklı yeşil dikdörtgen levhalar (bostan tarhı mı? çıplak yeşil levha), ortada yeşil küp-ağaç | bitki.gd (tarla), bitki_yama.gd | tarh dokusu, ağaç taçı yuvarlak |
| 8 | ZEMİN | 2 | Kharisios ikinci kapı | -3545, 2413 | lm_edirnekapi_kap2_K_yer, lm_edirnekapi_kap2_G_yer | taş döşeme ile düz yeşil-gri zemin arasında bıçak kenarı; ev duvarı tabanıyla çim arası çizgi | sur_zemin.gd / sehir zemini | geçiş: toprak şeridi, ot |
| 9 | KUTU | 3 | Kharisios, evler | -3545, 2413 | lm_edirnekapi_kap2_G_yer | ev tek kutu + düz kırmızı çatı, çıplak badana cephe, tek renk | evler.gd | cephe çeşitliliği |
| 10 | GÖRSEL | 1 | Khora (Kariye) avlusu | -3444, 2491 | lm_khora_K_yer | ekranın üçte biri dokusuz koyu lacivert dikdörtgen; yer kamerası sur/avlu duvarında (ŞÜPHELİ: arka yüz ya da sızıntı) | kuzeybati_kilise.gd:build_khora | iç yüz/arka yüz malzemesi kontrol |
| 11 | KUTU | 2 | Khora çevresi | -3444, 2491 | lm_khora_G_yer | ağaç taçı düz çokgen (oyuncak), servi düz koni; evler çıplak krem kutu, pencere/kapı siyah dikdörtgen deliği | bitki.gd:_agac, evler.gd | taç yuvarlat, pencere çerçevesi |
| 12 | GÖRSEL | 2 | Khora kilisesi | -3444, 2491 | lm_khora_h20 | altı kubbe koyu lacivert (neredeyse siyah), düz salmon galeri çatısı, avluda çıplak beyaz dikdörtgen levha; çatıda düz kırmızı levha | kuzeybati_kilise.gd | kubbe kurşun gri, çatı kiremit |
| 13 | ZEMİN | 1 | Tekfur sur dışı | -3612, 2880 | lm_tekfur_K_yer | yer karesi: düz iki ton yeşil-kahve çim, aralarında dümdüz köşegen bıçak kenar; ufuk boş çayır | sur_zemin.gd | arazi renk karışımı, çalı/ot |
| 14 | GÖRSEL | 1 | Tekfur hendek duvarı | -3612, 2880 | lm_tekfur_D_yer | hendek duvarı yüzlerce metre dokusuz, çok koyu yeşil-siyah, derz yok; üstünde beyaz-sarı küçük piramit kutu | sur_zemin.gd:_build_moat (surlar.gd:614) | taş dokusu, mazgal, aydınlık |
| 15 | ZEMİN | 2 | Tekfur sur önü | -3612, 2880 | lm_tekfur_h20 | hendek ve toprak yamalar: keskin yeşil üçgenler, düz çizgi hendek; sur dibine kadar boş çim | sur_zemin.gd | siper, kazık, ot |
| 16 | KUTU | 2 | Tekfur kuleleri | -3612, 2880 | lm_tekfur_h60 | kulelerin dev düz çatıları (BİLİNİYOR) | surlar.gd:_inner_tower | — |
| 17 | KUTU | 2 | Eğrikapı | -3353, 2826 | lm_egrikapi_K_yer | sarmaşık küp küp yeşil blok yığını, yeşil küre çalı; yanında çıplak beyaz küt silindir | bitki_yama.gd:build_sarmasik | sarmaşık yaprak şeritleri |
| 18 | GÖRSEL | 1 | Eğrikapı | -3353, 2826 | lm_egrikapi_D_yer | ekranın yarısı dokusuz lacivert-siyah dikdörtgen + sarı yüzey (ŞÜPHELİ: kamera yapı içinde) | surlar_kapi.gd | — |
| 19 | KUTU | 2 | Eğrikapı sur üstü | -3353, 2826 | lm_egrikapi_h20 | sur yürüme yolunda çıplak turuncu ahşap küp (sandık), dokusuz | ayrinti_api (sur eşyası) | sandık pah/çember |
| 20 | KUTU | 3 | Eğrikapı çevresi | -3353, 2826 | lm_egrikapi_h60 | havada beyaz dikdörtgen levhalar sur yanında (3–4 adet), kutu evler | kuzeybati/halic mahalle | — |

| 21 | GÖRSEL | 1 | Pentapyrgion / hendek dibi | -3528, 3014 | lm_pentapyrgion_K_yer, lm_pentapyrgion_D_yer | hendek karşı duvarı ve zemin çok koyu yeşil-siyah; çim üstünde düzenli koyu "damla" lekeleri (sıçrama gibi, damga); hendek dibi düz gri çakıl levha | sur_zemin.gd:set_, :hendek_dibi | leke dokusunu karıştır, hendek duvarını aydınlat |
| 22 | ZEMİN | 2 | Pentapyrgion sur dışı | -3528, 3014 | lm_pentapyrgion_h20 | hendek kıyısında keskin kenarlı toprak/çim basamak yamaları; sıra sıra düz taş blok basamak | sur_zemin.gd | yama kenarı yumuşat |
| 23 | GÖRSEL | 2 | Blakherna dış sur dibi | -3402, 3436 | lm_blakherna_saray_K_yer | sur dibinde yarı saydam açık sarı dikey levha çimin içinden duvara uzanıyor (ışık sızması / kopuk yüzey) | sur_zemin.gd / surlar_ayrinti.gd (ŞÜPHELİ düğüm) | levhanın kaynağını bul |
| 24 | GÖRSEL | 1 | Blakherna sur arası dar koridor | -3402, 3436 | lm_blakherna_saray_D_yer | iki sur arası koridor: duvarlar dokusuz koyu yeşil-lacivert, tamamen kişisiz (peribolos ölü) | surlar.gd:_build_moat | aydınlat, kişi/kapı ekle |
| 25 | MANTIK | 2 | Blakherna Sarayı konumu | -3402, 3436 | lm_blakherna_saray_h20, lm_blakherna_saray_h60 | geo.gd'deki "Blakherna Sarayı" noktasında saray YOK: Haliç kıyısında çapraz kalas yığını ve keskin yamalar; saray başka yerde (Meryem karesindeki yapı?) | geo.gd:620 Blakherna Sarayı, kuzeybati_kilise.gd | konumu yapıyla hizala |
| 26 | KUTU | 2 | Anemas | -3360, 3547 | lm_anemas_K_yer | ağaç tacı beyaz elmas/küp (renksiz, düz çokgen) | bitki.gd:_agac | taç yuvarlak ve yeşil |
| 27 | MANTIK | 2 | Anemas / Haliç suru ucu | -3360, 3547 | lm_anemas_B_yer, lm_anemas_D_yer | sur duvarı suya doğru birden kesiliyor, ucu düz kesik, hendek duvarı karşıda ayrı bir parça; zindan/Anemas yapısı görünmüyor | halic_sur.gd, surlar.gd | sur-kıyı köşesi kule ile kapanmalı |
| 28 | ZEMİN | 2 | Anemas kıyısı | -3360, 3547 | lm_anemas_h20 | kıyıda keskin kenarlı kahverengi/yeşil çokgen yamalar, sur uçtan su içine çıkan ince levha | geo (kıyı), halic_sur.gd | kıyı dokusu, iskele/kaya |
| 29 | BOŞLUK | 2 | Haliç kıyısı Blakherna–Anemas | -3360, 3547 | lm_anemas_h60 | Haliç'in bu ucunda gemi, kayık, iskele, insan yok: ölü liman; karşı kıyı boş çayır ve beyaz noktalar | gemiler.gd | kayık, ağ, balıkçı |
| 30 | BOŞLUK | 2 | Blakherna Meryem meydanı | -3150, 3303 | lm_meryem_D_yer | geniş döşeli meydan, 3–4 boş tezgâh, hemen hemen kişisiz | hayat_yakin.gd | kişi ekle |
| 31 | KUTU | 2 | Blakherna Meryem meydanı | -3150, 3303 | lm_meryem_G_yer | meydan ortasında koyu gri tek düz dikdörtgen blok (duvar mı?, dokusuz) | kuzeybati_kilise.gd (Meryem harabesi) | doku/derz |
| 32 | KUTU | 3 | Blakherna Meryem | -3150, 3303 | lm_meryem_h20 | altta salmon düz levha çatılı uzun yapı (kutu + levha) | kuzeybati_kilise.gd | — |
| 33 | KUTU | 1 | Isaakios Angelos kulesi çevresi | -3428, 3225 | lm_isaakios_D_yer | BEYAZ ağaçlar (renksiz bulut gibi taç) ve tek beyaz çıplak koni/obelisk; yanlış renk | bitki.gd:_agac | tür/renk |
| 34 | GÖRSEL | 2 | Isaakios kapısı | -3428, 3225 | lm_isaakios_B_yer | kapı deliği düz siyah dikdörtgen (kanat yok), üstünde parlak turuncu-kırmızı lento levhası | surlar_kapi.gd | kapı kanadı, kemer |
| 35 | KUTU | 2 | Isaakios sur üstü | -3428, 3225 | lm_isaakios_h20, lm_isaakios_h60 | sur üstünde beyaz küpler (BİLİNİYOR), kule dibinde beyaz küt kutular | surlar.gd:_parapet_x | — |
| 36 | GÖRSEL | 1 | Blakherna kapısı dış sur | -3512, 2925 | lm_blakherna_kapi_D_yer | tam ekran dokusuz çok koyu yeşil duvar, derz yok | surlar.gd | aydınlık/doku |
| 37 | MANTIK | 1 | Blakherna kapısı | -3512, 2925 | lm_blakherna_kapi_B_yer | sol üstte HAVADA asılı bej merdiven parçası (zeminle bağlantı yok) | surlar_ayrinti.gd (sur merdiveni) | merdiveni sura bağla |
| 38 | ZEMİN | 2 | Blakherna kapısı sur arası | -3512, 2925 | lm_blakherna_kapi_h20 | sur arası patika/hendek: gri düz zemin, yosun benekleri, kıyıda keskin kenar; yalnız bir martı | sur_zemin.gd | — |
| 39 | KUTU | 1 | Kuzey ordugâh kenarı (Haliç yamacı) | -3000, 2220 | g_3000_2220_D | kamerayı dev düz koyu yeşil prizma (çalı/ağaç kutusu) kaplıyor; yanında BEYAZ ağaç taçı | bitki.gd:_agac | çalı yuvarlak |
| 40 | KUTU | 1 | Haliç kıyı mahallesi | -3000, 2340 | g_3000_2340_D | beyaz çokgen ağaç öbeği + beyaz sivri koni; yerde çıplak gri düz levhalar (bahçe duvarı kütüğü) | bitki.gd, ayrinti_sokak.gd | renk, levha dokusu |
| 41 | KUTU | 2 | Haliç kıyı mahallesi | -3000, 2940 | g_3000_2940_D | beyaz çalı/ağaç bulutları, beyaz koni | bitki.gd | — |
| 42 | GÖRSEL | 1 | Haliç yamacı iç mahalle | -3120, 2940 | g_3120_2940_D | tüm ekran dokusuz lacivert (kamera yapı içinde: kırık yüz / sızıntı olarak oyuncuya görünür mü?) | evler.gd (ŞÜPHELİ) | iç yüz kontrolü |
| 43 | KUTU | 2 | Haliç yamacı | -3120, 2820 | g_3120_2820_D | kamera altında dev mor-erguvan düz levha (tente/çatı) | evler.gd / ayrinti | renk |
| 44 | KUTU | 2 | Blakherna yamacı | -3120, 3300 | g_3120_3300_D | iri yeşil çokgen kaya/çalı kütlesi, oyuncak biçim | bitki.gd (kaya/çalı) | — |
| 45 | GÖRSEL | 1 | Blakherna yamacı | -3240, 3300 | g_3240_3300_D | turuncu düz levha tavan altında dokusuz lacivert/siyah yüz (kamera yapı içinde) | evler.gd (ŞÜPHELİ) | — |
| 46 | KUTU | 2 | Haliç kıyı mahallesi | -3480, 2940 | g_3480_2940_D | düz çıplak sarı-kahverengi dev duvar blokları, derzsiz, lacivert gökle yan yana | evler.gd | doku |
| 47 | KUTU | 2 | Kara sur dışı ordugâh sınırı | -3600, 2340 | g_3600_2340_D | yer üstünde neon açık yeşil basamaklı çıplak levhalar (tarla tarhı?) | bitki_yama.gd (tarh) | doku, renk |
| 48 | KUTU | 2 | Kharisios iç yan | -3600, 2220 | g_3600_2220_D | kamera dev düz turuncu levha tente altında; turuncu minderler ayrı poligon | ayrinti_sokak.gd | — |
| 49 | KUTU | 2 | Sur dışı ağaçlar | -3600, 3060 | g_3600_3060_D | ağaç taçları tam yeşil elmas (düz çokgen), hendek ağzında keskin yama | bitki.gd:_agac | — |
| 50 | KUTU | 2 | Sur dışı köpek | -3720, 2460 | g_3720_2460_D | köpek gövdesi kutu parçalardan (düz yüzlü), önünde işaret direği | ayrinti_b.gd:build_kopek | kapsül gövde |
| 51 | GÖRSEL | 1 | Kharisios kule içi | -3720, 2340 | g_3720_2340_D | kule içinde tavan ışın şeklinde tuğla, duvarlar dokusuz lacivert, kapı yok | surlar.gd:_inner_tower | iç yüzeyler taş |
| 52 | MANTIK | 3 | Kharisios dış sur | -3840, 2220 | g_3840_2220_K | sur dibinde yerde çekiç ve bordo kan benzeri leke, kimse yok (iş yapan kişi yok) | ayrinti (sur eşyası) | — |
| 53 | ZEMİN | 2 | Sur dışı hendek | -3720, 2700 | g_3720_2700_D | hendek: keskin çokgen yamalar, hendek içinde mavi-yeşil su gibi ince şerit, duvar derzi yok | sur_zemin.gd | — |
| 54 | ZEMİN | 2 | Sur dışı | -3600, 2940 | g_3600_2940_K | düz çayır ortasında keskin bıçak çizgisi (hendek ağzı), sarı kenar çizgisi | sur_zemin.gd | — |
| 55 | BOŞLUK | 2 | Sur dışı 200 m kuşağı | -3720 … -3840, 2400–2800 | g_3720_2700_K, g_3720_2820_D (pafta_izgara_b2) | ordugâh görünmeden düz boş çayır; ufukta birkaç çadır, ateş yok (BİLİNİYOR ORDUGÂH-5) | ordugah | — |

| 56 | GÖRSEL | 1 | gece, 8 yer karesi | bkz. yan | pafta_gece.jpg (4. satır 1,2,5,6,7,8,11–14,16,19,20: lm_blakherna_saray_G/K, lm_edirnekapi_G/K, lm_egrikapi_G, lm_isaakios_K, lm_khora_K, lm_pentapyrgion_G/K) | 22 gece karesinin ~10'u tamamen siyah: yapı içine/yakınına düşen kamera ışık almıyor; gündüz lacivert olan yüzler gecede siyah | sehir ışığı (dunya.gd gece ortamı), surlar | iç yüze ışık ya da kamera dışı; ŞÜPHELİ (benim noktam) |
| 57 | BOŞLUK | 1 | gece, sur dışı | -3612, 2880 / -3528, 3014 | gece_lm_tekfur_K_yer, pafta_gece (pentapyrgion) | sur dışında gece tek ateş, meşale, nöbetçi ışığı yok; kuşatma gecesi simsiyah çayır (BİLİNİYOR ORDUGÂH-5) | ordugah | ateş, meşale |
| 58 | GÖRSEL | 2 | gece, Blakherna kapısı | -3512, 2925 | gece_lm_blakherna_kapi_G_yer | sur yüzü lacivert-siyah dokusuz blok, mazgal okunmuyor | surlar.gd, gece ortamı | yüzey emisyon/ay ışığı |
| 59 | GÖRSEL | 3 | gece, Khora çevresi | -3444, 2491 | pafta_gece (15. kare lm_khora_G_yer) | evler gece çıplak mavi-beyaz, pencere ve kapılar siyah kare; ışık yok | evler.gd | pencere ışığı |

## 4. Tür sayımı
59 bulgu: KUTU 24 (en az 8 BİLİNİYOR), GÖRSEL 17, ZEMİN 8, MANTIK 5, BOŞLUK 5 (ŞÜPHELİ işaretliler 2, 10, 18, 42, 45, 25); `KUTU kalan=24`.

## 5. En kötü 12 kare
1. lm_tekfur_D_yer — kilometrelerce dokusuz koyu hendek duvarı. 2. lm_blakherna_kapi_B_yer — havada asılı merdiven. 3. g_3000_2220_D — dev yeşil prizma + beyaz ağaç. 4. lm_isaakios_D_yer — beyaz ağaçlar + beyaz koni. 5. lm_khora_K_yer — dokusuz lacivert yüz. 6. lm_edirnekapi_h60 — hendek/set bıçak yamaları. 7. lm_anemas_B_yer — sur suya kesik bitiyor. 8. lm_blakherna_saray_D_yer — kişisiz karanlık peribolos. 9. lm_tekfur_K_yer — köşegen bıçak çim yaması. 10. g_3600_3060_D — elmas ağaç + keskin hendek ağzı. 11. lm_isaakios_B_yer — siyah kapı deliği. 12. g_3120_2940_D — tam ekran lacivert.

## 6. İyi olanlar (korunacak)
lm_edirnekapi_kap2_D_yer (taş döşeli pazar, insanlar, tezgâh), lm_edirnekapi_kap2_h20 (tepeden Kariye + insanlı meydan), lm_edirnekapi_c6_yer (sur doku/opus mixtum, kapı kemeri) , lm_khora_h20 (Khora planı okunuyor), lm_edirnekapi_kap2_B_yer.

## 7. Bakamadıklarım / eksikler (dürüst)
- Izgara 60 m yerine 120 m, 4 yön yerine 2 (K, D): 284×4 = 1 136 kare yerine 154. Yürüyüş yolları (15 m'de bir kare), 8'li çevre dolaşma, 120 m'de çapraz kare: YAPILMADI.
- Gerçek oyuncuyla 6 güzergâh / 1,2 km: YAPILMADI (zaman). `GEZI_OLAY` sayımı yok: takılma/boşluğa basma/kapalı cep hakkında hüküm yok.
- Gece: yalnız 22 yer karesi (`liste_C_gece.txt`, `pafta_gece.jpg`), ızgara gecesi ve havadan gece YOK.
- Kare yerleşimi: yer karelerinin birçoğu (özellikle `lm_*_yer`, `g_*`) bir yapının içine düştü (lacivert/turuncu yüzeyler); bunlar benim noktam, oyuncunun orada olabileceği doğrulanmadı. 2, 10, 18, 42, 45 ŞÜPHELİ.
- Meryem/Blakherna Sarayı eşleşmesi (25) görsel çıkarım: belge koordinatı ile görünen yapı uyuşmuyor, hangisi doğru bilinmiyor.
- Kare başı kaynak: düğüm adı çıkarımı (`sur4_kare --set=kim` koşulmadı); dosya:işlev yalnız grep tahmini, "ŞÜPHELİ" işaretli.
