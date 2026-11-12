# İstanbul, Nisan 1453 — hipodrom parçası raporu

Dal: `wip/ist-hipodrom`. Dosyalar: `scripts/world/ist/hipodrom*.gd` (kit, hipodrom, saray, aug), `tests/_ist/hipodrom_onizleme.*`.
Kurucu giriş noktası: `IstHipodrom.catalog()`, `IstHipodrom.build(id, host, k, lod)`, `perches(id, k)`, `climbs(id, k)`
(her yapı için ayrıca `build_<id>` / `perches_<id>` / `climbs_<id>` statik işlevleri var).

## Araştırma özeti (kısa; ayrıntılı ölçü yok → kestirim işaretli)
- Hipodrom: Septimius Severus'tan Konstantinos'a genişletilmiş at yarışı pisti; uzun ekseni KD–GB, kuzeyde carceres,
  güneyde kavisli sphendone. 1453'te oturma sıraları büyük oranda sökülmüş/çökmüş, sphendone altyapısı ayaktaydı;
  Panvinio'nun 1580 gravürü geç Paleologos dönemi harabe görünümüne dayanır (cavac.at/Hippodrome of Constantinople,
  Reinach/MOM derlemesi). Spina üstünde: Teodosius Dikilitaşı (Thutmose III, 390), Yılanlı Sütun (Delphi, 479 BC; üç
  başı 1700'de kayboldu, yani 1453'te vardı), Örme Dikilitaş (Konstantinos Porphyrogennetos, 10. yy; bronz levhaları
  1204'te sökülmüş). Ölçüler (117 × ~430 m, pist yarı genişliği 36 m, oturma sırası sayısı) KESTİRİM.
- Iustinianus Sütunu: tuğla çekirdek üstü bronz levha kaplama (1204 sonrası sökülmüş), tepede atlı heykel; yükseklik
  kaynaklarda çelişkili (Buondelmonti 70 m; modern tahmin ~35 m) → 35 m KESTİRİM. Heykel 1450'lerde yerindeydi
  (Wikipedia/Column of Justinian, byzantinemilitary.blogspot, thebyzantinelegacy.com).
- Büyük Saray: terasları ve salonları harap/bostan; konumlar ve ölçüler KESTİRİM. Khalke, Milion, Zeuksippos, Nea,
  Aya İrini, Aya Sergios-Bakhos konumları yaklaşık (BELİRSİZ: ±50 m).
- Anakronizm denetimi: minare, cami, cam, asfalt yok.

## Oynanış rakamları (player.gd / traversal.gd'den)
`JUMP = 3,6`, yerçekimi 9,8 → zıplama yüksekliği = 3,6² / (2 × 9,8) ≈ **0,66 m**. `STEP_H = 0,42` (zıplamadan çıkılan
basamak). `Traversal.REACH = 2,3` (tutunulabilen kenar), `VAULT_MAX = 1,1`. Bütün basamaklar 0,4 m (≤ 0,42).

## Öğe listesi
| id | ne | durum |
|---|---|---|
| hipodrom | pist, iki yan oturma basamağı (yıkık), sphendone (14 dilim), carceres + kuleler, spina (Dikilitaş, Yılanlı Sütun, Örme Dikilitaş, sütunlar, meta), kathisma kalıntısı, dış basamaklar, hayvanlar | KABA+ (ana kütle ve ayrıntılar var; doku/ayrıntı derinleştirilmeli) |
| buyuk_saray | üç yıkık salon, mozaik parçaları, kemerli teras, bostan sıraları, sütunlar | KABA+ |
| khalke | kapı kütlesi, bronz çerçeve izi, ikon boşluğu, yıkık tonoz tepe | KABA+ |
| zeuksippos | ana hol (kaburga kemerleri), caldarium, havuz | KABA |
| nea | haç planlı kilise, 4 köşe kubbesi (biri çökmüş), moloz | KABA+ |
| augustaion | meydan, Iustinianus Sütunu (bronz yamalar, atlı heykel), stoa kütükleri, kuyu | TAMAM (ilk tur) |
| milion | dört kemerli tetrapylon kalıntısı, ölçü taşı | KABA+ |
| aya_irini | bazilika + kubbe + atrium | KABA+ |
| sergios | sekizgen kubbeli kilise, narthex, apsis | KABA+ |

## Denetim (ISTAUDIT, lod 0)
```
ISTAUDIT id=hipodrom tris=15544 draws=0 delik=0 dar=0 havada=1 cati_yolu=5/5 ["@StaticBody3D@1629@(0.0, 4.3, -34.4)"]
ISTAUDIT id=buyuk_saray tris=9440 draws=758 delik=0 dar=0 havada=0 cati_yolu=2/2 []
ISTAUDIT id=khalke tris=1136 draws=137 delik=0 dar=0 havada=2 cati_yolu=1/1 ["@StaticBody3D@4255@(0.0, 6.5, 6.2)", "@StaticBody3D@4273@(0.0, 9.5, 0.0)"]
ISTAUDIT id=zeuksippos tris=1636 draws=299 delik=0 dar=2 havada=2 cati_yolu=1/1 ["@StaticBody3D@4594@(0.0, 6.7, -9.900001)", "@StaticBody3D@4603@(0.0, 6.7, -3.1)"]
ISTAUDIT id=nea tris=3652 draws=423 delik=0 dar=0 havada=2 cati_yolu=1/1 ["@StaticBody3D@4735@(0.0, 4.8, 8.900001)", "Roof2@(3.7, 8.400001, 0.0)"]
ISTAUDIT id=augustaion tris=3212 draws=352 delik=0 dar=0 havada=1 cati_yolu=2/2 ["@StaticBody3D@5108@(0.0, 22.6, 0.0)"]
ISTAUDIT id=milion tris=920 draws=133 delik=0 dar=0 havada=5 cati_yolu=1/1 ["@StaticBody3D@5445@(0.0, 5.2, 3.0)", "@StaticBody3D@5448@(3.0, 5.2, 0.0)", "@StaticBody3D@5451@(0.0, 5.2, -3.0)", "@StaticBody3D@5454@(-3.0, 5.2, 0.0)", 
ISTAUDIT id=aya_irini tris=2276 draws=369 delik=0 dar=0 havada=2 cati_yolu=1/1 ["@StaticBody3D@5641@(0.0, 5.3, 15.1)", "Roof2@(4.0, 9.5, 0.0)"]
ISTAUDIT id=sergios tris=2136 draws=349 delik=0 dar=2 havada=1 cati_yolu=2/2 ["@StaticBody3D@5949@(0.0, 5.1, 8.1)"]
```

k = 0,35 ve k = 1,0 denetimi (tüm yapılar): delik = 0; dar ≤ 10 (zeuksippos k=1,0: 10 — duvar/basamak köşeleri, aya_irini 4–6 — payanda aralıkları); tırmanma yolu hepsi geçti; kayıtlar docs içinde değil, koşu çıktısı: `ist=all k=<k>`.

`havada` satırlarının tamamı yanlış alarm: bronz levha/üst levha dört küpün (ya da payandanın) KENARINA oturur, merkezden
ışın boşluğa düşer. `dar` ≈ 2: sergios apsisi ile sekizgen duvar arasındaki üçgen köşeler (kusur, aşağıda).
Üçgen sayıları: lod 0 hipodrom ≈ 15,5 bin (k=0,5) / 27,5 bin (k=1,0); diğerleri 0,9–9,4 bin (bütçe 60 bin altında).
lod 1 / lod 2 sayıları ve kareleri: `ISTBUILD` satırları; lod 2 birkaç kutu/kubbe (≤ 600).

## Bilinen kusurlar / yapılacaklar
- Hipodrom: oturma sıraları düz renk + `ashlar` deseni; kemer boşlukları düz koyu kutu; atlı heykel ve at/koyun çok kaba.
- Bütün kiliselerde pencere/kapı ayrıntısı sade; Aya İrini atrium sütunları rastgele kütük.
- Kubbe kaburgaları ince çıta (hafif taşıyor).
- Sergios: apsis ile sekizgen arası dar köşe (0,2–1,4 m) var.
- MultiMesh yalnız ot/moloz için; kiremit sıraları desenle yapıldı (kiremit ayrıntısı yok).
- Bakılamayan: lod 1/2 kareleri ve k=0,35 / 1,0 görsel turu (yalnız denetim koştu).
- Konumlar (dogu_m/kuzey_m) ve yön KESTİRİM.

## Paftalar
`hipodrom_k050_kus60.jpg` (60 m kuş bakışı), `…kus15` (15 m), `…ust_goz`, `…yaklasma_D`, `buyuk_saray_…`, `augustaion_…`,
`khalke_…`, `zeuksippos_…`, `nea_…`, `milion_…`, `sergios_…`, `aya_irini_…`.
