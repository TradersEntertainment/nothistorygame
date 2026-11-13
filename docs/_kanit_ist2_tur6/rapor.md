# TUR-6 — İstanbul v2 karesi BÜTÜN olarak: rapor

Dal `wip/ist2-tur6` (taban `wip/ist2-birlik`). Birleştirilen: `wip/ist2-oturtma` (çakışma: birlik dalı oturtmanın ARA
kaydını taşıyordu; beş dosyada oturtmanın son hâli alındı — iki tarafın niyeti de duruyor: `gorsel_dil.gd` kancası
`dunya.gd`'de, oturtmanın arazi/hendek işi son hâliyle), `wip/ist2-ordugah5` (`ordugah_kisi.gd`: HEAD'in `fig_tur`
duruş türlü kişi karoları korundu; ordugah5'in karo düzeni zaten içindeydi), `canli`, `zemin`, `bitki`, `durus`
(birleşmeden sonra yeni kayıt getirmediler). ÖNCE kareleri birleştirme kaydının (`175ef140`) koduyla alındı (dışa
aktarılmış kopya, depo dışında), SONRA son kodla. Godot 4.4.1, xvfb, `--rendering-driver opengl3`, 1280×720, jpg 85,
gerçek kurucu (`IstDunya.build` → `IstSehir.attach_v2` → görsel birlik), sonda `tests/_ist/birlik_kare.tscn`
(`--set=liste`, mutlak kamera listesi `kameralar.txt`, gece `kameralar_gece.txt`).

## Ölçütler

| # | konu | durum | kare |
|---|---|---|---|
| A | Hendek "bıçakla açılmış yarık" | **KISMEN** | `s3_hendek`, `hk_04_boyunca`, `hendek_kenar_05/08`, `k03/k09_hendek_kenari`, `hava_05` |
| B | Sur dibi teması | **KISMEN (az)** | `sahip_03/04`, `k13/k14_kapi_onu`, `dip_*` |
| C | Zemin "yeşil halı" | **KISMEN** | `sahip_03`, `k08`, `k05`, `hava_*` |
| D | Ordugâhın uzak katmanı | **KISMEN** | `k08`, `k02`, `k05`, `k11` |
| E | Gece gerilemesi | **TAMAM (ölçüye göre)** | `k02/k10_*_GECE` |
| F | Şehir yanı (havada pencere, küp, pastel küme) | **KISMEN** | `dip_03_*`, `hava_05` |
| G | Sur dokusu (uzakta hatıl) | **KISMEN** | `k05`, `k11`, `sahip_04`, `hava_*` |
| H | Deniz surları ve Galata | **YAPILMADI** | — |
| I | Bütçe | bkz. §Bütçe | — |

### A. Hendek
Yapılan:
- **Harpuşta kesme taş** (`sur_zemin.gd harpusta_kur`): 0,45 m'lik düz yatay şerit (sur gölgelendiricisinin 0,9 m'lik
  döşeme ızgarasıyla "tahta kalas") yerine iki yakada tek tek bloklar: 0,6–1,1 m boy, 0,5 m en, 3–6 cm derz, üst
  kenarı pahlı (aşınmış), blok blok ton; %10 eksik, %12 kaymış (hendeğe 5–25 cm, 3–12° yatık), karşı yakanın toprak
  kayması kesimlerinde yok (dibe düşmüş). Kaplamayla aynı ağda ve aynı sur taşı malzemesinde (ek çizim yok). Üst yüz
  arazinin ~0,10 m üstünde (OTURTMA `yarik` ölçüsü ≤ 0,15 m).
- **Kuru hendek** (`dunya.gd _su_shader / _kuru_kur`): su gölgelendiricisinin v2 kopyası, hendek bandının ham arazisi
  karada kalan kesiminde suyu çizmez (1 m/piksel maske; `TUR6 kuru_hendek piksel=101607`). Dip: kuru açık toprak, yer
  yer ot öbeği, alçak yerde koyu nem lekesi; birikinti üçte bire indi, çamurlu renk.
- **İç yüzler aydınlık**: kaplamanın gölgelendirme normali yukarı yatık; kaplama malzemesinin taban rengi açıldı (sur
  gölgelendiricisi "dipte koyulaşmayı" yerel y'ye göre yapıyor: hendek kesiti hep y < 0 → bütün yüz %28 koyu + yosun);
  gündüz ortam ışığının %45'i sıcak toprak yansıması (gölgedeki teal/kara şerit).
- **Omuz**: arazi köşe rengine çıplaklık ipucu (köşe alfası; `zemin_v2.gdshader`): hendek dış kıyısı 0–9 m tamamen
  çıplak → dışa doğru ot öbekleri (gürültülü sınır), ateş alanı çiğnenmiş. Çimen kıyıda jilet gibi bitmiyor; kıyıda
  toprak/çakıl/top güllesi.
- **Çadır/sancak/tezgâh kuşağı**: IstHayat'ın çadır ve sancakları hendek + sur dibinden 15 m + ateş alanında (60 m),
  kutuları 15 m'de çıkmaz (`gorsel_dil.gd`; önce 12 m).
Yapılmayan / kötü kalan:
- Kıyı çizgisi hâlâ CETVEL GİBİ DÜZ (arazi ağı bant dikdörtgeniyle kırpılıyor); "yer yer çökmüş/yenmiş kenar" yok.
  Toprak kayması kesimleri yalnız karşı yaka iç yüzünde.
- Derinlik/oran değişmedi (6 m / ~20 m); dışarıdan uzakta hâlâ koyu bir bant (gölge tarafı).
- Bent duvarları (uç dolguları) üstü geniş düz taş yüzey: havadan "levha" gibi (`hava_05`).
- Denetim: `yarik/levha/gomuk` → 0 TUTMADI (aşağıda); kuzey ucunun (s≈1780–1860) üst üste binen dilim/köşe hendekleri
  ele alınmadı.

### B. Sur dibi
Yapılan yalnız dolaylı: ortam ışığının sıcak payı (gölgede kara bant hafifledi), sur dibinde çıplak toprak (etek ve
arazi aynı çıplaklık ipucu). İstinat duvarı, dilim eklemlerinin kulede gizlenmesi, eklemde 2,6 m arazi sıçraması:
**yapılmadı**. Uzaktan sur dibi hâlâ düz çizgiyle bitiyor (`sahip_03`, `k13`).

### C. Zemin
- `scripts/world/ist/zemin_v2.gdshader` (YENİ; ortak `zemin.gdshader`'ın v2 kopyası — yayındaki bölümler ortak
  dosyayı kullanmaya devam eder): köşe alfası = çıplaklık; çıplak yerde ipucunun zeytin tonu ezilmiş sıcak toprağa
  (çakıl/kuru ot/çamur alacası), "makro alaca" çıplak yerde otu geri getirmiyor; ezilmemiş ot adaları; mikro ayrıntı
  28–95 m'ye kadar (16–55 idi) ve daha güçlü; 0,3–0,8 m'lik tutam/kesek gölgesi 220 m'ye kadar; 2–6 m nem/toz alacası.
- `dunya.gd _renk`: ordugâh 0,45–0,95, sur önü 0,35–0,8, yerleşik doku 0,3–0,8 çıplaklık; kuşak rengi
  (`sur_oturtma.gd renk`) üçüncü öğe olarak çıplaklık verir.
- Ordugâhın 16–26 m'lik saydam zeytin lekeleri (zemin dokusunu siliyordu) 9–15 m, %22 opak, koyu toprak; oba altı
  lekesi %90 → %38.
- **Top çukurları**: düz koyu disk + yarım küre yerine kabarık kenarlı sığ çanak (zemin malzemeli, dibi yanık toprak,
  dış eteği araziye iner).
- Sonuç (ölçü): zemin doku enerjisi 1,2 → 1,5 (yayındaki 2,6) — **hedefe ulaşmadı**. Renk artık ot yeşili değil; ama
  ordugâh ve sur önü bu kez geniş, tek düze açık kahve ("sarı halı" tehlikesi; `k05`, `k01`).

### D. Ordugâhın uzak katmanı
- Duman (`ordugah_ocak.gd`): üç çapraz düz şerit kenardan bakınca beyaz çubuktu. Şimdi rüzgârla güneydoğuya eğilen,
  yukarıda kıvrılıp dağılan, kopuk tutamlı, ocakların yarısında, 9–16 m boy, 0,26 yoğunluk (0,4 idi).
- "Ufukta gri-bej dikdörtgen sırası": piksel tanısıyla bulundu — ordugâh değil, **kara surunun uzak (L2 pişmiş)
  katmanı** ve arkasındaki şehir hücreleri (`Ist_pempton/L2/Pismis`, `IstSehir/@MeshInstance3D`). Kuleler uzakta mazgalsız
  kutu. Yalnız hatıl/ton (G) ele alındı; uzak kule silueti **yapılmadı**.

### E. Gece
Ortak kurala (`gorsel_dil.gd ORTAK`) gece payları: ay ışığı tabanı (soğuk, kategori başına 0,10–0,42 öz-ışık) ve kumaşta
çadırların ~%30'unda alttan sızan sıcak ocak/kandil ışığı. Gündüz değişmez (pay 0). Ölçü (k02+k10 gece, V-orta):
kumaş 0,07 → 0,16, zemin 0,05 → 0,12 (birlik öncesi 0,18 / 0,11).

### F. Şehir yanı
- **Havada pencere**: kök neden `evler.gd`: üst bant bir kattan alçakken `max(1, …)` yine bir pencere sırası koyuyordu
  (pencere/kepenk/saksı saçağın üstünde). `pencere_y` (v2'de pencere bandın ortasına iner ya da konmaz; yayındaki
  bölümde eski davranış; ev ağı disk önbelleğine "v2" eki). Gece yanan pencereler aynı kuraldan.
- **Küp eşya**: IstHayat "kutu" katmanının (sandık, yük, tezgâh, baca, direk; ~2 300 kayıt) birim küpü yuvarlak köşeli,
  şişkin, pahlı yük ağıyla değişti (`gorsel_dil.gd yuk_yuvarlak`). Ateş alanında kazık/ok kutu → silindir.
- Denetim `tests/_ist/havada_denetim.tscn` (YENİ): aşağıda.
- **Pastel küme (`hava_05`)**: mektup bölümünün (hub) şehri — yayındaki kurucularla v2'ye taşınıyor. Malzeme ve köşe
  rengi kopyalarıyla palete çekme denendi; karede değişmedi (renk başka yoldan geliyor, bulunamadı) ve çizim ekliyordu →
  kapatıldı. **Yapılmadı.**

### G. Sur dokusu
`sur_doku.gd`: hatıl bandı uzakta (`bant_g` sönümü) taş-harç ortasına karışmak yerine kızıl-kahve mat şerit kalır;
bant piksel altına inince dönemin ortalamasına (taş + hatıl payı) karışır (titreşim/dama yok). Orta mesafede hatıl
okunuyor; 400 m+ (`k05`, `k11`) hâlâ zayıf.

### H. Deniz surları ve Galata
Kara kuşağı bitmediği için **başlanmadı**.

## Denetimler (son satırlar, son kod)

| denetim | ÖNCE | SONRA |
|---|---|---|
| `tests/_ist/oturtma_denetim.tscn` | `OTURTMA ornek=3227 bosluk=0 gomuk=6 yarik=25 levha=6` | `OTURTMA ornek=3227 bosluk=0 gomuk=6 yarik=26 levha=6` |
| `tests/_ist/birlik_denetim.tscn` | `BIRLIK malzeme=238 kategorisiz=0 doygunluk_asan=0 duz_buyuk_yuzey=0 saf_beyaz=0` | `BIRLIK malzeme=238 kategorisiz=0 doygunluk_asan=0 duz_buyuk_yuzey=0 saf_beyaz=0` |
| `tests/_ist/havada_denetim.tscn` (YENİ) | eski kural: `HAVADA_ESKI pencere=4731` (küp: ~2 300 kutu kaydı küp ağıyla) | `HAVADA pencere=0 esya=0 cati=0` |
| `tests/parse_check.tscn` | `PARSECHECK PASS scripts=345` | `PARSECHECK PASS scripts=345` |

- OTURTMA hedefi (hepsi 0) **TUTMADI**: `yarik` 25 → 26 (+1; yer listesi `denetim_sonra.txt`: s=12–42 Marmara ucu ve
  kuzey kırığı), `gomuk` 6, `levha` 6 değişmedi. Eşik gevşetilmedi. Ara bir denemede harpuşta yatağını arazinin altına
  indirmiştim, denetim `yarik=206` verdi (dış kıyıda harpuşta–zemin açıklığı > 0,15 m) — geri alındı, taşlar gömüldü.
- HAVADA kapsamı (dürüst): pencere sayımı v2 ev kurucusunun (`evler.gd`) pencereleri; Haliç mahallesi, kuzeybatı semti,
  Galata kendi pencereleriyle bu sayımda yok. `esya=0`'ın "küp" yarısı yapım gereği (görünüm ağı değişti).
- `tests/_ist/` öteki sondaları (`sur5_kare --set=surekli`, `sehir2_kare --set=suryuru`, bölüm otomatik testleri) bu
  turda KOŞULMADI.

## Ölçüm (birlik ölçücüsü `tests/_ist/birlik_olc.py`, kategori kimlik kareleriyle)

Tam tablolar `olcum.md`. Özet (S: doygunluk, V: parlaklık, doku |∇²|×100):

| kategori | ölçü | yayındaki (birlik ölçümü) | ÖNCE | SONRA |
|---|---|---|---|---|
| zemin | S ort · V-orta · doku | 0,41 · 0,42 · **2,6** | 0,40 · 0,49 · 1,2 | 0,40 · 0,50 · **1,5** |
| taş | S ort · V-orta · doku | 0,44 · 0,55 · 3,0 | 0,36 · 0,47 · 2,8 | 0,46 · 0,45 · 2,7 |
| kumaş | S ort · V-orta · V%95 | 0,41 · 0,48 · 0,87 | 0,49 · 0,52 · 0,78 | 0,57 · 0,50 · 0,77 |
| sıva | V %95 | 0,81 | 0,98 | 0,97 |
| gece kumaş | V-orta · V%95 | — (birlik öncesi 0,18) | 0,07 · 0,16 | **0,16 · 0,35** |
| gece zemin | V-orta | — (birlik öncesi 0,11) | 0,05 | **0,12** |

Zemin doku enerjisi 1,2 → 1,5: yayındaki 2,6'ya ULAŞMADI. Taş doygunluğu referansa yaklaştı (yalnız ortam ışığı
değişikliğinin etkisi; taş malzemesi aynı). Kumaş doygunluğu biraz arttı (0,49 → 0,57; sıcak ortam ışığı).

## Bütçe (aynı kamera sırası, oyunun RINFO'su; ÖNCE: birleşik kod)

| kamera | çizim ÖNCE | çizim SONRA | fark | üçgen ÖNCE | üçgen SONRA | fark |
|---|---|---|---|---|---|---|
| sahip_03_sur_disi_30m | 1279 | 1278 | -0.1% | 3195347 | 3204555 | +0.3% |
| sahip_04_sur_disi_70m | 1223 | 1218 | -0.4% | 2912205 | 2904529 | -0.3% |
| s3_hendek | 1519 | 1516 | -0.2% | 5216738 | 5214188 | -0.0% |
| hendek_kenar_05 | 1509 | 1507 | -0.1% | 4828128 | 4826532 | -0.0% |
| k01_cadir_yakin_5m | 1141 | 1140 | -0.1% | 3666573 | 3673959 | +0.2% |
| k02_ordugah_on_hat_40m | 1400 | 1398 | -0.1% | 4698236 | 4701640 | +0.1% |
| k03_hendek_kenari | 1472 | 1474 | +0.1% | 4613283 | 4622695 | +0.2% |
| k04_sur_ustunden_ordugaha | 1112 | 1110 | -0.2% | 3282148 | 3299412 | +0.5% |
| k05_ordugahtan_sura_400m | 1364 | 1363 | -0.1% | 5487836 | 5478996 | -0.2% |
| k06_sehirden_sura_40m | 1264 | 1263 | -0.1% | 3098420 | 3067522 | -1.0% |
| k07_cadir_yakin_5m | 1525 | 1522 | -0.2% | 6559490 | 6541634 | -0.3% |
| k08_ordugah_on_hat_40m | 1597 | 1595 | -0.1% | 6894078 | 6859638 | -0.5% |
| k09_hendek_kenari | 1335 | 1342 | +0.5% | 5227171 | 5251863 | +0.5% |
| k10_sur_ustunden_ordugaha | 1493 | 1492 | -0.1% | 5230954 | 5237292 | +0.1% |
| k11_ordugahtan_sura_400m | 1403 | 1401 | -0.1% | 6079678 | 6041628 | -0.6% |
| k12_sehirden_sura_40m | 1654 | 1653 | -0.1% | 5749610 | 5711784 | -0.7% |
| k13_kapi_onu_1 | 1408 | 1407 | -0.1% | 3009858 | 3009314 | -0.0% |
| k14_kapi_onu_2 | 1257 | 1257 | +0.0% | 2668729 | 2688319 | +0.7% |
| k02_ordugah_on_hat_40m_GECE | 1312 | 1309 | -0.2% | 4464897 | 4480597 | +0.4% |
| k10_sur_ustunden_ordugaha_GECE | 1147 | 1130 | -1.5% | 4296361 | 4347410 | +1.2% |
| **toplam** | 27414 | 27375 | -0.1% | 91179740 | 91163507 | -0.0% |

Toplam çizim **−%0,1**, üçgen **−%0,0**; kare başı en kötü çizim **+%0,5** (sınır +%3, üçgen +%5: TAMAM). Ara bir
sürümde harpuşta ayrı ağdı ve kaplama doğrudan gölgelendirici malzemesindeydi: çizim kare başı +%6…+%12'ydi; harpuşta
kaplama ağına alındı, kaplama pişirmede birleşen Props malzemesine döndü (bkz. A).

Yükleme (`BIRLIK yukleme_ms`, ayrı koşular): ÖNCE 38,7 / 34,1 / 34,8 sn (ort. 35,9), SONRA 35,8 / 37,6 / 38,6 / 37,3 / 37,0
sn (ort. 37,3) → **+1,4 sn: SINIR (+1 sn) AŞILDI** (koşudan koşuya ±2 sn oynuyor; kaynak ayrıştırılmadı — şüpheli: ev ağı
önbelleğinin "v2" ekiyle ilk koşularda yeniden kurulması, harpuşta blokları).

## Kutu sayımı (SONRA kareleri)
- IstHayat çadırı (alaçık), insanı (yuvarlak gövde): birlikten beri kutu değil.
- IstHayat "kutu" katmanı (sandık/yük/baca/direk/ip): **kutu → yuvarlak köşeli yük** (bu tur). İnce direk ve ip artık
  6–8 kenarlı.
- Ateş alanı kazık/ok: **kutu → silindir** (bu tur). Kırık merdiven rayları ve basamakları: **hâlâ birim kutu**
  (`sur_zemin.gd ates_alani` `merdiven`) — tahta, kutu biçimli eşya.
- Ordugâhın hafif figürlerinde (45 m ötesi) kol ve çizme ince kutu (`ordugah_kisi.gd figur`): **duruyor** (ortak kişi
  modeline dokunulmadı; bu figür v2'nin, ama bu tur ele alınmadı).
- Kapı önü yıkık köprü ayakları (`surlar.gd`, `ag.kutu` sıraları) ve kırık kalaslar: kesme taş/tahta, kutu biçimli.
- Harpuşta, bent: kesme taş (kutu biçimli taş blok, canlı/yuvarlak değil).

## Kendi karelerime bakınca hâlâ kötü olanlar (sahibi ne der?)

1. **Hendek kıyısı hâlâ cetvel düz.** Omuz artık çıplak toprak ve harpuşta kesme taş sırası (eksik/kaymış taşlarla), ama
   kıyı çizgisi kilometre boyunca tek doğru; "yenmiş/çökmüş kenar" yok. Sahibi `s3_hendek`'e bakınca "hâlâ bıçakla
   açılmış ama artık toprakta" der.
2. **Zemin "yeşil halı"dan "kahverengi halı"ya döndü** (`k05`, `k01`, `dip_03_dis_boy`): ordugâh ve sur önü geniş, tek
   düze açık kahve; ot adaları ve çakıl yamaları uzaktan seçilmiyor. Doku enerjisi referansın yarısından biraz fazla.
3. **Sur dibi (B) neredeyse aynı**: uzaktan düz çizgi + gölgede koyu bant; dilim eklemleri ve istinat duvarı yapılmadı.
4. **Ordugâhta yerde uzun düz koyu çizgiler** (`k08`): ordugâhın yol/tekerlek izi şeritleri — yapay duruyor; dokunmadım.
5. **Uzak sur katmanı** (`k05`, `k08` ufku): kuleler mazgalsız kutu, soluk; hatıl uzakta zayıf.
6. **Hub'ın pastel/turuncu kümesi** (`hava_05`) duruyor (F kısmen).
7. **Bent duvarlarının üstü** havadan geniş düz taş levha (`hava_05`), kapı önü yıkık köprü kalasları.
8. **Gece**: çadırlar okunuyor, ama ışık sızan çadırlar fazla turuncu ve düzgün (`k02 GECE`); zemin hâlâ çok koyu.
9. **H (deniz surları, Galata)** hiç ele alınmadı.

Üç soru (son kareler): (1) sur araziye oturuyor mu — hendek kıyısında daha iyi (taş, toprak), sur dibinde hayır, aynı;
(2) aynı ressam mı — sur/çadır/zemin artık aynı sıcak toprak-taş ailesinde, zemin dokusu hâlâ daha yumuşak; (3) kutu gibi
duran — harpuşta ve bent taşları (kesme taş), ordugâhın uzak hafif figürlerinin kol/çizmesi, kırık merdiven, uzak sur
kuleleri.

## Kanıt
- `once_sonra/`: 144 kamera + 2 gece ÖNCE | SONRA tam boy (birlik 18; oturtmanın `hk_01/04/07/10` × aşağı/boyunca/içten,
  `hava_02/05/08/11`, `dip_00…dip_11` × dış/peri/şehir × ayak/boy/dik, `kara_05_yer60`, `hendek_kenar_08`; `sahip_03/04`,
  `s3_hendek`, `hendek_kenar_05` birlik tanımlarıyla). `pafta/`: dörderli ÖNCE | SONRA paftaları.
- **Düzeltilen kameralar** (`kameralar.txt`): `dip_01_sehir_*`, `dip_05_sehir_*`, `dip_08_sehir_*` sura yaslı evlerin
  içinde/çatısındaydı → sura 3 m'ye (savunma yolu) çekildi; `dip_03_*` (dokuzu da evin içinde ya da ters yanda) →
  `dip_02` ile `dip_04`'ün ortası. Bu kameraların ÖNCE'si de yeni konumdan (ÖNCE koduyla) alındı.
- `ref_ciftleri/`: yayındaki | v2 SONRA 6 çift.
- `ara1/`: ilk ara kayıt (A + C ilk hâli).
- `olcum.md`, `butce.md`, `denetim_once.txt`, `denetim_sonra.txt`.

## Kurala uymadığım yer / notlar
- Ara kayıt 1 ~1 sa 40 dk'da gönderildi (40 dk değil): Godot kurulumu, birleştirme ve ÖNCE karelerinin alınması önce geldi.
- Çalışma sırasında kapsayıcı bir kez yeniden başladı; SONRA kareleri sonra baştan alındı.
- Değiştirilen ortak dosyalar (yalnız v2 çağrısı): `scripts/level/zemin.gd v2_malzeme` (v2 gölgelendiricisi). Yayındaki
  bölümlerin görünüşüne dokunan değişiklik yok: `evler.gd`, `sur_zemin.gd`, `surlar.gd` yolları `IstSehir.v2` ile korunur.
