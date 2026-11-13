# Bölüm 26 `hold_box`: ara sıra düşen görsel denetim (VISAUDIT) raporu

Komut (her koşu): `timeout 300 godot --headless --max-fps 20 --path . -- --chapter=26 --autotest=hold_box`
Godot 4.4.1.stable.official (linux x86_64, `49a5bc7b6`), 4 çekirdek, aynı anda 4–5 süreç. Kopyalar `~/is/` altında
`git worktree` ile açıldı ve her biri bir kez `--import` edildi.

## Kısaca

- Suç tırmanma (`c7256660`) ya da bakış (`482c5acf`) birleşmesinde **değil**. Aynı satırlar tırmanma birleşmesinden
  önceki kayıtta (`4fdb4db8`) ve yayından hemen sonraki ilk kayıtta (`646b4702`) da çıkıyor.
- Kök neden eski bir kusur, yayındaki sürümde de var (günlükle gösterildi). Bölüm 26'nın Büro alarmı
  (`scripts/chapter26.gd:835-839`) bölümün **bütün** çocuklarını gizliyor ama zamanlayıcılar sürüyor. Bu sırada
  yedek bölüğü kımıldatan `reserve_loop.gd` ve surdaki mızraklıyı yürüten `spear_loop.gd` adım atmaya devam ediyor.
  Bu ikisi yalnız kendi `visible` bayrağına bakıyor, ana düğümün gizli olduğunu görmüyor. Boş yer denetimi
  `Unclip.crowded` görünmeyen kişiyi saymadığı için gizli sahnede herkesi boş sanıyor ve adım yanındakinin içinde
  bitiyor. Sahne görünür olunca iki kişi iç içe kalıyor.
- Düzeltme 2 dosyada 4 satır (artı yorum): gizliyken adım yok. Denetim, eşik, test, süre, sayaç değişmedi.
- Kanıt: düzeltilmiş kodda `hold_box` ×40 → VISAUDIT 0, 40/40 `AUTOTEST PASS`.

## 1. İkiye bölme

Her satırda `hold_box` koşuları. "overlap" = iç içe kişiler (bu işin konusu). "sunk/insolid" = gedik molozuna gömülü
ya da duvarın içinde **düellocu**: bu ikisi ayrı ve eski bir kararsızlık, yayındaki sürümde de çıkıyor (aşağıda).

| kayıt | ne | koşu | VISAUDIT'li | overlap | sunk / insolid |
|---|---|---|---|---|---|
| `e551de84` | origin/main = v0.99.118 (yayındaki) | 24 | 1 | **0** | 1 / 0 |
| `e551de84` + günlük | aynı, geçici günlükle (2 tur) | 12 | 2 | **0** | 1 / 1 |
| `646b4702` | main'den sonraki ilk kayıt (P6 kara surları `_ground_wear`) | 23 | 2 | **2** | 0 / 0 |
| `b31cdf77` | P6 kara surları 2. ara durum | 23 | 1 | 0 | 1 / 0 |
| `4fdb4db8` | tırmanma birleşmesinden hemen önce | 24 | 4 | **3** | 1 / 0 |
| `c7256660` | tırmanma birleşmesi | 24 | 4 | **3** | 1 / 0 |
| `482c5acf` | bakış birleşmesi | 24 | 2 | **1** | 1 / 0 |
| `2e36e8b7` + günlük | HEAD (3 tur, geçici günlükle) | 23 | 2 | **2** | 0 / 0 |
| `2e36e8b7` + günlük | HEAD (sur adımı günlüğüyle) | 8 | 2 | **2** | 0 / 0 |

Overlap toplamı: yayındaki sürümde 0/36, sonraki bütün kayıtlarda 13/149 (~%9). Tırmanma birleşmesinden önce ve sonra
oran aynı: 3/24 ve 3/24. Bakış birleşmesi de oranı artırmıyor: 1/24. Ayrım main ile ilk sonraki kayıt (`646b4702`, 2/23)
arasında, ama orada da sayı küçük (0/36'ya karşı ~%9 için p≈0,04). Aşağıdaki günlük gösteriyor ki yayındaki sürümde de
aynı kör adımlar atılıyor (6 koşuda 25 gizli adım, en yakın 0,47 m). Kusur yeni değil. `646b4702`'nin oranı neden
artırdığını kanıtla bulamadım: o kayıt kara surlarına çarpışmasız zemin ayrıntısı ekliyor (`land_walls.gd`
`_ground_wear`, kendi tohumlu RNG'siyle) ve oynanış yolunu değiştirmiyor. Bu yüzden "bu satır suçlu" diye
gösterebileceğim bir değişiklik yok.

## 2. Kök neden (günlükle)

Geçici günlükler yalnız `~/is/w_dbg` ve `~/is/w_main` kopyalarındaydı, depoya girmedi:
`chapter26.gd`'de gizleme/gösterme karesi (`BUREAUHIDE/BUREAUSHOW`), gizliyken atılan adım ve en yakın kişiye uzaklık
(`RSTEPHIDDEN` reserve_loop, `SPEARHIDDEN` spear_loop), kişi başına konum geçmişi ve itmeler (`DBGHIST`).

**Yedek bölük (Garrison.squad + reserve_loop), HEAD:**
```
BUREAUHIDE f1035 n=128
RSTEPHIDDEN f1036 /root/Chapter26/@Node3D@35443/@Node3D@36001 near=0.96
RSTEPHIDDEN f1039 /root/Chapter26/Squad/@Node3D@34259 near=0.32
BUREAUSHOW f1044
VISAUDIT overlap scene=chapter26.tscn a=Squad b=Squad at=(-19.4, 0.0, 8.2) src=Chapter26>Squad>Person|Chapter26>Squad>Person
```
```
BUREAUHIDE f1044 n=122
RSTEPHIDDEN f1048 /root/Chapter26/@Node3D@35443/@Node3D@36265 near=0.34
BUREAUSHOW f1053
VISAUDIT overlap scene=chapter26.tscn a=@Node3D@35443 b=@Node3D@35443 at=(23.2, 0.0, 7.9) src=Chapter26>Node3D>Person|Chapter26>Node3D>Person
```
(`@Node3D@35443` ikinci bölüğün kökü: iki bölük de "Squad" adını istiyor, ikincisi adsız kalıyor.)
Adım anındaki denetim: `RSTEPNEAR ... near=.../@Node3D@35316 d=0.66 vis=false lying=false crowded=false ts=3.0`. Komşu
`crowded` için görünmez, o yüzden sayılmıyor.

**Surdaki mızraklı (Garrison.land_walls + spear_loop), HEAD:**
```
BUREAUHIDE f996 n=122
SPEARHIDDEN f1002 /root/Chapter26/Garrison/@Node3D@31862 to=(9.7, 8.0, 14.7) near=0.33 crowded=false
BUREAUSHOW f1005
VISAUDIT overlap scene=chapter26.tscn a=Garrison b=@Node3D@33134 at=(9.7, 8.0, 14.7) src=Chapter26>Garrison>Person|Chapter26>WallFight>Node3D>Person
```
`b` kazanın devirme kolundaki adam: `wall_fight.gd:65`, kazan `(8.6, 8, 15)`, adam `(9.4, 8, 14.55)`. Mızraklı
evinden ±1 m yürüyor (`spear_loop.gd:78`). Yöneticinin listesindeki `a=Garrison b=Garrison at=(11.6, 8.0, 14.7)` aynı
yoldan geliyor: iki nöbetçi 1,8–2,9 m arayla duruyor ve ikisi de 1'er metre birbirine yürüyebiliyor.

**Yayındaki sürümde de aynı (main + günlük, 6 koşu):** her koşuda Büro penceresinde 1–8 gizli adım var, toplam 25,
uzaklıklar 0,47–1,34 m. Örnek:
```
BUREAUHIDE f1012 n=120
RSTEPHIDDEN f1014 /root/Chapter26/Squad/@Node3D@34079
RSTEPHIDDEN f1014 /root/Chapter26/Squad/@Node3D@34211
RSTEPHIDDEN f1017 /root/Chapter26/Squad/@Node3D@33693
RSTEPHIDDEN f1018 /root/Chapter26/Squad/@Node3D@33023
BUREAUSHOW f1021
```
Gizleme 9 kare sürüyor (otomatik testte `time_scale` 3, yaklaşık 1,3 oyun saniyesi). Her adım 0,35 m'nin altında
bitmiyor, o yüzden olay seyrek.

İlgili yerler:
- `scripts/chapter26.gd:835-839`: Büro alarmında bölümün bütün Node3D çocukları gizleniyor ("zamanlayıcıları sürer").
  Kendisi doğru: gizleme kasıtlı ve ses/görüntü için gerekli.
- `scripts/npc/reserve_loop.gd:29` / `scripts/npc/spear_loop.gd:22`: yalnız `p.visible`'a bakıyor, gizli ana düğümü
  görmüyor.
- `scripts/npc/unclip.gd:253` (`crowded`): `not o.is_visible_in_tree()` olanı atlıyor. Oyun içinde doğru: görünmeyen
  kişi engel değil. Ama gizli sahnede herkes "yok" sayılıyor.

Elenen olasılıklar (günlükle):
- Tırmanma: merdivendeki ya da mazgala geçen kişi iç içe çiftlerin hiçbirinde yok. Çiftler hep bölük üyesi ya da
  nöbetçi.
- `discount_move` / yürüme eşiği / `_walk_face`: itmeler (`_clear_way`) çiftleri oluşturmuyor. Konum geçmişinde son
  hareket hep `RSTEP` ya da `SPEAR` adımı.
- Melee rally: bölük üyelerinde tek tek gizlenme (`VISIBILITY_CHANGED`, `self=false`) görülmedi. Bölük gizlenmeleri hep
  ana düğümden geliyor (`parvis=false`).
- Aynı anda adım atan iki komşu (`RSTEPRACE`): görüldü ama hedefler en yakın 0,54 m (≥0,35). Çift oluşturmuyor,
  dokunulmadı.

## 3. Düzeltme

- `scripts/npc/reserve_loop.gd:124-127` (`_step`): `if not p.is_visible_in_tree() or <ışın> or Unclip.crowded(...)`.
  Gizliyken yerinde adım atılmıyor.
- `scripts/npc/spear_loop.gd:87-90` (`_next`, "shift" dalı): `if q and p.is_visible_in_tree() and <ışın> and not
  Unclip.crowded(...)`. Gizliyken sur boyunca yürünmüyor.

Neden burada: kusur adımı atanın "gizli sahnede kimseyi göremediği" hâlde adım atması. Görünürken her şey önceki gibi
çalışıyor: bakınma, çökme, nara, dürtme, taş atma ve görünürken atılan adımlar aynı. Büro gizlemesi, denetim
(`hud.gd`), `Unclip.crowded` ve eşikler değişmedi. Tırmanma animasyonuna ve bakış koduna dokunulmadı. Denge, süre,
sayaç, replik ve kalabalık sayısı değişmedi. Gizliyken atlanan adım zaten görünmüyordu.

## 4. Kanıt (düzeltilmiş kod, hepsi `--max-fps 20`)

| koşu | sayı | `AUTOTEST PASS` | VISAUDIT | SCRIPT ERROR / WALKTHRU / HELDAUDIT / WARN_* / CLIMBAUDIT / ARMAUDIT |
|---|---|---|---|---|
| 26 `hold_box` | 40 | 40 | **0** | 0 |
| 26 bütün çeşitler (14) ×3 | 42 | 42 | 0 | `WALKTHRU` 1 (lighter #3), `CLIMBAUDIT` 1 koşu (hold_lose #3): ikisi de düzeltmesiz kodda var, aşağıda |
| 26 `hold_lose` ek | 6 | 6 | 0 | `CLIMBAUDIT` 1, `ARMAUDIT` 2: düzeltmesiz `482c5acf` ×6'da da aynı (1 ve 2) |
| 26o, 20, 20o, 30, 30o, 38o, 42b, 29o, 33o varsayılan ×3 | 27 | 27 | 0 | 0 |
| `tests/parse_check.tscn` | 1 | `PARSECHECK PASS scripts=251` | – | – |

26 çeşitleri: "", nophoto, hold, hold_box, hold23, hold3, warn_notrust, hold_lose, lighter, isidore, kasim, candle,
council_ok, council_bad. Bütün koşular `rc=0`.

Son satırlardan örnekler:
```
AUTOTEST PASS chapter=26 variant=hold_box outcome=26.3 water=3 repaired=3 cleared=0 world=W10 gun=3/4 gunner=5/5   (×40'ın 40.'sı)
AUTOTEST PASS chapter=26 variant= outcome=26.1 water=3 repaired=3 cleared=2 world= gun=3/4 gunner=2/2
AUTOTEST PASS chapter=26 variant=hold_lose outcome=26.1 water=3 repaired=3 cleared=2 world=W1 gun=3/4 gunner=0/1
AUTOTEST PASS chapter=26o variant= outcome=26.1 water=3 ladders=3 gun=3/4 stones=1/1 gunner=5/5 oil=1/1 turgut=no
AUTOTEST PASS chapter=20 variant= outcome=20.1 repair=10 knocks=0 arrows=true gun=3/4 gunner=3/3 niko=0
AUTOTEST PASS chapter=20o variant= outcome=20O.1 hits=3 cracks=0 gun=3/4 gunner=1/2 duel=true bed=
AUTOTEST PASS chapter=30 variant= outcome=30.1 gun=3/4 pushed=2 boarders=0 duel=true rifle=4
AUTOTEST PASS chapter=30o variant= outcome=30O.1 stones=4/4 gunner=3/3 tower=true fell=false guards=10 pokes=0 flee=ride pushed=true
AUTOTEST PASS chapter=38o variant= outcome=38O.1 oars=10 arrows=0 forks=3/3 fire=true pulled=true oil=false snaps=0 splashes=0 explored=14.6
AUTOTEST PASS chapter=42 variant= outcome=42.1 dir=4 bumps=0 blocks=3 parries=2 kick=true down=true fins=thrust,slash,ground spar=3/0 pushed
AUTOTEST PASS chapter=29o variant= outcome=29O.1 hooks=4/5 gun=4/4
AUTOTEST PASS chapter=33o variant= outcome=33O.1 stones=4 hits=0 falls=0 water=0 hidden=true gift=refuse warn=ok big=true
```

### Düzeltmeden bağımsız iki satır

- `WALKTHRU scene=chapter26.tscn who=@Node3D@43064 at=(31.5, 1.0, 5.0) by=@Node3D@177/@StaticBody3D@237 pos=(32.0, 1.5, 2.2)`
  (lighter #3). Düzeltmesiz `4fdb4db8` `hold_box` koşusunda da aynısı çıkıyor:
  `WALKTHRU ... who=@Node3D@43065 at=(32.6, 1.0, 4.9) by=@Node3D@177/@StaticBody3D@237 pos=(32.0, 1.5, 2.2)`.
  Peribolosta koşan biri (`Chapter26>Node3D>Person`, sur içi kalabalık; günlükte bölüklerin içinden 3 m/sn hızla
  geçip itiyor), x≈32'deki bir sur parçasının içinden geçiyor. Eski ve ayrı bir kusur.
- `CLIMBAUDIT chapter26 @Node3D@48700 hand_l=0.065` (hold_lose #3, 51 satır, tek kişi): kaybedilen dalgada
  (`WAVERUNNER ... won=false`) merdivende kalan tırmananın sol eli basamaktan 6,5 cm uzakta. Tırmanma animasyonuna ait
  (`climb_anim.gd`, `wip/tirmanma`). Benim değişikliğim tırmanmaya dokunmuyor. Düzeltmesiz bakış kaydında da aynısı
  çıkıyor: `482c5acf` `hold_lose` ×6 → 1 koşuda `CLIMBAUDIT chapter26 @Node3D@48196 hand_r=0.067` (49 satır, tek kişi).
  Düzeltilmiş kodda ek `hold_lose` ×6 → yine 1 koşu. Bu, 0.99.119'a tırmanmayla gelen ayrı bir kararsızlık
  (yayındaki sürümde ortak tırmanma animasyonu yok). Kaybedilen dalgada merdivende kalan tırmananın eli basamaktan
  kayıyor. Ayrı iş.

### ARMAUDIT (`hold_lose`)

| kod | `hold_lose` koşu | ARMAUDIT'li |
|---|---|---|
| yayındaki `e551de84` | 3 | 1 (`ARMAUDIT unarmed scene=chapter26.tscn foe_dist=2.1 duel_active=false`) |
| düzeltmesiz `482c5acf` | 6 | 2 |
| düzeltilmiş | 3 + 6 = 9 | 0 + 2 = 2 |

Oran üçünde de aynı (~1/3): eski kararsızlık, düzeltmeyle ilgisi yok, ayrı bakılmadı. Satır, oyuncunun silahsızken
2 m yakında düşman olduğunu ve düellonun açık olmadığını söylüyor. Kaybedilen dalga (`won=false`) ile düellonun
kapanması arasındaki geçişte görülüyor.

## 5. Dokunmadığım ama gördüğüm sorunlar

1. **Gedikteki düellocu molozun içinde (`VISAUDIT sunk`, bazen `insolid`)**: yayındaki sürümde de var (main 24'te 1
   sunk; günlüklü main 12'de 1 sunk + 1 insolid). Örnek: `sunk ... src=Chapter26>Duelist>Person feet=(5.4, 0.8, 13.0)
   floor=1.27 shape=(11.0, 0.55, 5.6)@(0.0, 1.0, 15.6)`. Düellocunun ayağı moloz katmanının görünen üstünden
   0,1–0,5 m aşağıda. Bu ×40'ta çıkmadı ama oran ~%4. Ayrı iş.
2. **Aynı desen başka yerlerde de olabilir**: "gizli ama zamanlayıcısı süren sahne + yalnız `visible`'a bakıp
   `Unclip.crowded` ile yer seçen döngü". Bölüm 26'da yalnız bu ikisi adım atıyor. Bölüm 22o da `reserve_loop`
   kullanıyor, bu düzeltmeden o da yararlanır.
3. `RSTEPRACE`: aynı bölükten iki kişi 0,7 sn içinde yakın hedeflere adım atabiliyor. Görülen en yakın 0,54 m, yani
   iç içe değil. Dokunulmadı.
4. Bölüm 26'da iki yedek bölük de "Squad" adını istiyor, ikincisi `@Node3D@…` adıyla kalıyor. Denetim satırlarında
   kafa karıştırıyor, zararsız.
5. Denetçinin "hücumda iki asker aynı merdivende üst üste" ve 26o "yatay figür merdivenin önünden" notları bu `hold_box`
   kararsızlığıyla ilgili değil. Bu koşularda tırmanan hiçbir çiftte görünmedi.
