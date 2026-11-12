# Çeviri ikinci okuma ve denetim · Grup D (dilim 7 ve 8)

Kaynak: ilk tur `wip/ceviri-7` (`dilim_7.csv`, 53 öneri) ve `wip/ceviri-8` (`dilim_8.csv`, 43 öneri).
Teslim: `docs/_ceviri/onay_D.csv` (uygulanacak son liste: `kabul` + `duzelt`), `docs/_ceviri/kapsam_D.csv`.
Oyun dosyalarına (strings.csv, VOICE_MAP.csv, INLINE.json, betikler, sesler) dokunulmadı.

## Sayılar

| | satır |
|---|---|
| İlk turun önerisi | 96 (dilim 7: 53, dilim 8: 43) |
| `kabul` | 86 |
| `duzelt` | 8 |
| `ret` | 2 |
| İkinci okumada yeni öneri (grup içi) | 12 satır: dilim 7'de 7, dilim 8'de 5 (4 anahtar, biri TR+EN) |
| Eşlenik eklemesi (başka dilimdeki aynı metin) | 8 |
| **Oyuna girecek satır (`kabul` + `duzelt`)** | **114** |

**Okunan satır:** 1494 anahtarın hepsi (dilim 7: 806, dilim 8: 688). `kapsam_D.csv` 2988 satır = 1494 × 2 (bu
gruplarda boş İngilizce yok). Hüküm dağılımı: `iyi` 2863, `oneri` 106, `supheli` 19.
Okuma 50'lik öbeklerle yapıldı; `BUR_AMB_*` diyalogları sırasıyla, `BUR_FG_*` tekil ve V2/V3 ziyaretleriyle, `REACT_*`
karakter bazında, `MG_*` mini oyun betiğiyle (`minigame_haggle.gd`) karşılaştırılarak okundu.

## A. İlk turun denetimi

### Ret (2)
- `QUEST_ENGINEER_DONE` "Hikmet Amca gurur duyardı. Duyuyordur." → önerilen "göğsü kabarırdı. Kabarıyordur."
  Eskisi gündelik Türkçe, kendini düzeltme şakası zaten çalışıyor; yenisinin ikinci cümlesi tuhaf (göğüs uzaktan
  kabarmaz). Not: aynı cümle `D4A_T_WIN_TAPE`'te de var; ikisi de kalıyor.
- `QUEST_CHICKENS_T` "Tavuk Fısıldayan" → önerilen "Kümes Avcısı". "X Fısıldayan" Türkçede yerleşmiş bir kalıp; kural 3
  replik uyarlaması için. Aynı ad `ACH_CHICKEN_WHISPERER_T`'de başarım adı, tek başına değişirse ikisi ayrışır.
  "Avcı" da tilki çağrıştırıyor. Sahibine soruldu (aşağıda).

### Düzelt (8)
| Anahtar | İlk tur | Son metin | Neden |
|---|---|---|---|
| `BUR_COOLER_2` | Kayıp saniyeler de böyle bulunsaydı Büro ihya olurdu. | Her baloncuk bir kayıp saniye olsa Büro çoktan ihya olurdu. | Baloncuk benzetmesi kayboluyordu |
| `BUR_FG_NEW_3` | Büyük Para Yenilemesi | Büyük Sikke Yenilemesi | Recoinage madenî para; Darphane ile bağ |
| `BUR_FG_CLE_V2_1` | …düpedüz yılan hikâyesi. | O yılandan tarihçiler bile emin değil. | "Yılan hikâyesi" = bitmeyen iş, "uydurma" değil |
| `BUR_FG_NAS_V2_2` (EN) | …you can come from 1453… | …If a pot can give birth, why not?… | Sesli satıra yeni sayı ekliyordu; uzunluk %140 idi |
| `BUR_DOOR_1815_1` | Beklemeyi öğrendiği gün yanlış gündü. | Beklemeyi öğrenmişti, ama yanlış günde. | Anlam kayıyordu |
| `REACT_PASHA_CHICKPEAS` | Kadri tuzu bol koyar. | Kadri'nin tuzu hep ağır kaçar. | "Diplomasi de öyle" bağı "ağır kaçmak"la kuruluyor |
| `DST_CHILDB_IDLE_4` | Hangisi olursa, ben hepsini severim. | Hangisi olursa olsun, ben hepsini severim. | Kalıp yarım kalıyordu |
| `DST_PRIEST_AGAIN` | sabır güzeldir derler | sabır iyidir, bilirim. Ama… | "Sabır güzeldir" (sabr-ı cemîl) Rum papazın ağzına İslami söz |

### Kabul (86)
Geri kalanların hepsi komşu repliklerle okundu; işlev, bağlı replik ve uzunluk tutuyor. Özellikle doğrulananlar:
`MG_HAG_WINE_FAIR` yön hatası gerçek (`minigame_haggle.gd`: FAIR = oyuncunun makul teklifi, satıcı ardından iner;
satıcının "in" demesi ters). `BUR_FG_GAG_1` ("sıra atlamak" = kaynak yapmak), `BUR_FG_POL_2` ("Efsane!" = harika),
`REACT_CALLIGRAPHER_SELFIE` ("elimi çek" ters anlam), `REACT_KID_POWERBANK` (mermer/misket) gerçek anlam hataları.
Uzunluk: hepsi %70–130 içinde (`BUR_AMB_G16_4_3` tam %130).

## B. İkinci okumada yeni öneriler

**Dilim 7 (7):** `QUEST_THERMOS_DONE` (asla bilmeyecek), `BUR_CCLOCK0` (düşmek/falls oyunu), `BUR_CCLOCK3` (never
o'clock), `BUR_DOOR_1789_1` (…için küçük bir dosya), `BUR_AMB_G7_4_1` (dağılmış "Suetonius bazılarına göre" dizimi),
`BUR_AMB_G7_9_1` ("Mart'ın İdleri" → "Mart'ın on beşi", oyunun kendi kullanımıyla uyumlu), `BUR_AMB_G12_5_2` (bozuk dizim).
**Dilim 8 (5 satır):** `REACT_HIKMET_PHONE` (adil yani / fair's fair), `REACT_KADRI_CHICKPEAS` ("Bu bir devrim": İngilizce
kalıp ve 1453 aşçısında anakronik sözcük), `REACT_WINE_CUBE` ("Tıpkı X." kapanışı, `REACT_CLERK_CUBE` düzeltmesiyle
tutarlılık), `MG_HAG_NIKO_FAIR` TR+EN (Wine'daki yön hatasının aynısı).

## Varyant ve alıntı eşlemeleri

`_NOFEZ/_HEN/_ALT/_B/_PLAIN/_WET` türü varyant bu dilimlerde yok; `UI_CH…` seçeneklerinde bu repliklerden alıntı yok
(her değişen satırın her cümlesi `strings.csv`'nin tamamında arandı). Aynı metni taşıyan başka anahtarlar bulundu ve
`kaynak=ikinci` satırı olarak eklendi:

| Değişen | Eşleniği (başka dilim) |
|---|---|
| `REACT_GUARDS_LIGHTER` (Hüseyin'in cümlesi) | `D4A_ITEM_LIGHTER_2` |
| `REACT_KADRI_TAPE` | `D6_KADRI_TAPE` |
| `REACT_KADRI_SELFIE` | `D6_KADRI_SELFIE` |
| `REACT_KADRI_CHICKPEAS` (ilk cümle) | `D6_KADRI_CHICKPEAS` |
| `REACT_FATIH_TAPE` | `D12_F_ITEM_TAPE` |
| `REACT_HIKMET_CUBE` (EN) | `HIKMET_ITEM_CUBE` (EN; TR'si farklı ve iyi) |
| `REACT_HIKMET_POWERBANK` | `HIKMET_ITEM_POWERBANK` ("sadece bir kere alev aldı") |
| `REACT_HIKMET_PHONE` | `HIKMET_ITEM_PHONE` ("Yani adil.") |

Ortak parçası olup değişmeyenler: `QUEST_ENGINEER_DONE` ↔ `D4A_T_WIN_TAPE` (ret, ikisi de kalıyor);
`BUR_AMB_G7_4_1`'in ilk cümlesi ↔ `BUR_FG_CAE_3` (değişen kısım ortak değil); `QUEST_CHICKENS_T` ↔
`ACH_CHICKEN_WHISPERER_T` (ret).

## Metne bakan testler ve entegrasyon tuzakları

- **`tests/check_inline.py`**: `docs/voice/INLINE.json`'daki metni altyazıyla karşılaştırır. `REACT_CROWD_BYZ_COLOGNE`
  INLINE.json'da (ve `.inline_done_tr.json`'da) eski metinle duruyor. Uygulanırken INLINE TR şöyle güncellenmeli:
  `[sniffs] [nostalgic] Limon kokusu! Rahmetli karım gibi kokuyorsun. [warmly] İyi anlamda söylüyorum.` Yoksa test
  düşer ve `voice_gen.py` eski cümleyi okur (CLAUDE.md'deki INLINE tuzağı). Bu gruptaki başka değişen anahtar
  INLINE.json'da yok.
- **`docs/voice/VOICE_MAP.csv`** her anahtarın `tr`/`en` metnini de taşıyor; uygulama sırasında değişen 114 satırın
  metni orada da güncellenmeli (betik `strings.csv`'den yeniden üretiyorsa o yeterli).
- `tests/check_voice_rules.py` (Hristiyan karaktere İslami söz, "bre", seçenek uzunluğu): yeni metinlerde ihlal yok;
  `DST_PRIEST_AGAIN` düzeltmesi bu kuralın ruhuna da uyuyor.
- Anahtar adıyla metne bakan başka test yok (`grep` ile `tests/` tarandı). Yeni metinlere rakam, kısaltma, parantez
  notu eklenmedi (`REACT_HIKMET_PHONE`'daki "%14" eskiden vardı).
- `MG_HAG_NIKO_FAIR`: Niko replikleri `wip/niko-yeniden`'de baştan yazılıyor. O yazım girerse bu satırın yerini alır;
  ama yeni metin de "çık / go up" yönünü taşımalı.

## Sahibine sorulacaklar
1. `QUEST_CHICKENS_T` + `ACH_CHICKEN_WHISPERER_T` "Tavuk Fısıldayan": kalsın mı (önerim kalsın), değişecekse ikisi birlikte mi?
2. `BUR_TUBE` + `D3_N_02` "Fwump": Türkçede "Pof." / "'Pof' hayra alamet değildir" olsun mu? İkisi birlikte değişmeli.
3. Marco Polo'da "Genova" (`BUR_AMB_G3_3_1`) ve "Cenova" (`BUR_FG_POL_V3_1`): "Cenova"da birleşsin mi?
4. `REACT_EMPEROR_CUBE` "Şu an bulmacaya ihtiyacım yok." kanon alıntısı; EN gibi "Benim bulmacam zaten yeterince var." olsun mu?
5. `BUR_AMB_G7_4_2` Shakespeare "Latincesi daha vurucuydu" diyor ama Türkçe altyazıda Sezar Latince sözü söylemiyor ("Sen de mi Brütüs"); `BUR_AMB_G7_4_1`'e "Et tu, Brute" mu eklensin, yoksa olduğu gibi mi kalsın?
6. `REACT_FISHMONGER_BOOK` "Kitap mı bu, çarşı mı?" iki dilde de mantıksız (çeviri değil, yazım sorunu). Yeniden yazılsın mı?
7. `REACT_KADRI_REPLAY_4` "Seni üç kere unutmadım": bilinçli tekrar şakası mı?
8. `REACT_THEODOROS_POWERBANK` "kâğıt ağırlığı": "prespapye" mi denmeli, yoksa arşivcinin düz dili olarak mı kalsın?
9. Nihat'ın kapı panolarındaki kuru kapanışlar ("Net bir plan.", "Hızlı bir itiraz.", "Bu bir sorun değil, bir aşama."): bilinçli tutanak üslubu sayılıp kalsın mı?

## En iyi on (önce | sonra)
1. `MG_HAG_WINE_FAIR` / `MG_HAG_NIKO_FAIR`: "…Biraz daha **in**." | "…Biraz daha **çık**." (yön hatası, iki satıcıda)
2. `BUR_FG_GAG_1`: "…108 dakikada bir **sıra bile atlamadım**." | "…bir **adım bile ilerlemedim**."
3. `REACT_CALLIGRAPHER_SELFIE`: "Resim yasak değil ama **elimi çek**." | "…ama **elimi dürtme**."
4. `BUR_AMB_G7_9_1`: "Oyunda falcı '**Mart'ın İdleri'ne dikkat et**' diyor." | "Oyunda falcı '**Mart'ın on beşinden sakın**' diyor."
5. `BUR_CCLOCK0`: "Gölge hiç **düşmüyor** ama mesai **düşüyor**." | "Gölgesi hiç **uzamıyor** ama mesai **uzadıkça uzuyor**."
6. `BUR_FG_NAS_V3_1`: "…Tutmadı. Tıpkı şu sıranın ilerlemesi gibi." | "Göle maya çaldım, **ya tutarsa** dedim. Tutmadı. Bu sırayı da **ya ilerlerse** diye bekliyorum."
7. `REACT_PASHA_CHICKPEAS`: "Kadri tuzu ağır koyar. Diplomasi de öyle." | "Kadri'nin tuzu hep **ağır kaçar**. Diplomasi de öyle."
8. `REACT_KADRI_CHICKPEAS` + `D6_KADRI_CHICKPEAS`: "…ama çıtır! **Bu bir devrim.** Adı ne?" | "…ama çıtır! **Bu iş çığır açar.** Adı ne?"
9. `BUR_AMB_G16_4_3` (Sabri): "Bekleyen kazanır." | "**Sabreden derviş muradına erer.**"
10. `BUR_FG_CLE_V2_1`: "…Tarihçiler bile emin değil." | "…**O yılandan** tarihçiler bile emin değil." (ilk turun "yılan hikâyesi" deyim hatası düzeltildi)

## Şüpheli (dokunulmadı; `kapsam_D.csv`'de `supheli`)
`QUEST_LIGHTER_H` (dolgu "gerçekten", ipucu olarak işliyor), `QUEST_GOATHERD_H`, `QUEST_CHICKENS_T`, `BUR_TUBE`,
`BUR_NOTICE_A_2`, `BUR_DOOR_2150_3`, `BUR_DOOR_1215_2`, `BUR_FG_POL_V3_1` / `BUR_AMB_G3_3_1` (Cenova/Genova),
`BUR_AMB_G4_3_3` EN ("Neither of our files is handed to anyone." tahta), `BUR_AMB_G9_7_3` ("Kıdem değil, numara
önemli." kalıbı; "kıdeme bakılmaz, numaraya bakılır" olabilir), `REACT_LUTFI_TAPE`, `REACT_NIKO_PHONE` (Niko
yeniden yazımında), `REACT_EMPEROR_CUBE`, `REACT_THEODOROS_POWERBANK`, `REACT_DERVISH_TAPE` EN ("My brother"),
`REACT_FISHMONGER_BOOK` TR+EN, `REACT_KADRI_REPLAY_4`.

## Gözlemler
- İlk turun önerileri iyi ve çoğu yerinde; hızına rağmen kabul oranı yüksek (86/96). Kusurlar deyimin anlamında
  (yılan hikâyesi), yan bağda (bol tuz / diplomasi), dönem ve din ağzında (papaz) ve sesli satıra yeni sayıda.
- İlk turun en büyük boşluğu **eşlenik anahtarlar**: aynı replik eşya tepkisi olarak hem `REACT_*`'te hem bölüm
  betiğinde (`D4A_ITEM_*`, `D6_KADRI_*`, `D12_F_ITEM_*`) ve Hikmet'in telsiz yorumunda (`HIKMET_ITEM_*`) yaşıyor.
  Raporda anılmışlardı ama CSV'ye girmemişlerdi; şimdi girdiler.
- İkinci okumada çeviri izi en çok Büro'nun tarihî kişi diyaloglarında ve Nihat'ın saat/kapı panolarında kaldı;
  sokak lafları (`DST_*`), Hasan ile Hüseyin, Urban, Kadri'nin kazanı ve Tolga'nın plaza cevapları temiz.
- Niko satırları (`REACT_NIKO_*`, `MG_HAG_NIKO_*`) okunup kapsama işlendi; yalnız yön hatası önerildi, gerisi
  `NIKO_YENIDEN.md`'nin işi.
