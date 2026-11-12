# İstanbul v2 — ÇEVRE-4 raporu (dördüncü tur; dal `wip/ist2-cevre4`)

Tarih: 12 Kasım. Görev: `docs/_ajan/gorev/ist2_tur4.md` "ÇEVRE-4". Taban `wip/ist2-taban4`; birleştirilen dallar:
`wip/ist2-ordugah4` (iki kez), `wip/ist2-sur4`, `wip/ist2-doku4`, `wip/ist2-baglama4` (çakışmasız; son birleştirme
saatleri git kaydında). Kareler yazılımla çizim (xvfb, llvmpipe), 1280×720, sonda `tests/_ist/sehir2_kare.tscn`.
Hüküm etiketleri: TAMAM (kare adıyla) / KISMEN / YAPILMADI / KANITSIZ / BAKILMADI.

**ÖNCE kareleri:** üçüncü turun aynı sondayla, aynı kamera kuralıyla alınmış eser kareleri
(`docs/_kanit_ist2_sehir3/son/`, orada yoksa `ilk/`). Taban dalın kendisinden ayrı ÖNCE koşusu ALINMADI (bu turun ilk
koşusu palet değişikliğinden sonraydı); Ayasofya çevresinin ÖNCE'si ayrıca `ara/aya0_*` (yalnız palet, çevre yapıları
yok). Yer karelerinde kamera kuralı bu turda düzeltildi (kule dibine yapışma, sütun içi, ağaç tacı içi): o karelerde
kamera AYNI DEĞİL, raporda ayrıca yazıldı.

## ÖNCE | SONRA paftaları

| Pafta | İçerik |
|---|---|
| `pafta_aya_cevre.jpg` | Ayasofya'nın dört yanı: ÖNCE (3. tur 15 m, tepe, yer) | SONRA (dört yandan 15 m, dört yandan yer, tepe) |
| `pafta_kotu_uc.jpg` | Sahibinin işaret ettiği üç kötü: Aya İrini, Büyük Saray harabesi, Hipodrom (15 m) ÖNCE | SONRA |
| `pafta_palet.jpg` | Palet: Galata Kulesi, Studios, Konstantin, Tauri, San Domenico, Havariyun ÖNCE | SONRA |
| `pafta_kirik.jpg` | Kırık kareler: `eser_hipodrom_yer`, `eser_halic_eugenios_yer`, Galata Kulesi yer ÖNCE | SONRA |
| `pafta_eser_1.jpg` … `pafta_eser_4.jpg` | 28 eserin 15 m kareleri, yedişer çift |
| `pafta_sahip.jpg` | 14 sahip karesinden 8'i (ÖNCE: `docs/_kanit_ist2_sehir3/sahip_*`) | SONRA; 14'ünün hepsi `sahip_*.jpg` |

## Kendi karelerime bakınca hâlâ kötü olanlar

Sahibinin gözüyle, dürüst:
- **Khora ve Pammakaristos kubbeleri hâlâ koyu lacivert-siyah** (`son/eser_khora_15m.jpg`, `eser_pammakaristos_15m.jpg`).
  Kaynağı kubbenin desen dokusu (parçanın kendi pişirmesi); son koşudaki doku düzeltmesi tutmadı. KÖTÜYE YAKIN, KISMEN.
- Ayasofya'nın batısındaki çimen yaması döşemenin üstü 0,17 m'ye kaldırılınca gitti (`son/aya_bati_15m.jpg`); kaynağı
  DOKU-4'ün yeni zemin katmanıydı (ince döşemelerin üstüne çıkıyor: Konstantin forumunu da yeşile boğmuştu).
- **Blakherna Sarayı** hâlâ tuzlu-pembe bir "tekfur" dokusu ile parlak duruyor; çevresi (sur ile saray arası) yeşil
  (`son/eser_blakherna_15m.jpg`). Orta.
- **Beyaz ve pembe yuvarlak ağaçlar, beyaz uzun koniler ve açık yeşil dikdörtgen yamalar** birçok eser karesinde göze
  batıyor (Hipodrom, Anemodoulion, Milion, Augustaion, Studios yer karesi): bunlar benim dosyalarımdan değil (DOKU-4'ün
  bitki/yama katmanı); ORTAK BİLGİ'de yazdım. Kare yine de bu yüzden "oyuncak" okunuyor.
- **Mokios** (açık sarnıç bostanı) ve **Aetios** yer kareleri sarnıç duvarına bakıyor; içi tepeden okunuyor ama yerden
  "duvar + çimen" (orta).
- **Studios** yerden bakınca eğimli boş toprak yamaç üstünde; manastır avlusu yok (Khora/Pammakaristos'taki avlu
  Studios'a uygulanmadı). Orta.
- **Sur dışı sahip kareleri (03, 04)** hâlâ boş yeşil ve sur kesik görünüyor (SUR-4/ORDUGÂH-4'ün konusu; benim
  dosyalarım değil).
- **Uzak/tepe bakışta düz kurşun çatılar** (Aya İrini yan nef çatıları, Ayasofya çatıları) hâlâ açık gök mavisine
  çalıyor (`son/eser_aya_irini_tepe.jpg`); yandan doğru (mavi-gri). Orta.
- Bütçe: Ayasofya çevresinde üçgen +%5–11 arttı (aşağıda); bazı yer karelerinde 2,5 M üçgen sınırı aşılıyor (önceden de).

## Madde madde hüküm

### 1. Ayasofya'nın dört yanı (kalite notu 13, 20) — TAMAM (`son/aya_*`, `pafta_aya_cevre.jpg`)

Yeni öğe `meydan_aya_cevre` (`sehir.gd` `_place_v2` sonunda; kurucusu `sehir_eser.gd` `aya_cevre()`), Ayasofya'nın
kendi yerel çerçevesinde (+z batı/narteks, +x güney, −x kuzey, −z doğu/apsis):
- **Döşeme:** 66 m yarıçapta her yanda sıcak gri-krem (`P_DOSEME`) taş döşeme; gövdenin dibine kadar (önceden gövde ile
  meydan arasında çimen halkası vardı). Komşu eserlerin çekirdeği ve oyun meydanının çekirdeği döşenmez. Levhalar eğimde
  araziye gömülmesin diye dört köşenin en yükseğine oturur; orta/uzak katmanda düz renk dokunun ortalaması kadar koyu
  (düz yatay yüz toon ışıkta bembeyaz görünüyordu: `ara/eser_ayasofya_tepe.jpg`).
- **Atrium (batı avlusu):** üç yanı revaklı (mermer sütun, arşitrav, kiremit sundurma, taş arka duvar), batıda kemerli
  propylon, ortada phiale (sekizgen havuz + dört sütunlu kurşun kubbeli baldaken), dört servi.
- **Vaftizhane** (güneybatı köşesi; sekizgen, kasnaklı kurşun kubbe), **skeuophylakion** (kuzeydoğu; yuvarlak tuğla
  gövde, pencereler, konik kurşun çatı), **patrikhane** (güney yanı; iki katlı, zemin katı kemerli revak, kiremit çatı),
  **Khalke'ye uzanan revak** (güneydoğu), **kuzey avlu duvarı** (kapılı, kiremit başlıklı; Aya İrini yönüne), çınarlar
  ve serviler, mumcu/ikona tezgâhları, taş sekiler, sura taşınacak taş yığınları ve fıçılar (kuşatma).
- Milion ve Augustaion (Iustinianus Sütunu) yerinde (parça kayıtları); Zeuksippos güneyde (yıkık duvar kurucusu
  yenilendi, madde 3).
- Ayasofya'nın kendisi: payandalar ve kubbe kütlesi modelde vardı; 1453 için sıvasız tuğla + kurşun, MİNARESİZ (palet).

Kareler (sonda `--set=aya`, dört yandan 15 m ve yerden + tepe): `son/aya_bati_15m`, `aya_guney_15m`, `aya_dogu_15m`,
`aya_kuzey_15m`, `aya_bati_yer`, `aya_guney_yer`, `aya_dogu_yer`, `aya_kuzey_yer`, `aya_tepe`; eser kareleri
`son/eser_ayasofya_15m`, `_tepe`, `_yer`. ÖNCE: `docs/_kanit_ist2_sehir3/son/eser_ayasofya_*`, `ara/aya0_*`.
Batıdaki çimen yaması son koşuda yok (`son/aya_bati_15m.jpg`).

### 2. Eser paleti (kalite notu 21) — TAMAM (kareler, `pafta_palet.jpg`) / KISMEN (Khora ve Pammakaristos kubbeleri koyu lacivert kaldı; düz kurşun çatı tepeden açık)

Tablo aşağıda. `IstSehir._build` her eser katmanını pişirmeden önce `ESER.palet()` ile indirir (malzeme, desen dokusu,
köşe renkli ağ). Kareler: `pafta_palet.jpg` (Galata külahı parlak kırmızı → soluk kiremit; Studios turuncu-kırmızı →
mat tuğla; Konstantin macenta → porfir kahve; Tauri nane-beyaz → gri-krem; San Domenico parlak kırmızı çatı → soluk kiremit). Ayasofya: `son/eser_ayasofya_15m` (sıvasız tuğla, mavi-gri
kurşun kubbeler, minare yok).

### 3. Aya İrini, Büyük Saray, Hipodrom (kalite notu 22–23) — TAMAM (Aya İrini, Büyük Saray) / KISMEN (Hipodrom)

- **Aya İrini** (`hipodrom_aug.gd` `build_aya_irini`, yeniden yazıldı): bazilika gövdesi (yüksek orta nef + alçak yan
  nefler, eğik kurşun çatılar, iki sıra pencere), orta nefin üstünde 16 pencereli yüksek KASNAKLI ana kubbe (kaburgalı,
  haçlı), batıda alçak ikinci kubbe, doğuda dışı çokgen apsis + yarım kubbe, yan neflerde tuğla payandalar, narteks ve
  revaklı atrium. Konma noktası (ana kubbe tepesi) ve tırmanma (sandık → payanda) yeni ölçülere göre. Kare:
  `son/eser_aya_irini_15m.jpg` (ÖNCE: düz kırmızı çatılı kutu + iki kubbe).
- **Büyük Saray harabesi** (`hipodrom_saray.gd`, `hipodrom_kit.gd`): `ruin_wall` artık "basamak bloğu" değil: sürekli
  alt gövde + komşusuna yumuşak geçen kırık (sivri/eğik) tepeler, gedikler, yüksek duvarda kör kemerler (tuğla kemer
  kaşı + koyu boşluk), seyrek yosun, sarmaşık lekeleri, dipte moloz. Yeni `kemer_dizisi`: ayaklar + yedi parçalı yarım
  daire kemerler, yıkık açıklıklar (üç dizi). Devrik sütunlar (mermer/porfir) ve başlık parçaları; zemin ot bürümüş
  yamalı toprak; mozaik renkleri aşınmış, yarısı toprak altında; bostan "yeşil topları" toprak sıralarına. Aynı
  `ruin_wall` Zeuksippos, Augustaion, Milion ve Aya İrini çevresinde de kullanılıyor. Kare:
  `son/eser_buyuk_saray_15m.jpg`, `_yer.jpg` (yarım kemer okunuyor).
- **Hipodrom** (`hipodrom.gd`): pist kum değil ot basmış çiğnenmiş toprak + toprak/taş yamaları; oturma sıralarının
  çoğu sökük (sağlam oranı 0,15–0,7, gedik olasılığı 0,45; orta kesim tırmanma yolu için sağlam); otlayan hayvan 9 → 18.
  Sphendone ve spina (Dikilitaş, Yılanlı Sütun, Örme Sütun) parçanın kendisinde vardı. Kare:
  `son/eser_hipodrom_15m.jpg`, `eser_hipodrom_tepe.jpg`, `sahip_08_hipodrom.jpg` (pist önce açık limon yeşili düz şeritti:
  toprak-zeytin tonuna indi). KISMEN: çevresindeki beyaz/pembe ağaçlar DOKU'nun.

### 4. Kırık kareler, döşeme tonu, yeşil küreler (kalite notu 26, 28, 29) — TAMAM (kareler) / KISMEN

- `eser_hipodrom_yer` (kamera sütunun içindeydi): sonda artık katı içinde mi diye nokta sorgusu ve yukarıdan aşağı ışınla
  sınar; yedek yön ancak denetimlerden geçerse seçilir; Hipodrom için yanlardan 75 m. Kare `son/eser_hipodrom_yer.jpg`
  (gündüz, göz hizası; önünde DOKU'nun beyaz ağacı var: orta).
- `eser_halic_eugenios_yer` (5 KB boş): `son/eser_halic_eugenios_yer.jpg` (Haliç suru ve Eugenios kulesi görünür).
- Hub yer karesi: BAKILMADI (hub BAĞLAMA'nın bölüm alanı; sahip karesi 05 bu bakışın en yakını).
- Yer karesinin tekdüze çıkması (ağaç tacı içi, `eser_arkadius_yer`) artık sonraki yöne geçer; hiçbir yön uymazsa
  geriden ve 6 m'den yedek kare.
- **Döşeme tonu:** bütün eserlerde döşeme dokusu (`flagstone`, `cobble`) `P_DOSEME`; desen dokusunun nötr pikselleri
  sıcak (nane-beyaz/camgöbeği gider). Kare: `son/eser_tauri_yer.jpg`, `eser_konstantin_yer.jpg`.
- **Yeşil küreler:** `forumlar_yapi.ot()` artık yassı, uzunca, koyu ot şeridi (yerden ≤ 0,2 m), sayı yarıya, kenara
  yakın. Kare `son/eser_tauri_15m.jpg`.

### 5. 28 eserin üç karesi + forum ovalleri — TAMAM (kareler) / KISMEN (hükümler aşağıda)

`son/eser_<id>_15m.jpg`, `_tepe.jpg`, `_yer.jpg` (28 eser, tablo aşağıda). Forum ovalleri (Konstantin, Tauri): yeni
`forumlar.gd` `_forum_dolgu` (çeşme: sekizgen havuz + su taşı; dört heykel kaidesi, üçünde bronz figür; taş sekiler;
kuyu bileziği; devşirme sütun tamburları). Tezgâh ve kişi DOKU-4'ün katmanından.

### 6. Blakherna'daki kapalı cep, Galata — KISMEN

- Cep (`--set=oyun` örneği (−1040, −1192)): kareler `son/blakherna_cep_tepe.jpg`, `_30m.jpg`. Cep, Blakherna'nın
  Haliç yanında **deniz surunun dış yüzü ile su arasındaki kıyı şeridi** (sur dışı). Oyuncu oraya ancak surdan atlayarak
  düşer; şerit iskeleye bitişik ama iskeleden sur içine dönüş yok. Sur SUR-4'ün dosyası: ORTAK İSTEK (aşağıda). Yer
  karesi (`blakherna_cep_yer`) suyun içine düştü (kıyı çizgisi): BAKILMADI sayılır.
- Galata: kule (soluk kiremit külah, Ceneviz kesme taş), San Domenico, Palazzo del Comune (Ceneviz bayrağı), dar sokaklar
  ve iskeleler parçanın kendisinde; bu turda yalnız palet (`son/eser_galata_kulesi_*`, `eser_san_domenico_*`,
  `eser_palazzo_comune_*`). Dönem kuralı: hilal/minare yok (bu dosyalarda arandı: yok). KISMEN: Galata'nın "loca"sı ve
  ikinci kilisesi karelerde seçilmiyor (BAKILMADI).

### 7. Kanıt — TAMAM

28 eser × 3 kare (`son/eser_*`), Ayasofya çevresi 8 + 1 kare (`son/aya_*`), ÖNCE | SONRA paftaları, 14 sahip karesi
(`sahip_<n>_<ad>.jpg`).

## 28 eser (yan görev) — hüküm

ÖNCE: `docs/_kanit_ist2_sehir3/son|ilk/eser_<id>_*`; SONRA: `son/eser_<id>_*`.

| # | Eser | Hüküm | Neden |
|---|---|---|---|
| 1 | Ayasofya | iyi | dört yanı döşeli ve dolu (atrium, vaftizhane, skeuophylakion, patrikhane, revak); mat tuğla + kurşun; batıda küçük çimen yaması |
| 2 | Aya İrini | iyi | bazilika + kasnaklı kubbe + apsis + atrium; tepeden kurşun açık |
| 3 | Augustaion + Iustinianus Sütunu | orta | döşeli, sütun ve yıkık duvar okunur; yanında açık yeşil DOKU yaması |
| 4 | Milion | orta | dört ayaklı kalıntı okunur; küçük, çevresindeki yapılar baskın |
| 5 | Hipodrom | orta | sphendone + spina + sökük sıralar + hayvanlar, pist toprak; çevresi beyaz/pembe ağaçlı (DOKU) |
| 6 | Büyük Saray harabesi | iyi | yıkık kemer dizileri, kör kemerli yarım duvarlar, devrik sütunlar, ot bürümüş zemin |
| 7 | Zeuksippos | orta | yıkık duvar + kemer okunur; yuvarlak salon tuzlu-pembe |
| 8 | Sergios-Bakkhos (Küçük Ayasofya) | iyi | sekizgen gövde, kurşun kubbe, mat tuğla |
| 9 | Nea | iyi | beş kubbeli kilise, mat tuğla, kurşun |
| 10 | Konstantin Forumu + Sütunu | iyi | porfir sütun (macenta değil), sıcak döşeme, oval içi çeşme/heykel kaidesi |
| 11 | Tauri Forumu + Theodosius Sütunu | iyi | döşeme sıcak gri-krem, yeşil küre yok, oval içi dolgu |
| 12 | Arkadius Sütunu | orta | sütun ve kaide okunur; mermer beyazı parlak |
| 13 | Markianos Sütunu | orta | sütun okunur; çevrede DOKU'nun beyaz koni/ağaçları |
| 14 | Anemodoulion | orta | piramit gövde okunur; önünde beyaz koni ve ağaç öbekleri (DOKU) |
| 15 | Havariyun | iyi | beş kubbeli haç plan, mat tuğla, kurşun |
| 16 | Pantokrator | iyi | üç kilise yan yana, kubbeler mavi-gri |
| 17 | Khora | orta | manastır avlusu döşeli ve dolu; kubbeler HÂLÂ koyu lacivert-siyah |
| 18 | Pammakaristos | orta | Khora gibi |
| 19 | Studios | orta | mat tuğla bazilika; avlu ve çevresi boş toprak yamaç |
| 20 | Tekfur Sarayı | orta | saray okunur ama 15 m karesi sur kuleleri arasından; yer karesi sur duvarı + sancak + kuyu |
| 21 | Blakherna Sarayı | orta | saray + avlu okunur; cephe pembe, çevresi yeşil |
| 22 | Bozdoğan Kemeri | orta | 15 m'den iki katlı kemer dizisi şehrin üstünde iyi; yer karesi bir ayağın dibinde (kamera kuralı, düzeltilmedi) |
| 23 | Galata Kulesi | iyi | külah soluk kiremit, Ceneviz taşı, sur yanında |
| 24 | San Domenico | iyi | gotik kilise + çan kulesi, soluk kiremit çatı |
| 25 | Palazzo del Comune | orta | mazgallı saray okunur; yer karesi eğik rampadan |
| 26 | Eugenios Kulesi ve Zincir | orta | kule + Haliç suru; yer karesi artık dolu (önce boş) |
| 27 | Aetios sarnıcı (bostan) | orta | 15 m'den bostan tarhları, ağaçlar, kuyu iyi; yerden yalnız sarnıç duvarı |
| 28 | Mokios sarnıcı (bostan) | orta | tepeden bostan sıraları iyi; yerden duvar |

"Kötü" kalan yok (kendi bakışım); "orta"ların çoğunda kalan kusur başka katmandan (DOKU'nun bitki/yaması, SUR'un
surları) ya da yer kamerasından.

## Palet tablosu (`scripts/world/ist/sehir_eser.gd` başı; bütün eserler)

Eser kurucularının renkleri kurulumdan sonra `ESER.palet()` ile tek palete indirilir (`IstSehir._build` içinde, pişirmeden
önce; köşe renkli ağların köşe renkleri ve desen dokuları da). Kapsam dışı: surlar ve sur kapıları (SUR-4), ordugâh,
gemiler, yaşam, hub (`IstSehir.PALETSIZ`).

| Sabit | Renk | HSV doygunluk / parlaklık | Kullanım |
|---|---|---|---|
| `P_TUGLA` | `#8e5646` | 0,51 / 0,56 | Bizans tuğlası (mat kiremit-kızıl) |
| `P_TUGLA_K` | `#74483b` | 0,49 / 0,45 | koyu tuğla (payanda, kemer kaşı) |
| `P_KIREMIT` | `#94594a` | 0,50 / 0,58 | çatı kiremidi (soluk) |
| `P_KURSUN` | `#7a838b` | 0,12 / 0,55 | kurşun kubbe/çatı (mavi-gri, mat: parlaklık yok) |
| `P_MERMER` | `#ddd4c2` | 0,12 / 0,87 | Prokonnesos mermeri (sıcak kırık beyaz) |
| `P_TAS` / `P_TAS_K` | `#c2b59a` / `#a3977f` | 0,21 / 0,76 – 0,64 | kireçtaşı gri-krem |
| `P_DOSEME` | `#c3b8a0` | 0,18 / 0,76 | meydan/avlu döşemesi (her meydanda aynı) |
| `P_PORFIR` | `#5c3836` | 0,41 / 0,36 | porfir: koyu erguvan-kahve |
| `P_AHSAP` / `P_ALTIN` / `P_YESIL` | `#6a4a30` / `#b49650` / `#5d7046` | ≤ 0,56 | ahşap, yaldız, ot/yosun |
| `DOYGUNLUK_EN` | — | 0,55 | hiçbir eser rengi bunu aşmaz |

`ton()` kuralları: kızıl-turuncu aile → ton 0,035'e çekilir, doygunluk ≤ 0,53, parlak olanlar ≤ 0,62 parlaklık (parlak
turuncu tuğla, düz kırmızı çatı → mat); krem/sarı → doygunluk ≤ 0,24 (açıklarda), parlaklık ≤ 0,84; yeşil ≤ 0,42/0,60; mavi
(kurşun) → ton 0,58, doygunluk ≤ 0,08, parlaklık 0,38–0,48 ve malzeme mat (metal/parlaklık/kenar ışığı kapalı: toon yansıması
kubbeyi gök mavisine çeviriyordu); mor-macenta → porfir; nötr açıklar → sıcak kırık beyaz (nane-beyaz gider). Desen
dokuları (tuğla, kiremit, tekfur, döşeme) bir kez kopyalanıp indirilir (doygunluk ≤ 0,42, kızıl pikseller %16 koyu, nötr
pikseller sıcak); dokulu malzemede renk nötrleştirilir (kızıl renk × kızıl doku çarpımı doygunluğu yeniden artırıyordu:
Galata külahı ve Studios çatısı ilk denemede koyu kırmızı kaldı, `k4/` → `k5/`). Döşeme dokusu (`flagstone`, `cobble`) her
yerde `P_DOSEME`.

### Eserlerin tonları

| Eser | Tuğla | Çatı / kubbe | Taş / mermer | Not |
|---|---|---|---|---|
| Ayasofya | P_TUGLA (doku) + taş şerit | P_KURSUN (kubbe, yarım kubbeler, çatılar) | P_MERMER (silmeler) | sıvasız tuğla, minaresiz |
| Ayasofya çevresi | P_TUGLA (vaftizhane, skeuophylakion, şerit) | P_KIREMIT (revak, patrikhane, propylon), P_KURSUN (phiale, vaftizhane, skeuophylakion) | P_MERMER sütun, P_TAS duvar, P_DOSEME döşeme | |
| Aya İrini | P_TUGLA | P_KURSUN (iki kubbe, apsis, yan nef çatıları) | P_MERMER (atrium sütunları) | önce düz KIRMIZI çatı levhası |
| Büyük Saray, Zeuksippos, Augustaion, Milion | P_TUGLA_K (yıkık duvar, kemer) | — | P_MERMER/P_PORFIR devrik sütun | |
| Hipodrom | P_TUGLA_K (dış duvar) | — | P_TAS (sıralar), P_MERMER/P_PORFIR (spina) | |
| Konstantin, Arkadius, Markianos | — | — | P_PORFIR (Konstantin gövdesi), P_MERMER | önce macenta/pembe |
| Khora, Pammakaristos, Studios, Pantokrator, Havariyun, Sergios, Nea | P_TUGLA | P_KURSUN kubbe, P_KIREMIT çatı | P_TAS | |
| Galata Kulesi, San Domenico, Palazzo Comune | P_TAS (Ceneviz kesme taş) | P_KIREMIT (külah, çatılar) | — | önce parlak kırmızı külah |
| Tekfur, Blakherna Sarayı | P_TUGLA + P_TAS (tekfur dokusu) | P_KIREMIT | P_MERMER | |
| Bozdoğan, Aetios, Mokios, Eugenios | P_TUGLA/P_TAS | — | P_TAS | |

## Bütçe (RenderingServer toplamı; oyunun kendi sayımı)

| Kare | çizim | üçgen | sınır | ÖNCE (yalnız palet, `ara/aya0`) |
|---|---|---|---|---|
| aya_bati_15m | 675 | 1,22 M | uçuş ✔ | 617 / 1,07 M |
| aya_guney_15m | 881 | 1,88 M | uçuş ✔ | 849 / 1,69 M (+%11 üçgen) |
| aya_dogu_15m | 1 005 | 3,04 M | uçuş ✔ | 971 / 2,91 M (+%4) |
| aya_kuzey_15m | 699 | 1,20 M | uçuş ✔ | 655 / 1,00 M (+%20; düşük taban) |
| aya_dogu_yer | 1 073 | 3,17 M | yer ✘ üçgen | 1 018 / 3,03 M (önceden de ✘) |
| aya_guney_yer | 830 | 1,69 M | yer ✔ | 768 / 1,49 M |
| aya_tepe | 408 | 0,74 M | ✔ | 390 / 0,66 M |
| eser_khora_yer | 1 271 | 2,32 M | yer ✘ çizim | — |
| eser_markianos_yer | 1 099 | 3,59 M | yer ✘ üçgen | — |

Ayasofya çevresi öğesi açılışta ön-pişirilir (`_on_pisir` listesi): akışta yakın katman bağlanır, kurulmaz.
`ISTONPISIR` 9 657 ms → 7 900 ms (iki koşu arasında öbür dalların birleşmesi de var: karşılaştırılamaz). "Üçgen her
evrede en çok +%8" kuralı Ayasofya'nın güney ve kuzey 15 m bakışında aşılıyor (+%11, +%20: atrium sütunları ve revak);
KISMEN. Tek iş ≤ 6 ms: palet geçişi malzeme/doku/ağ önbellekli; ilk desen dokusu kopyası (256² piksel) bir kez ~10–30 ms
(ölçülmedi: KANITSIZ).

## Sınamalar (başsız, yasak satır yok)

`parse_check` PASS (335 betik), `world_check` PASS, `flight_check` PASS, `city_check` PASS, Bölüm 7 PASS, Bölüm 7
`=byz` PASS, Bölüm 11 PASS, Bölüm 12b PASS (ordugâh birleşmesinden sonra; sur/doku/bağlama birleşmesinden sonra
yeniden: aşağıdaki son satırlar).

Son birleşik hâlde (dört dal birleştikten sonra, 17:00–17:40 UTC) yeniden: `parse_check` PASS (335), `world_check` PASS
(regions=13 landmarks=35), `flight_check` PASS, `city_check` PASS, Bölüm 7 PASS (7a, 7.1), Bölüm 7 `=byz` PASS (7b,
7.1 + 7.3), Bölüm 11 PASS (11.2), Bölüm 12b PASS (12B.1), Bölüm 6 PASS (6a.1). Yasak satırların hiçbiri yok. Bu
koşulardan sonraki son değişiklikler yalnız renk/doku (palet: mavi doku pikselleri), forum ve Hipodrom zemin rengi/kalınlığı:
ayrıştırma PASS; bölüm sınamaları yeniden koşulmadı (BAKILMADI).

## ORTAK İSTEK / BİLGİ

- **SUR-4 (Blakherna cebi):** Blakherna'nın Haliç yanında deniz surunun dışındaki kıyı şeridi (örnek (−1040, −1192))
  kapalı cep: şeride düşen oyuncu çıkamaz. Öneri: şeritten surun yürüme yoluna ya da iskeleden bir kapıya basamak/rampa
  (`IstMarmaraSur.rampa` gibi), ya da şeridin suya inen ucu.
- **SUR-4 / Haliç:** Blakherna kıyısında suyun üstünde açık camgöbeği düz dikdörtgen (önizleme suyu?) görünüyor
  (`son/blakherna_cep_tepe.jpg`). Kaynak aranmadı (KANITSIZ).
- **DOKU-4 (bitki ve yamalar):** eser karelerinde bembeyaz ve pembe yuvarlak ağaç tepeleri, beyaz uzun koniler (servi?),
  açık yeşil (lime) düz dikdörtgen yamalar eserlerin yanında "oyuncak" okunuyor (`son/eser_hipodrom_15m`,
  `eser_anemodoulion_yer`, `eser_augustaion_15m`, `eser_milion_15m`). Öneri: çiçekli ağaçlarda doygunluk ≤ 0,45, beyaz
  yerine soluk pembe-krem, koni servi koyu yeşil; yama renkleri toprak/ot karışımı.
- **DOKU-4 (bilgi):** eser paleti DOKU'nun `meydan_*` ve `doku_*` öğelerine de uygulanır (`IstSehir._paletli`: yalnız
  sur/ordugâh/gemi/yaşam/hub hariç); döşeme dokusu her yerde `P_DOSEME`. İstemiyorsanız `PALETSIZ`'e önek ekleyin.
- **DOKU-4 (bilgi):** Ayasofya'nın 66 m çevresi `meydan_aya_cevre` öğesinin döşemesi; kimliği `meydan_` ile başlar
  (taban damganız onu ev engeli saymaz). Sizin meydan hücreleriniz bunun altında kalır (0,13 m yüksekte).
- **BAĞLAMA-4 (bilgi):** Ayasofya oyun meydanının (`meydan_aya`) zemin levhası kalınlaştı (üstü aynı yükseklikte,
  0,9 m aşağı uzanır); oyun alanı ve dönüşüm değişmedi.

## Değişen dosyalar (yalnız ÇEVRE-4'ünkiler)

`scripts/world/ist/sehir.gd` (palet çağrısı + `_paletli`, `meydan_aya_cevre` öğesi, ön-pişirme listesi; sur işlevlerine
dokunulmadı), `sehir_eser.gd` (palet, `aya_cevre`, revak/sekizgen/avlu duvarı/servi/çınar/tezgâh yardımcıları,
manastır avlusu ve oyun meydanı zemini kalın levha), `hipodrom.gd`, `hipodrom_aug.gd`, `hipodrom_kit.gd`,
`hipodrom_saray.gd`, `forumlar.gd`, `forumlar_yapi.gd`, `tests/_ist/sehir2_kare.gd` (`--set=aya`, `--set=palet`,
yer kamerası denetimleri). Replik/süre/sayaç/kalabalık değişmedi; denetim susturulmadı; kanca yok (`palet` sondası
yalnız test dosyasında).

## SAHİBİNE GÖSTERİLECEK 8 KARE

1. `son/aya_guney_15m.jpg` — Ayasofya güneyden: patrikhane, vaftizhane, döşeli meydan, mat tuğla + kurşun kubbe.
2. `son/aya_bati_15m.jpg` — Ayasofya batıdan: revaklı atrium, phiale, propylon, skeuophylakion, avlu duvarı.
3. `son/aya_tepe.jpg` — tam tepeden: Ayasofya'nın dört yanı döşeli ve dolu (çıplak çayır yok).
4. `son/eser_aya_irini_15m.jpg` — Aya İrini artık bazilika: kasnaklı kubbe, yan nefler, apsis, atrium.
5. `son/eser_buyuk_saray_15m.jpg` — Büyük Saray harabesi: yıkık kemer dizileri, kör kemerli yarım duvarlar, devrik sütunlar.
6. `son/eser_konstantin_15m.jpg` — Konstantin Forumu: porfir sütun, sıcak döşeme, çeşme ve heykel kaideleri.
7. `son/eser_galata_kulesi_15m.jpg` — Galata Kulesi: soluk kiremit külah (parlak kırmızı değil), Ceneviz suru yanında.
8. `pafta_eser_1.jpg` — 28 eserin ilk yedisi ÖNCE | SONRA (palet farkı yan yana).
