# Steam çıkış hazırlık listesi

Kaynak: Haiku denetimi (2026-11-02, Claude Code Game Studios'taki launch-checklist'ten uyarlandı) ve doğrulama.
Durum: HAZIR · KISMEN · EKSİK. "Kim": **S** sahibi (hesap, karar, imza), **C** Claude (kod, belge, test).

## Çıkıştan önce mutlaka

| # | Madde | Durum | Kim | Not |
|---|---|---|---|---|
| 1 | Steamworks App ID, depo ID | EKSİK | S | `tools/steam/app_build.vdf` yer tutucu. App ID gelince C bağlar. |
| 2 | GodotSteam eklentisi | KISMEN | C | Köprü kodu hazır (`scripts/autoload/steam_bridge.gd`), eklenti `addons/` içinde yok; App ID ile denenir. |
| 3 | 62 başarım Steamworks'e girilir, 64×64 simgeler | KISMEN | S + C | Kimlikler `docs/STEAM_ACHIEVEMENTS.md`. Simgeleri C üretebilir; girişi S yapar. |
| 4 | Yapay zekâ içerik beyanı | EKSİK | S | Taslak aşağıda. ElevenLabs ticari kullanım koşulları hesabın planına göre doğrulanmalı. |
| 5 | IARC yaş derecelendirme anketi | EKSİK | S | Savaş/şiddet (stilize, kan yok), alkol yok; anket Steamworks'te. |
| 6 | Mağaza metinleri (tr/en), etiketler, sistem gereksinimleri | KISMEN | C taslak, S onay | Taslak aşağıda. |
| 7 | Dışa aktarım sürüm bilgisi = VERSION | HAZIR | C | v0.99.73'ten beri CI eşitliyor (Windows dosya özellikleri 0.1.0.0, macOS 1.0 kalmıştı). |
| 8 | Tam oyunun açık depoda (nothistorygamedemo) yayımlanması | KARAR | S | `release.yml` her sürümde tam oyunu herkese açık depoya yüklüyor. Steam'de satılacaksa bu ücretsiz dağıtım durdurulmalı ya da ayrı demo derlemesine çevrilmeli. |
| 9 | Oyun lisansı / kullanım koşulları | EKSİK | S | Depoda LICENSE yok. Kapalı kaynak ticari oyun için "tüm hakları saklıdır" ve EULA (Steam varsayılan EULA'sı yeterli olabilir). |

## Olsa iyi olur

| # | Madde | Durum | Kim | Not |
|---|---|---|---|---|
| 10 | Steam Cloud (kayıt dosyaları) | EKSİK | S + C | Kayıtlar `user://` altında; Steamworks'te Auto-Cloud yolu tanımlanır. |
| 11 | Steam Deck 1280×800 denetimi | KISMEN | C | Arayüz testleri 1280×720'de; 1280×800 ekran testi eklenebilir. |
| 12 | Windows kod imzası, macOS noterlemesi | EKSİK | S | Sertifika ve Apple geliştirici hesabı ister. Steam'den indirmede Windows uyarısı çıkmaz; macOS için önemli. |
| 13 | Çökme raporu | KISMEN | C | F8 hata raporu var, kendiliğinden çökme kaydı yok. |
| 14 | CHANGELOG ve geri bildirim kanalı | KISMEN | S | Sürüm notları `nothistorygamedemo/data/changelog.json`'da; Steam'de topluluk merkezi/Discord kararı. |
| 15 | Mağaza görselleri ölçüleri | KISMEN | C | `store/` içinde 9 görsel; Steam ölçüleriyle (kapsüller 616×353, 231×87, 460×215, 1232×706, kütüphane 600×900 vb.) karşılaştırılmalı. |
| 16 | Erişilebilirlik | KISMEN | C | v0.99.73: sallanma kapatma, aç/kapa, tepki ve okuma süresi. Arayüz ölçeği ayarı var. Kalan: renk körlüğü, ortam sesi kanalı. |
| 17 | Performans | KISMEN | C | Düşük FPS'te gülle isabet hatası düzeltildi (v0.99.73); hedef: orta dizüstünde 60 FPS (GDD). |

## Mağaza metni taslağı

**Kısa açıklama (tr):** 1453, İstanbul. Pijamalı mucit Hikmet Amca'nın koli bantlı zaman makinesi çalışıyor; tek sorun,
gönderdiği kişinin bir sigortacı olması. Fatih'e risk tablosu sunun, kuşatmayı iki taraftan yaşayın, pazartesi 09:00
toplantısına yetişmeye çalışın.

**Short description (en):** Istanbul, 1453. A duct-taped time machine sends an insurance salesman to the conquest of
Constantinople. A fully voiced, first-person time-travel comedy where every choice bends history.

**Öne çıkanlar:** Tamamen seslendirilmiş (Türkçe ve İngilizce) · 27 final · kuşatma iki taraftan (Bizans surları ya da
Osmanlı ordugâhı) · 56 bölüm · klavye-fare ya da kol · Windows, macOS, Linux / Steam Deck.

**Önerilen etiketler:** Komedi, Hikâye Zengin, Seçimler Önemli, Birinci Şahıs, Tarihî, Zaman Yolculuğu, Birden Fazla Son,
Macera, Bağımsız, Sesli Anlatım.

**Sistem gereksinimleri (taslak, ölçülmeli):** 64 bit Windows 10 / macOS 11 / Ubuntu 22.04; 4 çekirdekli işlemci;
8 GB RAM; OpenGL 3.3 destekli ekran kartı (GTX 1050 / RX 560 sınıfı; düşük kalitede tümleşik grafik); 3 GB disk.

**Yapay zekâ beyanı taslağı (Steam "AI generated content" formu):** Seslendirmeler, oyun içi metinlerden ElevenLabs
ses sentezi ile üretildi; müzikler ElevenLabs Music ile, ortam sesleri ve bazı ses efektleri yapay zekâ ile sentezlendi. Oyun kodu ve içeriğin bir kısmı yapay zekâ
destekli araçlarla geliştirildi ve ekip tarafından gözden geçirildi. Oyunda çalışma anında içerik üreten bir yapay zekâ
yoktur.

## 0.99.110 denetimi: açık kalanlar

Güncel koda karşı yapılan denetimin (Kasım 2026) özeti. Bu sürümde kapananlar: ayar ve başarım dosyaları kayıtlar
gibi yedekli yazılıyor; açılmayan eski kayıt bölümün kendi sahnesine düşüyor; paketli oyunda `--flag`, `--bag`,
`--outcome`, `--chaos` ile açılan oturum kayıt ve başarım yazmıyor; `VERSION` pakete giriyor; Release iş akışına
zaman sınırı, indirme yeniden denemesi ve GitHub tarafında düşen koşuyu yeniden başlatan bekçi eklendi;
`assets/CREDITS.md` müzik ve seslerin gerçek kaynağını söylüyor.

**Çıkışı durduranlar (sahibinin kararı ya da işi):**
1. Tam oyun her sürümde açık depoya (nothistorygamedemo) ücretsiz yükleniyor; oyunun içinden de oraya bağlantı var
   (`scripts/ui/final_review.gd`). Satış başlamadan durdurulmalı ya da ayrı bir demo derlemesine çevrilmeli.
2. GodotSteam eklentisi depoda yok (`addons/` boş). GitHub zip'i Steam'e yüklenirse 62 başarımın hiçbiri Steam'e
   gitmez (`scripts/autoload/steam_bridge.gd`). Kod tarafı hazır: 62/62 başarım belgede ve kodda eşleşiyor.
3. LICENSE / EULA dosyası yok; oyunda künye ekranı ve Godot (MIT) ile üçüncü taraf bildirimleri yok.
4. ElevenLabs aboneliğinin ticari kullanım hakkı (ses, müzik, efekt) belgelenmeli; Steam yapay zekâ formu müziği de
   içermeli.

**Düzeltilmesi iyi olur (kod işi, karar bekliyor):**
- Windows exe simgesi ve dosya bilgisi işlenmiyor (`modify_resources=false`, simge boş); CI'da rcedit gerekir.
- Oyunda sürüm numarası hiçbir ekranda görünmüyor.
- Yeni oyun tanıtımındaki "17 bölüm, 80+ karar, 91 sonuç" sayıları kuşatma perdesinden önce yazıldı (final sayısı
  artık koddan okunuyor: 27). Mağaza taslağı "56 bölüm" diyor; hangisi söylenecekse ikisi aynı olmalı.
- Kayıt klasörünün adı Türkçe karakter içeriyor (Steam Auto-Cloud için risk); değiştirilecekse eski klasörden
  kopyalayan göç koduyla birlikte. Buluta yalnızca `save_*.dat`, `save_auto.dat`, `meta.cfg` gitmeli.
- Ayarlar: çözünürlük/pencere boyutu, ana ses kaydırıcısı, kol tuş ataması, renk körlüğü yok; odak kaybında oyun
  duraklamıyor; ilk açılış pencereli.
- Başlıkta "yarat" yazınca açılan bölüm menüsü paketli oyunda da açık (bilinçli bir "bölüm seç" ise öyle kalabilir).
- Push ile yapılan yayın yalnızca hızlı test takımından geçiyor.
