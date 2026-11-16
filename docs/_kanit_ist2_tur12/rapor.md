# TUR-12 — 37o havadaki taşlar, kumaş ve ip dalgalansın, harpuşta

Dal `wip/ist2-tur12`, taban `wip/ist2-taban12` **1e27302d**. ÖNCE = aynı taban (`git archive 1e27302d`, depo dışı kopya
`~/is/once`, aynı içe aktarma önbelleği), aynı makine, aynı kameralar. Kareler xvfb + Mesa llvmpipe (yazılımsal GL),
1280×720 jpg 85. Ekransız testler `--max-fps 20`, tam süzgeç (`testler/kos1.sh`).

Klasörler: `once/`, `sonra/` (bölüm `=kare` anları), `pafta_*.jpg` (sol ÖNCE | sağ SONRA, yarım boy), `kumas/` (sergi
kareleri, tam boy), `pafta_kumas/` (aynı kameradan 0,4 sn arayla 3 kare yan yana), `harpusta/`, `testler/`.

Yeni test sahneleri: `tests/_ist/tur12_kumas.tscn` (KUMAŞ sergisi: oyundaki bayrak kurucularının KENDİLERİ, sabit
kameralar, 0,4 sn arayla 3 kare; `--gece`), `tests/_ist/tur12_butce.tscn` (bölümü ana sahneden açar, doğuş kamerasından
4 yönde 12 karelik ortalama çizim/ilkel; ÖNCE ve SONRA aynı anda, aynı kamera — `poz` satırı eşit).

## Özet

| # | Madde | Durum | Kısa |
|---|---|---|---|
| 1 | 37o baş hizasında havada duran koyu taş yığınları | **TAMAM** | `surlar.gd _gedik`: oyun kesitinde (sade) tümsek + 34 kaya kurulmuyor (GedikOnarim'ın kendi rampası ve kırık taşları kesitin gerçek tabanında). Şehir kipi aynı. 37o an_04, 20 an_03/an_08, 0 an_05, 22, 36b ÖNCE\|SONRA |
| 2 | Kumaş ve ip dalgalansın (bayrak/sancak/flama/tuğ/tente/çamaşır/çadır) | **TAMAM** (çadır: yakın katman) | Yeni `assets/shaders/ist_kumas.gdshader` + `scripts/world/ist/kumas.gd`; 20 bayrak işlevi kutu bayraktan ince, çift yüzlü, direği sabit, rüzgâr altına dalgalanan kumaşa; tuğ, tente, çamaşır, yakın çadır kumaşı hafif nefes; gemi bayrakları gemi gölgelendiricisinde. Bütçe ±%2 |
| 3 | Harpuşta yakından düz levha | **TAMAM** (yakın kare) / c5 hendek kıyısı **YAPILMADI** | Harpuşta tepesi eşek sırtı; 0,95 m'den geniş dişte derzli 2–3 taş. Sözleşme aynı |
| — | Sözleşme | **AYNI** | `SURSOZLESME PASS kalem=13 kesim=8` · `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` · `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` |

---

## 1. Bölüm 37o: barikat karesinde havada duran koyu taş yığınları — **TAMAM**

**Kök neden** (taşıma 7 §1 teşhisi, doğrulandı): `IstSurlar._gedik` oyun diliminin gediğini `gedik_sade` ile kurarken de
şehirdeki moloz tümseğini (yarım elips koni, taban **y 0**, gedik ortası z ± 6,5) ve üstündeki 34 kayayı
(`@MultiMeshInstance3D`) kuruyordu. Oyun kesitinde dış kuşak 3,7 m aşağıda: tümseğin dış yarısı ve kayalar terasın ve
`GedikOnarim`'ın `Toprak_GedikMolozRampa`'sının 1–3 m üstünde, baş hizasında koyu çokgen.

**Düzeltme** (`scripts/world/ist/surlar.gd _gedik`): `sade` ise yalnız kırık beden (`GedikBeden`, aynı malzeme/lod) kurulur
ve `gedik_dunya` kaydı (lod ≤ 1) eskisi gibi yazılır; tümsek ve kaya saçılımı kurulmaz. Gediğin molozunu zaten
`sur_oyun_parca.GedikOnarim` kesitin gerçek tabanına oturtarak kuruyor (rampa + 40 kırık taş, `taban` işlevi peribolos /
sur / teras / hendek). `GedikOnarim`'a dokunulmadı. Şehir kipi (`gedik_sade` vermeyen kurucular: şehir, 43o uçuşu)
bit bit aynı: aynı satırlar, aynı rastgele dizi.

**Kareler** (sol ÖNCE | sağ SONRA; "havada taş var mı" tek cümle):
- 37o an_04 barikat (`once/c37o/an_04_barikat.jpg`, `sonra/c37o/an_04_barikat.jpg`): ÖNCE sırtın iki yanında baş
  hizasında üç koyu taş yığını; **SONRA havada taş yok** — fıçılar ve sırt aynı, yığınların yerinde gece göğü ve sur.
- 20 an_03 gediğe taşıma (`pafta_c20_an03.jpg`): **havada taş yok**; ÖNCE'de taşıyıcıların arkasındaki koyu taş öbeği gitti, gerisi aynı.
- 20 an_08 çit, şehir tarafından (`pafta_c20_an08.jpg`): **havada taş yok**; ÖNCE'de sol duvar dibindeki gri tümsek
  (şehir molozu) gitti, çit, fıçılar, kalaslar aynı.
- 0 an_05 gün (`pafta_c0_an05.jpg`): **havada taş yok**; ÖNCE'de ön planda duran iri koyu kayalar (tümseğin kayaları)
  gitti, yerde döşeme ve GedikOnarim'ın barikatı görünüyor.
- 22 an_03 / an_05 (`pafta_c22_an_03.jpg`, `pafta_c22_an_05.jpg`): **havada taş yok**; gedik bu anlarda kadrajda değil, kareler aynı.
- 36b an_02 köprü / an_03 siper (`pafta_c36b_an_02.jpg`, `pafta_c36b_an_03.jpg`): **havada taş yok**; gedik kadrajda
  değil, kareler aynı. (22 ve 36b `=kare` koşuları dört süreç yük altında 590 sn'de kesildi: 22'de 5, 36b'de 3 an.)

## 2. Kumaş ve ip dalgalansın — **TAMAM** (çadır gövdesi yalnız yakın katmanda)

### 2.1 Yaklaşım (fizik gövdesi YOK; yalnız köşe gölgelendiricisi)
- `assets/shaders/ist_kumas.gdshader` (tek gölgelendirici, iki paylaşılan malzeme: köşe rengi sRGB / doğrusal):
  - **kip 1 bayrak**: köşede direkten uzaklık (UV.x, m) ve direk ekseni (UV2 ya da düğüm kökeni). Bayrak gölgelendiricide
    DÜNYA rüzgâr yönüne (`ruzgar` = (0,62; 0; 0,78), bütün malzemelerde aynı) yeniden kurulur: **direk kenarı (UV.x = 0)
    yerinde**, serbest uç rüzgâr altında 0,16–0,34 rad sarkık, iki dalgalı (2,6 ve 4,7 rad/m), genlik direkten uca büyür
    (1,6 m'de doyar), dalga boyunca kumaş kısalır (gerilmez). Normal türevle yeniden hesaplanır (ışık doğru).
    → **Aynı sahnedeki bütün bayraklar, kurucu hangi yöne kurmuş olursa olsun, aynı yöne uçar.** Duvara yakın bayrak
    (`yerel`) kurulduğu yöne uçar (Bölüm 39o kapı sancakları duvarın içine dönmesin).
  - **kip 2 sarkık kumaş** (tente, çamaşır, tuğ püskülü, yakın çadır): ağırlık (0 bağlı … 1 serbest) × normal boyunca
    3,5 cm nefes + rüzgâr yönünde 5 cm salınım (dünya metresinde; örnek ölçeği büyütmez).
  - **kip 0 sabit**: aynı ağdaki direk, alem, ip, kazık **kıpırdamaz**.
  - **LOD**: kamera 55 m'den uzaklaştıkça dalga söner, 110 m'de durur (bayrak rüzgâr altında sabit kalır).
  - Gece/gündüz aynı (ışık sahnenin); `gorsel_dil` kategorisi `kumas` (TEK GÖRSEL DİL son işlemi eklenir; renk tavanı, dokuma
    ayrıntısı, gece ay ışığı aynı kural). Parça gölgelendiricisinde Osmanlı hilali (keskin; ızgara bloğu değil).
- `scripts/world/ist/kumas.gd`: ince, **tek yüzlü-çift taraflı (cull kapalı) ızgara bayrak** (kutu kalınlığı yok); desen
  taban renk + dikdörtgen yamalar (ızgara yama kenarlarından geçer: üst üste ikinci yüz, z-kavgası yok), çatallı
  (kırlangıç kuyruğu) uç, hilal; sarkık levha (tente); önbellekli ağ; sınır kutusu direk çevresinde L yarıçaplı.
- Ordugâh birleşik ağı (`IstOrdugahKit.Bld`): `bayrak()` / `sarkik()`; kumaş eklenen ağ `done()`'da kumaş malzemesiyle
  kurulur (öbür köşeler kip 0). Uzak katmanda (lod > 0) bayrak **sabit ince çift yüz** (dalga zaten sönük).
- Gemiler (`gemiler_mesh`, tek MeshKit ağı, kendi `SALINIM` gölgelendiricisi): bayrak/flama köşelerine direkten uzaklık
  oranı köşe rengi alfasına yazılır (`_kumas_isaret`), `SALINIM` bu köşeleri dalgalandırır (direk kenarı sabit; uzakta
  söner). Gemi bayrağı kıça akar: demirli gemi rüzgâra pruva verir, bayrağı rüzgâr altına uçar.

### 2.2 Dokunulan bayrak işlevleri (yalnız bunlar; ✔ = kumaşa geçti)
| dosya / işlev | eski | yeni |
|---|---|---|
| `surlar_ayrinti.gd _flag` | 3 cm kutu + kutu yama | ✔ ince bayrak 1,65×1,0, yama kumaşta |
| `ordugah_yapi.gd sancak` (otağ, külliye, usta çadırı, donanma, `ordugah_yapi2.build_sancaklar`) | 3 cm kutu + kutu yama; tuğ sabit silindir | ✔ ince sancak 0,9×1,2 + krem yama; tuğ püskülü sarkık (nefes) |
| `ordugah_oba.gd _sancak` (oba, `ordugah_yerleske` tuğları, otağ tuğları) | iki poligon dil + 3,5 cm kutu hat | ✔ çatallı flama (yakında dalgalı, uzakta sabit ince); hat kumaşın yaması; tuğ sarkık |
| `ordugah_oba.gd _camasir` | sabit iki yüz bez | ✔ ipteki kenar sabit, bez nefes |
| `ordugah_kanat.gd` sancakları | 3 cm kutu + kutu yama | ✔ ince bayrak (uzakta sabit) |
| `galata_ortak.gd flag` | üç üst üste kutu (haç) | ✔ ince bayrak, haç kumaşın yaması |
| `halic_mahalle.gd _banner`, `halic_sur.gd _banner` | 4–6 cm kutular | ✔ ince sancak, yama/haç kumaşta |
| `gemiler_mesh.gd _bayrak`, `_flama` (+ `SALINIM`'a bayrak köşesi dalı) | sabit ızgara (6 cm sabit dalga) | ✔ dalgalanır (yakında ≥ 6 dilim) |
| `ayrinti_b.gd build_sancak_diregi` (`ayrinti_api` yalnız çağırır) | 2 cm kutu + kutu yama | ✔ ince bayrak |
| `ayrinti_a.gd build_tente` (grep ile bulundu) | 4 cm kutu levha + kutu şeritler + kutu saçak | ✔ ortası sarkık çizgili bez + dişli saçak, köşeler (direkler) sabit, nefes |
| `scripts/level/dressing.gd banner_pole` (+ yeni `kumas()`; `build()`'e "kumas" düğüm türü), `_c_banner_hay` (banner_pole'u çağırır) | birleşik parçaya pişen 3 cm kutu + kutu şerit | ✔ ayrı kumaş düğümü |
| `scripts/level/assault.gd _sancak` | 3 kutu (gövde + iki kuyruk dili) + 4 ince silindir disk (hilal) | ✔ tek kumaş: çatal kuyruk, hilal kumaşta |
| `scripts/level/assault.gd _tug` | 5 sabit silindir | ✔ tek sarkık ağ (bağ yeri sabit, uçlar salınır) |
| `scripts/level/training_yard.gd _banner` | 2 cm kutular | ✔ ince bayrak, şerit/haç yama |
| `scripts/level/siege_field.gd formation` (yalnız bayrak satırı) | 3 cm kutu | ✔ `Dressing.kumas` |
| `scripts/level/sea_battle.gd war_galley` (yalnız bayrak satırları) | 4 cm kutu + ayrı hilal | ✔ ince sancak, hilal kumaşta |
| `scripts/level/city_panorama.gd _ship` (yalnız bayrak satırı) | direksiz, güvertenin 1,3 m üstünde asılı 5 cm kutu (**havada**) | ✔ kendi kıç direğinde ince bayrak |
| `scripts/chapter39o.gd _plant_flag` (`_flags`'ın diktiği; yalnız görünüş) | döndürülen (tween) 3 cm kutu | ✔ ince kumaş, eğik direğin ucunda, sokağa uçar |
| `ordugah_cadir.gd` yakın çadır ağı (`_grid` kumaş aralıkları, `_nefesli_ag`, `ekle`) + `ordugah_kit.mm` | sabit | ✔ yakın (lod 0) çadır kumaşı nefes; ip/direk/kazık/iç eşya sabit |
| `hayat_veri.gd sancak` (şehir/hub MultiMesh sancakları) | `ist_bez` zaten dalgalanıyordu | değişmedi |

Kayıt dışı kalan (bilerek): `chapter39o._refresh_bundle` (kol altındaki SARILI sancaklar: kumaş direğe sarılı, dalga yok);
gemi yelkenleri (hafif şişme) **yapılmadı** (gemi gövde ağıyla aynı yüzeyde; ayrı iş).

### 2.3 Dalga kanıtı (`pafta_kumas/<istasyon>_<gun|gece>.jpg`: aynı kameradan 0,4 sn arayla 3 kare)
Sergi sahnesi oyunun KENDİ kurucularını çağırır (aynı işlev, aynı ölçü). Her pafta için tek cümle:
- **ordugah_sancak** (`ordugah_yapi2.build_sancaklar` → `ordugah_yapi.sancak`): dalgalanıyor (uç kenar karede karede
  yer değiştiriyor), kutu değil (yandan bakan sancak çizgi kadar ince), direğe bağlı.
- **otag_tug** (`ordugah_oba._sancak` tuğ + çatallı flama): flamalar dalgalanıyor, kuyruk çatalı kumaşın ucu; tuğ püskülü
  hafif salınıyor; kutu yok; direğe bağlı.
- **sur_bayrak** (`surlar_ayrinti._flag`, kule tepesi): dalgalanıyor; ince; direkten kopuk değil; gölgesi de dalgalı.
- **galata_bayrak** (`galata_ortak.flag`): dalgalanıyor, haç kumaşla birlikte kıvrılıyor; kutu değil; direğe bağlı.
- **gemi_kadirga / gemi_karaka** (`gemiler_mesh._bayrak/_flama`): dalgalanıyor (kıça akıyor), direk kenarı sabit; ince.
- **sehir_sancak** (`halic_mahalle._banner` ×2, `halic_sur._banner`, `dressing.banner_pole`): dördü de aynı yöne
  uçuyor ve dalgalanıyor; yama/haç kumaşta; kutu yok; direğe bağlı.
- **hucum_sancak** (`assault._sancak` çağrısı): çatal kuyruklu, hilalli sancak dalgalanıyor; hilal keskin; kutu yok.
- **c39o_sancak** (`chapter39o._plant_flag` kumaşı): eğik direğin ucunda, sokağa doğru dalgalanıyor; duvara girmiyor.
- **camasir** (`ordugah_oba._camasir`): bezler ipte asılı, alt uçları hafifçe nefes alıyor; ip kıpırdamıyor.
- **cadir_tente** (yakın çadır MultiMesh + `ordugah_cadir.ekle` paşa çadırı + `ayrinti_a.build_tente`): çadır kumaşı ve
  tente çok hafif nefes (kareler arası fark birkaç piksel); tente ortası sarkık, çizgili, ince; direkler kıpırdamıyor.
- Gece (`*_gece.jpg`): aynı dalga, aynı yön; ışık sahnenin. Gündüz sergisinin göğü/zemini sergi ortamının pozlama
  kusuru (oyunda değil); bayraklar ve renkleri doğru.

### 2.4 Bütçe (ÖNCE | SONRA aynı kamera; `testler/butce/*.txt`, tablo `testler/butce_tablo.py`)
Doğuş kamerasından 4 yön (yaw 0/90/180/270), duraklatılmış oyunda 12 karelik ortalama. Dört süreç yük altında bazı
koşular 400 sn sınırında kesildi (eksik yönler tabloda yok).



(6, 26, 43o son kodla; 20, 30o, 39o harpuşta ve genlik çarpanından önceki ara kodla ölçüldü — harpuşta diş başına +2 üçgen.) En kötü yön: 26/3 çizim +%3,0, ilkel +%0,8 (≤ +%5).

Kare betik süresi: kumaşın kare başına GDScript işi **yok** (dalga gölgelendiricide; 39o'daki bayrak tween'i kalktı);
yalnız kurulumda ızgara üretimi (önbellekli ağ). `T12SURE` satırları ölçüm anında bölümün yüklenmesine denk geldiği için
(1–3 kare/4 sn, llvmpipe) karşılaştırmaya elverişli değil; ekransız ölçüm (`--headless --max-fps 20`, oyun 90. sn'ye dek akar, son 30 sn = 600 kare; ÖNCE ve SONRA aynı anda; `testler/butce/sure_*.ham`):

| bölüm | betik ms/kare ÖNCE → SONRA |
|---|---|
| 6 (ordugâh) | 15,18 → 14,40 (−%5) |
| 26 | 48,93 → 49,56 (+%1,3) |

Fark ölçüm gürültüsü içinde (kumaşın kare başına betik işi yok).

## 3. Yetişirse — harpuşta **TAMAM (yakın kare)**, c5 hendek dış kıyısı **YAPILMADI**
- `sur_kule.gd _dis_tas` → yeni `_harpusta`: tepe **eşek sırtı** (diş boyunca sırt, iki yana 4,5–7 cm eğim, uçları kırma;
  sırt dışa hafif kaçık, uçtan uca 1–2 cm oynak) — eski 1,5–3,5 cm'lik basık kubbe yakından düz levha okunuyordu.
  **0,95 m'den geniş dişte harpuşta derzli 2–3 taş** (her taş kendi oynaklığı, derz 6–10 mm, iç uçlarda taşma yok,
  köşe kırığı tek taşta). Diş gövdesi, ölçü, çarpışma (korkuluk kutusu) aynı; üçgen: diş başına +2 (sırt), geniş dişte
  taş başına 36.
- Kareler `pafta_harpusta_*.jpg` (tur11_kare y1, a1, y5; gün ve gece): y1 (0,6 m) — **ÖNCE tek uzun düz levha, SONRA
  ortasında derzi olan iki ayrı, pahlı, sırtlı taş**; a1 (Bölüm 25 an_01 benzeri, gece) — levha yerine iki eğimli taş, siluette
  sırt okunuyor; y5 (sur yolu boyunca) — dişlerin tepesi sırtlı, aynı ritim, kutu yok.
- c5 hendek dış kıyısı düz kenar: bu turda yapılmadı (zaman).

## Sözleşme (her kayıttan önce; son kod)
Son kod (harpuşta dahil; `testler/soz/sozlesme`, `testler/soz2/denetim`, `testler/soz2/yuru`):
- `SURSOZLESME PASS kalem=13 kesim=8`
- `SUROYUN nokta=519 havada=0 gomuk=0 katida=0`
- `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0`

## Bölüm testleri (×1, `--max-fps 20`, tam süzgeç; `testler/b/`, `testler/b2/`)
Varsayılan ×1, hepsi **PASS**, `SCRIPT ERROR`/`VISAUDIT`/`WALKTHRU`/`HELDAUDIT`/`ARMAUDIT`/`WARN_*` satırı **0**:
- Küme 1 (`b/`, kumaş bayrakları sonrası): 0, 10, 20, 26, 30o, 37o, 39o, 43o, 17, 19, 28o, 6 (ordugâh).
- Küme 2 (`b2/`, harpuşta + çadır nefesi sonrası): 25, 20, 37o, 0, 41o (talim meydanı), 29 (deniz savaşı), 17o ve 8y
  (siege_field / dressing), 6, 43o, 39o, 26, 22, 38o.
- Son genlik çarpanı değişikliğinden sonra (yalnız gölgelendirici ve UV2 değeri) bölüm 6 ve 43o bütçe koşularında `SCRIPT ERROR` 0;
  tam paket yöneticide.

## Hâlâ kötü olanlar
- Gemi yelkenleri ve çadır gövdeleri ORTA/UZAK katmanda kıpırdamaz (yalnız yakın çadır nefes alır; uzak hücre ağı pişmiş).
- Pelerin/kaftan (giysi) bu turun dışında (`scripts/npc/` başka oturumda).
- Rüzgâr yönü gölgelendiricide sabit bir dünya yönü (sahneye göre değişmez; bütün bölümlerde aynı yön).
- Harpuşta: 0,6 m'lik dar dişlerde tek taş (doğru) ama uzaktan (> 20 m) sırt seçilmiyor; c5 hendek dış kıyısı hâlâ düz kenar.
- Sergi sahnesinin gündüz ortamı aşırı pozlu (yalnız test sahnesi).
- Bütçe ölçümü doğuş kamerasından; sancak ormanının ortasından ayrı bir kamera ölçülmedi (sergide istasyon başına çizim
  çağrısı `kumas/*.log`).
