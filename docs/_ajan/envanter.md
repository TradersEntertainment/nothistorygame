# Oyuna yayma: kusur envanteri (Bölüm 2 ölçütü)

**Kaynaklar**
1. Kod taraması: bütün `scripts/chapter*.gd` (60 dosya), kullandıkları `scripts/level/*.gd`, `scripts/npc/*`, `scripts/combat/*`.
2. Eski kareler: `tests/out/visual/<bölüm>/` (30 Ekim tam görsel denetim koşusu, test botu, her bölüm; kod o tarihten sonra kısmen değişti). Her bölüm için zaman sıralı 12 karelik örnek pafta: `yayma/kare/<bölüm>/eski_pafta.jpg` (59 bölüm, hepsi açılıp incelendi). 17 için ek: `kare/17/eski_kurek.jpg`.
3. Yeni kareler (bu tur, `--autotest --dialogshots --snapevery=3`): `yayma/kare/<bölüm>/yeni/` ve paftaları `yayma/kare/<bölüm>/yeni_pafta*.jpg`. Durum en altta.

**Türler:** A havaya yapılan iş · B zemin teması · C donmuş/eşzamanlı figür · D çıplak zemin/kıyı/düz levha · E su tepkisi · F oyuncunun elinde yersiz eşya · G tutma/verme · H okunmayan olay.
**İş:** K küçük (<30 dk) · O orta (30-90 dk) · B büyük (>90 dk). **Görülme:** oyuncunun o şeyi gördüğü yaklaşık süre.
**Kanıt:** `eski:` = `tests/out/visual/<bölüm>/<kare>.jpg`; `yeni:` = `yayma/kare/<bölüm>/yeni/<kare>.jpg`; `koddan` = karede görülmedi.

## Bütün oyunu ilgilendiren kalıplar (Bölüm 2'de düzeltilenlerin başka yerlerdeki örnekleri)

| Kalıp | Nerede | Kanıt | Önerilen parça |
|---|---|---|---|
| **Çubuk halat** (sarkmasız, burgusuz düz silindir; iki nokta arasında) | `Bogaz.rope/make_rope` (bogaz.gd:428-450) → 22o, 33o, 35o (8 çağrı), edirne_yard (34o, 6), thrace_road (35o); `chapter28o.gd:174-178` çekme halatları `Props.cyl`; `chapter37o.gd:817-876` "hep birlikte çek" halatı; `chapter24o.gd:562` çadır ipi; `chapter31o.gd:273` ve `chapter39o.gd:743` `_rope_between`; `training_yard.gd:94` ip çit (41o, 42b) | yeni:28o/t0016-t0028 (krem çubuk), eski:37o/t0122, eski:41o/t0011, eski:42b/t0023 | `Stage.rope`/`rope_to` (sarkma, burgu, uç saçağı), kazıkta `rope_wrap`, yerde `rope_coil` |
| **Elleri hedefsiz "pull" pozu** | `chapter37o.gd:528` (`s.pose = "pull"`, 3 asker); 28o haul askerleri halat çubuğuna kol açısıyla | eski:37o/t0122 | Soldier "haul" + `rope` uçları + `Stage.grip`, `plant_feet` |
| **Aletsiz iş pozu** (Person "hammer/chop/stir/paint" etkinliği alet vermez: person.gd:558 yalnız write/whittle/read_ground'a alet verir) | `chapter21o.gd:114` kazmacı (chop), `22o:262,303,478`, `26:1819`, `31o:390` Kadri (stir), `32o:299`, `33o:121,200`, `34o:124,130`, `35o:119`, `36b:131`, `bogaz.gd:259`, `camp_day.gd:505` Kadri (chop), `camp_day.gd:616` Urban (hammer), `wall_fight.gd:364`, `byz_city.gd:919` (paint) | eski:10b/D10B_U_01 (Urban elleri boş), eski:32o/t0038 (basamak çakanlar), koddan çoğu | YENİ `Person.give_tool(tür)` / Bölüm 2'nin `slipway._job_*` istasyonlarının ortak hâli (bkz. ortak_eksikler.md) |
| **Suya girişte efektsiz ışınlama** | `chapter4.gd:953 _fell`, `chapter18.gd:689 _swim_back`, `chapter17.gd:1118` düşüş + `_haul_back`, `chapter35o.gd:570` nehre düşüş (tween), `chapter33o.gd:261` | koddan (kararmaya giriyor; sıçrama halkası, damla, ıslak çıkış yok) | `Vfx.water_ring` ×2 + `water_drops` + `Vfx.splash`; çıkışta `Vfx.drip`, `wet_mark` |
| **Kürek palası suya değince tepki yok** | `OarGrip` (oar_grip.gd) hiç su efekti üretmez: 17, 19, 19o, 29o, 33o, 38o, sea_battle (29, 29o, 37o, 38o) | eski:17/t0031-35, eski:19o/t0014-21, eski:29o/t0007 (pala çevresinde halka yok) | YENİ `OarGrip` içinde pala dalışında `Vfx.water_ring`+`water_drops` (ortak_eksikler) |
| **Kayık izi yok** | 10g (kayıkla ayrılış), 17, 19, 19o, 29o, 33o, 38o | eski:10g/t0012, eski:19/t0006 | YENİ `Vfx.wake(tekne, su_y)` (kıçta köpük halkaları, pruvada köpük) |
| **Yüzen NPC'nin çevresinde su kıpırdamıyor** | `chapter17.gd:796,1111` (boğulanlar sinüsle sallanır), `17o:574`, `33o:1191`, `38o:1234` | koddan | `Vfx.water_ring` (seyrek), `water_drops` kulaçta |
| **Tırmanırken elde eşya** | 26o, 30o, 33o, 38o, 41o (30 Ekim kareleri) | eski:26o/t0097, eski:30o/t0026,t0108, eski:38o/t0037-t0081, eski:41o/t0165, eski:33o/t0021 | `player._sync_busy_hands` (player.gd:811) artık `ladder != null` iken cebe koyuyor: **büyük olasılıkla düzeldi**, yeni karede doğrulanmalı (26o kuyrukta) |
| **Çıplak düz arazi** (tek renk boyalı alçak poligon, ayrıntı saçıcı yok) | `Nature.ground_detail/shore_band` yalnız slipway'de. Eski `Scenery.ground_detail` 22o, 26o, 32o, 37o, camp_day, galata, siege_field'da var ama seyrek | eski:4/t0003, eski:6-7 (ordugâh), eski:30o/D30O_N_01, eski:35o, eski:36b, eski:37o/t0136, eski:43o/t0042-84 (kuşbakışı) | `Nature.ground_detail` (mud, footprint, grass, stone, chips, wrack…) |
| **Kıyı bandı yok** (su düz levhaya keskin kesişiyor) | Galata rıhtımı (10g, 27), Haliç kıyısı (18), Boğaz (33o), Trakya deresi (35o), Petrion (38o) | eski:10g/D10G_T_01, eski:18/t0004, eski:27/D27_N_01, eski:35o/t0003 | `Nature.shore_band` (rıhtımda: taş dibinde köpük + yosun şeridi) |
| **Düz levha su birikintileri** (ordugâhta gökyüzü mavisi düz elipsler) | camp_day.gd:970 `_build_mud` (ıslak birikintiler parlak yassı küre) | eski:7/t0009, eski:43o/t0028 | `Nature.ground_detail` "mud"/"wet" (yumuşak kenarlı, eğime yatık) |

## Bölüm bölüm

Sıra oynanış sırasıdır (Perde I → III). "Gör." = görülme süresi.

### Bölüm 0 (önsöz, kara surları gece) — chapter0.gd; LandWalls, BattleExtras, Garrison, Assault
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| Ok demeti taşıyan oyuncunun önünde kalabalık savunucular dikilip bekliyor, aynı yöne bakıyor | C | chapter0.gd (kalabalık kurulumu) | eski:0/t0004-t0010 | Assault/BattleExtras iş döngüleri (PoseCrew "pass", ok demeti taşıyanlar) | O | ~40 sn |
| Sur içi zemin düz koyu tahta/toprak, ayrıntısız | D | land_walls.gd:172 `_build_ground` | eski:0/t0001 | `Nature.ground_detail` (stone, chips, footprint) | O | ~60 sn |

### Bölüm 1 (Hikmet'in garajı) — chapter1.gd; Garage, Bedroom
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| Kumandanın verilişi: Hikmet'in elinden oyuncunun eline geçiş anı karede seçilmiyor (el değmesi) | G | chapter1.gd (Handover kullanımı 1 yer) | eski:1/D1_H_18 (kumanda zaten oyuncunun elinde) | `Handover.take_from` + `Stage.grip_hold` (Hikmet'in eli eşyada) | K | 3 sn |
| Bölüm Bölüm 2 ölçütünde temiz (iç mekân) | — | — | eski:1 | — | — | — |

### Bölüm 3, 5, 8, 14, 15 (Büro, garaj, hırdavatçı, pazartesi) — iç mekân
Ölçütün kusur türleri neredeyse yok (iç mekân, oturan/konuşan figürler). Yalnız: 13 ve 3'te Hikmet "kolu çekiyorum" derken kare dışında (H, eski:13/D13_H_LEVER, K). 15 toplantı odası figürleri donuk (C, eski:15/D15_O_Q, K, düşük öncelik).

### Bölüm 4 (ilk gece: ordugâh + Haliç surları) — chapter4.gd (1396 st.); Camp, SeaWalls, Night
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| Gece ordugâhı: zemin tek renk koyu düz levha; sandıklar düz kutu kümesi | D | camp.gd:40 `_build_ground` | eski:4/D4A_T_04, t0001 | `ground_detail` (mud, footprint, grass, stone) + sandıklara ip/örtü | O | ~2 dk |
| Nöbetçiler (Hasan/Hüseyin) ateş başında; çevre ordugâhta hiç kımıldayan yok | C | camp.gd:145-181 | eski:4/D4A_HA_END | arka planda ateşe bakan oturan/ısınan figürler (Rig "sit_ground", "stir") | K | ~1 dk |
| Kapanış: Nihat düz yeşil levha tepede | D | chapter4.gd (Nihat sahnesi) | eski:4/t0003 | `ground_detail` grass, tall_grass, stone | K | 10 sn |
| Suya düşüş (4b): ses + kararma; sıçrama, halka yok | E | chapter4.gd:953 `_fell` | koddan | `Vfx.splash`, `water_ring`×2, `water_drops` | K | 2 sn |
| Haliç sur dibi kıyısı (4b): kıyı bandı yok | D/E | sea_walls.gd | koddan (autotest 4a yolunu oynadı) | `Nature.shore_band` | O | ? |

### Bölüm 6, 7, 9, 10, 10b, 10z, 11, 16, 24o, 43o (gündüz/gece ordugâh) — CampDay (camp_day.gd, 1013 st.)
Ordugâh oyunun en çok görülen dış mekânı (10 bölüm, toplam ~25-30 dk).
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| Ordugâh zemini zeytin yeşili düz boyalı arazi; çiğnenmiş toprak dendiği hâlde ayrıntı yok | D | camp_day.gd:349 `_build_ground` | eski:6/t0001-t0004, eski:7/D7_N_ARRIVE, eski:16/D16_S_01 | `Nature.ground_detail` mud, footprint, grass (çadır diplerinde), stone, chips (aşhane), wrack yerine saman | O | 10 bölümde sürekli |
| Gökyüzü mavisi düz elips "birikintiler" düz levha gibi | D | camp_day.gd:970 `_build_mud` | eski:7/t0009, t0010, eski:43o/t0028 | ground_detail "mud"/"wet" (yumuşak kenar, koyu, eğime yatık) | K | aynı |
| Kuşbakışı (43o drone): bütün ordugâh tek renk düz yeşil düzlükte; yollar, çiğnenmiş alanlar yok | D | camp_day.gd + world_walk | eski:43o/t0042-t0084 | ground_detail (seyrek, büyük ölçekli: patika, çamur yamaları) | O | ~2 dk |
| Aşçıbaşı Kadri "chop" etkinliğinde ama elinde bıçak/tahtada soğan yok; "tadar" derken kaşık yok | A | camp_day.gd:505; chapter10z | eski:9/D9_T_A, eski:10z/D10Z_K_CRIT_2 | `Person.give_tool("knife"/"ladle")` | K | ~3 dk (6, 9, 10z, 24o) |
| Urban "hammer" etkinliğinde çekiçsiz; döküm (10b) sahnesinde kalıba eli değmiyor | A | camp_day.gd:616 | eski:10b/D10B_U_01, t0005 | `give_tool("hammer")`, kalıp/kepçe tutuşu `Stage.grip` | K | ~1 dk |
| Otağ kapısı kuyruğu (10): sıradakiler kıpırdamıyor, hep aynı yöne | C | chapter10.gd | eski:10/D100_T_01-D100_A_Q3_OK | sırada ağırlık değiştirme, başını uzatıp bakma, biri sırayı bozup geri çekilir | K | ~2 dk |
| Mutfak arka planındaki aşçılar karıştırıyor ama kazanda kepçe yok | A | camp_day.gd (aşhane kalabalığı) | eski:10z/t0007 | `give_tool("ladle")` + kazan merkezine `Stage.grip` | K | ~3 dk |
| 24o "çadır iplerini kazığa sar": ip düz çubuk, sarılınca kazıkta tur yok | A | chapter24o.gd:562 `_rope` | eski:24o/t0014 | `Stage.rope_to` (gergin/gevşek sarkma), kazıkta `rope_wrap` | K | ~1 dk |
| 24o fırtına/dolu: zeminde ıslaklık, birikinti yok | D/E | chapter24o.gd | eski:24o/t0014, D24O_K_LOST_0 | ground_detail "wet", `Vfx.wet_mark` birikinti | K | ~1 dk |
| 11 (gece pazarı): şenlik ateşinin altı düz turuncu disk (yerde levha) | D | chapter11.gd / camp_day ateşleri | eski:11/t0007-t0010 | ateş taşı halkası + kül/kömür (ground_detail "chips" koyu) | K | ~1 dk |
| 16 (Sinerji tavuk): tavuk gözünden zemin düz | D | camp_day | eski:16/t0001 | ground_detail (yakın çekimde en çok görünen yer) | — (yukarıdakiyle) | 1 dk |

### Bölüm 10a, 12, 13 (otağ içi, arşiv) — OtagHall
Temiz sayılır. 12: "Kâtibe döner, yaz": kâtip yazıyor mu (Person "write" alet verir) koddan doğrulanmalı (A?, K). Saraylılar donuk (C, düşük).

### Bölüm 10g ve 27 (Galata rıhtımı) — galata.gd (735 st.)
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| Rıhtım taşı suya keskin kesişiyor: köpük, yosun, ıslak taş yok | D/E | galata.gd:104 `_build_ground` | eski:10g/D10G_T_01, eski:27/D27_N_01 | `Nature.shore_band` (rıhtım modu: dikey taş dibinde köpük çizgisi, yosun bandı) | O | ~4 dk |
| Gemiler suda koyu düz kutular; çevrelerinde su kıpırtısı yok | D/E | galata.gd (gemiler) | eski:10g/t0004, eski:27/D27_N_02_NEW | gövdeye ince köpük halkası (`water_ring` seyrek), halatla rıhtıma bağ (`rope_to` + babada `rope_wrap`) | O | ~4 dk |
| 10g kayıkla ayrılış: kürekçi/kürek, iz yok | A/E | chapter10g.gd (kayık) | eski:10g/t0012 | OarGrip kürekçi + YENİ `Vfx.wake` | O | 30 sn |
| Kalabalık meydan (27): ahitname okunurken herkes dimdik, kımıltısız | C | chapter27.gd | eski:27/t0014-t0016 | baş uzatma, fısıldaşma (Rig emote), çocuk omuzda | K | ~1 dk |

### Bölüm 10h, 23 (Bizans sarayı önü, elçilik) — ByzCity
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| 23 kartvizit: "TOLGA" kartı iki el arasında havada | G | chapter23.gd (Handover.take_from/pass_to) | eski:23/D23_T_CARD, D23_I_FAREWELL | `Stage.grip_hold` (İsmail Hamza'nın eli kartta) | K | 5 sn |
| Muhafızlar ve maiyet donuk | C | chapter23.gd, 10h | eski:23/D23_N_01-t0013 | nefes/ağırlık değiştirme, mızrak dibi yere (B) | K | ~3 dk |

### Bölüm 12b, 24, 25, 39o, 31o (şehir içi) — ByzCity, Ayasofya, FallenCity, Petrion
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| 24 ikona alayı: önden taşıyanların omzu/eli sırıkta değil (sırık omuzdan geçiyor ya da yanında) | G/A | chapter24.gd:98-121, 469 `LITTER_Y` | eski:24/t0011-t0017 | `Stage.grip` (her taşıyıcının bir eli sırıkta), omuz yüksekliği taşıyıcı boyuna göre | O | ~3 dk |
| 24 sağanak: sokaklar "sel" ama kaldırım kuru; damlalar zemine sıçramıyor | E/D | chapter24.gd (yağmur) | eski:24/D24_M_STOP, t0023 | ground_detail "wet" (parlak), `Vfx.wet_mark` birikinti, sıçrayan damla (`water_drops` yerde) | O | ~3 dk |
| 25 Ayasofya: cemaat sıra sıra aynı boyda, aynı yöne, kımıltısız | C | chapter25.gd | eski:25/t0009-t0026 | bir kısmı diz çöker, haç çıkarır (Rig "cross_self"), mum tutar | K | ~2 dk |
| 31o "kirişi kaldır": kiriş kara levha gibi havada; ellerin değdiği yok | G/A | chapter31o.gd:349-356 `_beam` | eski:31o/t0025 | `player.free_hold` ile iki el kirişin altında; Kadri/Azap `Stage.grip` | O | 30 sn |
| 31o "kaz (E basılı)": oyuncunun elinde kürek yok, elde leblebi | F/A | chapter31o.gd (kazı evresi) | eski:31o/t0059, t0073 | elde kürek (show_prop), kazılan yerde toprak yığını + ground_detail "mud" | O | 30 sn |
| 31o mezarlık/tepe: çıplak düz yamaç | D | fallen_city.gd:94 / petrion | eski:31o/t0045 | ground_detail grass, stone, tall_grass | K | 1 dk |
| 31o ip: `_rope_between` düz silindir | A | chapter31o.gd:273 | eski:31o/t0096-t0110 | `Stage.rope` | K | 1 dk |
| 39o ip pencereden sokağa: düz silindir | A | chapter39o.gd:743 | koddan | `Stage.rope` | K | 20 sn |

### Bölüm 17 (Haliç gecesi, kurtarma kayığı) — chapter17.gd (1426 st.); SeaWalls, Galata, Bureau
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| Kürekçiler OarGrip ile çekiyor (doğru) ama palalar suya girince halka/damla yok; kayığın izi yok | E | chapter17.gd:749 `_chain_skiff`, OarGrip | eski:17/t0031-t0035 | OarGrip su teması, `Vfx.wake` | O | ~3 dk |
| Boğulanlar (yüzenler) sinüsle sallanıyor; çevrelerinde halka, çırpınma sıçraması yok | E | chapter17.gd:796, 1111 | koddan | `water_ring`, `water_drops` | K | ~1 dk |
| Oyuncu güverteden suya düşünce: ses, kararma; halka/sıçrama/ıslak çıkış yok | E | chapter17.gd:1118, `_haul_back` | koddan | `splash`, `water_ring`, çıkışta `Vfx.drip`, güvertede `wet_mark` | K | 3 sn |
| Kurtarılanı sudan çekme: el ele tutma | G | chapter17.gd (kurtarma) | koddan | `Stage.grip_hold` (tayfa eli kurtarılanın bileğinde) | O | 10 sn × 3 |
| Edirne geri dönüşü (17E): Radu'nun kalemi, kebap şişi tutuşu | G | chapter17.gd | eski:17/D17E_R_02, D17E_T_KEB_2 | küçük: elde eşya tutuş noktası | K | 20 sn |

### Bölüm 17o (Haliç gecesi, top bataryası) — chapter17o.gd; Galata, Night, cannon_crew.gd
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| Top doldururken topçubaşı ve tayfa yanında boş dikiliyor; tokmak/çubuk kimsenin elinde değil | A/C | cannon_crew.gd (combat), chapter17o.gd:1033 | eski:17o/t0008-t0014 | YENİ "top doldurma tutuşu" (ortak_eksikler): tayfa sırayla barut kepçesi, tokmak, gülle taşır (`Stage.grip` iki el) | O | ~3 dk |
| Kova zinciri ("kıyıdan kovaları kapın"): kova taşıyanlar? | A | chapter17o.gd | eski:17o/t0015, D17O_K_DAWN | kova elden ele (`Stage.grip` + Handover), suya daldırılan kovada `water_ring` | O | 1 dk |
| Kıyı: sur dibi düz | D | galata / horn | eski:17o/t0003 | shore_band | K | 1 dk |
| Batan kadırga/isabet: su sıçraması var mı | E/H | chapter17o | eski:17o/t0011 (İSABET yazısı, su tepkisi seçilmiyor) | `water_ring` büyük, `splash` | K | 5 sn |

### Bölüm 18 (fıçı köprüsü) — chapter18.gd; Horn
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| Fıçıyı suya yuvarlarken oyuncunun yumruğu havada; fıçı karede yok | F/A/G | chapter18.gd (fıçı itme) | eski:18/t0006, t0008 | `player.free_hold` iki el fıçıda; fıçı ekranın alt yarısında | O | ~2 dk |
| Fıçı suya girince halka/sıçrama yok; yüzen fıçılar suyla etkileşmiyor | E | chapter18.gd | koddan | `water_ring`, `splash`, yüzenlerde seyrek halka (Bölüm 2 #16) | K | ~2 dk |
| Topun arkasında iten üç işçi (Soldier "push" sabit kol açısı) | A/B | chapter18.gd:615-640 | koddan | `Stage.grip` (eller top arabasında), `plant_feet` | O | 30 sn |
| Kıyı: çimen suya keskin; ıslak kum, köpük yok | D | horn.gd | eski:18/t0001-t0004 | `Nature.shore_band` | O | ~3 dk |
| Suya düşüş: kararma + ışınlama | E | chapter18.gd:689 `_swim_back` | koddan | splash, water_ring, drip, wet_mark | K | 2 sn |
| Köprücü Usta Mahmud ve işçiler: işçi var mı, iş yapıyor mu | C | chapter18.gd | eski:18/t0001-t0004 (iki kişi konuşuyor, arkada kimse çalışmıyor) | iş istasyonları (ortak_eksikler `Jobs`) | O | ~3 dk |

### Bölüm 18b (sur üstünde Bizans topu) — Horn, Garrison
Ölçüt açısından küçük: savunucu donuk (C, eski:18b/D18B_G_01), gülle suya düşünce halka (E, koddan). K.

### Bölüm 19 (Venedik kayığı, zincir) — chapter19.gd; SeaWalls, Galata
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| Devriye kayığının kürekleri dikine, suya değmiyor gibi (uzaktan çubuklar) | A/E | chapter19.gd:174-181 (OarGrip) | eski:19/t0006, t0008, D19_C_PASSED | kürek eğimi (pala suda), OarGrip su teması, `wake` | O | ~1 dk |
| Brigantin tayfası güvertede donuk | C | chapter19.gd | eski:19/D19_N_EMPTY | halat toplama, yelken (iş döngüsü) | K | 1 dk |

### Bölüm 19o (Osmanlı devriyesi, zincir) — chapter19o.gd; SeaWalls, Horn
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| Kürekçiler OarGrip'te (doğru); palanın suya girişi, kayık izi yok | E | chapter19o.gd | eski:19o/t0014-t0021 | OarGrip su teması, `wake` | K (ortak parça gelince) | ~3 dk |
| Devriye reisi kayıkta dimdik, sallanmıyor | C | chapter19o.gd | eski:19o/t0002-t0006 | tekne yalpasıyla denge (gövde eğimi) | K | ~2 dk |
| Zincir: indirilip kaldırılan zincir sahnesi | A | sea_walls.gd:83 `_build_chain` | koddan | zincir `Stage.rope` koyu renk + şamandıra kütükler | O | 30 sn |

### Bölüm 20 (gece gedik savunması) — chapter20.gd; LandWalls, WallFight, SiegeChaos
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| Sur önü ova düz koyu levha; uzaktaki ordu yoğun ama aynı fazda | D/C | land_walls.gd:644 `_build_field` | eski:20/t0021-t0127 | ground_detail (stone, mud, footprint, kırık ok), PoseCrew faz kaydırma | O | ~4 dk |
| Sur yolu tahta/toprak düz, sepetle toprak taşıyan var (iyi) | D | land_walls.gd:172 | eski:20/t0205, t0258 | ground_detail chips, stone, kan değil toprak | K | ~3 dk |

### Bölüm 20o (Osmanlı bataryası gündüz + gedik) — chapter20o.gd; LandWalls, BattleExtras
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| Top doldururken tayfa topun yanında boş dikiliyor (Urban konuşuyor) | A/C | chapter20o.gd:602 + cannon_crew.gd | eski:20o/t0017, D20O_U_GUN | top doldurma tutuşu | O | ~2 dk |
| Batarya zemini düz petek taş deseni, ayrıntısız; tahta dolgu | D | land_walls/siege_field (koddan) | eski:20o/D20O_N_01, t0017 | ground_detail chips, stone, ayak izi, barut lekesi | O | ~2 dk |

### Bölüm 21, 10l, 21o (lağım tünelleri) — chapter21.gd, 10l, 21o
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| Kazmacı "chop" pozunda kazmasız; Novo Brdo madencisi "bir elinde kandil, öbüründe kazma" deniyor, kazma yok | A | chapter21o.gd:114; chapter21.gd (madenci) | eski:21/t0013, D21_M_LIE; eski:21o/t0006 | `give_tool("pickaxe")`, kazılan yüzde toprak düşüşü (Vfx dust) | K | ~1 dk |
| Oyuncu "kazı yüzünü kaz (E)": elde araç yok | F/A | chapter21o.gd | eski:21o/t0006 | elde küçük kazma (show_prop) | K | 20 sn |

### Bölüm 22 ve 22o (bir gecede kule) — chapter22.gd, chapter22o.gd (1418 st.); LandWalls, SiegeTower, Bogaz
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| 22o "halatı çek, deri yukarı çıksın": halat düz çubuk (Bogaz.rope), oyuncunun elleri halatta görünmüyor | A/F/G | chapter22o.gd:438 `_update_ropes` | eski:22o/t0017 | `Stage.rope` (sarkma), elde halat: `player.free_hold` iki el, makarada `rope_wrap` | O | ~1 dk |
| 22o ustalar "hammer/chop" pozunda aletsiz | A | chapter22o.gd:262, 303, 478 | koddan | `give_tool` | K | ~1 dk |
| Kule önü zemin düz kahverengi, seyrek ot | D | chapter22o / land_walls | eski:22o/t0026, t0105 | ground_detail mud, stone, chips (yonga: kule bir gecede kuruldu) | O | ~3 dk |
| 22 fıçı oluktan iner; fitil | — | — | eski:22/t0005-t0025 | temiz | — | — |

### Bölüm 24 — yukarıda (şehir içi). Bölüm 24o — yukarıda (ordugâh).

### Bölüm 26 (son hücum, 2494 st.) ve 26o — LandWalls, Ladder, Assault, FallenCity
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| "Merdiveni it": oyuncunun elleri merdivende değil (yalnız bastırma göstergesi) | G/F | chapter26.gd (merdiven itme) | eski:26/t0018-t0064 | `player.free_hold` iki el merdiven sırığında, merdiven devrilirken eller ayrılır | O | ~1 dk |
| Sur yolu ve gedik önü düz; ok/ölü saçılı (iyi) | D | land_walls.gd | eski:26/t0132 | ground_detail stone, chips | — (P6 ile) | ~5 dk |
| 26 "sd.rig.activity = hammer" aletsiz | A | chapter26.gd:1819 | koddan | give_tool | K | ? |
| 26o tırmanışta elde eşya (eski kare); kod düzelmiş olabilir | F | player.gd:811 | eski:26o/t0097 | doğrulama | K | 30 sn |
| 26o giriş alayı (şehre giriş): askerler sıra sıra aynı pozda dikiliyor | C | chapter26o.gd | eski:26o/D26_N_ENTRY, t0342, t0375 | yürüyen alay (Walker), selamlayan halk | O | ~2 dk |

### Bölüm 28o (Urban topu bataryaya çekiliyor) — chapter28o.gd (844 st.); LandWalls, SiegeField
**Bölüm 2'nin en yakın benzeri: oyuncu uzun süre çekme ekibinin içinde.**
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| Çekme halatları iki düz krem çubuk (`Props.cyl`), sarkmasız; kızakta halka var ama askerlerin arkasında kangal/serbest uç yok | A | chapter28o.gd:174-178 | yeni:28o/t0016-t0028 (yeni_pafta1.jpg); eski:28o/t0014-t0022 | `Stage.rope` (yükten askerlerin ellerine yükselir, arkada `rope_coil`) | O | ~3 dk |
| Çekenler (2×6) aynı fazda, aynı eğimle; hey-yap ritmi oyuncunun Space'ine bağlı, ama hepsi birden | C | chapter28o.gd:180-190 (Soldier "haul") | yeni:28o/t0016-t0028 | Bölüm 2 gibi kişi başına gecikme, nefeslenme, ter silme | K | ~3 dk |
| Askerlerin ayakları petek taş zeminde, kızakla birlikte kayıyor (askerler kızağın çocuğu) | B | chapter28o.gd:194 `sled.add_child(s)` | yeni:28o/t0016-t0028 (adımlar seçilmiyor) | `Stage.plant_feet`, `walk_on_ground` (askerler kızağın değil zeminin çocuğu) | O | ~3 dk |
| Oyuncu çekerken sağ elinde koli bandı, sol eli halata uzanıyor | F | chapter28o.gd:730 `phase in ["stakes","haul"]` | yeni:28o/t0016-t0028 | haul evresinde `player.stow_hands(true)` + iki el halatta `free_hold` | K | ~3 dk |
| "Kazık çak": oyuncunun bir elinde kazık, öbüründe bant; tokmak yok | F/A | chapter28o.gd (stakes evresi) | yeni:28o/t0008 | elde tokmak; kazık yere dik, çakılınca toprak kabarır (ground_detail "mud") | K | ~1 dk |
| "Altmış öküz getirdi" deniyor: öküz yok; Urban boş dikiliyor | C/H | chapter28o.gd | yeni:28o/D28O_U_HAUL | Bölüm 2'nin `Ox`'u (npc/ox.gd) bataryanın gerisinde koşumlu takım; Urban gösterir/bağırır | O | ~3 dk |
| Batarya zemini düz petek taş levhası | D | land_walls/siege_field (koddan) | yeni:28o/t0003 | ground_detail (çamur, ayak izi, kızak izi, yonga) | O | ~4 dk |

### Bölüm 29 (Ceneviz gemisi) — chapter29.gd; SeaBattle
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| Savaşın ortasında tayfa güvertede kollar yanda dikiliyor | C | sea_battle.gd:312 / chapter29.gd | eski:29/t0004-t0044 | ok atan, kova taşıyan, halat kesen tayfa (PoseCrew / iş döngüsü) | O | ~4 dk |
| "Kancaların iplerini kes": ipler karede seçilmiyor | A/H | chapter29.gd | eski:29/t0012-t0044 | kanca ipleri `Stage.rope` (kadırgadan küpeşteye gergin), kesilince sarkar | O | ~2 dk |
| "Ateşi söndür (fıçıdan kova)": kova elde mi | F/G | chapter29.gd | eski:29/t0050-t0066 | elde kova (`free_hold`), fıçıya daldırınca `water_ring` | K | 1 dk |
| Gemi bordasından fırlayan beyaz uzun sopa (kürek/direk?) | A | sea_battle.gd | eski:29/t0072 | Bölüm 2 A2 gibi kaynağı bulunur | K | 10 sn |

### Bölüm 29o (Baltaoğlu kadırgası) — chapter29o.gd; SeaBattle
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| Kürekler bordadan beyaz düz sopalar; palanın suya girişi yok | E | sea_battle.gd:219 | eski:29o/t0007, t0013, t0023 | OarGrip su teması, kadırga izi | O | ~3 dk |
| Kanca at: kanca ipi | A | chapter29o.gd | eski:29o/t0017-t0019 | `Stage.rope_to` (kanca → oyuncunun eli) | K | 30 sn |

### Bölüm 30 ve 30o (Blakhernai) — Blachernae, Ladder, Rout
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| 30 "merdivenleri it": merdiven ve eller karede yok; elde leblebi | G/F/H | chapter30.gd | eski:30/t0061, t0071 | merdiven başı kadrajda, `free_hold` iki el | O | ~1 dk |
| 30o gece ovası düz koyu, birkaç beyaz taş | D | blachernae.gd:63 `_ground` | eski:30o/D30O_N_01, t0012 | ground_detail | O | ~2 dk |
| 30o tırmanışta elde eşya (eski kare) | F | — | eski:30o/t0026, t0108 | doğrulama | K | ~1 dk |
| 30o itiliş (c.pose = "push") | A | chapter30o.gd:238 | koddan | Stage.grip | K | ? |

### Bölüm 32o (Osmanlı hendek hazırlığı) — chapter32o.gd (1465 st.); LandWalls, Assault
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| "Merdivene basamak çak": ustalar tezgâh başında aletsiz dikiliyor | A/C | chapter32o.gd:285-300 | eski:32o/t0038, t0053 | give_tool("hammer"), Jobs istasyonu | K | ~2 dk |
| "Mantoyu it": itici Soldier "push" (289) | A/B | chapter32o.gd:289 | eski:32o/t0067 (el mantoda, iyi) | `Stage.grip`, `plant_feet` | K | 30 sn |
| Hendek kıyısı / ova düz | D | land_walls | eski:32o/t0014, t0026 | ground_detail | — (P6) | ~5 dk |
| Batarya (top) gündüz: tayfa boş | A/C | cannon_crew | eski:32o/t0078-t0108 | top doldurma tutuşu | — (P0) | ~2 dk |

### Bölüm 33o (Rumeli Hisarı, Boğaz) — chapter33o.gd (1454 st.); Bogaz, SeaBattle
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| "Taşı yuvaya indir: kılavuz ipi": ip düz çubuk (Bogaz.rope); iskele işçileri dimdik | A/C | chapter33o.gd (6 Bogaz.rope), 121, 200 (hammer aletsiz) | eski:33o/t0004-t0013, D33O_N_01 | Stage.rope, give_tool, iskelede iş döngüsü | O | ~3 dk |
| Kayıkla akıntıya karşı: kürekçi, pala-su, iz | E | chapter33o.gd (OarGrip) | eski:33o/t0017 | OarGrip su teması, wake | K | ~1 dk |
| İp merdiven: elde eşya (eski kare) | F | chapter33o.gd:261 | eski:33o/t0021 | doğrulama | K | 20 sn |
| Hisar şantiyesi zemini düz petek | D | bogaz.gd:112 `_ground` | eski:33o/D33O_N_01 | ground_detail chips, stone, mud | O | ~2 dk |
| Kıyı (Boğaz): shore_band yok | D | bogaz.gd | eski:33o/D33O_FZ_01 | shore_band | O | ~2 dk |

### Bölüm 34o (Edirne, top dökümü, kar) — chapter34o.gd (1470 st.); EdirneYard
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| "Çıkrığı ustabaşıyla birlikte çevir": ustabaşı kadrajda yok / eli çıkrıkta mı | G/H | chapter34o.gd:379 | eski:34o/t0008-t0026 | ustabaşı karşı kolda `Stage.grip_hold` | O | ~2 dk |
| Dökümhane ustaları (124,130) çekiç pozunda aletsiz | A | chapter34o.gd:124, 130 | koddan | give_tool | K | ~1 dk |
| Kar düz beyaz levha; ayak izi, çiğnenmiş kar yok | D | edirne_yard.gd:190 `_ground` | eski:34o/t0032-t0044 | ground_detail "footprint" (kar rengi), mud (çiğnenmiş), stone | O | ~3 dk |
| Güvenlik ipi ve zincirler Bogaz.rope çubuk | A | edirne_yard.gd:115-128, 310-325 | eski:34o/t0044 | Stage.rope (sarkma zaten "a→m" ile taklit ediliyor) | K | ~2 dk |
| Talim gören askerler blok hâlinde kımıltısız | C | edirne_yard.gd | eski:34o/t0008 (arka plan) | iş/talim döngüsü | K | ~2 dk |

### Bölüm 35o (Trakya yolu, top arabası) — chapter35o.gd (1478 st.); ThraceRoad, Bogaz
**Bölüm 2'nin ikinci yakın benzeri (çekme, fren ipi, öküz, dere).**
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| "Fren ipi: E basılı sık": oyuncunun elinde kütük/kazık var, ip karede seçilmiyor; ip Bogaz.rope çubuk | A/F/G | chapter35o.gd:876-946 `_brake_rope` | eski:35o/t0024-t0047 | `Stage.rope_to` (kazığa volta `rope_wrap`, sarkma), iki el ipte (`free_hold`), elde eşya cebe | O | ~3 dk |
| "Hey-yap çek": çekenlerin halatı (thrace_road `_man_ropes`, 113-116) çubuk; adamlar arabaya bağlı mı | A/C | thrace_road.gd:113-116, 558 | eski:35o/t0020 | Stage.rope + Stage.grip (Bölüm 2 haul ekibi) | O | ~3 dk |
| Öküzler: boyunduruk/koşum, arabaya bağ yok gibi; "kaçan öküz" ipi | A | chapter35o.gd:1094-1187 `_runners` | eski:35o/t0014, t0052 | Bölüm 2 `Ox` modeli + koşum + zincir `Stage.rope` | O | ~3 dk |
| Dereye düşüş (570): tween ile suya, halka/sıçrama yok | E | chapter35o.gd:570-599 | koddan | splash, water_ring, drip | K | 3 sn |
| Dere kıyısı ve köprü ayakları: köpük/ıslak kıyı yok (foam silindiri var: thrace_road:290) | D/E | thrace_road.gd:280-295 | eski:35o/t0003, t0009 | shore_band, köprü kazıklarında `water_ring` | O | ~2 dk |
| Yol ve tarlalar düz boyalı | D | thrace_road.gd:196 `_ground` | eski:35o/t0024-t0047 | ground_detail mud (tekerlek izi), footprint, grass, stone | O | ~5 dk |
| Çekiç (hammer) ustası aletsiz | A | chapter35o.gd:119 | koddan | give_tool | K | ? |

### Bölüm 36b (gece çıkışı) — chapter36b.gd; LandWalls
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| Sur dışı ova düz koyu; kazıcılar "chop" aletsiz | D/A | land_walls; chapter36b.gd:131 | eski:36b/t0004-t0082 | ground_detail; give_tool("pickaxe"/"shovel") | O | ~4 dk |

### Bölüm 37o (Mesoteichion, barikat) — chapter37o.gd (1171 st.); LandWalls, SeaBattle
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| "Hep birlikte çek": 3 asker eski "pull" pozunda (eller hedefsiz), halat düz çubuk mesh | A | chapter37o.gd:528, 794-876 | eski:37o/t0122 | Soldier "haul" + Stage.rope + grip + plant_feet | O | ~1 dk |
| "Yaralının kalkanını ipinden çek": ip | A/G | chapter37o.gd | eski:37o/t0136 | Stage.rope_to (kalkan → oyuncunun eli) | K | 30 sn |
| Barikat önü ova düz | D | land_walls | eski:37o/t0136-t0170 | ground_detail | — (P6) | ~3 dk |
| Davul-zil ritmi: davulcunun tokmağı davula iniyor mu | A | chapter37o.gd:376 | eski:37o/t0009 | Bölüm 2 DrumBeat | K | ~1 dk |

### Bölüm 38o (Petrion baskını) — chapter38o.gd (1714 st.); SeaBattle, Petrion, Ladder, Horn
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| "Merdiveni tut": sol el merdivenin yanında havada, sağ elde leblebi | F/G | chapter38o.gd:754-769 | eski:38o/t0037-t0067 | iki el merdiven sırığında (`free_hold` iki el), eşya cebe | K | ~1 dk |
| Kadırga kürekleri: pala-su teması yok | E | chapter38o.gd (OarGrip) | eski:38o/t0009-t0024, t0125 | OarGrip su teması, wake | K | ~2 dk |
| Yüzücü (1234) | E | chapter38o.gd:1234 | koddan | water_ring | K | ? |
| Sur yolu (SURUN ÜSTÜ SERBEST) taş, temiz | — | — | eski:38o/t0094 | — | — | — |

### Bölüm 41o, 42b (talim alanı) — TrainingYard
| Kusur | Tür | Yer | Kanıt | Parça | İş | Gör. |
|---|---|---|---|---|---|---|
| İp çit: kazıklar arasında düz çubuk ip (Bölüm 2'nin "iki kazık arasında çubuk halat"ı) | A | training_yard.gd:94-97 | eski:41o/t0011-t0151, eski:42b/t0023-t0237 | `Stage.rope` (sarkan), kazıkta `rope_wrap` | K | ~6 dk (iki bölüm, sürekli kadrajda) |
| Kum zemin düz, desenli levha; ayak izi, çiğnenmiş alan yok | D | training_yard.gd | eski:41o, 42b | ground_detail footprint, stone, chips (kırık sopa) | O | ~6 dk |
| Arkadaki talim edenler (okçular, mızrakçılar) | C | training_yard.gd | eski:41o/t0011 | PoseCrew döngüleri | K | ~3 dk |
| Tırmanışta elde eşya (eski) | F | — | eski:41o/t0165 | doğrulama | K | 20 sn |

### Bölüm 43o (drone) — CampDay, Drone
Ordugâh kalemleri (yukarıda). Ayrıca: Sultan'ın elinde telefon (eski:43o/t0120) iyi.

## Tür başına sayım (yukarıdaki tablolar; aynı kalıbın her bölümdeki örneği ayrı sayıldı)

| Tür | Sayı | En kötü örnekler |
|---|---|---|
| A havaya iş | 38 | 28o halat, 37o pull, 35o fren/öküz, 41o/42b ip çit, aletsiz çekiç/kazma/kepçe (14 yer), top doldurma tayfası |
| B zemin teması | 4 | 28o askerler kızakla kayar, 18 ve 32o iticiler (koddan) |
| C donmuş/eşzamanlı | 20 | ordugâh kuyruğu (10), Ayasofya cemaati (25), Ceneviz tayfası (29), 28o çekenler, 26o alay |
| D çıplak zemin/kıyı | 30 | ordugâh (10 bölüm), sur önü ova (20, 22o, 30o, 36b, 37o), batarya (20o, 28o), kar (34o), Trakya (35o), Galata rıhtımı, Haliç kıyısı |
| E su | 18 | kürek palası (6 bölüm), suya düşüş ışınlaması (4, 17, 18, 35o), yüzen NPC, kayık izi |
| F oyuncunun elleri | 11 | 28o çekerken bant, 18 fıçı yumruğu, 31o kazı, 35o fren, 38o merdiven tutma; tırmanış (5 bölüm, muhtemelen düzeldi) |
| G tutma/verme | 9 | 24 sırık, 23 kartvizit, 34o çıkrık, 26 ve 30 merdiven itme, 31o kiriş, 17 kurtarma |
| H okunmayan olay | 5 | 28o öküzler yok, 29 kanca ipleri, 34o ustabaşı kadraj dışı, 30 merdivenler kadraj dışı, 13 Hikmet kolu |

## Yeni kare durumu
(kuyruk: 28o 35o 17 24 6 18 / 37o 41o 19 29o 26o 4; sonuçlar aşağıya eklenir)
- 28o: alındı (yeni/, yeni_pafta1.jpg). Halat çubuk, çekenler eşzamanlı, oyuncunun elinde bant: DOĞRULANDI (30 Ekim'den beri değişmemiş).
- 35o: alındı (AUTOTEST PASS; yeni_pafta1.jpg, yeni_pafta2.jpg). DOĞRULANDI: fren ipi evresi (t0045-t0098) boyunca sağ elde LEBLEBİ kutusu, sol elde kazık/kütük, **ip hiç görünmüyor** (A/F/G); kaçan öküzü "ipin ucuna E" (t0104-t0110): iki yumruk havada, ip yok, öküz kadrajın kenarında (A/G/H); çekme evresi (t0032) halat seçilmiyor; zemin düz boyalı yeşil/kahve, tekerlek izi yok (D). 35o, P4'ün en kötü maddesi.
- 37o: 10 dk zaman aşımı (RC=124) barikat/"hep birlikte çek" evresinden önce bitti (son anahtar D37O_T_PLANK). "pull" maddesi koddan + eski:37o/t0122.
- 17: alındı (kısmen; yeni_pafta1.jpg). DOĞRULANDI: kürek sahnesi (t0143-t0188) kürekçiler OarGrip'te ama palaların çevresinde halka/damla yok, kayığın izi yok (E); ön planda oyuncunun küreğinin palası bulanık kocaman bej kütük gibi kadrajın sol altını kaplıyor (F/A: oyuncunun küreği, `player.oar_hold`, yakın plan ölçeği) — YENİ madde, P2'ye.
- 41o: alındı (yeni_pafta1.jpg). DOĞRULANDI: ip çit kazıklar arasında dümdüz ince çizgi (A), kum zemin düz (D).
- Kuyrukta kalanlar (24, 6, 18 / 19, 29o, 26o, 4) bu rapor yazılırken sürüyordu; kareleri yayma/kare/<bölüm>/yeni/ altına düşer, envantere işlenmedi.
