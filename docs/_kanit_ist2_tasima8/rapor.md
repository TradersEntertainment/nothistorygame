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

## Sözleşme üçlüsü (her kayıttan önce)
`SURSOZLESME PASS kalem=13 kesim=8` · `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` · `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0`
(eklenen seçenekler yalnız verilince kurulur; `noktalar()`, `engeller()`, varsayılan `kur` dokunulmadı).

## 1. Bölüm 26

### 1.1 Bağ tablosu (bölüm çerçevesi: gedik x 0, peribolos y 0, dış surun iç yüzü z 14; eski → yeni)
Eski sette her sorgu `SurSet.eski()` üzerinden `LandWalls` sabitinin AYNISINI verir (`--eskisur=26`); 26o aynı dosyadan türer.

| Bağ | Eski | Yeni | Nasıl |
|---|---|---|---|
| Set | `LandWalls.new()` | `SurSetSahne` (`ic_poterna`, `romanos_kanat`; dolgu 1) | `SurSet.sec("26", ESKI_SUR)` |
| Ok sandığı `WELL` | (6,8; 0; 3,8) | (−4,6; 0; 5,6) | eski yer iç kulenin gövdesinde (x 0,2–9,2, etek −2,8…12,2, z ≤ 8); teslim yerine 7,3 m (eski 10,4) |
| Poterna `POSTERN` | (14,5; 0; 0,0) iç sur | (14,25; 0; −0,4) iç sur, peribolos yüzü | `SurSet.ic_poterna()` (+0,6) — `SurOyun.ic_poterna`: gedikten ≥ 12 m, iç kule ve eteği dışında, +x yanı |
| Poterna kapısı | bölümün kutu kanatları | setin `Poterna.kur_ic` kanadı (`ic_poterna_ac`) | kapı eteğin gerçek yüzüne ışınla oturur (+0,39 m) |
| Fıçılar `BLOCKS` | (12,6; 3,2), (14,6; 2,2); +z'ye yuvarlanır | (15,35; 3,2), (13,95; 2,8); +x'e yuvarlanır | taşıma yolu soldan iner; tween aynı (yalnız yön) |
| Sancak kulesi | (16; 11; 17) | (35,39; 13,12; 16,7) | gediğe en yakın kurulu dış kule `dis_kule_tepe` − 0,6 z |
| Komutan / savunucu sırası | BREACH + ofset (z 12 / 12,3–11,95) | gedik önüne hizalı `_gp` (z 11,2 / 11,5–11,15) | eski teslim yeri 11,6 ↔ yeni `gedik_onu` 10,8 |
| 5 hücum merdiveni | x −10,5; 9,5; −24; 22; 28 (9 m, 16°, ayak z 18,6) | x −10,5; 11,8; −24; 23; 17,5 (14,35 m, 16°, ayak teras y −3,675, z 20,68) | `SurSet.hucum_merdivenleri(lx, 40)`; gediğin iki yanı, `Garrison`/`SiegeChaos` alanı içinde; eski sıraya en yakın eşleme (ilki gediğin solu) |
| Kazanlar | (±8,6; 8; 15) | (±8,6; 8,62; 15,3) | `dis_yol_y/z` |
| Taşıyıcı/onarım ekibi | DEPOT(−2,6; 2,6) → BREACH − 3,4 / BREACH − 2,6 | depo (−14,1; 6,8) → `gedik_onu` / `_gp` | |
| Yedek bölükler | (−18; 8), (22,5; 9) | (−18; 8), (24; 7,4) | ikincisi peribolos eteğinin dışına |
| BattleExtras şeritleri | 5 şerit (z 2,4 / 12,6 / 6,6) | 5 şerit (z 3,2 / 9,6 / 9,6 / 5,6 / 6,6), deponun ve iç kulenin dışında | ilk denemede z 3,0 şeridi deponun içinden geçti (VISAUDIT sunk) → düzeltildi |
| `SiegeChaos.area`/`avoid` | Rect2(−44; 1,4; 88; 10,6) | ∩ `SurSet.peribolos()` (x −25,3…44; z 2,4…10,6) + iç kuleler + taşıma yolu çizgileri + yuvarlanan fıçılar | `SiegeChaos.sur` kancası (yeni) |
| `Garrison` boşlukları | (13,19), (−10,4;−6,8), (6,8;10,4) | (−12,6;−6,8), (6,8;13,8), her merdiven ±1,4 | `Garrison.land_walls(…, sur)` |
| Doğuş | `SPAWN` | `sur.dogus()` (−9,6; 0,05; 7,2) | |
| 1. dalga ışınlanma | (lad.x − 1,9; 8,05; 14,95) | (lad.x − 1,9; 8,67; 14,77) | `dis_yol_ic_z` |
| Kaynar yağ hedefi | (x; 0; 18) | (x; −3,675; 18,0) teras | |
| Ok/yaylım hedefleri | z 21–33, y 0; sur yolu y 8 | z 19,6–44,6, y `zemin_y`; sur yolu `dis_yol_x` | `_arrow_loop`, `_pour_loop` |
| Saldıranlar | z 40–70, y 0 | + `ova_ofs` (z +10,6, y −3,575), y `zemin_y` | |
| Şafak tüfeği | oyuncu (−10; 8,05; 15,3); koşucular hendekten | oyuncu sur yolu; koşucular hendeği dolgudan (x 0 ± 5) geçer | `ground: sur.dis_zemin_y` |
| İmparator | BREACH + (3; 0; −9) | (−4; 0; 6,8) | eski yer iç kule eteğinde |
| Şafak atışı oyuncu | (−0,6; 9,8) | (−0,6; 9,0) | `_gp` |
| Taşıma yolu | doğrudan poternaya | (−3,4; 9,0) → (12,85; 9,0) → poterna | iç kulenin önünden; savunucu sırasından 2 m |
| Final: iç kapı | x 0 `open_inner_gate` | Romanos (x −57,3) `KapiKanat` açılır | karar 11-A |
| `FallenCity` | yer 0 | `yer` = (−57,3; 0; −2,0) (`SurSet.sehir_ofs`) | konum parametresi |
| Alay yolu | dolgu → gedik tepesi → iç kapı (x 0) → cadde | dolgu → gedik tepesi (durur: "gediğin üstünden") → karartma → Romanos koridoru → iç kapı → cadde | aşağıda "replik/yol" |
