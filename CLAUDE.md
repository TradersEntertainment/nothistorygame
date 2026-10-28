# Not History Game — Claude Code Çalışma Talimatı ve Diyalog Notu

Bu dosya projede çalışan Claude Code için diyalog doğallaştırma ve ElevenLabs seslendirme sürecine dair kılavuzdur.

---

## 1. Ne Yapıldı?
Oyundaki tüm diyaloglar, oyuncu seçenekleri, eşya tepkileri ve kuşatma tutanakları (toplam 4.906 anahtar / 56 bölüm) taranıp güncellendi:
- Eski "noktalı telgraf dili" (kesik kesik cümleler, doğrudan çeviri hissi veren yapılar) kırılarak günümüz Türkçesiyle doğal, akıcı ve günlük konuşma diline dönüştürüldü.
- Karakterlerin meslek ve dönem ağızları korundu:
  - **Tolga:** 2026 beyaz yakalı sigortacı jargonu ("kapsam dışı", "hasar tespiti", "poliçe", "ya abi", "valla").
  - **Hikmet Amca:** Sıcak, babacan mahalle amcası/fizikçi ("evlât", "bak şimdi", "Zamanatör", "korkma be").
  - **Nihat & Saniye:** 1977 Büro memur ciddiyeti, tutanak, fıkra ve mevzuat dili.
  - **1453 Osmanlı (Hasan, Hüseyin, Kadri, Urban, Lütfi, Çandarlı, Fatih):** Canlı ordugâh ve çarşı dili ("bre", "ağam", "kâtip efendi", "lâkin", "devlet-i aliyye").
  - **1453 Bizans/Latin (Niko, Theodoros, Giustiniani, İmparator):** Niko çarşı fırlaması; Theodoros titiz imparatorluk arşivcisi ("yedi nüsha", "mühür"); Giustiniani pragmatik Cenevizli; İmparator hüzünlü ve vakur.

---

## 2. ÖNEMLİ: Oyun Dosyaları Değiştirilmedi!
- `i18n/strings.csv` ve oyun kaynak kodları **KESİNLİKLE EZİLMEDİ / DEĞİŞTİRİLMEDİ**.
- Yeni metinler tamamen ayrı iki bağımsız dosyada tutulmaktadır:
  1. `yeni_diyaloglar_dogal.txt`: Tüm 4.906 anahtarın ESKİ ve YENİ karşılaştırmalı tam dökümü (oyun içi altyazı ve inceleme için).
  2. `yeni_diyaloglar_elevenlabs_tts.txt`: Yalnızca seslendirilecek 4.007 anahtarın ElevenLabs TTS için optimize edilmiş fonetik metni.

---

## 3. ElevenLabs TTS Optimizasyonları ve Kredi Koruması
ElevenLabs'te kredi israfını, yanlış ses okumalarını ve ses motoru bozulmalarını engellemek için şu önlemler alındı:
- **Sessiz Satırlar Çıkarıldı (~%20 Kredi Tasarrufu):** UI seçenekleri (`UI_C*`), yazılı tutanaklar (`SIEGE_NOTE_*`), epilog metinleri (`PF_*`, `FATE_*`) ve şema etiketleri (`FLOW_*`) gibi seslendirilmeyecek 899 sessiz satır `yeni_diyaloglar_elevenlabs_tts.txt` dosyasına dahil edilmedi.
- **Parantez İçi Sahne Direktifleri Temizlendi:** `(Fısıldar)`, `[Yunanca]` vb. direktifler TTS metninden arındırıldı ve satır başlığına `[TON]` olarak taşındı (ses motorunun sahne notunu sesli okuması engellendi).
- **Çoklu Konuşmacı Ayrımı (`REACT_*`):** Hasan/Hüseyin veya Tolga/Urban gibi tek satırda iki kişinin konuştuğu replikler `_s1`, `_s2` olarak konuşmacı etiketlerine ayrıldı.
- **Rakam ve Kodlar Sıfırlandı (0 Rakam Kuralı):** Tüm sayılar, tarihler, saatler (`07:30` -> `yedi buçuk`), form kodları (`Z-1453/GT` -> `Ze bin dört yüz elli üç Ge Te`), yüzdeler (`%14` -> `yüzde on dört`), sıra sayıları (`15.` -> `on beşinci`) tam Türkçe okunuşla yazıldı.
- **Yabancı İsimler Fonetikleştirildi:** `Giustiniani` -> `Cüstinyani`, `Blakherna` -> `Blaherna`, `Mesoteichion` -> `Mezotekyon`, `Hodegetria` -> `Hodegetriya`, `Cattaneo` -> `Kattaneo`, `Johannes Grant` -> `Yohannes Grant`, `Novo Brdo` -> `Novo Bırdo`, `powerbank` -> `pavırbenk`, `selfie` -> `selfi` vb.
- **`Blocked` Çığlık Koruması:** `AAAAAAAAH!`, `TOLGAAA!`, `GATOOO!` gibi aşırı uzatılmış büyük harfli bağırışlar `Aaaah!`, `Tolgaaa!`, `Gatooo!` olarak normalize edildi.
- **DİKKAT — `docs/voice/INLINE.json` Tuzağı:** `tools/voice_gen.py` çalıştırılırken `INLINE.json` içinde bulunan 120 anahtar eski metinle ezilmektedir. Ses üretimine geçmeden önce `INLINE.json` kontrol edilmeli veya güncellenmelidir.

---

## 4. Claude İçin Kontrol Görevi (Hikaye Akışı Doğrulaması)
Sevgili Claude, oyunu güncellemeden veya seslendirme batch'ini tetiklemeden önce lütfen şu noktaları kontrol et:
1. **Hikaye Akışı ve Tutarlılık:** `yeni_diyaloglar_dogal.txt` içindeki metinlerin, `scripts/chapter*.gd` dosyalarındaki dallanan hikaye mantığına (`10O`, `10B`, `10Z`, `10G`, `10A`, `10H`, `10L`, Perde IV Kuşatma 17-39O, 1977 Düğün ve Emniyet Sigorta rotaları) eksiksiz uyup uymadığını doğrula.
2. **Karakter Arkı:** Karakterlerin duygusal gelişiminin (örneğin Bölüm 11-14'te Nihat'ın Tolga'ya karşı yumuşaması, Bölüm 25-26'da kuşatmanın ciddiyeti, Tolga'nın vicdani dönüşümü) hikaye tonuyla örtüştüğünden emin ol.
3. **Onay Sonrası Entegrasyon:** Kullanıcı onay verirse, `yeni_diyaloglar_dogal.txt` dosyasındaki metinleri `i18n/strings.csv` içine entegre et veya `yeni_diyaloglar_elevenlabs_tts.txt` üzerinden ses üretimini güvenle başlat.
