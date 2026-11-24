# TUR 15 — 17o: Haliç'in karşı kıyısındaki uzak surlar yeni deniz suru kalemiyle

Dal `wip/ist2-tur15` (taban `wip/ist2-birlesik` f1f007c5). Değişen oyun dosyaları: `scripts/world/horn_world.gd` (yalnız
seçmeli yol), `scripts/world/ist/deniz_set.gd` (yalnız iki yeni yardımcı), `scripts/level/galata_view.gd` (yalnız seçmeli yol).
`chapter17o.gd`, `siege_field.gd`, `scenery.gd`, `sur_kule.gd`, `sur_doku.gd` ve öteki bölümler değişmedi.

## Sonuç

| Kesme sırası | Durum |
|---|---|
| 1 Karşı kıyı Haliç surları yeni kalemle, eski kutular yok, öteki bölümler aynı | **TAMAM** |
| 2 17o çeşitleri ×2, eski kip, ZFIGHT, sondalar | **TAMAM** (hepsi PASS, denetim 0) |
| 3 Kareler + rapor | **TAMAM** (20 bakış × ÖNCE/SONRA, eski kip 6 × 2, sahip 3) |
| 4 `in_world = false` yolu (`_far_galata`) yeni kalemle | **YAPILMADI** (gerekçe aşağıda) |
| 5 Bütçe iyileştirmesi | **TAMAM** (240 m parçalı ağ; ilkel ve çizim tabanın altında) |
| DÜZELTME 5(a) Galata surları | **TAMAM** |
| DÜZELTME 5(b) Blakherna kabuğu, 5(c) kara surlarının Haliç ucu | **Görünmüyor → dokunulmadı** (kare 20) |

## Kök neden

`HornWorld._deniz_yakin` yeni kalemi yalnız bölümün `keep` alanına **≤ 250 m** olan kıyı suruna veriyordu. 17o'nun keep'i
Haliç'in kuzey kıyısında (dünya x −1108…−914), karşı sur x −700'de: eşik koşunun yalnız ortadaki ≈540 m'sini (dünya z
≈ −903…−1397) alıyordu. Geri kalan her şey `_wall_run`'ın eski dalından kuruluyordu: düz kutu gövde + iki kırmızı tuğla
şeridi + kutu dişler (`merl` çoklu ağı) + kutu kuleler (kırmızı kapaklı). Ayrıca üç kaynak eşiğin hiç dışındaydı:
Eugenius kulesi (`d.cyl` silindir, kırmızı halka), buruna ve Marmara'ya dönen koşular, **Galata surları**
(`GalataView.build`: kutu gövde, kutu mazgallar, kutu burçlar — oyuncunun kendi kıyısında, 80–400 m). Kare 16 ÖNCE dikişi
açıkça gösteriyor: solda yeni kalem, sağda düz açık gri kutular.

## Seçilen yol (DÜZELTMELER 2–4'e göre; `keep` genişletilmedi)

1. **Bölge adına bağlı sabit** — `horn_world.gd`: `const DENIZ_UZAK := {"springs": INF}`; `_deniz_yakin` eşiği
   `DENIZ_UZAK.get(region_name, DENIZ_YAKIN)`. "springs"i yalnız 17o kurar (`chapter17o.gd:142`; grep'le doğrulandı).
   Öteki bölgelerde eşik 250 m, kod yolu aynı. `_deniz_eski_mi()` (eski `--eskisur` denetimi aynen, ayrı işleve alındı) ve
   `_deniz_bolge()` (= keep var, bölge DENIZ_UZAK'ta, eski istenmedi).
2. **Kapsam (springs)**: Haliç koşusu (Blakherna köşesi → SHORE_END), buruna dönen koşu, Marmara koşusu (çoğu şehrin
   ardında, görünmez; ama eski kutu kurulmaz), Eugenius kulesi (`deniz_set.uzak_yuvarlak_kule`: uzak_kule'nin halka
   profili 14 kenarlı yuvarlak planda; yosunlu kaide, silme, mazgallı teras, 7 diş), Galata surları ve burçları
   (`GalataView.build(..., yeni_sur)` → `deniz_set.uzak_parca_uclu` + `uzak_kule`).
3. **Galata yamacı**: sur yamaca ≤ 8 m'lik **düz tepeli basamaklarla** tırmanır (uzak_parca dişleri a.y'de; eğimli parça
   dişleri havada bırakırdı). Basamak tabanı altındaki en alçak zemin (5 nokta × 2 yan örnekle), dip 2 m daha aşağıda
   (havada değil), tepe en yüksek zeminin 4,5 m üstü. Basamak uçları kapalı (`uzak_parca_uclu`: gövde, korkuluk, kaide
   kesiti) — açık iç görünmez. Burç: 4,4 m pahlı kare, tabanı ayak izinin en alçak zemini, terası sur tepesinin 2 m üstü;
   gece ateşi terasın üstüne oturur. `rng` tüketimi eskisiyle aynı (rıhtım, direkler, gemiler aynı yerde).
4. **Bütçe (kesme 5)**: springs'te koşunun ağı 240 m'lik parçalara bölünür (eski kutuların Dressing parça boyu;
   `_deniz_ag_al(p)` hücre → Ag), her parça `visibility_range_end = 1200` (`DENIZ_GORUNUR`). Tek ağ hâlinde kadraj dışı
   2 km'lik Marmara koşusu da çiziliyordu (ilk deneme: ilkel +%6,6'ya kadar); parçalı hâlde ilkel tabanın altında.
5. **Malzeme/ton**: hepsi `sur_doku.mat(1, Color("c9b89a"), false)` — 17, 18b, 19, 29… deniz bölümlerinin uzak
   katmanıyla aynı ressam. Çarpışma yok (`no_walk`; `Ag.mesh_ekle` de koyar). Işık, Galata ışığı, sis, gök değişmedi.

DENIZSET satırları (17o, SONRA; ÖNCE tek satırdı: `DenizSurUzak_740 bolge=springs ucgen=3852`):
```
DENIZSET galataview GalataSurYeni ucgen=6616
DENIZSET hornworld DenizSurUzak_740 bolge=springs ucgen=12212 parca=8
DENIZSET hornworld DenizKuleEugenius bolge=springs ucgen=224
DENIZSET hornworld DenizSurUzak_2360 bolge=springs ucgen=748 parca=2
DENIZSET hornworld DenizSurUzak_714 bolge=springs ucgen=14204 parca=13
```

## Öteki bölümler bit bit aynı (kural 1)

- **DENIZSET, otomatik test**: 4b (`--chapter=4 --autotest=chain`), 17, 18b, 19, 19o, 29, 29o, 38o, 8, 26 — ÖNCE (taban
  kopyası) | SONRA: `testler/denizset_once_sonra.txt`; fark dosyası `testler/denizset_fark.txt` **boş**. Hepsi
  AUTOTEST PASS, denetim satırı yok (`testler/onceA_*`, `onceB_*`, `sonraA_*`).
- **Görünüş karması** (`tests/_ist/tur15_karma.tscn`: HornWorld altındaki her GeometryInstance3D'nin yolu, sınıfı,
  dönüşümü, görünürlüğü, ağ köşeleri ve renkleri, MultiMesh örnekleri → MD5): 2, 18, 18b, 27 (GalataView'ün kendi
  bölgesi), 38o, 17, 19, 19o, 29, 29o ÖNCE = SONRA (`testler/karma_once.txt`, `karma_sonra.txt`). **Dürüst not**: bölüm 2'nin
  ilk ÖNCE koşusu farklı karma verdi (f904…); ÖNCE iki kez daha ve SONRA iki kez koşuldu, dördü de 26aa… (`karma_once2b`,
  `karma_sonra2b`): ilk koşu tek seferlik sapma (değişiklikle ilgisi yok: taban kodu). 6, 8, 8y, 26 HornWorld kurmuyor
  (karma aracında `horn=yok`); bunlar DENIZSET/otomatik testle karşılaştırıldı.
- SeaWalls bölümlerinin `GalataView.build` çağrısı yeni parametreyi vermez (varsayılan `false`): kod yolu aynı.

## Doğrulama (son kod; kopya2 = dal, `cmp` ile denetlendi)

| Denetim | Sonuç |
|---|---|
| `parse_check` | PARSECHECK PASS scripts=368 |
| `sur_sozlesme` | SURSOZLESME PASS kalem=13 kesim=8 |
| `sur_oyun_denetim` | SUROYUN nokta=519 havada=0 gomuk=0 katida=0 |
| `sur_oyun_yuru` | WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0 |
| `esya_fizik` | ESYATEST PASS |
| `tasima11_halic_sonda` | HALICSONDA OZET carp=661 karma=3854034809 (aynı) |
| `tur14_marmara_sonda` | MARMARASONDA OZET carp=1837 karma=2250736444 (aynı) |
| ZFIGHT `chapter17o.tscn` | 0 satır (`ZSCENE boxes=302 found=0`) |
| 17o `""`, `=slow`, `=kadri`, `=alone` × 2 | 8/8 AUTOTEST PASS, BİTER, denetim 0 (`testler/t17o_1_*`, `t17o_2_*`) |
| 17o `--autotest --eskisur=17o` | PASS, denetim 0, DENIZSET satırı yok (eski aynen) |
| Madde 1 bölümleri × 1 | 10/10 PASS, denetim 0, DENIZSET birebir |

Testler `--max-fps 20`, tam süzgeçle (`~/is/kos.sh`). Çıktılar: `testler/sozlesme_ve_zfight.txt` ve yukarıdakiler.

## Kareler (`kare/17o/`; 1280×720, jpg 85, tam boy, gece, aynı kamera)

Araç: `tests/_ist/tur15_kare.tscn -- bolum=17o shots=…` (tasima12_kare'nin üstüne). Bölüm gerçek akışında açılır, 6 sn
sonra ağaç **dondurulur** (çizim sürer) — yoksa NPC'ler ve akış ilkel sayısını ±%40 oynatıyordu. Göz: oyuncunun gerçek
konumları (açılış `GUN+(1.6,−2.6)`, top başı `GUN+(0,−2.3)`, kova yığını, kıyının iki ucu, vadinin yamacı — yer ışınla),
göz yüksekliği 1,65. FOV 72 (oyuncu), dar 25–30, inceleme ("dürbün") 6–12. `once/` taban, `sonra/` bu dal.

| SONRA karesi | Tek cümle |
|---|---|
| 01_baslangic_karsi_kiyi | Uzak fonda sur şeridi tek kalem; ölçekte fark küçük, kutu kalmadı. |
| 02_top_basi_karsi_kiyi_sol | Sol uçta da yeni kalem; ÖNCE'deki açık gri kutu bantları yok. |
| 03_kova_zinciri_karsi_kiyi_sag | Kadırgaların ardında sur ufku tek kalem; kutu yok. |
| 04_kiyi_sag_ucu_burun | Soldaki Galata surları kutu değil mazgallı taş; burun yönü tek kalem. |
| 05_kiyi_sol_ucu_blakherna | Kuzeye uzanan sur tek kalem; 700 m ötesi gece koyu siluet (aşağıda "hâlâ kötü"). |
| 06_baslangic_galata | Galata burçları ve surları kutu değil; çadırların ardında az görünür. |
| 07_dar_aci_karsi_kiyi | Orta kesim tabanda da yeniydi: değişmedi (aynı ressam), suya oturuyor. |
| 08_dar_aci_kule_dibi | Kule dipleri kıyıya oturuyor, havada değil; dişler gökte seçiliyor. |
| 09_dar_eugenius | Eugenius tarafı zincir gemilerinin ardında; görünen kısımda kutu yok. |
| 10_dar_kuzey_ucu | ÖNCE'de uzak kesim açık gri kutuydu; SONRA mazgallı ama çok koyu — siluet seçiliyor, yüzey okunmuyor. |
| 11_dar_galata_suru | Galata suru yamaçta basamaklı, mazgallı, burçlu; dibi toprağa oturuyor, havada değil. |
| 12_dar_burun | Burun ve Eugenius yönü tek kalem; gemiler büyük kısmını kapatıyor. |
| 13_yamactan_karsi_kiyi | Yamaçtan karşı kıyı tek kalem; NPC'ler kadrajı dolduruyor (kare zayıf). |
| 14_yamactan_galata_suru | **Kötü kare**: yer ışını yamacın içine baktırıyor, sur görünmüyor (ölçüm için tutuldu). |
| 15_yakin_eugenius | Kuleler ve dişler mazgallı taş; ÖNCE'nin düz kutu kuleleri ve kutu dişleri yok. |
| 16_yakin_karsi_sur_kuzey | **En açık kare**: ÖNCE'de yeni→eski dikişi (sağda düz açık gri kutular, kırmızı şerit) vardı; SONRA tek kalem. |
| 17_yakin_karsi_sur_guney | Kırmızı şeritli kutu sur → kuleli, mazgallı, taş taş ton farklı sur; dip yamaca oturuyor. |
| 18_yakin_galata_suru | Galata'nın düz kutu suru ve tarak dişleri → basamaklı taş sur; basamak tepelerinde yol taşı yüzü görünüyor. |
| 19_yakin_karsi_sur_orta | Tabanda da yeni olan kesim: değişmedi, suya oturuyor (karşılaştırma için). |
| 20_dar_blakherna_kara_suru_ucu | ≈1200 m: Haliç'in ucu koyu siluet; Blakherna kabuğu ve kara surunun Haliç ucu seçilmiyor → dokunulmadı. |

Eski kip (`kare/17o/eski_kip_once|eski_kip_sonra`, genel `--eskisur`): taban ve dal aynı. Çizim/ilkel 07, 15, 17, 18'de
birebir; piksel farkı (>24 gri düzey) %0,008–%0,15 (su dalgası), 01'de %1,8 (önplandaki NPC). DENIZSET satırı iki tarafta
da yok. **Araç notu**: kare araçları bölümü `current_scene` atanmadan kurduğu için `--eskisur=17o` bölüm adını eşlemiyor
(HornWorld sahneyi `tur15_kare` görür); kare aracında genel `--eskisur` kullanıldı. Oyunda ve otomatik testte
`--eskisur=17o` doğru çalışıyor (eski koşuda DENIZSET satırı yok). Aynı durum tasima10/12 kare araçlarında da var.

Sahibine: `kare/sahip_1_karsi_sur_tek_kalem.jpg` (16), `sahip_2_karsi_sur_guney_kuleler.jpg` (17),
`sahip_3_galata_suru_basamakli.jpg` (18) — ÖNCE'leri `kare/17o/once/` aynı adla.

## Bütçe (kural 4; `testler/butce_s3.md`, tur s3, sırayla ve tek süreçle; donuk akış; 10 karenin ortalaması)

Geometri (belirlenimli): **ilkel toplam −%0,8, çizim −%1,1**; tek tek ilkel en çok **+%3,8** (18, Galata suru yakın;
tek ağ 6616 üçgen), çizim en çok +%1,7 (13, yamaç; NPC'li kare); Galata karelerinde çizim −%14…−%22 (yüzlerce kutu →
tek ağ).

| kare | ms Ö | ms S | çizim Ö | çizim S | ilkel Ö | ilkel S | Δ ilkel |
|---|---:|---:|---:|---:|---:|---:|---:|
| 01 başlangıç | 1030 | 1044 | 2983 | 2962 | 4 289 574 | 4 250 403 | −0,9% |
| 02 top başı | 1666 | 1759 | 5869 | 5852 | 8 155 011 | 8 130 172 | −0,3% |
| 03 kova | 466 | 511 | 717 | 717 | 1 161 329 | 1 152 691 | −0,7% |
| 04 sağ uç | 439 | 474 | 596 | 570 | 969 146 | 958 900 | −1,1% |
| 05 sol uç | 1634 | 1689 | 5494 | 5480 | 7 722 815 | 7 711 924 | −0,1% |
| 06 Galata | 449 | 489 | 1305 | 1232 | 1 054 056 | 1 048 336 | −0,5% |
| 07 dar | 457 | 535 | 407 | 405 | 931 018 | 911 372 | −2,1% |
| 08 dar kule | 461 | 516 | 354 | 353 | 837 314 | 817 050 | −2,4% |
| 11 Galata suru | 388 | 439 | 246 | 209 | 526 374 | 542 541 | +3,1% |
| 13 yamaç | 904 | 928 | 1875 | 1907 | 2 968 354 | 3 028 943 | +2,0% |
| 18 Galata yakın | 347 | 353 | 88 | 69 | 426 828 | 442 956 | +3,8% |
| **toplam (19 kare)** | 14 061 | 14 565 | 29 330 | 29 012 | 46 974 079 | 46 606 471 | **−0,8%** |

Kare süresi: yazılım GL (llvmpipe, xvfb) ölçümü turdan tura **±%15** oynuyor — aynı taraf kendi içinde de (07 ÖNCE: s2
520 ms, s3 457 ms). İki tur: s2 toplam ÖNCE 15 307 → SONRA 14 720 (**−3,8%**), s3 14 061 → 14 565 (**+3,6%**); ortalama
29 368 → 29 285 (**−0,3%**). Gerçek GPU'da ölçülmedi. Geometri işi azaldığı için +%5 aşımı beklenmiyor.
Not: 09'da tek kare ilkel sayısı aynı tarafta turdan tura 0,83 M ↔ 1,34 M oynadı (görüntü birebir; gölge atlası
güncellemesi olası) — bu yüzden son turda 10 karenin ortalaması kullanıldı.

## Kesme 4 — neden yapılmadı

`chapter17o.gd:18 var in_world := true` hiçbir yerde `false` yapılmıyor (grep: yalnız 19/17'nin `walls.in_world = true`
satırları ve HornWorld'ün Blachernae örneği var): `_far_galata` ölü yol. Yeni kalemle kurmak için `Scenery.city_walls`
çağrısını kaldırmak gerekir, ama o işlev surların ardındaki şehri de (evler, kiliseler, Ayasofya, serviler) aynı çağrıda
kurar ve görev "17o'da çağırma / değiştirme" diyor: şehri 17o içinde yeniden kurmak + bu yolu sınamak için bölümü
`in_world = false` ile açan ayrı bir koşum gerekirdi. Süre içinde varsayılan (oynanan) yolu sağlamlaştırmayı öne aldım.
Sonraki taşıyana: `_far_galata` içinde `deniz_set.uzak_parca/uzak_kule` ile z = 180 boyunca sur + `Scenery.house_mesh`,
`cypress_mesh`, `hagia_sophia` ile şehir; `GalataView.build(..., yeni_sur = true)` (yerel hf ile çalışır).

## Hâlâ kötü olanlar (dürüst)

1. **Uzak sur gece çok koyu**: yeni kalem 700 m ötesinde neredeyse siyah siluet (kare 05, 10). Eski açık gri kutular
   daha "okunur"du (yanlış nedenle: ışığa tepkisiz düz renk). Kalem öteki deniz bölümlerindeki uzak katmanla aynı; tonu
   yalnız 17o'da açmak "tek görsel dil"i bozardı — sahibin kararı.
2. **Galata basamakları**: basamak tepelerinde yol taşı (yatay yüz) koyu kırmızımsı görünüyor (kare 18); yakından
   bakılırsa basamaklar kademeli kutu gibi okunabilir. Basamak 8 m; daha kısa basamak üçgen artırır.
3. Kare 14 kötü (yamacın içine bakıyor), kare 13 NPC'lerle dolu; oyuncunun gördüğünü temsil ediyor ama değerlendirme
   için 16–18 daha iyi.
4. Kadırgalar ve zincir gemileri Eugenius ile burun yönünü büyük ölçüde kapatıyor; Eugenius'un yeni yuvarlak kulesi
   karelerde ancak siluet olarak seçiliyor.
5. Blakherna kabuğu (`horn_world.gd` `_blachernae`) ve Blakherna surunun Haliç'e inen `Props.box` parçası ile
   `SiegeField._wall_extension` springs'te de eski hâliyle kuruluyor; 17o'dan ≈1200 m, gece görünmüyor (kare 20).
6. `in_world = false` yolu eski kutularla (kesme 4).
7. Kare süresi yalnız yazılım GL'de ölçüldü (gürültülü).
