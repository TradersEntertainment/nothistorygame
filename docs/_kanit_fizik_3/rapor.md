# FİZİK-3 — 37o ayak gerilemesi, giysi kumaşı, yığılma kalanları

Dal `wip/fizik-3` (taban `wip/fizik-taban3` 758502cd). Yöntem: [`yontem.md`](yontem.md). Süzülmüş günlükler:
[`gunluk/`](gunluk/). Kareler: [`kare/`](kare/). Durum: [`durum.md`](durum.md).

## Özet

| # | İstek | Durum | Not |
|---|---|---|---|
| 1 | 37o eski sette ayak IK açıkken asker havada/gömük (gerileme) | **TAMAM** | İki kök neden (bayat IK yazımı + `Stage.plant_feet` ile çift denetleyici), ikisi de `scripts/npc/` içinde kökten düzeltildi; denetim değişmedi. ÖLÇÜM_1 |
| 2 | Giysi kumaşı sallansın (kaftan, cüppe, etek, bel eteği, pelerin, yen, yatırtma, püskül) | **TAMAM** (kanıt KISMEN) | Köşe gölgelendiricisi + kişi başı yaylı sarkaç + bacak zarfı + zemin düzlemleri; yeni çizim çağrısı yok; kumaşın kendi payı kare betik süresinin ≈ %0,5'i. Deney sahnesinde bütün durumlar; oyun içi karelerde ÖZET_OYUN |
| 3 | Yığılma kalanları; 26 iş pozu (`Stage.grip_hold`) | **KISMEN** | `grip_hold` tutuşunda ayak izdüşümü yazıldı. YIGILMAAUDIT kalanları (yaslanan gövde, sarkan/taşa giren uzuv, taşın içinde başlayan kök, Assault okla vurulanlar) **YAPILMADI** (süre). |

(taslak — ölçümler tamamlanınca doldurulacak)
