# TAŞIMA 10 — durum

Dal `wip/ist2-tasima10` (taban `wip/ist2-taban17` = f962b002).

| Adım | Durum |
|---|---|
| Kurulum (Godot 4.4.1, import) | TAMAM |
| 1 ÖLÇ VE DÖK | TAMAM (dokum.md) |
| 2 12b | sürüyor: sur yolu yeni surda (PASS ×1); ilk kareler alındı; kusur: kapının güneyinde dış görünüşte sur boşluğu (inceleniyor) |
| 3 8y | sürüyor: v2 bölgesi gate8y (Romanos'un gerçek yeri) + kesim + kanatlar/köprü; `""` PASS ×1 |
| 4 10h | hub yeni surla `""` PASS ×1 (gedik henüz eski yerinde) |
| 5 6b | hub yeni surla (v2) `byz` PASS ×1 |
| 6 7b fon | başlamadı |

## Tasarım kararı (ilk)
- Hub (ByzCity "walls") için ortak bağdaştırıcı: `scripts/world/ist/sur_set_hub.gd` — `SurOyun.kur("romanos")` kesimini
  hub çerçevesine oturtur (kesim +z → hub +x dış; kapı ortası → `ByzCity.EXIT_POS.z`; iç surun şehir yüzü → hub x 32,5).
  ByzCity yeni kipte kendi kutu iç surunu/kulelerini/kapısını kurmaz (Giustiniani'nin iskelesi, masası, sandıkları kalır).
- Geri dönüş: `--eskisur` / `--eskisur=12b,10h,6,7,8y` → eski kod yolu satır satır.
