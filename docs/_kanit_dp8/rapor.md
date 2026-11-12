# dP8 — P8 düzeltme turu (bağımsız denetçinin ZORUNLU listesi)

Dal `wip/yardimci-p8`. ÖNCE = `10c615b0` (denetlenen kayıt), taban = `1e3a9b60` (P8'in başlangıcı).
Denetçi hükmü "KÜÇÜK DÜZELTMELERLE KABUL" (`origin/wip/denetim-p8:docs/_kanit_denetim_p8/rapor.md`); numaralı listenin hepsi bu turda ele alındı.

**Değişen oyun dosyaları:** `scripts/chapter31o.gd`, `chapter39o.gd`, `chapter23.gd`, `chapter24.gd` (hepsi P8'in izin verdiği dosyalar).
Bunun dışında yalnız belge dosyaları: `docs/_kanit_p8/rapor.md` (denetçinin 5. maddesi) ve bu klasör.
Ortak dosyaya dokunulmadı; yeni `class_name` yok; replik metni/sırası, süre, sayaç, kalabalık sayısı, denge, gizli süre değişmedi;
denetim susturulmadı (`no_audit`, `_ok` meta, filtre eklenmedi). Sonda/kanca depoda yok: `grep -rn "P8SONDA\|P8CAM\|P8MOVE\|P8DBG\|_p8" scripts/` boş.
Bütün sondalar depo dışı kopyalarda çalıştı (`~/w/…`), depoya girmedi.

## Yöntem (kısa)
- Godot 4.4.1, `xvfb` + yazılım çizici (llvmpipe). Ekranlı koşu: `--autotest --dialogshots=… --shotevery=1 --snapevery=0.5 --hitchaudit`.
- ÖNCE/SONRA **oyuncunun kendi kamerası** (31o ip/kiriş/kazı, 39o, 23, 24): aynı bölüm koşusunun aynı anı. ÖNCE: ip/kiriş/kazı/kart/birikinti için `10c615b0`;
  taşıyıcı, cemaat, bayrak, rulo, kepçe için tabandaki `1e3a9b60` (o maddelerde ÖNCE P8 öncesidir).
- **Gözlem kamerası kareleri** (oyuncu kamerası DEĞİL; pafta başlığında yazıyor): 24 taşıyıcılar, 25 cemaat, 10h elçi, 12b rulo, 31o Kadri, 39o sokak, 24 birikinti yakın kırpması.
  Koşu aynı, repliğe bağlı geçici bir `Camera3D` 3 kare almış.
- Performans: **olay-hizalı sonda** (aynı kod noktasında, ilk iki kare atılıp kare başına okunan `RenderingServer` çizim çağrısı / üçgen; `vis` ana geçiş, `sh` gölge).
  Denetçinin 2 sn'lik RINFO eşlemesi sahne geçişlerinde anlamsızlaştığı için (aşağıda gösterildi) ikincil tutuldu. Ham: `ham_olcum.txt`.
  **Önemli bulgu:** `gl_compatibility`'de her ışık, etkilediği her ağa ek çizim getiriyor; bu yüzden aynı sahnede bakış/konum değişince çizim sayısı %20-50 oynuyor,
  ve ışıklı sahnede tek bir ek ağ ~7-8 çizim ediyor. Sol elin ~20 ağı bu yüzden 150'ye yakın çizim demekti (aşağıda Z3).

---

## ZORUNLU listesi

### Z1 — ip ucu elin gerçek konumundan (31o ve 39o) → 31o **DÜZELDİ**, 39o **KISMEN**
- **Ne yapıldı.** `chapter31o.gd:276` `_rope_between` artık gövdeden değil `_hands_tip()`'ten (`:294`) başlıyor: sağ elin (`player.rig`) ve sol elin (`player.free_rig`)
  avuç içi düğümlerinin (`HandRig.palm`) dünya konumu, yumruğun ortası `(0,-0.01,-0.07)` için ortalanıyor; eller yoksa `hold_both` noktalarının kamera ortası.
  Eller `hold_both(Vector3(-0.07,-0.3,-0.46), …)` noktalarında (`:747`, `_two_hands` üzerinden). 39o'da aynı ölçüt: `chapter39o.gd:876` `_hands_point()`; `_rope_top` bu noktadan başlıyor (`:967`).
  12 m'yi aşan parça yine ağ kurdurmuyor (hızlandırılmış koşuda kamera salınımı belleği doldurmasın).
- **Kanıt.** `01_31o_ip_eller.jpg` (iki çift, oyuncu kamerası, kamera pencereden sokağa doğru aşağı bakarken): ÖNCE `f_prev_31o/t0060,t0062`'de ip eşikte bitiyor ve eller
  ayrı, aralarında boşluk; SONRA `f6_fin2_31o/t0060,t0062`'de ip çocuktan eşiğe, eşikten iki yumruğun arasına kesintisiz iniyor, parmaklar ipin ucunu kavrıyor.
  Kalan kusur: ipin son halkası koyu şeritli, yumruğun ~2 cm üstüne taşıyor ("bağ ucu" gibi okunuyor); ip ile el arasında boşluk yok.
- **39o:** oyuncu kamerasında duman ekranı (HUD) ipi örtüyor, yalnız iki yumruk görünüyor (kare: `f5_fin2_39o`, "Adamı iple indir"). Bu yüzden ip-el birleşimi karede
  KANITLANAMADI. Sayısal: ip ucu `unproject_position` ile ekranda **(645, 616)** / 1280×720 (iki yumruğun yeri: alt orta). Sokak tarafı karede doğrulandı: `04_39o_sokak_ip.jpg`.
- Test: 31o 4 varyant ×2 PASS, 39o 6 varyant ×2 PASS (aşağıda).

### Z2 — 39o üçgen bütçesi (≤ +%8) → **KANITLANDI (ihlal yok)**, geometri yine de küçültüldü
- **Ne yapıldı.** `chapter39o.gd:734` `_start_rope`: artan ip ayrı ağ değil, kılavuz ipin (`_rope_low`) devamı: adamın göğsü → tayfanın elleri → kangalın üstü
  tek ağ (`_rope_between` `via`+`sag_a`, `:759`, `:968`); kangal 3,5 turdan 2,5 tura (`:752`). Eski ek ip ağı yok: 1 ağ/çizim az.
- **Ölçüm.** İpin üçgenleri sondayla sayıldı: `rope_top=1140–1296, rope_low=648, kangal=492` → toplam ≈ **2,3 bin üçgen** (sahnenin ~%0,1'i). Olay-hizalı (ip evresi, tayfa+adam+eller):
  çizim taban **346** → SONRA **338 / 337** (−%2,3), üçgen 36k → 30-31k.
- **Denetçinin +%12'si neden gürültü:** `ham_olcum.txt` sonunda aynı kodun (taban `1e3a9b60`) iki ekranlı koşusu yan yana: ÖNCE#1 → ÖNCE#2'de de üçgen **+%12,2** çıkıyor
  (t=42: 1838k ↔ 1069k, yangın sahnesine geçiş anı); ÖNCE→SONRA'da medyan çizim −%0,6…+%0,3, üçgen +%0,0…+0,3. t=40-46 aralığı sahne geçişidir, evre eşlemesi yapılamaz.
- Durum: bütçe aşımı yok; **KANITLANDI**, ayrıca kod küçültüldü.

### Z3 — 31o iki elli anlarda çizim artmasın → kazı/kiriş **DÜZELDİ**, ip **KISMEN**
- **Kök neden.** Sol el (`player.free_hand`) avuç, 4×2 parmak boğumu, başparmak, kolluk olarak ~22 ayrı ağ; ışıklı sahnede (omni ışıklar) bunlar ~150 çizim ediyor.
  Önceki turdaki "+8…+87" buradan geliyordu.
- **Ne yapıldı.** `chapter31o.gd:312` `_two_hands` / `:324` `_free_hands` / `:330` `_bake_free_hand` (39o'da `:786/:798/:804` aynı): `hold_both`'tan 2 kare sonra sol elin bütün ağları
  yumruk pozunda (curl −85) köşe renkli **tek ağa pişirilir**, asıllar gizlenir; bırakınca geri gelir. Sol el aynalı (scale −1) olduğundan üçgen sırası ters çevrilir (yoksa arka yüz atılıp
  yumruk kayboluyordu; bu hata ara sürümde karede yakalanıp düzeltildi). Üç anın hepsi (`_hands_under_beam`, ip, `_shovel_tick`) ve 39o ipi bunu kullanıyor.
- **Ölçüm (çizim, olay-hizalı, taban ↔ SONRA).**

  | Evre | Taban `1e3a9b60` | ÖNCE `10c615b0` | SONRA (son kod) | Hüküm |
  |---|---|---|---|---|
  | kazı | 613 / 609 / 609 | — | 606 / 607 / 608 | −%0,5 ✔ |
  | kazı (kök anı) | 702 / 703 / 699 | — | 700 / 704 / 700 | ±0 ✔ |
  | kiriş (0/3-2/3) | 885-894 ve 1007-1079 | 1038-1104 | 813-828 | −%7…−25 ✔ |
  | ip (indirme) | 3599 / 3478 / 3486 | 3562 | 3624 / 3554 / 3542 / 3598 | ort. **+%1,7** (taban koşuları arası yayılım %3,5) |

  İp evresinde ortalama +%1,7: ölçülebilir ama taban koşuları arasındaki yayılımın içinde; "artmadı" diyemem → **KISMEN**. Kalan fark ipin kendi ağı + pişmiş el ağı (ışıklı sahnede ~8'er çizim).
- Not: pişirme ikinci karede olduğu için yumruk kapanışı eskisi gibi ~0,2 sn'de değil anında olur (kare atlaması gibi okunmuyor, eller zaten aşağıdan geliyor).

### Z4 — kiriş: iki el kirişin altında, kadrajın ortasına yakın → **DÜZELDİ**
- **Ne yapıldı.** `chapter31o.gd:412` `_hands_under_beam` + `:438` `_beam_stoop`: `hold_both` kolu kameradan 0,75 m ile sınırlıyor; eller kadraja ancak Tolga **çömelip** kirişe yaklaşırsa girer.
  Tolga kirişin kendine bakan yüzünün 0,3 m yanına iner (`BEAM_DIST`), göz 0,55 m (`BEAM_EYE`), bakış 40° aşağı (`BEAM_PITCH`); bilekler yüzün 10 cm önünde, yüzün alt kenarında,
  eksen boyunca ±0,26 m. Bilek yüzün üstüne konunca yumruk kirişin içinde kalıp bazı karelerde görünmüyordu: ara sürümde karede görüldü, 10 cm öne alındı.
  Eller kirişle birlikte kalkar; göz her kaldırışta ~0,27 m yükselir; bitince/süre dolunca göz ve bakış (−8°) eski hâle döner (`:695`, `:793`).
  Otomatik testin botu kaldırma başlarken oyuncuyu eski yerine ışınlıyor; `_beam_stoop` her karede yeniden kirişin yanına koyar (donuk oyuncu, gerçek oyunda etkisiz).
- **Kanıt.** `02_31o_kiris.jpg`: ÖNCE `f_prev_31o/t0044,t0047` (eller alt köşede, tek bilek) | SONRA `f6_fin2_31o/t0044,t0046` (iki yumruk kadrajın alt-orta bölümünde kirişin alt kenarında).
  **Kalan:** 2/3'te kiriş kadrajın üstüne çıkıyor, eller ortada, kiriş görünmüyor (kiriş 0,6 m kalkarken göz 0,54 m kalkıyor, el kutusu üstten kırpıyor).

### Z5 — `docs/_kanit_p8/rapor.md` düzeltmeleri → **YAPILDI**
- Madde 7 ("−80 çizim"): **GERİ ÇEKİLDİ** (denetimde yeniden üretilemedi); madde 16 ("eller ipte"): **YANLIŞ** diye işaretlendi (Z1);
  madde 10: DÜZELDİ → **KISMEN**; madde 3: DÜZELDİ → **KISMEN** (halka karede seçilmedi). Raporun başına denetim notu eklendi.

---

## Denetçinin "yeni kusur" ve "kanıtsız" maddeleri

| Denetçi maddesi | Sonuç | Kanıt / not |
|---|---|---|
| Yeni 1: 31o ip elde bitmiyor | **DÜZELDİ** | Z1, pafta 01 |
| Yeni 2: 31o iki elli anlarda çizim artışı | kazı/kiriş **DÜZELDİ**, ip **KISMEN** | Z3 |
| Yeni 3: 39o üçgen bütçesi | **KANITLANDI (ihlal yok)** | Z2 |
| Yeni 4/Madde 2: 24 sel evresindeki pastel disk | **KISMEN** | `chapter24.gd:329` `_puddle_mesh`: 5 halkalı geçiş (ortası açık, 0,74'te koyulaşan ıslak halka, kenarı saydam). Pafta 06 (yakın kırpma): fark küçük, hâlâ mavimsi oval. |
| Madde 3: 24 yağmur halkaları | **KANITSIZ** (karede seçilemedi) | `:350` `_rain_rings` halkaları oyuncunun önündeki birikintilere açıyor; kamerayla görüşteki halka oranı (başsız, küçük örnek) %10 → %18. Karede halka seçemedim. |
| Madde 1: 24 taşıyıcı elleri | **DOĞRULANDI** (öndeki iki taşıyıcı) | Pafta 05 (gözlem kamerası): ÖNCE kollar sarkık | SONRA sağ el sırığı kavrıyor. Arka sağ taşıyıcı (konuşan keşiş) bu karelerde sırığın arkasında: **KANITSIZ**. |
| Madde 4/5: ıslak kaldırım, D24_M_STOP | DURUYOR (ortak dosya `byz_city.gd`; bu turda dokunulmadı) | — |
| Madde 6: 25 cemaat | diz çökme + elde mum **DOĞRULANDI**; haç/baş sallama **KANITSIZ** | Pafta 07 (gözlem kamerası, aynı kişiler): ÖNCE ayakta, kollar yanda | SONRA diz çökmüş, eller göğüs önünde kavuşuk; ÖNCE eller boş | SONRA elde yanan mum. |
| Madde 7: 25 "−80 çizim" | **GERİ ÇEKİLDİ** | Z5 |
| Madde 8: 23 kartvizit | tutuş DOĞRULANDI (denetçi); **kart yazısı kaldırıldı**; geçiş anı **BAKILMADI** | `chapter23.gd:405-413`: `strings.csv` dışı sabit yazılar (TOLGA / Sigorta… / Tel…) yerine üç şerit; pafta 08. Geçiş anı: `PACE=1` ile `ismail`'e bakan 3 kareli sonda aldım, kart kadrajda seçilmedi. |
| Madde 9/11: 23 muhafız/erkân, 10h maiyet, 12b nöbetçi kıpırtısı | **KANITSIZ** | Karede (3 kare, 2,5 sn arayla) ayrık jest ile bekleme sallanması ayrışmıyor. Ayrıca 12 Person + 6 muhafızlık sınama sahnesinde `Crowd.idle_vary`'li ve **idle_vary'siz** kontrol grubunun ikisi de eşik 0,04 ve 0,15 rad'da 18/18 kişi "hareket etti": Person zaten sürekli sallanıyor, ölçüt ayrıştırmıyor (`ham_olcum.txt`). Kod yolu ve testler var, kanıt yok. |
| Madde 10: 10h bayrak sırığı | **DOĞRULANDI** (yakın plan, gözlem kamerası) | Pafta 09: ÖNCE sırık elçinin yanında duruyor, el boş | SONRA sağ el sırığı kavrıyor. |
| Madde 12: 12b rulo | **DOĞRULANDI (zayıf)** | Pafta 10: rulo avucun içinde, eğik; ÖNCE belde yatık. |
| Madde 13: 31o kiriş | Z4 | Pafta 02 |
| Madde 14: 31o kazı, kürek ağzı çukura inmiyor | **DÜZELDİ** | `chapter31o.gd:1017` `_shovel_place`: ağız çukurun ortasına doğru %75'te zemine (itmede toprağın içine) iner; sap başı ağızdan 1,06 m geride (`Items "shovel"` ağzı 0,98-1,11 m). `:891` çukura ikinci, koyu iç disk (derinlik; düz diskti). Pafta 03 (oyuncu kamerası): ÖNCE ağız kıyıda, oyuncunun önünde | SONRA ağız çukurun içinde. |
| Madde 15: 31o mezarlık zemini | DOĞRULANDI (denetçi) | değişmedi |
| Madde 16: 31o ip | **DÜZELDİ** | Z1 |
| Madde 17: 31o Kadri kepçesi | **DOĞRULANDI** | Pafta 11 (gözlem kamerası): ÖNCE kazanın kenarında eli boş | SONRA elinde kepçe kazanın içinde. |
| Madde 18: 39o ip | DOĞRULANDI (denetçi); sokak tarafı da **DOĞRULANDI** | Pafta 04: tayfa ipi eliyle tutuyor, ayağında kangal; ip burgulu, iki ucu bağlı. (Kare ip birleştirme sürümünden; gösterilen alan sol el pişirmesinden etkilenmez.) |
| Madde 19: ressama fırça | DURUYOR | `byz_city.gd` dokunulmaz; önceki rapordaki öneri geçerli. |

## Testler (son kod, başsız, `--max-fps 20`)
`parse_check`: `PARSECHECK PASS scripts=247`. Ham satırlar: `ham_testler.txt` (her koşu bir satır, yasaklı satırlar altında).

| Bölüm | Varyantlar | Koşu | PASS |
|---|---|---|---|
| 24 | "", late, niko, niko_slow, eclipse | 5×2 | 10/10 |
| 25 | "", caught, pass, kid, osm, osm_caught, osm_tez | 7×2 | 14/14 |
| 23 | "", creative, pass, singed, letter, osm | 6×2 | 12/12 |
| 10h | "", shame, save, save1, honest, open, pass | 7×2 | 14/14 |
| 12b | "", lie, year, d2, d3 | 5×2 | 10/10 |
| 31o | "", late, petrion_ok, petrion_bad (+ petrion_bad 10 ek) | 4×2 + 10 | 18/18 |
| 39o | "", late, tezkire, pass, sailor_ok, sailor_bad | 6×2 | 12/12 |
| komşu 6, 26, 30 | varsayılan | 3×2 | 6/6 |

Toplam **96/96 AUTOTEST PASS**. Yasaklı satır (SCRIPT ERROR, WARN_FX_STUCK, WARN_FLY_ITEM, VISAUDIT, WARN_VOID_TELEPORT, WALKTHRU, ARMAUDIT, HELDAUDIT, LOOKAUDIT backturn, JOURNEY_MISS, JOURNEY_OVERLAP):
**96 koşunun 95'inde yok. Bir koşuda var:** `39o late` tur 1: `VISAUDIT overlap … a=CityLife b=CityLife{carry} at=(-33.4, 2.6, -50.3)` — iki rastgele ambient halk figürünün çakışması
(`Petrion>SiegeField>CityLife`; bölümün ip/el/kiriş kodu bu düğümlere dokunmuyor). Aynı varyant yeniden koşuldu: tur 2 temiz; ek **12 koşu repoda, 12 koşu taban kopyasında** (`1e3a9b60`) 0 satır.
Ara sürümde (kiriş çömelme pozu hazır, el tutuşu henüz eski) bir 31o `petrion_bad` koşusunda bir kez `VISAUDIT personhidden key=D31O_AZ_03` (konuşan Azap'ı sokaktaki başka bir kişi örtüyor)
görüldü: o sürümde 28 koşuda 1 (2 test + 26 yinelenen koşu); son kodda 12 `petrion_bad` koşusunda 0, taban kopyasında 26 koşuda 0.
İkisini de **rastgele yerleşimli ambient halk kaynaklı, tekrarlanamayan** olarak kaydediyorum; "yasak satır sıfır" diyemem.

## Performans özeti
Ayrıntı ve ham satırlar `ham_olcum.txt`. Sonda hep aynı kod noktasında; çizim = toplam çizim çağrısı.
- 31o: yukarıdaki Z3 tablosu. 39o ip evresi: 346 → 337-338; ip üçgeni toplam ≈ 2,3 bin.
- Sol el pişirmesi dışında hiçbir bölümde çizim ekleyen değişiklik yok. 23/24: kart şeritleri 3 küçük kutu (yazı 3 ağdı), birikinti ağı 3→4 halka (34 örnekli tek ağ): sayı değişmedi.
- Yazılım çizicide ölçüldü; gerçek GPU'da çizim sayısı aynı, süre farklıdır.

## Ortak dosya önerisi (UYGULANMADI)
- `scripts/player/player.gd` `hold_both` (ve `hand_rig.gd`): sol el ağlarını ilk iki karede köşe renkli tek ağa pişirme (`chapter31o.gd:330 _bake_free_hand`, ~50 satır, ayna için üçgen sırası dönüşü dahil)
  ortak yerde olursa 23 kartı, 30, 38o gibi iki elli tutuşların hepsi ışıklı sahnede ~150 çizim kazanır. Bu turda 31o ve 39o içinde yerel çözüldü (23'ün kartı ışıksız gün sahnesi, ölçüm artış göstermedi).

## YAPILAMAYAN / BAKILMADI
- **Karede kanıtlanamayanlar:** 24 yağmur halkası (karede seçilemedi); 25 haç çıkarma/baş sallama; 23 muhafız/erkân, 10h maiyet, 12b nöbetçi kıpırtısı (ayrık jest ile bekleme sallanması ölçütle ayrışmadı);
  24 arka sağ taşıyıcının eli; 23 kartın İsmail'in eline geçtiği an (PACE=1 denendi, kare yakalayamadı); 39o dumanlı odada ip-el birleşimi (HUD duman ekranı ipi örtüyor; yalnız sayısal).
- **Kalan kusurlar:** 31o kiriş 2/3'te kiriş kadrajın üstünde kalıyor; 31o ip evresi çizimi ortalama +%1,7 (taban yayılımı içinde); 24 birikinti hâlâ mavimsi oval, fark küçük;
  31o ip ucunda koyu bağ ucu yumruğun ~2 cm üstüne taşıyor.
- **Yöntem sınırları:** gözlem kamerası kareleri oyuncu kamerası değil (paftada etiketli); ekranlı t-hizalı RINFO bu makinede sahne geçişlerinde ±%100 oynadığı için karar olay-hizalı sondaya dayandı;
  makine yazılım çizicili olduğundan süre (ms) ölçülmedi.
- **Dokunulmayanlar:** `byz_city.gd` (ıslak kaldırım parlaması, ressam fırçası), `ayasofya.gd` kandil alevleri.

## Pafta listesi (`docs/_kanit_dp8/`, JPEG ≤ 300 KB)
01 31o ip-el (ÖNCE|SONRA ×2) · 02 31o kiriş · 03 31o kazı · 04 39o sokak/ip · 05 24 taşıyıcılar · 06 24 birikinti (yakın) · 07 25 cemaat (diz, mum) ·
08 23 kart · 09 10h bayrak · 10 12b rulo · 11 31o Kadri kepçesi. Ham: `ham_testler.txt`, `ham_olcum.txt`.
