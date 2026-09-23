# Seslendirme (ElevenLabs)

**Replik haritası:** `VOICE_MAP.csv`, oyundaki her diyalog satırını, konuşan karakteri, Türkçe ve İngilizce metni ve bölümü listeler. `python3 tools/voice_map.py` ile yeniden üretilir.

Toplam replik: 790 · TR karakter: 51093 · konuşmacısı bulunamayan: 0

| Karakter | Replik | Karakter sayısı (TR) | Ses tarifi |
|---|---:|---:|---|
| Hikmet | 160 | 9900 | 70'lerinde mucit amca; sıcak, hafif çatlak, heyecanlı |
| Tolga | 129 | 7885 | 30'larında sigortacı; hızlı, şaşkın, iyimser, plaza jargonlu |
| Nihat | 121 | 8785 | Büro denetçisi; tekdüze, resmî, kuru mizah |
| Niko | 47 | 2926 | Bizans nöbetçisi; gür, iyi kalpli, hafif kaba |
| Aga | 41 | 2888 | Sorucu Ağa; gür, bağıran, köprü bekçisi tiyatrosu |
| Hasan | 37 | 1381 | Genç yeniçeri; saf, biraz yavaş |
| Kadri | 34 | 2337 | Aşçıbaşı; kalın, gürleyen, sert ama sevecen |
| Lutfi | 32 | 2603 | Tercüman; hızlı, kurnaz, hevesli, şakacı |
| Huseyin | 30 | 1354 | Hasan'ın ikizi gibi; biraz daha tiz |
| Urban | 28 | 1860 | Macar topçu ustası; gururlu, gürültülü, yabancı aksanlı |
| Clerk | 17 | 1042 | Bizans memuru; kuru, törensel, burnundan |
| Theodoros | 17 | 1516 | Logothetes; ağır, törensel, gizlice duygusal |
| Soldier | 13 | 529 | Genç asker; saf, annesine düşkün |
| Giust | 12 | 798 | Cenevizli komutan; kendinden emin, tüccar kurnazlığı |
| Mufide | 11 | 937 | Başdenetçi, orta yaş kadın; anaç ama kesin |
| Cemil | 11 | 901 | Yaşlı hırdavatçı esnaf; yavaş, dost, çay seven |
| Pasha | 7 | 661 | Çandarlı Halil Paşa; yaşlı, kurnaz, alçak sesli |
| Agent1 | 6 | 417 | Büro ajanı; kibar ama robotik |
| Van | 6 | 327 | Minibüs hoparlörü; metalik anons sesi |
| Candarli | 6 | 368 | Kukuletalı adam; fısıltılı, gizemli |
| Emperor | 6 | 395 | İmparator Konstantinos; ağırbaşlı, yorgun, sıcak (saygılı) |
| Riza | 5 | 335 | Depocu; ağır, esnek, işini bilen |
| Radio | 2 | 161 | Radyo spikeri |
| Agent2 | 2 | 122 | Büro ajanı 2; kibar, çay seven |
| Cameleer | 2 | 201 | Deveci Yakup; heyecanlı, köylü |
| Dervish | 2 | 172 | Derviş; yumuşak, dalgın, şiirsel |
| Tailor | 2 | 150 | Venedikli terzi; İtalyan aksanlı, telaşlı |
| Rower | 1 | 22 | Kürekçi |
| Guards | 1 | 19 | Hasan ile Hüseyin birlikte (Hasan'ın sesi kullanılır) |
| Bureau_Radio | 1 | 95 | Büro telsizi |
| Fatih | 1 | 6 | Genç Sultan Mehmed; 21 yaşında, sakin, keskin, otoriter (saygılı) |

## Nasıl üretilir

Anahtar ortam değişkeninden okunur, hiçbir dosyaya yazılmaz:

```bash
export ELEVENLABS_API_KEY=...          # Windows PowerShell: $env:ELEVENLABS_API_KEY="..."
python3 tools/voice_gen.py check       # paket ve kalan karakter
python3 tools/voice_gen.py cast        # ElevenLabs kütüphanesinden her karaktere Türkçe bir ses seçer, cast.json'a yazar
python3 tools/voice_gen.py samples     # her karakterden 3 örnek -> docs/voice/samples/tr/
python3 tools/voice_gen.py all         # hepsi -> assets/audio/voice/tr/<ANAHTAR>.mp3 (var olanları atlar)
python3 tools/voice_gen.py all --chapter 3 --limit 20   # parça parça
python3 tools/voice_gen.py all --lang en               # İngilizce
```

Beğenilmeyen bir ses için `cast.json`'daki `voice_id`'yi silip `cast --force` ya da elle başka bir ses kimliği yaz, sonra o karakterin dosyalarını silip `all` ile yeniden üret.

Sahne notları (`(Telsiz)`, `[Yunanca]`, `(Gözleri dolar)`) okunmaz, yalnızca altyazıda kalır.

Oyun, bir replik gösterilirken `assets/audio/voice/<dil>/<ANAHTAR>.mp3` dosyasını arar. Dosya varsa onu çalar, yoksa eski mırıltı sesi devam eder. Dosyalar parça parça eklenebilir.
