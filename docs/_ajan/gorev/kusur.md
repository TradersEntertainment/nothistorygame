Türkçe çalış. Bu depo Godot 4.4.1 ile yazılmış Türkçe birinci şahıs komedi oyunu "Gerçek Tarih Bu Değil" (1453 kuşatması; her şey GDScript ile üretiliyor). Sen bir yardımcı oturumsun: ana oturum ve başka yardımcılar başka makinelerde başka işleri yürütüyor. Görevin: fragman çekimi sırasında bulunan dört oyun kusurunu YENİDEN ÜRET, kök nedenini bul, düzelt, kanıtla. Soru sorma, plan onayı bekleme; başla, bitir, gönder.

## Kurulum
1. Godot 4.4.1 (Linux, x86_64): https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_linux.x86_64.zip → aç, yolu `G`. xvfb-run ve ffmpeg yoksa kur (apt).
2. Depo kökünde bir kez: `$G --headless --import`.
3. Başsız test: `timeout 420 $G --headless --max-fps 20 --path . -- --chapter=N --autotest[=varyant]`; `AUTOTEST PASS` olmalı ve `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `VISAUDIT`, `WARN_VOID_TELEPORT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `JOURNEY_MISS`, `JOURNEY_OVERLAP` satırları OLMAMALI. Varyantlar: `tests/run_tests.sh`.
4. Ekranlı koşu: `timeout 1800 xvfb-run -a -s "-screen 0 1280x720x24" $G --path . --resolution 1280x720 -- --chapter=N --autotest[=varyant] --dialogshots=KLASÖR`.
5. Önce oku: `docs/_ajan/ajan_kurallari.md` (bağlayıcı; `$S/...` yolları ana makineye ait, sen `/tmp/kusur/` kullan), `docs/QA_DERSLER.md`, `CLAUDE.md`.

## Kusurlar
1. **Bölüm 2, sonuç 2.1:** bölümün sonunda askerler kameranın (oyuncunun) içinden geçiyor. Hangi varyant 2.1'e çıkıyor, `tests/run_tests.sh` ve `scripts/chapter2.gd`'den bul; ekranlı koşuyla kareyle yakala; askerlerin yolu oyuncuyu dolanmalı ya da oyuncu kenara alınmalı (var olan `WALKTHRU` denetimi bunu neden yakalamadı, onu da açıkla ve gerekiyorsa denetimi güçlendir).
2. **Tek oturumda art arda yükleme takılması:** fragman aracı (`tools/trailer/montage.gd`) aynı süreç içinde önce Bölüm 17'yi (varyant `edirne_policy`), sonra Bölüm 15'i (varyant `wrong_stay`) yüklediğinde süreç 22 dakika %100 işlemciyle takılı kaldı. Oyunda da bölümler aynı süreçte art arda yüklenir (GameState.change / chapter geçişi), yani oyuncu da aynı takılmayı yaşayabilir. Yeniden üret (aynı süreçte 17 → 15; gerekirse başka çiftler de), sonsuz döngünün ya da kilitlenmenin yerini bul (ör. `await` bekleyen bir döngü, autotest botu, bayrak sızıntısı, bir önceki bölümden kalan statik durum), düzelt. Yeniden üretemezsen bunu açıkça yaz ve hangi koşulları denediğini listele.
3. **Bölüm 12, varyant "kitchen":** koşu "anahtar soru"ya (sahnenin asıl sorusu) hiç ulaşmıyor. Varyantın neyi sınadığını, akışın nerede koptuğunu bul; oyuncu için de aynı kopukluk var mı (yoksa yalnız bot mu), düzelt.
4. **Bölüm 0 (soğuk açılış):** yer/tarih başlık yazısı bot hızında (Engine.time_scale > 1) solmuyor, ekranda kalıyor. Normal hızda soluyor mu, kareyle doğrula; solma zaman ölçeğinden bağımsız doğru çalışmalı.

## Kurallar (kesin)
- Var olan replik metni değişmez/kesilmez; oynanış dengesi, gizli sayaçlar değişmez. Yeni `class_name` dosyası yok. Denetimleri susturmak yok. Ses üretimi yok. PR açma. `main` dalına dokunma. Alt ajan başlatma.
- Değiştirebileceğin dosyalar: `scripts/chapter2.gd`, `chapter12.gd`, `chapter0.gd`, `chapter15.gd`, `chapter17.gd`, 2. madde için kök neden neredeyse orası (küçük, dikkatli, gerekçeli; `scripts/autoload/game_state.gd` ve `scripts/ui/hud.gd`'de yalnız zorunlu en küçük değişiklik). `scripts/level/*`, `scripts/world/*`, `scripts/npc/*`, `scripts/player/*` dosyalarına dokunma (ana makinede değişiyorlar); gerekiyorsa raporda kod parçasıyla öner.
- Her düzeltme için kanıt: yeniden üretim (ÖNCE) ve aynı koşulda düzelmiş hâl (SONRA); görsel olanlarda aynı an kare çifti. "Düzeldi" demek için kanıt şart; yoksa KANITSIZ yaz.
- Testler: 0 (3 varyant), 2 (bütün varyantlar), 12 (bütün varyantlar), 15 ve 17 (run_tests.sh'taki listeler) son kodla geçmeli; sayıları ve hata satırlarını aynen yaz.

## Teslim
Değişiklikleri `wip/yardimci-kusur` dalına kaydet ve gönder. `docs/_kanit_kusur/rapor.md` (ve en çok 8 kanıt paftası, JPEG ≤ 300 KB): her kusur için yeniden üretim adımları, kök neden (dosya:satır), düzeltme, kanıt, durum (DÜZELDİ / KISMEN / YENİDEN ÜRETİLEMEDİ / AÇIK); test sayıları; ortak dosyalarda önerdiğin değişiklikler.
