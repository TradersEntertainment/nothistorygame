# GEZİ DENETİMİ — `kara-kuzey` — ILK GÖNDERİM (kısmî rapor; son rapor ardından gelecek)

Dal `wip/gezi-kara-kuzey`, taban `wip/ist2-gezi-taban`. Oyun kodu değişmedi (`git status`).
Araç: `tests/_ist/gezi.tscn` (xvfb, yazılımla çizim, kare başına ~20 sn; bu yüzden 60 m ızgara tam taranamadı — bkz. 7).

## 1. Bölge ve kare sayıları
Bölge sınırı (gerçek m, doğu, kuzey): GB (-3840, 2220), GD (-2950, 2220), KB (-3840, 3560), KD (-2950, 3560);
asıl yer: Edirnekapı (-3646, 2564) → Eğrikapı (-3353, 2826) → Blakherna/Anemas (-3360, 3547), Haliç kıyısı; sur dışı 260 m şerit.
Izgara: 284 düğüm planlandı (`liste_*`), ilk gönderimde yalnız simge yapı kuyruğu (A) yürüdü.
Çekilen: 35 (A kuyruğu, ilk 5 yer: Edirnekapı, Kharisios 2. kapı, Khora, Tekfur, Eğrikapı) + 12 deneme; bakılan: tamamı (paftalar + şüpheli kareler tam boy).
Gerçek oyuncuyla yürüyüş: bu gönderimde YOK (bkz. 7).

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

## 4. Tür sayımı
KUTU 8 (4 biliniyor), GÖRSEL 5, ZEMİN 4, ŞÜPHELİ-MANTIK 1; `KUTU kalan=8` (ilk gönderim).

## 5. En kötü kareler: lm_tekfur_D_yer (14), lm_khora_K_yer (10), lm_edirnekapi_K_yer (1), lm_edirnekapi_h60 (5), lm_tekfur_K_yer (13)

## 6. İyi olanlar (korunacak)
lm_edirnekapi_kap2_D_yer (taş döşeli pazar, insanlar, tezgâh), lm_edirnekapi_kap2_h20 (tepeden Kariye + insanlı meydan), lm_edirnekapi_c6_yer (sur doku/opus mixtum, kapı kemeri) , lm_khora_h20 (Khora planı okunuyor), lm_edirnekapi_kap2_B_yer.

## 7. Bakamadıklarım / eksikler
Izgara (284 düğüm) ve gece, Blakherna Sarayı, Anemas, Meryem, Pentapyrgion, Haliç inişi, 6 yürüyüş, RINFO tablosu: SONRAKİ RAPORDA.
Not: A kuyruğunun yer noktaları yapı içine düşebiliyor (benim konum seçimim).
