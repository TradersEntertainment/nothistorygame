# F12_ses_metin: düzeltme notları

Kapsam: tools/voice_*.py, docs/voice/*, ses kısmı (hud.gd dokunulmadı), i18n yerine fix/F12_ses_metin_strings.csv.

## Ek görev (koordinatör): bölüm 43 HELDAUDIT
- Kök neden: scripts/chapter43o.gd `_end_chapter()` akış şemasına geçmeden önce kumandayı gizlemiyordu. `_hold_remote(false)` yalnız `_chained()` yolunda vardı, iyi sonda kumanda (`_hold_remote(true)`, _give_remote(false) sonrası) Tolga'nın kamerasında görünür kalıyordu.
- Düzeltme: `_end_chapter()` başına `_hold_remote(false)` eklendi (scripts/chapter43o.gd:`_end_chapter`). Kumanda node'u silinmiyor, gizleniyor (`_remote.visible = false`); HELDAUDIT denetimi görünür Node3D'ye bakıyor.
- Test: `--chapter=43o --autotest` (varsayılan, =bad, =miss): üçü de AUTOTEST PASS. Ham Godot çıktısında grep: HELDAUDIT yok (varsayılan ve =bad, son durumda da kontrol edildi).
- Not: `--chapter=43` (sayısal) 43o'yu açmıyor, chapter 15'e düşüyor; tests/run_tests.sh `--chapter=43o` kullanıyor. Koordinatörün verdiği `--chapter=43` komutu yanlış sahneyi çalıştırıyor.
- Not: audit/gtest.sh çıktı filtresi HELDAUDIT satırını göstermiyor (grep deseninde yok). Bu yüzden HELDAUDIT'i doğrudan Godot çıktısında aradım. gtest.sh'ye `HELDAUDIT` eklenmesi önerilir.
- Not: scripts/chapter43o.gd, koordinatör/başka bir ajan tarafından da değiştirilmiş (diff'te fazladan satırlar var). Onlara dokunmadım.

## Ses bulguları

1. [YÜKSEK] Konuşmacı etiketi "Mr Tolga:" / ", Hikmet:" bölüyor: DÜZELTİLDİ
   - tools/voice_gen.py `LABEL`: `(?<!Mr )(?<!Mrs )(?<!, )` eklendi (hitap öneki). Gerçek etiketler korundu (`Arkamda Kadri: 'Düşürme!'`, `Nihat (telsiz): …`).
   - Doğrulama: VOICE_MAP'teki tüm satırlarda eski/yeni ayrıştırma karşılaştırıldı: 37 satır farklı; hepsi hitap (EN "Mr X:" ve TR ", Hikmet:"). Diff'te gerçek etiket kaybı yok.
   - Mevcut ses dosyaları yanlış: yeniden üretim listesinde.

2. [YÜKSEK] Çok parçalı MP3 bayt bayt ekleniyor: DÜZELTİLDİ
   - tools/voice_gen.py `_speak` artık parçaları `concat_mp3()` ile birleştiriyor: ffmpeg filter_complex concat, parçalar arası 0.25 sn sessizlik, yeniden kodlama (libmp3lame 128k) — tek MP3 başlığı.
   - Test: iki sentetik parça (1.2 sn + 2.0 sn) → 3.50 sn birleşik dosya (beklenen ~3.45, sessizlik/kodlayıcı gecikmesi).
   - Mevcut REACT_* ve çok konuşmacılı dosyalar eski (bozuk) biçimde: yeniden üretim gerekli (listede: "multi").
   - Oyunda dinleme doğrulaması yapılmadı (ses servisi kullanılmadı).

3. [ORTA] Sahne notu parantezsiz okunuyor: DÜZELTİLDİ (metin tarafı) + yeniden üretim
   - Denetimin 5 anahtarı + aynı kalıptaki 4 anahtar parantez içine alındı (fix/F12_ses_metin_strings.csv): REACT_GUARDS_SELFIE, REACT_URBAN_BOOK, REACT_FATIH_COLOGNE, REACT_EMPEROR_BOOK, REACT_GIUST_BOOK; ek olarak REACT_GUARDS_CUBE, REACT_NIKO_SELFIE, REACT_GUARDS_THERMOS, REACT_EMPEROR_COLOGNE. EN karşılıkları da yapıldı.
   - REACT_EMPEROR_COLOGNE'da Niko'nun repliği "Niko:" etiketiyle açıkça Niko'ya verildi (önceden İmparator'un sesiyle okunuyordu).
   - Hepsinde konuşma kısmı kaldı, dolayısıyla eski ses dosyası üzerine yazılacak (sessiz anahtar yok).

4. [ORTA] Derviş ile Akşemseddin aynı ses (31o): DÜZELTİLDİ
   - docs/voice/cast.json SPK_AKSEMSEDDIN same_as SPK_GURANI (Molla Gürânî; 31o'da yok).
   - docs/voice/cast_en.json SPK_AKSEMSEDDIN same_as SPK_PASHA (EN ses çakışması da giderildi: Tellal/HERALD ile 31o).

5. [ORTA] Topçubaşı Ali = Aşçıbaşı Kadri (17o, 32o): DÜZELTİLDİ
   - cast.json SPK_TOPCU same_as SPK_AGA (Sorucu Ağa; gür; 17o/32o'da yok). cast_en.json SPK_TOPCU eklendi: same_as SPK_AGA.

6. [ORTA] Azapbaşı Turgut = Hasan (26o); Yeniçeri = Hasan (32o): DÜZELTİLDİ (TR), EN de yapıldı
   - cast.json SPK_AZAPBASI same_as SPK_RIZA; SPK_JANISSARY same_as SPK_CITY_GUARD.
   - cast_en.json SPK_AZAPBASI same_as SPK_RIZA; SPK_JANISSARY eklendi same_as SPK_CITY_GUARD.

7. [ORTA] 15: Ece / Müdür / Ferit Bey aynı erkek ses: KISMEN
   - Müdür (SPK_MANAGER, TR) → SPK_CLERK; Ferit Bey (SPK_AGENCY, TR) → SPK_ISMAIL. EN'de Ferit Bey (SPK_AGENCY) → SPK_ISMAIL (EN Müdür kendi sesinde zaten).
   - DÜZELTİLMEDİ: Ece (SPK_COWORKER_B) hâlâ SPK_AGENT2 sesinde (TR ve EN). Kadro dosyalarında Müfide dışında kadın ses kimliği yok; yeni kadın ses için casting gerekli (ses servisi bu görevde kullanılmadı, yeni kimlik uydurulmadı).
   - Aynı nedenle Deniz (SPK_COWORKER_A) ile Müfide (SPK_MUFIDE) ch15'te aynı sesle (TR/EN). Kadın ses çözümüne bağlı, açık.

8. [ORTA] EN kadrosunda HERALD zinciri (33o, 34o, 31o, 39o): DÜZELTİLDİ
   - cast_en.json: SPK_FIRUZ → SPK_KASIM; SPK_RIZZO → SPK_BRIG; SPK_HALIL → SPK_THEODOROS; SPK_MASON → SPK_NOTARY; SPK_PRIEST → SPK_CEMIL; SPK_AKSEMSEDDIN → SPK_PASHA (ve yukarıdaki TOPCU/JANISSARY/AZAPBASI/AGENCY).
   - Kontrol: sahne öneki bazlı çakışma taraması (EN) 33O/34O/39O/31O için çakışma göstermiyor.
   - Not: HERALD (Tellal) ve Morosini (CAPTAIN) kendi seslerinde kaldı.

9. [ORTA] D10A_N_MEET_4 "Fesli ziyaretçi" → "fessiz": DOĞRULANAMADI
   - Dinleme yapılamadı (ses dosyası dinlenmedi, ASR kanıtı dışında karar yok). Yeniden üretilmedi.
   - Öneri: dinleyip "fesli" yanlışsa `python3 tools/voice_gen.py redo D10A_N_MEET_4` (ya da listeye ekle).

## Metin bulguları

1. [YÜKSEK] Top talimi adımları yinelenen anahtarlar: ZATEN DOĞRU (mevcut ağaç)
   - i18n/strings.csv'de yinelenen anahtar yok (kontrol: DUPS=[]). Tüfek metinleri UI_HGUN_* (5345-5348) olarak ayrılmış; scripts/combat/handgun.gd UI_HGUN_* kullanıyor. Top UI_GUN_POWDER/BALL/RAM/AIM (4332-4336) gun_drill.gd:143 tarafından kullanılıyor.
   - Yinelenen anahtar testi eklenmedi (tests/ dosyaları bu grubun sahipliğinde değil; gerekirse eklenebilir).
   - Not: "E/Space ile 6 kez" tokmak adımı ve 290 px sığma konusu kod/UI tarafı (F01 sahipliği); burada değiştirilmedi.

2. [ORTA] 75 EN satırı dış tırnakla sarılı: DÜZELTİLDİ (fix/F12_ses_metin_strings.csv, 75 satır)
   - Dış tırnaklar kaldırıldı; iç tırnaklar (12 anahtar) ‘ ’ yapıldı. Kod değişikliği yok (hud.gd:1491 tırnağı görmeye devam eder ama EN değer artık tırnaksız).
   - Ses yeniden üretimi gerekmiyor: segments() zaten dış tırnakları atıyor.

3. [ORTA] Yere düşme: Nihat'ın "evlât"/"bilet" replikleri: DÜZELTİLDİ (TR ve EN)
   - D_DOWNED_N_2 (TR): "(Telsiz) Yerde yatmak yönetmelikte yok, Tolga Bey."; EN: "(Radio) Lying on the floor isn't in the regulations, Mr Tolga." (EN'deki "son" da Hikmet ağzıydı).
   - D_DOWNED_N_1 (TR): "(Telsiz) Kalkın Tolga Bey! Tarih sizi bekliyor, ben de mesaimi bitireyim." (siz hitabına uyumlu). EN N_1 aynen bırakıldı.

## Ses yeniden üretim listesi
- Dosya: fix/F12_ses_metin_voice.txt (TR 170, EN 231 anahtar; iki ayrı başlık).
- Nedenler: çok parçalı (eski bayt birleştirme) + cast değişikliği + metin değişikliği.
- Kullanım sırası:
  1. strings.csv'ye fix/F12_ses_metin_strings.csv ve diğer grupların CSV'leri birleştirilir (yalnız ana oturum yapar).
  2. `python3 tools/voice_map.py` (VOICE_MAP tr/en sütunları güncellenir; yeniden üretimden önce gerekli).
  3. TR anahtarları: `python3 tools/voice_gen.py fix --list <dosya> --lang tr` (yalnız TR bölümü; dosya tek ama iki dile bölünmüş, EN satırları --lang tr ile çalıştırılmamalı).
  4. EN anahtarları: `... fix --list <dosya> --lang en` (yalnız EN bölümü).
  - Liste dosyasında `#` ile başlayan satırlar atlanır; ayrıştırma için ayrı dosyaya kopyalamak daha güvenli.
- Ses servisine bağlanılmadı; üretim yapılmadı.

## Test sonuçları
- `gtest.sh PARSE`: PARSECHECK PASS scripts=230.
- `gtest.sh`/doğrudan Godot: `--chapter=43o --autotest` (varsayılan, =bad, =miss): AUTOTEST PASS ×3; HELDAUDIT yok.
- `python3 -m py_compile tools/voice_gen.py`: OK. Label ayrıştırma ve concat testleri yukarıda.
- docs/voice/cast.json ve cast_en.json: JSON geçerli.

## Kapsam dışı ama tespit edilen (düzeltilmedi)
- AZAP ↔ SOLDIER (TR/EN): 26o, 30o, 31o, 32o, 37o'da aynı ses (AZAP same_as SOLDIER). Listede değil.
- EN 24: Derviş ↔ Keşiş (MONK). TR/EN: GUARDS ↔ HASAN (4a), AGENT1 ↔ VAN (8), NIKO ↔ SAILOR/DEFENDER (19, 20), NIHAT ↔ RADIO (5, telsiz sesi kasıtlı olabilir).
- Ece (COWORKER_B) ve Deniz (COWORKER_A) için kadın ses: yeni kadın kimlik gerekiyor (casting).

## ORTAK İSTEKLER
- Yok (F01 dosyalarına dokunulmadı; hud.gd yalnız ses kısmı, değişiklik yapılmadı).
- chapter43o.gd: yukarıdaki HELDAUDIT düzeltmesi koordinatör isteğiyle; sahip ajanın bilgisi için not.
- gtest.sh: HELDAUDIT grep deseni eklenmeli (ana oturum/test sahibi).
