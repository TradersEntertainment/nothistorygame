# TUR-8 — Sur kuşağının kalan görünüş kusurları: rapor

Dal `wip/ist2-tur8`. ÖNCE = `wip/ist2-birlesik` **28f42bb4** (depo dışı kopya, `git archive`, aynı makine, aynı kameralar).
SONRA = bu rapordaki son kayıt. Kareler 1280×720 jpg 85. Klasörler: `once/`, `sonra/` (A, B, C, D, c20), `pafta/`
(sol ÖNCE | sağ SONRA, `A.jpg`, `B.jpg`, `C.jpg`, `D.jpg`, `c20.jpg`). Ham test/ölçüm satırları `testler/`.

Kameralar: A `tests/_ist/sur_oyun_demo.tscn` (10 gündüz + 2 gece); B `docs/_kanit_ist2_tur7/kameralar_B.txt` (17) +
`kameralar_B_gece.txt` (2, `*_GECE.jpg`) ile `tests/_ist/birlik_kare.tscn --set=liste`; C `kameralar_C.txt` (8, göz 1,62 m)
ile `tests/_ist/tur7_kare.tscn`; D `tests/_ist/tur7_kesim.tscn --gece --sec=D1…D4`; D'nin gece oyuncu kamerası Bölüm 20 yeni
sette `-- --chapter=20 --autotest=kare --dialogshots=…` (`c20/an_01…an_10`, açılış = an_01, gediğe taşıma = an_03).

## Maddeler (1–5)

| # | madde | durum | kare (ÖNCE → SONRA) | kök neden → ne yapıldı |
|---|---|---|---|---|
| 1 | Hendek | **KISMEN** | A 02/03/05/07, C c4/c5, B s3/k03 | **İç yüzler "dikey şeritli perde"**: sur taşı gölgelendiricisi desen yönünü gölgelendirme normalinden alıyordu; hendek kaplamasının normali yukarı yatırıldığı için (y ≈ 0,78) yüz "yatay döşeme" sayılıyor, 0,9 m'lik xz ızgarası dik yüzde dikey şerit çiziyordu. Köşe tonu da 2,5 m'lik sütun başına rastgeleydi. → "dik mi" kararı geometrik normalden (görüş uzayı türevi), ton yumuşak iri gürültü + yer yer akıntı lekesi; yüzde **örgü + tuğla hatıl + dökülmüş taş oyukları** (hendek yüzünde sık, ana surda seyrek), iki yüzün dibinde dökülmüş taş öbekleri (`sur_doku.gd`, `sur_zemin.gd`). **Dış kıyı**: harpuşta taşları dış yakada öbek öbek eksik/kaymış (kıyının çöktüğü yerle aynı gürültü), ±8 cm düzensiz; kıyı örtüsünün kopan kenarı 2–3 m'de bir karaya girintili; dış yakada ot tutamı. TUR-7'nin "çökmüş kenarı" hendek yüzünün ~2,5 m üstünde boşlukta sarkıyordu: artık yüzü izliyor. Çarpışma AYNI. KALAN: uzaktan (B k03, A 05) kıyı hâlâ fazla düz bir çizgi; yakından iyi. |
| 2 | Sur tek ton / sarı yamalar | **KISMEN** | C c1/c2, A 03/04, B k04/k06, c20 an_01/an_03/an_09 | **Sarı dikdörtgenler**: blokların %14'ü "kumtaşı" sarısına çekiliyordu, ton aralığı geniş → güneşte düz sarı levha. **Uzakta tek ton**: hatıl ve derzler eşikle söndürülüyordu (fy > 0,34 m → ortalama renk). → blok tonu yalnız parlaklık + hafif sıcak/soğuk, blok kenarı içe doğru yumuşak kararır; komşu blokları birlikte koyulaştıran blok ölçeğinde yıpranma yaması; hatıl ve sıra derzi **kutu süzgeçli** (yakında tuğla tuğla, ortada ince kızıl çizgi, uzakta ortalama; titreşim yok). **Bölüm 20'de sur hiç bu gölgelendiriciden geçmiyordu** (Props "ashlar" dokusu; `_run` `uygula`'yı yalnız şehirde çağırıyordu) → kesimde de uygulanıyor (iki ressam → bir ressam). KALAN: güneşte sur hâlâ sıcak tan ağırlıklı (toon ışık + taban renk); yakından gece blok derzleri biraz "iri tuğla" okunuyor (D2, c20 an_09). |
| 3 | Gece zemini | **KISMEN** | D1–D4, A gece_06, c20 an_01/an_03/an_09 | Peribolostaki sert kenarlı koyu levhalar: tanı (`--gizle`): levhaların büyük kısmı **ay gölgesi** (kule ve sur gölgesi düz zemine düşüyor; kenar testere dişi gölge haritası çözünürlüğü). Bunun ışığı Bölüm 20'de `Night.environment` (`scripts/level/`, benim değil), test kesiminde test sahnesinin ışığı → **istek** (aşağıda). Benim dosyamdaki pay: `zemin_renk` koyu ıslak lekesi eşikliydi (n2 > 0,74; 2,5 m ızgarada düz kenarlı koyu çokgen) → yumuşak rampa. Sur dibi siyah tırtıklı bant: c20 an_01/an_03 SONRA'da sur dibinde görülmedi (TUR-7'nin yumuşak bandı yerinde). KALAN: gölge kenarı testere dişli; c20 an_09'da zeminde kahverengi/gri düz kenarlı yama (sette zemin; kaynağı bu turda ayrıştırılmadı). |
| 4 | Ordugâh önü | **TAMAM (çit) / KISMEN (çukur)** | B k04, s3, k03 | Kahverengi uzun "kutu": `ordugah_yapi2.gd build_siper` görünüşü 3 m'lik sürekli kalas kutusuydu (+ lod 0'da kutu kazıklar) → tek tek **sivri uçlu kazık** (lod 0 üç yüzlü prizma + uç, lod 1 iki yüzlü beşgen), boy 1,6–2,15 m, ±eğim, ton farkı, taban zemine 0,25 m gömülü. Çarpışma kutusu AYNI. Çukurlar: 0,24 m kabarık açık renkli kenar güneşte parlak çember okunuyordu → kenar 0,08 m, renkler arazi tonuna yakın, çember düzensiz. KALAN: B k04'te çukurlar üstten hâlâ soluk iz olarak seçiliyor (halka değil). |
| 5 | Bütçe | **TAMAM (bu turun ÖNCE'sine göre)** | B 17 kare | Aşağıdaki tablo. Uzak ordugâh figürü (lod 1) kuşak/çizme/göğüs kapağı atılarak ~%27 az üçgen; kıyı otu yalnız dış yaka. |

## Üç sözleşme denetimi (ÖNCE 28f42bb4 → SONRA)

| denetim | ÖNCE | SONRA |
|---|---|---|
| `tests/_ist/sur_sozlesme.tscn` | `SURSOZLESME PASS kalem=13 kesim=8` | `SURSOZLESME PASS kalem=13 kesim=8` |
| `tests/_ist/sur_oyun_denetim.tscn` | `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` | `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` |
| `tests/_ist/sur_oyun_yuru.tscn` | `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` | `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` |

(ÖNCE satırları tur 7 raporunda ve pilot raporunda aynı; bu turun her ara kaydından önce SONRA aynıydı. Son kodla:
`testler/den_*.txt`.)

## Testler (son kod, `--max-fps 20`, süzgeç `AUTOTEST (PASS|FAIL)|SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|WARN_FLY|WARN_VOID`)

- `tests/parse_check.tscn` → `PARSECHECK PASS scripts=355`
- `--chapter=20 --autotest` → `AUTOTEST PASS chapter=20 … outcome=20.1 … sur=yeni`
- `--chapter=20o --autotest` → `AUTOTEST PASS chapter=20o … outcome=20O.1 … sur=yeni`
- `--chapter=26 --autotest` → `AUTOTEST PASS chapter=26 … outcome=26.1`
- `--chapter=43o --autotest` → `AUTOTEST PASS chapter=43 … outcome=43O.1`

Dördünde de denetim satırı **0** (`testler/t_*.txt`).

## Bütçe (ÖNCE 28f42bb4 ↔ SONRA, aynı makine, aynı kamera, İKİ KOŞU AYNI ANDA; `testler/oB2.txt`, `testler/sB_butce.txt`)

| kare | çizim ÖNCE | çizim SONRA | Δ | ilkel ÖNCE | ilkel SONRA | Δ |
|---|---|---|---|---|---|---|
| sahip_03_sur_disi_30m | 1260 | 1308 | +3.8% | 3201968 | 3146018 | -1.7% |
| sahip_04_sur_disi_70m | 1180 | 1206 | +2.2% | 2844775 | 2837411 | -0.3% |
| s3_hendek | 1507 | 1550 | +2.9% | 5206393 | 5142695 | -1.2% |
| hendek_kenar_05 | 1482 | 1541 | +4.0% | 4813113 | 4779091 | -0.7% |
| k02_ordugah_on_hat_40m | 1397 | 1397 | +0.0% | 4708570 | 4678988 | -0.6% |
| k03_hendek_kenari | 1474 | 1500 | +1.8% | 4525471 | 4453585 | -1.6% |
| **k04_sur_ustunden_ordugaha** | 1089 | 1109 | **+1.8%** | 3239058 | 3174626 | **-2.0%** |
| k05_ordugahtan_sura_400m | 1721 | 1363 | -20.8% | 7555176 | 5474000 | -27.5% |
| k06_sehirden_sura_40m | 1266 | 1310 | +3.5% | 3044880 | 3005102 | -1.3% |
| k08_ordugah_on_hat_40m | 1594 | 1594 | +0.0% | 6898590 | 6837416 | -0.9% |
| k09_hendek_kenari | 1368 | 1377 | +0.7% | 5258099 | 5219019 | -0.7% |
| k10_sur_ustunden_ordugaha | 1513 | 1529 | +1.1% | 5186804 | 5115510 | -1.4% |
| **k11_ordugahtan_sura_400m** | 1414 | 1413 | **-0.1%** | 6126154 | 6084494 | **-0.7%** |
| k12_sehirden_sura_40m | 1661 | 1679 | +1.1% | 5674358 | 5581564 | -1.6% |
| k13_kapi_onu_1 | 1356 | 1414 | +4.3% | 2984873 | 3000975 | +0.5% |
| k14_kapi_onu_2 | 1266 | 1277 | +0.9% | 2659939 | 2654767 | -0.2% |
| kara_05_yer60 | 1283 | 1313 | +2.3% | 2983801 | 2991739 | +0.3% |

Bütün kareler şehir sınırı (+%5) içinde (çizim en çok +%4,3, ilkel −%2,0…+%0,5). k05'in −%20'si ÖNCE koşusunun akış
gürültüsü (aynı kod ilk ÖNCE koşusunda 1363 çizim). Çizim artışının kaynağı (dökümü `tests/_ist/tur8_butce.tscn`,
`testler/bo.txt` / `bs.txt`): hendek dibi dökülmüş taş MultiMesh'i (her dilimde bir; k04'te +11 yüzey) ve kıyı otu
(ilk sürümde iki yaka +23 yüzey; dış yakaya indirildi).

**Tur 7 ÖNCE'sine (20948418) göre k04/k11**: o kod bu depoda yok (yeniden ölçülemedi). Tur 7 raporunun aynı anda ölçülen
satırıyla: k04 1010/2,90 M → bu turun SONRA'sı 1109/3,17 M (fark büyük kısmı şehir akış gürültüsü + başka oturumların
eklemeleri; ayrıştırılamadı), k11 1341/5,69 M ↔ bu turun ÖNCE/SONRA'sı aynı anda 1341/5,71 M – 1341/5,72 M (`testler/bo.txt`,
`bs.txt`): **k11 aşımı gürültüydü**. k04'te bu turun kendi katkısı −%2,0 ilkel.

A (kesim, sınır +%15) D kareleri, ÖNCE/SONRA bu turun koşuları (`TUR7KESIM kare … cizim= ilkel=`; ekran kartı yok,
yazılımsal GL): D1 105→105 / 165428→163574 (−1,1%), D2 451→453 / 349641→355127 (+1,6%), D3 243→249 / 227926→239348
(+5,0%), D4 167→169 / 182908→187746 (+2,6%): sınır içinde.

## Kutu sayımı

Kesim sahnesi, pişirme kapalı (`tur7_kesim.tscn --kutu_say --pisirme_yok`, `testler/ko.txt`, `ks.txt`): görünen BoxMesh ağlı
öğe ÖNCE **904** → SONRA **904**, yeşil kutu **0 → 0** (hepsi yapı/ahşap: diş, kalas, merdiven, iskele).
Şehirde ordugâh kazık perdesi: 3 m'lik her siper diliminde ÖNCE 1 kalas kutusu (+ lod 0'da 6 kutu kazık) → SONRA **0 kutu**
(sivri prizma/beşgen kazık). Hendek ve kıyıya eklenenler kutu değil (kaya ağı, ot yaprağı). Şehrin bütününde otomatik kutu
sayımı yapılmadı.

## SONRA karelerine tek cümlelik bakış (tam boy bakıldı)

- A 01 ovadan: sur blok + hatıl uzaktan okunuyor, sarı yama yok; sur dibi uzaktan hâlâ düz — **kısmen iyi**.
- A 02 hendek kıyısı: karşı yüz örgülü/hatıllı/oyuklu (perde yok); kıyıda kalas çizgisi yok, ot var; ortadaki kahverengi dolgu kaması oyun parçası (benim değil) — **iyi**.
- A 03 köprü üstü: hendek iç yüzü artık taş örgü (ÖNCE dikey şeritli düz perde); ana surda yer yer dökülmüş taş; havada bir şey yok — **iyi**.
- A 04 merdiven dibi: ÖNCE'deki sarı dikdörtgen yamalar yok, bloklar yumuşak tonlu — **iyi**.
- A 05 sur yolundan: karşı yaka örgülü, kıyı kenarı girintili ama uzaktan hâlâ fazla düz — **kısmen**.
- A 06 / gece_06 peribolos: zemin yumuşak; gece ay gölgesi düz kenarlı — **kısmen**.
- A 07 gedik: arkadaki hendek yüzü örgülü (ÖNCE perde) — **iyi**.
- A 08 poterna: kanat ve sur aynı; gölgedeki peribolos zemini hâlâ koyu düz — **kısmen**.
- A 09/10 havadan: ÖNCE ile çok yakın; sur ve hendek aynı ressamın elinden, uzak ova soluk — **kısmen iyi**.
- D1–D4 gece: sur hatılı uzakta da okunuyor; zeminde ay gölgesinin düz/testere dişli kenarı (kule gölgesi) duruyor; D1'de kule mazgal yarıkları simsiyah çubuk — **kısmen**.
- B k04: kazık perdesi tek tek kazık (kutu değil), çukurlar soluk iz; yakın surun parapet üstünde ince koyu benekler — **iyi / kısmen**.
- B s3/k03/k09/hendek_kenar_05: hendek yüzü örgülü, kıyıda harpuşta kalası yok; uzaktan kıyı ince düz çizgi — **kısmen iyi**.
- B sahip_03/04, k13/k14: sur blok + hatıl, sarı yama yok; sur dibi uzaktan düz — **kısmen iyi**.
- B k05/k11 (400 m): fark gözle seçilmiyor (çadır denizi aynı) — **değişmedi**.
- B k06/k12 şehirden: sur aynı; ev kümeleri B'nin — **değişmedi (benim kısmım iyi)**.
- B gece k02/k10: değişmedi — **değişmedi**.
- C c1/c2: sarı dikdörtgen yok, bloklar ve yakında tuğla hatıl okunuyor — **iyi**; c3–c8: sur ve hendek örgülü — **iyi**.
- c20 an_01 açılış / an_03 gediğe taşıma: sur artık şehirdeki gölgelendiriciyle (blok + kızıl hatıl, uzak surda da bant); sur dibinde siyah tırtıklı bant görülmedi; karakterler aynı — **iyi**.
- c20 an_09 okçular: sur blokları ve tuğla hatıl net; surun üst yarısında ay ışığı/gölge düz kenarlı lekeler, zeminde düz kenarlı kahverengi/gri yama — **kısmen**.

## Hâlâ kötü olanlar (dürüst)

- **Ay gölgesinin kenarı testere dişli ve peribolos gölgeleri düz levha gibi** (D1–D4, c20 an_09): ışık ve gölge haritası benim
  dosyamda değil → istek.
- **Hendek dış kıyısı uzaktan** (A 05, B k03) hâlâ fazla düz bir çizgi; yakından düzensiz.
- **Güneşte sur sıcak tan ağırlıklı** (A 01, B sahip_03): blok tonu ve hatıl okunuyor ama bütün renk sıcak; toon ışık ortak.
- **Gece yakından derzler iri tuğla gibi** okunabiliyor (D2, c20 an_09).
- **c20 an_09 zemin yaması** (kahverengi/gri düz kenar): kaynağı bu turda ayrıştırılmadı (set zemini olabilir).
- **D1 kule yarıkları** simsiyah çubuk (gece, `KuleKoyu`): dokunulmadı.
- **Çukurlar** üstten soluk iz olarak seçiliyor (halka değil ama yok da değil).
- Sur dibi 60 m'den düz çizgide bitiyor (tur 7'den): bu turda yapılmadı.
- Bu oturumda bir kez kural dışı `pkill -P` yazıldı (eşleşen süreç yoktu, etkisiz); sonrası yalnız `kill <pid>`.

## İstekler

- **`Night.environment` / bölüm ışığı sahibine (scripts/level)**: ay ışığına `shadow_blur` (≈1,5–2) ve daha kısa
  `directional_shadow_max_distance` (peribolos için ~80 m) — kare: `sonra/D/gece_D1…`, `sonra/c20/an_09_okcular.jpg`. Peribolosun
  "düz kenarlı koyu levhaları" çoğunlukla kule/sur gölgesi; sertlik ve testere dişi bu ayardan.
- **C (TAŞIMA) / set zemini**: c20 an_09'daki kahverengi/gri düz kenarlı zemin yaması (`sonra/c20/an_09_okcular.jpg`).

## Değişen dosyalar (28f42bb4 → son kayıt; görünüş, çarpışmasız)

| dosya | ne |
|---|---|
| `scripts/world/ist/sur_doku.gd` | dik/yatay kararı geometrik normalden (görüş uzayı türevi); kutu süzgeçli hatıl + derz; blok tonu sarı değil, yumuşak kenar, blok ölçeğinde yama; dökülmüş taş oyuğu |
| `scripts/world/ist/sur_zemin.gd` | hendek yüzü yumuşak ton + akıntı; iki yüzün dibinde dökülmüş taş; dış yaka harpuştası düzensiz/eksik; kıyı kenarı yüzü izler + girintili; kıyı otu; çukur kenarı alçak/düzensiz |
| `scripts/world/ist/surlar.gd` | kesimde (bölüm seti dahil) dilimlere sur taşı gölgelendiricisi |
| `scripts/world/ist/sur_gorunus.gd` | zemin koyu lekesi yumuşak rampa |
| `scripts/world/ist/ordugah_yapi2.gd` | siper kazık perdesi tek tek sivri kazık (çarpışma aynı) |
| `scripts/world/ist/ordugah_kisi.gd` | uzak figür daha az üçgen (bütçe) |
| `tests/_ist/tur8_butce.gd/.tscn` (yeni) | görüş alanındaki geometrinin grup grup yüzey/gölge/üçgen dökümü |

Dokunulmayanlar: `sur_oyun*.gd`, `sur_set*.gd`, `sur_sozlesme*`, `scripts/chapter*.gd`, `scripts/level/`, `scripts/combat/`,
B'nin dosyaları. Yeni ışık yok. Replik/ses/denge/sayaç değişmedi.
