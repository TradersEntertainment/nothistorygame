# F13_ses: 9 bulgu

## 1. [YÜKSEK] [ses] [EN, 14-43o]
İngilizcede Nihat/Müfide'nin "Mr Tolga:" / "Mr Nihat:" diye hitap ettiği replikler hitaptan sonra kesiliyor ya da Tolga'nın sesine geçiyor

tools/voice_gen.py:295 LABEL düzenli ifadesi "Tolga: ", "Hikmet: " gibi konuşmacı etiketlerini arıyor; İngilizcedeki "Mr Tolga: the Ottoman copy…" hitabını da konuşmacı etiketi sanıp satırı bölüyor: "One correction, Mr" Nihat'ın sesiyle, devamı ("the Ottoman copy opens earlier…") Tolga'nın sesiyle üretilip MP3 baytları uç uca eklenmiş. ASR (small, VAD kapalı) dosyadan yalnız ilk parçayı duyuyor: D17_N_FIRST_28 → "one correction mr" (0.97 sn), D38O_N_BRIEF → "to sum up mr" (uzun brifing 1.39 sn), D27_N_PHOTO → "the last frame mr", D21_N_TORTURE → "that is what the sources say too mr", D14_M_SEEN → "and there's this mr". EN'de bu durumdaki 28 Nihat/Müfide dosyası var: D14_M_SEEN, D14_M_SEEN_LEGEND, D14_M_T3, D17_N_CLAIM(+_NOQ/_SOME/_SOME_NOQ), D17_N_FIRST_28/29/33/42, D21_N_TORTURE, D25O_N_01, D25_N_ISI, D26_N_ISI_O, D27_N_01, D27_N_PHOTO, D29_N_SULTAN, D30O_N_END, D30_N_END, D31O_N_03, D31O_N_PHOTO, D32O_N_LIGHTS, D37O_N_PHOTO, D38O_N_BRIEF, D38O_N_PHOTO, D41O_N_PHOTO, D42B_N_PHOTO, D43O_N_PHOTO. Oyuncu ya "Mr…" deyip susan bir Nihat duyuyor ya da cümlenin yarısını Tolga'nın sesinden. TR'de "Tolga Bey:" etikete uymadığı için Türkçe bu hatadan kurtulmuş; ama TR D15_S7_T_6 "…Bir de özel şart, Hikmet: kırmızı düğmeye basma." Tolga'nın daktilo satırı "Hikmet:" hitabından bölünmüş (ASR: "…bir de özel şart" ile bitiyor; devamı Hikmet sesiyle). Kanıt: /tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit/asr/enm.csv, trm.csv; assets/audio/voice/en/D17_N_FIRST_28.mp3 (iki ID3 başlığı). Öneri: LABEL yalnız satır başında ya da tırnaktan önce gelen etiketi kabul etsin (ör. `Mr |Bey|, ` sonrası hariç); listedeki dosyalar tek parça olarak yeniden üretilmeli.

## 2. [YÜKSEK] [ses] [eşya tepkileri, TR+EN]
Çok konuşmacılı REACT_* dosyaları yalnız ilk parçayı çalıyor (büyük olasılıkla)

voice_gen.py:360-367 her parçayı ayrı MP3 olarak alıp baytlarını uç uca ekliyor (`data += tts(...)`); her parçanın kendi ID3 ve "Info/LAME" başlığı kalıyor. İlk parçanın Info başlığındaki kare sayısı dosyanın uzunluğu sayılıyor: ffmpeg/PyAV kod çözümü ilk parçada duruyor (REACT_HIKMET_PHONE dosyası 112 KB ≈ 7 sn ses taşıyor, çözülen 1.46 sn ve ASR yalnız "Şarj yüzde 14" duyuyor; Hikmet'in "Yeter de artar evlât…" cevabı hiç duyulmuyor). Godot da MP3'ü minimp3 ile çözüyor ve uzunluğu/örnek sayısını aynı Info/VBR başlığından alıyor; hud.say süreyi vs.get_length() ile ayarladığı için oyunda da ilk parçadan sonra kesilmesi beklenir (oyunda dinlenerek doğrulanmalı). Etkilenen TR dosyaları (çözülen süre): REACT_GUARDS_PHONE 1.54 sn, _LIGHTER 0.89, _POWERBANK 1.12, _SELFIE 1.28, _TAPE 1.12, _BOOK 3.14, _CHICKPEAS 2.82, _COLOGNE 2.25; REACT_HIKMET_PHONE 1.46; REACT_FATIH_SELFIE 1.12, _CUBE, _POWERBANK, _COLOGNE; REACT_EMPEROR_BOOK, _TAPE; REACT_GIUST_BOOK; REACT_KADRI_CHICKPEAS; REACT_NIKO_LIGHTER; REACT_URBAN_BOOK, _POWERBANK; D15_S7_T_6 (TR'de 21, EN'de aynıları + yukarıdaki 28). ASR örnekleri: REACT_GUARDS_TAPE → yalnız "bununla ne bağlanır"; REACT_KADRI_CHICKPEAS → "…adı ne" (Tolga'nın "Leblebi" ve Kadri'nin "Leb-le-bi. Sultan'ın sofrasına!" yok); REACT_FATIH_CUBE → "…işte" sonrası yok. Kanıt: /tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit/asr/react_tr.csv. Öneri: parçaları ffmpeg concat ile tek akışa yeniden kodlamak (voice_gen.py'deki tighten gibi), ya da her konuşmacının parçasını ayrı anahtar yapıp say_chain ile söyletmek.

## 3. [ORTA] [ses] [eşya tepkileri]
Sahne notu parantezsiz yazıldığı için karakterin sesiyle okunuyor

voice_gen.clean yalnız (…) ve […] içini atıyor. ASR'nin duyduğu: REACT_GUARDS_SELFIE Hasan'ın sesinden "Tolga fotoğraf çeker" (ve dosya orada bitiyor), REACT_EMPEROR_BOOK İmparator'un sesinden "Kitabı kapatır ve tek kelime etmeden geri verir", REACT_FATIH_COLOGNE Fatih'in sesinden "Elini uzatır", REACT_GIUST_BOOK Giustiniani'nin sesinden "Tolga 29 Mayıs sayfasını gösterir", REACT_URBAN_BOOK Urban'ın sesinden "Tolga sayfayı gösterir". Kanıt: i18n/strings.csv bu anahtarlar; react_tr.csv. Öneri: anlatı kısımlarını parantez içine almak ve yeniden üretmek.

## 4. [ORTA] [ses] [31o]
Derviş ile Akşemseddin art arda aynı sesle konuşuyor (TR)

cast.json'da SPK_AKSEMSEDDIN same_as SPK_MONK, SPK_MONK same_as SPK_DERVISH; ikisi chapter31o.gd:597-598'de peş peşe söylüyor (D31O_DV_01 → D31O_AK_01), sahnede ikisi de var (aksem/dervish düğümleri 780/786). Oyuncu iki ayrı kişiyi aynı sesten duyuyor. Kanıt: docs/voice/cast.json SPK_AKSEMSEDDIN/SPK_MONK; scripts/chapter31o.gd:597. Öneri: Akşemseddin'e ayrı ses (ya da Derviş dışındaki bir sesle same_as, ör. SPK_GURANI/SPK_CANDARLI) verip D31O_AK_* yeniden üretilmeli.

## 5. [ORTA] [ses] [17o, 32o]
Topçubaşı Ali, Aşçıbaşı Kadri'nin sesiyle konuşuyor; iki karakter aynı bölümde

SPK_TOPCU same_as SPK_KADRI (TR ve EN). chapter17o.gd:769 Topçu (D17O_A_DAWN) hemen ardından :780 Kadri (D17O_K_DAWN); 32o'da da Kadri (348-378, 1062) ve Topçu (965-1027) aynı bölümde. Kadri ana karakter, sesi tanınıyor. Kanıt: cast.json SPK_TOPCU; scripts/chapter17o.gd:769,780. Öneri: Topçu'ya ayrı ses ya da ana kadroda olmayan bir sesle same_as.

## 6. [ORTA] [ses] [26o]
Azap Bölükbaşı Turgut, Hasan'ın sesiyle konuşuyor (TR)

SPK_AZAPBASI same_as SPK_JANISSARY → SPK_HASAN. 26o'da Hasan (325-353, 515-550) ve Turgut (464-466) aynı sahnede; ayrıca SPK_JANISSARY de Hasan'ın sesi (32o'da Hasan ile Yeniçeri aynı bölümde). cast.json'daki tarif "kırklarında, Rumelili, boğuk" diyor; Hasan genç ve saf. Kanıt: cast.json SPK_AZAPBASI/SPK_JANISSARY; scripts/chapter26o.gd:464. Öneri: Azapbaşı ve Yeniçeri için Hasan dışında bir ses.

## 7. [ORTA] [ses] [15]
"Ece (satış)" kadın adı, erkek sesle (Ajan 12/b) okunuyor; aynı bölümde Müdür Bey ve Ferit Bey de aynı ses

SPK_COWORKER_B same_as SPK_AGENT2 (gender male, "40'larında büro ajanı"); TR'de SPK_MANAGER ve SPK_AGENCY de SPK_AGENT2. chapter15.gd'de üç farklı kişi (Müdür x9, Ece x3, Ferit Bey x7) aynı erkek sesten. EN'de de Ece ile Ferit Bey aynı ses. Kanıt: cast.json SPK_COWORKER_B/SPK_MANAGER/SPK_AGENCY; scripts/chapter15.gd:516-540. Öneri: Ece'ye kadın sesi (en azından SPK_MUFIDE dışında bir kadın sesi; Deniz zaten Müfide sesinde), Müdür ile Ferit Bey'i ayır.

## 8. [ORTA] [ses] [33o, EN]
İngilizcede Dizdar Firuz Ağa, Kaptan Rizzo, Taşçı Ustası ve Çandarlı Halil aynı sesle

cast_en.json'da SPK_FIRUZ, SPK_RIZZO, SPK_MASON, SPK_HALIL → SPK_HERALD → SPK_CAPTAIN (Kaptan Morosini'nin sesi). chapter33o.gd:965-969'da Firuz → Rizzo → Firuz barkları peş peşe; Osmanlı dizdarı ile Venedikli kaptan aynı sesten konuşuyor. Aynı ses EN'de Çavuş Davud ile Yaşlı papaz (39o), Akşemseddin ile Tellal (31o), Usta ile Tellal (34o) için de ortak. Kanıt: docs/voice/cast_en.json (SPK_HERALD zinciri); scripts/chapter33o.gd:965-969. Öneri: EN kadrosunda HERALD zincirini bölmek; en az Firuz/Rizzo ve Çavuş/Papaz için ayrı ses.

## 9. [ORTA] [ses] [10a] (şüpheli)
D10A_N_MEET_4 "Fesli ziyaretçi" "fessiz" diye okunmuş olabilir

Nihat'ın yönetmelik maddesi ("Madde 1/a: 'Fesli ziyaretçi, geldiği araçla iade edilir.'") hem base hem small modelde "madde bir a fessiz…" diye duyuldu. Doğruysa anlam tersine dönüyor (fesli ↔ fessiz). Dinleyerek doğrulayın; yanlışsa yeniden üretin. Kanıt: .../asr/all_base.csv, re_small.csv.


## 1. [YÜKSEK] [metin] [17o/18b/20o/28o/32o/33o/34o top talimi]
Yinelenen anahtarlar top talimi adımlarını yanlış gösteriyor

UI_GUN_POWDER, UI_GUN_BALL, UI_GUN_RAM, UI_GUN_AIM CSV'de iki kez tanımlı. Satır 4332-4336'da top için "Barut koy / Gülleyi sür / Tokmakla sıkıştır / Nişan al", satır 5345-5348'de tüfek için "Barut namluya… / Gülle… / Harbiyle sık: işaret ortadayken R / Nişan: sağ tık · Ateş: sol tık" var. Godot CSV içe aktarımında sonraki satır öncekini ezer. Bu yüzden scripts/ui/gun_drill.gd:143 `tr("UI_GUN_" + k.to_upper())` top talimi adım listesine tüfek metnini basar. Tokmak adımı E/Space'e 6 kez basılarak yapılıyor (gun_drill.gd:94, 107-111), ama ekranda "R'ye bas" yazar; nişan adımında da "sağ tık" yazar. Uzun metin 290 px kutuya da sığmaz. Kanıt: i18n/strings.csv:4332-4336, 5345-5348; gun_drill.gd:143; scripts/combat/handgun.gd:252, 287, 293, 300 de aynı anahtarları kullanıyor. Öneri: tüfek anahtarlarını UI_HGUN_* adıyla ayır, handgun.gd'yi güncelle, testlere yinelenen anahtar denetimi ekle.

## 2. [ORTA] [metin] [17o/18b, 19o, 22o-26o, 26, arena]
75 EN satırı düz tırnak içinde kalmış, TR karşılıklarında tırnak yok

EN hücresinin kendisi `"..."` ile sarılı (ham CSV'de `"""..."""`). Altyazıda replik baştan sona tırnak içinde görünür, TR'de görünmez. hud.gd:1491 `_show_line(speaker_key, tr(text_key), true)` tırnağı temizlemiyor. Anahtarlar: D19O_N_01, D19O_R_01, D19O_R_02, D19O_T_NOTICE, D19O_T_TELL, D19O_R_TELL, D19O_R_SILENT, D19O_R_PASS, D19O_N_GONE, D19O_R_BACK, D19O_T_BACK, D19O_R_CLOSE, D19O_T_END, D19O_N_END, D22O_N_01, D24O_* (N_01, K_01, T_01, D_01, S_1/2/3 ve _SCIENCE/_SOUP/_JOKE türevleri, D_ALL, D_REST, T_MOON, K_STORM, K_LOST_2, K_END, T_END, N_END, T_SCIENCE, T_SOUP, T_JOKE), SIEGE_NOTE_24O_1/2, D26O_N_IN, SIEGE_NOTE_26O_1/2, D18B_N_01, D18B_G_01, D18B_G_END_HIT, D18B_G_END_MISS, D18B_T_END, D18B_N_END, SIEGE_NOTE_18B_1/2, D23O_N_01, D23O_I_01, D23O_I_END, D23O_T_END, D25O_N_VIGIL, D25O_H_1/2/3, D25O_T_LEB, D25O_H_WATER, D25O_H_SIT, D25O_T_END, D25O_N_END, D26_N_ENTRY, D26_T_ENTRY, D26_N_ENTRY_2, D26_F_ENTRY, D26_T_ENTRY_2, D_ARENA_N_B, D_ARENA_N_O. Öneri: dış tırnakları kaldır, iç tırnakları (`""x""`) tek `"`ye ya da ‘ ’ biçimine çevir.

## 3. [ORTA] [ses] [tüm bölümler, yere düşme]
Nihat'ın "yere düştün" replikleri arasına Hikmet'in repliği karışmış

D_DOWNED_N_2 "(Telsiz) Yerde yatmak için bilet almadık evlât!" SPK_NIHAT olarak çalınıyor (scripts/player/player.gd:775 `D_DOWNED_N_%d`; docs/voice/VOICE_MAP.csv:145 SPK_NIHAT). "evlât" Hikmet'in ağzı, "bilet almadık" da onun makinesine gönderme; Nihat Tolga'ya "siz / Tolga Bey" diye hitap eder. D_DOWNED_N_1 "Kalk Tolga! Tarih seni bekliyor" de Nihat'ın siz hitabıyla çelişiyor. Öneri: N_2'yi Nihat ağzıyla yeniden yaz (örn. "(Telsiz) Yerde yatmak yönetmelikte yok, Tolga Bey.") ya da konuşmacısını SPK_HIKMET yap; N_1'i "siz"e çevir.

