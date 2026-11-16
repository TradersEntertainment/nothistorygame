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

### 1.2 Final yolu: neden "peribolos boyunca" değil (replik ve yol)
Romanos kapı koşusunun (yan dilim, `IstSurlarKapi` `koridor`) iki yan duvarı iç surun peribolos yüzünden dış surun iç
yüzüne uzanır (`surlar_kapi.gd:77-80`): kapı geçidi peribolostan **kapalıdır** (kare `k1/r2`: peribolostan koridorun yan
duvarı). Sultan'ın atı ve oyuncu peribolostan Romanos iç kapısına giremez. İki repliğe uyan yol seçildi:
`D26_N_ENTRY_2` "Durdu. Gediğin üstünden şehre bakıyor." → at dolgudan gediğin tepesine çıkar ve durur (eskisi gibi);
`D26_N_CITY` "Aziz Romanos Kapısı'ndan içeri girdiniz." → ekran kararır, alay Romanos'un dış kapısından koridora girer, iç
kapıdan caddeye çıkar; oyuncu caddenin başında, kapının şehir yanında. Gedikten Romanos'un dış kapısına (teras boyunca
57 m) yürüyüş gösterilmez (karartma). Metin değişmedi.

## 2. Bölüm 26o

### 2.1 Bağ tablosu (eski → yeni; ova: eski + `SurSet.ova_ofs` = (0; −3,575; +10,6))

| Bağ | Eski | Yeni | Nasıl |
|---|---|---|---|
| Set | `LandWalls.ditch_filled = true; LandWalls.new()` | `SurSetSahne` (dolgu 1, `romanos_kanat`) — 26 ile aynı gedik, aynı kuleler | `SurSet.sec("26o", ESKI_SUR_O)` |
| `EDGE_Z`, `O_WATER`, `O_LADDERS`, `SQUADS`, `O_COVERS`, meşaleler, bekleyen saflar, Hasan, oyuncu başlangıcı | ova (y 0) | + `ova_ofs` | `_yeni_yerler_o` / `_ova` |
| Görünmez ova levhası | (0; −0,6; 57) 64×42 | kurulmaz (setin ovası katı) | |
| Hendek kenarı engeli | z 36,4 | z 47,0 (+ `ova_ofs`) | tırmanışta kalkar (eski hata düzeltildi: hiç kalkmıyordu) |
| Kazanlar | x −20,6; −8,6; 8,6; 21 (y 8, z 15) | x −20,6; −8,6; 8,6; 46,5 (sur yolu) | 21'deki kazan yeni sancak kulesine giden yolu kapatıyordu |
| Hücum (tırmanış) merdiveni | x 9, 8,6 m, 8°, ayak sur dibi y 0 | x 10,2 (mazgal açıklığı), dayama kuralı: 14,35 m, 16°, ayak terasta (y −3,675) | `SurSet.merdiven_dayama`; x 9 bir dişin önüne düşüyordu |
| Tırmanış bitişi | y > OUTER_H − 0,3, z < OUTER_Z1 − 0,1 | + yerde ve sur yolunun 0,5 m içinde | dişin/korkuluğun üstü "çıktı" sayılmasın |
| Hendek dolgusu (`CAUSEWAY_TOP`, `fill_y`) | LandWalls statikleri | `SurSet.dolgu_ust()`, `dolgu_y()` | `_entry_ground` |
| Mazgaldaki savunucular (tüfek) | `walk_x` [7,4; 9; 10,8; 12,5], z 15,25 | mazgal açıklıkları [6,6; 8,4; 10,2; 12,0], `dis_yol_on_z` | `_mazgal_x` (`SurOyun.mazgallar`) |
| Tüfekçi (düşman) | x 16 kulesinin tepesi | sur yolu x 19,2 (o aralıkta kule yok) | |
| `crowd_box` | (x−32; 6,5; −7) 64×11,5×25 | iç surun şehir yüzünden dış surun dışına | |
| Hendekteki kalabalık şeridi | x −26…26, z 27,5 | x −26…−8 ve 8…26, hendeğin ortası | dolgunun şevinde zemin formülü 0,44 m sapıyordu (VISAUDIT float) |
| Sur dibi şeridi | z 17,9 | `dis_sur_z1` + 1,3 (teras) | |
| Gedikten giren yeniçeriler | (x; 0; OUTER_Z1 + 2) | (x; teras; `dis_sur_z1` + 2) | |
| Sancak | (16; 11; 17) | (35,39; 13,12; 16,7) — 26 ile aynı kule | `_yeni_yerler` (26) |
| Giriş/FallenCity/Ayasofya | 26'dan miras | 26'dan miras (Romanos) | |

## 3. Bölümler arası süreklilik
26 ve 26o aynı `SurSetSahne` kesimini (Mesoteikhion, oyun gediği x 0 = 1. gedik, karar 4-A), aynı dolguyu (1,0: 29 Mayıs),
aynı sancak kulesini (x 35,4) ve aynı Romanos kapısını kullanır. Bölüm 20/22'nin gediği ile aynı nokta (`SurSet.yeni`
çerçevesi). 31o hâlâ eski sette (`LandWalls.new()` + `open_inner_gate`; `FallenCity.yer` verilmez → eski yer): 31o ×1 PASS
(aşağıda). 31o taşınınca `FallenCity.yer = sur.sehir_ofs(sur.romanos()["x"])` ve `SurSetSahne.romanos_kanat` ile aynı kapı.

## Sonraki taşıyana
1. **İç poterna**: `SurOyun.kur(…, {"ic_poterna": true})` → `parca["ic_poterna"]` (`Poterna.kur_ic`), yer `SurOyun.ic_poterna()`
   / `SurSet.ic_poterna()`. Sur gövdesi oyulmaz (surlar.gd değişmez): kanadın ardında söve derinliğinde karanlık geçit. Kapı
   kurulduktan 3 fizik karesi sonra iç surun eteğinin gerçek yüzüne ışınla oturur (`ICPOTERNA … oturma=` satırı, autotest).
2. **Romanos kapısı**: `{"romanos_kanat": true}` (+ `"romanos_kopru": true`, `"kapi_kopru": "saglam"|"yikik"`) →
   `parca["yan_kapi_kanat"]`, `SurSetSahne.open_inner_gate()`. Romanos koridoru peribolostan KAPALI (yan duvarlar); şehre
   geçiş iç kapıdan, dışarıya dış kapıdan. `SurSet.romanos()` eşikleri, `SurSet.sehir_ofs(x)` caddenin kaydırması.
3. **`FallenCity.yer`**: add_child'dan önce. Caddenin kendi zemin levhası z −42…−94 (yerel); kesimin şehir önü levhası iç
   surun 4 m gerisinden başlar: oyuncuyu caddeye koyarken iç surun gövdesine (yerel z −4…−0,6 eski; yeni çerçevede −6…−1)
   değil, caddenin başına (yerel −7,5 ve ötesi) koy (ilk denemede WARN_VOID_TELEPORT).
4. **`SiegeChaos.sur`**: area yeni periboloşa kırpılır, iç kuleler kaçınılır; `avoid_lines` ile oyuncunun yolu boş kalır.
5. **Vector3 bileşeni 32 bit**: `spec[1].z == 36.4` gibi eşitlikler tutmaz (26o'nun hendek engeli hiç kalkmıyordu).
6. **Mazgal**: el merdiveni tepesi bir mazgal AÇIKLIĞINA dayanmalı (`_mazgal_x`); dişin önündeki merdivenden çıkan dişin
   tepesine çıkar.
7. **Sonda**: `--sonda8` (26): savunucu sırası her evrede; kafile başı. `=yuru`, `=kare` (26 ve 26o).

## Görünüşe istek
1. İç poternanın kemer halkası (dış `Poterna` ile aynı ağ) alt uçlarında iki taş "kulak" gibi dışa taşıyor (kare `k1/p1`).
   `sur_oyun_parca.gd` `Poterna.kur/kur_ic` kemer döngüsü (açı 0 ve π'deki kama taşının dış ucu söveden 0,32 m dışarıda).
   Görünüş dosyası değil ama dış poternayla aynı ressam diye dokunmadım.
2. İç surun peribolos yüzündeki etek (OTURTMA) kapı önünde kesilmiyor (dış poterna için `kes["peri"]`'ye boşluk ekleniyor,
   iç yüz için yok: `surlar.gd:653-660`): iç poterna eteğin üstüne oturtuldu (eşik 0,39 m yüksekte). İç yüze `ic_poterna`
   boşluğu verilirse kapı toprağa iner.

## Replik uyumsuzluğu
- `UI_CH26_ENTRY` "Topkapı yanındaki gedik", `D26_N_ENTRY_2` "Gediğin üstünden şehre bakıyor": yeni yolda da doğru (at gedik
  tepesinde durur). `D26_N_CITY` "Aziz Romanos Kapısı'ndan içeri girdiniz": yeni yolda doğru (eskide x 0'daki adsız iç kapı).
  Uyumsuzluk yok; ama gedikten Romanos'a geçiş karartmayla (57 m) atlanıyor.

## run_tests.sh isteği (kendim eklemedim)
- `for v in "=yuru"; do run --chapter=26 --autotest$v; done` ve `run --chapter=26o --autotest=yuru` (≈ 50 sn, takılma/düşme
  satırı `TASIMA8YURU OZET`).

## Süre tabloları (ölçülen)

### 26
| Ölçü | Eski | Yeni | Fark / sınır |
|---|---|---|---|
| Taşıma yürüyüşü (gerçek bot, `=yuru` "giust → poterna" bacakları) | 19,6 m / 6,2 sn | 23,4 m / 7,4 sn | +3,8 m (sınır +5 m); oyunda taşıma hızı ×0,5: ≈ 12,3 → 14,6 sn |
| Taşıma (bölümün autotest botu, oyun saati, `TASIMA8 tasima`) | 3,1 sn | 5,0–6,7 sn | bot 5 m/sn ile ara noktalardan dolanır |
| Alay (giriş kartından ağarmaya, oyun saati, `TASIMA8 alay`) | 69,4–69,7 sn | 75,8–76,1 sn | +6,4 sn (sınır +15) |
| `=yuru` toplam | 91,8 m / 30,4 sn, takılma 0 | 98,3 m / 31,6 sn, takılma 0 | |
| Dalga süreleri (`WAVERUNNER t=`) | aşağıdaki çeşit tablosunda | | |

### 26o
| Ölçü | Eski | Yeni | Fark |
|---|---|---|---|
| Tırmanış (`CLIMB t=`, bot taştan kaçınarak) | 8,5–8,6 sn (8,6 m) | 11,1–27,0 sn (14,35 m; taş/yağ beklemesi dahil) | merdiven +5,75 m (teras 3,7 m aşağıda) |
| `=yuru` toplam | (eski yol korkuluğun önünde biter) | 98,2 m / 31,2 sn, takılma 0 | |

### 1.3 Kareler (26) — `kare/26/eski_an_NN_*.jpg` | `kare/26/yeni_an_NN_*.jpg`, 1280×720, tam boy bakıldı
Çekim: `xvfb-run … -- --chapter=26 --autotest=kare --dialogshots=DIR [--eskisur=26] [--karebas=N]` (yazılımsal GL; seri
10 dakikayı aştığı için `--karebas` ile iki parçada). Aynı anlamdaki kamera iki sette aynı kodla (`_t8_yuru`) kurulur.

| Kare | Yeni (tek cümle) | Eski ↔ yeni |
|---|---|---|
| 01 açılış | Gece peribolos: gedikte komutan ve savunucu sırası, kazık çit, meşale, solda ok sandığı; kutu yok (sandık bir sandık), havada yok, herkes zemine basıyor, aynı ressam; **eskisinden sönük**: peribolos daha seyrek (alan dar, kalabalık gedikte toplanmış). | eski kutu duvarlar, peribolos kalabalık |
| 02 ok demeti | Açık sandıkta ok demetleri, arkada deponun kalas yığını; oturuyor, havada yok; eskisiyle aynı yakınlık. | aynı |
| 03 merdiven/azap | Sur yolundan: mazgal açıklığına dayalı merdivenin iki direği, korkuluğun ardında azabın sarığı (yarısı dişin arkasında), sağda sur yolunda savunucular, önde stauroma fıçıları; havada yok; **eskisinden sönük**: dişli 1,2 m korkuluk azabı yarı saklıyor (ilk çekimde azap merdivenin eğimine değil dikine konmuştu: kare kurgusu hatası, havadaydı — düzeltildi, yeniden çekildi). | eskide kutu korkuluğun üstünde azap bütün görünür |
| 04 kazan | Sur yolunda kazancı ve savunucu, kazanın ateşi, sağda korkuluğa yaslı stauroma fıçıları ve kazık, iki yanda dişler; oturuyor, havada yok; eskisinden zengin. | eskide kazancının sırtı + kutu korkuluk |
| 05 barikat | Savunucuların arasından aşama-2 barikatı (kazık, fıçı, kum torbası); yakın kadraj, havada yok. | aynı kadraj |
| 06 poterna | İç surda kemerli küçük kapı, kanat peribolosa açık, karanlık geçit, fenerli nöbetçi, sağda yuvarlanmış fıçı; kapı eteğin üstüne oturuyor; **iyi**. | eskide kutu kanatlı kapı |
| 07 taşıma | Giustiniani sırtüstü taşınma pozunda (ayak ucundan), arkada baş ucundaki taşıyıcı; yakın, eskisiyle aynı kadraj. | aynı |
| 08 kapı/final | Caddeden Romanos iç kapısı açık, koridorda beyaz atlı Sultan, ötede dış kapı; **kötü**: kapının iki yanında iç surun dibinde kutu gibi gri taş blokları (görünüşe istek 3). | eskide açık kutu kapıdan gedik |

#### Bütçe (26; aynı kod, aynı anlamdaki kamera; `TASIMA8KARE … cizim ilkel`, 4 karenin ortalaması)
| Kare | Eski çizim / ilkel | Yeni çizim / ilkel | Sınır (yeni ≤ eski + %5) |
|---|---|---|---|
| 01 açılış | 10327 / 12,19 M | 6434 / 8,03 M | ✓ |
| 02 ok demeti | 1152 / 3,08 M | 840 / 1,59 M | ✓ |
| 03 merdiven | 6830 / 10,27 M | 6318 / 9,51 M | ✓ |
| 04 kazan | 9350 / 10,15 M | 7391 / 8,17 M | ✓ |
| 05 barikat | 7714 / 11,80 M | 7462 / 10,93 M | ✓ |
| 06 poterna | 1051 / 4,30 M | 512 / 1,85 M | ✓ |
| 07 taşıma | 911 / 3,55 M | 593 / 2,18 M | ✓ |
| 08 kapı/final | 8068 / 11,31 M | 2342 / 3,84 M | ✓ |

### 2.2 Kareler (26o) — `kare/26o/eski_an_NN_*.jpg` | `kare/26o/yeni_an_NN_*.jpg`
| Kare | Yeni (tek cümle) | Eski ↔ yeni |
|---|---|---|
| 01 açılış | Gece ovadan yeni sur ve kuleler, dayalı merdivenlerde tırmananlar, sura koşan ordu, pavez siperler, meşale; havada yok; **pavez siperler kutu gibi** (eski kod, iki sette aynı); üstteki kırmızı bant fesin kenarı (HUD). | eski kutu sur |
| 02 su fıçısı | İki on köşeli silindir fıçı, su yüzü, arkada bekleyen saflar, çayır; oturuyor; eskisiyle aynı. | aynı |
| 03 kıyı/merdiven | Hendek kıyısındaki bölüğün arasından surdaki merdivenler, tırmananlar, ateş ve duman; havada yok; eskisinden zengin (sur dili). | |
| 04 dolgu | Hendeğin ortasında dolgunun üstünde gediğe yürüyen bölükler, iki yanda surda merdivenler; herkes dolguya basıyor. | eski dolgu kutu set |
| 05 tırmanış | Terastan dış surun yüzüne dayalı 14,35 m'lik merdiven (alt basamaklar), yanında yerde bir saldıran; oturuyor; merdiven eskisinden uzun (teras 3,7 m aşağıda). | |
| 06 sancak | Kule tepesi basamağından sancak kulesi (x 35,4) ve kırmızı sancak; **sancak düz levha (`Props.box`), kutu gibi** (eski kod); havada yok. | eskide miğfer kadrajı kapatıyor |

#### Bütçe (26o)
| Kare | Eski çizim / ilkel | Yeni çizim / ilkel | Sınır |
|---|---|---|---|
| 01 açılış | 7190 / 4,99 M | 5337 / 3,73 M | ✓ |
| 02 su fıçısı | 7760 / 9,44 M | 6982 / 9,19 M | ✓ |
| 03 kıyı | 5880 / 4,56 M | 4954 / 3,79 M | ✓ |
| 04 dolgu | 3117 / 2,59 M | 2623 / 2,33 M | ✓ |
| 05 tırmanış | 1120 / 2,05 M | 964 / 1,37 M | ✓ |
| 06 sancak | 1197 / 2,86 M | 2241 / 3,87 M | **✗ (+87 % / +35 %)**: eski karede bir savunucunun miğferi kadrajın yarısını örtüyor ve eski kule ovayı kapatıyor; yeni kamera kule basamağında (y 11), ovaya ve ordugâha açık bakıyor. Aynı noktadan bakış değil; kök neden ölçülmedi (ova SiegeField'in çizim sayısı görünüşe ait). |
