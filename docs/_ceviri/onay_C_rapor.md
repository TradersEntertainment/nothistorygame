# Çeviri onayı · Grup C (dilim 5 + dilim 6): denetim ve ikinci okuma raporu

Görev: `docs/_ajan/gorev/ceviri_ikinci.md`. İlk turun teslimleri: `wip/ceviri-5`, `wip/ceviri-6a`, `wip/ceviri-6b`.
Oyun dosyalarına (i18n/strings.csv, VOICE_MAP.csv, betikler, sesler) dokunulmadı; ses üretilmedi.

## Nasıl okundu
Grubun 1.781 anahtarı betiklerdeki geçiş sırasına göre dizildi (her anahtar ilk geçtiği `scripts/chapter*.gd` işlevinin
altında, komşu replikleriyle; betikte adı birleştirilerek kurulan varyantlar `_NOFEZ`, `_HUFEZ`, `_KNOWN_*`, `_WARNED6B`
vb. kök anahtarın hemen arkasına kondu) ve sahne sahne, TR ve EN birlikte okundu. Kapsam dosyası her öbekten sonra
yazıldı ve ara kayıtlar gönderildi.

## Sayılar
- **Okunan satır (kapsam_C.csv):** 3.562 satır = 1.781 anahtar × 2 dil (EN'i boş anahtar yok).
  - dilim 5: 677 anahtar (1.354 satır) · dilim 6: 1.104 anahtar (2.208 satır).
  - hüküm: `iyi` 3.454 · `oneri` 102 · `supheli` 6.
- **İlk turun önerileri: 90 satır** → **kabul 77 · düzelt 8 · ret 5**.
  - dilim 5 (33): kabul 28 · düzelt 4 · ret 1
  - dilim 6a (36): kabul 32 · düzelt 2 · ret 2
  - dilim 6b (21): kabul 17 · düzelt 2 · ret 2
- **İkinci okumada yeni öneri: 17 satır** (dilim 5: 8 [tr 7, en 1] · dilim 6: 9 [tr 3, en 6]); bunların 5'i varyant ya da
  bağlı replik eşlemesi, 12'si ilk turun kaçırdığı çeviri kokusu.
- **Uygulanacak son liste (onay_C.csv'de `kabul` + `duzelt`): 102 satır, 91 anahtar.** Hepsi eskinin %70–130'u içinde,
  yeni rakam/kısaltma/parantez yok; Hristiyan konuşmacılarda `check_voice_rules.py` yemin listesine takılan söz yok.

## İlk turdan ret (gerekçeleriyle)
1. **D10O_A_Q3_WRONG (tr)** "Kesinlikle yanlış!" → "Düpedüz yanlış!": eski zaten doğal bir ünlem; dolgu değil vurgu. Değişiklik gereksiz.
2. **D24O_S_3_JOKE (tr)** "Belki de utandı. Hepimiz adına." → "Hepimizin yerine.": "birinin adına utanmak" Türkçede yerleşik
   ("senin adına utandım"); "yerine" anlamı kaydırıyor.
3. **D26_T_HOLD (tr)** "'hasarsız yıl' derler... Prim düşer." → "hasarsızlık indirimi derler... Prim düşer.": "hasarsız yıl"
   Türk sigortacının da sözü; "buna" hasarın olmamasını gösteriyor, indirimi değil. Yenisi kendini tekrarlıyor.
4. **D38O_R_01 (tr)** ve 5. **D38O_R_01_TOLD (tr)** "Zincirin önündeki göz" → "gözcü": "göz" bir lakap ve geri dönen söz; 19o'da
   aynı reis "Bu gece sinek de biziz, göz de biziz" (D19O_R_01) der. "Gözcü" göndermeyi siler. (EN tarafı düzeltildi, aşağıda.)

## İlk turdan düzelt (ilk turun metni → son metin)
- **D19_P_SALAM / D19O_T_WISH / D27_T_B_FLEE** "rast gele" / "yolunuz açık olsun" → üçünde de **"Rüzgârınız bol olsun"**; ayrıca
  ilk turun bıraktığı **D19O_C_TELL** de aynı söze çekildi (yeni öneri). "Rast gele" balıkçı selamı; dört replik aynı dileğin
  yankısı (19 devriyesi → 19o Tolga'nın aynası → 27 "bu sefer") ve ilk tur onları üç farklı söze dağıtmıştı.
- **D21_T_MAP** "Ben de kâğıt üstünde değil..." → "Ben kâğıt üstünde değil, tünelin içindeyim": "ben de" çelişkili okunuyordu.
- **D22_G_04** "kaşından olursun" → "kaşlarından olursun": şakanın döndüğü D22_T_SINGED "Kaşlarım!" çoğul.
- **D26O_T_WALL** "Eksik olmasınlar." → "İnecekler tabii.": "eksik olmasınlar" teşekkür alayı; burada "şansıma bak" alayı lazım.
- **D38O_R_01 / D38O_R_01_TOLD (en)** "The lookout at the chain" → "Our eye at the chain": lakap ve D19O_R_01 göndermesi korunuyor.

## İkinci okumada yeni öneriler (seçme)
- **D22_N_01** "yakan siz olmak zorunda değilsiniz" → "kuleyi yakmak size düşmez" (Nihat; "-mek zorunda değilsiniz" kalıbı).
- **D23_I_KNOWN (tr)** "iki tarafın da dilindesin" (= herkesin ağzındasın) → "iki tarafın da dili sensin" (tercümanlık; D23_I_LETTER'e bağlı).
- **D23_K_KNOWN (en)** "Every door in this city opens onto you." → "Every door I open in this city, there you are."
- **D26_I_TEZ_FREE / D26_I_KASIM_FREE** "Kâtibin olmak bir onurdur... Kimse olarak gidiyorum." → "...şereftir... Adsız sansız gidiyorum."
- **D27_T_NT_STAY** "birinin tutmaya devam etmesi gerek" → "biri tutmalı; defter yarım kalmasın."
- **D29_N_01** "Endişelenmeyin" → "Merak etmeyin".
- **D32O_TL_01 (en)** tellalın üçüncü ilanı da "Hear ye, and say not you did not hear!" diyordu; ilk tur ikisini düzeltip bunu atlamıştı.
- **D24O_D_REST** "lafım senin kadar tuzlu değildi" → "lafımın seninki kadar tadı tuzu yoktu".
- **D35O_T_SLOPE (tr+en)** "benden hep tam ortasını istediler" → "benden hep orta yolu istediler".
- **D42B_T_END** "tahta kılıçla da Ceneviz gibi vuruyor" → "tahta kılıçla da demir gibi vuruyor" (D42B_T_SPAR_LOSE ile eşleşir).
- **D22O_T_FIRE (en)**, **D38O_S2_HOOK (en)**, **D43O_F_02 (en)**: İngilizcede çalışmayan harfiyen kalıplar.

## Varyant / alıntı eşlemeleri
- D10O_T_THROWN_2 ↔ **D10O_T_THROWN_2_HUFEZ** (EN "My second carrying" ikisinde; ilk tur bağlı demiş ama satır yazmamıştı → eklendi).
- D26_G_DUCK ↔ D26_G_DUCK_WARNED6B (ikisi de değişiyor; _GBOOK / _WARNED'da şarap yok, doğru).
- D26_I_TEZ_FREE ↔ D26_I_KASIM_FREE · D27_I_THANKS ↔ D27_I_THANKS_KASIM · D38O_R_01 ↔ D38O_R_01_TOLD.
- D31O_HR_01 ↔ D34O_HR_01 ↔ **D32O_TL_01** (tellal kalıbı) · D37O_U_01 ↔ D37O_U_03 ("my balls").
- D19_P_SALAM ↔ D19O_T_WISH ↔ D19O_C_TELL ↔ D27_T_B_FLEE (denizci dileği).
- D32O_AZ_EARTH ↔ D32O_AZ_FIRE_OUT · D34O_T_KIDS ↔ D34O_T_ICE · D21_N_MAP ↔ D21_T_MAP · D25O_H_WATER → D32O_H_WATER (zaten aynı söz).
- Dokunulmayan ama cevabı yeni söze oturan replikler: D26_MG_INSURER, D27_T_I_THANKS, D29_C_END_HURT, D28O_N_END, D29O_N_FELL,
  D19O_C_WISH, D37O_T_U2, D41O_H_PARRY_EARLY/LATE, D27_NT_STAY, D22_T_SINGED.
- `UI_C*` seçenek metinlerinde değişen bir sözü alıntılayan yok (UI_C26_INSURER yalnız değişmeyen "Hasar tespitteydim. Büyük bir dosya." kısmını alıntılıyor).

## Metne bakan testler ve dosyalar
- **`tests/check_inline.py` + `docs/voice/INLINE.json`:** uygulanacak satırlardan 14'ü INLINE.json'da da var; altyazıyla birlikte
  INLINE güncellenmezse test FAIL verir ve ses eski cümleyi okur: D10O_T_THROWN_2_HUFEZ/en, D19_S_GRAIN_OK, D26O_AB_LADDER_BAD (tr+en),
  D26_G_DUCK, D26_I_KASIM_FREE, D26_I_TEZ_FREE, D27_I_THANKS, D27_I_THANKS_KASIM, D27_T_B_FLEE, D31O_T_39_BAD, D36_T_TORCH,
  D38O_R_01_TOLD/en, D38O_S2_HOOKS_OK.
- **`tests/check_voice_rules.py`:** yeni metinlerde Hristiyan konuşmacı ağzında yasak söz yok (kardinalin "duacıyım"ı listede değil).
- Kod yorumları eski metni alıntılıyor (işlevsiz, test etkisi yok): `scripts/chapter29o.gd:253` ("bu iplere ne oluyor"),
  `scripts/chapter29o.gd:377` ("Yukarıda bir kova vardı. Sonra bir taş vardı.").
- Başka test eski metne bakmıyor (`tests/` içinde değişen anahtar adı ya da ayırt edici parça yok).
- Bütün değişen satırlar seslendirilmiş replik; uygulanırsa yeniden ses üretimi gerekir.

## Sahibine sorulacaklar
1. **"İtfaiyeci" anakronizmi** (D17O_A_OUT "topçu değil itfaiyeciymişsin", D32O_TP_01, D32O_TP_01_HIT): 1453 topçusunun ağzında; bilerek mi? Değilse üçü birlikte "saka" (Sakabaşı finaline de bağlanır).
2. **Denizci dileği**: dört yerde "Rüzgârınız bol olsun" seçildi; "rast gele" ya da başka bir söz istenirse dördü birlikte değişmeli.
3. **D26_G_LIGHTER_BACK** "Topçularım bir hafta ödemedi. Ben de ödemedim.": neyin ödenmediği iki dilde de belirsiz.
4. **D33O_T_06** "Hikmet Amca'nın vergi dairesi": kanonda yok (Hikmet emekli elektrik teknisyeni).
5. **D21_M_LEB**: VOICE_MAP'te konuşmacı SPK_MUFIDE (Saniye) görünüyor, Mirko'nun sahne notu; ayrıca betikte yalnız _LEB2 çağrılıyor (ilk turun notu, doğrulandı).
6. **Niko'nun düzgün Türkçesi** (D19_NK_*, D20_NK_*, D24_NK_*): EVREN "kırık çarşı Türkçesi" diyor; bu sahnelerde Rumca konuştuğu düşünülüyorsa sorun yok.
7. **D41O_H_FIN_* / D42B_H_FIN_*** metinde tuş adları (E, A/D, sağ tık): EVREN 7.3 "tuş adı metne yazılmaz" ile çelişiyor; talim sahnesi olduğu için bırakıldı.
8. **D22_T_COLOGNE (en)** "eighty proof": TR "seksen derece" = %80 alkol = 160 proof. EN "eighty percent" mi olmalı?
9. **D24_T_KID** "birinin ıslanmasına engel olunur": Tolga'nın iç sesinde edilgen biraz resmî; istenirse "ama bir çocuk ıslanmaktan kurtulur".

## En iyi on: önce | sonra
1. **D19_P_SALAM + 3 yankısı**: "Rüzgâr arkanızda olsun." | "Rüzgârınız bol olsun."
2. **D23_I_2_ADD** (İsmail): "Ben Sultan'a bunu götürürsem başımı kaldırmam." | "Ben bunu Sultan'a götürürsem kellem gider."
3. **D26_I_TEZ_FREE** (Isidoros): "Kâtibin olmak bir onurdur, Frenk. ... Kimse olarak gidiyorum." | "Kâtibin olmak şereftir, Frenk. ... Adsız sansız gidiyorum."
4. **D26_T_INSURER** (Tolga): "Toplam ziya, ama belgeli." | "Tam pert, ama belgeli."
5. **D22_N_01** (Nihat): "Tolga Bey, yakan siz olmak zorunda değilsiniz." | "Tolga Bey, kuleyi yakmak size düşmez."
6. **D29O_B_HOOKS_BAD** (Baltaoğlu): "Bu iplere ne oluyor?" | "Bu ipler pamuk ipliği mi?"
7. **D34O_T_KIDS / _ICE** (Tolga): "Benim kızaklarla ilgili kötü anılarım var." / "Buz da kötü anılarım arasına giriyor." | "Ben kızaktan çok çektim." / "Buzdan da çekeceğim var demek."
8. **D23_I_KNOWN** (İsmail, tr+en): "Demek iki tarafın da dilindesin." / "So you are on the tongue of both sides." | "Demek iki tarafın da dili sensin." / "So now you speak for both sides."
9. **D32O_TL_01 + D31O_HR_01 + D34O_HR_01** (tellal, en): "Hear ye, and say not you did not hear!" | "Hear ye, hear ye!"
10. **D26O_T_WALL** (Tolga): "...kuleden iki Cenevizli iniyor. Tabii ki iniyor." | "...kuleden iki Cenevizli iniyor. İnecekler tabii."

## Genel gözlem
İlk turun önerilerinin çoğu (77/90) yerinde; hatalar tek tek değil bağlam okumamaktan geliyor: yankı ve lakap gibi geri dönen
sözler dağıtılmış ya da silinmiş (denizci dileği, "zincirin önündeki göz"), varyantlar ve üçüncü tellal ilanı atlanmış, iki yerde
yerli bir söz "düzeltilmiş" (hasarsız yıl, hepimiz adına). Perde IV metni genel olarak Türkçe düşünülmüş; kalan izler kalıp
dileklerde, minnet sözlerinde ("borçluyum") ve İngilizce sütundaki harfiyen hitap/ilan kalıplarında.
