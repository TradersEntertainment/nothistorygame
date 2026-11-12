# P7 — Son gün: Bölüm 26, önsöz 0 ve 21 · rapor

Dal: `wip/yardimci-p7` · özgün kod (ÖNCE): bu dalın başlangıç kaydı `1e3a9b60` (ayrı bir `git worktree`'den koşuldu,
çalışma ağacında dosya değiştirilip geri konmadı). Bütün kareler ekranlı oynanış koşusundan (`xvfb-run`, 1280×720,
`--autotest`), ÖNCE ve SONRA aynı varyant, aynı olay anı. Anı seçen geçici sonda `tests/_tmp/p7_probe*.gd` idi
(oyun koduna kanca konmadı; sonda kaydedilmedi, silindi). Sonda yalnız olay anında kare alır ve ölçüm basar;
iki yerde zamanı yavaşlatır (aşağıda), ÖNCE ve SONRA koşusunda aynı biçimde.

## Madde tablosu

| # | Madde | Ne yapıldı (dosya:işlev) | Pafta | Durum |
|---|---|---|---|---|
| 1 | 26 "merdiveni it": eller merdivende değil (eski: göstergeden başka bir şey yok; ÖNCE karesinde kamera sur yoluna bakıyor, kılıç elde, merdiven karede yok) | `chapter26.gd:_ladder_push_tick/_push_begin/_push_aim/_push_end/_push_hide_blade`: Melee'nin merdiven kaydı (`hold`/`down`) okunur. Basılı tutulunca Tolga mazgal taşının başına çıkıp üstünden eğilir (`pinned`, merdivenin 0,38 m gerisi, göz 0,4 m iner, yumuşak geçiş; bakış merdivene diktir, ova kadraja girmez), `Player.hold_both` ile iki el merdivenin iki sırığında (noktalar merdivenin yerelinde: merdiven oynarsa eller onunla gider), kılıç ve kalkan o an gizlenir (eller "meşgul" olduktan sonra: ARMAUDIT'in kendi istisnası, susturma yok). Merdiven devrilmeye başlayınca eller 0,35 sn onunla gider, sonra bırakır; kılıç geri gelir, Tolga sur yoluna geri adım atar ve bakışı itmeden önceki yere (dövüşe) 0,35 sn'de döner. Yalnız sürmekte olan çarpışmada ve merdiven başındayken (2,4 m) çalışır. | p01, p02 | DÜZELDİ. Sonda ölçümü (el kökü–sırık ekseni): tutarken sağ 0,072 m / sol 0,033 m; devrilme +0,12 sn'de 0,034 / 0,039 m (merdiven 0,02 rad dönmüş, eller sırıkta); +0,4 sn'de bırakmış (1,35 m). ÖNCE: 2,33 / 2,18 m, eller görünmez, merdiven kadrajda yok. |
| 1b | Merdivenin ucu mazgal taşının 0,25 m altında, surun dış yüzündeydi: sur yolundan görünmüyor, el yetişemiyordu | `chapter26.gd:_build_walls_scene`: merdivenler 9,0 m/16° → 9,8 m/14,5° (ayak aynı yerde; uç mazgalın 0,6 m üstünde, taşın önünde). Katı gövde eski 9 m boyunda bırakıldı (sur yolunun kenarında görünmez engel olmasın). Tırmanma yolu Melee'de merdiven boyundan hesaplanır: tırmanış ~%9 uzar (bot ve 14 varyant geçti). | p01 | DÜZELDİ (yan etki: tırmanış süresi biraz uzun; denge kaygısı varsa geri alınabilir, o zaman 1. madde eğilme payıyla yeniden ayarlanmalı) |
| 2 | 26:1819 baltalı asker "hammer" pozunda | Kod incelendi: asker aletsiz DEĞİL (`Soldier.equip("axe")`, sağ elde balta). Kusur başka: "hammer" kol salınımında balta ön kolun boyunca yukarı bakıyor, vuruş mermere (yere) inmiyor; kırıntı yerden çıkıyor. Ortak Rig'de diz çökme + iki elle aşağı vuruş pozu olmadan doğru çözülemiyor (öneri aşağıda). Kod değişmedi. | p08 (yalnız ÖNCE) | DURUYOR (p08: `--shots` koşusunda, balta salınımın altında göğüs hizasında, yere inmiyor) |
| 3 | 0: ok demeti taşıyan oyuncunun önünde savunucular eli boş dikiliyor, aynı yöne bakıyor | `chapter0.gd:_build` (altı savunucu): kenardaki dördü okçu (`equip("bow")`, yön ±0,3 rad dağınık), `_archer_tick/_loose`: her biri kendi saatinde yayı gerer (Rig "aim", yay kalkar), oku barikatın üstünden ovaya bırakır; ok yere inince silinir (birikmez). Ortadaki ikisi okları bekleyen savunucu: koşup gelen Tolga'ya bakar (`look_target`), `Crowd.idle_vary` ile el sallar/gösterir/başını sallar. Top atılınca okçular durur (siper). Kalabalık sayısı aynı (6). | p03, p05 (sonda) | KISMEN: p03 SONRA'da bekleyen (kırmızı) savunucu koşan Tolga'ya dönük (ÖNCE sırtı dönük); p05 sondada okçunun yayı ve barikatın üstünden uçan ok seçiliyor. El sallama ara bir koşu karesinde görüldü, son paftalarda yok; yayını germiş okçu hiçbir karede yakalanmadı → okçu döngüsünün germe anı KANITSIZ |
| 4 | 0: demetler savunucuya "uzatılınca" göğsüne uçup yok oluyordu (uzaktan verme) | `chapter0.gd:_hit`: en yakın bekleyen savunucu Tolga'ya döner, demeti `Person.receive_item` ile alır ve elinde dik tutar (sahnede kalır). | p04 | DÜZELDİ (p04 SONRA +0,15 / +1,6: demet savunucunun elinde) |
| 5 | 0: kolun altındaki demetler elsiz, kameranın altında duruyordu | `chapter0.gd:_hands_on_load`: koşarken `hold_both` — sol el başın üstündeki kalkanın altında (kalkan 9 cm indi: iki el tutuşunun erişim kutusu), sağ el demetlerin altında; teslimde sağ el uzanır ve iner. | p03 | KISMEN: sağ el demetin altında görünüyor ama avuç açık okunuyor (kavrama değil, alttan destek) |
| 6 | 21: madenci "bir elinde kandil, öbüründe kazma" — kazma okunmuyor | Kod incelendi: kandil ve kazma zaten veriliyordu (`equip("lamp")`, `equip("pick")`). Kazmanın sapı ön kol boyunca yukarı, başı gövdenin ardında kalıyordu. `chapter21.gd:_breakthrough`: kazma (`Pick`) sapı öne-yukarı döndürüldü: demir başı gövdenin önünde, kandilin altında. Kol pozuna dokunulmadı (önce kolu öne aldım: sap gövdeye giriyordu, geri aldım). | p06 | DÜZELDİ (p06: ÖNCE yalnız sapın ucu, SONRA kazmanın demir başı ve sapı solda seçiliyor; kandil ikisinde de var) |
| 7 | 21: duvarı delen "kazma ucu" yarım metrelik çıplak gri çubuktu | `chapter21.gd:_breakthrough`: gerçek ölçülü `Items.tool_model("pickaxe")`; demir ucu (≈20 cm) yüzden Tolga'ya doğru çıkar, sapı yüzün içinde. Delmedeki toz ucun altına alındı (ucun önünde bulut olup örtüyordu). | p07 | KANITSIZ: testte bekleme 0,05 sn; ağır çekimle alınan +0,02 sn karesinde bile önceki üç vuruşun tozu ucu örtüyor (iki koşuda da) |
| 8 | assault/garrison sur içi figürlerinin donukluğu | Bakılmadı (süre). Garrison'da canlı mızraklı/okçu döngüleri (spear_loop, archer_loop, PoseCrew) zaten var. | — | DURUYOR / BAKILMADI |
| 9 | Çizim yükü (performans için, görünüş aynı) | `assault.gd:_ladders`, `_ladder_team`: kuşatma merdivenlerinin sırık+basamakları `Props.bake_static` ile tek ağ (8 merdiven × ~19 → 8; 3-4 taşıma merdiveni × 17 → 1). `chapter26.gd`: duvardaki 5 Ladder'ın çerçevesi aynı biçimde tek ağ (merdiven başına ~29 → 1, ağ merdivenle döner). `chapter0.gd:_merge_shafts`: demet başına 18 ok ağı → 1 (demet artık sahnede kaldığı için). | p03 (merdivenler aynı görünüyor) | Ölçüldü (aşağıda) |

## Testler (başsız, `--max-fps 20`, son kodla)
Satır başına `RUNOK` = `AUTOTEST PASS` var ve `SCRIPT ERROR / WARN_FX_STUCK / WARN_FLY_ITEM / VISAUDIT /
WARN_VOID_TELEPORT / WALKTHRU / ARMAUDIT / HELDAUDIT / JOURNEY_*` yok. `parse_check`: PASS (247 betik).

Son kodla (başsız, `--max-fps 20`):

| Bölüm | Varyant | Sonuç |
|---|---|---|
| 0 | "", "=next" | 2/2 RUNOK (`AUTOTEST PASS chapter=0 variant= froze=true`, `variant=next froze=true`) |
| 21 | "", grant, fight, thermos, ear, captive | 6/6 RUNOK |
| 26 | "", nophoto, hold, hold_box, hold23, hold3, warn_notrust, hold_lose, lighter, isidore, kasim, candle, council_ok, council_bad | 12/14 RUNOK ilk geçişte; hold23 ve hold_lose yeniden koşuda RUNOK (aşağıda) |
| 20, 26o | "" (assault.gd'yi kullanıyorlar) | 2/2 RUNOK |

Not: görevde "0 (3)" yazıyor; `run_tests.sh`'ta Bölüm 0 için tek satır var, `chapter0.gd` yalnız "next" varyantını
tanıyor. İkisini koştum; üçüncü bir varyant bulamadım.

İlk geçişte düşen iki 26 koşusu (aynen):
```
RUNFAIL --chapter=26 --autotest=hold23
VISAUDIT overlap scene=chapter26.tscn a=Squad b=Squad at=(-16.6, 0.0, 6.6) src=Chapter26>Squad>Person|Chapter26>Squad>Person
RUNFAIL --chapter=26 --autotest=hold_lose
VISAUDIT overlap scene=chapter26.tscn a=Squad b=Squad at=(-19.4, 0.0, 8.1) src=Chapter26>Squad>Person|Chapter26>Squad>Person
ARMAUDIT unarmed scene=chapter26.tscn foe_dist=6.8 duel_active=false
```
O sırada aynı makinede ekranlı bir 26 koşusu da sürüyordu. Tek başına yeniden koşunca: hold23 RUNOK, hold_lose 2/2
RUNOK. `hold_lose` ARMAUDIT'i (duel_active=false, topçunun Giustiniani'yi vurduğu andan hemen sonra) ÖZGÜN kodda da
çıkıyor: başlangıç kaydıyla 9 koşuda 2 kez (`ARMAUDIT unarmed ... foe_dist=1.7 duel_active=false`,
`... foe_dist=1.4 ...`). Benim dalımda (ara sürümler ve ayırma denemeleri dahil) 27 koşuda 15 kez çıktı. Ayırma: itme kodu kapalıyken 3'te 1,
assault.gd özgünken 3'te 2, merdiven boyu özgünken 3'te 1; son kodla tek başına 2'de 0. Tek bir değişikliğe
bağlayamadım; özgün kodda da olan zamanlamaya bağlı bir oynaklık, ama benim dalımda daha sık görünüyor ve nedenini
kesin açıklayamıyorum: AÇIK (öneri: `melee.gd:_arm_audit` dövüş bitmişken (`duel.active == false`) ve kılıç
`keep_drawn_blade` ile saklanmamışken neden çalıştığına bakılmalı). Squad/Squad VISAUDIT'i
(garrison yedek bölüğü) daha önceki 3 hold23 koşusunda çıkmamıştı, yükte bir kez çıktı.
Ara sürümde gerçek bir hatam da çıktı ve düzeltildi: kılıç, eller merdivene geçmeden gizleniyordu
(`ARMAUDIT unarmed scene=chapter26.tscn foe_dist=4.5 duel_active=true`). Bitmiş dalganın Melee'sindeki bayat
"hold" yeni bir tutuşu başlatabiliyordu (yalnız `duel.active` olan Melee okunuyor); itme sonunda `_hand_shown`
kalıcı olarak değişiyordu (artık başta saklanıp aynen geri konuyor).

## Performans (ekranlı, llvmpipe; sondanın olay anında `RenderingServer` çizim ve ilkel sayısı)
FPS bu makinede iki koşuda da ~1 (yazılım çizimi): FPS karşılaştırması anlamsız, çizim/üçgen sayısı esas.

**Bölüm 26 (perf sahnesi), dalga 1 merdiven sahnesi**

| an | ÖNCE çizim / üçgen | SONRA çizim / üçgen | fark |
|---|---|---|---|
| RINFO t=1 | 10990 / 12609k | 10660 / 12611k | -3.0% / +0.0% |
| RINFO t=3 | 11689 / 12759k | 11213 / 12763k | -4.1% / +0.0% |
| RINFO t=5 | 6836 / 9338k | 6420 / 9333k | -6.1% / -0.1% |
| RINFO t=7 | 7015 / 9342k | 6229 / 8980k | -11.2% / -3.9% |
| c26_push_grip_a | 6789 / 9340k | 7859 / 9774k | +15.8% / +4.6% |
| c26_push_hold | 6796 / 9331k | 7672 / 9970k | +12.9% / +6.8% |
| c26_push_grip | 6905 / 9408k | 6712 / 9522k | -2.8% / +1.2% |
| c26_push_tip_12 | 6902 / 9301k | 6241 / 8941k | -9.6% / -3.9% |
| c26_push_tip_40 | 7009 / 9373k | 8908 / 12168k | +27.1% / +29.8% |
| c26_push_tip_90 | 7099 / 9329k | 6734 / 9410k | -5.1% / +0.9% |

**Bölüm 0 (açılış sahnesi), koşu ve teslim**

| an | ÖNCE çizim / üçgen | SONRA çizim / üçgen | fark |
|---|---|---|---|
| c0_walk_15 | 11344 / 13758k | 10999 / 13844k | -3.0% / +0.6% |
| c0_walk_35 | 10832 / 13754k | 10483 / 13679k | -3.2% / -0.5% |
| c0_walk_55 | 10743 / 13718k | 10477 / 13711k | -2.5% / -0.1% |
| c0_walk_75 | 10131 / 13087k | 9882 / 13081k | -2.5% / -0.0% |
| c0_deliv_15 | 9558 / 13283k | 9318 / 13332k | -2.5% / +0.4% |
| c0_deliv_50 | 9516 / 13218k | 9314 / 13234k | -2.1% / +0.1% |
| c0_deliv_100 | 7973 / 10815k | 7860 / 10899k | -1.4% / +0.8% |
| c0_deliv_160 | 7924 / 10911k | 7805 / 10946k | -1.5% / +0.3% |

**Bölüm 21, lağım**

| an | ÖNCE çizim / üçgen | SONRA çizim / üçgen | fark |
|---|---|---|---|
| c21_miner_03 | 1591 / 2201k | 1589 / 2195k | -0.1% / -0.3% |
| c21_miner_10 | 1556 / 2207k | 1546 / 2177k | -0.6% / -1.4% |

Değerlendirme. 0 ve 21'de her anda çizim azaldı, üçgen en çok +%0,8. 26'da 2 sn'lik RINFO örneklerinde çizim
−%3…−%11, üçgen ≤ +%0,0. 26'da itme penceresinde üç an bütçeyi AŞIYOR ve bunu gizlemiyorum:
- `grip_a`/`hold` (+%16/+%13 çizim, +%5/+%7 üçgen): bakış yumuşakça merdivene inerken (ilk ~0,3 sn). ÖNCE'de
  kamera bu anda sur yolunun taşına bakıyordu (merdiven hiç görünmüyordu).
- `tip_40` (+%27 / +%30): eller bıraktıktan sonra bakış dövüşe dönerken ovadan geçiyor.
Tutuş anında (`grip`, `tip_12`) ve sonrasında (`tip_90`) bütçe içinde: bunun için Tolga taşın üstüne eğilip merdivene
dik bakar (ova kadrajın dışında kalır) ve bırakınca bakış itmeden önceki yere döner. Aşan anlar yalnız bakışın
değiştiği ~0,5 sn; aynı bölümde oyuncu ovaya baktığında (RINFO t=1, t=3) çizim zaten 10 600–11 700.
Kalan çare: geçişi daha kısa tutmak ya da bakışı hiç ovadan geçirmemek (bırakırken önce aşağı, sonra yana).


## Ortak dosyalar için öneriler (değiştirilmedi)
1. `rig.gd`: yere vuruş pozu (diz çökme + iki elle yukarıdan aşağı balta/kazma). 26 baltalı asker ve 21o kazmacı için:
   ```gdscript
   "chop_ground":   # diz çöker, iki el sapta, ağız yere iner (Items "axe"/"pickaxe", mode "two", aim yerde)
       var ph := fmod(t * 0.9, 1.0)
       var down := smoothstep(0.55, 0.7, ph) * (1.0 - smoothstep(0.85, 1.0, ph))
       body.position.y = lerpf(body.position.y, -0.35, k)
       body.rotation.x = lerpf(body.rotation.x, 0.35 + down * 0.25, k)
       _knee(knee_l, 1.4, k); _knee(knee_r, 0.4, k)
       arm_r.rotation = Vector3(-2.6 + down * 2.0, 0, 0.15); arm_l.rotation = arm_r.rotation * Vector3(1, 1, -1)
   ```
   ve `items.gd:_tool_line` içinde "axe"/"pickaxe" için iki uçlu çizgi (sap omuzdan yere).
2. `player.gd:_hold_both_points`: erişim kutusu `z ≥ -0.75` sabit; mazgalın üstünden eğilme gibi durumlar için
   isteğe bağlı `hold_both(..., reach := 0.75)` parametresi (bugün 26'da oyuncuyu taşın başına taşıyıp göz yüksekliğini
   indirerek karşılandı).
3. `melee.gd:push_ladder`: devrilme anında `l["pushed_at"]` gibi bir işaret; bölümler (26, 30) tutuşu ona bağlar
   (bugün `down > 0` okunuyor).
4. `battle_extras.gd:arrow_bundle`: 18 ok ağını tek ağda kurmak (bugün 0'da yerelde `_merge_shafts`).

## Bakamadıklarım
- 26 baltalı asker (madde 2): kusur karede gösterildi (p08) ama düzeltilmedi; kod değişmedi.
- 26'nın yalnız dalga 1 merdiven sahnesi kareyle görüldü; Ayasofya, giriş alayı, şafak ve 26.3 "hold" yolları
  yalnız başsız testle (14 varyant) sınandı. Merdivenlerin boyu bütün dalgalarda değişti; yalnız dalga 1'de karesi var.
- 0'da okçunun yayı gerdiği an karede yakalanmadı (madde 3, KANITSIZ kısım).
- 21 delme anı (madde 7) KANITSIZ.
- assault/garrison sur içi figürleri (madde 8) incelenmedi.
- `assault.gd` değişikliği (merdiven tek ağ) 20, 26o, 32o, 37o ve ana menü arka planına da yansır; yalnız 0 ve 26'da
  kareyle, 20 ve 26o'da başsız testle bakıldı.
