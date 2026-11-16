# TAŞIMA-4 durum

Dal `wip/ist2-tasima4`, taban `wip/ist2-tasima3` 6f92f921.

## Biten
- Kurulum: Godot 4.4.1 (`~/is/godot/godot`), içe aktarma.
- Sondalar yazıldı: `tests/_ist/tasima4_kesit.gd` (gedik ekseni kesiti), `tests/_ist/tasima4_zemin.tscn` (düşen düellocunun konabileceği görünen zemin ızgarası).
- Çuvallar (`GedikOnarim._cuval`, `_cuval_duvar`): ilk sürüm yazıldı, henüz koşulmadı.

- ŞİMDİ ölçümü Bölüm 20 ×3 (9 çeşit, taban kopyası `~/is/taban`: düzeltmeler kapalı): `testler/simdi/c20_*`. 1. dalga 4,1 [1,8–11,8], 2. dalga 8,4 [4,3–30,0]; 23/23 koşuda düşen ceset 18'inde (en derin −128,9).
- §3 ceset kök nedeni bulundu (zemin sondası): yeni setin zemin gövdeleri `visible_body` değil → `Duelist._fall_tick` konmuyor. Düzeltme: `SurSetSahne` bölüm düğümüne `dusus_her_kati` metası, `Duelist._fall_solid` (varsayılan aynı).
- Kalas yığını (Bölüm 0 donma karesi): tek tek pahlı kalaslar (`SurSetSahne._kalas_yigini`), koşulmadı.

- ŞİMDİ 20o ×2 (`testler/simdi/c20o_*`): def 10,0 / 14,7; `=wide` 6,4 / 11,1; düşen ceset 13/20 koşu.
- §1 düzeltme: Bölüm 20 `_yaklasma` (ovadan dolgu → teras → moloz sırtı → gedik ağzı → barikat ucu; 2. dalga group 2 + kademeli), 20o `_savunan_yolu` (barikat kapalıyken peribolostan barikat ucundan dolanma). WaveRunner'a `stagger` ve giriş başına `via` (varsayılan aynı).
- Sondalar `testler/sonda/*_s2*`: 20 → 10,4 / 21,4 sn; 20o =wide → 12,1 / 18,3 sn; düşen 0.
- §2 Bölüm 0: ek hücum merdivenleri (Assault.ek_merdiven + SurSet.merdiven_dayama), Garrison boşlukları daraltıldı, yaralı şeridi, sur yolu meşaleleri, duman.

- SONRA Bölüm 20 ×3 (27 koşu, `testler/sonra/c20_*`): 27/27 PASS, denetim 0; 1. dalga 11,4 [9,3–18,9], 2. dalga 21,2 [17,7–26,2]; düşen ceset 0/27; tüfekçi çoğunlukla 4/4.
- Çuval karesi (Bölüm 20 an_06): tuğla dizisi, havada yok; renk bir ton açıldı.

- Makine yeniden başladı (kare/ölçüm yarıda): kalan 20o, eski koşuları yeniden koşuldu.
- SONRA 20o ×2 20/20 PASS, düşen 0; `=wide` son ayar ×6: 8,6 / 12,9 sn. Eski `--eskisur` 6 koşu PASS.
- Ortak sınıf kullanan 14 bölüm ×1 PASS, denetim 0. Sözleşme üçlüsü aynı.
- Bölüm 0: 3 kare turu (merdiven ucu, kuleye dayalı merdiven, yaralılar); donma karesi bütçesi için uzak figüran gizleme.

## Süren
- Bölüm 20 `=kare` yeniden çekim (2.400 sn sınır) yalnız `an_14_dalga2_orta` için; gelirse `kare/c20_sonra/`'ya eklenir.

## Sıradaki
- Bölüm 22 / 22o taşıması (yapılmadı; rapor §4).
- Rapor: `rapor.md` tamam (özet, ölçümler, kareler, bütçe, istekler).
