# TAŞIMA-6 — Bölüm 20 `=hit` gerilemesi; 37o yeni surda; 32o bağdaştırıcısı

> Dal `wip/ist2-tasima6`, taban `wip/ist2-taban11` 2fa8fb35. Makine: 4 çekirdek; ekransız testler `--max-fps 20`
> (`testler/kos1.sh`, toplu `testler/toplu.sh`), kareler xvfb + Mesa llvmpipe (yazılımsal GL), 1280×720 jpg 85
> (`testler/kare.sh`). Ham günlükler `testler/**.ham`; yanındaki süzülmüş dosya `kos1.sh`'in süzgeci
> (`AUTOTEST (PASS|FAIL)|SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|WARN_FLY|WARN_VOID` + `KOSU|WAVERUNNER|GUN|CESET4|TASIMA6`).
> Dalga tabloları `testler/dalga.py` (küme) ve `testler/cesit.py` (çeşit başına) ile süzülmüş dosyalardan. **ESKİ** = `--eskisur`.
> Dokunulmayanlar: sur görünüş dosyaları (TUR 11), `scripts/npc|ui|player/`, ortak sınıflar (`WaveRunner`, `Duelist`, `Melee`,
> `Duel`, `Garrison`, `Assault`, `SurSet`, `SurSetSahne`, `sur_oyun_parca.gd` dahil: bu dalda HİÇBİRİ değişmedi), `sur_sozlesme*`,
> `tests/run_tests.sh`, `project.godot`, `game_state.gd`; replik metni, ses, can/hasar, dalga sınırı (60 sn), düşman sayısı,
> gizli süreler (STOCKADE_TIME 180, BEATS 16, DITCH_TIME 240), sayaçlar. Yeni sesli replik yok.

(SÜRÜYOR — aşağıdaki bölümler sonuçlar geldikçe dolduruluyor.)

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

### 2.3 Gerçek bot (`=yuru`)

| set | bacak | takılma | düşme | tuş yok | süre | yol |
|---|---|---|---|---|---|---|
| yeni (`testler/c37o_yuru/yeni.ham`) | 9 | 0 | 0 | 0 | 27,2 sn | 81,4 m |
| eski (`testler/c37o_yuru/eski.ham`, ilk tur) | 9 | 1 | 0 | 0 | 28,5 sn | 67,8 m |

Eski setteki tek takılma botun kendi ara noktasında (kalasın ucundan eski teras boyunca x −3,5'e; eski sette oyuncu oraya
kararmayla geçer, yol yok); son kodda eski sette o iki ara bacak atlanır (yeniden ölçüm §2.3b).

### 2.5 Yön replikleri (metin DEĞİŞMEDİ; `docs/_kanit_ist2_sur_arayuz/yon_replikleri.md`'nin 37O satırları + hendek/kalas geçenler)

| anahtar | yön | yeni sette |
|---|---|---|
| `D37O_AB_02` "bir adım" | ritim | uyumlu (yürüyüş aynı uzunlukta, bölüm iter) |
| `D37O_AB_POT` "Sağa çek" | oyuncuya göre | uyumlu (çömlek oyuncunun yanına düşer; kod aynı) |
| `D37O_HZ_SALLY` "sol yanındayım" | oyuncuya göre | uyumlu (Hızır dost düellocu; kod aynı) |
| `D37O_AB_03` "Hendek! Kalası indir." | — | uyumlu (kıyı, kalas) |
| `D37O_AB_FALL` "duvara tutun, yukarı!" | — | uyumlu sayılır: duvara tutunup tırmanmak da (6 m, Traversal) mümkün, iki yanda dayalı merdiven de var |
| `D37O_T_DRAG` "Kalası geçince düzlük" | — | uyumlu (sürükleme ovada, iki sette aynı) |
