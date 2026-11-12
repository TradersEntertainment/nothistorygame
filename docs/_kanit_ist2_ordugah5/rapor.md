# ORDUGÂH-5 raporu (dal `wip/ist2-ordugah5`, taban `wip/ist2-ordugah4`; `wip/ist2-canli` ve `wip/ist2-sur4` birleşik)

Sahibinin sorusu: **"çadırlara odaklandın mı, kamp ateşlerine vs"**. Bu turda çadırlar baştan yazıldı (kumaş, ip-kazık,
saçak, kapı perdesi, içi), ocak başları ve dumanlar eklendi, zemin yumuşadı. Kare kare dürüst döküm aşağıda.

ÖNCE = bu dalın başlangıcı (`e106a7e1`, depo dışı `git worktree`), aynı sonda (`tests/_ist/ordugah5_kare.gd`), aynı kamera
(SONRA koşusunun kamera dosyası `--poz` ile ÖNCE dünyasında aynen yeniden çekildi). Çadır/ocak yerleşimi ÖNCE ile aynı
rastgele dizide kalsın diye yeni kararlar ayrı bir dizide (`r5`); bu yüzden kareler aynı yeri gösterir (küçük farklar: yeni
ocakların yer kaplaması sonraki dağınık çadırları kaydırır).

## 1. Çadır ve ateş ÖNCE | SONRA paftaları

| pafta | içerik |
|---|---|
| `pafta_cadir_5m.jpg` | yedi tür, 5 m: koni, çan, çatma, büyük orta çadırı, kıl çadır, başıbozuk barınağı, paşa (sayebânlı) |
| `pafta_cadir_25m_kapi.jpg` | 25 m (koni, çan, büyük) ve kapıdan içeri (koni, çan, paşa) |
| `pafta_ocak_gunduz.jpg` | üç obadan (yeniçeri, Anadolu, Rumeli) 6 m'den ocak başı + 70 m'den iki kare (duman sütunları) |
| `pafta_ocak_gece.jpg` | aynı üç ocak ve aynı iki 70 m karesi gece |
| `pafta_ordugah4_kameralar.jpg` | ORDUGÂH-4'ün altı kamerası (30 m, 70 m, otağ yakın, sur dışı, hendek) + gece 70 m ve gece 30 m |
| `pafta_yer_1.jpg`, `pafta_yer_2.jpg` | 12 yer karesi (kamera en yakın kişiye ≥ 2,5 m) |
| `ilk/sonda_cadir_turleri.jpg` | sonda (düz zemin, `tests/_ist/ordugah5_cadir.tscn`): türler ve katmanlar (yakın/orta/uzak) yan yana |
| `ilk/` | ilk kareli ara gönderim (60. dakikadan sonra; geç kaldı) |

## 2. Kendi karelerime bakınca hâlâ kötü olanlar

- **Bütçe Rumeli'de aşıyor:** uçuşta 60 m Rumeli üstü ordugâh payı **1 220 çizim gündüz / 1 270 gece** (ÖNCE 1 047, hedef ≤ 1 000).
  Öteki dokuz nokta hedefte (§4). Üçgen de arttı: ordugâh payı otağ üstünde 1,44 M → 2,70 M, Rumeli 2,88 M → 7,68 M
  (en büyük pay: yakın katmandaki ~600 üçgenlik kumaş çadırlar ve 7 000 hafif figür; çadır gölgesi kapatıldı, kişiler karolandı).
- **Kurulum süresi uzadı:** uzak hücre pişirme 8,0 sn (ÖNCE) → 11,5–12,5 sn; tek kanat kurulumu `kanat_l0` 745 ms, `kanat_l1`
  1 076 ms (ÖNCE raporu 330–615 ms; hedef ≤ 6 ms). Uçuşta ordugâh üstünde takılma VAR ve arttı. Bölünmüş kurulum YAPILMADI.
- **`ISTORDUKISI icinde=106` (toplam 1 073)**, ÖNCE aynı sondada `icinde=54` (toplam 819). Oran %6,6 → %9,9 kötüleşti. Çatma
  boyu yer dairesine sığdırıldı (son kod); son kodla yeniden sayım: §5'te. `havada=0` iki koşuda da.
- **Barınak (başıbozuk):** önden bakınca eğik örtünün altı koyu düz bir levha gibi (`cadir_barinak_5m`); çalı demetleri seçilmiyor.
  Kumaş değil "kara tahta" okunuyor → A maddesinde barınak KISMEN.
- **DOKU'nun ikinci ordugâh katmanı** (`hayat_veri.gd:_ordugah()`): düz sarı koni çadırlar ve kırmızı ikinci otağ benim
  çadırlarımın arasında duruyor (`cadir_buyuk_5m` solda sarı koni, `cadir_can_5m`). Benim dosyam değil → ORTAK İSTEK (§8).
- **70 m'den duman**: 340–640 sütun sayılıyor (gizlenenler dahil); kare biraz "beyaz çubuk ormanı" (küçük ocakların yalnız üçte
  birinde duman bıraktım). Sütunlar dik ve benzer; rüzgârla eğilme hafif.
- **Gece uzak ateşler** soluk: 70 m karesinde ufukta ateş noktası var (`ates_uzak=481`) ama küçük ve sönük; "ufka kadar ateş
  noktalarıyla dolu" tam okunmuyor (KISMEN).
- **Otağ zokakı** hâlâ düz, perdesiz kutu duvar panelleri (ORDUGÂH-4'ten; bu tur dokunulmadı); otağ önündeki sayebân ve
  mehterhane tentesi düz levha.
- **Ocak yanında odun yığını ve kesme kütüğü** 5–7 kenarlı silindir: yakından kalas/blok gibi duruyor (`yer_yeniceri_obasi`,
  `ocak_*`). Çadır önündeki torbalar 6 kenarlı küre: yastık/kutu gibi (`cadir_koni_5m`).
- **Yer karelerinde zemin** artık çiğnenmiş toprak, ama bütün kanat tek bir kumlu bej-yeşil tonda; çok düz/tekdüze.
- Bazı karelerde kamera bir sancak direğine ya da komşu çadıra çok yakın (`yer_zaganos`, `cadir_koni_5m` sağda çadır duvarı).

**`KUTU kalan=7`** (kendi SONRA karelerimde kutu gibi duranlar): (1) odun yığını/kesme kütüğü (kalas gibi), (2) çadır önü torbalar
(6 kenar), (3) mutfak tezgâhları ve sandık sıraları (`yer_mutfak`, ORDUGÂH-4 `ordugah_yapi`), (4) otağ zokak duvar panelleri,
(5) otağ önü sayebân ve mehterhane tentesi (düz levha), (6) barınak alt yüzü (düz koyu levha), (7) DOKU'nun sarı koni çadırları
(benim değil). Canlılar CANLI'nın (dokunmadım).

## 3. Maddeler

**A. Çadırlar — KISMEN** (barınak ve otağ zokakı yüzünden; öteki altı tür TAMAM).
Yeni dosya `scripts/world/ist/ordugah_cadir.gd` (class_name yok, preload). Bütün türler aynı kumaş gövde üretecinden: süperelips
çevre (yay uzunluğuna eşit aralıklı duvar direkleri), sırt çizgisine (1–4 direk) **içbükey sarkan çatı**, direkler arasında
saçak çökmesi ve içe çekilme, panel başına ayrı ton/normal (dikiş), rastgele yama ve su lekesi, **taraklı saçak + üstte ince renk
şeridi** (koni kahve, çan/büyük lacivert, paşa/otağ altın; kırmızı bez yalnız paşa/otağ), dalgalı gevşek etek ve çamur lekeli alt
şerit, her duvar direğinden **45° gergi ipi + kazık**, orta direk tepede çıkar, **küre topuz + sivri uç (BACA YOK; ÖNCE'deki boru
kalktı)**, kapıda **sol perde rulo hâlinde toplanıp bağlı, sağ perde yarı açık sarkar**, **içi koyu ama derinlikli** (iç duvar/çatı
yüzü koyu, toprak taban, kırmızı-lacivert kilim, minder, pahlı sandık, su kırbası, orta direk). İnce parçalar (direk, ip, kazık,
topuz) eşit olmayan örnek ölçeğinde kalınlaşmasın diye birim/ölçek dengeli.
- Türler (§2.2–2.3): `koni` (tek direk, alçak duvar), `can` (yüksek duvar, geniş taraklı saçak; yeniçeri orta çadırı, otağ halkası),
  `catma` (iki direk + mahya), `buyuk` (büyük orta/bey çadırı, iki direk, saçaklı), `pasa` (üç direk, kırmızı, altın saçak,
  **sayebân** iki direkli sarkık gölgelik + taraklı saçak + halı), `otag` (otağ-ı hümayun, 18 direk, kırmızı-altın), `kil` (koyu
  kıl, alçak, dört direk dalgalı sırt, ön yüz açık), `barinak` (yamalı örtü + çalı demetleri + eğri dallar).
- Kareler: `pafta_cadir_5m.jpg`, `pafta_cadir_25m_kapi.jpg`, `ilk/sonda_cadir_turleri.jpg`. Kumaş mı kulübe mi: koni, çan, çatma,
  büyük, kıl, paşa, otağ **kumaş** okunuyor; barınak okunmuyor.
- Çevre (§7b 8, 10, 11): çadır önlerinde kilim/hasır, mızrak çatkısı, çadıra yaslı yuvarlak kalkan, eyer, torba, su kırbası;
  obada çamaşır ipi (iki sırık, sarkan bezler); ocakta odun yığını ve kütüğe saplı balta (`ordugah_oba.gd:_cadir_onu`, `_camasir`).
- Kutu yasağı: pazar çuvalları ve kumaş topları, deve yük çuvalları yuvarlak oldu (`ordugah_yapi2.gd`, `ordugah_oba.gd`).
- Uzak/orta katman: orta ≤ 120, uzak ≤ 40 üçgenlik **aynı biçimli** (sarkık çatı) siluet; orta/uzak katmanda türler iki çoklu ağda
  birleşir (yuvarlak/dikdörtgen; kıl koyu tonla, barınak alçak), uzak hücreye pişer.
- Otağ kompleksi: otağ, iki divan (paşa ağı), hazine (çan), kilar ve namazgâh (çatma), mutfak (büyük, turuncu, tepesinden duman)
  kumaş ağlara geçti; otağın düz siyah kapı dikdörtgeni ve çatıdaki düz altın çubuklar kalktı.
- Çağıranlar: `ordugah_oba.gd` (bütün kanatlar), `ordugah_otag.gd`, `ordugah_yerleske.gd` (paşa, esir), `ordugah_yapi.gd`,
  `ordugah_donanma.gd` (eski adlar `K.tent_mesh` üzerinden eşlenir: yuvarlak→koni, cati→catma, bark→barınak, sade→orta).

**B. Kamp ateşleri ve ocak başı — TAMAM (gündüz) / KISMEN (gece uzak ufuk)** (`pafta_ocak_gunduz.jpg`, `pafta_ocak_gece.jpg`).
Yeni dosya `ordugah_ocak.gd`: yuvarlak taşlardan halka, çatılmış yuvarlak odunlar, kor ve kor parçaları, iki halkalı kül/is lekesi,
**sacayağında zincirli bakır kazan** ya da **iki çatallı sırıkta şişte et** ya da yalnız ateş; yanında odun yığını + kütükte balta.
Alev oyunun gerçek alevi (`Flame`, çoklu ağ; küp ateş yok), **gündüz de yanar** (yakın katman). §5.3 oranı: her obada ana ocak +
çadırların arasına **her ~4 çadıra bir** küçük ocak; hepsi çadır duvarına **≥ 3 m** (yer kaydı: ana ocak 2,3 m daire + çadır 1 m
payı; küçük ocak 2,5 m boşluk sınaması). Başlarında 2–7 kişi: bağdaş kurmuş, uyuklayan, ayakta konuşan (`sohbet`, yeni tip),
silah bileyen, aşçı (kepçe). Duman: host başına tek çoklu ağ, üç çapraz şerit, gölgelendirici ile titreşen/eğilen 14–26 m sütun
(gündüz açık gri, gece koyu ve soluk). **70 m'den sayım (ekranda): gündüz duman 354 (Anadolu) / 641 (yeniçeri); ÖNCE 0.**
Gece: alev + hale yakın ve orta katmanda; ana ocakta gerçek ışık (OmniLight, gölgesiz, en çok 2/oba) yüzlere ve çadıra vuruyor;
bey çadırı kapısında **meşale** (sırık + alev); uzak hücrelerde ocaklar ışıyan nokta (hücre başına tek çoklu ağ).
**70 m gece sayım (ekranda): ateş noktası yakın 556 / 1 042, uzak 0 / 481; ÖNCE gece yakın 258 / 476, uzak 0, duman 0.** Otağ çevresi fenerli (ORDUGÂH-4'ün 8 gece ateşi).

**C. Zemin — KISMEN** (`pafta_yer_*`, `pafta_ocak_gunduz.jpg`). Yumuşak kenarlı (köşe saydamlığı) zemin ağı (host başına tek
çizim): kanat boyunca büyük solgun/çiğnenmiş ot lekeleri, oba altında çiğnenmiş toprak, ocak çevresi isli, her çadırın altında koyu
"temas gölgesi" lekesi, obalar arası yollarda **iki tekerlek izi**; benekli (hücresel gürültü) doku ayak/toynak izi yerine geçiyor.
Keskin çokgen kenar YOK (yakın ve orta katman); uzak katmanda eski düz lekeler (pişen ağ, saydam olamaz). Kalan: ton çok tekdüze,
tekerlek izleri ince; "solgun ot öbekleri" (ayrı tutam) YAPILMADI.

**D. Yaşam çeşitliliği — TAMAM** (`pafta_yer_*`, sayım satırları). Sondada her karede kişinin işi sayıldı (`dimdik` = nöbet, okçu,
mızraklı azap, sipahi, yürüyen kol; `öbür` = oturan, uyuklayan, aşçı, odun kesen, bileyen, saka, seyis, konuşan, kâtip...). 12 yer
karesi toplamı **dimdik 113 / öbür 650 (%15)**; yalnız `yer_siper` (ön hat nöbeti) ve `yer_top_mevzii` çoğunluk dimdik. Sayılar
AZALMADI: 400 m içinde karede kişi ÖNCE 81–1 407, SONRA 81–2 159 (her karede ≥ ÖNCE; §5 tablosu). Kişi havada 0; çadır içinde
kişi KISMEN (yukarıda).

**E. Gece ve bütçe — KISMEN** (§4). Gece kareleri ve gece bütçesi ölçüldü. Rumeli üstü aşıyor (gündüz 1 220, gece 1 270).
Çadır üçgeni hedefte: **yakın 664–896, orta 56–98, uzak 4–36** (`ISTCADIR` satırları: koni 664/98/25, çan 764/98/25, çatma
858/62/28, büyük 818/58/32, kıl 488/56/30, barınak 208/20/4, paşa 896/70/36, otağ ölçülmedi: tek örnek).

**F. Dokunma kuralları — TAMAM.** Hayvan işlevleri (`_at`, `_at_sirasi`, `_deve_yatan`, `_koyun`, `_kopek`, `_okuz`, ağıl
hayvanları) değişmedi; `wip/ist2-canli` ve `wip/ist2-sur4` iki kez çekilip birleşti (çakışma yok). `IstOrdugah.plan` öğe
kimlikleri ve `wpt` arayüzü aynı. Bölüm 7 ve 11 başsız 20/20 PASS (§6).

## 4. Bütçe (oyunun RINFO'su, sonda `ISTORDUBUTCE`; ordugâh payı = ordugâh düğümü gizlenip yeniden ölçülerek)

Gündüz:

| nokta | ÖNCE v2 / ordugâh çizim (üçgen) | SONRA v2 / ordugâh çizim (üçgen) | hedef |
|---|---|---|---|
| uçuş 60 m otağ | 1 229 / 723 (1,44 M) | 1 224 / 713 (2,70 M) | ✔ |
| yer otağ | 1 124 / 601 (1,27 M) | 1 145 / 622 (2,04 M) | ✔ |
| uçuş 60 m Şahi | 1 001 / 321 (0,57 M) | 1 010 / 290 (0,85 M) | ✔ |
| yer Şahi | 893 / 116 (0,30 M) | 937 / 116 (0,34 M) | ✔ |
| uçuş 60 m Anadolu | 430 / 380 (0,62 M) | 406 / 348 (1,34 M) | ✔ |
| yer Anadolu | 392 / 348 (0,87 M) | 377 / 328 (1,34 M) | ✔ |
| uçuş 60 m Rumeli | 1 260 / **1 047** (2,88 M) | 1 439 / **1 220** (7,68 M) | ✘ |
| uçuş 60 m batarya 2 | 786 / 166 (0,33 M) | 825 / 173 (0,70 M) | ✔ |
| uçuş 60 m yeniçeri | 813 / 660 (1,43 M) | 810 / 653 (2,70 M) | ✔ |

Gece:

| nokta | ÖNCE gece ordugâh çizim (üçgen) | SONRA gece v2 / ordugâh çizim (üçgen) | hedef |
|---|---|---|---|
| uçuş 60 m otağ | 814 (1,58 M) | 1 325 / 806 (2,85 M) | ✔ |
| yer otağ | 643 (1,26 M) | 1 198 / 669 (2,07 M) | ✔ |
| uçuş 60 m Şahi | 344 (0,56 M) | 1 028 / 307 (0,87 M) | ✔ |
| yer Şahi | 143 (0,42 M) | 953 / 138 (0,37 M) | ✔ |
| uçuş 60 m Anadolu | 465 (1,01 M) | 477 / 415 (1,81 M) | ✔ |
| yer Anadolu | 379 (0,89 M) | 403 / 352 (1,37 M) | ✔ |
| uçuş 60 m Rumeli | **1 133** (2,91 M) | 1 495 / **1 270** (7,88 M) | ✘ |
| uçuş 60 m batarya 2 | 196 (0,40 M) | 851 / 197 (0,80 M) | ✔ |
| uçuş 60 m yeniçeri | 726 (1,55 M) | 886 / 723 (2,89 M) | ✔ |

Not: SONRA gündüz tablosu son kodun bir önceki hâliyle (gündüz orta katman alevi açık, kişi karosu 36 m) ölçüldü; son kodda bu iki
şey çizimi yalnız AZALTIR (yeniden ölçüm: BAKILMADI). Gece tablosu son kodla. Yapılanlar: kanat çadırları gölge düşürmez (yerine
temas lekesi), kanadın yakın katman eşiği 120 + r → 55 + r m, orta/uzak katmanda çadır türleri iki ağda, kişiler 50 m karolarda
(gerçek model ~20 000 üçgen yalnız ≤ 45 m; ötesi hafif figür), hafif figür ve ocak üçgeni azaltıldı, gündüz alev yalnız yakında.
Rumeli için sıradaki (yapılmadı): Rumeli kanadının orta katmanında duman/zemin ağlarını hücrede birleştirmek, `rumeli_*` lod 1
eşiğini 450 → 350 m.

## 5. Kişi ve hayvan (12 yer karesi; `kisi_karede` = 400 m içinde ekranda, `dimdik/öbür` = 40 m içinde işi)

| kare | ÖNCE kişi (karede) | SONRA kişi (karede) | SONRA dimdik / öbür |
|---|---|---|---|
| yer_otag_onu | 938 | 1 145 | 2 / 27 |
| yer_yeniceri_obasi | 1 254 | 1 929 | 2 / 54 |
| yer_anadolu | 965 | 1 600 | 6 / 42 |
| yer_rumeli | 1 407 | 2 159 | 16 / 142 |
| yer_pazar | 447 | 476 | 4 / 83 |
| yer_top_mevzii | 81 | 81 | 24 / 29 |
| yer_sahi | 94 | 94 | 6 / 24 |
| yer_siper | 631 | 809 | 41 / 18 |
| yer_at_bagi | 920 | 1 203 | 3 / 52 |
| yer_mutfak | 536 | 614 | 1 / 60 |
| yer_mescit | 769 | 875 | 3 / 56 |
| yer_zaganos | 186 | 291 | 5 / 63 |

`ISTORDUKISI` (yedi öğe çevresi, ışın sınaması): ÖNCE `icinde=54 havada=0 toplam=819`; SONRA `icinde=106 havada=0 toplam=1073`
(çatma sığdırmadan önceki kod). Son kodla (başsız, aynı sonda): `icinde=102 havada=0 toplam=1088` → oran %9,4; düzelmedi (KISMEN).
Kamera kişiye ≥ 2,5 m: `_kisiden_uzak` (sonda) en yakın kişiye 2,5 m'den yakınsa kamerayı geri/yana çeker; 12 karenin hepsinde.

## 6. Testler

- `parse_check`: `PARSECHECK PASS scripts=338`.
- Bölüm 7 (son kod): "" tea lost form wall wallkeep byz byzniko byzcell fez → **10/10 AUTOTEST PASS, yasak satır 0**
  (`ISTBAGLAMA temizle bolge=camp sehir_oge=0 ordugah_oge=30`).
- Bölüm 11 (son kod): "" arrest escape persuade help helpwall lost fired hikmet niko → **10/10 AUTOTEST PASS, yasak 0**.
- Komşu bölümler (varsayılan varyant, bir önceki kod): 6, 8, 10, 12b → 4/4 PASS, yasak 0.
- Yasak satır taraması: SCRIPT ERROR, WARN_FX_STUCK, WARN_FLY_ITEM, VISAUDIT, WARN_VOID_TELEPORT, WALKTHRU, ARMAUDIT, HELDAUDIT,
  LOOKAUDIT backturn, JOURNEY_MISS, JOURNEY_OVERLAP: hepsi 0.

## 7. §7c "KESİNLİKLE OLMASIN"

- [x] Hilal/yıldız yok: topuz/alem küre + sivri uç; sancaklar ORDUGÂH-4'ün hilalsiz flamaları.
- [x] Modern fes yok (kişi modelleri ORDUGÂH-4'ünkü; yeni tip `sohbet` sarıklı).
- [x] Kırmızı çadır ordusu yok: kırmızı bez yalnız `pasa` ve `otag` ağlarında (üç paşa, iki divan, otağ); saçak şeritleri kahve/lacivert.
- [x] Tüfekli yeniçeri hattı yok. [x] Kuka/kaşıklı külah yok. [x] Tekerlekli sahra topu / zigzag / tabya yok (dokunulmadı).
- [x] Modern/çan (Sibley) çadır yok: "çan" burada §2.2'nin duvarlı, saçaklı yeniçeri orta çadırı; metal, fermuar, cam yok;
  parlak beyaz bez yok (en açık bez `f1ead6`).
- [x] Çok renkli karnaval / ızgara / eş boy yok. [x] Minare/ezan yok. [x] 18. yy mehter bandosu yok. [x] Tuğra yok.
- [x] Pazarda çay/kahve/tütün/domates yok. [x] Çocuk/kadın kalabalığı yok. [x] Orhan bayrağı yok.

## 8. ORTAK İSTEK / BİLGİ

- **DOKU (İSTEK, ORDUGÂH-4'ten yineleniyor):** `scripts/world/ist/hayat_veri.gd:_ordugah()` ordugâh yerlerine düz sarı koni
  çadırlar (`K["cadir"]`, ~60–70) ve kırmızı ikinci otağ (`Color(0.78, 0.2, 0.16)`, satır ~578) koyuyor; karelerimde kumaş
  çadırların arasında "kutu/koni" olarak görünüyor. Öneri: o işlevde ordugâh alanı için yalnız uzak (> 450 m) ateş/duman kalsın:
  ```gdscript
  # hayat_veri.gd:_ordugah() başında
  if IstOrdugah.plan().size() > 0:
  	return   # ordugâhın kendi çadırı, kişisi ve ateşi var (ORDUGÂH-4/5)
  ```
- **BİLGİ:** `IstOrdugahKit.tent_mesh(ad)` artık kumaş çadır verir; yeni adlar `koni can catma buyuk pasa otag kil barinak`
  (önek `orta_`, `uzak_`), `IstOrdugahKit.tent_lod(ad, lod)`. Eski adlar eşlenir.

## 9. Kurallar

- Değişen dosyalar yalnız `scripts/world/ist/ordugah*.gd` (yeni: `ordugah_cadir.gd`, `ordugah_ocak.gd`, class_name yok) ve
  sondalar `tests/_ist/ordugah5_kare.*`, `tests/_ist/ordugah5_cadir.*`. Hayvan işlevlerine dokunulmadı (`git diff` ile bakıldı).
- Kanca/denetim susturma yok; ses üretilmedi; PR yok; `main`e dokunulmadı.

## SAHİBİNE GÖSTERİLECEK 8 KARE

1. `sahip_1_cadir_can_kapi.jpg` — çan çadır kapıdan: taraklı lacivert saçak, ipler, kazıklar, toplanmış perde, içerde kilim ve direk.
2. `sahip_2_cadir_koni_25m.jpg` — 25 m'den oba: konik ve büyük çadırlar, ipler, arkada duman sütunları.
3. `sahip_3_ocak_yeniceri.jpg` — ocak başı gündüz: sacayağında kazan, aşçı, bağdaş kurmuşlar, odun yığını, gerçek alev.
4. `sahip_4_gece_ocak_anadolu.jpg` — aynı tür ocak gece: ateş ışığı yüzlerde ve yerde, meşale, kazan.
5. `sahip_5_ust70_yeniceri.jpg` — 70 m'den ordugâh gündüz: yüzlerce ince duman sütunu, kumaş çadır denizi, otağ.
6. `sahip_6_gece_ust70_yeniceri.jpg` — 70 m'den gece: ocak noktaları, otağ çevresi, ufka doğru hale.
7. `sahip_7_cadir_kil_5m.jpg` — başıbozuk kıl çadırı: koyu kıl, dalgalı çok direkli sırt, ön yüz açık.
8. `sahip_8_cadir_pasa_5m.jpg` — paşa çadırı: kırmızı üç direkli çatı, altın saçak, sayebân, nöbetçiler.
