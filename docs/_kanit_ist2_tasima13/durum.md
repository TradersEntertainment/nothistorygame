# Taşıma 13 — durum (son)

- Dal: `wip/ist2-tasima13` (taban f1f007c5). Ayrıntı: `rapor.md`.
- [x] 31o yeni sette v2 şehri (8y kalıbı: SurHub "romanos" + IstBaglama `fallen31o`), tek sur, cadde korunur, kalabalık.
- [x] Evre geçişi temiz (düğüm eski düzeyde; bellek +92 MB kalıcı, rapor).
- [x] `ESKI_VARSAYILAN` boş: 31o anahtarsız yeni sette; `--eskisur=31o` eski.
- [x] Doğrulama: 31o çeşitleri ×2 PASS, eski ×1 PASS, CITYCHECK 31o ×2 PASS, ZFIGHT 0, sözleşme altılısı aynı, ortak dosya
      bölümleri (7, 7b, 11, 13, 13 city, 23, 24, 26, 26o, 12b, 8y) PASS, CITYCHECK 24 PASS.
- [!] `menu_return 31o` varsayılanla FAIL (MR_AFTER=60 ile PASS, 24 ile aynı); `street_check` FAIL (tabanda da FAIL).
- [ ] Yapılmadı: dönem seçeneği (madde 3 isteğe bağlı); cadde çevresindeki seyrek kuşak (sehir.gd isteği).
