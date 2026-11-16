# TAŞIMA-7 — 37o havadaki taşlar; 32o'nun kalanı; 36b ve 28o yeni (sağlam) surda

> Dal `wip/ist2-tasima7`, taban `wip/ist2-birlesik` 5203a40e. Makine: 4 çekirdek; ekransız testler `--max-fps 20`
> (`testler/kos1.sh`, toplu `testler/toplu.sh`), kareler xvfb + Mesa llvmpipe (yazılımsal GL), 1280×720 jpg 85
> (`testler/kare.sh`). Ham günlükler `testler/**.ham`; yanındaki süzülmüş dosya `kos1.sh`'in süzgeci
> (`AUTOTEST (PASS|FAIL)|SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|WARN_FLY|WARN_VOID` + `KOSU|WAVERUNNER|GUN|CESET4|TASIMA6|TASIMA7`).
> **ESKİ** = `--eskisur`. Piksel sondası: `tests/_ist/tasima7_pik.gd` (`--pik7=x,y;…`: o karede pikselin ışınının vurduğu
> ağlar, vuruş noktası ve altındaki zemin; `--pik7parca`: kameranın önündeki parçacık/sprite düğümleri, ekran yeri, ağı, ataları).
> Dokunulmayanlar: sur görünüş dosyaları, `scripts/npc|ui|player/`, `WaveRunner`, `Duelist`, `Melee`, `Duel`, `Garrison`,
> `sur_sozlesme*`, `tests/run_tests.sh`, `project.godot`, `game_state.gd`; replik metni, ses, can/hasar, dalga sınırı,
> düşman sayısı, gizli süreler (DITCH_TIME 240, RIDE_TIME 34, ROLLER_EVERY 4, STEP 1), sayaçlar. Yeni sesli replik yok.

## 1. Bölüm 37o: havada duran moloz taşları (an_04) — **KISMEN** (kök neden bulundu; ikisi düzeldi, biri görünüşe istek)

### 1.1 Sonda (kanıt; `kare/c37o_once.log`, `c37o_sonda2…4.log`, `c37o_sonra.log`)
Kare an_04 (`=kare`, oyuncu (0; −2,2; 23,2), barikata bakış) piksel sondasıyla, oyuncunun kendi gövdesi dışında ışının ilk
vurduğu şey (`PIK7 an=barikat px=… d=… yol=…`):

| karedeki şey | piksel | ilk vuran (uzaklık) | ne | kimin |
|---|---|---|---|---|
| sol koyu taş yığını | (330, 360) | `…/OyunDilimi/Mesoteikhion/GedikMoloz` (2,84 m), sonra `…/Mesoteikhion/@MultiMeshInstance3D@250` (3,54 m) | `surlar.gd _gedik` tümseği (yarım elips koni, tabanı **y 0**, z 8,8–21,8) ve üstündeki kaya saçılımı (34 kaya) | **A** (`surlar.gd`) |
| orta koyu taş yığını | (760, 360) | `GedikMoloz` (2,79 m), `@MultiMeshInstance3D@250` (3,68 m) | aynı | **A** |
| sağ koyu taş yığını | (980, 420) | `GedikMoloz` (5,26 m), `@MultiMeshInstance3D@250` (5,37 m) | aynı | **A** |
| sağ üstte beyaz altıgen | (893, 122) | ağ yok (yalnız 10,6 m'deki sur); `--pik7parca`: `Chapter37o/Assault/@CPUParticles3D` ekran (903, 99), p (5,49; 8,20; 15,48), `SphereMesh r 0,80 seg 8`, beyaz %85, ölçek 0,8–1,8 | `Vfx.dust(…, 1.6)` toz bulutu: `Assault._lob` (mancınık taşı) isabeti | **benim** (`assault.gd`) |
| sol üstte küçük turuncu kutu | (482, 200) | (bu koşuda yok: geçici) | `Assault._lob`/`_fire_gun` isabetinde saçılan `Props.box` kırık taşları (renk cdbd9e, meşale ışığında turuncu) | **benim** |

- **Koni (A)**: oyun diliminin gediği `gedik_sade` ile kurulur ama `_gedik` sade kipte de tümseği ve kayaları şehirdeki gibi
  düz tabanla (dilimin y 0'ında, gedik ortası z ± 6,5) kurup sonra döner. Oyun kesitinde dış kuşak 3,7 m aşağıda: tümseğin dış
  yarısı (z 16,6–21,8) terasın ve `GedikOnarim`'ın moloz rampasının (`Toprak_GedikMolozRampa`, bu taşımanın sınıfı; taşları
  taşıma 6'da kesite oturtuldu, `SONDA37K mm …Toprak_GedikOnarim… fark≈0`) 1–3 m üstünde kalır; dışarıdan bakan oyuncu
  koninin alt yüzünü ve kayaları baş hizasında koyu çokgen olarak görür. Taşıma 6'nın sondası (`docs/_kanit_ist2_tasima6/testler/sonda/c37o_kanca.ham`)
  aynı MultiMesh'in 6 kayasını zeminin 1,1–3,0 m üstünde ölçmüştü. → **görünüşe istek** (aşağıda).
- **Toz bulutu ve kutu (benim)**: `Assault._lob` isabet yerini ESKİ kesitten rastgele seçiyordu: y 4–9, z 12–16,2 (eski dış sur
  z 14–16, 8 m). Yeni sette bu ya sur gövdesinin içi ya peribolosun 4–9 m üstü (hava): toz bulutu ve 4 kutu kırık taş havada
  doğup saçılıyordu. `_fire_gun`'ın 5 kırık taşı da `Props.box` (kutu yasağı).

### 1.2 Düzeltme (yalnız yeni set yolu; eski set bit bit aynı)
`scripts/level/assault.gd`:
- `_lob_yeri(x)`: aynı anlam ("sura ya da surun ardına") gerçek bir yüzeyde: %50 dış surun ova yüzü (gedikte molozun yüzü),
  %30 sur yolunun taşı (gedik/kule dışında; değilse ova yüzü), %20 peribolosun toprağı (`on_rubble`).
- `_kirik_tas`: kırık taşlar kutu değil, yassı düzensiz kaya parçası (5 dilimli basık küre, rastgele dönük); yeni sette düşüşü
  gerçek zemine değince biter (`zemin_y`; eskide sabit y −0,5: yeni ovada havada kayboluyordu).
- Eski set yolu (`_yeni()` yanlış) aynı satırlar: aynı sayılar, aynı rastgele dizi.

### 1.3 Kareler an_04 ÖNCE | SONRA (`kare/c37o_once/an_04_barikat_tasima6.jpg` (sahibin gördüğü), `kare/c37o_once/an_04_barikat.jpg` (bu dalın tabanı), `kare/c37o_sonra/an_04_barikat.jpg`)
- ÖNCE: sırtın iki yanında baş hizasında üç koyu çokgen (A'nın koni + kayaları), sağ üstte opak beyaz altıgen (toz bulutu, sur
  yolunun 0,3 m altında doğup havada), (taşıma 6 karesinde) sol üstte küçük turuncu kutu.
- **SONRA** (tek cümle): beyaz altıgen ve turuncu kutu yok (mancınık tozu sağdaki kulenin yüzünde saydam ve sönerken
  görünüyor, havada değil); ip çeken azaplar ve fıçılar aynı; **sırtın iki yanındaki üç koyu çokgen DURUYOR** (A'nın
  `GedikMoloz`'u; bu taşımada dokunulmadı), kutu yok, eskisinden sönük değil.
- Bütçe (aynı 6 an, taşıma 6'nın eski ↔ bu SONRA): çizim −%64…−%80, ilkel −%50…−%60 (hepsi eskinin altında; taşıma 6 yeni ↔
  SONRA: −%6…+%9 çizim, rastgele mancınık/top anlarına bağlı).

## 3. Bölüm 36b (Huruç, 9 Nisan) — `scripts/chapter36b.gd`

### 3.1 Ne değişti (yalnız yeni set; `--eskisur` yolu eskinin aynısı)
- `ESKI_SUR` + `SurSet.sec("36b", …, saglam=true)`: 9 Nisan'da bombardıman başlamadı (eski set `walls.intact = true`) → yeni sur
  **sağlam kipte** (TUR-11 `saglam_yap`; bu taşımada `SurSet`/`SurSetSahne`'ye bağlandı, §5). `SurSetSahne`: `dolgu` 0 (dolgu
  yok), `kalas` true (köprü bölüm başında kurulu; eskide de), `poterna_acik` true (adamlar dışarıda).
- **Şerit**: eski `LANE_X` −24 → setin poternasının x'i (−17,9; kalas geçidi de orada, karar 7-A). Setin kendi `Poterna`'sı
  (dış surun ova yüzünde; dış kuşak 3,7 m aşağıda olduğu için kapının önünde sahanlık ve sur yüzü boyunca +x'e inen taş basamak)
  ve `KalasKopru`'su (parateikhion yalnız orada açık; 21,8 m) kullanılır; bölümün eski rampa/köprü/kapı kutuları yeni sette
  kurulmaz.
- **Ova** (siper hattı, üç manto, kazıcılar, meşaleler, Leon'un düştüğü yer, atlılar ve durdukları okçu menzili): eski
  koordinat + `ova_ofs` + şeridin x kayması (+6,1) → aralarındaki mesafeler eskiyle aynı (§3.3).
- **Çıkış yeri** (`TOPLAN`): sahanlıktan inen basamağın dibi, terasta (Giustiniani, beş savunucu, Leon, Tolga); **dönüş hedefi**
  (`RETURN`): poternanın sahanlığı (kapının önü; eskide de kapının önü). "Hendeği geç" eşiği uzak yakanın 4 m ötesi (eski de).
- **Köprü yolu** (adamlar, Leon): teras (açıklığın önü) → köprünün yakın ucu → uzak ucu → ova; yükseklik aşağı ışınla
  (sahanlık, basamak, köprü, teras, ova; kişiler sayılmaz). İlk koşuda (`tur0_yeni_def_2`) köprünün ucunda iki savunucu iç içe
  girdi (`VISAUDIT overlap (−17,5; −3,5; 47,4)`): sol şeritten inip sağa dönen, sağ şeritten inenin yolunu kesiyordu → yeni
  sette her adam hedefinin yanındaki şeritten iner. Sonraki bütün koşularda denetim 0.
- **Hendek**: düşen eski gibi 1,5 sn sonra köprünün başına kurtarılır (eşik ova − 1,5); ayrıca köprünün iki yanında hendeğin
  iç yüzüne dayalı iki merdiven (37o kalıbı; 6 m'lik hendekten kendisi de çıkabilir; karar 6: ceza 2× değil).
- İçeri dönüşte (karartma arkasında) poterna kapanır (`Poterna.ac(false)`). Surdaki okçular `Garrison` yeni sette `dense`
  (ovadan görünür; 22o/37o kalıbı).
- `=yuru` (gerçek bot) ve `=kare` (6 an) eklendi; AUTOTEST satırına `sur=`.

### 3.2 Testler (`testler/c36b`)

| çeşit | eski ×1 | yeni | alanlar (eski \| yeni) |
|---|---|---|---|
| (varsayılan) | PASS | PASS ×4 (`tur0_yeni_def_1…4`; 2. koşuda 1 overlap → düzeltildi, 3–4 temiz) | 36.1 · burned 3 · fights 1 · kills 5 \| 4–6 |
| leave | PASS | PASS ×2 | 36.2 · burned 3 · kills 3 \| 4–5 |

Çarpışma (`WAVERUNNER`, 75 sn sınır): eski 25,0 · 25,1 | yeni 19,4 · 20,6 · 19,7 · 24,6 · 20,5 · 23,6 sn (hepsi kazanıldı).

## 2. Bölüm 32o (Son Gün, 28 Mayıs) — kalanlar — `scripts/chapter32o.gd`

### 2.1 Ne eklendi / değişti
- `=yuru` (gerçek Player botu, bölümün KENDİ akışı; autotest kısayolları — ışınlanma, kendiliğinden basma, kendiliğinden itme —
  bu kipte kapalı, gerisi aynen): tellalın yolundan azaba → hendek döngüsü (yığından demet E → kıyı E; iki demette bir toprak
  sepeti E → kıyı E; Rum ateşinde toprak) → **ok yaylımı uyarısında en yakın mantonun arkasına** (mantonun içinden geçen yol yanından
  dolanır: ilk koşuda bot mantoya yapışıp kalıyordu, `yuru_yeni_1`) → Usta'nın tezgâhı (işaret ortadayken gerçek E) → manto
  (arkasına geç, E basılı it). Süreler (DITCH_TIME 240, yaylım 13/2,6 sn, Rum ateşi 15 sn) bölümün kendisi.
- `=kare` (6 an: açılış, yığında demet elde, kıyıda atış, yaylımda manto arkası, tezgâh, manto itme).
- **Çalı demeti** (eldeki, atılan, yan bölüğün sırtındaki): tek 6 köşeli silindir yerine bağlı dokuz ince dal + iki ip bağı
  (`_demet`). Elde kameranın dibinde iri, kutu gibi düz bir levha okunuyordu (kare `kare/c32o_yeni_tur0` yerine: ilk koşu,
  an_02; eskide de aynı). Yalnız görünüş (iki sette de); yığının 14 demeti ve hendekteki eski demetler aynı (uzaktan kütük gibi).

## 4. Bölüm 28o (İlk Atış, 6 ve 11 Nisan) — sağlam surla — `scripts/chapter28o.gd`

### 4.1 Ne değişti (yalnız yeni set; `--eskisur` yolu eskinin aynısı)
- `ESKI_SUR` + `SurSet.sec("28o", …, saglam=true)` → `SurSetSahne` sağlam kipte (11 Nisan: sur gediksiz; eski `intact`),
  `dolgu` 0, `kalas` false, `gun_gate` ve `field_keep` eskisi gibi (ova koordinatında).
- Bölümün bütün işi ovada, bataryada (22o/32o kalıbı): `gy(x, z)` = SiegeField zemini ova kaydırmasıyla (statik `_O`);
  kazık yığını, dört çukur, Urban'ın ve Tolga'nın yerleri, kızak yolu (`HAUL_Z` 124,5 + O.z; `HAUL_FROM`/`HAUL_TO` aynı), halat
  ucu, ip çit, zemin ayrıntısı, bakışlar **eski + `ova_ofs`** → aralarındaki bütün mesafeler eskiyle aynı (§4.3). Büyük top
  `SurSetSahne`'nin `far_gun`'ı (zaten ova kaydırmasıyla).
- İlk atışın hedefi `_hedef()`: eski `LandWalls.BREACH` ↔ yeni `sur.gedik()` (sağlam kipte gedik yok: çerçevenin x 0'ı, dış
  surun ortası = varsayılan kipin oyun gediğinin yeri, TUR-11 notu). İsabet dış surun ova yüzüne (yara `_scar` yüzde, teras +
  1,5 … sur yolu − 1 arasında); **ıska hendeğe** (D28O_U_MISS "Hendek."): eski yer (eski hendekte oran 0,125) yeni hendekte aynı
  oranda (ilk denemede terasa düşüyordu: replikle uyuşmazdı, düzeltildi). `CannonCrew.ground_y` yeni ova (32o'daki hata).
- `=yuru` (kazık işi gerçek botla), `=kare` (6 an: açılış, kazık yığını, kazık, kızak, kızak yarı yolda, top, ilk toz) eklendi;
  AUTOTEST satırına `sur=`.

## 5. Ortak: `SurSet` / `SurSetSahne` sağlam kip seçeneği (madde 4'ün ön koşulu; 36b de kullanır)
- `SurSet.yeni(kesim, p_saglam := false)`, `SurSet.sec(bolum, sabit, kesim, p_saglam := false)`: sağlamda çerçeve **varsayılan
  kipin** gediğinden kurulur (TUR-11 notu: `gx` gerekirse varsayılanın değeri; çerçeve gedik x 0 aynı kalır, bütün eski
  sayılar aynı yere düşer), sonra `a.saglam_yap()`: moloz profili boş (`moloz_y` 0, `zemin_y` molozsuz), `gedik_bosluk()` 0
  (sur yolu gedik yerinde de sürekli), `dis_kuleler` sağlamlaşan kuleyi içerir, `engeller()` gediksiz.
- `SurSetSahne`: `_enter_tree`'de `sur` verilmemişse `SurSet.yeni(kesim, intact)` (eski setin `intact` seçeneği → sağlam kip);
  `SurOyun.kur`'a `"saglam": sur.saglam`; sağlam surda gediğin teslim alanı/tekerlekli siperleri (`_build_breach_set`) kurulmaz
  (eski set `intact`'te `_build_breach` kurmaz).
- **Varsayılan aynı**: `p_saglam` false / `intact` false → aynı çağrılar, aynı sayılar (`"saglam": false` = `kur`'un varsayılanı).
  Kullanan bölümler ×1 (§6).

## 6. Ortak değişikliklerden sonra öteki bölümler (`testler/ortak`) ve sözleşme
