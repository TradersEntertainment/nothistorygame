# TUR-9 — Sur kuşağının son görünüş kusurları + Blakherna: rapor

Dal `wip/ist2-tur9`. ÖNCE = `wip/ist2-birlesik` **ee2ee089** (depo dışı kopya, `git archive`; aynı makine, aynı kameralar,
ÖNCE ve SONRA aynı anda koşuldu). Kareler 1280×720 jpg 85, xvfb + Mesa llvmpipe. Klasörler: `once/`, `sonra/`
(A, B, C, D_testisigi, D_bolum20isigi, c20, c21, gece_22o, gece_26, blak, cit), `pafta/` (sol ÖNCE | sağ SONRA),
`deney_ay/` (ay gölgesi deneyi), `kam/` (kamera listeleri), `testler/` (ham çıktılar, süzülmüş).

Kameralar: A `tests/_ist/sur_oyun_demo.tscn` (10 + 2 gece); B `docs/_kanit_ist2_tur7/kameralar_B.txt` (`birlik_kare`,
16/17 kare: son kare `kara_05_yer60` 10 dk sınırında kesildi, ayrıca `testler/k05_yeniden.txt`); C `kam/C.txt` (`tur7_kare`);
D_testisigi `tur7_kesim --gece` (testin kendi ışığı); **D_bolum20isigi** yeni `tests/_ist/tur9_gece.tscn` (aynı D kameraları,
ışık Bölüm 20'nin `Night.environment`'ı + kalite kancası); c20 `--chapter=20 --autotest=kare` (an_01–an_07: ÖNCE koşusu 10 dk
sınırında an_07'de kesildi; SONRA an_11'e kadar); c21 `--chapter=21 --autotest=kare` an_01; çit `kam/cit.txt` ve Blakherna
`kam/blak.txt` yeni `tests/_ist/tur9_kare.tscn` ile (tur7_kare + `--gizle=`, `YER_` zemine oturan kamera, `CIT_` en yakın
çite dik kamera).

## Maddeler

| # | madde | durum | kare (ÖNCE → SONRA) | kök neden → ne yapıldı |
|---|---|---|---|---|
| 1 | Hendek dış kıyısı (c5) | **KISMEN** | `pafta/C.jpg` c4/c5, `once|sonra/C/c5…` | c5 bir **köşe dolgusunda** (`Ist_kdolgu_kara_suru_16`; `--pik` ve `--gizle` ile ayrıştırıldı). **(870,437) havadaki yeşil eğik levha** = `dunya.gd`'nin karşı kıyı çalısı (`Karsi_cali`); kuşak maskesi yalnız dilim boyunca (−3…L+3) kayıtlıydı, köşenin dış kaması maskesizdi → çalı kesilmiş arazinin yüksekliğinde hendeğin üstünde asılıydı. `sur_oturtma.gd`: her köşe aralığına açıortay boyunca kuşak kaydı → **SONRA yok**. **(520–1100, 430–530) beyaz küp taşlar**: aynı maske açığından (karşı kıyı süsü/döküntü) → **SONRA yok** (c4'teki uçan beyaz taşlar ve çubuklar da). **(280–560, 550) üçgen koyu çentik** = arazi kesim bandı (`_bant_kur`) kırıkta dikdörtgen uzatılıyordu, ucu komşu bandın dış kıyısından taşıp araziyi yakanın dışında da kesiyordu (altından hendek tabanı görünüyordu; `--gizle=kdolgu` karesinde kesim çizgisi çentikli). Uzatılan uca kırığın açıortayından **gönye yarım düzlemi** (`kes_ucgen`, `bant_ici`) → **SONRA yok**; ayrıca köşe hendeği alt parçalarına kırık açısından gönye payı (`sehir.gd _kose_hendek`, sabit 0,6 m yerine 0,6 + r·tan(θ/2)). **y≈545 dümdüz kenar**: SONRA'da **duruyor** (aşağıda). Çarpışma: hendek kutuları aynı; arazi kesimi yalnız yakanın DIŞINA taşan kama kadar küçüldü (sözleşme denetimleri aynı). |
| 2 | Gece zemini / ay gölgesi | **TAMAM (ay gölgesi) / KISMEN (an_03 sol orta)** | `pafta/D_bolum20isigi.jpg`, `pafta/c20.jpg` an_01/an_03, `deney_ay/`, `pafta/gece_22o.jpg`, `pafta/gece_26.jpg` | **Kök neden ölçüldü** (`tests/_ist/tur9_gece`, D2 karesi, piksel farkı): `shadow_blur` 1,4 → 3,0 **fark 0** (Compatibility'de blur etkisiz), `directional_shadow_split_1` 0,1 → 0,35 / 0,5 fark ≈ 0 (etkisiz), yalnız **mesafe** texel'i küçültüyor (25 m, 20 m, 15 m denendi: 20 m'de uzak zeminde ani aydınlık bant, 15 m'de sur gölgesi kayboluyor). Basamak = gölge haritası texel'i; ay sur yüzünü sıyırarak geliyor (texel yüzde uzuyor). Bias değil (gölge yüzden kopmuyor), dilim kenarı değil (split etkisiz), **atlas çözünürlüğü / mesafe**. → `night.gd` `Night.environment`: ay gölgesi **35 → 22 m**, `directional_shadow_fade_start` **0,55** (12–22 m'de yumuşak söner). Dilim sayısı (2), atlas (`project.godot`), `look.gd` ve ışık rengi/şiddeti/sis **aynı**. SONRA: D2 sur gölge kenarı ince; D2 sağ alt (780–1280, 480–720) cetvel kenarlı koyu levhalar yumuşak ve soluk; D3 zemindeki sert kenarlı koyu şekil yok; **c20 an_03 kulede x≈620–660 basamaklı gölge kenarı yok** (kule 22 m ötesinde: ayla düz aydınlık). an_03 sol ortadaki (≈240,430) koyu dikdörtgen bir NESNE (gölge değil; SONRA'da yerinde); alttaki açık bej bant hâlâ var (aşağıda). Şehir dışı gece: 22o ve 26 ÖNCE|SONRA karelerinde kişi gölgeleri yerinde, fark yok. |
| 3 | Koyu taş yamaları / tuğla kesimi / ton | **TAMAM (yama, tuğla) / KISMEN (an_03 ton)** | `pafta/C.jpg` c2/c4/c5, `pafta/A.jpg` 03, `pafta/D_*` | `sur_doku.gd`: hendek yüzünde (yerel y < −0,4) "dökülmüş taş oyuğu" blokların **%12'sini** tam koyu, keskin kenarlı boyuyordu → **%5**, ton farkı az (×0,62–0,8, eskisi harcın ×0,42–0,68'i), blok içinde yumuşak kenar (0,02–0,16 m). **c2 tuğla x≈720'de düz turuncu**: tek tek tuğla eşikle (`fw = max(fy, fu)` 0,008–0,017) sönüyordu; eğik bakışta yatay sıkışma `fu`'yu büyütüp hatılı birden düz şeride çeviriyordu → sıra derzi `fy`'de, dikey derz `fu`'da ayrı **kutu süzgeç** (yan bakışta sıra çizgileri kalır; uzakta ortalama = eski uzak ton). SONRA c2: hatıl uzağa doğru kesintisiz. an_03 sağ üst sur açık: ayın baktığı yüz + meşale; sol sur ay gölgesinde (ışık yönü). Ton farkı SONRA'da biraz azaldı (gölge 22 m'de söner) ama bilerek ışığa dokunulmadı. |
| 4 | Sur dibi eteği (Bölüm 21 an_01) | **KISMEN** | `pafta/c21.jpg`, `pafta/D_bolum20isigi.jpg` D4 | `sur_oturtma_ag.gd`: etek gövdesinin köşe alfası **1** (zemin_v2'de "çıplaklık 0" = otlu desen) kalıyordu, çevresindeki zemin çıplak (≤ 0,2) → etek AYRI DESENLİ yama. Kesimde uç rengi sabit toprak rengiydi (zemin levhası `zemin_renk` paletinde). → alfa duvar dibinde çıplak, uca doğru zeminin kendi değerine; kesimde uç rengi `zemin_renk` (dilim kökünün x ötelemesiyle); sahte AO 0,5 → 0,68; kesik aralık (kule, kapı, poterna) kıyısında etek 3 m'de söner, dip bandı 1,8 m'de söner (kesik kıyısında birden biten şekiller). SONRA c21 an_01: Grant'ın arkasındaki etek zeminle aynı desen (kahve yama yok). **Grant'in altındaki gri, düz kenarlı dörtgen DURUYOR**: etek değiştiği hâlde aynı kaldı → kaynağı etek değil; `chapter21.gd`'de `--kim` yok (C'nin dosyası) → istek. |
| 5 | Çit ve palanka yakın kare | **TAMAM** | `pafta/cit.jpg` (`CIT_4_0`, `CIT_3_2`: 3–4 m, hatta dik) | Kazıklar yakından üç yüzlü sivri prizma (kutu değil, tur 8). Ama arkadaki **sedde** yamuk KUTU prizmaydı (düz yüzler, ızgara desen) → `ordugah_yapi2.gd`: yuvarlak omuzlu, tepesi engebeli, eteği gömülü toprak sırt; seddeyle çit arasındaki 3,4 m'lik düz koyu **kutu levha** (eğimde ucu havada) → zemini köşe köşe izleyen, kenarı düzensiz şerit. Çarpışma: aynı yamuk kabuk ve aynı çit kutusu. Sırt şeritle aynı ağda (ek çizim yok). |
| 6 | Blakherna aynı görsel dilde | **KISMEN** | `pafta/blak.jpg` (yerden 4: iç yüz, saray yanı, Haliç ucu, saray yanı gece; havadan 2) | `sehir.gd _blakherna_wall`: kutu gövde + 3 ayrı düz tuğla şerit kutusu + 1,1 m küp dişler + kutu kuleler yerine Mesoteikhion kalemi: gömülü temel + kaide + şevli dış yüz (sur taşı gölgelendiricisi: blok + tuğla hatıl), yürüme yolu korkuluğu + `KULE.disler_ag` dişleri (boy farkı, yer yer eksik), kuleler `KULE.ic_kule` (pahlı plan, şev, silme, yarık, tepe korkuluğu), dipte düşmüş taş. **ÖLÇÜ AYNI**: gövde 12 m, kule 17 m, diş tepesi WALK_Y + 1,1; **çarpışma dökümü ÖNCE = SONRA birebir** (`testler/blak_carpisma_once.txt` / `_sonra.txt`, 5 boyda 17 kutu, `tests/_ist/tur9_blak.gd`). Bulgu: şehirde `blakherna_suru` hattı ile `kara_suru` hattı Tekfur'dan Haliç'e **aynı çizgi** (aynı köşe noktaları); kara surunun iç suru Blakherna dilimiyle aynı yerde, onu büyük ölçüde örtüyor → karelerin çoğunda görünen sur zaten Mesoteikhion dilimi; fark açıkta kalan yerde (b3: ÖNCE düz turuncu şerit kutuları → SONRA hatıl + kaide). `_make_blakherna` sarayı `sehir_eser.gd`'de (dokunulmadı). 43o uçuş kameraları yerine şehir kurucusunda aynı yükseklikte iki hava kamerası (h1, h2) kullanıldı. |

### Madde 1–6'daki koordinatlar SONRA'da tek tek

- c5 (870,437) yeşil eğik levha: **yok**. (520–1100, 430–530) beyaz küp taşlar: **yok**. (280–560, 550) üçgen çentik: **yok**.
  y≈545 cetvel kenar: **var** (köşede kıyı örtüsü denendi: arazi köşede yakadan 0,1–0,5 m alçak, örtü görünmedi; dilim
  örtüsünü bent üstüne uzatmak arazide yeni düz yeşil yama yaptı → ikisi de geri alındı).
- D2 (780–1280, 480–720) koyu levhalar: **soluk, kenarı yumuşak** (gölge); kutu kenarlı zemin basamakları: D4 dip bandı/etek
  kesik kıyısında sönüyor, ama D4 duvar dibindeki koyu paneller **hâlâ seçiliyor** (`--gizle` ile etek, bant, oyun parçaları,
  kesim zemini tek tek gizlendi; panel kalmadı değil → ay gölgesi; SONRA'da daha açık).
- c20 an_03 (≈240,430) koyu dikdörtgen: **var** (nesne); altındaki sert kenarlı bej bant: **var**; x≈620–660 basamaklı ay
  gölgesi: **yok**.
- A03/c5 koyu dikdörtgen yamalar: **seyrek, yumuşak**. c2 x≈720 tuğla kesimi: **yok**. an_03 sağ üst sur tonu: **kısmen** (ışık).
- c21 an_01 etek yaması: **yok**; Grant altındaki gri dörtgen: **var** (etek değil).
- Çit 3–4 m: kazık prizma (kutu yok); sedde kutusu **yok** (toprak sırt).
- Blakherna 6 kare: kutu sayımı aşağıda; havada duran görülmedi (b1–b4, h1–h2 tam boy bakıldı).

## Üç sözleşme denetimi (ÖNCE ee2ee089 → SONRA)

| denetim | ÖNCE (tur 8 / taşıma 2 raporu) | SONRA (her ara kayıtta ve son kodda) |
|---|---|---|
| `tests/_ist/sur_sozlesme.tscn` | `SURSOZLESME PASS kalem=13 kesim=8` | `SURSOZLESME PASS kalem=13 kesim=8` |
| `tests/_ist/sur_oyun_denetim.tscn` | `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` | `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` |
| `tests/_ist/sur_oyun_yuru.tscn` | `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` | `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` |

(`testler/den_*`, `den2_*`, `den3_*`.)

## Testler (son kod, `--max-fps 20`, tam süzgeç)

- `tests/parse_check.tscn` → `PARSECHECK PASS scripts=356`.
- `--chapter=X --autotest`, X = **20, 20o, 21, 26, 43o, 30** (istenen) + Night.environment'ı doğrudan kullananlar **4, 17o,
  31o, 38o, 39o** + kurucularla kullananlardan **34o** (Edirne), **33o** (Boğaz), **35o** (Trakya yolu), **17, 19** (deniz
  surları), **30o** (Blakherna), **22, 25, 28o** (kara surları), **10** (kamp): **21/21 AUTOTEST PASS**, AUTOTEST FAIL 0,
  SCRIPT ERROR 0. Denetim satırı: **20'si 0**; **26'nın ilk koşusunda 1 `WALKTHRU`** (bir kişi `Chapter26>LandWalls`
  gövdesinin içinden, (31,4; 1,0; 5,0)). Aynı test iki kez daha (SONRA) ve ÖNCE kodunda: **0, 0, 0** (`testler/t_26_tekrar.txt`).
  Kararsız NPC yolu; ay gölgesi mesafesi fizik/NPC'ye dokunmaz. Kök nedeni bu turda bulunmadı (dosya `land_walls.gd`/NPC,
  benim değil) → yöneticiye not.
- Tam paket yöneticide.

## Bütçe (ÖNCE ee2ee089 ↔ SONRA, aynı makine, aynı kamera, iki koşu aynı anda; `testler/B_*_rinfo.txt`)

| kare | çizim ÖNCE | çizim SONRA | Δ | ilkel ÖNCE | ilkel SONRA | Δ |
|---|---|---|---|---|---|---|
| sahip_03_sur_disi_30m | 1310 | 1310 | +0.0% | 3222984 | 3226759 | +0.1% |
| sahip_04_sur_disi_70m | 1225 | 1226 | +0.1% | 2918470 | 2847997 | -2.4% |
| s3_hendek | 1549 | 1571 | +1.4% | 5140719 | 5149832 | +0.2% |
| hendek_kenar_05 | 1530 | 1549 | +1.2% | 4766933 | 4774968 | +0.2% |
| k02_ordugah_on_hat_40m | 1396 | 1434 | +2.7% | 4668732 | 4702674 | +0.7% |
| k03_hendek_kenari | 1499 | 1525 | +1.7% | 4456973 | 4460870 | +0.1% |
| k04_sur_ustunden_ordugaha | 1109 | 1129 | +1.8% | 3175442 | 3197582 | +0.7% |
| **k05_ordugahtan_sura_400m** | 1335 | 1335 | **+0.0%** | 5546564 | 5545020 | **-0.0%** |
| k06_sehirden_sura_40m | 1293 | 1330 | +2.9% | 2991354 | 3008818 | +0.6% |
| k08_ordugah_on_hat_40m | 1595 | 1618 | +1.4% | 6852838 | 6841040 | -0.2% |
| k09_hendek_kenari | 1378 | 1392 | +1.0% | 5217295 | 5234320 | +0.3% |
| k10_sur_ustunden_ordugaha | 1547 | 1546 | -0.1% | 5117224 | 5134097 | +0.3% |
| k11_ordugahtan_sura_400m | 1414 | 1435 | +1.5% | 6090994 | 6085698 | -0.1% |
| k12_sehirden_sura_40m | 1693 | 1698 | +0.3% | 5581420 | 5586614 | +0.1% |
| k13_kapi_onu_1 | 1432 | 1433 | +0.1% | 2996135 | 2991745 | -0.1% |
| k14_kapi_onu_2 | 1291 | 1278 | -1.0% | 2652175 | 2661974 | +0.4% |
| kara_05_yer60 | 1274 | 1248 | -2.0% | 2987213 | 2992143 | +0.2% |

Bütün kareler +%5 içinde. **k05**: tam B koşusunda +%21 çıktı; yalnız k05 aynı anda yeniden: önce +%6,4 (1306 → 1390) — kaynak
seddenin ayrı ağı (siper başına +1 çizim). Sırt şeritle aynı ağa alındı → 1335 ↔ 1335 (`testler/k05_yeniden.txt`; tablodaki
k05 ve kara_05 satırları bu son ölçüm). Öbür satırlar sırt ayrı ağdayken ölçüldü (birleştirme yalnız azaltır). D (kesim, test
ışığı): D1 105 / 163574, D2 453 / 355127, D3 246 / 233996, D4 169 / 187746 (tur 8 SONRA ile aynı düzey). Ay gölgesi 35 → 22 m
gölge geçişinde çizilen nesneyi azaltır (ölçülmedi).

## Kutu sayımı

Kesim (pişirme kapalı, `tur7_kesim --kutu_say --pisirme_yok`): görünen BoxMesh ağlı öğe ÖNCE **904** → SONRA **904**, yeşil
kutu **0 → 0** (`testler/kutu_*.txt`). Şehirde: siper başına 1 sedde kutu prizması + 1 düz kutu şerit → **0** (toprak sırt,
zemine yatan şerit). Blakherna dilimi başına: 1 gövde kutusu + 3 tuğla şerit kutusu + ~60 küp diş + 4 kule × (1 kutu + 3
şerit kutusu) → gövde/kule kutusu **0** (profil ağ, `ic_kule`); dişler Mesoteikhion'daki gibi `disler_ag` taş dişleri (kutu
biçimli taş blok: surun kendi dişi, Mesoteikhion ile aynı). Şehrin bütününde otomatik sayım yapılmadı.

## SONRA karelerine tek cümlelik bakış (tam boy bakıldı)

- C c5: sur, hendek yüzü örgülü; havada bir şey yok; yakın yaka dümdüz çizgi — **kısmen**. c4: havadaki taş/çubuk yok — **iyi**. c2: hatıl kesintisiz, zemin çıplak toprak — **iyi**. c1, c3, c6–c8: ÖNCE ile aynı — **değişmedi (iyi)**.
- A 03: hendek yüzündeki koyu dikdörtgen blok yamaları ÖNCE'de çok, SONRA'da neredeyse yok; hatıl uzakta okunuyor — **iyi**. A gece 06 (testin kendi ışığı, Night değil): ÖNCE'deki sol sur üstündeki sert ay gölgesi SONRA'da **görünmüyor** — bu ışığa dokunulmadı, nedeni ayrıştırılmadı (aşağıda).
- D_bolum20isigi D1–D4: sur gölge kenarı ince, zemindeki cetvel kenarlı levhalar soluk; uzak zemin yumuşak açılıyor; D4 duvar dibi koyu paneller seçiliyor — **kısmen iyi**.
- c20 an_01/an_03: kule üstünde basamaklı gölge yok; an_03 sol ortadaki koyu dikdörtgen nesne ve bej bant duruyor — **kısmen**.
- c21 an_01: etek zeminle aynı desen; Grant altındaki gri düz dörtgen duruyor — **kısmen**.
- 22o, 26 gece: ÖNCE ile aynı (kişi gölgeleri var) — **değişmedi**.
- Çit 4 m / 3 m: kazıklar sivri prizma, arkada toprak sırt; kutu yok, havada yok — **iyi**.
- Blakherna b1, b2, b4 gece, h1, h2: görünen sur Mesoteikhion dilimi (aynı ressam), saray `sehir_eser.gd`; kutu kule yok — **değişmedi/iyi**; b3: düz tuğla şerit kutusu yerine hatıl + kaide — **iyi**.
- B 16 kare: ÖNCE ile aynı düzey (k02'de sedde kadrajda değil; çadırlar aynı) — **değişmedi**.

## Hâlâ kötü olanlar (dürüst)

- **c5 yakın yaka cetvel kenar** (y≈545): köşe dolgusunda arazi yakadan alçak, kesim çizgisi düz; iki deneme (köşe kıyı örtüsü,
  dilim örtüsünü uzatma) işe yaramadı / yeni yama yaptı → geri alındı.
- **Bölüm 21 an_01**: Grant altındaki gri düz kenarlı dörtgen (etek değil; kaynak ayrıştırılmadı → C'ye istek).
- **Bölüm 20 an_03**: sol ortadaki koyu dikdörtgen nesne ve sur dibindeki açık bej bant (kaynak ayrıştırılmadı; bölüm `--kim`
  ile sorulmalı).
- **D4 duvar dibi koyu paneller** (gece): ay gölgesi; SONRA daha açık ama seçiliyor.
- **Blakherna**: sur kara surunun iç suruyla üst üste (aynı hat) — Blakherna'nın kendine özgü görünüşü şehirde çoğu yerde
  görünmüyor; düzeltmesi `_hatlar_v2`'de (benim değil). Saray `sehir_eser.gd`'de.
- **Uzakta ay gölgesi yok** (22 m ötesi): bilinçli takas; sert basamak ↔ uzak gölge.
- Bölüm 26 ilk koşuda 1 kararsız WALKTHRU (tekrarlarda 0).
- **A gece_06**: testin kendi ay ışığında sol surun gölgesi SONRA'da yok (ışık ve `look.gd` aynı; nedeni ayrıştırılmadı — gölge güncelleme zamanlaması olabilir, yeniden koşulmadı).
- c20 ÖNCE karelerinin an_08+'ı ve B'nin 17. karesi 10 dk sınırında alınamadı.

## İstekler

- **C (TAŞIMA)**: `chapter21.gd`'ye `--kim=x,y` (chapter20'deki gibi) — an_01 Grant altındaki gri dörtgen; Bölüm 20 an_03
  (≈240,430) koyu dikdörtgen ve sur dibi bej bant kaynağı. Kare: `sonra/c21/an_01_acilis_grant.jpg`, `sonra/c20/an_03_gedige_tasima.jpg`.
- **Yönetici / sehir.gd `_hatlar_v2` sahibi**: `kara_suru` ve `blakherna_suru` Tekfur → Haliç arası aynı köşe noktalarında; iki
  sur üst üste kuruluyor (kare: `sonra/blak/*`).
- **run_tests.sh isteği**: `tests/_ist/tur9_blak.gd` (Blakherna çarpışma dökümü; ÖNCE ile `diff` boş olmalı), `tests/_ist/tur9_gece.tscn` (D kameraları + Bölüm 20 ışığı).
- **NPC / land_walls sahibi**: Bölüm 26'da kararsız `WALKTHRU` (`testler/t_26.txt`).

## Değişen dosyalar (ee2ee089 → son kayıt)

| dosya | ne |
|---|---|
| `scripts/world/ist/sur_doku.gd` | hendek yüzü oyukları seyrek/yumuşak; tuğla hatılı kutu süzgeç (sıra derzi fy, dikey derz fu) |
| `scripts/world/ist/sur_oturtma.gd` | köşe aralıklarına kuşak (maske) kaydı; arazi kesim bandına gönye yarım düzlemi |
| `scripts/world/ist/sur_oturtma_ag.gd` | etek alfası/uç rengi/AO, kesik kıyısında etek ve dip bandı sönmesi |
| `scripts/world/ist/sehir.gd` | YALNIZ `_kose_hendek` (gönye payı) ve `_blakherna_wall` (görünüş; çarpışma aynı) |
| `scripts/world/ist/ordugah_yapi2.gd` | sedde toprak sırt, hendek şeridi zemini izler (çarpışma aynı) |
| `scripts/level/night.gd` | YALNIZ `Night.environment` ay gölgesi mesafesi 22 m, solma 0,55 |
| `tests/_ist/tur9_kare.*`, `tur9_gece.*`, `tur9_blak.gd` (yeni) | tanı/kare/döküm sahneleri |

Dokunulmayanlar: `look.gd` (deney kancası geri alındı), `project.godot`, `game_state.gd`, `sur_oyun*.gd`, `sur_set*.gd`,
`sur_sozlesme*`, `scripts/chapter*.gd`, B'nin dosyaları, `sehir_eser.gd`, `dunya.gd`. Replik/ses/denge/sayaç değişmedi.
