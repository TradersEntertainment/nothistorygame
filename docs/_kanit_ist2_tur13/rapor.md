# TUR 13 — kare sahibi: yeni surda kalan kutular ve görünüş kusurları (Bölüm 26/26o ve çevresi)

Dal `wip/ist2-tur13`, taban `wip/ist2-taban14` = **014b61a7**. ÖNCE = aynı taban (`git archive 014b61a7`, depo dışı kopya
`~/is/once`, aynı içe aktarma önbelleği), aynı makine, aynı kod yolu, aynı kameralar. Kareler xvfb + Mesa llvmpipe
(yazılımsal GL), 1280×720 jpg 85, hepsine TAM BOY bakıldı. Ekransız testler `--max-fps 20`, tam süzgeç.

Yeni test sahneleri (ÖNCE ve SONRA aynı betikle çekildi):
- `tests/_ist/tur13_kare.tscn` — Bölüm 26'nın kesimi (SurOyun: iç poterna, Romanos kanatları, dolgu 1), bölüm çerçevesi,
  sabit kameralar (`--set=poterna|romanos|dis_poterna|harpusta`, `--acik` kanat açık, `--gece`), her karede çizim/ilkel
  (`TUR13KARE`); `--sonda` ışın sondası (Romanos ve poterna önü zemin/etek), `--gizle=<düğüm>` tanı.
- `tests/_ist/tur13_sergi.tscn` — oyunun kendi kurucularından pavez (`Assault.pavez_ag`, iki ölçü), öküz arabası
  (`Dressing.cart`, 6 tohum), 26/26o burç sancağı (bölümdeki satırın aynısı).

Klasörler: `kare/once/`, `kare/sonra/` (tam boy), `pafta/` (sol ÖNCE | sağ SONRA, yalnız göz gezdirmek için), `testler/`.

## Özet

| # | Madde | Durum | Kısa |
|---|---|---|---|
| 1 | İç poterna surun içine oyulur | **TAMAM** | Sur gövdesi kapıda oyulur (görünen yüz; çarpışma birleşimi aynı), söve/kemer kesme taş yüzle aynı düzlemde (2 cm), kulak yok, tonoz + lünet + 1,45 m karanlık geçit; eşik peribolos zemininde (etek kapı önünde yassı). Dış poternanın kemer kulağı da kesildi |
| 2 | Romanos iç kapısının şehir yanı gri bloklar | **TAMAM** | Kaynak: iç kulenin KAİDESİ (`sur_kule.ic_kule`, şehir yüzünde 0,8 m çıkıntı + yan kenar uçları), etek değil. Kaide şehir yanında surun içine çekildi; kule köşesinin çapraz etek kamaları kırpıldı |
| 3 | Sancak (26, 26o) | **TAMAM** | `Props.box` levha → `kumas.bayrak` (aynı ölçü/renk/düğüm, yükseliş tween'i aynı) |
| 4 | 26o pavez + `Assault._pavises` | **TAMAM** | `Assault.pavez_ag`: 5 kalın tahta, enine kavis, pahlı kenar, boyalı yüz, arka kuşak, dayanak ayağı, demir uç. Çarpışma aynı |
| 5 | Öküz arabası (`Dressing.cart`) | **TAMAM** | Tahta döşeme, parmaklıklı yan, 12 parçalı ispit + 8 parmaklı tekerlek, dingil, yere inen ok, boyunduruk. rng sırası, çarpışma aynı |
| 6 | Harpuşta saçağı | **TAMAM** | Taşma 1,6–2,4 cm (± 0,6 cm oynama); sırt ve derz aynı |
| 7 | Yetişirse | **KISMEN** | Orta katman çadır kumaşı nefes alır (kip 2). c5 hendek kıyısı, gemi yelkeni, 28o çift zemin: YAPILMADI (aşağıda) |
| — | Sözleşme | **AYNI** | `SURSOZLESME PASS kalem=13 kesim=8` · `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` · `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` · `ESYATEST PASS` |

(Ayrıntı ve kareler aşağıda; bölüm testleri ve bütçe tablosu §8–§9.)

---

## 1. İç poterna (Bölüm 26) — **TAMAM**

**Sorun** (tasima8 `26/yeni_an_06_poterna`, sahibine "kötü"): kapı iç surun ÖNÜNE konmuştu (söve 16 cm, kemer 17 cm dışarıda,
kemer halkasının alt uçları söveden 0,32 m dışa taşan "kulak"), sur gövdesi oyulmamıştı (kanadın ardında yüze yapışık koyu
dörtgen), kapı iç yüz eteğinin üstüne oturtulmuştu (+0,39 m) → "kemerli ahşap kulübe".

**Düzeltme**
- `surlar.gd _run_ic` → `_ic_poterna_x` / `_ic_poterna_oyuk`: oyun diliminin atalarından biri `ic_poterna == true` taşıyorsa
  (Bölüm 26'nın `SurSetSahne.ic_poterna`; test sahnesinde meta) iç surun gövdesi kapı aralığında bölünür: iki yan parça +
  kemer tepesinin üstü (lento kütlesi) + 1,45 m geride arka parça. Görünen yüz oyulur; **oyuğu dolduran yalnız-çarpışma
  kutusu** konur → iç surun çarpışma BİRLEŞİMİ kesilmemiş duvarla aynı (kapının önünde yürünen yüz yine `zi1`).
  Yer `SurOyun.ic_poterna()` ile aynı (aynı arayüz nesnesi `SurSet.a`). Öteki bölümlerde ve sözleşme sahnelerinde ata
  istemediği için hiçbir şey değişmez (sözleşme üçlüsü aynı).
- Taş işçiliği surun içinde, yüzle aynı düzlemde (2 cm önde; z-kavgası yok): iki yanda dönüşümlü uzun/kısa söve taşları
  (köşe örgüsü; yüzde ve oyuğun yan yüzünde 0,34 m derinlikte), 9 kama taşlı yarım daire kemer (iç yarıçap 0,7, dış 1,04;
  kilit taşı 6 cm uzun; **alt uçlar söve taşının üstünde biter, kulak yok**), taşlar arası 16 mm derz, kemer altı (0,30 m) +
  tonoz, kanadın üstünde taş lünet ve lento. Malzeme: sur taşı gölgelendiricisine DÖNÜŞMEYEN düz kesme taş (ilk denemede
  "ashlar" deseni duvarın taş sıralarını kama taşlarının üstünden geçirip onları duvara gömüyordu).
- `sur_oyun_parca.gd Poterna.kur_ic`: yalnız oynayan/koyu parçalar: kanat oyukta (yüzden 0,15–0,24 m içeride, menteşe yan
  yüzde, peribolosa 95° açılır: 100°'de kanat söve köşesine 2 cm giriyordu), iki parçalı eşik taşı, kanadın ardında içeri
  doğru kararan yan yüzler/tavan/taban ve dipte koyu yüz (karanlık geçit derinliği).
- `sur_oturtma_ag.gd yuz(…, duz)`: iç yüz eteği kapı önünde **kesilmez, yassılaşır** (yükseklik 0; iki yanda 2,5 m'de
  eski boyuna çıkar). İlk deneme eteği kesiyordu: kesik ucunda "kutu kenarlı basamak" kaldı; yassı etek düzgün. Eşik taşı
  eteğin 7–10 cm üstüne oturur (`_otur_ic`, `ICPOTERNA … oyuk=true etek_y=0.01 oturma=0.10`): eşik peribolos toprağında,
  0,39 m'lik etek basamağı yok.
- Dış poterna (`Poterna.kur`, 36b/37o; sur zaten oyuk): kemer halkasının iç kenarı açıklıkta (w/2), dış kenarı sövenin
  dış yüzünde (w/2 + 0,28): alt uçlarda 0,18 m'lik kulak kalktı.

**Çarpışma (ölçüldü, gerekçe):** iç sur birleşimi aynı (oyuk dolgusu). Kanat kutusu aynı ölçü; kapalıyken 0,25 m içeride
(artık duvar gövdesinin içinde: kapı önünde oyuncu 0,19 m daha yaklaşabilir), açıkken 95°. Etek (üçgen çarpışma) kapı önünde
x ± 1,2 m'de 0,15–0,73 m'den 0–0,05 m'ye iner (2,5 m'lik geçişle): kapı toprağa insin diye görevin istediği değişiklik.
Eşik çarpışma kutusu aynı yerde. Bölüm 26'nın POSTERN noktası, fıçılar, taşıma yolu aynı; 26 çeşitlerinin hepsi PASS (§8).

## 2. Romanos iç kapısının şehir yanı — **TAMAM**

**Kaynak (düğüm yolu):** `SurCerceve/SurOyun_mesoteikhion/YanKapi_romanos/AzizRomanos` içindeki iç kulelerin ağı
(`sur_kule.ic_kule`, pişmiş). Tanı: `tur13_kare --gizle=SurDibiEtek` ile etek gizlendiğinde bloklar kalıyor; ışın sondası
blokların yerinde çarpışma bulmuyor (görünen ağ). İç kule çokgeni şehir yüzünün 0,15 m önünden başlar ve kaidesi
(`[y_base … 0,7] = şev + 0,35`, üstü eğik) bütün kenarlarda örülür: şehir yüzünde 0,8 m dışarı taşan, üstü eğik gri kaide,
yan kenarların şehir ucunda kapı geçidine bakan kutu uçları — "kutu gibi gri taş bloklar".
**Düzeltme:** `sur_kule.ic_kule` (lod 0): kaide ve gövde sur yolu düzeyine dek şehir kenarı surun 1 m İÇİNE çekilmiş
çokgenle örülür (Theodosius iç kuleleri şehir yanında çıkıntı yapmaz, peribolosa çıkar); sur yolunun üstü eskisi gibi
(alt kenarı kapalı). Kule kapısı (dipte kemerli) sur yüzüne alınır (eskiden kaidenin önündeydi). `sur_oturtma_ag.kule`:
iç kule yan kenarlarının şehir ucu surun içinde kırpılır (köşedeki etek satırı yüz normali ile yan normalin ortasına uzanıp
şehir yanında üçgen etek "kaması" bırakıyordu; kaide kalkınca göründü).
**Çarpışma:** kaidenin çarpışması yoktu (değişmedi). Etek kamaları (üçgen çarpışma) iç kulelerin şehir yanı köşelerinde
kalktı: Romanos'ta kapının iki yanında (dx ±2,9, şehir yüzünden 0,2–0,5 m) 0,41 m'lik etek → zemin (sonda §7). Bütün yeni
sur bölümlerinde iç kulelerin şehir yanı köşelerinde aynı (oyun alanı peribolosta; şehir yanı yalnız 26 finalinde, oyuncu
caddede). Sözleşme üçlüsü aynı.

## 3. Sancak (26 ve 26o) — **TAMAM**
`scripts/chapter26.gd:371` ve `scripts/chapter26o.gd:247` (yalnız görünüş satırı): `Props.box(banner, (0,04 × 1,2 × 1,8))`
düz kırmızı levha → `kumas.bayrak(banner, (0; 3,9; 0,03), +z, L 1,8, H 1,2, b3262d, nx 8, "Sancak")`: tur 12'nin ince, çift
yüzlü, direk kenarı sabit, dünya rüzgârına dalgalanan kumaşı. Ölçü (1,8 × 1,2), renk, direk (4 m silindir), `banner` düğümü,
görünmez başlayıp 3. dalgada yükselmesi (26o `_raise_banner` tween'i, 26 `banner.visible`), 26o'nun fotoğraf hedefi
(`banner.add_child(target)`) aynı. Çarpışma yoktu, yok.

## 4. Pavez (26o siperleri ve `Assault._pavises`) — **TAMAM**
Yeni görünüş yardımcısı `Assault.pavez_ag(en, boy, kalınlık, boya, eğim)` (önbellekli tek ağ, Dressing malzemesi: toon + dış
çizgi; kutu DEĞİL): beş kalın dikey tahta (7 mm derz, tahta tahta ton ve ±1,5 cm boy), ön yüz enine kavisli (ortada 4 cm
şişkin), ön kenarlar ve üst ön kenar 1,5 cm pahlı; ön yüz boyalı (taban boya, ortada soluk aşı şerit, dipte kir), arkada iki
enine kuşak kalası, arkadan zemine inen altıgen kesitli dayanak ayağı (eğimle kurulunca ucu y 0'da), altta iki demir uç.
- `Assault._pavises`: Dressing kutuları yerine renk başına bir MultiMesh (4 renk → ≤ 4 çizim). Yer, −12° eğim, okçular,
  `rng` çağrı sırası aynı (dekorun geri kalanı aynı yerde). Çarpışma yoktu, yok.
- 26o siperleri (`chapter26o.gd`, yalnız görünüş satırları): çarpışma kutusu `Props.solid(1,3 × 2,1 × 0,12)` aynı; kutunun
  görünen ağı yerine pavez ağı gövdenin ÇOCUĞU (gövde `Unclip.visible_body` için "görünür" kalır). Eski dört kutu (kuşaklar,
  kırmızı kare, çubuk ayak) kalktı.

## 5. Öküz arabası (`Dressing.cart`) — **TAMAM**
Tahta dalı (Kit modeli olmayan yarı; Kit'li dal `Stall_Cart_Empty` modeli, değişmedi): beş döşeme tahtası (yük düzlemi eskisi
gibi y 0,76: yük çuval/sandık/kütük aynı yerde), kasa altı kirişleri, iki yanda parmaklık (7 sırık + üst kalas), arka tahta;
dingil + takozlar; iki tekerlek: yarıçap 0,45 (alt ucu zeminde), 12 parça ispit + demir çember, 8 parmak, göbek ve çivi;
ön traversten çıkıp ucu YERE inen ok ve ucunda yerde yatan boyunduruk (iki kavisli boyun yayı). Eskiden: kutu kasa, düz disk
tekerlek, öne doğru havada biten iki çubuk (ucu 0,48 m yüksekte). Çarpışma kutusu (1,4 × 1,1 × 2,2) ve `rng` çağrı sırası
aynı (sonraki dekor aynı yerde).
**Kullanıldığı yerler (hepsi aynı işlev → hepsinde aynı):** `Dressing.auto` "byz"/"galata"/"camp" kümeleri (`ByzCity`:
6, 7, 10h, 12b, 13, 23, 24, 25, 26, 31o, 44b; `CampDay`: 6, 7, 8y, 9, 10, 10b, 10z, 11, 13, 16, 24o, 25, 43o; `Galata`: 10g,
13, 27), `Camp` (4), `Slipway` (2), `WallRear` (siege_field/sehir/rear_life/city_plan: 8y, 22o, 28o, 41o ve İstanbul v2
şehir arkası). Kit modelleri yüklüyse arabaların yarısı Kit'in satıcı arabasıdır (değişmedi).

## 6. Harpuşta saçağı — **TAMAM**
`sur_kule._harpusta`: taşma `0,025 + 0,02·h3` (2,5–4,5 cm) + uç oynaklığı ±2 cm + derinlik oynaklığı ±1,5 cm → `0,016 +
0,008·h3` (1,6–2,4 cm) + ±0,6 cm + ±0,5 cm: dişin dışına en çok ≈ 3 cm. Eşek sırtı, derz, taş bölümü, kırık köşe aynı.

## 7. Yetişirse — **KISMEN**
- **Orta katman çadır kumaşı — TAMAM:** `ordugah_cadir.mesh`: kumaş köşe aralıkları (`_grid`) artık orta katmanda (lod 1)
  da izlenir, orta ağ `_nefesli_ag` ile kip 2 ağırlığı alır ("kumas" işaretli → `K.mm` / `ekle` kumaş gölgelendiricisini
  seçer). Gölgelendiricinin LOD'u (55 m'den söner, 110 m'de durur) aynı; uzak (pişmiş hücre) katman sabit. Ağ ve üçgen
  sayısı aynı (yalnız UV/UV2 eklenir); MultiMesh başına çizim aynı.
- **Gemi yelkenleri — YAPILMADI:** gemi gövde ağıyla aynı yüzeyde (`gemiler_mesh`), ayrı iş (tur 12 ile aynı gerekçe).
- **c5 hendek dış kıyısı — YAPILMADI:** zaman ana maddelere (dördüncü tur üst üste; `sur_zemin.kiyi_ortu` var, c5 kamerası
  bu turda çekilmedi).
- **28o çift zemin — YAPILMADI (bilerek):** `Ova` SiegeField arazisi (`siege_field.gd`, bu turun dosyası değil; arazi
  inişli çıkışlı, tek yükseklikle eşlenemez) ile `Toprak_ZeminOva` (`sur_oyun_parca.zemin`, bir parça sınıfı değil: oynanış
  zemini; 20, 21, 22, 26, 26o, 28o… hepsinde yürünen taban) arasında. Birini kaldırmak ya da indirmek bu set kullanan
  bütün bölümlerde yürünen zemini değiştirir; görünüş turunda yapılmadı → "başka dosyaya istek" 2.
