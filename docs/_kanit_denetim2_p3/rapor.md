# P3 düzeltme turu — 2. tur bağımsız denetim (29, 29o, 33o, 38o)

Denetçi: kendi koşularım (Godot 4.4.1, xvfb 1280x720, `PACE=1 RINFO=1 --hitchaudit --dialogshots --shotevery=1 --snapevery=0.5`).
Dal `wip/denetim2-p3` (= `wip/duzeltme-p3` ucu `613a3019`). Oyun kodunu değiştirmedim (`git diff -- scripts` boş).

ÖNCE tanımları (iki karşılaştırma):
- **ÖNCE-ef** = `ef860ea2` (çatallanma noktası: `git merge-base HEAD origin/wip/0.99.119`), beş P3 dosyası o kayıttan.
- **ÖNCE-main** = `e551de84`, aynı beş dosya o kayıttan (geri kalan her şey dalın ucunda; önceki denetçinin yöntemi).
İkisi de depo dışı kopyada (`/root/w/onc`) koştu. SONRA = bu dalın ucu. Kare adı `tNNNN`: koşunun kare sayacı;
çiftler aynı replik anahtarından `+N` kare sonrasına hizalı (adı paftada yazılı). Ham veri: `ham_*.txt`.

## 1. Madde madde hüküm

| # | Madde | Hüküm | Kanıt (kendi karelerim) |
|---|---|---|---|
| 1a | 38o tutma kadrajı: tırmanan tayfa baştan ayağa, çatalın geldiği mazgal kadrajda, çatal görünüyor | **DOĞRULANDI** (küçük notlar) | p01 (ÖNCE-ef | SONRA, `D38O_T_02` +12/+40/+66/+100): ÖNCE'de yalnız tayfanın bacakları, tepe kadraj dışı; SONRA'da öndeki tayfa baştan ayağa (`t0238, t0266`), mazgal dizisi arkasında, çatal `t0292–t0295`'te (p03) sağ dikmenin tepesine inen ince koyu sırık olarak seçiliyor. Notlar: ikinci tayfa öndekinin arkasında hemen hiç görünmüyor; çatal ince/sönük (gece, koyu sırık); mazgal ince bir şerit. p02: `main`de tayfa daha büyük ve sur başındaki askerler de kadrajdaydı; SONRA'da bu askerler kadrajda değil (yayındakine göre kadraj dar, ama tayfa/çatal gereksinimi sağlanıyor) |
| 1b | Bakış denetimi oyuncuda (≤1 sn) | **DOĞRULANDI (kodda; farede KANITSIZ)** | `chapter38o.gd:_look_soft` 0,8 sn tween, yalnız `_brace` girişinde ve `_hooks_memory` içinde (0,6 + 0,8 sn). Eski `_brace_look` silinmiş (`grep` 0). `player.free_look = true` (`player.gd:739-742`, `_unhandled_input` donmuşken de fareyi işliyor). Bot fareyi oynatmadığından serbest bakış karede denenmedi |
| 1c | Eller bırakınca telsiz geri belirmiyor | **DOĞRULANDI** | `_ladder_grip`: tutuşta `stow_hands(true)`, çıkışta `(false)`. Çatal karesi `t0292–t0300`, çatal basılışı sonrası: sağ elde telsiz yok (p01/p03; eller dikmede ya da kadraj altında). Tutuş bitince (kum/ateş evresi, `t0414–t0420`) telsiz elde: bu beklenen |
| 2 | `world.visible = false` yok, dünya her yolda açık | **DOĞRULANDI** | `grep "visible" chapter38o.gd` içinde `world.visible` yok; `git diff e551de84 HEAD` içinde de yok. RINFO (aşağıda) `ladder` evresinde ÖNCE-main ile eşit: gizleme gerçekten yok |
| 3 | 29 kanca ipi oyuncunun durduğu yerden görünüyor | **DOĞRULANDI** (küçük) | p04 (ÖNCE-ef | SONRA) ve p06: SONRA `t0092, t0208–t0216`: kanca küpeştenin üstünde, altından kremsi ip kısa sarkıyor, "E basılı: ipi kes" etiketi bunun yanında; ÖNCE-ef karelerinde kanca hiç kadrajda değil (bot kancaya bakmıyor). **Not:** ÖNCE karesi eşit bakışta değil; sebebi SONRA'daki botun `_bot_look` ile kancaya bakması (`chapter29.gd:253-257`, test iskelesi değil ama bot davranışı: kancaya `player.face`). Kanca/ip küçük; gergin dış parça içeriden seçilmiyor, yalnız düğüm ve sarkan uç |
| 4a | 29o ip ağı her karede kurulmuyor | **KISMEN** | Koruma kodda var (`chapter29o.gd:_tube_to`, 5 mm), `_fly_hook`, `_climb/on_rope` kullanıyor, `cut_hook`→`Stage.rope_to` zaten korumalı. Ama tırmanışta oyuncu ~3 m'yi 2,2 sn'de çıkıyor (≈2 cm/kare ≫ 5 mm) ve uçan kancada ip uçları sürekli kayıyor: bu evrelerde ağ **yine her karede kuruluyor** (koruma yalnız durağan karelerde işe yarıyor: 0,5 sn bekleme ve düşüş sonrası). Maliyet küçük (8 noktalı ince boru), RINFO'da fark yok; "her karede yok" iddiası fazla geniş |
| 4b | Düşüşte yakın krem şerit yok, ip ≥25 cm önde, ince | **DOĞRULANDI** | p07 (ÖNCE-ef | SONRA `D29O_T_CLIMB` +14..+24), p08 (ÖNCE-main | SONRA): main'de kameranın önünü kesen dev krem koni/şerit (`t0169, t0171`); SONRA'da iki el ince ipte (`t0172, t0174`), düşüşte (`t0178, t0180`) yakın şerit yok. ÖNCE-ef karelerinde düşüşte de belirgin şerit çıkmadı (aynı anda ayrım zayıf): SONRA'nın iyileştirmesi özellikle `main`e göre net. `t0176`'daki saydam bulut kova suyu `Vfx.steam` (main'de de var, bu turun maddesi değil) |
| 5 | 29 seren/yelken "mızrak" | **DOĞRULANDI** (küçük) | p05 (ÖNCE-ef | SONRA `D29_C_WIND` +10/+12/+14/+16): ÖNCE'de bordadan uzanan beyaz konik mızrak (`t0495–t0501`); SONRA'da beyaz koni yok, serenin üstünde koyu kenevir demeti (`t0436, t0438`). Not: seren sırığı kendisi `+14/+16`'da çapraz uzun bir çubuk, demet üzerinde sivri bir "uç" gibi duruyor; mızrak okumasından çıktı ama serenle karışık |
| 6 | 29 halat çeken tayfa: eller halatta, sırttan görünür, ip babada bitiyor | **DOĞRULANDI** | p06 (`t0256` yakın kesit): arkadan görünen tayfa halatı yan elinde tutuyor, ip basamak dibindeki babaya sarılı, kangal yerde; ip bacağın arkasında bitmiyor. Uzak (kadrajda küçük); ÖNCE-ef karşılaştırması bakışa göre hizalanamadı (aynı an aynı bakış yok) |
| 7 | `hooks_bad` `VISAUDIT personhidden D38O_S_03` ×10 | **DOĞRULANDI** (örnek küçük) | ÖNCE-main **0/10**, ÖNCE-ef **1/10** (`D38O_S_03`, 2. koşu), SONRA **0/10**; hepsi `AUTOTEST PASS`. SONRA ÖNCE-main'den fazla değil. Düzeltmenin (yaşlı tayfanın şafakta yer değiştirmesi) etkisi 1/10 → 0/10: istatistiksel kanıt değil, ama kök neden anlatımı (görüş çizgisine yakın baş) makul. Not: ham sayım satırlarında `S03` sütunum kendi desenimle eşleşmedi, `vis` (toplam VISAUDIT) sütunu esas: `ham_hooks_bad_*.txt` |

### Kanıtsız kalanlar (geliştirici "DURUYOR, KANITSIZ" demişti)
- 33o ustaların aletleri, 33o/38o gülle-ok-yüzücü halkaları: **BAKILMADI / KANITSIZ**. 33o bu turda değişmedi; ekranlı 33o koşusu yapmadım.
- 29o pala-su teması: **KANITSIZ** (değişmedi).
- 29 taş atma döngüsü: taş tutma karede var (`t0067` yakın taş atan tayfa, ayak dibinde yığın), atış anı **KANITSIZ**.
- Görünmeyen ağ bırakılmamış mı: 38o `world` gizleme kaldırılmış; 29 kanca/halat ağları görünür düğümler. Yeni bir görünmeyen ağ görmedim.

## 2. Yeni kusurlar
1. 38o merdiven: ikinci tırmanan tayfa öndekinin tam arkasında, hemen hiç görünmüyor; çatal kadrajda ama çok ince ve karanlık (p01 `+66`, p03). ÖNCE-ef'de de çatal seçilmiyordu; kötüleşme yok. KÜÇÜK.
2. 38o kadraj `main`e göre dar: yayındaki (ÖNCE-main) karede sur başındaki askerler ve geniş mazgal görünüyordu, SONRA'da kadrajın tepesi sky + kırmızı bant (p02). Bu bir gerileme sayılır ama maddenin istediği (tayfa baştan ayağa + çatal) sağlanıyor. KÜÇÜK.
3. 29 `D29_C_WIND +14/+16`: seren sırığı çapraz uzun çubuk gibi (p05). ÖNCE'de de var, değişmedi.
4. 29 ve 29o'da sonda/bot kancaya bakışı `chapter29.gd:253-257` yeni bot davranışı: oyun mantığını değiştirmiyor, ama ÖNCE karesi eş bakışta alınamıyor (ÖNCE'de bot kancaya bakmıyor). Kanıt hizası için rapor notu.
5. Diğer (liste dışı) havada duran / gövdeye giren / birden beliren kişi bulmadım; bütün kare listemde (38o `t0226–t0470`, 29 `t0020–t0120, t0200–t0262, t0424–t0440`, 29o `t0150–t0190`) yok.

## 3. Kurallara uygunluk
- `git diff e551de84 HEAD -- altı dosya`: kaldırılan satırlar yalnız görsel (ip/çatal/kuyruk ağı, `hook`→`hook_line`, `Vfx.dust` kaldırılması, `world.visible`, bakış çağrıları); replik anahtarı/sırası, süre sabiti (`HOLD_TIME`, `fork_at`, `pot_at`, `FORK_WINDOW`), sayaç, kazanma/kaybetme koşulu, kalabalık sayısı değişmemiş.
- Oyuncu konumu/kamera: `chapter38o.gd:_brace` `BRACE_AT` (0, 0, −9,18), `eye_height` 1,15 (yeni durma yeri; ÖNCE-main'de (0,0,−7,8)); bakış denetimi ≤1 sn (`_look_soft`). `_dawn` yaşlı tayfayı `OLD_POST`tan (−0,7) kaydırıyor (NPC konumu; bot yolu değil).
- Kanca/susturma: `grep "no_audit\|no_unclip\|_ok\b\|SONDA\|print(" ` beş dosyanın farkında yok. `set_meta("no_walk")` ince ip ağlarında (önceki denetçinin kabul ettiği kullanım).
- Test iskelesi: yok. `_bot_look` bot davranışı (yukarıda).
- `chapter33o.gd` ÖNCE-ef'e göre değişmemiş (`git diff ef860ea2 HEAD`: yalnız 4 dosya).

## 4. Testler (başsız, `--max-fps 20`, 25 koşu hepsi `AUTOTEST PASS`)
`SCRIPT ERROR / WARN_FX_STUCK / WARN_FLY_ITEM / VISAUDIT / WARN_VOID_TELEPORT / WALKTHRU / ARMAUDIT / HELDAUDIT / LOOKAUDIT backturn / JOURNEY_*` satırı **0** (ham: `ham_test_sonra.txt`).

| Bölüm | Varyantlar | Sonuç |
|---|---|---|
| 29 | `""`, `lose` | 2/2 PASS |
| 29o | `""`, `lose` | 2/2 PASS |
| 33o | `""`, `wide`, `fall` | 3/3 PASS |
| 38o | `""`, `lose`, `hooks_ok`, `hooks_bad` | 4/4 PASS |
| 38o | `hooks_bad` ×10 | SONRA 10/10 PASS, VISAUDIT 0 (ÖNCE-main 0/10, ÖNCE-ef 1/10) |
| 28o | `""`, `lose`, `edirne`, `edirne_ok` | 4/4 PASS |
| 34o | `""`, `bad` | 2/2 PASS |
| 19 | 8 varyantın hepsi | 8/8 PASS |
| ekranlı | 38o ×3 (ef/main/sonra), 29 ×3, 29o ×3 | hepsi bitti (rc=0) |

`parse_check`: PASS (248 betik).

## 5. RINFO (ekranlı; replik satırından sonraki ilk üç örnek; (çizim, nesne, üçgen bin, görünür üçgen bin))
Üçgen = `prims` (bin). Sınır: üçgen ≤ +%8 `main`e göre, çizim artmaz.

| Evre | ÖNCE-main | ÖNCE-ef | SONRA | Hüküm |
|---|---|---|---|---|
| 29o `gun` (`D29O_B_GUN`) | 2805/2638/2656 çizim; 1269/1298/1304 üçgen | 2646/2633/1045; 1304/1306/932 | 2797/2645/2651; 1269/1304/1307 | **eşit** (çizim −0,3 %, üçgen +0,5 %) |
| 38o `ladder` (`D38O_T_02`) | 2863/3002/2967; 2208/2189/2143 | 1411/1411/1411; 730/730/730 (world gizli) | 2726/2991/2958; 2205/2196/2154 | **eşit** (çizim −%2,6, üçgen +%0,3): gizleme olmadan ÖNCE-main ile aynı |
| 38o `ladder` bütün evre (23 örnek) | ort. çizim 2349, üçgen 1941 | ort. 1242 / 790 (world gizli) | ort. 2561 / 1984 | **eşit** (çizim +%9 ort., üçgen +%2,2; örnek hizası ±%10 oynuyor) |
| 38o `explore` (`D38O_T_TOP`, 3 örnek) | 2521/5212/4957; 1783/5751/5355 | 4170/2223/5320; 5004/1557/5811 | 4205/2376/5309; 5040/1627/5792 | örnek hizası kayıyor (kamera hareketli); üçgen toplamı 12 889 → 12 459 (−%3): **eşit** |
| 29 `wind` (`D29_C_WIND`) | 2551/2421/3260; 1181/1200/1839 | 2555/2707/3469; 1183/1441/1787 | 2552/2648/3475; 1190/1373/1831 | 1. ve 3. örnek ±%1; 2. örnek +%14 (hizalama kayması: ÖNCE-ef de +%20); ortalama +%4,1: **eşit/sınır içinde** |

38o `ladder` evresinde ÖNCE-ef'in düşük sayıları `world.visible=false`'tan geliyordu (önceki denetçinin −%57'si); gizleme kalkınca ÖNCE-main'e eşit.
`gun`'da çizim ve üçgen `main`e göre artmadı. 38o `explore` ve 29 `wind` bütçe içinde.

## 6. GENEL HÜKÜM: **KÜÇÜK DÜZELTMELERLE KABUL**

Yedi zorunlu maddenin altısı gerçek oynanış karesinde DOĞRULANDI (1, 2, 3, 4b, 5, 6, 7). Reddedecek bozulma yok; testler ve performans bütçesi tutuyor. Aşağıdakiler yapılmadan "tam DÜZELDİ" yazılmamalı (hiçbiri oyun akışını bozmuyor):

1. `chapter29o.gd:_tube_to / _climb(on_rope) / _fly_hook`: rapor/görev "ip ağı her karede kurulmuyor" diyor; gerçekte tırmanışta (2,2 sn) ve kanca uçuşunda (0,4 sn) hâlâ her karede kuruluyor (nokta kayması ≫ 5 mm). Ya raporu düzelt (koruma yalnız durağan karede) ya da ip için tek silindir + `Transform3D` kullan; beklenen: tırmanışta `tube_mesh` çağrı sayısı kare sayısından belirgin az.
2. `chapter38o.gd:_ladder_phase` (`CLIMB_AT/CLIMB_GAP/_climb_side`): ikinci tırmanan, öndekinin arkasında kapalı; aralığı/yan kaymayı artır ki iki tayfa birlikte görünsün (`D38O_T_02` +40 karesinde iki baş + iki gövde seçilsin). Çatal (`_fork_visual`): rengi açılsın/kalınlaşsın ki gece çatal gökyüzüne karşı seçilsin (p03).
3. `chapter38o.gd:_brace / BRACE_LOOK`: `main` karesindeki gibi sur başındaki askerler/mazgal de kadrajda kalsın (bakış biraz daha yukarı ya da geri durma) — şu an kadrajın üst üçte biri gökyüzü + kırmızı bant.
4. `chapter29.gd` autotest dalı (`_bot_look`): kanıt hizası için botun kancaya bakması geçerli, ama ÖNCE/SONRA aynı bakışla çiftlemek için raporunda "bot bakışı" ayrıca belirtilmeli (rapor zaten belirtmiş; 3. maddenin ÖNCE karesi eş bakışta değil).

Bakamadıklarım: 33o ekranlı koşu ve 33o RINFO (değişmedi); 38o kovalamada halat silinmesi; fareyle serbest bakış (bot fareyi oynatmıyor); 29 taş atış anı; 29o pala-su teması.

Çalışma notu: `--import` bazı `i18n/*.translation` dosyalarını ve `.import` dosyalarını üretti; bunları geri aldım/kaydetmedim (`git status`'ta yalnız bu klasör ve üretilmiş `shadow_body.gd.uid`).
