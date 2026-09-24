# Seslendirme (ElevenLabs)

Bu klasördeki her şey `tools/voice_map.py` ve `tools/voice_gen.py` ile üretilir. Seslendirme **yerel bilgisayarda** yapılır
(bulut oturumunun ağ ayarı ElevenLabs'a izin vermiyor). Yerel Claude'a verilecek hazır talimat: [`LOCAL_CLAUDE.md`](LOCAL_CLAUDE.md).

## Anahtar
Anahtar **hiçbir dosyaya yazılmaz**, yalnızca ortam değişkeninden okunur:

    export ELEVENLABS_API_KEY=...            # macOS / Linux
    $env:ELEVENLABS_API_KEY="..."            # Windows PowerShell

## Akış
1. `python3 tools/voice_map.py`: replik haritası `VOICE_MAP.csv` (anahtar, bölüm, konuşmacı, **ton**, ton_elle, TR, EN).
2. `python3 tools/voice_gen.py check`: anahtar ve kota.
3. `python3 tools/voice_gen.py design`: `cast.json`'daki `design` tarifleriyle her karaktere 3 örnek ses (Voice Design).
   `design/index.html` sayfasını tarayıcıda aç, dinle.
4. `python3 tools/voice_gen.py pick SPK_TOLGA 2`: beğenilen örnek kalıcı ses olur, `cast.json`'a yazılır.
   Beğenilmezse `design --only SPK_TOLGA --force` (istersen önce `design` tarifini değiştir).
5. Pilot: `python3 tools/voice_gen.py all --chapter 10 --limit 40`, sonra `review --chapter 10` → `review.html`.
6. Beğenilmeyen satır: `python3 tools/voice_gen.py redo D10B_U_B3_1 --tone "[panicked]"`.
7. Hepsi: `python3 tools/voice_gen.py all` (var olan dosyaları atlar), İngilizce için `--lang en`.

Oyun, `assets/audio/voice/<dil>/<ANAHTAR>.mp3` dosyası varsa mırıltının yerine onu çalar; yoksa mırıltıya düşer.

## Ton etiketleri (eleven_v3)
`ton` sütunu satırın başına eklenen ses etiketidir: `[whispers]`, `[shouting]`, `[laughs]`, `[sighs]`, `[sad]`, `[panicked]`,
`[angry]`, `[sarcastic]`, `[excited]`, `[scared]`, `[hesitant]`, `[tired]` ve benzerleri. İlk değerler sahne notlarından ve
noktalamadan tahmin edilir. Elle değiştirdiğin satırda `ton_elle` = `1` yap; `voice_map.py` yeniden çalışınca korunur
(`redo --tone` bunu kendisi yapar). Boş ton = karakterin doğal sesi.

Parantez içindeki sahne notları (`(Mühür vurur)`) okunmaz; yalnız konuşma seslendirilir.

## Kadro
Toplam replik: 1439 · TR karakter: 95677

| Karakter | Replik | Karakter sayısı (TR) | Ses |
|---|---:|---:|---|
| Tolga | 310 | 18641 | 30'larında sigortacı; hızlı, şaşkın, iyimser, plaza jargonlu |
| Hikmet | 208 | 13374 | 70'lerinde mucit amca; sıcak, hafif çatlak, heyecanlı |
| Nihat | 200 | 15010 | Büro denetçisi; tekdüze, resmî, kuru mizah |
| Fatih | 80 | 5336 | Genç Sultan Mehmed; 21 yaşında, sakin, keskin, otoriter (saygılı) |
| Kadri | 78 | 5327 | Aşçıbaşı; kalın, gürleyen, sert ama sevecen |
| Urban | 64 | 3623 | Macar topçu ustası; gururlu, gürültülü, yabancı aksanlı |
| Hasan | 57 | 3069 | Genç yeniçeri; saf, biraz yavaş |
| Niko | 54 | 3554 | Bizans nöbetçisi; gür, iyi kalpli, hafif kaba |
| Aga | 41 | 2888 | Sorucu Ağa; gür, bağıran, köprü bekçisi tiyatrosu |
| Lutfi | 38 | 3126 | Tercüman; hızlı, kurnaz, hevesli, şakacı |
| Theodoros | 36 | 2954 | Logothetes; ağır, törensel, gizlice duygusal |
| Huseyin | 31 | 1425 | Hasan'ın ikizi gibi; biraz daha tiz |
| Emperor | 26 | 2098 | İmparator Konstantinos; ağırbaşlı, yorgun, sıcak (saygılı) |
| Soldier | 25 | 1510 | Genç asker; saf, annesine düşkün |
| Miner | 25 | 1661 | Lağımcı; kısık, yorgun, kuru mizah |
| Mufide | 21 | 1716 | Başdenetçi, orta yaş kadın; anaç ama kesin |
| Clerk | 21 | 1382 | Bizans memuru; kuru, törensel, burnundan |
| Giust | 17 | 1182 | Cenevizli komutan; kendinden emin, tüccar kurnazlığı |
| Cemil | 11 | 901 | Yaşlı hırdavatçı esnaf; yavaş, dost, çay seven |
| Riza | 8 | 541 | Depocu; ağır, esnek, işini bilen |
| Pasha | 7 | 661 | Çandarlı Halil Paşa; yaşlı, kurnaz, alçak sesli |
| Wine | 7 | 546 | Ceneviz şarapçı; telaşlı, İtalyan aksanlı |
| Agent1 | 6 | 417 | Büro ajanı; kibar ama robotik |
| Van | 6 | 327 | Minibüs hoparlörü; metalik anons sesi → Agent1 sesi |
| Candarli | 6 | 368 | Kukuletalı adam; fısıltılı, gizemli |
| Grant | 6 | 459 | Hibe memuru (Nihat'ın sesi) → Nihat sesi |
| Notary | 5 | 444 | Ceneviz noter; titiz, yavaş, mühür meraklısı |
| Sinerji | 5 | 248 | Tavuk; seslendirilmez, oyun tavuk efekti çalar |
| Envoy | 4 | 368 | Venedik elçisi; diplomatik, kibar |
| Manager | 4 | 250 | Ofis müdürü; plaza jargonlu, sabırsız |
| Coworker_A | 4 | 203 | İş arkadaşı A; dedikoducu, neşeli |
| Coworker_B | 4 | 295 | İş arkadaşı B; alaycı, sıkılmış |
| Captain | 3 | 158 | Venedik kaptanı; yıpranmış, İtalyan aksanlı |
| Double | 3 | 223 | İki tarafa satan tüccar; sinsi, güler yüzlü |
| Fishmonger | 3 | 230 | Balıkçı; bağıran, neşeli |
| Radio | 2 | 161 | Radyo spikeri → Nihat sesi |
| Agent2 | 2 | 122 | Büro ajanı 2; kibar, çay seven |
| Cameleer | 2 | 201 | Deveci Yakup; heyecanlı, köylü |
| Dervish | 2 | 172 | Derviş; yumuşak, dalgın, şiirsel |
| Tailor | 2 | 150 | Venedikli terzi; İtalyan aksanlı, telaşlı |
| Rower | 1 | 22 | Kürekçi → Niko sesi |
| Guards | 1 | 19 | Hasan ile Hüseyin birlikte (Hasan'ın sesi kullanılır) → Hasan sesi |
| Bureau_Radio | 1 | 95 | Büro telsizi → Mufide sesi |
| Rider | 1 | 160 | Ulak (Niko'nun sesi) → Hasan sesi |
| Driver | 1 | 60 | Servis şoförü; sesli repliği yok (yalnız sahne notu) |
