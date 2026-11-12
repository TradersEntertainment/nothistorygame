# İstanbul v2 — karış karış gezi denetimi: `kara-orta` (Rhegion, Romanos/Topkapı, Mesoteikhion, Pempton)

Denetçi: gezgin (dal `wip/gezi-kara-orta`, taban `wip/ist2-gezi-taban`). Oyun kodu DEĞİŞTİRİLMEDİ (yalnız `tests/_ist/gezi_kara-orta.gd/.tscn` ve bu klasör).
**DURUM: İLK GÖNDERİM (ara rapor).** Gece, tam ızgara ve oyuncu yürüyüşünün kalanı arka planda sürüyor; son rapor aynı dosyaya yazılacak.

## 1) Bölge sınırı, kare sayıları, yürüyüş

- Bölge: kara surunun Rhegion (Mevlanakapı, gerçek −4873, −512) → Pempton (≈ −4250, 1754 sur noktası) arası; kapılar: Rhegion, Romanos (Topkapı, hub'ın dış kapısı), Mesoteikhion (Lykos vadisi, ≈ −4657, 1283 yöresi), Pempton. Dış yan 200 m, iç yan 300 m.
- Dört köşe (gerçek doğu, kuzey m): GB (−5150, −560) · GD (−4650, −560) · KD (−3950, 1754) · KB (−4450, 1754).
- Sur hattı kaynağı: `IstGeo.R_KARA` (−560 ≤ kuzey ≤ 1800 dilimi); kapı konumları `sehir.gd` kapı kaydı (rhegion −4873,−512; romanos −4621,823; pempton −3906,1601 → sur hattına oturtulur).
- Kamera: `tests/_ist/sur4_kare.tscn --set=liste` (şehir kuyruğu boşalınca çeker). Kamera listeleri bu klasörde: `liste_A_sur_kapilar.txt` (sur boyu 180 m'de bir: dıştan 35 m, içten 28 m, sur dibinden; üç kapının çevresi 8 kare + üstü), `liste_E_ek.txt` (dıştan 70 m ve 35 m/6 m yükseklik; yürüyüş takılma noktaları), `liste_C_havadan.txt` (20 m, 60 m, 120 m çapraz, tam tepe ×3), `liste_B_izgara120.txt` (120 m ızgara), `liste_D_gece.txt`, `rotalar.txt` (yürüyüş rotaları).
- **ÇEKİLEN / BAKILAN (bu ara rapor):** A 69 + E 25 + C 33 = **127 çekildi / 127 bakıldı** (3×3 paftaların hepsi açıldı; şüpheli kareler tam boy açıldı). B (ızgara) / D (gece) / F (düşme kareleri) çekiliyor; bitince son raporda.
- **Izgara uyarısı (dürüstlük):** görevdeki 60 m ızgara × 4 yön (398 düğüm = 1 592 kare) yazılımla çizimde kare başına ~10–12 s ⇒ ~4,5 saat; 2,5 saatlik süreye sığmaz. Yapılan: 120 m ızgara (104 düğüm), her düğümde D+B (iç/dış), her ikinci düğümde K+G de (264 kare). Listede 60 m'lik tam liste `tests` altında değil, üretilen `liste_B_izgara120.txt` ile sınırlı; tam 60 m ızgara BAKILMADI.
- Yürüyüş (gerçek `Player`, başsız, `tests/_ist/gezi_kara-orta.gd`): R1 sur dibi iç 8 m, tüm bölge: **3 384 m yürünen** (282/359 dilim, 77 olay). R2 dış 25 m, R3 iç 60 m, üç kapı ve hub rotaları sürüyor (son raporda toplam km).
- RINFO (A+C, 102 kare ölçümü): ortalama çizim 1 131, üçgen 2,66 M; çizim > 1 200 olan 30 kare, üçgen > 2,5 M olan 69 kare (yer bütçesi 1 200 / 2,5 M **aşılıyor**; ham: `ham/rinfo.txt`).

## 2) GENEL NOT: 3 / 10

Sahibi bu bölgede sur dışına adımını atar atmaz kızar: dışarıdan göz hizasında hendek/set bir çukur gibi, gökyüzü yok, üstte bulutlu bej bir "tavan", altta camgöbeği çamur, yer yer düz lacivert boşluk (1–5). Sur yüzleri yakından düz bej ve çizgili, kapıların kanadı duvara yapıştırılmış levha ve Romanos kapalı, sur üstü beyaz küp ve düz tabliye. İçerisi (sur dibi sokağı, evler, insanlar) belirgin biçimde daha iyi; ama sur dibi yolunu kule payandaları kesiyor, hub turuncu bir oyuncak adası gibi duruyor.

GÖRSEL=23, KUTU=9, MANTIK=1, OYUNCU=1, ZEMİN=8 — toplam 42 bulgu (aşağıda). "BİLİNİYOR" sınıfındakiler de yerleriyle yazıldı.

## 3) BULGU TABLOSU

| no | tür | önem | yer adı | doğu, kuzey (kamera, gerçek m) | kare dosyası (kare/) | ne görünüyor | kaynak | öneri |
|---|---|---|---|---|---|---|---|---|
| 01 | ZEMİN | 1 | Rhegion önü, dış hendek kuşağı | -5020, -556 | e_dis70_00_-4950_-560.jpg | Sur dışından 70 m'de göz hizası: gökyüzü yok; üstte bulutlu bej-zeytin bir 'tavan' (set/kapak alt yüzü), altta düz camgöbeği çamur zemin; kamera çukurun içinde, dışarısı görünmüyor | surlar.gd:_build_moat (ZEMIN.CAMUR dibi + ZEMIN.set_ dış yaka seti) | Hendek/set çukuru sur dışı oyuncuyu gömmeyecek genişlik ve eğimde olmalı; set arka yüzü çift yüzlü ya da kapalı; gökyüzü görünmeli (ŞÜPHELİ kök neden: set ya da arazi kapağı) |
| 02 | GÖRSEL | 1 | Mevlanakapı–Topkapı arası, dış yaka | -4926, 447 | a06_-4892_456_dis.jpg | Üst yarı düz lacivert boşluk (kesik/arka yüzü çizilmeyen yüzeyler), altta yüzer gibi duran camgöbeği zemin şeridi ve altında yine lacivert: katman yarım kalmış | surlar.gd:_build_moat / ZEMIN.set_ (arka yüz çizimi); lacivert = gökyüzünün zemin rengi | Set/yaka yüzeylerini çift yüzlü yap; hendek dibinin altını kapat |
| 03 | GÖRSEL | 1 | Sur dışı, Lykos geçişi yakını | -4895, 820 | a08_-4861_810_dis.jpg | Eğik bej bir levha (set/kama) lacivert boşluğa karşı duruyor; zemin camgöbeği; sur yüzü yerine boşluk | surlar.gd:_wedge / ZEMIN.set_ | Kama yüzeyi dışa kapalı ve dokulu olsun |
| 04 | GÖRSEL | 1 | Mesoteikhion güney | -4687, 1298 | a11_-4656_1283_dis.jpg | Aynı boşluk: yarım çizilen yaka duvarı ve düz camgöbeği taban, üstü lacivert | surlar.gd:_build_moat | Bkz. 02 |
| 05 | GÖRSEL | 1 | Romanos Kapısı iç yanı, 22 m yükseklik | -4803, 999 | h20_07.jpg | Havadan kare tamamen lacivert: arazi, sur, ev hiçbiri çizilmemiş; yalnız dev kırmızı bayrak ve ince iplikler kalmış (yarım kalmış katman / çizim deliği) | ŞÜPHELİ: IstSehir sur/hub parçası görünürlüğü (sehir.gd:_show) ya da kamera hub KORU alanında; düğüm adı Ist_romanos | Aynı noktayı 60 m ve 120 m'den kontrol et (h60_07 normal): yakın LOD'da delik |
| 06 | ZEMİN | 2 | Rhegion dışı, hendek kıyısı | -4985, -558 | a00_-4950_-560_dis.jpg | Yeşil çim yamasının bıçak gibi keskin kenarı, önünde dokusuz açık nane-beyaz düz taban; zemin ile set arasında çizgi | surlar.gd:_build_moat (ZEMIN.set_ / ZEMIN.CAMUR); ZEMIN malzemesi | Kenar karışımı (blend) ve doku; beyaz düz taban kaldır |
| 07 | ZEMİN | 2 | Romanos Kapısı koridoru | -4833, 903 | k_romanos_2.jpg | Kapı koridorunda dokusuz açık nane-beyaz geniş şerit (yol?) çamur ve çimin üstünde; kenarları cetvelle kesilmiş | surlar.gd:_run (koridor:true, Romanos) | Taş/toprak yol dokusu, kenar aşınması |
| 08 | ZEMİN | 2 | Romanos Kapısı önü | -4841, 876 | k_romanos_3.jpg | Sur dibinde iri karelerden oluşan camgöbeği-mavi karo zemin, mavi derz çizgileri: not 17/28'deki 'camgöbeği gölge/iri karo' hâlâ var | surlar.gd:_s ('dirt'/döşeme deseni) + ZEMIN | Sıcak gri-krem Prokonnesos tonu, ince düzensiz derz |
| 09 | MANTIK | 2 | Romanos Kapısı (Topkapı) | -4850, 894 | k_romanos_0.jpg, k_romanos_1.jpg | Koridorun sonunda kapalı ahşap kapı kanadı; geçit yok. Gerçek oyuncu yürüyüşü (gezi_kara-orta, R_kapi_romanos): kapının önünde takılma, engel düğümü Ist_romanos/L0/AzizRomanos (0,3/1,0/1,7 m üçünde de) | surlar.gd:OPTS["romanos"] (kapali anahtarı yok ama kanat var) / sehir.gd:_kapi_gecit | Kanat açık ya da küçük kapı aç; ya da kapı kapalıysa koridoru gerçek sur dibinde kapat |
| 10 | GÖRSEL | 2 | Rhegion Kapısı | -4933, -508 | k_rhegion_1.jpg | Kapı kanadı duvara yapıştırılmış düz levha; kemer tuğlası somon-turuncu (oyuncak doygunluğu); yanındaki 'kapı' çok küçük | surlar.gd:_run (gate) / C_BRICK | Kapıyı sur içine al (derinlik), kemer rengini soluk tuğlaya indir |
| 11 | KUTU | 2 | Rhegion sur yüzü (iç) | -4835, 801 | a08_-4861_810_ic.jpg | Duvarda 0,5×1,1 m siyah dikdörtgen 'kapı' + kırmızı lento: kutu, ölçek insan altı, derinliksiz boyalı delik gibi | surlar.gd:_wall_niches (dark/lint MultiMesh kutuları) | Gerçek nişe çevir (içe oyuk, kemer) ya da kaldır |
| 12 | KUTU | 3 | Dış sur yüzü, Mesoteikhion öncesi | -4895, 820 | e_dis35y6_04_-4861_810.jpg | Dış surda 3 siyah dik çubuk yarık: mazgal gibi ama derinliksiz kutu | surlar.gd:_wall_niches (ikinci sıra, OH*0.5) | Yarığa içe eğimli pah ve gölge |
| 13 | GÖRSEL | 2 | Pempton, sur dibi | -4260, 1744 | k_pempton_0.jpg | Yakında taş blokların yüzü düz bej, ince dikey çizgili (moiré); derz/doku kaybolmuş | surlar.gd:_s (pat 'ashlar') / Props.mat doku ölçeği | Yakın LOD'da taş normal haritası ve derz |
| 14 | GÖRSEL | 2 | Mesoteikhion güneyi sur dibi | -4546, 1421 | a12_-4551_1427_surdibi.jpg | Sur yüzü düz soluk bej + çapraz tarama, dokusuz geniş levha; üstte turuncu kornişte keskin kenar | surlar.gd:_s / _inner_tower | Bkz. 12 |
| 15 | GÖRSEL | 2 | Pempton, kapı yanı | -4241, 1765 | k_pempton_1.jpg | Bordo tuğla bandının altında dokusuz koyu zeytin düz panel, harç yok | surlar.gd:_s | Taş doku |
| 16 | KUTU | 2 | Mesoteikhion iç, sur dibi sokağı | -4729, 1134 | a10_-4736_1137_surdibi.jpg | Eşek: kutu gövde, kutu bacak, kare baş (kutu yasağı); koyu yeşil kaba çokyüzlü ağaç tacı | hayat_mesh.gd (eşek), bitki.gd:tree_mesh (taç) | Yuvarlak kesitli gövde; taç için yumuşak normal |
| 17 | KUTU | 2 | Rhegion iç, sur dibi | -4865, -47 | a03_-4867_-40_surdibi.jpg | Beyaz kaba çokyüzlü ağaç tacı ince gövdede; yanında sur içinde parlak yeşil küp çalı | bitki.gd:tree_mesh | Taç dokusu, renk ve yumuşak biçim |
| 18 | KUTU | 3 | Pempton iç | -4332, 1699 | a14_-4338_1704_surdibi.jpg | Pembe-mor erguvan tacı kaba çokyüzlü yassı; yanında sundurma kirişleri ve kemer basamakları kutu | bitki.gd:build_erguvan | Tacı yumuşat |
| 19 | KUTU | 3 | Pempton iç, sur dibi | -4447, 1561 | a13_-4453_1566_surdibi.jpg | Yaşlı kişi yerde beyaz küp kasa/çuvallar arasında; yığın çıplak küpler | ayrinti_a.gd (sokak malı), Props | Çuval/kasa çeşitliliği, pah |
| 20 | ZEMİN | 2 | Mesoteikhion iç, sur dibi yolu | -4884, 458 | a06_-4892_456_surdibi.jpg | Toprak yol yaması çokgen, keskin köşeli; çimle bıçak çizgisiyle ayrılıyor; teal gölge ile 'halı' gibi | ayrinti_sokak.gd / ZEMIN yol yaması | Yama kenarı yumuşat, yol dar ve eğri olsun |
| 21 | GÖRSEL | 3 | Rhegion iç, sur gölgesi | -4837, 100 | a04_-4865_100_ic.jpg | Sur gölgesinin zemindeki kenarı testere dişi basamaklı; zeminde çimle toprak sınırı keskin | dunya.gd güneş gölge çözünürlüğü / ZEMIN | Gölge bias ve çözünürlük |
| 22 | GÖRSEL | 2 | Rhegion iç, 28 m | -4866, 629 | a07_-4894_633_ic.jpg | Lacivert boşluğun içinde havada duran küçük bej levhalar ve kapı kemeri: yapının arka yüzü çizilmiyor | ŞÜPHELİ: tek yüzlü ev/duvar kabuğu (evler.gd); kamera yapı içinde | Evleri çift yüzlü ya da arka yüzü kapalı yap |
| 23 | GÖRSEL | 2 | Rhegion iç | -4890, -207 | a02_-4918_-202_ic.jpg | Kare tamamen lacivert, sağda ince tuğla şeridi: duvar arka yüzü çizilmiyor | ŞÜPHELİ: sur dilimi arka yüz (surlar.gd:_s) | Bkz. 21 |
| 24 | GÖRSEL | 2 | Mesoteikhion, sur dibi | -4649, 1279 | a11_-4656_1283_surdibi.jpg | Sağda dev siyah dikdörtgen: sur yüzünün çizilmeyen parçası, arkasında gökyüzü | ŞÜPHELİ: surlar.gd:_run dilim birleşimi | Dilim birleşimlerinde boşluk kontrolü |
| 25 | GÖRSEL | 2 | Mesoteikhion iç | -4800, 978 | a09_-4808_981_surdibi.jpg | Siyah dik levha + kırmızı kornişli büyük 'kapı' kutusu; yerde iri camgöbeği karolar | surlar.gd:_wall_niches / ZEMIN | Bkz. 10, 8 |
| 26 | GÖRSEL | 3 | Rhegion, hendek | -4952, -195 | e_dis35y6_01_-4918_-202.jpg | Hendek duvarında bordo tuğla bandı koyu mavi-gri taşa karşı; zeminde parlak yeşil küp yaprak öbeği (sarmaşık küplerden) | surlar.gd:_build_moat (sarmaşık MultiMesh) | Yaprak kartı |
| 27 | KUTU | 3 | Mesoteikhion dış | -4928, 830 | e_dis70_04_-4861_810.jpg | Sur tepesinde yeşil küp yaprak parçaları; yerde açık gri-beyaz dokusuz teras ve onu kesen çapraz siyah çizgi | surlar.gd:_build_moat | Küp yaprak→yaprak kartı; terası dokula |
| 28 | GÖRSEL | 3 | Topkapı iç tarafı yakını | -4801, 1163 | e_dis70_05_-4736_1137.jpg | Sur ortasında havada duran altı gri-beyaz oval taş; üstünde yeşil küpler (ŞÜPHELİ: ne olduğu belli değil) | ŞÜPHELİ: surlar.gd MultiMesh (taş/gülle yığını) | Neyin olduğu belirsiz; ya yere otursun ya kalksın |
| 29 | KUTU | 2 | Sur üstü, Rhegion–Mesoteikhion | -4900, 330 | h20_04.jpg | Sur üstünde beyaz küpler ve düz gri-yeşil dokusuz yürüme yolu; kule mazgalları beyaz küp (BİLİNİYOR) | surlar.gd:_parapet_x, _roof_ring | Bilinen: SUR |
| 30 | KUTU | 2 | Sur üstü, Rhegion iç | -4935, -77 | h20_02.jpg | Mazgal dişleri açık mavi-beyaz küp sırası; sur duvarı yeşil-gri, kule penceresi siyah kutu | surlar.gd:_parapet_x | Mazgalı taş renginde, pahlı yap |
| 31 | GÖRSEL | 2 | Romanos iç, hub mahallesi | -4976, 845 | h60_06.jpg | Hub: doygun turuncu çatılı oyuncak mahalle, altında çıplak beyaz levha, keskin dikdörtgen sınır; çevre mahalleden kopuk renk | sehir.gd:hub (ByzCity far_hub), baglama.gd:donusum("byz_walls") | Hub palet ve zemin geçişi (kenar yumuşatma) |
| 32 | ZEMİN | 1 | Sur dışı, Mesoteikhion karşısı | -4840, 928 | h60_07.jpg | Sur dışında kahverengi-yeşil çizgili diyagonal arazi şeritleri; yamalar cetvelle kesilmiş, 'yeşil alan yükseltileri' hâlâ var | surlar.gd:_build_moat (ZEMIN.set_) / dunya.gd arazi | Seti organik tepeli yap, şerit yok |
| 33 | ZEMİN | 1 | Sur dışı, Lykos–Pempton | -4339, 1672 | h60_11.jpg | Sur dışında eğimli yeşil/kahve geniş çizgili set; çadır denizi uzakta; tek renkli bantlar | surlar.gd:_build_moat | Bkz. 31 |
| 34 | ZEMİN | 2 | Sur dışı, 120 m çapraz | -5014, 857 | hx_03.jpg | Surun dışındaki arazi yeşil-kahve diyagonal çizgili şeritler; hendek koyu kahverengi dikdörtgen levha gibi | surlar.gd:_build_moat | Bkz. 31 |
| 35 | GÖRSEL | 2 | Sur hattı, Pempton | -4826, 1299 | hx_04.jpg | Sur ve kuleler krem-beyaz düz kutu; hendek siyah-kahverengi dikdörtgen; kule çatısı mor-gri levha (BİLİNİYOR) | sehir.gd (uzak sur dilimi), surlar.gd | Bilinen: SUR |
| 36 | GÖRSEL | 2 | Sur dışı, tam tepeden | -4700, 650 | hh_tepe_orta.jpg | Tam tepeden: sur hattı koyu kahverengi bant, sur dışı çadır kümesi koyu kahverengi kabarcık yığını, iç yanda hub'ın beyaz kare levhası | sehir.gd uzak sur, ordugah.gd (BİLİNİYOR) | ORDUGÂH/SUR |
| 37 | GÖRSEL | 2 | Rhegion, kapı koridoru | -4987, -505 | k_rhegion_4.jpg | Kapı dibinden bakış: siyah-kahve dev levha ve altında düz bej şerit, doku yok | ŞÜPHELİ: surlar.gd:_run kapı koridoru | Doku ver |
| 38 | GÖRSEL | 3 | Romanos koridoru | -4832, 888 | k_romanos_ust_dis.jpg | Dar, uzun taş koridor, iki yanda çok yüksek duvar, zemin açık düz; kapı kemeri sonda; bastırıcı boş | surlar.gd:_run (koridor) | Koridoru kısalt/yaşam (nöbetçi, tezgâh) ekle |
| 39 | GÖRSEL | 3 | Rhegion sur tepesi | -4975, -318 | h20_01.jpg | Sur üstünde sancak parlak kırmızı oyuncak levha + sarı kare; kule çatısı kırmızı-kahve levha | surlar.gd:_roof_ring, bayrak | Sancağa dalga |
| 40 | OYUNCU | 2 | Sur dibi iç yol (sura 8 m), Rhegion→Pempton | -4902, -180 | e_tak0_-4902_-170.jpg, e_tak2_-4849_22.jpg, e_tak4_-4853_320.jpg | Gerçek oyuncu sur dibinden yürüyünce 359 dilimden 77'sinde takıldı/düştü (62 takılma: 37 köşe kule gövdesi, 21 sur dilimi W*, 6 kdolgu, 3 Ist_romanos, 1 Ist_pempton, 6 engel ışını boş/eğim). Kareler: sur dibi ile kule/payanda arasında ~2–3 m'lik dar boğaz; yaya yolu kesintili | Ist_kose_kara_suru_* / Ist_kara_suru_*/L0/W* (sehir.gd:_v2_item ile 'kose_' kayıtları, surlar.gd:_run) | Sur dibi savunma yolunu 4–6 m açık bırak; köşe kule çarpışmasını gövde ile sınırla |
| 41 | GÖRSEL | 3 | Rhegion iç, sur dibi | -4855, 179 | e_tak3_-4855_189.jpg | Martı: kaba çokyüzlü beyaz kuş evin sundurmasına girmiş uçuyor (ŞÜPHELİ: sundurma içinde) | hayat_mesh.gd (martı) | Martıyı yuvarlak kesit yap ve sundurma dışında tut |
| 42 | GÖRSEL | 2 | Rhegion kapısı dışı | -4890, 900 | e_kapi_romanos_dis.jpg | Romanos kapısı dışından 90 m'de: karşıda dokusuz koyu zeytin düz duvar, üstünde bej bulutlu 'tavan' (kapak alt yüzü), gökyüzü yok | surlar.gd:_build_moat (ZEMIN.set_) | Bkz. 01 |

## 4) Tür başına sayım

GÖRSEL=23, KUTU=9, MANTIK=1, OYUNCU=1, ZEMİN=8

**KUTU kalan = 9** (yalnız bu bölgenin kendi karelerinde seçilenler; hedef 0). Ek: tüm sur üstü mazgal/küpler (BİLİNİYOR) ve kule "kutu + levha çatı" (BİLİNİYOR) 40+ yerde tekrar ediyor, tek tek sayılmadı.

## 5) En kötü 12 kare

1. `e_dis70_00_-4950_-560.jpg` — dıştan 70 m: gökyüzü yok, bej "tavan", camgöbeği zemin.
2. `a06_-4892_456_dis.jpg` — lacivert boşluk + yüzer zemin şeridi.
3. `h20_07.jpg` — kare tamamen lacivert, yalnız dev bayrak (çizim deliği).
4. `a08_-4861_810_dis.jpg` — lacivert boşluğa karşı eğik bej levha.
5. `h60_07.jpg` — sur dışında çizgili diyagonal yeşil-kahve set (sahibinin "yeşil alan yükseltileri").
6. `k_romanos_0.jpg` — Romanos: kapalı ahşap kanat ve yürüyüşte takılma.
7. `a00_-4950_-560_dis.jpg` — bıçak kenarlı yama + dokusuz açık düz taban.
8. `k_romanos_3.jpg` — iri camgöbeği karo zemin.
9. `a12_-4551_1427_surdibi.jpg` — dokusuz bej sur yüzü.
10. `a10_-4736_1137_surdibi.jpg` — kutu eşek.
11. `h60_06.jpg` — hub: doygun turuncu oyuncak ada.
12. `hx_03.jpg` — sur dışı çizgili arazi şeritleri + koyu dikdörtgen hendek.

## 6) Bölgenin İYİ olan 5 karesi (korunacaklar)

1. `k_rhegion_5.jpg` — Rhegion önü: taş-tuğla şeritli sur, kemerli kapı, mazgal ritmi okunuyor.
2. `a03_-4867_-40_ic.jpg` — iç yandan sur: 5 sıra tuğla / taş şerit oranı ve kule köşesi doğru.
3. `a05_-4861_280_surdibi.jpg` — sur dibi sokağı: toprak yol, ahşap çıkmalı ev, yürüyen kişi.
4. `h60_03.jpg` — 60 m'den şehir: sokak/ada okunuyor, sur üç parçalı, ufukta Marmara.
5. `a09_-4808_981_ic.jpg` — sur dibinde taş döşeme ve sur yüzü.

## 7) Bakamadıklarım / kısmen bakılanlar

- 60 m'lik tam ızgara (1 592 kare) ve 15 m'lik yol kareleri: ZAMAN YETMEDİ; 120 m ızgara + 180 m sur boyu yapıldı.
- Yapıların içine girme: sur kulelerinin içi/merdivenleri (oyuncuyla) BAKILMADI; Romanos kapısı kanadı kapalı olduğundan geçiş denenemedi.
- Gece kareleri (D) ve düşme kareleri (F): çekiliyor, bu ara raporda yok.
- Kök neden ataması (kaynak sütunu): `ŞÜPHELİ` yazanlar kod okumadan çıkarım; dosya:işlev yalnız sezgidir, çalışma zamanı düğüm adı doğrulanmadı (yürüyüş engelleri dışında).
- DÖNEM: bu bölge karelerinde minare/hilal/cam vitrin/modern nesne GÖRÜLMEDİ (sur dibi evleri dönem uygun); sur dışı boşluk için ordugâh bölgesi (başka gezgin).
