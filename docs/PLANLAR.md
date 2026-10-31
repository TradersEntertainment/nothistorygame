# Bekleyen planlar

Şimdi yapılmayacak, ileride karar verilecek işler. Sürüm raporlarında ara sıra hatırlatılır.

## Gerçekçi görsellere geçiş (2026-10-30, ertelendi)

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

## Aura Autopilot ile oyun testi (2026-10-31, değerlendirilecek)

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
