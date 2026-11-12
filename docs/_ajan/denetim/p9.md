# P9 (Blakhernai: Bölüm 30 ve 30o) — bağımsız denetim raporu

Denetlenen: `wip/yardimci-p9` ucu (`ecec84f2`) ile başlangıç `a5e8111d`. Değişen üç dosya: `scripts/chapter30.gd`,
`scripts/chapter30o.gd`, `scripts/level/blachernae.gd`. Godot 4.4.1, xvfb, 1280×720, yazılım çizimi.

**Yöntem notu.** ÖNCE için üç dosyayı `git show a5e8111d:<dosya>` ile *ayrı bir kopya proje dizininde*
(`/tmp/aud/once_proj`, depodan `cp -a`) eski hâline getirdim; depodaki dosyalara dokunmadım (`git status`: oyun
kodunda değişiklik yok). Kare kaynakları: (a) ekranlı tam koşular (`PACE=1 … --dialogshots --shotevery=1
--snapevery=0.5`, ÖNCE ve SONRA birer kez; 30 ve 30o), (b) geçici sonda betikleri (`tests/_tmp/p9_probe*.gd`,
iş bitince silindi, `.gitignore`'da): dört merdivenin her birinde aynı oyuncu konumu/bakışı ve aynı tutma
ilerlemesiyle ÖNCE|SONRA; 30o kaldırma anında aynı sayaç. Kare adlarındaki `tNNNN` ekranlı koşunun kare sırasıdır.
Paftalarda sol ÖNCE, sağ SONRA.

## 1. Madde madde hüküm

| Madde | Hüküm | Kanıt ve gerekçe |
|---|---|---|
| **A** 30 merdiven itme: eller dikmelerde, merdiven başı kadrajda | **YANLIŞ** | `pafta_A1`, `pafta_A2` (dört merdiven), `pafta_A3` (oyun koşusu `once30/t0236` | `sonra30/t0242`). **Eller dikmede değil:** `Player._hold_both_points` elleri kameranın önünde, ekranın alt kutusuna sıkıştırıyor (y ∈ [−0,42; 0,05], z ≥ −0,75). 16 sondada eller her seferinde ekranda (548, 637) ve (732, 637) px'te, dikme noktaları ise y = 526–614 px: 25–110 px aşağıda, parapet taşının üstünde. Eller çaprazlanmıyor (sol x 548 < sağ x 732, 16/16). **Oyuncu neyi ittiğini anlamıyor:** bakış ≈ −36° aşağı; merdiven başı x = −4 ve x = 6'da mazgal taşının arkasında tamamen görünmüyor (A1 alt, A2 üst), x = −12 ve x = 14'te kenarda birkaç piksellik kahverengi çıkıntı. Geliştirici paftasındaki durum dört konumda da aynı. **Fare:** E basılıyken bakış her karede merdivene yumuşakça çekiliyor (5/sn), ≈0,8 sn sürüyor; bırakınca denetim hemen geri geliyor, AMA bakış (pitch ≈ −36°, yaw merdivene dönük) geri alınmıyor: itişten sonraki replikte (`D30_D_DUEL_STAY`) oyuncu hâlâ parapete bakıyor (A3 alt satır; ÖNCE'de bakış ufukta). Ani sıçrama yok; son 0,3 sn'de pitch ±1,5° sarsılıyor (madde C'nin yan etkisi). |
| **B** itmede elde eşya cebe, bitince geri | **DOĞRULANDI** | `pafta_B` (önce/sonra), `pafta_A3` üst (itiş anı): itiş sırasında elde simit/kumanda yok, iki boş el var; itiş bitince simit geri geliyor (`sonra30/t0250`). |
| **C** 30 merdiven titremesi | **DOĞRULANDI (görünüyor, fazla)** | `pafta_C`. Sonda: tutma %99'da merdiven başının ekran y'si kareden kareye 518–616 px (≈ ±50 px), `rotation.x` ±0,012 rad (≈6 Hz). Merdiven başı çoğu konumda zaten örtülü olduğundan oyuncuya görünen şey çoğunlukla sarsıntı + kamera pitch'i (±1,5°). |
| **D** 30o ova zemini | **KISMEN** | `pafta_D1`, `pafta_D2`. *Z-çakışması / havada / gömülü:* yedi sabit poz × iki kamera kayması (kuşbakışı, göz hizası, sıyırma, yakın plan, sur üstü): titreşim ya da havada/gömülü parça gözlenmedi; ayak izi/çamur +2,5 cm yassı, ok/taş gömülü-saplı görünüyor. *Levha:* tek levha `Props.solid(140×0,4×60,4)` @ y −0,2, z 4,4–64,8; ÖNCE altı levha z 4,5–64,8, `slope_y` ≡ 0 olduğundan yükseklik, çarpışma ve sınırlar eşdeğer; başsız 8/8 PASS, `WARN_VOID_TELEPORT` yok (oyuncu/asker düşme ya da takılma yok). *Görünürlük:* **kabul karesi D30O_N_01'de ova zemini çizilmiyor** (oyuncu alanın dışında ve ona sırtı dönük; RINFO üçgen −%0,3; ÖNCE|SONRA farkı yalnız kalabalık, `pafta_D2` üst). Yakın planda/kuşbakışında seyrek koyu çamur lekeleri, birkaç çakıl ve ok görünüyor (D1); surdan bakışta (30) ÖNCE'den ayırt edilemiyor (D2 alt). Geliştiricinin "iz ve çakıl seçiliyor" beyanı kabul karesi için doğru değil. |
| **E** 30o merdiveni kaldıran askerler | **KISMEN** | `pafta_E1`, `pafta_E2`. *Ayaklar:* en alçak taban–zemin aralığı SONRA −0,07 … +0,08 m (24 okuma; hedef ≤ 0,05), 6/24 okuma 0,06–0,08; ÖNCE −0,06 … −0,01 m (ÖNCE'de askerler yürür gibi eğik duruyordu, `pafta_E1` alt sol). *Eller:* kendi `Stage.grip` hata ölçümüm: 1. ve 2. asker (dikmeyi tutanlar) 0,15–0,27 m, 3. asker 0,00–0,09 m; geliştirici 0,0–0,17 demişti. Yandan iki kamerada kollar gövdeye gömük kütük gibi, avuçlar görünmüyor (E2 alt); üç asker omuz omuza yığılmış. *Oyuncunun geri çekilmesi:* hedef `ladder.z + 3,6`, gerçek yol 1,9 m (bot, 9,9 → 11,8) – 3,2 m (ÖNCE'deki duruş 8,64 → 11,79); tepe hız 4,2–5,5 m/s, 0,9 sn, yumuşak (sine). 24 örnekte oyuncu kapsülü hiçbir çarpışma nesnesiyle kesişmedi; ışınlanma yok. **Oynanış değişikliği: evet** — ÖNCE oyuncu kaldırma boyunca yerinde duruyordu (merdiven ayağına 0,45 m, sırtı dönük, `pafta_E1` sol); şimdi sürükleniyor ve merdivene bakıyor. Süreler (`RAISE`, 1,2 sn bekleme) ve tırmanış başlangıcı (`_climb`, `chapter30o.gd:370`) değişmedi. *Risk (KANITSIZ, yalnız hesap/sınırlı sonda):* sur tarafından (z < 8) yaklaşan oyuncuyu doğrusal tween askerlerin ve merdiven ayağının içinden geçirir; zorlanmış başlangıçta (9,4; 6,4) hedef doğrusu kırmızı askerin merkezine 0,31 m yaklaşıyor. Bot hep +z'den geldiği için testler görmez. |
| **F** 30o tırmanış: el boş, tek el | **DOĞRULANDI** (P9'dan bağımsız, ÖNCE'de de aynı) | `pafta_F`: tırmanırken elde eşya yok (Leblebi yalnızca tırmanış öncesi replikte elde, ÖNCE'de de). Ekranda tek (sağ) el, avuç açık, basamağa/dikmeye değmiyor. P9 bunu değiştirmedi. |
| **G** BAKILMADI denenenler | **Gezildi (sınırlı)** | 30 dövüş/imparator ve 30o taşıma, kule, geri çekilme, kovalama: her 10. kare + replik anları, ÖNCE|SONRA (`pafta_G1`). Kare kare değil. Bulgular §2. |
| 30 ve 30o geliştirici beyanları | — | Aşağıda §4 ("FAIL" beyanı, 3,6 m beyanı) |

## 2. Yeni kusurlar

| # | Bölüm, an, kare | Kusur | P9 kaynaklı mı |
|---|---|---|---|
| H | 30, merdiven daha taşınırken (carry/raise) oyuncu sur üstünde ilgili x'te E tutarsa; `pafta_H`, sonda `probe30_carry` | Yatay taşınan merdivenin `rotation.x`'i 1,850 → ≈0: merdiven dikilip taşıyanlardan kopuk, havada (y = 1,35) duruyor. ÖNCE'de aynı koşulda 1,850 kalıyor (sırık görseldi). Koşul normal oyunda erişilebilir: `near` (`chapter30.gd:202`) merdivenin gerçek yerine değil `(x, WALL_Z1−1)` noktasına bakıyor, `t ≥ 0` taşıma evresinde de sağlanıyor ve "Merdiveni it" istemi çıkıyor; bot (`t ≥ 1`) bu duruma girmediği için testler görmez. | **EVET** (`chapter30.gd:273`) |
| I | 30, itişten sonra, `D30_D_DUEL_STAY` (`pafta_A3` alt) | Bakış (pitch ≈ −36°) geri alınmadan bırakılıyor; sonraki replik parapete bakarak başlıyor. | **EVET** (`chapter30.gd:270-271`) |
| J | 30 sonu (`D30_T_EMPEROR`, `D30_N_END`), 30o `D30O_T_TOWER_WON`, `D30O_Z_URBAN` | Üçgen bütçesi aşımı, bkz. §5. İki ağ toplam **145.774 üçgen** (77.182 sert + 68.592 yumuşak) ve pişirme `visibility_range_end`'i (90/200 m) ve kümeleme/frustum ayıklamayı kaybettirdi: alanın küçücük bir kısmı görüşte olsa da 146 bin üçgenin hepsi çiziliyor. | **EVET** (`blachernae.gd:76-105`) |
| K | 30o `D30O_T_TOWER_WON`, `D30O_T_PB_MISS` (`pafta_G1`) | Kule üstünde düz beyaz küp mazgallar ("küp gibi duran bina"); kadrajı ortadan kesen dev direk. | Hayır, **ÖNCE'de de var** |
| L | 30, dövüş sonrası ≈30–40 sn bekleme (`t0340–t0440`, ÖNCE'de `t0330–t0400` civarı) | Oyuncu duvara/meşaleye bakıyor; ekranda gövdeye bağlı olmayan beyaz manşetli tek kol ve yerde kırmızı disk duruyor, hareket yok. | Hayır, **ÖNCE'de de var** |
| M | 30 dövüş (`t0300–t0320`) | Göğüs göğüse dövüşte kamera duvara yapışık, rakip duvarın içine gömük görünüyor. | Hayır, **ÖNCE'de de var** |
| N | 30o `ARMAUDIT unarmed foe_dist=2.1–2.2 duel_active=false` (`=lose`) | Başsız `lose` koşularında SONRA'da 4 koşuda 2, ÖNCE'de 4 koşuda 1. Kararsız (zamanlamaya bağlı) denetim satırı. | Hayır, **ÖNCE'de de var** |

## 3. Kurallara uygunluk (`git diff a5e8111d -- <üç dosya>`)

- Replik anahtarları ve sırası: değişmemiş (diff'te `say`/`bark` satırı yok). Süreler, sayaçlar, kazanma/kaybetme,
  engel yerleşimi, kalabalık sayısı: değişmemiş. Test botunun yolu: `chapter30.gd:190-196` ve
  `chapter30o.gd:205-217` aynı (yalnız `_pole_show(p, l)` bağımsız değişkeni eklendi).
- **Oynanış değişikliği (bildirilmeli, kural listesinde yok):** 30o kaldırma sırasında oyuncu konumu/bakışı betikle
  taşınıyor (`chapter30o.gd:251-258`); 30 itişte bakış denetimi kısmen alınıyor (`chapter30.gd:267-271`).
- Kare alma kancası, DBG/sonda satırı, `print`: diff'te yok. `no_audit`, `no_unclip`, `set_meta("..._ok")`: yok.
  Tek meta: `blachernae.gd:104` `mi.set_meta("no_walk", true)` (+`soft`): WorldWalk'ın zemin taramasından dışlama;
  `chapter22o.gd:260,358`, `slipway.gd:299,659` vb. ile aynı yerleşik kalıp ve görsel dekor için doğru; denetim
  susturması sayılmaz, yine de not ediyorum.
- Her karede yeniden kurulan ağ: yok. `_pole_show` her karede yalnız vektör/döndürme yazıyor (`hold_both` kolluğu
  yalnız ilk çağrıda kuruluyor); `plant_feet` yer çağrısını Callable ile alıyor (ışın yok). `_field_wear` bir kez
  kuruluyor. Sızıntı: `_plant_tw` düğümler `_carry_release` ile temizleniyor.
- `docs/_ajan/istanbul_prompt.txt`: **hiç gelmemiş.** `a5e8111d` ağacında yok; tüm yerel geçmişte (`git log --all --
  docs/_ajan/istanbul_prompt.txt`, `--diff-filter=D`) o yola dokunan hiçbir kayıt yok; ana dal `e551de84` ağacında da
  `docs/_ajan` klasörü yok (`docs/_ajan` `1e3a9b60`'ta eklenmiş). Silinmiş değil. (Yalnız yerelde bulunan başvurular
  denetlendi; uzaktaki henüz çekilmemiş dallar bakılmadı.)

## 4. Testler (başsız, SONRA, `--max-fps 20`) ve hata satırları

| Koşu | Sonuç satırı (aynen) |
|---|---|
| 30 `""` | `AUTOTEST PASS chapter=30 variant= outcome=30.1 gun=3/4 pushed=2 boarders=0 duel=true rifle=4` |
| 30 `lose` | `AUTOTEST PASS chapter=30 variant=lose outcome=30.2 gun=3/4 pushed=0 boarders=2 duel=false rifle=4` |
| 30 `bridge_ok` | `AUTOTEST PASS chapter=30 variant=bridge_ok outcome=30.1 gun=4/5 pushed=2 boarders=0 duel=true rifle=5` |
| 30 `bridge_bad` | `AUTOTEST PASS chapter=30 variant=bridge_bad outcome=30.1 gun=3/3 pushed=2 boarders=0 duel=true rifle=3` |
| 30o `""` | `AUTOTEST PASS chapter=30o variant= outcome=30O.1 stones=4/4 gunner=3/3 tower=true fell=false guards=10 pokes=0 flee=ride pushed=true` |
| 30o `lose` | `AUTOTEST PASS chapter=30o variant=lose outcome=30O.2 stones=4/4 gunner=0/1 tower=false fell=true guards=10 pokes=0 flee=fade pushed=false` + `ARMAUDIT unarmed scene=chapter30o.tscn foe_dist=2.2 duel_active=false` |
| 30o `sprint` | `AUTOTEST PASS chapter=30o variant=sprint outcome=30O.1 stones=4/4 gunner=3/3 tower=true fell=false guards=10 pokes=0 flee=made pushed=true` |
| 30o `stonehit` | `AUTOTEST PASS chapter=30o variant=stonehit outcome=30O.1 stones=0/4 gunner=3/3 tower=true fell=false guards=10 pokes=0 flee=ride pushed=true` |

8/8 PASS. Yasaklı satırlar: `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `VISAUDIT`, `WARN_VOID_TELEPORT`, `WALKTHRU`,
`HELDAUDIT`, `JOURNEY_MISS`, `JOURNEY_OVERLAP`: **yok**. `ARMAUDIT`: yalnız 30o `lose`'ta (4'er koşu: SONRA 2, ÖNCE 1 →
ÖNCE'de de var). `parse_check`: BAKILMADI.

**Ekranlı 30o:** geliştirici "AUTOTEST FAIL, ÖNCE de aynı" demişti. Bu makinede ekranlı (xvfb, `PACE=1`) koşular:
ÖNCE 30o iki kez `AUTOTEST PASS chapter=30o variant= outcome=30O.1 stones=4/4 gunner=4/4 tower=true fell=false guards=10 pokes=0 flee=ride pushed=true`
(biri `--dialogshots`lu, biri RINFO'lu), SONRA 30o `AUTOTEST PASS chapter=30o variant= outcome=30O.1 stones=4/4 gunner=4/4 tower=true fell=false guards=10 pokes=0 flee=ride pushed=true`.
**FAIL satırı üretilemedi**; neden karşılaştırılamıyor (geliştiricinin makinesine özgü zamanlama olabilir). Ekranlı 30 de ÖNCE/SONRA `PASS`.

## 5. RINFO (ekranlı, `RINFO=1 PACE=1 --hitchaudit`; "aynı replik anına hizalı": ilgili `PACE say key=` satırından sonraki ilk üç `RINFO`)

`prims` = toplam üçgen, `vis` = görünür geçiş. Ölçüt: çizim artmayacak, üçgen ≤ +%8. Sonda ölçümü: FieldWear = +145.774 üçgen (5 levha −60).

| Bölüm / an | Örnek | Çizim ÖNCE→SONRA | Üçgen ÖNCE→SONRA | Toplam | Görünür |
|---|---|---|---|---|---|
| 30 `D30_D_LADDERS` | 0 | 4764→4750 | 6589k→6713k | +%1,9 | +%2,1 |
| | 1 | 5025→5007 | 6680k→6853k | +%2,6 | +%2,9 |
| | 2 | 4803→4802 | 6592k→6781k | +%2,9 | +%2,9 |
| 30 `D30_T_DUEL` | 0–2 | 4875→4304 … 4781→4165 | 5962k→5444k … 5864k→5252k | −%8,7 … −%11,3 | (kalabalık/karşılaşma gürültüsü; hizalama güvenilir değil) |
| 30 `D30_T_EMPEROR` | 0 | 2069→2049 | 1313k→1444k | **+%10,0** | +%13,5 |
| 30 `D30_N_END` | 0 | 2153→2143 | 1299k→1438k | **+%10,7** | +%14,6 |
| | 1 | 1881→1870 | 1298k→1476k | **+%13,7** | +%18,3 |
| | 2 | 1886→1861 | 1312k→1430k | **+%9,0** | +%12,3 |
| 30o `D30O_N_01` | 0 | 2061→2038 | 2737k→2729k | −%0,3 | −%0,5 |
| 30o `D30O_Z_URBAN` | 0 | 1972→1967 | 2691k→2973k | **+%10,5** | +%18,6 |
| | 1 | 2241→2400 | 2981k→3386k | **+%13,6** | +%23,7 |
| | 2 | 3103→3107 | 3674k→3817k | +%3,9 | +%6,0 |
| 30o `D30O_T_TOWER_WON` | 0 | 3147→3255 | 2003k→2256k | **+%12,6** | +%15,3 |
| | 1 | 3536→3551 | 2645k→2852k | +%7,8 | +%12,8 |
| | 2 | 3540→3550 | 2655k→2855k | +%7,5 | +%11,6 |
| 30o `D30O_T_EMPEROR` | 0–2 | 3764→3688 … 4141→4032 | 2639k→2745k … 3201k→3286k | +%4,0 / +%4,4 / +%2,7 | +%8,8 / +%9,2 / +%7,4 |
| 30o `D30O_N_END` | 0–2 | 5791→5346 … 5570→5362 | 4414k→4581k … 4399k→4566k | +%3,8 / +%2,2 / +%3,8 | +%6,1 / +%3,9 / +%6,1 |

Çizim çağrısı artmıyor (eşit/az: −%0,3…−%8); iki 30o örneği hariç: `Z_URBAN` örnek 1 (+%7,1) ve `TOWER_WON` örnek 0 (+%3,4)
(kalabalık gürültüsü olabilir, FieldWear çizimi net −3 ekler). **Üçgen ise 30 sonunda (+%9…+%13,7) ve 30o'nun taban değeri düşük evrelerinde (`Z_URBAN`,
`TOWER_WON`: +%7,5…+%13,6) %8 sınırını aşıyor**; geliştiricinin "30o ilk örnek +%8" ve "+%3…+%5" ifadeleri taban değeri
yüksek evreleri yansıtıyor. Not: bu koşular eşzamanlı çalıştı (CPU paylaşımı), RINFO sayıları hızdan bağımsız ama
rastgele kalabalık/oyun durumu farkları ±%10 gürültü katıyor; sistematik fark FieldWear'ın 146k'sı.

## 6. GENEL HÜKÜM: **RET**

Gerekçe: paketin asıl iki teslimi (30'da merdiven başı kadrajda + eller dikmede; 30o ova zemininin kabul karesinde
görünmesi) karşılanmıyor; yeni bir görsel kusur (H) ve bütçe aşımı (J) getirilmiş; geliştirici raporunda doğrulanamayan
beyanlar var. Doğru tarafta: B (eşya), F (el boş), E'de oyuncunun merdivene dönük ve kadrajda olması ile askerlerin dikmeye
yaslanan pozu ÖNCE'ye göre iyi, D'de zemin çarpışması/sınırları eşdeğer, 8/8 test PASS.

### ZORUNLU düzeltmeler

1. **`chapter30.gd:_pole_show` (267-271), bakış hedefi.** Bakış −36° aşağı parapete iniyor, merdiven başı mazgal
   arkasında kalıyor (x = −4 ve 6'da tamamen görünmüyor). Bakışı merdiven başının mazgal üstünden göründüğü yere (hedef
   noktayı başın üstüne al, pitch'i sınırla) ya da oyuncuyu mazgal aralığına hizala. Görülmeli: dört konumun (x = −12, −4,
   6, 14) hepsinde itişin ortasında merdiven başı ekranın orta üçte birinde, örtülmeden.
2. **`chapter30.gd:_pole_show` (255-265) + `Player._hold_both_points` kutusu.** Eller dikme noktalarından 25–110 px aşağıda
   (kutu y ≥ −0,42). Tutma yüksekliğini (`hy`) kutuya göre seç ya da dikme noktalarını ekran izdüşümüne göre belirle;
   görülmeli: iki avuç dikmenin tam üstünde (≤ 20 px), sur taşının içinde değil, dört konumda.
3. **`chapter30.gd:_pole_show` (270-271, 231-248).** Bırakınca bakışı geri ver (başlangıç yaw/pitch'ine 0,3 sn yumuşak)
   ya da itiş boyunca bakışı hiç çevirme. Görülmeli: itişten sonra `D30_D_DUEL_STAY`'da bakış ÖNCE karesi gibi ufukta.
4. **`chapter30.gd:273`, kusur H.** `lad.rotation.x` yalnız `l["stage"] == "climb"` merdivenlerinde yazılsın/sıfırlansın
   (taşıma ve kaldırma evrelerinde `_carry_step`'in `flat`/lerp değerine dokunma); `_push_lad` bırakılırken de aynı koşul.
   Görülmeli: taşınan merdivenin yanında E basılıyken `rotation.x` 1,850 kalıyor (sonda `probe30_carry` karşılaştırması).
5. **`chapter30.gd:273`, titreme.** ±50 px'lik baş oynaması fazla; genliği (0,012 rad) ve kamera pitch ekini küçült
   (hedef: merdiven başı ekran sarsıntısı ≤ ±8 px, 6 Hz) ya da yalnız çerçeveyi titret.
6. **`blachernae.gd:_field_wear` (76-105), bütçe.** 145.774 üçgenlik iki ağ: 30 sonu ve 30o düşük tabanlı evrelerde +%9…+%13,7.
   Ağı 3-4 x-parçaya böl ve `visibility_range_end` (90 m) ver ya da ayak izi şeritlerini (68,6k üçgen) seyrelt; hedef: 30
   `D30_N_END` ve 30o `D30O_T_TOWER_WON`/`Z_URBAN` ÖNCE|SONRA üçgen ≤ +%8, çizim artmaz (aynı replik anına hizalı üç örnek).
7. **`blachernae.gd:_field_wear` + kabul karesi.** `D30O_N_01`'de ova zemini hiç çizilmiyor (alan z 6,2–52,2; oyuncu dışında,
   sırtı dönük). Ya ayrıntıyı oyuncunun çevresine/ baktığı yöne de ekle ya da kabul karesini ova zemininin göründüğü ana
   (ör. taşıma `D30O_Z_URBAN` sonrası) taşı ve orada ÖNCE|SONRA farkı seçilir olsun (yalnız kalabalık değil, iz/çakıl).
8. **`chapter30o.gd:_carry_grip` (284-297).** Dikmeyi tutan iki askerin avuç hatası 0,15–0,27 m (hedef ≤ 0,08), taban–zemin
   −0,07…+0,08 m (hedef ≤ 0,05). Askerleri dikmeye yaklaştır (x ±0,68 → ±0,5) ya da `lean`'i artır; üç asker omuz omuza
   yığılmış, aralık aç. Görülmeli: yan kamerada avuçlar dikmede, taban zeminde, gövdeler birbirine girmeden.
9. **`chapter30o.gd:_carry_ladder` (251-258).** Oyuncu çekilişi sur tarafından (z < 8) gelen oyuncuyu askerlerin/merdiven
   ayağının içinden geçiriyor (zorlanmış başlangıçta kırmızı askere 0,31 m). Yolu askerlerden en az 0,5 m uzak tut
   (önce yana/geri, sonra hedef) ya da çekilişi başlamadan oyuncuyu güvenli yarıçapın dışına ekle; testi, oyuncu
   sur tarafından yaklaşırken de ekle (bot yolu yalnız +z'den).
10. **Rapor düzeltmesi.** `docs/_kanit_p9/rapor.md`: "iz ve çakıl seçiliyor" (D30O_N_01), "palm hatası 0,0–0,17", "3,6 m geri
    çekilme" (gerçek 1,9–3,2 m) ve "titreme KANITSIZ" (ölçüldü, görünür, fazla) ifadeleri düzeltilsin; oynanış değişikliği
    (oyuncu konumu/bakışı betikle) açıkça yazılsın.

### BAKILMADI
- `parse_check`; 30o `=lose/sprint/stonehit` ekranlı koşusu; gerçek fare/oyuncu girdisiyle itiş (yalnız betikle bakış çekimi
  ölçüldü); 30'un ve 30o'nun her anı kare kare (yalnız her 10. kare + replik anları); ses; uzaktaki çekilmemiş dallarda
  `istanbul_prompt.txt`.

## Paftalar (`docs/_kanit_denetim_p9/`)
`pafta_A1` ve `A2` (30 merdiven itme, dört konum), `A3` (oyun koşusu + itiş sonrası bakış), `B` (eşya), `C` (titreme),
`D1` (ova, sabit kamera), `D2` (kabul karesi D30O_N_01 + sur üstü), `E1`, `E2` (30o kaldırma, oyuncu ve askerler), `F`
(tırmanış eli), `G1` (30o kule/geri çekilme: P9 dışı kusurlar), `H` (yeni kusur: taşınan merdiven). Toplam 12.
