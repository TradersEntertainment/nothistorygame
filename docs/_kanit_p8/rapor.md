# P8 — Şehir içi: alay, sağanak, kilise, yangın (24, 25, 23, 10h, 12b, 31o, 39o)

Dal: `wip/yardimci-p8` (başlangıç kaydı `1e3a9b60`). Değişen dosyalar yalnız `scripts/chapter24.gd`, `chapter25.gd`,
`chapter23.gd`, `chapter10h.gd`, `chapter12b.gd`, `chapter31o.gd`, `chapter39o.gd`. Ortak dosyaya ve
`byz_city.gd`/`ayasofya.gd`/`petrion.gd`'ye dokunulmadı. Yeni `class_name` yok, replik/oynanış/sayaç/kalabalık sayısı
değişmedi, denetim susturulmadı (`no_audit` vb. eklenmedi). Geçici sonda kancaları (`P8SONDA`) kare ve ölçüm için
eklenip söküldü: `grep -rn "P8SONDA\|P8DBG\|_p8(" scripts/` boş.

## Kanıt yöntemi
- **Önce:** başlangıç kaydının kopyası (`/tmp/p8/base`, yalnız aynı sonda kancaları eklenmiş; kancalar dışında
  özgünle bayt bayt aynı). **Sonra:** bu daldaki son kod.
- Oyun kareleri: `PACE=1` ekranlı koşu, `--dialogshots --shotevery=1` (replik anahtarıyla aynı an), gerektiğinde
  `--snapevery`. Yakın plan: `--shots` düzeninde aynı sabit kamera (24 alay) ya da iki sürümde **aynı kod noktasına**
  konmuş sonda (oyuncu kamerası ya da sabit yan kamera). 31o kiriş/ip çiftleri `--snapevery` oyun karesidir: iki koşu
  aynı hızda ilerlemediği için ~9-10 sn kayık, aynı evrenin aynı durumundan (sayaç 2/3, indirme ortası) seçildi.
- Paftalar bu klasörde (13 adet, her biri ≤ 300 KB): sol ÖNCE, sağ SONRA.

## Madde tablosu
| # | Bölüm · madde | Ne yapıldı (dosya:işlev) | Kanıt paftası | Durum |
|---|---|---|---|---|
| 1 | 24 ikona taşıyıcılarının elleri sırıkta değil (sırık omuzdan/başın arkasından geçiyordu) | `chapter24.gd:_build` — her taşıyıcıya `Stage.grip_hold(b, litter, [sırıkta omzun önü])`: sağ el sırığı omuz hizasında kavrar, sedyeyle birlikte gider | 01 (3 taşıyıcı, yan sonda), 02 | DÜZELDİ |
| 2 | 24 sağanak: birikintiler kara delik gibi düz disk | `chapter24.gd:_wet`, `_puddle_mesh` — 34 ayrı disk yerine tek MultiMesh; içi gökyüzünü yansıtan açık gri-mavi su, kenarı yumuşak koyu ıslak hale | 02, 03 (yakın kırpma) | DÜZELDİ |
| 3 | 24 damlalar zemine sıçramıyor | `chapter24.gd:_storm` — sıçrama parçacığı ince, beyazımsı, dikine taç (`particle_flag_align_y`); `_rain_rings`: yağmur birikintilere halka açar (`Vfx.water_ring`) | 02, 03, 04 | DÜZELDİ |
| 4 | 24 ıslak kaldırımın kendisi (parlama) | Kaldırım malzemesi `byz_city.gd:set_wet`'te (dokunulmadı). Denediğim su filmi ve olukta akan su karede seçilmedi → **kaldırıldı** | 03 (kaldırım iki sürümde aynı) | DURUYOR (öneri aşağıda) |
| 5 | 24 D24_M_STOP (kabul karesi) ıslak zemin | Bu replikte kamera keşişe bakıyor, zemin kadrajda neredeyse yok; yalnız sıçrayan damlalar seçiliyor | 04 | KISMEN (zemin bu karede görünmüyor) |
| 6 | 25 cemaat sıra sıra aynı boy, kımıltısız | `chapter25.gd:_congregation` — 22 kişiden 6'sı diz çöker (`_kneel`: diz yerde, eller kavuşuk, baş kendi fazında eğilip kalkar), 4'ü elinde yanan mum tutar, boylar 0,93-1,05; kalanlar `Crowd.idle_vary` ile kendi zamanlarında haç çıkarır, başını sallar, iç çeker | 05 (yan sonda: diz çökenler ve mumlar; oyuncu bakışı D25_N_ISI) | DÜZELDİ (diz çökme, mum, boy). Haç çıkarma/baş sallama hareket olduğu için tek karede KANITSIZ |
| 7 | 25 mumluk mumları ve elde mum (çizim bütçesi) | `chapter25.gd:_candles/_candle_put/_merge_lamp_flames` — mumluğun 18 ağı + eldeki mumlar + Ayasofya kandil alevleri (ayasofya.gd'nin ~100 ayrı küresi, çalışma anında gizlenip aynı yer/boyda) tek MultiMesh | 05 (kandil halkaları iki karede aynı) | DÜZELDİ (−80 çizim) |
| 8 | 23 kartvizit iki el arasında havada (elsiz kart, sonra 0,45 sn uçuş) | `chapter23.gd:_offer_card` — kart iki elin parmak uçları arasında (`player.hold_both`); `_give_card` — İsmail eğilip uzanır (`Stage.grip_hold`, kartın kenarı), kartı alır (`hold_item`, dönmeden), gövdesi doğrulur | 06 (D23_T_CARD, D23_I_CARD), 07 (geçiş anı: önce kart havada uçuyor) | DÜZELDİ |
| 9 | 23 muhafızlar ve saray erkânı donuk | `chapter23.gd:_build` — 9 mızraklı muhafız, 5 erkân, kâtip ve sarayın iki kapı muhafızı `Crowd.idle_vary` (baş sallama, fısıltı, iç çekme; rastgele faz) | — | KANITSIZ (hareket; tek karede gösterilemiyor) |
| 10 | 10h elçinin beyaz bayrak sırığı elde değil | `chapter10h.gd:_build` — `Stage.grip_hold(envoy, envoy, [sırıkta göğüs hizası])` | 13 | DÜZELDİ |
| 11 | 10h huzurdaki maiyet/muhafız donuk | `chapter10h.gd:_place_audience` — `Crowd.idle_vary` | — | KANITSIZ (hareket) |
| 12 | 12b Sfrancis'in rulosu üst kola bağlı (dirsek bükülünce havada kalır) | `chapter12b.gd:_build_wall_walk` — rulo önkolun ucunda, avucun içinde; nöbetçiler `Crowd.idle_vary` | — (D12B_K_COUNT'ta kol düz: iki sürümde rulo aynı yerde görünüyor) | KANITSIZ |
| 13 | 31o "kirişi kaldır": kiriş havada kalkıyor, elde kolonya şişesi | `chapter31o.gd:_hands_under_beam` — iki el kirişin altında (`hold_both`, hedef kiriş: kirişle birlikte kalkar), eldeki eşya cebe; bitince/süre dolunca `release_both` | 08 | DÜZELDİ |
| 14 | 31o kazı: elde kürek yok (kolonya şişesi), çukur çimenin ortasında düz disk | `chapter31o.gd:_shovel_tick/_shovel_place` — kürek dünyada, sap Tolga'nın beli önünde, ağız çukura; iki el sapta; E basılıyken it-kaldır-savur döngüsü, toprak yığına; uzaklaşınca kürek yere yatar. `_eyup_phase`: çukurun çevresine `ground_detail "camp_mud"` | 09 | DÜZELDİ |
| 15 | 31o mezarlık/tepe çıplak düz yamaç | `chapter31o.gd:_build_eyup` — `ground_detail` grass/tall_grass/stone (seyrek, düzensiz; kazı yeri ve işaretlerin dibi boş); mezar taşları 18 ayrı ağ yerine tek MultiMesh (aynı yer, renk, açı) | 11 | DÜZELDİ |
| 16 | 31o ip `_rope_between` düz silindir, üst ucu pencerenin dışında havada | `chapter31o.gd:_rope_between` — `Stage.rope`/`rope_to`: Tolga'nın iki eli → pencere eşiği (az sarkık) → çocuk (gergin); eller ipte (`hold_both`) | 10 | DÜZELDİ |
| 17 | 31o Kadri eli boş karıştırıyor | `chapter31o.gd:_build_street_people` — `kadri.give_tool("ladle")` | — (oyun karesinde Kadri kuyruğun arkasında kalıyor) | KANITSIZ |
| 18 | 39o ip pencereden sokağa düz silindir | `chapter39o.gd:_start_rope/_rope_between` — `Stage.rope`: Tolga'nın elleri → pencere direği → adamın göğsü; adamdan tayfanın iki eline kılavuz ip (`grip_hold`), artanı ayağının dibinde kangal (`Stage.rope_coil`); Tolga'nın iki eli ipte | 12 (sokaktan sonda) | DÜZELDİ |
| 19 | byz_city.gd:919 ressama fırça | Bölüm dosyasından denendi (`give_tool("brush")`), sis gününde +4 çizim getirdi → geri alındı | — | DURUYOR (öneri aşağıda) |

Ek bulgu (düzeltildi): 39o/31o ip ucunu kameradan hesaplamak, hızlandırılmış ekranlı koşuda kamera yüksekliği
salındığı için ipi yüzlerce metreye uzatıp belleği dolduruyordu (13 GB, OOM). El ucu gövdeden hesaplanıyor; 12 m'yi aşan
parça ağ kurdurmuyor. Özgün kodda bu yol yoktu.

## Testler (son kod, başsız, `--max-fps 20`, `timeout 420`)
`parse_check`: PARSECHECK PASS scripts=247.

| Bölüm | Varyant | Sonuç |
|---|---|---|
| 24 |  | PASS (24.1) |
| 24 | late | PASS (24.2) |
| 24 | niko | PASS (24.1) |
| 24 | niko_slow | PASS (24.1) |
| 24 | eclipse | PASS (24.1) |
| 25 |  | PASS (25.1) |
| 25 | caught | PASS (25.2) |
| 25 | pass | PASS (25.1) |
| 25 | kid | PASS (25.1) |
| 25 | osm | PASS (25.1) |
| 25 | osm_caught | PASS (25.2) |
| 25 | osm_tez | PASS (25.1) |
| 23 |  | PASS (23.1) |
| 23 | creative | PASS (23.2) |
| 23 | pass | PASS (23.1) |
| 23 | singed | PASS (23.1) |
| 23 | letter | PASS (23.1) |
| 10h |  | PASS (10H.1) |
| 10h | shame | PASS (10H.2) |
| 10h | save | PASS (10H.1) |
| 10h | save1 | PASS (10H.1) |
| 10h | honest | PASS (10H.1) |
| 10h | open | PASS (10H.1) |
| 10h | pass | PASS (10H.1) |
| 12b |  | PASS (12B.1) |
| 12b | lie | PASS (12B.2) |
| 12b | year | PASS (12B.3) |
| 12b | d2 | PASS (12B.1) |
| 12b | d3 | PASS (12B.1) |
| 31o |  | PASS (31O.1) |
| 31o | late | PASS (31O.2) |
| 31o | petrion_ok | PASS (31O.1) |
| 31o | petrion_bad | PASS (31O.1) |
| 39o |  | PASS (39O.1) |
| 39o | late | PASS (39O.2) |
| 39o | tezkire | PASS (39O.1) |
| 39o | pass | PASS (39O.1) |
| 39o | sailor_ok | PASS (39O.1) |
| 39o | sailor_bad | PASS (39O.1) |

Özet: 24 5/5, 25 7/7, 23 5/5, 10h 7/7, 12b 5/5, 31o 4/4, 39o 6/6 — toplam 39/39 AUTOTEST PASS.

Taranan satırlar: `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `VISAUDIT`, `WARN_VOID_TELEPORT`, `WALKTHRU`, `ARMAUDIT`,
`HELDAUDIT`, `JOURNEY_MISS`, `JOURNEY_OVERLAP` — hiçbir koşuda yok. Özgün kodla aynı 39 koşu da temizdi.

## Performans (aynı kod noktası, aynı kamera; `RenderingServer` çizim çağrısı ve ilkel sayısı)
Replik-hizalı RINFO bu makinede kullanılamadı (yazılım çizici <1 FPS, iki saniyelik örnekler seyrek). Bunun yerine her
evrede iki sürümün aynı kod noktasına konmuş sondası, aynı kare. Rastgele öğeler (yürüyen halk, közler, Vfx) yüzünden
aynı sürümün iki koşusu arasında da fark var; 31o ve 39o iki-üç kez ölçüldü (aralık verildi).

| Evre (sonda) | Çizim önce → sonra | Üçgen önce → sonra (bin) | Not |
|---|---|---|---|
| 24 sağanak başı (oyuncu bakışı) | 2394 → 2173 | 4057 → 3783 (−6,8%) | birikintiler tek ağ |
| 24 sel, D24_M_STOP | 2171 → 2160 | 3944 → 3901 (−1,1%) | |
| 24 sisli gün | 5165 → 5165 | 1401 → 1401 (0%) | |
| 25 ayin başı (yan sonda) | 11866 → 11786 | 10958 → 10956 (0%) | kandil alevleri tek ağ |
| 23 kart uzatılırken | 2870 → 2856 | 4475 → 4337 (−3,1%) | |
| 23 kart alındıktan sonra | 2920 → 2923 | 4386 → 4411 (+0,6%) | +3 gürültü sınırında |
| 10h kapı (elçi) | 5439 → 5437 | 4893 → 4853 (−0,8%) | |
| 10h huzur | 2250 → 2252 | 2660 → 2664 (+0,1%) | +2 gürültü sınırında |
| 12b sur | 5977 → 5977 | 5734 → 5734 (0%) | |
| 31o sokak | 5834–5873 → 5823–5931 | 7313–7336 → 7323–7386 (≤ +1%) | gürültü |
| 31o yanık ev, kiriş | 977–978 → 1000–1015 | 996–1013 → 999–1013 (≤ +1,7%) | **+22…+38** |
| 31o pencereden indirme | 3294–3312 → 3342–3381 | 4188–4206 → 4267–4282 (≤ +2,2%) | **+30…+87** |
| 31o Eyüp yamacı | 5860 → 5840 | 7436 → 7446 (+0,1%) | mezar taşları tek ağ |
| 31o kazı | 606–614 → 622 | 780–802 → 799–817 (≤ +4,8%) | **+8…+16** |
| 39o ipten indirme (sokaktan sonda) | 2892–2986 → 2834–2901 | 2475–2600 → 2491–2553 (≤ +3%) | gürültü |

Üçgen artışı her evrede ≤ +%8. Çizim sayısı 24, 25, 23, 10h, 12b, 31o sokak/Eyüp ve 39o'da artmadı (24 ve 25'te belirgin
düştü). **31o'nun iki elle tutulan üç anında (kiriş, ip, kazı) çizim sayısı +8…+87 arttı (%1-3)**: bu anlarda ikinci el
(player.gd'nin sol el modeli: avuç, parmak boğumları, başparmak, kolluk; her biri ayrı ağ ve dış çizgi) görünür hâle
geliyor. Ellerin gölgesini kapatmayı denedim, ölçülür etkisi olmadı, geri aldım. Bu anlarda karşılayacak bölüm-içi
birleştirme bulamadım → bütçe bu üç anda **aşılıyor** (aşağıda ortak dosya önerisi).

## Ortak dosyalar için öneriler (dokunulmadı)
- `byz_city.gd:915-919` (ressam): `painter.set_activity("paint")` satırından sonra `painter.give_tool("brush")`. Bölüm
  dosyasından eklemek sis gününde +4 çizim getirdi; ortak dosyada `_build_painter`'ın kendi parçalarından biriyle
  (ör. şövale ayakları) tek ağda birleştirilerek bütçe korunabilir.
- `byz_city.gd:set_wet` (ıslak kaldırım): bugün yalnız albedo koyulaşıyor ve pürüzlülük düşüyor; gl_compatibility'de
  yansıma olmadığı için parlama seçilmiyor. Öneri: ıslakken kaldırım desenine gökyüzü renginde hafif bir `rim`/
  `emission` katkısı (`_ground_mat.rim_enabled = true; rim = 0.35 * k; rim_tint = 0.6`) ya da yüzeye ikinci, çok soluk
  açık gri-mavi bir geçiş (`next_pass`). Tek malzeme değişikliği, çizim sayısı değişmez.
- `ayasofya.gd:_lamps`: kandil alevleri ve camları ~200 ayrı ağ. 25'te çalışma anında alevleri tek MultiMesh'e aldım
  (−80 çizim). Aynısı ortak dosyada yapılırsa Ayasofya'yı gösteren her bölüm (24 sis günü, 25, hub) kazanır; camlar
  (`Props.cyl ... 0.07`) da ayrı bir MultiMesh olabilir.
- `player.gd`/`hand_rig.gd`: sol el (free_hand) modeli parça parça; `hold_both` her kullanıldığında ~20-40 çizim
  ekliyor. Parmak boğumları tek ağda (köşe ağırlıksız, poz başına yeniden kurulan ArrayMesh ya da pozlar arası birkaç
  hazır ağ) birleştirilirse 31o, 38o, 30 gibi iki elli tutuşlar bütçeyi aşmaz.

## Bakamadıklarım / açık kalanlar
- Kıpırtı maddeleri (23 muhafız/erkân, 10h maiyet, 12b nöbetçi, 25'te haç çıkarma): kod ve testler var, tek
  karede hareket kanıtlanamıyor → KANITSIZ.
- 31o Kadri'nin kepçesi ve 12b rulosu: karede seçilmiyor → KANITSIZ.
- 24 ıslak kaldırımın kendisi: DURUYOR (ortak dosya).
- 31o iki elli anlarda çizim bütçesi aşımı (yukarıda).
- Sonda kareleri hızlandırılmış (`PACE`siz) koşudan; kabul kareleri (D24_M_STOP, D23_T_CARD, D25_N_ISI, 31o kiriş/ip)
  gerçek hızlı (`PACE=1`) koşudan.
