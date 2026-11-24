# G17 durum

- [x] Dal `wip/denetim17` (taban f957694c)
- [x] Denetim betiği `tests/_denetim17/denetim17.gd` (hayvan, görünmez zemin, alet, donuk) — ilk taslak, henüz koşulmadı
- [x] Kancalar: hud `_denetim17()`, CanliKit.dugum → "hayvanlar", Bld → "pismis_hayvan", Stage.station → is_noktasi
- [x] run_tests.sh: `_ADAY` satırları listelenir; 8y PACE bloğu
- [ ] İlk koşu / yakalama kanıtları
- [ ] Tam paket, bulgular, düzeltmeler, kareler, rapor

## Ara (yakalama kanıtları, 8y hızlı test)
- GORUNMEZZEMIN: `pis()` düzeltmesi geri alınınca `Toprak_KapiRampasi_Carp` yakalanıyor (testler/yakalar_rampa_geri_alinmis.txt); düzeltmeyle rampa satırı yok.
- Hayvan: `goat.zemin` kaldırılınca `VISAUDIT_ADAY float who=Goat gap=3.51` (testler/yakalar_keci_zemin_kaldirilmis.txt).
- Ölçüt düzeltmeleri: (a) ışın katının içinde başlarsa (pişmiş öküzün kendi gövde kutusu) o katı zemin sayılmaz;
  (b) dünya arazisi parçası yeniden kurulurken (IstDunya `_jobs`) çarpışma noktası IstGeo.h'ye ±0,35 ise bekler;
  (c) kopyalanan ağın kaynağı değişirse (arazi LOD) kopya eskimiş sayılır; (d) DONUK: 8 m içinde, bakış konisinde
  sahne betiğinin yürüttüğü kişi (stage_walk/grip) varsa "izlenen iş" (8y kapı açılışı, 7 sn).
- Açık: 8y PACE koşusunda bot z=17,3'te takılıyor ("noktasına varamadı") — tabanda da mı, ölçülüyor.
