# Dilim 7: çeviri kokusu taraması raporu

**Okunan satır:** 806 / 806 (`python3 docs/_ajan/gorev/ceviri_dilim.py 7`). Her satır TR ve EN sütunuyla birlikte okundu.
Dilimde şunlar var: `QUEST_*` (yan görevler: ad, ipucu, yer, Tolga'nın bitiş repliği), `BUR_*` (Büro'daki eşyalar, Nihat'ın
dokunma replikleri, kapı panoları), `BUR_FG_*` (Bekleme Salonu'ndaki tarihî kişilerin tekil replikleri) ve `BUR_AMB_*`
(tarihî kişilerin kendi aralarındaki ortam diyalogları). Komşulukları `scripts/level/bureau.gd` üstünden kontrol ettim.
`BUR_AMB_*` replikleri sırayla çalan küçük diyaloglar (`bureau.gd` ~4000. satırdan sonrası); `BUR_FG_*` her ziyarette tek
başına çalıyor (V2/V3 sonraki ziyaretler).

**Öneri:** 53 satır (yaklaşık %6.6), 46 TR ve 7 EN.

| şiddet | tr | en |
|---|---|---|
| 3 | 2 | 1 |
| 2 | 31 | 5 |
| 1 | 13 | 1 |

Uzunluk: hepsi eskisinin %70–130'u arasında. Tek istisna `BUR_AMB_G3_7_2` ("Söylenir mi?" → "Söylenir, ha?"): 12'den 13
karaktere çıkıyor, oran olarak sınırda ama süre olarak fark yok. Yeni rakam, kısaltma ya da parantez eklenmedi.

## En iyi on (önce | sonra)

1. `BUR_FG_GAG_1` (Gagarin): "…108 dakikada bir sıra bile **atlamadım**." | "…108 dakikada bir adım bile **ilerlemedim**."
   İngilizce "moved up one place" aktarılırken Türkçedeki "sıra atlamak" (kaynak yapmak) çıkmış; anlam tersine dönmüş.
2. `BUR_FG_POL_2` (Marco Polo): "**Efsane!** Ben sadece bir hapishanede kitap yazdırdım." | "**Masal!** Ben yalnızca zindanda bir kitap yazdırdım."
   "A myth!" karşılığı, ama Türkçede "Efsane!" "Harika!" anlamına geliyor.
3. `BUR_SANDAL_2` (EN): "The tag says **MS** 79." | "The tag says **AD** 79." Türkçe kısaltma İngilizcede kalmış.
4. `BUR_FG_NAS_V3_1` (Nasreddin): "Gölü mayalamak için bir kaşık yoğurt attım. Tutmadı. Tıpkı şu sıranın ilerlemesi gibi." |
   "Göle maya çaldım, **ya tutarsa** dedim. Tutmadı. Bu sırayı da **ya ilerlerse** diye bekliyorum." (EN de buna göre yazıldı.)
5. `BUR_FG_CLE_V2_1` (Kleopatra): "…Tarihçiler bile emin değil." | "…Tarihçiler bile emin değil; düpedüz **yılan hikâyesi**."
6. `BUR_AMB_G16_4_3` (Sabri): "Bekleyen kazanır." | "**Sabreden derviş muradına erer.**" (EN: "Good things come to those who wait.")
7. `BUR_FG_SHK_1` (Shakespeare): "Beklemeli mi, beklememeli mi; bütün mesele bu." | "**Beklemek ya da beklememek; işte bütün mesele bu.**"
   Türk okurun bildiği "Olmak ya da olmamak" kalıbına oturunca espri işliyor.
8. `BUR_FG_NAP_V2_1` (Napolyon): "…inmezsem kibirli. Zor seçim." | "…inmezsem kibirli. **İki arada bir derede kaldım.**"
9. `QUEST_FRIENDS_DONE` (Tolga): "Bu ya diplomasi ya da çok kötü bir fikir." | "Ya diplomasi bu, ya da **başımı yaktım**."
10. `BUR_COOLER_2` (Nihat): "Her baloncuk bir kayıp saniye olsaydı bu büro zengin olurdu." (if I had a nickel…) |
    "Kayıp saniyeler de böyle bulunsaydı Büro **ihya olurdu**."

## Şüpheli (dokunmadım; sahibine sorulabilir)

- `BUR_TUBE` (Nihat): "Fwump. 'Fwump' iyiye işaret değildir…". İngilizce yansıma ses; Türkçede "pof/fıss" olurdu. Ama
  **`D3_N_02`** ("Tüp yine 'fwump' dedi. 'Fwump' iyiye işaret değildir.", başka dilim) ile süren bir şaka. İkisi
  birlikte değişmeli (önerim: "Pof." / "'Pof' hayra alamet değildir"). Tek başına değiştirmedim.
- `QUEST_CHICKENS_T` "Tavuk Fısıldayan" → "Kümes Avcısı" önerildi. Aynı ad başarım olarak da var:
  **`ACH_CHICKEN_WHISPERER_T`** (başka dilim). Ya ikisi birlikte değişsin ya da ikisi de kalsın. `bagli` sütununa yazdım.
- `QUEST_LIGHTER_H` "ateşten gerçekten korkması gereken": dolgu "gerçekten", ama ipucu olarak iş görüyor.
- `QUEST_THERMOS_DONE` "Tarihçiler bunu asla bilmeyecek": hafif "will never know" kokusu var; "Tarihçilerin bundan haberi olmayacak" olabilir.
- `QUEST_GOATHERD_H` "keçiler köşeleri sevmez": "goats hate corners" iskeleti, ama ipucu ve şaka olarak çalışıyor.
- `BUR_BLIND` "…sadece görünmüyor", `BUR_NOTICE_A_2` "Net bir plan.", `BUR_CCLOCK0` "Gölge hiç düşmüyor ama mesai düşüyor"
  (İngilizce "falls" oyunu, Türkçede zayıf), `BUR_CCLOCK3` "Hiçbir zaman değil ama tam vaktinde" (never o'clock).
- `BUR_DOOR_1789_1` "Bu kadar gürültü için küçük bir dosya." İngilizce iskelet. "Bu kadar gürültüye küçücük bir dosya" ya da "dağ fare doğurdu" olabilir.
- `BUR_DOOR_2150_3` "Bu bir sorun değil, bir aşama.": plaza/İngilizce kalıp, ama Nihat'ın daire ağzında ironik duruyor.
- `BUR_AMB_G3_3_1` "Genova" ile `BUR_FG_POL_V3_1` "Cenova": aynı kişide iki yazım. Özel ad olduğu için dokunmadım; birleştirilmesi iyi olur.
- `BUR_AMB_G4_3_3` EN "Neither of our files is handed to anyone.": biraz tahta, ama anlaşılır.
- `BUR_FG_NAP_V2_1`'deki gibi "Zor seçim" türü kısa İngilizce kapanışlar Nihat'ın kapı panolarında da var ("Hızlı bir
  itiraz.", "Makul bir oran."). Bunları Nihat'ın kuru tutanak üslubu sayıp bıraktım.

## Komşusu değişen ama dokunmadığım replikler

- `BUR_AMB_G4_2_2` (Mozart'ın son gece uvertürü): cevabı `BUR_AMB_G4_2_3` değişti, kendisi aynı.
- `BUR_AMB_G5_1_1` (Sinan, kandil isi): cevabı `BUR_AMB_G5_1_2` değişti.
- `BUR_AMB_G3_5_1`, `BUR_AMB_G3_7_1`, `BUR_AMB_G3_4_2`: "dediğim söylenir" zincirindeki komşular; yalnız cevap replikleri düzeltildi.
- `BUR_AMB_G7_1_1`, `BUR_AMB_G7_7_2`, `BUR_AMB_G7_7_4`: Sezar–Shakespeare–Necmi üçlüsü; Necmi'nin "Bizde fiyat hep indirimli" cevabı yeni "Ucuza gitmek gururuma dokundu" ile de bağlanıyor.
- `BUR_AMB_G13_7_1`, `BUR_AMB_G13_7_4` (Tesla/Edison "sende birim, bende şirket"): yeni "Benden de koca bir şirket çıktı" ile uyumlu.
- `BUR_FG_NEW_1` (elma kafama düşmedi): `BUR_APPLETREE_2`'deki "rivayettir" onunla örtüşüyor.
- `D3_N_02`, `ACH_CHICKEN_WHISPERER_T`: yukarıda, başka dilimde.

## Genel gözlemler

- Dilim büyük ölçüde temiz. Büro espri dili (daire, dilekçe, numaratör, "incelemede") Türkçede doğal duruyor. Bazı yerler
  açıkça Türkçe düşünülmüş: "Kuru Gürültü, Islak İmza", "iş çıkardı / fatura çıkardı", "Bu görelilik değil, devlet
  dairesi", "Tanrı iki yüzlüymüş", "kimse aydınlanmıyor". Bunlara dokunulmamalı.
- Çeviri kokusu en çok **Bekleme Salonu'ndaki tarihî kişilerin ikinci ve üçüncü ziyaret repliklerinde** (`BUR_FG_*_V2/V3`)
  var: Marco Polo, Mozart, Gagarin, Sinan. Bu satırlar İngilizceden kurulmuş gibi duruyor: sona asılan yan cümle
  ("kimse bestelemese de", "bu da hiç sağlam değil"), "beni ... döndürdü", "bu çok adil değil mi?". Hepsine sahibin
  notundaki ölçüyü uyguladım: kişi kendi dünyasının lafını eder ama Türkçe düşünülmüş espriyle konuşur. Bu yüzden
  Nasreddin'e "ya tutarsa", Kleopatra'ya "yılan hikâyesi", Sabri'ye "sabreden derviş" verildi.
- İkinci yoğunluk **Tolga'nın görev bitiş replikleri** (`QUEST_*_DONE`): İngilizce kapanış esprileri ("stickier",
  "would be proud", "either … or a very bad idea") Türkçeye harfiyen geçmiş.
- İngilizce sütun genelde iyi. Bulduklarım Türkçeden kelime kelime gelmiş kalıntılar: "MS 79", "root of a company",
  "walk there to see the far away", Türkçe söz dizimli soru.
- Arayüz metinlerinde (`QUEST_*_H/_W`) yazılım çevirisi kalıbı yok.
