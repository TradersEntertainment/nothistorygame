# İstanbul, Nisan 1453: parça listesi

Her oturum BİR parçayı kurar. Önce `docs/_ajan/gorev/_istanbul_ortak.md` dosyasını oku (arayüz dondurulmuş, zorunlu).
Dal: `wip/ist-<ad>`. Dosyalar: `scripts/world/ist/<ad>*.gd`, `tests/_ist/<ad>_onizleme.*`, `docs/_kanit_ist_<ad>/`.
Aşağıdaki öğeler asgaridir; araştırmanda aynı bölgede 1453'te var olan başka belirgin şey bulursan ekle.

## surlar — Theodosius kara surları ve kapıları
Tam hat (Marmara'dan Haliç'e ~5,7 km × k): parametreli sur dilimi (iç sur ~12 m, 96 kule ~18–20 m; dış sur ~8,5 m ve
kuleleri; peribolos; parateikhion; hendek ~18 m en, bölmeli; şeritli taş-tuğla örgü), `build_run(host, uzunluk, k,
lod, tohum)` ile istenen uzunlukta üretilebilsin. Kapılar ayrı ayrı: Altın Kapı (mermer üçlü kemer, iki pilon),
Ksylokerkos (Belgrad), Pege (Silivri), Rhegion (Mevlevihane), Aziz Romanos (Topkapı), Pempton (Sulukule), Kharisios
(Edirnekapı), Kaligaria (Eğrikapı); Mesoteikhion (Lykos vadisi, alçalan kesim), Kerkoporta. Nisan 1453 izleri: top
hasarı, kazık-fıçı-toprak onarım tahkimatı (stauroma), iskeleler, sur üstü nöbetçi barınakları, mancınıklar, taş
gülle yığınları. Sur üstüne çıkış: kule içi merdiven/rampa (oynanır). Üslup: `scripts/level/land_walls.gd` ile uyumlu
(renk, mazgal ölçüsü, desen); onu DEĞİŞTİRME, oku.

## marmara — Marmara deniz surları, limanlar, Bukoleon
Marmara sur hattı (tek sur, ~12–15 m, kuleler, kapılar: parametreli `build_run`), Bukoleon Sarayı deniz cephesi
(balkonlar, mermer çerçeveler, aslan heykelleri, saray iskelesi), Kontoskalion limanı (kapalı havuz, mendirek,
kadırga tezgâhları), dolmuş Eleutherios limanı = Langa bostanları (sebze tarhları, kuyular, dolaplar), Sophia limanı
kalıntısı, Mermer Kule (surların denizle birleştiği köşe), Ahırkapı çevresi, balıkçı barınakları, kayıkhaneler, ağ
kurutma sehpaları, kıyı kayaları.

## halic — Haliç güney kıyısı: yabancı tüccar mahalleleri ve iskeleler
Haliç deniz suru (alçak tek sur, çok kapılı) parametreli; Eugenios Kulesi ve ZİNCİR (kütükler üstünde yüzen demir
zincir, Galata'ya), Neorion ve Prosphorion limanları, iskeleler (skala) sırası; Venedik mahallesi (bailo evi, San
Marco kilisesi, loca, ambarlar), Ceneviz'in eski yeri, Pisa ve Amalfi mahalleleri, Yahudi iskelesi; taş ambarlar,
ahşap rıhtım, vinçler (ahşap, insan gücüyle), fıçı/balya yığınları, demirli tüccar gemileri için bağlama babaları,
balık pazarı, Petrion ve Fener (Phanarion) kapıları. Not: `scripts/level/sea_walls.gd`, `petrion.gd` var; oku, uyumlu ol.

## galata — Galata (Pera), Ceneviz kolonisi
Sur çevresi (beş bölmeli, hendekli), Christea Turris (Galata Kulesi; 1453'te konik külahlı, ~67 m), San Domenico
(çan kuleli gotik kilise), San Francesco, San Michele, San Benedetto, Palazzo del Comune (podestà sarayı), loca,
dik yokuşlu sokaklar ve basamaklar, taş-ahşap Ceneviz evleri, rıhtım ve iskeleler, ambarlar, tersane, bağlar ve
mezarlık (sur dışı yamaç). Not: `scripts/level/galata.gd`, `galata_view.gd` var; oku, uyumlu ol.

## hipodrom — Hipodrom, Büyük Saray harabeleri, Augustaion
Hipodrom (harap: oturma sıraları sökülmüş, sphendone'nin kemerli altyapısı ayakta, spina üstünde Mısır dikilitaşı
kaideli, Örme Dikilitaş, Yılanlı Sütun (üç başlı hâliyle), birkaç sütun; kathisma kalıntısı; içinde otlayan hayvan,
cirit oynayanlar), Büyük Saray harabeleri (yıkık salonlar, tonozlar, mozaik döşeme parçaları, bostanlaşmış avlular),
Khalke kalıntısı, Augustaion meydanı ve Iustinianus Sütunu (tuğla gövde, bronz kaplama izleri, tepede atlı heykel;
küre 1317'de düşmüş), Milion kalıntısı, Zeuksippos hamamı harabesi, Aya İrini, Aya Sergios-Bakhos (Küçük Ayasofya),
Nea Ekklesia kalıntısı. Ayasofya'nın kendisini YAPMA (var: `ByzCity.aya_exterior`).

## forumlar — Mese, forumlar ve sütunlar
Mese caddesi (revaklı dilim: parametreli `build_mese(host, uzunluk, k, lod)`; 1453'te revaklar yer yer yıkık, dükkân
olmuş), Konstantin Forumu (oval meydan kalıntısı, porfir sütun: demir çemberli, tepesinde haç; iki kemerli kapı
kalıntısı), Theodosius (Tauri) Forumu (zafer takı kalıntısı: "gözyaşı" desenli sütunlar, sütun kaidesi), Amastrianon,
Forum Bovis, Arkadius Sütunu (spiral kabartmalı, Xerolophos tepesinde, ~50 m), Markianos Sütunu, Myrelaion (Bodrum)
kilisesi ve rotundası, Philadelphion, Kapitolion kalıntısı, Anemodoulion. Her biri bir bakışta tanınmalı.

## kemer — Bozdoğan Kemeri, Havariyun, Pantokrator ve orta tepeler
Valens (Bozdoğan) su kemeri (iki katlı kemerler, ~970 m × k, en yüksek ~29 m; parametreli, altından geçilir, üstünde
yürünür), Havariyun kilisesi (harap, haç planlı, beş kubbe, imparator mezar yapıları), Pantokrator manastırı (üç
bitişik kilise, kubbeler, avlu, hastane kalıntısı), Lips manastırı, Kyriotissa (Kalenderhane), Vefa kilisesi (Aziz
Theodoros), Pantepoptes, Gül (Aya Theodosia), açık Aspar sarnıcı (içi bostan/köy), Polyeuktos harabesi.

## kuzeybati — Khora, Pammakaristos, Tekfur, Blakhernai çevresi
Khora manastırı (kilise + parekklesion, kubbeler, payandalar), Pammakaristos (parekklesion, çok kubbeli), Tekfur
Sarayı (üç katlı, renkli taş-tuğla geometrik cephe, sur üstünde), Anemas zindanları ve kuleleri, Blakhernai kilisesi
harabesi (1434'te yanmış) ve ayazması, Aetios açık sarnıcı (bostan), Kynegion, Petra manastırı, Kaligaria semti
(ayakkabıcı atölyeleri), Ayvansaray iskelesi. Blakhernai Sarayı'nın kendisini YAPMA (var: `Blachernae.shell_parts`).

## guneybati — Studios, Peribleptos, Psamathia ve güneybatı köyleri
Studios manastırı (bazilika: narteks, atrium, sütunlu nef, ahşap çatı; manastır hücreleri, sarnıç), Peribleptos
manastırı, Aziz Andreas (Krisei), Mokios açık sarnıcı (dev bostan çukuru: tabanda tarhlar, rampayla inilir), Psamathia
köyü, Altın Kapı içindeki kale (Yedikule'nin öncülü, 1391'de yıkılmış kalıntı), Aziz Diomedes, Aya Ioannes (İmrahor),
bağlar, değirmenler, yel değirmeni YOK (belirsizse yapma), Lykos deresi ve köprüleri.

## kiliseler — genel kilise/manastır tipleri ve küçük anıtlar
Parametreli tipler (tohumla çeşitlenen): kapalı Yunan haçı küçük kilise (tek kubbe), dört sütunlu orta kilise
(narteks, üç apsis), bazilika, şapel, manastır külliyesi (çevre duvarı, kapı kulesi, hücre sıraları, yemekhane,
katholikon, kuyu/phiale), ayazma, münzevi kulesi, yol kenarı ikona nişi (proskynetarion), mezarlık ve lahitler,
çeşme/nymphaion kalıntısı, harabe tipleri (yıkık tonoz, tek ayakta kalmış kemer, sütun sırası, mozaik döşeme
parçası, sarmaşıklı duvar). Çan kulesi yalnız Latin etkili yerlerde; Bizans'ta semantron (tahta tokmak) asılı olur.

## ayrinti — sokak hayatı ayrıntı kitaplığı (en az 150 öğe)
Her biri `build_<id>(host, k, lod)` (insan ölçüsünde; k yalnız yerleşim aralığını etkiler) + hazır "köşe" grupları
(`build_set_<ad>`: pazar köşesi, fırın önü, balıkçı iskelesi, bostan köşesi, sur onarım şantiyesi, manastır avlusu,
meyhane önü, demirci, dokumacı/boyacı, mülteci çadırları, ayin alayı hazırlığı). Öğeler: tezgâh, tente, amfora,
pithos, fıçı, sepet, çuval, terazi, balık ağı, ağ sehpası, kayık (çekilmiş), kürek, çapa, çamaşır ipi, kümes,
güvercinlik, arı kovanı, yalak, kuyu ve çıkrık, su dolabı, el arabası, kağnı, eşek semeri yükü, odun yığını, taş
yığını, kireç ocağı, iskele, merdiven, sandık yığını (tırmanma basamağı olarak standart yükseklikte), fırın, tandır,
değirmen taşı, zeytin presi, şarap fıçısı ve üzüm teknesi, tezgâh kepengi, tabela (Yunanca harfli tahta), ikona
nişi, kandil, mum sehpası, haçlı taş, lahit, sütun başlığı (devrilmiş), mermer parçaları, çitler, bahçe kapısı,
asma çardağı, saksılar, çiçekli pencere, kedi-köpek-tavuk-keçi-eşek (durağan düşük poligon), çöp/moloz, su birikintisi,
mancınık, taş gülle yığını, ok sandığı, kalkan askısı, mızraklık, nöbetçi kulübesi, barikat, fıçı-toprak tahkimat…
MultiMesh dostu olsun (aynı ağ, çok örnek); her öğe ≤ 400 üçgen (hayvanlar ≤ 600).

## bitki — Nisan bitki örtüsü ve arazi dokusu
Parametreli/serpme kit: erguvan (Nisan'da pembe-mor çiçekte; İstanbul'un simgesi), badem/erik/kiraz çiçekte, çınar,
servi, incir, defne, nar, zeytin, dut, asma (yeni yaprak), meyve bahçesi, bağ (teraslı), bostan tarhları (bakla,
soğan, marul; domates/mısır/biber YOK), buğday tarlası (yeşil, Nisan), çayır ve kır çiçekleri (gelincik, papatya),
harabe üstü sarmaşık ve ot, kuru taş bahçe duvarı, çit, patika, toprak yol, taş döşeme yol, dere (Lykos) ve küçük
köprü, kaynak/pınar, sazlık, kıyı kumu ve çakıl, kaya, mezarlık servileri. `build_patch_<tur>(host, alan: Vector2, k,
lod, tohum)` ile alan doldurur; MultiMesh; uzakta tek renk yama değil, dokulu. Var olan `scripts/level/nature.gd`
üslubunu oku, uyumlu ol (değiştirme).
