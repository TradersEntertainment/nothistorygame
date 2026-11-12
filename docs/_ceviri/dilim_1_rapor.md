# Çeviri kokusu taraması · Dilim 1 raporu

Kapsam: `D0, D1, D2, D3, D4A, D4B, D5, D6, D6B, NPC, ITEM, USE` (`python3 docs/_ajan/gorev/ceviri_dilim.py 1`).
Oyun dosyalarına dokunulmadı; ses üretilmedi. Öneriler: `docs/_ceviri/dilim_1.csv`.

## Sayılar

- **Okunan satır: 718** (atlanan yok). Kuşkulu satırlar geçtikleri betikte komşularıyla okundu (`chapter2.gd`, `chapter3.gd`, `chapter4.gd`, `chapter6.gd`, `hud.gd`).
- **Önerilen düzeltme: 45 satır** (44 anahtar; `D5_H_HATCH_EMPTY` iki dilde) · dilimin %6'sı.

| | şiddet 3 | şiddet 2 | şiddet 1 | toplam |
|---|---|---|---|---|
| tr | 0 | 24 | 13 | 37 |
| en | 0 | 5 | 3 | 8 |

Şiddet 3 yok: dilimde "herkesin fark edeceği" ödünç replik olarak yalnız Niko'nun "Annen bir Ceneviz kayığıydı" kalıbı var. O satırlar `wip/niko-yeniden` kapsamında olduğu için CSV'ye koymadım (aşağıda).

## En iyi on örnek (önce | sonra)

| anahtar | önce | sonra | not |
|---|---|---|---|
| D2_H_09 | **Yakında** kıyı var ama askerler de var. | **Yakınlarda** kıyı var ama askerler de var. | "nearby" "yakında" (= soon) diye çevrilmiş; anlam kayıyordu |
| D2_H_AFTER_WARRANTY + D4A_H_02 | Ben bir şey yapacağım, bekle. | Ben bir çaresine bakacağım, bekle. | "I'll sort something out" |
| D6_KADRI_CHICKPEAS | ...ama çıtır! Bu bir devrim. Adı ne? | ...ama çıtır! Bu düpedüz keramet! Adı ne? | "This is a revolution"; 1453 aşçısında "devrim" olmaz |
| D3_H_VANISH | Garajım hayaletli oldu. | Garajı cin mi bastı ne? | "my garage is haunted"; mahallede ev cin basar |
| ITEM_SHOW_THING | ...Cansız nesneler etkilenmedi. | ...Cansız şey, ne anlasın. | "Inanimate objects are not impressed" iskeleti |
| NPC_CROWD_GAL_5 | Bu bizi kardeş yapar. | Korku insanı kardeş eder. | "That makes us brothers" |
| D5_H_HATCH_EMPTY (tr/en) | Bodrum boş bir şey istemez. / The cellar doesn't want nothing. | Bodruma eli boş inilmez. / No use going down empty-handed. | İki dilde de bulanık; EN Türkçenin birebiri |
| NPC_PAINTER_1 | sen de kadraja girdin | sen de resmin içine girdin | "walked into the frame" + 1453'te sinema terimi |
| D0_T_FREEZE_2 | Muhtemelen ... merak ediyorsunuz. Açıkçası ben de. | ...ne işi var diye düşünüyorsunuzdur. Valla ben de bilmiyorum. | "You're probably wondering..." |
| D3_H_TEA_3 (en) | So history changes, and that too. | History changes, and on top of that he's late. | "bir de o"nun birebiri, İngilizcede anlamsız |

## Şüpheli (dokunmadım, sahibine sorulabilir)

- **D0_T_FREEZE_1/2:** Donmuş kare + "Evet, o benim. ... merak ediyorsunuzdur" film/dizi klişesinin kendisi (kural 3'e değebilir). Sahne kurgusu olduğu için yalnız dilini Türkçeleştirdim; klişenin kalıp kalmayacağı sahibinin kararı.
- **D3_H_21** "Bir şey yapmadım. Genel olarak.": "Broadly speaking" kokusu var ama espri olarak işliyor.
- **D1_H_IDLE_4** "dönem otantikliği": Hikmet'in ağzında plaza kelimesi; Tolga'dan kapmış gibi de okunabilir.
- **D2_H_RADIO_NO** "Ben burada terliyorum!": "ter döküyorum" daha yerli, ama mevcut hâli de kulak tırmalamıyor.
- **D4A_H_02 / D4B_H_02** "Kırmızı düğme artık sadece cızırdar": "sadece" dolgusu; D4A_H_02'nin yalnız ikinci cümlesini değiştirdim.
- **D4B_T_CELL** "Pazartesi toplantısı hiç bu kadar uzak olmamıştı" ve **D6B_T_GULL** "Bazı şeyler hiç değişmiyor": İngilizce kalıp ama Türkçede yerleşmiş; Tolga'nın ağzında doğal.
- **D6_LUTFI_TAPE** "İsmi zaten mükemmel", **ITEM_SELF_TAPE** "Bu bir hastalık mı?", **ITEM_SELF_CUBE_2** "İlerleme.": hafif çeviri ritmi, Tolga/Lütfi'de kabul edilebilir.
- **D6_URBAN_ASK** "Beni etkileyecek bir şey göster": Lütfi'deki kalıbın aynısı; Urban'ın bozuk Türkçesi gereği bıraktım.
- **D2_T_FEZ_FOUND** "Haliç bizi birleştirdi", **D4A_HA_FEZ_2** "Kesin. Ömür boyu.": sınırda.
- **EN genelinde "son":** Hikmet'in "evlât"ı İngilizcede tutarlı biçimde "son". Bu, yaşlı bir İngilizin "son" hitabıyla örtüştüğü için çeviri kokusu saymadım.

### Niko satırları (`wip/niko-yeniden` kapsamında, CSV'de yok)
Niko'nun karakteri o dalda baştan yazılıyor; çakışma olmasın diye yalnız `D4B_N_THROW_SHIELD`'ı ("Umurumda değil" → "Bana ne") önerdim. Çeviri izi taşıyan öbür Niko satırları:
- **D4B_N_01 / _NOFEZ, D4B_N_02, D6B_N_BYE:** Monty Python hakaret skecinin uyarlaması (kural 3'ün örneği). niko-yeniden'in 12 anahtarında var.
- **D4B_NIKO_PHONE** "Hey adam! Annen de mi ayna?": Aynı skecin geri dönüşü, ama niko-yeniden'in 12 anahtarında **yok**. Annen esprisi kalkarsa bu da birlikte değişmeli.
- **D4B_N_CELL2** "İyi yüzüyorsun. Casus için." (= "for a spy"), **D4B_NIKO_TAPE** "geleceklilerin nesi var?", **D4B_N_THROW_CHICKEN_3** EN "...It came." (→ "It's back.").

## Dokunmadığım ama komşusu değişen replikler
- **D4B_T_HIT_2_SHIELD** ("Hektor kim?!"): Hektor yeni D4B_N_THROW_SHIELD'da duruyor.
- **D6B_G_SILENT** ("Dikkatli olmak benim mesleğim"): Yeni "kendinize dikkat edin"e de cevap oluyor.
- **D6_KADRI_CHICKPEAS_T** ("Leblebi."): "Adı ne?" sorusu korundu.
- **D1_T_20, D4A_ITEM_LIGHTER_1, D4A_ITEM_TAPE_2, D6_URBAN_POWERBANK, D0_N_FREEZE:** Bunlar değişen replikleri hazırlıyor ya da onlara cevap veriyor; hepsi uyumlu kalıyor.

## Bulgu (çeviri dışı)
- **D6_URBAN_POWERBANK_T:** Betikte bu satırı Tolga söylüyor (`chapter6.gd`, `key + "_T"` → `_t()`), ama `VOICE_MAP.csv`'de `SPK_URBAN` yazıyor. Ses Urban'ın ağzından üretilmiş olabilir; kontrol edilmeli.

## Genel gözlemler
- Dilim büyük ölçüde temiz. Hasan ile Hüseyin, Nihat, Büro, Giustiniani ve İmparator'un eşya tepkileri Türkçe düşünülmüş. Çarşı ve ordugâh kalabalığı (NPC_CROWD_*) en iyi bölüm.
- Çeviri izi en çok **Hikmet'in kısa tepki repliklerinde** çıkıyor: "ben bir şey yapacağım", "sesini duymak güzel", "hayat böyle", "çabuk olmalıyım", "açıkçası beklemiyordum". Hikmet'in uzun replikleri iyi; kısa bağlantı repliklerinde İngilizce iskelet kalmış.
- Tolga'nın **eşya gösterme barklarında** ("etkilenmedi", "etkilenmek zorunda değil") ve "çok başarılı bir uyarı" türü ironide İngilizce kuru espri kalıbı var.
- **Dönem dışı kelime:** Kadri'de "devrim", ressamda "kadraj", Lütfi'de "beni etkile".
- **İngilizce sütunda** Türkçe söz dizimi, Hasan ile Hüseyin'in eşya sahnelerindeki tek kelimelik cevaplarda ("Left is me", "What does it tie?") ve Tolga'nın "The slope has ended" barkında kalmış.
