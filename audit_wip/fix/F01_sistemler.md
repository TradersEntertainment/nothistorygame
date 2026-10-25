# F01_sistemler düzeltme notları

Ortak çalışma ağacı: /home/user/nothistorygame (git kullanılmadı). Değişen dosyalar (F01 sahipliği):
scripts/ui/hud.gd, scripts/ui/game_menu.gd, scripts/ui/photo_mode.gd, scripts/player/player.gd,
scripts/combat/duel.gd, scripts/combat/story_duel.gd, scripts/combat/wave_runner.gd.
Yeni metin / seslendirme: yok (fix/F01_sistemler_strings.csv ve _voice.txt oluşturulmadı).

## Bulgular

1. [KRİTİK] Tuş takımı kolla kilitleniyor: ZATEN DÜZELTİLMİŞ (commit c691a0f9). hud.gd `_keypad_joy`: D-pad ↑/↓ rakam,
   A yaz (4 hane olunca onay), B sil. Kalan: tuş takımı açıkken Start hâlâ duraklatmıyor (hud.gd `_unhandled_input`,
   `not _keypad_active`). Bilinçli bırakıldı: menü üstüne binerse rakam girişi menüye karışır. Ekranda fareyle tıklanan
   tuş yok, düzeltilmedi (düşük öncelik).

2. [YÜKSEK] Düello/dalga süresi duraklatmada akıyor: DÜZELTİLDİ. story_duel.gd `fight` ve wave_runner.gd `run`
   (dalga döngüsü) ve `await_withdrawn`: `t += delta` yalnız `not scene.get_tree().paused` iken.

3. [YÜKSEK] Bölüm 20 gedik saldırısı sayacı duraklatmada akıyor: DÜZELTİLMEDİ (bölüm dosyası scripts/chapter20.gd
   `_start_assault`, bölüm ajanına ORTAK İSTEK aşağıda). Aynı kalıp ~470 yerde.

4. [YÜKSEK] Düello duraklatmada girdi alıyor / sol tık menüyü yutuyor: DÜZELTİLDİ. duel.gd `_ready`:
   `process_mode = Node.PROCESS_MODE_PAUSABLE` (HUD çocuğu olduğu için ALWAYS devralıyordu). Böylece
   Duel._input/_process duraklatmada durur; sol tık menüye ulaşır, arkada vuruş sayılmaz.

5. [YÜKSEK] Seçim ekranı duraklatmada D-pad ile seçim yapıyor: DÜZELTİLDİ. hud.gd `choose()`: `paused` iken
   `continue` (süre de dolmaz); choice tuşları `_pressed()` ile okunur.

6. [YÜKSEK] Akış şemasında menüden Enter/A sonraki bölümü açıyor: KISMEN DÜZELTİLDİ. hud.gd `show_flowchart`:
   `paused` iken `continue`; `continue`/`red_button`/`quit` `_pressed()` ile (menüyü kapatan karede basılan tuş
   sayılmaz). Akış şeması açıkken duraklatma engellenmedi: menü üstüne biner, "Devam et" akış şemasına döner.

7. [YÜKSEK] Akış şemasında "Çık" kaydetmeden oyunu kapatıyor: DÜZELTİLMEDİ. Bölüm dosyalarındaki
   `get_tree().quit()` dalları (chapter8.gd:706 vb.) ve GameState kaydı (F05) gerekiyor. ORTAK İSTEK.

8. [ORTA] Duraklatmada ara sahne zamanlayıcısı akıyor: KISMEN. hud.gd: bütün `get_tree().create_timer(x)`
   çağrıları `create_timer(x, false)`; HUD'un bütün tween'leri `_tw()` (TWEEN_PAUSE_STOP). Bölüm betiklerindeki
   ~550 çağrı bölüm ajanlarına ORTAK İSTEK.

9. [ORTA] Harita düello sırasında açılıyor: DÜZELTİLDİ. hud.gd `map_ready()`: `active_duel` grubu doluysa kapalı.

10. [ORTA] Kolda D-pad ↓ hem harita hem 4. eşya: DÜZELTİLDİ (player.gd `_item_input`): joy olayında choice_4
    eşya seçmez; D-pad ↓ harita olur, 4. eşya LB/RB ile seçilir. game_state.gd binding'i değiştirilmedi.

11. [ORTA] "Eli boşalt" kolda bağlı değil: KISMEN. hud.gd: kolda klavye ipucu (X) gösterilmiyor. Gerçek kol
    bağlaması (JOY_BUTTON_PADDLE1 standart kolda yok) game_state.gd (F05) gerekiyor. ORTAK İSTEK.

12. [ORTA] Kolda istemler "[E]": DÜZELTİLDİ. hud.gd `set_prompt`: kol modunda "[E]" → "[X]" (key_hint).
    UI_BAG_HINT ("1–5") gibi sabit metinler strings.csv'de; dokunulmadı (metin ajanına not).

13. [ORTA] Bekleyen tuş atama sayfadan çıkınca açık kalıyor: DÜZELTİLDİ. game_menu.gd `_clear()` bekleyen
    atamayı sıfırlar; atamada aynı tuşu kullanan eylemle takas yapılır (`_key_of`, `show_keys`). "advance"
    REBINDABLE listesinde değil, düzeltilmedi (F05 notu).

14. [ORTA] Kolla gezinmede kaydırılan liste odak izlemiyor: DÜZELTİLDİ. game_menu.gd: 4 ScrollContainer
    `follow_focus = true`; `_finish_page` odağı kaydırılan listenin ilk denetimine verir.

15. [ORTA] Kayıt yarıda kalırsa ilerleme gider: DÜZELTİLMEDİ (scripts/autoload/game_state.gd F05'in). ORTAK İSTEK.

16. [ORTA] Mini oyunlar duraklatmada sürüyor: DÜZELTİLDİ. player.gd mini oyun oluşturulduğu yerde
    `mg.process_mode = PAUSABLE` (add_child öncesi; tek oluşturma yeri player.gd:~1803-1811).

17. [ORTA] Ayak üstü söz açık repliği kesiyor: DÜZELTİLDİ. hud.gd `bark()`: açık replik (zincir ya da serbest)
    varken en çok 12 sn bekler (duraklatma sayılmaz); hâlâ açıksa söz ATLANIR (kesmez). Duraklatmadayken hiç
    çalmaz.

18. [ORTA] Yerdeyken eylemler açık, düşme sonucu yok: KISMEN. player.gd: `is_down` iken zıplama (yerde), E
    etkileşimi ve eşya seçimi/kullanımı kapalı (merdiven bırakma değişmedi). Bölümlerde `downed` cezası
    düzeltilmedi (bölüm ajanlarına ORTAK İSTEK).

19. [ORTA] Bölüm geçişleri change_scene_to_file ile: DÜZELTİLMEDİ (bölüm dosyaları + game_state F05). ORTAK İSTEK.

20. [ORTA] Yan sahne (side_events) yarıda kalınca kilitleniyor: KISMEN. hud.gd `bark()` duraklatmada çalmaz
    (menü arkasında ses yok). side_events.gd F01 sahipliğinde değil; `_playing` sıfırlama, is_instance_valid,
    create_timer(secs, false) ORTAK İSTEK.

21. [ORTA] F2 ara sahnede kamerayı oyuncuya zorla çeviriyor: DÜZELTİLDİ. photo_mode.gd: açılmadan önceki etkin
    kamera (`_prev_cam`) kapanınca geri yüklenir. hud.gd `_photo_player()`: cinematic, seçim ya da frozen iken
    fotoğraf modu açılmaz.

22. [ORTA, şüpheli] Duraklatmadan Enter/A ile repliği ilerletme: DÜZELTİLDİ (önlem). hud.gd `_pressed("advance")`:
    menüyü kapatan karede basılan tuş ilerletmez (`_unpaused_frame`). Oyunda test edilmedi.

23. [ORTA, şüpheli] Hedef işaretçisi önbelleği: DÜZELTİLDİ. hud.gd `spot()`: önbellekteki nesne canlı
    değilse (toplandı, çarpışma kapalı) aynı kimlikli canlı nesne aranır; bulunamayan kimlik en çok 0,4 sn
    aralıkla taranır.

24. [ORTA, şüpheli] Edirne boş avlu: DÜZELTİLMEDİ. scripts/interlude_edirne.gd bölüm dosyası; kanıt render
    karelerine bölüm ajanı bakmalı.

25. [ORTA, şüpheli] Bulgu metni kesik (Bölüm 26 merdiven dövüşü ~25 dk). İncelenmedi: bulgu eksik; not.
    Not: WaveRunner süresi artık duraklatmada sayılmıyor; oyun duraklı kalırsa dalga hiç bitmez (tasarım gereği).

## Testler

- PARSE (son koşu): PARSECHECK PASS scripts=230. (Önceki koşuda başka bir ajanın chapter6.gd dosyası hata veriyordu; şimdi geçiyor.)
- Bölüm autotest (scratchpad/audit/fix/F01_test_results.txt): 1, 2, 8, 20, 20 lose, 22o, 22o lose, 26, 29, 29 lose
  hepsi "AUTOTEST PASS". SCRIPT ERROR / VISAUDIT / FAIL yok. Yalnız 26 çıkışında Godot'nun
  "Pages in use exist at exit" uyarısı (oyun hatası değil, çıkış uyarısı).
- Duraklatma yolları (paused dalları, Pause menüsü, düello içi tıklama) autotest'te çalıştırılmadı; kod incelemesiyle doğrulandı.

## ORTAK İSTEKLER

Bölüm ajanları (chapterNN*.gd, level/*):
- (3, 8) chapter20.gd `_start_assault` ve diğer `await get_tree().create_timer(x).timeout` beklemeleri:
  `create_timer(x, false)`; saymaya dayalı döngülerde `if not get_tree().paused:` ile sayaç ilerlet.
- (7) Bölüm sonu akış şeması `"quit"` dalları (chapter8.gd:706, chapter10g.gd:317-323, chapter7/9/12/14 vb.):
  get_tree().quit() yerine bir sonraki bölümün başlangıcını kaydet (GameState, F05) ve ana menüye dön.
- (18) Kuşatma bölümleri (20, 22o, 26, 26o, 30o–39o): player.downed sinyaline ceza bağla (zaman kaybı,
  son güvenli nokta ya da sonuç notu).
- (19) change_scene_to_file çağrıları (chapter2/7/8/9/10*/12/14/15 vb.): GameState.change_scene(path) kullan.

F05 (scripts/autoload/game_state.gd):
- (15) `_write`: önce `save_auto.tmp`'ye yaz, DirAccess.rename ile değiştir; önceki kaydı `.bak` tut; read_save
  başarısızsa .bak'a dön.
- (7) Çık yolu için kaydetme + ana menü akışı (bölüm tarafıyla birlikte).
- (11) "hands_free" kol bağlaması JOY_BUTTON_PADDLE1 (standart kolda yok): gerçek bir düğmeye (ör. Select uzun basış)
  bağla; hud'a kol ipucu eklenecek.
- (10, bilgi) "map" ve "choice_4" ikisi de JOY_BUTTON_DPAD_DOWN. F01 player.gd tarafında çözüldü; binding değişmedi.
- (13, opsiyonel) "advance" REBINDABLE listesinde değil; atanabilir yapılacaksa Enter/Space çakışması.

side_events.gd (sahiplik belirsiz):
- (20) `_play_scene` sahne başında `_playing = false` (ya da her adımda `is_instance_valid(hud)` kontrolü),
  bekleme `create_timer(secs, false)`.

Sahiplik dışı (not):
- (24) scripts/interlude_edirne.gd render/kamera sorunu.
