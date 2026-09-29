# Yerel Claude için: eksik sesler (Türkçe + İngilizce)

Yerel Claude Code'a şunu yaz:

> `docs/voice/LOCAL_TRAILER.md` dosyasını oku ve adımları uygula.

## Kurallar
- ElevenLabs anahtarı yalnızca `ELEVENLABS_API_KEY` ortam değişkeninde; hiçbir dosyaya, commit'e, log'a yazma.
  Değişken yoksa kullanıcıdan terminalde kendisinin ayarlamasını iste.
- Başlamadan `python3 tools/voice_gen.py check` ile kotayı söyle (toplam ~2.500 karakter).

## Adımlar
1. `git pull`
2. `python3 tools/voice_map.py` (yeni replikler ses haritasına girer)
3. Türkçe (Bölüm 0/12/20/26 replikleri; daha önce üretilenler kendiliğinden atlanır, yeniler: D26_S_ARROWS_1..3, D26_T_HIDE):
   `python3 tools/voice_gen.py fix --list docs/voice/REGEN_CH12_20.txt`
4. İngilizce (fragman `-- en` ve yeni sahneler; üretilenler atlanır):
   `python3 tools/voice_gen.py fix --list docs/voice/REGEN_TRAILER_EN.txt --lang en`
   İngilizce kadroda karakteri olmayan bir konuşmacı çıkarsa (ör. SPK_LOOKOUT, SPK_DEFENDER, SPK_GIUST):
   `python3 tools/voice_gen.py audition --lang en` + `python3 tools/voice_gen.py pick SPK_X N --lang en`, sonra 4. adımı tekrarla.
4b. Panikle yeniden okuma (fragman açılışı, Tolga ok yağmurunda koşarken "Bu işi her gece mi yapıyorsunuz? Her gece?"):
   ton `docs/voice/TONES.txt`'ten gelir (`[panicked] [out of breath] [shouting while running]`).
   `python3 tools/voice_gen.py fix --list docs/voice/REGEN_PANIC.txt`
   `python3 tools/voice_gen.py fix --list docs/voice/REGEN_PANIC.txt --lang en`
   Dinle: sakin çıktıysa aynı komutu `.done_REGEN_PANIC*` dosyasını silip bir kez daha çalıştır.
4c. Bölüm 1 öncesi yatak odası (gece telefonu, 10 replik; uykulu/bağıran tonlar TONES.txt'te):
   `python3 tools/voice_gen.py fix --list docs/voice/REGEN_CH1_BED.txt`
   `python3 tools/voice_gen.py fix --list docs/voice/REGEN_CH1_BED.txt --lang en`
4d. Bölüm 3 heyecan sahneleri (Büro alarmı, Hikmet'in delil karartması, telsizden Tolga, direnen makine; 22 replik):
   `python3 tools/voice_gen.py fix --list docs/voice/REGEN_CH3.txt`
   `python3 tools/voice_gen.py fix --list docs/voice/REGEN_CH3.txt --lang en`
5. `godot --headless --path . --import` (yeni mp3'ler için .import dosyaları)
6. Yeni `assets/audio/voice/tr/*.mp3`, `assets/audio/voice/en/*.mp3`, `.import` dosyalarını ve `docs/voice/VOICE_MAP.csv`'yi
   commit'le ve push et (mesaj Türkçe).

## Fragmanı kaydetmek
```
godot --path . --write-movie fragman.avi --fixed-fps 30 --resolution 1920x1080 res://tools/trailer/trailer.tscn
ffmpeg -i fragman.avi -c:v libx264 -crf 18 -pix_fmt yuv420p -c:a aac -b:a 192k fragman.mp4
```
İngilizce: birinci komutun sonuna ` -- en` ekle (dosya adını `fragman_en.avi` yap).
