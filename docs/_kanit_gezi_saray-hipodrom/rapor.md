# İstanbul v2 — karış karış gezi denetimi: bölge `saray-hipodrom`

Denetçi: bağımsız gezgin · dal `wip/gezi-saray-hipodrom` · taban `wip/ist2-gezi-taban` · oyun kodu DEĞİŞTİRİLMEDİ (`git status`: yalnız
`tests/_ist/gezi_saray-hipodrom.{gd,tscn}` ve bu klasör). Kareler 1280×720, gl_compatibility, yazılım çizimi (xvfb);
kare aracı `tests/_ist/sur4_kare.tscn --set=liste` (şehir kuyruğu boşalınca), yürüyüş `tests/_ist/gezi_saray-hipodrom.tscn` (gerçek `Player`).

## 1. Bölge sınırı, kare sayıları, yürüyüş

**Bölge** (gerçek doğu, kuzey m; Ayasofya kubbesi = 0,0): dört köşe **GB (−700, −800) · GD (+600, −800) · KD (+600, +900) · KB (−700, +250)**
(Marmara kıyısı güneyde, Haliç kıyısı kuzeyde; Ayasofya çevresi 150 m yarıçap `mese-dogu`ya, Haliç yamacı n > 250 ∧ e < 100 `halic`e bırakıldı).
Yapıların oyundaki gerçek yeri (IstSehir düğümlerinden okundu, `GEZIYER`): Hipodrom (−421, −344) · Büyük Saray (19, −271) · Khalke (78, −167) ·
Nea (138, −298) · Zeuksippos (−104, −241) · Milion (−224, −111) · Küçük Ayasofya/Sergios (−531, −660) · Bukoleon (−439, −706) · Sophia/Bukoleon limanı (−441, −838) ·
Ahırkapı (−17, −480) · Kayıkhane (−749, −681). Haritada kara maskesi: `GEZIMASKE` (60 m adım) ile alındı.

**ÖLÇÜ DÜRÜSTLÜĞÜ (önemli):** Görev "60 m ızgara / 15 m yol adımı / 8 kare çevre" der. Oyun dünyası gerçeğin 0,35'i olduğundan ve bölge 780'den fazla 60 m'lik
düğüm (3 000+ dört yönlü kare) tuttuğundan (yazılım çizimi kare başına ≈ 5–15 sn), kapsam şöyle ARALIKLI yapıldı — "karış karış" TAM değildir:
- **Izgara:** 180 m'lik ana ızgara (34 düğüm × 4 yön = 136 kare) + Hipodrom/Saray çekirdeğinde 180 m'lik ara ızgara (13 düğüm × 4 = 52 kare). Yani 60 m yerine 180 m (üçte bir).
- **Eserler:** 13 eser × 6–8 yönden çevre + 1 yakın kapı karesi = 103 kare (8 kare/eser kuralı: büyüklerde 8, küçüklerde 6).
- **Yollar:** Marmara suru (55 örnek), Haliç suru (23), Mese (21), Hipodrom yan (12) boyunca ~43 gerçek m adımla 111 kare (15 dünya m).
- **Havadan:** tam tepeden 2, 20 m ve 60 m'den 12 noktada 24 (çapraz −30°) = 26 kare.
- **Gece:** 24 sokak karesi + 5 eser karesi = 29 (her üçüncü düğüm, iki yön).
- **Olay kareleri:** yürüyüşteki takılma noktalarına 18 kare.

**KARE SAYILARI: çekilen 482 / bakılan 482** (hepsi 3×3 paftalarda tek tek incelendi; şüpheli ~25'inin tam boyu/kırpması ayrıca açıldı).
Tür dağılımı: eser 103 · hava 26 · ızgara 136 · çekirdek ızgara 52 · yol 111 · gece 29 · olay 18 + 7 = 25.

**Gerçek oyuncu yürüyüşü** (`GEZI_ROTA/GEZI_OLAY`, `yuru1.log`, `yuru2.log`): 12 rota (r1–r6 ilk deneme, r7–r12 yönlendirmeli ikinci deneme).

| rota | amaç | sonuç |
|---|---|---|
| r1 hipodrom_boyu | Hipodrom boyunca | 163 dünya m yürüdü; yoldan sapma yok (ilk deneme: duvara çarpınca vazgeçti) |
| r2 mese_saray | Mese → Saray | 9 m: (-330,-38) mermer sütun/duvara çarptı, vazgeçti |
| r3 marmara_ici | Marmara iç yol | 13 m: (-565,-697) tuğla duvara çarptı |
| r4 sergios_bukoleon | Küçük Ayasofya → Bukoleon | 13 m: (-516,-623) tuğla duvara çarptı |
| r5 nea_saray_cevre | Nea/Saray çevresi | 47 m: (102,-326) tuğla duvar |
| r6 sarayburnu | Sarayburnu yamacı | 72 m: (250,443) yapı duvarı |
| r7 mese_dogu_batiya | Mese → Zeuksippos | 854 m (sapmalı), tüm noktalara ulaştı |
| r8 marmara_ic_sokak | Marmara sur dibi sokağı | 317 m, tüm noktalara ulaştı |
| r9 saray_nea | Saray/Nea | 709 m, tüm noktalara ulaştı |
| r10 sarayburnu_kiyi | Sarayburnu kıyısı | 1 072 m, tüm noktalara ulaştı |
| r11 hipodrom_cevre | Hipodrom çevresi | 1 132 m, tüm noktalara ulaştı (tribün üstüne çıkıldı) |
| r12 mangana | Mangana | YARIM KALDI (test zaman aşımı; yalnız takılma satırları var) |

- Toplam: r1–r6 yaklaşık 317 dünya m, r7–r11 yaklaşık 4 084 dünya m (**≈ 4,4 km dünya metresi; ≈ 12,5 km gerçek-metre eşdeğeri**); bu uzunluk **sapma/dolanma dahil**: ikinci denemede oyuncu duvara çarpınca yönünü 55°/110° kaydırıyor, bu yüzden net rota boyu çok daha kısa.
- **GEZI_OLAY sayıları:** `dusme` = 0, `suya_girme` = 0 (hiçbir rotada boşluğa basma, düşme, suya girme yok). `takilma` = 514 satır (yuru2) + 530 satır toplam (yuru1+yuru2).
- Takılma kümeleri (≈25 m hücre): (-450,-300) ×127 · (225,425) ×96 · (-175,-125) ×55 · (-475,-275) ×48 · (75,-250) ×47 · (75,-275) ×44 · (-450,-275) ×37 · (-275,-25) ×29 · (-300,-25) ×27.
  Hepsine olay karesi çekildi (`olay_*`, `olay2_*`): **çoğu rotanın düz çizgi üzerinde duvara/sütuna çarpması** (tuğla duvar, mermer sütun, tezgâh direği); **gerçek hata değil** sondanın rota hatası. Kare kanıtlı gerçek sorun
  adayları: (-300,-40) kamera iç yüz çizilmemiş lacivert hacim görüyor (ŞÜPHELİ), (-450,-300) Hipodrom tribün tepesi: pistten çıkış/giriş çıkılabilir basamakla var, ama krem levhalar havada (bulgu).
- **Kapalı cep sayısı:** 0 yürüyüşle doğrulanmış; kare kanıtlı ŞÜPHELİ 6 (bkz. tablo: OYNANIŞ/MANTIK satırları "iç yüzü çizilmemiş").
- **Çıkılamayan basamak / görünmez duvar / duvardan geçme:** yürüyüşte tespit edilmedi (WALKTHRU yok); `Player` Hipodrom tribününe çıkabildi.


## 2. GENEL NOT: **4 / 10**

Sahibi bu bölgeyi gezse ilk olarak Hipodrom'un **neon yeşil, dokusuz, kutu hayvanlı** pistine ("öküzleri kare kare mi yapmışsın", "yerler çok kötü") ve Büyük Saray'ın **bembeyaz-krem maket zemininde** parlak yeşil konilerle serpiştirilmiş küp molozlara kızar; ikincisi
Marmara suru ile Haliç suru arasındaki **renk uçurumu** (biri sıcak taş, öbürü çelik-mavi + turuncu bant) ve oyuncak facetli ağaç taçlarıdır. Bölgenin ayakta kalan iyi tarafı Bukoleon cephesi, Chalke/Milion çevresindeki insanlı sıcak döşemeli meydan ve Haliç suru; buna karşılık bölge "harabe" havasından çok "boyalı karton"
izlenimi veriyor ve gece birçok yapı tam siyah.

## 3. BULGU TABLOSU

(doğu, kuzey = karenin kamera konumu, gerçek m; "KUTU kalan" ve kaynak notları aşağıda. Kaynak sütunu kod incelemesinden çıkarımdır; "düğüm adı bilinmiyor" = `--set=kim` ile doğrulanmadı.)

| no | tür | önem | yer adı | doğu, kuzey | kare dosyası | ne görünüyor | kaynak | öneri |
|---|---|---|---|---|---|---|---|---|
| 1 | KUTU | 1 | Hipodrom pisti (otlayan hayvanlar) | -520, -400 | kare/eser_hipodrom_guney_sphendone_0.jpg | Pistte duran inek/at kutu gövde + kutu baş + kare bacaktan: ayaklı sandık (kalite notu 32 ihlali). | scripts/world/ist/hipodrom.gd:_hayvanlar (K.sb/K.vb kutular) | CANLI hattındaki yuvarlak kesitli hayvan modelini kullan; yoksa pisti kaldır |
| 2 | ZEMİN | 1 | Hipodrom pisti | -343, -266 | kare/eser_hipodrom_orta_1.jpg | Pist zemini neon açık yeşil, dokusuz düz renk (parlak çim) ve ince dalgalı moiré deseni; sahibin 'yerler çok kötü' dediği türden. | hipodrom.gd:build_hipodrom (K.sb pist levhası, GRASS_D.lerp(SOIL,0.4)); dunya.gd:411 'hipodrom' zemin rengi | Pist levhasını kaldırıp arazi dokusuna (kuru çim/çiğnenmiş toprak) bırak ya da dokulu malzeme + ışık düzeltmesi |
| 3 | ZEMİN | 2 | Hipodrom pisti | -343, -266 | kare/eser_hipodrom_orta_1.jpg | Pistte cetvelle kesilmiş sivri köşeli pembe/açık dikdörtgen yamalar (keskin kenarlı yama). | hipodrom.gd:build_hipodrom (18 adet K.vb 'gp' yaması); hipodrom.gd:_sphendone_floor (SAND levhaları) | Yamaları kenar yumuşak karışımlı toprak lekesi (vertex renk/doku) yap |
| 4 | KUTU | 2 | Hipodrom pisti (ot ve moloz) | -343, -266 | kare/eser_hipodrom_orta_1.jpg | Ot öbekleri parlak yeşil prizma/koni (oyuncak çalı), moloz taşlar beyaz küp; havada duruyor gibi. | scripts/world/ist/hipodrom_kit.gd:scatter (PrismMesh 'ot', box_mesh 'moloz') | Düzensiz yuvarlak ot kümesi, kırık taş (pahlı, renk çeşitli) MultiMesh |
| 5 | GÖRSEL | 2 | Hipodrom, sphendone ucu | -569, -519 | kare/eser_hipodrom_guney_sphendone_5.jpg | Sphendone zemini aşırı parlak, bembeyaz dokusuz düz yüzey (ışık patlaması); ufuk çizgisi silik. | hipodrom.gd:_sphendone_floor (SAND levhası 10 dilim, 'dişli çokgen') | SAND levhaları daha koyu/dokulu; döşeme kaplaması |
| 6 | GÖRSEL | 2 | Hipodrom, kuzey carceres cephesi | -343, -422 | kare/eser_hipodrom_orta_3.jpg | Tribün/carceres cephesindeki pencere ve kapılar düz siyah dikdörtgen (içi yok, derinliksiz boşluk). | hipodrom.gd:_carceres (K.ground_box koyu kapı kutuları) | Niş/içe çökük kemerli kapı, iç gölgeli geri çekilmiş yüzey |
| 7 | GÖRSEL | 3 | Hipodrom, Kathisma | -343, -266 | kare/eser_hipodrom_orta_1.jpg | Kathisma çatısı 'ufo' gibi: krem düz tabla + pembe disk; çatı levhası gövdeden taşmış, kubbe okunmuyor. | hipodrom.gd:_kathisma | Eğimli kiremit/kurşun çatı + gerçek kubbe |
| 8 | KUTU | 3 | Hipodrom, spina anıtları | -498, -492 | kare/eser_hipodrom_guney_sphendone_yakin.jpg | Spina'daki sarı obelisk beyaz-krem tek kutu kaideye oturmuş; kaide pahsız çıplak küp. | hipodrom.gd:_spina (K.ground_box kaide, satır 287-330) | Kaideye basamaklı profil, pah ve derz |
| 9 | GÖRSEL | 1 | Büyük Saray harabesi | -45, -207 | kare/eser_buyuk_saray_7.jpg | Havada eğik duran büyük krem düz levhalar (yıkık tonoz yerine kağıt gibi tabaka); gölgesi yok, yüzeyi dokusuz. | scripts/world/ist/hipodrom_saray.gd:_hall / build_buyuk_saray (tonoz-çatı levhaları) | Levhaları kırık tonoz parçası (kalın, dokulu, yere oturmuş) yap |
| 10 | GÖRSEL | 2 | Büyük Saray harabesi | 41, -293 | kare/eser_buyuk_saray_yakin.jpg | Kemer boşlukları düz mor-gri dolgu (niş içi dokusuz disk), pembe çerçeveli: harabe değil karton kesik. | hipodrom_saray.gd:_wall_with_door / build_buyuk_saray (kemer dolgusu) | Kemer içini gerçekten boş bırak ya da dokulu taş dolgu |
| 11 | GÖRSEL | 2 | Büyük Saray harabesi | 41, -293 | kare/eser_buyuk_saray_yakin.jpg | Duvara yapıştırılmış dikdörtgen düz yeşil levha (sarmaşık olmalı); kenarları cetvelle kesik. | hipodrom_saray.gd:build_buyuk_saray (yeşil levha) | Sarmaşığı yaprak kümesi/alpha kartı yap |
| 12 | ZEMİN | 2 | Khalke / Saray avlusu | 78, -112 | kare/eser_khalke_0.jpg | İki farklı döşeme yan yana: gri-nane (gölgede camgöbeği) ve turuncu balık sırtı; sınır cetvelle düz (kalite notu 28). | hipodrom_saray.gd:build_khalke + hipodrom_kit.gd zemin/döşeme (ZEMİN) | Tek sıcak gri-krem döşeme, düzensiz geçiş ve kırık derz |
| 13 | GÖRSEL | 2 | Khalke | 100, -189 | kare/eser_khalke_yakin.jpg | Cephede dört düz siyah dikdörtgen pencere + beyaz çubuk şeritler; cephe tuğla ama pencere derinlik yok. | hipodrom_saray.gd:build_khalke | Pencerelere kemer ve geri çekme |
| 14 | GÖRSEL | 2 | Nea Ekklesia | 160, -320 | kare/eser_nea_yakin.jpg | İç zemin nane-beyaz alaca mermer deseni, çok açık ve düz; duvarlar V biçimli çıplak tuğla, tavan düz koyu kırmızı levha. | hipodrom_saray.gd:build_nea | Zemin kireçtaşı/prokonnesos tonu, tavan tonoz |
| 15 | GÖRSEL | 2 | Zeuksippos hamamı | -152, -268 | kare/eser_zeuksippos_4.jpg | Somon-pembe düz boyalı kaba tambur gövde, dokusuz, siyah dikdörtgen deliklerle; yanında açık mavi dikdörtgen levha (havuz) yerden fırlamış. | hipodrom_saray.gd:build_zeuksippos | Tambur tuğla/sıva dokulu; havuz suyu çukur içinde |
| 16 | GÖRSEL | 3 | Zeuksippos hamamı | -104, -186 | kare/eser_zeuksippos_0.jpg | Gri-mor düz dolgulu kemer + parlak yeşil levha + somon duvar yan yana: üç düz renk karton. | hipodrom_saray.gd:build_zeuksippos | Dokulu taş/sıva, sarmaşık kartı |
| 17 | GÖRSEL | 2 | Küçük Ayasofya (Sergios-Bakkhos) | -483, -632 | kare/eser_sergios_kucuk_aya_1.jpg | Çıplak tuğla kutu gövde, iki beyaz çıta bandı, siyah dikdörtgen pencere; üstünde düz somon tambur ve gümüş-mavi kubbe: 'kutu + kubbe'. | scripts/world/ist/hipodrom_aug.gd:build_sergios | Sekizgen gövde, kemerli pencereler, tuğla-taş şerit, kurşun gri kubbe |
| 18 | GÖRSEL | 3 | Küçük Ayasofya iç | -509, -682 | kare/eser_sergios_kucuk_aya_yakin.jpg | İçeriden kubbe düz gri kapak; iç duvar çıplak tuğla, ışık/süsleme yok. | hipodrom_aug.gd:build_sergios | İç duvara sıva/mozaik tonu, kubbe pencereleri |
| 19 | GÖRSEL | 3 | Küçük Ayasofya yakını | -579, -632 | kare/eser_sergios_kucuk_aya_5.jpg | Zemin nane-beyaz alaca mermer, açık ve düz (kalite notu 28). | hipodrom_aug.gd:build_sergios + zemin döşemesi | Sıcak gri-krem döşeme |
| 20 | KUTU | 2 | Bukoleon yakını (ağaçlar) | -359, -706 | kare/eser_bukoleon_2.jpg | Mor ve açık yeşil faceted küre taçlı 'oyuncak' ağaçlar; taç doygun mor. | scripts/world/ist/bitki.gd:tree_mesh/_agac (erguvan, badem… taç ağı) | Düzensiz yaprak kütlesi, soluk doğal tonlar |
| 21 | GÖRSEL | 1 | Bukoleon limanı (Sophia) | -371, -838 | kare/eser_sophia_liman_2.jpg | Su üstünde parlak camgöbeği düz dikdörtgen yamalar, açık yeşil küçük küpler ve ince yeşil çubuklar süzülüyor. | scripts/world/ist/marmara_liman.gd:build_sophia + marmara_kit.gd:WATER_PLANE/TUFTS | Su altı yamalarını kaldır; iskele kazığı ahşap dokulu |
| 22 | KUTU | 2 | Bukoleon limanı kayaları | -392, -887 | kare/eser_sophia_liman_3.jpg | Taşlar 'tespih' gibi birbirine eklenmiş facetli yastıklar (kozalak/tırtıl); kaya değil oyuncak. | marmara_kit.gd:ROCKB (kaya blob) – marmara_liman.gd:build_sophia | Düzensiz kaya parçası ağı, pahlı blok |
| 23 | GÖRSEL | 2 | Bukoleon limanı suru | -392, -887 | kare/eser_sophia_liman_3.jpg | Sur şeritleri parlak turuncu (doygun oyuncak), taş sırası renk çeşidi az; kule tepelerinde beyaz küp mazgal. | scripts/world/ist/marmara_sur.gd:_tower/_details (şerit rengi), _parapets (mazgal) | Tuğla bandı soluk kiremit; mazgal taş rengi |
| 24 | MANTIK | 3 | Ahırkapı | -17, -535 | kare/eser_ahirkapi_3.jpg | Kapı önünde somon-pembe düz levha basamak (kutu); duvarla zemin arasında aralık. | scripts/world/ist/marmara_sur.gd:_gate / rampa (Ahırkapı) | Taş basamak kademeli, pahlı |
| 25 | GÖRSEL | 3 | Kayıkhane | -749, -631 | kare/eser_kayikhane_0.jpg | Taş duvarlı kutu + düz kırmızı levha çatı; ince siyah yarık pencereler. | marmara.gd:build_kayikhane (KIY) | Kiremitli/eğimli çatı, kemerli kapı |
| 26 | GÖRSEL | 1 | Hipodrom (tam tepe) | -250, -350 | kare/hava_tam_tepe_cekirdek.jpg | Tam tepeden Hipodrom pisti dokusuz bembeyaz uzun dikdörtgen (neon-krem), çevresindeki şehirden kopuk; yeşil alanla keskin kenarlı. | hipodrom.gd:build_hipodrom (pist), hipodrom_kit.gd | Pist zeminini arazi dokusuyla uyumlu toprak/çim yap |
| 27 | KUTU | 2 | Büyük Saray harabeleri (bitki) | -300, -600 | kare/hava_60_01.jpg | Beyaz ve mor facetli 'bulut' ağaçlar harabe alanına serpiştirilmiş; toy gibi, taç düz renk. | bitki.gd:tree_mesh/_agac (taç ağı) | Daha az doygun, doku/gürültü eklenmiş taç; tür çeşidi |
| 28 | GÖRSEL | 2 | Marmara deniz suru (Saray önü) | -60, -500 | kare/hava_60_02.jpg | Sur dilimleri komşu renkte değil: kahverengi ahşap kaplama gibi ve koyu lacivert-gri yan yana (kalite notu 27 devam). | marmara_sur.gd | Bütün Marmara suruna tek malzeme ve renk |
| 29 | GÖRSEL | 2 | Marmara suru kule üstleri | -560, -700 | kare/hava_20_00.jpg | Sur kulelerinin yanında ve üstünde beyaz küp blok yığınları (mazgal/küp). | marmara_sur.gd:_parapets (BİLİNİYOR) | Mazgal taş dokulu, kule renginde |
| 30 | GÖRSEL | 2 | Haliç suru kule tablası | -300, 780 | kare/hava_20_09.jpg | Kule üstü geniş gri-yeşil dama döşeme düz, siyah kazan tek parça; kenarlar cetvelle. | scripts/world/ist/halic_sur.gd:_tower (kule tablası) | Taş döşeme düzensiz, mazgal ve basamak |
| 31 | MANTIK | 3 | Haliç suru kulesi | -300, 780 | kare/hava_20_09.jpg | Bayrak kuleye göre dev ölçekte (kırmızı-sarı levha, kuleden büyük görünüyor); rüzgârsız dümdüz. | halic_sur.gd:_banner | Bayrak boyu ≤ 2 m, dalgalanma |
| 32 | PERF | 2 | Bölge geneli (yer) | 41, -293 | kare/eser_buyuk_saray_yakin.jpg | RINFO (rinfo.txt): 402 yer karesinin 106'sı üçgen > 2,5 M (en kötü 3,31 M), 3'ü çizim > 1 200 (en kötü 1 266) bütçesini aştı; uçuş karelerinde bütçe tutuyor. Yazılım çizimiyle ölçüldü. | IstSehir/IstDunya (hipodrom + saray + mahalle MultiMesh) | LOD1 eşiği saray/hipodrom için yakınlaştır |
| 33 | KUTU | 1 | Sokak (Marmara yakası mahallesi) – yüklü eşek | -520, 120 | kare/izg_-520_120_G.jpg | Yüklü eşek gri kutu gövde + kutu baş + boru bacaklı (sandık eşek); yanındaki sarı sepet/torba da çıplak şekil. | scripts/world/ist/hayat_veri.gd:hayvan ('yuklu' katmanı) + hayat_mesh.gd hayvan ağı | Yuvarlak kesitli hayvan ağı (CANLI hattı) |
| 34 | KUTU | 2 | Sokak (ev önü) | -520, 120 | kare/izg_-520_120_G.jpg | Yerde dokusuz açık yeşil ve bej küp/levha yığınları (balya/ot?) – kenarları keskin, gölgesiz-düz renk. | scripts/world/ist/ayrinti_*.gd (ayrıntı seti: saman/ot kutuları) – düğüm adı bulunamadı | Dokulu, yuvarlak hatlı balya/torba; renk soluk |
| 35 | KUTU | 2 | Büyük Saray güneyi, ev bahçeleri | -520, -240 | kare/izg_-520_-240_K.jpg | Beyaz/krem faceted ikosahedron 'bulut' ağaç tacı ince gövde üstünde; oyuncak ağaç (kalite notu 32). | scripts/world/ist/bitki.gd:tree_mesh/_agac | Taç düzensiz yaprak kütlesi, doku, soluk doğal ton |
| 36 | KUTU | 2 | Hipodrom batı yanı | -520, -240 | kare/izg_-520_-240_G.jpg | Dev yeşil facetli küre taç, direk gövde; gövde/taç oranı oyuncak; gölge keskin çokgen. | bitki.gd:tree_mesh/_agac | Aynı |
| 37 | ZEMİN | 2 | Hipodrom–Küçük Ayasofya arası arazi | -520, -60 | kare/izg_-520_-60_K.jpg | Zemin düz sarı-yeşil, aynı koyu 'damga' çizgileri tekrarlanıyor; orta uzaklıkta çıplak düz renk, doku yok. | scripts/world/ist/dunya.gd (arazi gölgelendirici/vertex rengi; 'saray/harabe' tür rengi satır ~409) | Arazi dokusu çeşitlendir, damga tekrarını kır |
| 38 | ZEMİN | 2 | Hipodrom–Saray arası yol yaması | -520, -60 | kare/izg_-520_-60_D.jpg | Ocher yol/ocak yaması cetvelle kesilmiş çokgen kenarlı; çimle arada bıçak çizgisi. | dunya.gd (yol maskesi) | Yol kenarını gürültüyle yumuşat, taş kenar şeridi |
| 39 | GÖRSEL | 2 | Marmara yakası tuğla yapı | -520, -600 | kare/izg_-520_-600_K.jpg | Tuğla kutu cephe: pencere yerine pahsız düz koyu mor dikdörtgen levhalar; köşede alt-üst iki beyaz şerit; zemine oturmuyor (bıçak çizgisi). | scripts/world/ist/hipodrom_aug.gd/marmara_*.gd (düğüm adı bilinmiyor: tuğla 'hamam/ambar' kutusu) | Kemerli pencere, iç gölge, temel taşı |
| 40 | GÖRSEL | 3 | Ev sokağı (batı) | -700, -420 | kare/izg_-700_-420_K.jpg | Ev = kutu gövde + düz kahverengi saçaklı levha çatı + tek baca: tekdüze 'kutu + levha' (BİLİNİYOR gibi ama şehir evlerinde). | scripts/world/ist/evler.gd | Çatı eğim/kiremit, saçak profili, farklı çatı çeşitleri |
| 41 | OYNANIŞ | 2 | Yapı içleri (ev/ambar) | -700, -240 | kare/izg_-700_-240_D.jpg | Göz hizası kamera yapının içine düştüğünde iç duvarlar çizilmiyor: lacivert boşluk, yalnız zemin ve tavan var; kapılı ev içi 'karton kutu'. Oyuncu girebilirse görünmez duvar/boşluk (ŞÜPHELİ: girilebilirlik sınanmadı). | IstSehir ev kabuğu (tek yüzlü çokgen) – evler.gd | Kapısız kapalı gövde yap ya da iç yüz çiz |
| 42 | KUTU | 2 | Hipodrom–Zeuksippos arası boş arazi (kaya) | -340, 120 | kare/izg_-340_120_G.jpg | 1 m önde dev gri facetli çokgen kaya: oyuncak kaya, düz gri ton, tek renk, doku yok. | düğüm adı bilinmiyor (kaya/ayrıntı katmanı: ayrinti_*.gd / marmara_kit.gd:ROCKB benzeri) | Düzensiz pahlı kaya ağı + lekeli doku |
| 43 | GÖRSEL | 2 | Hipodrom batısı taş yapılar | -340, 120 | kare/izg_-340_120_B.jpg | Taş yapıların çatı/üst yüzeyi yarı saydam camgöbeği levha gibi (cam vitrin/su görünümü); duvarın üst kenarında ışıltı. Dönem dışı cam izlenimi. | evler.gd / IstSehir çatı örtüsü (düğüm adı bilinmiyor) | Çatıya kiremit/kurşun dokusu, saydamlık yok |
| 44 | GÖRSEL | 1 | Büyük Saray temel izleri | -160, -420 | kare/izg_-160_-420_D.jpg | Harabe duvar/temel izleri kalınlıksız ince bej levha şeritler (kâğıt duvar), köşeleri dikey çıta gibi; yere gömülü değil, yan yatık duruyor. | scripts/world/ist/hipodrom_saray.gd:build_buyuk_saray (temel şeritleri) – düğüm adı bilinmiyor | Temelleri taş sıra kalınlığında, dokulu, kırık uçlu yap |
| 45 | GÖRSEL | 2 | Büyük Saray güney yamacı | -160, -420 | kare/izg_-160_-420_B.jpg | Ekranın %40'ını kaplayan dev koyu yeşil düz dikdörtgen levha (tabela/sarmaşık perdesi?), kenarları cetvelle kesik, dokusuz. ŞÜPHELİ: ne olduğu düğümle doğrulanmadı. | hipodrom_saray.gd:build_buyuk_saray (yeşil levha) | Yaprak dokulu alpha kart |
| 46 | GÖRSEL | 1 | Büyük Saray iç zemini | 20, -240 | kare/izg_20_-240_G.jpg | Harabenin iç zemini bembeyaz-krem alaca düz yüzey; üstünde parlak yeşil koni çim ve beyaz küp moloz; gri kemer dolguları: 'harabe' değil sahne maketi. | hipodrom_saray.gd:build_buyuk_saray (zemin levhası), hipodrom_kit.gd:scatter | Zemin toprak/taş kırığı dokusu, molozu pahlı, ot kümesi yuvarlak |
| 47 | ZEMİN | 2 | Büyük Saray iç zemini | 20, -240 | kare/izg_20_-240_B.jpg | Zeminde pastel mavi/mor/yeşil düz kare levhalar rastgele serilmiş (mozaik yerine kâğıt kareler), kenarlar keskin, birbirinin üstüne biniyor (z-çatışması izi). | hipodrom_saray.gd:build_buyuk_saray (zemin karoları) | Mozaik parçalarını derz ve aşınmayla tek doku yap |
| 48 | GÖRSEL | 2 | Marmara sur dibi (Büyük Saray güneyi) | 20, -600 | kare/izg_20_-600_D.jpg | Sur şeritleri parlak turuncu (oyuncak doygunluk), sur koyu lacivert-gri; zemin koyu camgöbeği-yeşil düz renk (gölge camgöbeği, kalite notu 28). | scripts/world/ist/marmara_sur.gd:_tower/_details; dunya.gd arazi rengi | Tuğla bandı soluk kiremit, zemin toprak tonu |
| 49 | ZEMİN | 3 | Marmara sur dibi | 20, -600 | kare/izg_20_-600_G.jpg | Yerde parlak yeşil ince zigzag şeritler (çit/ot sırası?) koyu zeminin üstünde yüzüyor; ŞÜPHELİ ne olduğu: bıçak çizgisi. | düğüm adı bilinmiyor (marmara_kit.gd:TUFTS olabilir) | Çizgiyi kaldır ya da çit ağacı yap |
| 50 | GÖRSEL | 3 | Harabe kemer | 20, -420 | kare/izg_20_-420_K.jpg | Kemer üstündeki lento düz somon levha, tuğla payeler çıplak; harabe değil temiz kapı maketi. | hipodrom_saray.gd / kemer_harabe.gd | Kırık lento, sarmaşık, taş dökülmesi |
| 51 | KUTU | 2 | Nea Ekklesia | 200, -240 | kare/izg_200_-240_G.jpg | Pembe düz silindir tambur + gri-mavi düz kubbe kapak + çıplak tuğla kutu gövde (bkz. Zeuksippos aynı tür). | hipodrom_saray.gd:build_nea | Tambura pencere sırası, kurşun kubbe, tuğla-taş şerit |
| 52 | ZEMİN | 2 | Augustaion batısı (komşu sınırı) | -160, 120 | kare/izg_-160_120_D.jpg | İki döşeme yan yana: gri-nane dev karo ve turuncu balık sırtı; sınırda cetvelle düz kenar, taş bordür yok. | scripts/world/ist/forumlar*.gd / hipodrom_aug.gd (döşeme) | Tek sıcak gri-krem döşeme, kenarda taş bordür |
| 53 | GÖRSEL | 3 | Hipodrom çevresi bitkisi (ŞÜPHELİ) | 20, -600 | kare/izg_20_-600_B.jpg | Uzun beyaz sivri koni/prizma ('kalem') ağaç mı kule mi belirsiz; yanında dev gri facetli taç. | bitki.gd:build_servi olabilir (ŞÜPHELİ) | Servi koyu yeşil, doku |
| 54 | ZEMİN | 1 | Sarayburnu yamacı | 380, 300 | kare/izg_380_300_B.jpg | Yamaç çimi parlak doygun yeşil (neon), düz renk + damga; kıyıdaki koyu sur ile kontrast kopuk. Sahibin 'yerler çok kötü' / parlak çim dediği türden. | scripts/world/ist/dunya.gd (arazi rengi: 'seyrek/kir' türleri), geo.gd MAH_OZEL 'Mangana / Akropolis bahçeleri' | Çim tonu soluk-kuru, doku ve toprak lekeleri, yol kenarı yumuşak |
| 55 | KUTU | 2 | Sarayburnu yamacı (çalılar?) | 380, 300 | kare/izg_380_300_B.jpg | Yerde açık yeşil ve bej, ortadan katlanmış dörtgen levha çiftleri (çalı/ot mu kaya mı belli değil) – kutu/levha, gölgesiz düz renk. Birçok karede tekrarlanıyor (izg_380_300_G, izg_200_120_G). | bitki_yama.gd / bitki.gd (yama kartları) – düğüm adı bilinmiyor | Yuvarlak yaprak kümesi / dokulu kartlar |
| 56 | GÖRSEL | 2 | Sarayburnu, Mangana yakını | 380, 480 | kare/izg_380_480_G.jpg | Taş yapının çatısı yarı saydam camgöbeği levha (cam gibi, içinden duvar görünüyor), saçak çıkıntısında kahverengi kâğıt levha; dönem dışı cam görünümü. | evler.gd / IstSehir çatı örtüsü (düğüm adı bilinmiyor) | Opak kiremit/kurşun çatı |
| 57 | ZEMİN | 2 | Sarayburnu yürüyüş yolu | 380, 480 | kare/izg_380_480_D.jpg | Yol taşları üçgen ve eğik gri levha parçaları olarak yola saçılmış (dişli, sıra bozuk), ocher yamayla bıçak çizgisi; hiçbir yere gitmeyen taş basamak. | scripts/world/ist/ayrinti_sokak.gd (yol taşları) – düğüm adı bilinmiyor | Hizalı kaldırım taşı, yolu düz kenarlı değil yumuşak geçişli yap |
| 58 | ZEMİN | 2 | Kıyı mahallesi sokağı | 200, 660 | kare/izg_200_660_B.jpg | Yola serilmiş gri-krem kalın levha şeritler yerden fırlamış gibi, kenarları havada; ocher yol zemini düz renk. | ayrinti_sokak.gd (kaldırım şeritleri) | Taşları yola göm, kenar derzi |
| 59 | GÖRSEL | 3 | Kıyı mahallesi evleri | 200, 480 | kare/izg_200_480_G.jpg | Kapı/pencere açıklıkları düz siyah dikdörtgen, üstünde düz turuncu levha (tabela gibi, yazısız); içeri derinlik yok. | scripts/world/ist/evler.gd (kapı/pencere kutuları) | Kapı iç gölgeli geri çekilmiş, tabelasız |
| 60 | GÖRSEL | 3 | Kıyı mahallesi kapısı | 380, -60 | kare/izg_380_-60_D.jpg | Kapı yanlıklarında parlak beyaz krom/cam gibi silindirler (metal/cam okunuyor), kapı içi düz siyah tek renk. | evler.gd (kapı yanlığı silindirleri) | Taş/ahşap söve, mat doku |
| 61 | DÖNEM | 3 | Chalke önü meydan (ŞÜPHELİ) | 200, 120 | kare/izg_200_120_G.jpg | Çeşme/duvar kiosku: gri panel + kare 'ekran' + musluk; iki kişi önünde duruyor – modern otomat/ATM gibi okunuyor. ŞÜPHELİ: kaynak düğüm doğrulanmadı. | scripts/world/ist/ayrinti_*.gd (çeşme/şadırvan) – düğüm adı bilinmiyor | Çeşmeye taş lüle/yalak, kare panel kaldır |
| 62 | DÖNEM | 3 | Kıyı mahallesi tezgâhları (ŞÜPHELİ) | 200, 300 | kare/izg_200_300_D.jpg | Tezgâhta düz kırmızı-sarı sekizgen tabaklar; kırmızı yuvarlak 'domates' okunabilir (domates 1453'te yok). ŞÜPHELİ: ürünün adı kodda doğrulanmadı. | ayrinti_*.gd (tezgâh ürünleri) | Ürünleri elma/nar/ekmek gibi dönem ürünleri yap, doku ver |
| 63 | OYNANIŞ | 2 | Marmara sur dibi (Bukoleon doğusu, sur içi oda) | -280, -720 | kare/izc_-280_-720_K.jpg | Kapalı cep: yapının/surun içinde göz hizası kamerada kahverengi zemin, gri-tuğla duvar ve 'tavan' olarak arazinin benekli altyüzü; üç yan lacivert (iç yüzü çizilmeyen duvar). Oyuncu bu odaya girebiliyorsa kapalı cep/görünmez duvar (ŞÜPHELİ: girilebilirlik yürüyüşle sınanmadı). | marmara_sur.gd:_tower / marmara_bukoleon.gd (sur içi hacim) – düğüm adı bilinmiyor | İçi boş sur hacmini dolgu yap ya da kapıyı oyuncuya kapat |
| 64 | GÖRSEL | 3 | Hipodrom kuzeyi, hamam/ambar yanı | 80, -540 | kare/izc_80_-540_G.jpg | Ekranın %40'ını kaplayan koyu yeşil, neredeyse siyah düz prizma (muhtemelen çok yakın servi koni); doku/yaprak yok. ŞÜPHELİ. | bitki.gd:build_servi | Servi kütlesine dokulu yaprak, koni yerine düzensiz silüet |
| 65 | GÖRSEL | 2 | Marmara sur dibi (Ahırkapı doğusu) | 80, -540 | kare/izc_80_-540_D.jpg | Sur kuleleri koyu lacivert-gri ve turuncu bantlı; yer koyu camgöbeği-yeşil çim, sur dibinde yol/çıkıntı yok; sur 'karanlık' okunuyor (ışık yetmiyor). | marmara_sur.gd | Tuğla bandı soluk, taş sıcak gri, sur dibine çakıl yolu |
| 66 | ZEMİN | 3 | Ahırkapı–Hipodrom arası | -100, -540 | kare/izc_-100_-540_B.jpg | Yer yer yeşil dikdörtgen levha (ot kartı) parlak açık yeşil, kenarları keskin, yerden fırlamış; yanında dev pembe (magenta) faceted ağaç. | bitki_yama.gd / bitki.gd:_agac (erguvan) | Ot kartlarını yuvarlak, ağaç tacını soluk pembe-kahve |
| 67 | GÖRSEL | 1 | Marmara deniz suru, tüm iç yüz (Ahırkapı–Kontoskalion arası) | -396, -749 | kare/yol_sur_marmara_05.jpg | Sur iç yüzü koyu çelik-mavi/lacivert düz renkli taş + düz koyu bordo tuğla şerit; sıcak gri-krem Theodosius dili yok, kuru çizgi derz. Üstte parlak turuncu düz levha bant (kule 'kuşağı'). 54 yol karesinin çoğunda aynı: hat baştan sona soğuk ve karanlık. | scripts/world/ist/marmara_sur.gd:_details/_tower (renk sabitleri) | Taş sıcak gri-krem, tuğla soluk kiremit, turuncu bant kaldırılsın |
| 68 | KUTU | 2 | Marmara suru kulesi / çıkıntı levhası | -199, -717 | kare/yol_sur_marmara_12.jpg | Kule köşesinde dev düz turuncu üçgen/levha (çatı mı, kuşak mı belirsiz) surdan dışarı taşmış, kenarları cetvel keskin; sağ üstte havada duruyor. | marmara_sur.gd:_tower (çatı/kuşak levhası) | Kule üstüne taş mazgal + kiremit çatı, levha kaldır |
| 69 | GÖRSEL | 2 | Marmara suru, sur yürüyüş merdiveni | -515, -760 | kare/yol_sur_marmara_02.jpg | Sur iç yüzündeki merdiven ince camgöbeği-gri yarı saydam levha gibi (korkuluksuz, basamak üstü yüzüyor); üstünde diyagonal beyaz çizgi (z-çatışması izi). | marmara_sur.gd:_stair / rampa (satır 277, 378) | Basamakları kalın taş, korkuluklu, sur gövdesine gömülü yap |
| 70 | GÖRSEL | 2 | Marmara suru gövdesi | -252, -747 | kare/yol_sur_marmara_09.jpg | Sur yüzünde diyagonal şeffaf üçgen 'yama' ve bitişik katman çifte yüzey: iki farklı taş deseni üst üste (çifte nesne / z-fighting). | marmara_sur.gd (çifte yüzey: _plinth + gövde) / yamaçta basamak kademesi | Yamaç kademesini tek gövdeye çevir |
| 71 | GÖRSEL | 3 | Marmara sur dibi | 49, -605 | kare/yol_sur_marmara_20.jpg | Surun önünde bahçe duvarı yerine dokusuz düz gri-mavi levha blok (tek renk, çizgisiz); çimen üstünde havada kenarlı kutu. | scripts/world/ist/marmara_sur.gd:_plinth / ayrinti_sokak.gd (düğüm adı bilinmiyor) | Duvara taş dokusu, pah ve derz |
| 72 | MANTIK | 2 | Marmara sur dibi (Mangana/Ahırkapı) | -42, -654 | kare/yol_sur_marmara_16.jpg | Sur dibinde açık havada ahşap rıhtım/iskele (kuru çimen üstünde, suya 100 m uzak): karada duran iskele, 'karada tekne' benzeri. | scripts/world/ist/marmara_bukoleon.gd:_jetty (satır 242) / marmara_liman.gd | İskeleyi kıyıya (suya) bitişik koy ya da kaldır |
| 73 | MANTIK | 3 | Marmara sur dibi, balıkçı sahnesi | -217, -744 | kare/yol_sur_marmara_11.jpg | Karada, suya uzak yerde kayık gövdesi (bükülmüş kahverengi levha) çimenin üstünde; yanında kişi. | marmara.gd:build_kayikhane / ayrinti_*.gd (kayık) | Kayığı kıyıya çek |
| 74 | KUTU | 2 | Marmara sur dibi sokağı (kaya) | 276, -346 | kare/yol_sur_marmara_29.jpg | Sokak ortasında dev gri facetli çokgen kaya (oyuncak), yanında saksı; yolu kısmen kapatıyor. | ayrinti_*.gd (taş yığını: build_tas_yigini, ayrinti_a.gd:339) | Küçük taş yığını, doğal biçim |
| 75 | ZEMİN | 2 | Marmara sur dibi | 412, -221 | kare/yol_sur_marmara_34.jpg | Sur dibindeki çim koyu camgöbeği-yeşil (gölgede gri-mavi), ortada kahverengi çamur yolu ve düz yeşil şerit; yol-çim sınırı keskin cetvel. | dunya.gd (arazi tür rengi 'sur_dibi')  | Gölge tonunu ısıt, yolu yumuşak geçişle çakıl yap |
| 76 | MANTIK | 3 | Marmara sur dibi pazar yeri | 309, -319 | kare/yol_sur_marmara_30.jpg | Sur dibinde ahşap bank/kalas havada, yarım yamuk, ucu sur gövdesine giriyor (gövdeden çıkan kalas); yer zemini ile bank arasında boşluk. | ayrinti_sokak.gd (bank/kalas) – düğüm adı bilinmiyor | Banka ayak, yere otur |
| 77 | MANTIK | 2 | Haliç suru, kule içi (Eugenios–Ceneviz arası) | -123, 750 | kare/yol_sur_halic_15.jpg | Kamera surun içinde: yalnız zemin ve lacivert (iç yüzü çizilmeyen) yüzler; ardışık 15/16 karelerde aynı. Kule/gövde içi boş kapalı cep ya da duvardan geçme. ŞÜPHELİ: oyuncunun bu noktaya girebildiği yürüyüşle sınanmadı. | scripts/world/ist/halic_sur.gd:_tower / _wall_piece (tek yüzlü gövde) | Kule içini kapat (iç yüz çiz) ya da kapıyı oyuncuya kapalı yap |
| 78 | GÖRSEL | 2 | Haliç suru, kule üstü | 75, 751 | kare/yol_sur_halic_10.jpg | Surun üstünde dev düz siyah-yeşil yatay levha (havada, kenarları keskin; çatı/tabla alt yüzü?) ekranın üst yarısını kaplıyor. | halic_sur.gd:_parapets / _tower (üst levha) – düğüm adı bilinmiyor | Alt yüzü taş/ahşap dokulu; levhayı kule gövdesine otur |
| 79 | KUTU | 2 | Haliç suru yanı, ağaçlar | 32, 750 | kare/yol_sur_halic_11.jpg | Surun dibinde bembeyaz faceted taç + düz beyaz prizma gövdeli 'oyuncak' ağaçlar; taç doku yok. | bitki.gd:tree_mesh/_agac (beyaz 'badem'/'kiraz') | Taç pembe-beyaz çiçek dokulu, gövde kahverengi |
| 80 | ZEMİN | 3 | Haliç suru dibi | -11, 748 | kare/yol_sur_halic_12.jpg | Sur dibinde neon parlak yeşil şerit (çim kenarı), bıçak gibi düz çizgi; yamaç çimi pembeye çalıyor. | dunya.gd (sur_dibi tür rengi) | Şerit ince toprak/ot, kenar yumuşak |
| 81 | GÖRSEL | 1 | Marmara suru ile Haliç suru renk uyumsuzluğu | -38, 747 | kare/yol_sur_halic_13.jpg | Haliç suru sıcak gri-krem taş + kırmızı tuğla şerit (iyi); Marmara suru ise koyu çelik-mavi taş + bordo tuğla + turuncu levha: aynı yarımadanın iki suru farklı malzeme (kalite notu 27/30). | marmara_sur.gd vs halic_sur.gd (renk sabitleri) | Marmara suruna Haliç'in taş/tuğla paletini uygula |
| 82 | GÖRSEL | 2 | Mese batı (Konstantin yönü), sütunlu cadde | -454, -22 | kare/yol_mese_07.jpg | Zeminin alt yarısı bembeyaz düz levha (ışık patlaması, dokusuz); sütun sırası ve çatı güzel ama yer bembeyaz kesik. Bıçak çizgisi gibi alt kenar. | scripts/world/ist/forumlar*.gd / mese (döşeme levhası) – düğüm adı bilinmiyor | Levha kaldırıp döşemeyi sürdür |
| 83 | KUTU | 2 | Mese sütunlu cadde, mermer sunak/tezgâh | -411, -23 | kare/yol_mese_08.jpg | Yolun ortasında dev mermer küp/dikdörtgen 'sunak' çıplak, pahsız, üstüne düz bej kapak levha; kenarları keskin, desen tekrarı. | forumlar*.gd (mermer kaide/sunak) – düğüm adı bilinmiyor | Kaideye profil, pah, kırık köşe |
| 84 | GÖRSEL | 2 | Mese sütunlu cadde, dükkân içleri | -355, -25 | kare/yol_mese_10.jpg | Duvar arkasında beyaz-pembe düz küpler (mermer parçaları?) havada/yarı gömülü; sağ altta büyük beyaz levha kamerayı kapatıyor. | forumlar*.gd | Dükkân içi eşya, mermer parçaları dokulu |
| 85 | MANTIK | 2 | Mese batı kolu sonu (Ayasofya iç sınırı) – bölge dışı ek | -47, -48 | kare/yol_mese_19.jpg | Kamera kilisenin içinde: yerde dış çim (yeşil çayır), duvar pencereleri düz beyaz dikdörtgen; kubbe nervürleri havada, bağlı değil, yarım. Bölge sınırı dışında (mese-dogu) ama gezide karşılaşıldı. | scripts/world/ist/sehir.gd 'ayasofya' / kemer_kilise.gd (iç hacim) | İç zemini mermer döşe, kubbe nervürlerini gövdeye bağla |
| 86 | GÖRSEL | 2 | Mese sonu, bitişik kapalı yapı | -143, -134 | kare/yol_mese_16.jpg | İç mekân: beyaz düz mermer zemin, üç yanı lacivert iç yüz çizilmemiş duvar, tavan krem düz levha; dışarıdan girilen kapalı cep. | kemer_kilise.gd / forumlar*.gd (iç hacim) | İçeri duvar ve tavan çiz |
| 87 | KUTU | 1 | Hipodrom (kuzeydoğu uzun kenarı), hayvanlar | -528, -441 | kare/yol_hipodrom_yan_01.jpg | Pistteki hayvanlar çıplak kahverengi kutu (at/öküz) ve beyaz kutu (koyun) – bacaksız sandık, baş yok; neon yeşil pist üstünde duruyor. | hipodrom.gd:_hayvanlar (K.sb kutular) | Yuvarlak kesitli canlı modelleri kullan |
| 88 | ZEMİN | 2 | Hipodrom pisti, şeffaf yamalar | -496, -413 | kare/yol_hipodrom_yan_02.jpg | Pistte üst üste binen yarı saydam yeşil ve krem çokgen yamalar (pembe-krem dikdörtgen + ikinci yeşil alan): z-çatışması/çifte yüzey; kenarlar cetvelle. | hipodrom.gd:build_hipodrom (K.vb yamalar + pist levhası) ve _sphendone_floor | Yamaları pist dokusuna bake et, çifte levha kaldır |
| 89 | KUTU | 2 | Hipodrom spina'sı (sütunlar) | -470, -390 | kare/yol_hipodrom_yan_03.jpg | Spina üstündeki beyaz T-profil dev sütun, çıplak pahsız kare kaide ve geniş kare başlık, mermer dokusu yok; gövde düz beyaz. | hipodrom.gd:_spina (satır 280-350, K.ground_box) | Sütun gövdesi yivli silindir, başlık profilli |
| 90 | GÖRSEL | 2 | Hipodrom spina'sı, kaide | -380, -300 | kare/yol_hipodrom_yan_06.jpg | Ayasofya yönünde kaide devasa bembeyaz düz levha (obelisk kaidesi); yanında pembe düz levha yama pistte: boyalı karton duvar. | hipodrom.gd:_spina | Kaideye mermer dokusu, profil |
| 91 | GÖRSEL | 3 | Hipodrom kuzey carceres ucu | -560, -470 | kare/yol_hipodrom_yan_00.jpg | Beyaz-krem kenar şeridi zeminde tek parça düz beyaz çubuk olarak pist boyunca uzanıyor (spina korkuluğu mu euripos mu); mat kâğıt gibi, gölgesiz. | hipodrom.gd (spina duvarı) | Taş korkuluk, kırık parçalar |
| 92 | MANTIK | 2 | Hipodrom kuzey kapısı / carceres yanı | -227, -156 | kare/yol_hipodrom_yan_11.jpg | Carceres yanında dar geçit iki yanı kapalı: soldan lacivert iç yüz (duvarın arkası), sağdan tuğla duvar; yol bitiyor: kapalı cep. | hipodrom.gd:_carceres | Carceres arkası duvar çiz, geçidi kapat |
| 93 | GÖRSEL | 3 | Haliç suru, Eugenios yamacı | 181, 776 | kare/yol_sur_halic_07.jpg | Kamera önünde ekranı dolduran dokusuz düz gri-yeşil yüzey (iki ton şerit): taş/tuğla dokusu yok, sur gövdesinin boş bir parçası/kapağı. | scripts/world/ist/halic_sur.gd:_wall_piece | Parçaya sur dokusu ver |
| 94 | GÖRSEL | 3 | Haliç suru gövdesi | 389, 858 | kare/yol_sur_halic_01.jpg | Sur yüzünde diyagonal yarı saydam gölge-benzeri üçgen yama (Marmara'daki ile aynı tür çifte yüzey). | halic_sur.gd (yamaç kademesi/yüzey çifti) | Yüzey çiftini tek gövdede birleştir |
| 95 | MANTIK | 3 | Kayıkhane önü (ŞÜPHELİ) | -749, -731 | kare/eser_kayikhane_3.jpg | Yetişkin ve çocuk figürü birbirinin içine geçmiş duruyor (gövdeler üst üste); iki kişi tek nokta gibi. | scripts/world/ist/hayat_yakin*.gd (kişi yerleşimi) | İki kişi arasına ≥ 0,5 m ver |
| 96 | ZEMİN | 2 | Hipodrom pisti (gece) | -520, -420 | kare/gece_-520_-420_KD.jpg | Gece pist hâlâ düzgün koyu yeşil, gündüzdeki yamalarla aynı; yeşil koni ot ve beyaz küp moloz geceyi yiyor (ışık alıyor gibi parlak); pist uzun düz şerit. | hipodrom.gd:build_hipodrom (pist levhası, ot 'scatter') | Gece pist dokusu koyu toprak; koni otları yuvarlak |
| 97 | GÖRSEL | 2 | Büyük Saray iç (gece) | 59, -311 | kare/gece_eser_buyuk_saray.jpg | Gecenin ortasında bembeyaz/açık mavi levha parçaları ve pastel karo kareler parlıyor (ışıyan yanlış yüzey); çevre simsiyah. | hipodrom_saray.gd:build_buyuk_saray (zemin karoları, saray levhaları) | Malzeme karanlıkta albedoyu düşür, doku ver |
| 98 | GÖRSEL | 2 | Marmara kıyı mahallesi (gece) | -700, -600 | kare/gece_-700_-600_GB.jpg | Büyük yapı tamamen simsiyah, ayrıntısız siluet (karanlıkta kayboluyor); yanında tek tük pastel ağaç aydınlık: ışık dengesi bozuk. | evler.gd / IstSehir yapı malzemesi (gece ışık) | Yapılara gece zemin ışığı/ortam rengi |
| 99 | GÖRSEL | 3 | Kıyı mahallesi evleri (gece) | 200, 480 | kare/gece_200_480_KD.jpg | Pencere ışıkları çatıda/duvar kenarında yüzen düz sarı dikdörtgen levha (pencere yeri duvarda değil, çatı hizasında); yalnız bunlar aydınlık, evler siyah. | scripts/world/ist/evler.gd (pencere ışığı levhası) | Pencereyi duvar içine otur, sıcak ışık hâlesi |
| 100 | GÖRSEL | 3 | Hipodrom çevresi (gece) | 20, -420 | kare/gece_20_-420_KD.jpg | Kare tamamen siyah: iç yüzü çizilmeyen/ışıksız hacim kamerayı dolduruyor; gökyüzü bile görünmüyor (karanlıkta kaybolan yer). | IstSehir yapı iç yüzü (tek yüzlü gövde) | İç yüz çiz, gece ortam ışığı |
| 101 | OYNANIŞ | 3 | Mese–Hipodrom arası (ŞÜPHELİ) | -300, -40 | kare/olay_takilma_-300_-40.jpg | Oyuncu bu noktada 1 sn'den uzun ilerleyemedi (GEZI_OLAY takilma ×26 -300,-40 çevresinde); kare: kamera mermer sütun yanında lacivert (çizilmeyen iç yüz) gördü: kapalı cep/iç yüzü olmayan hacim. Rota düz çizgi olduğundan çoğu 'takılma' duvara çarpma (aşağıya bak); bu nokta ŞÜPHELİ çünkü iç yüz görünüyor. | IstSehir mese/forum yapı gövdesi (tek yüzlü) – düğüm adı bilinmiyor | İç yüz çiz, geçit aç ya da duvar yap |
| 102 | GÖRSEL | 2 | Büyük Saray çatısı (Khalke yanı) | 80, -270 | kare/olay_takilma_80_-270.jpg | Saray duvarı üstünde camgöbeği-yeşil yarı saydam piramit 'cam çatı' pencereleri ve sol kenarda beyaz küp parça; dönem (cam) ve malzeme hatası; çatı mazgal çizgisi taşıyor. | hipodrom_saray.gd:build_khalke / _hall (çatı penceresi) | Piramit pencere kaldır; opak kiremit/kurşun çatı |
| 103 | GÖRSEL | 2 | Hipodrom batı tribünü (dış duvar üstü) | -450, -300 | kare/olay2_hipodrom_-450_-300_d.jpg | Tribün duvarına yapıştırılmış/duvar önünde havada duran büyük krem-beyaz düz levhalar (dikdörtgen, gölgesiz); yanında pist neon yeşil; oyuncu bu duvar tepesine çıkabiliyor (yürüyüş r11). | hipodrom.gd:_back_wall / _kathisma / _outer_stairs (krem levhalar) – düğüm adı bilinmiyor | Levhaları duvar üstü taş parapete çevir |
| 104 | KUTU | 3 | Mangana mahallesi tezgâhı | 225, 425 | kare/olay2_takilma_225_425_a.jpg | Yerde dokusuz parlak sarı küp (peynir/saman balyası?) çıplak kutu; turuncu doygun tezgâh çatısı ve tente 'oyuncak'. | scripts/world/ist/ayrinti_*.gd (saman/peynir kutuları, tezgâh çatısı) | Yuvarlak balya/peynir teker, soluk tente rengi |


## 4. Tür başına sayım

| tür | adet |
|---|---|
| GÖRSEL | 53 |
| KUTU | 20 |
| ZEMİN | 16 |
| MANTIK | 9 |
| OYNANIŞ | 3 |
| DÖNEM | 2 |
| PERF | 1 |
| **toplam** | **104** |

Önem: 1 (kritik) = 12 · 2 (belirgin) = 62 · 3 (küçük) = 30.

**KUTU kalan = 20** (KUTU türü satırlar) + 5 kutu+levha çatı/kubbe biçimli yapı satırı (GÖRSEL altında: Küçük Ayasofya, Zeuksippos, Nea, Khalke, Hipodrom kathisma/spina) = toplam kutu gibi duran şeyler.
Canlılar: **3 satır** (Hipodrom pistindeki at/öküz/koyun ve yüklü eşek; no 1, 33, 87): hepsi kutu gövde. 5 m ve 60 m zorunlu yakın/uzak kareleri YAPILMADI (bkz. 7).
Bu bölgede "biliniyor/düzeltiliyor" kapsamındakiler: Marmara suru kule çatı levhası/turuncu bant, mazgal küpleri, hayvanlar (CANLI). Asıl yeni bulgular: Hipodrom zemini, Büyük Saray iç zemini, ağaç taçları, kutu kubbeli kiliseler, cam çatılar, gece ışığı.

## 5. En kötü 12 kare (`kare/` altında)

1. `eser_hipodrom_orta_1` — neon yeşil, dokusuz, ince moiré'li pist; kutu hayvanlar; keskin pembe yama; ışıyan beyaz moloz küpleri.
2. `eser_hipodrom_guney_sphendone_0` — pistte kutu "inek": kutu gövde, kutu baş, kutu bacak (sahibin "öküzleri kare kare mi yapmışsın" sözünün birebir karşılığı).
3. `izg_20_-240_G` — Büyük Saray'ın içi bembeyaz alaca zemin, parlak yeşil koniler, beyaz küp moloz: harabe değil sahne maketi.
4. `hava_tam_tepe_cekirdek` — tam tepeden Hipodrom beyazımsı-neon dikdörtgen, çevre şehirden kopuk, kenarlar cetvelle.
5. `yol_sur_marmara_05` — Marmara suru iç yüzü koyu çelik-mavi, bordo tuğla; Haliç suru sıcak gri-krem (`yol_sur_halic_13`) ile uyumsuz.
6. `izg_-520_120_G` — yüklü eşek: kutu gövde, boru bacak; önde bej-yeşil katlanmış levha ("balya/çalı") kutuları.
7. `izg_-160_-420_D` — Büyük Saray temel izleri "kâğıt" şeritler; oyuncak facetli ağaçlar.
8. `izg_380_300_B` — Sarayburnu yamacı neon çim + kıvrık yeşil/bej levhalar.
9. `yol_hipodrom_yan_02` — pistte üst üste binmiş yarı saydam yeşil/krem yamalar (z-çatışması).
10. `eser_sergios_kucuk_aya_1` — Küçük Ayasofya: çıplak tuğla kutu + somon tambur + mavi kubbe.
11. `eser_sophia_liman_2` — Bukoleon limanında suda yüzen camgöbeği düz yamalar ve küp parçalar.
12. `yol_mese_19` — Ayasofya iç mekânında zemin açık çayır, nervürler havada (bölge sınırında).

## 6. Bölgenin İYİ olan 5 karesi (korunacaklar)

1. `eser_bukoleon_5` — Bukoleon cephesi: tuğla-taş şeritli, beyaz mermer kemerli balkon, iç mekân okunuyor; bölgenin en iyi yapısı.
2. `izg_-160_120_K` — Chalke önü meydan: sıcak taş döşeme, tezgâhlar, testiler, insanlar; yaşam dolu.
3. `eser_milion_0` — Milion önü: gri döşeme, sancaklar, kişi, taş-tuğla bina; iyi.
4. `yol_sur_halic_13` — Haliç suru: sıcak gri-krem taş, kırmızı tuğla hatıl; Marmara suru bu paleti almalı.
5. `eser_sophia_liman_5` — Sophia limanı: sur + kapı + gemiler + su; Marmara tarafının en dolu karesi. (+ `izg_-520_-60_G` taş-tuğla şeritli sokak evi.)

## 7. Bakamadıklarım / yapamadıklarım (dürüstçe)
- 60 m ızgara ve 15 m yol adımı YAPILMADI (aralıklı: 180 m / ~43 gerçek m); Hipodrom güney yarısı ve Sarayburnu'nun doğu ucu (e > 450) seyrek örneklendi; Mangana'nın kuzeyi (n > 700) yalnız birkaç kare.
- Canlılar için 5 m / 60 m çifti çekilmedi (yalnız göz hizası yakınları).
- Binaların içine girme (gerçek girilebilirlik) yürüyüşle sınanmadı; "kapalı cep/iç yüz çizilmemiş" satırları kareden: ŞÜPHELİ olarak işaretli.
- Düğüm adı/kaynak çoğu satırda "düğüm adı bilinmiyor" (kare başına `--set=kim` çalıştırılmadı); kaynak sütunu kod incelemesinden çıkarım.
- ÖNCE'de var mıydı: taban dışında ek karşılaştırma yapılmadı.
- Gece karelerinde havadan tur yok; ordugâh bu bölgede değil.
- Yazılım çizimi RINFO'su gerçek GPU'dan farklı olabilir.

## Teslim durumu
Bu klasör: `kare/` (bulgu kareleri, tam boy JPEG ≤ 250 KB), `pafta_bulgu_*.jpg` (bulgu kareleri 3×3), `pafta_hava_*`, `pafta_gece_*`, `pafta_olay_*`,
`liste_*.txt` (kamera listeleri), `rinfo.txt` (475 kare RINFO), `yuru1_ham.txt` / `yuru2_ham.txt` (ham GEZI_ROTA/GEZI_OLAY satırları, süzülmüş).
