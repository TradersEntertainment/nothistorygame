# TAŞIMA-4 durum

Dal `wip/ist2-tasima4`, taban `wip/ist2-tasima3` 6f92f921.

## Biten
- Kurulum: Godot 4.4.1 (`~/is/godot/godot`), içe aktarma.
- Sondalar yazıldı: `tests/_ist/tasima4_kesit.gd` (gedik ekseni kesiti), `tests/_ist/tasima4_zemin.tscn` (düşen düellocunun konabileceği görünen zemin ızgarası).
- Çuvallar (`GedikOnarim._cuval`, `_cuval_duvar`): ilk sürüm yazıldı, henüz koşulmadı.

- ŞİMDİ ölçümü Bölüm 20 ×3 (9 çeşit, taban kopyası `~/is/taban`: düzeltmeler kapalı): `testler/simdi/c20_*`. 1. dalga 4,1 [1,8–11,8], 2. dalga 8,4 [4,3–30,0]; 23/23 koşuda düşen ceset 18'inde (en derin −128,9).
- §3 ceset kök nedeni bulundu (zemin sondası): yeni setin zemin gövdeleri `visible_body` değil → `Duelist._fall_tick` konmuyor. Düzeltme: `SurSetSahne` bölüm düğümüne `dusus_her_kati` metası, `Duelist._fall_solid` (varsayılan aynı).
- Kalas yığını (Bölüm 0 donma karesi): tek tek pahlı kalaslar (`SurSetSahne._kalas_yigini`), koşulmadı.

## Süren
- §1 Bölüm 20 düello süresi: ŞİMDİ ölçümü (×3 / ×2) sırada.
- §3 ceset düşmesi: kök neden adayı `Duelist._fall_tick` (görünmez/basılamaz yüzeye çarpınca konmuyor, 4 sn düşüp gizleniyor: −128 m = ½·16·4²); sonda ile doğrulanacak.

## Sıradaki
- §1 kaldıraçlar (yaklaşma yolu, kademeli katılma), §2 Bölüm 0, §3 kalanlar, §4 22/22o.
