# Oyuna yayma: iş paketleri

Kaynak: `yayma/envanter.md` (madde ayrıntıları ve kanıt kareleri), `yayma/ortak_eksikler.md` (P0).
Her paket bir ajanın 1-2 saatlik işi. **Dosya sahipliği:** bir `scripts/level/*.gd` dosyasını yalnız sahibi paket
değiştirir; öteki paketler onu yalnız çağırır. Birden çok paketin kullandığı ama düzeltme gerektirmeyen dosyalara
(`night.gd`, `handover.gd`, `look.gd`, `props.gd`, `player.gd`) P0 dışında kimse dokunmaz. `chapter2.gd`,
`slipway.gd` hiçbir pakette yok (Bölüm 2 başka ajanda).

**Sıra:** P0 → (P1, P2, P4 paralel) → (P3, P5, P6 paralel) → (P7, P8, P9, P10). Aynı anda en çok 2 ekranlı Godot
kuralı yüzünden en çok 2-3 paket aynı anda yürür.

**Her paketin ortak kabul ölçütü** (Bölüm 2 ölçütü):
- Önce/sonra kareleri: aynı varyant, aynı an (`--dialogshots` anahtarı ya da yakın-plan sonda `tests/_tmp/<paket>_close.gd`),
  `yayma/<paket>/once|sonra/`, karşılaştırma paftası `yayma/<paket>/karsilastirma/`.
- Sonda ölçümü: tutulan her nesnede el-nesne uzaklığı ≤ 0,08 m; ayak tabanı-zemin ≤ 0,05 m; halatların iki ucu bağlı.
- `tests/run_tests.sh` içindeki ilgili bölüm satırlarının bütün varyantları AUTOTEST PASS, yeni `VISAUDIT float/sunk`,
  `WARN_FLY_ITEM`, `SCRIPT ERROR` yok.
- Perf: paketin en ağır bölümünde (belirtilmiş) önce/sonra FPS ve çizim çağrısı; düşüş ≤ %5.

---

## P0 — Ortak eksikler (ilk, tek başına)
- **Bölümler:** yok (ortak dosyalar); doğrulama için 2 (yalnız koşu), 17, 28o, 38o.
- **Dosyalar:** `scripts/level/stage.gd`, `nature.gd`, `vfx.gd`, `scripts/npc/person.gd`, `soldier.gd`, `rig.gd`,
  `oar_grip.gd`, `crowd.gd`, `scripts/combat/cannon_crew.gd`, `scripts/player/player.gd` (yalnız ekleme),
  `scripts/level/bogaz.gd` (yalnız `rope`/`make_rope`), YENİ `scripts/level/jobs.gd`, `items.gd` (alet modelleri).
- **Maddeler:** ortak_eksikler.md 1-11 (give_tool, Jobs, OarGrip su teması, Vfx.wake, water_entry/exit, top doldurma
  tayfası, Player.hold_both, Bogaz.rope→Stage.rope, Stage.chain, ground_detail yeni türleri + quay_band, Crowd.idle_vary).
- **Kabul:** her işleve sonda; Bogaz.rope değişikliğinin 22o/33o/35o/34o karelerinde sarkan burgulu halat olarak
  göründüğü 4 kare; 17 kürek sahnesinde pala halkası karesi; tırmanışta elin boş olduğu 26o ve 38o kareleri.
- **Test:** `--chapter=2` (bütün varyantlar: slipway ortak dosyaları kullanıyor), 17 (""/"=fall"), 19o, 22o, 33o, 35o, 34o, 26o, 38o, 28o.
- **Süre:** 2 saat (en büyüğü). Bölmek gerekirse P0a (1-5, 8) ve P0b (6, 7, 9-11).

## P1 — Ordugâh (en çok görülen dış mekân) · ÖNCELİK 1
- **Bölümler:** 4, 6, 7, 9, 10, 10b, 10z, 11, 16, 24o, 43o (ordugâh kısımları).
- **Dosyalar:** `scripts/level/camp_day.gd`, `camp.gd`, `chapter4.gd`, `chapter6.gd`, `chapter7.gd`, `chapter9.gd`,
  `chapter10.gd`, `chapter10b.gd`, `chapter10z.gd`, `chapter11.gd`, `chapter16.gd`, `chapter24o.gd`, `chapter43o.gd`.
  (4'ün Haliç kısmındaki `sea_walls.gd` dokunulmaz: P2'nin.)
- **Maddeler:** ordugâh zemini `ground_detail` (mud, footprint, grass, stone, chips, straw) — gündüz ve gece (camp.gd);
  düz mavi birikintiler → mud/wet; kuşbakışı (43o) ölçeğinde patika/çamur yamaları; Kadri bıçak/kepçe, Urban çekiç
  ve döküm kalıbı tutuşu; aşhane kazanlarında kepçe; otağ kuyruğu kıpırtısı (Crowd.idle_vary); 24o çadır ipi
  (`Stage.rope_to` + `rope_wrap`), fırtınada ıslak zemin; 11 şenlik ateşinin altındaki düz disk → taş halka + kül;
  4 gece kampı zemini ve ateş başı figürleri; 4 suya düşüş (`Vfx.water_entry`); 4 Nihat'ın tepesi.
- **Kabul (kareler):** 6 D6A_T_01 (ordugâh genel), 7 t0009 (birikinti), 9 D9_T_A (Kadri bıçakla), 10 D100_T_01 (kuyruk),
  10b D10B_U_01 (Urban), 10z D10Z_K_CRIT_2 (tadarken kaşık), 11 t0007 (ateş), 24o t0014 (ip), 43o t0042 (kuşbakışı),
  4 D4A_T_04 + 4 "=fall" düşüş anı.
- **Test:** 4 (bütün 9 varyant), 6 (10), 7 (10), 9 (12), 10 (7), 10b (6), 10z (4), 11 (10), 16 (3), 24o (6), 43o (4).
- **Perf:** 43o (kuşbakışı bütün ordugâh) ve 6.
- **Süre:** 2 saat.

## P2 — Haliç: kayıklar, kıyılar, Galata · ÖNCELİK 2
- **Bölümler:** 17, 17o, 18, 18b, 19, 19o, 10g, 27.
- **Dosyalar:** `scripts/level/galata.gd`, `horn.gd`, `sea_walls.gd`, `chapter17.gd`, `chapter17o.gd`, `chapter18.gd`,
  `chapter18b.gd`, `chapter19.gd`, `chapter19o.gd`, `chapter10g.gd`, `chapter27.gd`.
- **Maddeler:** rıhtım ve Haliç kıyısı (`Nature.quay_band`/`shore_band`); gemilerin rıhtım halatları; kayıklarda
  OarGrip su teması (P0) etkinleştirme ve `Vfx.wake`; 19 devriye küreklerinin eğimi; yüzen/boğulan NPC halkaları;
  17 ve 18 suya düşüşte `water_entry/exit` (ışınlama yerine kısa çırpınma + çekilme); 17 kurtarmada el ele
  `grip_hold`; 18 fıçıyı iki elle itme (`hold_both`) ve fıçının suya girişi; 18 topu iten üç işçi (grip,
  plant_feet); 18 köprü şantiyesinde iş istasyonları (Jobs); 17o top tayfası (P0 `add_crew`) ve kova zinciri; 19
  brigantin tayfası iş döngüsü; 19o reis yalpası, zincir (`Stage.chain`); 27 meydan kalabalığı kıpırtısı.
- **Kabul (kareler):** 17 t0031-t0035 (pala halkası, iz), 17 "=fall" düşüş, 18 t0006 (fıçı iki elde), 18 t0004 (kıyı),
  10g D10G_T_01 (rıhtım dibi), 10g t0012 (kayık izi), 19 t0006 (kürek), 19o t0014 (pala), 17o t0008 (tayfa top başında),
  27 t0014 (kalabalık).
- **Test:** 17 (11 varyant), 17o (4), 18 (6), 18b (2), 19 (8), 19o (4), 10g (3), 27 (7).
- **Perf:** 17 (gece, su, kalabalık).
- **Süre:** 2 saat.

## P3 — Deniz savaşları ve Boğaz şantiyesi · ÖNCELİK 5
- **Bölümler:** 29, 29o, 33o, 38o.
- **Dosyalar:** `scripts/level/sea_battle.gd`, `bogaz.gd` (P0'dan sonra), `chapter29.gd`, `chapter29o.gd`,
  `chapter33o.gd`, `chapter38o.gd`. (`petrion.gd`, `horn.gd`, `ladder.gd` dokunulmaz.)
- **Maddeler:** 29 Ceneviz tayfası iş döngüsü (ok, kova, halat), kanca ipleri `Stage.rope` (kesilince sarkar), kova
  elde ve fıçıda halka, bordadan fırlayan sopa; 29o kadırga kürekleri su teması + iz, kanca ipi; 33o kılavuz ipi
  (Bogaz.rope zaten P0'da sarkacak; ellerin ipte olması), iskele ustalarına alet, hisar şantiyesi zemini, Boğaz
  kıyısı, kayık; 38o "merdiveni tut" iki el (`hold_both`), kürek su teması, yüzücü halkası.
- **Kabul:** 29 t0012-t0044 (tayfa iş başında, kanca ipleri), 29o t0007 (pala), 33o t0004 (ip, iskele), 38o t0037 (iki el merdivende).
- **Test:** 29 (2), 29o (2), 33o (3), 38o (4).
- **Perf:** 29o (kadırga + kürekler).
- **Süre:** 1,5 saat.

## P4 — Top çekme, Trakya yolu, Edirne dökümhanesi (Bölüm 2'nin en yakın benzerleri) · ÖNCELİK 3
- **Bölümler:** 28o, 35o, 34o.
- **Dosyalar:** `chapter28o.gd`, `chapter35o.gd`, `chapter34o.gd`, `scripts/level/thrace_road.gd`, `edirne_yard.gd`,
  `siege_field.gd`. (28o'nun `land_walls.gd` zemini P6'nın; batarya zemini 28o'nun kendi yaması olarak `chapter28o.gd` içinde yapılır.)
- **Maddeler:** 28o çekme halatı `Stage.rope` (ellerden yükselir, arkada kangal), askerler kızağın değil zeminin
  çocuğu (`walk_on_ground` + `plant_feet`), kişi başına faz; oyuncunun iki eli halatta (eşya cebe); kazık çakarken
  elde tokmak; öküz takımı (npc/ox.gd) bataryanın gerisinde; Urban yönetir; batarya zemini (cobble_wear, mud,
  footprint, kızak izi). 35o fren ipi (kazıkta `rope_wrap`, iki el), çekme ekibi halatları ve tutuşları (Bölüm 2
  haul ekibi), öküz koşumu + zincir, kaçan öküzün ipi, dereye düşüş `water_entry/exit`, dere kıyısı `shore_band`,
  köprü kazıklarında halka, yol zemini (wheel_ruts, mud, footprint, grass, stone), ustaya çekiç. 34o çıkrıkta
  ustabaşı karşı kolda (`grip_hold`), dökümcülere alet, kar izi (`snow_tracks`), güvenlik ipi/zincirler (Stage.rope/chain),
  talim bölüğü kıpırtısı.
- **Kabul:** 28o t0016-t0028 (yayma/kare/28o/yeni_pafta1.jpg ile aynı anlar), 28o t0008 (kazık), 35o t0024-t0047
  (fren), 35o t0014 (öküz), 35o "=slip", 34o t0008-t0026 (çıkrık), 34o t0044 (kar, ip).
- **Test:** 28o (4), 35o (2), 34o (2).
- **Perf:** 35o (uzun yol, çok figür).
- **Süre:** 2 saat.

## P5 — Talim alanı ve Osmanlı bataryaları (gündüz sur önü) · ÖNCELİK 6
- **Bölümler:** 41o, 42b, 20o, 32o.
- **Dosyalar:** `scripts/level/training_yard.gd`, `chapter41o.gd`, `chapter42b.gd`, `chapter20o.gd`, `chapter32o.gd`.
  (`land_walls.gd`, `assault.gd`, `battle_extras.gd` dokunulmaz: P6/P7.)
- **Maddeler:** ip çit `Stage.rope` + kazıkta `rope_wrap` (41o, 42b, oyuncunun önünde sürekli); kum zemin
  footprint/stone/chips; arkadaki talim edenlerin döngüleri; 20o ve 32o top tayfası (P0 `add_crew`), batarya
  zemini (cobble_wear, barut lekesi); 32o basamak çakan ustalara alet ve tezgâh (Jobs), mantoyu iten Soldier "push"
  → grip + plant_feet; hendek kıyısı zemini (yalnız chapter32o.gd içinde yerel yama).
- **Kabul:** 41o t0011 (ip çit), 42b t0023, 20o t0017 (tayfa), 32o t0038 (çakan ustalar), 32o t0067 (manto).
- **Test:** 41o (2), 42b (2), 20o (10), 32o (7).
- **Perf:** 42b.
- **Süre:** 1,5 saat.

## P6 — Kara surları gece (sur önü ovası, kule, barikat) · ÖNCELİK 4
- **Bölümler:** 20, 22, 22o, 26o, 36b, 37o.
- **Dosyalar:** `scripts/level/land_walls.gd`, `battle_extras.gd`, `wall_fight.gd`, `siege_tower.gd`, `ladder.gd`,
  `chapter20.gd`, `chapter22.gd`, `chapter22o.gd`, `chapter26o.gd`, `chapter36b.gd`, `chapter37o.gd`.
- **Maddeler:** `land_walls._build_field/_build_ground` ova ve sur yolu ayrıntısı (stone, mud, arrows, footprint,
  ash) — bu tek değişiklik 0, 20, 20o, 21, 22, 22o, 25, 26, 26o, 28o, 32o, 36b, 37o'ya yansır (yoğunluk ışık/gece
  koşuluna göre); uzak ordunun faz kaydırması; 22o halatı (P0 ile sarkar) + ellerin halatta olması (`hold_both`),
  makarada `rope_wrap`, ustalara alet, kule önü yonga; 26o giriş alayı yürüyüşü ve halk; 36b kazıcılara kazma/kürek;
  37o "hep birlikte çek" (Soldier "haul" + Stage.rope + grip + plant_feet), kalkan ipi, davulcu tokmağı;
  wall_fight.gd:364 aletsiz işçiler.
- **Kabul:** 20 t0021 (ova), 22o t0017 (halat ve eller), 22o t0026 (kule önü), 36b t0004, 37o stockade evresi
  (D37O_AB_04 sonrası kareler: çekenler), 37o t0136 (kalkan ipi), 26o D26_N_ENTRY (alay).
- **Test:** 20 (9), 22 (7), 22o (6), 26o (5), 36b (2), 37o (3). Ağır: 20, 26o — kısa zaman aşımı, ilk 3 dk kareleri yeter.
- **Perf:** 20 (en ağır sahne; ova ayrıntısı burada ölçülür).
- **Süre:** 2 saat.

## P7 — Son gün: 26 ve önsöz 0 · ÖNCELİK 7
- **Bölümler:** 26, 0, 21.
- **Dosyalar:** `chapter26.gd`, `chapter0.gd`, `chapter21.gd`, `scripts/level/assault.gd`, `siege_chaos.gd`,
  `garrison.gd`, `fallen_city.gd`.
- **Maddeler:** 26 "merdiveni it" iki el merdivende (`hold_both`), merdiven devrilirken bırakılır; 26:1819 alet;
  0 ok demeti taşıyanlar ve savunucu kalabalığının iş döngüleri (PoseCrew "pass", Crowd.idle_vary); 21 madenci
  kazması (give_tool "pickaxe") ve kandil tutuşu; assault/garrison sur içi figürlerinin donukluğu.
- **Kabul:** 26 t0018-t0064 (merdiven itme), 0 t0004-t0010 (kalabalık), 21 t0013 (madenci).
- **Test:** 26 (14 varyant; ağır: kısa zaman aşımı), 0 (3), 21 (6).
- **Perf:** 26.
- **Süre:** 1,5 saat.

## P8 — Şehir içi: alay, sağanak, kilise, yangın · ÖNCELİK 8
- **Bölümler:** 24, 25, 23, 10h, 12b, 31o, 39o.
- **Dosyalar:** `scripts/level/byz_city.gd`, `ayasofya.gd`, `petrion.gd`, `chapter24.gd`, `chapter25.gd`,
  `chapter23.gd`, `chapter10h.gd`, `chapter12b.gd`, `chapter31o.gd`, `chapter39o.gd`.
- **Maddeler:** 24 ikona taşıyıcılarının elleri sırıkta (`Stage.grip`, omuz yüksekliği), sağanakta ıslak kaldırım +
  birikinti + yere sıçrayan damla; 25 cemaat kıpırtısı (diz çökme, haç, mum); 23 kartvizit `grip_hold`, muhafızlar;
  10h maiyet; 31o kiriş iki elde, kazıda elde kürek + toprak yığını, tepe zemini, `_rope_between` → Stage.rope;
  39o ip → Stage.rope; byz_city.gd:919 boyacıya fırça.
- **Kabul:** 24 t0011-t0017 (taşıyıcılar), 24 D24_M_STOP (ıslak), 25 t0009, 23 D23_T_CARD, 31o t0025 (kiriş), 31o t0059 (kazı).
- **Test:** 24 (5), 25 (7), 23 (5), 10h (7), 12b (5), 31o (4), 39o (6).
- **Süre:** 1,5 saat.

## P9 — Blakhernai · ÖNCELİK 9
- **Bölümler:** 30, 30o.
- **Dosyalar:** `scripts/level/blachernae.gd`, `rout.gd`, `night_army.gd`, `chapter30.gd`, `chapter30o.gd`.
  (`ladder.gd` P6'nın: yalnız çağrılır.)
- **Maddeler:** 30 merdiven itmede merdiven başı kadrajda + iki el (`hold_both`), elde eşya cebe; 30o gece ovası
  zemini, `c.pose = "push"` (238) → grip + plant_feet; tırmanışta elin boş olduğunun doğrulanması.
- **Kabul:** 30 t0061 (merdiven itme), 30o D30O_N_01 (ova), 30o t0026 (tırmanış).
- **Test:** 30 (4), 30o (4; ağır: kısa zaman aşımı).
- **Süre:** 1 saat.

## P10 — İç mekânlar ve tüneller (düşük öncelik) · ÖNCELİK 10
- **Bölümler:** 1, 3, 5, 8, 10a, 10l, 12, 13, 14, 15, 21o.
- **Dosyalar:** ilgili `chapter*.gd`; `scripts/level/garage.gd`, `otag_hall.gd`, `bureau.gd` (yalnız 2209 "push",
  2504 "stir" alet).
- **Maddeler:** 1 kumandanın el ele geçişi (`grip_hold`); 13 ve 3'te Hikmet kolu çekerken kadrajda; 12 kâtibin
  yazarken kalemi (doğrulama); 21o ve 10l kazmacılara kazma, oyuncunun kazısında elde araç; 15 toplantı figürleri;
  bureau işçilerine alet.
- **Kabul:** 1 D1_H_18, 13 D13_H_LEVER, 21o t0006, 10l D10L_T_04.
- **Test:** 1 (3), 3 (6), 5 (5), 8 (10), 10a (2), 10l (4), 12 (9), 13 (11), 14 (9), 15 (tam liste, uzun), 21o (4).
- **Süre:** 1 saat.

---

## Öncelik gerekçesi (kısa)
1. **P1 Ordugâh:** 11 bölüm, demonun (Perde I) içinde; toplam görülme ~25-30 dk; en çok tekrarlanan "çıplak zemin".
2. **P2 Haliç:** Bölüm 2'nin hemen ardından gelen su sahneleri (17, 18, 19), aynı kusurlar (kürek, düşüş, kıyı).
3. **P4 Top çekme/Trakya:** Bölüm 2 ile birebir aynı tür iş (halat ekibi, fren, öküz); sahibi farkı hemen görür.
4. **P6 Sur gecesi:** `land_walls.gd` zemini tek değişiklikle 13 bölüme yansır; 37o "pull" Bölüm 2'nin eski kalıbı.
5. P3, P5, P7, P8, P9, P10: daha az görülen ya da tekil kusurlar.
