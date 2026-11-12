# İstanbul 1453 — şehir mimarı / birleştirici raporu (dal `wip/istanbul`)

Tarih: 12 Kasım. Durum: **ARA RAPOR (tur 1–2)**. Her turda güncellenir. Bakamadığım her şey BAKILMADI diye yazıldı.

## 1. Ne kuruldu (bu oturum)

| İş | Dosya | Durum |
|---|---|---|
| Araştırma dalı birleşti; `CityGeo.ANCHORS` dizindeki konumlara göre, TPS katsayıları yeniden | `scripts/world/city_geo.gd`, `docs/_kanit_istanbul/arac/geo_tps2.py` | TAMAM (17 dayanak dizinden; Kız Kulesi ve Eyüp dizinde yok, eski kestirim). Katlanma: 3584 noktada 1 (Altınkapı'nın güneyi, şehir dışı) |
| Ev kiti (mektup bölümünün `ByzCity._house` dili) | `scripts/world/ist/evler.gd` (`IstEvler`) | TAMAM: sıra ev, dükkânlı ev, kule ev, harabe, sundurma, sandık, dış merdiven; lod 0/1/2; CityPlan'ın 7 ev tabanıyla birebir |
| Şehir kurucusu: parça kayıtları → dünya, lod 2→1→0 akış, zaman dilimli | `scripts/world/ist/sehir.gd` (`IstSehir`) | TAMAM (kare başına 6 ms bütçe; kurma/boşaltma 25 m pay; 3B uzaklık) |
| CityPlan evleri (≈5 000) CityHouses (Quaternius Kit) yerine yeni ev diliyle, MultiMesh | `IstSehir.houses` ← `CityHouses.build` | TAMAM: uzak/orta katman hemen, yakın katman ve çarpışma 48 m hücrelerle akışla |
| Mahalle dokusu: boş hücrelerde bitişik sıra evler (aralık 0), bostan/bağ/tarla yamaları, harabe, ağaç; ada içlerinde bahçe ağaçları | `IstSehir._doku` | KABA (sık/seyrek mahalle dikdörtgenleri plan §2'den) |
| Eski kaba yapıların kaldırılması (çifte yapı yok) | `landmarks1453.gd`, `horn_world.gd` (yalnız ekleme) | TAMAM: Hipodrom, Büyük Saray terasları, Tauri, Aya İrini, Augustaion, Havariyun, Pantokrator, Kariye, Pammakaristos, Studios, üç Haliç iskelesi |
| Nihat'ın yan görevi: yeni eserler listeye EK (ilk dokuz kimlik ve sıra aynı) | `world1453.gd` `flight_data`, `nihat_powers.gd`, `i18n/strings.csv` (+19 ad, +19 replik) | TAMAM (adı yazılı olmayan eser listeye girmez) |
| ÖNCE anahtarı | `IstSehir.enabled` (`--once`) | TAMAM |
| Şehir sondası (havadan 4 yön + tepe, eser 15 m + tepe, yerden) | `tests/_ist/sehir_kare.*` | TAMAM |

## 2. Birleştirilen parça dalları (tur 1–2)

surlar, halic, galata, hipodrom, forumlar, kemer, kuzeybati, guneybati, kiliseler, ayrinti, bitki (11/12; `wip/ist-marmara` henüz yok).

### Yerleştirme kararları (yerleştirme tablosu `IstSehir.YER`; modül dosyalarına dokunulmadı)
- **forumlar**: modülün konumları araştırma dizininden 100–700 m sapıyordu; Arkadius ve Myrelaion SUYA düşüyordu. Dizindekiler
  dizinden, Konstantin ve Tauri eski yerlerine (yan görev ve bölüm 24'ün sütunu), ötekiler bilinen yerlerinden (kestirim).
  Mese dilimi CityPlan'ın Mese'sine hizalanmadan kurulmuyor (sokağı kapatırdı). Forum döşemeleri 0,5 m yüksekti, meydandaki
  siviller gömülüyordu: döşeme arazi hizasına indirildi (`dy`).
- **hipodrom**: Ayasofya çevresi haritada sıkışık (gerçek 480 m → dünya 95 m). Milion, Zeuksippos, Khalke, Nea elle Ayasofya,
  Hipodrom ve Augustaion arasındaki boşluklara oturtuldu (gerçek sırası korunarak); TPS onları Ayasofya'nın içine düşürüyordu.
- **halic**: Haliç kıyısı haritada x −700'de düz. Mahalleler kıyı surunun hemen içine, şehre bakacak yönde, batıdan doğuya
  gerçek sırayla dizildi (Yahudi, Venedik, balık pazarı, Pisa-Amalfi, Neorion, iskeleler, Ceneviz). Kıyı suru, Eugenios/zincir,
  Petrion ve Fener kapıları KURULMADI: HornWorld'ünküler duruyor (çifte sur olurdu; G6 kıyı suru göçüyle değişir).
- **galata**: KURULMADI. GalataView (HornWorld) aynı yerde kendi Galata'sını kuruyor; modülün yapılarının yarısı haritanın dar
  Galata kıyısında suya düşüyor. Sonraki tur: GalataView'ün yerine geçirme (kanca + yer tablosu).
- **surlar**: KURULMADI. Kara surları SiegeField/LandWalls'ta bölümlerin oynanış alanı (P02); modülün kapı konumları
  `World1453.LAND_GATES` ile eşleşmiyor. Altın Kapı (guneybati) da aynı sebeple.
- **kemer**: Bozdoğan modülü 970 m × k; haritadaki kemer 156 m: sığmıyor, HornWorld'ünkü kalıyor. Havariyun, Pantokrator eski
  yerlerinde (HornWorld'ün Havariyun'u kancayla kaldırıldı).
- **kuzeybati**: Tekfur ve Anemas Blakherna surlarının üstünde (bölüm 30'un surları), kurulmadı. Kariye, Pammakaristos eski yerlerinde.
- **guneybati**: Studios eski yerinde; Lykos köprüsü kurulmadı (haritada dere yok; lod 1 çarpışması tutucunun dışına, hub'a
  düşüyordu: 10h VISAUDIT — **modül kusuru: guneybati `build_kopru` lod 1**).

## 3. Testler (tur 2, başsız)

| Test | Sonuç |
|---|---|
| parse_check | PASS (296 betik) |
| world_check | PASS |
| 6 =byz, 7, 7 =byz, 12b, 23, 24, 25, 11, 8, 9, 20 | AUTOTEST PASS, hata satırı 0 |
| 10h | ilk koşuda 1 VISAUDIT (Lykos köprüsü) → köprü kurulmadı; yeniden koşu PASS, hata satırı 0 |
| flight_check | ilk koşuda FAIL (yeni eserlerin konma noktası yakın katman kurulmadan çarpışmasız) → görünmez konma kapağı; yeniden koşu PASS (perches=24) |
| city_check | ilk koşuda FAIL (Konstantin Forumu: sivil 0,52 m gömülü, sonra devriye kaidenin içinde) → Konstantin bu tur kurulmadı, Tauri döşemesi 0,5 m indirildi; yeniden koşu PASS |

## 4. Ölçümler (havadan, bütün şehir görünürken; sonda, aynı kamera)

| Kare | ÖNCE çizim / üçgen | SONRA çizim / üçgen |
|---|---|---|
| kuzey (Haliç'ten, 650 m) | 10 341 / 8,22 M | 13 488 / 8,38 M |
| güney (Marmara'dan) | 9 454 / 7,16 M | 12 612 / 7,32 M |
| doğu (Boğaz'dan) | 10 957 / 8,69 M | 14 091 / 8,84 M |

Çizim artışı (+%30) parçaların uzak katmanının ilkel parça başına çizilmesinden. Düzeltme yazıldı (uzak/orta katman kurulunca tek
ağa pişirilir, `IstSehir._bake_lod`); ölçümü sonraki turda. Yerde (oyuncu gözü) RINFO: BAKILMADI (sonraki tur).

## 5. Bilinen kusurlar
- Havadan karelerde soluk yarı saydam diskler ÖNCE'de de var (var olan dünya katmanı; benim katmanım değil). BAKILMADI: kaynağı.
- Galata, surlar, Bozdoğan, kıyı suru modülleri bu tur yerleşmedi (yukarıda).
- `city_audit` (delik/dar/cep) yeni hâlde: BAKILMADI (sonraki tur).

## 6. Ortak dosyalara eklenen satırlar
- `scripts/world/world1453.gd`: `build` içinde `IstSehir.attach(f)`; `flight_data` içinde yeni eserler ve konma noktaları (ekleme).
- `scripts/world/city_houses.gd`: `build` başında `IstSehir.houses(...)` kancası (2 satır).
- `scripts/world/landmarks1453.gd`: `build` döngüsünde yerine yeni parça kurulan anahtar atlanır (3 satır).
- `scripts/world/horn_world.gd`: Hipodrom/sütun/Büyük Saray ve Havariyun için "boş Dressing" kancaları (yalnız ekleme, var olan
  satırlar yeniden sıralanmadı).
- `scripts/player/nihat_powers.gd`: sayaç (bulunan / listedeki eser sayısı) ve seyyah koşulu (ilk dokuzun hepsi) — 2 satır değişti.
- `tests/flight_check.gd`: ilk dokuz aynı sırada; ardından adı yazılı yeni eserler kabul.
- `i18n/strings.csv`: yalnız sona eklenen satırlar (LM_*, D_LM_*).

## 7. Kanıt kareleri
- `tur_1_{kuzey,guney,dogu,bati,tepe}.jpg` (SONRA) ve `once_{…}.jpg` (ÖNCE), aynı kamera.
