# Kuşatma seslendirmesi (v0.32)

Kendi bilgisayarında, yerel Claude Code'a şöyle ver:

> `docs/voice/SIEGE_VOICES.md` dosyasını oku ve adımları sırayla yap. `docs/voice/LOCAL_CLAUDE.md` kuralları geçerli.

Durum (v0.32.0):
- **524 replik** henüz seslendirilmedi, toplam yaklaşık **36.700 karakter** (neredeyse hepsi kuşatma bölümleri 17–26 ve
  Osmanlı tarafı 17o–26o). Metni değişmiş eski replik yok; hepsi yeni.
- **14 yeni konuşmacının** sesi yok (aşağıdaki tablo).
- **Mühendis Grant** (`SPK_GRANT`) yanlışlıkla Nihat'ın sesine bağlıydı (eski "hibe memuru" kaydı). 10L'deki 6 repliği
  Nihat'ın sesiyle üretilmiş; kendi sesiyle yeniden üretilecek (`docs/voice/REGEN_GRANT.txt`).

## Kurallar (LOCAL_CLAUDE.md'den)
- ElevenLabs anahtarı yalnız `ELEVENLABS_API_KEY` ortam değişkeninde; hiçbir dosyaya yazılmaz, ekrana basılmaz.
- Her aşamadan önce `python3 tools/voice_gen.py check` ile kotayı söyle; bu iş için ~37 bin karakter + ses tasarımı gerekir.
- Sesleri kullanıcı seçer.

## 1. Güncelle ve haritayı yenile
```
git pull
python3 tools/voice_map.py
python3 tools/voice_gen.py check
```

## 2. cast.json: yeni konuşmacılar
`docs/voice/cast.json` dosyasına şu girdileri ekle (var olanlara dokunma). `SPK_GRANT` girdisini **değiştir**
(`same_as` kaldırılır, kendi tarifi olur). `same_as` olanlar tasarım gerektirmez, başka bir karakterin sesini kullanır.

```json
"SPK_GRANT":     {"tarif": "Mühendis Johannes Grant; İskoç/Alman, kuru, kesin, pratik",
                  "gender": "male", "age": "middle_aged",
                  "design": "Scottish-German military engineer in his 50s, dry, precise and practical, calm under pressure, slight foreign accent when speaking Turkish"},
"SPK_BRIG":      {"tarif": "Brigantinin kaptanı; Türk kılığında Venedikli, kırık Türkçe",
                  "gender": "male", "age": "middle_aged",
                  "design": "Venetian sea captain in his 40s, weathered, calm and dry, speaks Turkish with a noticeable Italian accent"},
"SPK_PATROL":    {"tarif": "Osmanlı devriye reisi; huysuz, pratik, yorgun mizah",
                  "gender": "male", "age": "old",
                  "design": "Ottoman naval petty officer in his 50s, gruff, pragmatic, tired sense of humour, deep weathered voice"},
"SPK_TOPCU":     {"tarif": "Topçubaşı Ali; top gürültüsünden yüksek sesli, kendinden emin",
                  "gender": "male", "age": "middle_aged",
                  "design": "Ottoman master gunner in his 40s, loud from years beside cannons, confident and commanding, slightly hoarse"},
"SPK_ISMAIL":    {"tarif": "İsmail Hamza, Sultan'ın elçisi; ölçülü, nazik, diplomat",
                  "gender": "male", "age": "middle_aged",
                  "design": "Ottoman envoy in his 50s, measured, courteous and diplomatic, calm authoritative voice"},
"SPK_TREVISANO": {"tarif": "Venedikli kaptan Trevisano; asil, cesur, kararlı",
                  "gender": "male", "age": "middle_aged",
                  "design": "Venetian naval captain in his 40s, noble, brave and decisive, Italian accent"},
"SPK_USTA":      {"tarif": "Köprücü Usta Mahmud; yaşlı marangoz, öğretmen gibi azarlar, sıcak",
                  "gender": "male", "age": "old",
                  "design": "Ottoman master carpenter in his 60s, practical and warm, scolds like a patient teacher"},
"SPK_DEFENDER":  {"tarif": "Surdaki savunucu; yorgun, kararlı, pürüzlü ses",
                  "gender": "male", "age": "middle_aged",
                  "design": "Byzantine soldier in his 30s, exhausted but determined, rough voice"},
"SPK_LOOKOUT":   {"tarif": "Gözcü; genç, telaşlı, uyarı bağırır",
                  "gender": "male", "age": "young",
                  "design": "young Byzantine lookout, urgent, shouting warnings from the walls, clear voice"},
"SPK_MONK":      {"tarif": "Keşiş Makarios; yaşlı, yumuşak, yavaş, dingin",
                  "gender": "male", "age": "old",
                  "design": "elderly Orthodox monk, soft, slow and serene, slightly frail voice"},
"SPK_ZAGANOS":   {"tarif": "Zağanos Paşa; savaş yanlısı vezir, keskin, buyurgan",
                  "gender": "male", "age": "middle_aged",
                  "design": "Ottoman vizier and general in his 40s, hawkish, sharp and forceful, commanding voice"},
"SPK_COCO":      {"tarif": "Giacomo Coco; atak, sabırsız Venedikli kaptan",
                  "gender": "male", "age": "middle_aged",
                  "design": "Venetian captain, bold, impatient and energetic, Italian accent"},
"SPK_NOVOMINER": {"tarif": "Novo Brdo'lu madenci (Dragan'ın kendisi olabilir)", "same_as": "SPK_MINER"},
"SPK_SAILOR":    {"tarif": "Brigantin tayfası", "same_as": "SPK_DEFENDER"},
"SPK_SAILOR2":   {"tarif": "Yaşlı tayfa", "same_as": "SPK_USTA"}
```
Tarihî kişiler (İsmail Hamza, Zağanos Paşa, Trevisano, Coco, Grant) saygılı seslendirilir; alaya alınmaz.

## 3. Ses tasarımı ve seçim
```
python3 tools/voice_gen.py design --only SPK_GRANT,SPK_BRIG,SPK_PATROL,SPK_TOPCU,SPK_ISMAIL,SPK_TREVISANO,SPK_USTA,SPK_DEFENDER,SPK_LOOKOUT,SPK_MONK,SPK_ZAGANOS,SPK_COCO
```
`docs/voice/design/index.html` sayfasını aç; kullanıcı her karakter için 1, 2 ya da 3 der → `python3 tools/voice_gen.py pick SPK_X N`.
Özel ses sınırı dolarsa küçük rolleri paylaştır (`share`): örn. `SPK_LOOKOUT` → `SPK_SOLDIER`, `SPK_COCO` → `SPK_TREVISANO`.

## 4. Üretim
```
python3 tools/voice_gen.py fix --list docs/voice/REGEN_GRANT.txt     # Grant'in 10L replikleri, kendi sesiyle
python3 tools/voice_gen.py all --chapter 17                           # önce bir bölüm: dinle, beğenilirse devam
python3 tools/voice_gen.py review --chapter 17
python3 tools/voice_gen.py all                                        # kalanların hepsi (var olanları atlar)
```
Bölüm bölüm `review` ile dinlet; beğenilmeyen satır: `python3 tools/voice_gen.py redo ANAHTAR --tone "[..]"`.
Ton ipuçları: gözcü ve dalga bağırışları `[shouting]`, lağım ve gece sahneleri `[whispers]`, Hasan'ın son sahnesi (26o)
ve ateş başı (25o) sakin ve ağırbaşlı, Fatih'in girişi (D26_F_ENTRY) saygılı.

## 5. Commit
`assets/audio/voice/`, `docs/voice/cast.json`, `docs/voice/VOICE_MAP.csv`, `docs/voice/design/design.json` commit'lenir
(mesaj Türkçe), sonra `git push`. `VERSION` dosyasını bir artır (ör. 0.32.1) ki yeni sürüm sesleriyle yayınlansın.
