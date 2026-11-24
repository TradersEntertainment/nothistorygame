# G16 Güncelleyici — durum

- [x] KESME 1: `scripts/ui/guncelleyici.gd` (denetim, bant, sayfa yolu, oto kip), menü bandı + ayar satırı, 30 `UI_GUNC_*` anahtarı, CI bildirimi (`release.yml`), birim testi `tests/guncelleme_check` → GUNCELLEMECHECK PASS
- [~] KESME 2: Linux e2e koşuyor (ilk koşu: root chmod engel değil → yazılamaz senaryosu güncelledi; chattr +i ile düzeltildi)
- [ ] KESME 3: Windows yolu (wine)
- [ ] KESME 4: kareler, rapor

Son denetim: parse PASS, SURSOZLESME PASS kalem=13 kesim=8, ESYATEST PASS, check_keys/inline/voice_rules/export_refs PASS.
Gerileme: ui_fit, quip, chapter0/1 autotest, menu_return 26/20o PASS.
