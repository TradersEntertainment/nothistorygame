# İstanbul v2 — ŞEHİR-2 (yerleşim) raporu, ikinci tur (dal `wip/ist2-sehir2`)

Tarih: 12 Kasım. Görev: `docs/_ajan/gorev/ist2_tur2.md` "ŞEHİR-2"; sayılar `_ist2_ortak.md` "SON AYAR" (S = 0,35; ünlü eserler
k = 0,75; Ayasofya var olan model × 1,5), bağlayıcı notlar `ist2_kalite_notlari.md`. Taban `wip/ist2-taban2`; birleştirilen dallar:
`wip/ist2-dunya2` (S = 0,35 dahil, üç kez), `wip/ist2-doku2` (iki kez), `wip/ist-ordugah`, `wip/ist-gemiler`, `wip/ist-hayat`,
`wip/ist-guneybati`, `wip/istanbul-gorunus`, `wip/istanbul-arastirma` (üç kez); öbür parça dallarında yeni kayıt yoktu.
Düzenlenen dosyalar: yalnız `scripts/world/ist/sehir.gd`, `tests/_ist/sehir2_kare.gd` ve bu klasör.
Hüküm etiketleri: TAMAM / KISMEN / YAPILMADI / KANITSIZ / BAKILMADI. Kareler yazılımla çizim (xvfb, llvmpipe), 1280×720.

## Özet

| # | Madde | Hüküm |
|---|---|---|
| 1 | S = 0,35 ve yeni k değerleri, çakışma çözümü, hiçbir eser atılmaz | TAMAM (2 KALAN çakışma çifti, aşağıda) |
| 2 | Surların kesiti 1:1, kapılar yerinde, sur üstü yürüyüş, oyuncu sınaması | KISMEN (kara %88, Blakherna %79 geçiş; deniz surlarında modül merdiveni takılıyor) |
| 3 | IstOrdugah / IstGemiler / IstHayat bağlandı | TAMAM (bağlı; ordugâh yoğunluğu ve çizim sayısı ORTAK İSTEK) |
| 4 | Ufuk ve anıt okunurluğu | KISMEN |
| 5 | Zaman dilimi (ön-pişirme), ISTYAVAS ÖNCE / SONRA | KISMEN (30 → 4 yavaş iş türü; sur dilimi lod 0 hâlâ 7–34 ms) |
| 6 | Denetimler (delik/kapalı cep, çatıdan çatıya, eser paftası) | bkz. §6 |
| 7 | `flight_data_v2`: işaretler eser tepesinde, formlar | TAMAM (işaret) / KISMEN (form) |
| 8 | Oyun alanları boş, S = 0,35'teki yerleri | TAMAM |
| — | Eski dünya (parse/world/flight/city_check, Bölüm 6, 7, 11, 12b, 24) | PASS, yasak satır 0 |

## 1. Ölçek ve yerleşim — TAMAM

- `IstGeo.S` DÜNYA-2'den (0,35) geldi; `sehir.gd` içindeki bütün dünya konumları `IstGeo.w/w2/yol/kiyi/h` üzerinden türer
  (gerçek koordinatlı `YER2` tablosu; önceden çarpılmış tablo yok). Sondanın tam tepe yüksekliği de S'den türer.
- k değerleri (`IstSehir._k2`): ünlü/yan görev eserleri ve kapılar 0,75 (`UNLU` + kaydında `gorev: true` olanlar); öteki anıt ve
  kiliseler 0,6; çok yer kaplayanlar (`GENIS`): Hipodrom, Büyük Saray, Augustaion, Kontoskalion/Langa/Sophia limanları, Aetios/
  Aspar/Mokios sarnıçları 0,45; Bukoleon, Philadelphion, Kapitolion, Amastrianon, Bovis, Anemodoulion, Zeuksippos, Neorion,
  Haliç iskelesi 0,5; Konstantin ve Tauri forumları 0,6 (sütun 0,75 isterdi, forum meydanı 0,45–0,5: ortası seçildi, bkz.
  kusurlar); surlar ve sur kapıları 1,0 (`K_SUR`); Bozdoğan 0,75. Ayasofya: var olan model × 1,5 (`AYA_K`; taban ~54 m, kubbe
  tepesi ~40 m; anıtsal kapı/basamak 1,5 kat — kabul). Ayasofya'nın uzak katmanına gövde üstü kurşun çatı levhası eklendi (tam
  tepeden içi boş görünüyordu).
- **Çakışma çözümü** (`_coz_cakisma`): taban daireleri (yarıçap + 5 m pay) kesişen eserler merkezlerini birleştiren doğru
  boyunca itilir (komşuluk sırası korunur). Öncelik: Galata Kulesi, Hipodrom, Konstantin, Havariyun, Pantokrator, Khora, Tekfur,
  Studios (3, gerçek yerinden kaymaz) > yan görev / ünlü (2) > öteki (1); Ayasofya, Blakherna Sarayı, hattaki/kıyıdaki kayıtlar ve
  iki oyun alanı sabit engel. Kayan eser denize, sur dışına, sur bandına düşmez; gerçek yerinden en çok `1,6 r + 40 m`.
  Son koşu (`ISTCAKISMA`): kayanlar Augustaion 33 m, Milion 30, Aya İrini 36, Küçük Ayasofya 16, Hipodrom 17, Büyük Saray 63,
  Khalke 53, Zeuksippos 20, Nea 62, Anemas 21, Peribleptos 11, Galata rıhtım/ambar 3–7 m. **KALAN** (kayma sınırına takılan):
  Büyük Saray ~ Zeuksippos, Büyük Saray ~ Nea (üçü de harabe saray alanının parçaları; iç içe girme sınırlı). Atılan eser yok.
- **Hat üstündeki kayıtlar** (`_hat_dizi`): kapılar hat boyunca gerçek sırasıyla dizilir; kapı koşusu modülün 150 m'si yerine
  60 m (`GATE_L`, kesit 1:1), ardışık kapılar üst üste binmez: kara suru `mermerkule, altin_kapi, ksylokerkos, pege, rhegion,
  romanos, pempton, kharisios` (Altın Kapı 40 m, Ksylokerkos 29, Pege 40 m ileri itildi); Blakherna `kerkoporta`; Haliç
  `petrion, fener`. Kapı tabanı sur dilimleri gibi hat boyunca ortanca; hattaki kayıtlar artık arazi düzlemesine girmez (önce
  kapılar çevresinde zemini alçak tabana düzleyip çukur açıyordu).
- Ordugâh, gemiler ve hayat modüllerinin `catalog()` kayıtları yerleşimden çıkarıldı (kendi `attach`'leri kuruyor; önce otağ,
  şahi top, Diplokionion iki kez kuruluyordu).

## 2. Surlar — KISMEN

- Kesit 1:1: `IstSurlar.build_run(…, k = 1,0)` (iç sur 12 m, kule 19 m, dış sur 8,5 m, hendek 20 m), deniz surları
  `IstMarmaraSur.build_run(k = 1,0)` (12 m), Haliç modül parçası `IstHalicSur.build(k = 1,0)`; uzunluk hat boyunca S ile.
  Köşe kulesinin tepesi önceki dilimin yürüme yolu hizasında, temeli zemine iner (köşede basamak kalmaz).
- **Bulunan ve düzeltilen hata:** gizli lod 1 katmanlarının çarpışması fizikte kalıyordu: lod 1'deki DOLU kule bloğu lod 0
  kulesinin kapısını kapatıyordu (kara surunda yürüyüşün %90'ı takılıyordu). v2'de lod 1/2 katmanlarından çarpışma gövdeleri
  sökülür.
- Kapı koşusunun ve deniz surlarında kule tepesinin yürüme yolunu enine kesen alçak korkulukları kaldırılır (`_kapi_gecit`,
  mazgallarıyla).
- Sur bandı (evler için): surun iç yüzü + 5 m savunma yolu (`_walk_w/2 + 5,6 m`; önce kara surunda 26 m'lik boşluktu).
- Sur uzak katmanı (`_hat_far`): renkler kireçtaşı kremine çekildi (önce dokunun ortalaması yüzünden kahverengi "çit").
- **Işın sınaması (ISTSUR, 0,25 m adım; yürüme yolunda boşluk):**

| Hat | ÖNCE (tur 1, S = 0,5) boşluk | SONRA (S = 0,35) adım | boşluk |
|---|---|---|---|
| kara_suru | 1 157 / 12 504 (%9) | 8 745 | **40 (%0,5)** |
| blakherna_suru | 0 | 1 158 | 0 |
| marmara_suru | 199 (%1,3) | 10 561 | 239 (%2,3) |
| halic_suru | 30 (%0,3) | 7 417 | 197 (%2,7) |
| galata_suru | 43 (%1) | 3 071 | 108 (%3,5) |

- **Gerçek oyuncuyla yürüyüş (ISTSURYURU):** `scripts/player/player.gd` (CharacterBody3D; `move_mode = "script"`, gövde, basamak
  çıkma `step_up` ve yerçekimi oyunun kendisi), her 15 m'de yürüme yoluna konup bir sonraki noktaya en çok 8 sn yürür; takılınca
  zıplar (JUMP 3,6 m/sn ≈ 0,66 m). Geçti = varıp yürüme yolundan > 2,5 m düşmedi.

| Hat | uzunluk (m) | dilim | geçti | düştü | takıldı | not |
|---|---|---|---|---|---|---|
| kara_suru | 2 192 | 145 | **127 (%88)** | 6 | 12 | ilk 80 m (Mermer Kule + Altın Kapı kümesi) 5 takılma |
| blakherna_suru | 291 | 19 | 15 (%79) | 2 | 2 | |
| marmara_suru | 2 650 | 176 | 99 (%56) | 15 | 62 | modülün kule merdiveni |
| halic_suru | 1 862 | 123 | 40 (%33) | 15 | 68 | aynı merdiven (deniz suru parçası) |
| galata_suru | 770 | 51 | 13 (%25) | 9 | 29 | aynı merdiven |

  Deniz surlarındaki takılmaların çoğu `IstMarmaraSur._tower` merdiveni: 0,52 m basma × 0,28 m rıht, dokuz basamakla kule
  tepesine çıkıyor; oyuncu 7. basamakta (1,94 m) kalıyor (zıplama da aşmıyor). **Parça kusuru (marmara):** kule merdiveni
  oyuncunun basamak çıkma yoklamasına uymuyor ya da üstünde baş payı yok; ORTAK İSTEK aşağıda. Ilk turdaki "%9 kapı üstü
  boşluk" kapanmış durumda (ışın %0,5).
- Sur dışından 30 m ve 70 m'lik bakış (DÜNYA-2'nin sahip kareleri 03–04; benim `tur_5_kara_disi`): üç hat (iç sur + kuleler, dış
  sur, hendek) ve kuleler ufku kesiyor.

## 3. Yeni parçalar — TAMAM (bağlandı)

`IstSehir.attach_v2` sonunda (`_parcalar_bagla`; dosya yoksa atlanır): `IstOrdugah.attach(dunya, gece)`, `IstGemiler.attach`,
`IstHayat.attach` (hayat sokak ağını `IstSehir.sokak`'tan okur; dokudan sonra). Kurulum: ordugâh 1 ms (akışlı), gemiler
~0,8 sn, hayat ~0,35 sn. Kareler: sur dışında çadır alanları ve bataryalar, zincirin ardında filo, Haliç'te Osmanlı ve Latin
gemileri, sur üstünde ve sokakta insanlar. Ordugâh çadır denizi 70 m'den seyrek görünüyor (ORTAK İSTEK).

## 4. Ufuk ve anıt okunurluğu — KISMEN

- Kurşun kubbe ve çatılar (`_kursun`): parçaların mavimsi açık gri kurşun malzemeleri koyu kurşuna (#4C525A) çevrilir, toon
  kenar ışığı kapatılır; ilk denemede `material_override` önceliği yüzünden uygulanmıyordu (düzeltildi).
- Ayasofya × 1,5 ufukta en büyük kütle; Galata Kulesi, Hipodrom dikilitaşları, Konstantin/Arkadius/Markianos sütunları,
  Bozdoğan ve Pantokrator/Havariyun kubbeleri Galata ve şehir üstü karelerinde seçiliyor (`tur_5_galata`, `tur_5_ucus70`).
- Uzak katmanda büyük düz yüzeylerin (Konstantin forumu döşemesi, Mokios/Aetios/Aspar sarnıç tabanı) tam tepeden simsiyah
  görünmesi (`eser_uzak_pafta`, `tur_5_tepe`) SÜRÜYOR: motorun mesh LOD'u v2 pişmiş katmanlarında kapatıldı, düzelmedi; neden
  KANITSIZ (lod 2 düz pişirmede normal ya da renk). 70 m uçuş ve yakın karelerde yok (orada lod 1/0).
- Uzak sur ağı kireçtaşı kremine çekildi: Galata'dan Haliç surları ve kuleler taş duvar olarak okunuyor (`tur_5_galata`;
  önce kahverengi/ahşap görünüyordu, `tur_4_galata`).

## 5. Zaman dilimi — KISMEN

Açılışta ön-pişirme (`_on_pisir`): anıtların lod 1'i kurulur ve gizli bekler; lod 0 kurulup ölçülür, 4 ms'yi aşanlarınki
ağaçtan ayrık bellekte bekler (yaklaşınca yalnız ağaca bağlanır, uzaklaşınca yine ayrılır, yeniden kurulmaz); sur dilimleri ve
köşe kulelerinin lod 1'i açılışta. Açılışa eklenen süre ~4,6–5,8 sn (133–136 ön-pişmiş lod 0).
Ölçüm: aynı uçuş/yürüyüş yolu (Romanos'un iç yanı → Tauri → Konstantin → Ayasofya → Haliç → Galata → yerde Mese), 18 m/sn,
`--set=yavas`; tek iş = kurma + pişirme (6 ms'yi aşanlar):

| İş | ÖNCE (ön-pişirme kapalı) ms | SONRA ms |
|---|---|---|
| ayasofya lod 1 / lod 0 | 253,8 / 174,7 | — / — |
| mese lod 1 / lod 0 | 34,0 / 93,4 | — / — |
| hipodrom lod 1 / lod 0 | 69,7 / 91,8 | — / — |
| hipodrom_saray lod 1 / lod 0 | 22,1 / 71,4 | — / — |
| forumlar lod 1 / lod 0 | 13,5 / 45,5 | — / — |
| hipodrom_aug lod 1 / lod 0 | 16,7 / 26,2 | — / — |
| bozdogan lod 0 | 20,4 | — |
| zincir lod 1 / lod 0 | 11,6 / 16,5 | — / — |
| guneybati lod 1 | 13,5 | — |
| doku (bostan/bahçe/kilise/harabe/şapel) lod 1 | 8,4–29,2 | — |
| doku kilise/şapel lod 0 | 6,2–14,8 | doku lod 0: 6,8 |
| kara / marmara sur dilimi lod 1 | 15,0 / 18,4 | — / — |
| halic sur dilimi lod 1 / lod 0 | 40,7 / 81,7 | — / **16,7** |
| galata (sur dilimi) lod 1 / lod 0 | 13,4 / 33,4 | — / **33,7** |
| kose (köşe kulesi) lod 0 | 7,3 | 6,2 |
| ön-pişmiş katmanı bağlama (en çok) | — | 7,6 |
| kare süresi ortanca / p95 / p99 / en çok | 6,9 / 25,0 / 53,4 / 264 | 6,9 / 22,0 / 48,7 / 385 |

Sonuç: 6 ms'yi aşan iş türü 30 → 4; kalanlar sur dilimlerinin lod 0'ı (deniz/Galata suru 17–34 ms; kara suru bu yolda yakına
gelmedi, tur 2 ölçümünde 82 ms). Kare süresinin kuyruğu (p99 ~49 ms, en çok 385 ms) başka katmanlardan da geliyor (dünya
parçaları, ordugâh, hayat; şehrin kuyruğu ≤ 6 ms bütçe + tek iş). **≤ 6 ms/iş sağlanmıyor: KISMEN.** Sıradaki: sur dilimini
lod 0'da alt dilimlere bölmek (kule aralığı başına) ya da dilimlerin lod 0'ını yakın çevreye göre önceden kurmak.

## 6. Denetimler

- Eski `ISTAUDIT` (benim taban dikdörtgeni denetimim) DOKU-2'nin yeni ev modeline uymuyor (sıra/dükkân alanları değişti:
  `dar 259`, `cati_yolu_eksik_sira 1 900` sayıları bu yüzden anlamsız); ev aralığı denetimi DOKU-2'nin `doku2_kare`'sinde
  (rapor: dar aralık 0). BAKILMADI (benim tarafımdan yeniden yazılmadı).
- Eser paftası (24 eser): 15 m ve tam tepe; ayrıca 700 m'den uzak katman (siyah yüzey avı) — `eser_15m_pafta.jpg`,
  `eser_tepe_pafta.jpg`, `eser_uzak_pafta.jpg` (tur 4; Ayasofya kubbesi bu karelerde kurşun düzeltmesinden önce).

### 6b. Oynanış denetimi (`--set=oyun`, başsız, gerçek fizik; beş mahalle, her biri 80 × 80 m, 0,5 m ızgara = 25 600 hücre)

Delik: karada hiçbir çarpışmaya değmeyen ya da zeminin > 0,5 m altına inen ışın. Kapalı cep: zemin hizasındaki hücreden
sokağa yürüyüş + zıplamayla (komşu hücreye ≤ 1,1 m çıkış, iniş serbest) dönülemiyor. Çatı: zeminden > 2,5 m yüksek hücreler;
"sokaktan yürüyerek" = tırmanma kipi olmadan ulaşılabilen oran (tırmanma kipi bu ölçüme girmez).

| Mahalle (`IstGeo.mahalle`) | merkez (dünya) | delik | kapalı cep hücre | çatı hücre | sokaktan yürüyerek | çatıdan çatıya (oyuncu) |
|---|---|---|---|---|---|---|
| Psamathia | (−1567, 126) | **0** | 355 (≈ 89 m²; örnek −1607, 156) | 9 342 | %20 | KALDI |
| Kyparission | (−1290, −193) | **0** | 0 | 6 664 | %26 | KALDI |
| Aksaray (Bous) | (−1038, 28) | **0** | 2 (örnek −1078, 67) | 8 560 | %37 | KALDI |
| Zeugma (Unkapanı) | (−744, −496) | **0** | 0 | 9 455 | %25 | GEÇTİ |
| Konstantin Forumu | (−308, 126) | **0** | 52 (örnek −269, 95) | 8 884 | %0 | GEÇTİ |

Çatıdan çatıya: aynı sıradaki iki bitişik evin çatısında `Player` (script yürüyüşü) A'dan B'ye 6 sn yürür: 2 / 5 geçti; kalan
üçünde oyuncu iki çatı arasındaki sırtta/çatı farkında kalıyor (A 22,5 → 22,0 m; komşu evlerin kat farkı). Kapalı cepler:
Psamathia'da 355 hücre ve Konstantin'de 52 hücre — avlu/bahçe duvarıyla ya da anıt tabanıyla çevrili, çıkışsız zemin parçaları
(kaynağı, DOKU-2 avlusu mu anıt mı: KANITSIZ, kare alınmadı). Sokaktan çatıya erişim (yalnız yürüyüş+zıplama) %0–37: geri
kalanı `IstEvler.climbs` (sandık → tente → tırmanma) ile; tırmanma kipiyle oyuncu sınaması BAKILMADI.

## 7. Nihat'ın yan görevi (`IstSehir.flight_data_v2`) — TAMAM (işaret) / KISMEN (form)

- İşaret: eserin kurulmuş ağının en yüksek 3 m'lik kümesinin tam üstü + 8 m (Ayasofya + 6 m; Bozdoğan + 9 m), yarıçap
  `max(bakis_r, 0,8 r)`. İlk dokuz aynı kimlik ve sırayla; ardından 33 `gorev` eseri (ordugâh kayıtları artık ordugâhın).
  Kare: `isaret_pafta.jpg` (32 eser, kırmızı küre işaret): hepsi eserin üstünde; Eugenios'ta modülün deniz plakası karada.
- Konma noktaları: 34 / 34 gerçek çarpışmalı yüzeyde (ISTKONMA).
- Formlar (12): Ayasofya kubbe kapağı, Konstantin sütunu, Galata Kulesi, Hipodrom, Bozdoğan, Havariyun, Blakherna, Eugenios
  (konma noktası varsa onun 0,6 m üstü), San Domenico (Galata sırtı), Kız Kulesi adacığı, Romanos, Üsküdar sırtı. ISTFORM
  (altında 3 m içinde çarpışma): önce 6 / 12 (haç ucu, havada), sonra **8 / 12**; kalan: Bozdoğan ve Blakherna (en yüksek
  köşe görsel bir parça), Kız Kulesi ve Üsküdar (zemin üstünde; dünyanın arazi çarpışması yalnız oyuncunun çevresinde akıyor,
  sınama anında uzakta: KANITSIZ).

## 8. Oyun alanları — TAMAM (boş)

`IstSehir.oyun_alanlari()` (ev, ağaç, doku yok; eser çakışma çözümünde sabit engel): hub (6b, 7b, 10h, 12b, 23, 24)
Romanos Kapısı'nın iç yanında, kapıdan 75 m içeride 90 × 90 m; Ayasofya meydanı (24, 25, 26, 31o) Ayasofya'nın batısında
(narteks önü, Ayasofya × 1,5'e göre kaydırıldı) 55 × 50 m. S = 0,35'te (`ISTOYUN`):

| Alan | dünya merkezi (x, z) | boyut | gerçek (doğu, kuzey) |
|---|---|---|---|
| hub (Romanos'un iç yanı) | (−1620, −289) | 90 × 90 m | (−4630, 826) |
| Ayasofya meydanı | (−90, 0) | 55 × 50 m | (−259, 0) |

## 9. Bütçe (tur 4, 1280×720; RenderingServer toplamı: dünya + şehir + ordugâh + gemiler + hayat)

| Kare | çizim | üçgen | sınır | baskın (kırılım) |
|---|---|---|---|---|
| tur_4_galata (60 m) | 934 | 1,87 M | 1 500 / 3,5 M ✔ | ordugâh 213, gemiler 118, şehir ağları 101 |
| tur_4_kara_disi | 1 030 | 2,11 M | ✔ | ordugâh 273 |
| tur_4_marmara | 866 | 2,04 M | ✔ | ordugâh 345 |
| tur_4_sarayburnu | 1 231 | 2,10 M | ✔ | ordugâh 417, şehir ağları 268, köşe kuleleri 108 |
| tur_4_ucus70 | 631 | 1,25 M | ✔ | ordugâh 493 |
| tur_4_tepe (1 834 m, oyunda yok) | 1 682 | 2,52 M | ✘ | |
| yer_4_mese | 1 947 | 3,60 M | 900 / 2,5 M ✘ | ordugâh 494, mahalle dokusu 328, şehir ağları 281, köşe 118 |
| yer_4_bostan_koy | 1 548 | 2,56 M | ✘ | ordugâh 541, mahalle dokusu 375 |
| yer_4_halic_iskele | 1 266 | 2,08 M | ✘ | |
| yer_4_sur_dibi | 979 | 1,52 M | ✘ (çizim) | |
| yer_4_ayasofya_bati | 757 | 1,20 M | ✔ | |

Yerde bütçe aşılıyor: en büyük pay **ordugâh (~500 çizim, şehrin ortasından bile)**, sonra DOKU-2'nin mahalle dokusu (~350) ve
şehrin birleşik ağları (~300). Benim payım için yapılan: köşe kulelerinin lod 1 yarıçapı (uzak sur ağının başlangıcı 360 → 200 m)
küçültüldü. Tur 5 (aynı noktalar):

| Kare | tur 4 çizim / üçgen | tur 5 çizim / üçgen | baskın (tur 5) |
|---|---|---|---|
| tur_5_galata | 934 / 1,87 M | 742 / 1,86 M | |
| tur_5_kara_disi | 1 030 / 2,11 M | 904 / 2,07 M | |
| tur_5_sarayburnu | 1 231 / 2,10 M | 1 165 / 2,09 M | |
| tur_5_ucus70 | 631 / 1,25 M | 555 / 1,28 M | |
| yer_5_mese | 1 947 / 3,60 M | **1 167 / 2,79 M** | şehir ağları 287, mahalle dokusu 222, ordugâh 174, köşe 44 |
| yer_5_halic_iskele | 1 266 / 2,08 M | 946 / 1,65 M | ordugâh 337, halic 190 |
| yer_5_bostan_koy | 1 548 / 2,56 M | 1 310 / 2,37 M | ordugâh 517 |
| yer_5_sur_dibi | 979 / 1,52 M | 957 / 1,58 M | ordugâh 543 |
| yer_5_ayasofya_bati | 757 / 1,20 M | 751 / 1,21 M | ordugâh 505 |
| yer_5_cati_0 | 1 350 / 3,08 M | 1 334 / 3,07 M | ordugâh 494, mahalle dokusu 353 |

Uçuşta sınır içinde; yerde çizim 750–1 330 (sınır 900): ordugâhsız (−~500) yerdeki karelerin hepsi sınırın altına iner.
KISMEN; ORTAK İSTEK: ordugâh.

## 10. Eski dünya (IstSehir kapalı) — PASS

parse_check PASS (322 betik), world_check PASS (regions=13 landmarks=35), flight_check PASS, city_check PASS, Bölüm 6, 7, 11, 12b,
24 başsız AUTOTEST PASS; yasak satırların hiçbiri yok.

## 11. Parça kusurları (parça adıyla)

- **marmara (IstMarmaraSur._tower):** kule tepesine çıkan dokuz basamaklı merdiven gerçek oyuncuyu 7. basamakta tutuyor;
  kule tepesinin yan korkulukları yürüme yolunu enine kesiyordu (şehir tarafında söküldü).
- **surlar (IstSurlar):** lod 1'de kule DOLU kutu (çarpışmalı); Altın Kapı/Mermer Kule kümesinde (hattın ilk 80 m'si) yürüyüş
  takılıyor; kapı kulelerinin tepe korkulukları yürüme yolu hizasına gelince yolu kesiyor.
- **forumlar:** Konstantin Sütunu pembe (porfir koyu mor-kızıl olmalı); forum döşemesi ile sütun aynı k'yi paylaşıyor.
- **halic (Eugenios):** deniz plakası kıyıya uymuyor, karada.
- **galata:** uzak katmanda pişmeyen parçalar (tam tepede ~130 çizim).
- **ordugah:** çadır denizi seyrek; uzak katmanı birleşik değil (~500 çizim her yerden).

## 12. ORTAK İSTEK

- **ordugâh (`wip/ist-ordugah`):** uzak katman (> 400 m) hücre başına tek ağ; çadır yoğunluğu otağdan Marmara'ya ve Haliç'e.
- **marmara (`wip/ist-marmara`):** `IstMarmaraSur._tower` merdiveni: basma ≥ 0,6 m, rıht ≤ 0,3 m, merdiven üstünde ≥ 2,2 m baş
  payı; kule tepe korkuluğunda yürüme yolu hizasında 2 m'lik geçit.
- **surlar (`wip/ist-surlar`):** lod 1 kulesi çarpışmasız (`_s(..., lod)` lod ≥ 1'de `Props.box`); kapı kulesi tepe
  korkuluğunda geçit.
- **DOKU-2:** `IstMahalleDoku` yerde ~350 çizim (bütçe).

## 13. BAKILMADI / sıradaki

- Sur dilimlerinin lod 0'ını alt parçalara bölmek (≤ 6 ms).
- Sokaktan çatıya tırmanma (traversal kipi) gerçek oyuncuyla: yalnız yürüyüş+zıplama erişilebilirliği ölçüldü (§6b).
- Gece karesi bu turda yenilenmedi (ilk turdaki gece katmanı yerinde).
- Uçuş bölümlerinin (7, 11) v2'ye bağlanması ayrı pakette.
