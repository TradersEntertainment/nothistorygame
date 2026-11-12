# Düzeltme turu: bakış yönü — geliştirici raporu (`wip/duzeltme-bakis`)

ÖNCE = dalın başlangıcı (`2f35c591`, ayrı çalışma ağacı); SONRA = bu daldaki son kod. Özgün (yayın) = `e551de84`.
Başsız koşular `--max-fps 20`, 3 paralel. Ham veri: bu klasördeki `ham_test_satirlari.txt`, `kosu_ozeti_*.txt`, `sayface_*.txt`.

## Madde madde

| # | Madde | Durum |
|---|---|---|
| 1 | Yürüyüş eşiği 0,35 (çıkış 0,25), `_look_audit` aynı | **KISMEN.** `stage.gd:gaze_dir` ve `game_state.gd:_look_audit` değişti. Ölçüm (geçici sonda, söküldü; 17/20/26/28o/31o başsız): 0,35-0,6 m/sn arası 21 örnekten 17'si ≤ 24°, 4'ü >35° (48, 62, 85, 165). Bölüm 20 Giustiniani 0,40-0,52 m/sn örnekleri: 0, 0, 15, 24° (yürüyüş başında bir örnek 85°: dönüş geçişi). Bütün örneklerde (≥0,6 dahil) 102 örneğin 32'si >35°: bunlar yürüyüş başı/yön değişimi, kararlı yürüyüşte açı küçük. Ekranlı kare çifti YOK (17, 26, 28o, 31o, 35o: KANITSIZ). 35o'da yürüyen örnek çıkmadı |
| 2 | `D9_KADRI_OFFER_1`, `D9_URBAN_OFFER_1_PLAIN` SAYFACE | **DÜZELDİ.** Kök neden denetçinin dediği: `hud.gd:_turn_speaker` alet işindekini testte döndürmüyordu; öneri A uygulandı (`lt == p and _fast()` istisnası). `chapter9.gd` ve `chapter10.gd` `face_toward` satırları kaldırıldı. Son SONRA koşusunda her ikisi de yok; ayrıca `D10O_K_COME` da kayboldu. Yeni SAYFACE anahtarı yok (`D39O_SA_02` rastgele, ÖNCE'de de iki kez çıkmıştı, bu koşuda ÖNCE'de yok / SONRA'da var: dalgalı) |
| 3 | Süre: Bölüm 4 `_niko_opens_gate`, 8y `_open_gate` | **DÜZELDİ (8y ölçüldü), 4 yalnız hesap.** 8y `await _open_gate()` süresi (`PACE=1`, başsız, oyun süresi): özgün 7,60 sn, ÖNCE 9,80 sn, SONRA 7,62 sn. Bölüm 4: `autotest` altında süre sabit 0,05 olduğundan ölçülemedi; kodda özgün 1,2 sn, ÖNCE 0,7+1,2 = 1,9 sn, SONRA 0,3 (dönüş) + 0,9 (kanat) = 1,2 sn. Kişi işine dönük: 4'te Niko kanatlara dönük, 8y'de nöbetçi kanada dönük çekiyor. 8y yeni hareket: nöbetçi sol kanadın tutamağını iki eliyle tutup ~35° çekiyor, sonra kanat savrulurken süpürme alanından önce çıkıp `GUARD_AT`'a gidiyor (sağ kanat birlikte açılır, o kanadı kimse tutmuyor: sol kanada bağlı gibi simetrik). Hızlı testte (`Stage.fast()`) nöbetçi önce yerine ışınlanıp kanatlar açılıyor: aksi hâlde kare atlaması `WALKTHRU` basıyordu (7 satır, düzeltildi) |
| 4 | Bölüm 20 `LOOKAUDIT backturn` on koşu | **KISMEN.** Varsayılan varyant on koşu: backturn 0, 10/10 PASS. `lose` varyantı sekiz koşu: 0. Ama bütün paketin son koşusunda (111 koşu) `--chapter=20 --autotest=lose` bir kez Giustiniani `walk` 146° iki ardışık örnek verdi (ÖNCE'de aynı koşuda yoktu). Nedeni: dövüş sırasında yön değişimi, denetim 0,25 sn'lik ortalama hareket yönüyle ölçüyor. Tekrarlanamadı (8/8 temiz). "0 olmalı" tam sağlanmadı |

## Testler (son kod, 111 koşu: `kosu_listesi.txt` = bütün bölümler varsayılan + 4, 8y, 9, 10, 10b, 17, 20 bütün varyantlar)
- `parse_check`: PASS (248). 111/111 `AUTOTEST PASS` (ÖNCE da 111/111). `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `VISAUDIT`, `WARN_VOID_TELEPORT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `JOURNEY_*`: 0.
- `LOOKAUDIT raw`: ÖNCE 44 → SONRA 51. `LOOKAUDIT backturn`: ÖNCE 0 → SONRA 2: (a) Bölüm 20 `lose` Giustiniani walk 146° (madde 4); (b) Bölüm 10 `fail` Kadri `chop` work 132°: Kadri oyuncunun 3 m içinde (tasarım gereği döner), denetim bunu "iş sırtı" sayıyor; ÖNCE'de aynı Kadri'de raw 104° vardı. İlk SONRA turunda (8y düzeltmesinden önce) ayrıca Bölüm 17 `ship_ok` üç `grip` backturn çıktı (kurtarılan denizciler); ÖNCE'de aynı satırlar `raw`. Son turda çıkmadı: dalgalı. Kök neden `chapter17.gd:826` (yasak dosya): `look_target` yok, gövde yönünü sahne betiği belirliyor; denendi (`s.look_target = player`) ve düzeltmedi, geri alındı.
- SAYFACE: ÖNCE 27 anahtar, SONRA 25 (`sayface_ONCE.txt` | `sayface_SONRA.txt`): `D9_KADRI_OFFER_1`, `D9_URBAN_OFFER_1_PLAIN`, `D10O_K_COME` gitti; `D39O_SA_02` (rastgele) geldi.
- Başsız komşular: bütün bölümler koşuldu (3'ten fazla).

## Kare
- `pafta1_8y_kapi_ONCE_ustte_SONRA_altta.jpg`: ekranlı `PACE` koşusu, kapı sahnesi, her koşudan 8 kare (üst iki sıra ÖNCE, alt iki sıra SONRA; aynı an değil, aynı sahne bölümü). SONRA'da nöbetçi kanada dönük, el kanatta, mızrak yerde; kanatlar açık. Kare eşleşmesi zayıf, kamera sabit değil.

## Yapılmayanlar / bakılamayanlar
- Bölüm 4 kapı karesi: ekranlı koşu alınmadı (KANITSIZ); süre yalnız hesap.
- Bölüm 17, 20, 26, 28o, 31o, 35o yürüyen kare çiftleri: YOK (KANITSIZ); yalnız sayısal ölçüm.
- RINFO üç örnek (çizim/üçgen ÖNCE | SONRA): ÖLÇÜLMEDİ (BAKILMADI). Yeni mesh yok (8y'de yeni gövde/mesh eklenmedi; mızrak aynı düğüm).
- Madde 4 tam sıfır değil (yukarıda); Bölüm 10 `fail` ve 17 `ship_ok` backturn'leri denetim/yasak dosya kaynaklı.
- 12 pafta sınırı: 1 pafta verildi.

## ORTAK DOSYA ÖNERİLERİ (uygulanmadı)
1. `scripts/npc/person.gd:841`: yürüme eşiği `0.6` → `0.35` (ayrı `look_target == null` kolu; `stage.gd` ile tutarlı olsun). Hız `delta` ile ölçülüyor, çıkışta 0,25 histerezisi.
2. `scripts/game_state.gd:_look_audit` "work" türü: oyuncu 3 m içindeyken (`Stage.gaze_dir` bunu konuşma sayar) ölçmesin; aksi hâlde Bölüm 10 Kadri yanlış alarm veriyor. (Bu dosya benim listemde ama "susturma yok" kuralı yüzünden değiştirmedim.)
3. `scripts/chapter17.gd:_pull`: tutulan denizcinin gövdesini bileğe çeviren bir adım yok (denendi: tek başına `look_target` yetmedi).
