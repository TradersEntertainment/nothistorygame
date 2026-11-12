# P10 — İç mekânlar ve tüneller: rapor

Dal: `wip/yardimci-p10`. ÖNCE = `a5e8111d` (0.99.119 tabanı), SONRA = bu dalın son kodu. Kanıt kareleri aynı koşu düzeni,
aynı replik anı (`--dialogshots --shotevery=1 --snapevery=0.5`, `PACE=1`, xvfb 1280×720) ya da oyunun kendi `--shots`
düzeninden; ÖNCE kareleri `git worktree` ile ayrı kopyada özgün koddan alındı. Yakın plan **sonda** kareleri (kâtip, kazmacılar,
vezirler) oynanış karesi değil, geçici sonda koduyla alındı; sonda kodu sökülüdür (`grep GECICI_SONDA|P10PROBE scripts/` boş).
Karelerin hepsi 640 px (oynanış kareleri) ya da 1280 px (sonda); ince ayrıntı (kazma başı, kalem ucu) bu çözünürlükte
seçilemiyorsa aşağıda öyle yazıldı.

## Madde tablosu

| # | Madde | Ne yapıldı (dosya:işlev) | Pafta | Durum |
|---|---|---|---|---|
| 1 | Bölüm 1 kumanda elden ele | `chapter1.gd` `_run` (D1_H_15–16), `_remote_prop`, `_pass_remote`: kumanda Hikmet'in elinde görünür (`rig.hold_item`), Tolga uzanınca elden çıkıp (`Handover.audit_distance`, 0,4 sn) Tolga'nın eline gelir; sonra `show_remote`. Eski `Stage.reach` havaya uzanıyordu | p01 (ÖNCE: Hikmet'in elleri boş, kumanda Tolga'nın elinde birden beliriyor; SONRA: Hikmet kumandayı tutuyor, Tolga uzanıp alıyor), p02 (D1_H_18) | **DÜZELDİ** |
| 2 | Bölüm 13 Hikmet kolu çeker (D13_H_LEVER) | `chapter13.gd` `_open_window`, `_lever_knob`: el kolun topuzunu tutar (`player.reach_grab`), kol inerken el onunla iner (tween), bırakılır. Kamera **çevrilmedi** (ilk denemede `player.face(knob)` vardı: çizim sayısı +%9 oldu, söküldü) | p03 (ÖNCE: el havada, kol kadrajda ama boş; SONRA: kol uzanır, el topuzda, kol iner) | **DÜZELDİ** |
| 3 | Bölüm 3 Hikmet kolu çeker | `chapter3.gd` yasak dosya; `grep lever/knob` bu dosyada kol sahnesi bulmadı. Envanterin 3 iddiası doğrulanamadı | — | **KANITSIZ** (dokunulmadı) |
| 4 | Bölüm 12 kâtip yazarken kalem | `otag_hall.gd` `_build_people`: kâtip alçak masaya döndü (arkası dönüktü), `set_activity("write")` → kalem sağ elde, defter solda. ÖNCE'de kâtip ayakta, elleri boş, masa boş | p07 (sonda: ÖNCE ayakta eli boş; SONRA oturmuş yazıyor, kalem elinde, kırmızı defter) | **KISMEN** — düzeltme sondayla kanıtlı; oynanış karelerinde kâtip kadrajda değil (oyuncu tahta bakıyor), oynanış karesi yok |
| 5 | 21o kazmacı kazmasız | `chapter21o.gd` `_build`: `digger.give_tool("pickaxe")` | p04 (ÖNCE ust: boş el; SONRA alt: elde kazma sapı, savurma evreleri farklı) | **KISMEN** — sap elde ve vuruşla birlikte oynuyor, kazma **başı** karede seçilmiyor (karanlık, baş duvara dönük) |
| 6 | 21o oyuncunun kazma modeli (elde araç) | `chapter21o.gd` `_give_pick`: `Items.tool_model("pickaxe")` (sivri/düz çift başlı) — eski düz gri levha yerine | p06 (ÖNCE: düz levha/tokmak; SONRA: gerçek kazma) | **DÜZELDİ** |
| 7 | 10l Dragan kazma (D10L_T_04 "Kazmaya bakar") | `chapter10l.gd` `_build`: Dragan'ın sol elinde dik kazma (`Items.attach_tool`, hand "l", ağız yukarıda, 35° dışa yatık; sağ elde Tolga'nın paketinin arkasında kalıyordu, ağız aşağıda altyazı kutusunun arkasında), `_give_pick`'te Dragan'dan kalkar | p09 (satır 1 ve 3) | **DÜZELDİ** |
| 8 | 10l oyuncunun kazması | `chapter10l.gd` `_give_pick`: `Items.tool_model("pickaxe")` | p09 (satır 2: D10L_D_DIG_1) | **DÜZELDİ** |
| 9 | 10l yan kazmacılar (odada 2 kişi) | `chapter10l.gd` `_build`: duvara döner, `set_activity("chop")`, `give_tool("pickaxe")` | p05 (ÖNCE: kollar sarkık, boş; SONRA: kol uzanmış, elde kazma sapı) | **KISMEN** — sap görünür; kazma başı kadraj/ışık yüzünden seçilmiyor |
| 10 | 15 toplantı figürleri donuk | `chapter15.gd` `_meeting_nods` (+ `_nod_later`, iki sahnede çağrı): oturan çalışanlar 3–9 sn'de bir başını sallar (rig "nod"). Oturanlar `Crowd.idle_vary`'de atlandığı (activity "sit") için ayrı işlev | p10 (ÖNCE: yalnız nefes sallanması; SONRA: yeşil çalışan kare 13 ve 15'te başını sallar) | **KISMEN** — ÖNCE'de de sürekli hafif nefes kıpırtısı var (tam donuk değildi); fark küçük, baş sallaması ölçüldü (bölge farkı 24 / taban 5) ve karede seçiliyor ama zayıf |
| 11 | 12/10a/13/14/15 sarayda vezirler | `otag_hall.gd` `_build_people`: `Crowd.idle_vary(_court, ...)` | p08 (14 kare) | **KISMEN** — SONRA'da kol kaldırma/açma jestleri var (kareler 4, 10, 12), ÖNCE'de de bir kol kaldırma var; fark seyrek ve küçük |
| 12 | bureau işçilerine alet | `bureau.gd` yasak dosya, dokunulmadı | — | **YAPILMADI** (öneri aşağıda) |
| 13 | 5, 8, 10a, 14 baştan sona kare gezisi | Diyalog kareleri (640 px) tarandı; havada/gömülü/eli boş iş belirgin seçilmedi. Tutuş ayrıntısı bu çözünürlükte doğrulanamaz | — | **KANITSIZ** (kusur bulunmadı ≠ kusur yok) |

Kod, kabul karelerine göre: D1_H_18 (p02), D13_H_LEVER (p03), 21o (p04, p06), D10L_T_04 (p09), 12 kâtip (p07).

## Testler (son kodla, `--headless --max-fps 20`, hata satırı: SCRIPT ERROR, WARN_FX_STUCK, WARN_FLY_ITEM, VISAUDIT, WARN_VOID_TELEPORT, WALKTHRU, ARMAUDIT, HELDAUDIT, JOURNEY_*)

`parse_check`: PARSECHECK PASS scripts=247.

| Bölüm | Varyant | Sonuç |
|---|---:|---|
| 1 | 3 (`""`, kick, red) | 3 PASS |
| 5 | 5 | 5 PASS (+ `=next` 1 PASS) |
| 8 | 10 | 10 PASS (+ `=next` ve `=next --outcome=6:6b.1` 2 PASS) |
| 10a | 2 | 2 PASS (+ `=next` 1 PASS) |
| 10l | 4 | 4 PASS son kodla (+ `=next` 1 PASS) |
| 12 | 9 | 9 PASS son kodla (+ `=next` 1 PASS) |
| 13 | 10 (run_tests.sh listesi) + `=next`, `=wrong_next`, `=gidak` = 13 | 13 PASS son kodla |
| 14 | 9 | 9 PASS (+ `=next` 1 PASS) |
| 15 | 33 (tam liste) | 33 PASS son kodla |
| 21o | 4 | 4 PASS son kodla |
| 3 | — | yasak dosya, koşulmadı (yalnız kare gezisi) |

Toplam 99 koşu, **99 PASS**, hata satırı **0** (SCRIPT ERROR / WARN_* / VISAUDIT / WALKTHRU / ARMAUDIT / HELDAUDIT / JOURNEY_* hiçbirinde yok). Görev dosyası "13 (11)" diyor; `run_tests.sh`'ta 13'ün 10 varyantı + 3 `next` satırı var, hepsi koşuldu. 1, 5, 8, 10a, 14 son kodla da aynıdır (o dosyalar değişmedi; ilk tam koşuda geçti). 10l, 13, 15 en son değişiklikten sonra yeniden, 12 ve 21o sonda sökülünce yeniden koşuldu.

## Performans (`tests/perf_run.sh`, RINFO, 1280×720; ÖNCE → SONRA)

| Sahne | çizim ort. | çizim en yüksek | üçgen ort. (k) | üçgen en yüksek (k) |
|---|---|---|---|---|
| 1 | 694→573 | 1520→1510 | 311→311 | 748→1242 (örnekleme gürültüsü, nota bak) |
| 10a | 793→781 | 1006→918 | 77→77 | 170→170 |
| 10l | 501→537 (+%7,2) | 704→718 | 96→97 (+%1) | 105→105 |
| 12 | 644→634 | 1043→1043 | 145→145 | 148→148 |
| 13 (son kod, kamera çevirmesiz) | 532→532 | 6964→6964 | 105→105 | 6552→6552 |
| 14 | 3446→3442 | 3447→3446 | 770→804 (+%4,4) | 796→837 (+%5,2) |
| 15 | 595→595 | 637→637 | 299→299 | 518→518 |
| 21o | 445→458 (+%2,9) | 582→588 | 69→61 | 137→127 |

(13: ayrı koşu `PERF_OUT=/tmp/p10/perf3`; diğer satırlar tek tam koşu, 300 sn sınırlı. 15 ve 10l son küçük değişikliklerden önce ölçüldü: `_meeting_nods` ve Dragan kazmasının eğimi geometri/çizim eklemez.)

Notlar:
- **13**: ilk sürümde kamerayı kola çevirmek tepe çizimini 6964 → 7617 (+%9,4) çıkardı; kamera çevirmesi söküldü, son kodda RINFO ÖNCE ile birebir aynı (t=3: 463/72k, t=5: 6964/6552k, t=7: 466/135k çizim/üçgen).
- **10l**: 3 kazma aleti (Dragan + 2 kazmacı) ≈ +21 çizim (468 → 489, +%4,5) ekledi; çizim sayısı sıfır artış ölçütünü **aşıyor** (alet modeli çok parçalı). Üçgen +%1.
- **1**: örnekleme evresi gürültülü (ÖNCE'nin kendi koşularında da t=11'de üçgen 323–326k ile 618k, çizim 692–696 ile 1076 arasında sıçrıyor). SONRA 6 koşuda bir kez t=9'da 1246k çıktı (çizim sayısı aynı, 1510); tekrarlanabilir bir artış bulunamadı, nedeni **açıklanamadı** (ÖNCE'de benzer sıçramalar var, ama bu tam o değer değil).
- **14**: +%4–5 üçgen (796→837k, görünür; çizim sayısı aynı). Nedeni doğrulanmadı (otag_hall'daki kâtip/vezir değişikliği olması muhtemel); %8 sınırının altında.
- 15, 12, 10a, 21o: çizim ve üçgen değişmedi ya da azaldı.

## Ortak dosyalarda önerim

- `bureau.gd` Çaycı Necmi: `_rb_necmi_p.set_activity("stir")` yanına `_rb_necmi_p.give_tool("ladle")` (elde kepçe; `Items.TOOLS["ladle"]`'ın aim'i kazanda). Zeki'nin "push" etkinliği arabanın tutamağını iki elle tutuyor (araba `_ld_cart` çocuk), alet gerekmez. **Denenmedi** (dosya yasak).
- `chapter3.gd`: Hikmet kol sahnesi bulunamadı; varsa `chapter13.gd` `_lever_knob` + `reach_grab` kalıbı uygulanır.

## Bakamadıklarım / açık

- Kâtip ve vezirler oynanış karelerinde kadraj dışında; yalnız sonda kanıtı var.
- Kazma **başı**: 21o ve 10l kazmacılarında sap ve savurma görünür, baş seçilmiyor (KISMEN).
- 15 toplantısında baş sallama etkisi küçük.
- 5, 8, 14, 10a, 3: kare gezisi yalnız 640 px diyalog kareleriyle; el/alet ayrıntısı KANITSIZ.
- Ortam: Godot 4.4.1 indirildi, `--import` yapıldı; `i18n/*.translation` içe aktarmayla değişince geri alındı; `.import` dosyaları (yeni ses mp3'leri) kayda girmedi.
