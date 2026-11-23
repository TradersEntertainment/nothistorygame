# TUR 14 — kare sahibi: yeni surlarda yakın görünüş kusurları

Dal `wip/ist2-tur14` (taban `wip/ist2-taban19` = a38ad405; 8y yeni sette `--yenisur=8y`). Yalnız görünüş; sur ölçüleri ve
çarpışma aynı (sözleşme, denetim, yürüyüş, eşya, Haliç sondası aynı; yeni Marmara sondası eşit). Var olan replik, ses, denge,
sayaç değişmedi.

## Özet

| # | madde | durum |
|---|---|---|
| 1 | Romanos kapı kemeri + kanat (tahta damarı, çivi) | **TAMAM** (aynı kalem: deniz kapısı, kule kapısı, Marmara kapısı) |
| 2 | Harpuşta yakında/gölgede koyu-yeşilimsi-pürüzsüz | **TAMAM** (ortak gölgelendirici: Mesoteikhion, Blakherna, deniz) |
| 3 | Sur yolu ve rıhtım döşemesi | **TAMAM** |
| 4 | Şehirde Haliç hattı + Marmara (`IstMarmaraSur.build_run`) deniz kalemine | **TAMAM** (çarpışma dökümü eşit) |
| 5 | Blakherna/ova kalanları | **KISMEN** (pavez + gece harpuşta yapıldı; 30o zemin ve saray sütunu başka dosya) |
| 6 | c5 hendek, HornWorld uzak katman | **YAPILMADI** |

## Değişen dosyalar
| dosya | ne |
|---|---|
| `scripts/world/ist/surlar_kapi.gd` | `arch_ag`/`arch` (gerçek ölçü kemer, tek ağ, sur_doku), `arch_yon` (yönlü), `lento_ag`, `kanat_ag`/`kanat_mat`/`damar_doku`, statik kanat (çarpışma aynı kutu) |
| `scripts/world/ist/sur_doku.gd` | harpuşta dalı, döşeme dalı (yerel çerçeve), türev kabartması, yukarı bakan taşa sekme ışığı, gece payı |
| `scripts/world/ist/sur_oyun_parca.gd` | YALNIZ `KapiKanat` ağ/malzeme satırları (`kanat_ag`); gövde, `kanatlar`, `ac()` aynı |
| `scripts/world/ist/sur_kule.gd` | kule kapısı kemeri (`_kemer` → `arch_yon`), kule tuğla ağı sur_doku'da |
| `scripts/world/ist/surlar_ayrinti.gd` | örülmüş eski kapı izinin kemeri ortak kalem |
| `scripts/world/ist/marmara_sur.gd` | `build_run` deniz kalemine (`_S` + gizle + `_yeni_gorunus`, pencereye kırpılı) |
| `scripts/world/ist/deniz_set.gd` | `kapi_kemer` kemeri ortak kalem, mermer bir ton sönük |
| `scripts/level/assault.gd` | YALNIZ `pavez_ag` / `_pavises` görünüşü |
| `scripts/level/blachernae.gd` | YALNIZ pavez malzemesi |
| `tests/_ist/tur14_kare.*`, `tur14_marmara_sonda.*`, `tur14_bolum_kare.*` | yeni kare ve sonda araçları |

`sehir.gd` (2900-2908 dahil), `marmara_kiyi.gd`, `halic_sur.gd` değişmedi.

## 1. Romanos kapı kemeri ve kanat — TAMAM

**Kök neden.** `IstSurlarKapi.arch()` (`scripts/world/ist/surlar_kapi.gd`) kemeri 11 ayrı `Props.box` ile kuruyordu: her biri
56 cm × 72 cm × 14 cm, renk `C_BRICK` 96503a ve ikide bir `lightened(0.12)`; Props toon malzemesi + kenar ışığı (rim 0,2)
+ dış çizgi → güneşte parlak turuncu-somon, iri, birbirinin kopyası blok. Lento üstü "yazıt şeridi" `e2d6bb` (açık krem) tek
levha. Kanat: `KapiKanat` (`sur_oyun_parca.gd`) ve şehirdeki statik kanat (`IstSurlarKapi.build`) dört geniş (≈ 60 cm) tahta;
`Props.mat(C_WOOD 7a5634, "wood")` köşe rengini OKUMUYOR (`vertex_color_use_as_albedo` yok) → tahtadan tahtaya ton farkı
hiç görünmüyordu, "wood" gürültüsü 0,88–1,0 (damar yok) → tek ton turuncu levha.

**Yapılan.**
- `arch_ag()`: Theodosius kapılarının ölçüsünde boşaltma kemeri, tek ağ: kama halkası (r … r+0,56) kesme taş kama taşları
  (iç yüzde ≈ 30–38 cm, pahlı 1,8–3,8 cm, %28'inde kırık köşe, taş taş ton) ile **üçer tuğlalık demetler** (4,5 cm tuğla +
  3,5 cm harç) dönüşümlü; iki üzengi ve kilit taşı taş; dış halka tek tek tuğla (rowlock, 4,5 + 3,5 cm); arkada kirli bej-gri
  harç yatağı (derzler gerçek boşluk + gölge); yüz yüze 1–4 cm oynak çıkıntı. Malzeme **sur taşı gölgelendiricisi**
  (`sur_doku`; kesme taş köşe alfası 0,8 = tek taş yolu, tuğla köşe rengi kızıl = desensiz yıpranma; gece payı duvarla aynı).
  Tuğla tonu tuğladan tuğlaya (soluk / fazla pişmiş mor-kahve / az pişmiş sarımsı), doygunluk sur hatılı tuğlasıyla aynı.
- Lento üstü şerit: kesme taş sırası (85 cm'lik taşlar, derz, çıkıntı).
- Dört kemer + lento tek ağ (eski 44 kutu + 44 dış çizgi → 1 çizim). Altın Kapı cephesi (mermer) aynı işlevle yalnız taş kama.
- Kanat (`kanat_ag`, iki yol da aynı işlev): dikey tahtalar ≈ 27 cm (8 mm aralık, arkada koyu dolgu), tahtadan tahtaya ton
  (yıpranmış meşe gri-kahve; güneşte grileşmiş / yağ-is koyusu), 0–8 mm çıkıntı; `kanat_mat()` = Props "wood" toon ayarı +
  köşe rengi + üretilmiş **damar dokusu** (dikey lif, yıllık halka, budak; dünya üç düzlemli); demir kuşak (yer ve ölçü
  eskisi, DÜZELTME 1) + kuşakta tahta başına iki dövme çivi başı (piramit), kuşak aralarında perçin çivileri.
- Çarpışma: `KapiKanat` gövdesi, `kanatlar`, `ac()` aynı; statik kanadın kutusu `IstSurlar._s` ile AYNI kutu (yalnız çarpışma
  kipinde kuruluyor: `carp_only`), sözleşme karması aynı.
- Aynı kalem deniz kapısında: `deniz_set.kapi_kemer` 11 iri dilimli (yarısı Props tuğla, parlak turuncu) kemer yerine
  `IstSurlarKapi.arch_ag` (sur_doku tur 1) — Haliç dilimi, SeaWalls (4b, 17, 19, 29), 18b/38o kesimi, Marmara kapıları.

## 2. Harpuşta (diş tepe taşı) — TAMAM

**Kök neden.** `sur_doku.gd` harpuşta dalı (köşe alfası 0,75–0,86; `sur_kule.disler_ag` → `_harpusta`): taban `tas × (1; 0,98;
0,94)` sarımsı kireçtaşı; üstüne koyu liken `tas × (0,42; 0,44; 0,38)` (yeşilimsi) %55'e kadar, yosun `(0,17; 0,2; 0,11)` %40'a
kadar; normal pürüzsüz (kabartma yalnız dikey duvarda). Gölgede yalnız gök ışığı alan yüz (doğrusal uzayda mavi baskın) ×
sarımsı taş = yeşil; gece payı duvarla aynı (×0,68) → koyu ağır "kapak".

**Yapılan.** Açık, sıcak gri kireçtaşı (kızıla çekik `1,13; 1,06; 0,97`), taş taş ton (köşe renginden karma: ±%11, sıcak/soğuk),
kaba yontu (taştan taşa değişen yönde kısa paralel keski olukları), dane, çukurcuk, kılcal çatlak — hepsi **türev kabartması**
ile normale de işler (yeni: görüş uzayında yükseklik alanının ekran türevi; yakında, uzakta söner). Liken seyrek ve gri-sarı,
yosun lekeler halinde ve zayıf (%16). Gece harpuşta duvardan %55 az kararır (diş silueti seçilir). Yukarı bakan taşa küçük,
sıcak "sekme ışığı" (EMISSION, yalnız yukarı bakan yüz, gece 0): gölgede yeşil/camgöbeği okunmuyor. Aynı yol Romanos kemerinin
kama taşlarında ve iç poterna kesme taşında (ortak gölgelendirici: Mesoteikhion, Blakherna, deniz suru, SeaWalls, şehir).

## 3. Sur yolu ve rıhtım döşemesi — TAMAM

**Kök neden.** `sur_doku.gd` yatay dalı: `wpos.xz / 0,9` eşit kare ızgara (0,9 m kare, cetvel derz), renk `tas × (1,06; 0,9;
0,74) × 0,66–0,96` (kiremit-kahve; SUR-5'te gölgede camgöbeği karo okunmasın diye kızıla çekilmiş), liken yeşil `(0,2; 0,22;
0,13)` %30 → gölgede zeytin yeşili.

**Yapılan.** Gerçek ölçü kesme taş döşeme: sıra eni 0,34–0,56 m (sıradan sıraya), taş boyu 0,4–0,95 m (sıra sıra; %30'u
ikiye bölünmüş), şaşırtmalı, derz 1–2,4 cm dalgalı ve toz/toprak dolu (yalnız derzde yer yer ot), taş taş ton (solgun gri-bej;
soğuk gri ↔ bal; %8 koyu onarım taşı), aşınmış yuvarlanmış kenar, %35'inde kırık köşe, seyrek kılcal çatlak, ayak izi
aşınması (açık yama), yağmur lekesi; kabartma (derz girintisi 12 mm, kenar yuvarlanması) türev normaliyle. Ton `tas × (1,1;
0,985; 0,85)` + yukarı bakan yüzde sıcak sekme ışığı: güneşte gri-bej, gölgede gri (eski: kahve ve zeytin yeşili).

## 4. Şehirde Haliç hattı ve Marmara deniz surları deniz kalemine — TAMAM

**Kök neden.** `sehir.gd:2900-2906` yalnız tam 96 m'lik Haliç dilimlerini `IstHalicSur.build`'e (taşıma 11'de deniz kalemine
geçti) veriyor; ötekiler ve bütün Marmara kıyısı `IstMarmaraSur.build_run` (`marmara_sur.gd`) ile kuruluyor: gövde, kule,
korkuluk `IstMk.S` kutuları (Props "ashlar" → şehirde sur_doku), dişler `IstMk.MM` kutu, kule kornişi tuğla kutu + taş kutu,
korkuluk kapağı kutu, kapı kemeri `IstMk.ARCH` 13 kutu (Props tuğla), mermer söve/lento kutu, devşirme mermer levha (8 cm
kutu), oluk kutusu, yeşil "yosun bandı" kutusu, kulede havada duran mermer sütun kütüğü ve korkuluk boyu (1,6 m) havada
bayrak direği. Aynı kıyıda iki ressam (96 m'lik dilim yeni kalem, komşusu kutu).

**Yapılan.** `sehir.gd` dağıtımı DEĞİŞMEDİ (satır 2900-2908'e dokunulmadı: kalem `build_run`'ın içinde). Taşıma 11'in
`IstHalicSur` kalıbı: yakın ve orta katmanda (`lod < 2`, `--eskisur` yoksa) `IstMk.S` kutuları `_S` ile toplanır, ağları
gizlenir (`deniz_set.gizle`: `wall` metası), görünüş `deniz_set` ile kurulur:
- `govde` (kapı açıklıkları, su çizgisinde kaide 0,55 m = eski kaya ayağın çıkıntısı), `korkuluk` deniz (1,9 m; orta 1,4) ve
  şehir (1,05 m; merdiven ağzı açık), `disler` (eski merlon dizisinin yerleri ve ölçüsü: 0,95 × 0,8), `kule` (eski kutu
  kulenin ayak izi ve tepesi; pahsız: çarpışma kutusuyla aynı kenar; konsol, silme, ok yarığı, teras korkuluğu + dişler),
  `kapi_kemer` iki yüzde (söve, lento, ortak kemer kalemi, kitabe).
- Kutu süsler yeni kipte kurulmaz (korniş, kutu diş, kapak, kutu kemer, devşirme levha, oluk, yosun bandı, ok yarığı kutusu,
  kandil, sütun kütüğü). Açık kapı kanatları `IstSurlarKapi.kanat_ag` (tahta, damar, çivi; dönüşlü). Bayrak direği teras
  döşemesinden (eskisi 1,6 m havadaydı). Merdiven, sandık istifi, fenerler, kazan aynı.
- **Pencereli kurulum:** şehir yakın katmanı 7 m'lik pencerelerle kurar (`sehir.gd _pencere_is`, `IstMk.pencere`); yeni
  görünüş pencereye kırpılır (gövde ve korkuluk aralığı, diş/kule/kapı merkezi `IstMk._ic`), uç yüzleri yalnız tam kurulumda.
- Çarpışma: yeni sonda `tests/_ist/tur14_marmara_sonda.tscn` — build_run (k 1,0 / 0,5; L 30, 61,5, 150, 233; lod 0/1/2;
  merdivenli/merdivensiz), şehrin 7 m'lik pencereli kurulumu (L 61,5 ve 150) ve `marmara_kiyi.gd`'nin build_run çağıranları
  (Mermer Kule, Ahırkapı; DÜZELTME 4) + build_msur: **`MARMARASONDA OZET carp=1837 karma=2250736444` ÖNCE = SONRA**
  (`testler/marmara_sonda_{once,sonra}.log`; dönüş değerleri `MARMARADON` satırı aynı).

## 5. Blakherna ve ova kalanları — KISMEN

- **Pavez (30o, ova bölümleri) — TAMAM.** Kök neden: `Assault.pavez_ag` beş tahta (2,6 m'lik Blakherna pavezinde 52 cm'lik
  tahta), ön yüz düz boya bantları; malzeme `Dressing._material()` köşe rengini doğrusal okuyor (`vertex_color_is_srgb` yok:
  renk soluk, açık) ve damarsız → gece ay ışığında açık renk düz levha. Yapılan: tahta eni gerçek ölçü (≈ 24 cm; 2,6 m'de 11
  tahta), ön yüzde **ham deri kaplama** (kenarlarda 6,5 cm tahta açıkta; deri 6 mm kalkık, kavsi izler, boyalı + soluk şerit +
  dipte kir, 2,5 cm koyu kıvrık kenar), deri kenarında ≈ 14 cm arayla dövme çivi başları, tahtada damar (`kanat_mat`: köşe
  rengi sRGB × damar dokusu, aynı toon + dış çizgi). Yer, eğim, okçular, rng sırası, çarpışma (yoktu) aynı.
- **30o zemin iki ton keskin sınır — YAPILMADI.** Görünen zemin `blak_set.zemin` (etek malzemesi) ile bölümün ova zemini
  arasında; 28o'daki çift zemin (`Ova` / `Toprak_ZeminOva`, DÜZELTME 5) ile aynı aile — kaynak `sur_set_sahne.gd`,
  `sur_set_hub.gd`, `sur_oyun_parca.gd:47` (benim değil). Bu turda düzeltmedim, raporluyorum.
- **Saray önü ince beyaz sütunlar — YAPILMADI.** Saray `sehir_eser.palace` (şehir eseri; benim dosyam değil); `blachernae.gd`
  yalnız onu kuruyor. "Başka dosyaya istek" 2.
- **Gece harpuşta koyu ağır levha — TAMAM** (madde 2 ile: gece payı harpuştada %55 az, açık ton).

## 6. Yetişirse — YAPILMADI
c5 hendek dış kıyısı cetvel ve `HornWorld._wall_run` 250 m ötesindeki eski kutu deniz surları bu turda yapılmadı (süre
1–5'e harcandı).

## Hâlâ kötü olanlar (dürüst)
1. **38o / SeaWalls deniz kapısı kanatları** düz kahverengi iki levha (SeaWalls'ın kendi `_kapi_kanatlar`ı; `sea_walls.gd`
   benim değil). Kemer, söve ve lento yeni; kanat eski.
2. **Gece tuğla** (sur hatılı ve kemer tuğlası) ay ışığında doygun kırmızıya kaçıyor (38o k1); kemer tuğlası hatıl tuğlasıyla
   aynı tonda, yani aynı ressam — ama ikisi birlikte gece fazla kızıl. Ortak `sur_doku` "düz" yolunun gece payı; bu turda
   dokunmadım.
3. **Döşeme sıra yönü** artık modelin yerel çerçevesinde (sur dilimi yönünde); komşu dilim sınırında desen kesiliyor (yakında
   seçilir: iki dilim arası düz bir derz çizgisi gibi). Pişmiş uzak katmanda yerel = dünya.
4. **Sekme ışığı (EMISSION) bir hile**: gölgede yeşili kırıyor, güneşte döşemeyi ≈ %10–15 açıyor. Işık/gök ayarı (`look.gd`,
   `night.gd`) benim değil; asıl çözüm bölüm gökünün ortam ışığında.
5. **Kanat tahtaları** yakından (k3) hâlâ biraz şeritli (tahta tahta ton + doku bandı); son kayıtta karşıtlık azaltıldı.
6. **Kule sur yolu kapılarının küçük kemeri** (`sur_kule` 5 tuğla kutusu) kutu olarak kaldı (yalnız rengi sönük tuğla:
   sur taşı gölgelendiricisi).
7. **30o zemin iki ton keskin sınır** ve **saray önü ince sütunlar** (madde 5) yapılmadı.
8. **Şehir uçuşu kareleri** yazılımla çizimde kare başına ≈ 2 dk; 10 dk sınırı içinde Haliç dilimi 12 ve 22 + ek kareler
   çekildi, bütün kıyı gezilmedi.

## Başka dosyaya istek
1. **`scripts/level/sea_walls.gd` (`_kapi_kanatlar`)**: deniz kapısı kanatları `IstSurlarKapi.kanat_ag` ile (tahta, damar,
   çivi; kaplama aynı) — 4b, 17, 19, 29, 38o.
2. **`scripts/world/ist/sehir_eser.gd` (`palace`)**: Blakherna saray revakının sütunları ince (çubuk gibi) ve açık; çap ve
   başlık/kaide (30o saray önü).
3. **28o/30o çift zemin** (`sur_set_sahne.gd:129,282`, `sur_set_hub.gd:129`, `sur_oyun_parca.gd:47`; DÜZELTME 5): ova
   zemininde iki ton keskin sınır.
4. **`scripts/level/look.gd` / `night.gd` (gök ortam ışığı)**: yukarı bakan taş gölgede yalnız mavi gök ışığı alıyor
   (yeşil/camgöbeği); "yer" yarısının sıcak sekmesi ortam ışığında olursa `sur_doku`'daki sekme ışığı kaldırılabilir.

## Kareler (ÖNCE | SONRA, 1280×720 jpg 85, tam boy) ve SONRA cümleleri

**Yakın (Bölüm 26 kesimi, `tests/_ist/tur14_kare.tscn`; gündüz ve `_gece`)** — `kare/yakin/{once,sonra}/`
- `k1_kemer_sehirden_3m`: kesme taş kama + üçer tuğla demeti + dış tuğla halkası, harçlı, solgun; kutu yok, havada yok (yüze
  oturuyor), sur ile aynı ressam, eskisinden sönük değil (eskisi parlak somon kutu). Gece: kemer duvarla birlikte kararır,
  taş/tuğla seçilir.
- `k2_kapi_sehirden_10m`: kapı ve iki kule kapısı aynı kemer kalemi; kanat tahta tahta gri-kahve; kutu yok, havada yok.
- `k3_kanat_1m`: ≈ 27 cm tahtalar, damar, budak, çivi başları, demir kuşak; kutu değil; yakından hâlâ biraz şeritli.
- `k4_dis_kapi_peribolos_4m`: koridor içinden dış kapı kemeri ve kanadı aynı kalem; kutu yok.
- `h1_harpusta_06m`: harpuşta açık sıcak gri, dane ve yontu, gölgede yeşil değil; kutu değil, havada değil.
- `h2_harpusta_yol_boyu`: döşeme gerçek ölçü taş, sur yolu boyunca sıralı, gri-bej; harpuştalar açık; aynı ressam.
- `h3_ic_sur_disler_2m`: iç sur dişleri; harpuşta açık tonda, taş taş farklı.
- `d1_dis_yol_doseme_15m`: döşeme 1,5 m'den: derz, kırık köşe, taş taş ton; gölgede gri (eskisi zeytin yeşili, iri kare).
- `d2_ic_yol_doseme_3m`: iç sur yolu, aynı döşeme; kiremit-kahve yok.
- `g1_peribolostan_12m`: sur yüzü değişmedi (dikey dal aynı); zemin (`sur_zemin`) kapsam dışı.

**Bölüm 8y (yeni set, `--yenisur=8y`; `tests/_ist/tur14_bolum_kare.tscn`)** — `kare/8y/`
- `01_sehirden_ic_kapi` (Taşıma 10'un şikâyet karesi): kemer solgun taş + tuğla, gerçek ölçü; kutu yok, havada yok, aynı ressam.
- `03_kanat_yakin`: kanat tahta, damar, çivi (turuncu sürgü kirişi bölümün kendi parçası: `chapter8y.gd`, benim değil).
- `06_dis_kapi_yakin`: dış kapı kanadı dikey tahtalar, damar; kutu levha değil.

**Bölüm 12b** — `kare/12b/`
- `06_kapi_sehir_yani` (gün batımı): kemer taş + tuğla, duvarla aynı tonda — seçiliyor ama sönük (son kayıtta kesme taş tonu
  bir parça açıldı; kare açmadan önceki kodla).
- `02_mazgal_yakin`: harpuştalar açık, kapak gibi koyu levha değil.

**Bölüm 38o (gece)** — `kare/38o/`
- `k1_deniz_kapisi_rihtim_3m`: deniz kapısı kemeri ortak kalem (eskisi seyrek iri kırmızı kutular); kanatlar SeaWalls'ın eski
  levhası (kötü, başka dosya); tuğla gece kızıl.
- `k2_deniz_kapisi_8m`: kemer ve söve; kutu yok.

**Bölüm 30o (gece)** — `kare/30o/`
- `p1_pavez_4m`, `p2_pavez_ova`: pavezin arkası dar tahtalı, damarlı (eskisi düz soluk levha); kutu değil, ayağı zeminde.
- `p3_sur_yolu`: sur yolu döşemesi gerçek ölçü (eskisi iri kare); meşale ışığında turuncu (ışık bölümün).

**Şehir (v2 dünyası, `tests/_ist/gezi.tscn`, Haliç dilimleri 12 ve 22)** — `kare/sehir/`
- `h_12_denizden_14m`, `h_22_denizden_14m`: kule kaideli (su çizgisi), yeşil kutu yosun bandı ve havada duran mermer kütük
  yok; kule deniz kalemi; aynı ressam.
- `h_12_denizden_70m`: kule tepesi konsollu + harpuştalı dişler (eskisi düz kutu tepe, seyrek kutu diş).
- `h_12_sehirden_9m`: şehir yüzü aynı (gövde deseni), korkuluk kutu kapağı yok.
- `*_gece` (varsa): aynı kadrajlar gece.

**Sahibine** — `kare/sahip_1_yakin_sur.jpg` (sur yolu, harpuşta, döşeme), `sahip_2_kapi.jpg` (8y şehirden iç kapı),
`sahip_3_sehirden_halic.jpg` (Haliç dilimi 22, denizden 14 m), `sahip_4_gece.jpg` (kemer, gece).

## Bütçe (ilkel = RenderingServer ilkel sayısı, 4 kare ortalaması; çizim çağrısı)

| kare | ÖNCE ilkel | SONRA ilkel | fark | çizim ÖNCE→SONRA |
|---|---|---|---|---|
| yakın k1 kemer 3 m (gündüz / gece) | 168 006 / 176 662 | 171 862 / 178 898 | +%2,3 / +%1,3 | 139→134 / 146→140 |
| yakın k2 kapı 10 m | 248 270 | 252 018 | +%1,5 | 230→222 |
| yakın k3 kanat 1 m (gündüz / gece) | 155 586 / 135 378 | 157 806 / 137 598 | +%1,4 / +%1,6 | 235→226 / 216→207 |
| yakın k4 dış kapı | 208 342 | 209 050 | +%0,3 | 137→130 |
| yakın h1 harpuşta 0,6 m | 273 202 | 268 794 | −%1,6 | 133→126 |
| yakın h2 / h3 / d1 / d2 / g1 | 334 145 / 320 235 / 253 098 / 357 491 / 358 769 | 333 361 / 321 071 / 249 088 / 358 327 / 354 759 | −%0,2 / +%0,3 / −%1,6 / +%0,2 / −%1,1 | ≈ aynı |
| 8y 01 / 03 / 06 | 1 992 807 / 2 089 615 / 2 816 857 | 2 009 491 / 2 088 963 / 2 821 703 | +%0,8 / −%0,0 / +%0,2 | 1995→1992 / 1786→1769 / 1109→1102 |
| 12b 06 / 02 | 2 141 107 / 1 602 291 | 2 135 933 / 1 613 449 | −%0,2 / +%0,7 | 4182→4150 / 4040→4024 |
| 38o k1 / k2 (gece) | 6 333 289 / 1 266 073 | 6 333 277 / 1 265 045 | %0,0 / −%0,1 | 4136→4137 / 885→883 |
| 30o p1 / p2 / p3 (gece) | 3 778 951 / 2 937 891 / 2 295 042 | 3 792 515 / 2 962 531 / 2 305 078 | +%0,4 / +%0,8 / +%0,4 | ≈ aynı |
| şehir Haliç 12 denizden 14 m / 70 m / şehirden 9 m | 1 001 288 / 1 161 647 / 1 830 566 | 1 006 028 / 1 166 319 / 1 834 634 | +%0,5 / +%0,4 / +%0,2 | 592→553 / 591→516 / 647→583 |
| şehir Haliç 22 denizden 14 m | 2 521 248 | 2 521 292 | %0,0 | 720→682 |

Hepsi ≤ +%5 (en yüksek +%2,3); çizim çağrısı her karede aynı ya da az (kemer 44 kutu + 44 dış çizgi → 1 ağ; Marmara kutu
süsleri kalktı). Not: 38o/30o kareleri kule kapısı kemeri değişikliğinden önceki kodla (o kemer yalnız kara surunda).

## Testler (`~/is/kopya`, `--max-fps 20`, tam süzgeç)
- **Bölümler ×1** (`testler/c*.ozet`): 0, 4, 6, 7, 8y, 8y `--yenisur=8y`, 10, 11, 12b, 17, 17o, 18b, 19, 20, 20o, 25, 26, 26o,
  28o, 29, 30, 30o, 37o, 38o, 43o, 44b — **26/26 AUTOTEST PASS**, bitmeyen 0, sorun satırı 0; tek ek satır 8y yeni sette
  `VISAUDIT float … Station_coil_rope` (DÜZELTME 6: tabanda da var, TAŞIMA 12'nin).
- `SURSOZLESME PASS kalem=13 kesim=8` · `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` · `WALKTHRU OZET yol=7 tamam=7
  takilma=0 dusme=0` · `ESYATEST PASS` · `HALICSONDA OZET carp=661 karma=3854034809` · **`MARMARASONDA OZET carp=1837
  karma=2250736444` (ÖNCE = SONRA)** · `MENURETURN PASS from=res://scenes/chapter26.tscn` · `PARSECHECK PASS scripts=368`
  (`testler/son_testler.txt`).
- **zfight** (`tests/zfight_check.gd`) 25 bölüm sahnesinde `found=0`.
- Bölüm koşuları kanat damarı sabitleri ve döşeme yerel çerçevesinden önceki kodla; o iki değişiklik yalnız görünüş (doku
  sabiti, gölgelendiricide koordinat); son kodla 26 ve 8y (yeni set) yeniden koşuldu (aşağıda).
