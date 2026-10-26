# QA dersleri: bölüm bölüm denetimde bulunan hata türleri ve kontrol listesi

Her bölüm denetiminde ve her düzeltmede bu listeyi baştan uygula. Yeni bir hata türü bulunca buraya ekle
(ne oldu, nasıl anlaşıldı, nasıl önlenir). Bölüm 1 ve 2 denetimlerinden (v0.99.35-36) çıkarıldı.

## 1. Kamera ve kadraj
- **Oyuncuyu bir noktaya taşırken zemini gerçek, görünen çarpışma yüzeyinden ölç.** Seviyenin çizim işlevi (ör.
  `Slipway.surface_h`) tek haritada (World1453) dünyanın arazisiyle uyuşmaz: Bölüm 2'de oyuncu kıyı yerine su altındaki
  kuma iniyordu; kamera su yüzünün altında kalınca gök "gece" gibi lacivert görünüyordu. Görünmeyen çarpışma kutularını
  atla (`hud._is_visible_occluder`, `hud._is_person_part` → `chapter2._ground_y`).
- **Kameranın baktığı yönde ne var, kareye bakarak doğrula.** Bölüm 2 zincir sahnesinde oyuncu kütük hattının tam
  ekseni üzerine kondu: kamera kütüklerin oluşturduğu tüpün içinden karanlığa bakıyordu. Uzun bir nesneye (zincir,
  duvar, gemi) yanından ve çapraz bakılır.
- **Seçilen yerin üstü ve önü boş mu**: fizik ışını yalnız çarpışması olan nesneleri görür; tezgâh damı, sundurma gibi
  çarpışmasız modeller için görünen nesnelerin sınır kutusuna da bak (`chapter2._spot_clear`).
- **Yamaçta yan yana duranlar**: dik arazide yan yana konan iki karakter arasında metrelerce yükseklik farkı olur;
  yükseklik çizgisi boyunca diz, düzlüğü (en çok ~0,6 m fark) kontrol et.
- **Konuşan kadrajda olmalı.** Replik söyleyen karakter sahnede yoksa (Bölüm 2.2: Hasan ile Hüseyin hiç yaratılmamıştı)
  ya da kameranın arkasında kalıyorsa düzelt. Önceki turlarda "TUTMAMIŞ" diye dönen bulguların çoğu bu türdendi.
- **Replik ekrandakiyle çelişmesin**: "Arkamda bir gemi var" derken gemi önde; "kimse görmedi" derken askerler
  Tolga'ya bakıyor (HUD konuşanı oyuncuya çevirir: birbirlerine bakacaklarsa `look_target` ver).

## 2. Animasyon: her hareketin bir hareketi olsun
- Kullanıcı notu (Bölüm 2): "Zincire tutunma animasyonu yok; elimiz hep dimdik duran çubuk gibi." Birinci şahıs elin
  kendi hareketi olmalı: nefes, yürüme/koşma salınımı, bakışla gecikme, zıplama/düşme, suda kulaç, uzanıp tutunma.
- Senaryoda bir eylem anlatılıyorsa (tutunur, tırmanır, düşer, uzatır, verir, alır) ekranda o hareket görünmeli.
  Kontrol: replik ya da sahne notunda fiil var mı → `player` tarafında karşılığı (`reach_grab`, `flail`, `show_prop`,
  `hand_gesture`) çağrılıyor mu.
- Karartmayla geçilen hareketler (kıyıya çıkış) için en azından karartma olmalı; göz önünde ışınlanma olmaz.
- Oyuncuyu yürütmek gerekirse tween'le kaydırma: `move_mode = "script"` + `script_velocity` (adım sesi, kafa ve el
  salınımı gelir; Bölüm 4 `_walk_to`).
- Denge (zincir, ip): `player.balance_arms(eğim)`, bitince `balance_arms(INF)`; düşüşte `flail` + çığlık + su sesi.
- Eşya göstermek (`show_prop`, `show_badge`): sol el eşyayı tutar; kart, kitap, çay havada asılı durmaz (v0.99.37).
- Karakterler arası eşya: verilen şey alanın elinde görünür (`rig.hold_item`, okurken `read = true`); taşınan şey
  taşıyanın elinde yürür (Hikmet'in çay tepsisi), havada süzülmez.
- Yürüyen karakter gideceği yöne döner (`face_toward`); sabit açıyla geri geri yürümez. Bölümlerde ortak yardımcı
  (Bölüm 3: `_walk_hikmet`).
- Sahne notundaki fiil (eğilir, süpürür, bırakır, telsize atılır) bir `emote` ya da hareketle karşılanır.
- Birinci şahıs kol: kolluk omuzdan ele doğru yönelmeli (`Player.FREE_SHOULDER`); sabit açılı kol uzanınca kolluğun ağzı
  kameraya döner. Ekranın kenarına yakın çizilen el geniş açıda devleşir: uzanma noktası ortaya yakın sıkıştırılır.
- Hazır araçlar: `player.reach_grab(nokta)` / `release_grab()` (sol el uzanır, tutunur), `player.flail(sn)` (kollar
  savrulur), suda sol el kendiliğinden kulaç atar; sağ el nefes alır, yürürken/koşarken salınır, bakışla gecikir.

## 3. Zamanlama ve ses
- **Bark sırası HUD'da (v0.99.37):** `hud.bark` çalan bir ayak üstü sözün sesini bekler (en çok 3,5 sn), `hud.say` da
  başlamadan bekler (en çok 3 sn); hemen söylenmesi gereken (çığlık, darbe) `bark(..., true)`. `cut_voice` bekleyen
  bayat sözleri düşürür. Bölüm 3 ses denetimi kesilmelerin çoğunun tek kökten geldiğini gösterdi.
- **Bark'lar birbirini keser.** Aynı karede iki `hud.bark` → ilki duyulmaz. Sonrakini öncekinin ses süresine bağla
  (`_voice_len`, `_delayed_bark`). Önemli satır (garanti uyarısı) sürerken tökezleme repliği atlanır.
- **Duraklatma**: `await get_tree().process_frame` döngüleri menü açıkken de döner; döngü başında
  `get_tree().paused` kontrolü yap. Bekleme süreleri `create_timer(s, false)` (duraklatmada durur).
- **İstem zamanlaması fiziğe uysun**: halat istemi geçerli sıçrama aralığından önce çıkıyordu (erken basan tökezliyor).
- Metin değişince: `docs/voice/INLINE.json` güncelle, değişen anahtarı seslendirme listesine ekle (ses eski metinle
  kalır; altyazı ile ses ayrışır).
- Kayıtlı ama hiç çalınmayan replik (ölü anahtar): ya kullan ya not et. Tersi de var: çalınan ama hiç
  seslendirilmemiş replik (Bölüm 3 Samimi yolunun dört satırı) mırıltıyla geçer; seslendirme listesine ekle.
- Eylemin sesi: mühür, kâğıt, kapı, asansör, çay. Altyazı "gıcırdar" diyorsa ses de gıcırdasın.
- Uyarı ve darbe sözleri (atış uyarısı, "Ay!") `bark(..., true)`: sıra beklerse olaydan sonra gelir (Bölüm 4 rıhtım).
- Dal başına ortam: aynı bölüm dosyası iki yere gidiyorsa (4a ordugâh / 4b deniz surları) sahne `set_meta("ambience")`
  ve `Audio.step_surface` dala göre verilmeli; yoksa denizde ordugâh gecesi, taşta çim adımı çalar.

## 4. Arayüz
- Kolla oynanınca tuş yazıları: `GameState.tr_pad(KEY)` ve `KEY_PAD` çevirisi. Yeni bir istem eklerken ikisini de yaz.
- `tr()` dışında sabit metin olmasın ("Fes: ✓").
- Kartta da varyant: fes kapalıyken "fesli adam" yazmasın (`GameState.line_variant`).
- HUD öğeleri fesin altında okunmuyor: üst ortaya bir şey koyarken fes şeridini ve "Elde" satırını hesaba kat.

## 5. Denetim süreci
- Oyuncu tarafındaki "anında yap" kapıları `GameState.autotest` değil `Player._instant()` (PACE'te jestler oynar);
  bölüm betiklerinde de animasyonu atlayan `if GameState.autotest` kapıları PACE'i hesaba katmalı.
- Otomatik test karelerinde jestler, el hareketleri ve bazı eşyalar görünmez (`hud._fast()`): animasyon denetimi için
  `PACE=1` ile çek (`PACE=1 rshot.sh AD --chapter=N --autotest`), replikler gerçek hızda akar.
- Öldürülen tween `finished` sinyali yaymaz: `kill()` edilebilecek bir tweeni `await tw.finished` ile beklemek oyunu
  dondurur (Bölüm 3 sabotajı). `while tw.is_valid() and tw.is_running()` ile bekle.
- Ajanların "bozuk kare", "karanlık" gibi iddialarını kareye kendin bakarak doğrula (Bölüm 2 dalış karesi sualtıydı,
  bozuk değildi). Kaynağını bulmadan düzeltme: karanlık gök iki ayrı nedenden (su altı kamera, kütük tüpü) çıktı.
- Düzeltmeden sonra aynı sahneyi yeniden çek ve kareye bak; testin geçmesi görüntünün doğru olduğu anlamına gelmez.
- Arka planda bekleme döngüsünde `pgrep -f "[r]shot.sh"` kendi komut satırını da yakalar (kilitlenir): beklenen
  işi PID ile bekle.
