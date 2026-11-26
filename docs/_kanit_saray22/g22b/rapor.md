# G22b rapor — sur ardı dolgusu (eski hub dairesi, iç mahalle köşeleri, döşeme kenarı)

Dal `wip/saray22`, taban 37ae2b7d. Kanıt `docs/_kanit_saray22/g22b/` (kareler `kare/once`, `kare/sonra`, sahibe dört
yan yana kare `kare/sahip_*_once_ust_sonra_alt.jpg`; ham test çıktıları `testler/`).

## Özet

- **Kök neden ölçüldü (D1):** uzak hub öğesi `hub_sehir` (r 50, `gercek_olcu` yok) `IstSokak._taban_kayitlardan`'da
  54 m'lik occ=3 dairesi basıyor. Dairede hub yereli x < 17 kısmında 1601 hücre boş kalıyordu; ÖNCE 10 m'lik karelerin
  **38/38'i boş**, kare 01'in bakışında sur ile kamera arasında **50 m** kesintisiz çimen (`testler/sonda_23_once.txt`).
- Daire **küçültülmedi** (D2). Yeni geçiş `IstSokak._hub_dolgu()` `_ogeler(rng)`'den SONRA, önbellek yazılmadan önce,
  kendi rng'siyle (tohum 1453022), yalnız dairenin (ve iç mahalle taban dikdörtgeninin) occ=3 hücrelerine yazıyor;
  kayıtlar listelerin sonuna ekleniyor.
- **SONRA:** boş 10 m kare **0/38** (hub), **0/24** (iç mahalle köşeleri); en uzun çıplak çimen **9,5 m** (eşik 12);
  kapı → uc → iç sokak ağzı hattında occ=1 kopukluğu **0**; senaryo yerleri **55/55 ≥ 3 m**; önek karmaları birebir aynı.

## Ne yapıldı

| İş | Durum | Not |
|---|---|---|
| 1. Hub dairesini doldur | TAMAM | yol, nöbet açıklığı, 6 köy evi (+1 avlu), kuyulu meydan, harabe adası (harabe_kemer), 6 duvarlı/çitli yama (bostan/bağ/bahçe), 30 küçük öğe (bostan köşesi, ağaç kümesi, kuyu, odun/saman/taş yığını, el arabası, bağ kulübesi, çiftlik) |
| 1. Kapıdan yola gerçek yol | TAMAM | `hub_yolu` 7 m taş yol: sur parçasının sokak ağzından (x 17,6; z −14,25) batıya düz, sonra kavisle G21'in bağlantı yoluna (daireden çıktığı ilk yol hücresi J). İki yanında ev, avlu duvarı, yama duvarı/çiti, ağaç. Kare 01 ve 6/04'ün kamerası yolun üstünde |
| 1. Nöbet açıklığı (x 2…14) | TAMAM | toprak (kimliksiz yol hücresi), sur onarım şantiyesi seti, sığınmacı çadırları seti (ocak, kazan, sandık, yatak), ağıl; x 14…17 döşemenin önü toprak (yalnız zemin) |
| 2. Senaryo yerleri boş | TAMAM | liste ve ölçüm aşağıda |
| 3. İç mahalle köşe üçgenleri | KISMEN | IC_RECT'in 3 m dışındaki occ=3 hücreleri doldu (toprak + 7 yama + 55 küçük öğe), `_saray_yolu` sokak ağzına uzatıldı. Görünüş seyrek: aşağıda "hâlâ kötü" |
| 4. Döşemenin keskin kenarı | TAMAM | `ByzCity._build_kenar`: 70 m boyunca alçak yontma bordür taşları (tek ağ, tabanı −0,45: bölümdeki oluk ve uçuştaki düzleme aynı taşla kapanır), önünde toprak (v2), döşemenin kenarında odun, çuval, sandık (Dressing; ayrılmış dikdörtgenlerin dışında) |
| 5. Eski dünyada iç mahalleye yol | YAPILMADI | 43o drone karesinde eski hub yeri çayır değil (bej toprak, CityPlan yolları; `kare/once|sonra/43o_*`), D18'in koşulu yok. CityPlan'a dokunmadan WallRear süslemesi + harita pişirmesi 1 saati aşacaktı; yapılmadı |

### Kod (taban 37ae2b7d'ye göre)
- `scripts/world/ist/sokak.gd`: `_hub_dolgu` (2108–), `_hub_yolu`, `_dolgu_yamalari`, `_dolgu_kumeler`, `_saray_dolgu`,
  `_toprak_disc`, `_hepsi_bos`/`_bos_mu` (`_izin`: yalnız dolgu hücreleri), `cell_taban` (dolgudan önceki hücre değeri),
  `dolgu` alanı `_OB_ALANLAR`'da (D12: önbellekten okuyan koşuda da dolgu var; soğuk ve sıcak koşuda aynı kareler).
  Çağrı `_build_hesapla`'da `_ogeler`'den sonra (630).
- `scripts/world/ist/mahalle_doku.gd`: dolgudan önceki döşeli meydan diskleri (hub_sehir'in "eser meydanı" r 63) dolgu
  hücrelerini boyamaz (yoksa nöbet açıklığı ve yamalar taş döşeme altında kalıyordu); dolgu hücrelerinin zemini +3,5 cm
  (bölümde arazi hub düzleminin 5 cm altında, zemin 1 cm altında kalıp görünmüyordu: `testler/yukseklik_7_23.txt`).
- `scripts/world/ist/ayrinti_sokak.gd`: dolgu evlerinin sokak eşyası meydanlardan sonra ayrı rng ile; eski kayıtların
  yer denetimi `cell_taban` ile. Sonuç: eski evlerin eşyası 6437 = 6437, meydan eşyası 382 → 387 (yalnız yeni meydanın 5'i).
- `scripts/world/ist/sehir.gd:3414, 3457`: eski yamaların kenar ağacı denetimi `cell_taban` ile (rng sırası aynı).
- `scripts/level/byz_city.gd`: `_build_kenar`, `_bordur_tas` (yalnız bölünmüş sur parçası zemininde).
- `tests/_ist/g22b_sonda.*` (ölçüm + yürüyüş), `tests/_ist/g22b_kare.*` (kareler).

## Senaryo yerleri (D15; v2 çerçevesinde, `SurHub.hub_v2()`; en yakın YENİ dolgu kaydının ayak izine uzaklık, m)

Ayak izleri: ev (dikdörtgen + 1,4 m), yama (+1,2 m), set (yerleşim tablosu × 1,2 + 1,2 m), ağaç kümesi r 8,5, ağıl r 5,
kuyu/kulübe r 2,8, yığınlar r 1,8, avlu, meydan r 6. 55 yerin hepsi ≥ 3 m (`testler/sonda_23_sonra.txt`).

| Yer | Yerel | En yakın | Kayıt |
|---|---|---|---|
| 6b tünek 0–3 | iç (0,−16) (−4,8,−15,2) (0,9,1) (8,5,−18,5) | 23,4 · 27,6 · 22,0 · 15,9 | iç köşe öğeleri |
| 6b tünek 4 (fıçı) / 5 (masa) | hub (21,5,−10,5) / (24,6,−12,4) | 15,4 / 18,6 | çadır / şantiye seti |
| 6b kararma sonrası "fıçıya ~11 m" | hub (20,0,4) | 6,6 | çadır seti |
| 6b/10h sokak ağzı yerleşmesi | hub (20,−14) | 14,9 | şantiye seti |
| Giustiniani yanı ×2 (6b), GIUST_POS, 7b "walls" izi | hub (22,5…26,−11,5…−14) | ≥ 16,7 | set |
| Kapı yanı, Niko kapıda (6b), EXIT_POS, 7b "outside" izi, 10h kapıdan giriş | hub (27…33, 4…7) | ≥ 13,2 | çadır seti |
| 10h gece Niko / gedik | hub (22,9,−8,3) / (32,4,−26) | 14,4 / 18,5 | set |
| 6b martı/bakış sur noktaları | hub (30,−14) (34,−14) | 21,0 / 24,2 | set |
| `_dress_bolunmus` ayrılmış dikdörtgenlerin 20 köşesi | hub x 17,5…36 | en az 4,4 | çadır seti |
| START, rapor kapısı, 13 doğuş, EMPEROR, NIKO, hücre, 7b kançılarya izi, 24 ROUTE_A/B | iç | ≥ 11,9 | iç köşe öğeleri |
| IC_RECT dört köşesi, iç sokak ağzı | iç | 7,7 · 5,1 · 3,2 · 4,3 · 8,2 | iç köşe öğeleri |

- Dolgunun hub yereli en doğu ucu x 14,3 (ağıl, kaba r 5 ölçüsüyle; gerçek çit halkası x ≤ 13,8). Sur parçası x ≥ 18.
- Otomatik test yolları (6b `byzyuru`, 10h gece işleri, 7b izleri) bütünüyle sur parçasında ya da iç mahallede; dolgu
  onlara en az 4 m uzak. Oyuncunun kapı → yol → saray hattı dolgunun yoludur (evlerin cephesi yol kenarından 0,9 m geride).

## Sayılar

- **Önek karması (D5)**, 37ae2b7d ile birebir (`testler/sonda_23_once.txt`, `sonda_23_sonra.txt`):
  streets[0:1098] `7a8b05b3…`, houses[0:8306] `5a763cea…`, doku[0:125] `2b88f632…`, oge[0:403] `0e8aca49…`,
  avlu[0:1023] `3084653d…`, meydan[0:86] `dbaeab54…`. Yeni: 3 sokak, 6 ev, 14 doku, 107 öğe, 1 avlu, 1 meydan.
  Dürüst not: `IstCati` önbellekten sonra 12 çatı rotası evini listenin sonuna ekliyor; dolgu evleri onlardan önce
  geldiği için bu 12 evin dizini 8306 → 8312 kaydı (içerikleri aynı; eşyaları `ayrinti_sokak`'ta eski sırayla işleniyor).
- **D19:** (a) çıplak çimen en uzun 9,5 m (ÖNCE 50 m); (b) boş 10 m kare 0/38 ve 0/24 (ÖNCE 38/38, 24/24);
  (c) ISTBOS `gezi bos=1` şehir içi 10/1109 = %0,9, G21/G22 ile aynı (gezi sahnesi v2'yi bağlamasız kurar: hub orada
  bölünmemiş, dolgu kurulmaz; örnek boş kareler hub'dan uzakta). Dolgu bölgesinin kendi sayımı %0. (d) occ=1 kopukluğu 0,
  yol genişliği ≥ 3,0 m (2 m ızgarada).
- **D6 kalabalık** (CITYCHECK, ÖNCE taban ağacında | SONRA; noktaların biri her koşuda başka yerde):
  24 → 12 / 16 / 14 | 13 / 19 / 21; 31o → 15 / 19 / 15 | 16 / 18 / 20. Azalma yok, eşik 8 gevşetilmedi.
- **Çizim (D20)** açılış kareleri: 23/01 ÖNCE 1102 çizim / 1,59 M üçgen → SONRA 1176 / 1,83 M; 6/04 ÖNCE 1083 / 1,56 M →
  SONRA 1177 / 1,83 M (+%7–9 çizim, +%15–17 üçgen: yolun iki yanındaki evler ve yamalar ilk bakışta).
- **Yükleme** (load_time, tek başına; ms, `testler/yukleme.txt`): 24 51 790 → 39 010; 23 40 298 → 37 332;
  10h 37 814 → 38 941; 6 8 791 → 8 986. Soğuk (`--onbellek=yaz`) 24: 57 774. Belirgin artış yok (ilk ÖNCE 24 koşusu
  taban ağacının soğuk önbelleği; gürültü ±%5).

## Testler (`--max-fps 20`)

- Sözleşme altılısı birebir: SURSOZLESME PASS kalem=13 kesim=8 · SUROYUN 519/0/0/0 · WALKTHRU 7/7/0/0 · ESYATEST PASS ·
  HALICSONDA 661/3854034809 · MARMARASONDA 1837/2250736444.
- Hub bölümleri bütün çeşitleriyle ×2: 6 byz/byzmistake/byzfail/byzclimb/byzgive, 7 byz/byzniko/byzcell, 10h 7 çeşit,
  12b 5 çeşit, 13 city, 23 6 çeşit, 24 5 çeşit → **64/64 AUTOTEST PASS**; VISAUDIT, WALKTHRU, HELDAUDIT, ARMAUDIT,
  GORUNMEZZEMIN, ALETAUDIT, DONUKAUDIT, ESYAAUDIT (dusme/havada/gomuk/tikama/sinir), JOURNEY, YUKLEMEAUDIT_KESIN,
  SCRIPT ERROR satırı **0**. Son kod düzeltmesinden (dar öğe çeşitleri) sonra 23, 24, 6 byz, 7 byz, 10h, 12b, 13 city
  bir kez daha: 7/7 PASS.
- G22'nin 14 dünya bölümü ×1 (6, 7, 8y, 9, 10, 10b, 10z, 11, 13, 16, 24o, 25 osm, 31o, 43o): 14/14 PASS, denetim satırı 0.
- Eski yollar (D17): `--eski-dunya` hub 7/7 PASS, `--saray-eski` (23) PASS, `--eskisur=12b` PASS; sondada üçünde de
  dolgu boş (`testler/d17_eski_yollar_dolgu.txt`). Koşul kodda açık: `_hub_dolgu` `SurHub.uzak_yeni()` yanlışsa,
  `--saray-eski` varsa ya da hub oyun alanı sur parçası değilse (31o) çıkar.
- PARSECHECK PASS (370), CITYCHECK 24 ve 31o PASS, STREETCHECK PASS, WORLDCHECK PASS regions=13, WALKCHECK PASS,
  FLIGHTCHECK PASS, MAPCHECK PASS, ZFIGHT 0 (6, 7, 10h, 12b, 13, 23, 24), menu_return 26 ve 20o PASS.
- Harita: eski dünyada değişen yalnız sur parçasının bordürü (3B); `map1453.png` yeniden pişirilmedi, MAPCHECK PASS.
- **D16 yürüyüş sondası** (`g22b_sonda yuru=1`, `testler/yuruyus.txt`): kapının şehir yanı → döşemeden bordürle inip
  toprak kenar → sokak ağzı → hub yolu → bağlantı → saray yolu → iç sokak ağzı, 6 m'de bir 82 nokta, 450 m.
  10h'de: düşme 0, takılma 1 — o da bölümün kendi akışı (10h kapıdan girişte kararma ile oyuncuyu saraya ışınlıyor;
  noktadan sapma sondada takılma sayıldı). 23'te hub kesiminde 5–6 "düşme" çıkıyor, **taban ağacında aynı hat çayırın
  üstünde de aynısı** (`yuruyus.txt` sonu): 23'ün kamerası saray avlusunda kalırken oyuncu hub'da yürütülünce oyuncu
  arazi çarpışmasının ~1,6 m altında başka bir yüzeyde ilerliyor; dolguyla ilgisi yok, 23'te oyuncu sur parçasına gitmez.
  En dar geçit ≥ 3,0 m.

## Kareler (`kare/`, tam boy, ÖNCE taban ağacında aynı araç ve kamerayla)

- Sahibe: `sahip_1_v2_23_01_caddeden_sur`, `sahip_2_v2_6_04_ilk_bakis`, `sahip_3_uzak7_04_iki_parca`, `sahip_4_v2_23_05_tepeden`
  (üst ÖNCE / alt SONRA).
- v2 23: 01, 05, 11 yoldan kapıya (göz 1,7 m), 12 yoldan saraya (göz 1,7 m, J noktasından), 19/24 tepeden, 20 saray köşeleri,
  25/26/27 kapı önü ve nöbet açıklığı, 28 yolun batısı; yalnız SONRA: 17, 18 bordür, 30 bostan, 31 bağ, 32 meyve bahçesi,
  33 harabe, 34 ev (0,5–3 m yakın).
- v2 6/04 (6'nın ilk bakışı), uçuş 7a: 03, 04, 29 dik, 30 bant, D13 21/22/23 (150 m, 400 m, 1 km).
- 43o drone iki yol (`taze_*`, `v2_*`): drone70 Romanos, drone90 saray, saray yakın/göz, sur parçası.

## Hâlâ kötü (dürüst)

- **Uçuşta (7a) hub dairesinin sur yanı hâlâ yeşil.** Uzaktan (sahip_3) dairenin batı yarısı dolu görünüyor, sur dibi
  yeşil kalıyor. Nedeni dolgu değil, arazinin uzak katmanı: `IstDunya` yakın parçaları izleyicinin çevresinde 6 m
  ızgarayla kurar, uzakta 12–48 m; hub düzlemesi (r 48) kaba ızgarada çevredeki 2–3 m yüksek doğal araziyle karışıp
  düzlemin ve döşemenin üstüne çıkıyor (çarpışma doğru: 13,968). G22'nin `v2_uzak7/02_uzak_hub_kapi` karesinde sur
  parçasının döşemesi de aynı nedenle gömük. Düzeltme `dunya.gd`'de (bu görevin dosya listesi dışında); ayrı iş.
  Ayrıca uçuş bölümünde toprak zemin yöre paletiyle yeşile çalıyor.
- **İç mahalle köşeleri seyrek:** dikdörtgenin 3 m dışında büyük yama konamıyor (bölümde `_temizle` doku öğelerini
  IC_RECT + 8 m içinde siler, geriye boş duvar kalırdı); köşeler toprak zemin + küçük öğeler (kuyu, yığın, el arabası,
  kulübe) ve 7 yama. Havadan bakınca hâlâ geniş bir toprak halka.
- Yama içerikleri (bostan sıraları, bağ kazıkları) akışla geliyor: tepeden bazı karelerde yalnız duvar/çit görünüyor.
- Harap kilise konamadı: dairede 19 × 25 m yer var ama 100 m kuralı (`_harap_kilise_yok`) G21'in yakındaki harap
  kilisesi yüzünden reddetti; yerine harabe adası (`harabe_kemer`, 14 × 8 m) kondu (D9'un izin verdiği seçenek).
- Yolun ilk kesimi (x −24'e kadar) cetvel düzü; kavis yalnız bağlantıya doğru.
- Kenarın bordürü uzakta (43o) ince açık bir çizgi gibi okunuyor.
- Eski dünyada iç mahalleye yol yok (iş 5 yapılmadı, yukarıda).
- `kare/once/uzak7_*` ve `sonra/uzak7_*` her bakışta 14 sn bekledikten sonra çekildi (G22'nin uzak karelerinden farklı
  bekleme; ÖNCE de aynı araçla yeniden çekildi).
