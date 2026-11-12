# Ara not (denetim sürüyor, nihai rapor rapor.md olacak)
- Varsayılan varyant, 61 bölüm, ÖNCE (bakış dosyaları e551de84) ve SONRA: ikisi de 61/61 RUNOK.
- SAYFACE: önce 23, sonra 25 anahtar. Fark: D39O_SA_02 (39o rastgele: ÖNCE ağacında da tekrar koşuda çıktı, gerileme değil),
  D9_KADRI_OFFER_1 (sonra 2/2, önce 0/2: kök neden aşağıda).
- D9_KADRI_OFFER_1 kök neden: chapter9.gd _talk() otomatik testte oyuncuyu Kadri'nin 3 m içine ışınlıyor; Kadri "chop" alet işinde,
  3 m dışındayken gaze_dir gövdeyi çevirmiyor (tasarım), ışınlanma anında sırtı dönük. Geliştiricinin face_toward'ı yalnız
  _run_shots içinde ve autotestte hiç çalışmıyor. Oyunda etkileşim ışını 2,4 m: oyuncu yürüyerek 3 m içine girince döner.
