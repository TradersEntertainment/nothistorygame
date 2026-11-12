# P6 düzeltme turu — bağımsız denetim (2. tur)

Denetçi: yalnız KENDİ koşularım ve karelerim; geliştiricinin paftalarına/ölçümlerine dayanmadım. Oyun kodu değiştirilmedi (`git status`: yalnız
`--import` ürünü `.translation`/`.import` dosyaları; bunlar kaydedilmedi). Dal: `wip/denetim2-p6` (`wip/duzeltme-p6` ucu `b4e88133` üstünde).

## 0. Düzen (üç ağaç, hepsi depo dışı)

| Ad | İçerik |
|---|---|
| **ÖNCE** | dalın ucu, ama 8 dosya `git show e551de84:` ile eski hâlinde: `chapter20/22o/26o/36b/37o.gd`, `level/land_walls.gd`, `level/wall_fight.gd`, `combat/oil_hazard.gd` (`/root/w/once`) |
| **ARA** | `ef860ea2` (= `git merge-base HEAD origin/wip/0.99.119`, bu turun başı): 5 dosya (`chapter26o/36b/37o.gd`, `land_walls.gd`, `oil_hazard.gd`) o kayıttan (`/root/w/ara`) |
| **SONRA** | dalın ucu `b4e88133` |

Makine: 4 çekirdek, llvmpipe. Başsız: `--max-fps 20`, aynı anda ≤2. Ekranlı: `PACE=1 xvfb-run … --dialogshots --shotevery=1 --snapevery=0.5 --hitchaudit` (RINFO=1), aynı anda 1;
26o/36b/20/22o koşuları 1200–1500 sn zaman sınırıyla kesildi (RINFO için yeter; 26o'nun giriş alayı ayrıca PACE'siz tam koşuldu). Kareler 640×360 (oyunun kendi çıktısı).
Kare adları: `t####` = `--snapevery` oynanış karesi, `D…` = replik karesi; ÖNCE/SONRA aynı replik anına (dosya zamanı sırası) hizalı.

## 1. Kapsam ve kurallara uygunluk

`git diff --stat ef860ea2 HEAD`: `chapter26o.gd +1`, `chapter36b.gd`, `chapter37o.gd`, `combat/oil_hazard.gd +3/-1`, `level/land_walls.gd` (yalnız `_wear_props`, `:777-799`) + `docs/_kanit_dp6`.
**Görev dosyasının dışına çıkılmamış.** Ortak dosya (bot/test betikleri, `tests/`, `wall_fight.gd`, `stage.gd`…) değişmemiş. `oil_hazard.gd` yalnız 7. madde (`:86-87`).

| Kural | Sonuç |
|---|---|
| Replik anahtarı/sırası, süre, sayaç, sonuç koşulu | `git diff ef860ea2 HEAD -- scripts` içinde `say/bark/create_timer/await/STOCKADE_TIME/WARN/HIT_*` satırı eklenmemiş/değişmemiş; tek silinen `randf` satırı bot satırı |
| Kalabalık sayısı | 37o: ip çeken azap sayısı 3 (aynı); 36b: 6 kazıcı (aynı) |
| Bot yolu | yalnız `chapter37o.gd:610-612` (`GameState.autotest and lose`); 36b rakip çıkış noktası `spawn_z` = 56,1 = özgündeki `54,6 + 1,5` (aynı) |
| Denetim susturma / `no_audit` / `_ok` / filtre | yok. `no_rally/no_talk/no_walk` yalnız yeni azap/dekor ağlarında (önceki turdan) |
| Kanca/sonda kalıntısı | `grep -rn "SONDA\|PROBE\|HAULMETRIC" scripts tests tools` boş |
| Yeni `class_name` | yok |
| Testi kolaylaştırmak için koşul gevşetilmiş mi | kabul koşulları (`_autotest_report`, `oil.hits==1`, `barrels>=2 …`) **aynı**; gevşetme yok. Bot tarafı değişikliği 6. maddede, oyun tarafı 7. maddede (aşağıda, dosya:satır ile) |

## 2. Madde madde hüküm (d_p6.md)

| # | Madde | Hüküm | Kendi kanıtım |
|---|---|---|---|
| 1 | 37o RINFO | **DOĞRULANDI** | §5 tablo: ön çekiş (`D37O_T_03` ilk 3 örnek) ÖNCE 4755/3844 → SONRA 4659/3870 = çizim **−%2,0**, üçgen **+%0,7** (hedef ≤+%5 tutuyor); ARA'ya göre −%5,7/−%3,2 (yani bu tur yükü düşürmüş). `D37O_AZ_01` +%0,1/+%1,2, `D37O_T_PLANK` −%6,0/−%2,1. (Geliştiricinin "ilk dört örnek +%5,6" sonucunu tekrar edemedim; örnek gürültüsü ±%5.) |
| 2 | 37o azap yerleşimi | **DOĞRULANDI (bot yolu) / KISMEN (oyuncu yürürse)** | Kare: `p01` (ARA|SONRA aynı an: ARA karesinde kırmızı azap çok büyük: gözle kadrajın ~%17'si, alt kenardan taşıyor; SONRA'da ~3 m ve ~%5), `p03` yan sonda. Geçici sonda (`/root/w/probe`, sökülü/depo dışı) 58 örnek, bot yolunda: en yakın azap **3,04 m**, en büyük kadraj payı **%11,2** (≤%15), ayak izi yayılması ≤0,20 m, azap y − zemin ≤0,065 m (ayak havada/gömülü değil). Arkadaki azabın taşan ayağı: yok. **Ama** oyuncu azaplara 0,55 m yürürse (`_haul_tick`:`>0.6` eşiği, `chapter37o.gd:869`) en yakın azap **2,16 m**'ye iniyor (sonda `w37`, 3 koşu; 3 sn kadar yerine dönmüyor) → "2,2 m'den yakın olmasın" ölçütü gerçek oyuncuda 0,05 m ihlal ediliyor (kadraj payı hâlâ <%15). Öndeki azabın kolu: yan karede iki el ipte (`p03`), oynanış karesinde 640 px'te kol ayrıntısı seçilmiyor (KISMEN). |
| 3 | 26o açılışta elde eşya | **DOĞRULANDI** | `p04`, `p09`: ÖNCE "Elde: Leblebi" (kutu avuçta; giriş alayında da elde), SONRA "Elde: boş", eller rahat. Kod `chapter26o.gd:57`. |
| 4 | Yer ayrıntıları (sedye/kova/kırık merdiven) | **KISMEN** | `p06` (20): SONRA'da yalnız sol kenarda kesik bir kırık-merdiven tahtası ve taş benzeri koyu kütleler; sedye ve kova **seçilmiyor** (zoom: taş gibi). `p04`/`p08` (26o): küçük kahverengi-gri bir kütle (~25 px), sedye/kova diye okunmuyor. `p07` (22o): kadraj kenarında ~15 px'lik küçük lekeler. `p05` (36b, `t0032`): kova (yan yatmış) ve kırık gri parça okunuyor → en iyi sonuç 36b'de. `WALKTHRU`/yürüme tıkanması: bu ayrıntılarla ilgili yok (`no_walk`, çarpışmasız). Kural "seçilir biçimde" → 20/22o/26o'da karşılanmıyor. |
| 5a | 36b kazıcı aletleri | **DOĞRULANDI** | `p05`: ÖNCE (`t0040`) kazıcılar ~14 m'de, alet okunmuyor, elde Kol Bandı; SONRA (`t0032`) kazıcı 4–5 m'de, kürek elde, önünde koyu çukur şeridi, yan yatmış kova. Çukur şeridi düz koyu levha gibi duruyor (çukur derinliği yok): küçük estetik kusur. Çarpışma sonrası çıkış noktası özgündeki yerde (`spawn_z`). Kazıcı i=3 (x+2,0; z 44,8) Leon'un yerine (x+3,2; z 45,2) 1,2 m: kare ve `VISAUDIT overlap` yok. |
| 5b | 37o ıska kancası | **DOĞRULANDI (oynanış karesi) / KISMEN (okunurluk)** | Geçici sonda (`probe`: ilk atışı ıskaya zorlayan env, depo dışı) + **gerçek oyuncu kamerasından** `p03` alt satır (`p37/t0306,t0308,t0309`): ip elden yere sarkıyor, uzak parça kancaya ince kenevir ip; kameranın içinden geçen damalı düz şerit **yok**. Bot kamerayı yere indirdiği için kare kısmen yer görüntüsü. |
| 6 | 37o `lose` botu (`chapter37o.gd:610-612`) | **DOĞRULANDI (bot tarafı)** | §3 tablo: SONRA 50/50 PASS; ÖNCE 47/50 (3 FAIL). Yalnız `autotest and lose` yolu; oyuncu etkilenmiyor. |
| 7 | 26o `lose` yağ yarışı (`oil_hazard.gd:87`) | **DOĞRULANDI** | §3: SONRA 50/50 PASS; ÖNCE 48/50 (2 FAIL, ikisi de `oil=1/1`). **Oyun tarafında** ve gerçek oyunda da geçerli bir değişiklik: aşağıda §3. |
| 8 | `ARMAUDIT unarmed` kök neden | **KANITSIZ (kök bulunmadı; bulgu maskelenmiş olabilir)** | ÖNCE 37o `lose` 50 koşuda 3 kez (`foe_dist=2,2/2,4/2,4`, `duel_active=false`; üçü de PASS koşusu, `cuts=3…20`); SONRA'da 100 koşuda (37o+26o `lose`) **0**. Geliştiricinin hipotezi ("rakip 12 m eşiğinde") ÖNCE satırlarındaki 2,2–2,4 m ile uyuşmuyor. Yeni deterministik bot fıçıları ilk dakikalarda indirdiği için (`cuts=1`) satırın kaybolması botun zaman çizelgesinin değişmesinden olabilir; kök neden gösterilmedi. ORTAK DOSYA ÖNERİSİ (`wave_runner.gd`) denenmedi/doğrulanmadı. |

### Geliştiricinin "yapılamadı / bakılmadı" dediklerine karşılık

| Geliştirici | Bu denetimde |
|---|---|
| RINFO ilk-dört +%5,6 (hedefi aştı) | Kendi hizalı ölçümümde ilk 3 örnek +%0,7 → sorun yok (§5) |
| 22o `H_GUN` +%10,6 "KANITSIZ" | Benim ölçümüm: ilk3 çizim +%2,9 / üçgen +%7,0, en ağır3 −%8,0/+%4,9 → sınır içi; ama 22o'nun `H_DUEL` anı örnek sayısı 13/6, çizim −%28,7 üçgen +%27,3 (en ağır3), **belirsiz** (dövüş konumları farklı); bu tur 22o'ya yalnız yassı yer ayrıntısı eklemiş (ARA→SONRA farkı kodda yok) |
| 20'de sedye/kırık merdiven Giustiniani arkasında; yalnız kova seçilir | Bende kova da seçilmiyor (`p06`) → madde 4 YANLIŞ/KISMEN |
| 26o'da sedye altyazı arkasında | doğrulandı (KISMEN) |
| 36b'de kova seçilir | doğrulandı |
| Oyuncunun azaplara yürümesi karelenmedi | Ölçtüm (sonda `w37`): 2,16 m (madde 2) |
| `ARMAUDIT` kök neden | bulunmadı (madde 8) |
| 37o elle yürüyüş | gerçek oyuncu elle oynanmadı (BAKILMADI) |

## 3. Kararsız testler (kök neden, oran, oyuna etkisi)

Başsız `--max-fps 20`, bütün koşular ham olarak `testler.txt`'te.

| Senaryo | Düzen | Koşu | PASS | FAIL | ARMAUDIT/VISAUDIT |
|---|---|---|---|---|---|
| 37o `lose` | ÖNCE | 50 (20+30) | 47 | 3 (hepsi `barrels=1/5 cuts=37–39 duel=true`) | ARMAUDIT 3 |
| 37o `lose` | **SONRA** | 50 (20+30) | **50** | 0 | 0 |
| 26o `lose` | ÖNCE | 50 (20+30) | 48 | 2 (`oil=1/1`) | 0 |
| 26o `lose` | **SONRA** | 50 (20+30) | **50** | 0 | 0 |
| 26o varsayılan (yağdan kaçan bot; yarışın geçtiği diğer yol) | ÖNCE / SONRA | 20 / 20 | 20 / 20 | 0 / 0 | 0 |

İlk 20'şer koşuda ÖNCE de 20/20 geçti (37o ve 26o); farkı ancak ek 30'ar koşu gösterdi (ÖNCE FAIL oranı ≈%6 / %4, SONRA 0/50): Fisher (37o 3/50 vs 0/50) p=0,24, (26o 2/50 vs 0/50) p=0,49, birlikte 5/100 vs 0/100 p=0,06 → **kararsızlığın azaldığına işaret, kesin kanıt değil**; kök neden zaten kodla açık.

**Kök neden ve düzeltmenin yeri:**
- 37o: bot tarafı. `chapter37o.gd:610-612`: `randf() < 0.5` yerine `_lose_strokes % 4 == 0` (`:69` sayaç, `GameState.autotest and lose` kapılı). Oyun/denge/gizli süre değişmedi (`STOCKADE_TIME`, `_heave`, `_throw_hook` aynı). Etki: `lose` botu artık 3 art arda iyi vuruşu hep yapabiliyor (her kancada ilk fıçı); eskiden P(<2 fıçı)≈%5. Not: kayıp koşusu artık hep "2 fıçı, `cuts=1`" yolundan geçiyor (eski rastgele yolun `cuts=3…39` çeşitliliği kalktı) → test kapsamı biraz daraldı, kabul koşulu aynı.
- 26o: **oyun tarafı**, `oil_hazard.gd:87`: `_live = fight.pour(...) > 0 or float(cauldron["t"]) >= 0.0`. `chapter26.gd:_pour_loop` (ambiyans dökümü) aynı kazanı ±2,95 sn pencerede dökerken `WallFight.pour` 0 döndürüyor, `_live=false` oluyor, merdivende duran oyuncu yanmıyordu (ve `dodged += 1` sayılıyordu: "kaçtı" değil, "yağ yok"). **Oyuncunun deneyimi:** merdivende yağ penceresinde (`WARN+0,5…WARN+1,5` sn) ortada duran oyuncu artık bu yarış durumunda da 35 hasar alıyor (eskiden alınmıyordu). Kazanın dökümü ambiyans ise yağ şeridi ekranda ambiyans dökümü olarak da görünüyor (hedef kazanın x±1 m'si, z 18); ama ambiyans dökümü hasar penceresinden 1,5–2,9 sn önce başlamışsa akan yağ hasar anında bitmiş olabilir (şerit ~2 sn görünür) → o dar durumda görünür yağ olmadan 35 hasar. Sıklık: yarış başsız botta ≈%35–55 (ÖNCE denetçi ölçümü); gerçek oyunda kazan sırası ve süre rastgele olduğu için benzer olasılık. Dengeyi/zorluğu çok az sertleştiriyor, `HIT_*`, hasar, eşikler aynı. KABUL edilebilir; ama ZORUNLU 4'te öneri var.

## 4. Yeni kusurlar (listeden bağımsız aradıklarım)

Her biri için "ÖNCE'de var mıydı?" yazıldı.

| # | Kusur | Yer | ÖNCE | ARA | SONRA |
|---|---|---|---|---|---|
| K1 | **`VISAUDIT sunk`**: Duelist/Person gedik moloz basamağında 0,48 m gömülü (`feet y 1,8`, kat üstü 2,28; `shape (8.6,0.55,2.4)@(0,2.0,15.6)`) — bölüm 20 `hit` (ve bir ekranlı 37o koşusunda `feet 0,8/zemin 0,97`) | `land_walls.gd:545-552` katman 0 (rubble basamağı), Person zemin y'si moloz üstünü bilmiyor | **1/50 koşu** (%2) | 2/20 (%10) | **5/52 (%10)** |
| K2 | `WALKTHRU` + `VISAUDIT insolid` 26o giriş alayı (`D26O_N_IN`, askerler z 42,4'teki 1,3×2,1×0,1 pavez kalkanlarından geçiyor; `chapter26o.gd:135`), yalnız PACE'li ekranlı koşuda | 26o `Assault`/giriş | **VAR** (`o26p`, 3 satır) | VAR (`a26`) | VAR (`s26`) |
| K3 | `VISAUDIT float` ARA'da 37o ip çeken azap (`feet y 0,7`, zemin 0,27) | `_haul_spots` ARA | – (azap yok) | 1/1 ekranlı koşu | 0 (SONRA'da s37 ve p37 ekranlı koşularında, ayrıca 3 başsız sonda koşusunda yok; tek örnek, düzeltmenin işlediğine işaret) |
| K4 | 36b çukur şeridi düz koyu levha | `chapter36b.gd:115-116` | yok (kazı önceki konumda) | var | var; küçük |
| K5 | RINFO gürültüsü: 36b/26o'da çizim artışı kesin çürütülemedi (§5) | — | — | — | KISMEN |

K2 ÖNCE'de de var → P6 sorumluluğu değil. K1 özgünde nadir, P6'nın moloz basamağıyla (önceki tur) yükselmiş; bu turda düzelmemiş (ARA'da %10, SONRA %10).

## 5. RINFO (çizim artmaz, üçgen ≤+%8; hedef ≤+%5)

PACE ekranlı, `--hitchaudit`, RINFO 2 sn aralıkla; hizalama: replik anahtarı evresi (`PACE say … key=` sıralaması). "ilk3" = o evrenin ilk üç örneği (aynı an), "en ağır3" = evrede üçgeni en yüksek üç örnek. Sayılar: çizim/üçgen(k). Ham: `rinfo_ham.txt`.

| Sahne / anı | n (Ö/S) | ÖNCE | SONRA | çizim | üçgen | ARA→SONRA |
|---|---|---|---|---|---|---|
| **37o `D37O_T_03` ön çekiş (ilk3)** | 20/17 | 4755 / 3844 | 4659 / 3870 | **−%2,0** | **+%0,7** | −%5,7 / −%3,2 |
| 37o `D37O_AZ_01` (ilk3 = en ağır3) | 11/12 | 5010 / 5556 | 5015 / 5623 | +%0,1 | +%1,2 | −%0,4 / +%0,2 |
| 37o `D37O_AB_02` (ilk3) | 13/12 | 4276 / 2862 | 4127 / 2940 | −%3,5 | +%2,7 | −%2,3 / −%1,0 |
| 20 `D20_G_GUN` (en ağır3) | 11/11 | 8072 / 10113 | 7952 / 10218 | −%1,5 | +%1,0 | – |
| 20 `D20_G_DUEL` (ilk3; n 15/5) | 15/5 | 6636 / 9072 | 7627 / 9678 | **+%14,9** | +%6,7 | – (en ağır3: −%6,2/−%6,1) |
| 22o `D22O_H_GUN` (ilk3) | 8/8 | 4582 / 3422 | 4714 / 3662 | +%2,9 | +%7,0 | – |
| 22o `D22O_T_FIRE` | 2/2 | 4390 / 2884 | 4547 / 3077 | +%3,6 | +%6,7 | – |
| 22o `D22O_H_DUEL` (en ağır3; n 13/6) | 13/6 | 6651 / 4657 | 4744 / 5926 | −%28,7 | **+%27,3** | – (ilk3: +%3,2/+%2,4) |
| 36b `D36_G_GO` (ilk3, 2 koşu havuzlu) | 24/25 | 4041 / 5452 | 4106 / 5847 | **+%1,6** | +%7,2 | +%3,9 / +%5,2 |
| 36b `D36_G_GO` (en ağır3) | 24/25 | 4483 / 6016 | 4769 / 6300 | **+%6,4** | +%4,7 | +%11,9 / +%4,5 |
| 26o `D26O_H_GUN` (ilk3; n 21/10) | 21/10 | 7811 / 5988 | 8612 / 6255 | **+%10,3** | +%4,5 | +%10,1 / +%4,5 |
| 26o `D26O_H_GUN` (en ağır3) | 21/10 | 9154 / 6750 | 8588 / 6786 | −%6,2 | +%0,5 | +%0,5 / +%3,6 |

Okuma: **37o** (ana madde) açıkça geçiyor ve ARA'dan da hafif. **20 ve 22o'da** bu tur kod değişikliği yalnız 12 yassı yer ayrıntısı (baked tek ağ, +0 çizim): farklar dövüş anındaki konum/örnek gürültüsü (±%10–15; aynı kodla örnek sayıları 15/5, 13/6 farklı). **36b ve 26o**: çizim artışları (+%1,6…+%10,3) gürültüyle ayrılamıyor, bu turda 36b'ye eklenen 2 `Props.box` çukur şeridi tek tek +2 çizim çağrısı eder (≈%0,05) — ölçülen artışı açıklamaz; yönü "var" diye yazmıyorum, "çürütemedim" yazıyorum (KISMEN). Üçgen hiçbir ağır "ilk3" anında +%8'i aşmadı (en yüksek 36b +%7,2, 22o +%7,0). Dövüş anlarındaki +%27 (22o H_DUEL en ağır3) bu turun değişikliğine atfedilemiyor (ARA=SONRA 22o kodu aynı).

## 6. Testler

- `parse_check`: `PARSECHECK PASS scripts=248` (SONRA, ÖNCE ve ARA kopyalarında da).
- P6 bölümleri, bütün varyantlar **ikişer kez**, başsız: 20 (`""`, tape, late, hit, lose, niko_idle, idle, difficulty=0, difficulty=2: 9/9×2), 22 (7×2), 22o (6×2), 26o (5×2), 36b (2×2), 37o (3×2) = **64/64 `AUTOTEST PASS`**. Yasak satırlar: yalnız §4 K1 (`VISAUDIT sunk`, 20 `hit` ikinci koşu); `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `WARN_VOID_TELEPORT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `JOURNEY_*` **yok**.
- Komşular (bir kez): 0, 21 (6/6), 26, 28o, 20o, 25, 31o, 32o, 41o, 42b: hepsi `AUTOTEST PASS`, yasak satır yok.
- Ek: 20 `hit` ×(20+30+2) SONRA, ×50 ÖNCE, ×20 ARA (K1 için); 37o ve 26o `lose` ve 26o varsayılan (yukarıda).
- Ekranlı koşular: 37o ×4 (ÖNCE, ARA, SONRA, sonda), 36b ×5, 22o ×2 ve PACE'siz 26o ×2 `AUTOTEST PASS` (`rc=0`); PACE'li 26o ×4 ve 20 ×2 koşusu zaman sınırında kesildi (`rc=124`, yalnız kare/RINFO için); hiçbirinde `SCRIPT ERROR` yok. RINFO ham: `rinfo_ham.txt`.

## 7. Kare kanıtı (paftalar)

`p01_37o_azap_ara_sonra` (azap yerleşimi ARA|SONRA), `p02_37o_once_sonra_cekis` (ÖNCE el: Leblebi + damalı şerit ip | SONRA iki el ipte, azaplar), `p03_37o_sonda_yan_arka_iska` (sonda_ yan görünüş + ıska oynanış karesi), `p04_26o_once_sonra` (eller), `p05_36b_once_sonra_kazici`, `p06_20_once_sonra`, `p07_22o_once_sonra`, `p08_26o_yer_yakin` (yer ayrıntısı 3× yakın), `p09_26o_giris_alayi_once_sonra` (Leblebi alayda).

## 8. Bakılmadı / yapılamadı

- Gerçek oyuncu elle yürüyüşü (yalnız bot + sonda ile 0,55 m kayma); 37o'da elle ıska atışı (sondayla zorlandı).
- 22 (kule önü) ekranlı gezilmedi; hendek zemini oynanış karesi yok.
- RINFO tek koşuluk (36b ×2, 26o ×1–2 tree); gürültü ±%10 → "çizim artmaz" kuralı 36b/26o'da kesin sınanamadı.
- Ses üretilmedi; PR açılmadı; `main`e dokunulmadı.

## GENEL HÜKÜM: **KÜÇÜK DÜZELTMELERLE KABUL**

Gerekçe: dokuz zorunlu maddenin (37o RINFO, azap yerleşimi, 26o eller, 36b kazıcılar, ıska ipi, iki kararsız test, kural uyumu) çekirdeği kendi karelerimle/sondamla doğrulandı (37o çizim −%2/üçgen +%0,7; 3,0 m/≤%11 kadraj; 100/100 `lose` PASS; 64/64 tam paket). Kalan sorunlar küçük ve yerel.

### ZORUNLU düzeltmeler
1. **`scripts/level/land_walls.gd` (≈`:545-552`, gedik moloz basamağı katman 0/Person zemin y)**: bölüm 20 `hit` (ve 37o) `VISAUDIT sunk` (ÖNCE %2 → ARA/SONRA %10). Beklenen: moloz basamağı üstünde yürüyen/duran Person/Duelist y = üst yüzey (2,28); `hit` ×50 koşuda `VISAUDIT` yok.
2. **`land_walls.gd:_wear_props` (sedye/kova/kırık merdiven, yeni 12 öğe)**: 20, 22o, 26o açılış karelerinde seçilmiyor (taş gibi). Beklenen: 20'de `D20_G_01` karesinde, 26o'da `D26O_H_01`'de 3–5 m öndeki sedye (iki sap, bez), kova (kulplu) ve yatık merdiven (basamaklı) ayırt ediliyor; kadraj ortasından 1,5–3 m yanda, ≥ özgün ölçü, kenar/altyazı kutusu arkasında kalmasın.
3. **`chapter37o.gd:_haul_tick` (`:869`, 0,6 m yeniden yerleştirme eşiği)**: oyuncu 0,55 m yürüyünce en yakın azap 2,16 m. Beklenen: eşik ≤0,3 m ya da `HAUL_MIN_DIST` ≥2,9 m; sonda `d_min ≥ 2,2 m`.
4. **(Öneri → zorunlu değil ama izlenmeli)** `oil_hazard.gd:87`: ambiyans dökümü hasar penceresinden >1,5 sn önce başlamışsa şerit canlı sayılmasın (`float(cauldron["t"]) < 1.45`), böylece yağ görünmeden hasar olmaz; 26o `lose` ×50 yine PASS olmalı.

### Önerilen / düşük öncelik
5. `ARMAUDIT unarmed` kök neden (ÖNCE %6, SONRA 0/100): `wave_runner.gd` önerisi doğrulanmadı; ayrı iş.
6. 36b çukur şeridine derinlik (koyu kutu yerine iki katman) ve yan yatmış kova küçük estetik.
7. K2 (26o giriş alayı `WALKTHRU`, ÖNCE'de de var) 26o sahibine.
