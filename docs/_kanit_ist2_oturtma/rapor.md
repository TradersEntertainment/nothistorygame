# OTURTMA raporu — sur ile arazi TEK yer (dal `wip/ist2-oturtma`)

Taban: `wip/ist2-sur5` (5169cbf8). Birleştirilen: `origin/wip/ist2-zemin` (zaten içerideydi), `origin/wip/ist2-bitki`
(`dunya.gd` çakışması: iki taraf da korundu: BİTKİ'nin `_ates_alani` kütüğü + benim kuşak maskem), `origin/wip/ist2-durus`
(`baglama.gd` tek satır: gelen dal o satırı değiştirmemişti, mevcut `["12b", "10h"]` kaldı).
Kareler: Godot 4.4.1, xvfb, `--rendering-driver opengl3` (yazılımla çizim), 1280×720, jpg 85, GERÇEK kurucu
(`IstDunya.build` → `IstSehir.attach_v2`), sonda `tests/_ist/oturtma_kare.tscn`.

**Aynı kamera:** ÖNCE (sur5 başlangıç kodu, depo dışında `~/is/once`) ve SONRA, `kam2.txt` mutlak kamera listesiyle
(`kameralar.txt` olarak bu klasörde). Liste ÖNCE'de üretildi; göz yüksekliği iki ağacın arazisinin büyüğü + 1,7 m'ye
çekildi (`--birlestir`; ilk ÖNCE koşusunda sur dışı kameralar ÖNCE arazisinin altında kalıyordu). Bu yüzden `dip_*`
kameralarının bir kısmı ÖNCE'de de, SONRA'da da yerden 1,7 m'den yüksek.

## Ne yapıldı (özet)

- **Tek yükseklik kaynağı (`scripts/world/ist/sur_oturtma.gd`, YENİ):** kara surunun her dilimi ve kapı koşusu için
  `IstGeo.duzle` kayıtları (geo.gd'nin kendi düzlük düzeneği; IstGeo.h hepsinin tek kaynağı): şehir önü (iç sur şehir
  yüzünden 16 m, 10 m'de doğala geçiş; bölüm düzlükleri — hub — korunur), iç kuşak (iç sur + peribolos = dilim tabanı),
  teras (dış kademe), hendek dış kıyısı (dilimin harpuşta düzeyi, 1 m geçiş), dış omuz (12 m'de doğala), hendek tabanı
  oyması (yalnız çarpışma). Dış kademe düzlemeden ÖNCE ölçülüp kaydedilir; dilimlerin kendi kurulumu (`IstSurlar.dis_dy`)
  kaydı okur (düzlenmiş araziden yeniden ölçmez). Kara tabanı ve kuşak zemini ≥ 2 m (deniz düzlemi/kıyı gölgelendiricisi
  sur dibini su gibi boyuyordu). Kurulum 8 ms (`OTURTMA kur oge=50 duz=1985 bant=88`).
- **Arazi ağı kesilir (`dunya.gd`):** hendek bandı (iç yaka duvarının dış yüzü … karşı yaka duvarının dış yüzü) ve dış sur
  gövdesinin içi: o bantlara değen arazi üçgenleri kırpılır (Sutherland–Hodgman, yeni köşe yüksekliği IstGeo.h'den →
  kıyıda arazi harpuşta düzeyinde biter); iç kırıklarda gönye payı. Kıyı köşelerinin normali oyuktaki komşuyu saymaz.
- **Levhalar:** şehir önü kaldırımı, peribolos ve teras levhaları kalktı (arazinin 0,12 m altında yalnız dikiş arkalığı);
  duvar gövdeleri tabanın 1 m altından, temeller 3,5 m; temel levhası duvar yüzünden 0,15 m içeride (dış kademe uzatmasıyla
  aynı düzlemde z-çakışması yapıp dış surun dışında **beyaz/gri bant** çiziyordu — sahibin "levha"sı buydu). Ateş alanının
  arazi üstünde 0,12–0,6 m yüzen ikinci zemin ağı (`AtesAlaniOrtu`) ve hendek dışındaki ayrı toprak set ağı kalktı; rengi
  arazinin köşe rengine geçti.
- **Hendek:** kesitte iki yakada harpuşta (arazinin 8–13 cm üstü), taş örgü yüz, yuvarlak dip, çamur taban; dilim uçlarında
  bent duvarları (önceden). Köşe dolgularında düz tek renk taban / dik prizma yerine aynı kesit (`sehir.gd:_kose_hendek`);
  köşe dolgusunun toprak şeritleri alçak ucun düzeyinde (yüksek uçta levha oluyordu).
- **Sur dibi (`sur_oturtma_ag.gd`, YENİ):** her duvar yüzünde ve kule kaidesinde 3–6 m'lik düzensiz toprak/moloz eteği
  (0,3–0,8 m, iç ucu duvarın içinden çıkar, uç arazinin 3 cm altına iner), duvar dibinde sahte AO, taş tozu → çıplak
  toprak köşe rengi (arazinin aynı 6 m ızgarası ve aynı malzemesi), dip bandı (alt 1,5 m nem/sıçrama/yosun, benekli,
  yukarı seyrelir), ot öbeği (ince yapraklar), düşmüş taş (düzensiz kaya), çalı (düzensiz öbek). Etek çarpışmalı.
- **Maske:** karşı kıyı öğeleri (ot piramidi, ağaç, ev, kütük) sur dibi 12 m + hendek + ateş alanı (hendek dış kıyısından
  60 m) içinde çıkmaz (`kusak_maskele`, 171 öğe kaldırıldı).

## Ölçütler

| # | ölçüt | durum | kanıt |
|---|---|---|---|
| 1 | Tek yükseklik kaynağı | **KISMEN** | Bütün kara hattı IstGeo.h'den (düzlük kayıtları); dilim tabanı hâlâ dilim başına sabit (30–110 m), eğimde dilim dilim basamaklanır (kule kule değil). `dip_*`, `hava_*` |
| 2 | Görünen alt kenar yok | **TAMAM (ölçüye göre)** | denetim `bosluk=0`; ama ölçü ÖNCE'de de 0 verdi (aşağıda) → ayırt edici değil; asıl kanıt `dip_00_dis_dik` (gri bant gitti) |
| 3 | Temas kuşağı | **KISMEN** | etek, AO, dip bandı, ot/taş/çalı var (`dip_02_peri_ayak`, `dip_03_sehir_ayak`); renk geçişi kaba (6 m ızgara), eteğin ucu bazı karelerde tümsek çizgisi gibi |
| 4 | Düz gri levha yok | **KISMEN** | levha 520 → 6 (denetim); kalan 6 ve ölçülmeyen istinat duvarı (teras kenarı = parateikhion; ayrı istinat duvarı YOK) |
| 5 | Hendek gerçek hendek | **KISMEN** | arazi çukurun üstünden geçmiyor (yarik 595 → 25); harpuşta arazi hizasında; köşe dolgularında kesit. Kalan: alçak yerlerde hendeğe deniz düzlemi giriyor (su dolu hendek), sık kırıklı kuzey ucunda (s≈1780–1860) dilimlerin hendekleri üst üste |
| 6 | Sur kuşağında yabancı oyuncak yok | **KISMEN** | `Karsi_*` piramit/ağaç TAMAM (`s3_hendek`, `sahip_03/04`); `IstHayat` çadır/sancak/kutuları DURUYOR (benim dosyam değil, ORTAK İSTEK 1) |
| 7 | Kutu yasağı | **KISMEN** | eklediklerimde kutu 0; dosyamda kalan SUR-4 ateş alanı çubuk/merdiveni kutu (aşağıda) |
| 8 | Kapsam sırası | **kara: KISMEN, deniz surları + Galata: YAPILMADI** | — |
| 9 | Çarpışma görünenle aynı | **KISMEN / ölçülmedi** | arazi çarpışması aynı IstGeo.h; etek trimesh çarpışmalı; hendek rampaları duruyor; oyuncuyla sur dibi/hendek yürüyüşü ÖLÇÜLMEDİ |
| 10 | Bütçe | **TAMAM (üçgen/çizim) / yükleme KÖTÜLEŞTİ (ayrıştırılmadı)** | aşağıda |

### Denetim (`tests/_ist/oturtma_denetim.tscn`, bütün kara hattı, 5 m adım, görünen üçgenlere dikey ışın)

| | örnek | bosluk | gomuk | yarik | levha |
|---|---|---|---|---|---|
| ÖNCE (sur5) | 3246 | 0 | 66 | 595 | 520 |
| SONRA | 3227 | 0 | 6 | 25 | 6 |

Son satır (SONRA, son kod): `OTURTMA ornek=3227 bosluk=0 gomuk=6 yarik=25 levha=6` (deniz üstü düzlük düzeltmesinden önce 21; fark hat uçlarında). Hedef 0 TUTMADI. Kalanlar (yer listesi
`denetim_sonra.txt`):
- gomuk 6: hattın Marmara ucu s=22–28 (sur denize iniyor; arazi duvar tepesinden yüksek ölçülen iki nokta), s=1458 (2,0 m),
  s=1682 (kuzey kırığı).
- yarik 25 (listede ilk 12): s=12–32 Marmara ucu; s=1168/1362 iç kırıkta komşu dilimin rampası; s=1780–1860 ve 2038 kuzeyde art arda kırık
  (köşe dolguları 36–40 ve dilimler 30–34 hendekleri üst üste), açıklık −0,2…−2 m.
- levha 6: s=1372/1378 teras 0,28 m, s=1732/1772 peribolos 0,21 m, s=1858 0,86 m, s=2052 0,78 m (köşe dolgusu şeritleri).
- **Ölçü zaafı (dürüst):** `bosluk` ÖNCE'de de 0 çıktı: dikey ışın duvarın en alt yüzeyini (temel levhası, −1,5/−3,5 m)
  buluyor; o hep zeminin altında. Sahibin gördüğü "duvar levhaya basıyor / alt kenar" kusurunu bu ölçü yakalamıyor;
  onun kanıtı karelerdir. Eşik gevşetilmedi.

### Bütçe (oyunun RINFO'su, aynı 132 kamera)

`kare=132 cizim ONCE=167370 SONRA=169573 (+1,3 %) ucgen ONCE=495,2 M SONRA=494,8 M (−0,1 %)`  (sınır ≤ %15: TAMAM)

| kare | ÖNCE çizim | ÖNCE üçgen | SONRA çizim | SONRA üçgen | fark (çizim / üçgen) |
|---|---|---|---|---|---|
| sahip_03_sur_disi_30m | 1186 | 3.15 M | 1244 | 3.22 M | +5 % / +2 % |
| sahip_04_sur_disi_70m | 1118 | 2.88 M | 1193 | 2.92 M | +7 % / +1 % |
| s3_hendek | 1039 | 2.84 M | 1078 | 2.87 M | +4 % / +1 % |
| kara_05_yer60 | 1197 | 2.97 M | 1238 | 3.02 M | +3 % / +2 % |
| hendek_kenar_05 | 1145 | 3.07 M | 1139 | 3.10 M | −1 % / +1 % |
| hendek_kenar_08 | 1114 | 2.24 M | 1173 | 2.30 M | +5 % / +3 % |
| hava_02 | 1275 | 5.88 M | 1276 | 5.88 M | 0 % / 0 % |
| hava_08 | 1032 | 5.71 M | 1058 | 5.76 M | +3 % / +1 % |

(Toplam fark SONRA'daki bitki/duruş birleşimini de içerir.)

Yükleme (`OTURTMA yukleme_ms`, kurucu çağrısından dönüşe; aynı makine, tek başına, ikişer koşu):
ÖNCE 31 619 / 31 831 ms, SONRA 34 085 / 34 846 ms → **+2,7 s (+%8,6) KÖTÜLEŞTİ.** SONRA'da bitki ve duruş dallarının
birleşimi de var; benim payım ayrıştırılmadı (OTURTMA kurulumu 8 ms; düzlük kayıtları ~1 985 disk → IstGeo.h çağrıları
sur kuşağında pahalılaştı; arazi ağı kırpması bant çevresindeki parçalarda).

### Var olan testler

- `tests/parse_check.tscn`: `PARSECHECK PASS scripts=344`.
- `tests/_ist/sur5_kare.tscn --set=surekli` (yakın/orta/uzak aynı): kara iç `bosluk=0`, kara dış `bosluk=5` (SUR-5: 3;
  yeni ikisi s=792/798 = Mesoteikhion gediği, belgeli kasıtlı yıkık), Blakherna 0, Marmara 0, Haliç 1 (hat başı, aynı),
  Galata 0.
- `tests/_ist/sehir2_kare.tscn --set=suryuru`: kara 130/145 (SUR-5 130/145), Blakherna 14/19 (14/19), Marmara 159/176
  (159/176), Haliç 88/123 (87/123); **Galata ölçülmedi** (koşu 30 dk zaman sınırında durdu).
- Bölüm otomatik testleri (7, 11) bu turda KOŞULMADI.

## Kendi karelerime bakınca hâlâ kötü olanlar

1. **Sur dışından bakınca hendek hâlâ "koyu bir yarık".** Arazi artık hendeğin üstünden geçmiyor ve harpuştada bitiyor,
   ama 6 m derin, iki yanı koyu taş, dibinde deniz düzlemi suyu olan kesit uzaktan siyah bir şerit okunuyor
   (`kara_05_yer60`, `dip_05_dis_ayak`). Alçak yerlerde (Lykos) hendeği deniz düzlemi dolduruyor: "yer yer su birikintisi"
   değil, dolu kanal.
2. **Kuzey ucundaki sık kırıklar (s≈1780–1860) karışık:** dilimlerin ve köşe dolgularının hendekleri üst üste biniyor,
   kıyıda 0,2–2 m'lik kademeler var (denetim yarik listesi).
3. **Hendek yanında IstHayat çadırları, sancaklar, mavi örtü kutuları duruyor** (`sahip_03`, `s3_hendek`, `kara_05_yer60`).
4. **Peribolos ve teras zemin rengi düz ve yeşil-gri;** sur dibinde gölgede bazı yerler koyu mavi-yeşil okunuyor. Renk
   geçişi 6 m ızgarada, etekle aradaki geçiş bazen çizgi gibi.
5. **Teras kenarında gerçek istinat duvarı yok** (alçak parateikhion duvarı var; teras hendeğe parateikhion + harpuştayla
   iniyor); "kalınlığı görünen yatay yüzey" kalmadı ama 4. ölçütün istinat duvarı kısmı yapılmadı.
6. **Dilim tabanı hâlâ 30–110 m'lik rijit parça:** eğimde sur kule kule değil dilim dilim basamaklanıyor; eklem yerinde
   arazi 2,6 m'lik kısa geçişle bir düzeyden ötekine iniyor.
7. **Kuzey ucunda (Haliç kıyısı, `hava_11`) kıyıya taşan küçük bir arazi parçası kaldı.**
8. **Deniz surları ve Galata hiç ele alınmadı** (havada duran kule/parça sayımı yapılmadı).

## Kutu sayımı (kendi karelerimde, sur kuşağı)

- Eklediklerim: ot öbeği (ince yaprak), taş (düzensiz kaya), çalı (düzensiz öbek), etek (kesit ağı): **kutu 0, piramit 0.**
- Dosyamda (SUR-4'ten) kalan: ateş alanında kazık/ok `cubuk` ve kırık merdiven rayları birim kutu (`sur_zemin.gd:ates_alani`)
  → **1 tür kutu kalan.** Hendek bentleri ve harpuşta köşeli taş (kesme taş: sayılmadı).
- Yabancı: `IstHayat` çadır/kutu/sancak (ORTAK İSTEK 1). `Karsi_ot_*` piramidi ve oyuncak ağaç: kuşakta **0**.

## ORTAK İSTEK

1. **CANLI / HAYAT (`hayat_veri.gd` yerleşim döngüleri, satır ~629 ve ~663):** sur kuşağında öğe konmasın:
   `if IstDunya.OTURTMA.kusakta(p.x, p.y, 12.0, IstDunya.OTURTMA.ATES): continue` (hendek + sur dibi 12 m + ateş alanı
   60 m). Çadır, sancak, örtülü kutu şu an hendeğin kıyısında.
2. **DÜNYA / DENİZ (`dunya.gd:_deniz*`):** deniz düzlemi hendeğin içinde çiziliyor (taban y < 0 olan yerlerde hendek su dolu).
   Hendek bandı (`OTURTMA.bant_ici`) için deniz çizilmesin ya da `IstGeo.deniz_yok`'a eklenebilen biçim (eksen hizalı
   dikdörtgen değil, çizgi bandı) gerekiyor.
3. **ZEMİN (`zemin.gdshader`):** malzeme kıyı bandını ve aşınma maskesini ağın YEREL y'sine göre hesaplıyor; yerel
   çerçevede kurulan ağlar (etek, hendek toprağı) kıyı sanılıyor. `su_y`'yi dünya y'sine bağlayan bir seçenek.
4. **ORDUGÂH (BİLGİ):** hendekten 60 m'ye kadar ateş alanı; çadırlar ve bayraklar oraya düşmesin.

## Dosyalar

- Yeni: `scripts/world/ist/sur_oturtma.gd`, `scripts/world/ist/sur_oturtma_ag.gd`, `tests/_ist/oturtma_kare.gd/.tscn`,
  `tests/_ist/oturtma_denetim.gd/.tscn`.
- Değişen: `dunya.gd` (yalnız arazi ağı kırpma, kuşak rengi, kuşak maskesi), `surlar.gd`, `sur_zemin.gd`, `sehir.gd`
  (yalnız sur işlevleri: `_hatlar_v2` çağrısı, `_hat_piece` taban alt sınırı, kapı tabanı alt sınırı, `_kose_dolgu`,
  yeni `_kose_hendek`).

## Kareler

- `once_sonra/<ad>_ONCE.jpg`, `once_sonra/<ad>_SONRA.jpg` — 132 kamera, tam boy.
- Paftalar: `pafta_a_sur5_kameralari.jpg` (sahip_03/04, s3_hendek, kara_05_yer60, hendek_kenar/ici_05/08),
  `pafta_b_dip_*.jpg` (12 nokta × dış/peribolos/şehir × dik/boy/ayak), `pafta_c_hendek_kenari.jpg`,
  `pafta_d_hava.jpg`. `ara1/`: ara kayıt.
- Kamera listesi: `kameralar.txt` (ad x y z rx ry).
- **Kod sürümü notu:** 25 kare (`hava_*`, `dip_00_*`, `dip_11_*`, `hk_10_*`) en son kodla; öteki 107 SONRA karesi deniz
  üstü düzlük düzeltmesinden (son işlem) ÖNCEki kodla alındı. Fark yalnız hattın Marmara ve Haliç uçlarında (kuzey ucunda
  arazinin Haliç'e dil gibi uzaması; `hava_11`'de küçük bir parça hâlâ duruyor).
