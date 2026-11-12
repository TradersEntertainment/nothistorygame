# BAĞLAMA-4 — RINFO (çizim / üçgen, yükleme, takılma)

Hepsi xvfb (yazılımla çizim, llvmpipe) 1280×720, oyunun sayaçları (`RenderingServer` kare toplamı: çizim çağrısı,
ilkel); aynı bölüm, aynı an (bölüm açılışından ~14 sn sonra), aynı yerel bakış. ÖNCE = eski dünya (`--eski-dunya`),
SONRA = v2 (bu dalın son kodu). Ölçüm sırasında makinede 2 başsız test koşusu da vardı (yükleme süreleri şişkin).

## 1. Bölüm 12b hub (tests/_ist/hub_kare, `pafta_12b_hub.jpg`)

| bakış | ÖNCE çizim | ÖNCE üçgen | SONRA çizim | SONRA üçgen |
|---|---|---|---|---|
| 01 cadde_sura (yerde, sura) | 11 197 | 9,65 M | 10 427 | 4,59 M |
| 02 sur_ici_kapiya (yerde) | 4 900 | 7,00 M | 3 633 | 2,84 M |
| 03 surdan_sehre (14 m) | 7 017 | 5,05 M | 6 718 | 5,20 M |
| 04 tepeden_sura (45 m) | 11 303 | 8,50 M | 10 601 | 4,34 M |
| 05 disaridan_sur (25 m) | 5 831 | 2,84 M | 6 973 | 3,74 M |
| 06 disaridan_sehre (55 m) | 6 264 | 3,27 M | 7 625 | 3,93 M |

Hüküm: yerde bütçe (≤ 1 200 çizim / 2,5 M) ÖNCE'de de SONRA'da da AŞILIYOR; kaynak bölümün kendi hub'ı (ByzCity:
üçüncü turda ölçülen ~5 870 çizim tek başına). Çizim 4 bakışta azaldı, 2 bakışta arttı (+%20, +%22: dışarıdan
bakışta v2 surları ve ordugâhı); üçgen 4 bakışta azaldı, 2'de arttı (+%19–32). "Çizim artmaz, üçgen ≤ +%8" kuralı
05 ve 06 bakışında SAĞLANMIYOR (yalnız sur dışı/üstten bakışlar; oyuncu bu bölümde surun dışına çıkmaz).

Yükleme (bölüm sahnesinin eklenmesinden ilk kareye, xvfb, yük altında): ÖNCE 29,6 sn · SONRA 49,5 sn. v2 kurulumunun
kırılımı: `ISTDUNYA kurulum_ms=754`, `ISTSEHIR2 kur_ms=3515 hat_ms=1186 doku_ms=25854 parca_ms=10653`,
`ISTBAGLAMA kurulum_ms=42595` (yük altında; DOKU-4'ün yükleme işi bu ölçümden önceki birleşimde yoktu).

Takılma (> 50 ms kare) hub'da: ÖLÇÜLMEDİ (KANITSIZ).

## 2. Bölüm 11 (ordugâh, gece; tests/_ist/baglama_ucus kip=kare en_cok=1)

| bakış | ÖNCE çizim | ÖNCE üçgen | SONRA çizim | SONRA üçgen |
|---|---|---|---|---|
| 01 kalkış (kapının 8 m üstü) | 4 399 | 5,97 M | 2 170 | 3,91 M |
| 02 ordugâhın üstü (60 m) | 3 830 | 3,37 M | 4 222 | 2,10 M |
| 03 şehrin üstü | 1 155 | 1,11 M | 1 023 | 2,00 M |
| 04 Ayasofya'ya yaklaşma | 595 | 0,66 M | 1 011 | 1,30 M |
| 05 Galata'dan dönüş | 5 883 | 8,14 M | 811 | 2,61 M |
| 06 eve dönüş (25 m) | 3 203 | 3,95 M | 3 833 | 1,89 M |

Hüküm: uçuşta bütçe (≤ 1 500 / 3,5 M) SONRA'da 03, 04, 05'te içinde; 01 (2 170 / 3,9 M), 02 (4 222), 06 (3 833) ordugâhın
içinde/üstünde aşıyor (bölümün kendi CampDay ordugâhı + v2 ordugâhı; ÖNCE'de de aşıyordu: 4 399 / 3 830 / 3 203).
Üçüncü turda 02 bakışı 12 483 çizimdi (v2 gece katmanı 8 956): ORDUGÂH-4'ün birleşik ağlarıyla 4 222.

Yükleme (xvfb, yük altında): ÖNCE 16,7 sn · SONRA 48,7 sn (`ISTBAGLAMA kurulum_ms=41922`). Açılıştan sonraki 20 sn'de
> 50 ms kare: ÖNCE 149/149 (en uzun 5,2 sn) · SONRA 149/149 (en uzun 3,0 sn) — xvfb yazılım çiziminde her kare 50 ms'yi
aşıyor, bu sayı ayırt edici DEĞİL (gerçek ekran kartıyla ölçüm BAKILMADI). Uçuş evresi takılması bu koşuda ölçülmedi
(`kip=kare`; KANITSIZ).
