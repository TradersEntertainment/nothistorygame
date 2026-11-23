# TUR 15 — durum

Dal: `wip/ist2-tur15` (taban `wip/ist2-birlesik` f1f007c5).

## Yapılan (kod)
- `horn_world.gd`: `DENIZ_UZAK := {"springs": INF}` bölge anahtarı; `_deniz_yakin` eşiği `DENIZ_UZAK.get(region_name, DENIZ_YAKIN)`;
  `_deniz_bolge()`; Eugenius kulesi springs'te `deniz_set.uzak_yuvarlak_kule`; GalataView'a `yeni_sur` bayrağı yalnız springs'te.
- `deniz_set.gd`: yeni yardımcılar `uzak_yuvarlak_kule`, `uzak_parca_uclu` (var olanlar değişmedi).
- `galata_view.gd`: `yeni_sur` (varsayılan false) → surlar/burçlar yeni kalemle, rastgele dizi tüketimi aynı.
- Araçlar: `tests/_ist/tur15_kare.*` (kareler), `tests/_ist/tur15_karma.*` (HornWorld görünüş karması).

## Sıradaki
- ÖNCE ölçümleri (kare, DENIZSET, karma) → SONRA → testler → rapor.
