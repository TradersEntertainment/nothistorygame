# TAŞIMA 8 — Bölüm 26 (Şafak, Bizans) ve 26o (Şafak, Osmanlı) yeni Mesoteikhion surunda

Dal `wip/ist2-tasima8` (taban `wip/ist2-taban13` = c6ab0f7b). Godot 4.4.1 resmi, `--max-fps 20`, tam süzgeç
(`AUTOTEST (PASS|FAIL)|SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|WARN_FLY|WARN_VOID`). Ham ölçüm satırları
`testler/` altında (yalnız süzülmüş satırlar; ham günlükler diskte tutulmadı).

## Özet (madde madde)

| Madde | Durum | Not |
|---|---|---|
| (a) `SurOyun` iç poterna seçeneği (`{"ic_poterna": true}`) | **TAMAM** | Varsayılan kurulum bit bit aynı; sözleşme üçlüsü aynı (aşağıda) |
| (a) Romanos yan dilimine `kanat_disarida` + `KapiKanat` (+ isteğe bağlı `KapiKopru`) | **TAMAM** | `surlar_kapi.gd` DEĞİŞMEDİ: seçenek sözlüğünün kopyası verilir (paylaşılan `OPTS` aynı) |
| (a) `SurSetSahne.open_inner_gate()` → Romanos kanatları açılır | **TAMAM** | `romanos_kanat` verilmezse eski uyarı |
| (a) `FallenCity` konum parametresi (`yer`, varsayılan ZERO) | **TAMAM** | 31o eski sette aynı (aşağıda koşu) |
| (a) `SiegeChaos.sur` kancası | **TAMAM** | null/eski: birebir aynı |
| (a) 26o statik karşılıkları (`SurSet.dolgu_ust`, `dolgu_y`; `walk_x` = var olan `dis_yol_x`) | **TAMAM** (yalnız sorgu) | 26o henüz bunları kullanmıyor (d) |
| (a) 26 ve 26o ESKİ sette PASS | **TAMAM** | `--eskisur=26` ve 26o (kendi `_ready`'si eski set) |
| (b) 26 savaş evreleri yeni sette | **TAMAM** (denetim satırları için bkz. "hâlâ kötü") | |
| (c) 26 final: Romanos kapısı, Sultan, FallenCity | **KISMEN** | Yol: dolgu → gedik tepesi → karartma → Romanos koridoru → iç kapı → cadde; "peribolos boyunca" mümkün değil (aşağıda) |
| (d) 26o yeni sette | **YAPILMADI** | 26o eski sette sabit (kendi `_ready`'si `LandWalls.new()`); süreklilik geçici bozuk (§3) |

(Bu tablo son kayıtta güncellenir.)
