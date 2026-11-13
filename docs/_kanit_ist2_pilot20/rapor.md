# PİLOT-20 — Bölüm 20 ve 20o yeni İstanbul surunda (Mesoteikhion kesimi): doğrulama raporu

> Dal `wip/ist2-pilot-20`. Taban: önceki oturumun kanıtsız kaydı `9f32c394`. Bu oturum: kur, koş, bul, düzelt, kanıtla.
> Sur görünüşü dosyalarına (`surlar*.gd`, `sur_oturtma_ag.gd`, `sur_gorunus.gd`, `sur_zemin.gd`, `sur_doku.gd`, `sur_kule.gd`,
> `gorsel_dil.gd`, `ordugah*`) ve `sur_sozlesme_donmus.json`'a dokunulmadı. Denge, hasar, sayaç, replik metni, ses: değişmedi.
> Ham çıktılar `testler/`, kareler `kare/`. Makine: 4 çekirdek, ekransız testler `--max-fps 20`; kareler xvfb + Mesa llvmpipe
> (yazılımsal GL, kare başına ≈1,3 sn).

## Özet

| # | Madde | Durum | Kısa |
|---|---|---|---|
| 1 | Kurulum + ayrıştırma | **TAMAM** | Godot 4.4.1 resmi, `--import`, `PARSECHECK PASS scripts=354`; Bölüm 20 yeni sette ilk koşu PASS |
| 2 | Testler (20 ×3 + eski ×1; 20o ×2 + eski ×1) | **TAMAM** (bir madde KISMEN) | ilk tur 66/66 PASS, denetim 0; bulunan 4 kusur düzeltildi; son tur aşağıda. 20o `=wide` düellosu hâlâ eskiden uzun (KISMEN) |
| 3 | Öteki bölümler | **TAMAM** | 21 bölüm PASS, denetim 0. 26 `=hold_box`'ta seyrek `VISAUDIT overlap` **taban kayıtta da var** (pilot öncesi) |
| 4 | Sözleşme | **TAMAM** | `SURSOZLESME PASS kalem=13 kesim=8`; `SUROYUN … havada=0 gomuk=0 katida=0`; `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` |
| 5 | Gerçek yürüyüş | **TAMAM** | iki sette 10 bacak, takılma 0, düşme 0, etkileşim eksiği 0 |
| 6 | Kareler | **TAMAM** (Bölüm 20: 10 çift) / bkz. 20o | oyuncunun kamerasından 1280×720 jpg 85 + pafta |
| 7 | Yöneticinin gördükleri | **KISMEN** | bant ve dikdörtgen yama = sur kesiminin `SurDibiEtek`'i (tur 7'ye istek, teşhis karesiyle); set dekoru yerleşimi düzeltildi |
| 8 | Bütçe | **TAMAM** | yeni set eski setten HAFİF (çizim −%15…−%45, ilkel −%10…−%43); kurulum 6,7 → 4,9 sn |
| 9 | Rapor | **TAMAM** | bu belge |

## Bu oturumda bulunan ve düzeltilen kusurlar (kök neden → düzeltme → kanıt)

1. **Gözcü canlı değildi** (yeni sette `=hit`/`=lose`'da `WARN_PORTRAIT_STUDIO speaker=SPK_LOOKOUT`, eskide yok). Yeni kesimde gediğe
   en yakın kurulu dış kule x 35,4 (eskide ±16); bölümün "yakın" aralığı ±32 olduğundan kule gözcüsü uzak siluet (MultiMesh)
   kalıyor, "Top geliyor!" sahnede yüzü olmayana düşüyordu. → `Garrison._land_walls_sur`: yakın aralık verilmişse gediğe en
   yakın kurulu dış kulenin gözcüleri canlı (eski anlam). Kanıt `testler/ara_c20_yeni_*_fix*.txt`, son matris.
2. **Moloz sırtı yanlış yerdeydi** (20o `=wide` düellosu 41/43 sn ↔ eski 13/11). `SurSet.moloz_sirti()` duvarın ortasını veriyordu;
   eskide sırt dış yüzün 0,2 m DIŞI, bütün barikat aşamalarının ova tarafıydı. Aşama 4'te `GedikOnarim` dış yüze insan boyu kazık
   çit (çarpışmalı) kurar: azaplar çitin içinde, oyuncu dışında kalıyordu. → sırt dış yüz + 1,4 m (çitin bir kişi payı önü).
   Sonuç: 20o `=wide` 2. dalga 43 → 22 sn; Bölüm 20 2. dalgası 31 → 17 sn (eski 24). **1. dalga hâlâ 35–41 sn (KISMEN)**:
   deneyle kanıtlı neden aşama 4'ün dış çiti (çit çarpışması kapalı denemede 11/15 sn, `testler/ara_deneme_citsiz_wide*.txt`;
   deneme kayda girmedi). Çit sözleşme parçası: bkz. "tur 7'ye istekler".
3. **Komutan taşıyıcıların arkasında kalıyordu** (`VISAUDIT personhidden key=D20_G_ASSAULT / D20_G_DUEL speaker=SPK_GIUST
   by=WallFight>Person`, kare koşusunda). Yeni sette depo ve taşıyıcı şeridi gediğin SOLUNDA; Giustiniani de soldaydı, şeride
   0,7 m. Eskide komutan şeritlerin karşı yanındaydı ("işçilerin ve taşıyıcı şeritlerinin dışında"). → Giustiniani ve Leon
   gediğin sağında (iç kulenin önü, işçilerle sağ siperin arası); doğuştan uzaklık eskiyle aynı (≈14 m). Engel denetimi 0.
4. **Okçular gedikten 21,8 m uzaktaydı** (eski 9,8). Gedik düellosu oyuncunun durduğu yerde başlar (azaplar oyuncunun gedik
   yönünde 3,6 m önünde doğar): ok teslim eden oyuncu için düello peribolosun ortasında açılıyordu. → okçular eskideki yerine
   (−9; 0; 11), ok sandığı depo yanına, iç surun dibine (−16; 0; 1,2). Hücumdaki ok koşusu eski 31,6 ↔ yeni 30,1 m (yürüyüşte
   26,7 ↔ 26,2 m).
5. **Mini harita yeni sette yoktu** (pafta: eskide sağ altta var). Yeni ova `SiegeField.world = false` kurulur; harita alanı
   (`MapView.GROUP`) yalnız `world` kurulumunda gruba giriyordu. → `SurSetSahne._harita()`: kesimin gerçek dünya yeri
   (`SurOyun a.xf`) ile IstBaglama'nın yaptığı gibi v2 harita alanı + `MapView.v2` (sahneden çıkınca kapanır).
6. Küçükler: `Assault` yeni sette tabya ve mancınık yönü ova kaydırmasını hesaba katıyor (bataryayla aynı); `spear_loop`
   yer değiştirirken komşunun VARACAĞI yeri de dolu sayar (yarış durumu; 26'daki overlap'ı tek başına çözmedi, aşağıda).
7. Test aracı: `=kare` bacakları ışınlar (yazılımsal GL'de gerçek yürüyüşle saatler sürüyordu; yürüme `=yuru`'da ölçülür),
   tüfek evresini atlar, karede gece saati gerçekçi (eskiden HUD'da "Saat −9.−31"), onarım karesi taşıyıcıların varış
   noktasının yanından. Teşhis aracı `tests/_ist/pilot20_teshis.tscn` (sur dışındakileri gizleyip kesimin adlı düğümlerini
   tek tek gizler).

## 2. Testler

Komut: `timeout 300 godot --headless --max-fps 20 --path . -- --chapter=… --autotest[=çeşit] [--difficulty=N] [--eskisur]`.
Süzgeç `tests/run_tests.sh`'inki; her dosyada `KOSU … rc=` satırı. Ham çıktılar `testler/`:
- **ilk tur** (önceki oturumun kodu, düzeltmelerden önce): `c20_yeni_*_r{1,2,3}.txt`, `c20_eski_*.txt`, `c20o_yeni_*_r{1,2}.txt`,
  `c20o_eski_*.txt` → 66/66 `AUTOTEST PASS`, denetim satırı 0 (ama `WARN_PORTRAIT_STUDIO` ve 20o `=wide` süresi: yukarıda 1, 2).
- **ara koşular** (her düzeltmenin sınaması): `ara_*.txt`.
- **son tur** (bütün düzeltmelerden sonra, aynı matris): `son_*.txt` → aşağıdaki "Son tur" bölümü.

<!-- SON_TUR -->

### AUTOTEST alanları eski ↔ yeni (ilk tur; alanların anlamı iki sette aynı, değerler aynı aralıkta)

### Bölüm 20: AUTOTEST alanları (eski ×1 | yeni ×3)

| çeşit | outcome | repair | knocks | arrows | gun | gunner | niko |
|---|---|---|---|---|---|---|---|
| d0 | 20.1 \| 20.1 / 20.1 / 20.1 | 10 \| 10 / 10 / 10 | 0 \| 0 / 0 / 0 | true \| true / true / true | 3/4 \| 3/4 / 3/4 / 3/4 | 4/4 \| 1/1 / 2/2 / 4/4 | 0 \| 0 / 0 / 0 |
| d2 | 20.1 \| 20.1 / 20.1 / 20.1 | 10 \| 10 / 10 / 10 | 0 \| 0 / 0 / 0 | true \| true / true / true | 3/4 \| 3/4 / 3/4 / 3/4 | 4/4 \| 4/4 / 4/4 / 2/2 | 0 \| 0 / 0 / 0 |
| def | 20.1 \| 20.1 / 20.1 / 20.1 | 10 \| 10 / 10 / 10 | 0 \| 0 / 0 / 0 | true \| true / true / true | 3/4 \| 3/4 / 3/4 / 3/4 | 4/4 \| 4/4 / 4/4 / 4/4 | 0 \| 0 / 0 / 0 |
| hit | 20.1 \| 20.1 / 20.1 / 20.1 | 10 \| 10 / 10 / 10 | 1 \| 1 / 1 / 1 | true \| true / true / true | 3/4 \| 3/4 / 3/4 / 3/4 | 5/5 \| 3/3 / 3/3 / 3/3 | 0 \| 0 / 0 / 0 |
| idle | 20.3 \| 20.3 / 20.3 / 20.3 | 10 \| 10 / 10 / 10 | 0 \| 0 / 0 / 0 | true \| true / true / true | 3/4 \| 3/4 / 3/4 / 3/4 | 3/3 \| 2/2 / 2/2 / 2/2 | 0 \| 0 / 0 / 0 |
| late | 20.3 \| 20.3 / 20.3 / 20.3 | 10 \| 10 / 10 / 10 | 0 \| 0 / 0 / 0 | false \| false / false / false | 3/4 \| 3/4 / 3/4 / 3/4 | 3/3 \| 2/2 / 2/2 / 2/2 | 0 \| 0 / 0 / 0 |
| lose | 20.3 \| 20.3 / 20.3 / 20.3 | 10 \| 10 / 10 / 10 | 0 \| 0 / 1 / 0 | true \| true / true / true | 3/4 \| 3/4 / 3/4 / 3/4 | 0/2 \| 0/1 / 0/1 / 0/1 | 0 \| 0 / 0 / 0 |
| niko_idle | 20.1 \| 20.1 / 20.1 / 20.1 | 10 \| 10 / 10 / 10 | 0 \| 0 / 0 / 0 | true \| true / true / true | 3/4 \| 3/4 / 3/4 / 3/4 | 4/4 \| 4/4 / 3/3 / 3/3 | 5 \| 5 / 5 / 5 |
| tape | 20.2 \| 20.2 / 20.2 / 20.2 | 10 \| 10 / 10 / 10 | 0 \| 0 / 0 / 0 | true \| true / true / true | 3/4 \| 3/4 / 3/4 / 3/4 | 3/3 \| 4/4 / 3/3 / 4/4 | 0 \| 0 / 0 / 0 |

### Bölüm 20o: AUTOTEST alanları (eski ×1 | yeni ×2)

| çeşit | outcome | hits | cracks | gun | gunner | duel | bed |
|---|---|---|---|---|---|---|---|
| def | 20O.1 \| 20O.1 / 20O.1 | 3 \| 3 / 3 | 0 \| 0 / 0 | 3/4 \| 3/4 / 3/4 | 1/2 \| 2/2 / 2/2 | true \| true / true |  \|  /  |
| edirne | 20O.1 \| 20O.1 / 20O.1 | 3 \| 3 / 3 | 1 \| 1 / 1 | 3/4 \| 3/4 / 3/4 | 1/2 \| 2/2 / 2/2 | true \| true / true | crooked \| crooked / crooked |
| edirne_ok | 20O.1 \| 20O.1 / 20O.1 | 3 \| 3 / 3 | 0 \| 0 / 0 | 3/4 \| 3/4 / 3/4 | 2/2 \| 2/2 / 2/2 | true \| true / true | sound \| sound / sound |
| flawed | 20O.1 \| 20O.1 / 20O.1 | 3 \| 3 / 3 | 1 \| 1 / 1 | 3/4 \| 3/4 / 3/4 | 2/2 \| 2/2 / 2/2 | true \| true / true |  \|  /  |
| hot | 20O.1 \| 20O.1 / 20O.1 | 3 \| 3 / 3 | 2 \| 2 / 2 | 3/4 \| 3/4 / 3/4 | 1/2 \| 2/2 / 2/2 | true \| true / true |  \|  /  |
| hot_tape | 20O.1 \| 20O.1 / 20O.1 | 3 \| 3 / 3 | 0 \| 0 / 0 | 3/4 \| 3/4 / 3/4 | 1/3 \| 3/3 / 2/2 | true \| true / true |  \|  /  |
| hot_taped | 20O.1 \| 20O.1 / 20O.1 | 3 \| 3 / 3 | 1 \| 1 / 1 | 3/4 \| 3/4 / 3/4 | 1/2 \| 2/2 / 2/2 | true \| true / true |  \|  /  |
| lose | 20O.1 \| 20O.1 / 20O.1 | 3 \| 3 / 3 | 0 \| 0 / 0 | 3/4 \| 3/4 / 3/4 | 0/1 \| 0/1 / 0/1 | false \| false / false |  \|  /  |
| named | 20O.1 \| 20O.1 / 20O.1 | 3 \| 3 / 3 | 0 \| 0 / 0 | 3/4 \| 3/4 / 3/4 | 2/2 \| 2/2 / 2/2 | true \| true / true |  \|  /  |
| wide | 20O.2 \| 20O.2 / 20O.2 | 0 \| 0 / 0 | 0 \| 0 / 0 | 3/4 \| 3/4 / 3/4 | 1/2 \| 8/8 / 7/7 | true \| true / true |  \|  /  |

`gunner=a/b` (tüfekçinin atış/kaçınılan) düellonun süresine bağlıdır, iki sette de koşudan koşuya oynar. Düello dalga süreleri
(`WAVERUNNER t=`): Bölüm 20 eski 1. dalga 8–18 sn ↔ yeni 4–11 sn; 2. dalga eski 16–30 ↔ yeni (son kod) 16–17 sn; 20o eski
9–18 ↔ yeni 8–17 sn, **20o `=wide` eski 13/11 ↔ yeni 35–41/21–23 sn (KISMEN, kusur 2)**.

## 3. Öteki bölümler

Kancalı yardımcıları kullanan bölümler (`grep -rln "Assault\|Garrison\|WallFight\|SiegeChaos\|SiegeField\|BattleExtras"
scripts/chapter*.gd`): 0, 1, 2, 12b, 17o, 18b, 21, 22, 22o, 23, 25, 26, 26o, 28o, 30o, 32o, 36b, 37o, 38o, 41o, 8y (+20, 20o).
Hepsi `AUTOTEST PASS`, denetim satırı 0 (`diger_c*.txt`, son tur `son_diger_c*.txt`). Bağdaştırıcı verilmeyen yol kodda
birebir aynı: bütün yeni dallar `sur != null and not sur.eski_mi` (ya da `SurSet.etkin` boş değilken) arkasında;
`SurSet.eski()` aynı sabitleri döndürür.

**26 `=hold_box`:** 6 koşuda 1 (`c26_hold_box_r4`: `VISAUDIT overlap … Garrison/Garrison at=(11.4, 8.0, 14.7)`), ikinci 8'lik
turda 1 (`Garrison/WallFight at=(9.6, 8.0, 14.7)`). **Pilot öncesi kayıtta da var:** taban `20948418` `git archive` ile ayrı
klasöre açılıp 12 kez koşuldu: 1 kez `VISAUDIT overlap … Squad/Squad at=(-17.9, 0.0, 8.0)` (`taban_c26_hold_box_r*.txt`). Bölüm 26
bağdaştırıcı almıyor; yani bu titreşim pilottan değil, 26'nın kalabalık koreografisinden (dış surdaki mızraklıların yer
değiştirmesi, yedek bölük). `spear_loop`'a varılacak yeri ayırma eklendi (gerçek bir yarış durumu), ama tek başına yetmedi:
**kök neden bu oturumda bulunmadı** (sonrakine not).

## 4. Sözleşme

`testler/sozlesme_*.txt`: `SURSOZLESME PASS kalem=13 kesim=8` · `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` (bu sürüm denetimi
3 kesim × tür tarıyor; önceki rapordaki 1186 nokta 8 kesimdi) · `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0`. Donmuş ölçü
dosyasına dokunulmadı.

## 5. Gerçek yürüyüş (`tests/_ist/pilot20_yuru.tscn`, gerçek `Player`, yükler gerçek etkileşim tuşuyla)

`testler/yuruyus_yeni.txt`, `yuruyus_eski.txt`. Takılma 0, düşme 0, etkileşim eksiği 0 (iki sette).

| bacak | eski sn | eski m | yeni sn | yeni m |
|---|---|---|---|---|
| doğuş → depo | 0,3 | 0,8 | 1,1 | 3,5 |
| depo → gedik (yüklü) ×3 | 4,5 / 4,8 / 4,6 | 10,8 / 11,3 / 10,7 | 6,3 / 5,5 / 5,5 | 13,8 / 13,1 / 13,0 |
| gedik → depo ×2 | 3,3 / 3,4 | 10,6 / 10,8 | 4,0 / 4,0 | 13,3 / 12,7 |
| gedik → ok sandığı | 3,4 | 10,6 | 5,8 | 17,4 |
| ok sandığı → okçular | 6,7 | 16,1 | 3,7 | 8,8 |
| okçular → siper | 0,9 | 2,8 | 1,2 | 3,6 |
| siper → gedik (düello yeri) | 1,8 | 5,6 | 1,7 | 5,2 |
| **toplam** | **34,0** | **90,1** | **38,9** | **104,4** |

Depo turu (git-gel) eski 8,0 sn ↔ yeni 9,5 sn: on yük 80 ↔ 95 sn, gece 170 sn içinde (süre değişmedi, karar 1-A).
Hücumdaki ok koşusu (gedik → sandık → okçular) eski 26,7 m / 10,1 sn ↔ yeni 26,2 m / 9,5 sn.

### Mesafe tablosu (yatay, merkezden merkeze; sözleşme kuralı: hedefe ≤ 20 m)

| çift | eski m | yeni m | not |
|---|---|---|---|
| doğuş → depo | 3,4 | 3,6 | |
| depo → gedik | 16,9 | 16,0 | kural 15–19 ✓ |
| depo → gedik önü (teslim) | 14,5 | 12,7 | |
| gedik önü → ok sandığı | 13,0 | 18,1 | ≤ 20 ✓ |
| ok sandığı → okçular | 18,6 | 12,0 | ≤ 20 ✓; ok koşusu toplamı 31,6 ↔ 30,1 |
| okçular → gedik | 9,8 | 9,8 | (önceki oturumda 21,8: kusur 4) |
| okçular → siper | 3,6 | 3,6 | |
| siper → gedik | 7,4 | 7,3 | ≤ 20 ✓ |
| doğuş → Giustiniani | 14,2 | 14,3 | |

Yeni noktalar (bölüm çerçevesi; x 0 gedik, y 0 peribolos, z 14 dış surun iç yüzü): depo (−11,5; 0; 4,2), doğuş (−9,6; 0,05; 7,2),
siperler (±5,5; 0; 10,5), ok sandığı (−16; 0; 1,2), okçular (−9; 0; 11), Giustiniani gedik önü + (3,6; 0; 1,8), ateş halkaları
(−33; 0; 6,6) ve (24; 0; 6,2). Hepsi `SurOyun.engeller()` dışında: `PILOT20ENGEL OZET nokta=9 engelde=0`.

## Bağdaştırıcı arayüzü (hangi sorgu hangi eski sabitin yerine)

Tam tablo `docs/SUR_SOZLESME.md` "Bölüm bağdaştırıcısı". Bölüm 20/20o'da kullanılanlar:

| eski | yeni sorgu | bu oturumda |
|---|---|---|
| `LandWalls.BREACH`, `BREACH_W` | `sur.gedik()`, `sur.gedik_en()` | |
| `BREACH + (0,0,−3,4)` (taşıyıcı varışı), `BREACH + (0,2,2,−1,2)` (teslim/hedef) | `sur.gedik_onu()`, `sur.barikat()` | |
| `on_rubble(BREACH + (0,0,1,2))` (düello sırtı) | `sur.moloz_sirti()` | **değişti**: dış yüz + 1,4 (kusur 2) |
| `LandWalls.on_rubble`, `rubble_y`, `outside_y` | `sur.on_rubble`, `sur.moloz_y`, `sur.dis_zemin_y` | |
| `DEPOT`, `SPAWN`, `MANTLETS`, `CANNON` | `sur.depo()`, `sur.dogus()`, `sur.siperler()`, `sur.top()` | |
| `OUTER_H`, sur yolu z 15 | `sur.dis_yol_y()`, `sur.dis_yol_z()`, `sur.dis_yol_x(x)` | |
| set / hendek (z 18–36, y 0 / −2,9) | `sur.teras_y()`, `sur.teras()`, `sur.hendek_z(t)`, `sur.ova_z0()`, `sur.ova_y()` | |
| `SiegeChaos.area` | `sur.peribolos()`, `sur.peribolos_engelleri()` | |
| `Garrison.land_walls(…)` | `…, sur)` → `_land_walls_sur` | **değişti**: en yakın kurulu kulenin gözcüsü canlı (kusur 1) |
| `field.world` (mini harita) | `SurSetSahne._harita()` | **yeni** (kusur 5) |
| `ARCHERS`, `ARROWS` (bölüm sabiti) | `ARCHERS_YENI`, `ARROWS_YENI` | **değişti** (kusur 4) |

## 6. Kareler (oyuncunun gerçek kamerası, xvfb + opengl3, 1280×720, jpg 85)

- Bölüm 20: `godot --path . --rendering-driver opengl3 --resolution 1280x720 -- --chapter=20 --autotest=kare
  --dialogshots=<klasör> [--eskisur]` → `kare/c20_eski|c20_yeni/an_01…an_10.jpg`, `kare/pafta_c20.jpg`. (`--autotest` +
  `--dialogshots` biçimi yazılımsal GL'de saatler sürüyordu, `=kare` aynı anları bölümün kendi akışından ışınlanarak alır.)
- Bölüm 20o: `-- --chapter=20o --autotest --dialogshots=<klasör> --shotevery=1 --snapevery=3 --tamboy [--eskisur]` →
  `kare/c20o_eski|c20o_yeni/an_01…an_06.jpg`, `kare/pafta_c20o.jpg`. (PACE=1 ile 600 sn'de oyunun yalnız 38. saniyesine
  geliniyordu; PACE'siz koşuldu.)
- Teşhis: `kare/teshis/sur_dibi_etek_teshis.jpg` (sol üst: sahne; sağ üst: yalnız sur kesimi; sol alt: `SurDibiEtek` gizli).

**Yeni setin her karesi (tam boy bakıldı):**

| kare | ne görünüyor | hüküm |
|---|---|---|
| 20 an_01 açılış | peribolos, iki surun arası, kuleler, taşıyıcılar, meşale, siper; sağdaki iç kulenin dibinde siyah tırtıklı bant | iyi; bant kötü (sur kesimi) |
| 20 an_02 depo | iç surun dibinde fıçılar ve toprak yığını, karanlık; yerde yatan yaralı; zeminde gri düz alan ile kahverengi şerit düz kenarla ayrılıyor | vasat: depo seyrek ve karanlık, zemin yaması kötü |
| 20 an_03 gediğe taşıma | elde fıçı, önde Giustiniani, taşıyıcılar, siper, yol taşları, mini harita | iyi |
| 20 an_04 aşama 2 | barikat fıçı sırası (ortada geçit), eğik kazıklar, işçiler, Giustiniani | iyi |
| 20 an_05 top uyarısı | siperin hemen ardında, "TOP!" uyarısı; kadrajı siper dolduruyor | doğru ama az şey görünüyor |
| 20 an_06 aşama 4 | toprak set kadrajı kaplayan dev, pürüzsüz kahverengi bir hap gibi; arkada kazık çit | **kötü** (GedikOnarim'ın toprak seti) |
| 20 an_07 hücum başlangıcı | bir taşıyıcının başı kameraya çok yakın; barikatın ardında azaplar | vasat |
| 20 an_08 ok sandığı | iç surun dibinde üst üste sandıklar, karanlık toprak; sur dibinde bitki | kabul (sandık zaten kutu) |
| 20 an_09 okçular | üç okçu dış sura bakıyor; sur dibinde siyah bant ve kara dikdörtgen boşluk; zeminde düz kenarlı kahverengi/gri yama | **kötü** (sur kesimi) |
| 20 an_10 düello | gediğin üstünde, barikat kazıkları kadrajı dolduruyor, ortada iki azap, tüfekçi uyarısı | okunur ama kalabalık: vasat |
| 20o an_01 top başı | mevzi, Urban, gabionlar; eskinin aynısı | iyi |
| 20o an_02 nişan | dolduran topçular, duman, nişan listesi | iyi |
| 20o an_03 atış | duman, isabet repliği | iyi |
| 20o an_04 soğutma | aynı mevzi, soğutma hedefi | iyi |
| 20o an_05 gece hücumu | ovadan gece sura bakış, tüfek; sur mazgallı, bantlı | iyi |
| 20o an_06 gedik | moloz yamacı, iç surun gediği; yamaçta dik duran düz yeşil levhalar (eskide yok) | **şüpheli/kötü**: kaynağı bu oturumda doğrulanmadı |

Kişi havada / gömülü / duvarın içinde: görülmedi (VISAUDIT de 0). "Aynı ressamın elinden": surla bölüm dekoru (ahşap siper,
fıçılar, kazıklar) birlikte duruyor; ayrık duranlar zemin yamaları, `SurDibiEtek` bandı ve aşama 3–4 toprak seti.

## 7. Yöneticinin ilk karede gördükleri

- **Sur dibinde siyah tırtıklı bant** ve **peribolos zemininde düz dikdörtgen doku yamaları**: teşhis (`pilot20_teshis.tscn`,
  `testler/teshis_okcu.txt`): bölümün bütün dekoru, kalabalığı ve ovası gizlendiğinde de duruyor; `SurOyun_mesoteikhion/
  OyunDilimi/Mesoteikhion/SurDibiEtek` gizlenince kutudaki koyu oran 0,598 → 0,229 ve kahverengi düz yama da kalkıyor. Kalan
  koyu tırtıklar kesimin adsız bitki/kaya düğümleri. Kaynak `scripts/world/ist/sur_oturtma_ag.gd:451` → **tur 7'ye istek**.
- **Set dekorunun boş köşeleri**: komutan, Leon, okçular, ok sandığı yeniden yerleştirildi (kusur 3, 4); mini harita geri geldi.
  Depo hâlâ seyrek ve karanlık (eski depo da aynı parçalardan; yeni yerde meşale yok) — aşağıda "hâlâ kötü".

## 8. Bütçe (Bölüm 20, `--autotest=butce`, ekranlı, tek başına koşu; 10 kare ortalaması; `testler/butce_*.txt`)

| bakış | eski çizim | yeni çizim | fark | eski ilkel | yeni ilkel | fark |
|---|---|---|---|---|---|---|
| peribolos | 5.741 | 3.560 | −%38 | 8,44 M | 6,22 M | −%26 |
| gedik ağzı | 5.618 | 4.346 | −%23 | 9,19 M | 8,28 M | −%10 |
| sur yolu | 7.713 | 4.278 | −%45 | 9,26 M | 5,27 M | −%43 |
| hava | 11.671 | 9.949 | −%15 | 9,14 M | 8,28 M | −%9 |

Kurulum (ms): eski set 5.270 + bölüm 1.438 = **6.708** ↔ yeni set 3.443 (sur kesimi 802) + bölüm 1.420 = **4.863**. Eski setin
ağırlığı `SiegeField.world` (HornWorld, şehir, CityLife); yeni sette ova `world = false`. Ekransız paralel testlerde set kurulum
medyanı eski 5.642 ↔ yeni 3.247 ms (31 koşu). Not: yazılımsal GL'de iki set de çok ağır (3,5–11,7 bin çizim); gerçek ekran
kartında ölçülmedi.

## Yön söyleyen replikler (yeni sette yanlış düşen; metne dokunulmadı)

Tarama: `i18n/strings.csv` tr, D20_/D20O_/UI_OBJ20*/UI_QTE20/UI_CH20*/UI_ITEM20/LORE_20 anahtarlarında yer/yön sözcükleri.

| anahtar | metin | yeni sette |
|---|---|---|
| `UI_OBJ20_ARROWS` | "Hücum! Ok sandığını al (depo, kapı yanı)" | **yanlış düşer**: depo yanı doğru, ama Mesoteikhion kesiminde iç kapı yok (karar 11) |
| `D20_G_ASSAULT` | "…okçular surun dibinde!" | doğru (okçular dış surun iç yüzüne 3 m) |
| `D20_LN_TALIM` | "Sol yanın bende." | doğru (Leon oyuncunun soluna konur, kod aynı) |
| `D20_G_03`, `UI_QTE20_COVER` | "siperin arkasına geç" | doğru |
| `UI_OBJ20O_COOL` | "topun yanında" | doğru |
| `UI_OBJ20O_GUN`, `D20O_U_GUN` | "mazgaldaki" | doğru (hedefler dış sur yolunda) |

## Sonraki bölümü taşıyacak kişiye kılavuz

1. **Oku:** `docs/SUR_SOZLESME.md` "Bölüm bağdaştırıcısı", bu rapordaki kusur listesi (aynı tuzaklar her bölümde çıkacak).
2. **Bağla (≈1 saat):** `var sur := SurSet.sec("<bölüm>", ESKI_SUR)`; `walls = LandWalls.new() if sur.eski_mi else SurSetSahne`;
   yardımcılara `sur` ver (`fight.sur`, `assault.sur`, `Garrison.land_walls(…, sur)`). Bölümdeki her `LandWalls.<SABİT>` ve her
   çıplak sur sayısını (z 14–36, y 8, −2,9…) bağdaştırıcı sorgusuna çevir; `grep -n "LandWalls\.\|, 0, 1[5-9]\|, 0, 2[0-9]\|, 0, 3[0-6]"`.
3. **Yerleşim (≈1–2 saat), tuzaklar:**
   - Yeni sette gediğin sağında iç kule peribolosa taşar (x 0,2–9,2, etekle −2,8–12,2; z ≤ 8): depo SOLDA. Eskide sağda olan her
     şeyin (şerit, komutan, işçi) "karşı yanı" değişir: kim kimin önünde kalır, ona bak (VISAUDIT personhidden).
   - Dış kule aralığı ≈2 kat: kule x'ine bağlı "yakın" aralıkları (Garrison `near`) yeniden düşün.
   - Gedik onarım aşaması 4 dış yüze çarpışmalı kazık çit kurar: gedik sırtına doğan kişiler çitin önüne (`moloz_sirti()`).
   - Düello/olay "oyuncunun bulunduğu yerde" başlıyorsa, oyuncunun o anda olabileceği her noktanın (okçular vb.) gedikten
     uzaklığını eskiyle karşılaştır.
   - `field.world = false`: mini harita, CityLife, WorldWalk yok; harita `SurSetSahne._harita()` ile geliyor.
   - Her set noktası için `sur.engelde(p)` (autotest'te `PILOT20ENGEL` gibi bir satır yaz).
4. **Kanıt (≈2–3 saat makine):** varsayılan + bütün çeşitler yeni ×2–3, `--eskisur` ×1 (4 paralel, 20 FPS); yürüyüş botu
   (`pilot20_yuru` kalıbı); kareler `=kare` kalıbıyla (ışınlama; yazılımsal GL'de gerçek yürüyüş yok), `--tamboy`. Dalga
   sürelerini (`WAVERUNNER t=`) eskiyle karşılaştır: test PASS olsa da düello sıkışabilir (20o `=wide`).
5. **Tahmini süre:** bağlama + yerleşim 2–3 saat, kanıt 2–3 saat (makinede), kare değerlendirme 1 saat. Kuşatma
   hücumlu/merdivenli bölümler (26, 26o) bunun 2 katı.

## Tur 7'ye istekler (sur görünüşü; bu oturum dokunmadı)

1. **`SurDibiEtek`** (`sur_oturtma_ag.gd:451`): gece sur dibinde siyah tırtıklı bant + düz kenarlı kahverengi dikdörtgen şerit
   (`kare/c20_yeni/an_09_okcular.jpg`, `an_01_acilis.jpg`, teşhis `kare/teshis/sur_dibi_etek_teshis.jpg`). Kenar yumuşasın,
   peribolos zemin rengine karışsın; gece koyu tırtıklar (kesimin adsız bitki/kaya düğümleri) çok kara.
2. **`GedikOnarim` aşama 3–4 toprak seti** (`sur_oyun_parca.gd`, `Props.ball` 8,6 × 1,5 × 2,4): yakından dev, pürüzsüz bir hap
   (`kare/c20_yeni/an_06_onarim_asama4.jpg`). Sepet/çuval/toprak yığını dokusu ya da parçalı yığın.
3. **`GedikOnarim` aşama 4 dış kazık çiti** (çarpışma kutusu dış yüz + 0,1, 2,4 m): düello çitin dibine sıkışıyor; 20o `=wide`
   1. dalga eski 13 ↔ yeni 35–41 sn (çit çarpışması kapalıyken 11 sn). Öneri: çit gediğin tam eni değil, ortada 2 m'lik bir
   "kırık" bıraksın ya da çarpışma kazıkların üst yarısında olsun; ya da sözleşmeye "aşama 4'te düello yeri" noktası eklensin.
4. 20o gedik karesinde moloz yamacında dik duran düz yeşil levhalar (`kare/c20o_yeni/an_06_gedik.jpg`): kaynağı bulunmadı
   (yeni sette `BattleExtras` osm şeridi terasa taşındı; ondan olabilir — doğrulanmadı).

## Kendi karelerime bakınca hâlâ kötü olanlar (dürüst)

- Sur dibi bandı ve zemin yamaları (her peribolos karesinde) — kaynak sur kesimi, düzeltilmedi.
- Aşama 3–4 toprak seti hap gibi; onarım karesi (an_06) kötü.
- Depo seyrek ve karanlık (an_02): yeni yerinde ışık yok. Eski depo da aynı parçalar; bu oturumda dokunulmadı.
- Düello karesi (an_10) kazıklarla dolu, okunması zor.
- 20o gedik karesinde açıklanmamış yeşil levhalar.
- 20o `=wide` düellosu eskiden 3 kat uzun (oyun süresi sabit kalmasına karşın oyuncu hissi değişir).
- Bütçe yazılımsal GL'de ölçüldü; gerçek GPU'da kare süresi ölçülmedi.
- `docs/_ajan/gorev/ist2_kalite_notlari.md` bu dalda 31. notta bitiyor: görevde anılan 32–33. notlar yok, okunamadı.
