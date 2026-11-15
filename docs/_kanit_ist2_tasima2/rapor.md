# TAŞIMA-2 — pilot kalanları (kazık çit, Bölüm 20) ve Bölüm 21 yeni Mesoteikhion surunda

> Dal `wip/ist2-tasima2`, taban `wip/ist2-birlesik` (28f42bb4). Makine: 4 çekirdek; ekransız testler `--max-fps 20`,
> kareler xvfb + Mesa llvmpipe (yazılımsal GL). Ham çıktılar `testler/` (koşu betikleri `kos.sh`, `kos1.sh`, süzgeç
> `suz.sh`, dalga tablosu `dalga.py` de orada), kareler `kare/`. "ÖNCE" ölçümleri tabanın `git archive` kopyasında (ayrı
> klasör, aynı içe aktarma önbelleği) koşuldu (`testler/once_*`). Dokunulmayanlar: sur görünüşü (TUR 8), çatı (B),
> `scripts/npc/`, `scripts/ui/`, `sur_sozlesme*`, `tests/run_tests.sh`, `project.godot`; replik metni, ses, denge, süre,
> sayaç değişmedi. Süzgeç her dosyada tam: `AUTOTEST (PASS|FAIL)|SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|WARN_FLY|WARN_VOID`.

## Özet

| # | Madde | Durum | Kısa |
|---|---|---|---|
| 1 | Kazık çit "oyuncunun arkasına" | **TAMAM** | çit barikatın şehir tarafında (teslim yerinin 2,8 m gerisi, uçları açık); sırt dış yüz + 0,2. Bölüm 20 2. dalga medyan 27,2 (pilot) / 49,8 (taban) → **7,8 sn** (eski 22,7); 20o `=wide` 1. dalga 34,0–35,5 → **3,7–7,6 sn** (eski 9,3) |
| 2a | `=hit` `VISAUDIT personhidden D20_G_ASSAULT` | **TAMAM** | kök neden: yeni sette işçiler taşıyıcı şeridinin üstündeydi, taşıyıcılar onları adım adım itiyordu (komutanla oyuncunun arasına, barikat kutusunun içine); konuşanın önünden çekilme (`WallFight.dodge`) işçileri kapsamıyordu. `=hit` ×10 (son kod) denetim **0**. 0.99.121 `Unclip.clear_line` düzeltmesi **aynı kök neden değil** (bu replikten önce `clear_line` hiç çağrılmıyor; bkz. 2a) |
| 2b | Gökte koyu köşeli biçim | **TAMAM** (yalnız doğrulama) | pilot kaydında var (yeniden üretildi), bu dalda yok: biçim kesimin birleşik sur ağının içinde (`OyunDilimi/Mesoteikhion/@MeshInstance3D…`, kurucu `surlar*.gd`, tur 6 sürümü), ayrı bir düğüm değil; tur 7 birleşimiyle kaybolmuş. Benim dosyamda değil; TUR 8'e istek gerekmiyor |
| 3a | Bölüm 21 taşıması | **TAMAM** | `SurSet` + `--eskisur`; yeni ×2 12/12, eski ×1 6/6 PASS, denetim 0; gerçek bot yürüyüşü iki sette takılma 0 / düşme 0 / kap gerçek tuşla; 6 kare çifti; bütçe yeni −%48…−%82 çizim |
| 3b | Bölüm 0 | **YAPILMADI** | süre yetmedi (Bölüm 20 kalanları beklenenden uzun sürdü); "sonraki taşıyana" notları aşağıda |
| 3c | Bölüm 25 (Bizans yarısı) | **YAPILMADI** | süre yetmedi |
| — | Sözleşme | **TAMAM** | `SURSOZLESME PASS kalem=13 kesim=8` · `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` · `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` (`testler/sozlesme_*.txt`) |

## 1. Kazık çit

### Kök neden (ölçüldü: `testler/sonda_*.txt`, düellocuların konumu 2 sn'de bir; sonda kodu kayda girmedi)
- **Bölüm 20, 2. dalga:** otomatik testte oyuncu peribolosta (doğuş, okçular) kalır. 2. dalganın azapları `moloz_sirti()`
  (dış yüz + 1,4, aşama 4'ün dış yüzdeki çitinin ova tarafı) üstünde doğar, oyuncuya yürürken çitin kutusuna çarpar
  (`Duelist._swept_free` bütün katıları sayar), yana kayıp moloz yamacından **terasa (y −2,9) düşer** ve dış surun dibinde
  oyuncuyu x'te izleyerek dalga süresi (60 sn) dolana dek kalır: `e=(-13.3, -2.9, 16.9)` ×30 satır, `WAVERUNNER wave=2/2 t=60.0`.
- **20o `=wide`, 1. dalga:** savunanların giriş noktası (`Melee.auto_entry`) "düello yerinin ötesinde" aranır. Çitin ve
  toprak setin çarpışma kutularında ağ ya da meta yok → `Unclip.visible_body` onları görünmez sayar → giriş barikatın
  ARKASINDAN (peribolos) seçilir; savunan z 11,7'de 30 sn kalır, oyuncu botu çitin dibinde (z 17,2) bekler.

### Düzeltme (`sur_oyun_parca.gd` `GedikOnarim`, `sur_set.gd`, `chapter20.gd`, `wall_fight.gd`)
- Aşama 4'ün insan boyu kazık çiti dış yüzden kalktı; **barikatın şehir tarafına**, teslim yerinin 2,8 m gerisine
  (`GedikOnarim.CIT_Z_PAY` = dış surun iç yüzünden 6 m), gedik eni kadar, iki ucu açık (depodan gelen yol ve siperler
  ucun dışından geçer), iki yatay kuşakla. 5 m'de taşıyıcı şeridi çitin sol ucunu sıyırıyordu (`VISAUDIT insolid … carry
  x −4,1`): 6 m'de uçta 1,7 m açık.
- Çitin ve toprak setin/fıçı sırasının kutuları `wall` metası alır (görünen katının kutusu): giriş seçimi ve görüş denetimi
  onları görür.
- `moloz_sirti()` eski anlamına döndü: dış yüzün 0,2 m dışı (eski LandWalls'ta da 0,2). Sırtla gedik arasında çit yok.
- Barikatın aşamalı görünüşü korundu (1 açık · 2 kazık/fıçı, ortada geçit · 3 toprak dolgu · 4 barikat tam + sur yolu
  tahtası + kazık çit). Aşama 3–4 toprak seti fıçı sırasının şehir tarafından (teslim yerini, işçileri ve komutanı içine
  alan "dev hap", pilot an_06) fıçıların ARDINA, gediğin iç yarısına alındı; çarpışması aynı yerde.
- Çitin yeni yeri yeni denetim satırları doğurdu, köklerinden düzeltildi (hepsi yalnız yeni set; eski yol değişmedi):
  - `TESPITBLOCK … Ahsap_GedikCit_Carp` ve `VISAUDIT hidden D20_G_END/D20_G_TAPE by=…GedikCit`: şafak tespit yeri gedik
    önü − 4 m çitin şehir yanındaydı → (2,0; 9,4): çitin önünde, gediğin hafif sağı, barikata 4,5 m (eski 7,6; önce
    (−6,5; 9,5) denendi: soldan gelen taşıyıcı şeridi ve sol işçiler kadrajı kesiyordu, `TESPITBLOCK person` 17/18);
    kararma kesmesinde Giustiniani yerine döner, boşta kalan dost düellocular sahneden çekilir (`Duelist.dismiss_idle`;
    biri oyuncunun 0,5 m önünde kalıyordu: `personhidden D20_G_END by=…(no_talk,no_chat,no_yield)`).
  - `VISAUDIT insolid … Toprak_GedikSet_Carp`: (a) Giustiniani'nin pilot yeri (gedik önü + (3,6; 1,8)) fıçı sırası
    kutusunun içindeydi (kutu önceden görünmez sayıldığı için denetim görmüyordu) → sağ siperin önü (5,0; 9,4), doğuştan
    14,8 m (eski 14,2); Leon aynı nedenle (1,6; 9,8). (b) İşçiler taşıyıcıların itişiyle 0,4–0,5 m'lik adımlarla kutuya
    itiliyordu (sonda `testler/sonda_isci.txt`) → bkz. 2a.

### Düello dalga süreleri (`WAVERUNNER t=`, sn; `testler/`)

| küme | 1. dalga medyan [aralık] | 2. dalga medyan [aralık] |
|---|---|---|
| 20 eski (pilot son tur, ×1) | 9,0 [8,4–15,6] (n 9) | 22,7 [18,9–34,2] (n 8) |
| 20 yeni ÖNCE (pilot son tur, ×3) | 4,4 [1,8–12,4] (n 27) | 27,2 [12,6–60,1] (n 24) |
| 20 yeni ÖNCE (bu dalın tabanı, ×1) | 3,8 [3,4–12,2] (n 9) | 49,8 [19,4–60,1] (n 8) |
| 20 yeni SONRA (çit + sırt, ×3, `sonra_c20_*`) | 4,6 [2,2–11,6] (n 27) | 8,8 [4,8–11,4] (n 24) |
| 20 yeni SON (bütün düzeltmeler, ×2, `fin_c20_*`) | 4,3 [2,0–9,8] (n 18) | 7,8 [5,2–14,6] (n 16) |
| 20o eski (pilot son, ×1) | 11,0 [9,0–13,7] (n 9) | 14,2 [11,9–15,1] (n 8) |
| 20o yeni ÖNCE (pilot son, ×2) | 11,4 [7,2–15,1] (n 18) | 13,8 [6,2–17,6] (n 16) |
| 20o yeni ÖNCE (taban, ×1) | 11,1 [7,5–14,5] (n 9) | 14,3 [8,2–15,6] (n 8) |
| 20o yeni SONRA (×2, `sonra_c20o_*`) | 12,1 [4,8–14,9] (n 18) | 14,8 [9,9–21,5] (n 16) |
| 20o `=wide` eski | 9,3 | 22,3 |
| 20o `=wide` yeni ÖNCE (pilot ×2 / taban ×1) | 32,4–35,7 / 35,5 | 19,0 / 17,8 |
| 20o `=wide` yeni SONRA (×2) | 3,7–7,6 | 10,3–11,0 |

(20o satırlarında `=wide` hariç.) Bölüm 20'nin 2. dalgası artık eskiden KISA (7,8 ↔ 22,7): eski sette de azaplar
barikatın kutularına takılıyordu; yeni sette sırtla oyuncu arasında yalnız fıçı sırası var. Süre, sayaç, dalga sınırı
(60 sn), dalga sayısı, rakip sayısı değişmedi. `gunner=a/b` (tüfekçinin atışı) düello süresine bağlıdır: düello kısaldığı
için tüfekçi daha az atıyor (aşağıdaki alan tablosu) — oyuncu hissi açısından not edilmeli.

### Testler (Bölüm 20 ×3 + son ×2, 20o ×2; eski ×1)

- `sonra_c20_*` 27/27, `fin_c20_*` 18/18, `fin3_c20_*` 12/12 (şafak yeri son hâli; bütün çeşitler + tape/hit/def ikinci
  kez), `sonra_c20o_*` 20/20, `fin_c20o_*` 10/10, `son_c20_eski_def`, `son_c20o_eski_wide` (`--eskisur`) PASS; süzgeç
  satırı **0**. 20o son tur dalgaları: 11,9 [6,9–14,8] / 12,9 [9,4–18,2]; `=wide` 3,6 / 11,5.
- Ara koşular (`ara1_*`, `ara2_*`, `hit_c20_*`, `hit2_*`) düzeltme sırasındaki satırları gösterir (bilerek saklandı).
- 20o'da her koşuda `HELDDEFAULT … item=tape|remote` var: tabanda da aynı (`once_c20o_*`), süzgeç dışı; dokunulmadı.
- `TESPITBLOCK` (süzgeç dışı) tabanda da vardı (`once_c20_*` 8/9: çoğu oyuncunun kendi gölge gövdesi `Skeleton/Mesh`
  göz hizasının altında, kalanı önündeki biri); son tur `fin3_c20_*` 9/12: 6'sı aynı kendi gövdesi, 3'ü bir işçi.

AUTOTEST alanları (Bölüm 20: taban ×1 \| son ×2):

| çeşit | outcome | repair | knocks | arrows | gun | gunner | niko |
|---|---|---|---|---|---|---|---|
| def | 20.1 \| 20.1 / 20.1 | 10 \| 10 / 10 | 0 \| 0 / 0 | true \| true / true | 3/4 \| 3/4 / 3/4 | 5/5 \| 1/1 / 2/2 | 0 \| 0 / 0 |
| d0 | 20.1 \| 20.1 / 20.1 | 10 \| 10 / 10 | 0 \| 0 / 0 | true \| true / true | 3/4 \| 3/4 / 3/4 | 4/4 \| 1/1 / 2/2 | 0 \| 0 / 0 |
| d2 | 20.1 \| 20.1 / 20.1 | 10 \| 10 / 10 | 0 \| 0 / 0 | true \| true / true | 3/4 \| 3/4 / 3/4 | 7/7 \| 3/3 / 2/2 | 0 \| 0 / 0 |
| hit | 20.1 \| 20.1 / 20.1 | 10 \| 10 / 10 | 1 \| 1 / 1 | true \| true / true | 3/4 \| 3/4 / 3/4 | 3/3 \| 3/3 / 2/2 | 0 \| 0 / 0 |
| idle | 20.3 \| 20.3 / 20.3 | 10 \| 10 / 10 | 0 \| 0 / 0 | true \| true / true | 3/4 \| 3/4 / 3/4 | 7/7 \| 1/1 / 2/2 | 0 \| 0 / 0 |
| late | 20.3 \| 20.3 / 20.3 | 10 \| 10 / 10 | 0 \| 0 / 0 | false \| false / false | 3/4 \| 3/4 / 3/4 | 3/3 \| 2/2 / 2/2 | 0 \| 0 / 0 |
| lose | 20.3 \| 20.3 / 20.3 | 10 \| 10 / 10 | 0 \| 0 / 0 | true \| true / true | 3/4 \| 3/4 / 3/4 | 1/1 \| 0/1 / 0/1 | 0 \| 0 / 0 |
| niko_idle | 20.1 \| 20.1 / 20.1 | 10 \| 10 / 10 | 0 \| 0 / 0 | true \| true / true | 3/4 \| 3/4 / 3/4 | 7/7 \| 2/2 / 2/2 | 5 \| 5 / 5 |
| tape | 20.2 \| 20.2 / 20.2 | 10 \| 10 / 10 | 0 \| 0 / 0 | true \| true / true | 3/4 \| 3/4 / 3/4 | 7/7 \| 2/2 / 2/2 | 0 \| 0 / 0 |

### Aşama 4 ve düello kareleri (oyuncu kamerası, 1280×720 jpg 85; `kare/c20_once` ÖNCE ↔ `kare/c20_sonra` SONRA)

| an | ÖNCE (taban) | SONRA | SONRA tek cümle |
|---|---|---|---|
| aşama 4 (`an_06_onarim_asama4`) | kadrajı kaplayan pürüzsüz kahverengi hap, ardında dış yüzde çit | `an_06` | fıçı sırası, önünde iki çuval, arkada gediğin içinde toprak set ve eğik kazıklar, solda işçiler: kutu yok (fıçı yuvarlak, kazık silindir), havada duran yok, zemine oturuyor, sur ile aynı el; toprak set hâlâ pürüzsüz (hap biçimi küçüldü ama yok olmadı) |
| çit (`an_07_cit_sehir_tarafindan`, yalnız SONRA) | — | `an_07` | şehir tarafından bakış: insan boyu kazık çit (iki kuşak), ardında işçiler, fıçılar, sağda siper: çit zemine oturuyor, havada değil; kazıklar ve kuşaklar düz kesitli tahta gibi duruyor (kalas olarak kabul, ama ahşap çit "bahçe çiti" gibi düzgün: vasat); üstte sur yolu tahtasının sehpaları karanlık bir iskele gibi görünüyor |
| hücum başlangıcı (`an_07`/`an_08`) | azaplar dış yüzdeki çitin ardında, gökte koyu biçim YOK (taban) | `an_08` | fıçı sırası, ardında toprak set ve azaplar, gök temiz: iyi |
| düello (`an_10`/`an_11`) | azaplar dikey çit kazıklarının ardında, kadraj kazıkla dolu | `an_11` | iki azap barikatın toprağı üstünde, aralarında yalnız eğik kazıklar: okunur; kutu yok, havada yok |

## 2. Bölüm 20 kalanları

### 2a. `=hit` `VISAUDIT personhidden key=D20_G_ASSAULT … by=…(no_talk,garrison,armed,tool_armed)`
- Satırın `by` metası (`no_talk, garrison, tool_armed`) `WallFight.add_builders`'ın işçisidir (çekiç/balta). Yeni sette
  işçiler gedik önü + 0,4'teydi: soldakiler **taşıyıcı şeridinin tam üstünde**. `Person._clear_way` (yürüyen önündekini
  yana iter) taşıyıcı geçtikçe işçiyi 0,4–0,5 m'lik adımlarla iter (sonda: `(-3.6, 10.1) → (-3.7, 10.6) → (-3.8, 11.0) →
  (-3.9, 11.4) …`); işçi komutanla oyuncunun arasına, sonunda barikatın fıçı sırası kutusunun içine girer. `=hit`'te
  oyuncu gediğin önüne ışınlanır; komutan pilot yerindeydi (işçilerin ardı): itilmiş işçi çizgiye düşünce `personhidden`.
  Taşıyıcılar için var olan "konuşanın önünden çekil" (`WallFight.dodge`, Hud `sight_dodgers`) işçileri kapsamıyordu.
- Düzeltme (yalnız yeni set; eski yol aynı): işçiler barikatın dibine (gedik önü + 1,1), taşıyıcı varışı 0,4 m geri
  (şerit işçilerden ≥1,4 m), iş başındaki işçi itilmez (`no_yield`, `chapter20.gd`), görüş çizgisindeki işçi barikat
  boyunca (x) boş bir yere kayar (`WallFight._dodge_builders`, yalnız `sur` yeni ise). Komutan ve Leon kutudan çıktı (1).
- **0.99.121 karşılaştırması:** `wip/0.99.121` 3e1772c1 `Unclip.clear_line`'da "çizginin tam üstündeki kişi için yan
  yön çizgiye dik" düzeltmesi. Bölüm 20'de `clear_line` yalnız `_see_giust`, şafak ve son sözde çağrılır;
  `D20_G_ASSAULT`'tan (`_start_assault`) önce hiç çağrılmaz → **aynı kök neden değil**; düzeltme bu dala alınmadı,
  onunla birlikte ölçmek gerekmedi.
- Ölçüm: `=hit` ×10 (son kod, `testler/hit3_c20_r1..10.txt`) denetim **0**, 10/10 PASS. Ara turda (`hit2_*`, `no_yield`
  var, `_dodge_builders` yokken) 1/10 `personhidden D20_G_REPELLED/DONE` (itilemeyen işçi çizgide kaldı): `_dodge_builders`
  bunun için eklendi. Taban ×1 (`once_c20_hit_r1`) bu koşuda temizdi (yöneticinin oranı 1/4).

### 2b. Gökte, kulenin yanında koyu köşeli biçim
- Pilot kaydı (`origin/wip/ist2-pilot-20` 23af1cac) ayrı klasörde `=kare` ile yeniden koşuldu: biçim an_03 (kulenin sağı)
  ve an_07'de (gediğin üstü) aynen var (`kare/gok_bicim/pilot_an_03.jpg`, `pilot_an_07.jpg`). Bu dalda aynı bakışta yok
  (`budal_an_03.jpg`, `budal_an_07.jpg`).
- Kimlik: piksel → ışın → görünür ağ sorgusu (`tests/_ist/tasima2_kim.gd`, `=kare -- --kim=x,y`). 25 m'den küçük hiçbir ağ
  o pikselin ardında değil; büyük ağlarla: yalnız `SurCerceve/SurOyun_mesoteikhion/OyunDilimi/Mesoteikhion/` altındaki
  birleşik sur ağları (`@MeshInstance3D@1976/1977/1978`, en olası `@1977`: 190 × 30,8 × 55,3 m, y −9,6…21,2) ve
  `SurDibiBant` (`testler/kare_pilot_kim2.txt`). Yani biçim kesimin sur kurucusunun (`surlar*.gd`, tur 6 sürümü) ürettiği
  geometrinin parçası, ayrı bir düğüm değil; birleşik ağ olduğundan düğüm gizleyerek ayrıştırılamadı. Tur 7 birleşimiyle
  (`surlar.gd`, `surlar_ayrinti.gd`, `sur_gorunus.gd` değişti) kaybolmuş. Benim dosyamda değil; bu dalda yok → TUR 8'e
  istek yok (yalnız bilgi: tur 8 bu bakışları gözden geçirirken aynı açılardan bakabilir).

## 3. Bölüm 21 (Lağım) — taşıma

### Bağdaştırıcı (`scripts/chapter21.gd`)
- `const ESKI_SUR := false`, `sur = SurSet.sec("21", ESKI_SUR)`; `walls = LandWalls` (eski) ya da `SurSetSahne` (yeni);
  `--eskisur` / `--eskisur=21` eskiyi seçer. `walls.set_repair(STAGES)` yeni sette gedik onarımının 4. aşaması.
- `Garrison.land_walls(…, sur)` (yeni sette `_land_walls_sur`). Tünel (y −30) ve Kasım'ın odası surdan bağımsız: aynı.
- Değişen yerler (yalnız yeni set; eski sabitler aynen): eski yerler gediğin sağındaki iç kulenin (x −2,8…12,2; z ≤ 8)
  içine düşüyordu (`tests/_ist/tasima2_engel.gd` sondası: `oyuncu (−2;5)`, kaplar `(2;4) (8;4) (10;2)` **engelde=true**).
  `OYUNCU_YENI (−4; 6,3)`, `GRANT_YENI (−4; 3,4)`, Grant'in boş kapları z 2,6 (eski 1,8 yeni sette iç surun dibi eteği),
  otomatik testin kap yerleri `KAP_TEST_YENI (−17; 8,5)` ve `KAPLAR_TEST_YENI` (sağda dört "soğuk" kap; uzaklık sınıfı
  aynı). Lağım (`MINE (−9;0;7)`) ve ateş halkaları aynı. Otomatik testte `TASIMA21ENGEL OZET nokta=10 engelde=0`.
- `AUTOTEST` satırına `sur=eski|yeni` eklendi; yeni kipler `=yuru` (gerçek bot) ve `=kare` (kare + bütçe).

### Testler (`testler/c21_*.txt`): yeni ×2 12/12, eski ×1 6/6 PASS, süzgeç satırı 0

| çeşit | outcome | bowls | tunnel | talk | trust | captive | next |
|---|---|---|---|---|---|---|---|
| def | 21.1 \| 21.1 / 21.1 | 2 \| 2 / 2 | leb \| leb / leb | talk \| talk / talk | 3 \| 3 / 3 | false \| false / false | — |
| grant | 21.2 \| 21.2 / 21.2 | 4 \| 4 / 4 | leb \| leb / leb | talk \| talk / talk | 3 \| 3 / 3 | false \| false / false | — |
| fight | 21.1 \| 21.1 / 21.1 | 2 \| 2 / 2 | fight \| fight / fight | iron \| iron / iron | 0 \| 0 / 0 | false \| false / false | — |
| thermos | 21.1 \| 21.1 / 21.1 | 5 \| 5 / 5 | leb \| leb / leb | talk \| talk / talk | 3 \| 3 / 3 | false \| false / false | — |
| ear | 21.1 \| 21.1 / 21.1 | 5 \| 5 / 5 | leb \| leb / leb | talk \| talk / talk | 3 \| 3 / 3 | false \| false / false | — |
| captive | 21.1 \| 21.1 / 21.1 | 2 \| 2 / 2 | leb \| leb / leb | talk \| talk / talk | 3 \| 3 / 3 | true \| true / true | chapter22o \| chapter22o / chapter22o |

(eski ×1 \| yeni ×2)

### Gerçek bot yürüyüşü (`=yuru`; gerçek `Player`, ileri tuşu; kap GERÇEK etkileşim tuşuyla; `testler/yuru_c21_*.txt`)

| bacak | eski sn / m | yeni sn / m |
|---|---|---|
| doğuş → Grant | 0,3 / 0,8 | 0,3 / 0,8 |
| Grant → 1. kap (test yeri; eski (2;4), yeni (−17;8,5)) | 1,1 / 3,3 | 3,8 / 12,0 |
| 1. kap → lağım (2. kap, bulunur) | 2,5 / 7,8 | 2,1 / 6,7 |
| lağım → tespit yeri | 0,8 / 2,4 | 0,3 / 0,9 |
| **özet** | takılma 0, düşme 0, kap eksiği 0, bulundu | takılma 0, düşme 0, kap eksiği 0, bulundu |

(1. kap bacağı test yerinin seçimidir, oynanışta oyuncu kabı istediği yere koyar; kap aşamasında süre yok.)

### Mesafe tablosu (yatay, bölüm çerçevesi; kural: hedefe ≤ 20 m)

| çift | eski m | yeni m | not |
|---|---|---|---|
| doğuş → Grant | 2,8 | 2,9 | |
| doğuş → lağım | 7,3 | 5,0 | ≤ 20 ✓ |
| Grant → lağım | 6,4 | 6,2 | ≤ 20 ✓ |
| lağım → gedik | 12,0 | 12,2 | |
| lağım → en yakın iç kule (orta, yaklaşık) | 15,9 | 14,6 | |
| lağım → ateş halkası (sol) | 14,1 | 14,1 | |

### Yön söyleyen replikler (`i18n/strings.csv` tr, `D21_`, `UI_OBJ21`, `UI_CH21`, `UI_C21`, `LORE_21`; metne dokunulmadı)

| anahtar | metin (kısa) | yeni sette |
|---|---|---|
| `D21_K_TELL` | "…Biri de burada, kuleye yakın." | doğru: başka bir lağımı anlatır; peribolosta iç kule lağıma 14,6 m (eskide 15,9) |
| `D21_G_MAP` | "…biri kulenin dibinde." | doğru (aynı anlam) |
| `D21_J_OK` | "…sol koldan kazacağız." | tünelin içi, set bağımsız |
| `D21_G_DIG` | "Aşağı iniyoruz." | set bağımsız |
| `UI_OBJ21_BOWLS`, `UI_OBJ21_PHOTO` | yön yok | — |

### Kareler (oyuncu kamerası; `kare/c21_eski` ↔ `kare/c21_yeni`, aynı adlar)

| an | SONRA (yeni) tek cümle | hüküm |
|---|---|---|
| `an_01_acilis_grant` | Grant iç surun dibinde, ayağında dört boş kap, solda depo kalasları; arkası düz koyu sur yüzü, zemin gri/kahverengi düz kenarlı yama (sur dibi eteği) | vasat: karanlık, zemin yaması kötü (tur 8'in `SurDibiEtek` konusu, pilot istek 1) |
| `an_02_kap1_peribolos` | peribolos boyunca bakış: depo fıçıları, toprak yığını, meşaleler, siperler, uzakta Grant; kutu yok, havada yok | iyi |
| `an_03_lagim_kap` | lağımın üstü: deponun fıçıları ve kalas yığını kadrajda, kaplar arkada | **kötü**: yeni sette lağım deponun dibine düşüyor (2,8 m), kalabalık |
| `an_04_tespit` | dalgalanan kap ortada, solda fıçılar, sağda siper kazığı | kabul |
| `an_05_peribolos_gedik` | peribolos ve gediğe uzun bakış: meşaleler, siperler, gedikte barikat | iyi (eski karede sağda el merdiveni ve tahta iskele vardı; yeni sette taş merdiven ayrı yerde) |
| `an_06_tunel` | mum ışığında destekli tünel; iki sette aynı | iyi |

### Bütçe (aynı kameralar, 10 kare ortalaması; `testler/kare_c21_*2.txt`)

| bakış | eski çizim | yeni çizim | fark | eski ilkel | yeni ilkel | fark |
|---|---|---|---|---|---|---|
| an_04 tespit | 1.702 | 887 | −%48 | 1,95 M | 0,69 M | −%64 |
| an_05 peribolos→gedik | 4.790 | 2.248 | −%53 | 4,40 M | 2,85 M | −%35 |
| an_06 tünel | 2.114 | 504 | −%76 | 2,17 M | 0,03 M | −%99 |
| an_01 açılış (kamera yeri farklı) | 1.197 | 374 | — | 2,32 M | 0,37 M | — |

Tünelde eski set 2,1 M ilkel çiziyordu (şehir ve HornWorld yerin üstünde, örtücüsüz); yeni sette 30 bin.
Bölüm 20 bütçesi: çit yer değiştirdi, ağ sayısı aynı (bir kuşak çifti eklendi: aynı `Ahsap_GedikTahta` birleşik ağına);
ayrıca ölçülmedi.

## Öteki bölümler
Kanca eklenen yardımcı: `WallFight` (`builders` dizisi + `_dodge_builders`, yalnız `sur` yeni ise; eski yolda koşmaz).
`WallFight.sur`'u veren bölümler yalnız 20 ve 20o (`grep "fight.sur"`): ikisi de yukarıda. `GedikOnarim` yalnız
`SurSetSahne`'de (20, 20o, 21). Öteki bölümlerin kod yolu değişmedi; ayrıca koşulmadı.

## Sonraki taşıyana
1. Yeni sette **görünmez çarpışma kutusu** yok sayılır: `Unclip.visible_body` ağı/metası olmayan kutuyu görmez. Görünen bir
   şeyin kutusuysa `wall` (ya da `ground`) metası verin; yoksa giriş noktası, yana çekilme ve görüş denetimi onu görmez —
   ama düellocunun adımı (`_swept_free`) görür: takılma buradan çıkar.
2. Kutuyu görünür yapınca **eskiden gizli kalan çakışmalar** denetime çıkar (bu oturumda: komutan ve işçiler barikatın
   içindeydi). Bunları susturmayın, yerleri düzeltin.
3. Yeni sette depo ve taşıyıcı şeridi gediğin SOLUNDA; şeridin üstüne hiçbir duran kişi koymayın (itilir).
4. Bölüm 0: `scripts/chapter0.gd` START/LINE ok demeti peribolosta; Assault/Garrison/WallFight bağlanmalı; gedik önü kadrajı.
   Bölüm 25 (Bizans yarısı): oyuncu dış sur yolunda (yeni yol 1,7 m, kule geçitli); başlangıç ışınlaması `sur.dis_yol_*`.
   İkisinde de ilk iş `tests/_ist/tasima2_engel.gd -- --nokta=ad:x,z;…` ile bölümün sabit noktalarını engele karşı tara.
5. Kare kipi (`=kare`) ve bot (`=yuru`) kalıbı: `chapter21.gd` sonunda (ch20'ninkinden kısa, bütçe ölçümü içinde).

## Hâlâ kötü olanlar (dürüst)
- Aşama 3–4 toprak seti hâlâ pürüzsüz bir hap (küçüldü, gediğin içine geçti; doku/çuval yığını değil).
- Çit ve sur yolu tahtası düz kesitli tahta; sehpalar gece karanlık bir iskele gibi (an_07).
- Bölüm 21'de lağım deponun dibinde: kap konan yer depo yığınlarıyla kalabalık (an_03). Lağımın yerini taşımak testlerin
  "sıcak/soğuk" dağılımını değiştirir; bu oturumda yapılmadı.
- Sur dibi eteğinin düz kenarlı zemin yamaları (Bölüm 21 an_01): tur 8'in konusu (pilot istek 1, hâlâ geçerli).
- Bölüm 20 2. dalgası eskiden 3 kat kısa (7,8 ↔ 22,7 sn); tüfekçi daha az atış yapıyor.
- Şafak tespit karesinde `TESPITBLOCK` (süzgeç dışı; tabanda 8/9, son tur 9/12): çoğu oyuncunun kendi gölge gövdesi (tespit
  ışını kendi ayağına değiyor — `TespitCam`, `scripts/ui/` değil mi bakılmadı, dokunulmadı), 3/12 barikat dibindeki bir işçi.
- Bölüm 0 ve 25 taşınmadı.
- Gerçek GPU'da kare süresi ölçülmedi (bütçe yazılımsal GL'de).
