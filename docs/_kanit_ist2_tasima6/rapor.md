# TAŞIMA-6 — Bölüm 20 `=hit` gerilemesi; 37o yeni surda; 32o bağdaştırıcısı

> Dal `wip/ist2-tasima6`, taban `wip/ist2-taban11` 2fa8fb35. Makine: 4 çekirdek; ekransız testler `--max-fps 20`
> (`testler/kos1.sh`, toplu `testler/toplu.sh`), kareler xvfb + Mesa llvmpipe (yazılımsal GL), 1280×720 jpg 85
> (`testler/kare.sh`). Ham günlükler `testler/**.ham`; yanındaki süzülmüş dosya `kos1.sh`'in süzgeci
> (`AUTOTEST (PASS|FAIL)|SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|WARN_FLY|WARN_VOID` + `KOSU|WAVERUNNER|GUN|CESET4|TASIMA6`).
> Dalga tabloları `testler/dalga.py` (küme) ve `testler/cesit.py` (çeşit başına) ile süzülmüş dosyalardan. **ESKİ** = `--eskisur`.
> Dokunulmayanlar: sur görünüş dosyaları (TUR 11), `scripts/npc|ui|player/`, ortak sınıflar `WaveRunner`, `Duelist`, `Melee`,
> `Duel`, `Garrison`, `SurSet`, `SurSetSahne` (değişmedi; `Assault` yalnız yeni set yolunda §4.1, `GedikOnarim` §4.2), `sur_sozlesme*`,
> `tests/run_tests.sh`, `project.godot`, `game_state.gd`; replik metni, ses, can/hasar, dalga sınırı (60 sn), düşman sayısı,
> gizli süreler (STOCKADE_TIME 180, BEATS 16, DITCH_TIME 240), sayaçlar. Yeni sesli replik yok.



## Özet

| # | Madde | Durum | Kısa |
|---|---|---|---|
| 1 | Bölüm 20 `=hit` D20_T_DUEL "wall" | **TAMAM** | kök neden günlükle (§1.1): `=hit` yeri yeni setin toprak setinin dibinde + azap yolu set ile siper arasındaki 0,4 m'lik aralıkta bitiyor → bot sete yapışıp D20_T_DUEL'i sete 0,3 m'den bakarak söylüyor. Düzeltme: yol siperi dolanır, `=hit` yeri `gedik_onu`, 1. dalga çıkışı dengelendi. `=hit` ×12 **denetim 0**; Bölüm 20 bütün çeşitler ×2 (+def ×4, hit ×10) **32/32 PASS denetim 0**; 20o ×1 **10/10 PASS denetim 0**; 2. dalga medyanı **20,6 sn** (taşıma 4: 21,2) — değişmedi |
| 2a | 37o yeni surda | **TAMAM** | `SurSet` + `--eskisur`; setin kalas köprüsü (x −17,9, parateikhion açıklığı), ova `ova_ofs`, barikat moloz sırtında, hendek merdivenleri (düşme cezası). Yeni ×2+ **10/10**, eski ×1 **3/3 PASS, denetim 0**; gerçek bot takılma 0 düşme 0; 6 ESKİ\|YENİ kare (3 turda: tabya, kalkan kümesi, savunucular düzeltildi); bütçe 6/6 eskinin altında (−%50…−%79); çıkış düellosu yeni kısa değil (13,2 ↔ 10,9) |
| 2b | 32o yeni surda | **KISMEN** | bağdaştırıcı (ova kaydırması, hendek oranı, dolgu 0,5, top zemini); yeni 8/8 + eski def PASS, denetim 0. `=yuru`, kareler, bütçe, eski ×1 (öteki çeşitler) yapılmadı |
| 2c | 36b | **YAPILMADI** | süre |
| — | Ortak | **TAMAM** | `Assault._sura_bak` (yeni sette ova bataryaları/tabyaları/mancınıkları 3,55 m havadaydı; eski yol aynı), `GedikOnarim` taşları kesite oturur; kullanan bölümler ×1 PASS (§4.3). `WaveRunner`/`Duelist`/`Melee`/`Duel` değişmedi |
| — | Sözleşme | **TAMAM** | `SURSOZLESME PASS kalem=13 kesim=8` · `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` · `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` |

---

## 1. GERİLEME: Bölüm 20 `=hit` — Tolga D20_T_DUEL'i duvara bakarak söylüyor

### 1.1 Yeniden üretme ve kök neden (günlükle)
- Sonda (yalnız autotest; `chapter20._t6_sonda`): düello başında ve sonunda oyuncunun yeri, kamerasının yönü ve önündeki ilk
  gövde (`TASIMA6DUELLO … ilk=<yol>@<uzaklık>`); `--sonda6` ile düello boyunca 0,25 sn'de bir yer/hız/hareket kipi/botun evi
  (`SONDA6`). Taban kodla `=hit` ×6 (`testler/c20_hit_once`): **2/6 `VISAUDIT wall key=D20_T_DUEL`** (at (2,8; 2,2; 11,7),
  (3,0; 2,1; 11,7)), 1/6 ayrıca `personhidden` ×2 (D20_G_REPELLED/D20_G_DONE: Giustiniani bir garnizon askerinin ardında).
- **Oyuncu düello başında** her koşuda `(−0,1; 0,8; 11,7)`, kamerası +z'ye, **aşama 3–4'ün toprak setinin kutusuna
  (`Toprak_GedikOnarim/Asama/Toprak_GedikSet_Carp`) 0,76 m'den** bakıyor. `=hit` bu yeri `gedik() + (0, 0, −3)` ile verir: eski
  sette z 12, barikat z 13,6'dan başlar (1,6 m pay); yeni sette gedik z 15,3 → z 12,3, setin kutusu z 12,0–13,2 → bot setin
  dibinde (kapsül 0,3 m: z 11,7).
- **Düello sonunda** (kötü koşular) oyuncu `(2,8…3,0; 0,5; 11,7)`, kamera +z, **toprak setin kutusuna 0,30–0,31 m'den**
  bakıyor; arada giren gövde = `Toprak_GedikSet_Carp` (görünen toprak set, `wall` metalı). Toprak set değil çit ya da sur
  yanağı değil.
- **Neden x 3'e kayıyor** (`testler/sonda/hit_s1.ham`, SONDA6): taşıma 4'ün yaklaşma yolu azapları barikatın oyuncu
  yanındaki ucuna (`kose` (±4,8; 13,5)) getirip bırakır. Oradan oyuncuya inmenin tek yolu toprak setin kutusu (x ±4,2,
  z 12,0–13,2) ile o yandaki tekerlekli siperin (x 4,3–6,7, z 11,4–11,6) arasındaki **≈ 0,4 m'lik aralık**: azap orada
  sıkışır; test botu (`Duel._bot`) yolu bitmiş rakibe doğru yürür, setin arka yüzüne yapışıp yan yan kayar (SONDA6:
  `p=(2,1…2,9; 0,6; 11,7) mod=script`); dalga bitince evine (başlangıç yeri) ancak 1,5 m'den uzaksa döner, dönmeyince
  D20_T_DUEL sete 0,3 m'den bakarak söylenir. Taşıma 3'te yaklaşma yolu yoktu (azaplar gedik ağzında doğuyordu): bu yüzden
  orada görülmedi. Öbür çeşitlerde oyuncu teslim yerinde (setin 1,6 m berisi) durduğu için seyrek; `=hit`'te sete yaslı başlıyor.

### 1.2 Düzeltme (kökten; susturma/eşik/muafiyet yok, ortak sınıf değişmedi)
1. **Azap yolu siperi dolanır** (`chapter20._yaklasma`, yalnız yeni set): `kose`'den sonra dış surun iç yüzü boyunca o
   yandaki siperin dış ucunu (|x| = 5,5 + 1,8) dolanıp peribolosa siperin önünden, açık zeminden girer (iki ara nokta). Set ile
   siper arasındaki aralığa kimse girmez; düello açık zeminde olur.
2. **`=hit`'in yeri** (yalnız yeni set): `gedik_onu()` (setin 1,6 m berisi; eski setteki payın aynısı). Top hâlâ görür
   (`_exposed`: gediğe 4,5 m, siper arkası değil) → `knocks=1`.
3. **Süre dengesi**: yol ≈ 6 m uzadı; 1. dalga ilk ölçümde +3,5 sn (`testler/c20_dolan`: 14,6 ↔ taşıma 4 11,4). 1. dalganın
   çıkışı hendek dolgusunun yakın ucundan (+1,0) teras eteğine (−2,6; gediğin ardı, peribolostan görünmez), kademe 2,0 → 1,2 sn
   (`YAKLASMA_1_Z`, `YAKLASMA_1_ARA`). 2. dalga dokunulmadı. `Duelist` temposu, can, hasar, dalga sınırı, düşman sayısı aynı.

### 1.3 Ölçüm (Bölüm 20, yeni set; `testler/…`, `dalga.py` / `cesit.py`)

| küme | koşu | PASS | denetim | 1. dalga medyan [aralık] | 2. dalga medyan [aralık] |
|---|---|---|---|---|---|
| taban `=hit` ×6 (`c20_hit_once`) | 6 | 6 | **4** (wall ×2, personhidden ×2) | 13,8 [13,5–15,3] | 22,7 [16,3–24,6] |
| ara 1: yalnız `=hit` yeri ×12 (`c20_hit_tur1`) | 12 | 12 | **2** (personhidden ×2, oyuncu yine setin dibinde) | 12,1 | 20,5 |
| ara 2: + yol siperi dolanır, `=hit` ×12 (`c20_hit`) | 12 | 12 | **0** | 11,7 | 17,1 |
| ara 2, bütün çeşitler ×1 (`c20_dolan`) | 8 | 8 | 0 | **14,6** (+3,2) | 25,5 |
| **son**: + 1. dalga teras eteği/1,2 sn — 9 çeşit ×2 + def ×4 + hit ×10 (`c20_son`) | **32** | **32** | **0** | **12,2** [9,4–22,0] (n 32) | **20,6** [15,8–35,1] (n 30) |
| taşıma 4 "sonra" (sahibinin kararı; 9 çeşit ×3) | 27 | 27 | 0 | 11,4 [9,3–18,9] | **21,2** [17,7–26,2] |

- **`=hit` ×12: denetim 0** (son paketin `hit_r1…r12`; ayrıca `c20_hit` ×12: 0). Ceset düşüşü (`CESET4 dusen`) 32/32 koşuda 0.
- **Bölüm 20 bütün çeşitler ×2: 18/18 PASS, denetim 0**; alanlar (`outcome`, `repair`, `knocks`, `arrows`, `gun`) tabanla aynı
  (`=hit` `knocks=1`, `tape` 20.2, `late`/`lose`/`idle` 20.3).
- **Düello süreleri (×6+)**: 2. dalga medyanı 20,6 sn (taşıma 4: 21,2; sahibinin kararı ≈ 21) — **DEĞİŞMEDİ**; `def` ×6: 12,6 /
  21,4 (taşıma 4 `def` ×3: 10,7 / 20,8). 1. dalga 12,2 (taşıma 4: 11,4; eski set 9,0–9,4).

Çeşit başına (son, ×2; `def` ×6, `hit` ×12): def 12,6 / 21,4 · tape 13,1 / 31,8 · late 12,2 / 22,9 · hit 10,6 / 18,6 ·
idle 12,6 / 21,5 · niko_idle 12,8 / 22,7 · d0 12,4 / 26,2 · d2 13,2 / 20,7 · lose 20,7 / — (taşıma 4: def 10,7/20,8 · tape
10,6/24,3 · late 12,0/18,9 · hit 14,8/22,3 · idle 11,2/20,7 · niko_idle 11,6/21,3 · d0 9,9/20,4 · d2 10,2/23,1 · lose 18,4).
`=hit`'in 2. dalgası 22,3 → 18,6: eskiden bot sete yapışık, rakip aralıkta sıkışık dövüşüyordu (o sıkışma dalgayı uzatıyordu);
şimdi `def` gibi açık zeminde. `tape` 24,3 → 31,8 (n 2; uzun yönde, 60 sn sınırının çok altında).

### 1.4 Bölüm 20o ×1 (kod yolu bu dalda değişmedi; `testler/c20o`)
10/10 çeşit **PASS, denetim 0** (def, wide, lose, hot, hot_taped, hot_tape, named, flawed, edirne, edirne_ok); alanlar taşıma
4/5'teki gibi (`wide` 20O.2, ötekiler 20O.1). Dalga: 1. 10,6 [7,4–13,3], 2. 12,7 [9,6–20,1] (taşıma 4: 10,3 / 13,9).

---

## 2. Bölüm 37o (İlk Hücum, 18 Nisan gecesi) — `scripts/chapter37o.gd`

### 2.1 Ne değişti (yalnız yeni set; `--eskisur` yolu eskinin aynısı)
- `ESKI_SUR` + `SurSet.sec("37o", …)`; yeni sette `SurSetSahne` (`dolgu` 0: ilk hücum, hendek dolmamış; `kalas` false: köprüyü
  bölük getirir; poterna kapalı). Sabitler `*_E` (eski) + bölüm değişkeni (yeni): `_yeni_yerlesim`.
- **Ova** (yürüyüş, kıyı, sürükleme, ordu, meşaleler, zemin ayrıntısı): eski koordinat + `sur.ova_ofs()` (0; −3,55; 10,6)
  → aralarındaki mesafeler eskiyle aynı (22o kalıbı).
- **Kalas köprü**: setin kendi `KalasKopru`'su (karar 7-A), setin kalas geçidinde (x −17,9; poternanın önü). x −9'da (eski
  yer) yeni setin **parateikhionu** (1,6 m alçak duvar, z 24,8–25,7) yalnız geçişlerin önünde açık: kalasın ucu duvara
  çıkardı. Sürükleme kalasın x'ine kayar (−8,9); yürüyüş eski x'inde kalır (ilk turda o da kaydırılmıştı: başı yeni setin
  x −24'teki batarya yuvasının dibine düşüyordu, kare `kare/c37o_yeni_tur1/an_01`); kalas yığını yürüyüşün sonu ile kalasın
  arasında (x −16,9). Kalas inişi: köprü ortasında bir mil düğümüne
  alınır, uzak ucu havada (−14°, +1,2 m) gelip kıyılara oturur (eski kalas −60°), toz; çarpışma `tak()` ile açılır; üstünde
  yürürken dengeyle hafifçe yalpalar (eski `_plank.rotation.z`).
- **Hendek**: kıyı `EDGE_Z` uzak yakanın 1 m ötesi (eski de), kalasın karşı ucu `FAR_Z` yakın yakanın 0,6 m berisi (eski de).
  Eskinin kendi hendek duvarları (tırmanma için) yeni sette kurulmaz: setin taş duvarları var.
- **Düşme cezası** (karar 6: hendek 20 × 6 kalır, ceza 2× olmaz): eskide 2,9 m'lik duvara tutunulup çıkılıyordu; 6 m'lik
  taş yüz tırmanışı nefesi ve süreyi ikiye katlardı. Kalasın iki yanında (x ±2,3) hendeğin iç yüzüne dayalı birer **hücum
  merdiveni** (`Ladder`, 15°, W ile tırmanılır; tepesi kapak taşının üstünde). Can kaybı aynı (20).
- **Barikat**: bölümün 5 fıçısı eskisi gibi dış yüzün 0,6 m dışında, moloz sırtında (eski z 16,6 ↔ yeni 17,2); kanca yeri
  fıçılardan eskisi gibi 6 m (moloz yamacının ortası, yeni z 23,2); kancayı tutan azapların yerleri ve sıradaki üç azap aynı
  farkla; çıkışta (Cenevizliler) geri çekilen azaplar terasın ucunu geçmez (ötesi parateikhion ve hendek). Giustiniani gediğin
  ortasında, Cenevizlilerin çıkışı moloz sırtından; tüfekçi yeni dış sur yolunda; taş ve çömlekler yeni sur yolundan.
- **Barikatın ardı** (Bizans BattleExtras): eski şerit (z 7 ± 2,5) yeni peribolosta iç kulenin (x 0,2…9,2, z ≤ 8) ve deponun
  (x −11,5, z 4,2) içinden geçiyordu (ilk koşuda `VISAUDIT sunk` depo yığınında koşan, `testler/c37o_tur0/yeni_def_1`):
  yeni sette şerit dış surun dibine yakın (peribolos ucu − 1,7 m, en 2,2).
- `=yuru` (gerçek bot) ve `=kare` (6 an) eklendi; autotest faz süreleri `TASIMA6FAZ` (yalnız autotest).

### 2.2 Mesafe tablosu (eski ↔ yeni; gerçek botun yürüdüğü yol `testler/c37o_yuru`, m)

| çift | eski | yeni | fark |
|---|---|---|---|
| yürüyüş (ritimle, bölüm iter) | 32,5 | 32,5 | 0 |
| yürüyüşün sonu → kalas yığını → kıyı | 4,3 + 7,5 | 8,3 + 5,5 | +2,0 |
| kalasın üstü: kıyı → karşı uç (bot) | 19,4 | 23,4 | +4,0 (hendek 16 → 20 m) |
| kalasın ucu → kanca yeri (oyunda kararmayla geçilir; bot yürür) | 7,1 | 19,2 (parateikhion açıklığı, teras, moloz eteği) | +12,1 (≤ 20) |
| kanca yeri ↔ fıçılar | 6,0 | 6,0 | 0 |
| sürükleme (DRAG_FROM → DRAG_TO) | 28,5 | 28,5 | 0 |
| kalastan düşüş (kalasın üstü → hendek dibi) | 2,9 | 6,0 | +3,1 (dibe merdivenle çıkış) |

Oyuncunun yürüdüğü bütün hedefler ≤ 20 m (karar 1-A). Süreler (BEATS 16, STOCKADE_TIME 180, düello sınırı 45) aynı.

### 2.3 Gerçek bot (`=yuru`, son kod; `testler/c37o_yuru/yeni_son.ham`, `eski_son.ham`)

| set | bacak | takılma | düşme | tuş yok | süre | yol |
|---|---|---|---|---|---|---|
| yeni | 9 (Turgut, kalas yığını, kıyı, kalas ortası, kalas ucu, teras, yamaç eteği, kanca yeri, sürükleme) | **0** | **0** | 0 | 28,5 sn | 85,5 m |
| eski | 7 (teras ve yamaç bacağı yok: kalasın ucundan doğrudan kanca yerine) | 0 | 0 | 0 | 22,3 sn | 67,4 m |

Etkileşimler gerçek E tuşuyla (zil, kalas al, kalası indir): iki sette tuşsuz geçiş 0. (İlk turda eski sette botun kendi ara
noktası bir kez takılmıştı, `eski.ham`: eski sette o yol yok, oyunda kararmayla geçilir → eski sette o iki ara bacak atlanır.)

### 2.4 Testler (son kod; `testler/c37o_son`)

| çeşit | eski ×1 | yeni ×2 (+) | alanlar eski \| yeni |
|---|---|---|---|
| (varsayılan) | PASS | PASS PASS (+2 PASS) | 37O.1 · barrels 5/5 · falls 0 · arrows 0 · duel true · beats 12 \| 12–14 |
| lose | PASS | PASS PASS | 37O.2 · barrels 2/5 · falls 1 · duel false · beats 5 \| 4–5 · cuts 13 \| 0, 8 (rastgele: kaçan çekişte ip %50 kesilir) |
| trespass | PASS | PASS PASS | 37O.1 · caught 1 \| 1 |

**13/13 PASS, denetim satırı 0** (ilk turda yeni `def`'te `VISAUDIT sunk` — Bizans şeridi deponun içinden geçiyordu, §2.1;
düzeltildi). Faz süreleri (`TASIMA6FAZ`, oyun saniyesi, autotest 3× hız; eski | yeni medyan): yürüyüş 24,6 | 23,9 · barikat
23,9 | 23,7 · sürükleme 22,7 | 22,8 · kalas fazı iki sette de 90,0 (test botu kalasın son 0,6 m'sinde durur, 90 sn kaçış
yolu: eskide de aynı; oyuncu için değil). **Çıkış düellosu** (Cenevizliler, `WAVERUNNER`): kazanılan eski 9,7 · 12,0 (n 2) |
yeni 12,1 · 12,3 · 12,8 · 13,5 · 13,7 · 14,6 (n 6, medyan 13,2) → **yeni kısa değil**; kaybedilen eski 14,3 | yeni 10,3 · 10,6.

### 2.6 Kareler ESKİ | YENİ (oyuncu kamerası, `=kare`; `kare/c37o_eski`, `kare/c37o_yeni` = tur 3; ara turlar `kare/c37o_yeni_tur1`, `_tur2`)

| an | ESKİ | YENİ — tek cümle | hüküm |
|---|---|---|---|
| an_01 yürüyüş başı | bölük, ziller, ovanın ucunda alçak surlar, gedikte ateş | bölük, ziller, meşaleler, ovanın ucunda yeni surlar, gedik ve mazgallarda savunucular; kutu yok, havada duran yok, herkes ovaya oturuyor | **iyi** (tur 1: yürüyüş kalasla kaydırılınca bir batarya tabyası kameranın dibindeydi; tur 2: tabya hâlâ sol üstte, **havada** → kök neden `Assault` §4.1, düzeltildi) |
| an_02 kalas indi | sığ hendeğin üstünde tek dar kalas, sur tepesi savunucu dolu | derin hendeği ayaklarıyla aşan kalas köprü, iki yanda dayalı hücum merdiveni, ucunda poterna, mazgallarda savunucular, gedik yamacı; kalaslar tahta, kutu değil; köprü kıyılara oturuyor | **iyi** (tur 1: sur tepesi boş → Garrison `dense`) |
| an_03 kalasın ortası | kameranın dibinde patlama ateşi (eski: kötü kadraj) | köprünün ortasından poterna, dayalı merdiven, gediğin moloz yamacı ve fıçılar, mazgallarda savunucular | **kabul** (karanlık; tur 1: bakış göğe → barikata çevrildi) |
| an_04 kanca yeri, barikat | ip çeken azaplar eski moloz dilinin basamaklarında, sırtta fıçılar | ip çeken azaplar yeni gediğin moloz yamacında, sırtta beş fıçı; sırtın iki yanında havada gri moloz taşları (TUR 11'in `GedikMoloz` taşları, sonda §"görünüşe istek") | **kabul** (taşlar A'nın; benim `GedikOnarim` taşlarım oturuyor; tur 2'deki kalkan kümesi kaldırıldı) |
| an_05 Giustiniani (yandan) | patlama, fıçılar, azaplar | yamaçta iki azap, sırtta fıçılar ve Giustiniani, sağda patlama; mazgallarda savunucular | **kabul** (tur 2: ip çekenler Giustiniani'yi örtüyordu → yandan çekim; sağdaki patlama Assault'un rastgele atışı, eskide de var) |
| an_06 sürüklemeden geri bakış | ovada kalas, gedikte azaplar, surlarda savunucular ve ateş | önde kalas yığını, kıyıda kalas köprü ve iki merdiven, gedik yamacında azaplar, surlarda savunucular; kıyının önünde iki soluk düz zemin parçası (A'nın ova/kıyı levhası) | **kabul** (eskisi kadar ateşli değil: gece hücumunun alevleri eskide surun önündeydi) |

### 2.7 Bütçe (`=kare`, aynı an, 4 kare ortalaması; `kare/c37o_eski.log` ↔ `kare/c37o_yeni.log`; `testler/butce.py`)

| an | çizim eski → yeni | ilkel eski → yeni |
|---|---|---|
| yuruyus | 3.293 → 1.202 (−%63) | 2,54 M → 1,27 M (−%50) |
| kalas_indi | 3.650 → 1.164 (−%68) | 2,68 M → 1,20 M (−%55) |
| kalas_ortasi | 3.892 → 998 (−%74) | 2,87 M → 1,27 M (−%56) |
| barikat | 4.291 → 1.032 (−%76) | 3,44 M → 1,43 M (−%59) |
| giustiniani | 4.719 → 1.012 (−%79) | 3,87 M → 1,64 M (−%58) |
| geri_bakis | 4.644 → 1.252 (−%73) | 3,13 M → 1,37 M (−%56) |

Hepsi eskinin altında. Kare günlüklerinde denetim satırı 0.

### 2.5 Yön replikleri (metin DEĞİŞMEDİ; `docs/_kanit_ist2_sur_arayuz/yon_replikleri.md`'nin 37O satırları + hendek/kalas geçenler)

| anahtar | yön | yeni sette |
|---|---|---|
| `D37O_AB_02` "bir adım" | ritim | uyumlu (yürüyüş aynı uzunlukta, bölüm iter) |
| `D37O_AB_POT` "Sağa çek" | oyuncuya göre | uyumlu (çömlek oyuncunun yanına düşer; kod aynı) |
| `D37O_HZ_SALLY` "sol yanındayım" | oyuncuya göre | uyumlu (Hızır dost düellocu; kod aynı) |
| `D37O_AB_03` "Hendek! Kalası indir." | — | uyumlu (kıyı, kalas) |
| `D37O_AB_FALL` "duvara tutun, yukarı!" | — | uyumlu sayılır: duvara tutunup tırmanmak da (6 m, Traversal) mümkün, iki yanda dayalı merdiven de var |
| `D37O_T_DRAG` "Kalası geçince düzlük" | — | uyumlu (sürükleme ovada, iki sette aynı) |

---

## 3. Bölüm 32o (Son Gün, 28 Mayıs) — `scripts/chapter32o.gd`

### 3.1 Ne değişti (yalnız yeni set; `--eskisur` yolu eskinin aynısı)
- `ESKI_SUR` + `SurSet.sec("32o", …)`; yeni sette `SurSetSahne` (`dolgu` 0,5: gediğin önündeki dolgu önceki haftalarda yarıya
  dek dolmuş; 26o'da tam). Bölümün bütün işi hendeğin önünde, ovada (22o kalıbı): `PILE`, `EARTH`, `COVERS` (mantolar),
  `BENCH` (Usta Mahmud), `MANTLET_FROM/TO`, `FIRE_Z` (akşam ateşleri), `KADRI_POT`, `HASAN_FIRE`, tellal, azap, demet
  taşıyanlar, ova sınırı, zemin ayrıntısı, kamera kareleri **eski + `ova_ofs`** → aralarındaki bütün mesafeler eskiyle aynı;
  kıyı `EDGE_Z` uzak yakanın 1,4 m ötesi (eski de). Süreler (DITCH_TIME 240, yaylım 13/2,6 sn, Rum ateşi 15 sn) aynı.
- Hendeğin içi (atılan demetler, toprak, Rum ateşi, önceden atılmış demetler): eski hendekteki oranlarıyla yeni hendekte
  (`_hendek_p`: z oranı, dipten yükseklik); gediğin önündeki yarı dolu dolgunun üstüne düşen demet dolgunun yüzüne konur
  (aşağı ışın; dibe konsa toprağın içinde kalırdı).
- Ali'nin bataryası: hedef yeni gedik (`sur.gedik()`); ıskalayan gülle surun önündeki gerçek zemine.
- Sur yolundaki savunanlar: Garrison `dense` (22o kalıbı: yeni dış surun dişleri insan boyu, yolun iç yanı ovadan görünmüyor).

---

### 3.2 Testler (`testler/c32o`)

| çeşit | eski ×1 | yeni | alanlar (eski = yeni) |
|---|---|---|---|
| (varsayılan) | PASS | PASS PASS | 32O.1 · bundles 6/6 · earth 2 · rungs 6 · hits 3/3 · fires 6 · greek 2/2 |
| late | — | PASS | 32O.2 · bundles 4/6 · hits 0/3 (beklenen) |
| cracked | — | PASS | 32O.1 · hits 3/3 |
| gunner | — | PASS | 32O.1 |
| named | — | PASS | 32O.1 |
| council_ok | — | PASS | 32O.1 |
| council_bad | — | PASS | 32O.1 |

**Yeni 8/8 PASS, eski 1/1 PASS, denetim 0.** İlk koşu (`tur0_yeni_def_1`) FAIL idi: `hits=0/3` — Ali'nin güllesi namludan
çıkar çıkmaz (`CREW impact … t=0.04 at=(8,2; −1,1; 118,8)`) "yere düştü": `CannonCrew.ground_y` 0'da kalmıştı, yeni ova
−3,57'de (20o `sur.ova_y()` veriyordu). Düzeltildi (yalnız yeni set).

### 3.3 Yapılmayanlar (32o)
Eski ×1 yalnız varsayılan çeşitte; gerçek bot (`=yuru`), ESKİ|YENİ kareler, bütçe ve mesafe tablosu **yapılmadı** (süre 20 ve
37o'ya gitti). Ova içindeki bütün mesafeler kaydırmayla eskiyle aynı (kurgu gereği); hendek içi oranla. Yön repliği
`D32O_AZ_B3` "Sağdaki bölük" (demet taşıyan yan bölük x 17/22; kaydırmayla aynı yerde) — uyumlu.

## 4. Ortak sınıflarda yapılanlar (yalnız yeni set yolu; eski yol bit bit aynı)

### 4.1 `Assault`: ovadaki batarya, tabya ve mancınık yeni sette havadaydı (`scripts/level/assault.gd`, `_sura_bak`)
- Sonda (`chapter37o --autotest=yuru --sonda37`, `testler/sonda/c37o_an01b.ham`): 37o yürüyüş karesinin sol üstündeki yakın
  yapı `AssaultOva/…/MeshInstance3D` (tabyanın yan seti, 3 × 1,6 × 6), merkezi **y 0,5**, altındaki ova **y −3,58**; tabya
  düğümünün küresel yeri (−24; 0; 81) = ova koordinatının kendisi (ova düğümü (0; −3,55; 10,6)).
- Kök neden: `_batteries`, `_earthwork`, `_trebuchet` yapıyı `look_at_from_position(p, …)` ile yerleştiriyor; bu işlev
  **küresel** konum alır. Eski sette ova düğümü Assault'un kendisi (yerel = küresel); yeni sette ova düğümü kaydırılmış →
  bütün bataryalar, tabyalar ve mancınıklar yeni ovanın **3,55 m üstünde (havada)** ve 10,6 m önde kuruluyordu (Bölüm 0, 20,
  32o, 37o: yeni sette Assault kullanan bütün bölümler).
- Düzeltme: `_sura_bak(n, p, k)` — ova düğümü Assault'un kendisiyse eski çağrının aynısı; değilse konum ve bakış hedefi ova
  düğümünden küresele çevrilir. Varsayılan (eski set) davranış aynı dallar, aynı sayılar.
- Bunu kullanan bölümler ×1: Bölüm 0, 20 (def + hit ×2), 32o, 37o (§2, §3, `testler/c20_assault`, `testler/ortak`).

### 4.2 `GedikOnarim` (sahiplik: bu taşıma): moloz üstündeki kırık taşlar enine kesite oturur (`sur_oyun_parca.gd`)
- `kur`'daki 40 kırık taşın y'si moloz profilinin ORTA yüksekliğinden alınıyordu (±3 m'ye dek); tümseğin kesiti (`_tumsek`)
  ±1,05'ten sonra alçalır (±3'te %35, ±4,6'da taban). Yamaçta (sırt ile teras arası, düşüş 2–5 m) yandaki taşlar 0,8 m'ye
  dek havada kalıyordu. Şimdi aynı kesitle. Rastgele dizi aynı (taşların x/z'si, boyu, dönüşü aynı); çarpışma yok (görsel).
- Bu sınıfı kullanan bölümler (yeni set): 0, 20, 20o, 21, 22, 22o, 25, 32o, 37o — ×1 (§1, §2, §3, `testler/ortak`).

### 4.3 Ortak değişikliklerden sonra kullanan bölümler ×1 (`testler/ortak`, `testler/c20_assault`, §2.4, §3.2)
Bölüm 0 PASS (`froze=true`), 20 `def` + `hit` ×2 PASS, 20o (§1.4) 10/10 PASS, 21 PASS (21.1), 22 PASS (22.1), 22o PASS (22O.1,
`gun=3/4 carry=0.75`), 25 PASS (25.1), 32o 9/9 PASS, 37o 13/13 PASS — **denetim satırı 0**, alanlar taşıma 4/5 raporlarıyla aynı.

### 4.4 Sözleşme (son kod, `testler/soz_son`)
`SURSOZLESME PASS kalem=13 kesim=8` · `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` · `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0`
— aynı (ilk kayıttaki `testler/soz` ile).

---

## Değişen dosyalar
- `scripts/chapter20.gd`: `_yaklasma` (siperi dolanan iki ara nokta; 1. dalga teras eteğinden, 1,2 sn), `=hit` yeri (yeni set),
  sondalar (`_t6_sonda` → `TASIMA6DUELLO`, `--sonda6` → `SONDA6`; yalnız autotest).
- `scripts/chapter37o.gd`: yeni sur bağdaştırıcısı, setin kalas köprüsü, hendek merdivenleri, Bizans şeridi, garnizon (yeni),
  `=yuru`, `=kare`, sondalar (`TASIMA6FAZ`; `--sonda37` → `SONDA37`/`SONDA37K`; yalnız autotest), AUTOTEST satırına `sur=`.
- `scripts/chapter32o.gd`: yeni sur bağdaştırıcısı (ova kaydırması, hendek oranı, dolgu üstü), AUTOTEST satırına `sur=`.
- `scripts/level/assault.gd`: `_sura_bak` (ova yapılarının yeri; ova düğümü Assault'un kendisiyse eski çağrının aynısı).
- `scripts/world/ist/sur_oyun_parca.gd`: yalnız `GedikOnarim.kur` — moloz üstü kırık taşların yüksekliği tümseğin enine kesitine
  (görsel; çarpışma yok, rastgele dizi aynı).
- Kanıt: `docs/_kanit_ist2_tasima6/` (`.gdignore`'lu: kareler içe aktarılmaz).

## run_tests.sh isteği
Paket değişmedi. Öneri: `--chapter=37o --autotest=yuru` (çıktıda `TASIMA37OYURU OZET … takilma=0 dusme=0`); Bölüm 20 `=hit`
çeşidinde `VISAUDIT` sayısının 0 olduğu (×3) denetimi.

## Sonraki taşıyana
1. **Düello yolu bitişi**: `WaveRunner` `via`'nın son noktası açık zeminde olmalı. Yol bir katının (toprak set, siper) yanında
   biterse rakip oradan oyuncuya inerken sıkışır, test botu (`Duel._bot`) yolu bitmiş rakibe yürüyüp katıya yapışır; dalga sonu
   evine ancak 1,5 m'den uzaksa döner (Bölüm 20 `=hit`, bu rapor §1). `--sonda6` (chapter20) oyuncunun yörüngesini verir.
2. **Yol uzarsa süre değişir**: 6 m'lik ek yol 1. dalgaya +3,5 sn ekledi; çıkış yeri ve kademe (`YAKLASMA_*`) ile dengelendi.
   Ölçüm en az ×6 ve bütün çeşitler: çeşitler arasında fark büyük (`tape` 2. dalga hep uzun).
3. **Parateikhion**: yeni setin teras ucundaki alçak duvar (1,6 m) yalnız geçişlerin (dolgu x 0 ± 5, kalas x −17,9) önünde
   açık. Terastan hendeğe/hendekten terasa her yol bu açıklıklardan geçmeli (37o: kalas setin kalas geçidine taşındı).
4. **Kalas köprü**: setin `KalasKopru`'su yerinde canlandırılabilir: bir mil düğümüne alıp (global dönüşüm korunur) döndür/indir;
   `tak()`/`sok()` çarpışmayı açar/kapar (37o `_kalas_indir`).
5. **Hendekten çıkış**: 6 m'lik hendekte düşme cezası eskisi gibi kalsın diye dayalı `Ladder` (37o). 36b'nin kalası da aynı
   geçitte (poternanın önü): aynı merdivenler kullanılabilir.
6. **Kare kipi**: ovada bir şeyi x'te kaydırmadan önce yeni setin batarya yuvalarına bak (`sur.top_yuvalari`; Mesoteikhion'da
   x −24 ve 18, z ≈ 91,6): 37o yürüyüşünün başı oraya düşmüştü.

## Hâlâ kötü olanlar (dürüst)
- **37o kalasta denge (gerçek oyuncu)**: köprü artık 1,6 m enli, ayaklı setin kalas köprüsü (eskide 0,55 m'lik tek kalas); denge
  ibresi ve düşüş kodu aynı (A/D; ibre kenara giderse yana düşülür) ama geniş köprüde "tek kalasın üstünde yalpalama" hissi zayıf.
  Kalas inişi eskinin −60°'lik savruluşu yerine −14° + 1,2 m iniş (22 m'lik köprü).
- **37o kalastan karşıya ve kanca yerine**: oyunda kararmayla geçilir (eskide de); gerçek yürüyüş yeni sette 19 m (teras boyunca),
  eskide 9 m. Oyuncu bunu yürümez ama botla ölçüldü.
- **37o test botu kalas fazında**: iki sette de 90 sn kaçış yoluyla biter (kalasın son 0,6 m'sinde durur) — taban davranışı,
  dokunulmadı; gerçek botla kalas yürüyüşü ayrıca ölçüldü (takılma 0).
- **37o kareleri** eski setteki gece hücumu kadar ateşli değil (eskide surun önünde yangınlar, kırmızı surlar); an_05'te
  Giustiniani küçük ve sağdaki rastgele patlama kadrajı kalabalıklaştırıyor; an_04'te sırtın iki yanında A'nın havada duran moloz
  taşları.
- **Bölüm 20**: 1. dalga 12,2 sn (taşıma 4: 11,4; eski set 9,0); `tape` 2. dalgası 31,8 sn (n 2; taşıma 4: 24,3); `=hit` 2.
  dalgası 18,6 sn (taşıma 4: 22,3: eskiden bot sete yapışık dövüşüyordu).
- **32o** yalnız testlerle doğrulandı: kare, bütçe, gerçek bot yok. Gediğin önündeki dolgu 0,5 doluluğuyla kuruldu (seçim; 26o'da
  tam): sahibin onayı gerekebilir.
- **36b** yapılmadı.
- İlk kaydın (`e4d47980`) iletisinde ortak yazar satırında model adı geçti (kural: kayıt iletisine model adı yazılmaz);
  sonraki kayıtlarda yok. Geçmiş yeniden yazılmadı (yasak).

## Görünüşe istek (TUR 11 / A'nın dosyaları; dokunulmadı)
- **Gedik molozunun taşları havada** (`OyunDilimi/Mesoteikhion/@MultiMeshInstance3D`, `GedikMoloz` taş saçılımı; `surlar*.gd`):
  37o kanca yerinin önündeki ~30 taştan 6'sı dış yamaçta zeminin 1,1–3,0 m üstünde — ör. (−3,98; 0,52; 16,66) zemin −2,50;
  (3,63; 0,41; 18,44) zemin −2,10; (−2,1; 0,52; 20,01) zemin −1,25 (sonda `testler/sonda/c37o_kanca.ham`, `SONDA37K mm`).
  Kare `kare/c37o_yeni/an_04_barikat.jpg` (sırtın iki yanında gri çokgenler). Taşların y'si büyük olasılıkla molozun iç
  (peribolos) profilinden; dış yamaçtaki taşlar yamacın üstünde kalıyor. Aynı hata `GedikOnarim`'da vardı (§4.2, düzeltildi).
- **Ova kıyısında soluk düz dikdörtgenler** (kare `kare/c37o_yeni/an_06_geri_bakis.jpg`, kıyının önünde iki soluk düz zemin
  parçası): kesimin ova/kıyı levhası ya da dolgu geçidinin kapağı olabilir; sondalanmadı.
