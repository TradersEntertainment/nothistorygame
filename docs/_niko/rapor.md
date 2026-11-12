# Niko, yön B: uygulama raporu

**Karar:** sahibin seçtiği yön B, "eski nöbetçi: hepsini gördü, hiçbirine şaşırmıyor" (`origin/wip/niko-yeniden:docs/NIKO_YENIDEN.md` §3b, §4.2) ve o yönün sahibin dinleyip seçtiği 12 örnek repliği (`docs/NIKO_YENIDEN_ornek.json`, yön `b`). Örnekler TR ve EN olarak **aynen** kullanıldı.

**Okunacak belge:** `docs/_niko/once_sonra.md` (sahne sahne, karşı repliklerle, ESKİ → YENİ, yeni İngilizce ve her espri için not). Makine okur döküm: `docs/_niko/niko_b.csv`.

## Sayılar

| | Adet |
|---|---|
| Niko anahtarı (`VOICE_MAP.csv`, `SPK_NIKO`) | 125 |
| Metni değişen | **82** (Türkçesi 82, İngilizcesi 81; `D10H_N_1`'in İngilizcesi zaten iyiydi) |
| Aynen kalan | **43**: 8Y'nin 11'i (`SINERJI_N` dışı); 19 ve 20'nin hepsi; 24'ün `SAVED` dışındakiler; 10H'den `NOPEAS`, `NOPEAS_NEW`, `DONE`, `K_ALT`; `D4B_N_ISTANBUL`, `D4B_N_HAT(_NOFEZ)`, `D6B_N_HINT`, `D6B_N_NOT_YET`, `D6B_N_E_04`, `D7_AWE_NIKO`, `D7_EAVES_*` (2), `D11_NK_00`, `D13_N_MISSED_STRANGER`, `BOOK` ve `POWERBANK` (ikişer anahtar), `REACT_NIKO_REPLAY_2…5` |
| Yeni anahtar | **1**: `D4B_N_02_NOFEZ` (aşağıda, soru 1) |
| Başka karakterin değişen repliği | **0** metin; 1 biçim değişikliği (`REACT_NIKO_LIGHTER` içindeki Tolga cümlesi, aşağıda) |

**Ne değişti, kısaca:**
- Ödünç skeç ("Annen bir Ceneviz kayığıydı", "Annen de mi ayna?") ve her cümlenin sonundaki espri gitti.
- Bağırma yalnız gerçek seslenmede kaldı: nöbetçi çağrısı ("Kim o?", "Casus! Buraya.", "Dur!"), selde kapı, gedikte yük.
- Tavuk fırlatmanın sebebi var: ok bitti.
- "Zindan formu" Niko'nun ağzında **defter** oldu. Tolga ve Nihat kendi ağızlarında yine "form" der; Bölüm 11'de Niko Nihat'ın "Bu da bir form mu?" sorusuna cevap veriyor.
- Korunanlar: "Fes: kırmızımsı" / "Şapka: yok" (30 anahtarlık dayanak), incir ve Hektor (Tolga'nın cevapları), "fes + casus", eşya tepkilerinin işi (leblebi → dostluk), pazarlık bilgisi (elli akçe, bir gün, akşam), bütün yön tarifleri ve kurallar.
- Yeni damarlar seyrek tutuldu: dört aydır maaş yok, otuz yıl, uykusuzluk, "Olur." / "Why not.".
- Ay tutulması, hiçbir şeye şaşırmayan adamı sarsan tek şey: fısıltı ve tek bir "Panagia".

## Uygulanan dosyalar

- `i18n/strings.csv`: 82 hücre çifti değişti, 1 satır eklendi. Satır düzeyinde yazıldı; `git diff`'te yalnız bu 83 satır görünür, satır sonu (LF) ve öbür satırların tırnaklaması aynı.
- `docs/voice/VOICE_MAP.csv`: aynı 83 satırda `tr` ve `en` güncellendi (CRLF korundu). Ton sütunu:
  - `ton_elle=0` satırlarda `tools/voice_map.py`'nin kendi `guess_tone` kuralıyla yeni metinden yeniden hesaplandı (eski `[shouting]` ünlemlerden geliyordu).
  - Elle `[whispers]`, `ton_elle=1`: `D4B_N_ECLIPSE_2`, `D4B_N_ECLIPSE_3`.
  - `D19_NK_01`'in elle tonu (`[excited]`) korundu.
- `docs/voice/INLINE.json`: Niko'nun INLINE girdileri (`D19_NK_TEZKIRE`, `D20_*`, `D24_*`) içinde metni değişen yalnız `D24_NK_SAVED`; İngilizce satır içi okuma yeni metne göre yeniden yazıldı. Öbürleri aynen kaldı.
- `docs/voice/MESAFE.csv`, `scripts/`, `i18n/*.translation`, `cast.json`: dokunulmadı.
- Denetimler: `check_keys.py` (0 sorun), `check_speakers.py` PASS, `check_voice_rules.py` PASS, `check_inline.py` PASS.

## Seslendirme listeleri

- `docs/voice/REGEN_NIKO_TR.txt`: 83 anahtar (82 + yeni `D4B_N_02_NOFEZ`).
- `docs/voice/REGEN_NIKO_EN.txt`: 82 anahtar.
- `docs/voice/REGEN_NIKO_DIGER_TR.txt`, `REGEN_NIKO_DIGER_EN.txt`: **boş**. Başka konuşmacının seslendirilen metni değişmedi. `REACT_NIKO_LIGHTER` Niko'nun anahtarı ve Niko listelerinde.

## B. Uyum: başka karakterler

**Değişen (1, yalnız biçim):**

| Anahtar | Ne | Gerekçe |
|---|---|---|
| `REACT_NIKO_LIGHTER` (Niko anahtarı, içinde Tolga cümlesi) | Tolga'nın cümlesi kelimesi kelimesine aynı kaldı, yalnız parantez içine alındı: `(Tolga, kendi kendine: "Rum ateşi... tamam, belgeselini izlemiştim.")` | Anahtar Niko'nun sesiyle üretilir; eskiden Tolga'nın sözü de Niko'nun sesiyle okunuyordu. `voice_gen.clean()` parantezi okumaz. Altyazıda cümle duruyor. Kod değişmeden yapılabilen en küçük düzeltme bu (belge §4.3 `_s1`/`_s2` bölmesini önermişti; o yeni anahtar ve kod ister). |

**Bakıldı, değişmesi gerekmedi:**

| Anahtar | Neden aynen |
|---|---|
| `D4B_T_HIT_2`, `D4B_T_HIT_2_SHIELD`, `D4B_T_HIT_2_CHICKEN` | "İncir", "Hektor" ve tavuk Niko'nun bark'larında duruyor. |
| `D4B_T_SPY` | "Fes. Türk casusu." dayanağı duruyor. |
| `D4B_T_ECLIPSE_2` ("Sakin ol.") | Niko bağırmıyor ama korkuyor; "Sakin ol" korkuya cevap. |
| `D6B_T_01_NIGHT` | "Geceyi Niko'nun kapı odasında geçirdim": `D4B_N_SPY2`/`MERCHANT2` artık tam buna sebep veriyor ("defter sabah açılır"). |
| `D7_T_CELL*` (4), `D7_N_TRACE_CELL*`, `D14_NN_2` vb. | "Fes rengi: kırmızımsı" / "Şapka: yok" korundu; Tolga'nın "form" demesi kendi (2026) ağzı. |
| `D11_N_NK_02`, `D11_N_NK_04` (Nihat) | `D11_NK_03` artık Nihat'ın "Bu da bir form mu?" sorusuna cevap veriyor; Nihat'ın satırları aynen işliyor. |
| `D8Y_T_DEP_TOWEL` ("Genelde.") | `D8Y_NIKO_DEP_TOWEL` aynen. |
| `D24_T_NK_01` | Aşağıda soru 4. |
| `D9_T_DEPORTED` | Aşağıda soru 4 (çelişki eskiden beri var, bu iş yaratmadı). |

## Sahibine sorulacaklar

1. **Yeni anahtar `D4B_N_02_NOFEZ`.** Seçtiğiniz örnek `D4B_N_02` "Zincirden in, **fesli**" diyor. Fesi cebinde olan oyuncu da bunu duyuyordu, çünkü bu satırın fessiz eşi yoktu (01 ve 03'ün vardı). Eşi ekledim ("Zincirden in, yabancı…"); kod onu `line_variant` ile kendisi seçer, kod değişmedi. Kalsın mı? Kalırsa yöneticinin `MESAFE.csv`'ye `D4B_N_02_NOFEZ,uzak,12` satırını eklemesi gerekir. Ben dokunmadım.
2. **Örneklerin uzunluğu.** `D4B_N_01` eskisinin 1,5 katı, `D4B_N_SPY` 1,36, `D4B_N_03` 1,31 katı (fessiz eşleri de öyle). Bunlar sizin dinleyip seçtiğiniz metinler, aynen bıraktım. Yalnız `D4B_N_01` 3,5 saniyelik bir bark: sesi süreye sığmazsa üstteki altyazı erken kapanır. Ses üretilince süresine bakılsın mı, yoksa kısaltalım mı ("Kim o? …Zincirde fesli. Eh, olur.")? Öbür bütün repliklerde sınır (en çok 1,3 kat) tutuyor.
3. **`REACT_NIKO_LIGHTER`.** Tolga'nın cümlesini parantez içine aldım: altyazıda görünüyor, seslendirilmiyor. Tolga'nın sesiyle de duyulsun isterseniz anahtarı ikiye bölmek gerekir, bu da kod işi. Bu çözüm yeterli mi?
4. **Tolga'nın iki repliği.** `D9_T_DEPORTED` "Kapıdan itti" diyor, oysa 8Y'de Niko onu kapıya kadar götürüyor. `D24_T_NK_01`'de "sen de beni güldürme" yeni Niko için de işliyor (onun düzlüğü güldürüyor). Yalnız Niko'ya izin verdiğiniz için ikisine dokunmadım. Belgedeki öneri: "Kapıya kadar götürdü. Gerisini bana bıraktı." Uygulayayım mı?
5. **Hitap.** Bölüm 4–13 arasında "casus" dedim; `D6B_N_MISS`'teki "sigortacı" da "casus" oldu, çünkü Niko o anda Tolga'yı öyle biliyor. 10H ve 20'de "Frenk", 19, 20 ve 24'te "Tolga" var. `D8Y_NIKO_1`'deki "Günaydın, sigortacı" ise aynen kaldı: Niko 6b'de "sigorta elçisi" sözünü kendisi tercüme etmişti. Bu yay böyle kalsın mı? Adın öğrenildiği sahne (belge §4.4) yeni anahtar ister, yapmadım.
6. **`REACT_EMPEROR_COLOGNE`.** İçinde bir Niko cümlesi var ("İmparator elini vermez. Ben veririm.") ama İmparator'un sesiyle üretiliyor. Metin yön B ile uyuşuyor, dokunmadım. Bölünmesi ayrı bir iş.
7. **Ses tarifi.** `cast.json`'da `SPK_NIKO.design` hâlâ "Loud, booming, good-hearted, jovial" diyor. Ses seçimini siz yaptığınız ve bu iş metin işi olduğu için değiştirmedim. Bağırmasın diye yeni metinlerde ünlem yalnız seslenme anlarında var; ton sütunu da buna göre yeniden hesaplandı. Ayrıca `D4B_N_ECLIPSE_2/3`'teki elle `[whispers]` tonu kalsın mı?
8. **"Geçer." sözü.** Belge "Geçer."i kuşatma için gittikçe azalan bir inançla tekrar eden söz olarak öneriyordu. 19 ve 24'ün iyi replikleri aynen kaldığı için yerleştirecek doğal yer bulamadım; zorla sokmadım. 24'ün sonuna tek satırlık veda ("Ben Petrion'a, anneme. Geçer, Tolga. …Geçer.") yeni anahtar ve betik ister. İster misiniz?

## Yazım kuralına göre son okuma

Bütün yeni Türkçe replikler sesli okunur gibi bir kez daha geçildi. Bu turda düzeltilenler:
- "Beni yazarlar" (anlamı belirsiz) → "Hesabını benden sorarlar".
- "ne yamadıysak kapatmadı" → "ne yamasak tutmadı".
- "Ateşsiz sıcak testi" (isim yığını) → "Ateş görmeden sıcak duruyor".
- "Martı mı aldı? Olur." → "Olur öyle".
- Fessiz hücre satırındaki kesik "Sabah." → "Acelesi yok, sabah yazarız".

Çeviri kokan eski kalıplar da ayıklandı:
- "Nohut! Kavrulmuş!" → "Nohut mu bu? Kavrulmuş…".
- "Sen iyi casussun" → "Adam gibi casusmuşsun sen".
- "Arkadaşımı korurdum" → "ele vermezdim".
- "Casus için" → "Casusa göre".
- "Kaybolmuşsun" → "Yolunu şaşırmışsın".
- "Dost casus" hitabı düştü.

Dönem hatası olarak 1453 Bizans'ındaki "çay" "tavla" (tabula) oldu.

İngilizceler ayrı yazıldı:
- Söz oyunu yalnız İngilizcede: "Chicken. Duck.".
- İngiliz atasözü: "Fine words butter no parsnips".
- Asker deyimi: "on report".
- Kuru kabul: "Why not.".

Rakam yok; `{…}`/`%s` yer tutucusu Niko satırlarında yoktu. Var olan parantezli sahne notları korundu.
