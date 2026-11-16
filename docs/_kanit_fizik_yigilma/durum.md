# Fizik-yığılma: durum

- [x] Dal `wip/fizik-yigilma` (taban `wip/fizik-ayak` 2ec2d1db), Godot 4.4.1 kuruldu, içe aktarma
- [x] `scripts/npc/yigilma.gd`: Verlet bez bebek (13 parçacık, eklem sınırları, boyun, zemin ızgarası + ışın bütçesi, sürtünme, uyku/donma, 30 Hz + ara değer)
- [x] YIGILMAAUDIT (yığılma bitince baş/gövde/el/ayak zemine uzaklığı; eski klip yolunda da `klip` etiketiyle)
- [x] Kancalar: Duelist (ölüm, bitirici, kenardan düşüş, tekmeyle yere serilip kalkma), Assault merdivenden düşen, tüfekle vurulan (Soldier/Person.shot), Rig "fall" savrulma duruşu (Bölüm 0 donma karesi)
- [x] Deney sahnesi `tests/_fizik/yigilma_sahne.tscn` + pafta aracı
- [ ] Bütçe: kare başı maliyet düşürülüyor (ilk ölçüm: 2 kişi 5 ms; hedef ≤ %5)
- [ ] ÖNCE|SONRA koşuları, kare süresi, kareler, rapor
