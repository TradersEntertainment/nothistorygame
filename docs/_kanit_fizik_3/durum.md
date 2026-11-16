# Fizik-3 durum

Dal `wip/fizik-3` (taban `wip/fizik-taban3` 758502cd).

- [x] 1. 37o eski set gerileme: kök neden bulundu ve düzeltildi (iki neden; `gunluk/m1_37o_eskisur_kok_neden.txt`).
  - (a) "haul" pozunda Soldier `rig.update`'i çağırmıyor: ayak IK'nın son gövde inişi (pel) donuk kalıyor,
    `Stage.plant_feet` kökü bu bayat inişe göre kaydırıyor → `Ayak.bayatsa_birak` (Rig.extremities'in başında).
  - (b) duruşta `Stage.plant_feet` (kök) ile IK kalçası/dizleri aynı serbestliği sürüyor → kök kayıyor → kökü dışarıdan
    dikine sürülen kişide IK kapalı (`ayak_kok_dis`).
  - Ölçüm: eski set 37o ×3, =trespass ×3 temiz; =lose 8/9 PASS, 1 FAIL (düello kazanıldı: rastlantı — oyunun RNG'si
    tohumlanmıyor; tabanda da `cuts` 2–32 arası değişiyor; IK ve kumaş kapalıyken de aynı dağılım). Yeni set 37o ×3,
    =lose ×3 temiz; =trespass sürüyor. Eski set 20/20o/22/22o/26/0/25 sürüyor.
- [~] 2. Giysi kumaşı: gölgelendirici (`assets/shaders/giysi_kumas*`) + `scripts/npc/kumas.gd` + CharKit.bake UV işareti;
  Person (kaftan, etek, zırh etekleri, yen, pelerin, yatırtma, püskül, kaftan süsleri), Soldier (bel eteği, yatırtma).
  Deney sahnesi `tests/_fizik/fizik3_kumas_sahne.tscn`. Sırada: kareler, oyun içi kareler, bütçe.
- [~] 3. `Stage.grip_hold`: tutuş duruşunda ayak IK izdüşümü (kod yazıldı, ölçülmedi). Yığılma kalanları: sırada.

Son güncelleme: madde 1 ölçümleri, kumaş deney sahnesi kareleri (ÖNCE/SONRA).
