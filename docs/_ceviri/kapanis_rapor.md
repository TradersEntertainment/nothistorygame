# Çeviri taraması: kapanış raporu

Dal: `wip/ceviri-kapanis` (taban `wip/0.99.119`). Ses üretilmedi, oyun kodu değişmedi; yalnız metin ve belge dosyaları.

## 0. Sayılar

| Adım | Uygulanan | Uygulanmayan |
|---|---|---|
| 1. Çelişen 12 karar | 12 hücre (12 anahtar, hepsi TR) | 0 |
| 2. Arayüz + uzun tire | 7 hücre (6 TR + 1 EN) | 1 (`UI_CHOICE_KICK_HIKMET` en: eskisi kaldı) |
| 3. Bağlı replikler | 0 değişiklik gerekti | 58 çiftin 58'i okundu, 58'i tutuyor |
| 4. Satır içi yönergeler | 31 INLINE hücresi (22 TR + 9 EN) yeniden yazıldı | 0 |

Toplam altyazı değişikliği (tarama başından beri): **371 TR + 77 EN hücre, 419 anahtar** (448 hücre = birleştiricinin 429 hücresi + bu turun 19 hücresi; bir anahtarın iki dili ayrı hücre sayıldığı için anahtar sayısı 419). `strings.csv` ve `VOICE_MAP.csv`'de bu turun hücreleri: strings 19, VOICE_MAP 10 (kalan 9'u arayüz/tutanak, VOICE_MAP'te anahtarı yok). Yeniden seslendirme listesi: `REGEN_CEVIRI_TR.txt` 324 → 334 anahtar (+10), `REGEN_CEVIRI_EN.txt` 71 (değişmedi); 31 INLINE anahtarı kendi dillerindeki listede zaten vardı.

## 1. Çelişen 12 karar

Her çiftte iki öneriyi ve sahnedeki komşu repliği okudum; yazım kuralına göre seçtim ya da derledim.

| Anahtar | Özgün | Öneri 1 | Öneri 2 | Karar (uygulanan) |
|---|---|---|---|---|
| `D10G_T_W_3` | Sadece soruyorum. Şarap içmem, sigortacıyım. | B: Öylesine soruyorum. Şarap içmem, sigortacıyım. | E: Sormanın zararı yok. Şarap içmem, sigortacıyım. | **Öylesine soruyorum. Şarap içmem, sigortacıyım.**: B; E de yerli ama 'Şarap içmem' ile bağlanmıyor |
| `UI_CH10G_W_ASK` | 'Sadece soruyorum.' | B: 'Öylesine soruyorum.' | E: 'Sormanın zararı yok.' | **'Öylesine soruyorum.'**: D10G_T_W_3 ile aynı söz |
| `D6B_T_SILENT` | Sadece... dikkatli olun. | A: Siz... kendinize dikkat edin. | E: Şey... dikkatli olun. | **Şey... dikkatli olun.**: E; Giustiniani 'Dikkatli olmak benim mesleğim' diye sözü geri alıyor |
| `UI_CH6B_SILENT` | Sus: 'Sadece... dikkatli olun.' | A: Sus: 'Siz... kendinize dikkat edin.' | E: Sus: 'Şey... dikkatli olun.' | **Sus: 'Şey... dikkatli olun.'**: D6B_T_SILENT ile aynı söz |
| `HIKMET_ITEM_POWERBANK` | Onu kendi icadım olan şarj aletiyle doldurdum. Sadece bir kere alev aldı. | D: …Topu topu bir kere alev aldı. | E: …kendi icadım şarj aletiyle doldurdum. Bir kere alev aldı, o kadar. | **Onu kendi icadım şarj aletiyle doldurdum. Topu topu bir kere alev aldı.**: derleme: E'nin 'icadım şarj aleti'si + D'nin 'topu topu'su |
| `D4A_ITEM_LIGHTER_2` | Büyücü değil, çakmaktaşı bu. Sadece küçük ve hızlı. | A: Büyücü ne be, çakmaktaşı bu. Ufak, çabuk çakanından. | D: Ne büyücüsü be, çakmaktaşı bu. Ufağı, o kadar. | **Ne büyücüsü be, çakmaktaşı bu. Ufak ama tez çakar.**: derleme: 'Ne büyücüsü be' (D, kalıp doğru) + 'tez çakar' (A'nın çakma oyunu, sadeleşti) |
| `REACT_GUARDS_LIGHTER` | Hasan: "Büyücü!" Hüseyin: "Büyücü değil, çakmaktaşı bu. Sadece küçük ve hızlı." | A: …Büyücü ne be… | D: …Ne büyücüsü be… | **Hasan: "Büyücü!" Hüseyin: "Ne büyücüsü be, çakmaktaşı bu. Ufak ama tez çakar."**: D4A_ITEM_LIGHTER_2 ile aynı söz |
| `D6_KADRI_SELFIE` | Kepçenin sapı uzun olmuş ama kepçesi yok. Kötü kepçe. | A: …Hayırsız kepçe! | D: Sapı kulaç kulaç, kendisi yok. Bundan kepçe olmaz. | **Kepçenin sapı uzun olmuş ama kepçesi yok. Hayırsız kepçe!**: A; D 'kepçe'yi anmadan başladığı için kime dendiği belirsiz |
| `REACT_KADRI_SELFIE` | "Kepçenin sapı uzun olmuş ama kepçesi yok. Kötü kepçe." | A: …Hayırsız kepçe! | D: Sapı kulaç kulaç… | **"Kepçenin sapı uzun olmuş ama kepçesi yok. Hayırsız kepçe!"**: D6_KADRI_SELFIE ile aynı |
| `D12_F_ITEM_TAPE` | Yapışıyor, kopuyor, yine yapışıyor. Her mühendisin rüyası. Kaç tane var? | B: …Ustalarım görse bayram eder… | D: …Mühendis bundan iyisini istemez… | **Yapışıyor, kopuyor, yine yapışıyor. Ustalarım görse bayram eder. Kaç tane var?**: B; Fatih ağzında 'ustalarım' |
| `D6_KADRI_CHICKPEAS` | Nohut... ama kavrulmuş... ama kuru... ama çıtır! Bu bir devrim. Adı ne? | A: …Bu ne icat böyle!… | D: …Bu iş çığır açar… | **Nohut... ama kavrulmuş... ama kuru... ama çıtır! Bu ne icat böyle! Adı ne?**: A; aşçı ağzı |
| `REACT_KADRI_CHICKPEAS` | "Nohut... ama kavrulmuş... ama kuru... ama çıtır! Bu bir devrim. Adı ne?" Tolga: "Leblebi." Kadri: "Leb-le-bi. Sultan'ın sofrasına!" | A: …Bu ne icat böyle!… | D: …Bu iş çığır açar… | **"Nohut... ama kavrulmuş... ama kuru... ama çıtır! Bu ne icat böyle! Adı ne?" Tolga: "Leblebi." Kadri: "Leb-le-bi. Sultan'ın sofrasına!"**: D6_KADRI_CHICKPEAS ile aynı |

Not: `D10G_T_W_3`↔`UI_CH10G_W_ASK` ve `D6B_T_SILENT`↔`UI_CH6B_SILENT` çiftleri aynı sözle bitiyor; `REACT_*`↔`D6_*`/`D4A_ITEM_*` kopyaları birebir aynı.

## 2. Uygulanmayan 7 arayüz metni + 1 uzun tire

| Anahtar | Eski | Yeni | Karakter | Not |
|---|---|---|---|---|
| `UI_CH10H_G_NOTHING` (tr) | 'Hiçbir şey. Sadece uğradım.' | 'Hiç. Öylesine uğradım.' | 29 → 24 | Giustiniani 'Öylesine mi uğradın?' diyor; eskisinden kısa |
| `UI_CH10H_FRANK_3` (tr) | 'Kimse ölmesin istiyorum. Hepsi bu.' | 'Kimse ölmesin, tek dileğim bu.' | 36 → 32 | D10H_T_FRANK_3 'Tek dileğim bu.' ile aynı; eskisinden kısa |
| `UI_CH13_HE_STAYS` (tr) | 'Sen kal. Urban'ın sana ihtiyacı var.' | 'Sen kal. Urban sensiz yapamaz.' | 38 → 32 | 'sana ihtiyacı var' kalıbı gitti; eskisinden kısa |
| `UI_CH10O_Q2_D` (en) | 'I've brought the Sultan Çandarlı's secret letter.' | 'A secret letter for the Sultan, from Çandarlı.' | 51 → 48 | bozuk sözdizimi düzeldi; eskisinden kısa |
| `UI_DUEL_BLOCKED` (tr) | Muhafızda! Başka yönden vur (A/D). | Siperde! Başka yönden vur (A/D). | 34 → 32 | 'Muhafızda' (on guard harfi) yerine kılıç ağzı; eskisinden kısa |
| `UI_ARENA_RESULT` (tr) | Dayanılan dalga: %d   ·   Yere serilen: %d   ·   Savuşturma: %d   ·   Rekor: %d | Geçilen dalga: %d   ·   Yere serilen: %d   ·   Savuşturma: %d   ·   Rekor: %d | 79 → 77 | 'Dayanılan' edilgeni gitti; eskisinden kısa |
| `SIEGE_NOTE_26_3` (tr) | Şafakta Giustiniani ayakta kaldı. Son hücum püskürtüldü, şehir o sabah düşmedi. Tespit: fetih bugün değil. Tarih kendi kaydını yeniden deneyecek. — T. | Şafakta Giustiniani ayakta kaldı. Son hücum püskürtüldü, şehir o sabah düşmedi. Tespit: fetih bugün değil. Tarih rekor denemesine yeniden girişecek. — T. | 150 → 153 | imzadaki '— T.' özgün metindeki gibi korundu; yalnız son cümle |
| `UI_CHOICE_KICK_HIKMET` (en) | You kick it, Hikmet! | (eskisi kaldı) | 20 | Önerilen 'Your foot's used to it, Hikmet!' 31 karakter; 20 karakteri aşmadan 'senin ayağın alışık' göndermesi taşınamadı |

`SIEGE_NOTE_26_3`: özgün metinde de `— T.` imzası vardı (uzun tire imza biçimi); imza korundu, yalnız son cümle değişti. Karakter sayısı +3 (düz tutanak metni, düğme değil).

## 3. Bağlı replikler (58 çift)

Her çiftte iki replik sahnesinde art arda okundu (`scripts/` ve `i18n/strings.csv`). Hüküm: **tutuyor** = dokunulmadı.

| # | Çift | Hüküm | Yapılan |
|---|---|---|---|
| 1 | `BUR_AMB_G11_6_2` → `BUR_AMB_G11_6_1` | tutuyor | dokunulmadı: _2 'Üç satıra bu kadar hayat sığıyor' _1'in 'herkese üç satır' sözüne oturuyor |
| 2 | `BUR_AMB_G13_7_2` → `BUR_AMB_G13_7_1` | tutuyor | dokunulmadı: Tesla'nın 'birim' sözüne Edison'un 'şirket'i cevap; denge tamam |
| 3 | `BUR_AMB_G13_7_2` → `BUR_AMB_G13_7_4` | tutuyor | dokunulmadı: _4'teki 'Bende şirket, sende birim' geri dönüşü _2'nin 'şirket'iyle tutuyor |
| 4 | `BUR_AMB_G3_2_2` → `BUR_AMB_G3_2_1` | tutuyor | dokunulmadı: Galileo teleskobunu gösterir, Marco Polo 'biz yürüyerek giderdik' der; karşılık yerinde |
| 5 | `BUR_AMB_G3_4_3` → `BUR_AMB_G3_4_2` | tutuyor | dokunulmadı: 'Şimdi herkes cüzdanında taşıyor' → 'Hâlâ da kimse değerine inanmıyor': 'hâlâ da' bağı sağlam |
| 6 | `BUR_AMB_G3_5_2` → `BUR_AMB_G3_5_1` | tutuyor | dokunulmadı: Marco Polo'nun 'dediğim söylenir' kalıbını Galileo 'Benim de…' ile sürdürüyor |
| 7 | `BUR_AMB_G3_7_2` → `BUR_AMB_G3_7_1` | tutuyor | dokunulmadı: 'Söylenir, ha?' Galileo'nun 'söylenir'ine bire bir cevap |
| 8 | `BUR_AMB_G4_2_3` → `BUR_AMB_G4_2_2` | tutuyor | dokunulmadı: Mozart'ın son gece uvertürüne Curie'nin 'teslim tarihleri ders almamış' iğnesi oturuyor |
| 9 | `BUR_AMB_G5_1_2` → `BUR_AMB_G5_1_1` | tutuyor | dokunulmadı: Sinan 'hiçbir şey boşa gitmedi' diyor, Nasreddin 'burada da öyle, beklemek evraka dönüşüyor' |
| 10 | `BUR_AMB_G6_5_3` → `BUR_AMB_G6_5_4` | tutuyor | dokunulmadı: 'indi' sorusu ve 'tek satır, iki ayrı iniş' cevabı tutuyor |
| 11 | `BUR_AMB_G7_1_2` → `BUR_AMB_G7_1_1` | tutuyor | dokunulmadı: Sezar 'oyunun adı benim' → Shakespeare 'afişe adın lazımdı' |
| 12 | `BUR_AMB_G7_7_3` → `BUR_AMB_G7_7_2` | tutuyor | dokunulmadı: Fidyeyi yükseltme sorusu ile 'ucuza gitmek gururuma dokundu' cevabı tutuyor |
| 13 | `BUR_AMB_G7_7_3` → `BUR_AMB_G7_7_4` | tutuyor | dokunulmadı: Necmi'nin 'bizde fiyat indirimli, alan yok' esprisi 'ucuz' temasına bağlı; tutuyor |
| 14 | `BUR_AMB_G7_9_1` → `BUR_AMB_G7_9_2` | tutuyor | dokunulmadı: Falcı uyarısı ve 'takvime kırmızı daire' tutuyor |
| 15 | `BUR_APPLETREE_2` → `BUR_FG_NEW_1` | tutuyor | dokunulmadı: Newton'un 'elma kafama düşmedi'si ile Nihat'ın 'efsane/rivayet' sözü aynı yönde |
| 16 | `D12_F_WHO_A` → `D12_F_CANNON_D` | tutuyor | dokunulmadı: Fatih'in 'olmadan önce / olduktan sonra' ikilisi paralel kalıyor |
| 17 | `D12_K_01` → `D12_T_K_02` | tutuyor | dokunulmadı: Kadri'nin 'soğan mı, akıl mı' sorusuna Tolga'nın 'soğan daha kolay'ı oturuyor |
| 18 | `D14_N_W2_ARREST` → `D14_N_W2` | tutuyor | dokunulmadı: ARREST varyantı 'Tolga Bey', ana replik 'Bay Tolga': Nihat'ta iki hitap de var (25 'Bay', 155 'Bey'), farklı yollar, aynı sahnede yan yana duyulmuyor; dokunulmadı |
| 19 | `D15_O_DOCS` → `D15_O_DOCS_2` | tutuyor | dokunulmadı: Müdürün 'Güzel. Sunuma koy.' cevabı 'ikisinden biri, kesin'e oturuyor |
| 20 | `D17E_R_KEB` → `D17E_R_KEB_BACK` | tutuyor | dokunulmadı: 'verir' → 'verdi! Bir de soğan!' dönüşü tutuyor |
| 21 | `D17E_V_KEB` → `D17E_R_KEB_2` | tutuyor | dokunulmadı: Vlad'ın 'Güzelmiş' demesi ile Radu'nun 'Abim gülümsedi' sevinci tutuyor |
| 22 | `D17E_V_POL_3` → `D17E_T_WHAT_POLICY` | tutuyor | dokunulmadı: 'Kazık' sözü ve Tolga'nın 'kazığı sevdi' özeti tutuyor |
| 23 | `D17E_V_POL_3` → `D17E_V_POL_2` | tutuyor | dokunulmadı: V_POL_2 'Kazık.' → V_POL_3 'Kazık. Beğendim. Ben de herkese kazık atacağım' (kazık atmak = kazıklamak, ikili anlam) çalışıyor |
| 24 | `D17_TR_02` → `D17_T_02` | tutuyor | dokunulmadı: 'Hem sen niye ters oturuyorsun?' → Tolga'nın 'yolu görmem lazım' cevabı tutuyor |
| 25 | `D19O_T_WISH` → `D19O_C_WISH` | tutuyor | dokunulmadı: 'Rüzgârınız bol olsun' → kaptanın 'Size de' cevabı tutuyor |
| 26 | `D1_H_21` → `D1_T_20` | tutuyor | dokunulmadı: Tolga 'az önce acil dönüş demedin mi' diyor, Hikmet 'bunda anlamayacak ne var' diye karşılıyor; sorunun yerine oturuyor |
| 27 | `D22O_T_FIRE` → `D22O_H_02` | tutuyor | dokunulmadı: Hasan 'ıslak deri yanmaz' demişti; Tolga'nın 'ıslak deri mi demiştin' sözü tutuyor |
| 28 | `D22_G_04` → `D22_G_SINGED` | tutuyor | dokunulmadı: 'kaşlarından olursun' ve 'Kaş çıkar. Kule çıkmaz.' tutuyor |
| 29 | `D22_G_04` → `D22_T_SINGED` | tutuyor | dokunulmadı: 'kaşlarından olursun' ve Tolga'nın 'Kaşlarım!' tepkisi tutuyor |
| 30 | `D23_I_KNOWN` → `D23_I_LETTER` | tutuyor | dokunulmadı: 'iki tarafın da dili sensin' ve 'yine senin dilinden geçmesi' aynı dil sözü üzerinden dönüyor |
| 31 | `D24O_D_REST` → `D24O_D_ALL` | tutuyor | dokunulmadı: İki ayrı dal (kalan ateşler / üç ateş); ikisi de 'söz–çorba' benzetmesini kendi başına taşıyor |
| 32 | `D25O_H_WATER` → `D32O_H_WATER` | tutuyor | dokunulmadı: D25 ve D32 aynı espri; yalnız bir virgül farkı (sesi etkilemiyor), dokunulmadı (seslendirilmiş satırı boşuna yeniden üretmemek için) |
| 33 | `D26_T_INSURER` → `D26_MG_INSURER` | tutuyor | dokunulmadı: 'Tam pert, ama belgeli' → 'Belgeli mi? Aferin.' tutuyor |
| 34 | `D27_I_THANKS` → `D27_T_I_THANKS` | tutuyor | dokunulmadı: 'Bir de şapka borcum var' → Tolga'nın 'Şapkayı unutun' cevabı tutuyor |
| 35 | `D27_T_NT_STAY` → `D27_NT_STAY` | tutuyor | dokunulmadı: 'defter yarım kalmasın' → Noter'in 'yeni bir defter açarım' cevabı tutuyor |
| 36 | `D28O_T_END` → `D28O_N_END` | tutuyor | dokunulmadı: 'Kulaklarım şimdiden gitti' → Nihat'ın 'kulaklarınız için formda kutucuk yok' tutuyor |
| 37 | `D29O_T_FELL` → `D29O_N_FELL` | tutuyor | dokunulmadı: 'kova, taş, güverte; sırasıyla' → Nihat'ın 'bordadan reddedilme' tutanağı tutuyor |
| 38 | `D29_T_END` → `D29_C_END_HURT` | tutuyor | dokunulmadı: Tolga 'ben bile inanmıyorum', Cattaneo 'Cenova'da kimse inanmaz': birbirini tamamlıyor |
| 39 | `D35O_T_SLOPE` → `D35O_U_SLOPE` | tutuyor | dokunulmadı: Urban'ın 'çok gevşetirsen / çok sıkarsan' sözü ve Tolga'nın 'orta yol' dertlenmesi tutuyor |
| 40 | `D37O_U_03` → `D37O_T_U2` | tutuyor | dokunulmadı: 'Güllelerim ne açmış?' → 'Bir gedik açmışlar' tutuyor |
| 41 | `D41O_H_PARRY_2` → `D41O_H_PARRY_EARLY` | tutuyor | dokunulmadı: 'Ne erken, ne geç' ile 'Erken!' uyarısı artık bire bir aynı sözcükleri taşıyor (eskiden 'önce/sonra'ydı); iyileşti |
| 42 | `D41O_H_PARRY_2` → `D41O_H_PARRY_LATE` | tutuyor | dokunulmadı: 'Ne erken, ne geç' ile 'Geç!' uyarısı tutuyor |
| 43 | `D42B_T_END` → `D42B_T_SPAR_LOSE` | tutuyor | dokunulmadı: 'demir gibi vuruyor' → 'hasar raporu demirinki kadar uzun': demir bağı sağlam |
| 44 | `D4A_ITEM_LIGHTER_2` → `D4A_ITEM_LIGHTER_1` | tutuyor | dokunulmadı: 1. adımda birlikte yazıldı: Hasan 'Büyücü!' → Hüseyin 'Ne büyücüsü be…' |
| 45 | `D4A_ITEM_TAPE_1` → `D4A_ITEM_TAPE_2` | tutuyor | dokunulmadı: 'Bununla ne bağlanır?' → 'Her şey.' |
| 46 | `D4B_N_THROW_SHIELD` → `D4B_T_HIT_2_SHIELD` | tutuyor | dokunulmadı: Niko 'Hektor'un' diyor, Tolga 'Hektor kim?!' diye soruyor: ad geri dönüyor |
| 47 | `D6A_M_KAFTAN` → `D6A_M_JOBS` | tutuyor | dokunulmadı: Keçi, yüzük ve kaftan üçlüsü iki replikte de aynı |
| 48 | `D6A_S_LETTER` → `D6A_S_LETTER_R1` | tutuyor | dokunulmadı: Mektup yazdırma isteği ve 'Top çok gürültülü… Annem bilsin' cevap kolları tutuyor |
| 49 | `D6B_T_SILENT` → `D6B_G_SILENT` | tutuyor | dokunulmadı: 1. adımda birlikte yazıldı: 'Şey… dikkatli olun.' → 'Dikkatli olmak benim mesleğim' |
| 50 | `D6_KADRI_CHICKPEAS` → `D6_KADRI_CHICKPEAS_2` | tutuyor | dokunulmadı: 1. adımda yazıldı: 'Bu ne icat böyle! Adı ne?' → 'Leb-le-bi. Sultan'ın sofrasına!' |
| 51 | `D6_KADRI_CHICKPEAS` → `D6_KADRI_CHICKPEAS_T` | tutuyor | dokunulmadı: 'Adı ne?' → Tolga'nın 'Leblebi.' cevabı tutuyor |
| 52 | `D6_URBAN_POWERBANK_T` → `D6_URBAN_POWERBANK` | tutuyor | dokunulmadı: Urban 'topun içine koysak ne olur?', Tolga 'Lütfen koymayalım' (betikte _T = Tolga'nın cevabı) |
| 53 | `D7_NIKO_HELLO` → `D7_N_NIKO_ASK` | tutuyor | dokunulmadı: Niko'nun 'fes değil' sözü, Nihat'ın 'fesli bir şahıs… casus diyordunuz' cevabına oturuyor |
| 54 | `D8_H_FAIL_LATE` → `D8_C_LATE` | tutuyor | dokunulmadı: 'Servis saati' ile Cemil'in 'servisin geliyor' sözü tutuyor |
| 55 | `D9_T_LUTFI_Q` → `D9_LUTFI_OFFER_2` | tutuyor | dokunulmadı: Tolga'nın 'bunun benimle ne alakası var?' sorusuna Lütfü'nün teklifi cevap |
| 56 | `D_DOWNED_N_3` → `D_DOWNED_N_1` | tutuyor | dokunulmadı: Nihat'ın üç 'Kalkın' kolu aynı hitapta ('Kalkın… Kalkın da sileyim') |
| 57 | `D_DOWNED_N_3` → `D_DOWNED_N_2` | tutuyor | dokunulmadı: 'Yerde yatmak yönetmelikte yok' ve 'Kalkın da sileyim': aynı kayıt şakası |
| 58 | `UI_B38O_ROW` → `UI_B38O_ROW_T` | tutuyor | dokunulmadı: Gece baskınının açıklaması ile başlık satırı aynı görevi anlatıyor |

Kopan çift yok; iki not: #18 (Bay/Bey hitabı iki dalda farklı) ve #32 (bir virgül farkı) sahibine gösterilmek üzere not edildi, sesli satırı boşuna yeniden ürettirmemek için değiştirilmedi.

## 4. Satır içi yönergeler (`docs/voice/INLINE.json`)

Sözcükler yeni altyazıyla birebir aynı; yönergeler eski duygu akışını yeni cümlenin uygun yerine taşıyor. `tests/check_inline.py` önce FAIL (31), şimdi **PASS (723 anahtar, 0 sorun)**.

| Anahtar | Dil | Eski INLINE | Yeni INLINE |
|---|---|---|---|
| `D2_H_WARRANTY_END` | tr | [sighs] Garanti bitti. [firm] [urgent] Artık sadece koş. | [sighs] Garanti bitti. [firm] [urgent] Koş artık, koş! |
| `D2_H_AFTER_WARRANTY` | tr | [flustered] Garanti bitti. [determined] Ben bir şey yapacağım, bekle. | [flustered] Garanti bitti. [determined] Ben bir çaresine bakacağım, bekle. |
| `D2_H_RADIO_YES` | tr | [relieved] [exhales] Oh be. [warm] Sesini duymak güzel. [urgent] Şimdi koş. | [relieved] [exhales] Oh be, [warm] sesin geliyor ya. [urgent] Şimdi koş. |
| `D2_T_FALL` | en | [nervous] [out of breath] The slope is ending... [terrified] [shouting] The slope has ended! | [nervous] [out of breath] Running out of hill... [terrified] [shouting] Out of hill! |
| `D2_H_09` | tr | [calm] [thinking] Yakında kıyı var [worried] ama askerler de var. [squinting] Uzakta bir zincir görüyorum... [pause] [sheepish] Yani sen görüyorsun. | [calm] [thinking] Yakınlarda kıyı var [worried] ama askerler de var. [squinting] Uzakta bir zincir görüyorum... [pause] [sheepish] Yani sen görüyorsun. |
| `D2_T_ARROW_3` | tr | [nervous laugh] Uyarı atışı herhalde. [shaky] [sarcastic] Çok başarılı bir uyarı. | [nervous laugh] Uyarı atışı herhalde. [shaky] [sarcastic] Uyarıyı aldık, sağ olun. |
| `D3_H_RESIST` | tr | [nervous] [hurried] O tavuk bizim değil! [pause] ...O ok da bizim değil. [innocent] Ben hiçbir şeyi tanımıyorum. | [nervous] [hurried] O tavuk bizim değil! [pause] ...O ok da bizim değil. [innocent] Ben hiçbirini tanımam! |
| `D1P_T_01` | en | [sleepy] [groggy] Mmh... Hello? [alarmed] [half awake] Who died? | [sleepy] [groggy] Mmh... Hello? [grumbling] At this hour? [alarmed] [half awake] Who died? |
| `D1_H_06` | tr | [serious] Makinenin tek bir arızası var evlât: [baffled] çalışıyor. Açıkçası ben de beklemiyordum. | [serious] Makinenin tek bir arızası var evlât: [baffled] çalışıyor. Valla ben de şaştım kaldım. |
| `D1_T_05` | tr | [skeptical] Dur dur dur. Şaka yapıyorsun, değil mi? [whispers] Bu gerçekten çalışıyor mu? | [skeptical] Dur dur dur. Dalga mı geçiyorsun? [whispers] Bu alet cidden çalışıyor mu? |
| `D1_H_21` | tr | [as if it's obvious] Acil olursa bas, acil değilse basma. Bu kadar basit evlât. | [as if it's obvious] Acil olursa bas, acil değilse basma. Bunda anlamayacak ne var evlât? |
| `D17E_G_01` | en | [stern] Mehmed. Sit. [dry] The guest too; [wise] knowledge taken standing stays standing. | [stern] Mehmed. Sit. [dry] The guest too; [wise] learning taken standing up never settles in. |
| `D17E_M_TO_AVLU` | tr | [eager] Gel, seni arkadaşlarımla tanıştıracağım. Biri çok ilginçtir. | [eager] Gel, seni arkadaşlarımla tanıştıracağım. Biri pek acayiptir. |
| `D17E_R_KEB` | en | [eager] I'll get lamb from the kitchen. [grinning] The head cook grumbles, but he gives. | [eager] I'll get lamb from the kitchen. [grinning] The head cook grumbles, but he hands it over. |
| `D17E_R_LEG_0` | en | [scared] [squeaky] Brother! There's a bat on the wall! | [scared] [squeaky] Vlad! There's a bat on the wall! |
| `D17E_T_BRUTUS_2` | tr | [whispers] [horrified] Bunu söylememeliydim. [panicked] Bunu kesinlikle söylememeliydim. | [whispers] [horrified] Bunu söylememeliydim. [panicked] Hiç ama hiç söylememeliydim. |
| `D17E_T_NONE_2` | tr | [nervous] Hayır. [forced compliment] Güzel… sopa. | [nervous] Yok. [forced compliment] Sopan… güzelmiş. |
| `D17E_V_02` | tr | [bitter] [flat] Babam bizi burada bıraktı. Şimdi duyduk ki Haçlılarla birlik oluyormuş. [darkly] Sultan bizi keser mi, merak ediyorum. | [bitter] [flat] Babam bizi burada bıraktı. Şimdi duyduk ki Haçlılarla birlik oluyormuş. [darkly] Sultan bizi kestirir mi acaba? |
| `D17E_V_KEB` | tr | [chewing] [surprised] [reluctantly] …Bu iyi. | [chewing] [surprised] [reluctantly] …Güzelmiş. |
| `D17E_V_POL_3` | en | [deadpan] A stake. Through the purse. [slow smile] I like it. [darkly amused] I'll stake everyone. | [deadpan] A stake. [slow smile] I like it. [darkly amused] I'll give everyone a stake. |
| `D26O_AB_LADDER_BAD` | en | [weary] [bitter] Clerk... On 18 April that stockade didn't give us a scratch. This is what's left of my company. [warning] Keep your head down; stones are coming. | [weary] [bitter] Clerk... On 18 April we didn't so much as scratch that stockade. This is what's left of my company. [warning] Keep your head down; stones are coming. |
| `D38O_R_01_TOLD` | en | [urgent] [remorseful] Clerk! The eyes before the chain! That night you said "their turbans are wound wrong"; I didn't listen, and we missed them by an oar's length. [earnest] Tonight, whatever you see, tell me. I'll listen. | [urgent] [remorseful] Clerk! Our eye at the chain! That night you said "their turbans are wound wrong"; I didn't listen, and we missed them by an oar's length. [earnest] Tonight, whatever you see, tell me. I'll listen. |
| `D10O_T_THROWN_2_HUFEZ` | en | [groaning] My second carrying. [wry] The one in the fez is Hüseyin. I'd know my own fez anywhere. | [groaning] Eviction number two. [wry] The one in the fez is Hüseyin. I'd know my own fez anywhere. |
| `D_CLIMB_FALL_2` | tr | [groaning] [wry] Yerçekimi bugün çok mesai yapıyor. | [groaning] [wry] Yerçekimi bugün fazla mesai yapıyor. |
| `D_CLIMB_TIRED_3` | tr | [straining] [whining] Kollarım kalem tutmak için yapılmış, duvar için değil. | [straining] [whining] Benim kollarım kalem tutar, duvar tutmaz ki. |
| `D_LM_ZINCIR` | tr | [thoughtful] Haliç'in zinciri. Kütüklerin üstünde demir halkalar. [grave] Yakında gemiler karadan yürüyecek; zincir buna hazır değil. [quietly] Kimse değil. | [thoughtful] Haliç'in zinciri. Kütüklerin üstünde demir halkalar. [grave] Yakında gemiler karadan yürüyecek; zincir buna hazır değil. [quietly] Hazır olan da yok. |
| `D_PERCH_AYA` | tr | [awed] [softly] Kubbenin tepesindeyim. Dokuz yüz yıllık kurşun, altımda ılık. [whispers] Bir dakika... sadece bakıyorum. | [awed] [softly] Kubbenin tepesindeyim. Dokuz yüz yıllık kurşun, altımda ılık. [whispers] Bir dakika... öylece bakıyorum. |
| `D_WIT_2` | tr | [awed] [confused] Melek mi o? Neden şapkası var? | [awed] [confused] Melek mi o? Meleğin şapkası mı olur? |
| `D_WIT_8` | tr | [nervous] [whispers] Kimse bir şey demesin. Sadece yüzüne bakmayın. | [nervous] [whispers] Kimse bir şey demesin. Sakın yüzüne bakmayın. |
| `D_WIT_9` | tr | [stammering] O... o bir kuş değil. [baffled] Kuşlar kravat takmaz. | [stammering] O... o kuş değil. [baffled] Kuş kravat takar mı hiç? |
| `REACT_CROWD_BYZ_COLOGNE` | tr | [sniffs] [nostalgic] Limon kokusu! Rahmetli karım gibi kokuyorsun. [warmly] İyi bir şey bu, merak etme. | [sniffs] [nostalgic] Limon kokusu! Rahmetli karım gibi kokuyorsun. [warmly] İyi anlamda söylüyorum. |

## 5. Testler

```
=== python3 tests/check_consequences.py   bayrak: 201 ... sorun: 0
=== python3 tests/check_export_refs.py    EXPORTREFS PASS
=== python3 tests/check_inline.py         INLINECHECK PASS (723 anahtar, 0 sorun)   [önce FAIL, 31 sorun]
=== python3 tests/check_keys.py           anahtar: 6810 sorun: 0
=== python3 tests/check_outcomes.py       kuşatma sonucu: 74  okunan: 74  okunmayan: 0 ...
=== python3 tests/check_speakers.py       SPEAKERCHECK PASS
=== python3 tests/check_tween_await.py    (çıktı yok = sorun yok)
=== python3 tests/check_voice_rules.py    VOICERULES PASS (9665 anahtar, 0 sorun)
parse_check                               PARSECHECK PASS scripts=248
```

Başsız autotest (`--headless --max-fps 20 -- --chapter=N --autotest`, varsayılan yol, birer kez): bölümler **1, 2, 3, 4, 6, 9, 10, 10g, 10h, 11, 12, 13, 17, 23, 26** (15 bölüm): **15/15 `AUTOTEST PASS`, çıkış kodu 0**. Yasak satırlar (SCRIPT ERROR, WARN_FX_STUCK, WARN_FLY_ITEM, VISAUDIT, WARN_VOID_TELEPORT, WALKTHRU, ARMAUDIT, HELDAUDIT, LOOKAUDIT backturn, JOURNEY_MISS, JOURNEY_OVERLAP) ve altyazı taşması/uzunluk uyarısı: **sıfır** (15 günlükte de tarandı).

Sınırlar: bu başsız koşular altyazı kutusunu piksel olarak ölçmez (ekranlı koşu yapılmadı, KANITSIZ); arayüz metinlerinde taşma riski karakter sayısının eskisinden uzun olmamasıyla güvenceye alındı (bkz. 2. bölüm).

## 6. Derlenmiş çeviri dosyaları ve kayıtlar

- `i18n/strings.tr.translation` ve `strings.en.translation`, `strings.csv` değiştikten sonra Godot içe aktarmasıyla yenilendi (birleştiricinin `ef5bdc85` kaydındaki yöntem); `.import` ve `.uid` dosyaları kaydedilmedi.
- `docs/voice/REGEN_CEVIRI_TR.txt`: +10 anahtar (334), yinelenme yok, sıralı. `REGEN_CEVIRI_EN.txt`: değişmedi (71).
- `docs/_ceviri/once_sonra.md`: en üste yarım sayfalık özet ve en iyi 25 örnek eklendi, kapanış turunun tam listesi ve çözülen kararların işareti eklendi.
- Ses üretilmedi.
