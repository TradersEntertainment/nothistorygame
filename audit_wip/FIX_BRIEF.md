# Düzeltme ajanı talimatı (bütün ajanlar için ortak)

Oyun: Godot 4.4.1, Türkçe/İngilizce hikâye oyunu "Gerçek Tarih Bu Değil". Kod: /home/user/nothistorygame (ORTAK çalışma ağacı, aynı anda ~12 ajan düzenliyor).
Senin bulgu listen: /tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit/groups/<GRUP>.md
Bulgular bir QA denetiminden geliyor; satır numaraları biraz kaymış olabilir. Her bulguyu önce kodda doğrula; yanlışsa "zaten doğru" diye not et.

## Kurallar
1. git KULLANMA: commit, stash, checkout, reset, add YOK. Ana oturum hepsini birleştirip commit edecek. (Yalnız `git diff -- <dosya>` serbest.)
2. Dosya sahipliği (başkasının dosyasına dokunma; gerekiyorsa isteğini notlarına "ORTAK İSTEK" diye yaz):
   - F01: scripts/ui/*, scripts/player/*, scripts/combat/*, scripts/autoload/* (game_state.gd HARİÇ), scripts/npc/*
   - F05: scripts/autoload/game_state.gd, scripts/siege.gd, scripts/level/bureau.gd, chapter13/14/15/16/27 ve final dosyaları
   - Bölüm ajanları: kendi bölüm betikleri scripts/chapterNN*.gd (+ o bölüme özel interlude/level dosyaları).
     Ortak seviye dosyaları (scripts/level/*.gd, birkaç bölüm kullanıyor): yalnız kendi bölümüne özgü küçük, yerel değişiklik yap ve notuna yaz; genel davranışı değiştirme.
   - F12: tools/voice_*.py, docs/voice/*, scripts/ui/hud.gd içinde YALNIZ ses/mırıltı kısmı (F01 ile çakışmasın diye o fonksiyonu notuna yaz).
3. METİN (i18n/strings.csv): bu dosyayı DÜZENLEME (aynı anda herkes yazarsa birbirini siler). Yeni ya da değişen her metni
   /tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit/fix/<GRUP>_strings.csv dosyasına yaz:
   satır biçimi tam olarak: ANAHTAR,"türkçe metin","english text"   (tırnak içinde " varsa "" yaz). Var olan anahtarı değiştiriyorsan aynı anahtarı yaz, yeni değer geçerli olur.
   Biçim için i18n/strings.csv'den birkaç satıra bak (sütunlar: keys,tr,en). Seslendirilen replikler genelde D… ile başlar.
   Değişen/yeni seslendirilmiş replik anahtarlarını ayrıca fix/<GRUP>_voice.txt dosyasına satır satır yaz (ses sonra üretilecek; ses servisine SEN BAĞLANMA).
4. Test (Godot'yu doğrudan çalıştırma, bu betiği kullan; aynı anda en çok 3 Godot çalışır, sıra bekler):
   - Ayrıştırma: bash /tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit/gtest.sh PARSE
   - Bölüm: bash /tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit/gtest.sh --chapter=20 --autotest   (varyant: --autotest=lose vb.)
     Varyant listesi: tests/run_tests.sh içinde `run --chapter=...` satırları. Beklenen: "AUTOTEST PASS", hiç "SCRIPT ERROR"/"VISAUDIT"/"FAIL" yok.
     Yeni anahtarlar strings.csv'de olmadığı için ekranda anahtar görünür; bu test hatası değildir.
   - Her düzenlemeden sonra en az PARSE, sonunda dokunduğun her bölümün bütün varyantları.
   - Bir koşu birkaç dakika sürebilir; Bash'te timeout'u 600000 ms ver. Arka planda çalıştırabilirsin.
5. Kapsam: listendeki KRİTİK, YÜKSEK ve ORTA bulgular. Küçük ve yerel çöz; büyük yeniden yazım yapma. Çözemediğini/riskli olanı not et.
   GDScript tip uyarıları hata sayılır: `var x := ...` yazarken tip çıkarılamıyorsa açık tip ver.
   await ile beklenen tween'ler: tests/check_tween_await.py kuralına uy (bitmiş tween'i bekleme).
6. Bitince notlarını yaz: /tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit/fix/<GRUP>.md
   Her bulgu için: no, durum (düzeltildi / zaten doğru / düzeltilmedi + neden), değişen dosya:fonksiyon. Sonra test sonuçları ve ORTAK İSTEKLER.
   Son mesajın kısa Türkçe özet olsun (kaç düzeltildi, kaç kaldı, ortak istekler).
