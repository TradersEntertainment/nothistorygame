# Bekleyen planlar

Şimdi yapılmayacak, ileride karar verilecek işler. Sürüm raporlarında ara sıra hatırlatılır.

## Gerçekçi görsellere geçiş (2026-10-30, ertelendi: oyun bittikten sonra)

Soru: Bütün modeller Blender'da baştan, komedi çizgisi yerine gerçek hissiyatlı (Detroit: Become Human tarzı) yapılsa
ne kadar sürer?

Bugünkü durum: 62 sahne, ~100 konuşan karakter, ~145 bin satır GDScript; sahnelerin, insanların, askerlerin ve
animasyonların çoğu kodla kutu/silindir/küreden kuruluyor (hazır 3B model ~179 dosya). Gerçekçi grafik yalnız model
değişimi değil: sahne kurma kodu, karakter/animasyon sistemi ve ona bağlı denetimler (VISAUDIT, iç içe geçme, havada
duran) büyük ölçüde yeniden yazılır.

| Hedef | Ne gerekir | Süre (kaba) |
|---|---|---|
| Detroit seviyesi | Stüdyo, yüz ve vücut hareket yakalama, 100+ kişi | 3–4 yıl; bu proje için gerçek dışı |
| Gerçekçi AA indie | Unreal 5 (MetaHuman, Quixel), videodan hareket yakalama, 5–10 sanatçı; kodun çoğu yeniden | 1,5–3 yıl |
| Godot'da yarı gerçekçi | Blender'da kemikli karakterler, gerçek doku/malzeme, ışık; oyun mantığı kalır | 2–4 sanatçı + kod, ~8–15 ay |
| Mevcut stili cilalamak | Işık, malzeme, yüz ifadeleri, animasyon; modeller kademeli | Haftalar – birkaç ay |

Claude'un payı: Blender Python betikleriyle mimari, eşya ve sahne parçaları; içe aktarma, malzeme, ışık, animasyon
bağlama ve testler. Tek başına yapamayacağı: inandırıcı insan yüzü, heykel çalışması, oyuncu performansı (sanatçı ya
da MetaHuman ve yapay zekâ ile 3B üretim araçları + elle temizlik).

Ton: Mizah (fesli Tolga, leblebi, "±571 yıl") çizgi film stiliyle uyumlu; gerçekçi görselde farklı okunur. Grafik
işi olduğu kadar tasarım kararı.

Önerilen ilk adım (karar verilince): tek bölümde deneme, örneğin 9. bölüm pazarı; 2–3 karakter Blender modeliyle,
gerçek doku ve ışık. 2–4 hafta. Sonuç görülünce bütün oyuna yayılıp yayılmayacağına karar verilir.

## Aura Autopilot ile oyun testi (2026-10-31; 2026-11-02 bakıldı: şimdilik uygun değil)

Kaynak: https://x.com/aura_assistant/status/2116191581992816889 (Aura, @Aura_Assistant). Duyuruya göre açık kaynak,
oyunu ekrandan oynayıp hata bulan, kendini geliştiren bir ajan; Unity, Godot ve Unreal'ı destekliyor. Ücretsiz deneme ve
GitHub deposu var. "%43 daha doğru, 2 kat hızlı, Claude Code'dan iyi playtest" iddiaları firmanın kendi ölçümü,
doğrulanmadı.

Bizdeki karşılığı: senaryolu test botları (--autotest, 116 koşuluk hızlı takım), kaos ve durum fuzz'ı, sanal ekranda
kare denetimi (visual_run.sh + frame_check + Haiku paftaları), ses denetimi, VISAUDIT. Bunların ortak açığı: hepsi
bizim yazdığımız yolları yürüyor, oyunu "ilk kez gören biri" gibi oynamıyor.

Faydalanabileceğimiz yer: botun hiç gitmediği yerler (takılma noktaları, anlaşılmayan hedefler, görünmez duvarlar,
yanlış yöne giden oyuncu), oyuncu gözüyle "ne yapacağımı bilmiyorum" anları.

Denerken bakılacaklar: kurulumun Xvfb'li bulut kapsayıcıda çalışıp çalışmadığı; Godot 4.4 desteği; maliyet (model
çağrısı başına); bulgu kalitesi (gerçek hata mı, gürültü mü); bulguların bizim F8 hata raporu biçimine bağlanıp
bağlanamayacağı. Önerilen ilk adım: 2–3 bölümde (örneğin 1, 9, 18) bir gün deneme, bulguları mevcut testlerin
yakaladıklarıyla karşılaştırmak.

2026-11-02 inceleme (https://github.com/ramenvr/autopilot, Apache 2.0): Godot için 4.7 ve üstü gerekiyor (biz 4.4.1),
yalnız Windows ve macOS'ta editör eklentisi olarak çalışıyor, Aura hesabı ya da kendi API anahtarıyla. Bulut
kapsayıcısında (Linux) çalışmaz. Denemek için: (1) sahibinin Windows/Mac bilgisayarında, (2) oyunun Godot 4.7'ye
taşınması (ayrı bir iş; API değişiklikleri, bütün testler yeniden). Taşıma oyun bitince değerlendirilir.

## Claude Code Game Studios şablonu (2026-11-01, incelendi)

Kaynak: https://github.com/Donchitos/Claude-Code-Game-Studios (MIT). Tek Claude Code oturumunu "stüdyo"ya çeviren
şablon: 49 ajan (yönetmen, bölüm şefi, uzman), 74 skill (slash komutu), 15 hook, 14 kural, 62 belge şablonu. Godot 4
için ayrı uzman ajanlar ve sürüm farkları belgesi (docs/engine-reference/godot) var.

Değerlendirme: Bütünüyle kurmaya değmez. Şablon yeni başlayan projeye göre (fikir → GDD → mimari → epik/hikâye →
sprint); bizim oyun v0.99'da, akışımız (denetim → düzeltme → test → sürüm, Haiku denetçileri, QA_DERSLER) oturmuş.
Kendi ölçümleri de söylüyor: kodu yazmadan önce 30 belge çıkaran mod, tek sayfalık moddan daha iyi oyun üretmemiş.
49 ajan ve yönetmenlerin Opus istemesi kotayı yer.

İşe yarayabilecek parçalar (seçip uyarlamak, kurmadan):
- launch-checklist: Steam çıkışı öncesi bölüm bölüm hazırlık listesi (mağaza sayfası, yasal, yerelleştirme,
  başarımlar, performans, çökme raporu). docs/STEAM.md ile birleştirilebilir.
- perf-profile: bütçeye karşı darboğaz raporu. Bilinen açık: 20, 26, 26o, 30o, 34o, 41o, 42b'de düşük FPS'te
  render NOPASS.
- soak-test: saatlerce oynamada bellek sızıntısı ve geç çıkan hatalar (çıkışta "ObjectDB leaked" uyarısı görülüyor).
- accessibility-specialist: erişilebilirlik denetimi (renk körlüğü, altyazı boyutu, tuş atama, QTE süreleri).
- Godot sürüm farkları belgesi: 4.5–4.7'ye geçilirse kırılacak API'ler için başvuru.

## Aynı evrende ikinci oyun (2026-11-02, sürekli kural)

Sahibinin isteği: evren, ileride aynı evrende ikinci oyun yapılabilecek özenle kurulmalı.
- Kanon: docs/EVREN.md (karakterler, Zaman Bürosu ve zaman yolculuğu kuralları, mekânlar, tekrar eden öğeler,
  tutarlılık kuralları). Yeni hikâye, karakter ya da kural eklendiğinde EVREN.md de güncellenir; çelişki çıkarsa
  sahibine sorulur.
- Kodda yeniden kullanılabilir çekirdek (ikinci oyuna taşınacak): CharKit/Rig/Person/Soldier (karakter kiti ve
  canlandırma), HandRig ve eşyalar (Items), Props/LowPoly (ilkel model), World1453/CityLife (şehir ve kalabalık),
  Hud/diyalog/seslendirme hattı (voice_gen, voice_tempo, voice_trim, VoiceGain, LipSync), Audio, testler (autotest,
  visual_run, audio_run, soak, hitch/still denetçileri, smooth_check). Bölüme özgü kod (chapter*.gd) çekirdeğe
  bağımlı olabilir, çekirdek bölümlere bağımlı olmamalı. Oyun bitince çekirdek ayrı bir klasöre/eklentiye ayrılır.
- Karar bekleyen: ikinci oyunun hangi finali kanon kabul edeceği (EVREN.md'de seçenekler).
