# TAŞIMA-3 — Bölüm 20 kalanları (=late, barikat görünüşü), Bölüm 21 depo, Bölüm 0 ve 25 (Bizans yarısı) yeni surda

> Dal `wip/ist2-tasima3`, taban `wip/ist2-birlesik` ee2ee089. Makine: 4 çekirdek; ekransız testler `--max-fps 20`, kareler
> xvfb + Mesa llvmpipe (yazılımsal GL), 1280×720 jpg 85. Ham çıktılar `testler/` (`*.ham` tam günlük, süzülmüş dosya yanında),
> kareler `kare/`. Bölüm 20'nin ÖNCE kareleri ve bütçesi tabanın `git archive` kopyasında (aynı içe aktarma önbelleği); o
> kopyaya yalnız ölçüm eki kondu: `=kare` akışına aşama 3 karesi, `=butce`'ye `--butce_onarim=N` (bu dalda da aynısı var).
> Bölüm 0 ve 25'in ESKİ kareleri bu dalda `--eskisur` ile (eski yol kodda birebir aynı). Süzgeç her dosyada tam:
> `AUTOTEST (PASS|FAIL)|SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|WARN_FLY|WARN_VOID`.
> Dokunulmayanlar: A'nın ve B'nin dosyaları (A'nın yardımcıları — `KULE.Ag`, `KalasKopru._dikme`, `IstSurlarAyrinti._barrel` —
> yalnız ÇAĞRILDI, değiştirilmedi), `scripts/npc/`, `scripts/ui/`, `byz_city.gd`, `sur_sozlesme*`, `tests/run_tests.sh`,
> `project.godot`, `game_state.gd`; replik metni, ses, denge, süre, sayaç, dalga sınırı, düşman sayısı.

## Özet

| # | Madde | Durum | Kısa |
|---|---|---|---|
| 1 | Bölüm 20 `=late` düellocu toprak setin içinde | **TAMAM** | kök neden günlükle bulundu: **dost** düellocu (ve cesetler) aşama 2'nin açık molozunda dururken şafakta sayaç 5 → 10 sıçrıyor, aşama 4'ün toprak seti onların üstüne kuruluyor; `dismiss_idle` kutudan SONRA çağrılıyordu. `=late` ×20 + `=lose` ×5 + 20 bütün çeşitler ×2 + 20o ×1: PASS, denetim 0 |
| 2 | Gedik barikatının görünüşü | **TAMAM** (çuval: vasat-iyi) | toprak yığını + çuval + taş + kazık + kütük; düzensiz sivri kazık çit, iple bağlı; sur yolu tahtası dikmesiz köprü kirişi; çarpışmalar aynı; bütçe ±%1 |
| 3 | Bölüm 21 kap yeri kalabalık | **TAMAM** | depo yığınları YALNIZ 21'de 7 m sola (`SurSetSahne.depo_kaydir`); lağım ve kaplar aynı; en yakın yığın lağıma 1,3 → 4,6 m |
| 4a | Bölüm 0 taşıması | **TAMAM** | `SurSet` + `--eskisur`; yeni ×2 / eski ×1 PASS, denetim 0; bot takılma 0, düşme 0; engel 14/14 dışarıda; 6 kare çifti; bütçe −%14…−%38 çizim |
| 4b | Bölüm 25 (Bizans yarısı) | **TAMAM** | `byz_city.gd`'ye dokunmadan: sur gecesi evresi `SurSetSahne`'de, ayin aynı; Bizans çeşitleri yeni ×2 / eski ×1, Osmanlı yarısı yeni/eski ×1 PASS, denetim 0; bot iki sette 3 bacak, takılma 0 |
| — | Sözleşme | **TAMAM** | `SURSOZLESME PASS kalem=13 kesim=8` · `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` · `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` (`testler/son/sozlesme_*`, taban `testler/once_sozlesme_*`) |

## 1. Bölüm 20 `=late`: düellocu toprak setin içinde

### Kök neden (günlük: `testler/sonda/late_r*.ham`, `SONDA20` satırları; sonda kodu kayda girmedi)
Geçici sonda şafak kesmesinde her `Duelist`'i yazdı (takım, durum, hedef, görünürlük, geri çekilme, silinme kuyruğu, yer):
`once_set` (barikat tamamlanmadan), `sonra_set` (`walls.set_repair(10)` hemen sonra), `dismiss` (`Duelist.dismiss_idle`'dan sonra).
Satırı veren koşu (`late_r4`):

```
WAVERUNNER wave=2/2 won=true t=9.1 … allies=4+0
SONDA20 an=sonra_set … team=0 state=IDLE target=false vis=true withdrawn=false qdel=false at=(-3.1, 0.5, 12.0)
SONDA20 an=dismiss   … team=0 state=IDLE target=false vis=true withdrawn=false qdel=true  at=(-3.1, 0.5, 12.0)
VISAUDIT insolid scene=chapter20.tscn who=Duelist at=(-3.1, 0.5, 12.0) by=Asama size=(8.4, 1.4, 1.2)@(0.0, 1.5, 12.6) … Toprak_GedikSet_Carp
```

- **Hangi an:** aşama değişirken. `=late`'te bot 5 yük getirir (aşama 2: açık moloz, ortada geçit), hücum ve iki dalga o
  aşamada oynanır; gece bitince `_dawn` sayaç 5 → 10 yapar (aşama 4) ve toprak setin kutusu (z 12,0–13,2) **o anda** kurulur.
  Kimse içine yürümüyor; kutu kişinin üstüne kuruluyor.
- **Hangi düellocu:** dalgaya yardıma gelen **dost** (team 0, IDLE, hedefsiz: dövüşten sonra "nefeslenip kalan"); ayrıca
  **ölü düşmanlar** (team 1, DEAD; denetim cesedi saymaz ama karede setin içinde yatıyorlar).
- **Neden şimdiye dek seyrek:** denetim yarım saniyede bir, en çok 40 kişiyi tarar; dost aynı karede `dismiss_idle` ile
  kuyruğa alınıyordu (kutu ONDAN önce kuruluyordu). 12 sondalı koşuda kutunun içinde kalan: **9/12** (5'inde dost, 7'sinde
  ceset; `testler/sonda_say.py` tablosu, `testler/sonda/`), denetimin yakaladığı 1/12 (yöneticinin oranı 2/11).
- Oyunda da aynı: hücumdan sonra getirilen yük aşamayı 2 → 3 yaparsa set, gedikte nefeslenen dostun üstüne kurulur.

### Düzeltme
- `SurSetSahne.set_repair` → aşama YÜKSELİNCE `_kutudan_cikar()`: `GedikOnarim.kati_kutular()` (aşamanın görünen katı
  kutuları: toprak set, kazık çit) içinde duran her düellocuyu (dost, düşman, ceset) kutunun şehir yanında en yakın boş,
  zemini olan yere alır (`Unclip.floor_y / in_solid / crowded`). Testte `GEDIKBOSALT asama=… tasindi=…` yazar.
- `chapter20._dawn` (yalnız yeni set): dost düellocular kararma kesmesinde barikat tamamlanmadan ÖNCE çekilir, bir kare
  beklenir (queue_free kare sonunda siler), sonra sayaç 10 olur. Eski yol aynı.
- Susturma, eşik, muafiyet yok; denetim koduna dokunulmadı.

### Ölçüm (`testler/sonda_sonra/` ×12 sondalı; `testler/son/` son kod)
- Sondalı ×12: kutunun içinde kalan **0/12** (önce 9/12); taşınanlar yalnız cesetler (dostlar önceden çekildi).
- `=late` ×20: **20/20 PASS, denetim 0**; `GEDIKBOSALT` 8 koşuda (1–3 ceset taşındı).
- `=lose` ×5: 5/5 PASS, denetim 0.
- Bölüm 20 bütün çeşitler ×2 (def, tape, hit, niko_idle, idle, `--difficulty=0/2`; late/lose yukarıda): 14/14 PASS, denetim 0.
- 20o bütün çeşitler ×1: 10/10 PASS, denetim 0. Bölüm 21 bütün çeşitler ×1: 6/6 PASS, denetim 0.
- Dalga süreleri değişmedi (`WAVERUNNER t=`): `=late` önce (sonda) 1. 5,1 [3,9–5,8] / 2. 9,9 [6,3–13,3] ↔ son ×20 1. 4,4
  [3,6–5,6] / 2. 8,6 [5,1–11,4]; öteki çeşitler 1. 3,7 [2,9–7,2] / 2. 8,4 [7,4–13,4]; 20o 1. 12,2 [4,3–13,8] / 2. 13,6 [7,7–20,3].

AUTOTEST alanları (son ×2; tabloyu `testler/tablo.py` üretti, ham `testler/son/`):

| çeşit | outcome | repair | knocks | arrows | gun | gunner | niko |
|---|---|---|---|---|---|---|---|
| def | 20.1 / 20.1 | 10 / 10 | 0 / 0 | true / true | 3/4 | 2/2 / 2/2 | 0 |
| tape | 20.2 / 20.2 | 10 | 0 | true | 3/4 | 2/2 / 2/2 | 0 |
| hit | 20.1 / 20.1 | 10 | 1 / 1 | true | 3/4 | 2/2 / 2/2 | 0 |
| idle | 20.3 / 20.3 | 10 | 0 | true | 3/4 | 2/2 / 2/2 | 0 |
| niko_idle | 20.1 / 20.1 | 10 | 0 | true | 3/4 | 2/2 / 2/2 | 5 / 5 |
| late (×20) | 20.3 ×20 | 10 | 0 | false | 3/4 | 2/2 ×20 | 0 |
| lose (×5) | 20.3 ×5 | 10 | 0 | true | 3/4 | 0/2, 0/2, 0/1, 0/1, 2/2 | 0 |

(def satırındaki iki `--difficulty` koşusu da 20.1, alanlar aynı.)

## 2. Gedik barikatının görünüşü (`GedikOnarim`, `sur_oyun_parca.gd`)

Kendi özel işlevlerim: `_toprak_yigin` (yumrulu, lekeli toprak yığını ağı), `_yigin_y`, `_kazik` (yuvarlak kesitli, sivri
uçlu kazık), `_cubuk` (yuvarlak kütük/ip). A'nın yardımcıları çağrıldı, değiştirilmedi.

- **Aşama 3–4 toprak seti:** pürüzsüz `Props.ball` hap yerine moloz profilinin üstünde yumrulu toprak yığını (sırtı 1,1 m,
  tepesi eski hapınkiyle aynı ≈2,1 m), sırtında ve fıçıların ardında kum çuvalları (yuvarlak, yassı, farklı eğimde; kutu
  değil), eteğinde 22 yarı gömülü taş, yığına çakılı 7 eğik kazık ve 2 yatık kütük. Çarpışma kutusu aynı yerde, aynı boyda
  (8,4 × 1,4 × 1,2 @ zs).
- **Aşama 4 kazık çiti:** kazıklar yuvarlak, sivri uçlu; boyları 1,75–2,3 m (yüzde 12'si kısa/kırık 1,2–1,5), aralıklar
  0,27–0,4 m, ovaya ve yer yer yana eğik; iki kuşak sarkık iple bağlı (kalas kuşak yok). Çarpışma aynı (8 × 2,4 × 0,4).
- **Sur yolu tahtası:** molozdan 7 m yükselen altı dikme kalktı; iki kırık sur ucuna gömülü iki boyuna kiriş, üstünde enine
  düzensiz genişlikte tahtalar, uçlarda kısa çapraz payandalar (köprü gibi). Yürüme çarpışması aynı.
- İlk turdaki kusurlar (kare `kare/c20_ara1`): çuvallar soluk, yassı "tabak" gibi; yığın fıçıların ardında görünmüyordu; çit
  neredeyse siyahtı; ortadaki dikme gökyüzüne karşı iskele gibi duruyordu → ikinci turda düzeltildi.

### Kareler (oyuncu kamerası; `kare/c20_once` ÖNCE ↔ `kare/c20_sonra` SONRA, aynı adlar)

| an | SONRA tek cümle | hüküm |
|---|---|---|
| `an_04_onarim_asama2` | fıçı sırası (ortada geçit) ve eğik kazıklar, işçiler; aşama 2 değişmedi (iki kare aynı) | aynı |
| `an_06_onarim_asama3` | fıçıların ardında yığının sırtı boyunca koyu kahverengi çuvallar ve yığından çıkan kazıklar; ÖNCE'de pürüzsüz kahverengi hap. Kutu yok, havada yok, moloza oturuyor, toprak/ahşap sur ile aynı elden | iyi (çuvallar hâlâ biraz yassı somun gibi: vasat-iyi) |
| `an_07_onarim_asama4` | aynı yığın + çuvallar, üstte sur yolu kirişi; havada duran yok | iyi |
| `an_08_cit_sehir_tarafindan` | açık renkli, düzensiz boylu, sivri, yer yer eğik kazıklar, iki sarkık ip kuşak; ÖNCE'de eşit düz tahtalar ve iki kalas ("bahçe çiti"). Zemine oturuyor; üstte dikmesiz köprü kirişi (ÖNCE: altı dikmeli koyu iskele) | iyi |
| `an_12_duello` | azap barikatın ardında, çuvallar ve kazıklar arasında; ÖNCE'de hapın üstünde | kabul (kalabalık; azapların gövdesi çarpışmasız yığının içinden geçiyor — eski hapta da aynı, çarpışma kutusu aynı kalmalıydı) |

### Bütçe (Bölüm 20 `=butce --butce_onarim=7|10`, aynı kameralar, 10 kare ortalaması; `testler/butce/`)

| bakış (aşama) | ÖNCE çizim | SONRA çizim | ÖNCE ilkel | SONRA ilkel |
|---|---|---|---|---|
| peribolos (3) | 3.540 | 3.546 (+%0,2) | 6,141 M | 6,154 M (+%0,2) |
| gedik ağzı (3) | 4.344 | 4.350 (+%0,1) | 8,160 M | 8,151 M (−%0,1) |
| sur yolu (3) | 4.249 | 4.238 (−%0,3) | 5,181 M | 5,169 M (−%0,2) |
| hava (3) | 9.973 | 9.907 (−%0,7) | 8,234 M | 8,203 M (−%0,4) |
| peribolos (4) | 3.542 | 3.546 (+%0,1) | 6,141 M | 6,153 M (+%0,2) |
| gedik ağzı (4) | 4.349 | 4.345 (−%0,1) | 8,152 M | 8,177 M (+%0,3) |

(Aşama 4'ün sur yolu/hava bakışları ÖNCE koşusunda 900 sn sınırına takıldı; SONRA sur yolu (4) 4.284 / 5,23 M.) Yeni parçalar
`PARCA_.pis` ile aşamanın tek ağına pişiyor: çizim çağrısı değişmedi.

## 3. Bölüm 21 kap yeri

- `SurSetSahne.depo_kaydir` (varsayılan sıfır: 20/20o aynı); `chapter21.gd` `DEPO_KAYDIR_21 = (−7; 0; 0)` verir. Lağım
  (`MINE (−9; 0; 7)`), kaplar ve sıcak/soğuk dağılımı aynı; 21 depoyu kullanmaz (yük yok).
- En yakın yığın lağıma: önce küçük fıçılar 1,3 m, kalas yığını 2,4 m → sonra kalas yığınının ucu 4,6 m, küçük fıçılar 7 m.
- Yeni yığın noktaları engel dışında (`testler/c0/engel_tarama.txt`: `depo21 (−18,5; 4,2) engelde=false`; ayrıca
  `TASIMA21ENGEL OZET nokta=12 engelde=0`, depo noktası eklendi).
- 21 bütün çeşitler ×1 PASS, alanlar taşıma 2 ile aynı (def 21.1 bowls 2; grant 21.2 bowls 4; fight iron trust 0; thermos/ear
  bowls 5; captive → chapter22o). 20 ve 20o'nun depo karesi değişmedi (`kare/c20_*/an_02_depo` aynı).
- Kare: bu oturumda 21 için `=kare` koşulmadı (yazılımsal GL süresi Bölüm 0/25'e ayrıldı) — **an_03 SONRA karesi yok**.
  Sonraki tur `-- --chapter=21 --autotest=kare --dialogshots=…` ile bakmalı.

## 4a. Bölüm 0 (soğuk açılış) — taşıma

### Bağdaştırıcı (`scripts/chapter0.gd`)
- `ESKI_SUR`, `sur = SurSet.sec("0", ESKI_SUR)`; yeni sette `SurSetSahne` (`assault_mode`, `set_repair(8)` → aşama 3).
  `--eskisur` / `--eskisur=0` eski seti seçer; eski yolun bütün sayıları aynen (değişkenlere eski sabitler atanır).
- `Assault.sur`, `keep` ova kaydırmasıyla; `Garrison.land_walls(…, sur)`; `WallFight.sur`, kazanlar `sur.dis_yol_y/z`,
  taşıyıcılar depodan gedik önünün 0,4 m gerisine, işçiler barikatın dibinde (Bölüm 20'nin yeni yerleşimi, iş başındaki
  işçi `no_yield`); `SiegeChaos.area = sur.peribolos()`, engel çemberleri, siperler, taşıyıcı şeridi ve patlama yeri `avoid`.
- Yeni yerler (bölüm çerçevesi): START (−8,6; 4,4) — eski (7; 4) yeni sette **iç kulenin içinde** (`engelde=true`,
  `testler/c0/engel_eski_noktalar_yeni_sette.txt`); LINE (−0,6; 10,6) (toprak set kutusu z 12,0'da başlar); Giustiniani
  (−4,6; 11); altı savunucu işçilerin önünde/arasında, taşıyıcı varış yerini açık bırakarak (`no_yield`); yedek bölük
  (−20; 7,6); BattleExtras şeritleri peribolos içinde (z 3,4 / 9,8), eskinin ok yolu yanındaki 4 yaralısı sol sur boyu şeride
  katıldı (yeni START ile iç kule arasında yer yok; ilk karede kutu biçimli enkazla kameranın dibindeydiler).
- Donan kare **aynalı** (`_ayna = −1`): STAGE (−3; 8,6), kamera +4,2 x'te, patlama −5,8 x'te; eski kadrajda sağdaki iç kule
  kareyi kapatırdı.
- Engel taraması (`TASIMA0ENGEL OZET nokta=14 engelde=0`; `tests/_ist/tasima2_engel.gd` ile ayrıca 16 nokta, hepsi dışarıda).
- İlk denemede `VISAUDIT overlap … SPK_DEFENDER … WallFight{hammer}` (savunucu x −2,3 işçinin üstündeydi) → savunucu yerleri
  işçilere ≥ 1,1 m (`testler/c0/ara_*`). Son koşularda 0.
- `AUTOTEST` satırına `sur=eski|yeni`; yeni kipler `=yuru`, `=kare`.

### Testler (`testler/son/c0_*`): yeni ×2, eski ×1 — 3/3 `AUTOTEST PASS … froze=true`, denetim 0
Kurulum (`TASIMA0KURULUM`): eski 6.153–6.554 ms (set 4.934–5.152) ↔ yeni 4.912–5.034 ms (set 3.321–3.440). Oyunun ilk dakikası
≈ 1,3 sn daha erken açılıyor.

### Gerçek bot (`=yuru`, gerçek `Player`, ileri tuşu; `testler/yuru/c0_*`)

| bacak | eski sn / m | yeni sn / m |
|---|---|---|
| START → savunucu sırası (LINE'a 3 m: teslim) | 3,6 / 8,2 | 2,5 / 7,2 |
| özet | takılma 0, düşme 0, teslim tamam | takılma 0, düşme 0, teslim tamam |

(Eskide kalabalığın arasından geçiş yavaşlatıyor: 2,3 m/sn ↔ 2,9 m/sn.)

### Mesafe tablosu (yatay; hedef ≤ 20 m)

| çift | eski m | yeni m |
|---|---|---|
| START → LINE | 10,6 | 10,1 |
| START → depo | 4,4 | 2,9 |
| LINE → gedik | 3,7 | 4,7 |
| LINE → Giustiniani | 3,7 | 4,0 |
| START → donma yeri (STAGE) | 6,1 | 7,0 |
| STAGE → patlama | 5,9 | 5,9 |

### Yön söyleyen replikler (metne dokunulmadı)

| anahtar | metin | yeni sette |
|---|---|---|
| `D0_G_ARROWS` | "…demetleri gediğe, koş!" | doğru (LINE gediğin önü) |
| `UI_OBJ0_ARROWS` | "Ok demetlerini gedikteki okçulara götür" | doğru |
| `D26_L_WAVE_1` | "…Merdivenleri sura dayıyorlar!" | doğru (Assault merdivenleri dayama kuralıyla) |
| `UI_CH0_PLACE` | "…Konstantinopolis, kara surları" | doğru |
| `D20_L_WARN_2`, `D0_S_ARROWS`, `D0_T_FREEZE_*`, `D0_N_FREEZE` | yön yok | — |

### Kareler (`kare/c0_eski` ↔ `kare/c0_yeni`; 4 kare ortalaması bütçe, `testler/kare_c0_*.log`)

| an | YENİ tek cümle | hüküm | çizim eski → yeni | ilkel eski → yeni |
|---|---|---|---|---|
| `an_01_acilis` | yer yazısı, hedef; ileride gedik, barikatın çuvalları, savunucular, meşale ve siper, solda dış sur; kutu yok, havada yok | iyi (eskisi daha kalabalık ve destansı: sur yolunda merdiven, koşan kalabalık) | 11.409 → 7.030 | 13,9 M → 9,1 M |
| `an_02_kosu_orta` | savunucular ve taşıyıcılar, ardında barikat; solda peribolos boyunca kalabalık | iyi | 10.181 → 6.399 | 13,3 M → 8,8 M |
| `an_03_teslim_savunucular` | savunucu sırası yakın, bir taşıyıcı fıçıyla önden geçiyor, ardında çuval yığını | vasat (kalabalık, kadraj dolu) | 9.114 → 6.838 | 13,1 M → 10,6 M |
| `an_04_sabit_bakis` (aynı kamera) | kameranın dibinde bir savunucunun kaskı kadrajın yarısını kapatıyor | **kötü kadraj** (bütçe için sabit kamera; oyunda kimse oraya bakmaz) | 9.344 → 7.054 (−%25) | 11,1 M → 9,5 M (−%14) |
| `an_05_gun` | gözcü bağırışı, gediğin içinden gökyüzüne; çuvallar, fıçılar, kazıklar, gedikte bir azap; iki yanda sur | iyi | 8.142 → 5.080 | 11,0 M → 8,4 M |
| `an_06_donma` | havada Tolga, arkasında patlama, savrulan oklar ve kalkan; solda savrulan askerler, sağda iç kulenin karanlık duvarı, yerde kalas yığını | vasat (eskisi daha dolu: yerde yaralılar, merdiven; yenisi boş ve kalas yığını kutumsu duruyor) | 4.363 → 4.643 | 8,1 M → 6,8 M |

## 4b. Bölüm 25 (Bizans yarısı) — taşıma

### Bağdaştırıcı (`scripts/chapter25.gd`) — `byz_city.gd`'ye dokunmadan
- Bizans yarısının sur gecesi evresi ayrı bir `LandWalls` kurar, ayinden önce kaldırır; ayin `ByzCity` ile ayrı kurulur. Bu
  yüzden taşıma yalnız sur evresinde: `sur = SurSet.sec("25", ESKI_SUR)`, `SurSetSahne` (aşama 4), `Garrison.land_walls(…, sur)`.
- Ordugâhın kandilleri ve ateşleri `sur.ova_ofs()` kaydırmalı bir düğümde (kaydırmasız yeni ovanın 3,5 m üstünde havada
  dururlardı); tespit hedefi ve oyuncunun bakışı da kaydırmalı.
- Oyuncu ve nöbetçi dış sur yolunda (y 8,62, z 15,3), x −9,2 / −7,4'e **en yakın dış mazgal açıklığında** (`_mazgal_x`):
  ilk turda oyuncu bir dişin tam karşısındaydı, ordugâh yalnız yandaki açıklıktan görünüyordu (`kare/c25_yeni_tur1/an_01`).
- Osmanlı yarısı (`osm*`) koşulur, kodu aynı (`sur=-`).

### Testler (`testler/son/c25_*`)
Bizans çeşitleri (def, caught, pass, kid, cistern, cistern_blab) yeni ×2 (mazgal düzeltmesinden sonra; ilk tur
`testler/son/c25_tur1/` de 12/12 PASS) + eski ×1; Osmanlı (osm, osm_caught, osm_tez) yeni ×1 + `--eskisur` ×1: **27/27 PASS,
denetim 0**. Alanlar eski ↔ yeni aynı:
def 25.1, caught 25.2, pass 25.1, kid 25.1 marco=true, cistern/cistern_blab 25.1, osm 25.1, osm_caught 25.2 caught=2,
osm_tez 25.1 tezkire=true.

### Gerçek bot (`=yuru`; `testler/yuru/c25_*`)

| bacak | eski sn / m | yeni sn / m |
|---|---|---|
| başlangıç → nöbetçinin yanı | 0,2 / 0,5 | 0,2 / 0,5 |
| nöbetçi → sur yolu boyunca 12 m | 4,1 / 12,4 | 3,9 / 12,2 |
| geri başlangıca | 3,7 / 11,4 | 3,6 / 11,2 |
| özet | 8,0 sn / 24,3 m, takılma 0, düşme 0 | 7,6 sn / 23,8 m, takılma 0, düşme 0 |

(Yeni başlangıç x −8,7, nöbetçi −6,9: en yakın mazgal açıklıkları.)

### Mesafe tablosu

| çift | eski m | yeni m |
|---|---|---|
| oyuncu → nöbetçi | 1,8 | 1,8 (iki komşu mazgal) |
| oyuncu → gedik | 9,2 | 8,7 |
| oyuncu → tespit hedefi (ordugâh) | 315 | 326 (ova +10,6) |

### Yön söyleyen replikler
`UI_CH25B_WALL` "27 Mayıs, gece · Mesoteichion, dış sur": doğru (kesim Mesoteikhion, oyuncu dış sur yolunda). `D25B_*`,
`UI_OBJ25B_PHOTO`: yön yok.

### Kareler (`kare/c25_eski` ↔ `kare/c25_yeni`)
Bütçe 4 kare ortalaması (`testler/kare_c25_*.log`). İlk tur YENİ karesi `kare/c25_yeni_tur1` (an_01'de oyuncu dişin
karşısındaydı: **kötü**, düzeltildi).

| an | YENİ tek cümle | hüküm | çizim eski → yeni | ilkel eski → yeni |
|---|---|---|---|---|
| `an_01_acilis_ordugah` | iki dişin arasındaki açıklıktan ovada ışıklı çadırlar ve alevler, turuncu ufuk; dişler A'nın sur görünüşü | kabul (eskisi alçak korkulukla geniş manzara; yeni dar ama ordugâh kadrajın ortasında) | 4.289 → 3.792 | 6,4 M → 5,8 M |
| `an_02_nobetci` | iki nöbetçi sur yolunda, ardında kule, ufukta turuncu ışık; havada yok | iyi | 3.530 → 2.134 | 4,2 M → 3,3 M |
| `an_03_tespit_ordugah` | ova, çadırlar, kandiller ve alevler ovaya oturuyor (kaydırma doğru), turuncu ufuk | iyi | 3.886 → 3.804 | 5,6 M → 5,8 M |
| `an_04_sur_yolu_boyunca` | tahta kaplı sur yolu, ilerde kule ve nöbetçi, sağda ordugâh | iyi | 2.087 → 2.088 | 3,8 M → 3,3 M |
| `an_05_peribolos_asagi` | yüksek iç korkuluk kadrajı dolduruyor, peribolos görünmüyor | vasat (kadraj) | 1.688 → 584 | 1,5 M → 0,7 M |
| `an_06_gedik_sur_yolundan` | solda sur yolu kenarında büyük köşeli dekor fıçıları, ilerde nöbetçiler | vasat (A'nın dekoru) | 3.488 → 1.935 | 4,1 M → 3,1 M |

## Öteki bölümler
Kanca eklenen yardımcılar: `SurSetSahne` (`_kutudan_cikar`, `depo_kaydir`) ve `GedikOnarim` (görünüş, `kati_kutular`). Bunları
kullananlar 0, 20, 20o, 21, 25 (Bizans): hepsi yukarıda koşuldu. `Assault`, `Garrison`, `WallFight`, `Duelist` değişmedi.

## run_tests.sh isteği
Yeni çeşitler (`--chapter=0 --autotest=yuru|kare`, `--chapter=25 --autotest=yuru|kare`, `--chapter=20 --autotest=butce
--butce_onarim=N`) `tests/run_tests.sh`'e eklenmedi. İstek: `run --chapter=0 --autotest=yuru` ve `run --chapter=25 --autotest=yuru`
(ekransız, ~70 sn); `=kare`/`=butce` ekranlı, pakete girmemeli.

## Sonraki taşıyana
1. **Aşama değişimi = yeni katı.** `GedikOnarim` aşama yükselince kutu kurar; içinde duranları `SurSetSahne._kutudan_cikar`
   alır. Kendi bölümünde başka bir anda katı kuruyorsan (kapı, dolgu) aynısını yap; denetim yalnız bir kısmını yakalar —
   sondayla say (bu oturumda 9/12 koşuda kutuda biri vardı, denetim 1'ini gördü).
2. **Dekor yerleşiminde eski sabitleri yeni sete karşı tara**: `tests/_ist/tasima2_engel.gd -- --nokta=…`. Yeni sette gediğin
   sağı iç kule (x −2,8…12,2, z ≤ 8), gedik önünde toprak set kutusu z 12,0–13,2 (aşama ≥ 3), işçiler x ±2,4 z 11,3,
   taşıyıcı varışı (0; 10,4).
3. **Yeni dış surun dişleri insan boyu:** sur yolundan ovaya bakan her kare/tespit için oyuncuyu mazgal açıklığına koy
   (`SurSet.a.mazgallar("dis")`, x + `ofs.x`; Bölüm 25 `_mazgal_x`).
4. **Ova kaydırması:** ovaya mutlak koordinatla konan her şey (`Flame`, hedef, bakış) `sur.ova_ofs()` almalı.
5. Sıradakiler (taşıma belgesi §4.3): 22 / 22o (kule hendeğin ötesinde), 26 / 26o (merdiven, poterna, Romanos kapısı).
6. Kare kipi yazılımsal GL'de pahalı: her anda 4+4 kare yeter (Bölüm 0'da 12+10 ile bir an ≈7 dk sürüyordu).

## Hâlâ kötü olanlar (dürüst)
- Çuvallar karede hâlâ biraz yassı somun gibi (vasat-iyi); toprak yığınının çarpışması yok (çarpışma kutusu "aynı kalsın"
  dendiği için): düelloda azaplar yığının ve çuvalların içinden geçiyor (eski hapta da aynıydı).
- Sur yolu kirişi gece gökyüzüne karşı yine koyu bir çizgi (dikmeler gitti, iskele görüntüsü yok).
- **Düşen cesetler boşluğa:** sondada (yeni set, `=late`) gedikten atılan/ölen düşmanların bir kısmı y −70…−128'e düşmüş
  (`testler/sonda/late_r*.ham`, `SONDA20 … at=(-11.0, -120.0, 22.3)`); oyuncu görmüyor ama düşmeye devam ediyorlar. Kök
  nedeni (teras/moloz çarpışması mı, `_retreat_step` mı) bu oturumda araştırılmadı; `WARN_VOID` yalnız oyuncuyu denetliyor.
- Bölüm 0 donan karesi eskisinden boş (yerde yaralılar yok, kalas yığını kutumsu); `an_04` sabit bakışta kask kameranın dibinde.
- Bölüm 25'te sur yolundan aşağı bakışta yüksek iç korkuluk peribolosu kapatıyor; sur yolunda A'nın dekor fıçıları büyük
  ve köşeli görünüyor (A'nın dosyası: **A'ya istek**, kare `kare/c25_yeni*/an_06_gedik_sur_yolundan.jpg`).
- Bölüm 21 an_03 SONRA karesi alınmadı (yalnız sayısal ölçüm).
- Bölüm 20 2. dalgası eskiden kısa (sahibin kararını bekliyor; dokunulmadı).
- Gerçek GPU'da kare süresi ölçülmedi (bütçe yazılımsal GL'de).
