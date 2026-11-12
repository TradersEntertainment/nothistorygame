# Düzeltme turu: P3 deniz savaşları ve Boğaz şantiyesi (29, 29o, 33o, 38o) — GELİŞTİRİCİ

Önce `docs/_ajan/gorev/_ortak2.md` dosyasını oku ve uy. Dalın: `wip/duzeltme-p3`. Kanıt klasörün: `docs/_kanit_dp3/`.
Bağımsız denetçinin raporu: `docs/_ajan/denetim/p3.md` (tamamını oku). Hükmü: "küçük düzeltmelerle kabul"; 6. bölümdeki
yedi ZORUNLU madde bağlayıcı. Paket tanımı: `docs/_ajan/paketler.md` "P3".

Düzenleyebileceğin dosyalar: `scripts/level/sea_battle.gd`, `scripts/chapter29.gd`, `scripts/chapter29o.gd`,
`scripts/chapter33o.gd`, `scripts/chapter38o.gd`. (`bogaz.gd` yalnız ekleme gerekiyorsa; `petrion.gd`, `horn.gd`,
`ladder.gd`, oyuncu ve ortak dosyalar yok.)

## Zorunlu maddeler (denetçinin sırasıyla)
1. **38o merdiven tutma kadrajı** (`_brace`, `_brace_look`, `BRACE_AT`, `BRACE_LOOK`, `eye_height`): iki el dikmede
   kalırken tırmanan tayfa baştan ayağa ve çatalın geldiği mazgal kadrajda; çatal gelince çatal görünüyor. Oyuncudan alınan
   bakış denetimi sürekli 45 sn olmasın: bakışı yalnız girişte yumuşak çevir (≤ 1 sn), sonra oyuncu serbestçe bakabilsin
   (eller dikmede kalır) ya da serbest bakışı dar bir koniyle sınırla. Eller dikmeyi bırakınca sağ ele telsiz geri
   belirmesin (tutuş bitene kadar el eşyası cepte).
2. **38o `world.visible = false` kaldır** (`_ladder_grip`): bütün dünya düğümü gizlenmeyecek. Maliyet gerekiyorsa yalnız
   görünmeyen uzak katmanı, ve her çıkış yolunda geri açıldığı güvenceyle. RINFO'yu evre evre ver.
3. **29 kanca ipi oyuncunun durduğu yerden görünsün** (`_spawn_hook`, `sea_battle.gd:hook_line`): ip küpeştenin üstünden
   içeriye de gözüksün (kanca küpeşteye oturuyor, ip dışarı sarkıyor; içeriden ipin küpeşte üstündeki düğümü ve gergin
   parçası seçilsin). Oynanış karesinde kanıt.
4. **29o ip ağı her karede kurulmasın** (`_climb/on_rope`, `_fly_hook`, `sea_battle.gd:cut_hook`): uçlar 5 mm'den az
   oynadıysa atla (33o `_guide_lay` ve 38o `_rope_hands`teki koruma gibi). Düşüş anındaki yakın krem şerit: ip kameradan
   ≥ 25 cm önde ve ince kesit.
5. **29 seren/sarılı yelken "mızrak"** (`sea_battle.gd:war_galley`): bordadan öne fırlayan ~7 m konik demet kısalsın ya
   da serene yaslansın; `D29_C_WIND` anında "mızrak" kalmasın.
6. **29 halat çeken tayfa** (`_crew_jobs`): eller halatta ve sırttan görünür; ipin ucu bacağın arkasında bitmesin
   (bir babaya/makaraya bağlansın).
7. **38o `hooks_bad` `VISAUDIT personhidden D38O_S_03`:** aynı koşuyu ÖNCE ve SONRA onar kez çalıştır, say; SONRA'da
   fazlaysa kök nedeni (`_brace` durma yeri?) bul ve düzelt.

## Kanıtsız kalanlar (ya kanıtla ya dürüstçe yaz)
33o ustaların aletleri, 33o/38o gülle-ok-yüzücü halkaları, 29o pala-su teması, 29 taş atma döngüsü: oynanış karesinde
seçilir kıl ya da "DURUYOR, KANITSIZ" yaz; görünmeyen ağ bırakma.

## Testler
29 (2), 29o (2), 33o (3), 38o (4; `hooks_bad` ×10), 28o, 34o, 19. RINFO: 29o `gun`, 38o `ladder` ve `explore`.
