# TUR-10 — YAKINDAN sur ("oyuncak gibi") + tur 9 kalanları: rapor

Dal `wip/ist2-tur10`, taban `wip/ist2-taban10` **0ded6ea0**. ÖNCE = aynı taban (`git archive 0ded6ea0`, depo dışı kopya, aynı
içe aktarma önbelleği), aynı makine, aynı kameralar, xvfb + Mesa llvmpipe, 1280×720 jpg 85. Ölçüt bu turda OYUNCU GÖZÜ (0,5–3 m).
Klasörler: `once/`, `sonra/` (c25, c20, c0, yakin, blak), `pafta/` (sol ÖNCE | sağ SONRA, yarım boy), `testler/` (süzülmüş çıktılar).

Kameralar
- Bölüm 25 `--chapter=25 --autotest=kare`: an_01…an_06 (hepsi).
- Bölüm 20 `--chapter=20 --autotest=kare`: an_01…an_12 (sur dibi 2 m: **an_11 okçular**; gedik yanı: an_03, an_04).
- Bölüm 0 `--chapter=0 --autotest=kare`: an_01…an_05 (açılış an_01; gedik an_05).
- YAKIN sahne (yeni) `tests/_ist/tur10_yakin.tscn` (sur_oyun_demo kurulumu; `--gece` = Bölüm 20/25 ışığı `Night.environment`):
  y1 dış sur yolu dişi **0,6 m**, y2 iç sur korkuluğu **1,5 m**, y3 kule kapısı **2 m**, y4 **sur dibinden 2 m**, y5 dış sur yolu
  boyunca, y6 diş sırası üstten 1 m, y8 gedik fıçıları 2 m; her biri gece ve gündüz (gündüz 2 yakın kare isteği: y4, y5/y6).
- Blakherna: `tests/_ist/tur9_kare.tscn` b1–b3 + üç yakın (b1y, b2y, b3y; 6–8 m öne). ÖNCE = tur 9 SONRA kareleri (taban o).

## 1. "Oyuncak gibi surlar" (Bölüm 25 an_01)

### Kök neden (yakından bakınca)
- Mazgal = `surlar.gd _parapet_x` korkuluk kutusu + `sur_kule.gd disler_ag` diş KUTUSU (5 yüz, hepsi aynı; tepe düz levha).
- Taş/tuğla = `sur_doku.gd` gölgelendiricisi (dünya y'sine göre desen). Tuğla sırası ölçüde doğruydu (8,4 cm) ama: doygun kırmızı
  (0,37 0,14 0,085), harç ince (%34) ve açık, tuğlalar birbirinin kopyası (yarım tuğla kaydırma, ton farkı ±%15) → Lego.
  Kireçtaşı yakında TEK TON (blok ton farkı ±%10, derzi 0,42 m'de bir; 0,6 m'lik dişte hiç derz düşmüyordu) → beyaz levha.
- Gece: kireçtaşı albedosu yüksek (0,51), ay ışığı + lila ortam ışığında yakın sur ordugâhtan/gökten parlak; uzak çadırlar sisle
  kararırken yakın sur sissiz kalıyordu.

### Ne yapıldı (ölçü ve çarpışma AYNI; sözleşme üçlüsü aynı)
| dosya | değişiklik |
|---|---|
| `sur_doku.gd` (gölgelendirici) | **Tuğla**: sıra 8,4 cm = ≈4,5 cm tuğla + ≈3,9 cm harç (tuğladan tuğlaya oynar); doygunluk düşük (0,30 0,165 0,115); tuğla tuğla ton (0,7–1,1), %14 koyu fazla pişmiş, %16 sarımsı az pişmiş; sıra kaydırması düzensiz; kenar aşınması ve pürüz (yakında). **Harç**: kirli pembemsi bej-gri (kireç + tuğla tozu), lekeli, yer yer oyulmuş, üst tuğlanın gölgesinde, kumlu dane (yakında). **Kireçtaşı**: bir ton koyu ve gri (0,465 0,445 0,40); blok blok ton iki katı (0,8–1,1, soğuk gri ↔ bal), %7 onarım taşı; derzler ±2 cm dalgalı; kenar bandı blok blok 4–14 cm, pürüzlü, kenara doğru koyu (aşınmış/yuvarlanmış); blokların %40'ında kırık köşe; gözenek, liken, koyu benek; akıntı + ince damar, is, dipte kir ve yosun daha güçlü, yosun yakında lekeli. **Döşeme/tepe taşı**: şaşırtmalı sıra, dalgalı kirli derz, aşınmış kenar, liken; eğik yüz (diş omzu) taş tonunda. **Gece**: `gece` uniformu — sahnenin göğünden okunur (`SurGeceIzle`, 0,25 s; ışığa ve `night.gd`/`look.gd`'ye dokunulmadı), dik yüzde ×0,68 (yatayda daha az). **Döküntü taşı işareti** (köşe alfası 0,5): duvar deseni, dip kararması, gece payı uygulanmaz. Uzak ortalama (hatıl) yeni yakın ortalamaya eşit. |
| `sur_kule.gd disler_ag` | Diş = yontulmuş taş ağı: altıgen plan (sur yolu tarafındaki iki dikey kenar 5–10 cm pahlı), o kenarda omuz (yuvarlanmış tepe kenarı), tepe sur yoluna doğru 3–7 cm eğimli (yandan sırt/beşik çatı okunmaz), en ±%6, boy ±%12, yana yatık, %30'unda bir tepe köşesi 10–28 cm kırık, %9'u yıkık (sırtsız, köşe köşe farklı yükseklikte pürüzlü alçak tepe), diş diş ton (köşe rengi). Kaplama (en, derinlik, boy) aynı; çarpışma yok (korkuluk kutusu aynı). ≤ 24 üçgen/diş (eski 10), tek ağ: çizim çağrısı aynı. |
| `sur_kule.gd _moloz_tas` | Döküntü taşı kutu (8 köşeli altı yüzlü) → oynatılmış yirmiyüzlü (12 köşe, 20 üçgen), altı yassı; köşe alfası 0,5. |
| `surlar_ayrinti.gd _barrel` | Fıçı: 10 köşeli düz silindir (çap 0,84) + 3 ayrı çember silindiri → tek karınlı ağ (uç çapı 0,54, karın 0,66, boy 0,92; 12 dilim, tahta tahta ton, demir çember, gömme kapak; ≈180 üçgen, eskisi 160), yatık ve dönük. **Çarpışma eski silindirin dışbükey kabuğu (aynı)**. Köşe rengi pişiricide doğrusal okunduğu için doğrusal değer (sRGB yazılınca gece lila-beyaz). |
| `tests/_ist/tur10_yakin.*` (yeni) | Yakın kare sahnesi (yukarıda). |

### Madde madde (karesiyle)
| istenen | durum | kare |
|---|---|---|
| Tuğla gerçek ölçek (4–5 cm, aynı kalınlıkta harç, 5 sıra hatıl), doygunluk düşük, ton farkı, kirli/oyulmuş harç | **TAMAM** | `pafta/yakin_gun.jpg` y4, `pafta/c20.jpg` an_11, `pafta/c25.jpg` an_01 |
| Kireçtaşı: blok ton farkı, aşınmış kenar, kırık köşe, akıntı, dipte kir/yosun; düz beyaz levha yok | **TAMAM (orta/yakın) / KISMEN (0,6 m)** | `sonra/yakin/gun_y4…`, `gece_y2…`; 0,6 m'de (y1) dişin üst taş yüzü hâlâ düz ve tek tonlu okunuyor |
| Dişler birbirinin kopyası değil, tepe eğimli/yuvarlatılmış, kutu gibi okunmasın | **TAMAM** | `pafta/yakin_gun.jpg` y5, y6; `pafta/c25.jpg` an_01, an_04 |
| Gece sur kararır, ordugâh ve gökle aynı tonda | **TAMAM** | `pafta/c25.jpg` (bütün anlar), `pafta/yakin_gece.jpg`, `once|sonra/c0/an_01` |
| Gündüz kareleri ayrıca | **TAMAM** | `pafta/yakin_gun.jpg` (7 kamera) |
| Bütçe ≤ +%5 (kendi ÖNCE'ne göre) | **TAMAM** | aşağıda |
| Bölüm 25 an_06 fıçılar yuvarlak, gerçek ölçek | **TAMAM** (an_06'da fıçı karede değil; sur yolundaki dekor fıçıları an_04'te) | `pafta/c25.jpg` an_04, `pafta/yakin_gun.jpg` y8 |

### Her SONRA karesine tek cümle ("oyuncak gibi mi?")
Bölüm 25 (`sonra/c25`, gece):
- an_01: mazgal dişleri koyu, pahlı, tepesi eğimli; tuğla soluk, harç koyu; sur ordugâh ve gökle aynı tonda; kutu yok, havada yok, korkuluğa oturuyor, aynı ressam — **oyuncak değil; ama dişin önü yakından hâlâ düz yüzlü (kısmen).**
- an_02: sağdaki dişler koyu taş, tuğla bandı ince ve soluk; nöbetçilerle aynı resim — **oyuncak değil.**
- an_03: sur ve kuleler gece tonunda, ordugâh kandilleri öne çıkıyor — **oyuncak değil.**
- an_04: sur yolundaki fıçılar artık karınlı, çemberli, koyu tahta (eski: iri, köşeli, soluk lila); dişler pahlı — **oyuncak değil.**
- an_05: peribolos aşağı bakış; sur gece tonunda — **değişmedi/iyi.**
- an_06: gedik yanakları koyu taş (gece ×0,68 sonra okunuyor), kalas köprü aynı — **oyuncak değil; yanaklar karanlıkta az okunuyor.**

YAKIN (`sonra/yakin`):
- gece_y1 (0,6 m): diş koyu ve pahlı, tuğla bandı koyu; kutu kenarı yok ama düz yüzlü — **kısmen.**
- gece_y2 (1,5 m): korkuluk taşı lekeli/aşınmış, dişler yontulmuş, gökle aynı ton — **oyuncak değil.**
- gece_y3: kule geçidi (kamera kule yüzünden 2 m ama geçidin içi okunuyor) — taş blok blok — **iyi.**
- gece_y4 (sur dibinden 2 m): blok blok ton, aşınmış kenar — **oyuncak değil.**
- gece_y5, y6: dişler pahlı, eğimli tepe; sur yolu döşemesi aynı — **oyuncak değil.**
- gece_y8: gedik fıçıları yuvarlak, karınlı — **iyi.**
- gun_y1 (0,6 m): tuğlalar soluk, ton ton; harç kalın ve kirli; ama dişin taş kısmı yakından düz tek ton, tuğla bandı şerit şerit — **kısmen oyuncak (en zayıf kare).**
- gun_y2…y6: taş kuşağı bal/gri ton farklı, aşınmış; dişler kutu değil; tepe yüzleri gölgede yeşilimsi (gök ışığı × sarı; sur yolu döşemesiyle aynı) — **oyuncak değil.**
- gun_y8: fıçılar yuvarlak, çemberli, gerçek ölçek; çevresindeki moloz/kazık taşıma oturumunun — **iyi.**

Bölüm 20 (`sonra/c20`): an_11 (sur dibinden 2 m, gece) ÖNCE parlak pembe bloklar + doygun tuğla → SONRA koyu, blok blok tonlu
taş, soluk tuğla — **oyuncak değil**. an_03 (240,430) koyu kutu yok (aşağıda). Öbür anlar sur gece tonunda, kutu/havada yok.

Bölüm 0 (`sonra/c0`): an_01 açılış: ÖNCE bembeyaz parlak sur → SONRA gece tonunda koyu taş, hatıl soluk — **oyuncak değil**. an_05:
gedik fıçıları yuvarlak (bkz. "hâlâ kötü").

## 2. Tur 9 kalanları
| madde | durum | kare / not |
|---|---|---|
| Bölüm 20 an_03 (≈240,430) koyu dikdörtgen | **TAMAM** | Üçgen düzeyinde ışın teşhisi (geçici, depoya girmeyen `tasima2_kim` sürümü, ÖNCE kopyasında): ilk görünen yüz dilim-yerel (−66,2; 0,22; 10,5), sur taşı ağında 22 cm yüksekte dik yüz = `sur_kule._moloz_tas` döküntü taşı (köşesi oynatılmış KUTU). → yirmiyüzlü taş + zemin taşı tonu. `pafta/c20.jpg` an_03: kutu yok, yerinde gri yuvarlak taşlar. |
| an_03 altındaki sert kenarlı açık bej bant | **YAPILMADI** | Işın, sur dibinde `SurDibiEtek` / `SurDibiBant` (`sur_oturtma_ag.gd`, benim) gösteriyor; düzeltmeye zaman kalmadı. |
| c5 hendek dış kıyısı y≈545 cetvel kenar | **YAPILMADI** | Zaman ana maddeye ayrıldı. |
| D4 duvar dibi koyu paneller (ay gölgesi) | **YAPILMADI** | — |
| Blakherna tek görsel dil + yakın kareler | **KISMEN** | `pafta/blak.jpg` (b1–b3 ÖNCE = tur 9 SONRA; SONRA + b1y–b3y yakın). Gölgelendirici ve diş ağı Blakherna'da da aynı (aynı kod yolu). b3y (8 m): kuleler ve sur blok blok tonlu, aşınmış, hatıl soluk; kutu kule yok, havada yok — iyi. b1/b1y: şehirde `gorsel_dil` karşıtlık sıkıştırması (b9_karsit 0,7) ve gündüz ışığı altında görünüş tur 9'dakine yakın. Kara suru ile üst üste binme (hat sahibi) aynı. Sağdaki sarı kutu basamaklar şehir merdiveni (benim değil). |

## Üç sözleşme denetimi (ÖNCE 0ded6ea0 → SONRA son kod)
| denetim | ÖNCE (tur 9 raporu, taban) | SONRA |
|---|---|---|
| `tests/_ist/sur_sozlesme.tscn` | `SURSOZLESME PASS kalem=13 kesim=8` | `SURSOZLESME PASS kalem=13 kesim=8` |
| `tests/_ist/sur_oyun_denetim.tscn` | `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` | `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` |
| `tests/_ist/sur_oyun_yuru.tscn` | `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` | `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` |

(`testler/denetim_sonra.txt`; ara kayıtlardan sonra da koşuldu, değişen dosyalar çarpışmaya dokunmuyor.)

## Testler (son kod, `--max-fps 20`, tam süzgeç `AUTOTEST (PASS|FAIL)|SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|WARN_FLY|WARN_VOID` + `SHADER ERROR`)
- `tests/parse_check.tscn` → `PARSECHECK PASS scripts=357`.
- `--chapter=0, 20, 20o, 21, 25, 26, 43o --autotest` → **7/7 AUTOTEST PASS**, denetim satırı **0** (`testler/autotest_*.txt`).
  (Testler son fıçı rengi ayarından önce koşuldu: yalnız köşe rengi sabiti değişti.)

## Bütçe (ÖNCE ↔ SONRA, aynı kamera; Bölüm 25/0 kendi =kare ölçümü (4 kare ort.), yakın sahne 3 kare ort.)
| kare | çizim ÖNCE | çizim SONRA | Δ | ilkel ÖNCE | ilkel SONRA | Δ |
|---|---|---|---|---|---|---|
| c25 an_01 | 3683 | 3684 | +0,0% | 5 660 576 | 5 668 102 | +0,1% |
| c25 an_02 | 2092 | 2092 | 0 | 3 269 305 | 3 274 029 | +0,1% |
| c25 an_03 | 3694 | 3690 | −0,1% | 5 664 056 | 5 667 416 | +0,1% |
| c25 an_04 | 2069 | 2065 | −0,2% | 3 266 878 | 3 268 486 | +0,0% |
| c25 an_05 | 592 | 556 | −6,1% | 786 248 | 721 273 | −8,3% |
| c25 an_06 | 1888 | 1880 | −0,4% | 3 058 201 | 3 027 249 | −1,0% |
| c0 an_01 | 8314 | 8320 | +0,1% | 10 039 460 | 10 054 508 | +0,1% |
| c0 an_02 | 7011 | 7060 | +0,7% | 9 305 065 | 9 396 554 | +1,0% |
| c0 an_03 | 7396 | 7385 | −0,1% | 11 429 386 | 11 421 100 | −0,1% |
| c0 an_04 | 7988 | 8022 | +0,4% | 10 410 699 | 10 443 547 | +0,3% |
| c0 an_05 | 5264 | 5229 | −0,7% | 8 659 710 | 8 626 806 | −0,4% |
| yakın gece y1 | 65 | 65 | 0 | 251 494 | 255 880 | +1,7% |
| yakın gece y2 | 164 | 164 | 0 | 321 853 | 328 497 | +2,1% |
| yakın gece y4 | 129 | 129 | 0 | 280 271 | 286 915 | +2,4% |
| yakın gece y5 | 154 | 154 | 0 | 316 397 | 323 041 | +2,1% |
| yakın gece y8 | 173 | 173 | 0 | 338 618 | 339 148 | +0,2% |
| yakın gün y2 | 168 | 168 | 0 | 315 155 | 325 257 | +3,2% |
| yakın gün y3 | 157 | 157 | 0 | 309 075 | 319 177 | +3,3% |
| yakın gün y4 | 127 | 127 | 0 | 272 007 | 282 109 | **+3,7%** |
| yakın gün y5 | 158 | 158 | 0 | 310 381 | 320 483 | +3,3% |
| yakın gün y6 | 158 | 158 | 0 | 323 115 | 331 297 | +2,5% |

Hepsi +%5 içinde; çizim çağrısı artmadı (diş, taş, fıçı tek ağda / pişiriciye birleşiyor). Ara sürümde diş 40 üçgenken c25 an_05
+%7,5 çıkmıştı → 24 üçgene indirildi; fıçı 368 üçgenken yakın sahne +%12 → 180'e indirildi. Bölüm 25 an_05'teki −%8 ve Bölüm 0'daki
küçük farklar sahne durumundan (NPC) da etkilenir. Ham: `testler/*_butce.txt`. Gölgelendirici maliyeti (piksel başına daha çok
gürültü örneği) yazılımsal GL'de ölçülmedi; kare süresi gerçek GPU'da ölçülmedi.

## Kutu sayımı
- Mazgal dişi: kutu (5 yüz, eşit) → **0** (her diş pahlı/omuzlu/eğimli ayrı taş). Kesimde ≈2000 diş.
- Döküntü taşı (`_moloz_tas`: yıkık korkuluk, yıkık kule, kule dipleri, hendek): köşesi oynatılmış altı yüzlü → **0** (yirmiyüzlü).
- Fıçı: silindir + 3 çember silindiri → karınlı tek ağ (kutu değildi; "köşeli" 10 kenar → 12 dilim, karınlı).
- **Kalan kutu**: korkuluk gövdesi ve sur gövdeleri hâlâ `_s` kutusu (çarpışma ve sözleşme ölçüsü; desen gölgelendiriciden). Şehrin
  bütününde otomatik sayım yapılmadı.

## Hâlâ kötü olanlar (dürüst)
- **0,6 m'de diş** (gun_y1, gece_y1, c25 an_01'in en yakın dişi): düz yüzlü ve tek tonlu; tuğla bandı bu mesafede hâlâ şerit
  şerit (ölçü doğru, ama gölgelendiricide derinlik/kabartma yok). Sıradaki adım: harç derzine ve taş kenarına sahte kabartma
  (normal oynatma), toon ışıkta denenmedi.
- Diş ve korkuluk tepe yüzleri gündüz gölgede yeşilimsi (sur yolu döşemesiyle aynı: gök ışığı × sıcak döşeme rengi).
- an_06 gedik yanakları gece çok koyu (doku az okunuyor).
- Bölüm 20 an_03 sur dibi **sert kenarlı açık bej bant** (`SurDibiEtek`/`SurDibiBant`), c5 hendek kıyısı cetvel kenar, D4 duvar
  dibi koyu paneller: bu turda yapılmadı.
- Blakherna: şehirde gündüz, `gorsel_dil` karşıtlık sıkıştırması altında değişim az; kara suru ile üst üste binme (hat) aynı.
- Gedik onarımının fıçıları (taşıma oturumunun aşama parçası) `_barrel` ortak olduğu için onlar da yeni fıçı oldu (çarpışma aynı);
  Bölüm 0 an_05'te gece koyu okunuyor (son renk ayarı karede: `sonra/c0/an_05`).
- y3 kule kapısı kamerası kule geçidinin içini çekiyor (kule yüzü ışını kapının üstünde de geçide denk geliyor).
- Gerçek GPU'da kare süresi ölçülmedi.

## İstekler
- **run_tests.sh isteği**: `tests/_ist/tur10_yakin.tscn` (yakın kare + bütçe; `--gece`).
- **Taşıma / bölüm sahibi**: `tests/_ist/tasima2_kim.gd`'nin AABB boy süzgeci (>25 m) sur dilimi gibi büyük pişmiş ağları
  eliyor; an_03'te kaynağı bulmak için üçgen düzeyinde sürüm gerekti (ÖNCE kopyasında geçici kullanıldı, depoya girmedi). Kalıcı
  bir `--kim` üçgen kipi önerilir.

## Değişen dosyalar (0ded6ea0 → son kayıt)
| dosya | ne |
|---|---|
| `scripts/world/ist/sur_doku.gd` | yakın ayrıntı (tuğla, harç, taş, döşeme), gece payı + `SurGeceIzle`, döküntü işareti |
| `scripts/world/ist/sur_kule.gd` | `disler_ag` + `_dis_tas` (yontulmuş diş), `_moloz_tas` (yirmiyüzlü) |
| `scripts/world/ist/surlar_ayrinti.gd` | `_barrel` görünen ağı (çarpışma aynı) |
| `tests/_ist/tur10_yakin.gd/.tscn` (yeni) | yakın kare sahnesi |
| `docs/_kanit_ist2_tur10/` | kanıt |

Dokunulmayanlar: `night.gd`, `look.gd`, `project.godot`, `sehir.gd`, `sur_oyun*.gd`, `sur_set*.gd`, `sur_sozlesme*`, bölüm
dosyaları, `gorsel_dil.gd`, `evler/sokak/cati*`. Replik, ses, denge, gizli süre, sayaç değişmedi.
