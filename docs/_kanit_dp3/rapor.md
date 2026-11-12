# P3 düzeltme turu (29, 29o, 33o, 38o) — geliştirici raporu

Dal: `wip/duzeltme-p3` (taban `wip/0.99.119` ucu `ef860ea2`). Düzenlenen dosyalar yalnız: `scripts/chapter38o.gd`,
`scripts/chapter29.gd`, `scripts/chapter29o.gd`, `scripts/level/sea_battle.gd`. (`chapter33o.gd` ve `bogaz.gd`
değişmedi.) Ortak dosya önerisi yok.

Kanıt düzeni: ÖNCE = `e551de84` (altı P3 dosyası eski hâlinde, ayrı kopya dizininde; depoya dokunulmadı), SONRA = bu
dalın ucu. Kareler ekranlı oynanış koşularından (`PACE=1`, xvfb 1280x720, `--dialogshots --shotevery=1 --snapevery=0.5`,
RINFO için `RINFO=1 --hitchaudit`). Kare adı `tNNNN` = koşunun kare sayacı; ÖNCE ve SONRA aynı replik anahtarına göre
hizalandı (ör. `D38O_T_02+60` = o replik karesinden sonraki 60. kare). Sonda karesi yok (merdiven kadrajını ayarlarken
`SONDA_P3` adlı geçici bir atlama kullandım; söküldü: `grep -rn SONDA_P3 scripts` → 0).

## Madde madde

| # | Madde | Ne yapıldı (dosya:işlev) | Kanıt | Durum |
|---|---|---|---|---|
| 1 | 38o merdiven tutma kadrajı | `chapter38o.gd:_brace`, `_look_soft`, `_ladder_grip`, `_fork_visual`, sabitler `BRACE_*`, `CLIMB_AT/GAP`, `_climb_side`. Oyuncu ayağın 0,22 m önünde çömelir (göz 1,15); bakış YALNIZ girişte 0,8 sn'de yumuşakça merdivenin yukarısına döner (`_look_soft`), sonra oyuncunundur (`player.free_look = true`, donmuşken de fareyle bakar; A/D ibreyi tutar). Eller dikmelerde (1,42 m); oyuncu başını çevirip tutuş yeri görüşten çıkınca eller kadrajın altına iner (havada, kameraya yapışık durmaz), bırakmaz. Tutuş boyunca `stow_hands(true)`: eller inip kalksa da telsiz belirmez; tutuş bitince (ateşe koşu, evre sonu) `stow_hands(false)`. Tırmanan iki tayfa merdivenin üst yarısına alındı (4,4 ve 7,4 m; eskiden 2,6 m'deki tayfa tam tepede kaldığından yalnız bacakları kadrajdaydı) ve basamağın iki yanına 0,1 m kaydırıldı. Çatal artık siperin üstünden çapraz iner, dişleri sağ dikmenin ucunu kavrar (eskiden mazgalın ardından düz geliyor, tayfanın gövdesinin arkasında kalıyordu). Eski `_brace_look` (45 sn süren bakış denetimi) silindi. | `p01`: `D38O_T_02+60` iki el dikmede, tayfa baştan ayağa, mazgal sırası kadrajda; `ÇATAL!` anı ve +2 karede çatal sağ dikmenin tepesinde, eller dikmede, telsiz yok | DÜZELDİ (ikinci tayfa öndekinin arkasında çoğunlukla kapalı: KISMEN görünür) |
| 2 | 38o `world.visible = false` | `chapter38o.gd:_ladder_grip`: dünya düğümü artık hiç gizlenmiyor (gizleme ve geri açma satırları kaldırıldı). | RINFO tablosu (`ladder` evresi) | DÜZELDİ |
| 3 | 29 kanca ipi içeriden görünsün | `sea_battle.gd:hook_line` yeni isteğe bağlı `over` (küpeşte genişliği yönü) kipi: kanca küpeştenin üstüne oturur (sap üstte, iki diş iç yüzden aşağı), ip sapın halkasına düğümlü, düğümden artan uç küpeştenin üstünden içeri uzanıp iç yüzden 0,34 m sarkar, gergin parça dış kenardan kadırgaya iner. `chapter29.gd:_spawn_hook` ve `_board_fight` bu kipi kullanır. 29o'nun `hook_line` çağrıları değişmedi (eski kip). Test botu artık keseceği kancaya bakar (`chapter29.gd` autotest dalı, `_bot_look`): gerçek oyuncu E'ye basmak için zaten kancaya bakmak zorunda; bot bakmadan kestiği için kanca hiçbir oynanış karesine girmiyordu. Botun yolu, ışınlandığı yerler ve zamanlaması aynı. ÖNCE koşusunda da aynı bot bakışı (yalnız kopya dizininde) kondu ki çift aynı bakışta olsun. | `p03`: `t0080` ÖNCE: kanca demiri küpeştenin dışında, ip görünmez; SONRA: kanca küpeştenin üstünde, düğüm ve iç yüzden sarkan ip seçiliyor (alt satır yakın kesit) | DÜZELDİ |
| 4 | 29o ip ağı her karede kurulmasın; düşüşte yakın krem şerit | `chapter29o.gd:_tube_to` (uçlar 5 mm'den az oynadıysa ve kesit aynıysa ağ kurulmaz; 33o `_guide_lay`/38o `_rope_hands` koruması) `_fly_hook` ve `_climb/on_rope`'ta kullanılıyor. `cut_hook`'taki `Stage.rope_to` zaten aynı 5 mm korumasını içeriyor (ortak `stage.gd`, değişmedi). Düşüşte: ipin alt ucu oyuncunun ayağının dibinden kadırganın küpeştesine (0,55 m önüne) alındı; düşüş boyunca `_rope_clear` ipi kameradan en az 0,3 m önde tutar, kesit 0,012. Tırmanış ipinin kesiti de 0,017 → 0,012 (`CLIMB_ROPE_R`): elden aşağı inen parça 35-50 cm'de kalın görünüyordu. | `p06` (SONRA: ince kesitli son koşu `sonra_29o2`): ÖNCE'de kameranın önünü kesen kalın krem çubuk; SONRA'da iki el ipte, düşüşten sonra ip ince ve önde | DÜZELDİ (not: ilk SONRA koşusunda `sonra_29o/t0240`'taki saydam bulut kova suyunun `Vfx.steam`'i, ip değil; e551de84'te de var) |
| 5 | 29 seren/sarılı yelken "mızrak" | `sea_battle.gd:war_galley`: demet serene yaslandı (serenin altında 0,14 m, direğin yanında x 0,15), boyu 6,8 → 5,4 m, uç kesiti 0,07 → 0,09 (sivri değil), rengi koyulaştırıldı. Eskiden demet serenin 1,37 m altında, ona koşut, havada duruyordu. Çizim sayısı aynı (tek silindir). | `p05` `D29_C_WIND +10/+16`: ÖNCE'de bordadan uzanan beyaz konik "mızrak"; SONRA'da +10'da yok, +16'da serenin üstünde demet. Ayrıca `p03`, `p04` üst satır | DÜZELDİ |
| 6 | 29 halat çeken tayfa | `chapter29.gd:_crew_jobs`: ip tayfanın sağ yanından geçer (ön el göğüs önünde, arka el belde), oradan güvertede basamağın dibindeki babaya (direk + çapraz, taş yığınlarıyla aynı tek ağda: çizim artmaz) iner, babaya sarılır, artanı babanın yanında kangal. | `p04` `t0250` ve yakın kesit: SONRA'da sırttan, ip gövdenin yanında, eller ipte, ip babaya sarılı ve kangalda biter; ÖNCE'de kollar yanda, ip yok | DÜZELDİ |
| 7 | 38o `hooks_bad` `VISAUDIT personhidden D38O_S_03` | Kök neden: şafakta rıhtıma yanaşınca oyuncu (kadırga yereli x 1,1 z 0) ile kıçtaki tayfa (1,4; −5,6) arasındaki görüş çizgisinin 0,3 m yanında yaşlı tayfa duruyor (OLD_POST 1,0; −4,6); `hooks_bad`'de "kuşkulu" dönüşünden sonra başı çizgiye 0,28 m'den yakın düşebiliyor. `_brace` durma yeriyle ilgisi yok (denetim satırındaki göz noktası (14,0; 2,6; 56,2) rıhtımda). Düzeltme `chapter38o.gd:_dawn`: yaşlı tayfa direk dibindeyse karartma içinde direğin iskele yanına (x −0,7) geçer. | Sayım aşağıda | DÜZELDİ |

Madde 7 sayımı (başsız, `--max-fps 20`, aynı komut):

| Kod | `hooks_bad` koşusu | `VISAUDIT personhidden D38O_S_03` | AUTOTEST |
|---|---|---|---|
| ÖNCE (`e551de84`) | 10 | **1** (3. koşu) | 10 PASS |
| P3 ilk teslim (`ef860ea2`, bu turdan önce) | 10 | 0 | 10 PASS |
| SONRA (bu dal) | 10 | **0** | 10 PASS |

Yani satır P3'ten önce de nadiren çıkıyordu (denetçide P3 ucunda 1/3, ÖNCE'de 0/3; bende ÖNCE 1/10, P3 ucu 0/10):
kaynağı yaşlı tayfanın şafaktaki yeri; düzeltmeden sonra 10 koşuda 0.

## Kanıtsız kalanlar

| Konu | Durum |
|---|---|
| 29 taş atma döngüsü | KISMEN: `p04` alt satır `t0050` ve `p03` `t0080`: taş atanlar taşı iki eliyle göğsünde tutuyor, ayaklarının dibinde yığın var (ÖNCE'de eller boş). Taşın küpeşteden atıldığı an karede yakalanmadı: atış KANITSIZ. |
| 33o ustaların aletleri | DURUYOR, KANITSIZ (33o'ya bu turda dokunmadım; ekranlı 33o koşusu yapmadım). |
| 33o / 38o gülle-ok-yüzücü halkaları | DURUYOR, KANITSIZ. 38o kurtarmada (`D38O_S2_FALL` +0..+20) kamera rıhtım duvarına bakıyor, yüzücü ve halkası kadrajda değil. |
| 29o pala-su teması | DURUYOR, KANITSIZ (değiştirilmedi). |

## Gözüme çarpan, düzeltmediğim

- 29 `t0080`: bot, kancanın önündeki tayfanın 0,3 m arkasına ışınlandığında o tayfanın kovası yakın düzlemin içinde
  kalıp yalnız dış çizgisi görünüyor (kadrajın sağ altında boş halka). Kova P3 ilk teslimde (`give_tool`) geldi; bot
  yoluna dokunmadığım için kaldı.
- 29o tırmanışın tepesinde (`t0240`) kova suyu `Vfx.steam` ile tam göz hizasında açılıyor: ekranı saydam bir bulut
  kaplıyor. e551de84'te de aynı (`once_29o/t0236`); bu turun maddesi değil.
- 38o merdivende alttaki tayfa üsttekini çoğu karede kapatıyor (yana 0,1 m kaydırmaya rağmen).

## Testler (başsız, `--max-fps 20`)

`parse_check`: PASS (248 betik). Son kodla, hepsi `AUTOTEST PASS`; `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`,
`VISAUDIT`, `WARN_VOID_TELEPORT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `LOOKAUDIT backturn`, `JOURNEY_MISS/OVERLAP`
satırı **0** (ham satırlar: `ham_test_ve_rinfo.txt`).

| Bölüm | Varyantlar | Sonuç |
|---|---|---|
| 29 | `""`, `lose` | 2/2 PASS |
| 29o | `""`, `lose` | 2/2 PASS |
| 33o | `""`, `wide`, `fall` | 3/3 PASS |
| 38o | `""`, `lose`, `hooks_ok`, `hooks_bad` | 4/4 PASS |
| 38o | `hooks_bad` ×10 | 10/10 PASS, VISAUDIT 0 |
| komşu: 28o, 34o, 19, 37o | `""` | 4/4 PASS |

Ekranlı koşular (kanıt kareleri) de `AUTOTEST PASS` ya da istenen evreden sonra benim durdurduğum koşular; hata
satırı yok.

## RINFO (ekranlı, `RINFO=1 --hitchaudit`, replik satırından sonraki ilk örnekler; ham: `ham_test_ve_rinfo.txt`)

| Evre (hizalama) | Çizim ÖNCE → SONRA | Üçgen (bin) ÖNCE → SONRA | Hüküm |
|---|---|---|---|
| 29 `wind` (`D29_C_WIND` +0..2) | 2371/2913/3457 → 2373/2911/3457 (ort. 2914 → 2914) | 1491 → 1494 (+%0,2) | eşit |
| 29o `gun` (`D29O_B_GUN` +1..3) | 2642/1556/1725 → 2633/1519/1683 (ort. −%1,5) | 1495 → 1486 (−%0,6) | düştü/eşit |
| 29o `hooks` (`D29O_B_HOOK`) | ort. 2122 → 2103 | 1639 → 1639 | eşit |
| 29o `climb` (`D29O_T_CLIMB` +0..2) | 2801/770/607 → 2793/797/606 | 752 → 755 (+%0,4) | 2. örnek +27 çizim, +%3,9 üçgen (kamera 2,2 sn'lik tırmanışta hareket ederken örnek anı kayıyor); öbür ikisi −8/−1 |
| 38o `climb` (`D38O_R_UP` +2..4) | ort. 6184 → 6205 (+%0,3) | 7487 → 7475 (−%0,2) | eşit |
| 38o `explore` (`D38O_T_TOP` +3..5) | 1394/1510/1497 → 1402/1510/1497 | 1131 → 1095 (−%3) | eşit |
| 38o `ladder` (`D38O_T_02` +6..8) | 2412/2412/2566 → 2680/2684/2853 (koşu 1), 2625/2610/2766 (koşu 2) | 2010 → 2146 / 2059 (+%6,8 / +%2,4) | **KISMEN / belirsiz** (aşağıda) |

38o `ladder`: dünya düğümü artık hiç gizlenmiyor (madde 2), çizim ÖNCE'nin altına inmiyor. Replik satırına hizalı RINFO
örneklerinde SONRA iki koşuda da ~+200..270 çizim (+%7..11) gösteriyor; üçgen artışı +%8'in altında. Bunu ayırmak için
iki geçici sonda (söküldü) koştum:
- Aynı sahne, aynı an, yalnız bakış pozu değişince (merdivene atlayarak): SONRA pozu 1786/1767, ÖNCE pozu 1776 çizim;
  ÖNCE kodu + ÖNCE pozu 1787. Bakış ve kod tek başına çizimi artırmıyor.
- Tam akış (kürek evresi dahil), merdiven kurulduktan tam 16 sn sonra: ÖNCE 2637, SONRA 2617 çizim (−%0,8); sahnedeki
  görünür ağ sayısı grup grup eşit (fazladan kalan düğüm yok). Aynı anda ÖNCE'nin RINFO koşusu 2412 veriyordu: aynı kodda
  koşudan koşuya ±%10 oynama var.
Sonuç: SONRA'nın merdiven evresinde çizim artırdığını gösteren bir neden bulamadım, ama RINFO örneklerindeki farkı da
"gürültü" diye kesinleyemedim: KISMEN.

## Bakamadıklarım

- 38o kovalama (`_chase`) ve rıhtım halatının silinmesi: bu turda koşmadım.
- Serbest bakışta (fareyle) ellerin kadraj altına inip geri gelmesi: test botu fareyi oynatmadığı için oynanış karesinde
  görülmedi; yalnız kod (`_ladder_grip`).
- 33o ekranlı koşu ve RINFO (33o değişmedi).
