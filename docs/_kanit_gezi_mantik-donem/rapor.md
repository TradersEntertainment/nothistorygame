# Gezi denetimi — `mantik-donem` (bütün şehir, MANTIK ve DÖNEM gözüyle)

Denetçi: bağımsız gezgin. Taban `wip/ist2-gezi-taban`. Oyun kodu DEĞİŞTİRİLMEDİ (yalnız `tests/_ist/gezi_mantik-donem.gd/.tscn` sondası ve bu klasör).
Bu bir **KISMİ** rapordur (ilk gönderim): aşağıda "bakamadıklarım" bölümü neyin yapılmadığını açıkça söyler.

## 1. Bölge, sayılar
- Bölge: bütün şehir + sur dışı (gerçek m): kara surları GB (−5250, −1607) … KB (−3436, 3013), doğu Galata/Haliç (−425…−155, 1600…1958), Ayasofya (0,0), Marmara kıyısı (−1500, −1450). Dört köşe: (−5300, −1700), (−3000, 3400), (300, 3400), (300, −1700).
- **Çekilen kare: 88. Bakılan: 88** (10 pafta açıldı; 12 kare tam boyda açıldı: `u_romanos`, `u_galata_kulesi`, `s_kara_ic_orta`, `y_hipodrom` ve paftadaki şüpheliler).
- Eser dökümü: 845 öğe, 37'si "gorev:true" (sondan `--set=dump`; `eser_dokum.txt`). Belgenin "28 yan görev eseri" sayısı kodda 37 kayıt olarak çıktı; hepsine iki kare (yer 1,7 m + 45 m yukarıdan) alındı.
- Gerçek oyuncuyla yürüyüş: **0 km — YAPILMADI**. Izgara taraması, gece, 15 m'de bir yol karesi: **YAPILMADI**.
- Eser konumları `docs/ISTANBUL_YERLER.csv` ile sayısal karşılaştırıldı (aşağıda M-bulguları).
- Ad/etiket taraması (`ara_sayim.txt`): düğüm/mesh adında hilal, minare, domates, patates, mısır, tütün, kahve, tabela için eşleşme **0**; ancak düğüm adları genel olduğundan bu **kanıt değildir**, yalnız "adla bulunmadı". Sahnedeki tek `Label3D`: Ayasofya'da "IC XC" (Hristiyan monogramı; döneme uygun). Karelerde minare/hilal/tabela GÖRÜLMEDİ.

## 2. GENEL NOT: **5 / 10**
Sahibi bu bölgeyi gezse ilk olarak kapı kulelerinin sur üstüne oturmuş dev, çıplak "kutu + mor beşik çatı" kütlelerine ve oyuncak küp/koni ağaç-koyunlara kızar. İkinci olarak, bazı eserler belgedeki yerinden 200–750 m uzakta (Arkadius, Mokios, Pege, Venedik mahallesi) ve güneyde sur dışı çıplak çayır. Mese, forumlar, Konstantin Sütunu, Tekfur Sarayı ve Topkapı karşısındaki ordugâh/batarya iyi.

## 3. BULGU TABLOSU
Önem: 1 kritik, 2 belirgin, 3 küçük. "ŞÜPHELİ" = emin değilim. Kare dosyaları `kare/*.jpg` (tam boy) ya da `pafta/pafta_NN.jpg` (sıra: liste_1.txt'nin alfabetik sırası, 3×3, soldan sağa).

| no | tür | önem | yer | doğu, kuzey | kare | ne görünüyor | kaynak | öneri |
|---|---|---|---|---|---|---|---|---|
| 1 | KUTU | 1 | Romanos kapısı (Topkapı) | −4833, 892 | kare/u_romanos.jpg | Kapıyı çevreleyen iki dev kule: çıplak dikdörtgen gövde + mor-gri düz beşik çatı levhası; sur gövdesinden büyük, kapı/kemer okunmuyor | `surlar.gd:build_romanos` (satır 853) | Kule gövdesine mazgal/parapet, çatıyı kaldır (belge §3.2: kule üstü kirişsiz taş parapet) |
| 2 | KUTU | 1 | Pege (Silivri) kapısı | −4988, −1241 | pafta_05 (8. kare, u_pege) | Aynı mor beşik çatılı iki kutu kule, sur üstünde | `surlar.gd:build_pege` (839) | Bulgu 1 gibi |
| 3 | KUTU | 1 | Kharisios (Edirnekapı) | −3647, 2565 | pafta_04 (7. kare u_kharisios) | Sur üstünde iki dev kutu + mor çatı; sur yürüme yolunu kapatıyor | `surlar.gd:build_kharisios` (867) | Bulgu 1 gibi |
| 4 | DÖNEM | 2 | Galata Kulesi | −504, 1892 | kare/u_galata_kulesi.jpg | Kule üstü kırmızı KONİK KÜLAH (oyuncak doygunluğu, kırmızı kiremit) | `galata.gd:build_galata_kulesi` (93) | Belge §5/§9: 1453'te külah YOK; düz/mazgallı çatı |
| 5 | KUTU | 2 | Hipodrom içi | −421, −344 | kare/y_hipodrom.jpg | Küpten yapılmış beyaz "koyun" (iki küp), parlak açık-yeşil düz çim, yeşil koniler | `hipodrom.gd` (koyun), CANLI/ZEMİN (biliniyor) | Gerçek koyun modeli, çim tonunu soldur |
| 6 | MANTIK | 2 | Venedik mahallesi | −916, 846 (CSV: −924, 1268) | kare/u_halic_venedik.jpg, pafta_04 (2. kare), pafta_08 (3. kare) | Belgede "iskeleler, bailo evi, depolar" olan yer boş çayır, bir ahşap levha; konum CSV'den 422 m güneyde | `halic.gd:build_halic_venedik` (111); belge `ISTANBUL_1453.md §4.6/7.1` | Mahalleyi CSV konumuna yaklaştır, depo/iskele ekle |
| 7 | MANTIK | 2 | Arkadius Forumu | −3419, −678 (CSV −3100, −89) | kare/u_arkadius.jpg | Eser belge konumundan 670 m uzakta; tepeden devasa düz beyaz elmas levha (kaide) | `forumlar.gd:build_arkadius` (78); CSV `Arkadius Forumu ve Sütunu` | Konumu düzelt; kaideyi küp yerine basamaklı/profilli yap |
| 8 | MANTIK | 2 | Mokios Sarnıcı | −3600, −450 (CSV −3806, 189) | kare/u_mokios.jpg, pafta_09 (4. kare) | 671 m kayık. İç: eş aralıklı yüzlerce özdeş tarh + yeşil koni/küre "sebze" (oyuncak), düz krem zemin | `guneybati.gd:build_mokios` (97) | Konum; tarh/ürün çeşitlilik ve kuyu, bostan ürünü gerçek biçimde |
| 9 | MANTIK | 2 | Pege kapısı konumu | −4988, −1241 (CSV Silivrikapı −5041, −489) | eser_dokum.txt | Oyunda Pege ile Altın Kapı arası 366 m; CSV'de 1 212 m. Pege 754 m güneye kaymış; Xylokerkos/Pege/Rhegion sırası bozuk | `sehir.gd:YER` tablosu | Kapı konumlarını CSV'ye göre sırala |
| 10 | MANTIK | 3 | Kerkoporta / Anemas / Büyük Saray / Romanos / Kharisios | −3436,3013 / −3140,3383 / 19,−271 / −4833,892 / −3647,2565 | eser_dokum.txt | CSV'den sapma 361 / 341 / 257 / 269 / 276 m | `sehir.gd` YER çakışma çözümü | Sapmanın kasıtlı (ölçek çakışma kayması) olup olmadığını belgele |
| 11 | MANTIK | 3 | Tauri, Pantokrator, Petrion, San Domenico, Marcianus, Altınkapı | bkz. eser_dokum.txt | eser_dokum.txt | Sapma 197 / 208 / 193 / 233 / 158 / 155 m | aynı | aynı |
| 12 | GÖRSEL | 2 | Ayasofya, Aya İrini, Havariyun, Pantokrator, Nea | 0,0 / 130,177 / −2540,1210 / −2024,1414 / 138,−298 | pafta_03 (2,3), pafta_04 (3), pafta_05 (4,7) | Kubbeler açık mavi-beyaz (cam göbeği), parlak; belge: kurşun grisi | `sehir_eser.gd:palet` | Kurşun gri, hafif parlak, daha koyu |
| 13 | GÖRSEL | 2 | Khora, Pammakaristos | −3444, 2516 / −2831, 2338 | pafta_04 (8), pafta_05 (6), kare/u_khora.jpg | Kubbeler lacivert-siyah, çatılar tek renk | `kuzeybati_kilise.gd:build_khora` (29), `:build_pammakaristos` (100) | Kubbeleri kurşun grisine al |
| 14 | KUTU | 2 | Markianos/Anemodoulion/Arkadius | −2560, 900 / −1660, 300 | pafta_06 (9), pafta_09 (2), pafta_02 (9) | Beyaz çıplak küp kaide, dokusuz beyaz sivri koni ve beyaz "yuvarlak ağaç" kütleleri (hemen her havadan karede) | `forumlar.gd`, bitki kitaplığı (`bitki.gd`, ŞÜPHELİ kaynak) | Beyazı taş dokusuna, ağacı yeşil/dallı yap |
| 15 | MANTIK | 2 | Sur dışı güney (Altın Kapı, Pege) | −5150, −1607 / −5250, −1240 | kare/o_altin_dis.jpg, pafta_01 (4. kare) | Hendek/ateş alanı ve ordugâh yok: düz çayır; belge ORDUGAH §1.1 Anadolu kanadı Lykos'tan Marmara'ya | ordugâh (`ordugah*.gd`, ŞÜPHELİ) | Güney kanatta çadır/ağıl ekle (karşılaştır: o_topkapi_hava iyi) |
| 16 | KUTU | 2 | Edirnekapı dışı | −3900, 2600 | pafta_01 (2. kare), kare/o_edirne_dis.jpg | Dev oyuncak küre/küp "ağaç" ve eğik yeşil küp, düz yeşil çimde | `bitki.gd` (ŞÜPHELİ) | Ağaç modeli |
| 17 | GÖRSEL | 2 | Kara suru iç yanı (hub) | −4500, 1500 | kare/s_kara_ic_orta.jpg | Yola dikilmiş kırmızı üstlü SİYAH düz levha (kapı yaprağı/pano?) ve uzun bej dik direk; kule tepesinde kırmızı küp bayrak | düğüm adı bilinmiyor | Levhayı kapıya dönüştür |
| 18 | KUTU | 3 | Sur dibi evi | −4750, −1000 | pafta_01 (8. kare) | Evin üstünde yeşil levha çatı + gri düz rampa levha | `ayrinti*.gd` (ŞÜPHELİ) | Çatıyı kiremitle |
| 19 | GÖRSEL | 3 | Büyük Saray | 19, −271 | pafta_07 (7. kare, y_buyuk_saray) | Kırmızı tuğla duvarda parlak yeşil dikdörtgen levha; harabe değil kutu | `hipodrom_saray.gd:build_buyuk_saray` (73) | Moloz, sarmaşık |
| 20 | GÖRSEL | 3 | Palazzo del Comune | −425, 1600 | pafta_09 (6. kare) | Cephede koyu kahve düz levha | `galata.gd:build_palazzo_comune` (111) | Pencere/kapı |
| 21 | GÖRSEL | 3 | Milion / Aya İrini çevresi | 130,177 | pafta_05 (2. kare), pafta_07 | Parlak nane-yeşil düz çatı/çim levhaları | `hipodrom_aug.gd:build_milion` (193) | Renk soldur |
| 22 | GÖRSEL | 3 | Bozdoğan kemeri | −2030, 865 | pafta_07 (6. kare) | Payeler eğik/çarpık, üst tabliye ahşap gibi (ŞÜPHELİ) | `kemer.gd:build_bozdogan` (84) / `kemer_su.gd:119` | Payeleri dik, tabliye taş |
| 23 | GÖRSEL | 3 | Marmara suru (uzak) | −1500, −1450 | pafta_02 (1. kare) | Ufukta düz bej-gri blok sırası (kalite notu 11/24 bilinen) | deniz suru uzak katman | Mazgal/şerit |
| 24 | DÖNEM | 3 | Mese, tezgâh | −3000, −300 | pafta_02 (3. kare) | Tezgâhta karpuz (ŞÜPHELİ; Nisan'da mevsimi değil — belge §1 mevsim) | `ayrinti*.gd` (ŞÜPHELİ) | Soğan/lahana |
| 25 | DÖNEM | 3 | Haliç suru | −900, 900 | pafta_01 (7. kare) | Surda kırmızı haçlı beyaz (Ceneviz) bayrak; Venedik kıyısında Venedik aslanı beklenir (ŞÜPHELİ) | bayrak yerleşimi (`halic*.gd`, ŞÜPHELİ) | Venedik arması |
| 26 | DÖNEM | 3 | Sur kuleleri | −4833, 892 | kare/s_kara_ic_orta.jpg, pafta_06 | Kule tepelerinde küçük parlak kırmızı küp "bayrak"; Palaiologos/Osmanlı ayrımı okunmuyor, hilal GÖRÜLMEDİ (ŞÜPHELİ) | sancak (`ayrinti_api.gd:build_sancak_diregi`) | Çift başlı kartal |
| 27 | ZEMİN | 3 | Altın Kapı dışı | −5100, −1607 | kare/o_altin_dis.jpg | Sol önde siyah dikdörtgen levha (hendek bandı) | sur hendek parçası (SUR-5, biliniyor) | — |
| 28 | GÖRSEL | 3 | Yer karesinde yapı içine düşen kamera | 12 yer | pafta_07 (3), pafta_08 (2,4,7), pafta_09 (5,9), pafta_10 (1,2,7) | `y_aya_irini`, `y_khalke`, `y_romanos`, `y_san_domenico`, `y_zeuksippos`, `y_havariyun`, `y_halic_petrion`, `y_nea`, `y_pege`: lacivert boşluk/iç yüz. **ŞÜPHELİ: büyük olasılıkla sondanın kamera yerleşimi (yapı gövdesinin içi), oyun hatası olmayabilir** | — | Yürüyüşle doğrula |
| 29 | GÖRSEL | 3 | Ayasofya | 0, 0 | pafta_07 (4. kare) | Dışarıdan 1,7 m kamera Ayasofya iç mekânını görüyor; pandantifler siyah-lacivert kalın plakalar | `sehir_eser.gd` / ayasofya | ŞÜPHELİ (kamera içeride olabilir) |
| 30 | MANTIK | 3 | Khora avlusu | −3444, 2516 | pafta_04 (8. kare) | Kare, pembe düz duvarlı avlu kutusu; kilise tek başına | `kuzeybati_kilise.gd` | Avlu revak/bahçe |

## 4. Tür başına sayım
KUTU 7 (satır 1,2,3,5,14,16,18) · DÖNEM 4 (4, 24, 25, 26) · MANTIK 8 (6–11, 15, 30) · GÖRSEL 10 · ZEMİN 1 · OYNANIŞ 0 (**yürüyüş yapılmadı**) · PERFORMANS: RINFO `rinfo_liste1.txt` (88 satır, yer 1 200 / 2,5 M bütçesine karşı ayrıca değerlendirilmedi).
**KUTU kalan = 7** (bu kare setinde).

## 5. En kötü 12 kare
1. kare/u_romanos.jpg — dev kutu kule + mor çatı (bulgu 1)
2. pafta_05 (8. kare) u_pege — aynı (2)
3. pafta_04 u_kharisios — aynı (3)
4. kare/u_galata_kulesi.jpg — kırmızı külah (4)
5. kare/y_hipodrom.jpg — küp koyun + parlak çim (5)
6. kare/o_edirne_dis.jpg — oyuncak küp ağaç (16)
7. kare/s_kara_ic_orta.jpg — siyah levha (17)
8. kare/u_mokios.jpg — eş tarh/koni bostan (8)
9. kare/u_arkadius.jpg — dev beyaz levha (7)
10. kare/u_halic_venedik.jpg — boş Venedik mahallesi (6)
11. kare/o_altin_dis.jpg — çıplak güney sur dışı (15)
12. pafta_07 (7. kare) y_buyuk_saray — yeşil levha harabe (19)

## 6. İYİ olan 5 kare (korunacaklar)
1. pafta_02 s_mese_ayasofya — Mese'de taş döşeme, insanlar, dükkânlar
2. pafta_04 u_konstantin / pafta_09 y_konstantin — sütun ve forum
3. pafta_01 o_topkapi_hava — Şahi/batarya, siperler, sancaklar, sur
4. pafta_06 y_tekfur — şeritli Tekfur cephesi
5. pafta_06 y_anemas — taş-tuğla kule

## 7. BAKAMADIKLARIM (dürüstçe)
- Gerçek oyuncuyla yürüyüş (≥ 1,2 km), takılma/düşme sayımı: YAPILMADI.
- 60 m ızgara, dört yöne kareler, gece kareleri, 15 m'de bir yol karesi, kapıdan kapıya sokak ağı (çıkmaz yol, kapısız ada, Lykos köprüsü): YAPILMADI; M-bulguları yalnız eser konumları ve 88 karedir.
- Sokak ağı, Mese kesintisizliği, Lykos köprüsü/menfez, kişi kıyafeti/iş (Osmanlı askeri sur içinde mi?), zincir/donanma konumu, topların yönü: **BAKILMADI** (yalnız o_topkapi_hava'da toplar surun ana saldırı bölgesine bakıyor görünüyor; ŞÜPHELİ).
- Ölçek ölçümü (insan/kapı) yapılmadı; yalnız görsel izlenim: kapı kuleleri insana göre aşırı büyük (bulgu 1–3).
- Düğüm adı ile kaynak eşlemesi çoğu satırda dosya:işlev düzeyinde; `sur4_kare --set=kim` koşulmadı.
- Sonda `tests/_ist/gezi_mantik-donem.*`; `git status`: oyun kodunda değişiklik yok.
