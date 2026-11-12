# Çeviri düzeltmeleri: uygulama raporu

Dal: `wip/ceviri-uygula`. Girdi: beş onay dosyası (A–E), 484 satır; birleşik dosya `docs/_ceviri/onay_hepsi.csv` (+ `grup` sütunu).

## 1. Özet

- Uygulanan: **353 Türkçe + 76 İngilizce = 429 hücre**, `i18n/strings.csv` ve `docs/voice/VOICE_MAP.csv` içinde aynı metinle (VOICE_MAP: 324 TR + 71 EN hücre; 34 hücre VOICE_MAP'te anahtarı olmadığı için atlandı).
- Beklenen ~460 idi: 461 satır `kabul`/`duzelt` (ret: 23). Aşağıdaki nedenlerle 32 satır uygulanmadı.

## 2. Denetim bulguları

- **Çelişen karar:** 12 (anahtar, dil) çifti, iki grup farklı metin önermiş. Hangisini seçmek yeni metin yazmak/karar vermek olacağından **ikisi de UYGULANMADI** (24 satır). Ayrıntı `once_sonra.md` sonunda:
  D10G_T_W_3 (tr), D12_F_ITEM_TAPE (tr), D4A_ITEM_LIGHTER_2 (tr), D6B_T_SILENT (tr), D6_KADRI_CHICKPEAS (tr), D6_KADRI_SELFIE (tr), HIKMET_ITEM_POWERBANK (tr), REACT_GUARDS_LIGHTER (tr), REACT_KADRI_CHICKPEAS (tr), REACT_KADRI_SELFIE (tr), UI_CH10G_W_ASK (tr), UI_CH6B_SILENT (tr)
- **`eski` ≠ güncel metin:** 0 (hepsi `strings.csv` ile aynen eşleşti).
- **`yeni` boş / `eski` ile aynı:** 0.
- **Yer tutucu / BBCode / `\n` farkı:** 0. **Köşeli/parantezli sahne etiketi farkı:** 0.
- **UI_ düğme/etiket metni uzayan (UYGULANMADI):** 7 (çakışanlar hariç): UI_CH10H_G_NOTHING (tr), UI_CH10H_FRANK_3 (tr), UI_CH13_HE_STAYS (tr), UI_CH10O_Q2_D (en), UI_CHOICE_KICK_HIKMET (en), UI_DUEL_BLOCKED (tr), UI_ARENA_RESULT (tr). `UI_CH15_*`, `UI_LOADTIP_*`, `UI_RECAP_*`, `UI_MENU_NEW_CONFIRM`, `UI_B38O_ROW` düğme değil düz metin sayıldı ve uygulandı.
- **Uzun tire (UYGULANMADI):** SIEGE_NOTE_26_3 (tr), yeni metinde "— T." imzası var.
- **Uzunluk oranı %60–140 dışı (UYGULANDI, işaretli):** D4A_ITEM_BOOK_3 (en, 1.80: "Left." → "Left one."), D4A_ITEM_TAPE_1 (en, 1.53), D1P_T_01 (en, 1.61). Dördüncüsü UI_CHOICE_KICK_HIKMET (en, 1.55) düğme olduğu için uygulanmadı.
- **`ret` (uygulanmadı):** 23 satır, gerekçeler `once_sonra.md`.
- **`bagli` sütunundaki ama listede OLMAYAN anahtarlar** (58 çift; hepsi `strings.csv`'de var, yani bağlı replik değişmeden kalmış; sahibi gözden geçirsin): BUR_AMB_G11_6_2 → BUR_AMB_G11_6_1; BUR_AMB_G13_7_2 → BUR_AMB_G13_7_1; BUR_AMB_G13_7_2 → BUR_AMB_G13_7_4; BUR_AMB_G3_2_2 → BUR_AMB_G3_2_1; BUR_AMB_G3_4_3 → BUR_AMB_G3_4_2; BUR_AMB_G3_5_2 → BUR_AMB_G3_5_1; BUR_AMB_G3_7_2 → BUR_AMB_G3_7_1; BUR_AMB_G4_2_3 → BUR_AMB_G4_2_2; BUR_AMB_G5_1_2 → BUR_AMB_G5_1_1; BUR_AMB_G6_5_3 → BUR_AMB_G6_5_4; BUR_AMB_G7_1_2 → BUR_AMB_G7_1_1; BUR_AMB_G7_7_3 → BUR_AMB_G7_7_2; BUR_AMB_G7_7_3 → BUR_AMB_G7_7_4; BUR_AMB_G7_9_1 → BUR_AMB_G7_9_2; BUR_APPLETREE_2 → BUR_FG_NEW_1; D12_F_WHO_A → D12_F_CANNON_D; D12_K_01 → D12_T_K_02; D14_N_W2_ARREST → D14_N_W2; D15_O_DOCS → D15_O_DOCS_2; D17E_R_KEB → D17E_R_KEB_BACK; D17E_V_KEB → D17E_R_KEB_2; D17E_V_POL_3 → D17E_T_WHAT_POLICY; D17E_V_POL_3 → D17E_V_POL_2; D17_TR_02 → D17_T_02; D19O_T_WISH → D19O_C_WISH; D1_H_21 → D1_T_20; D22O_T_FIRE → D22O_H_02; D22_G_04 → D22_G_SINGED; D22_G_04 → D22_T_SINGED; D23_I_KNOWN → D23_I_LETTER; D24O_D_REST → D24O_D_ALL; D25O_H_WATER → D32O_H_WATER; D26_T_INSURER → D26_MG_INSURER; D27_I_THANKS → D27_T_I_THANKS; D27_T_NT_STAY → D27_NT_STAY; D28O_T_END → D28O_N_END; D29O_T_FELL → D29O_N_FELL; D29_T_END → D29_C_END_HURT; D35O_T_SLOPE → D35O_U_SLOPE; D37O_U_03 → D37O_T_U2; D41O_H_PARRY_2 → D41O_H_PARRY_EARLY; D41O_H_PARRY_2 → D41O_H_PARRY_LATE; D42B_T_END → D42B_T_SPAR_LOSE; D4A_ITEM_LIGHTER_2 → D4A_ITEM_LIGHTER_1; D4A_ITEM_TAPE_1 → D4A_ITEM_TAPE_2; D4B_N_THROW_SHIELD → D4B_T_HIT_2_SHIELD; D6A_M_KAFTAN → D6A_M_JOBS; D6A_S_LETTER → D6A_S_LETTER_R1; D6B_T_SILENT → D6B_G_SILENT; D6_KADRI_CHICKPEAS → D6_KADRI_CHICKPEAS_2; D6_KADRI_CHICKPEAS → D6_KADRI_CHICKPEAS_T; D6_URBAN_POWERBANK_T → D6_URBAN_POWERBANK; D7_NIKO_HELLO → D7_N_NIKO_ASK; D8_H_FAIL_LATE → D8_C_LATE; D9_T_LUTFI_Q → D9_LUTFI_OFFER_2; D_DOWNED_N_3 → D_DOWNED_N_1; D_DOWNED_N_3 → D_DOWNED_N_2; UI_B38O_ROW → UI_B38O_ROW_T

## 3. Kopya metinler

- `scripts/`, `tests/`, `data/` içinde eski metnin kopyası yok.
- Güncellendi: `tools/trailer/trailer.gd:10` ve `:185` (yorum içinde D10B_T_B3_2 alıntısı: "Bu 'hmm' iyi bir 'hmm' mi?" → "Bu 'hmm' hayra alamet mi?").
- **`docs/voice/INLINE.json` (GÜNCELLENMEDİ, tetikli satır içi metin; etiketlerin yeni cümlede nereye gireceği karar gerektirir):** 31 anahtar artık altyazıyla uyuşmuyor, `tests/check_inline.py` bu yüzden **FAIL (31 sorun)**. Ses üretilmeden önce bu satırların etiketleri yeni cümleye göre yerleştirilmeli (bu 31 anahtar REGEN listelerinde):
```
INLINECHECK D2_H_WARRANTY_END (tr): INLINE '[sighs] Garanti bitti. [firm] [urgent] Artık sadece koş.' ≠ altyazı 'Garanti bitti. Koş artık, koş!'
INLINECHECK D2_H_AFTER_WARRANTY (tr): INLINE '[flustered] Garanti bitti. [determined] Ben bir şey yapacağı' ≠ altyazı 'Garanti bitti. Ben bir çaresine bakacağım, bekle.'
INLINECHECK D2_H_RADIO_YES (tr): INLINE '[relieved] [exhales] Oh be. [warm] Sesini duymak güzel. [urg' ≠ altyazı 'Oh be, sesin geliyor ya. Şimdi koş.'
INLINECHECK D2_T_FALL (en): INLINE '[nervous] [out of breath] The slope is ending... [terrified]' ≠ altyazı 'Running out of hill... Out of hill!'
INLINECHECK D2_H_09 (tr): INLINE '[calm] [thinking] Yakında kıyı var [worried] ama askerler de' ≠ altyazı 'Yakınlarda kıyı var ama askerler de var. Uzakta bir zincir g'
INLINECHECK D2_T_ARROW_3 (tr): INLINE '[nervous laugh] Uyarı atışı herhalde. [shaky] [sarcastic] Ço' ≠ altyazı 'Uyarı atışı herhalde. Uyarıyı aldık, sağ olun.'
INLINECHECK D3_H_RESIST (tr): INLINE '[nervous] [hurried] O tavuk bizim değil! [pause] ...O ok da ' ≠ altyazı 'O tavuk bizim değil! ...O ok da bizim değil. Ben hiçbirini t'
INLINECHECK D1P_T_01 (en): INLINE '[sleepy] [groggy] Mmh... Hello? [alarmed] [half awake] Who d' ≠ altyazı 'Mmh... Hello? At this hour? Who died?'
INLINECHECK D1_H_06 (tr): INLINE '[serious] Makinenin tek bir arızası var evlât: [baffled] çal' ≠ altyazı 'Makinenin tek bir arızası var evlât: çalışıyor. Valla ben de'
INLINECHECK D1_T_05 (tr): INLINE '[skeptical] Dur dur dur. Şaka yapıyorsun, değil mi? [whisper' ≠ altyazı 'Dur dur dur. Dalga mı geçiyorsun? Bu alet cidden çalışıyor m'
INLINECHECK D1_H_21 (tr): INLINE '[as if it's obvious] Acil olursa bas, acil değilse basma. Bu' ≠ altyazı 'Acil olursa bas, acil değilse basma. Bunda anlamayacak ne va'
INLINECHECK D17E_G_01 (en): INLINE '[stern] Mehmed. Sit. [dry] The guest too; [wise] knowledge t' ≠ altyazı 'Mehmed. Sit. The guest too; learning taken standing up never'
INLINECHECK D17E_M_TO_AVLU (tr): INLINE '[eager] Gel, seni arkadaşlarımla tanıştıracağım. Biri çok il' ≠ altyazı 'Gel, seni arkadaşlarımla tanıştıracağım. Biri pek acayiptir.'
INLINECHECK D17E_R_KEB (en): INLINE '[eager] I'll get lamb from the kitchen. [grinning] The head ' ≠ altyazı 'I'll get lamb from the kitchen. The head cook grumbles, but '
INLINECHECK D17E_R_LEG_0 (en): INLINE '[scared] [squeaky] Brother! There's a bat on the wall!' ≠ altyazı 'Vlad! There's a bat on the wall!'
INLINECHECK D17E_T_BRUTUS_2 (tr): INLINE '[whispers] [horrified] Bunu söylememeliydim. [panicked] Bunu' ≠ altyazı 'Bunu söylememeliydim. Hiç ama hiç söylememeliydim.'
INLINECHECK D17E_T_NONE_2 (tr): INLINE '[nervous] Hayır. [forced compliment] Güzel… sopa.' ≠ altyazı 'Yok. Sopan… güzelmiş.'
INLINECHECK D17E_V_02 (tr): INLINE '[bitter] [flat] Babam bizi burada bıraktı. Şimdi duyduk ki H' ≠ altyazı 'Babam bizi burada bıraktı. Şimdi duyduk ki Haçlılarla birlik'
INLINECHECK D17E_V_KEB (tr): INLINE '[chewing] [surprised] [reluctantly] …Bu iyi.' ≠ altyazı '…Güzelmiş.'
INLINECHECK D17E_V_POL_3 (en): INLINE '[deadpan] A stake. Through the purse. [slow smile] I like it' ≠ altyazı 'A stake. I like it. I'll give everyone a stake.'
INLINECHECK D26O_AB_LADDER_BAD (en): INLINE '[weary] [bitter] Clerk... On 18 April that stockade didn't g' ≠ altyazı 'Clerk... On 18 April we didn't so much as scratch that stock'
INLINECHECK D38O_R_01_TOLD (en): INLINE '[urgent] [remorseful] Clerk! The eyes before the chain! That' ≠ altyazı 'Clerk! Our eye at the chain! That night you said "their turb'
INLINECHECK D10O_T_THROWN_2_HUFEZ (en): INLINE '[groaning] My second carrying. [wry] The one in the fez is H' ≠ altyazı 'Eviction number two. The one in the fez is Hüseyin. I'd know'
INLINECHECK D_CLIMB_FALL_2 (tr): INLINE '[groaning] [wry] Yerçekimi bugün çok mesai yapıyor.' ≠ altyazı 'Yerçekimi bugün fazla mesai yapıyor.'
INLINECHECK D_CLIMB_TIRED_3 (tr): INLINE '[straining] [whining] Kollarım kalem tutmak için yapılmış, d' ≠ altyazı 'Benim kollarım kalem tutar, duvar tutmaz ki.'
INLINECHECK D_LM_ZINCIR (tr): INLINE '[thoughtful] Haliç'in zinciri. Kütüklerin üstünde demir halk' ≠ altyazı 'Haliç'in zinciri. Kütüklerin üstünde demir halkalar. Yakında'
INLINECHECK D_PERCH_AYA (tr): INLINE '[awed] [softly] Kubbenin tepesindeyim. Dokuz yüz yıllık kurş' ≠ altyazı 'Kubbenin tepesindeyim. Dokuz yüz yıllık kurşun, altımda ılık'
INLINECHECK D_WIT_2 (tr): INLINE '[awed] [confused] Melek mi o? Neden şapkası var?' ≠ altyazı 'Melek mi o? Meleğin şapkası mı olur?'
INLINECHECK D_WIT_8 (tr): INLINE '[nervous] [whispers] Kimse bir şey demesin. Sadece yüzüne ba' ≠ altyazı 'Kimse bir şey demesin. Sakın yüzüne bakmayın.'
INLINECHECK D_WIT_9 (tr): INLINE '[stammering] O... o bir kuş değil. [baffled] Kuşlar kravat t' ≠ altyazı 'O... o kuş değil. Kuş kravat takar mı hiç?'
INLINECHECK REACT_CROWD_BYZ_COLOGNE (tr): INLINE '[sniffs] [nostalgic] Limon kokusu! Rahmetli karım gibi kokuy' ≠ altyazı 'Limon kokusu! Rahmetli karım gibi kokuyorsun. İyi anlamda sö'
INLINECHECK FAIL (723 anahtar, 31 sorun)
```
- Geçmiş kayıtlar, dokunulmadı: `docs/voice/.inline_done_{tr,en}.json`, `docs/voice/design/design.json` ve `index.html` (ses tasarımı örnekleri; D6_LUTFI_ASK, D6_URBAN_ASK, D10H_E_01, D12_F_ITEM_CHICKPEAS, D17_TR_02, D17E_V_02, D19O_C_TELL, D24_M_01 eski metni taşıyor).

## 4. Yeniden seslendirme listeleri

`docs/voice/REGEN_CEVIRI_TR.txt` (324 anahtar), `docs/voice/REGEN_CEVIRI_EN.txt` (71 anahtar). Ses üretilmedi. Konuşmacıya göre:

**TR**: TOLGA 86, NIHAT 50, HIKMET 19, FATIH 16, GIUST 9, KADRI 7, MARCOPOLO 5, HASAN 5, SHAKESPEARE 4, MINER 4, ISIDORE 4, AZAP 4, TOWNSMAN 4, CALLIGRAPHER 4, NASREDDIN 3, CAESAR 3, GAGARIN 3, MOZART 3, EMPEROR 3, ISMAIL 3, NIKO 3, SOLDIER 3, WITNESS 3, DOUBLE 3, WINE 3, NEWTON 2, CLEOPATRA 2, NAPOLEON 2, MUFIDE 2, HUSEYIN 2, VLAD 2, DEFENDER 2, BRIG 2, SAILOR 2, SAILOR2 2, DERVISH 2, AZAPBASI 2, PASHA 2, GENOESE 2, STREET_MONK 2, WOMAN_BYZ 2, PAINTER 2, CANDARLI 2, KID 2, GUIDE 1, ARCHAEOLOGIST 1, EDISON 1, SABRI 1, GALILEO 1, CURIE 1, EINSTEIN 1, GENGHIS 1, SINAN 1, THEODOROS 1, ENVOY 1, SEHZADE 1, TOPCU 1, TREVISANO 1, PATROL 1, MONK 1, MANAGER 1, FISHMONGER 1, BALTA 1, CATTANEO 1, CAVUS 1, MERCHANT 1, LUTFI 1, URBAN 1, CEMIL 1, CITY_GUARD 1, CHILD_BYZ 1, JANISSARY 1, PRIEST 1, CLERK 1, NOTARY 1, TAILOR 1

**EN**: TOLGA 10, HIKMET 8, HASAN 6, NIHAT 4, FATIH 4, URBAN 4, EMPEROR 3, HERALD 3, NASREDDIN 2, KADRI 2, RADU 2, PATROL 2, HUSEYIN 2, NIKO 2, EDISON 1, SABRI 1, MARCOPOLO 1, GALILEO 1, GURANI 1, VLAD 1, TOPCU 1, GIUST 1, ISMAIL 1, AZAPBASI 1, SAILOR2 1, CAVUS 1, MINER 1, SOLDIER 1, PORTER 1, WINE 1, KID 1

## 5. Satır sayısı kanıtı

Taban: `origin/wip/0.99.119`. Satır sonu: strings.csv LF, VOICE_MAP.csv CRLF (korundu); özgün tırnaklama hücre bazında korundu; dosya sonu ve boyut dışında yapı aynı; yeniden ayrıştırma: strings.csv 9666 kayıt × 3 sütun, VOICE_MAP.csv 5805 × 8 (değişmedi).

```
 docs/voice/VOICE_MAP.csv | 736 +++++++++++++++++++++----------------------
 i18n/strings.csv         | 800 +++++++++++++++++++++++------------------------
 2 files changed, 768 insertions(+), 768 deletions(-)

368	368	docs/voice/VOICE_MAP.csv
400	400	i18n/strings.csv
```
Uygulanan hücre → dosya satırı: strings.csv 429 hücre / 400 benzersiz anahtar = 400 satır; VOICE_MAP.csv 395 hücre / 368 anahtar = 368 satır (bir satırda hem TR hem EN değişmişse tek satır sayılır). Eşit.

## 6. Testler

```
=== python3 tests/check_consequences.py
bayrak: 201 yalnız kendi bölümünde okunan: 61 okunmayan: 21 izinli: 21 sorun: 0
=== python3 tests/check_export_refs.py
EXPORTREFS PASS
=== python3 tests/check_inline.py
INLINECHECK D_WIT_8 (tr): INLINE '[nervous] [whispers] Kimse bir şey demesin. Sadece yüzüne ba' ≠ altyazı 'Kimse bir şey demesin. Sakın yüzüne bakmayın.'
INLINECHECK D_WIT_9 (tr): INLINE '[stammering] O... o bir kuş değil. [baffled] Kuşlar kravat t' ≠ altyazı 'O... o kuş değil. Kuş kravat takar mı hiç?'
INLINECHECK REACT_CROWD_BYZ_COLOGNE (tr): INLINE '[sniffs] [nostalgic] Limon kokusu! Rahmetli karım gibi kokuy' ≠ altyazı 'Limon kokusu! Rahmetli karım gibi kokuyorsun. İyi anlamda sö'
INLINECHECK FAIL (723 anahtar, 31 sorun)
=== python3 tests/check_keys.py
anahtar: 6810 sorun: 0
=== python3 tests/check_outcomes.py
kuşatma sonucu: 74  okunan: 74  okunmayan: 0  izinli: 1  hiç iz bırakmayan bölüm: 0 ()
=== python3 tests/check_speakers.py
SPEAKERCHECK PASS
=== python3 tests/check_tween_await.py
=== python3 tests/check_voice_rules.py
VOICERULES PASS (9665 anahtar, 0 sorun)
```
- `parse_check`: PARSECHECK PASS scripts=248
- `tests/check_inline.py`: **FAIL (31 sorun)**, nedeni yukarıda (INLINE.json eski metinde). Taban dalda PASS (0 sorun). Diğer `check_*.py` hepsi PASS/sorun 0.
- Başsız autotest (varsayılan yol, `--autotest`), 12 bölüm, hepsi `AUTOTEST PASS`; yasak satırlar (SCRIPT ERROR, WARN_FX_STUCK, WARN_FLY_ITEM, VISAUDIT, WARN_VOID_TELEPORT, WALKTHRU, ARMAUDIT, HELDAUDIT, LOOKAUDIT backturn, JOURNEY_MISS, JOURNEY_OVERLAP) = 0; altyazı taşması/uzunluk uyarısı yok. Bölümler (değişen replik sayısı): 1 (4), 2 (6), 3 (6), 4 (8), 6 (9), 7 (12), 9 (7), 10 (24), 11 (23), 12 (19), 17 (15), 26 (11).
- Not: bu autotestler altyazı kutusunu ölçen ekranlı koşu değildir; ekranlı altyazı taşması denetimi yapılmadı (KANITSIZ).
- `.translation` (derlenmiş çeviri) dosyaları Godot içe aktarmasıyla yenilendi ve kaydedildi; `.import`/`.uid` dosyaları kaydedilmedi.
