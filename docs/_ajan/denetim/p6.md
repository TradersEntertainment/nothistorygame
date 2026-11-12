# P6 (kara surları) — bağımsız denetim, 3. tur

Denetçi koşuları: Godot 4.4.1, 4 çekirdekli/16 GB makine, başsız koşular `--max-fps 20`, aynı anda en çok 3 başsız (ekranlı koşular ayrıca; iki kez bellek yetmeyip çekirdek bir ekranlı koşuyu öldürdü, bunlar yeniden koşuldu, bkz. §5).
Ham AUTOTEST satırları: `kosular.txt`. Paftalar bu klasörde (`p01…p11`).

**Düzenler.** SONRA = bu dalın ucu (`wip/denetim-p6`, f375da92 üstü). ÖNCE = aynı ağaç, yalnız yedi P6 dosyası `git show e551de84:<dosya>` ile eski hâlinde (diğer bütün dosyalar dalın ucunda; yani ÖNCE *saf* e551de84 değil. Bu, P6'yı başka ajanların işinden ayırmak için bilerek böyle kuruldu; "saf e551de84" düzeni KURULMADI). Üçüncü düzenler: A = ÖNCE + `chapter37o.gd` + `land_walls.gd` yeni; B = ÖNCE + `land_walls.gd` + `wall_fight.gd` yeni. Hepsi depo dışında scratch kopyalarında; depo dosyaları değişmedi (`git status` bkz. §6).

---------------------------------------------------------------------

## (1) İstatistik: kararsız testler gerçek bir gerileme mi?

### Tablo (her satır ayrı `AUTOTEST` satırı; hepsi `kosular.txt`'te)

| Senaryo | Düzen | Koşu | PASS | FAIL | ARMAUDIT/diğer denetim satırı |
|---|---|---|---|---|---|
| 37o lose | ÖNCE | 40 | 37 | 3 | ARMAUDIT×2 |
| 37o lose | SONRA | 40 | 39 | 1 | ARMAUDIT×1 |
| 26o lose | ÖNCE | 40 | 37 | 3 | ARMAUDIT×2 |
| 26o lose | SONRA | 40 | 40 | 0 | ARMAUDIT×1 |
| 37o (varsayılan) | ÖNCE | 5 | 5 | 0 | - |
| 37o (varsayılan) | SONRA | 5 | 5 | 0 | - |
| 37o trespass | ÖNCE | 5 | 5 | 0 | - |
| 37o trespass | SONRA | 5 | 5 | 0 | - |
| 26o (varsayılan) | ÖNCE | 5 | 5 | 0 | - |
| 26o (varsayılan) | SONRA | 5 | 5 | 0 | - |
| 26o nophoto | ÖNCE | 5 | 5 | 0 | - |
| 26o nophoto | SONRA | 5 | 5 | 0 | - |
| 26o turgut | ÖNCE | 5 | 5 | 0 | - |
| 26o turgut | SONRA | 5 | 5 | 0 | - |
| 26o turgut_bad | ÖNCE | 5 | 5 | 0 | - |
| 26o turgut_bad | SONRA | 5 | 5 | 0 | - |
| 37o lose üçüncü düzen A (37o+land_walls yeni, wall_fight eski) | A | 10 | 9 | 1 | - |
| 37o lose üçüncü düzen B (land_walls+wall_fight yeni, 37o eski) | B | 10 | 10 | 0 | - |


İlk 20'şer koşu (görevin istediği) ve ek 20'şer koşu ayrı dosyalarda; tabloda ikisi toplanmış:

| Senaryo | Düzen | ilk 20 | ek 20 |
|---|---|---|---|
| 37o lose | ÖNCE | 19/20 PASS | 18/20 PASS |
| 37o lose | SONRA | 20/20 PASS | 19/20 PASS |
| 26o lose | ÖNCE | 19/20 PASS | 18/20 PASS (3 FAIL toplam, bkz. aşağı) |
| 26o lose | SONRA | 20/20 PASS | 20/20 PASS |

### FAIL satırları (aynen)

ÖNCE 37o lose (3):
```
AUTOTEST FAIL chapter=37o variant=lose outcome=37O.2 beats=5/16 arrows=0 falls=1 barrels=1/5 cuts=39 stones=0 slips=0 burns=0 duel=true caught=0
AUTOTEST FAIL chapter=37o variant=lose outcome=37O.2 ... barrels=0/5 cuts=35 ... duel=true
AUTOTEST FAIL chapter=37o variant=lose outcome=37O.2 ... barrels=1/5 cuts=34 ... duel=true
```
SONRA 37o lose (1):
```
AUTOTEST FAIL chapter=37o variant=lose outcome=37O.2 beats=4/16 arrows=0 falls=1 barrels=1/5 cuts=36 stones=0 slips=0 burns=0 duel=true caught=0
```
ÖNCE 26o lose (3):
```
AUTOTEST FAIL chapter=26o variant=lose outcome=26.2 water=3 ladders=3 gun=3/4 stones=1/1 gunner=0/1 oil=1/1 turgut=no   (×3)
```
SONRA 26o lose: 0 FAIL (40 koşu). Ayrıca "SONRA kodu + `OILPROBE` yazdırmaları" olan bir sonda ağacında (oyun mantığı aynı, yalnız `print` eklendi; **saf SONRA değil**) 100 koşuda 6 FAIL, hepsi aynı `oil=1/1` imzası.

Geliştiricinin yazdığı imzalar (37o `barrels=1/5 … duel=true`, 26o nopass `oil=1/1`) **ÖNCE'de de aynen çıkıyor**.

### Fisher kesin testi (FAIL oranı ÖNCE vs SONRA)
37o lose 3/40 vs 1/40 → p = 0,62; 26o lose 3/40 vs 0/40 → p = 0,24; ikisi birlikte 6/80 vs 1/80 → p = 0,12. Fark yok (gerileme yönünde de değil: ÖNCE daha çok düşüyor).

### Hüküm: gerileme YOK (kararsızlık ÖNCE'de de var; P6 dışı, ikisi de test/oynanış yarışı)

**37o `lose` — kök neden (kanıtlı, P6 dışı).** `chapter37o.gd:604`: `if GameState.autotest and lose and randf() < 0.5: good = false` — bot lose varyantında her vuruşu %50 bozuyor; `_heave` (`:849`) kötü vuruşta lose'da *her zaman* ipi kesiyor (`cuts += 1; _clear_hook()`) ve `_pull` her kancada sıfırlanıyor (`_throw_hook`): bir fıçı için art arda **3 iyi vuruş** gerekiyor. Ölçülen kanca başına başarı q = 0,133 (79+76 başarı / 1166 kanca). `STOCKADE_TIME := 180` sn (`:25`) içinde ~36–40 deneme sığıyor; P(<2 fıçı) = 2,4–3,8 %. Gözlenen 4/80 = %5. `_sally` tetiği `barrels_down >= 2` olduğundan <2 fıçıda `_duel_won` ilk değerinde (`true`) kalır ve rapor `duel=true` ile FAIL olur. FAIL satırlarının hepsinde `cuts = 34–39` (süre dolana dek hep denenmiş), geçenlerde ~10–12. Tohum: oyunda yalnız `chapter34o.gd:94` `seed()` çağırıyor, yani P6'nın eklediği `randf*` çağrıları "tohumlu dizi kaydırmaz" (zaten her koşu rastgele); bu iddia değerlendirildi ve geçersiz.
Üçüncü düzen (10'ar koşu; SONRA'da FAIL çıktığı için istendi): A 9/10, B 10/10 — FAIL ÖNCE'de de olduğundan bir "dosyayı getiren" yok. (A'da tek FAIL aynı imza: barrels=1/5 cuts=36.) Not: "yalnız `chapter37o.gd` yeni" düzeni kurulamaz: `chapter37o.gd` `LandWalls.hemp_material()` çağırıyor (`land_walls.gd:861`, yeni işlev); bunu derleme denemesiyle değil kod okumasıyla söylüyorum.

*Önerilen düzeltme (UYGULANMADI), `chapter37o.gd:604`:*
```gdscript
# rastgele yerine deterministik: her 4. vuruş bozuk, 3 art arda iyi vuruş hep mümkün
_lose_strokes += 1
if GameState.autotest and lose and _lose_strokes % 4 == 0:
    good = false
```
(`var _lose_strokes := 0` ekle.) Ya da `STOCKADE_TIME` testte uzat.

**26o `lose` — kök neden (kanıtlı, P6 dışı).** Test `oil.hits == 1` (`chapter26o.gd:896-897`) bekliyor; başarısız koşuda `OilHazard._live == false` (sonda satırı: `OILPROBE dodged live=false poured=true on_ladder=true side=0.00`). `oil_hazard.gd:86`: `_live = fight.pour(cauldron, foot, 1) > 0.0`; `WallFight.pour` (`wall_fight.gd:73-74`) kazan ~2,95 sn dökülürken (`d["t"] >= 0`) `0.0` döndürüyor. Aynı kazanı (`cauldrons[2]`) **ikinci bir çağıran** da döküyor: `chapter26.gd:297-310` `_pour_loop` (dalga boyunca kazanları sırayla, 3,5–5,5 sn arayla döker). bot merdivene çıkış zamanı neredeyse deterministik olduğundan ambient dökümün `cauldrons[2]` sırası ile OilHazard'ın dökümü aynı ±3 sn penceresine düşebiliyor (sonda ağacında 60 koşunun 34'ünde `wall_fight.pour` bir kazanı "meşgul" `t=0.0` buldu: iki çağrı ±2,95 sn içinde çakıştı). Ambient önce gelirse OilHazard'ınki reddediliyor → `_live=false` → yanmıyor → `dodged` → test FAIL (60 koşunun 5'inde; her FAIL'de `live=false`). Sıra, ambient döngünün rastgele 3,5–5,5 sn aralığına bağlı.
*Önerilen düzeltme (UYGULANMADI), `oil_hazard.gd:86`:*
```gdscript
_live = fight.pour(cauldron, foot, 1) > 0.0 or float(cauldron["t"]) >= 0.0   # kazan başkası tarafından dökülüyorsa da yağ şeridi canlı
```
ya da `chapter26.gd:_pour_loop`'ta, `oil.active` iken `cauldrons[2]`yi atla.

Her iki kararsızlığın "P6 dosyalarından gelmediğine" dair en sert kanıt: aynı imza, ÖNCE düzeninde (yedi P6 dosyası e551de84'ten) aynen çıktı.

### Diğer varyantlar (beşer koşu, ÖNCE ve SONRA)
37o varsayılan, 37o trespass, 26o varsayılan/nophoto/turgut/turgut_bad: **hepsi 5/5 PASS, her iki düzende, hiç denetim satırı yok**.

### Denetim satırı: ARMAUDIT
37o ve 26o `lose`'da `ARMAUDIT unarmed …` (görevin "OLMAMALI" listesinde): ÖNCE 4 koşuda, SONRA 2 koşuda çıkıyor (koşu sonu PASS olsa da satır var). Yani P6'dan gelmiyor, yine de açık hata (bkz. §3 P6 DIŞI).

---------------------------------------------------------------------

## (2) Görsel maddeler (ÖNCE|SONRA, ayrıca "sonda_" ek kareleri)

Kare adlarım: `kare/S_<bölüm>/tNNNN.jpg` = SONRA, `O_…` = ÖNCE (PACE=1, `--shotevery=1 --snapevery=0.5`; ilgili paftada anı yazıyor). Replik anahtarıyla adlanan kareler aynı replik anı; `tNNNN` kareleri yaklaşık (zamanla alınır, replikle hizalı değil). Karelerin kendisi bu klasöre konmadı (yalnız paftalar, 12 sınırı); `kare/…` adları yalnız denetçi koşularının geçici dizinindedir.

| # | Madde | Hüküm | Kanıt |
|---|---|---|---|
| 2.1a | 37o üç ayrı ip çeken azap | DOĞRULANDI | `p01` (SONRA t0957, t1149, t1173; sonda `p04` yan/arka görünüş: üç ayrı azap, farklı adım, farklı yükseklikte basamak) |
| 2.1b | kameranın yüzünde değiller | **KISMEN** | `p01` alt-sağ (t1173): kırmızı (`k=0`, `#b3262d`) azap kameraya ~1,3 m, kadrajın ~%40'ını kaplıyor; öbür ikisi orta uzaklıkta. Sürekli değil, 2. çekişte (oyuncu sağa kayınca) belirgin |
| 2.1c | kılıçsız | DOĞRULANDI | tüm karelerde (`p01`, `p04`) elleri boş, kınları görünmüyor; kod `chapter37o.gd:748-757` `Soldier.new(..., "stand", ...)` kılıç vermiyor |
| 2.1d | tutuş sabit, ip ellerinden geçiyor | DOĞRULANDI (sonda) / oynanış karesinde KISMEN | `p04` yan: ip beyaz-kenevir ince çizgi, iki azabın yumruğunun içinden fıçıya gidiyor. Ancak arkadaki azabın bir kolu "kütük gibi" gövdeye yapışık, el görünmüyor; oynanış karelerinde (640 px) ayrıntı okunmuyor |
| 2.1e | ayaklar yerde (havada/gömülü değil) | **KISMEN** | `p04` yan (sonda): ortadaki ve öndeki azabın ayakları basamakta; **arkadaki azabın bir ayağı basamak kenarından taşıp boşlukta asılı** (dil basamağı ~50 cm; `_haul_spots` x kayması 0,6 m, `_floor_y` yalnız merkezden ışın atıyor, `chapter37o.gd:721-728`). `VISAUDIT`/`_ground_audit` hiçbir koşuda ateşlenmedi (≥150 başsız koşu) |
| 2.1f | ikinci ve sonraki çekişlerde aynı | DOĞRULANDI | `p01` 2. satır, `p03`: yeniden yerleşme (`_haul_place`) sonrası aynı poz; ÖNCE'de ikinci çekişte kılıç elde kalıp ipsiz çekiyor |
| 2.1g | geliştiricinin notu: öndeki azabın kolları yana açık | **KISMEN (doğrulandı, ama anlık)** | t0957/t0963/t0975 (SONRA): kırmızı azabın sağ kolu kadrajın soluna doğru yana uzanıyor, ipin ucuna değil bileğe doğru; `heave` kare aralığında kol ipe dönüyor (t1149). Kalıcı değil, "yana açık" bir kare var |
| 2.1h | oyuncu >3 m yana kayınca azaplar ipi bırakıyor, ip havada mı kalıyor | DOĞRULANDI (ip havada kalmıyor) | sonda (oyuncuyu 4 m kaydırdım): `p04` kayma-yan/üst: azaplar `stand` pozunda basamakta kalıyor, ip yalnız fıçıdan oyuncunun eline gergin; havada sarkan serbest uç yok (kod: `_haul_tick` `off` ⇒ `s.rope = []`, `chapter37o.gd:830-838`) |
| 2.2a | kalkan ipi: iki el ipte, eller kapalı | DOĞRULANDI | `p02` (SONRA t1270/t1340/t1395): iki yumruk kapalı, ip iki yumruktan geçiyor; ÖNCE'de el açık, ip hiç görünmüyor |
| 2.2b | ipin kalkan ucu nereye bağlı | **KANITSIZ** | kızak oyuncunun arkasında (`_sled` 2,4 m geride), kamera arkaya bakmıyor; yakın parça yumruktan aşağı-geri çıkıp kadrajdan düşüyor. Kodda `Bogaz.rope(_rope, a, join, …)` ucu kızağın `a` noktasına bağlıyor (`chapter37o.gd:1086`); karede görünmüyor. Yakın ip ~30 cm düz ve sert (sarkma yok): "çubuk gibi" |
| 2.3 | kazanılan çıkıştan sonra müttefikler kameranın önünden kılıçla geçiyor mu | **DOĞRULANDI (düzelmiş)** | `p03`: ÖNCE'de karartmadan sonra kılıçlı müttefik kameranın dibinde; SONRA'da karartma sırasında `restore_now` + yeniden yerleşme, temiz. Işınlanma karartma altında, görünmüyor |
| 2.4 | ip çeken azaplar gölgesiz: süzülüyor gibi mi | **KISMEN** | kodda gölge kapalı (`:757`); gece/ay ışığında oynanış karelerinde belirgin süzülme izlenimi yok (`p01`), ama sondada (`p04` yan) yere gölge düşmüyor, arka azabın asılı ayağı bunu güçlendiriyor |
| 2.5a | `_wear_props` sedye/kova/kırık merdiven | **KANITSIZ (oynanış karelerinde seçilmiyor)** | 20, 22o, 26o, 36b karelerinin hiçbirinde ayırt edilemedi (`p08`, `p09`); sedye/kova/merdiven 640 px karede ≤4 piksellik lekeler. Kodda var (`land_walls.gd:751-857`, sabit konum listesi `:777`). Sabit konumlar oyuncunun peribolos yolunda x=-5…14, z=9…13: yürüme çizgisinin yanında ama kamera 2 m yükseklikte öne bakıyor |
| 2.5b | peribolos ve hendek zemini | **KISMEN** | `p08`, `p06`: peribolosta taş, ok sapı, kütük, çamur lekesi, uzakta cesetler görünüyor (ÖNCE'de dümdüz mavimsi zemin) → DOĞRULANDI; ancak büyük alanlar hâlâ düz (özellikle gece, `p08` sağ), ve **hendek zemini** hiçbir oynanış karesinde yok → BAKILMADI. Yürüme yolu: `no_walk` meta, çarpışma yok, `WALKTHRU`/`ARMAUDIT` yok → kapatmıyor |
| 2.6a | 22o makara halatı, eller | DOĞRULANDI | `p05`: ÖNCE kalın gri direk + elde koli bandı; SONRA ince kenevir ip, iki yumruk kapalı. İp düz, sarkmıyor (görsel "çubuk" izlenimi) |
| 2.6b | 22o marangoz baltaları | DOĞRULANDI (küçük) | `p06`/`z22`: SONRA'da ustaların elinde mavi küçük balta başı; ÖNCE'de el boş. Yalnız arkadan, ~10 piksel |
| 2.6c | 36b kazıcı aletleri | **KANITSIZ** | kazıcılar oyuncudan ≥25 m, `p07`: alet seçilemiyor (SONRA'da figürler daha belirgin ama alet okunmuyor). Kodda `give_tool("pickaxe"/"shovel")` var (`chapter36b.gd:134`) |
| 2.6d | 37o ıskalanan kanca | **KISMEN** | sonda `p11`: kanca yerde (kırmızı top), havada asılı değil; ip yerden ele sarkıyor mu oynanış karesinde okunmuyor. Bot hiçbir koşuda ıskalamıyor, oynanış karesi YOK |
| 2.7 | 26o açılışta elde eşya | **DURUYOR** (düzeltme geri alınmış, ÖNCE ile aynı) | `p09`: "Elde: Leblebi" ve avuç içi açık, kollu; giriş alayında (`p10`) elde görünür Leblebi kutusu. `chapter26o.gd` `hands_free` hiç atamıyor (20, 22o, 36b, 37o'da var). |
| 2.8 | 26o giriş alayı | DOĞRULANDI | `p10`: ÖNCE'de bütün yeniçeriler aynı pozda, aynı yönde donmuş; SONRA'da birkaçı dönüyor, mızrak/duruş değişiyor (`_entry_stage/_entry_vary`). Alay hâlâ yürümüyor, sıra hâlinde dikiliyor |
| 2.9 | Altı bölümü baştan sona gez | KISMEN | 22o, 36b, 37o (SONRA) baştan sona ekranlı koşu (rc=0; ÖNCE 37o 2400 sn sınırında son replikte kesildi, kareler tam); 20 ve 26o PACE koşuları 1100–1300 sn'de kesildi, 26o PACE'siz tam koşuyla giriş alayına kadar (`p10`; ÖNCE kolu alayın başında zaman aşımına uğradı); **22 (kule önü Bölüm 22) ekranlı hiç gezilmedi** (BAKILMADI) |

---------------------------------------------------------------------

## (3) Yeni kusurlar

**P6 kaynaklı:**
1. 37o ip çeken azaplar: kırmızı azap kameraya ~1,3 m, kadrajın %40'ını kaplıyor (2.1b); arka azabın bir ayağı basamak kenarından taşıyor (2.1e); gölgesiz (2.4).
2. 37o RINFO: ön çekiş evresinde (D37O_T_03, 4 örnek) çizim **+%1,6…+%9 (medyan +%5,9)**, üçgen **+%5,1…+%9,9 (medyan +%7,3)**; bütün evre medyanı üçgen +%7,8 (sınırın hemen altı). Çizim "artmamalı" kuralı ön çekişte ihlal, üçgen sınırda. Bkz. §5.
3. 26o açılış elde eşya (2.7) — "geri alındı" olarak raporlanmış, açık hata.
4. `_wear_props` sabit sedye/kova/kırık merdiven oynanışta görünmüyor (2.5a); görünmeyen detay "kural 2" (ya seçilir kıl ya kaldır) ihlali.

**P6 DIŞI (ÖNCE'de de var, P6 dosyalarından gelmiyor):**
1. `ARMAUDIT unarmed` — 37o ve 26o `lose`'da (ÖNCE 4, SONRA 2 koşu). Oyuncu kılıçsız, rakip <12 m; PASS olsa bile satır var.
2. `VISAUDIT overlap … a=CityLife b=CityLife` — 20 `niko_idle`'da, ÖNCE 1/17, SONRA 1/18 (rastgele iki şehirli üst üste; `Chapter20>LandWalls>SiegeField>CityLife`: şehir kalabalığı kodu, P6 dosyası değil).
3. 37o `lose` (2,5 %) ve 26o `lose` (~%4–8) test kararsızlığı: yukarıda §1 — iki ayrı yarış, ikisi de ÖNCE'de.
4. 37o ateş çömleği birikintisi (`p02` sağ-alt, SONRA t1395): alev kümesi kameranın ~1 m önünde kadrajın üçte birini kaplıyor. ÖNCE'de aynı anda karşılaştırılamadı (çömlek zamanı rastgele), ama `_drag` çömlek kodu P6 diff'inde değişmemiş (`git diff` bu bloğa dokunmuyor) → P6 dışı sayıldı.

---------------------------------------------------------------------

## (4) Kurallara uygunluk (`git diff e551de84 -- <yedi dosya>`)

| Kural | Sonuç |
|---|---|
| Replik anahtarı/sırası | Değişmemiş: hiçbir `hud.say/bark` anahtarı eklenip silinmemiş (diff'te yeni `D…` anahtarı yok) |
| Süreler, sayaçlar | Değişmemiş: `STOCKADE_TIME`, `WARN`, sayaçlar aynı. 37o: yeni zamanlayıcılar var (`_heave` 3 tane `create_timer(0.0–0.28)` `:859`, `_topple` 0,8 sn `:887-890`) yalnız görsel; yeni `await` yok (yalnız `_sally`'de eski `fade_to`'lar) |
| Sonuç koşulları | Değişmemiş; `_autotest_report` aynı (`:1316-1335`) |
| Test botu yolu | Değişmemiş (`_stockade` bot bölümü, `:566-632`); yalnız `_throw_hook` ıska dalı (`:663-667`): kanca artık yere iniyor |
| Kalabalık sayısı | 37o: +3 `Soldier` (haulers, `:746-758`); `Melee.rally` `_eligible` (`melee.gd:441-446`) `no_rally` ile onları dışlıyor ✓; `soldiers` grubuna girdikleri için `hud._crowd_audit`/`still_audit` sayıyor ama oynanış hedef seçimi görmüyor |
| `no_audit`, `no_unclip`, `*_ok` susturması | Yeni yok. `no_rally`/`no_talk` yalnız yeni azaplarda (`chapter37o.gd:751-752`) ✓. `no_walk` yalnız yeni dekor ağlarında (`land_walls.gd:680`, 22o `:260`,`:358`, 37o `:791`, `:1022`) ✓ |
| Kanca/DBG/`P6JUMP`/sonda satırı | Yok (7 dosyada ve diff'in `+` satırlarında arandı). `print(` satırlarının hepsi diff öncesinden (AUTOTEST/`shot:`/`GUN`/`CLIMB`/`WALLCROWD`) |
| Rastgele sayı çağrısı | Yeni `randf*`: 37o `:859,:861` (+6/çekiş), 26o `:978-982` (`_entry_vary`, 0,8–2 sn'de bir). Tohum yok (yalnız 34o) → "dizi kayması" geçersiz; `land_walls` zemin ayrıntısı kendi `RandomNumberGenerator`'ı (tohum 6230) ✓ |
| Fizik katmanları / yeni çarpışma cismi | Yok: ağlar `no_walk`, `GeometryInstance3D` çarpışmasız; haulers `Soldier` (çarpışma var ama `no_rally`+`stage_walk` ile kontrollü) |
| Oyuncuyu iten şey | `_haul_place` yürüten azaplar moloz dilinde oyuncunun yanında (x ±0,6); itme yok, `Stage.walk_on_ground` oyuncudan kaçınmıyor, çarpışma gözlenmedi |
| `player.hands_free = true` | 20, 22o, 36b, 37o'da `_ready`'de; 26o'da YOK (2.7). Bu bir oynanış değişikliği (açılış elinde eşya yok) ama istenmiş |

---------------------------------------------------------------------

## (5) Testler ve RINFO

### Testlerin tamamı birer kez (SONRA, başsız `--max-fps 20`)

20 (9 varyant: "", tape, late, hit, lose, niko_idle, idle, `--difficulty=0`, `--difficulty=2`) 9/9 PASS (niko_idle'da bir `VISAUDIT overlap CityLife`, P6 dışı, bkz. §3); 22 (7/7 PASS); 22o (6/6 PASS); 36b (2/2 PASS); 0 (PASS); 28o (4/4 PASS); 41o (2/2 PASS); 42b (2/2 PASS); 32o (7/7 PASS); 21 (6/6 PASS); 26o (5 varyant ×5 = hepsi PASS + lose §1); 37o (3 varyant, §1). Toplam ham satırlar `kosular.txt`. Başka `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `WALKTHRU`, `HELDAUDIT`, `JOURNEY_*` **yok**.

Ekranlı koşu notları: ikinci/üçüncü ekranlı koşu aynı anda başlayınca bellek (16 GB, her ekranlı Godot ~2,5 GB) iki kez yetmedi: `NS_26o` ve `RO_0` çekirdek tarafından öldürüldü (rc=137) ve yeniden koşuldu; 37o RINFO için ilk deneme (`RS_37o`/`RO_37o`) 1700–2900 sn'de barikat evresine varamadan zaman aşımına uğradı, tabloya ikinci deneme (`RS2_37o`/`RO2_37o`, ikisi de rc=0, AUTOTEST PASS) alındı. Sonda kodu yalnız depo dışı bir scratch kopyada (`probe`) çalıştı; `tests/_tmp` ve depo dosyalarında sonda yok.

### RINFO (PACE=1 ekranlı koşu, replik anahtarına göre medyan; ÖNCE→SONRA)

| Bölüm | Replik anı (örnek sayısı) | çizim | üçgen (toplam) |
|---|---|---|---|
| 20 | D20_G_GUN (6) | −2,0 % | +0,8 % |
| 20 | D20_G_ASSAULT (1), G_03 (1), G_01 (1) | −1,6 / −1,6 / +2,1 % | −0,6 / +1,3 / +0,8 % |
| 22o | D22O_H_02 (9) | −0,9 % | +2,0 % |
| 22o | D22O_H_GUN (8) | −4,3 % | −2,9 % |
| 22o | D22O_H_DUEL (13/16) | +2,5 % | **+9,0 %** (kılıç dövüşü; konumlar farklı: dövüşçü sayısı/kamera aynı değil, BELİRSİZ) |
| 36b | D36_L_HELP (6) | +1,3 % | +2,2 % |
| 36b | D36_G_GO (12/10) | −10,5 % | −10,1 % (dövüş evresi, konumlar farklı) |
| 36b | D36_N_END (3) | −0,3 % | +2,5 % |
| 37o | D37O_AB_02 (13) | −3,2 % | +2,7 % |
| 37o | **D37O_T_03 bütün evre (18/17 örnek)** | +0,2 % | **+7,8 %** (sınırın hemen altı) |
| 37o | **D37O_T_03 ön çekiş (4 örnek)** | **+1,6…+9,0 % (medyan +5,9 %)** | **+5,1…+9,9 % (medyan +7,3 %)** |
| 37o | D37O_T_03 duello sonrası çekiş (7 örnek) | +2,5 % | +6,8 % (aralık −2,3…+9,9) |
| 0 | START (3) | +0,8 % | +1,9 % |
| 0 | D0_N_FREEZE (1) | **+10,3 %** | +1,4 % |

Yorum: 20, 22o (dövüş dışı), 36b, 0 (üçgen): ≤ +%8, çizim artmıyor. **37o çekiş evresinde bütün evre medyanı çizim +%0,2 / üçgen +%7,8 (sınırın hemen altı); ön çekişte çizim +%2…+%9 (medyan +%5,9) ve tek örneklerde üçgen +%10 (sınırı aşıyor).** Geliştiricinin "37o üçgen +%5-6" ölçümü benimkiyle uyumlu (alt sınır), ama çizim "artmamalı" kuralını ihlal ediyor (üç yeni `Soldier` + iki yakın ip + uzak ip ağı); sahne zamanı kaymaları yüzünden örnek başına gürültü ±%5 civarı, bu yüzden "RET gerekçesi" değil "ZORUNLU düzeltme". 0'daki +%10,3 tek örnek (D0_N_FREEZE), `t`-hizalı iki örnekte +0,3/+0,8 %: BELİRSİZ.

---------------------------------------------------------------------

## (6) GENEL HÜKÜM: **KÜÇÜK DÜZELTMELERLE KABUL**

Gerekçe: kararsız iki test gerçek gerileme değil (hükmü yukarıda); görsel işlerin çoğu DOĞRULANDI (halat/eller 22o, kalkan ipi eller 37o, çıkış sonrası müttefik, ip çeken azaplar var ve ipten tutuyor, 26o alay, zemin ayrıntısı). Ama açık kalanlar var:

### ZORUNLU düzeltmeler
1. **37o RINFO**: bütün evre medyanı üçgen +%7,8 (sınırın 0,2 puan altı), ön çekişte çizim +%2…+%9 ve üçgen tek örneklerde +%10. Üç yeni azabın ağlarını/çizimini azalt (ör. çekerken uzak azabı sadeleştir, `Crowd` LOD veya hauler'ları 2'ye indir); düzeltmeden sonra `D37O_T_03` anında yeniden ölç.
2. **37o ip çeken azap yerleşimi**: kırmızı azap kameraya ~1,3 m ve kadrajın ~%40'ını kaplıyor; `_haul_spots` ofsetini (`[0.62, -0.6, 0.5]`) oyuncudan ≥2,2 m yapacak şekilde büyüt; `_floor_y` yalnız merkezden değil ayak izinden (±0,2 m) örnekle, arkadaki azabın taşan ayağını (basamak kenarı) düzelt.
3. **26o açılışta elde eşya** (`Elde: Leblebi`, açık el): `chapter26o.gd _ready`'ye `player.hands_free = true` (20/22o/36b/37o'daki gibi) ya da "DURUYOR" diye raporda kalsın; şu hâliyle düzeltme "geri alındı" diye gizlenmiş.
4. **Görünmeyen detay**: `land_walls.gd:777` sabit sedye/kova/kırık merdiven oynanış karelerinde seçilemiyor. Ya yürüme çizgisinin 2–3 m yanına çek ve boyutlarını büyüt ya da kaldır; "kural 2".
5. **36b kazıcı aleti** ve **37o ıska kancası**: oynanış karesinde kanıt yok. Kazıcıları oyuncunun yolundan görünür bir yere ya da `kare` ile kanıtlanabilir yakına al; ıska için test varyantı (`miss`) ekle ki karede görülsün.

### Önerilen (P6 dışı, ama paket kabulünü etkilemez)
6. 37o `lose` botunu deterministik yap (`chapter37o.gd:604`; §1 kod parçası).
7. 26o `lose` OilHazard yarışı: `oil_hazard.gd:86` (§1 kod parçası).
8. `ARMAUDIT unarmed` (37o/26o lose) ve `VISAUDIT overlap CityLife` (20 niko_idle): ÖNCE'de de var, kendi sahiplerine.

### BAKILMADI
- Hendek zemininin oynanış karesi (2.5b).
- 22 (peribolos) ekranlı koşu; 20 ve 26o'nun ekranlı PACE koşuları 1100–1300 sn'de kesildi (26o PACE'siz tam koşuyla giriş alayına kadar görüldü).
- "Saf e551de84" düzeni (yalnız yedi P6 dosyası ÖNCE; diğer dosyalar dalın ucu). P6'yı ayırmak için bu yeterliydi, ama "başka ajanların işi" tek başına hiç ölçülmedi.
- Çekişte oyuncunun elle sağa-sola kaçışı yalnız sondayla (oynanış karesi değil).
