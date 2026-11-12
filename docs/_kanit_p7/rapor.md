# P7 — Son gün: Bölüm 26, önsöz 0 ve 21 · rapor

Dal: `wip/yardimci-p7` · özgün kod (ÖNCE): bu dalın başlangıç kaydı `1e3a9b60` (ayrı bir `git worktree`'den koşuldu,
çalışma ağacında dosya değiştirilip geri konmadı). Bütün kareler ekranlı oynanış koşusundan (`xvfb-run`, 1280×720,
`--autotest`), ÖNCE ve SONRA aynı varyant, aynı olay anı. Anı seçen geçici sonda `tests/_tmp/p7_probe*.gd` idi
(oyun koduna kanca konmadı; sonda kaydedilmedi, silindi). Sonda yalnız olay anında kare alır ve ölçüm basar;
iki yerde zamanı yavaşlatır (aşağıda), ÖNCE ve SONRA koşusunda aynı biçimde.

## Madde tablosu

| # | Madde | Ne yapıldı (dosya:işlev) | Pafta | Durum |
|---|---|---|---|---|
| 1 | 26 "merdiveni it": eller merdivende değil (eski: göstergeden başka bir şey yok; ÖNCE karesinde kamera sur yoluna bakıyor, kılıç elde, merdiven karede yok) | `chapter26.gd:_ladder_push_tick/_push_begin/_push_aim/_push_end/_push_hide_blade`: Melee'nin merdiven kaydı (`hold`/`down`) okunur. Basılı tutulunca Tolga mazgal taşının başına çıkıp üstünden eğilir (`pinned`, göz 0,4 m iner, yumuşak geçiş), `Player.hold_both` ile iki el merdivenin iki sırığında (noktalar merdivenin yerelinde: merdiven oynarsa eller onunla gider), kılıç ve kalkan o an gizlenir (eller "meşgul" olduktan sonra: ARMAUDIT'in kendi istisnası, susturma yok). Merdiven devrilmeye başlayınca eller 0,35 sn onunla gider, sonra bırakır; kılıç geri gelir, Tolga sur yoluna geri adım atar. | p01, p02 | DÜZELDİ. Sonda ölçümü: el–sırık uzaklığı tutarken sağ 0,048 m / sol 0,040 m; devrilme +0,12 sn'de 0,092 / 0,074 m (merdiven 0,02 rad dönmüş, eller hâlâ sırıkta); +0,4 sn'de sağ el bırakmış (1,46 m). ÖNCE: 2,33 / 2,18 m, el görünmez. |
| 1b | Merdivenin ucu mazgal taşının 0,25 m altında, surun dış yüzündeydi: sur yolundan görünmüyor, el yetişemiyordu | `chapter26.gd:_build_walls_scene`: merdivenler 9,0 m/16° → 9,8 m/14,5° (ayak aynı yerde; uç mazgalın 0,6 m üstünde, taşın önünde). Tırmanma yolu Melee'de merdiven boyundan hesaplanır: tırmanış ~%9 uzar (bot ve 14 varyant geçti). | p01 | DÜZELDİ (yan etki: tırmanış süresi biraz uzun; denge kaygısı varsa geri alınabilir, o zaman 1. madde eğilme payıyla yeniden ayarlanmalı) |
| 2 | 26:1819 baltalı asker "hammer" pozunda | Kod incelendi: asker aletsiz DEĞİL (`Soldier.equip("axe")`, sağ elde balta). Kusur başka: "hammer" kol salınımında balta ön kolun boyunca yukarı bakıyor, vuruş mermere (yere) inmiyor; kırıntı yerden çıkıyor. Ortak Rig'de diz çökme + iki elle aşağı vuruş pozu olmadan doğru çözülemiyor (öneri aşağıda). Kod değişmedi. | — | DURUYOR (ÖNCE karesi alınamadı: `--shots` koşusu süre içinde bitmedi → KANITSIZ) |
| 3 | 0: ok demeti taşıyan oyuncunun önünde savunucular eli boş dikiliyor, aynı yöne bakıyor | `chapter0.gd:_build` (altı savunucu): kenardaki dördü okçu (`equip("bow")`, yön ±0,3 rad dağınık), `_archer_tick/_loose`: her biri kendi saatinde yayı gerer (Rig "aim", yay kalkar), oku barikatın üstünden ovaya bırakır; ok yere inince silinir (birikmez). Ortadaki ikisi okları bekleyen savunucu: koşup gelen Tolga'ya bakar (`look_target`), `Crowd.idle_vary` ile el sallar/gösterir/başını sallar. Top atılınca okçular durur (siper). Kalabalık sayısı aynı (6). | p03, p05 (sonda) | KISMEN: bakan/el sallayan bekleyenler ve uçan ok karede (p03 SONRA 7,5 sn, p05 SONRA), yayını germiş okçu yakalanan karelerde YOK → okçu döngüsü KANITSIZ |
| 4 | 0: demetler savunucuya "uzatılınca" göğsüne uçup yok oluyordu (uzaktan verme) | `chapter0.gd:_hit`: en yakın bekleyen savunucu Tolga'ya döner, demeti `Person.receive_item` ile alır ve elinde dik tutar (sahnede kalır). | p04 | DÜZELDİ (p04 SONRA +0,15 / +1,6: demet savunucunun elinde) |
| 5 | 0: kolun altındaki demetler elsiz, kameranın altında duruyordu | `chapter0.gd:_hands_on_load`: koşarken `hold_both` — sol el başın üstündeki kalkanın altında (kalkan 9 cm indi: iki el tutuşunun erişim kutusu), sağ el demetlerin altında; teslimde sağ el uzanır ve iner. | p03 | KISMEN: sağ el demetin altında görünüyor ama avuç açık okunuyor (kavrama değil, alttan destek) |
| 6 | 21: madenci "bir elinde kandil, öbüründe kazma" — kazma okunmuyor | Kod incelendi: kandil ve kazma zaten veriliyordu (`equip("lamp")`, `equip("pick")`). Kazmanın sapı ön kol boyunca yukarı, başı gövdenin ardında kalıyordu. `chapter21.gd:_breakthrough`: kazma (`Pick`) sapı öne-yukarı döndürüldü: demir başı gövdenin önünde, kandilin altında. Kol pozuna dokunulmadı (önce kolu öne aldım: sap gövdeye giriyordu, geri aldım). | p06 | DÜZELDİ (p06: ÖNCE yalnız sapın ucu, SONRA kazmanın demir başı ve sapı solda seçiliyor; kandil ikisinde de var) |
| 7 | 21: duvarı delen "kazma ucu" yarım metrelik çıplak gri çubuktu | `chapter21.gd:_breakthrough`: gerçek ölçülü `Items.tool_model("pickaxe")`; demir ucu (≈20 cm) yüzden Tolga'ya doğru çıkar, sapı yüzün içinde. Delmedeki toz ucun altına alındı (ucun önünde bulut olup örtüyordu). | p07 | KANITSIZ: testte bekleme 0,05 sn; ağır çekimle alınan +0,02 sn karesinde bile önceki üç vuruşun tozu ucu örtüyor (iki koşuda da) |
| 8 | assault/garrison sur içi figürlerinin donukluğu | Bakılmadı (süre). Garrison'da canlı mızraklı/okçu döngüleri (spear_loop, archer_loop, PoseCrew) zaten var. | — | DURUYOR / BAKILMADI |
| 9 | Çizim yükü (performans için, görünüş aynı) | `assault.gd:_ladders`, `_ladder_team`: kuşatma merdivenlerinin sırık+basamakları `Props.bake_static` ile tek ağ (8 merdiven × ~19 → 8; 3-4 taşıma merdiveni × 17 → 1). `chapter26.gd`: duvardaki 5 Ladder'ın çerçevesi aynı biçimde tek ağ (merdiven başına ~29 → 1, ağ merdivenle döner). `chapter0.gd:_merge_shafts`: demet başına 18 ok ağı → 1 (demet artık sahnede kaldığı için). | p03 (merdivenler aynı görünüyor) | Ölçüldü (aşağıda) |

## Testler (başsız, `--max-fps 20`, son kodla)
Satır başına `RUNOK` = `AUTOTEST PASS` var ve `SCRIPT ERROR / WARN_FX_STUCK / WARN_FLY_ITEM / VISAUDIT /
WARN_VOID_TELEPORT / WALKTHRU / ARMAUDIT / HELDAUDIT / JOURNEY_*` yok. `parse_check`: PASS (247 betik).

TESTLER_BURAYA

Ara sürümde bir kez `ARMAUDIT unarmed scene=chapter26.tscn foe_dist=4.5 duel_active=true` çıktı (kılıç, eller
merdivene geçmeden gizleniyordu); sıralama düzeltildi (önce eller meşgul, sonra kılıç kalkar; bırakırken önce kılıç
döner). Son kodda yok.

## Performans (ekranlı, llvmpipe; sondanın olay anında `RenderingServer` çizim ve ilkel sayısı)
FPS bu makinede iki koşuda da ~1 (yazılım çizimi): FPS karşılaştırması anlamsız, çizim/üçgen sayısı esas.

PERF_BURAYA

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
- 26 baltalı asker (madde 2): ÖNCE/SONRA karesi yok; kod değişmedi.
- 26'nın yalnız dalga 1 merdiven sahnesi kareyle görüldü; Ayasofya, giriş alayı, şafak ve 26.3 "hold" yolları
  yalnız başsız testle (14 varyant) sınandı. Merdivenlerin boyu bütün dalgalarda değişti; yalnız dalga 1'de karesi var.
- 0'da okçunun yayı gerdiği an karede yakalanmadı (madde 3, KANITSIZ kısım).
- 21 delme anı (madde 7) KANITSIZ.
- assault/garrison sur içi figürleri (madde 8) incelenmedi.
- `assault.gd` değişikliği (merdiven tek ağ) 20, 26o, 32o, 37o ve ana menü arka planına da yansır; yalnız 0 ve 26'da
  kareyle, 20 ve 26o'da başsız testle bakıldı.
