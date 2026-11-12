# Kuzeybati (Khora, Pammakaristos, Tekfur, Blakhernai çevresi) — rapor

Dal: `wip/ist-kuzeybati`. Dosyalar: `scripts/world/ist/kuzeybati*.gd`, `tests/_ist/kuzeybati_onizleme.{gd,tscn}`.
Aşağıdaki "Denetim" bölümü son koşudan doldurulur (aşağıya bakın). Araştırma özeti: `arastirma.md` (kaynaklı).

## Arayüz notları (şehir kurucusu için)
- Giriş: `IstKuzeybati.catalog()`, `IstKuzeybati.build(id, host, k, lod)`, `perches(id, k)`, `climbs(id, k)`.
  Ayrıca her öğe için `build_<id>`, `perches_<id>`, `climbs_<id>` (sınıflar: `IstKbKilise`, `IstKbSaray`, `IstKbSemt`).
- Yerel çerçeve PUSULA HİZALIDIR (+x doğu, -z kuzey); yapının `yon_derece` dönüşü kurucu içinde uygulanmıştır
  (pivot). Yerleştirici yalnız şehrin pusula→dünya dönüşümünü uygular; `yon_derece` bilgi amaçlıdır.
- `perches_*` ve `climbs_*` kurucudan toplanır (`IstKbCtx.harvest`); önbelleklidir.
- k yalnız kütleyi ölçekler; kapı, basamak (≤ 0,34 m), sandık (≤ 0,6 m), siperlik (1,1 m), mazgal, tezgâh sabit boydadır.
  Kaligaria evleri k < 0,7 iken tek kat, taban en az 0,7 ölçeğinde (insan ölçüsü alt sınırı).
- Oyuncu sınırları: JUMP 3,6 m/sn, g 9,8 → zıplama 0,66 m; STEP_H 0,42 m; tutunma REACH 2,3 m.

## Öğeler
| id | ne | durum |
|---|---|---|
| khora | Kariye: naos + 6 kubbe, parekklesion, iki nartheks, apsisler, payandalar | TAMAM (ayrıntı derinleştirilebilir) |
| pammakaristos | ana kilise + beş kubbeli parekklesion, dolaşma yolu | TAMAM |
| tekfur | üç katlı saray, mermer revak, tuğla geometrik cephe, sur kesiti, kuleler | TAMAM (turret→çatı yolu k ≤ 0,5'te başarısız) |
| anemas | sekizgen kule, kareli kule, tonozlu zindan taraçası | TAMAM |
| blakhernai_kilise | 1434 yangın harabesi + ayazma | TAMAM |
| petra | küçük çapraz-kare manastır + avlu duvarı | TAMAM |
| aetios | açık sarnıç bostanı (244 × 85 m, MultiMesh sebze/bağ) | TAMAM |
| kaligaria | iki sıra ayakkabıcı dükkânı, sundurma, tezgâh | KABA-TAMAM |
| kynegion | yıkık eliptik arena (bitişik kademeler) | KABA-TAMAM |
| ayvansaray_iskele | rıhtım, ahşap iskele, kayıklar, fener | KABA-TAMAM |

## Bilinen kusurlar
- `dar` (0,2–1,4 m girilebilir aralık) sayıları sıfır değil: Blakhernai (6–7), Kynegion (5–6), Kaligaria (2–6),
  Pammakaristos (2–3), Petra (≤ 4), Tekfur (≤ 4), Khora (≤ 3). Çoğu moloz/duvar-ağaç gövdesi arası dar yarıklar.
- Tekfur: sur kuleli yürüme yolundan saray çatısına sandık yolu k = 0,35 ve 0,5'te hedefe 0,7 m kala takılıyor (1,0'da geçiyor).
- Kynegion ve Aetios'ta lod 1 ≈ lod 0 (kasıtlı basit); büyük anıtlarda lod 1 oranı hedef %15'in üstünde olabilir.
- Su (iskele) ince saydam levha, yürünebilir sığ su; deniz seviyesi şehir kurucusuna bağlı.
- Önizleme zemini düz; yamaç (Haliç eğimi) yok: Aetios taban/çevre set yüksekliği şehir arazisine uydurulmalı.
- Nihat bakış noktaları `catalog()` içinde (`bakis`, `bakis_r`, `gorev`); kubbe tepelerinde katı fener var.

## Denetim (son koşu, k = 0,5, lod 0; `ISTAUDIT`)
```
ISTAUDIT id=khora k=0.5 tris=11850/2678/1580 draws=409 delik=0 dar=1 havada=0 cati_yolu=3/3
ISTAUDIT id=tekfur k=0.5 tris=5694/468/432 draws=333 delik=0 dar=3 havada=0 cati_yolu=2/3
ISTAUDIT id=pammakaristos k=0.5 tris=12682/3182/1720 draws=402 delik=0 dar=2 havada=0 cati_yolu=2/2
ISTAUDIT id=anemas k=0.5 tris=3338/818/384 draws=209 delik=0 dar=0 havada=0 cati_yolu=2/2
ISTAUDIT id=aetios k=0.5 tris=67380/276/240 draws=279 delik=0 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=kaligaria k=0.5 tris=2388/356/356 draws=389 delik=0 dar=2 havada=0 cati_yolu=1/1
ISTAUDIT id=petra k=0.5 tris=2980/912/544 draws=177 delik=0 dar=2 havada=0 cati_yolu=2/2
ISTAUDIT id=blakhernai_kilise k=0.5 tris=2150/2090/1724 draws=254 delik=0 dar=13 havada=0 cati_yolu=1/1
ISTAUDIT id=kynegion k=0.5 tris=2294/2294/2028 draws=520 delik=0 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=ayvansaray_iskele k=0.5 tris=2240/148/36 draws=209 delik=0 dar=0 havada=0 cati_yolu=1/1
```
Üçgenler lod 0/1/2. Hepsi bütçe içinde (lod 0 ≤ 60 bin; Aetios 67 bin: tek çok büyük alan, 150 bin sınırının altında).
Aetios k = 1,0'da 133 bin üçgen. Tırmanma yolları: k = 1,0'da 10 öğenin 9'unda tamam, Petra'daki iki yol o turdan sonra
düzeltildi ve yeniden sayılmadı. k = 0,35'te Khora'nın üç yolu düzeltmeden sonra geçti; Tekfur'un turret→çatı yolu
k = 0,35 ve 0,5'te başarısız (1,0'da geçti).

Denetim tanımları (önizleme betiğinde): `delik` = görünür büyük ağın merkezi hiçbir çarpışma şeklinde değil (bitki ve su
levhası hariç); `dar` = y = 0,7 ve 1,3 m'de iki katı arası 0,2–1,4 m yatay aralık (0,5 m ızgara); `havada` = gövde tabanının
altında > 5 cm boşluk ve komşu gövdeye de değmiyor; `cati_yolu` = gerçek CharacterBody3D (yarıçap 0,3, boy 1,8) ile
yürü / 0,42 basamak / 0,65 zıpla simülasyonu. Not: `climbs_*` kurucudan toplanır, dolayısıyla yollar çizilen merdiven ve
sandıklarla birebir tutarlıdır.

## Ayırt edici ayrıntılar (Nihat için, eser başına ≥ 5)
- Khora: dilimli 7,7 m ana kubbe + 16 pencereli kasnak; iki nartheks kubbeli; üç apsis yarım kubbeli; tuğla-taş bantlı
  cephe; parekklesion kubbesi ve payandalar; kubbe tepelerinde haç.
- Pammakaristos: ana kubbe + beş küçük kubbe; tekfur-desenli cephe; üç apsis; payandalı parekklesion; haçlı fenerlikler.
- Tekfur: üç kat, beş kemerli mermer sütunlu revak, kırmızı eşkenar dörtgen rozetler, mermer bantlar, mazgallı sur
  yürüme yolu, iki uç kule, merdiven kulesi.
- Anemas: sekizgen mazgallı yüksek kule, kareli kule, yedi kemerli zindan taraçası (parmaklıklı), siperlikli taraça.
- Blakhernai harabesi: yıkık duvarlar, kolon kalıntıları ve devrik sütun, moloz, ayazma hücresi + havuz, apsis kalıntısı.
- Aetios: 244 m'lik duvar çerçevesi, lahana tarhaları, bağ kazıkları, sulama arkı, kuyu, bostancı kulübeleri, korkuluk.

## Bakamadıklarım
- Oyun içi (gerçek oyuncu fiziği ile) yürüme; yalnız kapsül simülasyonu yapıldı.
- Pafta çekimlerinin bir kısmı (t4 koşusu) eski ışık ayarıyla: havadan kareler solgun; Khora ve Kynegion düzeltilmiş ışıkla.
- lod 1 / lod 2 kareleri her öğe için yazıldı ama hepsini tek tek incelemedim; k = 1,0 ve 0,35 için kare alınmadı (yalnız denetim).
- Şehir kurucusu ile `World1453.landmarks` entegrasyonu (kendi dosyam dışı).

## Paftalar
`pafta_*.jpg` (12 adet): yerden, çatıdan ve havadan.
