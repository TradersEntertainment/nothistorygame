# Fragman kusurları — 2. tur küçük düzeltmeler (`wip/duzeltme-kusur`)

Denetçi raporu (`origin/wip/denetim2-kusur`) ZORUNLU 1–3 ve ÖNERİLEN 4–6 işlendi. Araç: Godot 4.4.1, başsız (`--max-fps 20`) ve
xvfb ekranlı PACE=1. Ortak dosya (`stage.gd` vb.) DEĞİŞMEDİ: `Stage.grip_hold` zaten vardı, yeni işlev gerekmedi.
Değişen dosyalar: `scripts/chapter2.gd`, `scripts/chapter0.gd`, `scripts/chapter10b.gd`. Replik metni, sayaç, denge, gizli süre değişmedi.

## 1. B2 avuç–bilek hatası ≤ 0,10 m, her bakışta — DÜZELDİ (gerçek fare ile bakılmadı)
- **Neden:** `_land_on_shore` yamaçta; `_spot_clear` yalnız `_shore_look` yönünde düzlük arıyor. 90°/180° bakışta askerlerin zemini oyuncunun ayağından
  0,3–0,4 m aşağıda kalıyor, omuz bileğe ~0,6–0,76 m uzakta (kol boyu ≈ 0,5 m) → hata 0,25 m. (Tanı: bakış 90°, `gy=-13.62/-13.49`, `py=-13.20`, omuz–bilek 0,76/0,75.)
- **Düzeltme** (`chapter2.gd`): `_seize_spot` (≈ satır 1253) askerin yerini sabit "1 m önde, 0,55 m yanda" yerine bileğin kameradan geçen ışını üzerinde,
  bileğin `SEIZE_BACK`=0,72 m ötesine koyar; `_seize_ground` (≈ 1268) alçak zemini en çok `SEIZE_LIFT_MAX`=0,35 m kabartır. Duruş noktası
  `_grab_arms` değil `_seize`te (≈ 1203) seçilir. `_grab_arms` (≈ 1292) artık `GRIP_PTS`/`FREE_HOLD` sabitlerini kullanır. `SEIZE_AHEAD`/`SEIZE_SIDE` artık kullanılmıyor (bırakıldı).
- **Ölçüm** (`SEIZE_GRIP` satırı, süre boyunca en kötü hata; asker 1 / asker 2; `SEIZE_AUDIT closest` = kameraya en yakın parça):

| iniş / bakış | ÖNCE (denetçi) | SONRA hata | SONRA closest | WALKTHRU |
|---|---|---|---|---|
| sonuç 2.1, 0° | 0,100/0,080 | 0,051/0,045 | 0,66 m | yok |
| sonuç 2.1, 90° | 0,255/0,249 | 0,077/0,051 | 0,68 m | yok |
| sonuç 2.1, 180° | 0,153/0,255 | 0,052/0,065 | 0,70 m | yok |
| 2.1, 0° iken yakalama sırasında 70° çevrilme | — | 0,083/0,051 | 0,68 m | yok |
| `chainfail` (2.4) | 0,100/0,080 | 0,052/0,045 | 0,66 m | yok |
| `swimshore` | 0,101/0,084 | 0,052/0,045 | 0,66 m | yok |
(Başsız PACE=1; ham: `testler_ozet.txt`, çalıştırma günlükleri depo dışında.) `WALKTHRU` yok, asker kameraya ≥ 0,65 m (en düşük 0,62 sn'lik **başsız bot** koşusunda, PACE olmadan askerler yürümeden varır).
- **Ayar süpürmesi** (neden 0,72): `SEIZE_BACK` 0,5 → elbow `WALKTHRU`; 0,6 → closest 0,62; 0,7–0,72 ikisini de sağlıyor; 0,76'dan sonra 90°'de hata > 0,10. Eğilme (`lean`) 0,22 kaldı (0,3 → kameraya yaklaşıyor, 0,1 → kol yetişmiyor).
- **Kare:** `p01_b2_bakis_once_sonra.jpg` — gerçek oyuncu kamerası, ekranlı PACE=1, üç bakış (0°, 90°, 180°) × iki an (`D2_T_15`, `D2_S_16`); her çiftte solda ÖNCE (bu dalın önceki ucu `e2d7455a` chapter2), sağda SONRA. `D2_S_16` karelerinde SONRA'da iki asker yüzü kadrajda, kameradan geçmiyor.
- **KANITSIZ/KISMEN:** "iki yumruk bileklerde görünüyor" ölçümle (hata ≤ 0,08) doğrulandı; karede yumruk ayrıntısı 480 px'lik paftada net seçilmiyor. `D2_T_15` anında (askerler yürüyor) üç bakışta da askerler henüz yolda (ÖNCE'de de öyle). Gerçek fareyle bakış çevirme denenmedi: yalnız programla döndürülen bakış (iniş anında 0/90/180°, yakalama sırasında 70°).

## 2. Bakış kilidi ≤ 3 sn — DÜZELDİ
- Kilit artık yalnız askerlerin yürüyerek yerleştiği pencerede (`_seize_release_lock`, ≈ 1222): yürüme bitince ya da en çok 2,6 sn sonra `look_lock=false`; ardından `_seize_following` ile askerler her karede `_seize_spot` hedefine yumuşakça (8/sn) taşınır ve kollar bileği izler (oyuncu bakışını çevirirse de hata ≤ 0,083).
- **Ölçüm** (`SEIZE_LOCK`, gerçek zaman; kilit, kararma açılırken başlar): yürüme penceresi 1,85 sn, kilidin toplamı **2,33–2,59 sn** (ÖNCE 7,7–14,0 sn). Testte (askerler yürümeden varır) 0,01–0,02 sn.
- Kilit bırakılınca B2'de oyuncu replik sürerken bakışı çevirebilir; HUD'un replik-sırasında-bakış kuralı değişmedi.

## 3. B0 yer/tarih yazısı ≥ 2,0 sn — DÜZELDİ (yazılış hızı değişti — dikkat)
- Denetçi hesabı: ihtiyaç `age + 1,3 ≥ yazılış + 2,0`; bot `age` 1,7–2,0 iken yazılış 1,4 ise sığmıyor (patlamadan 0,26 sn önce sönme sınırı korunmalı). Tek çıkış yazılışı kısaltmaktı: `PLACE_WRITE` = 0,8 sn (eskiden 1,4). Bekleme `tween_interval(3,2)` (eskiden 2,6) yapıldı → yürüyen oyuncuda toplam süre (4,5 sn) aynı. `_place_out` (≈ 428) `PLACE_WRITE`i kullanır, üst sınır `hold ≤ 1,0` aynı.
- **Ölçüm** (`PLACE_OUT age hold full_visible`; full_visible = tam yazıldıktan sonra görünür kalma = (age−0,8)+hold+0,3): başsız bot 2,30 sn ve 2,30 sn; başsız PACE=1 **2,19 sn** (age 1,69); ekranlı PACE=1 **2,30 sn** (age 1,88). ÖNCE 1,58–1,91 sn. Patlamaya/TOLGA kartına taşmaz (hold ≤ 1,0 sınırı değişmedi).
- Bu basış (`PLACE_OUT`) ölçümden sonra **kaldırıldı** (`grep PLACE_OUT scripts` yalnız bir yorum satırı).
- **Not:** "var olan süre değişmez" kuralına göre yazılış hızı (1,4 → 0,8) bir görünüm süresi değişikliğidir; alternatif patlamayı geciktirmekti, yapılmadı. Karar sizin: gerekirse `PLACE_WRITE = 1.4` yapılır, bot/PACE'te 1,6–1,9 sn'ye döner.

## 4. B10b `D10B_U_EARS` Urban kadrajda — DÜZELDİ
- Neden: `Stage.walk_player` bitince oyuncuyu topa çeviriyor (`player.face(lk)`), Urban'ın "KULAKLARI TIKAYIN!" repliğinde kadraj dışı kalıyordu (`VISAUDIT offview`).
- `chapter10b.gd`: geri çekilme `_retreat_and_face_urban` (≈ 993) içinde; bitince `_ease_face_urban` (≈ 1002) 0,6 sn yumuşak dönüş (testte anında); replik, Urban yerleşip dönüş bitene dek (en çok 2 sn) bekler (`_face_urban_done`).
- **Kare:** `p02_b10b_urban_ears.jpg` — ekranlı PACE=1 `--chapter=10b --autotest=boom`, `D10B_U_EARS`: solda ÖNCE (Urban yok; bu kare ilk, yetersiz deneme sürümünden — aynı durum özgün kodda da var), sağda SONRA (Urban tam kadrajda, altyazıda "KULAKLARI TIKAYIN!"). `VISAUDIT offview` sonrasında yok.

## 5. `PLACE_OUT` basışı — kaldırıldı (madde 3'te).

## 6. `_seize_audit` ihlal yolu için pozitif kontrol — DÜZELDİ (WALKTHRU yolu); GRIP yolu yarı
- Bilerek bozuldu: `SEIZE_BACK` = 0,20 → ekranlı olmayan PACE=1 koşusu: 6 adet `WALKTHRU … part=head/arm/elbow … src=chapter2.gd:_seize` (askerler kameranın içinde), sonra sabit 0,72'ye **geri alındı** (`git diff` boş).
- `SEIZE_GRIP … OVER` yolu aynı koşuda tetiklenmedi (kol hedefe yakın); ayar süpürmesinde bilerek büyük `SEIZE_BACK` (0,8–0,9) ile `SEIZE_GRIP err=0,119/0,111 … OVER` basıldı (geçici sonda; sökülü). Yani GRIP ihlal yolu da çalışıyor.
- Yeni: `SEIZE_GRIP err=a/b max=0.10 ok|OVER` satırı (yalnız `GameState.autotest`; `_seize_report` ile bir kez basılır). Denetim susturulmadı.

## Testler (başsız, temiz kod, `--max-fps 20`)
- `parse_check`: `PARSECHECK PASS scripts=248`.
- 62/62 koşu `AUTOTEST PASS`: bölüm 0 (`""`, `next`, PACE=1 `""`), bölüm 2 8 varyant × 2 (PACE yok/var: `""`,perfect,chain,chainfail,red,swimshore,swimchain,next), 10b 8 varyant (`""`,eye,boom,untaped,tape,ulighter,cube,next), 8y 8 (`""`,warn,dep,opened,honest,hikmet,sinerji,next), 12 10 (…`next`), 17 13 (`""`,two,fall,nophoto,chain,ship_ok,ship_bad,lost,edirne_policy,edirne_none,osm,route,edirne_legend), 3, 8, 9 birer. Ham: `testler_ozet.txt`.
- Yasak satırlar: `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `VISAUDIT`, `WARN_VOID_TELEPORT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `JOURNEY_*` **sıfır**. **İstisna:** `LOOKAUDIT backturn` (`chapter17.tscn` `grip` kişileri) 12 `next` ve 17 `two/ship_ok/ship_bad` koşularında — denetçi Y3, ÖNCE'de de var, bu işin dosyalarından değil; düzeltilmedi.
- İlk tam koşuda `chainfail`te `SCRIPT ERROR rig_of` çıkmıştı: geçici sondamın hatası (askerler silinmişken), sökülünce yok; son koşuda sıfır.
- Çalışırken bir kez bir önceki yarım koşunun artık süreçleri `e2` günlüklerini karıştırdı (sahte `exit=124`); süreçler öldürülüp tüm paket baştan koşuldu (`e4`).

## Yapılamayan / dürüst notlar
- Gerçek fare ile bakış çevirme denenmedi (yalnız programla döndürme).
- B0 yazısı durağan oyuncu (`_first_step_hint`) ve yürüyen insan koşusu ölçülmedi (yazılışı 0,8 sn: hesapla yürüyen oyuncuda toplam süre aynı).
- Performans (RINFO üç örnek) ayrıca alınmadı; çizim değişmedi (yalnız bir kez konum/bakış güncellemesi), yeni üçgen yok.
- Ekranlı kare alınırken geçici `PROBE_YAW`/`PROBE_TURN` ortam değişkeni sondaları kullanıldı; hepsi sökülü (`grep PROBE scripts` boş).
- Hepsi depo dışında: Godot içe aktarma artıkları (`*.import`, `i18n/strings.*.translation`, `*.uid`) kaydedilmedi.

## Paftalar
`p01_b2_bakis_once_sonra.jpg`, `p02_b10b_urban_ears.jpg`.
