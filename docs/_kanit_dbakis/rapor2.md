# Bakış düzeltmesi, ikinci küçük tur — `wip/duzeltme-bakis`

Taban (ÖNCE) = dalın önceki ucu `38be72d9`. SONRA = bu tur. Koşular `~/w/once` ve `~/w/sonra` kopyalarında (scripts ayrı, varlıklar sembolik bağ); ikisine de aynı geçici sonda (`WPSAMPLE/WPSHOT/GSERIES`, yalnız scratch) konuldu, depoda yok. Godot 4.4.1, başsız `--max-fps 20`; ekranlı koşular `xvfb-run`, `PACE=1`.

## Yapılan değişiklikler (5 dosya)
- `scripts/npc/person.gd`: yeni `discount_move(step)`: itme ya da ışınlama kaymasını kişinin kendi yürüyüşünden düşer (`_last_pos` ve bakış denetiminin son konumu). `_clear_way` itilene bunu uygular. `look_target == null` kolunda yürüme eşiği 0,6 → 0,35 (çıkış 0,25, `_walk_face` histerezisi; `Stage.gaze_dir`, `rig.gd` ve `_look_audit` ile aynı). `look_target` kolunda yürüyüşün ilk 0,3 sn'sinde dönüş oranı 4 → 10.
- `scripts/level/stage.gd`: `gaze_dir` yürüyüş açıldığında `gaze_walk_t` damgası; `approach`'ın otomatik test ışınlama dalı yürüme saymaz (`discount_move`).
- `scripts/chapter8y.gd`: mızrağı geri alma tek karede ışınlanmak yerine 0,3 sn'lik tween (`_d(0.3)`, süre değişmez, beklenmez).
- `scripts/autoload/game_state.gd`: `look_audit_shift` (yukarıdaki kaydırma için); `_look_audit` artık `no_audit` yerine `no_look_audit` metasını atlar (`no_audit` kişileri de bakış denetimine girer; hiçbir yere `no_look_audit` konmadı). Denetim gevşemedi, kapsamı genişledi.
- Değişmeyenler: replik, süre, sayaç, kazanma/kaybetme, denge, kalabalık, bot yolu.

## Madde madde

| # | Madde | Hüküm | Kanıt |
|---|---|---|---|
| 1 | İtilen kişi dönmesin; Bölüm 20 `lose` ×20: Giustiniani `raw kind=walk` 0 ve `backturn` 0 | **DÜZELDİ** | Başsız 20 koşu, hepsi PASS. `backturn`: ÖNCE 5 → SONRA **0**. Giustiniani `raw kind=walk`: ÖNCE 16 → SONRA **0** (ilk SONRA turunda 1 kalmıştı: `Stage.approach` otomatik test ışınlama kolu; ışınlama da yürüme saymayacak şekilde düzeltilip 20 koşu YENİDEN koşuldu; sonuç bu satır). Ekranlı koşu (Giustiniani yaw serisi, 0,25 sn örnek): hareketliyken (hız >0,3) >40° pivot ÖNCE **11**, SONRA **0**; durup dönen (sahne betiği) ÖNCE 6, SONRA 5. Kare: `pafta4_b20_itme.jpg` (ÖNCE 0,57 m/sn gövde 34° sapık yürüyen Giustiniani; SONRA itilirken oyuncuya dönük kayıyor, 0,40-0,45 m/sn). İki kare görsel olarak benzer; asıl kanıt sayısal seri. |
| 1b | İtme olan başka üç bölüm aynı sayım | **KISMEN** | Başsız, varsayılan yol, tek koşu, ÖNCE / SONRA: 12: raw 0 / 0; 26: 1 / 0; 17: raw 4 (walk 1) / 4 (walk 1); 28o: 1 (walk 1) / 1 (walk 1); 35o: 12 (walk 0) / 12 (walk 0). `backturn` hepsinde 0. Bu bölümlerde itme olayı az: fark yok, gerileme de yok. |
| 2 | Yürüme eşiği 0,35 / çıkış 0,25; ekranlı kareler 17, 20, 26, 28o, 31o | **KISMEN (kod DÜZELDİ, kare KANITSIZ)** | Kod tek eşik. Ekranlı örnekler (0,35-0,6 m/sn, ekranda, 1,5-10 m), >35° olanlar ÖNCE / SONRA: 20: 69 örnekte 7 / 58'de **3**; `look_target`'sızlarda 66'da 7 / 53'te **0**. 26: 75'te 30 / 90'da 48: büyük açılar merdivendeki ve dövüşen kişilerde (`climb_a/b`, ikili dövüş gövdeleri); `act=""` olup 84-97° ve ~178° sapanlar iki ağaçta da var, kim oldukları çözülmedi. 17: örneklerin ~%95'i kayıktaki kürekçi (`act=row`, taşınıyor, yürüme değil). 28o: iki ağaçta uygun örnek yok. 31o: ÖNCE 1, SONRA 0 örnek. Kare: `pafta5_b17_b26_yuruyen.jpg` (17 Fatih 16° ÖNCE/SONRA; 26 üstten kamera, **yetersiz**). 28o ve 31o için kare çifti **YOK**. |
| 3 | Yürüyüş başında gövde hızlı dönsün | **KISMEN** | Uygulandı (`gaze_walk_t`, ilk 0,3 sn dönüş oranı 10). 17 Radu ve 28o Urban `raw walk` (146° / 140°) ÖNCE ile aynı sayıda; denetim ilk aşımı `raw` yazar, `backturn` 0. Etkisi ölçülmedi. |
| 4 | 8y mızrak geri alma "pop" | **DÜZELDİ (kod), kare KISMEN** | `spear.reparent(…, true)` + 0,3 sn tween. 8y ekranlı `PACE` koşu, kare 1/0,5 sn: `pafta1_8y_kapi.jpg`, `pafta2_8y_cekme_mizrak.jpg` (ÖNCE ve SONRA aynı replik anına mtime ile hizalı): kanat çekme ve nöbetçi hareketi aynı, kapı açılışı bozulmadı. 0,3 sn'lik tween 2 sn aralıklı karede görünmedi; "pop yok" yalnız kodla iddia edilir. |
| 5 | `_look_audit` `no_audit`'a değil `no_look_audit`'a bakar | **DÜZELDİ** | 30 bölüm paketinde (12b dahil) `LOOKAUDIT backturn` 0; yeni ölçülen kişilerden yeni satır çıkmadı (35o `grip` raw 12, ÖNCE'de de 12). |
| 6 | (not) `hud.gd:_turn_speaker` test dalı | **YAPILMADI** | zorunlu değil, görev dışı dosya |

Kapı açan kişiler: 8y yukarıda. Bölüm 4: `pafta3_b4_kapi.jpg` (`chain`, `D4B_N_GATE` çevresi, ÖNCE|SONRA hizalı). Kapı açılışı 1,2 sn sürdüğünden 0,5 sn'lik örneklemede kapıyı açma anı yakalanmadı: KISMEN. Önceki turun karesi (`pafta1_8y_kapi_ONCE_ustte_SONRA_altta.jpg`) duruyor.

## Kendi karelerime bakınca hâlâ kötü olanlar
- **26**: kare yetersiz; `act=""` olup >35° sapan yürüyenlerin kimliği çözülmedi (ÖNCE'de de var). Düzeldi denemez.
- **28o, 31o, 17**: yürüyen yüzün gidiş yönüne baktığını gösteren kare çifti yok (17 Fatih karesi diyalog anı, kişi kameraya dönük görünüyor).
- **8y nöbetçi** (`Soldier[SPK_CITY_GUARD]` `kind=grip` 128° `backturn`): ÖNCE'de de aynı (126°), ekranlı `PACE` koşusunda iki ağaçta çıkıyor; bu turun getirdiği değil, düzeltilmedi. ÖNCE'de ayrıca Hasan `walk` raw 176° vardı, SONRA'da yok.
- **Bölüm 4 `PACE` koşusu**: `VISAUDIT insolid SeaWalls` + `WALKTHRU` iki ağaçta aynı; başsız paketteki Bölüm 4'te çıkmıyor. Bu tur kaynaklı değil, düzeltilmedi. (Yasak satır kuralı başsız paket için sağlandı; ekranlı `PACE` Bölüm 4 bu kuralı iki ağaçta da ihlal ediyor.)
- Raw satırlar: 17 (3 `grip` denizci, 1 Radu `walk`), 28o Urban `walk`, 35o 12 `grip`: ÖNCE ile aynı.

## Testler
- `PARSECHECK PASS scripts=248`.
- 30 bölüm başsız (0, 2, 4, 6, 6b, 7, 8, 8y, 9, 10, 10b, 11, 12, 12b, 17, 17o, 19, 20, 20o, 22o, 24, 26, 26o, 28o, 30, 30o, 31o, 35o, 38o, 43o), varsayılan yol: **30/30 `AUTOTEST PASS`**; `SCRIPT ERROR, WARN_FX_STUCK, WARN_FLY_ITEM, VISAUDIT, WARN_VOID_TELEPORT, WALKTHRU, ARMAUDIT, HELDAUDIT, JOURNEY_*, LOOKAUDIT backturn`: **0** (son kodla).
- Bölüm 20 `lose` ×20: 20/20 PASS, backturn 0, raw 0, yasak satır 0.
- Ekranlı: 4 `chain`, 8y, 17, 20, 26, 28o, 31o: PASS (not: yukarıdaki PACE bulguları).
- Yalnız bu liste koşuldu; bu ağaçta diğer varyantlar (8y, 9, 10, 20 vb.) KOŞULMADI.
- RINFO / performans: **BAKILMADI** (yeni mesh/çizim yok; yalnız mantık).

## Ortak dosya önerisi
`hud.gd:_turn_speaker` test dalı ve `chapter17.gd` grip sahneleri bu turun kapsamı dışında.
