# İstanbul 1453: forumlar paketi (dal `wip/ist-forumlar`)

Dosyalar: `scripts/world/ist/forumlar.gd` (`IstForumlar`: catalog, build_*/perches_*/climbs_*), `scripts/world/ist/forumlar_yapi.gd`
(`IstForumlarYapi`: ortak yapı taşları), `tests/_ist/forumlar_onizleme.{gd,tscn}`. Var olan hiçbir dosya değiştirilmedi.

## Araştırma özeti (kaynaklı; kısa tutuldu)
- Arkadius Sütunu: Xerolophos tepesinde, 421'de tamamlandı; yükseklik kaynağa göre ~40–50 m; sarmal kabartma 14 tur
  (Freshfield Albümü, 1574 çizimi); heykel 704/740'ta düşmüş; 1715–1719'da yıkıldı (yani 1453'te ayakta).
  Kaynak: Wikipedia "Column of Arcadius", livius.org. Gövde çapı için kaynak bulamadım → kestirim (≈ 3,8 m).
- Konstantin Sütunu: oval forumun ortasında, porfir tamburlar (7–11 sayı kaynağa göre değişir), beyaz mermer kaide;
  toplam yükseklik ~35–40 m (heykelsiz). Demir çemberlerin tarihi belirsiz (Osmanlı ~1515 ya da daha önce).
  Kaynak: Wikipedia "Column of Constantine". Tepedeki haç (1081 sonrası) → yapıda haç var.
- Tauri (Theodosius) Forumu: ortada sütun (sarmal kabartma, tepede heykel; ~40 m kestirim), batıda üç gözlü zafer takı kalıntısı.
  Kaynak: cavac.at "Forum of Theodosius", livius.org, Columbia Istanbul Documentation Project. Sütunun 1500'e kadar
  ayakta olduğu bilgisi kaynaklarda dolaylı → ayakta kabul ettim (kestirim).
- BELİRSİZ / KESTİRİM: Amastrianon'un 1453'teki düzeni (pazar meydanı kurguladım), Forum Bovis'te bronz boğanın 1453'te yerinde
  olup olmadığı, Anemodoulion'un 1453'te ayakta olup olmadığı (harap + devrik figür kurguladım), Myrelaion rotunda çapı
  (~24 m kestirim), Kapitolion'un yerleşimi ve boyutları, Philadelphion tetrapylon'un ayrıntıları. Konumlar (catalog)
  ±100–200 m belirsiz; CityGeo dayanakları gelince şehir kurucusu düzeltmelidir.
- Mese: 1453'te revaklar yer yer yıkık, dükkân olmuş; ölçüler (yol 11 m + iki revak 4,5 m + dükkân 4 m ≈ 28 m) kestirim.

## Oyuncu yetenekleri (koddan)
`player.gd`: JUMP = 3,6, yerçekimi 9,8 → zıplama h = 3,6² / (2·9,8) = **0,66 m**; `STEP_H` = 0,42 m (yürüyerek çıkılır);
`traversal.gd` (tırmanma kipi): REACH 2,3 m, VAULT_MAX 1,1 m. Bu pakette tüm yollar **yürüyerek**: basamak 0,28 m (≤ 0,42), tırmanma kipi gerekmez.

## Öğe listesi
| id | ne | durum |
|---|---|---|
| mese | revaklı cadde dilimi (parametreli uzunluk), yıkık sütunlar, dükkân, çatılar, dış merdiven | TAMAM (v1) |
| konstantin | oval forum, porfir sütun (demir çember, haç), iki kapı (biri yıkık) | TAMAM (v1) |
| tauri | zafer takı kalıntısı, gözyaşı sütunları, Theodosius Sütunu (sarmal) | TAMAM (v1) |
| amastrianon | pazar meydanı, havuz, çınarlar, yıkık revak köşesi | KABA/TAMAM (kestirim) |
| bovis | meydan, bronz boğa kaidesi, yıkık dükkân sırası | KABA/TAMAM (kestirim) |
| arkadius | sarmal kabartmalı ~50 m sütun, kaide, iç merdiven kapısı | TAMAM (v1) |
| markianos | granit tek parça sütun, Korint başlık, Nike madalyonları, kartallar | TAMAM (v1) |
| myrelaion | rotunda alt yapı + haç planlı üç apsisli kilise, kubbe | TAMAM (v1) |
| philadelphion | tetrapylon (dört kemer, bir yüzü yıkık) | TAMAM (v1) |
| kapitolion | podyum, kırık Korint sütunları, alınlık parçası, hücre duvarları | TAMAM (v1) |
| anemodoulion | dört yüzlü piramit kule, bronz levhalar, devrik figür | TAMAM (v1) |

## Ölçek ve oynanış
- k yalnız kütleyi ölçekler; kapı/basamak/yürüme genişliği sabit: basamak 0,28 m (≤ STEP_H 0,42), merdiven genişliği 1,8–2,0 m,
  revak serbest yüksekliği ≥ 3,4 m, geçit açıklığı ≥ 3,4 m. Kaideler/anıtlar k ile (k = 0,35 / 0,5 / 1,0 üçünde koşuldu).
- Her sütun/anıtta kaideye dış taş merdiven (kaide–merdiven yarığı dolgu bloğuyla kapalı); yıkık kapı ayağına kırık taş basamak;
  mese revak çatısına iki uçtan dış merdiven; Kapitolion ön geniş merdiven; Myrelaion rotunda yanından terasa merdiven.
- Çatılar: eğimli kiremit çatıların altında/içinde çarpışma kabuğu var (üçgen prizma ya da eğik plaka, eğim ≤ 32°).
- Nihat: `perches_x` her öğede ≥ 1 (kubbe, sütun başlığı, çatı sırtı, kule tepesi); `catalog()` içinde `bakis`, `bakis_r`, `gorev`.

## ISTAUDIT (k = 0,5, lod 0; kendi denetim sahnem, 0,5 m ızgara)
```
mese          tris=7744 draws=460 delik=0 dar=44 havada=0 cati_yolu=2/2
konstantin    tris=5712 draws=154 delik=0 dar=0  havada=0 cati_yolu=2/2
tauri         tris=9152 draws=118 delik=0 dar=0  havada=0 cati_yolu=2/2
amastrianon   tris=1880 draws=56  delik=0 dar=0  havada=0 cati_yolu=1/1
bovis         tris=1876 draws=54  delik=0 dar=1  havada=0 cati_yolu=1/1
arkadius      tris=4452 draws=48  delik=0 dar=0  havada=0 cati_yolu=1/1
markianos     tris=1544 draws=42  delik=0 dar=1  havada=0 cati_yolu=1/1
myrelaion     tris=1508 draws=75  delik=0 dar=1  havada=2 cati_yolu=1/1
philadelphion tris=2124 draws=69  delik=0 dar=1  havada=0 cati_yolu=1/1
kapitolion    tris=2504 draws=69  delik=0 dar=0  havada=0 cati_yolu=1/1
anemodoulion  tris=1062 draws=83  delik=0 dar=0  havada=0 cati_yolu=1/1
```
k = 0,35 ve 1,0 koşuları: delik = 0 her yerde, havada = 0 (k = 0,35'te myrelaion 2), cati_yolu tam; dar yalnız mese (85–93),
tauri (10–14, bu tur giderildi, k = 0,5'te 0), birkaç öğede 1–4 küçük kayıt.
Yol sınaması: `climbs_x` noktaları arasında 10 cm adımla yürüyen, yükselmeyi ≤ 0,43 m ve kapsülü (r 0,3, boy 1,8)
çarpışmasız tutan betik (gerçek `CharacterBody3D` değil; oyunun basamak kuralının simülasyonu).

## Üçgen sayıları (lod 0 / 1 / 2)
mese 7744 / 3556 / 60; konstantin 5712 / 2760 / 1344; tauri 9152 / 2016 / 1920; amastrianon 1880 / 1292 / 1004;
bovis 1876 / 604 / 580; arkadius 4452 / 864 / 864; markianos 1544 / 288 / 288; myrelaion 1508 / 1136 / 872;
philadelphion 2124 / 1404 / 1212; kapitolion 2504 / 1040 / 180; anemodoulion 1062 / 1038 / 234.
Hepsi lod 0 bütçesinin (60 bin) çok altında. UYARI: lod 1 ≤ %15 hedefi mese, konstantin, amastrianon, myrelaion, philadelphion,
kapitolion, anemodoulion'da tutmuyor (lod 0 zaten küçük olduğu için oran yüksek; mutlak değer ≤ 3,6 bin) ve lod 2 birkaç
öğede 600 üçgenin üstünde (konstantin 1344, tauri 1920, philadelphion 1212, amastrianon 1004).

## Bilinen kusurlar
- mese: denetimde 44 "dar" kaydı (0,25 m; moloz yığınları ile sütun kütükleri arasındaki ince parçalar). Oynanışı engellemez ama temizlenmedi.
- bovis, markianos, philadelphion, myrelaion: birer 0,25–0,5 m'lik küçük dar kayıt; myrelaion'da iki "havada" kaydı (narteks yakını, nedeni bulunamadı).
- lod 1 / lod 2 üçgen hedefleri yukarıdaki gibi aşılıyor; lod 2 yalnız birkaç kutu değil çoğu öğede basitleştirilmiş tam kütle.
- Bronz boğa (bovis) ve devrik figür (anemodoulion) kaba (kutu/küre). Mese 'yıkık bölüm' rastgele tohumla sabit; konum kestirimleri belirsiz.
- Aydınlatma önizlemede aşırı parlak (toon malzeme); renkler oyun sahnesinde farklı görünecek.
- İlk elde: Godot'un `--import` ürettiği `.import`/`.uid` dosyaları depoya EKLENMEDİ.

## Bakamadıklarım
Oyun içi gerçek oyuncu hareketi (gerçek `player.gd` ile yürüyüş), gerçek şehir yerleşimiyle (CityGeo) çakışma/yükseklik farkı,
1,0 ölçeğinde ekran karelerinin tamamı (denetim sayıları var, kareleri tek tek incelemedim), gece/farklı ışık.

## Paftalar (`pafta/`, k = 0,5)
mese (45° kuş bakışı), konstantin (45° ve çatı/merdiven üstü), tauri, arkadius (yerden), markianos (kuş bakışı 15 m),
myrelaion, philadelphion, kapitolion, anemodoulion (yerden), bovis, amastrianon.
