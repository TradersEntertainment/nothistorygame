# Düzeltme turu: P6 kara surları (20, 22, 22o, 26o, 36b, 37o) — GELİŞTİRİCİ

Önce `docs/_ajan/gorev/_ortak2.md` dosyasını oku ve uy. Dalın: `wip/duzeltme-p6`. Kanıt klasörün: `docs/_kanit_dp6/`.
Bağımsız denetçinin raporu: `docs/_ajan/denetim/p6.md` (tamamını oku). Hükmü: "küçük düzeltmelerle kabul".

Düzenleyebileceğin dosyalar: `scripts/chapter37o.gd`, `scripts/chapter26o.gd`, `scripts/chapter36b.gd`,
`scripts/level/land_walls.gd` (yalnız `_wear_props` ve yardımcıları), `scripts/combat/oil_hazard.gd` (yalnız 7. madde).

## Zorunlu maddeler
1. **37o RINFO:** ip çeken üç azabın çizim/üçgen yükünü azalt (uzaktakini sadeleştir ya da gölgesiz/tek ağ); `D37O_T_03`
   anında ve ön çekişte üçer örnek: çizim artmaz, üçgen ≤ +%8 (hedef ≤ +%5).
2. **37o azap yerleşimi:** `_haul_spots`: hiçbir azap kameraya 2,2 m'den yakın olmasın, kadrajın %15'inden fazlasını
   kaplamasın; `_floor_y` ayak izinden (±0,2 m) örneklensin, arkadaki azabın basamaktan taşan ayağı düzelsin; öndeki
   azabın kolu yana açılmasın (iki el ipte). Yan ve oyuncu gözünden kare.
3. **26o açılışta elde eşya:** bölümde eller iş görüyorsa `player.hands_free = true` (20/22o/36b/37o'daki gibi);
   değilse neden kaldığını raporda yaz.
4. **Görünmeyen ayrıntı (`land_walls.gd` sedye/kova/kırık merdiven):** oyuncunun yürüdüğü çizginin 2–3 m yanına,
   gerçek ölçüde ve seçilir biçimde koy ya da kaldır. Yürüme yolunu kapatmasın (`WALKTHRU` yok). 20, 22o, 26o, 36b
   oynanış karelerinde kanıt.
5. **36b kazıcı aletleri ve 37o ıska kancası:** oynanış karesinde kanıtla (kazıcıları oyuncunun yolundan görünür yere
   al; ıska için yalnız kare almak üzere geçici sonda kullan, sonra sök).

## Test kararsızlıkları (denetçi kök nedeni buldu; yayın derlemesini düşürebilir, düzelt)
6. **37o `lose` botu:** `chapter37o.gd:604` civarı `randf() < 0.5` yerine deterministik sayaç (denetçinin kod parçası).
   Yalnız `GameState.autotest and lose` yolunu değiştir; oyuncu için hiçbir şey değişmesin. Kabul: 40/40 PASS.
7. **26o `lose` yağ yarışı:** `oil_hazard.gd:86`: kazan o anda başkası tarafından dökülüyorsa da şerit canlı sayılsın
   (denetçinin kod parçası). Oyunda görünür davranış değişikliğini (varsa) raporda açıkça yaz. Kabul: 40/40 PASS.
8. `ARMAUDIT unarmed` (37o/26o `lose`): kök nedeni bul; kendi dosyalarındaysa düzelt, değilse ORTAK DOSYA ÖNERİSİ.

## Testler
20 (9 varyant), 22 (7), 22o (6), 26o (hepsi), 36b (2), 37o (hepsi), 26, 0, 21, 28o. RINFO: 37o, 20, 22o.
