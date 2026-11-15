# TAŞIMA-4 durum

Dal `wip/ist2-tasima4`, taban `wip/ist2-tasima3` 6f92f921.

## Biten
- Kurulum: Godot 4.4.1 (`~/is/godot/godot`), içe aktarma.
- Sondalar yazıldı: `tests/_ist/tasima4_kesit.gd` (gedik ekseni kesiti), `tests/_ist/tasima4_zemin.tscn` (düşen düellocunun konabileceği görünen zemin ızgarası).
- Çuvallar (`GedikOnarim._cuval`, `_cuval_duvar`): ilk sürüm yazıldı, henüz koşulmadı.

## Süren
- §1 Bölüm 20 düello süresi: ŞİMDİ ölçümü (×3 / ×2) sırada.
- §3 ceset düşmesi: kök neden adayı `Duelist._fall_tick` (görünmez/basılamaz yüzeye çarpınca konmuyor, 4 sn düşüp gizleniyor: −128 m = ½·16·4²); sonda ile doğrulanacak.

## Sıradaki
- §1 kaldıraçlar (yaklaşma yolu, kademeli katılma), §2 Bölüm 0, §3 kalanlar, §4 22/22o.
