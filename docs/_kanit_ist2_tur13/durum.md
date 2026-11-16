# TUR 13 — durum (her kayıtta güncel)

Dal `wip/ist2-tur13`, taban `wip/ist2-taban14` = 014b61a7.

| # | Madde | Durum |
|---|---|---|
| 1 | İç poterna surun içine oyulur | KOD TAMAM (kare `tur13_kare` p1–p4): oyuk + kesme taş söve/kemer (kulak yok) + tonoz + lünet; etek kapı önünde yassı; dış poterna kemer kulağı kesildi. Bölüm testleri bekliyor |
| 2 | Romanos şehir yanı gri bloklar | KOD TAMAM: kaynak iç kulenin kaidesi (sur_kule `ic_kule`), şehir yanında surun içine çekildi; kule köşesi etek kamaları kırpıldı (sur_oturtma_ag `kule`) |
| 3 | Sancak kumaşı | KOD TAMAM: 26 ve 26o `Props.box` → `kumas.bayrak` (aynı ölçü, renk, düğüm; yükseliş tween'i aynı) |
| 4 | Pavez | KOD TAMAM: `Assault.pavez_ag` (5 kalın tahta, kavisli, pahlı, boyalı, kuşaklı, dayanaklı); `_pavises` renk başına MultiMesh; 26o siper çarpışma kutusu aynı, görünen ağ gövdenin çocuğu |
| 5 | Öküz arabası | KOD TAMAM: `Dressing.cart` tahta dalı (döşeme, parmaklık, 12 parça ispitli 8 parmaklı tekerlek, dingil, yere inen ok, boyunduruk); rng sırası ve çarpışma aynı |
| 6 | Harpuşta saçağı | KOD TAMAM: taşma 1,6–2,4 cm (+ ±0,6 cm oynama) |
| 7 | Yetişirse | — |

Sözleşme (son kayıt): `SURSOZLESME PASS kalem=13 kesim=8` · `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` · `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0`
