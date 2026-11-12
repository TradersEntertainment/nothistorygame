# SUR-5 raporu (İstanbul v2) — dal `wip/ist2-sur5`

Taban `wip/ist2-sur4`; `wip/ist2-ordugah5`, `wip/ist2-canli`, `wip/ist2-doku4`, `wip/ist2-cevre4`, `wip/ist2-baglama4`
birleşik (çakışma yok). `wip/ist2-zemin` dalı uzakta YOK (`git ls-remote` boş): ortak zemin kitaplığı gelmedi; sur
kuşağında kendi yumuşak geçişli toprak ağlarım kullanıldı. Kareler yazılımla çizim (xvfb, llvmpipe), **1280×720**.

**Kameralar.** Kendi sondam `tests/_ist/sur5_kare.tscn` (SUR-4 sondasının kopyası; kamera tanımı gezi.tscn ile aynı:
gerçek doğu/kuzey, yükseklik, pusula yönü, eğim, fov 70; kareden önce şehir kuyruğu boşaltılır). Sahip kareleri
`gezi_sahip.txt` satırlarıyla (`--set=liste`), kara kareleri `--set=kara`, hendek `--set=hendek` (SUR-4 ile aynı kamera).
**ÖNCE** kareleri taban kodla (`35c8732e`, `wip/ist2-sur4`), depo DIŞINDA bir çalışma ağacında (`/root/once`), aynı
sondayla aynı kameralardan alındı. SONRA kareleri son kodla (beş dal birleşik).

## ÖNCE | SONRA paftası

`pafta_01_once_sonra_alti_kare.jpg` — sol ÖNCE, sağ SONRA; satır satır: `sahip_03_sur_disi_30m`, `sahip_04_sur_disi_70m`,
`kara_05_yer60`, `kara_03_ust_a`, `kara_03_ust_b`, `s3_hendek`. Tam boy tek tek: `once_sonra/<ad>_ONCE.jpg`,
`once_sonra/<ad>_SONRA.jpg` (1280×720).

Öteki paftalar: `pafta_02_kuleler_once_sonra.jpg` (kule türleri 15 m ve 150 m; yalnız dilim, ÖNCE kutu kule),
`pafta_03_kara_once_sonra.jpg` (kara 03/05/06 dışarıdan 30 m, sur üstü, yerden 60 m), `pafta_04_hendek.jpg` (hendek içi
ve kenarı), `pafta_05_gedikler.jpg`, `pafta_06_gece_once_sonra.jpg`, `pafta_07_uzak_once_sonra.jpg`. Bütün tek kareler:
`kare/*.jpg` (1280×720). 14 sahip karesi: `sahip_<n>_<ad>.jpg` (13 gündüz + `sahip_14_gece_galata`).

## Kendi karelerime bakınca hâlâ kötü olanlar

Sahibinin gözüyle, dürüstçe ("kare kare mi? kule kutu mu? yer kötü mü?"):

1. **`kara_05_yer60` hâlâ kötü.** Romanos kapısının önü: yıkık köprü ayakları artık kesme kutu değil (kademeli kırık taş
   sıraları), ama kare hâlâ "bıçak kenarlı çukur" okunuyor: önde büyük düz sarı/yeşil üçgen yüzler ve koyu dik duvarlı
   çukur. Sondam (`--set=piksel`) öndeki geniş yüzlerin büyük kısmının arazi ağı (`IstDunya`) ve SUR-4'ün köşe dolgusu
   (`sehir.gd:_kose_dolgu`, hendek şeritleri DİK prizma) olduğunu gösteriyor. Köşe dolgusunun hendek şeritleri bu turda
   yumuşatılmadı. **Kötü.**
2. **`sahip_03`: hendekteki yeşil "piramit" duruyor.** Kaynağı benim değil: piksel sondası o noktada yalnız
   `IstDunya/IstHayat/@MultiMeshInstance3D` (1×1×1 birim ağ), `IstHayat/Hayat_kutu` ve `IstSehir/doku_bahce_61`
   (bahçe otu/çiçeği) buluyor (220–285 m). Benim rampa kamam artık görünmez (çarpışma), yerine toprak döküm rampa.
   ORTAK İSTEK 1.
3. **`s3_hendek` ve `sahip_04`: oyuncak ağaçlar, sarı/yeşil piramitler, beyaz-mavi çadırlar duruyor.** Piksel sondası:
   hendekteki sarı piramit = `IstDunya/Karsi_ot_-2_-1` (dunya.gd "ot" öbeği, ~1 m piramit); ağaçlar
   `IstDunya/Karsi_agac_*`; çadırlar ordugâh/yaşam katmanı. Benim dosyalarımda değil. **Kötü** (ORTAK İSTEK 1–2).
4. **Sur üstü döşeme: güneşte sönük kireçtaşı, gölgede hâlâ yeşilimsi** (`once_sonra/kara_03_ust_a/b_SONRA.jpg`, son
   kod). ÖNCE camgöbeği karo; ara denemelerde olive-yeşil ve turuncu çıktı. Gök ışığı (mavi) toon gölgelemede gölgedeki
   yatay yüzü yeşile kaydırıyor. KISMEN.
5. **Uzak katman kuleleri (400 m) yakından koyu-kahve** (`kare/uzak_kara_400m.jpg`); gölgelendiricide uzak çarpanı
   0,84 → 1,08 yapıldı; 400 m karesi bu değişiklikten SONRA (k5) alındı: fark azaldı, tamamen kapanmadı. KISMEN.
6. **Gedik kareleri gediği iyi göstermiyor** (`pafta_05_gedikler.jpg`): kamera hedefi dış surun dış yüzü; peribolos
   karelerinde fıçılar ve toprak set seçiliyor, moloz yığını ve kırık beden zayıf. KISMEN.
7. **Gece `kara_07_yer60` karesi boş/karanlık** (kamera arazinin içinde kalıyor; ÖNCE'de de aynı) — kare geçersiz.
8. **Tuğla hatılı 15 m'den hâlâ seçilir şerit** (`kare/kule_*_15m_*`), ama artık mat ve koyu; "parlak kırmızı duvar
   kâğıdı" değil; tek tek tuğla ~6 m'den yakında (`kara_03_ust_a`: köşe kulesi gövdesinde tuğla sırası yakından).
9. **Kule pencerelerinin kemer taşları kızıl kaş gibi** (`kule_*`): tuğla rengi koyultuldu (7a4a3a → 6a4a3e), yine
   belirgin. Küçük kusur.

`KUTU kalan` sayımı (kendi karelerimde, sur kuşağı; hedef 0):
- **Kule: 0 düz küp kule** (yakın/orta/uzak: kare planlılar da pahlı, şevli, kaideli, konsollu; `kule_ic_kare_*`).
  Ancak uzak katmanda (400 m+) kare planlı kuleler hâlâ "dişli blok" okunuyor → **uzak kare kule ≈ 1/2'si kutumsu**.
- **Sur üstü eşyası: 0** (beyaz küp YOK — `kara_03_ust_a/b` SONRA; taş yığını düzensiz kaya, kazan yuvarlak, ok sepeti
  silindir, nöbetçi barınağı yuvarlak gövde + konik çatı). Mancınık kolları ve ağırlık sandığı kalas/sandık (köşeli
  gerçek nesne). Mazgal dişleri kesme taş bloklar (boyu oynak, kırık/eksik) — köşeli olması doğru, sayılmadı.
- **Moloz: 0 kutu** (gedik ve yıkık korkulukta düzensiz kaya ağı + eğik, köşesi kırık bloklar).
- **Hendek duvarı dişleri: 1 grup** (`kule_dis_*_15m_a`: parateikhion alçak duvarındaki dişler yakından "kapaklı sandık
  dizisi" gibi). KUTU kalan=1.
- **Sur kuşağındaki yabancı nesneler (benim değil): 4 tür** — `Karsi_ot_*` piramitleri, `Karsi_agac_*` yuvarlak ağaçları,
  `IstHayat` 1×1×1 kutular (`Hayat_kutu`), ordugâh çadırları/kutuları.
- **Toplam KUTU kalan = 2 (benim: hendek duvarı dişleri, uzak kare kuleler) + 4 tür yabancı.**

## Madde madde

### A. Kuleler (kutu yasağı) — KISMEN (yakın ve orta TAMAM; uzakta kare planlı kule kutumsu)
- `scripts/world/ist/sur_kule.gd` (YENİ, class_name yok): plan çokgeni + profil halkaları.
  İç sur kuleleri dönüşümlü **kare (pahlı) / sekizgen / kare / altıgen** (`_inner_tower`: `[0,1,0,2][sıra % 4]`; Romanos ve
  Kharisios kapı kuleleri sekizgen); dış sur kuleleri dönüşümlü **kare (pahlı) / U** (yarım yuvarlak ön).
  Her kule: tabanda çıkıntılı kaide (eğik üst), **şevli gövde** (dipte 0,3 m dışa), iki **kat silmesi**, üst oda (yürüme
  yolu kapıları, iç duvar, tavan, döşeme — eski kutu odayla aynı yerde), **kemerli mazgal pencereleri** (koyu iç, taş söve,
  denizlik, 7 tuğla kemer taşı yüzden 0,22 m çıkar: gölge derinliği), gövdede lentolu ok yarıkları, şehir yüzünde kemerli
  kule kapısı, **üç kademeli konsol sırası** üstünde **mazgallı teras** (dişler 0,95 × 0,75 m, %8 eksik, %12 kırık), köşeler
  pahlı, halka köşeleri ±3 cm oynar (siluet cetvel değil). Yıpranma: onarım yamaları (köşe rengi), çatlak (zikzak), eksik
  blok (koyu oyuk), dipte düşmüş düzensiz bloklar. 1/7'sinde direkler üstünde **ahşap kırma çatı** (n yüzlü, saçaklı,
  soluk kiremit; eğik kırmızı levha KALKTI), 2/7'sinde mermer **yazıt levhası** (yazısız oyma çizgi; dönem kuralı).
  Sancak direği, nöbetçi barınağı, mancınık, gülle yığını `surlar_ayrinti.gd`'den (önceden).
- Köşe kuleleri (`sehir.gd:_kose` → `SURKULE.kose`): kutu + yerde duran dişler yerine **sekizgen**, kaideli, şevli,
  silmeli; yürüme yolunun girip çıktığı kenarlarda korkuluk açık, öteki kenarlarda mazgallı korkuluk.
- Çarpışma görünen ağdan ayrı: plan çokgeninin dışbükey prizması + oda duvarları (kapı boşluklu) + teras korkuluğu.
- Bütçe (üçgen/kule, sonda `--set=birim`): iç kule yakın **1 940–2 008**, orta **225–297**, uzak **44**; dış kule yakın
  474–582, orta 120–150, uzak 42 (sınırlar 2 500 / 300 / 60: TAMAM).
- Kareler: `pafta_02_kuleler_once_sonra.jpg`, `kare/kule_ic_{kare,sekizgen,altigen}_15m_{a,b}.jpg`,
  `kare/kule_ic_*_150m.jpg`, `kare/kule_dis_{kare,U}_15m_{a,b}.jpg`, `kare/kule_dis_*_150m.jpg`, `sahip_03`, `kara_05_dis30`.
- Kalan: uzak katmanda kare kuleler (yukarıda); kule kareleri yalnız (oyun dışı) bir dilimden — oyun içinde aynı kurucu.

### B. Beden duvarı — KISMEN
- Üst çizgi: dişler artık gerçek ağ (boy ±%12, %9 kırık), uzun kesimlerde %45 olasılıkla 4–12 m'lik **yıkık korkuluk**
  (dört basamaklı alçak kalıntı + düşmüş bloklar; çarpışma tam boy: düşme olmasın) — `surlar.gd:_parapet_x`.
- **Beyaz küpler — kaynak ve çözüm:** sonda `--set=kimust` (kara nokta 03): `SurDilimi/@MultiMeshInstance3D` (ölçek
  1,0 × 0,6 × 0,45 = mazgal dişi MultiMesh'i, sur taşı gölgelendiricisinde dokusuz beyaz) ve köşe kulesinin (`_kose`)
  yerde duran 1,0 × 1,1 × 0,6 diş kutuları. İkisi de kalktı (`KULE.disler_ag`, `KULE.kose`). `kara_03_ust_a/b` SONRA:
  beyaz küp YOK — **TAMAM**.
- Yürüme yolu döşemesi: camgöbeği karo kalktı; sıcak kireçtaşı tonu, taş taş ton ve aşınma (`sur_doku.gd` yatay dal).
  Ton ayarı kararsız (yukarıda 4) — KISMEN.
- Gövde: payanda (şehir yüzü, şevli), su olukları ve altında is/yosun akıntısı, örülmüş eski kapı izleri (tuğla kemer +
  farklı tonda dolgu) — `surlar_ayrinti.gd:_beden`. Kare: `kare/kara_06_dis30.jpg` (yakından ayrı kare ALINMADI → KANITSIZ
  ayrıntı düzeyinde).
- Tuğla hatılı: mat koyu kiremit (0,24/0,12/0,08 doğrusal), uzaktan taşla aynı düzlemde sönük bant; tek tek tuğla
  ~6 m'den yakında (`ince_t`). Kare: `kara_03_ust_a` (SONRA). KISMEN (15 m'de şerit yine seçilir).
- Sur üstü savunma eşyası: taş yığınları (düzensiz kaya), kazanlar (yuvarlak, üç ayaklı), ok sepetleri (silindir + ok),
  gülle yığınları; nöbetçi barınağı yuvarlak. Kare: `kara_06_ust_b` (yakın eşya karesi ayrıca ALINMADI) — KANITSIZ.

### C. Hendek ve sur dibi — KISMEN
- `sur_zemin.gd:hendek_kesit` (yeni): kutu çukur yerine tek ağ — iki yanda taş kaplama (hafif şevli, üst kenarı
  düzensiz), dipte yuvarlanmış köşeler, düzensiz çamur taban (ortası çukur, ıslak lekeler), ~45 m'de bir 6–10 m'lik
  **yıkılmış kaplama + toprak kayması** (karşı yaka yatıklaşır, dibe düşmüş kaya). Kutular yalnız çarpışma.
  Saz kutu değil koni. Toprak set (SUR-4) köşe normalli ve sıklaştırılmış (düz renkli üçgen yüz kalmasın). Hendek rampaları
  görünür kama yerine toprak döküm rampa (yumuşak yanlar). Romanos önündeki yıkık köprü ayakları kademeli kırık taş.
- Kareler: `pafta_04_hendek.jpg` (`kare/hendek_ici_05/08`, `hendek_kenar_05/08`), `kara_06_dis30` (sol: su birikintisi,
  saz, taş kaplama), `s3_hendek`.
- Kötü kalan: `kara_05_yer60` (yukarıda 1); kırık noktalarında köşe dolgusu hendek şeritleri dik prizma (`_kose_dolgu`
  — bu turda değişmedi). Zemin kitaplığı (ZEMİN) gelmedi: yamalar ona geçirilmedi.

### D. Mesoteikhion gedikleri — KISMEN
- `surlar.gd:_gedik` + `sehir.gd:_gedik_x`: hat üstünde Romanos kapısına en yakın noktadan güneye yay boyunca 110, 215,
  330 m'de (kapı koşusunun dışı) dış surda gedik: kırık profilli alçak kalıntı beden, gedikte dış kule yok, peribolosa ve
  terasa yayılan moloz tümseği + düzensiz kayalar (kutu değil), **stauroma**: toprak dolu fıçı sırası, kazıklı toprak set,
  sehpalar üstünde kalas yürüme tahtası (dış sur yürüme yolu hizasında, çarpışmalı).
- Kurulan: **2 gedik** (`SURGEDIK tekil=2`: gerçek (−4943, 426) ve (−4922, 116)); üçüncüsü dilim ucuna düştüğü için
  atlandı. Kareler: `pafta_05_gedikler.jpg` (kamera gediği iyi çerçevelemiyor — KISMEN).
- Süreklilik ölçütü: gedikler dış surda; ölçüm koşusunda (aşağıda) kara dış sur boşlukları gedik noktalarında çıkmadı
  (ışın yüksekliği OH−2 m'de yürüme tahtası direkleri/fıçılar değil; büyük olasılıkla ölçüm sırasında gedik dilimleri
  ağaçta değildi: gedik konumları yakın katmanda kurulur) — "belgeli gedik" listesi: yukarıdaki iki nokta. KANITSIZ (ölçüt
  gediği görmüyor).

### E. Devredenler
- **Süreklilik (`ISTSURSUREKLI`, son kod):**

| hat | katman | örnek | boşluk SUR-4 | boşluk SUR-5 |
|---|---|---|---|---|
| kara (iç sur) | yakın / orta / uzak | 438 | 0 / 0 / 0 | **0 / 0 / 0** |
| kara (dış sur) | yakın / orta / uzak | 438 | 3 / 3 / 3 | **3 / 3 / 3** (s=2 hat ucu; s=2158, 2162 kırıkta köşe kulesi 68) |
| Blakherna | y / o / u | 58 | 0 / 0 / 0 | **0 / 0 / 0** |
| Marmara | y / o / u | 529 | 0 / 0 / 0 | **0 / 0 / 0** |
| Haliç | y / o / u | 372 | 1 / 1 / 1 | **1 / 1 / 1** (s=2 hat başı) |
| Galata | y / o / u | 154 | 0 / 0 / 0 | **0 / 0 / 0** |

  `bosluk=0` hedefi kara dış sur (3) ve Haliç (1) için **YAPILMADI** (bozulmadı, düzelmedi).
- **Uzak katman rengi:** KISMEN (yukarıda 5). **Deniz surları sıcak gri:** gölgelendiricide deniz taşı (0,43, 0,395, 0,335)
  — `kare/uzak_marmara_400m`, `uzak_halic_400m`; yakın deniz karesi bu turda alınmadı → KANITSIZ.
- **Sur üstü yürüyüş** (`sehir2_kare --set=suryuru`, son kod):

| hat | SUR-4 | SUR-5 | hedef |
|---|---|---|---|
| kara | 131/145 = %90,3 | **130/145 = %89,7** (düşme 2, takılma 13) | ≥ %97 ✗ |
| Blakherna | 15/19 = %78,9 | **14/19 = %73,7** | ≥ %95 ✗ |
| Marmara | 159/176 = %90,3 | **159/176 = %90,3** | ≥ %90 ✔ |
| Haliç | 87/123 = %70,7 | **87/123 = %70,7** | ≥ %90 ✗ |
| Galata | 36/51 = %70,6 | **36/51 = %70,6** | ≥ %90 ✗ |

  Kara %97 hedefi **YAPILMADI**; kara −1, Blakherna −1 (Blakherna'da köşe kulesi: `L0` 8×17×8 kutu olayları; kara
  takılmaları çoğunlukla `SurDilimi` 6,47 m'lik oda duvarı kutusu ve köşe geçişleri — `yuru.txt` olay satırları).
- **Bütçe** (oyunun RINFO'su, aynı kamera; ÖNCE taban, SONRA beş dal birleşik — fark yalnız benim değil):

| kare | ÖNCE çizim | ÖNCE üçgen | SONRA çizim | SONRA üçgen | fark |
|---|---|---|---|---|---|
| sahip_03 | 1 169 | 3,00 M | 1 438 | **4,31 M** | +269 / +43 % |
| sahip_04 | 1 099 | 2,75 M | 1 384 | **4,04 M** | +285 / +47 % |
| kara_03_dis30 | 1 059 | 2,39 M | 1 030 | 2,66 M | −29 / +11 % |
| kara_05_yer60 | 1 247 | 2,90 M | 1 194 | 3,02 M | −53 / +4 % |
| kara_05_dis30 | 1 134 | 2,96 M | 1 154 | 3,17 M | +20 / +7 % |
| kara_06_dis30 | 1 229 | 2,62 M | 1 215 | 2,83 M | −14 / +8 % |
| kara_06_ust_b | 1 557 | 2,75 M | **1 716** | **4,00 M** | +159 / +46 % |
| s3_hendek | 916 | 2,50 M | 931 | 2,73 M | +15 / +9 % |
| uzak_kara_400m | 676 | 2,46 M | 683 | 3,58 M | +7 / +45 % |
| uzak_kara_1000m | 848 | 2,66 M | 965 | **5,43 M** | +117 / +104 % |
| uzak_marmara_1000m | 932 | 3,06 M | 1 071 | **6,02 M** | +139 / +97 % |

  Uçuş sınırı (1 500 çizim / 3,5 M üçgen): çizim `kara_06_ust_b` (1 716; ÖNCE'de de 1 557) dışında tutuyor; **üçgen
  sınırı sahip_03/04, kara_06_ust_b, uzak 1 km karelerinde AŞILIYOR** — "çizim artmaz / üçgen ≤ +%8" kuralı TUTMADI.
  Ayrım KANITSIZ: SONRA'da beş dalın (ordugâh-5, canlı, doku-4) eklemeleri de var; benim payım: yakın kule ~2 000 üçgen ×
  yakın katmandaki kule sayısı, sıklaştırılmış toprak set (×4, yalnız yakın), hendek kesiti. Uzak katmanda kule 44, hendek
  kesiti lod 2'de 40 m adım, set lod 2'de sıklaştırma yok (ölçülü azaltma).
- **Kurulum zaman dilimi (tek iş ms, `sehir2_kare --set=yavas`, son kod):** `kara/0w` (kara dilim penceresi) **63,3 ms**
  (SUR-4: 33,8; hedef 6 ms) — **KÖTÜLEŞTİ** (yakın kule ağının SurfaceTool kurulumu + hendek kesiti + gedik); Galata 17,1,
  Haliç 13,3, Marmara 6,9, köşe 6,4 ms. Düzeltme önerisi (yapılmadı): kule ağlarını tür×tohum başına önbelleğe almak.
- **Testler:** `PARSECHECK PASS` (339 betik). Başsız: Bölüm 7 (10 varyant) ve 11 (10 varyant) **20/20 PASS**, yasak satır
  0 (gedik/köprü ayağı/ton değişikliklerinden ÖNCEki ara kodla); son kodla Bölüm 7 `=wall`, 11 `=helpwall`, komşu 6, 12b, 24
  **5/5 PASS**, yasak satır 0.

### F. Dallar
- ordugah5, canli, doku4, cevre4, baglama4 iki kez birleştirildi (17:5x ve 19:05); `wip/ist2-zemin` 19:05'te uzakta
  belirdi ve birleştirildi (çakışma yok). ZEMİN, `sur_zemin.gd:_mat()`'ı ortak zemin malzemesine (`zemin.gd`
  `kopya("kusatma")`) geçirmiş: toprak set, hendek kesitinin toprak/çamur yüzü ve rampalar böylece ortak zemine bağlı
  (yamalarım ayrıca taşınmadı; API aynı). Birleşik son kodla kareler: `birlesik/*.jpg` (sur dibi artık parlak yeşil değil,
  çiğnenmiş gri-kahve toprak; `birlesik/sahip_03_sur_disi_30m.jpg`, `birlesik/s3_hendek.jpg`). Hayvan/çadır dosyalarına
  dokunulmadı.
- **Birleşik son kodla testler:** Bölüm 7 (boş, `=wall`) ve 11 (boş, `=helpwall`) **4/4 AUTOTEST PASS**, ama her koşuda
  binlerce `SCRIPT ERROR: Cannot call method 'get_image' on a null value` — kaynak `scripts/level/zemin.gd:159`
  (`doseme_kir`, ZEMİN'in dosyası; başsızda gürültü dokusu boş; çağıranlar `land_walls.gd:176`, `byz_city.gd:353`,
  `galata.gd:108`). ZEMİN birleşmeden önceki kodla aynı testlerde yasak satır 0'dı. Benim dosyalarımdan değil:
  ORTAK İSTEK 6.

## ORTAK İSTEK / BİLGİ

1. **BAĞLAMA (`dunya.gd:_karsi_kiyilar`)** — sur kuşağının 200 m'sinde (`alt == "hendek"` ya da `IstSehir` kara suru
   hattına < 200 m) `Karsi_ot_*` (piramit ot öbeği — hendekte sarı piramit), `Karsi_agac_*`, `Karsi_cali_*` kurulmasın:
   ```gdscript
   # dunya.gd _karsi_kiyilar, öğe döngüsünde
   if String(IstGeo.mahalle(p.x, p.y).get("alt", "")) == "hendek" or _sur_yakin(p, 200.0):
       continue
   ```
   (`_sur_yakin`: `IstSehir._sade(IstGeo.yol("kara_suru"))` parçalarına uzaklık.)
2. **DOKU-4 / CANLI (`hayat*.gd`)** — `IstHayat/Hayat_kutu` ve 1×1×1 birim MultiMesh öğeleri sahip_03 karesinde hendeğin
   önünde yeşil piramit/kutu olarak görünüyor; sur dışı 200 m kuşakta kutu öğe konmasın ya da gerçek nesneye (fıçı, sepet)
   çevrilsin.
3. **ORDUGÂH-5 (BİLGİ)** — sur kuşağı (hat ekseninden 0–110 m) benim; `sahip_04`'teki beyaz/mavi çadırlar sizin
   katmanınızdan; çadırlar hendekten 60 m'den yakına konmasın.
4. **ÇEVRE (BİLGİ)** — `sehir.gd`'de yalnız sur işlevleri: `_kose` (köşe kulesi kurucusu), `_hat_piece` (kara dilimine
   gedik listesi), yeni `_gedik_x` ve `_gedik_nok`, sabit `SURKULE`. `sehir_eser.gd`'ye dokunulmadı.
5. **ZEMİN (BİLGİ: API)** — sur kuşağı yamalarım: `sur_zemin.gd:set_` (toprak set), `hendek_kesit`, `rampa`,
   `ates_alani` (SUR-4). Ortak zemin kitaplığı gelince bunlar `ZEMIN.toprak_mat()` benzeri ortak malzemeye geçirilebilir;
   çağrılar: `set_(p, x0, x1, z0, lod, tohum, pencere)`, `hendek_kesit(p, x0, x1, z0, z1, md, lod, tohum, pencere)`.

6. **ZEMİN (`scripts/level/zemin.gd:doseme_kir`)** — başsız koşuda `_gurultu` dokusu null: `get_image` öncesi denetim:
   ```gdscript
   var src: Image = _gurultu.get_image() if _gurultu != null else null
   if src == null:
       return m          # başsız/yükleme öncesi: kir katmanı atlanır
   ```

## Dosyalar
- Yeni: `scripts/world/ist/sur_kule.gd`, `tests/_ist/sur5_kare.gd/.tscn`.
- Değişen: `surlar.gd` (kuleler, `carp_only`, yıkık korkuluk, gedik, köprü ayağı, rampa, diş ağı), `surlar_ayrinti.gd`
  (yuvarlak barınak, `_beden`), `sur_zemin.gd` (hendek kesiti, rampa, set normalleri, saz konisi), `sur_doku.gd` (tuğla,
  döşeme, deniz taşı, uzak çarpanı), `sehir.gd` (yalnız sur işlevleri, yukarıda 4).
- Sonda kancası oyun koduna konmadı (yalnız `tests/_ist/sur5_kare.gd`). `IstSurlar.gedik_dunya` oyun kodunda yalnız
  konum listesi (denetim değil).

## SAHİBİNE GÖSTERİLECEK 8 KARE

1. `pafta_01_once_sonra_alti_kare.jpg` — altı kare aynı kamerayla ÖNCE | SONRA (kutu kule → çokgen kule, beyaz küp yok).
2. `once_sonra/sahip_03_sur_disi_30m_SONRA.jpg` — sur dışından: sekizgen ve kare kuleler, konsollu mazgallı teraslar.
3. `kare/kule_ic_sekizgen_15m_b.jpg` — sekizgen kule 15 m'den: şev, kaide, silme, kemerli pencere, mazgallı teras.
4. `kare/kule_dis_U_15m_a.jpg` — dış surun U kulesi ve mazgallı beden.
5. `once_sonra/kara_03_ust_a_SONRA.jpg` — sur üstü: beyaz küpler gitti, sekizgen köşe kulesi.
6. `kare/kara_06_dis30.jpg` — 30 m'den: kule ritmi, yumuşak kesitli hendek, su birikintisi ve saz.
7. `kare/hendek_ici_05.jpg` — hendeğin içinden: taş kaplı yanlar, çamur taban, kayma.
8. `pafta_02_kuleler_once_sonra.jpg` — kule türleri ÖNCE (kutu) | SONRA (kare/sekizgen/altıgen/U).
