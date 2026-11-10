# Çıkış hazırlığı denetimi: Gerçek Tarih Bu Değil (VERSION 0.99.109)

Denetim yalnızca okuyarak yapıldı (Read/Grep/Glob); oyun derlenmedi, çalıştırılmadı. Yollar `/home/user/nothistorygame`'e göredir.
"tahmin" yazan yerler koddan çıkarılan, çalıştırılarak doğrulanmamış sonuçlardır.

## (A) Kontrol listesi: güncel kodla karşılaştırma

### docs/LAUNCH_CHECKLIST.md

| # | Madde | Belgedeki durum | Gerçek durum | Kanıt / not |
|---|---|---|---|---|
| 1 | App ID, depo ID | EKSİK | YAPILMADI | `tools/steam/app_build.vdf:3` `"AppID" "APPID"`, `:9-11` DEPOTID_* yer tutucu |
| 2 | GodotSteam eklentisi | KISMEN | KISMEN | Köprü var: `scripts/autoload/steam_bridge.gd:13-37`; `addons/` boş (Glob sonuç vermedi) |
| 3 | 62 başarım + 64×64 simge | KISMEN | Kod tarafı TAMAM, simge YOK | `scripts/achievements.gd:7-70` 62 kayıt, belgedeki 62 kimlikle birebir aynı; simge dosyası bulunamadı |
| 4 | Yapay zekâ beyanı | EKSİK | YAPILMADI, taslak da EKSİK | Taslak (`LAUNCH_CHECKLIST.md:51-54`) müziği saymıyor; müzik ElevenLabs Music ile üretilmiş: `tools/music_gen.py:2`, `scripts/autoload/audio.gd:227-231` (önce .mp3 çalınıyor) |
| 5 | IARC anketi | EKSİK | KODDAN DOĞRULANAMAZ | Steamworks'te yapılıyor |
| 6 | Mağaza metinleri | KISMEN | KISMEN, bir yanlış var | Sistem gereksinimi "Vulkan destekli" (`LAUNCH_CHECKLIST.md:49`), oysa oyun GL Compatibility kullanıyor (`project.godot:16,39-41`, OpenGL 3.3/ANGLE). "56 bölüm · 27 final" ile oyun içi tanıtım çelişiyor (bkz. B) |
| 7 | Dışa aktarım sürümü = VERSION | HAZIR | KISMEN (belge eskimiş) | CI sürümü yazıyor (`release.yml:68`), ama Windows'ta `application/modify_resources=false` (`export_presets.cfg:31`): dosya özellikleri ve simge exe'ye işlenmez (tahmin: Godot bu bayrak kapalıyken PE kaynaklarını değiştirmiyor). macOS'ta yazılıyor |
| 8 | Tam oyunun açık depoda yayımı | KARAR | Hâlâ AÇIK | `release.yml:122-133` her sürümde `nothistorygamedemo`'ya yüklüyor; `:148-172` eski sürüm sayfalarını da yeni dosyalarla güncelliyor |
| 9 | Oyun lisansı / EULA | EKSİK | YAPILMADI | Kökte `LICENSE*` yok (Glob) |
| 10 | Steam Cloud | EKSİK | YAPILMADI | Kayıtlar `user://` (`game_state.gd:5-8`); `project.godot` içinde `use_custom_user_dir` yok, klasör adı Türkçe karakterli (bkz. B) |
| 11 | Deck 1280×800 | KISMEN | KISMEN | `tests/` ve `scripts/` içinde 1280×800 geçmiyor; görüntü `canvas_items` + `expand` (`project.godot:29-30`), uyum tahmin |
| 12 | Kod imzası, noter | EKSİK | YAPILMADI | Win `codesign/enable=false` (`export_presets.cfg:30`); macOS ad-hoc `codesign/codesign=1`, kimlik boş, `notarization=0` (`:117-120,135`) |
| 13 | Çökme raporu | KISMEN | KISMEN (doğru) | F8 ve menü düğmesi: `game_state.gd:1572,1627-1628,1660-1700`, `game_menu.gd:306`; kendiliğinden çökme kaydı yok; yalnızca yerelde, ağa bir şey gitmiyor |
| 14 | CHANGELOG, geri bildirim | KISMEN | KODDAN DOĞRULANAMAZ | Hata raporu metni "bize gönder" diyor ama adres vermiyor (`i18n/strings.csv:3139`) |
| 15 | Mağaza görsel ölçüleri | KISMEN | Belge eskimiş | Belge eski ölçüleri yazıyor (616×353, 231×87, 460×215); `store/` dosyaları ve `assets/CREDITS.md:102-105` güncel ölçüleri (920×430, 462×174, 1232×706, 748×896, 3840×1240…) veriyor. Piksel ölçüsü okunamadı, doğrulanmalı |
| 16 | Erişilebilirlik | KISMEN | KISMEN, belge eskimiş | "Arayüz ölçeği kaldı" yazıyor ama var: `game_menu.gd:606`, `game_state.gd:1230`. Ortam sesi kanalı yok (yalnızca Music/SFX/Voice: `game_state.gd:1039`), renk körlüğü seçeneği yok |
| 17 | Performans | KISMEN | KODDAN DOĞRULANAMAZ | Kalite 0-3 var (`game_state.gd:1142-1194`); varsayılan kalite 2 (`:66`), Deck için önerilen "Orta" değil |

### docs/STEAM.md ve docs/STEAM_ACHIEVEMENTS.md iddiaları

| İddia | Durum | Kanıt |
|---|---|---|
| Eklenti yoksa oyun her yerde aynı çalışır | TAMAM | `steam_bridge.gd:14-15` singleton yoksa döner; `:20-22` başlatma hatasında yalnız uyarı |
| Açılışta `SteamBridge.init()` bağlanır | TAMAM | `game_state.gd:189-190` (autotest/shots/exitcheck dışında); `tick()` `:552` |
| Önceden açılan başarımlar ilk Steam açılışında eşitlenir | TAMAM (tek yönlü) | `steam_bridge.gd:23-25`; Steam'den yerele eşitleme yok |
| "GodotSteam eklenince unlock_achievement'a setAchievement eklemek yeter" (STEAM_ACHIEVEMENTS.md:4) | Belge eskimiş: zaten yapılmış | `game_state.gd:1772` → `steam_bridge.gd:33-37` |
| Kimlikler oyundakiyle birebir | TAMAM | 62/62 eşleşiyor; her koşulun sayacını yazan kod var (ör. `vista.gd:26`, `grade.gd:45-51`, `chapter28o.gd:525`); belgede olup kodda olmayan ya da kodda olup belgede olmayan başarım yok |
| SteamPipe: zip'leri `content/*`'a aç, `run_app_build ../scripts/app_build.vdf` | KISMEN / belge belirsiz | Dosya `tools/steam/` altında; komut ContentBuilder'ın `scripts/` klasörünü varsayıyor, kopyalama adımı yazmıyor. GitHub zip'lerinde GodotSteam olmadığı için bu yolla yüklenen sürüm başarımları Steam'e göndermez (eklenti depoya girene kadar) |
| Deck: "kol desteği tam", ipuçları kola döner | ÇOĞUNLUKLA TAMAM | Kol atamaları `game_state.gd:1547-1592`, ipucu çevirisi `:1704-1709`. Foto modu (F2), hata raporu (F8), FPS (F3) kolda yok ama menüden ulaşılıyor (`game_menu.gd:305-306,604`). Kol tuşları yeniden atanamıyor (`:1103` yalnız klavye) |
| Önerilen: kalite Orta, altyazı %120 | Seçenekler VAR | `game_menu.gd:588,599`; varsayılan Yüksek ve %100 |
| macOS universal, ad-hoc imzalı | TAMAM | `export_presets.cfg:101,117,135` |
| "Steam'den dağıtımda uyarı çıkmaz" | KODDAN DOĞRULANAMAZ | Gerçek Mac'te denenmeli |

## (B) Riskler

### BLOCKER

**B1. Tam oyun her sürümde ücretsiz, herkese açık yayımlanıyor.** `release.yml:122-133` (`nothistorygamedemo`, `make_latest: true`) ve `:148-172` (eski sürüm sayfaları). Steam'de satılacak bir oyunun bedava ve güncel tam sürümü GitHub'da durursa satış zarar görür. Oyun içinde de bu siteye bağlantı var: `final_review.gd:309`.
En küçük düzeltme: sahibin kararıyla iki adımı `if: false` yapmak ya da ayrı bir demo dışa aktarımı hazırlamak (ör. `custom_features="demo"` ile ilk perdeden sonrasını kesmek).

**B2. GodotSteam depoda yok, Steam yükleme yolu başarımsız sürüm üretir.** `addons/` boş; STEAM.md §4 GitHub zip'lerini yüklemeyi söylüyor. Bu zip'lerde eklenti olmadığı için `Engine.has_singleton("Steam")` false döner (`steam_bridge.gd:14`) ve 62 başarımın hiçbiri Steam'e gitmez.
En küçük düzeltme: GodotSteam GDExtension'ı (Godot 4.4.x sürümü) `addons/godotsteam/` olarak depoya eklemek ve CI'da paketin içinde `libsteam_api`/`steam_api64.dll` dosyasının bulunduğunu denetlemek. Eklenti Godot 4.4.1 şablonlarıyla uyumlu olmalı (CI: `release.yml:29`).

**B3. Yapay zekâ beyanı ve CREDITS yanlış ya da eksik.** `assets/CREDITS.md:5` "üçüncü taraf kaynak kullanılmamıştır" diyor; aynı dosyanın `:89-91` satırları müziği "numpy ile prosedürel" diye anlatıyor. Oysa oyun önce ElevenLabs Music mp3'lerini çalıyor (`audio.gd:227-231`, `tools/music_gen.py:2`; `assets/audio/music/` içinde 40'tan fazla mp3 var). Ortam sesleri ElevenLabs SFX ile üretilmiş (`tools/amb_gen.py:2`). Seslendirmenin (ElevenLabs TTS) CREDITS'te bölümü yok. Quaternius CC0 modelleri ve animasyonları (`assets/models/CREDITS_QUATERNIUS.txt`, `assets/anim/CREDITS.txt`), DejaVu ve Noto Color Emoji yazı tipleri (`assets/fonts/LICENSE_DejaVu.txt`, `LICENSE_NotoColorEmoji.txt`) ana CREDITS'te yok. Steam'in AI içerik formu yanlış ya da eksik doldurulursa inceleme reddedebilir ve mağaza sayfası yanıltıcı olur.
En küçük düzeltme: CREDITS.md'ye "Seslendirme: ElevenLabs", "Müzik: ElevenLabs Music", "Ortam/SFX: ElevenLabs + prosedürel", "Quaternius CC0", "DejaVu, Noto Emoji" satırlarını eklemek; beyan taslağına müziği eklemek. ElevenLabs ticari kullanım hakkı plan bazında doğrulanmalı (bu sahibin işi, bkz. C).

**B4. Lisans: depoda LICENSE ya da EULA yok, Godot/MIT bildirimi oyunda yok.** Kökte `LICENSE*` yok. `i18n/strings.csv` içinde "Godot Engine" ya da MIT bildirimi geçmiyor, oyunda jenerik/künye ekranı da yok (menüler: `game_menu.gd:282-296`). Godot'nun MIT lisansı, telif bildiriminin dağıtılan oyunla birlikte verilmesini istiyor. OFL lisans .txt dosyaları `all_resources` dışa aktarımına girmez (tahmin), kurulum da yalnız `OYNA.txt` kopyalıyor (`installer.nsi:57`).
En küçük düzeltme: Ayarlar ya da ana menüye "Künye" sayfası eklemek (Godot `Engine.get_license_text()`, yazı tipleri, Quaternius, ElevenLabs); `THIRD_PARTY.txt` dosyasını zip'lere ve Steam deposuna koymak.

### SHOULD FIX

**S1. Test bayrakları sürüm derlemesinde kapısız.** `game_state.gd:112-176`: `--autotest`, `--chapter=`, `--chaos`, `--bag=`, `--flag=`, `--outcome=`, `--difficulty=`, `--lang=`; ayrıca `arena.gd:44-46` `--arena=`. Yalnızca `dressing.gd:1086` `OS.is_debug_build()` ile korunuyor. `--chaos`, `--flag` ve `--bag` ile kayıt kapanmıyor (kapatan yalnız autotest ve shots: `:817-818`), yani oyuncu Steam başlatma seçenekleriyle bayrakları değiştirip otomatik kayda ve başarımlara yazabilir. `--flowtrace` ve `--heldcycle` dışa aktarılmayan `res://tests/` altındaki betikleri yüklüyor (`:137,140`); paketli oyunda `load()` null döner, `.new()` betik hatası verir (tahmin). Ek olarak başlık ekranında "yarat" yazınca gizli Yaratıcı Menüsü açılıyor (`hud.gd:3507,3550-3563`), bütün bölümler kayıt onayı sorulmadan açılabiliyor. Tek oyunculu oyunda hile sorun değil; asıl risk spoiler ve kendi kaydının üstüne yazılması.
Kapı koyarken dikkat: CI paketli oyunu `--chapter=1 --autotest` ile deniyor (`release.yml:79`), bu yüzden düz `is_debug_build()` kapısı bu testi bozar. En küçük düzeltme: bayrakları `OS.is_debug_build() or OS.has_environment("NHG_TEST")` koşuluna bağlamak (CI'da ortam değişkeni verilir), `--flowtrace` ve `--heldcycle`'ı `ResourceLoader.exists` ile korumak, Yaratıcı Menüsü'nü aynı koşula almak ya da bilinçli bir "bölüm seç" özelliği olarak bırakmak.

**S2. Meta kaydı atomik değil, başarımlar ve finaller kaybolabilir.** Bölüm kayıtları tmp, .bak ve rename ile doğru yazılıyor (`game_state.gd:837-857`). Ama `meta.cfg` (başarımlar, görülen finaller, tarih sayfaları, dil) doğrudan `cfg.save` ile yazılıyor (`:1526-1539`), `settings.cfg` de öyle (`:1100`). Yazma sırasında oyun çökerse ya da elektrik giderse `_load_meta` sessizce boş başlar (`:1514`), sonraki kayıt da boş meta'yı kalıcı yapar. Steam'den yerele geri eşitleme yok (`steam_bridge.gd:23-25` tek yönlü).
En küçük düzeltme: meta ve ayarları aynı `_write` deseniyle (tmp, .bak, rename) yazmak ve okurken .bak'a düşmek.

**S3. Kayıt sürümü yazılıyor ama okunmuyor.** `"version": 1` yazılıyor (`:831`), ama `read_save` yalnızca `snapshots` anahtarına bakıyor (`:850-857`), `prepare_load` da `data["chapter"]` değerini ve snapshot'taki sahne yolunu denetlemeden kullanıyor (`:999-1017`). Bir güncelleme sahne adını değiştirirse `change_scene` var olmayan yola gider (`:902`): menü kapanmış, sahne açılmamış olur (tahmin). Ücretli oyunda güncelleme sonrası "kaydım açılmıyor" en sık şikâyetlerden biridir.
En küçük düzeltme: `prepare_load` içinde `ResourceLoader.exists(path)` başarısızsa bölümün varsayılan sahnesine düşmek; `version` alanına göre göç işlevi için yer açmak.

**S4. Steam Cloud ve kayıt klasörü.** Godot varsayılanı kullanılıyor, klasör adı proje adından geliyor: `…/Godot/app_userdata/Gerçek Tarih Bu Değil/` (`project.godot:13`; `use_custom_user_dir` yok). Auto-Cloud'da Türkçe karakterli yol risk taşır (tahmin). `settings.cfg` (tam ekran, kalite) makineye özgüdür ve buluta gitmemeli. `reports/`, `playtest`, `logs`, `.tmp` dosyaları da aynı kökte duruyor.
En küçük düzeltme: Auto-Cloud kalıbını yalnızca `save_*.dat`, `save_auto.dat` ve `meta.cfg` olarak tanımlamak. `custom_user_dir` değiştirilecekse bunu çıkıştan önce ve eski klasörden bir kerelik kopyalayan göç koduyla yapmak; yoksa GitHub oyuncularının kayıtları kaybolur.

**S5. Windows exe kimliği ve sürüm bilgisi.** `export_presets.cfg:31` `modify_resources=false`, `:32` `icon=""`, `:40` telif boş. Exe'de Godot simgesi ve Godot dosya bilgisi kalır (tahmin). `file_description` hâlâ "Bölüm 1: Zamanatör" (`:39`; ayrıca `project.godot:14`). Oyun içinde sürüm gösterilmiyor. Hata raporu `res://VERSION` dosyasını okuyor (`game_state.gd:1337,1672`), ama uzantısız dosya `all_resources` filtresiyle pakete girmez, `include_filter=""` (`:10`); raporlarda sürüm "?" ya da boş çıkar (tahmin, paket açılarak doğrulanmalı).
En küçük düzeltme: `include_filter="VERSION"`, Windows'ta `modify_resources=true` ve `.ico` simgesi (Godot 4.4'te rcedit gerekip gerekmediği CI'da denenmeli), ana menünün köşesine sürüm etiketi.

**S6. Oyun içi sayılar mağaza metniyle çelişiyor.** Yeni oyun tanıtımı "17 bölüm, 80+ karar, 91 sonuç, 24 final" diyor (`hud.gd:3598`, `strings.csv:2561`). Kod 27 final sayıyor (`achievements.gd:72`), mağaza taslağı "56 bölüm · 27 final" diyor. Oyuncu ilk ekranda tutarsız bilgi görür.
En küçük düzeltme: sayıları sabitlerden hesaplamak (ör. `Achievements.FINALS_TOTAL`).

**S7. Release iş akışı kırılgan.**
- Tetikleyiciler (`release.yml:8-23`): `v*` etiketi; `main`'de `VERSION` ya da `release-mirrors.txt` değişince; elle çalıştırma.
- Yaptıkları: hızlı test paketi (QUICK=1, `:54-57`); Windows ve Linux dışa aktarımı; paketli oyunun açılış ve 1. bölüm testi (`:78-83`); NSIS kurulumu; macOS (`continue-on-error`, `:92-93`, başarısızsa sürüm macOS'suz ve sessizce çıkar); GitHub Releases'e, açık depoya ve eski sürüm sayfalarına yükleme.
- İmza: Windows imzasız, macOS ad-hoc imzalı ve noter onaysız, Linux'ta gerekmiyor.
- Eksikler: `concurrency` yok, aynı sürüm hem etiket hem `main` push'u ile iki kez koşup aynı etikete yarışabilir. `timeout-minutes` yok (varsayılan 6 saat). `wget` için yeniden deneme yok (`:42,45`). İş başlamadan GitHub tarafında düşen bir koşu ("Internal server error") için yeniden deneme ya da bildirim yok; böyle bir koşu workflow içinden yakalanamaz, GitHub'ın varsayılan başarısızlık e-postası dışında kimse uyarılmaz.
- En küçük sağlam düzeltme: ayrı bir `release-watchdog.yml` (`schedule: cron "17 * * * *"`, `permissions: actions: write, contents: read`). Bu iş `v$(cat VERSION)` sürümü yoksa ve son bir saatte çalışan Release koşusu da yoksa `gh workflow run release.yml -f version=$(cat VERSION)` çalıştırır (GITHUB_TOKEN workflow_dispatch tetikleyebilir). Ek olarak `release.yml`'ye `concurrency: {group: release-${{ github.ref }}, cancel-in-progress: false}`, `timeout-minutes: 120` ve `wget --tries=3` eklenir; macOS başarısız olursa `::warning::` ile sürüm notuna yazılır.

**S8. Ayarlar: oyuncunun beklediği seçeneklerden eksikler** (`game_menu.gd:575-626`).
- Var: müzik, efekt ve ses kaydırıcıları; konuşma hızı; fare ve kol hassasiyeti; ters Y; klavye tuş atama; tam ekran (F11, Alt+Enter); vsync; kalite 0-3; FOV; sarsıntı efekti; zorluk; altyazı boyutu; işaretçi; mini harita; otomatik ilerleme; süreli seçim; FPS; arayüz ölçeği; sallanma; aç/kapa tutuş; tepki ve okuma süresi; dil.
- Yok: çözünürlük ya da pencere boyutu ve ekran seçimi; ana ses (Master) kaydırıcısı; ortam sesi kanalı; kol tuşlarını yeniden atama (`game_state.gd:1103-1116` yalnız klavye); renk körlüğü; altyazı arka planı; FPS sınırı.
- Varsayılanlar: pencereli 1280×720 ve kalite Yüksek (`game_state.gd:64-66`).
- Odak kaybında ve Steam katmanı açılınca duraklatma yok (`FOCUS_OUT` ya da `overlay_toggled` geçmiyor).
- En küçük düzeltme: `NOTIFICATION_APPLICATION_FOCUS_OUT` gelince duraklatma menüsünü açmak, ilk açılışta tam ekran, Master kaydırıcısı eklemek. Çözünürlük için `window/size` seçenekleri sonra eklenebilir.

### NICE TO HAVE

- **N1.** Kendiliğinden çökme kaydı yok. Godot günlüğü `user://logs/godot.log`'a düşüyor ve F8 raporu onun son 300 satırını alıyor (`game_state.gd:1689-1695`). Ağ çağrısı yok: `HTTPRequest`, `HTTPClient` ve soket kullanılmıyor. Tek dış bağlantı tarayıcıda açılan `final_review.gd:309` (github.io). Playtest verisi yalnız yerelde kalıyor, panoya kopyalanıyor (`:1422`) ve oyuncuya açıklanıyor (`strings.csv:3515`). Gizlilik politikası gerekmeyebilir (tahmin). Rapor metnine gönderim adresi eklenmeli.
- **N2.** Otomatik kayıt yalnızca bölüm başlarında (`_autosave`, `:821-826`). Bölüm ortasında çıkan oyuncu ilerlemesini kaybeder; "Yeni oyun" onayı var (`game_menu.gd:285-289`), slota üstüne yazma onayı da var (`:452`).
- **N3.** `str_to_var` ile okunan kayıtta ayar ve tuş sözlüğü türleri denetlenmiyor (`game_state.gd:1087-1088,1115`); elle bozulmuş `settings.cfg` hata basabilir (tahmin).
- **N4.** Steam: `restartAppIfNecessary` yok, yani Steam dışında açılan Steam sürümü başarım yazmaz (bilinçli olabilir). Deck'e özel kod yok. Kol ipuçları yalnızca Xbox adlarıyla (`:1704-1705`), PlayStation simgesi yok.
- **N5.** macOS `min_macos_version_x86_64="10.12"` (`export_presets.cfg:113`), mağaza taslağı macOS 11 diyor; macOS simgesi boş (`:105`), proje simgesi 128 px SVG (`icon.svg:1`), büyük boyutta bulanık görünebilir.
- **N6.** Push ile yapılan yayın yalnızca hızlı testten geçiyor (`release.yml:56`); tam paket elle seçilmedikçe CI'da koşmuyor.
- **N7.** `LATEST_CHAPTER := 15` ve yorumları (`game_state.gd:10-11`) güncel bölüm sayısını yansıtmıyor; yalnızca geliştirici menüsünü etkiliyor.

## (C) Yalnızca sahibin yapabilecekleri

1. Steamworks hesabı, Steam Direct ücreti, App ID ve depo ID'leri; `tools/steam/*.vdf` için numaralar.
2. Tam oyunun GitHub'da açık yayımına karar vermek (B1): durdurmak, demoya çevirmek ya da gizli depoya almak; eski sürüm sayfalarındaki dosyalar da buna dahil.
3. ElevenLabs aboneliğinin ticari kullanım hakkını (TTS, Music, SFX) belgelemek; Steam AI içerik formunu doldurmak (müzik dahil).
4. IARC yaş derecelendirme anketi; mağaza metinleri, etiketler, fiyat ve bölgesel fiyatlar, çıkış tarihi, "Yakında" sayfası ve istek listesi.
5. Lisans ve EULA kararı (Steam varsayılan EULA'sı yeterli mi), şirket ve telif adı ("TradersEntertainment" yasal bir varlık mı), vergi ve banka formları.
6. Windows kod imzası sertifikası ve Apple Developer hesabı; noter onayı isteniyorsa ekip kimliği ve gizli anahtarların CI'a eklenmesi.
7. Steamworks'te 62 başarımın TR/EN ad ve açıklamalarıyla girilmesi, kilitli ve açık simgelerin yüklenmesi; Auto-Cloud kalıpları (S4) ve kota.
8. Steam Input varsayılan şablonu ("Gamepad"), Deck Verified başvurusu ve gerçek Deck'te deneme; gerçek Mac ve Windows makinelerde kurulum denemesi.
9. Mağaza görsellerinin gerçek piksel ölçülerinin Steamworks yükleyicisinde doğrulanması (`store/`).
10. Topluluk ve destek kanalı (Steam tartışmaları ya da Discord) ve hata raporunun gönderileceği adres.
