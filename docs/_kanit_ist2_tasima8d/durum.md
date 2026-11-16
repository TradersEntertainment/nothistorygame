# Taşıma 8D — durum

Dal `wip/ist2-tasima8d` (taban `wip/ist2-taban15` aec59c9f).

| Bulgu | Durum |
|---|---|
| 1. 26o tırmanış döngüsü bitmiyor | Kök neden bulundu (tepe çıkışı mazgal eşiğinin üstü, y 10,03 / sur yolu 8,62; bot merdivene geri yürüyüp yeniden tutunuyor). Düzeltme yazıldı (`SurMerdiveni.top_exit` → sur yolu zemini, bot tepede merdivene bakmaz, yedek tek sefer). İlk ölçüm: 26o 5 çeşit ×2 = 10/10 bitti. Geniş ölçüm sürüyor |
| 2. 26o sur yolu fıçıları geçidi tıkıyor | Kök neden: 26o dekor patlamaları eski koordinatla surun gövdesinde; `_patlama` siper bilmiyordu. Düzeltme: siper kuralı (`_siperde`), 26o patlamaları dış yüze, dar geçitte yavaşlayan gövde duvara yaslanır. Sonda (`tests/_ist/tasima8d_tekme.tscn`) iki esya_fizik kusuru daha buldu ve düzeltildi: uyanan gövde ilk fizik adımında fırlıyordu (donuk başlangıç, itkiler 3. karede), kesişme ayırma (`_kesisme_ayir`). Sonda 26o/20/22/26/37o PASS, ESYATEST PASS |
| 3. 26 iç içe geçmeler | `SPK_DEFENDER|Duelist`: kök neden öldürme kamerasının gizlediği savunucuyu `Unclip.spread` görmüyor; `_dostlari_dagit` kamera dönünce dağıtır. Squad/chop ölçülüyor |

Not: `TMP8D` satırları geçici tanı satırıdır (son kayıtta kaldırılacak).
