# İstanbul, Nisan 1453: güneybatı parçası (rapor)

Dal: `wip/ist-guneybati`. Dosyalar: `scripts/world/ist/guneybati.gd` (`IstGuneybati`: `catalog()`, `build_<id>`, `perches_<id>`,
`climbs_<id>`, ayrıca `build(id, …)` dağıtıcı), `scripts/world/ist/guneybati_kit.gd` (`IstGbKit`, ortak yapı taşları),
`tests/_ist/guneybati_onizleme.{gd,tscn}`, bu klasör. Var olan hiçbir dosya değiştirilmedi.

Durum özeti: **ilk tur, kaba+ düzey**. Bütün öğeler kuruluyor, çarpışmalı, tırmanılabilir ve denetimden geçiyor. Görsel ayrıntı
(doku, dekor) hedefin altında; "bilinen kusurlar" bölümüne bakın. Süre kısıtı yüzünden üç değil, denetim odaklı yaklaşık dört
düzeltme turu yapıldı (merdiven/sandık yönü, dar aralık, havada kütle, üçgen bütçesi); görsel turlar sınırlı kaldı.

## 1. Araştırma özeti (kaynaklı)

Araştırma kısa tutuldu (WebSearch iki sorgu). Kalanı genel bilgi; belirsizler işaretli.

- **Studios (Stoudios) Manastırı**: 5. yy. üç nefli bazilika; batıda üç bölmeli narteks ve revaklı atrium, doğuda tek apsis.
  Toplam taban yaklaşık 40 × 26 m (tek kaynak). Kilisenin güneyinde yamuk biçimli sarnıç: kenarlar yaklaşık 18,6 / 16,65 × 26,4 m,
  24 granit sütun (6 × 4), Korint başlıklı. Kaynaklar kuruluş tarihinde ayrışıyor (453 / 462).
  Kaynak: thebyzantinelegacy.com/stoudios, Wikipedia "Monastery of Stoudios", ancient-history-sites.com. Kilise sonradan İmrahor Camii
  (Aya Ioannes / İmrahor aynı yapı) oldu; 1453'teki tam durumu **BELİRSİZ**. `harap` işaretlendi (kestirim).
- **Mokios sarnıcı**: Anastasios dönemi (491–518), yaklaşık 170 × 147 × 12 m; 626 Avar kuşatmasından sonra işlevini yitirmiş;
  açık sarnıçlar Latin dönemi sonrası çukur bahçe (çukurbostan) olarak kullanıldı.
  Kaynak: thebyzantinelegacy.com/mocius-cistern ve /cisterns, istanbul-su.rich.ru.nl. 1453'teki ekin türleri **kestirim**.
- Peribleptos, Aziz Andreas (Krisei), Aziz Diomedes, Psamathia, Altın Kapı kalesi, Lykos değirmen ve köprüsü, bağ: **araştırılmadı**;
  ölçüler ve düzen tamamen **kestirim** (kapalı haç planlı kubbeli kilise tipi, mahalle ölçeği). Altın Kapı kalesinin (1390–91,
  Yedikule'nin öncülü) yalnız kalıntı olduğu görev tanımından alındı. Yel değirmeni yapılmadı (görev kuralı).
- Konumlar (`dogu_m`, `kuzey_m`) **KESTİRİM**; şehir kurucusu `CityGeo` ve `ISTANBUL_YERLER.csv` ile düzeltmeli.
- Anakronizm denetimi: minare, cam, vapur vb. yok; çan kulesi yapılmadı (1453 Bizans kilisesinde belirsiz).

## 2. Oyuncu ölçüleri

`JUMP = 3.6`, yerçekimi 9.8 → zıplama yüksekliği 3.6² / (2·9.8) = **0,66 m**; `STEP_H = 0,42 m`. Merdiven basamağı 0,24–0,26 m,
sandık basamağı ≤ 0,4 m, kapı 2,3 m, korkuluk 1,0 m, yürüme yolu ≥ 1,4 m, kapı açıklığı 1,7 m. Bunlar k'den bağımsız.

## 3. Öğe listesi

| id | ne | durum |
|---|---|---|
| studios | bazilika (yan nef çatıları, nave çatısı, apsis), narteks, sütunlu atrium + çeşme, hücre sırası, sarnıç | KABA+ |
| peribleptos | kubbeli haç planlı kilise + avlu duvarı, servi | KABA+ |
| andreas | kubbeli kilise (Krisei) | KABA+ |
| mokios | duvarlı çukur bostan, tarhlar, kuyu, kulübe, iç merdiven, dış merdiven | KABA+ |
| psamathia | 6 ev, kuyu, ağ direkleri, kayık, amfora | KABA |
| altinkapi | üç geçitli mermer kapı bloğu, yıkık kule kütükleri, dış merdivenler | KABA |
| diomedes | küçük bazilika, apsis | KABA |
| degirmen | su değirmeni, çark, su şeridi | KABA |
| kopru | Lykos taş köprüsü (rampalı) | KABA |
| bag | omca sıraları, kuru taş duvar, bekçi kulübesi | KABA |
| Aya Ioannes (İmrahor) | Studios kilisesi ile aynı yapı, ayrı öğe yok | — |

## 4. ISTAUDIT (son koşu; arka plan: Godot 4.4.1, xvfb)

Aşağıdaki satırlar `tests/_ist/guneybati_onizleme.tscn` çıktısıdır. `lod=1` aynı kodu "lite" bayrağıyla (pencere, kiremit sırası,
kubbe dilimi, ekin kapalı) kurar; `lod=2` yalnız siluet kütlesidir (çarpışma var, tırmanma yolu yok).

```
studios      k=0.5  lod0 tris=7300   draws=252 delik=0 dar=0 havada=0 cati_yolu=4/4
studios      k=0.35 lod0 tris=5932   draws=218 delik=0 dar=0 havada=0 cati_yolu=4/4
studios      k=1.0  lod0 tris=14628  draws=438 delik=0 dar=1 havada=0 cati_yolu=4/4
studios      k=0.5  lod1 tris=4700   lod2 tris=20
peribleptos  k=0.5  lod0 tris=5422   delik=0 dar=0 havada=0 cati_yolu=3/3   (k=0.35: 3/3, k=1.0: 3/3)   lod1 1738, lod2 100
andreas      k=0.5  lod0 tris=4924   delik=0 dar=0 havada=0 cati_yolu=2/2   (k=0.35, 1.0: 2/2)         lod1 1168, lod2 100
mokios       k=0.5  lod0 tris=34808  delik=0 dar=0 havada=0 cati_yolu=2/2   (k=0.35: 14960)           lod1 2312, lod2 60
psamathia    k=0.5  lod0 tris=2492   delik=0 dar=0 havada=0 cati_yolu=2/2   (k=0.35, 1.0: 2/2)         lod1 1508, lod2 120
altinkapi    k=0.5  lod0 tris=2048   delik=0 dar=0 havada=3* cati_yolu=2/2  (k=0.35, 1.0: 2/2)         lod1 2048, lod2 36
diomedes     k=0.5  lod0 tris=1002   delik=0 dar=0 havada=0 cati_yolu=1/1   (k=0.35, 1.0: 1/1)         lod1 502, lod2 20
degirmen     k=0.5  lod0 tris=752    delik=0 dar=0 havada=0 cati_yolu=1/1   (k=0.35, 1.0: 1/1)         lod1 472, lod2 20
kopru        k=0.5  lod0 tris=408    delik=0 dar=0 havada=0 cati_yolu=2/2   (k=0.35, 1.0: 2/2)         lod1 408, lod2 12
bag          k=0.5  lod0 tris=1380   delik=0 dar=0 havada=0 cati_yolu=1/1   (k=0.35: 1/1, k=1.0: 7524) lod1 1308, lod2 12
```

Notlar:
- `*` Altın Kapı `havada=3`: üç geçidin lentosu; kutu açıklığı tam örttüğü için köşe ışınları alttaki boşluğu görüyor
  (yapısal olarak iki yanındaki duvarlara oturur). **Yanlış alarm**, ama otomatik denetim bunu ayıramıyor.
- Mokios k=1.0 (son koşu): `tris=73784 draws=170 delik=1 dar=0 havada=0 cati_yolu=2/2`; büyük külliye sınırı (150 000) içinde.
  `delik=1`: kapı üstündeki dekoratif taş lento kutusu (çarpışmasız görsel; duvar lentosunun önüne 0,1 m taşar). Bilinen küçük kusur.
- lod 1 ≤ %15 hedefi **çoğunda karşılanmadı**: lod 1 yalnız ayrıntıyı kısıyor (Studios %64, Peribleptos %32, Andreas %24, Mokios %7 ✓.).
  Altın Kapı, Köprü lod 1'de lod 0 ile aynı. Kabul edilebilir bir ara sürüm için ayrı lod 1 kütle kodu gerekir.
- Denetim sınırları: `delik` yalnız dönmemiş büyük kutu ağlarını örnekler; `dar` 1 m ızgarada ayak yüksekliği yatay ışınlardır;
  `havada` yalnız eksen hizalı kutu şekillerini ve 5 örnek noktayı denetler; `cati_yolu` test gövdesi (kapsül 0,35 × 1,8, g 9,8,
  zıplama 3,6, 0,42 m basamak yükseltmesi) bir `climbs` çiftinin tepesine (2,2 m yatay, ≥ yükseklik − 0,35) varabilir mi diye bakar.
  Oyunun asıl `player.gd` / `traversal.gd` kodu çalıştırılmadı.

## 5. Ayırt edici ayrıntılar (anıt başına ≥ 5 hedefi; görsel doğrulanan işaretli)

- Studios: tuğla-taş kuşaklı yan duvarlar; iki katlı nef çatısı (yan nef eğik çatısı + yüksek nave çatısı + üst pencere sırası);
  tek apsis; narteks cephesinde kör kemerler; atrium revağı ve ortada çeşme (phiale); hücre sırası; sarnıç (kırık sütunlu açık depo).
- Peribleptos / Andreas: kasnaklı, dilimli kurşun kubbe, haç; haç biçimli çatı kolları; kuşaklı tuğla duvar; apsis; narteks.
- Mokios: 2,2 m kalın duvar, iki yanı korkuluklu yürüme yolu, payandalar, tarhlar ve ekin sıraları, kuyu çıkrığı.
- Diğerleri: kaba (ayrıntı sayısı hedefin altında).

## 6. Bilinen kusurlar (dürüst liste)

1. Dokular genel `Props` desenleri; Studios atrium duvarları düz beyaz, boş görünüyor. Kubbe dilimleri yaklaşık.
2. Nihat için `bakis` / `bakis_r` / `gorev` kaydı var, ama "üst yüzeyler bitmiş" şartı yalnız Studios, Peribleptos, Andreas
   için kısmen sağlandı. Altın Kapı, Psamathia, Diomedes, değirmen, köprü, bağın üst yüzeyi basit.
3. Gerçek `player.gd` ile elle oynama sınaması yapılmadı. Tırmanma güvencesi yalnız kendi test gövdemizden.
4. Mokios çukuru yerine duvarlı set kuruldu (zemin deliği açılamaz). Şehir kurucusu isterse zemini kesip tabanı −D'ye indirmelidir.
5. Perde/kiremit sıraları ve sütunlar tek tek düğüm; MultiMesh yalnız tarh/ekin/omca/kazıkta kullanıldı.
6. lod 1 hedefi karşılanmadı (yukarıya bakın). Altın Kapı ve köprü için lod 1 = lod 0.
7. Su şeridi (değirmen, köprü) çarpışmasız ince kutu; üstünde yürünür.
8. Psamathia: evlerin iç mekânı boş; Studios iç mekânı (sütun, altar) çıplak.
9. Konumlar ve çoğu ölçü kestirim.

## 7. Bakılamayanlar

lod 1 karelerine, k=0,35 / 1,0 karelerine ve çatı gözü karelerinin çoğuna bakmadım (yalnız sayısal denetim); geceleyin ışık/ateş (`Flame` hiç kullanılmadı).

## 8. Paftalar (`pafta/`, JPEG)

Studios (uçuş, yerden, kuş bakışı 60 m, tepe), Peribleptos, Andreas (tırmanış), Mokios (uçuş, yerden), Psamathia,
Altın Kapı, değirmen, köprü; hepsi k = 0,5, lod 0.
