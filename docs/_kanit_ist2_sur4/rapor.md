# SUR-4 raporu (İstanbul v2, dördüncü tur) — dal `wip/ist2-sur4`

Taban `wip/ist2-taban4`; son hâlde `wip/ist2-ordugah4`, `wip/ist2-cevre4`, `wip/ist2-doku4`, `wip/ist2-baglama4` birleşik
(16:46'daki hâlleri, `wip/ist2-doku4` 17:05'te yeniden; çakışma yok). Kareler yazılımla çizim (xvfb, llvmpipe), 1280×720.

**Kameralar.** Sahip kareleri DÜNYA-2'nin `tests/_ist/gezi.tscn` + `gezi_sahip.txt` sahnesiyle (sahibinin karesiyle AYNI
araç ve kamera). Öteki kareler yeni sondamla (`tests/_ist/sur4_kare.tscn`): gezi ile aynı kamera tanımı (gerçek doğu/kuzey,
yükseklik, pusula yönü, eğim, fov 70) ama kareden önce şehir kuyruğu da boşaltılır (gezi yalnız arazi işlerini bekliyor; sur
dilimleri pencere pencere kurulduğu için gezi karelerinde yakın katman yarım kalabiliyor — bkz. ORTAK İSTEK 4). Hendek karesi
`pafta_ordugah.jpg`'deki alt orta karenin kamerası (`sehir2_kare --set=s3` → `s3_hendek`: `IstOrdugah.at(1350, 70)` →
`at(1600, 20)`, 15 m, sis kapalı) — sondada `--set=hendek`.
**ÖNCE** kareleri taban kodla, depo DIŞINDA bir çalışma ağacında (`git worktree`, `wip/ist2-taban4`) aynı sondayla alındı.

## ÖNCE | SONRA paftası

- `pafta_01_sahip03_04_hendek.jpg` — sahibinin iki karesi (`sahip_03_sur_disi_30m`, `sahip_04_sur_disi_70m`, gezi.tscn ile)
  ve `pafta_ordugah` hendek karesi (`s3_hendek`), aynı kamera. **Bu turun kabul paftası.**
- `pafta_02/03/04_kara_dis30_*.jpg` — kara suru boyunca 12 nokta (~180 m arayla), dışarıdan 30 m.
- `pafta_05/06/07_kara_yer60_*.jpg` — aynı 12 nokta, yerden 60 m uzaktan.
- `pafta_08_sur_ustu.jpg` — sur üstünden iki yöne (nokta 03 ve 09).
- `pafta_09_deniz_galata.jpg` — Marmara, Haliç, Galata (dışarıdan) ve Galata sur üstü.
- `pafta_10_uzak.jpg` — uzak katman 400 m ve 1 km.
- `pafta_11_gece.jpg` — gece: kara, Marmara, Haliç, Galata.
- `pafta_12_sur_disi_toprak.jpg` — sur dibi: ateş alanı, toprak set, hendek.
- Bütün SONRA kareleri tek tek: `kare/*.jpg` (68 kare, 960×540). 14 sahip karesi: `sahip_<n>_<ad>.jpg` (son kod, birleşik).

Ne değişti (kısa): sur taşı artık eşit kalınlıkta açık-koyu şerit değil, yordamsal **opus mixtum** (blok sıraları, şaşırtmalı
derz, ince tuğla hatılı, yıpranma) — yakın, orta, uzak katmanda AYNI gölgelendirici; dilimler ve kapı koşuları arasındaki
kama/boşluklar hattı izleyen dolgularla kapandı; hendek kuşağı araziye indi (dış sur aşağı uzadı), arazi hendek şeridinde
oyuldu; yeşil kutu şeritler yerine düzensiz tepeli toprak set ve hendekten 50 m'lik ateş alanı (çukur, gülle, ok, kalkan,
kırık merdiven); kapılar kapalı, köprüler yıkık; kulelerde pencere, çatı/sundurma, çatlak, eksik diş.

## Kendi karelerime bakınca hâlâ kötü olanlar

Sahibinin gözüyle, dürüstçe:

1. **`sahip_04_sur_disi_70m` ön planı hâlâ parlak yeşil çimen** (gezi karesi). Kamera hendekten ~110 m dışarıda: benim
   ateş alanı örtüm hendekten 60 m'de bitiyor (ORDUGÂH-4 ile sınır), ötesi `IstDunya` arazisinin rengi. Kare **kötü**:
   madde 3 bu kare için TAMAM değil (ORTAK İSTEK 2).
2. **Ateş alanında oyuncak ağaçlar ve beyaz/mavi kutular duruyor** (`s3_hendek`, `sahip_04`). Kaynak benim dosyalarımda
   değil: ağaçlar `IstDunya/Karsi_agac_*`, `Karsi_cali_*` (dunya.gd `_karsi_kiyilar`; sondanın `--set=kim` çıktısı); kutu ve
   çadırlar sur dışı çadır/kutu katmanı (ordugâh/yaşam). Kare **kötü** (ORTAK İSTEK 1–2).
3. **Uzak katmanda kuleler yakınındakinden açık krem** (`sahip_03`'ün solu, `kara_*_dis30` ufku): aynı gölgelendirici ama
   uzak ağın köşe rengi açılıyor; koyulaştırdım (×0,84), fark azaldı, kapanmadı. KISMEN.
4. **Hendek içi yer yer koyu-camgöbeği ve çimen lekeli** (`kara_04_dis30`, `kara_05_dis30`): arazi oyuldu ama kısa
   dilimlerde ve kapı ayaklarında düzlük kayıtları arasında çimen kalıyor; gölgede çamur tabanı soğuk görünüyor.
5. **Ateş alanı örtüsü uzaktan düz bej** (`sahip_03`, `kara_05_yer60`): renk yamaları var ama ince doku yok; "çiğnenmiş
   toprak" okunuyor, "top güllesi çukurlu tarla" 60 m'den zayıf okunuyor.
6. **Sur üstünde beyaz kutular** (`kara_03_ust_a/b`): ÖNCE'de de var; benim kurucularımdan değil (sur üstü sandık/kutu
   katmanı, büyük olasılıkla yaşam katmanının "kutu" öğeleri — BAKILMADI, kaynağı kesinleşmedi).
7. **Deniz surları gri-mavimsi** (`halic_2`, `marmara_1`): "daha gri, yamalı" istendi; doğru yönde ama gölgede soğuk.

Kötü OLMAYAN (kendi gözümle): `sahip_03` (taş sur, kesintisiz üçlü hat, kuleler bedene bağlı, toprak set; yeşil prizma yok),
`s3_hendek` (yeşil prizma ve hilalli bayrak yok, taş kaplı hendek; ağaçlar hariç), `kara_*_dis30` serisi, gece kareleri,
Galata (kesme taş, tuğlasız).

## Madde madde hüküm

### 1. Süreklilik — TAMAM (kara iç sur, Blakherna, Marmara, Galata) / KISMEN (kara dış sur 3, Haliç 1 örnek)
- Ölçüt (`--set=surekli`, `tests/_ist/sur4_kare.gd:_surekli`): her hat (`IstSehir._sade(IstGeo.yol(ad))`) boyunca 5 m adım;
  dış yandan içe yatay ışın, iç sur için o noktadaki yürüme yolunun 2 m altından (kara: hattan 10 m dışarıdan 9 m içeriye;
  deniz: 14 m'den), dış sur için ayrı (dış surun 2 m altından, z 25 → 14,5 m). Her katman için o katmanın görsel ağlarından
  çarpışma üçgenleri kurulur (yakın: lod 0, orta: lod 1, uzak: hücre başına pişmiş uzak ağ + kapıların lod 2'si) — çarpışma
  değil, GÖRÜNEN beden ölçülür. Kapılar kendi yapılarıyla örnek alır (boşluk sayılmaz çünkü gövde vardır).
- Nedenler ve yapılanlar:
  - Kırık noktalarında dış yanda kama boşluğu (köşe kulesi yalnız iç suru örtüyordu), köşe kulesi olmayan köşelerde iç surda
    da; kısa kenarlarda iki köşe kulesi arasındaki < 6 m'lik aralığa dilim kurulmuyordu (kara s=1632'deki iç boşluk):
    `sehir.gd:_kose_dolgu` — ardışık her iki öğenin (dilim/kapı koşusu) arasında, kesitin her şeridi (iç sur, peribolos,
    dış sur, parateikhion terası ve alçak duvarı, iki hendek duvarı, hendek tabanı) için hattı izleyen (kırıkta gönyeli)
    prizma şeridi; yakın/orta/uzak katmanda; yakında çarpışmalı. 178 dolgu.
  - Modül parçaları (Galata kapısı, Haliç kapıları, Mermer Kule) hattı yarıçaplarının 1,4 katı kesiyordu, gövdeleri daha
    kısa: Galata'da 80 m'lik boşluk, Haliç'te 25 m. `sehir.gd:_hatlar_v2`: kesik 0,8 × yarıçap; Galata kapı parçası hattı
    kesmez (dilimler kesintisiz, kapı parçası üstüne oturur).
- Belgeli gedik: Mesoteikhion gedikleri KURULMADI (madde listesinde; YAPILMADI — süre).
- Kalan: kara dış sur s=2 (Mermer Kule ucu: dış sur kıyıdan 7 m önce biter — hat ucu), s=2158/2162 (Blakherna'ya dönüşteki
  keskin kırık; dolgu var, ışın kaçıyor — KISMEN, kare alınmadı); Haliç s=2 (Sarayburnu ucu, hat başı).
- Basamak sıçraması/kademe: dilim tabanları arasındaki fark `_basamaklar` ile (önceki turdan) basamaklı; "kademe kulede
  gizlenir" YAPILMADI (dolgu şeridinin tepesi iki ucun yükseğinde). Havada kalan kule: dış bölge kademesi ile dış kuleler
  aşağı uzadı (`surlar.gd:_outer_tower`); sayılmadı (KANITSIZ).

### 2. Taş gibi — KISMEN (yakın ve orta TAMAM; uzakta ton farkı)
- Kök neden: Props'un `ashlar` dokusu (256 px; 180 px taş + 76 px tuğla) 0,55 ölçekle dünyaya yayılınca 1,3 m taş + 0,55 m
  tuğla şeridi tekrarlıyordu: uzaktan eşit kalınlıkta açık-koyu şerit = kereste. Dokuya (props.gd) dokunmadım.
- `scripts/world/ist/sur_doku.gd` (YENİ, class_name yok): dünya konumundan yordamsal gölgelendirici, UV gerektirmez;
  pişmiş ağlarda köşe rengiyle, tekil ağlarda malzeme rengiyle çalışır. Kara (opus mixtum): 4 sıra × 0,42 m kireçtaşı blok
  (~2,1 m kuşak; sıra başına blok boyu 0,85–1,6 m, şaşırtmalı derz, blok blok ton, %14 sarımsı kumtaşı) + 5 sıra tuğla hatılı
  (0,42 m, kalın harç), dönem 2,5 m; deniz surları (Marmara, Haliç): daha gri, iri sıra, seyrek 3 sıralı hatıl (3,4 m), moloz
  yamaları; Galata: düzgün kesme taş, tuğlasız. Yıpranma: dikey yağmur akıntısı, is lekesi, dipte koyulaşma ve yosun. İnce
  ayrıntı ekran türeviyle söner (uzakta titreşmez; hatıl ince kızıl çizgi olarak kalır). Taş soluk gri-krem (sıcak), tuğla
  mat kiremit.
- Bağlama: `sehir.gd:_sur_tas` — sur dilimlerinin, köşe kulelerinin, dolguların ve sur kapılarının "ashlar" desenli
  yüzeyleri pişirmeden SONRA çevrilir (`_build`, `_pis`, `_pencere_is`); uzak katman `sehir_eser.gd:sur_uzak_mat(tur)` aynı
  gölgelendirici; uzak hücreler taş türüne göre ayrı (`_hat_far_add`, anahtar `Vector3i(x, z, tur)`). 401 yüzey çevrildi.
- Kuleler (`surlar.gd:_inner_tower`): üst katta iki kemerli pencere (yakın ve orta katman), kulelerin 2/7'sinde direkler
  üstünde ahşap kırma çatı (soluk eski kiremit), 2/7'sinde ön yüzde çatlak; mazgal dişleri insan boyunda (1,0 m en, korkulukla
  1,8 m, 1,8 m arayla), yer yer eksik diş; hendek duvarı mazgallı. Sancak direği, nöbet barınağı, gülle yığını (önceden).
- Kareler: `pafta_02–04`, `pafta_08`, `pafta_09`, `kare/kara_*`, `kare/marmara_*`, `kare/galata_*`, `sahip_03`.
- Kalan: uzak kuleler yakınından açık (yukarıda 3).

### 3. Sur dibi arazisi — KISMEN (sahip_03 ve s3_hendek'te prizma gitti; sahip_04 ön planı ve ağaçlar kaldı)
- (a) **Yeşil prizmanın kaynağı:** `surlar.gd:_build_moat` hendeğin dış yakasında `C_GRASS` 14 m'lik düz kutu
  (`zm1+0,9 … zm1+14`, y −1,5…0) ve `_run`'da parateikhion terası (`C_GRASS`); dilim tabanı iç surun hattındaki ortanca
  yükseklikte olduğu için arazi dışa düşünce yerden yüksekte kalan keskin köşeli parlak yeşil prizma. Yapılan:
  `sur_zemin.gd:set_` — 4 m'lik bölmelerle düzensiz tepeli (±0,35 m), dışa 1:2,5 eğimle eteği araziye inen (arazi dünya
  dönüşümüyle örneklenir; uzak katmanda IstSehir dönüşümü verir) çiğnenmiş toprak + solgun ot seti, katı (trimesh). Teras
  toprak rengi. **Dış bölge kademesi** (`surlar.gd:dis_dy`): hendek kuşağının dışında arazi tabandan > 1,5 m aşağıdaysa
  parateikhion, hendek ve set o kadar (en çok 14 m) aşağı iner, dış sur ve kuleleri aşağı uzar.
- Hendek: iki yanı taş kaplı (önceden), iç yanda alçak duvar artık mazgallı; tabanı kuru çamur + oval su birikintileri +
  saz öbekleri (`sur_zemin.gd:hendek_dibi`; eskiden boydan boya tek su levhası). Arazi hendek şeridinde oyuldu
  (`sehir.gd:_hendek_oy`: 7 m'de bir `IstGeo.duzle`, 630 kayıt; arazi ağı o şeritte yenilenir) — eskiden hendeğin içi
  çimenle doluydu (`tani_ust`).
- Ateş alanı (`sur_zemin.gd:ates_alani`, `sehir.gd:_ates_alani`): kara suru boyunca hendeğin dış yakasından 50 m (hattan
  57–107 m), araziyi izleyen örtü (çiğnenmiş toprak, solgun ot yamaları, yanık lekeleri, devriye izi), 265 gülle çukuru
  (yuvarlak, kenarı kabarık), 193 taş gülle, 280 ok/kazık, 123 kalkan, kırık merdiven parçaları (581 parça); ağaç yok
  (benim kurduklarımda). Kapı önleri boş.
- (b) **Hilalli bayrak:** kaynağı `hayat_veri.gd:622, 623, 665` (DOKU-4'ün 17:05 hâlinde; ilk sayımda 595, 596, 638) (`sancak(..., desen = 3)` = `ist_bez.gdshader` hilal deseni;
  ordugâh sancakları rastgele 30–110 m'ye konuyor, hendeğe/sur dibine düşebiliyor). DOKU-4'ün dosyası: ORTAK İSTEK 1.
  `ISTHILAL sayi=3 hayat_veri.gd:622 hayat_veri.gd:623 hayat_veri.gd:665` (sonda `--set=hilal`; `Props.crescent` v2
  dosyalarında 0). `s3_hendek` SONRA karesinde hilalli bayrak görünmüyor ama kaynak duruyor: **YAPILMADI (benim dosyam değil)**.
- (c) **Beyaz-mavi kutular ve yuvarlak ağaçlar:** ağaçlar `IstDunya/Karsi_agac_-2_-1`, `Karsi_cali_-2_-1`
  (`dunya.gd:_karsi_kiyilar`, sur önü "kir/hendek" hücrelerine de ağaç/çalı koyuyor); kutular/çadırlar sur dışı katmanların
  (KANITSIZ: sondam MultiMesh örnek konumlarında 9 m'de eşleşme bulamadı). ORTAK İSTEK 1–2.
- Kareler: `pafta_01`, `pafta_12`, `kare/s3_hendek`, `kare/tani_ust`, `kare/kara_*_yer60`.

### 4. Uzak deniz surları — KISMEN
- Beyaz blok yığını değil: uzak katman yakınla aynı taş gölgelendiricisi (deniz türü), kule ritmi ve mazgal dişi
  (`pafta_10_uzak`, `kare/uzak_marmara_1000m`, `kare/uzak_halic_400m`). 1 km'den deniz suru koyu-gri tek bant; hatıl
  seçilmiyor (beklenen). Ton yakınından açık (yukarıda 3).

### 5. Sur üstü yürüyüş — KISMEN (bozulmadı, hepsi biraz arttı; eşiklere ulaşmadı)
`sehir2_kare --set=suryuru` (ÇEVRE-4'ün sondası, 15 m'de bir yürüme yolunun üstüne konup bir sonrakine yürünür):

| hat | 3. tur | SUR-4 (son kod) | hedef |
|---|---|---|---|
| kara | %88 | 131/145 = **%90,3** (düşme 3, takılma 11) | ≥ %97 |
| Blakherna | %74 | 15/19 = **%78,9** | ≥ %95 |
| Marmara | %85 | 159/176 = **%90,3** | ≥ %90 ✔ |
| Haliç | %64 | 87/123 = **%70,7** | ≥ %90 |
| Galata | %63 | 36/51 = **%70,6** | ≥ %90 |

(Beş dal birleşik son kodla `yuru3`; birleştirmeden önceki `yuru2` ile aynı sayılar.) Takılma türleri bu turda ayrıştırılmadı.

### 6. Kapılar — KISMEN
- Kuşatma: açık kapıların (Pege, Rhegion, Romanos, Pempton, Kharisios, Kaligaria) kanatları artık KAPALI, iç surda ve dış
  surun geçidinde, demir bağlı, sürgü kirişli (`surlar_kapi.gd:build`). Altın Kapı örülü ve mermer (önceden). Hendek köprüsü
  kaldırılmış: iki yakada taş ayak, arası açık, kırık kalaslar (`surlar.gd:_build_moat`). Kare: `sahip_03` (Romanos kanadı),
  `kare/kara_05_*`.
- Her kapının kendi kimliği: genişlik/yükseklik/kule oranı ve hasar önceki gibi; bu turda kapı başına ayrı kare ALINMADI
  (KANITSIZ). Deniz kapıları: BAKILMADI.

### 7. Kanıt
- Kara suru boyunca 12 nokta × (dışarıdan 30 m + yerden 60 m) + 4 noktada sur üstünden iki yön: ✔ (`pafta_02–08`).
- Marmara, Haliç, Galata dörder kare + birer sur üstü: ✔ (`kare/`), gece ikişer + kara iki: ✔ (`pafta_11`).
- Uzak katman 400 m ve 1 km'den dörder: ✔ (`pafta_10`). Sahip 03/04 ÖNCE | SONRA: ✔ (`pafta_01`).

## Süreklilik tablosu (`ISTSURSUREKLI`, son kod, beş dal birleşik)

| hat | katman | örnek | boşluk ÖNCE | boşluk SONRA |
|---|---|---|---|---|
| kara (iç sur) | yakın / orta / uzak | 438 | 1 / 1 / 1 | **0 / 0 / 0** |
| kara (dış sur) | yakın / orta / uzak | 438 | 34 / 34 / 35 | **3 / 3 / 3** (s=2 hat ucu; 2158, 2162) |
| Blakherna | yakın / orta / uzak | 58 | 0 / 0 / 0 | **0 / 0 / 0** |
| Marmara | yakın / orta / uzak | 529 | 6 / 6 / 6 | **0 / 0 / 0** |
| Haliç | yakın / orta / uzak | 372 | 6 / 6 / 8 | **1 / 1 / 1** (s=2 hat başı) |
| Galata | yakın / orta / uzak | 154 | 19 / 19 / 19 | **0 / 0 / 0** |

(ÖNCE sütunu: taban geometri, aynı sonda; `ISTSURSUREKLI hat=<ad> katman=<k> ornek=N bosluk=K` satırları.)

## Bütçe (oyunun RINFO'su; sur4 sondası, yakın katmanlar kurulu)

64 kare çifti (ÖNCE taban, SONRA birleştirmeden önceki SUR-4): ortalama çizim **+31,6** (~%3), üçgen ortalama **+0,2 %**.
Ayrıntı:

| kare | ÖNCE çizim | ÖNCE üçgen | SONRA çizim | SONRA üçgen | fark |
|---|---|---|---|---|---|
| kara_00_dis30 | 917 | 2,50 M | 945 | 2,46 M | +28 / −1,7 % |
| kara_03_dis30 | 1 244 | 2,52 M | 1 322 | 2,68 M | +78 / +6,3 % |
| kara_04_yer60 | 1 353 | 2,93 M | 1 328 | 2,87 M | −25 / −1,8 % |
| kara_05_yer60 | 1 222 | 2,75 M | 1 245 | 2,81 M | +23 / +2,1 % |
| kara_06_ust_b | 1 165 | 1,99 M | **1 577** | 2,79 M | **+412 / +40 %** |
| kara_09_ust_b | 1 134 | 4,62 M | 1 387 | 3,40 M | +253 / −26 % |
| uzak_kara_1000m | 717 | 3,11 M | 869 | 2,69 M | +152 / −13 % |
| uzak_halic_1000m | 743 | 3,31 M | 974 | 3,02 M | +231 / −9 % |
| s3_hendek (son kod) | 859 | 2,41 M | 916 | 2,50 M | +57 / +4,0 % |
| sahip_03 (gezi) | 979 | 2,86 M | 1 056 | 3,20 M | +77 / +12 % |
| sahip_04 (gezi) | 871 | 2,57 M | 986 | 2,95 M | +115 / +15 % |

- Uçuş sınırı (1 500 / 3,5 M): bütün uçuş karelerinde tutuyor; tek aşım `kara_06_ust_b` sur üstünde (yer kipi) 1 577.
- Yer sınırı (1 200 / 2,5 M): ÖNCE'de de aşılıyor (kara yer60 karelerinin 9'unda ÖNCE > 1 200); SONRA aynı düzeyde.
  "Çizim artmaz" kuralı **tutmadı** (ort. +3 %, sur üstünde +412, uzakta +6…+231). Olası nedenler (ölçülmedi): uzak hücrelerin
  taş türüne göre bölünmesi, köşe dolgularının orta katmanı (178 öğe), hendek dibi MultiMesh'leri (dilim başına 2), ateş
  alanının 7 çizimi. sahip_03/04 gezi farkının bir kısmı öbür dalların birleştirilmesinden (KANITSIZ ayrımı).
- Kurulum (`sehir2_kare --set=yavas`, son kod): en uzun tek iş **kara dilim penceresi 33,8 ms** (`kara_suru_3`, tek
  pencereli kısa dilim; 3. turda 25,9 ms) — 6 ms hedefi aşılıyor, KÖTÜLEŞTİ (toprak setin trimesh çarpışması + dış bölge
  kademesi). Galata penceresi 16,9, Haliç 12,7 ms. Kare süresi ortanca 6,9 / p95 19,8 / p99 61,3 ms (beş dal birleşik).
  Açılışta tek seferlik: ateş alanı 59,2 ms (akışta değil).

## Testler
- `PARSECHECK PASS` (son kod).
- Başsız, bütün varyantlar (birleştirmeden önceki SUR-4 kodu): Bölüm 7 (10 varyant) ve 11 (10 varyant) **20/20 PASS**,
  komşu 6, 12b, 24 **PASS**; yasak satırların (SCRIPT ERROR, WARN_*, VISAUDIT, WALKTHRU, …) hiçbiri yok.
- Birleştirmeden sonra (beş dal): Bölüm 7 (boş, `=wall`) ve 11 (boş, `=helpwall`) yeniden **4/4 PASS**, yasak satır yok;
  öbür 16 varyant birleşik kodla yeniden koşulmadı.

## ORTAK İSTEK / BİLGİ

1. **DOKU-4 (`hayat_veri.gd`)** — hilal: 622, 623, 665. satırlarda `sancak(..., 0, 1, 3, ...)` desen 3 = hilal; dönem kuralı
   ve kuşatma: desen 4 (dikey şerit) ya da 2 yapılsın; ayrıca sur dışı sancak/çadır/kutu hendekten 60 m içeri konmasın:
   ```gdscript
   # hayat_veri.gd:663 civarı (sancak döngüsü)
   if IstGeo.sehir_ici(p.x, p.y) or IstGeo.su(p.x, p.y) or String(IstGeo.mahalle(p.x, p.y).get("alt", "")) == "hendek":
       continue
   sancak(Vector3(p.x, _h(p), p.y), rng.randf() * TAU, 6.0, 0, 1, 4, 3.0, 2.0)   # 3 → 4
   ```
2. **BAĞLAMA-4 (`dunya.gd`)** — (a) `_karsi_kiyilar`: sur önü (`tur == "kir"`, `alt == "hendek"`) hücrelerine ağaç/çalı
   konmasın (ateş alanı ağaçsız): `if alt == "hendek": continue`. (b) `_renk`: `alt == "hendek"` dalı zaten çiğnenmiş toprak;
   ama `sahip_04`'ün ön planı parlak yeşil — kamera noktasında `mahalle()` "hendek" dönmüyor olabilir; sur önü 200 m kuşakta
   `C_CIGNEN.lerp(C_KURU, …)` + solgun ot. (c) Arazi ağı `IstGeo.duzle` kayıtlarını uzak (lod 3) parçalarda da yenilesin
   (ben `yenile(alan)` çağırıyorum; kaba parçalar ilk kurulumdan kalıyor olabilir — KANITSIZ).
3. **ORDUGÂH-4 (BİLGİ)** — ateş alanı sınırı: kara suru ekseninden dışa 57–107 m (hendek dış yakası 50 m + 7) benim
   örtüm; hendekten 60 m (eksenden ~110 m) ötesi senin. Bu kuşakta senin öğen varsa ateş alanıyla çakışır.
4. **BAĞLAMA-4 (`tests/_ist/gezi.gd:_bekle`)** — kareden önce şehir kuyruğu da bitsin (yoksa sur dilimleri yarım):
   ```gdscript
   var s := IstSehir.active
   while s != null and not s._queue.is_empty() and Time.get_ticks_msec() - t0 < sn * 1000.0:
       await get_tree().process_frame
   ```
5. **ÇEVRE-4 (BİLGİ)** — `sehir.gd`'de yalnız sur işlevlerine dokundum: `_build`/`_pis`/`_pencere_is` içinde `_sur_tas`
   çağrısı; `_hatlar_v2` (kesik boyu, `_kose_dolgu`, `_hendek_oy`, `_ates_alani`); `_hat_far_add`, `_acik`,
   `_hat_far_commit`; yeni: `_sur_tas`, `_kose_dolgu`, `_hat_nokta`, `_prizma`, `_dis_dy`, `_hendek_oy`, `_ates_alani`.
   `sehir_eser.gd`'de yalnız `sur_uzak_mat`.

## Dosyalar
- Yeni: `scripts/world/ist/sur_doku.gd`, `scripts/world/ist/sur_zemin.gd`, `tests/_ist/sur4_kare.gd/.tscn`.
- Değişen: `surlar.gd`, `surlar_kapi.gd`, `surlar_ayrinti.gd` (ot rengi), `sehir.gd` (sur işlevleri), `sehir_eser.gd`
  (`sur_uzak_mat`). Kanca/sonda oyun koduna konmadı (yalnız `tests/_ist/sur4_kare.gd`).
- Yapılmayan: Mesoteikhion gedikleri, kademenin kulede gizlenmesi, kapı başına kare, deniz kapıları, takılma türleri.

## SAHİBİNE GÖSTERİLECEK 8 KARE

1. `pafta_01_sahip03_04_hendek.jpg` — sahibinin üç karesi aynı kamerayla ÖNCE | SONRA (yeşil prizma, tahta sur, hilal gitti).
2. `sahip_03_sur_disi_30m.jpg` — sur dışından: taş üçlü hat, kuleler bedene bağlı, kapalı Romanos kapısı, toprak set.
3. `kare/kara_04_dis30.jpg` — 30 m'den kara suru: iç sur, peribolos, dış sur, mazgallı hendek duvarı, taş kaplı hendek.
4. `kare/kara_03_ust_a.jpg` — sur üstünden: blok sıraları ve ince tuğla hatılı yakından, insan boyunda mazgal.
5. `kare/kara_05_yer60.jpg` — yerden 60 m: ateş alanı (çiğnenmiş toprak, gülle çukurları) ve hendek.
6. `kare/galata_1.jpg` — Galata suru: Ceneviz kesme taşı, tuğlasız; önünde gemiler.
7. `kare/uzak_kara_400m.jpg` — 400 m'den kara suru ve ordugâh: uzak katman taş silüeti, kule ritmi.
8. `kare/gece_kara_05_dis30.jpg` — gece kara suru: ay ışığında taş, bembeyaz değil.
