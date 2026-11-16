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

## Özet

| # | Madde | Durum | Kısa |
|---|---|---|---|
| 1 | 37o havadaki moloz taşları (an_04) | **KISMEN** | Piksel sondasıyla üçü de bulundu. **Üç koyu çokgen** = `OyunDilimi/Mesoteikhion/GedikMoloz` tümseği + kaya saçılımı (`surlar.gd _gedik`, sade kipte düz tabanla, dış kuşağın 1–3 m üstünde) → A'nın dosyası: **görünüşe istek** (düğüm yolu + kare + öneri). **Beyaz altıgen** = mancınık taşının toz bulutu, **turuncu kutu** = isabet kırıntısı (`Assault._lob/_fire_gun`, eski kesitten seçilen isabet yeri yeni sette havada; kırıntı `Props.box`) → düzeltildi (gerçek yüzey, kaya parçası; yalnız yeni set). an_04 ÖNCE\|SONRA: altıgen ve kutu yok, koyu çokgenler DURUYOR |
| 2 | 32o'nun kalanı | **TAMAM** | `=yuru` gerçek bot (çalı demeti → hendek, toprak, yaylımda manto arkası, basamak, manto itme): yeni ve eski bacak bacak aynı, takılma 0 düşme 0 tuş yok 0; eski ×1 7/7, yeni ×1 7/7 PASS, denetim 0; 6 ESKİ\|YENİ kare; bütçe; mesafe tablosu (ova içinde hepsi aynı); yön replikleri uyumlu. Kutu yasağı: çalı demeti dal demeti, manto kalaslı |
| 3 | 36b (Huruç) | **TAMAM** | Yeni **sağlam** surda: setin `Poterna`'sı (sahanlık + terasa inen basamak), `KalasKopru` (görünmeyen tahta düzeltildi: gizli kur + `tak()`), hendek merdivenleri, ova kaydırması; son kod yeni 5/5 + eski 4/4 PASS denetim 0 (ara turlarda üç `VISAUDIT overlap` sondayla kökten düzeltildi); `=yuru` takılma 0 düşme 0; mesafe ≤ 20; 6 kare (eski 5); bütçe 5 anın 4'ünde ≤ (an_01 ilkel +%2) |
| 4 | 28o (sağlam sur) | **TAMAM** | `SurSet`/`SurSetSahne` sağlam kip seçeneği (varsayılan aynı); 28o sağlam surla (ova kaydırması, HAUL_Z 124,5 + O.z, ıska hendeğe); yeni 8/8 + eski 4/4 PASS denetim 0; `=yuru` (kazık) iki sette aynı; kareler @@OZET28O@@ |
| — | Ortak bölümler | @@OZETORTAK@@ | 0, 20 ×2, 20o ×2, 21, 22, 22o, 25, 32o, 37o ×1 (SurSet, SurSetSahne, Assault değişti) |
| — | Sözleşme | @@OZETSOZ@@ | `SURSOZLESME PASS kalem=13 kesim=8` · `SUROYUN … havada=0 gomuk=0 katida=0` · `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` |

---

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

## 2. Bölüm 32o (Son Gün, 28 Mayıs) — kalanlar — `scripts/chapter32o.gd`

### 2.1 Ne eklendi / değişti
- `=yuru` (gerçek Player botu, bölümün KENDİ akışı; autotest kısayolları — ışınlanma, kendiliğinden basma, kendiliğinden itme —
  bu kipte kapalı, gerisi aynen): tellalın yolundan azaba → hendek döngüsü (yığından demet E → kıyı E; iki demette bir toprak
  sepeti E → kıyı E; Rum ateşinde toprak) → **ok yaylımı uyarısında en yakın mantonun arkasına** (mantonun içinden geçen yol yanından
  dolanır: ilk koşuda bot mantoya yapışıp kalıyordu, `yuru_yeni_1`) → Usta'nın tezgâhı (işaret ortadayken gerçek E) → manto
  (arkasına geç, E basılı it). Süreler (DITCH_TIME 240, yaylım 13/2,6 sn, Rum ateşi 15 sn) bölümün kendisi.
- `=kare` (6 an: açılış, yığında demet elde, kıyıda atış, yaylımda manto arkası, tezgâh, manto itme).
- **Çalı demeti** (eldeki, atılan, yan bölüğün sırtındaki): tek 6 köşeli silindir yerine bağlı dokuz ince dal + iki ip bağı
  (`_demet`). Elde kameranın dibinde iri, kutu gibi düz bir levha okunuyordu (kare `kare/c32o_yeni_tur0/an_02_yigin.jpg`: ilk
  koşu; eskide de aynı). Yalnız görünüş (iki sette de); yığının 14 demeti ve hendekteki eski demetler aynı (uzaktan kütük gibi).

- **Manto** (dört tekerlekli perde): tek düz levha + kuşak yerine sekiz dikine kalas (boyları/tonları farklı, araları yarık;
  36b'nin mantosu gibi), çarpışma aynı kutu (görünmez). Yaylımda arkasına sığınınca kameranın dibinde koca bir kutu okunuyordu
  (`kare/c32o_yeni_tur0/an_04_manto_arkasi.jpg`). Yalnız görünüş, iki sette de.

### 2.2 Testler (`testler/c32o`; son kod)

| çeşit | eski ×1 | yeni ×1 (taşıma 6'da ×1–2 daha) | alanlar (eski = yeni) |
|---|---|---|---|
| (varsayılan) | PASS | PASS | 32O.1 · bundles 6/6 · earth 2 · arrows 0 · rungs 6 · hits 3/3 · fires 6 · greek 2/2 · hasan water |
| late | PASS | PASS | 32O.2 · bundles 4/6 · earth 1 · hits 0/3 · greek 1/1 |
| cracked | PASS | PASS | 32O.1 · hits 3/3 |
| gunner | PASS | PASS | 32O.1 |
| named | PASS | PASS | 32O.1 |
| council_ok | PASS | PASS | 32O.1 |
| council_bad | PASS | PASS | 32O.1 |

**Eski 7/7, yeni 7/7 PASS; denetim satırı 0.** Alanlar eski ile yeni arasında bire bir aynı.

### 2.3 Gerçek bot (`=yuru`; `testler/c32o/yuru_yeni_2.ham`, `yuru_eski_1.ham`)

| set | bacak | takılma | düşme | tuş yok | ok | süre | yol | demet / toprak / Rum ateşi | basamak | manto |
|---|---|---|---|---|---|---|---|---|---|---|
| yeni | 75 (13 kez mantoya sığındı) | **0** | **0** | 0 | 0 | 211,8 sn | 512,8 m | 6/6 · 3 · 0/2 | 6/6 (kötü 0) | itildi (16,3 sn, 22,8 m) |
| eski | 75 (13) | 0 | 0 | 0 | 0 | 211,8 sn | 512,7 m | 6/6 · 3 · 0/2 | 6/6 (kötü 1) | itildi (16,3 sn, 22,8 m) |

İki sette bacak bacak aynı yol ve süre (ova kaydırmasının kanıtı). Rum ateşi iki sette de söndürülemedi (bot yaylımda mantoya
gidiyor; GREEK_TIME 15 sn bot için kısa — autotest botunda 2/2; süre değişmedi). İlk koşuda (`yuru_yeni_1`) bot, mantonun arkasından
kıyıya giderken perdenin içinden yürümeye çalışıp yapışıyordu → yol mantonun yanından dolanır (`_yb_rota`).

### 2.4 Mesafe tablosu (`TASIMA32OMESAFE`, m; eski = yeni)

| çift | eski | yeni |
|---|---|---|
| açılış → azap | 30,5 | 30,5 |
| yığın → kıyı · toprak → kıyı | 13,0 · 13,0 | 13,0 · 13,0 |
| kıyı → manto 0 · yığın → manto 2 | 6,7 · 9,1 | 6,7 · 9,1 |
| kıyı → tezgâh · tezgâh → manto · manto yolu | 27,9 · 30,1 · 23,0 | 27,9 · 30,1 · 23,0 |
| kıyı → hendeğin ortası (yükseklik farkı) | 9,4 (−2,9) | 11,4 (−0,2: yarı dolu dolgunun yüzü) |
| kıyı → sur yolu (yükseklik farkı) | 21,4 (+8,0) | 31,4 (+12,2) |

Oyuncunun yürüdüğü her şey ovada ve eskiyle aynı; yalnız sur daha uzak ve yüksek (yeni hendek 20 m + teras 10 m). Yön repliği
`D32O_AZ_B3` "Sağdaki bölük" (demet taşıyan yan bölük x 17/22): uyumlu (aynı yerde). `D32O_AZ_02` "mantonun arkasına": uyumlu.

### 2.5 Kareler ESKİ | YENİ (oyuncu kamerası, `=kare`; `kare/c32o_eski`, `kare/c32o_yeni`)
@@KARE32O@@

### 2.6 Bütçe (aynı an, 4 kare ortalaması; `kare/c32o_eski.log` ↔ `kare/c32o_yeni.log`)
@@BUTCE32O@@

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
- **Köprünün görünmesi**: setin köprüsü `"kalas": true` ile kurulunca tahta ağı `SurOyun.kur`'un pişirmesinde siliniyordu
  (yalnız çarpışma kalıyordu; askerler hendeğin üstünde boşlukta yürüyordu: `kare/c36b_yeni_tur0/an_02_kopru.jpg`; kök neden
  görünüşe istek 2). Köprü `"kalas": false` ile kurulup `add_child`'dan sonra `tak()` edilir (37o'nun yolu): sonda
  `tests/_ist/tasima7_kalas.gd` (`Ahsap_KalasTahta` duruyor).
- `=yuru` (gerçek bot) ve `=kare` (6 an) eklendi; AUTOTEST satırına `sur=`; `--sonda36` (yalnız autotest).

### 3.2 Testler (`testler/c36b`)

| çeşit | eski ×1 | yeni | alanlar (eski \| yeni) |
|---|---|---|---|
| (varsayılan) | PASS (+1 son) | **son kod ×3** PASS (`son_yeni_def_1…3`) | 36.1 · burned 3 · fights 1 · kills 4–6 \| 4–6 |
| leave | PASS (+1 son) | **son kod ×2** PASS (`son_yeni_leave_1…2`) | 36.2 · burned 3 · kills 3–4 \| 4–5 |

**Son kod: yeni 5/5, eski 4/4 PASS; denetim satırı 0** (`testler/c36b/son_*`). Ara turlarda yeni sette üç ayrı
`VISAUDIT overlap` çıktı (köprüden inişte şerit kesişmesi, geri çekilmede köprü ucunda birleşme, Giustiniani'nin dönüş yeri),
kök nedenleri `--sonda36` (`SONDA36YAKIN`: 0,5 m'ye yaklaşan iki kişinin her karede yeri ve bacağı) ile bulundu, §3.1:
- köprüden inerken sol şeritten inip sağa dönen sağdakinin yolunu kesiyordu → hedefin yanındaki şerit;
- geri çekilmede herkes köprünün uzak ucundaki tek noktaya farklı yönlerden yürüyordu, ikisi aynı anda varıyordu
  (`testler/sonda/c36b_s4…s11`) → köprü ucuna yakın olan önce, şeridin önünde 1,2 m arayla kendi sıra yerine, oradan tek sıra;
- dönüşte yerine varmış Giustiniani savunucuların köprü başından toplanma yerine giden yolunun üstündeydi (`c36b_s15/s17`) →
  dönüş yeri bu yolun 1,5 m dışı; geri yürüyüşün ilk ve son bacağında duranın yanından dolanma.
Sonda koşuları `c36b_s19`, `s20` ve son paket: çakışma yok.

Çarpışma (`WAVERUNNER`, 75 sn sınır; aynı dalga, aynı rakip sayısı): eski 25,0 · 25,1 | yeni 19,4–25,0 sn (hepsi kazanıldı).

### 3.3 Mesafe tablosu (eski ↔ yeni; `TASIMA36BMESAFE`, düz çizgi xz, m) ve gerçek bot (`=yuru`)

| çift | eski | yeni | fark / not |
|---|---|---|---|
| çıkış yeri → köprünün başı | 1,7 | 9,5 | +7,8: yeni dış kuşak 3,7 m aşağıda, kapının önündeki basamak +x'e iner (≤ 20) |
| köprü (baş → karşı uç) | 20,9 | 23,7 | +2,8 (hendek 16 → 20 m, karar 6) |
| karşı uç → "hendeği geç" hedefi | 3,5 | 3,7 | ≈ |
| hedef → manto 0 · manto 0→1 · 1→2 · 2 → Leon | 9,2 · 7,6 · 7,6 · 4,2 | 9,2 · 7,6 · 7,6 · 4,2 | 0 (ova kaydırması) |
| Leon → köprünün karşı ucu | 8,3 | 8,5 | ≈ |
| köprünün başı → dönüş (kapının önü) | 0,6 | 7,0 (dy +3,8: basamaktan sahanlığa) | +6,4 (≤ 20) |
| köprü ucu → siper hattı · siper → atlıların durduğu yer | 16,5 · 4,5 | 16,7 · 4,5 | ≈ (RIDE_TIME 34 sn aynı) |
| dönüş → içeride toplanma | 8,2 | 8,3 | ≈ |

Oyuncunun yürüdüğü her hedef ≤ 20 m; köprünün kendisi hendeğin eni (karar 6). Leon'la dönüş (çarpışmasız, süresiz) yeni sette
≈ 15 m uzun (basamak ve köprü); atlıların Leon'a varış süresi (RIDE_TIME) aynı, Leon'un düştüğü yer siper hattına aynı uzaklıkta.

Gerçek bot (`testler/c36b/yuru_*`, son kod `son_yuru_yeni_1`):

| set | bacak | takılma | düşme (hendeğe) | tuş yok | süre | yol | not |
|---|---|---|---|---|---|---|---|
| yeni | 13 (köprü başı, ortası, ucu, hedef, 3 manto, Leon, geri ×2, basamağın dibi/üstü, kapı) | **0** | **0** | 0 | 43,1–43,3 sn | 108,8–109,2 m | 3 manto E ile yandı, Leon E ile kalktı, varış (kapının önü, Leon ≤ 4 m) |
| eski | 11–12 | 1 | 1 | 0 | 38,9–39,6 sn | 79,9–89,2 m | **eski rampa**: ayağı sur yüzüne dayalı (0,2 m), yanından çıkılamıyor (zıplama da) → bot rampanın yanından hendeğe düşüp kurtarılıyor; eskinin kendi geometrisi |

Yeni sette köprü 1,6 m enli, ayaklı, ova ile aynı düzde: eskideki dar rampa + inişli kalas yerine.

### 3.4 Yön replikleri (metin DEĞİŞMEDİ)
| anahtar | söz | yeni sette |
|---|---|---|
| `D36_G_01` | "hendeğin elli adım ötesinde siper kazıyor" | uyumlu: siper hattı hendeğin uzak yakasından 18 m (eskide de 18 m) |
| `D36_G_02` | "Kalas köprüden geçin" | uyumlu (setin kalas köprüsü) |
| `D36_G_BACK` | "Hepiniz köprüye! Surdakiler sizi örter!" | uyumlu (köprü; surdaki okçular `dense`, ovadan görünür) |
| `D36_T_01` | "taş duvarların dışına" | uyumlu |
| `D36_N_END` | "surun içinden" | uyumlu (dönüş poternadan, içeride peribolos) |

### 3.5 Kareler ESKİ | YENİ (`kare/c36b_eski`, `kare/c36b_yeni`; ara tur `kare/c36b_yeni_tur0` = görünmeyen köprü)
| an | ESKİ | YENİ — tek cümle | hüküm |
|---|---|---|---|
| an_01 çıkış (köprünün başı) | rampanın tepesinden sığ hendeğin üstünde tek düz levha köprü (kutu), ötede adamlar ve ordugâh | parateikhion açıklığından 6 m'lik taş hendeğin üstünde ayaklı kalas köprü, karşıda mantoların önüne yayılmış adamlar ve ordugâh; köprü kıyılara oturuyor, havada duran yok, kutu yok | **iyi** (ilk turda tahta görünmüyordu: `c36b_yeni_tur0/an_01`) |
| an_02 köprünün ortası | düz levhanın ortası, sığ hendek | derin hendeğin ortasında kalasların üstü, iki yanda taş hendek duvarı, ötede adamlar; tahtaya saplı bir ok (yaylımın oku, yerde) | **iyi** (ilk turda adamlar hendeğin üstünde boşlukta: `c36b_yeni_tur0/an_02`) |
| an_03 siper hattı | mantolar, sepetler, kazıcılar, meşaleler | aynı dizilim yeni ovada (mantolar kalaslı, sepet siper toprak sette, meşaleler yanıyor), yakında bir savunucu | **iyi** |
| an_04 yanan mantolar | iki manto yanıyor, duman | üç manto yanıyor, duman sütunları, elde meşale, kazıcılar siperde | **iyi** (eskiden sönük değil) |
| an_05 Leon | yerde yatan Leon, bacağında ok | aynı; yerde turuncu bir kıvılcım lekesi (geçici) | **kabul** |
| an_06 geri bakış | — (eski sette çekilemedi: kare kipinde Leon eski sur gövdesine ışınlandı, kip ilerlemedi) | ovadan sura: sur yolunda savunucular, poternanın kemeri, sahanlıktan inen basamak, hendeğin üstünde köprü ve iki merdiven; önde iki savunucu | **iyi** (eskiyle karşılaştırılamadı) |

### 3.6 Bütçe (aynı an, 4 kare ortalaması)
| an | çizim eski → yeni | ilkel eski → yeni |
|---|---|---|
| cikis | 4.431 → 4.390 (-1%) | 6.09 M → 6.23 M (+2%) |
| kopru | 4.378 → 4.317 (-1%) | 6.08 M → 6.08 M (-0%) |
| siper | 4.222 → 4.053 (-4%) | 5.87 M → 5.74 M (-2%) |
| yanan | 3.888 → 3.376 (-13%) | 5.31 M → 4.67 M (-12%) |
| leon | 1.040 → 1.030 (-1%) | 2.00 M → 1.95 M (-2%) |

an_01'de ilkel **+%2** (çizim −%1): bütçe kuralının tek istisnası (iki kamera aynı yerde değil: eskide rampanın tepesi y 1,5,
yenide terasta y −3,7 — derin hendeğin iki taş duvarı ve parateikhion kadrajda; ordugâh iki sette de ilkelin çoğu). Kök nedeni
ayrıştırılmadı (Hâlâ kötü). Öteki dört an eskinin altında (−%0,1 … −%13).

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


### 4.2 Testler (`testler/c28o`)

| çeşit | eski ×1 | yeni ×2 | alanlar (eski = yeni) |
|---|---|---|---|
| (varsayılan) | PASS | PASS PASS | 28O.1 · stakes 4 · slips 0 · hit true · roller_every 4 · rollers 2 |
| lose | PASS | PASS PASS | 28O.2 · slips 1 |
| edirne | PASS | PASS PASS | 28O.1 · master true · roller_every 3 · rollers 3 |
| edirne_ok | PASS | PASS PASS | 28O.1 · roller_every 6 · rollers 1 |

**Eski 4/4, yeni 8/8 PASS; denetim satırı 0** (`WARN_PORTRAIT_STUDIO … D28O_S_BALL` iki sette de, tabanın: portre stüdyosu uyarısı,
süzgecin dışı). 41o, 42b, 31o eski `LandWalls`'u kullanıyor (taşınmadı, bu dalda değişmedi): koşulmadı.

### 4.3 Gerçek bot (`=yuru`, kazık işi; `testler/c28o/yuru_yeni_1.ham`, `yuru_eski_1.ham`) ve mesafe tablosu

| set | bacak | takılma | düşme | tuş yok | süre | yol | kazık |
|---|---|---|---|---|---|---|---|
| yeni | 8 | 1 | 0 | 1 | 49,0 sn | 78,7 m | 4/4 |
| eski | 8 | 1 | 0 | 1 | 42,4 sn | 70,0 m | 4/4 |

İki sette de ilk çukur bacağında bir takılma (bot kazık yığınından ilk çukura dümdüz yürüyor, bataryanın engeline yapışıyor;
sonra çukurun E'si tutmuyor → `tus_yok 1`): eskinin aynı davranışı, taşımadan değil. Öteki üç kazık takılmasız.

| çift (`TASIMA28OMESAFE`, m) | eski | yeni |
|---|---|---|
| açılış → kazık yığını · yığın → çukur 0 · yığın → çukur 3 | 3,2 · 16,6 · 6,6 | 3,2 · 16,6 · 6,6 |
| kızak yolu (HAUL_FROM → HAUL_TO) · kızak ucu → top | 12,0 · 6,5 | 12,0 · 6,5 |
| top → hedef (sur) · çukur → sur | 103,4 · 99,6 | 113,7 · 109,9 (yükseklik +3,5) |

Yön replikleri: `D28O_U_01` "Kazıkları siperin arkasına" uyumlu (aynı yer); `D28O_F_01` "Surlar orada" uyumlu; `D28O_U_MISS`
"Hendek." ıska yeni hendekte (§4.1).

### 4.4 Kareler ESKİ | YENİ (`kare/c28o_eski`, `kare/c28o_yeni`)
@@KARE28O@@
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
@@ORTAK@@

## Değişen dosyalar
- `scripts/level/assault.gd`: yalnız yeni set yolu — `_lob_yeri` (mancınık isabeti gerçek yüzeyde), `_kirik_tas` (kırıntı
  kaya, kutu değil), kırıntının yeni sette gerçek zemine değince bitmesi. Eski set yolu aynı satırlar.
- `scripts/world/ist/sur_set.gd`: `saglam` (isteğe bağlı `p_saglam`; varsayılan aynı), `gedik_bosluk` sağlamda 0.
- `scripts/world/ist/sur_set_sahne.gd`: `intact` → sağlam kip; `"saglam"` kesime; sağlamda gedik dekoru yok (varsayılan aynı).
- `scripts/chapter32o.gd`: `=yuru`/`=kare` (gerçek bot; autotest kısayolları bu kipte kapalı), `_rung_iyi` (bot okur),
  `_demet` (çalı demeti dal demeti), manto kalaslı, `_yb_rota`.
- `scripts/chapter36b.gd`: yeni sağlam sur bağdaştırıcısı (poterna, kalas köprü gizli kur + `tak()`, hendek merdivenleri,
  ova kaydırması, köprü yolu ışınla, geri çekilmede sıra yerleri, dolanma, yol verme), `=yuru`/`=kare`, `--sonda36`, `sur=`.
- `scripts/chapter28o.gd`: sağlam sur bağdaştırıcısı (ova kaydırması, `gy` statik `_O`, hedef, ıska hendeğe, top zemini),
  `=yuru`/`=kare`, `sur=`.
- `scripts/chapter37o.gd`: yalnız `_kare` içinde piksel sondası çağrısı (argümansız etkisiz).
- Yeni: `tests/_ist/tasima7_pik.gd` (piksel/parçacık sondası), `tests/_ist/tasima7_kalas.gd` (kalas köprü ağ sondası).
- Kanıt: `docs/_kanit_ist2_tasima7/` (`.gdignore`'lu).

## run_tests.sh isteği
Paket değişmedi. Öneri: `--chapter=36b --autotest=yuru` ve `--chapter=32o --autotest=yuru` (çıktıda `TASIMA36BYURU OZET …
takilma=0 dusme=0`, `TASIMA32OYURU OZET … takilma=0 dusme=0`); 36b varsayılan çeşidi ×3 (geri çekilme kalabalığının
`VISAUDIT overlap` denetimi aralıklıydı).

## Görünüşe istek (A'nın dosyaları; dokunulmadı)

1. **Gedik molozunun tümseği ve kayaları oyun kesitinde havada** — `surlar.gd` `_gedik` (`OyunDilimi/Mesoteikhion/GedikMoloz` ve
   kaya saçılımı `OyunDilimi/Mesoteikhion/@MultiMeshInstance3D@250`). Sahibin gördüğü kare: `docs/_kanit_ist2_tasima6/kare/c37o_yeni/an_04_barikat.jpg`
   (kopya `kare/c37o_once/an_04_barikat_tasima6.jpg`); bu dalda hâlâ: `kare/c37o_sonra/an_04_barikat.jpg` (sırtın iki yanında
   baş hizasında üç koyu çokgen). Sonda §1.1 (`PIK7 an=barikat px=(330,360) d=2.84 …/GedikMoloz`, `…@MultiMeshInstance3D@250 d=3.54`;
   (760,360), (980,420) aynı). Kök neden: `_gedik(…, sade=true)` (oyun dilimi, `gedik_sade`) tümseği (`tm`, taban y 0, gedik
   ortası z ± 6,5) ve kayaları (`kl`, y = 1,6·(1−r)) şehirdeki düz kesitle kurup ancak sonra `return` ediyor; oyun kesitinde dış
   kuşak `dy` −3,7 m aşağıda ve gediğin oyun molozunu `GedikOnarim` kuruyor (`Toprak_GedikMolozRampa`, kesite oturan taşlarıyla).
   Tümseğin dış yarısı (yerel z zo1 … zc + 6,5) terasın 1–3 m üstünde kalıyor; dışarıdan alt yüzü görünüyor. **Öneri**: `sade`
   kipte `tm`/`kl` kurulmasın (oyun molozu `GedikOnarim`'ın) ya da tabanı `dy`'ye göre (molozun dış yamacı terasa) kurulsun.
2. **Kurulu kalas köprünün (ve kapı köprüsünün) ağı pişirmede siliniyor** — `sur_oyun_parca.gd` `kur_hepsi` (GedikOnarim dışı,
   A'nın): `for c in out["kalas"].get_children(): PARCA_.pis(c)` — çocuk bir `MeshInstance3D` (ör. `Ahsap_KalasTahta`) olunca
   `Props.bake_static(c, [c])` pişmiş ağı `c`'nin altına ekliyor, sonra kurbanı (`c`'nin kendisini) siliyor: pişmiş ağ da gidiyor.
   `"kalas": true` ile kurulan köprüde yalnız çarpışma kalıyor (`tests/_ist/tasima7_kalas.gd`: `KALAS7 … Ahsap_KalasKopru → yalnız
   Ahsap_Kalas_Carp`; `"kalas": false` + `tak()` ile `Ahsap_KalasTahta` duruyor). Kare: `kare/c36b_yeni_tur0/an_02_kopru.jpg`
   (askerler hendeğin üstünde boşlukta yürüyor). 37o köprüyü gizli kurup sonra `tak()` ettiği için etkilenmiyordu; 36b'de aynı yol
   kullanıldı (§3.1). Aynı döngü `kapi_kopru` için de çalışıyor ama orada ağlar `Node3D` alt düğümlerde (`Ahsap_KapiKopruSaglam`):
   sonda (`KALAS7 === romanos`) kökte `Baked` (5,6 × 1,4 × 11,4 m) buldu, etkilenmiyor. **Öneri**: `pis(out[k])` (kökü bir kez) ya da çocuk `MeshInstance3D` ise atla.

## Sonraki taşıyana
1. **Kurulu köprü**: `SurOyun.kur(…, {"kalas": true})` ile gelen `KalasKopru`'nun tahta ağı pişirmede siliniyor (görünüşe istek 2).
   A düzeltene dek köprüyü `"kalas": false` ile kurup `add_child`'dan sonra `kesim["parca"]["kalas"].tak()` (36b, 37o).
2. **Sağlam sur**: `SurSet.sec(bolum, ESKI_SUR, "mesoteikhion", true)` ve `SurSetSahne.sur` ile; çerçeve varsayılan kipin
   gediğinden (x 0 = eski gedik yeri), `gedik()` hâlâ o noktayı verir (hedef gibi kullanılabilir), molozsuz zemin, sur yolu sürekli.
   Eski setin `walls.intact = true`'su yeni sette de verilebilir (`SurSetSahne` `sur` verilmemişse ona bakar).
3. **Ova bölümleri** (28o, 32o, 36b'nin dışarısı): eski + `ova_ofs` (36b'de ayrıca şeridin x kayması); `SiegeField.ground` ova
   yerelidir: bölümün `gy`'si `ground(x − O.x, z − O.z) + O.y` (28o). `CannonCrew.ground_y` yeni ova (`sur.ova_y()`).
4. **Assault'un isabet yerleri**: yeni sette eski kesitten rastgele seçilen her yer (y, z) gerçek bir yüzeye oturtulmalı
   (`_fire_gun`, `_lob` düzeltildi; `_smoke`, `_dust_line` ve okçuların kaynakları eski kesitle ölçülmedi).
5. **Gerçek bot**: yol bir katının (manto, rampa yanı, batarya) içinden geçiyorsa bot yapışır (32o ilk koşu, 28o ilk çukur,
   36b eski rampa); `_yb_rota` (32o) gibi dolanma ara noktası ya da zıplama. Kare kipinde adamlar köprüdeyken ışınlanma
   kamerayı adamların içine koyar (36b: adamlar geçene dek bekle).
6. **Piksel sondası** `tests/_ist/tasima7_pik.gd`: bölümün `_kare`'sinde `uygula(self)` + `yaz(self, ad)`; `--pik7=x,y;…`,
   ağ olmayan çizilenler için `--pik7parca` (parçacık, sprite: ekran yeri, ağı, ataları). Havadaki bir şeyin kimin olduğunu
   bulmanın en kısa yolu.

## Hâlâ kötü olanlar (dürüst)
- **37o an_04**: sırtın iki yanında baş hizasında üç koyu çokgen DURUYOR (A'nın `GedikMoloz` tümseği ve kayaları; görünüşe istek 1).
  Bu taşımada yalnız mancınık tozu ve kutu kırıntıları (benim) düzeldi. Sahibin gördüğü karenin ana kusuru bu yüzden SÜRÜYOR.
- **36b köprü**: tahta ağı ancak gizli kurup `tak()` ile görünüyor (görünüşe istek 2, A'nın pişirme döngüsü); köprünün kalasları
  geniş, düz kalaslar (A'nın `KalasKopru`'su). Eskideki "dar rampa + inişli kalas" hissi yok (ova ile aynı düzde).
- **36b geri çekilme kalabalığı**: yeni sette çakışmalar üç ayrı yerde çıktı ve üç kökten düzeltildi (şerit seçimi, köprü ucunda
  sıra yeri, Giustiniani'nin dönüş yeri); her biri az koşuda (%20–50) görülüyordu: son doğrulama ×4+ (§3.2). Kalabalık tween'le
  yürüyor; yol ver/sıra kuralları yalnız yeni sette.
- **36b bütçe**: an_01 ilkel eskiden %2 fazla (çizim %1 az) — bkz. §3.5; ordugâh ve hendek iki sette de kadrajın çoğu.
- **28o ilk çukur**: gerçek bot kazık yığınından ilk çukura giderken bataryanın yanında bir kez takılıyor (iki sette de aynı:
  eski `yuru_eski_1` takılma 1); düz yol bataryanın sepet/fıçı engelinden geçiyor. Oyuncu dolanır; bot yolu düzeltilmedi.
- **32o Rum ateşi (gerçek bot)**: iki sette de 0/2 söndürüldü (bot yaylımda mantoya, sonra yığına/toprağa gidiyor; 15 sn yetmiyor);
  autotest botunda 2/2. Süre (GREEK_TIME 15) değişmedi.
- **32o kareler**: eldeki leblebi paketi açılışta (Tolga'nın eşyası; eski de) kadrajın sağında; yakın plan manto ve demet artık
  kalaslı/dallı ama hâlâ iri (kameranın dibinde).
- **Ova bölümlerinde sur uzak**: 32o'da kıyıdan sura 31,4 m (eski 21,4), 28o'da topla sur arası 113,7 m (eski 103,4): yeni
  hendek ve teras daha geniş (kurgu gereği; aradaki ova mesafeleri aynı).
