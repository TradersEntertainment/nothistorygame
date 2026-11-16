# TAŞIMA-5 — Bölüm 22 ve 22o yeni surda; küçük kalanlar

> Dal `wip/ist2-tasima5`, taban `wip/ist2-taban10` 0ded6ea0. Makine: 4 çekirdek; ekransız testler `--max-fps 20`
> (`testler/kos1.sh`, toplu `testler/toplu.sh` + `kos1_tek.sh`), kareler xvfb + Mesa llvmpipe (yazılımsal GL), 1280×720 jpg 85
> (`testler/kare.sh`). Ham günlükler `testler/**.ham`; yanındaki süzülmüş dosya `kos1.sh`'in süzgeci
> (`AUTOTEST (PASS|FAIL)|SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|WARN_FLY|WARN_VOID` + `KOSU|WAVERUNNER|GUN|CESET4`).
> **ESKİ** = `--eskisur` (aynı kod, LandWalls seti). Ortak sınıflar (`WaveRunner`, `Duelist`, `Melee`, `StoryDuel`, `Garrison`,
> `WallFight`, `SurSet`, `SurSetSahne`) bu dalda **DEĞİŞMEDİ**; A'nın yardımcısı `SurOyunAg._tumsek/pis` yalnız ÇAĞRILDI.
> Dokunulmayanlar: A'nın ve B'nin dosyaları, `scripts/npc|ui|player/`, `sur_sozlesme*`, `tests/run_tests.sh`, `project.godot`,
> `game_state.gd`; replik metni, ses, süreler (fitil 2,6 sn, bant, yuvarlanma 1,0 + 1,2 sn, ok yaylımı 22/3 sn, yangın 26 sn,
> deri 2,6/3,4 sn), sayaçlar, can/hasar, düşman sayısı. Yeni sesli replik yok.

## Özet

| # | Madde | Durum | Kısa |
|---|---|---|---|
| 1a | Bölüm 22 yeni surda | **TAMAM** | SurSet bağdaştırıcısı + `--eskisur`; oluk ve fıçılar eski yerinde, aşama 4'ün gedik üstü sur yolu tahtasında; kule hendeğin ötesinde (ova kaydırması); fıçı izi oluk → moloz yamacı → teras → dolgu → kule dibi (süreler aynı). Yeni 7 çeşit ×2 **14/14 PASS**, eski ×1 **7/7 PASS**, denetim 0; `=yuru` takılma 0 düşme 0 (iki set) |
| 1b | Bölüm 22o yeni surda | **TAMAM** | ova içeriği `ova_ofs` ile yeni ovaya (iç mesafeler AYNI); kule önü dolgusu uzak yakadan dolan kendi tümseğim (setin dolgu yardımcısıyla); tüfek hedefleri yeni sur yolunun mazgallarında. Yeni 6 çeşit ×2 **12/12 PASS**, eski ×1 **6/6 PASS**, denetim 0; `=yuru` 20 bacak takılma 0 düşme 0 tuş 0 (iki set aynı, 80 sn) |
| 1c | Düello (22o çıkış düellosu) süresi | **TAMAM** | kazanılan düello medyan eski 18,6 sn [10,8–34,3] (n 5) ↔ yeni 28,1 [23,9–33,7] (n 10): yeni kısa DEĞİL |
| 1d | Kareler ESKİ\|YENİ | bkz. §1.6 | |
| 1e | Bütçe | bkz. §1.7 | |
| 2 | Bölüm 28o | **YAPILMADI** | yeni sette "sağlam sur" (gediksiz) seçeneği yok: 28o 11 Nisan, sur sağlam (`LandWalls.intact`); gedik `surlar.gd`/`SurOyun.kur` kesiminin parçası (A) → **A'ya istek** |
| 3a | Bölüm 21 an_01 gri dörtgen | **KAYNAK BULUNDU — A'nın dosyası** | `--golgesiz5` ile de duruyor (gölge değil); üçgen düzeyinde piksel sondası (`--pik5`): gri yüzey peribolosun çıplak zemin ağı `OyunDilimi/Mesoteikhion/@MeshInstance3D@1366`, dokulu kısım `SurDibiEtek` (iç surun ve iç kulenin eteği; iç kule eteği x −2,8'den sağda). "Dörtgen" = iki eteğin örtmediği peribolos zemininin dokusuz, düz görünüşü → **görünüşe istek** |
| 3b | Bölüm 20 dost asker terasa | **YENİDEN ÜRETİLEMEDİ** | `--sonda4` 4 koşu (def ×2, late, tape): hiçbir dost (tk=0) gedikten dışarı (z > 17) ya da aşağı (y < −0,8) çıkmadı. İncelenen yollar §3b; kod değişmedi |
| — | Sözleşme | **TAMAM** | `SURSOZLESME PASS kalem=13 kesim=8` · `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` · `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` (`testler/soz/`) |

---

## 1. Bölüm 22 (Bizans, sur üstü) — `scripts/chapter22.gd`

### 1.1 Ne değişti (yalnız yeni set; `--eskisur` yolu eskinin aynısı)
- `ESKI_SUR` + `SurSet.sec("22", …)`; yeni sette `SurSetSahne` (onarım 10 → aşama 4: barikat tam, **sur yolu tahtası gediğin
  üstünde**). Eskinin kalas köprüsü + iskelesi (Props.box dikmeler, kuşaklar) yeni sette KURULMAZ: setin kendi tahtası var.
- Sabitler değişkene döndü: `WALK_Y` = `sur.dis_yol_y()` (8,62), `YOL_Z` = `sur.dis_yol_z()` (15,3), `CHUTE` = (−2,5; 8,62;
  `dis_sur_z1 − 0,2` = 16,4), `BARRELS` = (3,5; 8,62; 15,3), `TOWER` = eski + `ova_ofs` = (−3; −3,545; 50,6).
- Oluğun önü: sondada (`tests/_ist/tasima5_sonda.tscn`, `~/is/sonda5.log`) aşama 4 tahtası x −4…3,5'te y 8,62, **ova kenarında
  diş yok** → yalnız orada eskinin görünmez korkuluğunun eşi (`_build_yeni_yol`, x ±5,1, dış yüzün 0,12 m ötesi).
- Fıçı izi (`_yuvarlanma_izi`, `_yer`): oluğun tahtası boyunca, ucundan moloz yamacına düşer, yamaçtan terasın ortasına (z 21:
  "yamaçta patladı"), parapetin dolgu önündeki açıklığından setin dolgusuna (x 0, en 10), dolgudan kulenin dibine. Zemin
  çarpışma ışınıyla (SurSet.zemin_y dolgunun gerçek yüzünü 0,5 m yüksek veriyor). Süreler eskinin aynısı (1,0 + 1,2 sn).
- Erken bırakılan fıçı: iki asker dolgunun yanından 6 m'lik hendeğin dibine iter (x −8,6; eski "1,5 m aşağı").
- Hendeğin kule önü dolgusu: eskide 10×3,2×16 kutu; yeni sette setin kendi dolgusu (`SurSetSahne.dolgu` 1).
- Garnizon/kazan/onarım ekibi/taşıyıcı/okçular yeni setin sorgularıyla (Bölüm 20'nin yerleri); peribolos ateşleri engel sınamalı.
- Şafak: oyuncu gediğin solundaki ilk **mazgal açıklığında** (x −6,9; eski −8): −8'de dişin tam arkasındaydı, kule görünmüyordu
  (ilk tur karesi). Giustiniani şafakta oyuncudan 2 m (eskide de 2 m), gecede yolun iç yanında (yolun ortası oluğun önünü
  kapatıyordu: bot oluğa 5,3 sn'de varabildi).
- `=yuru` (gerçek bot: fıçı al → oluk → yak → 0,55'te bırak, ×2, gerçek tuşlar) ve `=kare` (6 an; çekimde fitil durur).

### 1.2 Testler (`testler/c22_yeni`, `testler/c22_eski`)

| çeşit | eski ×1 | yeni ×2 | alanlar (eski = yeni) |
|---|---|---|---|
| (varsayılan) | PASS | PASS PASS | outcome 22.1 hits 2 singed false window 0.42–0.68 |
| brow | PASS | PASS PASS | 22.2 hits 2 singed true |
| miss | PASS | PASS PASS | 22.3 hits 0 |
| cologne | PASS | PASS PASS | 22.1 hits 2 (kolonya) |
| early | PASS | PASS PASS | 22.3 hits 0 |
| blakh_ok | PASS | PASS PASS | 22.1 hits 2 window 0.36–0.74 |
| blakh_bad | PASS | PASS PASS | 22.3 hits 0 window 0.46–0.64 |

Denetim satırı (süzgeç) **0**. `TESPITBLOCK who=siege22 blocker=Skeleton/Mesh` (oyuncunun kendi gövdesi) eskide de var; süzgeç dışı.

### 1.3 Gerçek bot yürüyüşü (`=yuru`, `testler/eski/c22_yuru.ham`, `testler/c22_yeni/c22_yuru_r1.ham`)

| set | bacak | takılma | düşme | tuş yok | süre | yol | isabet |
|---|---|---|---|---|---|---|---|
| eski | 4 | 0 | 0 | 0 | 7,5 sn | 17,7 m | 2 |
| yeni | 4 | 0 | 0 | 0 | (bkz. §1.8 son koşu) | | 2 |

### 1.4 Mesafe tablosu (eski ↔ yeni; yatay / 3B, m)

| çift | eski | yeni | fark |
|---|---|---|---|
| gece doğuşu ↔ fıçılar | 4,2 | 4,2 | 0 |
| fıçılar ↔ oluk (oyuncunun yürüdüğü döngü) | 6,8 | 6,8 | 0 |
| oyuncu ↔ Giustiniani (gece) | 2,2 | 2,3 | +0,1 |
| oluk ↔ kule dibi (fıçının yolu; yürünmez) | 24,2 / 25,5 | 34,2 / 36,3 | +10,0 (≤ 20) |
| şafak yeri ↔ kule (tespit; TespitCam en çok 60) | 25,5 / 26,7 | 35,5 / 37,5 | +10,0 |

Oyuncunun yürüdüğü bütün hedefler ≤ 7 m (karar 1-A: ≤ 20 m).

### 1.5 Yön replikleri — `yon_replikleri.md` (metin DEĞİŞMEDİ). 22'de hepsi uyumlu.

### 1.6 Kareler (oyuncu kamerası) — `kare/c22_eski`, `kare/c22_yeni2` (ilk tur `kare/c22_yeni`)
(doldurulacak)

### 1.7 Bütçe
(doldurulacak)

---

## 2. Bölüm 22o (Osmanlı, hendeğin önü) — `scripts/chapter22o.gd`

### 2.1 Ne değişti (yalnız yeni set)
- `ESKI_SUR` + `SurSet.sec("22o", …)`; yeni sette `SurSetSahne` (`dolgu` 0: setin gedik önü dolgusu boş, bu gece dolar).
- **Ova kaydırması**: bölümün bütün işi hendeğin ötesinde. Sabitler (`TOWER`, `PILE`, `DROP`, `HIDE_PILE`, `WATER`, `COVERS`)
  ve ovaya mutlak koordinatla konan her şey (yürünür zemin, kıyı sınırı, meşaleler, çadırlar, sepet siper sıraları, ateşler,
  pavezli okçular, bölükler, zemin ayrıntısı, ayak izi yolu, işçi zincirleri, ok yaylımının yere saplanan okları, botun kıyı
  noktası, kare kameraları) `O = sur.ova_ofs()` = (0; −3,545; 10,6) alır → **aralarındaki bütün mesafeler eskiyle aynı**.
- Hendek: eski 16 × 2,9 → yeni 20 × 6. Kule önü dolgusu (`_dolgu_uzak`): setin `Dolgu` parçası yakın (sur) yakadan dolduğu için
  kullanılmadı; aynı biçim (tümsek, 32° şev, omuz 2 m), aynı yardımcı (`SurOyunAg._tumsek` + `pis`), aynı toprak rengi, setin
  dolgu geçidinin yerinde (x 0, en 10), **Osmanlı (uzak) yakasından** dolar: sepet başına 0,25 (üç sepet 0,75), şafakta tam.
  Kıyıdan dökülen toprak 6 m'lik dibe (dolgu yükseldikçe daha az) düşer.
- Hendek kalabalığı (BattleExtras) yeni hendeğin aynı oranındaki z'sinde, dolgunun dışında; sur dibi şeridi terasta.
- Kuleden tüfek: hedefler yeni dış sur yolunda, **mazgal açıklığında** (`_mazgal_x`; dişler insan boyu); WallCrowd kutusu iç
  surdan dış surun ova yüzüne (`_sur_kutusu`). İkinci gecenin fıçıları yeni dış surun yolundan yuvarlanır, orta noktası dolgunun
  üstü (ova kaydırmasıyla).
- `=yuru` (gerçek bot: Hasan → sepet ×3 → kıyı → deri ×3 → kule önü, E basılı çak/çek → su → ıslat; siper ve kule gövdesini
  dolanan ara noktalar iki sette aynı) ve `=kare` (7 an).

### 2.2 Testler (`testler/c22o_yeni`, `testler/c22o_eski`)

| çeşit | eski ×1 | yeni ×2 | alanlar (eski = yeni) |
|---|---|---|---|
| (varsayılan) | PASS | PASS PASS | 22O.1 saved 3 gun 3/4 warn 3 carry 0.75 |
| late | PASS | PASS PASS | 22O.2 saved 2 |
| lose | PASS | PASS PASS | 22O.2 saved 2 (düello yenilgisi) |
| twins_late | PASS | PASS PASS | 22O.1 saved 3 (Hüseyin) |
| blakh_ok | PASS | PASS PASS | 22O.1 warn 5 |
| blakh_bad | PASS | PASS PASS | 22O.1 carry 0.60 |

Denetim satırı **0**. Tüfek `gun=3/4` bütün koşularda iki sette aynı.

### 2.3 Düello (kule dibindeki çıkış düellosu, `STORYDUEL t=`, sn)

| küme | kazanılan | kaybedilen (lose) |
|---|---|---|
| eski (×1, 5 çeşit) | medyan **18,6** [10,8–34,3] (n 5) | 21,4 |
| yeni (×2, 5 çeşit) | medyan **28,1** [23,9–33,7] (n 10) | 33,4 · 34,3 |

Yeni eskiden kısa değil (daha uzun; düellonun yeri ve rakip sayısı aynı, `StoryDuel`/`Duelist` değişmedi: fark ovanın zemin
gövdesinden ve dağılımdan; ölçüm ×6+).

### 2.4 Gerçek bot yürüyüşü (`testler/c22o_yeni/c22o_yuru_r1.ham`, `testler/c22o_eski/c22o_yuru_r1.ham`)

| set | bacak | takılma | düşme | tuş yok | süre | yol | sonuç |
|---|---|---|---|---|---|---|---|
| eski | 20 | 0 | 0 | 0 | 80,1 sn | 179,5 m | sepet 3 deri 3 ıslak |
| yeni | 20 | 0 | 0 | 0 | 80,3 sn | 179,5 m | sepet 3 deri 3 ıslak |

(İlk turda ara noktasız: iki sette de aynı 4 takılma — botun düz çizgisi siperin ve kulenin gövdesine; ara noktayla 0.)

### 2.5 Mesafe tablosu
Ova içindeki bütün çiftler (Hasan, sepet yığını, kıyı, deri yığını, kule önü, su fıçısı, siperler) **eskiyle aynı**
(aynı kaydırma; en uzun yürüyüş su ↔ kule 16,8 m). Değişenler: kıyı ↔ hendek dibi 2,9 → 6,0 m (düşüş); kule tepesi ↔ dış sur
yolu (tüfek) yatay 23,6 → 33,6 m, kule tepesinin sur yolundan yüksekliği 5,5 → 1,4 m (bkz. yön replikleri D22O_H_GUN).

### 2.6 Kareler — `kare/c22o_eski`, `kare/c22o_yeni`
(doldurulacak)

---

## 3. Küçük kalanlar

### 3a. Bölüm 21 an_01 — Grant'in altındaki gri, düz kenarlı dörtgen
- Sonda: `tests/_ist/tasima5_pik.gd` (bölümün `=kare`'sinden çağrılır; `--pik5=x,y;…` piksellerin ışınıyla **üçgen düzeyinde**
  ilk kesişen ağlar; `--golgesiz5` yönlü ışıkların gölgesini kapatır; `--gizle5=ad`). Çıktı `kare/c21_pik.log`,
  `kare/c21_pik_golgesiz.log`; kare `kare/c21_pik_golgesiz/an_01_acilis_grant.jpg`.
- Gölgesiz karede dörtgen **aynı** → gölge değil. Piksel (640,600) ve (300,640) [dörtgenin içi]: ilk ağ
  `SurCerceve/SurOyun_mesoteikhion/OyunDilimi/Mesoteikhion/@MeshInstance3D@1366` (peribolos zemini; AABB y −7,6…0,1,
  z −10…25,7), d 3,4–3,6 m. Piksel (150,560) [dörtgenin dışı, dokulu]: önce `SurDibiEtek`, sonra aynı zemin.
- Yani "dörtgen" bir nesne değil: iç surun ve iç kulenin **sur dibi eteklerinin örtmediği peribolos zemini**, dokusuz ve düz
  (eteğin kenarı kadrajda düz bir çizgi; iç kule eteğinin batı kenarı x −2,8 sağdaki çapraz çizgi). Kaynak A'nın zemin/etek
  dosyaları (`sur_zemin.gd`, `sur_oturtma*.gd`) → **görünüşe istek**. `chapter21.gd`'ye yalnız sonda çağrısı eklendi
  (argümansız hiçbir şey yapmaz).

### 3b. Bölüm 20 — dost asker gediğin dış yanından terasa
- Sonda `--sonda4` (taşıma 4'ün `SurSetSahne.CesetSayac` satırı, tk=0 dost): `testler/sonda/c20_def_s1/s2`, `c20_late_s3`,
  `c20_tape_s4` — 4 koşu, **dışarı/aşağı çıkan dost 0** (süzgeç: z > 17 ya da y < −0,8). Hepsi PASS, CESET4 düşen 0.
- İncelenen yollar: (1) taze dostların geldiği yer `WaveRunner._behind` — rakiplerin ağırlık merkezinden uzaklaşır; 2. dalganın
  ilk bölüğü `_enter` ile hemen sahneye (ovadaki giriş noktalarına) konduğu için merkez ova tarafında, "arka" peribolos (sondada
  dostlar z 10,9–13,7'de doğuyor). (2) `Melee.rally` — kat farkı ≤ 2,5 m şartı terastaki (−3,7) kimseyi aday yapmaz. (3) dönüş
  (`stand_down` → `home`) yalnız ayaklanan kişinin kendi yerine. (4) `Duelist.withdraw` — yalnız yenilgi/süre dolunca, sırtının
  döndüğü yöne 7 m: içeri dönük duran bir dost dışarı, yamaçtan aşağı çekilebilir (aday; bu koşularda tetiklenmedi).
- Kod değişmedi (kök neden kanıtlanmadan değişiklik yok). Sonraki taşıyana: `=lose`/`=late` ve süre dolan dalgada `--sonda4`.

---

## Değişen dosyalar
- `scripts/chapter22.gd`, `scripts/chapter22o.gd` (taşıma, `=yuru`, `=kare`).
- `scripts/chapter21.gd` (yalnız `_kare` içinde sonda çağrısı; argümansız etkisiz).
- Yeni: `tests/_ist/tasima5_sonda.gd/.tscn` (yeni setin 22 sayıları), `tests/_ist/tasima5_pik.gd` (piksel sondası).
- Kanıt: `docs/_kanit_ist2_tasima5/` (rapor, durum, yön replikleri, testler, kareler).

## run_tests.sh isteği
Paket değişmedi. Öneri: `--chapter=22 --autotest=yuru` ve `--chapter=22o --autotest=yuru` (çıktıda `TASIMA22YURU OZET … takilma=0
dusme=0`, `TASIMA22OYURU OZET … takilma=0 dusme=0`). `=kare` yazılımsal GL'de 20–30 dk: pakete değil, elle.

## A'ya istek (görünüş dosyaları)
- **Sağlam sur seçeneği (28o):** `SurOyun.kur`'a gediksiz kesim (ya da aşama 0 = gedik yok, moloz yok, sur yolu sürekli). 28o
  (11 Nisan, ilk atış) ve fonda kullanan bölümler bunsuz taşınamaz (`LandWalls.intact`).
- **Peribolos zemini dokusuz (Bölüm 21 an_01):** eteklerin örtmediği peribolos zemini (`OyunDilimi/Mesoteikhion` zemin ağı)
  gece karesinde düz gri, kenarı eteğin düz kenarı; kare `kare/c21_pik_golgesiz/an_01_acilis_grant.jpg`, sonda §3a.

## Sonraki taşıyana
1. **Ova bölümleri:** bütün iş hendeğin ötesindeyse (22o) sabitleri `+ sur.ova_ofs()` ile kaydır: iç mesafeler kendiliğinden
   aynı kalır. Ovaya ışınla değil `zemin_y` ile bakan yardımcılar (`Assault.ground_y`, `BattleExtras` osm) dolgu geçidinde
   (x 0 ± 5) dolgu boşken bile "dolu" der: kalabalığı oradan uzak tut.
2. **Dolgu yönü:** setin `Dolgu` parçası sur yakasından dolar; Osmanlı tarafı için `chapter22o._dolgu_uzak` (aynı yardımcı,
   uzak yakadan).
3. **Sur yolundan bakış:** her bakış/tespit/hedef mazgal açıklığında (`_mazgal_x`); gediğin üstündeki aşama-4 tahtasının ova
   kenarında diş yok (görünmez korkuluk gerekir).
4. **Kare kipinde süreler:** yazılımsal GL'de bir kare saniyeler sürer; çekim sırasında akan bir sayaç (fitil) olayı bozar —
   çekimde durdur.
5. **Kule boyu:** yeni ova 3,55 m alçak, dış sur 0,5 m yüksek: ovadaki 13,4 m'lik kule sur yolunun ancak 1,4 m üstünde
   (eski 5,5). Kuleye bağlı her bakışta (26o, 32o) hesaba kat.

## Hâlâ kötü olanlar (dürüst)
- 22o: kule tepesinden sura bakış eskisi kadar "yukarıdan" değil (1,4 m; D22O_H_GUN zayıf uyum) — kule boyu ya da metin sahibin
  kararı.
- 22o dolgusu gece karesinde yakından kaba taş döşeme gibi okunuyor (setin dolgusuyla aynı ağ/doku; eskide düz kutu idi).
- 28o yapılmadı (A'nın sağlam sur seçeneği yok). Bölüm 20 dost asker yeniden üretilemedi.
- (kareler/bütçe sonrası eklenecek)
