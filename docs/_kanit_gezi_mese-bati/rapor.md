# GEZİ DENETİMİ — `mese-bati` (Mese'nin batı kolu ve güneybatı)

Gezgin: bağımsız denetçi (oyun kodu DEĞİŞTİRİLMEDİ; yalnız `tests/_ist/gezi_mese-bati.*` sondası ve bu klasör). Taban: `wip/ist2-gezi-taban`.

## 1. Bölge, kare ve yürüyüş sayıları

- **Bölge sınırı (gerçek doğu, kuzey; `IstGeo.w2` koordinatı):** KB (-4950, +440) · KD (-1450, +440) · GD (-1450, -1000 civarı Marmara kıyısı) · GB (-4950, -1780 Altın Kapı/Studios kıyısı). Kıyı çizgisi güneydedir; Haliç'e (kuzeye) ve Lykos vadisine uzanmaz. 60 m'lik ızgaranın kara+şehir içi düğümü: **1 435** (`gezi_mese-bati.gd --set=ara`, ham veri `ara_ozet.txt`).
- **Çekilen kare / bakılan kare:** **125 çekildi / 102 bakıldı** (3×3 paftalar açılarak; bakılan karelerin listesi `bakilan_kareler.txt`). Çekilip bakılmayanlar §7'de.
- **Tam 60 m ızgara (1 435 düğüm × 4 yön = 5 740 kare) YAPILAMADI:** yazılımla çizimde kare başına 8–25 sn; 2,5 saatlik bütçeye sığmaz. Yerine: (a) 14 ünlü yer × (yer 4 yön + 20 m + 60 m + tam tepe), (b) Mese ekseni boyunca 200 m'de bir ileri/geri, (c) 360 m'lik seyreltilmiş ızgarada 2 yön (K, G), (d) 360 m ızgarasında 60 m çapraz hava, (e) yürüyüşte takılma noktalarının önünden kare, (f) gece: bkz. §7. Yer karesinde kamera yapı içine düşerse sonda en yakın açık yere kaydırır (`GEZI_KAYDIR`); ilk 116 karelik koşuda bu kaydırma yoktu, o kareler "yapı içi" diye ayrıca sayıldı.
- **Gerçek oyuncuyla yürüyüş (`player.gd`, başsız):** 7 güzergâh, **toplam 2 095 gerçek m** (dünya 733 m; ölçek 0,35). Ham satırlar `yuru_ham.txt`. Güzergâhlar düz çizgidir (sokağı izlemez); bu yüzden "takılma" sayıları sokak değil BİNA duvarına çarpma olabilir (aşağıda §3'te ŞÜPHELİ).

## 2. GENEL NOT: **4 / 10**

Sahibi bu bölgeyi gezse ilk iki şeye kızar: (1) Marmara deniz suru boyunca kulelerin bir kısmı DOKUSUZ BEYAZ, surun gri gövdesinden kopuk küpler (üstten ve 60 m'den bile dişli gibi sıralı) ve Psamatya kule yanında havada asılı beyaz parçalar; (2) hemen her ağaç/çalı "oyuncak" çokgen balon (düz yüzlü açık yeşil/pembe/beyaz/mor taç) ve bostan/sarnıç alanları (Langa, Mokios) hâlâ bomboş parlak çayır, üstünde cetvelle kesilmiş dikdörtgen "ot" levhaları.
Üçüncü kızacağı şey: eşek hâlâ kutu (Altın Kapı iç yakası), Mese'nin sarı-turuncu doygun kaldırımı ve forum döşemesi ile kaidesi çıplak küp olan Tauri sütunu. Bous/Aksaray'daki Mese çarşısı (tezgâh, insan, kaldırım, saçak) ise bölgenin en iyi yeri: yaşam dolu.

## 3. BULGU TABLOSU

| no | tür | önem | yer adı | doğu, kuzey | kare dosyası | ne görünüyor | kaynak | öneri |
|---|---|---|---|---|---|---|---|---|
| 1 | BOŞLUK/YAŞAM | 1 | Langa bostanı | -2250,-560 | `kare/L_langa_bostan_h20.jpg`, `kare/L_langa_bostan_top.jpg` | ~300 m'lik açık çayır: tek tük ağaç ve kare bostan tarla dışında iş yok; sıra, tezgâh, insan, hayvan görünmüyor | mahalle_doku.gd (bostan türü) | çiftçi, sebze sıraları, kuyu, hayvan, çit |
| 2 | GÖRSEL | 1 | Marmara deniz suru (Arkadius önü) | -3444,-956 | `kare/L_arkadius_top.jpg`, `kare/L_arkadius_h60.jpg` | Sur kulelerinin bir kısmı DOKUSUZ BEYAZ düz küp (pah kesikli), gövdesi olan gri sura bitişik değil; kıyı boyunca sıralı | marmara_sur.gd (kule) / sur_doku.gd | beyaz levha materyalini ve kule gövdesini incele (bilinen: uzak deniz suru beyaz) |
| 3 | GÖRSEL | 1 | Psamatya kapısı / Marmara suru | -4272,-1475 | `kare/L_psamathia_sur_y90.jpg` | Kule yanında HAVADA asılı iki beyaz parça (silindir + küp), hiçbir şeye bağlı değil | marmara_sur.gd:_tower (pencere/mazgal parçası?) | parçaları kuleye göm ya da kaldır |
| 4 | GÖRSEL | 1 | Tauri Forumu batı yanı (Mese) | -1750,100 | `kare/M_20_geri.jpg` | İki evin çatıları arasında HAVADA duran bej basamaklı zikzak kiriş/merdiven (hiçbir yere dayanmıyor) | ayrinti_sokak.gd / sehir.gd (çatı ayrıntısı; kaynağı düğümle doğrulanmadı) | kaynağı bul; çatıya oturt ya da kaldır |
| 5 | KUTU | 1 | Langa bostanı (Eleutherios) | -2250,-560 | `kare/L_langa_bostan_y90.jpg`, `kare/L_langa_bostan_y180.jpg` | Ağaç tacları düz yüzlü (flat-shaded) çok yüzlü iri kayalar gibi: açık yeşil, koyu yeşil, pembe, beyaz; yaprak dokusu yok. Tam "oyuncak ağaç" (kalite 32) | bitki.gd:tree_mesh (taç ağı) | taçları yaprak kümesi dokulu ve yumuşak normalli yap |
| 6 | KUTU | 1 | Marmara deniz suru (Langa) | -2250,-700 | `kare/L_langa_bostan_top.jpg`, `kare/L_langa_bostan_h60.jpg` | Dokusuz beyaz düz küp kuleler surun GRİ gövdesinden ayrı, sıra sıra (kıyı boyunca beyaz dişler) | sehir_eser.gd:sur_uzak_mat / sehir.gd:2107 | beyaz materyal ve kule konumunu düzelt (bilinen) |
| 7 | KUTU | 1 | Altın Kapı iç yakası (Mese başı) | -4800,-1650 | `kare/M_01_ileri.jpg` | Eşek kutulardan yapılmış: dikdörtgen gövde, kutu baş, kutu bacaklar, sepet; "ayaklı sandık" (kalite 32 doğrudan ihlal) | hayat_yakin_govde.gd / hayat_mesh.gd (hayvan) | yuvarlak kesitli gövde (CANLI işi, bilinen) |
| 8 | BOŞLUK/YAŞAM | 2 | Tauri Forumu | -1650,150 | `kare/M_21_geri.jpg`, `kare/M_21_ileri.jpg` | ~200 m'lik döşeli forum meydanında 3-5 kişi var; tezgâh/tente/çeşme/hayvan yok: "kişisiz meydan" | forumlar.gd (Tauri) | tezgâh, ağır arabalar, kalabalık |
| 9 | GÖRSEL | 2 | Theodosius (Tauri) Forumu | -1554,211 | `kare/L_tauri_y180.jpg` | Havada asılı beyaz kavis (yarım kemer) siyah taş kemerin yanında, bağlantısı yok | forumlar_yapi.gd:kemer_taslar | kemeri sütuna oturt |
| 10 | GÖRSEL | 2 | Altın Kapı | -4857,-1698 | `kare/L_altinkapi_y0.jpg`, `kare/L_altinkapi_y90.jpg` | Kamera sur kulesinin içinde: lacivert boşluk, duvar arka yüzü yok (oyuncu girerse görür) | surlar_kapi.gd | oyuncuya kapalı olduğunu doğrula |
| 11 | GÖRSEL | 2 | Psamatya kapısı / Marmara suru | -4272,-1475 | `kare/L_psamathia_sur_y270.jpg`, `kare/L_psamathia_sur_y180.jpg` | Kule yüzünde çıplak beyaz kutu pencereler (dokusuz, çıkıntılı); kule koyu şeritleri doygun turuncu-kırmızı | marmara_sur.gd:_tower | pencereyi kemerli oyuk, şeridi tuğla mat |
| 12 | GÖRSEL | 2 | Psamatya kapısı | -4272,-1475 | `kare/L_psamathia_sur_y90.jpg`, `kare/L_psamathia_sur_y0.jpg` | İskele/rıhtım tahtası ve büyük krem panolu A-çerçeve ("tabela" gibi) çıplak, kıyıda yerden kopuk görünüyor | marmara_liman.gd | dönem: yazı yok, ağ germe çerçevesi yap |
| 13 | GÖRSEL | 2 | Altın Kapı iç yakası | -4800,-1650 | `kare/M_01_ileri.jpg` | Merdiven basamakları üçgen testere dişi gibi yan yana dizili, yamuk; merdiven mi kayalık mı belli değil | sokak.gd/ayrinti_sokak.gd (merdiven) | basamağı düz dikdörtgen yap |
| 14 | GÖRSEL | 2 | Altın Kapı iç yakası | -4800,-1650 | `kare/M_04_geri.jpg` | Dev kırmızı tuğla silindir kule: tuğla çok doygun parlak kırmızı (notlar: soluk kahve-kırmızı) | sur_doku.gd / surlar_kapi.gd | renk doygunluğunu düşür |
| 15 | GÖRSEL | 2 | Altın Kapı iç yakası | -4800,-1650 | `kare/M_03_geri.jpg`, `kare/M_04_ileri.jpg` | Dış sur kuleleri koyu kurşun-gri ve doygun turuncu şeritli (iç tarafın bej-krem taşı ile uyumsuz) | sur_doku.gd | şeritleri tuğla tonuna çek |
| 16 | GÖRSEL | 2 | Altın Kapı | -4857,-1698 | `kare/M_00_ileri.jpg`, `kare/M_00_geri.jpg` | Kapı geçidinin içine düşen kamerada lacivert boşluk: kule bedeni içi boş, kapı geçidi arkası kapalı mı belli değil | surlar_kapi.gd | kontrol |
| 17 | GÖRSEL | 2 | Tauri Forumu | -1650,150 | `kare/M_21_ileri.jpg` | Ufukta ev çatılarının üstünde ince bej çubuk/levha parçaları havada yüzüyor (4–5 adet) | ŞÜPHELİ: ayrinti_sokak.gd (çatı çubukları) | kaynağı doğrula |
| 18 | GÖRSEL | 2 | Kara suru iç yanı | -4950,-1180 | `kare/G_-4950_-1180_y0.jpg` | Sur gövdesi bej-krem ile aşırı sık, doygun turuncu şeritli (bant sıklığı tahta kaplama gibi) | sur_doku.gd | şerit sıklığı seyrelt |
| 19 | KUTU | 2 | Mokios sarnıcı çevresi | -3806,189 | `kare/L_mokios_y0.jpg` | Pembe, düz yüzlü (facet) "erguvan" ağaç tacı: oyuncak balon gibi, yaprak dokusu yok | bitki.gd:_agac (erguvan) | taç kürelerini birleştir, renk soluk morumsu-yeşil, yaprak dokusu |
| 20 | KUTU | 2 | Mokios sarnıcı çevresi | -3806,189 | `kare/L_mokios_y90.jpg` | Sarnıç duvarının üstünde yeşil düz levha çatılı dört ayaklı "masa" gölgelik ve duvara yaslı çıplak bej küp | bitki_yama.gd? (sarnıç bostanı kiti) | çatıyı hasır/çardak yap, küpü kaldır |
| 21 | KUTU | 2 | Aksaray (Bous) Mese | -2540,-70 | `kare/L_bous_y90.jpg`, `kare/L_bous_h20.jpg` | Açık yeşil, düz yüzlü lolipop ağaçlar (balon taç) sokak başlarında | bitki.gd:_agac | taçları örgülü kürelerle yap |
| 22 | KUTU | 2 | Theodosius (Tauri) Forumu | -1554,211 | `kare/L_tauri_y0.jpg`, `kare/L_tauri_h20.jpg` | Zafer sütununun kaidesi çıplak, dokusuz krem-beyaz küp; üstüne beyaz spiral sütun; yanında kahverengi basamaklı piramit (merdiven yığını) | forumlar_yapi.gd:sutun / forumlar.gd | kaideye derz+pah+leke ver |
| 23 | KUTU | 2 | Theodosius (Tauri) Forumu | -1554,211 | `kare/L_tauri_y0.jpg`, `kare/L_tauri_y90.jpg` | Yeşil-beyaz damalı pagoda çatılı kule ve mavi-beyaz benekli silindir: 1453 Bizans'ına yabancı, oyuncak renkli | forumlar.gd (?) | renk ve çatıyı Bizans'a çevir |
| 24 | KUTU | 2 | Tauri çevresi | -1554,211 | `kare/L_tauri_y0.jpg`, `kare/L_tauri_y90.jpg` | Beyaz pamuk topu gibi yüz yüzlü "ağaç" kümeleri forumun çevresinde | bitki.gd | beyaz taç yerine badem çiçeği dokusu |
| 25 | KUTU | 2 | Xerolophos | -3400,-480 | `kare/L_xerolophos_top.jpg` | Dikdörtgen surlu avluda tek tip sıralı kahverengi çubuklar (ızgara) – ne olduğu anlaşılmıyor; bomboş | sehir_eser.gd? | avluyu pazar/askerî revir gibi canlandır |
| 26 | KUTU | 2 | Kyparission | -3200,300 | `kare/L_kyparission_top.jpg`, `kare/L_deuteron_h20.jpg` | Birçok evin düz çatısında parlak açık yeşil düz levha (kiremitsiz) | evler.gd (düz çatı) | çatı: toprak/kil damı rengi |
| 27 | KUTU | 2 | Kyparission | -3200,300 | `kare/L_kyparission_y90.jpg`, `kare/L_deuteron_h20.jpg` | Düz yüzlü pembe/açık yeşil çalı kümeleri (poligon balon) evlerin dibinde | bitki.gd | aynı |
| 28 | KUTU | 2 | Mokios sarnıcı bostanı | -3670,-70 | `kare/L_sarnic_mokios2_y0.jpg`, `kare/L_sarnic_mokios2_y90.jpg` | Dev düz yüzlü (poligon) ağaç tacı, mor/beyaz/yeşil; beyaz konik servi; çim üstünde koyu-yeşil kahverengi düz şeritler | bitki.gd:tree_mesh, selvi | aynı |
| 29 | MANTIK | 2 | Xerolophos (7. tepe) | -3400,-480 | `kare/L_xerolophos_y0.jpg`, `kare/L_xerolophos_y90.jpg` | Kamera bir yapının içine düştü: içerisi tamamen boş, iç yüzeyler yok (lacivert boşluk görünüyor) | sehir.gd (ev kabuğu) | iç yüz ya da kapat |
| 30 | MANTIK | 2 | Deuteron/Vlanga ızgara düğümleri | -3900,1300 / -1500,-500 | `kare/L_deuteron_y0.jpg`, `kare/L_deuteron_y90.jpg` | Yapı içine düşen kamera: duvarın arka yüzü yok, içi lacivert boşluk (dış kabuk çift yüz değil) | sehir.gd (bina kabuğu) | iç yüz ya da kapı kapalıysa girilmez doğrula |
| 31 | PERFORMANS | 2 | Bölge geneli (yer karesi) | -4800..-1500 | `kare/L_vlanga_y0.jpg`, `kare/L_tauri_y270.jpg` | Yer karelerinin 31/86'sında üçgen 2,5 M bütçesini aşıyor (en çok 3,36 M); çizim 1 200 altında | IstDunya/IstSehir LOD (rinfo_ham.txt) | yakın katman üçgen bütçesi: bina ayrıntısı/gölge geçişi LOD'a bağla |
| 32 | ZEMİN | 2 | Mokios sarnıcı çevresi | -3806,189 | `kare/L_mokios_y0.jpg`, `kare/L_mokios_y180.jpg` | Düz parlak yeşil zemin üstünde aynı koyu "ok/ot" damgası tekrar ediyor; yeşil çim ile sarı toprak yaması cetvel keskinliğinde | bitki_yama.gd / mahalle_doku.gd (arazi damga) | damgayı seyrelt, yama kenarına gürültü ve geçiş |
| 33 | ZEMİN | 2 | Aksaray (Bous) Mese | -2540,-70 | `kare/L_bous_y0.jpg`, `kare/L_bous_y90.jpg` | Mese kaldırımı doygun turuncu-sarı (oyuncak), notlardaki sıcak gri-krem değil; kalıp tekdüze | mahalle_doku.gd (kaldırım) | rengi gri-krem'e indir |
| 34 | ZEMİN | 2 | Aksaray (Bous) üst | -2540,-70 | `kare/L_bous_top.jpg`, `kare/L_bous_h20.jpg` | Çimen yamaları parlak limon yeşili, dikdörtgen, cetvelle kesik; evlerin arasında kare yeşil levhalar | bitki_yama.gd | yama sınırını gürültüyle bük, rengi sönükleştir |
| 35 | ZEMİN | 2 | Theodosius (Tauri) Forumu | -1554,211 | `kare/L_tauri_y180.jpg`, `kare/L_tauri_h20.jpg` | Forum döşemesi iri, nane-gri karolar (1,5 m); kenarı toprakla basamak basamak cetvel kesik; döşeme sınırı kare | forumlar.gd (döşeme) | karoyu küçült, kenarı düzensiz yap |
| 36 | ZEMİN | 2 | Xerolophos | -3400,-480 | `kare/L_xerolophos_h60.jpg` | Evlerin arasında düz limon-yeşil çatılı kutular | evler.gd | çatı kiremit yap |
| 37 | ZEMİN | 2 | Langa bostanı | -2250,-560 | `kare/L_langa_bostan_y90.jpg`, `kare/L_langa_bostan_y270.jpg` | Parlak, tek ton çim üstünde dağınık sarı-yeşil DİKDÖRTGEN küçük levhalar (ot öbeği yerine); kenarı cetvel gibi | bitki_yama.gd (ot öbeği) | öbekleri sivri çok-yapraklı yap |
| 38 | ZEMİN | 2 | Langa bostanı | -2250,-560 | `kare/L_langa_bostan_h60.jpg`, `kare/L_langa_bostan_top.jpg` | Bostan "tarlaları" beyaz çerçeveli açık yeşil kare yamalar (futbol sahası gibi), sebze dokusu yok | bitki_yama.gd | sıra sıra toprak/ekin dokusu |
| 39 | ZEMİN | 2 | Psamatya kapısı | -4272,-1475 | `kare/L_psamathia_sur_y90.jpg`, `kare/L_psamathia_sur_y180.jpg` | Alçak mendirek/duvar üstü PARLAK yeşil elmas karolu kaplama (oyuncak), çevresi su gibi dalgalı camgöbeği zemin | marmara_kiyi.gd / marmara_liman.gd | taş kaplama gri, zemin toprak/çakıl |
| 40 | ZEMİN | 2 | Altın Kapı–Mese | -4700,-1600 | `kare/M_02_ileri.jpg`, `kare/M_03_ileri.jpg` | Kaldırım tuğlaları iri, doygun sarı-turuncu; yamaç boyunca aynı desen; çevre çimen parlak sarı-yeşil | mahalle_doku.gd | sıcak gri-krem |
| 41 | GÖRSEL | 3 | Mokios sarnıcı çevresi | -3806,189 | `kare/L_mokios_y0.jpg`, `kare/L_mokios_y180.jpg` | Gölge kenarları basamak basamak (shadow map çözünürlüğü), zeminde merdiven gibi kırık gölge çizgisi | dunya.gd DirectionalLight shadow ayarı | shadow bölme/bias artır |
| 42 | GÖRSEL | 3 | Gökyüzü (her yerde) | -3806,189 | `kare/L_mokios_y0.jpg`, `kare/L_bous_y0.jpg` | Bulut sprite'ları dört kanatlı pervane gibi küçük beyaz haç; bulut okunmuyor | dunya.gd Gok (bulut) | yumuşak bulut katmanı |
| 43 | GÖRSEL | 3 | Kyparission | -3200,300 | `kare/L_kyparission_y0.jpg` | Sokak boyunca saçak levhası parlak turuncu (doygun) kenarlı kalın düz tahta; saçak altı çıplak | evler.gd (saçak) | saçağı koyu ahşap, kalınlığı incelt |
| 44 | GÖRSEL | 3 | Psamatya kapısı | -4272,-1475 | `kare/L_psamathia_sur_y180.jpg` | Yerde yamuk duran düz krem levha üstünde kutular (tezgâh?) yarı gömülü | marmara_liman.gd | oturt |
| 45 | KUTU | 3 | Theodosius (Tauri) Forumu | -1554,211 | `kare/L_tauri_y90.jpg`, `kare/L_tauri_y180.jpg` | Zeminde çıplak küçük beyaz levha/bloklar serpili | forumlar_yapi.gd:moloz | moloz biçimine çevir |
| 46 | KUTU | 3 | Studios yöresi | -4318,-1390 | `kare/L_psamathia_sur_top.jpg` | Çok doygun kırmızı-turuncu uzun çatılı basilika (düz levha çatı), civarda hiç ağaç/duvar yok | kiliseler_manastir.gd (Studios) | çatı soluk kiremit |
| 47 | MANTIK | 3 | Langa bostanı | -2250,-560 | `kare/L_langa_bostan_y270.jpg`, `kare/L_langa_bostan_y0.jpg` | Ufukta uzun düz beyaz bant (çıplak uzak sur) bostanın hemen arkasında | sehir.gd:2107 | aynı |
| 48 | MANTIK | 3 | Altın Kapı iç yakası | -4750,-1620 | `kare/M_02_geri.jpg` | Kırmızı pagoda çatılı kilise üstünde altın haç, civarında Osmanlı bayrağı değil sarı bayrak; çatı levha biçimli | kiliseler_*.gd | çatıyı kubbe/beşik |
| 49 | ZEMİN | 3 | Psamatya kıyısı | -4272,-1475 | `kare/L_psamathia_sur_h20.jpg`, `kare/L_psamathia_sur_top.jpg` | Çıplak sarı-turuncu eş şekilli taş kaplama kıyı boyunca geniş bant; üstüne yama gibi koyu yeşil çim ve düz kenar | sur_zemin.gd | kaplamayı kır, otlan |
| 50 | ZEMİN | 3 | Kara suru iç yanı (Studios–Altın Kapı arası) | -4950,-1180 | `kare/G_-4950_-1180_y0.jpg` | Çim zeminde tekrarlayan koyu kesik çizgi/ok damgası; sur dibi çimeni düz ve tekdüze | bitki_yama.gd:_ground | damgayı seyrelt |

## 4. Tür başına sayım

- GÖRSEL: 17
- KUTU: 15
- ZEMİN: 11
- MANTIK: 4
- BOŞLUK/YAŞAM: 2
- PERFORMANS: 1
- toplam bulgu: 50
- önem 1: 7, önem 2: 33, önem 3: 10
- **KUTU kalan=15** (hedef 0)


## 5. En kötü 12 kare

1. `kare/L_langa_bostan_y180.jpg`, `kare/L_langa_bostan_y90.jpg` — dev düz yüzlü poligon ağaç tacı (kareden yarısını kaplıyor).
2. `kare/L_langa_bostan_top.jpg` — beyaz çerçeveli kare "tarla"lar, 300 m boş çayır, sur dibinde beyaz küp kuleler.
3. `kare/L_psamathia_sur_y90.jpg` — havada asılı beyaz silindir + küp, parlak yeşil elmas karolu mendirek, krem "tabela".
4. `kare/L_arkadius_top.jpg` — kıyı suru boyunca dokusuz beyaz küp kuleler, gövdeden kopuk.
5. `kare/L_tauri_y0.jpg` — çıplak krem kaide, sütun, kare gövdeli kahverengi basamak piramidi; döşeme 1,5 m'lik gri levhalar.
6. `kare/M_01_ileri.jpg` — kutu eşek, testere dişi merdiven basamakları.
7. `kare/M_20_geri.jpg` — iki çatı arasında havada zikzak bej kiriş.
8. `kare/L_mokios_y0.jpg` — pembe balon ağaç, keskin kenarlı sarı toprak yaması, dikdörtgen gölge basamağı, çardak üstü yeşil levha.
9. `kare/L_sarnic_mokios2_y90.jpg` — dev mor poligon taç, çimde dikdörtgen kahverengi şeritler.
10. `kare/L_tauri_h20.jpg` — kare döşeme + eğri/yamuk sütun + basamaklı kenar.
11. `kare/L_psamathia_sur_top.jpg` — Studios kırmızı levha çatılı kilise, çıplak turuncu kaplama bandı.
12. `kare/M_04_geri.jpg` — dev, çok doygun parlak kırmızı tuğla kule, sarı-kahve doygun kaldırım.

## 6. İyi olan 5 kare (korunacaklar)

1. `kare/L_bous_y0.jpg` / `L_bous_y180` — Mese çarşısı: tezgâhlar, insanlar, taş-tuğla şeritli duvar, saçaklar; sokak yaşam dolu.
2. `kare/L_bous_h20.jpg` — Mese'nin havadan görüntüsü: şerit yol, çevre evler, kalabalık.
3. `kare/L_kyparission_y0.jpg` — dar toprak sokak, saçaklar, taş duvarlar, oturan/gezen kişiler; doğal.
4. `kare/L_psamathia_sur_h20.jpg` — Marmara suru gri taş + mazgal bütün hat boyunca kesintisiz, kıyıda kaplama.
5. `kare/L_altinkapi_h60.jpg` — Altın Kapı kuleleri + Mese + iç mahalle bütünlüğü.

## 7. Bakamadıklarım / yapamadıklarım

- Tam 60 m ızgara ve 15 m'de bir yol karesi (§1); Studios Manastırı'nın kendisi (koordinat denizde kaldı; CSV koordinatı -4318,-1390 çekildi); Mokios sarnıcı içine inme, Arkadius sütunu dibi (koordinat suya düştü: `GEZI_SU atlandi`).
- Binaların içine girilebilir mi: doğrulanmadı (yalnız kamera içinden bakıldı; "iç yüz yok / lacivert boşluk" gördüm).
- RINFO (ham satırlar `rinfo_ham.txt`; oyunun kendi ölçüsüyle aynı `RENDERING_INFO_TOTAL_*_IN_FRAME`): yer karelerinde (86 kare) çizim en çok 1 162 (< 1 200) AMA **31 karede üçgen > 2,5 M (en çok 3,36 M `L_vlanga_y0`)**; hava karelerinde (39 kare) çizim en çok 1 213 (< 1 500), üçgen en çok 2,77 M (< 3,5 M). Kurulumda > 50 ms kare ayrıca ölçülmedi (KANITSIZ).
- Oyun kodu değişmedi: `git status` yalnız `tests/_ist/gezi_mese-bati.*` ve bu klasör.
