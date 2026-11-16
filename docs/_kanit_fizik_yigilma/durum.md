# Fizik-yığılma: durum

- [x] Dal `wip/fizik-yigilma` (taban `wip/fizik-ayak` 2ec2d1db), Godot 4.4.1
- [x] `scripts/npc/yigilma.gd`: Verlet bez bebek, YIGILMAAUDIT, YIGPERF, kanıt kareleri (`--yig-kare`)
- [x] Kancalar: Duelist (ölüm, bitirici, kenardan düşüş, tekmeyle serilip kalkma), Assault merdiven düşüşü, Soldier/Person.shot, Rig "fall" savrulma
- [x] Bütçe: 30 Hz + ara değer, ışın bütçesi, kare başı 1,2 ms, sınır 8, LOD
- [x] Ayak: dik molozda topuk-burun, yokuş aşağı koşuda kalça
- [x] ÖNCE|SONRA 20 koşu (YIGILMAAUDIT 94 → 15; son kodla 4 bölüm 35 → 4), ek 7 bölüm PASS, kare süresi
- [x] Kareler (deney sahnesi 9 tür, Bölüm 0 donma), rapor `rapor.md`, yöntem `yontem.md`
- Kalan (rapor "hâlâ kötü"): hedef 0'a inmeyen 15 satır, kısa karelerde bütçe %6, oyun içi kareler
