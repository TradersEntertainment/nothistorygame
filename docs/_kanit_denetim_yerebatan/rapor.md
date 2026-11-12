# Bağımsız denetim — Bölüm 44 Sarnıç (`chapter44b`)

Denetçi dalı `wip/denetim-yerebatan`; denetlenen `wip/bolum-yerebatan` (33662898). Oyun koduna dokunulmadı (`git status`: izlenen dosyada değişiklik yok; yalnız `.import` üretimleri, kaydedilmedi).
Kendi koşularım: ekranlı (xvfb, `PACE=1`) iki koşu: (a) `--dialogshots --snapevery=0.5` (640×360 kareler, 917+), (b) `x11grab` ile **1280×720 gerçek ekran videosu** + RINFO (kareler `p02…p08`). Bot oyuncudur; kamera oyuncu kamerasıdır. Sonda karesi kullanılmadı.
Ölçüt notu: botun süreleri gerçek oyuncunun alt sınırıdır.

## Madde madde hüküm

### 1. HAYRANLIK — **7 / 10**
- İniş: **KISMEN/YANLIŞ.** Kuyu içi (≈15 sn; `p01` sol üst) **dokusuz, düz kahverengi kubbe**, ortada tek nokta; Tolga "bu genişliyor" derken ekranda hiçbir şey genişlemiyor. Sonra kesme ile suda yüzer (`chapter44b.gd:_descend` 282–320). Hayranlık öncesi ilk 15 sn en zayıf yer.
- Karanlık an (`p01` sağ üst): kare karanlık ama okunur (ortalama 38/255); ancak havada **dış çizgili beyaz oval "balon/yapışkan" zerrecikler** (toz, `cistern.gd:658` `_dust_mat`) sütunların önünde; ışık açılınca kayboluyor. Hayranlık öncesi ilk izlenim "baloncuk": **KUSUR** (ÖNCE'de yok, yeni bölüm).
- Açılış anı (`p02`, `p03`): **DOĞRULANDI, güçlü.** İki yakın sütun, arkada ~7 sıra sütun, kıvrık/oluklu başlıklar, tuğla tonoz turuncu kostik çizgileriyle, sütunların suda **inandırıcı ters yansıması**, su çizgisinde ışık. Ortam ışığı 2,5 sn'de açılıyor: iyi sahnelenmiş. Zayıflık: sütun gövdelerinde "alev gibi" siyah lekeler (başlık/oluk deseni karanlık yama gibi okunuyor); yan duvar/tonoz ucu uzakta karanlığa gömülü, "138×65 m" hissi sınırlı (en çok ~35 m görünür).
- **Parlaklık (kendi ölçüm, 8-bit gri):** açılış anı ort. 37–42, medyan 10–21, en parlak %5 ort. ≈156–163 (≈%55 piksel <20). Kürek evresi: ort. 20–22, medyan 3, en parlak %5 ≈134–167, **%73–79 piksel <20**; sarsıntı evresi ort. 21–29. Yani oynanış karesi geliştiricinin sonda karesinden belirgin karanlık; fener konisi dışı neredeyse siyah (ölü alan). Bilinçli gizem ama ödül anından sonra 4+ dk bu karanlık sıkıcı.
- Medusa (`p07`, `p08`): **YANLIŞ/KANITSIZ okunabilirlik.** Kayıktan oynanışta kafa bir **kutu (kaide küpü)** gibi görünüyor, yüz kabartması küpün yan yüzünde ~40 px, karanlık, ters/yan ayrımı okunmuyor; çevresinde kadrajın yarısını kayık burnu kaplıyor. Yoldan geçerken (sütun ormanı boyunca) Medusa yok (köşede zaten); yani "kaç metreden seçiliyor": ≈3 m'de, o da ancak kandil açıkken ve bakılırsa. Ters/yan doğruluğu: **KANITSIZ** (karede seçilmiyor). Gözyaşı sütunu: oynanışta karşılaşılmadı, **KANITSIZ**.
- Sütun/tonoz: 12×28 aralıkları doğru görünüyor, çapraz tonoz ve kemer bandı var; kutu gibi parça yalnız Medusa kaidesi; havada duran: toz "balonları" (yukarıda). Çifte gölge yok.

### 2. HEYECAN — **5 / 10**
- Kayık+kürek ritmi çalışıyor, hedef mesafe sayacı ve pil yazısı var (`p04`). **İlk kürek evresi ≈124 sn, hiçbir tehdit yok** (127→251 sn): gerilim yok, görüntü hep aynı koridor.
- Sarsıntı evresi (`p06`): ≈70 sn kürek; tuğla düşüşü **neredeyse görünmüyor** (36 karede 1 turuncu tuğla; halkalar çok ince). Test botunda `hits=0`: tehlike gerçek bir oyuncuyu bile nadiren ıskalatıyor. Süre sayacı ("95 sn") ve pil var ama ölümcül tehlike/kovalama yok; en gergin an pilin bitmesi ("tuğla" şakası).
- Adalet: **iyi.** Süre dolarsa kayıp yok, Yakovos çeker (`dark` varyantı PASS, 3/3). Karanlıkta sıkışma yok (kayığı rota/çarpma durdurur, `bumps=1–2`). Suya düşme yalnız iniş anında; yeniden deneme gerekmez (kayıp yok). Sonuç: adil ama **gerilim yok**; "heyecanlı bölüm" isteği KISMEN.
- Süre: bot ≈8,2 dk (yükleme dahil 38 sn); gerçek oyuncu tahmini 10–12 dk. Çıkış tırmanışı: **≈20 sn tam siyah ekran** (`v_0426`, ortalama 0,2/255; `chapter44b.gd:594 _climb`, fade 0.7 sn sonrası) — "Kırk basamak" repliği siyah ekranda: **KUSUR**, oynanış boşluğu.
- HUD: "Pil: %N" yazısı ekranın ortasında nişangâh/hedef işaretiyle ve Yakovos'un gövdesiyle üst üste (`chapter44b.gd:957`): **KÜÇÜK KUSUR**.

### 3. GİRİŞ ve ÇIKIŞ
- Avlu/Eudokia/kuyu (`p10`): okunur, çocuk (24.1) varyantı PASS; kuyuya iniş **KISMEN** inandırıcı (yukarıdaki düz kahverengi). 24 → 44 → 25 sırası: `Siege.ORDER` 24,43,44,25; `creator_check` bkz. test tablosu. Osmanlı: 24o→25o akışı bozulmadı: **DOĞRULANDI** (`chapter43o` PASS; 44'ün yalnız `chapter44b.tscn`'i var, `scene_path` Osmanlı'da atlıyor).
- İki sonuç: 44.1/44.2 gerçekten ayrışıyor **ama hafif**: Bölüm 25'te tek replik (`D25_E_CISTERN_1/2`), akıbet sayfası, başarım; `check_outcomes` 76/76. Dünya sonucuna etki yok (tasarım gereği). Ayrışma "var" ama ağırlığı düşük.

### 4. TARİH
- Çekirdek DOĞRU: unutulmuş sarnıç, kuyudan su/balık, Gyllius 1540'lar "bir Fransız", Saray'ın Blaherna'ya taşınması, 336 sütun, kuyu üstü evler. "1985" Nihat'ın çamur repliği sorun yok ama:
- **İÇ ÇELİŞKİ (KUSUR 1):** `D44B_N_MEDUSA` "1985'te çamurdan çıkacaklar" (yani 1453'te çamurda, görünmez) ↔ `D44B_Y_STONE` ("Taş kadınlar. Annem onlara bakma derdi") ve `D44B_Y_MEDUSA` ("kırk yıldır bakıyorum") ↔ oyunda suyun 0,7 m altında görünüyor. Tasarım belgesi bunu "uydurma, ödül anı" diye kaydetmiş ama replik "kırk yıldır bakıyorum" tarihî iddia (kimse bilmiyordu) ile çatışıyor: Yakovos Medusa'yı biliyorsa Gyllius'un "kimse bilmiyordu"su zayıflar.
- **Anakronizm (küçük):** Nihat (1977 Büro) "1985'te" der: Büro zaman dışı olduğundan savunulabilir; not.
- "Saray Blaherna'ya taşınalı çok oldu": doğru. "Mahalle kuyuları taşla doldurur" (`D44B_Y_BLAB`): uydurma, Gyllius'un kuyularla su çektiğiyle çelişmez ama "kesin bilgi" gibi söylenmiyor, kabul.
- `D44B_T_AWE_3` "Üç yüz otuz altı sütun. Rehber söylemişti": Tolga'nın bilgisi, uygun.

### 5. REPLİK
- Sayı: `yeni_replikler.txt` **64** (62+2) replik; görevde "66" deniyordu. `strings.csv` +106 anahtar (64 replik + 42 arayüz). **Fark not: görevdeki 66 ≠ 64** (KANITSIZ hangi 2 eksik; tahminim UI satırları sayıldı).
- `git diff 99df39c5 HEAD -- i18n/strings.csv`: **106 ekleme, 0 silme/değişiklik: DOĞRULANDI.** İngilizce: 64/64 dolu, TR'ye eşit değil; anadil okuması yok (geliştirici de söyledi).
- Ses/üslup: Nihat kulaklıkta (Hikmet susuyor): canon'a uygun. Tolga mizahı iyi ("navigasyonsuz otopark", "tuğla"). Yakovos'un "Türk mü?/sigortacı" şakası dönemine uygun. Sorun: `D44B_Y_KEEP` "Sağ ol, sigortacı" (Yakovos "sigortacı"nın ne olduğunu sormuştu, `D44B_Y_02`; sonra kullanması tutarlı ama "torunumun torunu … Senin gibi bir yabancıya" biraz fazla bilir). Küçük.
- **KUSUR 2:** `docs/voice/VOICE_MAP.csv` bu dalda **~5.800 satır "değişmiş" görünüyor** (CRLF→LF; `git diff --ignore-cr-at-eol`: yalnız +64). Gerçek içerik eklemesi 64 satır ama diff gürültüsü gözden geçirmeyi bozar; satır sonu korunmalı.

### 6. TEKNİK
- `parse_check`: **PARSECHECK PASS scripts=250.**
- Başsız (`--max-fps 20`), her varyant **3×**: ``""``(a1-3), `blab`(b1-3), `dark`(d1-3), `kid`(k1-3), `nophone`(n1-3): **15/15 AUTOTEST PASS**. Komşular: 25 (`""`,caught,pass,kid,osm,osm_caught,osm_tez,cistern,cistern_blab) 9/9; 24 (`""`,late,niko,niko_slow,eclipse) 5/5; 23, 42b, 36b, 43o 4/4 PASS. Yasak satır (`SCRIPT ERROR`, `WARN_*`, `VISAUDIT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `LOOKAUDIT`, `JOURNEY_*`) **sıfır** (ham log: `log_*.txt`; yalnız çıkışta motorun `Pages in use… PagedAllocator`/"resources still in use" gürültüsü). Üç tekrarın tamamı aynı sonucu verdi.
- `tests/check_*.py` (8) hepsi PASS/0 sorun; `journey_data --check` ok. `tests/run_tests.sh` tam paketi ve `creator_check` KOŞULMADI (BAKILMADI): menü sırası (24→44→25) yalnız kod okumasıyla (`Siege.chapters`).
- Performans (RINFO, ekranlı; **ffmpeg kaydı aynı anda koştu, süreler şişik**; `rinfo_rec1.txt`): sarnıç evrelerinde çizim 252–384 (≤600 ✔), üçgen 0,56–0,90 M (≤1,5 M ✔), görünür 0,28–0,59 M, gölge ≤311k. `proc` 136–750 ms/kare: yazılım çizimi (llvmpipe) nedeniyle **60 FPS KANITSIZ**. Işık sayısı: kodla sayıldı: en çok eşzamanlı Omni/Spot = fener(Spot)+dolgu+çakmak+2 huzme+kuyu ağzı+meşale+Medusa kandili ≈7–8 (gl_compatibility nesne başına 8): sınırda; ışık titremesi/sönmesi karelerde görülmedi (KISMEN: ölçülmedi).
- Ses (yankı/damlama/su): kodda var (`Audio.voice_space("hall")`, `splash`, `rumble`); bu makinede ses çıkışı yok → **KANITSIZ (duyulmadı)**.
- Kapak/menü/akış şeması/başarım: kodda var (diff incelendi); görsel doğrulanmadı.
- Test iskelesi: `chapter44b.gd:1188 _run_shots` ve `--shots` yolu sürüme girmiş (ajan kuralları 3: "sürüme test iskelesi girmez"): **KÜÇÜK KUSUR** (öncekilerde benzeri var mı: bakılmadı).

## Yeni kusurlar (özet; ÖNCE = bu bölüm yeni, öncesi yok)
| # | Kusur | Yer |
|---|---|---|
| K1 | Kuyu inişi düz kahverengi, ~15 sn | `chapter44b.gd:282 _descend`, `cistern.gd` kuyu bacası |
| K2 | Karanlık anda dış çizgili beyaz oval toz zerrecikleri (balon) | `cistern.gd:658–750` |
| K3 | Çıkış tırmanışı ≈20 sn siyah ekran | `chapter44b.gd:594 _climb` |
| K4 | Medusa kaide küpü olarak, ~40 px, yüz okunmuyor | `cistern.gd:854–970`, `chapter44b.gd:512 _medusa` |
| K5 | İlk kürek evresi 124 sn tehdit yok; tuğla görünmüyor | `chapter44b.gd:1033–1098` |
| K6 | Medusa/balıkçı replik çelişkisi | `strings.csv` D44B_Y_STONE / D44B_Y_MEDUSA / D44B_N_MEDUSA |
| K7 | VOICE_MAP satır sonu gürültüsü | `docs/voice/VOICE_MAP.csv` |
| K8 | "Pil %N" ekran ortasında kişiyle üst üste | `chapter44b.gd:957` |
| K9 | `_run_shots` iskelesi sürümde | `chapter44b.gd:1188` |

## GENEL HÜKÜM: **KÜÇÜK DÜZELTMELERLE KABUL**
Teknik zemin sağlam (15/15 + komşular PASS, yasak satır sıfır, replik yalnız ekleme, bütçe tutuyor). Hayranlık anı gerçekten çalışıyor; heyecan ve Medusa ödülü zayıf.

### ZORUNLU
1. K3: tırmanış sırasında siyah ekranı kaldır (kuyu basamakları/Yakovos'un kileri görünsün ya da fade'i ≤2 sn yap).
2. K1: kuyu inişinde baca taşları ve ip görünsün (dokulu taş duvar, ışık huzmesi yukarıda küçülen daire).
3. K2: toz zerreciklerini dışı çizgili ovalden yumuşak yuvarlak nokta yap; karanlık evrede görünmesin ya da küçüt.
4. K4: Medusa kafası kayık konumundan ≥%15 kadraj yükseklikte, kandil önde, yüz yön okunur (yan/ters seçilir); aksi hâlde Tespit karesini yakın plana çek.
5. K6: ya "Ben kırk yıldır bakıyorum"/"Annem onlara bakma derdi" ya da Nihat'ın 1985 repliği tutarlı olsun (örn. Yakovos yalnızca kandil ışığıyla "bu gece ilk kez görüyorum" der).
6. K7: VOICE_MAP'te CRLF'yi geri getir (yalnız 64 satır eklemesi görünsün).

### DAHA İYİ OLURDU
- Sarsıntı evresinde görünür düşen tuğla (büyük, kayığa 2–3 m), suya sıçrayan halka, tavandan toz kesintisi; kayık sütuna girip sıkışan bir "daralan geçit" anı.
- İlk kürek evresine kısa bir olay (balık sürüsü, ilk küçük sarsıntı); Yakovos'un meşalesine varmak 60 sn'yi geçmesin.
- Sütun gövdelerindeki siyah leke deseni; duvarlara/tonoza uzak ışık; çarpıcı bir geniş plan (kayıktan 35 m ötesi sis).
- Pil yazısını HUD köşesine.
- Gözyaşı sütununa oynanışta rota (karşılaşılmıyor).
- `D44B_Y_STONE` sonrası Tespit karesi oynanışta botla yalnız 3 sn: gerçek oyuncu karesi bakılmadı.

## Bakılamayanlar
60 FPS, ses, 44.2'nin ekranlı kareleri (başsız PASS), gözyaşı sütunu, tam `run_tests.sh`, `creator_check`.
