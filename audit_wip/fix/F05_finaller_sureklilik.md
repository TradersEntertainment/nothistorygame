# F05_finaller_sureklilik düzeltme notu

Durum: 23 bulgunun tamamı için karar verildi. 19'u düzeltildi (bazıları yalnız kısmen, not edildi), 1'i zaten doğru çıktı, 3'ü kısmen ya da düzeltilmedi. Ayrıştırma (PARSE) geçti. Tüm test varyantları (93 koşu) AUTOTEST PASS.

## Bulgular

1. [YÜKSEK] 8.4 + 12.4: Hikmet hem 1453'te hem garajda — DÜZELTİLDİ. chapter13.gd `_ready`: sürüm önceliği 12.6 → 8.4 (1453) → 8.3 (depot) → 12.4 (w4). Fatih'in tamiri yalnız makine garajdayken W4 yapar.
2. [YÜKSEK] Boş Masa'da "Evlât servise yetişti" — DÜZELTİLDİ. chapter15.gd `_scene_garage`: final empty_desk → D15_G_T2 (yeni anahtar). W varyantları T2'de devre dışı.
3. [YÜKSEK] Gıdak, kapanmış pencereden geri sarıyor — DÜZELTİLDİ. chapter13.gd: `_gidak` yalnız mutfakta (12.5) ve Sinerji'de; Gıdak yolunda "kapandı" replikleri atlanır, doğrudan kart.
4. [YÜKSEK] Kuşatmadan dönüşte geri çağrı hep Galata/şehir — DÜZELTİLDİ. siege.gd `gate()` `flags.pre_siege_scene` kaydeder; game_state.gd `last_place()` siege_done iken onu kullanır.
5. [YÜKSEK] Tutuklu Tolga Bekleme Salonu yerine 26 Nisan'a dönüyor — DÜZELTİLDİ (metin varyantı). game_state.gd yeni `_ARREST` bayrak varyantı (bureau_from == "arrest"); D26_N_RETURN / D26_T_RETURN / UI_ACT4_END_SUB / D14_N_W2 / D14_N_W4 için _ARREST sürümleri (strings dosyasında). Kod değişikliği yok; varyant otomatik seçilir.
6. [YÜKSEK] Osmanlı tarafı "Bir Akşam" finaline ulaşamıyor — ZATEN DOĞRU. chapter26o.gd `_end_chapter`, chapter26.gd'den miras alınıyor; orada `Siege.resolve(false)` çağrılıyor (`_outcome` 26.1/26.2 olunca). Denetim grep'i kalıtımı görmemiş. Değişiklik yapılmadı.
7. [YÜKSEK] Dönüş Penceresi'nde Tolga neredeyse hep Galata'da — DÜZELTİLDİ. Bulgu 4 ile aynı kök (pre_siege_scene).
8. [YÜKSEK] 8.4 + 12.4 garajda W4 — DÜZELTİLDİ. Bulgu 1 ile aynı (1453 önce).
9. [YÜKSEK] Gıdak'ta pencere "kapandı" ama 16'da 90 sn açık — DÜZELTİLDİ. Bulgu 3 ile: Gıdak yolunda kaçış replikleri atlanır, kart ve 16 ile tutarlı.
10. [ORTA] 8.3 + 12.4'te W4 garajda — DÜZELTİLDİ. Bulgu 1'in öncelik sırasıyla 8.3 depo sürümü W4'ün önüne geçti (makine Büro deposunda oynanır).
11. [ORTA] "Büro'ya alınsın" T2/T3'te ve 10A'da "Sırada bekledi" — DÜZELTİLDİ. chapter14.gd `_desk`: öneri yalnız tutuklu ya da 10A'da T1 Tolga için; 10A (tutuklanmamış) raporu UI_CH14_R_RECRUIT_10A ve D14_N_RECRUIT_10A kullanır.
12. [ORTA] H3'te "Zaman Tamir Servisi" ve istifa — DÜZELTİLDİ. chapter14.gd: istifa seçeneği H3'te gizli (time_repair'e gitmez).
13. [ORTA] Ofis "sudan çektim" cevabı her rotada aynı — DÜZELTİLDİ. chapter15.gd `_siege_question`: W10–W12 → D26_T_HONEST_CHANGED; 17.1 değilse → D26_T_HONEST_PLAIN; 17.1 → eski D26_T_HONEST.
14. [ORTA] 1453'te frekans kaçınca Gıdak açılıyor — DÜZELTİLDİ. Bulgu 3'teki mutfak kapısı 1453 yolunu dışarıda bırakır (1453'te mutfak yok).
15. [ORTA] Galata'nın tanıdık yüzleri yalnız 10G'de — DÜZELTİLDİ. chapter27.gd `_known_galata()`: D27_T_01_NEW, D27_N_02_NEW, D27_W_1_NEW (şarapçının ilk satırı).
16. [ORTA] Gıdak'a yer sıçraması — DÜZELTİLDİ. Bulgu 3 ile (Gıdak yalnız mutfak).
17. [ORTA] Kayıt sırası 16 > 14 — DÜZELTİLDİ. game_state.gd `play_order(16) = 13.5`.
18. [ORTA] 10L.3'te Nihat tanışması — DÜZELTİLDİ. chapter11.gd: 10L.3 → D11_N_KNOWN_TUNNEL; chapter17.gd `_met_nihat()` 10L.3'ü sayar.
19. [ORTA] 8.4 yolunda dal bölümlerinin telsizi garajdaymış gibi — KISMEN DÜZELTİLDİ. game_state.gd `_H1453` bayrak varyantı; chapter10a/10g/10h/10l/10z ve chapter12b telsiz satırları için _H1453 sürümleri (strings dosyasında). Kalan: D10B_H_RADIO_1/3 (genel, bırakıldı), D10H_H_RADIO_SAVE (kaydedilmedi).
20. [ORTA] 6b uyarısı kuşatmada anılmıyor — DÜZELTİLDİ (kısmen). game_state.gd `_WARNED6B` (giustiniani_warned); D20_G_01_KNOWN, D26_G_DUCK, D26_G_HURT, D26_G_NOTRUST için _WARNED6B sürümleri. İnsanların Akıbeti (people_fates.gd) yalnız 10H bayrağına bakıyor: ORTAK İSTEK (aşağıda).
21. [ORTA] 16'da "tavuk da yok" ama kamera tavukta — KISMEN. chapter16.gd `_win`: Sinerji flaştan önce Hasan'ın yanına ayakta konur. Görsel doğrulama gerekli (test yalnız AUTOTEST PASS).
22. [ORTA] Konuşmacısız sahne notları Hikmet/Driver/Nihat etiketiyle — DÜZELTİLDİ (betimleme kartı). chapter15.gd `_stage()`: D15_G_H3, D15_G_TWO, D15_S_T2, D15_S_N3. KISMEN: D15_S_N3'te yeni Nihat'ın yürümesi gösterilmiyor (eski Nihat durakta duruyor).
23. [ORTA] 13.5'te Tolga'nın boş garaja inişi yok — DÜZELTİLDİ. chapter13.gd `_return_alone()` (iki kısa replik: D13_T_ALONE_1/2).

## Değişen dosyalar
- scripts/chapter13.gd: `_ready` (sürüm önceliği), `_gidak` (yeni değişken), `_apply_autotest_setup` ("gidak"), `_tolga_moment` (gidak koşulu, kaçış replikleri), `_h3_version` (13.5 → `_return_alone`), `_return_alone` (yeni), `_end_chapter` (gidak koşulu).
- scripts/chapter14.gd: `_desk` (öneri/istifa koşulu, 10A metni), recruit `_n` anahtarı.
- scripts/chapter15.gd: `_scene_garage` (empty_desk → D15_G_T2; H3/TWO → `_stage`), `_scene_monday` (`_stage` T2 ve N3), `_siege_question` (dürüst cevap varyantı), yeni `_stage()`.
- scripts/chapter11.gd: `10L.3` → D11_N_KNOWN_TUNNEL (elif).
- scripts/chapter16.gd: `_win` (Sinerji'nin konumu).
- scripts/chapter17.gd: `_met_nihat` (10L.3).
- scripts/chapter27.gd: `_known_galata()` (yeni), `_run` (T_01/N_02 varyantları), `_talk` (W_1 varyantı).
- scripts/siege.gd: `gate()` (pre_siege_scene).
- scripts/autoload/game_state.gd: FLAG_VARIANTS (+ _WARNED6B, _H1453, _ARREST) ve `_flag_variant`; `last_place()` (pre_siege_scene); `play_order(16) = 13.5`.

## Strings / ses
- Yeni ve değişen metinler: `fix/F05_finaller_sureklilik_strings.csv` (24 anahtar, i18n/strings.csv'ye birleştirilecek).
- Seslendirilecek anahtarlar: `fix/F05_finaller_sureklilik_voice.txt` (24 satır).
- Yeni varyant son ekleri (_ARREST, _H1453, _WARNED6B) için tablo: ses/metin denetimi için ana oturum eklemeli.

## Test sonuçları
- PARSE: PASS (scripts=230).
- Statik denetimler: check_tween_await, check_consequences (sorun 0), check_outcomes (okunmayan 0), check_inline, check_voice_rules PASS. check_speakers'ta hata var ama 36b/42b'de (bu grup değil). check_keys: yalnız bu grubun henüz birleşmemiş anahtarları eksik.
- Bölüm koşuları (gtest.sh): 13 (tüm varyantlar + next, wrong_next, gidak), 14, 15 (tüm varyantlar), 16, 27, 17 (edirne_*, osm, route), 1 (--autotest, kick, red), 20 (tüm varyantlar, difficulty 0/2). 93/93 "AUTOTEST PASS".
- Bir VISAUDIT (chapter20 CityLife overlap at (36.9, 0, -13.2)) görüldü. Bu koşu PASS; bölüm 20'de benim değişikliğim yok (chapter20.gd'deki diff başka ajanın Leon/36.1 çalışması). Bu grubun dışında.
- Not: gtest.sh çıktı filtresi WARN_FX_STUCK, HELDAUDIT, ARMAUDIT, JOURNEY_* satırlarını göstermez; bu denetimler bu koşularda doğrulanamadı.

## ORTAK İSTEKLER
- Bulgu 20: people_fates.gd:103 yalnız `giust_warned` (10H) bayrağına bakıyor; 6b uyarısı (giustiniani_warned) İnsanların Akıbeti'nde yok. Ana oturum ya da F-grubu sahibi eklemeli.
- Bulgu 19 (kalan): D10B_H_RADIO_1/3 ve D10H_H_RADIO_SAVE için _H1453 sürümleri — bölüm 10B/10H sahiplerine.
- Bulgu 5/14 yan etkisi: _ARREST bayrağı chapter26.gd D26_N_RETURN'de de devreye girer (26.3 + tutuklama rotası) — bu doğru (dönüş 14'e), ama 26 sahibi bilmeli.
- Yeni anahtar son ekleri (_ARREST, _H1453, _WARNED6B) ses kazanç tablosu (voice_gain.gd) için varsayılan kullanır; gerekirse eklenmeli.
- D15_G_H3 / D15_G_TWO / D15_S_T2 / D15_S_N3 artık kart (betimleme). Eski seslendirmeleri (Hikmet/Driver/Nihat sesi) kullanılmıyor; ses listesinden çıkarılabilir.
- chapter20 (Leon/36.1) için VISAUDIT: ilgili ajanın bakması gerekiyor.

## Kalanlar / riskler
- 16 ve 15 (S_N3) kısmen; görsel doğrulama (kamera, kart) yapılmadı.
- Bulgu 6 değişmedi; bulgu 19 ve 20 kısmi.
