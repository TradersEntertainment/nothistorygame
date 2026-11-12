# İstanbul v2 — DOKU-4 raporu (dördüncü tur)

Dal `wip/ist2-doku4` (taban `wip/ist2-taban4`; SUR-4, ORDUGÂH-4, ÇEVRE-4, BAĞLAMA-4 dalları iki kez çekilip birleştirildi,
çakışma yok). Görev: `docs/_ajan/gorev/ist2_tur4.md` "DOKU-4". Etiketler: TAMAM / KISMEN / YAPILMADI / KANITSIZ / BAKILMADI.
Kareler: xvfb + llvmpipe (yazılımla çizim) 1280×720. ÖNCE = `wip/ist2-taban4` (depo dışı çalışma ağacı, aynı sonda);
SONRA = bu dalın birleşik son kaydı (depo dışı anlık görüntü). Sonda: `tests/_ist/doku2_kare.tscn -- tur=4 [gece=1]`
(sokak bakışlarında kamera en yakın düz sokağa oturur: SONRA'da sokak ağı değiştiği için bazı yer kareleri ÖNCE ile aynı
sokakta değil; bakış koordinatı aynı). Sahip kareleri: `tests/_ist/gezi.tscn` + `gezi_sahip*.txt`.

## 1. Yükleme ve takılma — ÖNCE | SONRA

Komut (aynı, başsız, yalnız başına koşuldu): `godot --headless --max-fps 60 --path . res://tests/_ist/baglama_ucus.tscn --
bolum=11 kip=olc` · `BAGLAMA_YUKLE` = bölüm sahnesinin eklenmesinden ilk kareye · `BAGLAMA_TAKILMA ucus_60sn` = 60 sn uçuşta
> 50 ms kare · `acilis_20sn` = açılıştan sonraki 20 sn (kart, kararma, konuşma; oyuncu donuk).

| ölçü | ÖNCE (taban4) | SONRA-1: yalnız DOKU-4 (`9bf8ac2b`) | SONRA: birleşik son dal |
|---|---|---|---|
| yükleme, sıcak önbellek (3 koşu) | 44,6 / 37,8 / 34,4 → **37,8 sn** | 20,7 / 19,7 / 21,0 → **20,7 sn** | 26,5 / 25,4 / 27,1 → **26,5 sn** |
| yükleme, ilk açılış (önbellek boş, `--onbellek=yaz`) | (önbellek yok: yukarıdaki) | 39,5 sn (1 koşu) | 42,7 sn (1 koşu) |
| uçuşta > 50 ms (3 koşu) | 22 / 22 / 20 → **22** | 12 / 18 / 19 → **18** | 31 / 29 / 31 → **31** |
| açılış 20 sn'de > 50 ms | 29 / 14 / 11 → 14 | 16 / 15 / 16 → 16 | 44 / 34 / 37 → 37 |

Birleşik dalda yükleme 37,8 → 26,5 sn (SONRA-1'den kötü: ordugâh 2,5 → 6,4 sn, ön-pişirme 7,8 sn, IstSehir 3,3 sn; benim
katmanlarım aynı). Uçuş takılması birleşik dalda ÖNCE'den KÖTÜ (22 → 31); `ISTPROF mahalle_doku` 29–33 kare > 33 ms
(benim akışım: öğe/zemin hücreleri; ikinci düzeltme denemesi `f_d1` 33 → ölçüldü, düzelmedi).

Hedefler: ilk kareye ≤ 10 sn → **KISMEN** (DOKU-4 payı ≈ 19 sn → ≈ 1,5 sn; toplam 37,8 → 20,7 sn; kalan büyük kalemler
başkalarının: ÇEVRE-4 ön-pişirme ~7 sn, IstSehir yerleşim ~3 sn, ordugâh 2,5–7 sn, IstDunya ~1 sn → ORTAK İSTEK 1–3).
Uçuşta > 50 ms ≤ 3 → **YAPILMADI, birleşikte kötüleşti** (yukarıda; kendi payım `ISTPROF`).

Kırılım (DOKU-4 katmanları, sıcak önbellek, ÖNCE → SONRA; `ISTSOKAK`, `ISTDOKU2`, `ISTDOKU3`, `ISTKISI`, `ISTEVONBELLEK`):

| iş | ÖNCE | SONRA |
|---|---|---|
| sokak ağı + evler + doku (`IstSokak.build`) | 6,8 sn | 0,13 sn (disk) |
| sokak zemini (22 hücre, 309 bin kare) | 4,0–4,6 sn | arka plan iş parçacığı + ilk karelerden sonra kare bütçesiyle |
| avlu katmanı (+ yeni çatı geçitleri) | 0,9 sn | ~0,8 sn (disk; dizilerden ağ) |
| sokak eşyası yerleşimi | 0,85 sn | 0,01 sn |
| ev ağlarının ısınması (ön-pişirmenin içinde, 876 ağ) | ~1,5–2 sn (kestirim) | 0,29 sn (disk) |
| yakın kişi katmanı | 0,83 sn (önbelleksiz ilk açılışta 6,3) | 0,24 sn (14 gövde; kalanı oyunda) |
| gemiler (313) | 0,55 sn | bölümde ertelenir (karede bir filo) |
| yaşam verisi | 0,35–0,6 sn | disk |

Paftalar: `p01_carsi`, `p02_sik`, `p03_surdibi`, `p04_bostan` (yerden 16 sokak karesi), `p05_hava`, `p06_forum_cati`,
`p07_gece_1`, `p08_gece_2` (gece sekiz), `p09_sahip_a`, `p10_sahip_b`, `p11_sahip_c` (14 sahip karesi ÖNCE | SONRA),
`p00_once_ozet` (ilk gönderimin ÖNCE özeti). SONRA sahip kareleri: `sahip_01…14_*.jpg`.

## 2. Kendi karelerime bakınca hâlâ kötü olanlar

- **Sık mahallede yer yer düz yeşil yamalar** (`p02` SONRA `y4_sik_2`, `y4_sik_4`): parsel dokusu 6 m ızgaranın boş
  noktalarını aldı, ama sokak kenarı ile ev arası şeritler ve küçük boşluklar hâlâ çıplak çimen. Kötü.
- **Duvar dibinde fosforlu açık yeşil topaklar** (`p02` SONRA `y4_sik_1`): ağaç/çalı paletini soluklaştırdım (Mese'deki
  topaklar gitti, `p01`), ama bunların kaynağını bulamadım (sokak eşyası mı ÇEVRE parçası mı: BAKILMADI). Kötü.
- **Hub'ın sur yanındaki yeşil şerit** (`p05` SONRA `h4_hub_30`, sağ): çevre yolu yalnız boş hücrelere girdiği için sur bandı
  ile hub arası yeşil kaldı. Hub'ın kendisi (pembe/turuncu evler, parlak kiremit) benim dosyam değil.
- **Gece yakın kuşak** (`p07` SONRA `g4_halic_100` ön planı): uzak ışıklar 280 m'den öte; 100–280 m arası yalnız yakın
  pencere dörtgenleri (450 m) ile seyrek. Galata yer karesinde (`g4_galata_yer`) kamera bir ağacın içinde (sonda kusuru).
- **Gölgede camgöbeği yol** (kalite notu 28, `p03`): denediğim taban ışıması güneşte yolları turuncuya çevirdi, geri aldım;
  sorun sürüyor.
- **Gemiler** (`p10` `sahip_09`): renkler soluklaştı ama gövdeler hâlâ kutu gibi; bu turda biçime dokunmadım.
- Sur dibi (`p03`): savunma yolu ve kalabalık iyi; yığınlar az (17).

İyi: gece Galata'dan/uçuştan şehir ışıklı (`p07`, `p08`, `sahip_14`); Mese'nin fosforlu topakları yok; havadan ağaç
renkleri doğal, batı mahallelerinde düz yeşil yerine toprak-parsel dokusu (`p05` `h4_bati_70`); sokaklarda kişi sayısı arttı.

## Kişi sayıları (`ISTKISI`, gündüz, 16 yer karesi; "görünen" = 90 m içinde ve görüş konisinde)

| | ÖNCE | SONRA |
|---|---|---|
| görünen (toplam / kare başına) | 153 / 9,6 | 191 / 11,9 |
| etkin (toplam) | 358 | 438 |
| çarşı karelerinde görünen | 25, 6, 12, 15 | 20, 11, 22, 21 |
| evde / havada / suda | 0 / 0 / 0 (bir karede evde 1) | 0 / 0 / 0 |
| uzak katman insan kaydı | 3 195 | 4 298 |

## Bütçe (RINFO, sonda kamerası, gündüz; sınır yerde ≤ 1 200 çizim / 2,5 M üçgen, uçuşta ≤ 1 500 / 3,5 M)

| bakış | ÖNCE çizim / üçgen | SONRA çizim / üçgen |
|---|---|---|
| y4_carsi_1 | 957 / 3,36 M | 948 / 3,48 M (✘ üçgen; yakın kişiler 164 çizim / 0,20 M) |
| y4_sik_2 | 635 / 1,60 M | 642 / 2,40 M |
| y4_surdibi_1 | 1 430 / 2,69 M | 1 500 / 3,24 M (✘; ÖNCE de aşıyordu) |
| y4_bostan_1 | 487 / 0,60 M | 649 / 1,32 M |
| h4_hub_30 | 801 / 3,18 M | 865 / 3,31 M |
| h4_mahalle_70 | 506 / 1,12 M | 495 / 1,23 M |
| h4_bati_70 | 669 / 2,24 M | 705 / 2,40 M |

Tam liste `ham_satirlar.txt`. Yer karelerinin üçgen aşımı ÖNCE'de de var (çarşı, sur dibi); SONRA'da artış kalabalık ve
birleşik dalın öbür katmanlarıyla karışık (katman payı: kişiler 26–164 çizim, sokak eşyası 4–8 çizim). Uzak gece ışıkları
tek çizim. Kurulumda tek iş: kendi akışlarımda `ISTPROF` en uzun kare işi `mahalle_doku` 85–113 ms (60 sn uçuşta 92–106 kare > 16 ms, 29–33 kare > 33 ms: uçuş takılmalarının bir kısmı BENİM; kaynak öğe/zemin hücresi kurulumu olmalı, çarpışma gövdesini kareye bölmek yetmedi — ölçüldü, BAKILMADI kaynağı), `hayat` ≤ 10 ms, `hayat_yakin` ≤ 30 ms.

## Testler
- `PARSECHECK PASS scripts=335` (birleşik dal).
- Birleşik dal, başsız: Bölüm 7 bütün varyantları (`- tea lost form wall wallkeep byz byzniko byzcell fez`) **10/10 PASS**,
  Bölüm 11 bütün varyantları (`- arrest escape persuade help helpwall lost fired hikmet niko`) **10/10 PASS**, komşular
  6, 10, 12b **3/3 PASS**; yasak satır 0 (`ham_satirlar.txt`). (Bir `b7_byzniko` satırı "YOK": iki koşucu aynı günlüğe yazdı;
  yeniden koşu PASS.)
- `SCRIPT ERROR` (StreetEye.is_night) ÖNCE'de her açılışta 13 → SONRA 0.

## 3. Madde madde hüküm

### 3.1 Yükleme ve takılma — KISMEN
Yapılan (yalnız kendi dosyalarım):
- **Disk önbelleği** (`user://ist_onbellek/`, zstd; ortak yardımcılar `IstSokak.onbellek_imza / onbellek_oku / onbellek_yaz`):
  imza = sürüm + oyun/motor sürümü + ilgili betiklerin md5'i + girdiler (anıt tabanları, oyun alanları, sur bantları, kapılar)
  + arazi özeti (64 × 64 örnek yükseklik/deniz/sur içi; öteleme, dönüşüm ve bölge yaması bunun içinde). Kod, arazi ya da
  yerleşim değişirse yeni imza, eski dosya silinir. `--onbellek=yok` (okumaz/yazmaz), `--onbellek=yaz` (soğuk ölçüm).
  - `IstSokak.build` (sokak ağı, 9 bin ev, doku, meydan): 6,8 sn → 0,13 sn
  - `IstMahalleDoku` zemin: 4,0–4,6 sn → arka plan iş parçacığında okunur (`WorkerThreadPool`), hücreler ilk karelerden sonra
    kare bütçesiyle kameraya yakından uzağa kurulur (zemin yalnız görünüş; çarpışma arazinin/evlerin)
  - avlu katmanı (duvar, ağaç, tarh, çatı geçidi ağları + çarpışma kutuları + avlu öğeleri): 0,9 sn → önbellekten
  - sokak eşyası yerleşimi: 0,85 sn → 0,01 sn
  - pişmiş ev ağları (`IstEvler.mesh`, 876 ağ; malzeme gömülmez, desen adından yeniden kurulur ve oturum içinde
    paylaşılır): ön-pişirmenin içindeki ev ısınması ~1,5–2 sn → 0,29 sn
  - döşeme dokusu (512 px piksel döngüsü) PNG olarak
  - yaşam katmanı kayıtları (`IstHayatVeri`): önbellekten
- **Zaman dilimli kurulum:** yakın kişi katmanı açılışta 14 gövde + 3 hayvan kurar, kalanı oyunda iki karede bir
  (önce bütün havuz: önbellek sıcakken 0,8 sn, ilk açılışta 6,3 sn); gemi filoları bölümde ilk karelerden sonra karede bir filo
  (`IstGemiler.ertele`; gezi/önizlemede hemen).
- **Hata:** `StreetEye.is_night` v2'nin yakın kişi katmanında (`CityLife` adlı `IstHayatYakin`) `night` alanı olmadığı için
  her açılışta 13 `SCRIPT ERROR` veriyordu (ÖNCE'de de var): `IstHayatYakin.night` eklendi; SONRA'da 0.

### 3.2 Çatıdan çatıya (1/5 → 5/5 istendi) — KISMEN (4/5)
- Neden takılıyordu (kendi dökümüm, `doku2_kare -- cati2=1`): bitişik iki evin yürünür üstü arasında 0,3–3,9 m fark (kat
  farkı, kiremit sırtı H+1,6 / düz dam H+0,18 / teras ve kule korkuluğu H+1,2) ve **bıçak sırtı**: kapsül 0,3 m'lik farkta
  bile sırtın ucunda kalıyordu.
- Yapılan (`mahalle_doku.gd _cati_gecitleri`, avlu katmanında; görünüş avlu duvarı ağında, çarpışma avlu duvarı akışında,
  kameranın VE oyuncunun 150 m çevresinde): aynı sıradaki bitişik her çiftte sınırın üstünde 0,9 m'lik ahşap **sahanlık**
  (yüksek olanın üstü hizasında), fark > 0,2 m ise iki evin sırt noktalarını birleştiren hat üstünde **ahşap basamaklar**
  (basamak ≤ 0,30 m, derinlik 0,30–0,55 m: evlerin dış merdiveniyle aynı kural) ve her kiremit sırtının üstünde 0,5 m'lik
  yürünür **mahya kalası**. Birleşik dalda: 5 362 geçit, 5 640 mahya; 22 çiftte basamak sığmıyor (kısa ev + büyük fark).
- Ölçüm (gerçek oyuncu `player.gd`, 2,4 m/sn, A'nın çatısından B'nin çatısına 7 sn; ŞEHİR'in `--set=oyun` seçimi + her
  mahallede 4 ek çift): ÖNCE ŞEHİR sınaması **1/5**; SONRA birleşik dal kendi sondamda **23/25**, ŞEHİR'in seçtiği ilk
  çiftlerde **4/5**. Kalan: Zeugma'da iki dükkânlı ev arası 2,1 m (başlangıçta takılıyor; nedeni BAKILMADI), Psamathia'da
  2,3 m'lik bir çift. Ham satırlar `ham_satirlar.txt` (`DOKU4 cati`).
- Sokaktan çatıya çıkış (≥ %25 istendi): ŞEHİR'in `ISTDELIK … sokaktan_yuruyerek` sayısı Psamathia %29, Kariye %23, Aksaray
  %20, Blakherna %0, Kontoskalion %0 (birleşmeden önceki koşu): **YAPILMADI** (bu turda çatı geçidine öncelik verdim).

### 3.3 Gece Galata'dan şehir karanlık — KISMEN (kare: `p07_gece_1.jpg`, `p08_gece_2.jpg`)
- YENİ `hayat_uzak_isik.gd` (class_name yok; `IstHayat` gece kurar): ışık kaynağı değil, ekranda sabit piksel boyunda ışıyan
  noktalar (tek MultiMesh, tek çizim, gölgelendiricide billboard; 280–420 m'de belirir, 6 km'ye kadar): yaşam katmanının
  gece pencereleri + evlerin %18–42'si (mahalle türüne göre) **15 472 pencere**, kandil/meşale/ateş haleleri **2 238**,
  surlarda nöbet ateşleri **133** (kara/Blakherna 45 m, deniz surları 70 m, Galata 60 m), ordugâh kamp ateşleri **155**.
  Kurulum 43 ms.
- Surların üstünde yakın 3B nöbet ateşi (mangal + alev + hale) **120** (`hayat_veri.gd _surlar`, gece).
- Ordugâh ufku: ORDUGÂH-4'ün kendi ateşleriyle çakışma ORTAK BİLGİ'de.

### 3.4 Sokak dokusu ikinci geçiş — KISMEN (kareler `p01`–`p05`)
- Evlerin arası düz parlak yeşil (ÖNCE `y4_sik_*`, `sahip_11`): 6 m'lik boş ızgara noktalarının hiçbir şey almayan %38'i
  artık parsel dokusu: sürülmüş bostan toprağı (sıra izli), kuru taş bahçe duvarı, çiğnenmiş patika + ot öbeği (tarh ağına,
  ek çizim yok).
- Fosforlu yeşil "oyuncak" ağaçlar/çalılar ve kar beyazı çiçekli taçlar: bütün bitki ağlarının köşe renkleri tek yerde
  soluklaştı (`IstBitki.palet`: yeşilde doygunluk × 0,62, parlaklık × 0,86; beyaz taç kreme). Gemiler aynı (gölgelendiricide
  doygunluk × 0,68).
- Gölgedeki yol/döşeme camgöbeği (kalite notu 28; ÖNCE `y4_surdibi_2`): zemin malzemesinde gündüz ortam ışığı kapalı +
  sıcak taban ışıması.
- Hub (Romanos iç yanı) ve Ayasofya meydanı oyun alanları: alanın 4,5 m dışında 5 m kaldırım çevre yolu + dört yandan
  dışarı bağlantı (yalnız boş/yol hücrelerinden; 14 parça); sıra evler çevre yoluna yaslanır (`h4_hub_30`).
- Mese ve ana caddelerin revakları ŞEHİR/ÇEVRE'nin parçası (`mese_*`): dokunmadım.

### 3.5 Yaşam — KISMEN (sayılar korunup artırıldı)
- Uzak/orta katman (`hayat_veri.gd _kusatma`, yeni): sur dibinde savunmaya taş ve su taşıyan **85** kişi + onarım yığınları,
  kilise ve eser meydanlarında dua eden **316** (kapıya dönük, diz çökmüş/ayakta), sık dokuda ve çarşıda koşuşan çocuk
  kümeleri **637**. İnsan kaydı 3 195 → **4 298**.
- Yakın (gerçek kişi modeli) havuzu 49 → **58** (kadın 8→10, çocuk 4→6, hamal 5→7, işçi 3→5, rahip 1→2); hedefler çarşı
  40→46, liman 28→30, sık 22→26, sur dibi 17→22, seyrek 10→11. Liman yük indirenler ve kedi/köpek önceki turdan.
- Kuşatma havası: sokak eşyasının sur dibi takımı (taş/tuğla yığını, gülle, ok sandığı, gabyon) önceki turdan; kapalı
  dükkân kepengi: YAPILMADI.

### 3.6 Forum ve meydan içleri — KISMEN (kare `p06_forum.jpg`)
- `IstSokak.FORUM_IDS` meydanlarında halka pazar köşesi, mumcu, kuyu, ayin alayı ile dolar; halkada öğesiz kalan her
  40 m'lik kareye pazar köşesi/mumcu/kuyu (`_kare_doldur`). Yapı ÇEVRE-4'ün.

## ORTAK İSTEK / ORTAK BİLGİ

**ORTAK İSTEK 1 — ÇEVRE-4 (`sehir.gd` `_on_pisir`, açılışın en büyük kalemi):** sıcak önbellekle ön-pişirme hâlâ ~6,7–7 sn
(geçici sayaçla ölçtüm, sonra geri aldım: v2 anıtları 2,0 sn · sur dilimleri 1,2 sn · `mod == "doku"` öğeleri 1,1 sn ·
kalan anıt modülleri ~2,5 sn). Öneri: (a) `mod == "doku"` öğeleri (bostan/bağ/harabe/şapel, kuyu/çeşme; öğe başına ~5 ms)
ön-pişirmeden çıksın, akışta kurulsun; (b) ön-pişirme ilk kareden sonra, bölüm kartı + kararma süresince (~3,6 sn) kare
bütçesiyle sürsün; (c) ev ısınması artık diskten (`IstEvler.mesh` önbellekli, 0,29 sn), dokunmaya gerek yok.
```gdscript
# _on_pisir() içinde, döngünün başı:
if mod == "doku":
    continue        # DOKU-4: doku öğeleri akışta (öğe başına ~5 ms) kurulur
```
**ORTAK İSTEK 2 — ORDUGÂH-4 (`IstOrdugah.attach`):** birleşik dalda açılışta 2,5–7 sn (`ISTPARCA`). Öneri: plan ve uzak hücre
ağları için aynı disk önbelleği (`IstSokak.onbellek_imza([...betik yolları..., plan girdileri, IstSokak.arazi_ozeti(...)])`,
`onbellek_oku/yaz`), ya da kurulumu ilk karelerden sonraya (`IstGemiler.ertele` örneği: `SceneTree.process_frame`'e bağlı,
karede bir iş).
**ORTAK İSTEK 3 — BAĞLAMA-4:** v2 kurulumu bölümün `_ready`'sinde eşzamanlı; "ilk kare ≤ 10 sn" ancak kurulumun bir kısmı
bölüm kartı/kararma sırasına (ilk karelerden sonraya) kayarsa tutar. Benim katmanlarım (zemin, gemiler, yakın kişiler) zaten
ilk karelerden sonra tamamlanıyor; `IstMahalleDoku.bekleyen()` bunları da sayar.
**ORTAK BİLGİ — herkes:** önbellek yardımcıları `IstSokak.onbellek_imza/oku/yaz/var` ve `IstSokak.arazi_ozeti(rect, n)`;
dosyalar `user://ist_onbellek/<ad>_<imza>.bin`. Yeni durağan dünya-konumu önbelleği yok (BAĞLAMA'nın `_onbellek_sifirla`
listesine ekleme gerekmez: önbellek imzası arazi özetini içerir).
**ORTAK BİLGİ — ORDUGÂH-4:** gece uzak ışık katmanı (`hayat_uzak_isik.gd` §4) ordugâh yerlerinin çevresinde ~155 ateş noktası
koyar (yalnız 280 m'den ötede görünen ışıyan nokta; yakında sizin 3B ateşleriniz). Sizin uzak ateşlerinizle çift olursa
§4'ü kapatmak tek blok.
**ORTAK BİLGİ — SUR-4:** gece surların yürüme yolunda nöbet ateşi (mangal kutusu + alev + hale; kara/Blakherna 45 m,
deniz surları 70 m; `IstSehir._walk_h` yüksekliğinde; `hayat_veri.gd _surlar`). Sur üstü yürüyüşte çarpışmasız.
**ORTAK BİLGİ — ÇEVRE-4 (forum içleri):** `IstSokak.FORUM_IDS` (konstantin, tauri, bovis, amastrianon, arkadius,
philadelphion, augustaion) meydanlarının halkası pazar köşesi/mumcu/kuyu/ayin ile dolar; yapı sizin.

**ORTAK İSTEK 4 — BAĞLAMA-4 (`tests/_ist/baglama_ucus.gd:129`):** birleşik dalda ölçüm sahnesi ayrıştırılmıyor ("There is
already a variable named q") ve süreç kapanmadan takılı kalıyor. Son ölçümü depo dışı anlık görüntüde şu yerel düzeltmeyle
aldım (dalıma koymadım):
```gdscript
		var ql := IstBaglama.kok.to_local(Vector3(x, 0.0, z))
		return IstBaglama.kok.to_global(Vector3(ql.x, IstGeo.h(ql.x, ql.z), ql.z)).y
```

## BAKILMADI / KANITSIZ
- Gerçek ekran kartıyla ölçüm (hepsi başsız ya da llvmpipe). Hareketli gözlemde belirme/kaybolma (yalnız durağan kareler).
- Sokaktan çatıya ≥ %25: bu turda ölçülmedi (YAPILMADI).
- Uzak ışık gölgelendiricisinin gerçek ekran kartında görünüşü (llvmpipe'ta çalışıyor: `p07`).
- Çatı geçitlerinin oyuncu yürüyüşü dışında (tırmanma kipi, Nihat'ın konması) etkisi: KANITSIZ.

## SAHİBİNE GÖSTERİLECEK 8 KARE
1. `p07_gece_1.jpg` — Galata kulesinden ve uçuştan gece şehir: ÖNCE karanlık, SONRA pencere/kandil/sur ateşi ışıkları.
2. `p08_gece_2.jpg` — surdan ordugâh ufku ve Mese gece: sur üstünde nöbet ateşleri, ufukta kamp ateşleri.
3. `sahip_14_gece_galata.jpg` — sahibin sabit gece karesi, SONRA: ışıklı yarımada.
4. `p05_hava.jpg` — havadan: fosforlu ağaçlar ve düz yeşil yerine soluk ağaçlar ve toprak/parsel dokusu.
5. `p01_carsi.jpg` — Mese yerden: döşemedeki fosforlu yeşil topaklar gitti, daha çok kişi.
6. `p02_sik.jpg` — sık mahalle yerden: dolu sokaklar, eşya, kişi (hâlâ kötü olan yeşil yamalar da burada).
7. `p06_forum_cati.jpg` — forum içleri (pazar köşeleri) ve çatıdan çatıya ahşap geçitler/mahya.
8. `p10_sahip_b.jpg` — sahip kareleri 06–10 ÖNCE | SONRA (Mese, Ayasofya meydanı, Hipodrom, Haliç iskelesi, sur dibi).
