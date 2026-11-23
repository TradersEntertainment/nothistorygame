# TUR 15 — durum (son)

Dal: `wip/ist2-tur15` (taban `wip/ist2-birlesik` f1f007c5). Ayrıntı: `rapor.md`.

- Kesme 1–3 ve 5 TAMAM; kesme 4 (`in_world = false`, ölü yol) YAPILMADI; DÜZELTME 5(a) Galata TAMAM, 5(b)/(c) görünmüyor.
- Kod: `horn_world.gd` (`DENIZ_UZAK {"springs": INF}`, `_deniz_bolge`, `_deniz_eski_mi`, 240 m parçalı ağ, Eugenius),
  `deniz_set.gd` (yeni: `uzak_yuvarlak_kule`, `uzak_parca_uclu`), `galata_view.gd` (`yeni_sur`, varsayılan false).
- Araçlar: `tests/_ist/tur15_kare.*`, `tests/_ist/tur15_karma.*`.
- Testler (son kod): parse PASS; sözleşme altılısı aynı; ZFIGHT 0; 17o 4 çeşit × 2 + eski kip PASS, denetim 0; madde 1'in
  10 bölümü PASS, `testler/denizset_fark.txt` boş; HornWorld karması 10 bölümde ÖNCE = SONRA.
- Bütçe: ilkel toplam −%0,8, en çok +%3,8; çizim −%1,1; kare süresi (yazılım GL, ±%15 gürültü) iki tur ortalaması −%0,3.
