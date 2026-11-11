# Ortak parçalarda eksikler (Paket P0: ÖNCE bu yapılır)

Bölüm 2'de eklenen `Stage.grip/rope/plant_feet…`, `Nature.ground_detail/shore_band`, `Vfx.water_ring…` çoğu
kusuru karşılıyor. Envanterde birden çok paketin isteyeceği ama bugün olmayan yardımcılar aşağıda. Kural Bölüm 2'deki
gibi: mevcut imzalar değişmez, yalnız YENİ statik işlev / isteğe bağlı parametre eklenir; her işlevin başında kullanım
notu. Dosya sahipliği: P0 bitene kadar `stage.gd`, `nature.gd`, `vfx.gd`, `npc/person.gd`, `npc/rig.gd`,
`npc/oar_grip.gd`, `combat/cannon_crew.gd`, `level/bogaz.gd` (yalnız `rope`/`make_rope`) P0'ındır; sonra
paketler bunları yalnız ÇAĞIRIR (bogaz.gd'nin geri kalanı P3'e geçer).

Öncelik sırası (kaç paketin istediği / oyuncunun gördüğü süre):

## 1. `Person.give_tool(kind)` ve Soldier karşılığı: iş pozuna alet (A; 14 yer, 6 paket)
Bugün `Person.set_activity("hammer"|"chop"|"stir"|"paint")` yalnız kolu sallıyor (person.gd:558 aleti yalnız
write/whittle/read_ground'a veriyor). Slipway bunu kendi `_job_*` işlevleriyle (slipway.gd:1037-1125) çözdü; o ortak değil.
```gdscript
## person.gd — set_activity'nin sonunda otomatik çağrılır (tool_auto := true); elle de çağrılabilir.
## kind: "hammer" (tokmak), "mallet", "axe", "pickaxe", "shovel", "knife", "ladle" (kepçe), "brush" (fırça),
##       "rammer" (top tokmağı), "bucket", "torch". Alet sağ dirseğin "hand" noktasına bağlanır (el kemiği), _tools'a girer.
func give_tool(kind: String, hand := "r") -> Node3D
## soldier.gd — aynı alet kataloğu (Soldier'ın rig.elbow_r'i)
func give_tool(kind: String, hand := "r") -> Node3D
## items.gd (ya da yeni scripts/level/tools.gd) — modeller tek yerde: static func tool_model(kind) -> Node3D
```
Etkinlik→varsayılan alet: hammer→hammer, chop→axe, stir→ladle, paint→brush. Kazmacılar için `set_activity("chop")` +
`give_tool("pickaxe")`. Kabul: `tests/_tmp` sondasında her etkinlikte aletin ucu ile el kemiği arası < 0,05 m.

## 2. `Jobs` (iş istasyonu) — slipway `_job_*`'ın ortak hâli (A/C/D; 6 paket)
Yol/meydan kenarına "işiyle birlikte" figür koymak: figür + aleti + işlenen nesne (kütük, takoz, kazan, çuval,
tezgâh) + yere talaş/çamur. Ordugâh, şantiye (33o, 22o, 32o, 34o), Galata, 18 köprü için.
```gdscript
## scripts/level/jobs.gd (YENİ, class_name Jobs). Canlı (Person/Soldier, kendi rig döngüsü, fazı rastgele) ya da
## ucuz (slipway._fig gibi donuk çoklu ağ) seçilebilir. ground: Callable(x,z)->y (eğime oturur, Stage.plant_feet).
static func station(parent: Node3D, kind: String, at: Vector3, face: Vector3, ground: Callable, seed := 0, live := true) -> Node3D
## kind: "hammer_log", "chop_log", "stir_pot", "carry_wood", "carry_sack", "saw", "dig", "sharpen", "drink", "report"
static func scatter(parent: Node3D, area: Rect2, kinds: Array, n: int, ground: Callable, avoid: Array[Rect2], seed := 0) -> Array
```
Slipway'deki `_job_*` sonradan bunu çağıracak biçime çevrilir (P0'da değil; chapter2/slipway başka ajanda).

## 3. Kürek-su teması: `OarGrip` içinde pala dalışı (E; 6 bölüm: 17, 19, 19o, 29o, 33o, 38o + sea_battle)
`OarGrip._process` palayı suya sokup çıkarıyor ama hiç su efekti yok.
```gdscript
## oar_grip.gd — water_y zaten var (attach/phantom). Pala ucu su_y'yi aşağı doğru geçtiği karede:
##   Vfx.water_ring(scene, tip, water_y, 0.35, 1.1) + Vfx.water_drops(scene, tip, water_y, 4); çekişte palanın ardında
##   küçük köpük; çıkarken damla. Kamera 40 m'den uzaksa atlanır (bütçe). Sesi: "oar_splash" (yoksa "splash" -18 dB).
var splash := true          # yeni alan; false ile kapatılır
```

## 4. `Vfx.wake(tekne, su_y, …)`: kayık/kadırga izi (E; 7 bölüm)
Bölüm 2'de kıç izi slipway'in kayığına elle yazıldı. Ortak hâli:
```gdscript
## vfx.gd — teknenin hızından (global_position farkı) kıçta aralıklı water_ring, pruvada ince köpük şeridi,
## yanlarda V. Tekne durunca seyrek halkalar (yalpa). Düğüm döndürür (tekneyle silinir).
static func wake(boat: Node3D, water_y: float, stern := Vector3(0, 0, -2), bow := Vector3(0, 0, 2), width := 1.2) -> Node3D
```

## 5. `Vfx.water_entry(ebeveyn, nokta, su_y, büyüklük)` ve `water_exit(kişi, ...)` (E; 5 bölüm)
Suya giriş/çıkış anlarının hepsi aynı 4-5 çağrıyı istiyor (Bölüm 2 chapter2.gd:399, 417, 480'de elle yazıldı).
```gdscript
## vfx.gd — giriş: splash + iki genişleyen water_ring + water_drops + Audio "splash"; büyüklük kütleye göre (fıçı, insan, gülle).
static func water_entry(parent: Node, at: Vector3, water_y: float, size := 1.0) -> void
## çıkış: kişiye Vfx.drip(sn), ayak altına wet_mark birikinti, sonraki adımlarda wet_mark izleri (Stage.walk_on_ground ile)
static func water_exit(who: Node3D, ground: Callable, seconds := 6.0) -> void
```
Kullanılacak yerler: 4:_fell, 17:1118/_haul_back, 18:_swim_back ve fıçı, 35o:570, 33o:261, 17o isabet, 18b gülle.

## 6. Top doldurma tutuşu: `CannonCrew` tayfası (A/C; 17o, 20o, 28o, 32o, 18b, 34o)
cannon_crew.gd oyuncunun adımlarını (powder, wad, ball, ram, aim) yönetiyor; NPC topçular yanında boş duruyor.
```gdscript
## cannon_crew.gd — isteğe bağlı yardımcı tayfa: her adımda bir topçu ilgili aleti alır (barut kepçesi, tapa, gülle
## iki elle, tokmak), Stage.grip ile namluya/aletin sapına; oyuncu yaparken tayfa ötekini hazırlar (gülleyi getirir).
func add_crew(men: Array[Node3D], ground: Callable) -> void
```
Ayrıca durağan bataryalar için (yalnız görüntü): `Jobs.station(..., "load_cannon")`.

## 7. Merdiven/sırık/kiriş tutuşu: `Player.hold_both(sol, sağ)` (F/G; 22o, 26, 30, 31o, 35o, 38o)
`player.free_hold` tek (sol) eli bir noktaya koyuyor; sağ elde eşya kalıyor (38o "merdiveni tut", 28o çekme,
35o fren ipi). İki el + eşyanın cebe girmesi tek çağrıda:
```gdscript
## player.gd — iki el kameranın yerelinde iki noktada; eldeki eşya ve kumanda cebe (stow_hands sayacına girer).
## INF/INF ile bırakılır. Dünya düğümü verilirse (merdiven sırığı, halat) noktalar her karede o düğümden okunur.
func hold_both(left: Vector3, right: Vector3, target: Node3D = null) -> void
```
Not: tırmanışta elde eşya (eski karelerde 5 bölüm) `_sync_busy_hands` ile büyük olasılıkla düzeldi; P0 bunu
yeni karede doğrular (26o, 38o).

## 8. `Bogaz.rope` → `Stage.rope` köprüsü (A; 22o, 33o, 34o, 35o: 22 çağrı)
`Bogaz.rope(node, a, b)` düz silindir. İmza aynı kalarak içeriği Stage'in burgulu, sarkan halatına yönlendirmek
bütün bu yerleri tek değişiklikle düzeltir:
```gdscript
## bogaz.gd — make_rope bir "halat düğümü" döndürmeye devam eder (MeshInstance3D); rope(node,a,b, sag := 0.04)
## Stage.sag_points + Stage.rope_mesh ile ağı yeniden kurar (noktalar değişmezse kurmaz). Zincir rengi (koyu) için
## halka deseni: Stage.rope(..., "chain") — YENİ isteğe bağlı tür parametresi.
static func rope(node: MeshInstance3D, a: Vector3, b: Vector3, sag := 0.04) -> void
```
Aynı köprü `chapter31o._rope_between`, `chapter39o._rope_between`, `chapter24o._rope`, `chapter37o` (817-876),
`training_yard.gd:94`, `chapter28o.gd:174` için de kullanılabilir (onlar kendi paketlerinde değiştirilir).

## 9. Zincir görünümü: `Stage.chain(ebeveyn, a, b, sarkma, halka_r)` (A; 19, 19o, 34o, 35o öküz zinciri)
`Stage.rope` koyu renkle zincir yerine kullanılıyor; yakın çekimde (34o makara zinciri, Haliç zinciri) halka halka
görünmeli. Halkalar tek MultiMesh.

## 10. `Nature.ground_detail` için yeni türler (D; 5 paket)
Bugünkü 14 tür kıyı/kızak odaklı. Eksik: `snow_tracks` (34o kar izi), `cobble_wear` (petek taşta aşınma/çamur, 20o,
28o, 33o), `straw` (ordugâh samanı, ahır), `ash` (ateş başı kül/kömür halkası: 11, 24o, 36b), `arrows` (yere saplı
kırık oklar, sur önleri), `wheel_ruts` (tekerlek izi: 35o, ordugâh yolu). İmza aynı: tür adı yeni.
Ayrıca `Nature.quay_band(ebeveyn, a, b, su_y)`: dikey rıhtım taşının dibinde köpük + yosun (Galata 10g/27, Haliç
surları 4b/17o, Petrion 38o) — `shore_band` eğimli kumsal içindir.

## 11. Kalabalık kıpırtısı: `Crowd.idle_vary(kişiler)` (C; 10, 23, 25, 27, 29, 26o)
Donuk sıralar için tek çağrı: her kişiye rastgele faz ve sıklıkta ağırlık değiştirme, baş çevirme, kısa emote
(nod, cross_self, whisper), en yakın olaya (look_target) yarı gecikmeli dönüş. Rig'de zaten var olan emote'ları
zamanlar; PoseCrew'a benzer ama canlı Person/Soldier için.

## Kabul (P0)
- Her yeni işlev için `tests/_tmp` sondası (Bölüm 2'deki `c2_grip_check` gibi): alet ucu-el, kürek pala-su halkası
  sayısı, wake halka sayısı, water_entry efekt sayısı ölçülür.
- `tests/run_tests.sh` tam koşu RUNOK (özellikle `--chapter=2` varyantları: slipway bu dosyaları kullanıyor).
- Perf: `tests/perf` ölçümünde (Bölüm 2, 17, 29o) çizim çağrısı +%5'i geçmez (ground_detail tek çoklu ağ/tür kuralı).
