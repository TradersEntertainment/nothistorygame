# Taşıma 8D — durum

Dal `wip/ist2-tasima8d` (taban `wip/ist2-taban15` aec59c9f).

| Bulgu | Durum |
|---|---|
| 1. 26o tırmanış döngüsü bitmiyor | Düzeltildi (`SurMerdiveni.top_exit` sur yolu zemini, bot tepede merdivene dönmez, yedek tek sefer, eşik/diş 1,5 sn → bir kez sur yoluna). Gerçek oyuncu sondası `=dis_in/=dis_dur/=esik_dur` PASS. Son doğrulama (26o ×5) sürüyor |
| 2. 26o sur yolu fıçıları | Düzeltildi (siper kuralı, 26o patlamaları dış yüze, dar geçitte yaslanma; uyanışta donuk ilk adımlar + kesişme ayırma). Tekme sondası 26o/20/22/26/37o PASS |
| 3. 26 iç içe | Düzeltildi (gizlenip geri gelen kişiler: `_dostlari_dagit` kamera dönünce, kamera bekçisi, göründü-bekçisi; yedek bölükler kargaşanın yolsuz alanında, 4. şerit bölükten çıkarıldı). 26 hold/isidore/hold_box ×8 = 24/24 PASS, denetim 0 |

Son doğrulama: sözleşme üçlüsü + ESYATEST + PARSECHECK PASS; 26 öteki çeşitler ×2 + eski set sürüyor; sonra 26o ×5, bağımlı bölümler, menu_return.
