# Yerebatan 4 — son görsel tur (bölüm 44b) — rapor

Dal `wip/duzeltme4-yerebatan` (taban `wip/0.99.119`, `bf4695eb`). Godot 4.4.1 resmi linux x86_64, `xvfb-run` + `--rendering-driver opengl3`, 1280×720.
Ekran kartı yok (llvmpipe): kare hızı ölçülmedi, yalnız çizim çağrısı ve üçgen sayıldı.

**Kanıt yöntemi.** ÖNCE = başlangıç kodu, depo dışı kopya (`~/is/once`, `git archive HEAD`). SONRA = bu dalın son kodu.
İkisi de aynı ayarla ekranlı, gerçek hızlı koşuldu: `PACE=1 godot --path … --rendering-driver opengl3 -- --chapter=44b --autotest`,
`ffmpeg x11grab` 2 kare/sn. Kareler **aynı replik anından** alındı (günlükteki `PACE say … key=` zamanı + aynı ofset; bot iki koşuda
farklı yol tutabildiği için kadraj birebir aynı değil). Günlükler: `ekranli_kosu_gunlugu_ONCE.txt`, `…_SONRA.txt`.
Ayrıca sabit kameralı sonda kareleri (`tests/cistern_shots.tscn`, adında `sonda_`): oyuncu kamerası değil, yalnız Medusa yakınları ve bütçe için.
Tüm çiftler tek paftada: `pafta_once_sonra.jpg` (sol ÖNCE, sağ SONRA).

## Madde madde

| # | Madde | Durum | Kareler |
|---|---|---|---|
| 1 | **Medusa başları** | **TAMAM (okunurluk KISMEN)** | `m1_medusa_genis_Y_STONE_*`, `m1_medusa_oyuncu_T_MEDUSA_1_a/b_*` (oyuncunun gerçek kamerası, `D44B_T_MEDUSA_1` anı), `m1_sonda_medusa_side_*`, `m1_sonda_medusa_inv_*`, `m1_sonda_medusa_ikisi_kandil_*` |
| 2 | Düşen tuğla/taşlar | TAMAM | `m2_dusen_parca_Y_TORCH+5.5_*`, `m2_cokus_parcalari_N_uyari_*` |
| 3 | Ön plandaki sütunlar | TAMAM | `m3_inis_karanlik_T_DARK_*`, `m3_hayranlik_T_AWE_2_*`, `m3_kayik_ilk_kurek_T_BOAT_*` |
| 4 | Yanık/fosforlu yüzeyler | KISMEN | `m4_yakovos_medusa_Y_MEDUSA_*`, `m4_8_yakovos_ilk_Y_01_*` |
| 5 | Tırmanış borusu | TAMAM | `m5_tirmanis_boru_T_CLIMB-5_*` |
| 6 | Kiler ilk karesi | TAMAM | `m6_kiler_ilk_T_CLIMB-2_*` |
| 7 | Kuyu ağzı (avlu) | TAMAM | `m7_avlu_kuyu_T_01_*` |
| 8 | Kayık / Yakovos bacakları | Kayık TAMAM; bacak **ORTAK İSTEK** | `m4_8_yakovos_ilk_Y_01_*`, `m2_dusen_parca_*` |
| 9 | Avlu çıkışı dizilişi | TAMAM | `m9_avlu_cikis_E_BACK_*` |
| 10 | Dört metin | TAMAM | (metin; ses üretilmedi) |

### 1. Medusa (`scripts/level/cistern.gd`, `_medusa_*`)
- Küp blok + içine gömülü çerçeveli panel **kalktı**. Baş ve blok **tek ağ**: köşeleri yuvarlanmış (r 12 cm), kaba yontulu, üç köşesi kırık
  mermer blok (1,62 × 1,62 × 1,2 m); ön yüzü kabartmanın yükseklik alanıyla dışarı itilir (≈29 cm çıkıntı). Çerçeve, panel, ayrı malzeme yok.
- Yüz bloğun yüksekliğinin ~2/3'ünü doldurur: dolgun yanaklar, oyuk göz çukuru + ağır üst göz kapağı + bebeksiz iri göz, kalın kaş
  kemeri, geniş burun (kanatlı), kalın iki dudak ve ağız yarığı, çene.
- Yılan saçlar gerçek geometri: yüzün çevresinden dalgalanarak dışa uzanan 9 kalın yılan (7'sinin ucunda iri, sivri burunlu baş ve iki göz
  oyuğu), alnın çevresinde birbirine dolanan iki kıvrımlı yılan (evreleri ters, üst üste biner), kulak hizasında iki yılanın çaprazlandığı
  düğüm ve küçük kanat tüyleri, çenenin altında düğümlenen iki yılan.
- "side" yan yatık, "inv" baş aşağı (yükseklik alanı döndürülerek örneklenir).
- Oyuk kiri köşe renginde (çevresinden alçak yerler koyu): kandil ışığı yandan vurunca kabartma gölgeyle okunur. Alt kısımda çamur
  (dünya yüksekliğine göre), seyrek yosun, yanlarda ve arkada eski su çizgisinin lekesi (ön yüzde hafif: kabartmanın üstünden çatlak gibi
  geçiyordu, düzeltildi).
- Bloğun üstünde Attik sütun kaidesi (iki torus + oyuk), kaide düzgün oturur; altında çamura gömülü temel taşı (yuvarlatılmış).
- Ağlar statik önbellekte, iki baş için bir kez kurulur.

### 2. Düşen parçalar (`scripts/chapter44b.gd`, `_brick_fall`, `_chunk_mesh`)
- Tek yüzlü ince levha yerine 5 hacimli ağ (önbellekli): üç boy kırık tuğla parçası (7–12 cm kalın, iki köşesi düzlemle kesik, düz
  gölgeli; üst yüzünde yapışık harç kabuğu), yumru harç topağı, büyük düşüşte üç sıra tuğla + harç bantlı tonoz öbeği.
- Her parça kendi ekseninde çok tur dönerek düşer; yanında küçük harç kırıntıları yağar (tek parçacık düğümü).
- Suya çarpınca: halka (var olan), yumuşak sıçrama + yukarı ve yanlara saçılan damlalar.
- **Sert kenarlı parlak dikdörtgen kalktı:** kaynağı sıçrama kartının yalnız yatay degradeli dokusuydu (üst/alt kenar sertti); doku
  her yönde yumuşak (dairesel) yapıldı.
- Görsel çeşitlilik ayrı RNG ile (oyun akışının rastgeleliğine dokunmaz). İsabet, gölge uyarısı, süreler aynı.

### 3. Ön plandaki sütunlar
- **Alttaki bej bant:** kaynağı fener ya da yansıma değil, düşülen kuyunun su üstündeki toplamsal ışık lekesiydi (kamera lekenin içinde).
  Leke 1,2 m'den yakında söner, 4 m'den ötede tam (ayrıştırma: düğüm düğüm gizleyerek bulundu). Bant gitti (`m3_hayranlik`, `m3_kayik`).
- Düşüşün itişiyle oyuncu 1,4 m güneyde yüzeye çıkar: tonoz gözünün tam ortasında ön köşe sütunları geniş açının kenarında dev, bulanık
  levhalar gibiydi; şimdi 4,6 m ötede, gövde, damar ve su çizgisi okunur. Sıçrama halkaları da yeni yere kaydı.
- Her sütun suya net girer: suyun hemen üstünde koyu ıslak bant, yosun bandı (var olan), su çizgisinde ince koyu halka (336 örnek tek
  MultiMesh, tek çizim), yansımada temas çizgisi koyu; gövde suyun altına dibe kadar iner ve bulanık yeşile gömülerek kaybolur
  (sütun suyun içinden çıkar, "üstünde durmaz"). Yansıma kopyası ayrı ağ (aynada suyun üstüne taşmaz).
- Yakın sütunda mermer damarı (4–12 m arası belirgin, uzak sıralar sakin).

### 4. Yanık yüzeyler
- Mermer ve suya özel ışık işlevi: dağınık ışık **toplam üstünden** yumuşak doyuruluyor (`x/(1+x/K)`, birikmiş değer ters çevrilip
  yeniden sıkıştırılır): fener + meşale + kandil aynı yüzeyde toplanınca da düz beyaza varmaz. Suyun dağınık ışığı kısık, parıltısı keskin.
- `m4_yakovos_medusa`: Yakovos'un arkasındaki sütun hâlâ kadrajın en parlak yeri (açık krem), ama tam beyaz dikdörtgen ve yanık leke
  değil; **KISMEN**. İnce dikey çizgi artefaktı SONRA karelerinde görmedim; kaynağını kesin bulamadım (bkz. hâlâ kötü olanlar).

### 5. Tırmanış borusu
- Çıkış bacasının taş gölgelendiricisine dolgu: kilerin ışığı yanınca duvar yukarıdan aşağı solan sıcak bir ışıkla okunur; harç
  derzlerindeki normal kırılması yarıya indi (yalnız halka çizgileri parlıyordu). Tel kafes tünel görüntüsü gitti.

### 6. Kiler
- Dört düz taştan bilezik → yuvarlak (20 kenar), üst kenarı pahlı alçak taş halka; kapak yere indirildi.
- Hevenkler: tavan kirişine dolanan ip, ipin ucunda zikzak örgü sapı, sapın çevresine sarmal dizilmiş yuvarlak başlar (soğan iri ve
  kızıl, sarımsak küçük ve ak). "Şiş kebap" dizisi kalktı.
- Çıkış anında kamera dönerek kilerin içine (raflar, küpler, fıçı, açık kapı) açılır: ilk kare `k22` kadrajına yakın (`m6`).

### 7. Avlu kuyusu
- Düz siyah sekizgen disk yerine: 20 kenarlı, üst kenarı iki yandan pahlı bilezik; ağzın içinde örme taş iç duvar 3 m aşağı iner ve
  aşağı doğru kararır; ip makaradan kuyunun içine iner. Çarpışma ve etkileşim aynı.

### 8. Kayık
- Düz yüzeyli kama yerine bölümün kendi sandal ağı: iki ucu sivri, bordası kavisli (yuvarlak sintine), bindirme kaplama (sıra sıra ton),
  içte 7 eğri kaburga, küpeşte, üç oturak, iki yanda ıskarmoz (çift ahşap çivi), kıçta kova, pruvada ağ yığını; dipte elips su.
  Tek ağ (eskiden gövde + 3 oturak + su ayrı ayrıydı). Ölçüler, kürek yuvaları, oturak ve meşale yeri aynı.
- **ORTAK İSTEK:** Yakovos'un bacakları ortak kişi modelinden (`scripts/npc/person.gd`) geliyor; bu bölümde özel bacak kurulumu yok.
  Avludaki komşularda da aynı kesit görünüyor (`m9`). Ortak dosyaya dokunmadım: kişi modelinde bacak/pantolon kesitinin yuvarlak
  (çok kenarlı ya da kapsül) yapılması ortak istek olarak bırakıldı.

### 9. Avlu çıkışı
- Eudokia önde (3,0 m), Yakovos kuyunun bileziğine yaslı (yanında), bir komşu avlu kapısının eşiğinde (geride), öteki duvar dibinde yana
  dönük. Aralar, uzaklıklar ve yönler farklı. Dinleyenler konuşana döner (`_heed`); seçimden önce hepsi Tolga'ya bakar.

### 10. Metin (yalnız bu dört satır)
| Anahtar | Önce | Sonra |
|---|---|---|
| `D44B_T_DARK` EN | "…The way I came in is a coin-sized spot up there…" | "…The well mouth up there is no bigger than a dinner plate…" |
| `SPK_YAKOVOS` EN | The fishmonger | The fisherman |
| `D44B_Y_KEEP` EN | "…deep, and no echo." | "…deep, and it keeps its secrets." |
| `D44B_K_01` TR/EN | "Annemle burada kalıyoruz." / "Mum and I are staying here." | "Annemle Kyra Eudokia'nın evinde kalıyoruz." / "Mum and I are staying at Kyra Eudokia's house." |

`i18n/strings.csv` (LF) ve `docs/voice/VOICE_MAP.csv` (CRLF) bayt düzeyinde değiştirildi (satır sonu, tırnak korunur).
"The fishmonger" `docs/voice` altında Yakovos için geçmiyor (geçenler ayrı karakter `SPK_FISHMONGER`, dokunulmadı).
Yeniden üretilecekler: `docs/voice/REGEN_YEREBATAN4_TR.txt` (`D44B_K_01`), `REGEN_YEREBATAN4_EN.txt` (`D44B_T_DARK`, `D44B_Y_KEEP`, `D44B_K_01`).
Ses üretilmedi. `D44B_N_MEDUSA` ("1985") dokunulmadı.

## Testler (hepsi PASS; ham çıktı `test_ciktilari.txt`)
| Test | Son satır |
|---|---|
| `check_keys.py` | `anahtar: 6888 sorun: 0` |
| `check_speakers.py` | `SPEAKERCHECK PASS` |
| `check_voice_rules.py` | `VOICERULES PASS (9786 anahtar, 0 sorun)` |
| `check_inline.py` | `INLINECHECK PASS (725 anahtar, 0 sorun)` |
| `tests/parse_check.tscn` | `PARSECHECK PASS scripts=250` |
| `--chapter=44b --autotest` | `AUTOTEST PASS chapter=44 variant= outcome=44.1 light=phone battery=3.6 bumps=2 hits=0 rescued=false kid=false` |
| `=blab` | `AUTOTEST PASS … variant=blab outcome=44.2 …` |
| `=dark` | `AUTOTEST PASS … variant=dark outcome=44.1 light=remote battery=0.0 bumps=0 hits=0 rescued=true kid=false` |
| `=kid` | `AUTOTEST PASS … variant=kid outcome=44.1 … kid=true` |
| `=nophone` | `AUTOTEST PASS … variant=nophone outcome=44.1 light=remote battery=14.0 …` |
| `=hit` | `AUTOTEST PASS … variant=hit outcome=44.1 … hits=3` (ilk koşuda hits=2, ikisi de PASS) |
| Ekranlı, `PACE=1`, son kod | `AUTOTEST PASS chapter=44 variant= outcome=44.1 light=phone battery=4.1 bumps=1 hits=0` |
| Komşu 24 | `AUTOTEST PASS chapter=24 variant= outcome=24.1 …` |
| Komşu 25 | `AUTOTEST PASS chapter=25 variant= outcome=25.1 …` |
| Komşu 43o | `AUTOTEST PASS chapter=43 variant= outcome=43O.1 …` |

## Bütçe (sarnıç içi, sabit kamera, aynı 15 açı; `cistern_shots` her karede `RENDER_TOTAL_*_IN_FRAME`)
| Açı | çizim ÖNCE | çizim SONRA | üçgen ÖNCE | üçgen SONRA | Δ üçgen |
|---|---|---|---|---|---|
| awe_1 | 84 | 79 | 575 644 | 607 064 | +5,5% |
| awe_2 | 40 | 41 | 561 400 | 580 080 | +3,3% |
| awe_3 | 38 | 39 | 326 602 | 348 034 | +6,6% |
| dark | 84 | 80 | 575 644 | 607 208 | +5,5% |
| well_up | 5 | 5 | 191 180 | 191 180 | 0 |
| well_down | 17 | 18 | 559 462 | 578 142 | +3,3% |
| medusa_pair | 24 | 19 | 328 822 | 357 466 | +8,7% |
| medusa_side | 26 | 21 | 567 006 | 595 298 | +5,0% |
| medusa_inv | 27 | 22 | 567 294 | 595 586 | +5,0% |
| medusa_side_yakin | 18 | 16 | 514 374 | 538 036 | +4,6% |
| medusa_inv_yakin | 22 | 20 | 563 374 | 587 036 | +4,2% |
| medusa_ikisi_kandil | 25 | 19 | 328 966 | 357 466 | +8,7% |
| heneye | 34 | 29 | 332 618 | 364 038 | +9,4% |
| cellar | 31 | 32 | 563 900 | 585 332 | +3,8% |
| ladder | 13 | 13 | 283 090 | 294 538 | +4,0% |
| **TOPLAM** | **488** | **453 (−7,2%)** | **6 839 376** | **7 186 504** | **+5,1%** |

En kötü açı +9,4% üçgen (sınır +10%). Üçgen artışının çoğu suyun altına inen sütun gövdeleri (sütun başına 24 üçgen) ve Medusa
kabartması (baş başına ~8,4 bin). Çizim çağrısı azaldı (Medusa 3 → 2 düğüm/baş, kayık tek ağ). Düşen parça ve damlalar evre başına
geçici düğümler (eskiden de parça başına bir düğüm vardı; şimdi düşüş başına +2 parçacık düğümü). Süreler, sayaçlar, bot yolu aynı:
ekranlı koşu süresi ÖNCE 705,7 sn, SONRA 608,6 sn (fark bot yolundan; replik süreleri aynı).

## Kutu sayımı (SONRA karelerinde "kutu gibi duran")
- **Canlı/yüz/yuvarlak nesnede kutu: Medusa 0** (önce: 2 küp blok + 2 çerçeveli panel). Kayık 0 (önce kama). Hevenk/soğan 0 (önce çokyüzlü
  top dizisi). Kuyu ağzı 0 (önce düz sekizgen disk). Düşen parçalar: tuğla parçası doğası gereği köşeli prizma (kesik köşeli), harç topağı
  yumru — levha yok.
- Kalan, kutu ama canlı/yuvarlak olmayan: kiler rafları, oturaklar, demir basamaklar, kapı kanadı, çöküşteki tonoz kasnağı parçası
  (`m2_cokus_parcalari_N_uyari_SONRA`: uzun dikdörtgen blok — tonoz kemerinin taşı, bu turda değişmedi).
- Kalan, sayılması gereken: **kişi modeli bacakları** (Yakovos ve komşular: dikdörtgen kesitli, ORTAK İSTEK); Medusa köşesinde berrak suyun
  altında yansıyan başlıkların yastık taşları kare kutu gibi seçiliyor (`m1_sonda_medusa_side/inv_SONRA` sağ/sol altta). Toplam: 2 tür.

## Kendi karelerime bakınca hâlâ kötü olanlar (dürüst)
1. **Medusa yüzü "Medusa" diye tanınıyor ama tam ikna etmiyor:** kabartma ve yılan saçlar okunuyor, fakat yakın karede (`m1_medusa_oyuncu_*`)
   yüz su altında, fener önden vurduğu için düzleşiyor; yılanlar biraz "yumru/solucan" gibi, yılan başları ancak sonda yakınında seçiliyor.
   Göz kapakları ve dudak iyi, burun zayıf. Gerçek Yerebatan başlarının iri, yumuşak hatlı yüz ifadesi tam yakalanmadı.
2. **Yakovos'un yanındaki sütun** (`m4_yakovos_medusa_SONRA`) hâlâ kadrajın en parlak yüzeyi (krem-beyaz), yanık değil ama göz yoruyor.
3. **İnce dikey çizgi artefaktı** (denetim `k16`, `k08`): SONRA karelerimde görmedim, ama kaynağını bulmadım; kaybolması bot kadrajının
   değişmesinden de olabilir.
4. Yakın sütun damarı bazı açılardan mermerden çok ahşap damarına benziyor (`m3_hayranlik_SONRA` sağdaki sütun).
5. Avluda bir komşu (kapı eşiğindeki) bu kadrajda Eudokia'nın arkasında kalıyor (`m9_SONRA`); diziliş doğal ama dört kişiden üçü görünür.
6. Kişi modelinin bacakları (ORTAK İSTEK).
7. Karanlık anında (`m3_inis_karanlik_SONRA`) su yüzünde düşüş halkası ince beyaz bir eğri olarak kameraya yakın görünüyor.

## Değişen dosyalar
`scripts/level/cistern.gd` (Medusa, sütun gölgelendirici/ışık işlevi, su ışık işlevi, su çizgisi halkası, suya inen gövde, havuz lekesi
yakın sönümü, çıkış bacası dolgusu, kiler bileziği ve hevenkler), `scripts/chapter44b.gd` (düşen parçalar, damla/kırıntı, sıçrama dokusu,
düşüş noktası, tırmanış kamerası, avlu kuyusu, kayık, avlu dizilişi), `tests/cistern_shots.gd` (Medusa yakın açıları, `--only=` süzgeci),
`i18n/strings.csv`, `docs/voice/VOICE_MAP.csv`, `docs/voice/REGEN_YEREBATAN4_TR.txt`, `docs/voice/REGEN_YEREBATAN4_EN.txt`.
Ortak dosyalara (`hud.gd`, kişi modeli, ses) dokunulmadı.
