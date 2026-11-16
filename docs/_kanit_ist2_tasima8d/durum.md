# Taşıma 8D — durum

Dal `wip/ist2-tasima8d` (taban `wip/ist2-taban15` aec59c9f).

| Bulgu | Durum |
|---|---|
| 1. 26o tırmanış döngüsü bitmiyor | Kök neden bulundu (tepe çıkışı mazgal eşiğinin üstü, y 10,03 / sur yolu 8,62; bot merdivene geri yürüyüp yeniden tutunuyor). Düzeltme yazıldı (`SurMerdiveni.top_exit` → sur yolu zemini, bot tepede merdivene bakmaz, yedek tek sefer). İlk ölçüm: 26o 5 çeşit ×2 = 10/10 bitti. Geniş ölçüm sürüyor |
| 2. 26o sur yolu fıçıları geçidi tıkıyor | Yeniden üretildi (`lose`: `tikama_gecit fici id=23 at=(-11.2,8.9,15.1)`; uyanma nedeni patlama). Kök neden araştırılıyor |
| 3. 26 iç içe geçmeler | Başlanmadı |

Not: `TMP8D` satırları geçici tanı satırıdır (son kayıtta kaldırılacak).
