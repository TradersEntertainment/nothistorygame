# Yerel Claude için seslendirme talimatı

Bu dosyayı yerel Claude Code'a şöyle ver:

> `docs/voice/LOCAL_CLAUDE.md` dosyasını oku ve 1. aşamayı yap.

---

## Kurallar
- ElevenLabs anahtarı **yalnızca** `ELEVENLABS_API_KEY` ortam değişkeninde. Hiçbir dosyaya, commit'e, log'a yazma; ekrana basma.
  Değişken yoksa kullanıcıdan terminalde kendisinin ayarlamasını iste (sohbete yapıştırmasını isteme).
- Kota: ElevenLabs karakter başına ücret alır. Toplam Türkçe metin yaklaşık 96 bin karakter. Her aşamadan önce
  `python3 tools/voice_gen.py check` ile kalan kotayı söyle; kota yetmeyecekse durup kullanıcıya sor.
- Sesleri kullanıcı seçer; sen seçme. Sen dinleme sayfasını hazırlayıp açarsın.
- İş bitince `assets/audio/voice/`, `docs/voice/cast.json`, `docs/voice/VOICE_MAP.csv` ve `docs/voice/design/design.json`
  dosyalarını commit'le (mesaj Türkçe). `docs/voice/design/*.mp3`, `samples/` ve `review.html` git dışıdır.
- Scriptlerde hata çıkarsa (ör. ElevenLabs API'si değişmişse) `tools/voice_gen.py` içinde düzelt. Güncel API belgesi:
  https://elevenlabs.io/docs/api-reference

## 1. aşama: ses tasarımı
1. `python3 tools/voice_map.py` ve `python3 tools/voice_gen.py check`.
2. Önce ana kadro: `python3 tools/voice_gen.py design --only SPK_TOLGA,SPK_HIKMET,SPK_NIHAT,SPK_KADRI,SPK_FATIH,SPK_NIKO,SPK_URBAN,SPK_HASAN,SPK_AGA,SPK_LUTFI`
3. `docs/voice/design/index.html` dosyasını tarayıcıda aç. Kullanıcı her karakter için 1, 2 ya da 3 der.
   Hiçbirini beğenmezse `docs/voice/cast.json` içindeki `design` tarifini kullanıcının dediğine göre İngilizce güncelle
   ve `design --only SPK_X --force` ile yeniden üret.
4. Seçilenler: `python3 tools/voice_gen.py pick SPK_X N`.
5. Kalan karakterler: `python3 tools/voice_gen.py design` (seçilmiş olanları atlar), aynı şekilde seçim.

## 2. aşama: pilot bölüm (10. bölüm ve dalları, yaklaşık 40 satır)
1. `python3 tools/voice_gen.py all --chapter 10 --limit 40`
2. `python3 tools/voice_gen.py review --chapter 10`, ardından `docs/voice/review.html` sayfasını aç.
3. Kullanıcı beğenmediği satırı söyler ("şu daha panik olsun"). Uygun etiketle yeniden üret:
   `python3 tools/voice_gen.py redo ANAHTAR --tone "[panicked]"`.
   Etiketler İngilizce ve köşeli parantezli: `[whispers]`, `[shouting]`, `[laughs]`, `[sighs]`, `[sad]`, `[panicked]`,
   `[angry]`, `[sarcastic]`, `[excited]`, `[scared]`, `[hesitant]`, `[tired]`, `[deadpan]`, `[proud]`, `[nervous]`.
   Gerekirse iki etiket birlikte kullanılabilir: `[nervous] [whispers]`.
4. Karakterin genel tonu hep yanlışsa `cast.json`'da o karaktere `"ton": "[deadpan]"` gibi varsayılan ton ya da
   farklı `stability` (0 = daha duygulu, 1 = daha sabit) ver.

## 3. aşama: ton geçişi ve tüm oyun
1. Ton sütununun çoğu boş (doğal ses). Üretmeden önce `VOICE_MAP.csv` dosyasını bölüm bölüm oku; sahnenin bağlamına göre
   (kovalamaca = panik, Fatih'in huzurunda = gergin ya da saygılı, Nihat = bıkkın, patlama sonrası = sersem) boş `ton`
   hücrelerini doldur ve `ton_elle` = `1` yap. Bağlam için `scripts/chapterN.gd` dosyasına bakabilirsin.
   Fatih ve İmparator Konstantinos saygılı seslendirilir, alaya alınmaz.
2. `python3 tools/voice_gen.py all` ile tüm Türkçe replikleri üret. Bölüm bölüm `review` ile kullanıcıya dinlet.
3. İngilizce için kullanıcı onay verirse `--lang en`.
4. Oyunu aç, birkaç bölümde sesin altyazıyla eşleştiğini kontrol et (Godot 4.4, `project.godot`).
