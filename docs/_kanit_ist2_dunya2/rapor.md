# İstanbul v2 — DÜNYA-2 (ikinci tur): rapor

Dal: `wip/ist2-dunya2` (taban `wip/ist2-taban2`; `wip/ist2-sehir2` ve `wip/ist2-doku2` birleştirildi). Görev:
`docs/_ajan/gorev/ist2_tur2.md` "DÜNYA-2"; sayılar `_ist2_ortak.md` "SON AYAR". Dosyalar: `scripts/world/ist/geo.gd`,
`scripts/world/ist/dunya.gd`, `tests/_ist/gezi.gd` (+ `gezi_sahip.txt`, `gezi_sahip_gece.txt`: sabit sahip kareleri listesi).

## Durum

| # | Madde | Durum |
|---|-------|-------|
| 1 | `IstGeo.S = 0,35`; bütün tablolar gerçek koordinattan | DÜZELDİ (ilk gönderim ~25. dakikada) |
| 2 | `mahalle(x,z)` yeniden dağıtım (sura kadar dolu, adalar, ayrı türler, sur dışı/karşı kıyı türleri) | DÜZELDİ (harita + sayım aşağıda) |
| 3a | Batıdaki dikdörtgen koyu mavi alan | KISMEN: arazi tarafında yok (şehirsiz tam tepe karesinde mavi dikdörtgen görünmüyor; bütün çekirdek parçalar kuruluyor); şehirli tam tepede görülen koyu dikdörtgenler şehir/parça tarafının (aşağıda ORTAK BİLGİ) |
| 3b | Kıyı basamaklı | DÜZELDİ / küçük dişler KISMEN (kıyı şeridinde yükseklik kıyı çokgenine işaretli uzaklıkla, sürekli profille) |
| 3c | Zemin tek renk yeşil | DÜZELDİ (türlere göre renk + tarla parselleri; ayrıca uzaklıkla süt beyazına dönme giderildi) |
| 4 | Karşı kıyılar ve ufuk dolu, Kız Kulesi | DÜZELDİ (31 768 öğe; Kız Kulesi küçük kale) |
| 5 | `kare40`, gezi `bos=1` (ISTBOS) | DÜZELDİ; şehir içi %5,5 (hedef %0) → ŞEHİR/DOKU'ya rapor |
| 6 | 14 sahip karesi | DÜZELDİ (`sahip_01…14`, 2. yenileme; 07 meydanın üstünden, 09 iskeleden) |
| 7 | Uçuş bölümleri (7, 11) v2 dökümü | DÖKÜM (aşağıda; uygulama yok) |

## 1. Ölçek: `IstGeo.S = 0,35`, tek sabit

- `const S := 0.35` tek sabit (0,25–0,5 arası değiştirilebilir). Kıyı çokgenleri, sur/yol çizgileri (`R_YARIMADA`, `R_KARA`, `R_MESE`…)
  artık GERÇEK (e, n) metre; dünya tabloları (`K_*`, `Y_*`) açılışta `_wl(R_*)` ile S'den türer. Önceden çarpılmış tablo kalmadı.
- Arazi ızgarası gerçek koordinatta tanımlı: `GE0 = −12 000`, `GN0 = 11 000`, `GST = 20 m` (1201 × 1001); değerler `VERI_S = 0,5`
  ölçeğinde saklı, `h_ham` S/VERI_S ile çevirir (yükseklik = gerçek × S). `X0`, `Z0`, `ST` (dünya) `static var`, S'den türer.
  Dünyada ızgara hücresi 7 m (önceden 10 m).
- `mahalle`, `KOYLER`, `MAH_OZEL`, ada ızgarası: bütün eşikler gerçek metre. `IstDunya` çekirdek parça ızgarası gerçek kapsamdan
  (e −6144…+4608, n −3072…+6144) türer: S = 0,35'te 5 × 5 parça (768 m); kıyı kumu, renk desenleri gerçek metre.
- Yer dizini (`yerler()`) gerçek e, n tutar, `w` S ile.

## 2. `mahalle` (kalite notu 0b)

Harita: `mahalle_harita.png` (gezi `kip=harita`; renk: kırmızı çarşı, turuncu sık, kahve sur dibi, mavi liman, yeşil bostan/bağ,
gri harabe, koyu yeşil sarnıç, mor ordugâh, pembe köy, zeytin bağ, koyu orman, açık kir/tarla).

Şehir içi 10 m hücre sayımı (`HARITA` satırları):

| tür | oran |
|---|---|
| sik (orta–sık doku, yoğunluk 0,6–0,92) | %72,6 |
| carsi (Mese boyu ±70 m gerçek, Galata merkezi) | %7,7 |
| sur_dibi (kara suru iç yüzü 110 m, Marmara suru 70 m gerçek; yoğunluk 0,7–0,75) | %7,3 |
| liman (Haliç ±110 m gerçek) | %4,1 |
| bostan (bostan/bağ/meyve adaları, Lykos, Langa) | %3,7 |
| saray (Büyük Saray, Bukoleon harabesi) | %1,5 |
| seyrek (manastır adaları, Mangana, Havariyun nekropolü) | %1,4 |
| sarnic (Aetios, Aspar, Mokios açık sarnıç bostanı) | %0,9 |
| hipodrom | %0,5 |
| harabe (ada) | %0,3 |

- En büyük kesintisiz evsiz ada (sarnıç/Hipodrom/Saray hariç): **120 m** (Langa bostanı; ölçüt ~120 × 120 m). Adalar 420 m'lik gerçek
  ızgarada, yarıçap ≤ 125 m gerçek (≤ 88 m dünya çapı), komşular birleşmez; batıda (kara suruna doğru) ve Lykos boyunca daha sık.
- Galata surlarına kadar dolu (`sik` 0,9, kıyıda `liman`, sur dibi 63 m gerçek `sur_dibi`).
- Sur dışı: kara suru önü 150 m gerçek `kir`/`alt=hendek`; ötesi 2,6 km `ordugah` (yoğunluk surdan uzaklaştıkça azalır); Eyüp ve
  Pera `bag`; Trakya `kir` (tarla/çayır) + `orman`. Karşı kıyılar: köyler `koy` (Üsküdar, Khalkedon, Kuzguncuk, Beylerbeyi, Kandilli,
  Diplokionion, Ortaköy, Arnavutköy, Kosmidion, Kasımpaşa, Hasköy, Haydarpaşa), çevreleri `bag`, tepeler `orman`/`kir`.
- Yeni alan `alt`: `bag|meyve|bostan|manastir|harabe|mezarlik|tarla|cayir|cadir|hendek` (doku/zemin için). Var olan türler aynı
  anlamda; yeni türler: `sarnic`, `hipodrom`, `saray`, `ordugah`, `koy`, `bag`, `orman`.
- Hız: `mahalle` ~10–20 µs/çağrı (kip=harita 43 bin çağrı 1,9 sn, xvfb).

## 3. Kusurlar

- **Kıyı basamağı:** kaynağı ızgara verisi (kıyı maskesi 20 m'lik rasterden, `distance_transform_edt`). `h_ham` artık kıyı adayı
  (|y| < 9 saklı m) noktalarda en yakın DENİZE BAKAN kıyı kenarına (yarımada, Trakya, Anadolu çokgenleri; kara suru ve veri sınırı
  kenarları ayıklanır) işaretli uzaklığı ölçer ve 26 m gerçeğin içinde kıyı profilini (kara +0,4 m + %10, deniz −0,6 m − %8) kurar,
  40–70 m gerçek arası eski veriye yumuşak geçer. Profil SÜREKLİ (kıyıdan 5 m'ye %30, ötesi kara %12 / deniz %8): ilk denemede
  kıyıda +0,4 / −0,6 m sıçrama vardı, sıfır çizgisi ağ hücresine kilitlenip yine dişli görünüyordu; ayrıca yatık kıyıyı ±0,25 m
  dalga kesiyordu. 80 m'lik hücre dizini; kıyıdan uzakta ek maliyet yok. ÖNCE | SONRA: `oncesonra_kiyi.jpg` (aynı bakış, gezi
  `kiyi=0` ile yumuşatma kapalı). Kalan: çokgenin kendi köşeleri (OSM ilçe sınırı) ve 6 m ağ hücresi ölçeğinde küçük dişler: KISMEN.
- **Zemin rengi:** `_renk` türe göre: yerleşik doku çiğnenmiş toprak + taşlık lekeleri; bostan/bağ/meyve/tarla için ~150 × 110 m
  gerçek parseller (sürülmüş tarla çizgili kahve, yeşil buğday, nadas, çiçekli çayır, bağ sıraları, bostan tarhları; parsel
  sınırında toprak patika); harabe/saray taşlık; Hipodrom kuru toprak; ordugâh çiğnenmiş toprak; orman koyu. Albedo %20 koyu,
  doygunluk ×1,25.
- **Uzakta süt rengi (yeni bulunan):** `Look.apply_env` açılışta pus ve hava perspektifini (0,3) yeniden kuruyor; tam tepeden 2,3 km
  uzaklıkta zemin %30 açılıyordu (sis kapalı denemede de: neden hava perspektifi + gök). `IstDunya._pus`: her karede hava perspektifi
  0,1, pus yoğunluğu kamera yüksekliğine göre (80 m altı 0,00008/m → 980 m üstü %18'i). Ölçüm (aynı yer, şehirsiz): 2300 m / 400 m /
  80 m'den zemin ortalaması önce #CFC595 / #ACAA6F / #9EA365, sonra #A3A570 / #A5A66B / #9EA365.
- **Mavi dikdörtgen:** arazide yok. Şehirli tam tepe karesindeki koyu/siyah dikdörtgenler (Aetios, Aspar, Mokios yerleri ve batıda
  birkaç tane) parça/şehir tarafının; `mahalle` artık bu yerleri `sarnic` (alt `bostan`) verir.

## 4. Karşı kıyılar, sur dışı, Kız Kulesi

- `IstDunya._karsi_kiyilar`: gerçek e −8200…+9000, n −4600…+9600 içinde her 40 m dünya karesine (deniz, sur içi ve Galata hariç)
  `mahalle` türüne göre öğe: köyde 1–4 ev + ağaç/servi; ormanda 3–5 ağaç (+servi); bağda çalı sıraları + meyve ağacı (çiçekte) +
  seyrek bağ evi; tarlada ot yığını ya da sınır ağacı; ordugâhta ot yığını/çalı (çadırlar `IstOrdugah`'ın); hendekte çalı.
  1600 m'lik öbeklerde tür başına tek MultiMesh (ağaç, servi, ev, ot, çalı), görünürlük 2,4–4,2 km.
  **31 768 öğe, 12 841 kare, kurulum 296–319 ms.** Çizim: görünen öbek başına ≤ 5.
- Kız Kulesi (`_kiz_kulesi`): adacıkta 1453 biçimi küçük kale (kestirim): çevre duvarı + köşe kuleleri + merkez kule (k = 0,75),
  bayrak. `ek_kiz_kulesi.jpg` (birinci turdaki adacık 28 m → gerçek 56 m yarıçap).

## 5. ISTBOS (gezi `bos=1`; 14 sahip karesi alındıktan sonra, birleşik dal)

Öğe = zeminden ≥ 0,3 m yükselen her geometri (ağ köşesi, MultiMesh örneğinin tepesi, ilkel ağ). Arazi, deniz, gök, ufuk sayılmaz.
Kıyıda karasının %40'ından azı kara olan kareler sayılmaz.

| bölge | kare | boş | oran | hedef | örnek boş kareler (gerçek e, n) |
|---|---|---|---|---|---|
| şehir içi | 1109 | 61 | **%5,5** | %0 | (−2000, 1200) (−2342, 1085) (−1657, 971) (−1200, 971) (−4742, 857) (−628, 857) (−4628, 742) (−2228, 742) |
| Galata | 24 | 0 | %0 | %0 | |
| sur dışı 600 m kuşak | 803 | 3 | %0,4 | ≤ %5 | (−5771, −2457) |
| karşı kıyılar (3 km) | 3906 | 8 | %0,2 | ≤ %15 | (3028, 3942) (3942, 2914) (−514, 2114) |

Harita: `istbos_harita.png` (yeşil dolu, kırmızı boş). **ŞEHİR-2 / DOKU-2'ye:** şehir içindeki boş kareler Haliç kıyısı ile Mese
arasındaki kuşakta (n 700–1200) ve Romanos iç yanında (−4742, 857; −4628, 742: oyun alanı hub'ı, bilerek boş olabilir) toplanıyor.
Komut: `xvfb-run … res://tests/_ist/gezi.tscn -- liste=tests/_ist/gezi_sahip.txt shots=KLASÖR bos=1`.

## 6. Sahip kareleri (her turda aynı 14 bakış)

Liste `tests/_ist/gezi_sahip.txt` (+ gece `gezi_sahip_gece.txt`); kareler `sahip_<n>_<ad>.jpg`. Güneş öğleden sonra (36°,
güneybatı), sıcak ışık; pus yüksekliğe göre.

| # | bakış | RINFO (çizim / üçgen, birleşik dal, xvfb) |
|---|---|---|
| 01 | tam tepe 2300 m | 1193 / 1,63 M |
| 02 | Galata kulesi üstünden yarımada | 745 / 1,93 M |
| 03 | kara surlarının dışından 30 m (hendek dışı) | 1108 / 2,53 M |
| 04 | … 70 m | 1114 / 2,36 M |
| 05 | Romanos iç yanından Ayasofya yönü | 1071 / 2,53 M |
| 06 | Mese'de yürüyüş | 736 / 1,37 M |
| 07 | Ayasofya meydanı | 756 / 1,12 M |
| 08 | Hipodrom | 367 / 0,61 M |
| 09 | Haliç iskelesi | 668 / 1,05 M |
| 10 | sur dibi mahallesi (Edirnekapı iç yanı) | 999 / 1,90 M |
| 11 | bostan adası (Langa) | 623 / 1,49 M |
| 12 | Marmara'dan | 1589 / 2,89 M |
| 13 | Sarayburnu açığından | 1222 / 2,16 M |
| 14 | gece Galata'dan | 706 / 1,89 M |

IstDunya'nın payı her karede 37 ağ (arazi + deniz + ufuk) ve 70–171 bin üçgen + karşı kıyı öbekleri; kare başına iş 120–270 µs.
Üçgen bütçesi (uçuşta ≤ 3,5 M, yerde ≤ 2,5 M) toplamda sur dışında ve Marmara'dan sınırda: büyük pay şehir/ordugâh/gemiler.

## 7. Uçuş bölümleri (7, 11) için v2 dökümü (UYGULAMA YOK)

Eski uçuş: `World1453.flight_data(world)` (`scripts/world/world1453.gd:323`) `landmarks / forms / perches`; bölümler bunu
`ByzCity` ve `CampDay` üzerinden okur (`scripts/level/byz_city.gd:1385-1404`, `scripts/level/camp_day.gd:1026-1048`). V2'de
karşılığı `IstSehir.flight_data_v2(world)` (`scripts/world/ist/sehir.gd:2358`, ŞEHİR-2'nin). Bağlama için gereken:

| eski anahtar | v2 gerçek (e, n) | S = 0,35 dünya (x, z) | not |
|---|---|---|---|
| ayasofya | (0, 0) | (0, 0) | kubbe tepesi ~40 m (× 1,5 model) + arazi ~12 m |
| hippodrome | (−378, −289) | (−132, 101) | |
| column (Konstantin) | (−756, −11) | (−265, 4) | |
| apostles | (−2394, 1156) | (−838, −405) | |
| aqueduct_a/b (Bozdoğan) | `IstGeo.yol("bozdogan")` uçları | (−861, −350) / (−560, −256) | |
| chain_s / chain_n | `yol("zincir")` | (−133, −286) / (−180, −538) | |
| galata_tower | (−512, 1889) | (−179, −661) | kule ~50 m (k 0,75) + tepe 21 m = ~71 m: **70 m tavanını aşar**, tavan ≥ 90 m olmalı |
| blachernae | (−3402, 3436) | (−1191, −1203) | |
| romanos | Topkapı (−4837, 889) | (−1693, −311) | |
| galata_center | (−504, 2046) | (−176, −716) | |
| damalis (Kız Kulesi) | (2005, 1390) | (702, −487) | `IstDunya._kiz_kulesi` |
| uskudar | (2950, 1900) | (1033, −665) | `IstGeo.KOYLER` |
| ordugâh / otağ | (−4789, 1101) | (−1676, −385) | sur dışı, düz |

Sınır kutusu: `IstGeo.kiyi("yarimada")` + Galata + 300 m ≈ x −1750…+300, z −1250…+700 (S = 0,35'te yarımada ≈ 1,9 × 2,0 km;
eski World1453 ~1,4 × 1,7 km'ye yakın: bölüm süreleri büyük ölçüde korunur). Bağlama paketi: (1) bölüm 7/11 sahnesinde `World1453`
yerine `IstDunya.build` + `IstSehir.attach_v2`; (2) `flight_data` çağrıları `IstSehir.flight_data_v2`; (3) tavan 70 → 90 m;
(4) başlangıç noktası otağ; (5) eski sınır (`SiegeField` dikdörtgeni) yerine yukarıdaki kutu.

## ÖNCE | SONRA paftaları

- `oncesonra_genel.jpg`: tur başı (yalnız S = 0,35 + mahalle; renk, pus, karşı kıyı yok) | şimdiki birleşik dal: tam tepe, Galata, sur dışı.
- `oncesonra_kiyi.jpg`: Haliç güney kıyısı 60 m'den, kıyı yumuşatması kapalı | açık (şehirsiz).

## Testler

- `parse_check`: PASS (322 betik, birleşik dal). `world_check` PASS (13 bölge, 35 işaret), `city_check` PASS, `flight_check` PASS
  (eski dünya; dosyalarına dokunulmadı).
- Yürüme sınaması (`kip=yuru_sina`, şehirsiz, S = 0,35): `yol=130 m alt_dusme=0 yerde_en_buyuk_fark=0.01`, yakalayıcı PASS.
- Bölüm 6, 7, 11, 12b, 24 başsız `--autotest`: PASS (6a.1, 7.1, 11.2, 12B.1, 24.1; yasak satır 0).

## ORTAK BİLGİ / İSTEK

- ŞEHİR-2: Ayasofya meydanı oyun alanının (`_meydan_rect`) içinde yerden (gerçek e −320, n 0) bakınca kamera revaklı bir yapının
  (Mese portiği?) içinde kalıyor: alan boş değil. Tam tepede koyu/siyah dikdörtgenler (sarnıç yerleri ve batıda) sürüyor; `IstGeo.mahalle` → `"sarnic"` kullanılabilir.
  Sur dışı 30 m karesinde sur yüzünde havada beyaz dörtgenler (bayrak/levha?) var (`sahip_03`).
- DOKU-2: şehir içi ISTBOS %5,5 (örnekler yukarıda). `mahalle` yeni alanı `alt` (bag/meyve/bostan/manastir/harabe/mezarlik).
- Herkes: `IstGeo.X0/Z0/ST` artık `static var` (const değil); `IstDunya.CX0/CZ0/CNX/CNZ` de.

## BAKILMADI / KANITSIZ

- Kıyı yumuşatmasının Haliç'in dar ucunda (Kâğıthane) ve Adalar'da davranışı (Adalar çokgeni yok: ufuk ağı).
- Serbest uçuş kipi elle (ekransız ortam).
- Kız Kulesi'nin 1453 biçimi KESTİRİM.
