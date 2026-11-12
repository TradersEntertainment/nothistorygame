# CANLI — ortak canlı kiti ve kutu hayvanların kaldırılması (kalite notu 32 "KUTU YASAĞI")

Dal `wip/ist2-canli` (taban `wip/ist2-ordugah4`, üstüne `wip/ist2-doku4` birleşik). ÖNCE kareleri depo dışı kopyadan
(`e106a7e1` = `wip/ist2-ordugah4` ucu, `git archive`), SONRA bu daldan; ikisi de aynı sonda/kamera ile.

## 1. Öküz ÖNCE | SONRA

- `pafta_01_ordugah_sahi_once_sonra.jpg`: sahibinin karesinin AYNI kamerası (`yer_sahi`: ORDUGÂH-4 sondası `_yer()`
  hesabı, `tests/_canli/ordu_kare.gd` mirasla aynı kodu kullanır) + Şahi öküzleri 6 m'den + ağıl öküzü/koyunları.
  Sol ÖNCE (ahşap dokulu kutu gövde, kutu baş, çubuk bacak), sağ SONRA (kesit halkalı gövde, geniş alınlı baş, lir
  boynuz, gerdan, diz/bilek eklemli bacak, püsküllü kuyruk, boyunduruk).
- `sonda_01_okuz_once_sonra.jpg`: nötr zeminde sonda (adı `sonda_`): üst ÖNCE, alt SONRA; 5 m yandan, çapraz önden,
  önden, 60 m, sürü (10).

## 2. Kendi karelerime bakınca hâlâ kötü olanlar

- **Orta katman yakında çokgen:** ordugâhın düz Bld'lerinde (at bağı, ağıl, oba) hayvan orta katmanda (≈ 260–300
  üçgen, 6 kesim) Bld'nin içine pişiyor (çizim artmasın diye). 5–8 m'den bakınca gövde kenarı çokgen kırığı ve toon
  gölgede yüz yüz okunuyor (`yakin_agil`: ağıl öküzü). Kutu değil, ama "yuvarlak" da değil: KISMEN.
- **60 m karesi:** gerçek ölçekte hayvan 20–40 piksel; siluet (dört bacak, boyun, baş) okunuyor ama ayrıntı yok.
- **Deve:** baş gövdeye göre küçük, boyun gerçek devedeki gibi aşağı inip yükselmiyor (düz öne uzanıyor); çökmüş
  devede bacak katlanışı yandan bakınca dizin dışarı taştığı yerde kırık.
- **Kedi ve köpek:** kutu değil ama karikatür: kedi hâlâ biraz gelincik gibi uzun, köpeğin başı ata benziyor
  (`sonda_07`, `sonda_08`). ÖNCE'deki kedi zaten kürelerdendi; kazanç küçük.
- **Martı:** tünekte katlı kanadın koyu ucu kuyruğun çok gerisine uzanıyor, yandan bıçak gibi (`sonda_07`).
- **`pafta_01` 60 m karesi:** kamera öküze bakıyor ama öküzler batarya setinin arkasında kalıyor; karede hayvan yok
  (ÖNCE'de de yok). 60 m kanıtı yalnız sonda paftalarında: ordugâh içinde KANITSIZ.
- **28o uzak sürü:** ilk SONRA karesinde sürü bembeyazdı (kitin açık postu eski yüz gölgesinden parlak); taban rengi
  koyulaştırıldı, son karesi `pafta_03`'te (aşağıda).
- **Öküz önden:** boyunduruk başın üstünden geçen düz çubuk gibi duruyor (ensede değil, alnın üstünde okunuyor).
- **Koyun:** yatan koyunun bacakları gövdenin altında kayboluyor, iyi; ama otlayan koyunun başı yakında çok koyu leke.
- **Ordugâhta canlılık yok:** ordugâh hayvanları durağan birleşik ağ (duruş çeşitliliği var: duran, otlayan, yatan,
  başı dönük; ama baş/kuyruk/kulak OYNAMIYOR). Canlılık yalnız oyunun sınıflarında (Ox, Horse, Goat, Cat, Chicken,
  martı, şehrin yakın hayvanları, kızak öküzü). KISMEN.
- **Şehir sürüsü (MultiMesh, ≤ 520 m):** uzak katman siluetine (≤ 90 üçgen) indi; yakından bakılırsa köşeli (yakında
  gerçek gövde katmanı var, ama 26 m'nin hemen ötesinde siluet seçiliyor). Kare almadım: BAKILMADI.

## 3. A. Ortak canlı kiti — `scripts/world/ist/canli_kit.gd`

`class_name` YOK (yeni class_name yasağı): kullanan `preload("res://scripts/world/ist/canli_kit.gd")` ile çağırır.

- Gövde, boyun, baş, bacak, kuyruk, kulak, boynuz **kesit halkalarından örülmüş tüp** (her halka elips: yan rx, üst
  ryt, alt ryb; renk); uçlar yumuşak kubbe; normaller halka elipsinin normali (yumuşak). Küçük parçalar (göz, burun
  deliği, hörgüç, pati, yük çuvalı) aynı üreticiden elipsoit. **Kutu çağrısı yok** (`grep -c "box(" canli_kit.gd` = 0).
- Gövde profili türe göre 8 kesit (sağrı, kalça, karın, göğüs, omuz, göğüs ucu; sırt çizgisi ve karın eğrisi):
  sığır, at, köpek/kedi, deve, koyun profilleri. Boyun gövdenin içinden başlar (dikiş yok). Baş türün biçiminde:
  öküzde geniş alın + açık burun aynası + lir boynuz + gerdan; manda yassı geriye kıvrık boynuz; atta uzun yüz, yele,
  perçem, dik kulak, kıl kuyruk; eşek/katırda uzun kulak, açık burun; devede uzun kavisli boyun, hörgüç, yarık dudak,
  diz nasırı; koyunda yün hacmi (pürüzlü kabuk), koyu baş ve bacak; keçide geriye kıvrık boynuz, sakal; köpek/kedi pati.
- Bacak: omuz/kalça → dirsek/diz → bilek/hock → toynak (ayrı ton) iki eklemli; arka bacakta hock geride.
- Ton: düz renk + köşe renginde hafif fark (sırt koyu, karın açık, burun/toynak/boynuz ayrı ton), oyunun toon malzemesi
  (`Props.mat` dili, dış hat dahil).
- Ölçü: öküz cidago 1,42 (sınıfta 1,48), gövde + baş ≈ 2,4 m; at 1,50 (binek sınıfı 1,66: eski eyer yüksekliği
  `SADDLE_Y` korunsun diye); deve hörgüç tepesi ≈ 2,05; koyun 0,70.
- Katmanlar, duruşlar (`dur`, `otla`, `yat` = çökme, `yuru` = çapraz adım evresi, kuş `uc`), koşum ayrı parça
  (`boyunduruk`, `yular`, `semer`, `yuk`, `eyer`, `cul`).
- Çıktılar: `mesh()` (durağan, önbellekli), `dugum()` (eklemli düğüm ağacı; `birlestir` ile parçalar atasına pişer),
  `bld_ekle()` (ordugâh Bld'sine), `birikim()`.

### Tür tablosu (üçgen; `tests/_canli/sonda_kit.gd` → `CANLIUCGEN`)

| tür | yakın (lod 0, ≤ 1 400) | orta (lod 1, ≤ 300) | uzak (lod 2, ≤ 90) | eklemli parçalar |
|---|---|---|---|---|
| öküz | 1 380 | 279 | 80 | gövde, boyun, baş, 2 kulak, kuyruk, 4 üst + 4 alt bacak |
| manda | 1 380 | 279 | 80 | aynı |
| at | 1 316 | 261 | 80 | aynı (+ yele boyunda) |
| katır | 1 268 | 261 | 80 | aynı |
| eşek | 1 268 | 261 | 80 | aynı |
| deve | 1 396 | 297 | 88 | aynı (hörgüç gövdede) |
| koyun | 1 160 | 273 | 80 | aynı |
| keçi | 1 316 | 291 | 80 | aynı |
| köpek | 1 220 | 297 | 80 | aynı |
| kedi | 1 220 | 297 | 80 | aynı |
| tavuk | 686 | 144 | 61 | gövde, baş, 2 kanat |
| martı | 624 | 108 | 72 | gövde, baş, 2 kanat |
| güvercin | 576 | 108 | 72 | gövde, baş, 2 kanat |

Uzak katman siluet: dört bacak (omuzdan yere tek tüp), boyun, baş, gövde (hörgüç devede gövde kesitinde).

## 4. B. Oyunun kendi hayvan sınıfları (arayüz, çağrılar, çarpışma, hız, davranış AYNI)

| dosya:işlev | ne oldu | durum |
|---|---|---|
| `scripts/npc/ox.gd:_ready` (s. 29) | kit öküzü; `_body`, `_head` (= boyun kökü), `_tail`, `_legs` aynı adla; `OxBody` çarpışma aynı. Görünüş için `_knees`, `_ears`: yatınca diz katlanır, yürürken bükülür, kulak seğirir | SONRA sondası `sonda_` + 28o kareleri |
| `scripts/npc/horse.gd:_ready` (s. 30) | kit atı (H 1,66) + eyer, örtü (`cloth` rengi), yular; üzengi ve göğüslük yuvarlak; `_legs/_knees/_neck/_tail` aynı. Diz yönü anatomiye göre (ön bilek geri, arka hock öne) | sonda |
| `scripts/npc/goat.gd:_ready` | kit keçisi, kök düğüm adı `Body` korunur, `_legs` 4 | sonda |
| `scripts/npc/cat.gd:_ready` | kit kedisi; `_body`, `_tail` | sonda |
| `scripts/npc/chicken.gd:_ready` | kit tavuğu; `_body`, `_head`, `_wings` (z çırpma) | sonda |
| `scripts/npc/thief_gull.gd:_ready` | kit martısı; `_head` (izin kâğıdı onun çocuğu), `_wings` [[pivot, s]] | sonda |
| `scripts/level/slipway.gd:_ox_model` (s. 2619) | kızak öküzü (Bölüm 2) kitten; dönüş sözlüğü aynı; RNG tüketimi aynı | test PASS; kare BAKILMADI |
| `scripts/level/scenery.gd:horse_mesh` (s. 221) | ordu dolgusu atı kitten (orta, açık post; örnek rengi boyar) | KANITSIZ |
| `scripts/chapter10.gd:_camel` (s. 202) | kit devesi + kırmızı çul + yular | KANITSIZ |
| `scripts/chapter16.gd` kedi kurulumu (s. 124) | "kutu gibi" kedi kit kedisi oldu (boyu aynı) | KANITSIZ |
| `scripts/chapter28o.gd:_herd_pair_mesh` | 28 boyunduruk çifti (56 öküz) uzak sürü: kit (orta) + yuvarlak ortak boyunduruk | 28o karesi |
| `scripts/level/dressing.gd:horse` | `Kit.has_horse()` doğru (hazır model) → DOKUNULMADI; kutu yedeği hâlâ kodda | — |

## 5. C. Ordugâh ve şehir (yalnız hayvan işlevlerinin gövdesi; imza, yer, sayı, yön, RNG tüketimi aynı)

| dosya:satır | işlev | not |
|---|---|---|
| `ordugah_yapi.gd:430` | `_okuz` | kit öküzü + boyunduruk; duruş konuma göre (dur/otla, baş yönü); `solid_box` aynı |
| `ordugah_yapi2.gd:166` | `_at` | at (çul, yular) / ayakta deve (yular); duruş karışık; `solid_box` aynı |
| `ordugah_oba.gd:518` | `_deve_yatan` | çökmüş deve (`yat`) |
| `ordugah_oba.gd:526` (s. 538 gövdesi) | `_koyun` | yalnız koyun çizimi; otlayan/duran/yatan karışık |
| `ordugah_oba.gd:550` | `_kopek` | çoban köpeği (ayakta) |
| `ordugah_yerleske.gd:161` (s. 189) | `build_agil` | yalnız koyun çizimi (öküzler `_okuz` üzerinden) |
| `hipodrom.gd:390` | `_hayvanlar` | ÇEVRE-4'ün 18 hayvanı korunarak: görünüş kitten, çarpışma kutuları görünmez katı (aynı yer/ölçü), RNG aynı |
| `hayat_mesh.gd:65` | `hayvan`, `tavuk`, `kus` (+ yardımcı `_canli`) | şehir MultiMesh'i: eşek/tavuk uzak siluet, martı/güvercin uzak siluet (kanat açık); gölgelendirici kuralları (bacak y < 0,64, otlama baş z < −0,4, renk alfa kodu) korunur |
| `hayat_yakin_govde.gd:244` (s. 254) | `animal` (köpek, kedi, eşek) | kit; gövde+boyun+baş+kulak tek ağ, alt bacak üste pişer (hayvan başına 6 ağ); `legs`/`tail` metası aynı |

**Bld kuralı (`canli_kit.gd:bld_ekle`):** desensiz Bld ve orta katmanın `rubble` tek ağı → hayvan Bld'nin İÇİNE
(çizim eklenmez; `rubble` = ordugâhın lod ≥ 1 obası → uzak siluet). Ahşap desenli Bld (Şahi topu, batarya arabası,
öküz sırası) → ahşap dokusu canlıya geçmesin diye Bld katısının altında ayrı köşe renkli ağ: yakın (≤ 24 m, dış hatlı)
ve orta (24–300 m, dış hatsız, gölgesiz) çifti, aynı anda biri çizilir.

**Birleştirme:** `wip/ist2-doku4` (içinde ordugah4, cevre4) birleşti; çakışma `hipodrom.gd`'de: ÇEVRE-4 hâli + benim
hayvan gövdem (sayı 18). `.uid` çakışmaları karşı tarafın hâli.

## 6. D. Kutu avı (yalnız rapor; sonraki turun girdisi). `KUTU kalan=21` (ordugâh + şehir, hayvan dışı)

| # | dosya:işlev (satır) | nesne | olması gereken |
|---|---|---|---|
| 1 | `ordugah_oba.gd:_deve_cokegi` (513) | yük çuvalları (4 kutu) | elipsoit/torba |
| 2 | `ordugah_yapi2.gd:build_mutfak` (130) | 7 saman/erzak çuvalı | torba |
| 3 | `ordugah_yapi2.gd:build_pazar` (87, 89) | tezgâh mal yığınları (saman kutusu, renkli kumaş kutusu) | sepet, torba, top kumaş (silindir) |
| 4 | `ordugah_yapi2.gd:build_pazar` (91) | "kasa ve fıçı": fıçı yerine kutu | fıçı silindiri |
| 5 | `ordugah_yerleske.gd:build_dokumhane` (70–73) | ocak, körük, örs, kıl örtü | ocak taş yığını, körük deri torba, örs biçimi |
| 6 | `ordugah_yerleske.gd:build_lagim` (240–243) | lağım ağzı | moloz/kazık |
| 7 | `ordugah_yapi.gd:_top` (392–397) | top kundağı ve arka dayanak bloğu | kalas istifi (pahlı) |
| 8 | `ordugah_yapi.gd:build_sahi_top` (449–453) | vinç ayakları ve karşı ağırlık (çıplak kutu) | kiriş (pahlı) + taş sepeti |
| 9 | `ordugah_yapi.gd:build_mancinik` (489–504) | karşı ağırlık sandığı, sandık yığını | sandık doğru ama tek çıplak kutu |
| 10 | `ordugah_kisi.gd:figur` (126–137) | orta katman KİŞİ: kollar, çizme, bıyık, yatırtma kutu | canlı → kapsül (kutu yasağı) |
| 11 | `hayat_mesh.gd:insan` / `insan_uzak` (25, 52) | şehrin MultiMesh insanı kutu (10 kutu) | kapsül/kesit halkalı siluet |
| 12 | `ordugah_kit.gd:tent_mesh` (317–330) | çatma çadırın duvar/söve parçaları | çadır kumaşı kavisli |
| 13 | `ordugah_otag.gd:build` / `_zokak` (35–145, 224–245) | otağ çevresi zokak ve söveler (çok sayıda çıplak kutu) | çit, perde kumaşı |
| 14 | `ordugah_yapi.gd:build_otag` (81–146) | kapı söveleri, taht kürsüsü, sandıklar | pah/derz |
| 15 | `ordugah_yapi.gd:_kule_ahsap` (196–229) | kule platformu ve korkuluk (kalas: kalabilir, pahsız) | pah |
| 16 | `ordugah_yapi.gd:build_kule` (520–563) | tekerlekler kızağa kutu (520 yorum) | tekerlek silindiri |
| 17 | `ordugah_yapi2.gd:build_ahir` (202–209) | su tekneleri | oyma tekne (yuvarlak dip) |
| 18 | `ordugah_yerleske.gd:build_pasa` (31–44) | paşa çadırı önü kutular | sandık/minder |
| 19 | `ordugah_yerleske.gd:build_kule_hazirlik` (218–228) | deri balyaları | balya yuvarlak kenarlı |
| 20 | `ordugah_donanma.gd:build_kizak`, `build_fici_kopru` | fıçı köprüde fıçılar? (kalas doğru) | fıçı silindir olduğunu doğrula: BAKILMADI |
| 21 | `scripts/level/dressing.gd:pigeons` | güvercin iki küre (kutu değil ama kuş değil) | kit güvercini |

Ağaç tacı, kaya ve gülle ordugâh dosyalarında `sph`/`cyl` ile (kutu değil); sur dışındaki "oyuncak ağaçlar" SUR-4/ÇEVRE-4
dosyalarında: BAKILMADI.

## 7. Bütçe (oyunun RINFO'su; ordugâhta ORDUGÂH-4 sondasının `_olc` ölçüsü)

`_olc`: aynı kamera, önce toplam, sonra ordugâh düğümü gizlenip fark alınır (`ordu_cizim`, `ordu_ucgen`). İki ayrı akış
(kısa: `--kisa`, sahibin iki karesinden sonra; tam: yakın karelerden sonra), her biri ÖNCE ve SONRA aynı akışla:

| nokta | kısa ÖNCE | kısa SONRA | tam ÖNCE | tam SONRA | üçgen farkı (en kötü) |
|---|---|---|---|---|---|
| ucus60_otag | 747 / 1,49 M | 751 / 1,50 M | 582 / 1,14 M | 586 / 1,15 M | +%0,9 |
| yer_otag | 601 / 1,27 M | 605 / 1,27 M | 456 / 0,99 M | 460 / 0,99 M | %0 |
| ucus60_sahi_top | 321 / 0,57 M | 323 / 0,57 M | 245 / 0,47 M | 247 / 0,47 M | %0 |
| yer_sahi_top | 116 / 0,29 M | 116 / 0,28 M | 104 / 0,34 M | 104 / 0,33 M | −%3 |
| ucus60_anadolu_4_1 | 380 / 0,62 M | 381 / 0,64 M | 332 / 0,56 M | 332 / 0,57 M | +%3,2 |
| yer_anadolu_4_1 | 348 / 0,87 M | 348 / 0,88 M | 334 / 0,87 M | 334 / 0,88 M | +%1,1 |
| ucus60_rumeli_3_1 | 1 047 / 2,93 M | 1 046 / 3,01 M | 985 / 2,81 M | 1 023 / 2,90 M | +%3,2 |
| ucus60_batarya_02 | 166 / 0,33 M | 167 / 0,33 M | 145 / 0,31 M | 146 / 0,31 M | %0 |
| ucus60_yeniceri_2_1 | 660 / 1,44 M | 662 / 1,45 M | 623 / 1,35 M | 625 / 1,37 M | +%1,5 |

- Üçgen: her noktada ≤ +%3,2 (sınır +%8): TAMAM.
- Çizim: +0…+4 (ahşap Bld'li bataryalarda canlının ayrı ağı); tam akışta `ucus60_rumeli_3_1` +38 (kısa akışta −1:
  akış/yükleme sırası farkı, aynı noktada iki akış çelişiyor). "Çizim artmaz" tam tutmadı: KISMEN. ORTAK DOSYA
  ÖNERİSİ (ORDUGÂH-4): `ordugah_yapi.gd:build_batarya` (s. 319–320), `build_sahi_top` (s. 458),
  `ordugah_cephe.gd` (s. 166) öküzleri ahşap Bld yerine desensiz Bld'ye versin (ayrı ağ kalkar, çizim 0):

```gdscript
var okz := B.new("")              # öküzler için desensiz Bld (canlı ahşap dokusu almasın, ayrı ağ kurulmasın)
_okuz(okz, Vector3(-W * 0.25 + 2.7, 0, -D / 2.0 - 8.5), 90.0, r)
_okuz(okz, Vector3(-W * 0.25 + 2.7, 0, -D / 2.0 - 10.5), 90.0, r)
okz.done(host, "okuz")
```

- Karedeki TOPLAM çizim (`yer_sahi` 892 → 948, `yer_at_bagi` 1 128 → 1 139) karşılaştırılamaz: ÖNCE kopyası
  `wip/ist2-doku4` birleşmesinden önceki kayıt (`e106a7e1`); fark ordugâhın dışında (ordugâh payı yukarıda eşit).
  Şehrin yakın hayvanları 6 ağa pişirildikten sonra da toplam aynı kaldı: fark birleşen dallardan. KANITSIZ (birleşik
  taban ayrıca ölçülmedi).
- **28o** (`RINFO=1 PACE=1 … --chapter=28o --autotest --hitchaudit`, ÖNCE ve SONRA aynı akış; 2 sn'lik örnekler,
  aynı sahne anında; geçiş anlarındaki tek örnekli sıçramalar dışında):

  | an (sahne sn) | ÖNCE çizim / üçgen | SONRA çizim / üçgen | fark |
  |---|---|---|---|
  | t = 9 | 2 900 / 3 456 k | 2 904 / 3 462 k | +4 / +%0,2 |
  | t = 19 | 2 375 / 2 675 k | 2 385 / 2 682 k | +10 / +%0,3 |
  | t = 44 | 2 429 / 2 803 k | 2 441 / 2 766 k | +12 / −%1,3 |
  | t = 57 | 2 260 / 2 647 k | 2 273 / 2 630 k | +13 / −%0,6 |

  Üçgen: TAMAM (≤ +%0,6). Çizim +4…+13 (≈ +%0,5): Ox sınıfının parçaları (gövde ağı + boyun/baş/bacak pişmiş ağları,
  dış hat geçişi) eski pişmiş kutulardan birkaç fazla: "çizim artmaz" tam tutmadı: KISMEN. Not: `HitchAudit` RINFO
  örneklerini sahnenin ilk ~73 sn'sinde verdi (çekme anı 190. sn civarında; o anın RINFO'su yok: KANITSIZ).
  Uzak sürü (56 öküz) kutu ~126 üçgen → kit orta ~280 üçgen/öküz: +8,6 k üçgen, görünürken.

## 8. Testler

- Ayrıştırma: `PARSECHECK PASS scripts=336`.
- Başsız (her biri `AUTOTEST PASS`, yasak satır sayıldı):
  - 1. grup (102): 2 (7), 10 (7), 16 (3), 26 (14), 28o (4), 35o (2), 7 (10), 11 (10), 6 (10), 8y (7), 34o (2),
    36b (2), 10a (2), 10b (6), 32o (7), 4 (9): 102 PASS; yasak 0, bir istisna: `26 warn_notrust` bir koşuda
    `VISAUDIT overlap Squad>Person|Squad>Person` (iki asker üst üste). Aynı varyant yeniden koşunca 0, ÖNCE
    kopyasında 0 → rastlantısal, hayvanla ilgisi yok (kişi çakışması).
  - 2. grup (55): 15 (32), 3 (6), 17o (4), 9 ve 8y kalanlar: 55 PASS, yasak 0.
  - Ara koşular: 12 anahtar (28o, 35o, 2, 10, 6, 8y, 11, 16, 7, 26) + 28o dört varyant + 16 üç varyant: PASS 0.
  - SON KODLA (bütün değişikliklerden sonra, `OZET6`): 28o (4 varyant), 35o (2), 2 (2), 10 (2), 6 (2), 8y (2),
    16 (2), 11, 7, 9, 15, 3, 26: 22/22 PASS, yasak 0. Ekranlı 28o (SONRA, son kod): PASS.
  - Toplam 198 başsız koşu; 197 temiz, 1 rastlantısal (yukarıda).
- Bakamadıklarım: 1. ve 2. gruptan sonraki değişiklikler (ordugâh Bld kuralı, göz kesimi, halka çerçevesi sürekliliği,
  şehir yakın hayvan birleştirme, 28o sürü, 16 kedisi, at göğüslüğü) son kodla yalnız 22 koşuluk listeyle sınandı;
  157 varyantın hepsi son kodla yeniden koşmadı.

## 9. Paftalar (`docs/_kanit_canli/`, hepsi ÖNCE | SONRA; JPEG ≤ 300 KB)

| dosya | içerik |
|---|---|
| `pafta_01_ordugah_sahi_once_sonra.jpg` | sahibinin karesinin aynı kamerası (`yer_sahi`), Şahi öküzleri 6 m, 60 m |
| `pafta_02_ordugah_at_agil_oba_once_sonra.jpg` | at bağı (yer + 6 m), ağıl (koyun, öküz), oba (köpek) |
| `pafta_03_bolum28o_okuzler_once_sonra.jpg` | Bölüm 28o çekme anı (`D28O_U_HAUL`), tam kare + 3× kırpık |
| `sonda_01_okuz_once_sonra.jpg` | ordugâh öküzü: 5 m yan, çapraz, ön, 60 m (kırpık), sürü |
| `sonda_02_at_once_sonra.jpg` | ordugâh atı |
| `sonda_03_deve_once_sonra.jpg` | ayakta deve + çökmüş deve sürüsü |
| `sonda_04_koyun_agil_once_sonra.jpg` | ağıl (koyun, öküz, köpek, çoban) |
| `sonda_05_sinif_okuz_at_once_sonra.jpg` | oyunun `Ox` ve `Horse` sınıfları |
| `sonda_06_keci_tavuk_once_sonra.jpg` | `Goat`, `Chicken` |
| `sonda_07_kedi_marti_once_sonra.jpg` | `Cat`, `ThiefGull` (ÖNCE'de bunlar zaten küreydi: fark küçük) |
| `sonda_08_esek_kopek_once_sonra.jpg` | şehrin yakın eşeği (`IstHayatGovde.animal`), ordugâh köpeği |

Sonda sahnesi: `tests/_canli/sonda_kare.tscn` (nötr zemin, oyunun API'siyle kurar; ÖNCE kopyasında aynı betik).
Ordugâh: `tests/_canli/ordu_kare.tscn` (ORDUGÂH-4 sondasından miras, aynı kamera hesabı). Üçgen sayacı:
`tests/_canli/sonda_kit.gd`.

SAHİBİNE GÖSTERİLECEK KARELER: `pafta_01` (üst satır: aynı kamera, kutu öküz → gerçek öküz), `pafta_02` (at bağı ve
ağıl), `sonda_01` (öküz yakın üç bakış), `sonda_03` (deve), `sonda_05` (sınıf öküz ve at), `sonda_06` (keçi, tavuk),
`pafta_03` (28o, uzakta), `sonda_04` (koyun sürüsü).

## 10. Bakamadıklarım

- Ordugâh hayvanlarında baş/kuyruk/kulak oynaması (durağan ağ): YAPILMADI (duruş çeşitliliği var).
- Bölüm 2 kızak öküzü, 10 devesi, 16 kedisi, 6 martısı, keçi (8y) ve kedi (Galata) için oyun içi kare: BAKILMADI
  (sonda kareleri var).
- Şehrin MultiMesh sürüsü ve uçan kuşları: kare yok (BAKILMADI).
- Gece karesi: BAKILMADI.
- `tests/_canli/` sondaları kalıcı test aracıdır (oyun koduna kanca değil); oyun kodunda kanca yok
  (`grep -rn "canli" scripts` yalnız kit çağrıları).
