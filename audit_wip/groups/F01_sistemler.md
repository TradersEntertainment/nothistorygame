# F01_sistemler: 25 bulgu

## 1. [KRİTİK] [oyun] [Bölüm 1]
Zamanatör tuş takımı yalnız klavyeyle çalışıyor; gamepad oyuncusu kilitlenir

Garajdaki panelde hedef yılı girme adımı zorunlu (chapter1.gd `_use_panel`: `player.frozen = true`, doğru kod girilene kadar `while true` döngüsü). Hud.keypad girdisini yalnız `InputEventKey` ile alıyor (0-9, Backspace, Enter); kol düğmesi, D-pad ya da fareyle rakam girmenin yolu yok, ekranda tıklanabilir tuş da yok. Üstelik `_keypad_active` iken duraklatma menüsü de açılmıyor (`_unhandled_input` koşulu) — gamepad'li oyuncu ilk bölümde ne ilerleyebilir ne de menüden çıkabilir. Kanıt: scripts/ui/hud.gd:2726-2765, :3297; scripts/chapter1.gd:795-806; UI_KEYPAD_HINT ("Rakamları yaz · Enter"). Öneri: D-pad yukarı/aşağı ile rakam değiştirme + sola/sağa hane seçme + A onay, B sil; ya da ekranda odaklanabilir 0-9 düğmeleri. Tuş takımı açıkken de Start ile duraklatmaya izin ver.

## 2. [YÜKSEK] [oyun] [Kuşatma düelloları: 20, 22o, 29 vb. StoryDuel/WaveRunner kullanan her bölüm]
Duraklatma menüsü açıkken düello süresi işlemeye devam ediyor

StoryDuel.fight süreyi `await get_tree().process_frame` + `get_process_delta_time()` ile sayıyor; SceneTree.process_frame sinyali oyun duraklatılmışken de her karede gelir, döngüde `get_tree().paused` denetimi yok. Senaryo: oyuncu düelloda Esc'e basıp ayarlarla 75 sn uğraşır; menüden döndüğünde süre dolmuştur, rakipler geri çekilir ve düello "kazanılamadı" (won=false) sayılır, bölüm sonucu kötüleşir. WaveRunner'da tersine: dalga süresi duraklatmada dolar ve dalga "tutuldu" sayılır (duraklatarak kazanma açığı). Kanıt: scripts/combat/story_duel.gd:60-63; scripts/combat/wave_runner.gd:104-105, :264-265 (Hud.say aynı sorunu bilerek `if get_tree().paused: continue` ile çözmüş: scripts/ui/hud.gd:1561). Öneri: bu döngülerde `if scene.get_tree().paused: continue` (ya da PROCESS_MODE_PAUSABLE bir Timer / `create_timer(t, false)`).

## 3. [YÜKSEK] [oyun] [Bölüm 20 (gedik saldırısı)]
Okları taşıma süresi (30 sn) duraklatmada da akıyor

`_start_assault` döngüsü `await get_tree().process_frame` ile `t` sayıyor, duraklatma denetimi yok. Oyuncu saldırı başında menüyü açıp 30 sn beklerse döndüğünde "D20_G_ARROWS_LATE" (geç kaldın) azarı gelir, taşıdığı ok yere bırakılır. Aynı kalıp (process_frame + delta sayacı) projede ~470 yerde var; bölüm yönetmenlerindeki süreli görevlerin çoğu bu yüzden duraklatmadan etkilenir. Kanıt: scripts/chapter20.gd:323-347. Öneri: ortak bir `await Util.frame_unpaused()` yardımcısı ya da sayaçlara `if get_tree().paused: continue`.

## 4. [YÜKSEK] [oyun] [Bütün kılıç dövüşleri]
Düello sırasında duraklatma menüsünde fare tıklaması çalışmıyor, arkada kılıç sallanıyor

Duel bir Control olarak HUD'un çocuğu yapılıyor (story_duel.gd:20, wave_runner.gd:25, drill.gd:68); HUD `PROCESS_MODE_ALWAYS` olduğu için Duel de duraklatmada çalışıyor. Duel._input sol tıkı (`sword_attack` = MOUSE_BUTTON_LEFT) yakalayıp `set_input_as_handled()` diyor; `_input` GUI'den önce işlendiği için tıklama menü düğmelerine hiç ulaşmıyor. Üstelik `attack()` çalışıyor, Duel._process'te `_player_tick` ilerliyor ve `_resolve_player_swing` donmuş rakibe vuruş uygulayabiliyor; sağ tık (`sword_block`) ve dayanıklılık dolumu da duraklatmada sürüyor. Senaryo: düelloda Esc → "Devam et"e fareyle tıklamak işe yaramaz (yalnız klavye/kol ile çıkılır), tıklamalar arkada vuruş olarak sayılır. Kanıt: scripts/combat/duel.gd:318-343, :488-518; scripts/ui/hud.gd:152. Öneri: Duel.new() sonrası `process_mode = PROCESS_MODE_PAUSABLE` (ya da _input/_process başında `if get_tree().paused: return`).

## 5. [YÜKSEK] [oyun] [Bütün seçimli diyaloglar]
Duraklatma menüsünde D-pad ile gezinmek arkadaki seçimi yapıyor

Hud.choose döngüsü duraklatmayı denetlemeden her karede `Input.is_action_just_pressed("choice_N")` bakıyor; choice_1..4 kolda D-pad ←↑→↓ (game_state.gd:1146-1150). Duraklatma menüsü de D-pad ile geziliyor. Senaryo: herhangi bir hud.choose seçeneği ekrandayken oyuncu Start'a basar, menüde aşağı inmek için D-pad ↓'e basar → arkada 4. seçenek (ya da ↑ ile 2.) seçilir; menüden dönünce karar verilmiş, hikâye o dala girmiştir. "Süreli kararlar" açıksa geri sayım da menüde akar ve seçim süresi dolar (-1). Kanıt: scripts/ui/hud.gd:2696-2711 (say() aynı durumu `if get_tree().paused: continue` ile korumuş: :1561). Öneri: choose döngüsünde `if get_tree().paused: continue` ekle.

## 6. [YÜKSEK] [oyun] [Her bölüm sonu akış şeması]
Akış şemasında duraklatma menüsü açıp Enter/A ile bir düğme seçmek arkada sonraki bölüme geçiriyor

`show_flowchart` döngüsü duraklatmayı denetlemeden `continue` (Enter, KP Enter, kolda A ve Start), `red_button` (R / kolda B) ve `quit` (Q) eylemlerine bakıyor; duraklatma da akış şemasında engellenmiyor. Senaryo: bölüm sonunda akış şeması ekrandayken Esc → menüde Enter ile "Ayarlar"a girmek ya da kolda A ile "Devam et"e basmak aynı karede `continue` sayılır, sonraki bölüm yüklenir; menüde kolda B'ye basmak `red_button` sayılır ve bölüm baştan oynatılır (replay_scene). Kanıt: scripts/ui/hud.gd:3253-3263; scripts/autoload/game_state.gd:1122-1123 (`continue` = Enter/A/Start, `pause` = Start). Öneri: döngüde `if get_tree().paused: continue`; akış şeması açıkken `_unhandled_input` duraklatmasını kapat ya da düğmeleri GUI düğmesi yap.

## 7. [YÜKSEK] [oyun] [Bölüm sonu akış şeması: 1–16, 10a–10z, 12b vb.]
Akış şemasında "[Q] Çık" oyunu kapatıyor ve bitirilen bölüm kaydedilmemiş oluyor

Bölüm sonunda `"quit"` sonucu doğrudan `get_tree().quit()` çağırıyor. Otomatik kayıt yalnız bir sonraki bölümün `_ready`'sindeki `GameState.snapshot()` ile yazılıyor; bölüm sonucu (`set_outcome`) yalnız meta dosyasına gidiyor, oyunun kaydı (save_auto.dat) hâlâ bitirilen bölümün BAŞINI gösteriyor. Senaryo: oyuncu Bölüm 8'i bitirir, akış şemasında "Çık"a basar; ertesi gün "Devam et" Bölüm 8'in başından açar, bütün bölümü (ve kararlarını) yeniden oynamak zorunda kalır. Ayrıca "Çık" ana menüye değil masaüstüne atıyor. Kanıt: scripts/chapter8.gd:700-706, scripts/chapter10g.gd:317-323 (aynı kalıp chapter7.gd, chapter9.gd, chapter12.gd, chapter14.gd…); scripts/autoload/game_state.gd:665-684, :706-712. Öneri: akış şemasından çıkarken bir sonraki bölümün başlangıcını kaydet (ör. "next" sahnesini ve durumu snapshot olarak yaz) ya da "Çık"ı ana menüye dönüş yap ve çıkmadan önce kaydet.

## 8. [ORTA] [oyun] [Bütün bölümler, ara sahneler]
Duraklatma ara sahnenin zaman çizelgesini durdurmuyor; yalnız replikler duruyor

Bölüm yönetmenleri bekleme için çoğunlukla `await get_tree().create_timer(x).timeout` kullanıyor (~550 çağrı); SceneTree.create_timer'ın varsayılanı `process_always = true`, yani duraklatmada da dolar (yalnız 13 çağrı `false` veriyor). HUD da PROCESS_MODE_ALWAYS olduğu için `card()` bekleme süresi, `fade_to` / başlık kartı / daktilo (`typewriter`) tween'leri menü açıkken sürer. Sahnedeki 3B düğümler ise duraklar. Senaryo: ara sahnede bir kişi tween'le yürürken Esc'e basılır; menü açıkken betiğin zamanlayıcısı dolar ve sonraki adımlar (ışınlama, kararma, kart) arkada işler, menü kapanınca kişi bir anda yeni yerine sıçrar ya da bölüm başlık kartı hiç görülmeden geçmiş olur. Hud.say ise duraklatmada bekliyor (hud.gd:1559-1562), bu yüzden replik ve sahne birbirinden kopar. Kanıt: scripts/ui/hud.gd:152, :2768-2779, :2825-2826, :2903-2905; örnek scripts/chapter20.gd:351, scripts/combat/story_duel.gd:94. Öneri: bölüm betikleri için `create_timer(t, false)` kullanan ortak bir bekleme yardımcısı; HUD tween'lerinde `set_pause_mode(Tween.TWEEN_PAUSE_STOP)` (say()'deki gibi).

## 9. [ORTA] [oyun] [Bütün kılıç dövüşleri]
Büyük harita (M) düello sırasında açılabiliyor

`map_ready()` dövüşü (`active_duel` grubu / `player.combat`) denetlemiyor; harita oyunu duraklatıyor, ama yukarıdaki nedenlerle düello süresi ve Duel._process sürüyor, haritayı fareyle sürükleme (sol tık) Duel._input'a yutuluyor. Kanıt: scripts/ui/hud.gd:537-540, :551-569. Öneri: `map_ready()` içine `not get_tree().get_first_node_in_group("active_duel")` ve oyuncu `combat` denetimi.

## 10. [ORTA] [oyun] [Kolla oynayan herkes, Bölüm 2'den sonra (çantada 4+ eşya)]
D-pad ↓ hem "harita" hem "4. eşya"; ne olacağı bölüme göre değişiyor

`map` = JOY_BUTTON_DPAD_DOWN ve `choice_4` = DPAD_DOWN (game_state.gd:1131, :1146-1150). Player._item_input `choice_k` ile eşya seçiyor ve girdiyi tüketiyor; Hud._unhandled_input haritayı açıyor. _unhandled_input ters ağaç sırasıyla gittiği için: Bölüm 2'de Player önce eklenip HUD sonra eklendiğinden (chapter2.gd:44-47) D-pad ↓ haritayı açar ve 4. eşya kolla tek tuşla seçilemez; Bölüm 9'da HUD önce eklendiğinden (chapter9.gd:66-69) aynı tuş 4. eşyayı seçer, harita kolla hiç açılmaz. Kanıt: scripts/player/player.gd:1600-1603; scripts/ui/hud.gd:3297-3300. Öneri: haritayı ayrı bir düğmeye (ör. Select uzun basış / dokunmatik yüzey) taşı ya da eşya seçimini yalnız LB/RB ile yap.

## 11. [ORTA] [oyun] [Kol kullanan herkes]
"Eli boşalt" eylemi kolda yalnız JOY_BUTTON_PADDLE1'e bağlı

standart Xbox/PlayStation kollarında arka pedal yok, eylem kolla yapılamıyor; HUD'daki "[%s] eli boşalt" ipucu da `key_name` ile klavye tuşunu (X) gösteriyor. Kanıt: scripts/autoload/game_state.gd:1134; scripts/ui/hud.gd:1066. Öneri: kolda var olan bir düğmeye bağla (ör. D-pad'e uzun basış) ya da kol kullanılırken ipucunu gizle.

## 12. [ORTA] [görsel] [Kol kullanan herkes]
Etkileşim istemleri kolda yanlış düğmeyi gösteriyor

`set_prompt` yalnız "E ·" ile başlayan metni kol düğmesine (X) çeviriyor; strings.csv'de 61 istem "[E] …" biçiminde (UI_PROMPT_TAKE, UI_PROMPT_HIKMET, UI_PROMPT3_TALK, UI_PROMPT5_RADIO…) ve bunlar kolda da "[E]" diye kalıyor. Tuşlar yeniden atandığında da istemler, UI_CONTROLS ve UI_BAG_HINT eski tuşu yazmaya devam ediyor (yazılar sabit). Kanıt: scripts/ui/hud.gd:755-759; i18n/strings.csv:16-19, :227-232. Öneri: istemlerde "[E]" yerine `{interact}` gibi yer tutucu kullanıp `key_hint`/`key_name` ile doldur.

## 13. [ORTA] [oyun] [Ayarlar · Tuş atama]
Bekleyen tuş atama sayfadan çıkınca da açık kalıyor, sonraki ilk tuş yanlış eyleme atanıyor

Tuş düğmesine tıklanınca `_waiting_action` kuruluyor; oyuncu vazgeçip fareyle "Geri"ye tıklarsa ya da kolda B ile çıkarsa sıfırlanmıyor (yalnız Esc iptal ediyor). Sonra basılan ilk klavye tuşu (ör. menüde Enter ya da W) o eyleme (ör. "zıpla") atanır, tuşa basış yutulur, düğme de çalışmaz. Atamada çakışma denetimi de yok (ör. "etkileşim"i F'ye vermek tekme/uçuş tuşuyla çakışır; diyalog ilerletme "advance" ise atanamaz, E'de kalır). Kanıt: scripts/ui/game_menu.gd:102-118, :698-701. Öneri: `_clear()` içinde `_waiting_action = ""`; atamada aynı tuşu kullanan eylem varsa uyar/takas et.

## 14. [ORTA] [oyun] [Ayarlar, Yan görevler, Tuş atama sayfaları]
Kolla gezinmede kaydırılan liste odak izlemiyor

Ayarlar sayfası bir ScrollContainer içinde; `follow_focus` açılmamış (Godot varsayılanı false), sayfa açılınca odak en alttaki "Geri" düğmesine gidiyor (`_finish_page` _box'taki ilk Button'u seçer; ayar satırları kaydırmanın içinde). Kolla yukarı çıkınca odaklanan kaydırıcı/onay kutusu görünür alana kaydırılmaz; 720p'de alt sıradaki ayarlar (Süreli kararlar, FPS, Dil) görmeden değiştiriliyor. Kanıt: scripts/ui/game_menu.gd:199-204, :541-548, :685-691. Öneri: `scroll.follow_focus = true`; ilk odağı listenin ilk denetimine ver.

## 15. [ORTA] [oyun] [Kayıt]
Kayıt dosyası doğrudan üstüne yazılıyor; yazım yarıda kalırsa bütün ilerleme gidiyor

`_write` FileAccess.WRITE ile dosyayı önce boşaltıp sonra yazıyor; geçici dosya + yeniden adlandırma ya da yedek yok. Bölüm başında (her snapshot'ta) otomatik kayıt yazılırken oyun çökerse/elektrik giderse save_auto.dat boş ya da yarım kalır; `read_save` bunu `{}` sayar, ana menüde "Devam et" kaybolur, "Bölümler" kilitlenir (bütün bölüm başları tek dosyada). Kanıt: scripts/autoload/game_state.gd:706-713, :720-733. Öneri: önce `save_auto.tmp`ye yaz, `DirAccess.rename` ile değiştir; bir önceki kaydı `.bak` olarak tut ve okuma başarısızsa ona dön.

## 16. [ORTA] [oyun] [Mini oyunlar: kazan (ordugâh), pazarlık, mangala, okçuluk]
Mini oyunlar duraklatmada sürüyor

MiniGame HUD'un çocuğu (player.gd:1817 `hud.add_child(mg)`), HUD PROCESS_MODE_ALWAYS; kazan ritim oyununda `_now` duraklatmada ilerler, notalar kaçırılır ve "ıska" sayılır; menüde kolla D-pad'e basmak (choice_1..4) kazanda kepçe vuruşu, pazarlıkta teklif seçimi yapar (minigame_cauldron.gd:99-121, minigame_haggle.gd:86-91). Senaryo: Kadri'yle kazan düellosunun ortasında Start → menüde gezinip dönen oyuncu düelloyu kaybetmiş bulur. Kanıt: scripts/ui/minigame_cauldron.gd:95-130; scripts/player/player.gd:1793-1820. Öneri: MiniGame._ready'de `process_mode = PROCESS_MODE_PAUSABLE`.

## 17. [ORTA] [ses] [Oyuncunun serbest olduğu engelleyen replikler; ör. Bölüm 20 gedik saldırısı]
Ayak üstü söz (bark) süren engelleyen repliği kesiyor

`bark()` yalnız arka plan dizisi (say_chain) sürerken bekliyor; normal `say()` açıkken (`line_open`, `_chain_running == 0`) hemen aynı altyazı kutusuna ve aynı `_voice` oynatıcısına yazıyor: konuşanın sesi yarıda kesilir, altyazı bark'ınkiyle değişir; asıl say() döngüsü `_voice.playing` false olunca biter ve kutuyu gizler, bu kez bark yazısı erken kaybolur. Senaryo: Bölüm 20'de `_start_assault` Giustiniani'nin "D20_G_ASSAULT" repliğini beklemeden açar (chapter20.gd:317) ve oyuncu serbesttir; bu sırada oyuncu yaralanınca/düşünce `D20_T_KNOCK_n` ya da `D_DOWNED_N_n` bark'ı Giustiniani'yi susturur. Oyuncu serbest bir replik sırasında bir halk NPC'sine E'ye basarsa (SideEvents.interact → bark) aynısı olur. Kanıt: scripts/ui/hud.gd:2568-2599 (bekleme koşulu :2571), :1466-1470. Öneri: bark'ta `line_open` iken (zincir olsun olmasın) beklet ya da bark için ayrı bir ses oynatıcısı/altyazı satırı kullan.

## 18. [ORTA] [mantık] [Kuşatma bölümleri: 20, 22o, 26, 26o, 30o–39o (ok, gülle, kaynar yağ, nöbetçi)]
Dövüş dışında canı biten oyuncu için hiçbir sonuç yok

Player.down() `downed` sinyalini yayıyor ve belge "bölüm `downed` sinyaliyle kendi cezasını uygular" diyor, ama projede bu sinyale bağlanan tek bir bölüm yok (yalnız StoryDuel/WaveRunner `is_down`'a bakıyor, 32o bir taşıma durumunda). Oyuncu ok yağmurunda/yağ altında bilerek bekleyip düşse bile 2 sn sonra 40 canla kalkıyor, görev sürüyor; tehlikeler anlamını yitiriyor ("kaybetme durumu işlenmiyor"). Ayrıca yerdeyken (`is_down`) zıplama, eşya kullanma ve etkileşim kapalı değil (yalnız yürüme hızı 0). Kanıt: scripts/player/player.gd:66-70, :757-789; `grep downed` yalnız player.gd'de. Öneri: ya bölümlerde `downed`'a ceza bağla (zaman kaybı, son güvenli noktaya dönüş, sonuç notu) ya da belgeyi düzelt; `is_down` iken `_unhandled_input`/zıplamayı kapat.

## 19. [ORTA] [oyun] [Bölüm geçişleri: 25 dosyada 52 çağrı]
Bölümden bölüme geçişlerin çoğu yükleme perdesini ve tek kapıyı atlıyor

chapter2/7/8/9/10*/12/14 vb. sonraki bölüme `get_tree().change_scene_to_file()` ile geçiyor; GameState.change_scene'in yükleme ekranı, eski sahneyi önce boşaltma (game_state.gd:385-394 açıklaması: "bekleyen işler yeni sahne kurulurken uyanıyordu… Windows'ta çökme"), `changing` bayrağı, `paused=false` ve `time_scale=1` sıfırlaması bu geçişlerde yok. Senaryo: Bölüm 9 → ağır 10x dalına geçerken ekran saniyelerce donuk kalır (oyuncu "dondu" sanır); geçiş karesinde Esc'e basılırsa yeni bölüm duraklatılmış açılabilir (yalnız yeni Hud._ready kurtarır). Kanıt: scripts/chapter8.gd:695-702, scripts/chapter9.gd:590, scripts/chapter14.gd:337-344, scripts/chapter15.gd:660; karşılaştır scripts/autoload/game_state.gd:754-776. Öneri: bütün bölüm geçişlerini `GameState.change_scene()` üzerinden yap.

## 20. [ORTA] [oyun] [Yan olaylar "ev:council" (Bizans konseyi) ve "ev:envoy" (Macar elçisi)]
Yan sahne yarıda kalırsa oturum boyunca hiçbir yan sahne oynamıyor, ilgili yan görev tamamlanamıyor

`SideEvents._play_scene` statik bir eşyordam; `_playing` statik bayrağı başta true yapılıyor, sonda false. Bekleme `tree.create_timer(secs)` (sahne değişse de sürer) ve her satırda `hud.bark(...)` geçerlilik denetimi olmadan çağrılıyor. Oyuncu 7-8 satırlık sahne sürerken duraklatma menüsünden "Bölümün başına dön"/"Kayıt yükle" seçerse ya da bölüm o sırada biterse, sonraki satırda silinmiş HUD'a çağrı hata verir, eşyordam düşer, `_playing` true kalır ve `council_heard`/`envoy_heard` bayrağı yazılmaz. Sonra bu sahnelere E'ye basmak sessizce hiçbir şey yapmaz (oyun kapanana dek). Ayrıca zamanlayıcı duraklatmada da işlediği için sahne menü açıkken konuşmaya devam eder: yeni bark `_voice.play()` ile sesi menünün arkasında çalar (Audio.hold yalnız menü açıldığı anda çalanları durdurur). Kanıt: scripts/side_events.gd:25, :133-160; scripts/autoload/audio.gd:237-253. Öneri: `_playing`'i sahne başında sıfırla (Hud._ready) ya da her adımda `is_instance_valid(hud)` denetleyip çık; bekleme için `create_timer(secs, false)`.

## 21. [ORTA] [görsel] [Ara sahne kamerası kullanan bölümler (ör. 17, 19, 22o, 23, 27, 29, 31o: `hud.add_child(cam)`), düello bitirici kamerası]
Ara sahnede F2 (fotoğraf modu) kapanınca kamera oyuncunun gözüne zorla dönüyor

`_photo_player()` yalnız Tolga'nın oynanıp oynanmadığına bakıyor; sinematik/donmuş durumu, etkin başka kamera ya da konuşma denetlenmiyor. `PhotoMode.close()` her durumda `player.camera.make_current()` diyor. Senaryo: bölüm yönetmeni sinematik kamerayla bir sahne oynatırken oyuncu F2'ye basıp çıkar; sahnenin kalanı oyuncunun birinci şahıs kamerasından (çoğu zaman duvara/yere bakarak) görülür, sinematik kamera bir sonraki `make_current`'a dek devre dışı kalır. Ayrıca fotoğraf modu açıkken (oyun duraklatılmış) seçim ekranı açıksa D-pad ↑/↓ (yakınlaştırma) arkadaki seçimi yapar (bkz. Hud.choose bulgusu). Kanıt: scripts/ui/hud.gd:3269-3290; scripts/ui/photo_mode.gd:57-70, :297-306. Öneri: açılırken `get_viewport().get_camera_3d()`'yi sakla ve kapanınca ona dön; `cinematic`, `player.frozen` ya da seçim/konuşma sırasında F2'yi kapat.

## 22. [ORTA] [oyun] [Bütün diyaloglar] (şüpheli)
Duraklatmadan Enter ya da kolda A ile "Devam et" seçmek açık repliği ilerletebilir

Menü düğmesi `ui_accept` basışında tetikleniyor, `picked` sinyali `_set_paused`'ı aynı karede sürdürüp `paused = false` yapıyor; `advance` eylemi de Enter ve A'yı içeriyor. say() döngüsü bir sonraki process_frame'de `paused` false görür ve `is_action_just_pressed("advance")` aynı karenin basışı sayılırsa yazıyı tamamlar ya da repliği geçer. Godot'nun "just pressed" kare sayımına bağlı; oyunda denenmeli. Kanıt: scripts/ui/hud.gd:1555-1567, :3324-3332; scripts/autoload/game_state.gd:1116 (`advance` = E/Space/Enter/sol tık/A/X).

## 23. [ORTA] [oyun] [Hedef işaretçisi] (şüpheli)
`hud.spot()` önbelleği aynı `interact_id`'ye sahip birden çok nesnede yanlış (ya da hiç) hedef gösterebilir

ilk bulunan düğüm önbelleğe alınıyor ve yalnız silinirse yeniden aranıyor; toplanıp gizlenen (ya da çarpışması kapatılan) ilk nesne önbellekte kaldıkça aynı kimlikli diğer nesneler hiç aranmıyor, işaret kaybolur. Ayrıca bulunamayan her kimlik için bütün sahne ağacı her karede baştan taranıyor (mini harita da aynı Callable'ı sorduğu için iki kez). Hangi bölümde aynı kimlikli birden çok nesnenin spot ile hedeflendiği doğrulanmadı. Kanıt: scripts/ui/hud.gd:711-741.

## 24. [ORTA] [görsel] [Edirne] (şüpheli)
Havuza dalıştan sonra uzun süre boş avlu

edirne_policy render'ında t00243-t00261 arası (~6 kare) kamera havuz kenarından bomboş avluya bakıyor; çocuklar, Halil ve muhafızlar görünmüyor. Çocukların _walk_bg yürüyüşü bitmezse her biri için _until(r, 7.0) bekleniyor (3×7 sn). Varsayılan varyantta (v3_17) çocuklar el sallıyor görünüyor; sorun kaçış/yakalanma yoluna bağlı olabilir. Kanıt: /tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit/renders/v3_edirne/t00243.7.jpg…t00261.4.jpg; scripts/interlude_edirne.gd:1456-1478.

## 25. [ORTA] [oyun] [] (şüpheli)
(şüpheli) [26] Aynı merdiven dövüşü otomatik testte ~25 dakikadan uzun sürdü ve render 1800 sn zaman aşımına uğradı (WaveRunner "limit": 75 sn verilmiş olmasına rağmen dövüş bitmedi; "E basılı: merdiveni it" istemi dövüş



