# TAŞIMA 9 — durum

- Dal `wip/ist2-tasima9`, taban `wip/ist2-taban16` = fa66841e.
- [x] Godot 4.4.1 kuruldu, içe aktarma bitti.
- [x] Ölçüm sondası `tests/_ist/tasima9_sonda.tscn` (eski | yeni aynı sahnede): çarpışma farkı 0 (saray hariç: 11 kutu, şehirdeki saray).
- [x] Ortak kalem `scripts/world/ist/blak_set.gd` (şehir `_blakherna_wall` artık bunu çağırıyor; şehir çarpışma dökümü tur 9 ile birebir aynı).
- [x] `Blachernae` yeni görünüş + `--eskisur` dalı; 30/30o bağları zemin sorgusuna (`Blachernae.zemin_y`).
- [x] Döküm `dokum.md` (eski set ölçüleri + 30/30o bağ tabloları).
- [x] `=kare` / `=yuru` kipleri (30, 30o; yardımcı `tests/_ist/tasima9_bot.gd`), evre süresi satırları `T9SURE`.
- [x] Beyaz ekran (ilk yeni kareler): birleştirmesiz sürümde; saray + sur ağları malzeme malzeme birleştirilince (çizim bütçesi
      için `blak_set.birlestir`) tanı karelerinde temiz. Tanı sahnesi `tests/_ist/tasima9_parca.tscn`.
- [ ] Kareler (koşuyor), bölüm testleri, rapor.
