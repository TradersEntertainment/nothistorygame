# TAŞIMA 10 — durum

Dal `wip/ist2-tasima10` (taban `wip/ist2-taban17` = f962b002).

| Adım | Durum |
|---|---|
| Kurulum (Godot 4.4.1, import) | sürüyor |
| 1 ÖLÇ VE DÖK | sürüyor (okuma: SUR_BOLUM_TASIMA §1/§4.4, tasima8/9 raporları, byz_city, baglama, 12b, 10h, 8y, 6) |
| 2 12b | başlamadı |
| 3 8y | başlamadı |
| 4 10h | başlamadı |
| 5 6b | başlamadı |
| 6 7b fon | başlamadı |

## Tasarım kararı (ilk)
- Hub (ByzCity "walls") için ortak bağdaştırıcı: `scripts/world/ist/sur_set_hub.gd` — `SurOyun.kur("romanos")` kesimini
  hub çerçevesine oturtur (kesim +z → hub +x dış; kapı ortası → `ByzCity.EXIT_POS.z`; iç surun şehir yüzü → hub x 32,5).
  ByzCity yeni kipte kendi kutu iç surunu/kulelerini/kapısını kurmaz (Giustiniani'nin iskelesi, masası, sandıkları kalır).
- Geri dönüş: `--eskisur` / `--eskisur=12b,10h,6,7,8y` → eski kod yolu satır satır.
