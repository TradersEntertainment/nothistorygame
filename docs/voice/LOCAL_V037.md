# Yerel Claude için: v0.37 seslendirmesi (brigantin kaptanı, Bölüm 21 yeni sahneler, v0.37 listesi)

Bu dosyayı yerel Claude Code'a şöyle ver:

> `git pull` yap, sonra `docs/voice/LOCAL_V037.md` dosyasını oku ve adımları sırayla uygula.

`docs/voice/LOCAL_CLAUDE.md` içindeki **Kurallar** burada da geçerli (anahtar yalnız `ELEVENLABS_API_KEY` ortam
değişkeninde; dosyaya, commit'e, log'a yazılmaz; sesleri kullanıcı seçer).

## 1. Kadroya yeni girdiler (`docs/voice/cast.json`)
Tarifler `docs/voice/SIEGE_VOICES.md` §2'de. Var olan girdilere dokunmadan:
- `SPK_KASIM` ekle (kendi sesi: `tarif`, `gender`, `age`, `design` alanlarıyla).
- `SPK_JANISSARY` ekle: `{"tarif": "Yeniçeri (Bölüm 21 tünelde); sert, sabırsız", "same_as": "SPK_HASAN"}`.
- `SPK_BRIG` girdisini **değiştir**: `same_as` kaldırılır, `SIEGE_VOICES.md`'deki kendi tarifi (`gender`, `age`,
  `design`) yazılır. Şu an Kaptan'ın (SPK_CAPTAIN) sesini paylaşıyor ve telsizden geliyormuş gibi duyuluyor.

## 2. Hazırlık
```
python3 tools/voice_map.py
python3 tools/voice_gen.py check
```
Kalan kotayı kullanıcıya söyle. Bu iş yaklaşık 60 replik, 6–7 bin karakter; ayrıca iki karakter için ses tasarımı.

## 3. Ses tasarımı (kullanıcı seçer)
```
python3 tools/voice_gen.py design --only SPK_KASIM,SPK_BRIG
```
`docs/voice/design/index.html` sayfasını aç. Kullanıcı her biri için 1, 2 ya da 3 der:
```
python3 tools/voice_gen.py pick SPK_KASIM N
python3 tools/voice_gen.py pick SPK_BRIG N
```
Beğenmezse `design` tarifini kullanıcının dediğine göre İngilizce güncelle ve `--force` ile yeniden üret.

## 4. Üretim
```
python3 tools/voice_gen.py fix --list docs/voice/REGEN_BRIG.txt
python3 tools/voice_gen.py fix --list docs/voice/REGEN_CH21.txt
python3 tools/voice_gen.py fix --list docs/voice/REGEN_V037.txt
```
Sahne bağlamı için `scripts/chapter21.gd` dosyasına bakıp tonları ayarlayabilirsin, örneğin:
- `D21_J_CALL` ve `D21_M_LIE` uzaktan bağırış: `[shouting]`.
- `D21_N_DANGER` fısıltı ve panik: `[whispers] [panicked]`.
- Kasım'ın replikleri yorgun ve korkmuş: `[tired]`, `[scared]`.

Parantez içindeki sahne tarifleri, örneğin `D21_T_FREEZE` ya da `D21_M_HUSH`, `voice_gen` tarafından metinden çıkarılır;
tamamı parantez olan satırlardan boş ses üretilirse o dosyayı sil.

## 5. Dinletme
```
python3 tools/voice_gen.py review --chapter 21
python3 tools/voice_gen.py review --chapter 19
```
`docs/voice/review.html` sayfasını aç. Kullanıcının beğenmediği satırı `redo ANAHTAR --tone "[...]"` ile yeniden üret.
İstersen `python tools/voice_asr_check.py --only D21_,D19_,D19O_` ile metin-ses eşleşmesini denetle.

## 6. Kaptanın ses kısması
Brigantin kaptanı kendi sesiyle üretildiyse `scripts/autoload/voice_gain.gd` başındaki `SPK_BRIG` kısma satırlarını
(D19_C_*, D19O_C_*) sil.

## 7. Commit
`assets/audio/voice/`, `docs/voice/cast.json`, `docs/voice/VOICE_MAP.csv`, `docs/voice/design/design.json` ve
`scripts/autoload/voice_gain.gd` dosyalarını commit'le (mesaj Türkçe) ve push'la.
