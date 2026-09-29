# Yerel Claude için: eksik bütün sesler + fragman (Türkçe ve İngilizce)

Yerel Claude Code'a şunu yaz:

> `docs/voice/LOCAL_TRAILER.md` dosyasını oku ve adımları sırayla uygula.

## Kurallar
- ElevenLabs anahtarı yalnızca `ELEVENLABS_API_KEY` ortam değişkeninde; hiçbir dosyaya, commit'e, log'a yazma.
  Değişken yoksa kullanıcıdan terminalde kendisinin ayarlamasını iste.
- Eksik sesler (v0.39.5 itibarıyla): Türkçe ~117 replik (~7.700 karakter), İngilizce ~749 replik (~63.000 karakter).
  Başlamadan `python3 tools/voice_gen.py check` ile kotayı söyle. Kota İngilizcenin hepsine yetmiyorsa önce fragmanda
  geçenleri (adım 5a) üret, kalanı kotanın yettiği kadar (5b) ve kullanıcıya kaç replik kaldığını bildir.

## Adımlar
1. `git pull`
2. `python3 tools/voice_map.py` (yeni replikler ses haritasına ve ton etiketlerine girer)
3. Yeni konuşmacılar (kadroda yoksa her biri için `python3 tools/voice_gen.py casting SPK_X` → `cast_pick SPK_X <seçim>`;
   İngilizce için `python3 tools/voice_gen.py audition --lang en` → `pick SPK_X <n> --lang en`):
   - `SPK_WITNESS` ("Tanık", Nihat'ı uçarken gören halktan biri: şaşkın, bağıran)
   - `SPK_TOWNSMAN` ("Kentli", Bizans'ta yoldan geçen; orta yaşlı, günlük konuşma). Yoldan geçenlerin replikleri
     (NPC_CROWD_*) şimdiye dek ses haritasına hiç girmemişti; bu yüzden kentlilerle konuşunca ses çıkmıyordu.
   - `SPK_GENOESE` ("Cenevizli", Galata'da yoldan geçen tüccar; hafif İtalyan ezgisi)
   - `SPK_CITY_GUARD` ("Bizans muhafızı", sert, resmî)
4. Türkçe:
   - Önce tonu önemli olanlar (ton `docs/voice/TONES.txt`'ten gelir):
     `python3 tools/voice_gen.py fix --list docs/voice/REGEN_PANIC.txt`
     `python3 tools/voice_gen.py fix --list docs/voice/REGEN_CH1_BED.txt`
   - Metni değişen replikler (mühür labirenti martı kovalamacası oldu):
     `python3 tools/voice_gen.py fix --list docs/voice/REGEN_V0397.txt`
   - Sonra eksik olan her şey (var olan dosyalar atlanır; Bölüm 3 heyecan sahneleri, Nihat'ın uçuşu, tanıklar,
     seyir defteri, uçuşan formlar, çatı denetimi, suya iniş, görev bitiş replikleri dahil):
     `python3 tools/voice_gen.py all`
5. İngilizce:
   a. Fragmanda geçenler önce: `python3 tools/voice_gen.py fix --list docs/voice/REGEN_TRAILER_EN.txt --lang en`
      ve `python3 tools/voice_gen.py fix --list docs/voice/REGEN_PANIC.txt --lang en`
   b. Metni değişenler: `python3 tools/voice_gen.py fix --list docs/voice/REGEN_V0397.txt --lang en`
   c. Kalan her şey: `python3 tools/voice_gen.py all --lang en`
   İngilizce kadroda karakteri olmayan konuşmacı çıkarsa: `audition --lang en` + `pick SPK_X N --lang en`, sonra tekrarla.
6. Dinleme: `python3 tools/voice_gen.py review` ile üretilenlere göz at. Panik repliği ("Bu işi her gece mi
   yapıyorsunuz?") sakin çıktıysa `.done_REGEN_PANIC*` dosyasını silip 4. adımdaki panik komutunu bir kez daha çalıştır.
7. `godot --headless --path . --import` (yeni mp3'ler için .import dosyaları)
8. Yeni `assets/audio/voice/tr/*.mp3`, `assets/audio/voice/en/*.mp3`, `.import` dosyalarını, `docs/voice/VOICE_MAP.csv`'yi
   ve kadro dosyalarını commit'le ve push et (mesaj Türkçe).

## Fragmanı kaydetmek
Fragman sırası: soğuk açılış (gedik) → garaj → dünya → kızak → otağ → **Nihat uçuyor** (surların üstünden şehre,
Ayasofya'nın kubbesi çevresinde, Galata Kulesi'nin galerisine iniş; "HER YERE UÇ") → kuşatma → Büyük Patlama → kapanış.

1. Önce uçuş sahnesini tek başına dene (hızlı önizleme):
   ```
   godot --path . --write-movie ucus.avi --fixed-fps 30 --resolution 1920x1080 res://tools/trailer/trailer.tscn -- only=flight
   ```
   Kontrol et: Nihat parlayan Form Z-9'un üstünde dimdik uçuyor (yatık değil), Ayasofya'nın kubbesi ve Galata'nın evleri ayrıntılı (uzak kutular değil),
   replikler seslendirilmiş, altyazı sesle bitiyor.
2. Tam fragman (Türkçe ve İngilizce):
   ```
   godot --path . --write-movie fragman.avi --fixed-fps 30 --resolution 1920x1080 res://tools/trailer/trailer.tscn
   godot --path . --write-movie fragman_en.avi --fixed-fps 30 --resolution 1920x1080 res://tools/trailer/trailer.tscn -- en
   ffmpeg -i fragman.avi -c:v libx264 -crf 18 -pix_fmt yuv420p -c:a aac -b:a 192k fragman.mp4
   ffmpeg -i fragman_en.avi -c:v libx264 -crf 18 -pix_fmt yuv420p -c:a aac -b:a 192k fragman_en.mp4
   ```
3. Videoları commit'leme (büyük dosya). Kullanıcıya dosya yollarını, sürelerini ve dikkat çeken bir sorun varsa
   (ör. sesi eksik replik, boş kare) hangi saniyede olduğunu bildir.
