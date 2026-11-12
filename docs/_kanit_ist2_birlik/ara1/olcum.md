# BİRLİK — ara kayıt 1: ölçüm tablosu

Kareler 1280×720; kategori maskesi: kimlik karesi (tests/_ist/birlik_id.gd, oyunla aynı sınıflandırıcı). Ölçücü: tests/_ist/birlik_olc.py.
S: HSV doygunluk (sRGB, ekranda), V: parlaklık; doku: |Laplace|×100 (iç maske); öğe: yüksek geçirgen işaret değişimleri arası ortalama koşu (px); çizgi: maske kenarında V<0,16 oranı; ton: parlaklık çizelgesi tepe sayısı (kaba).

Referans: yayındaki 24, 9, 8, 8y, 4, 12b (oyuncu kamerası, test botu oynarken; arayüz gizli). Not: yayındaki sahnelerde düğümler çoğunlukla adsız; sınıflama desen/gölgelendirici/NPC betiği/kumaş rengiyle — kalan köşe renkli pişmiş ağlar 'yapi' (karışık).

## REFERANS (yayındaki bölümler) (9 kare)
| kategori | piksel | S ort | S %95 | V %5 | V %50 | V %95 | doku (|∇²|×100) | öğe (px) | çizgi | ton |
|---|---|---|---|---|---|---|---|---|---|---|
| tas | 2336941 | 0.48 | 0.73 | 0.26 | 0.55 | 0.82 | 2.7 | 12.4 | 0.07 | 1.5 |
| siva | 35597 | 0.33 | 0.52 | 0.33 | 0.71 | 0.83 | 4.1 | 7.9 | 0.00 | 2.0 |
| kiremit | 87675 | 0.78 | 0.87 | 0.49 | 0.64 | 0.92 | 2.1 | 12.2 | 0.02 | 1.2 |
| ahsap | 805661 | 0.49 | 0.78 | 0.24 | 0.58 | 0.80 | 2.8 | 10.8 | 0.09 | 3.2 |
| zemin | 1033437 | 0.41 | 0.58 | 0.24 | 0.42 | 0.59 | 2.6 | 10.2 | 0.04 | 1.3 |
| bitki | 65169 | 0.81 | 0.96 | 0.28 | 0.34 | 0.47 | 0.9 | 24.9 | 0.07 | 1.1 |
| kumas | 6993 | 0.41 | 0.71 | 0.11 | 0.52 | 0.95 | 6.6 | 15.3 | 0.14 | 2.0 |
| kisi | 242719 | 0.54 | 0.85 | 0.23 | 0.41 | 0.99 | 2.7 | 8.3 | 0.09 | 1.2 |
| yapi | 1565430 | 0.47 | 0.83 | 0.25 | 0.67 | 0.92 | 4.5 | 10.0 | 0.11 | 1.3 |

## v2 ÖNCE (sahibin 4 kamerası) (4 kare)
| kategori | piksel | S ort | S %95 | V %5 | V %50 | V %95 | doku (|∇²|×100) | öğe (px) | çizgi | ton |
|---|---|---|---|---|---|---|---|---|---|---|
| tas | 794023 | 0.25 | 0.48 | 0.14 | 0.29 | 0.62 | 4.2 | 10.9 | 0.11 | 1.3 |
| ahsap | 7150 | 0.64 | 0.81 | 0.17 | 0.36 | 0.68 | 3.3 | 9.3 | 0.10 | 1.0 |
| zemin | 1406578 | 0.32 | 0.37 | 0.46 | 0.55 | 0.60 | 1.0 | 13.2 | 0.00 | 1.2 |
| kumas | 30946 | 0.27 | 0.72 | 0.51 | 0.86 | 1.00 | 5.7 | 10.4 | 0.00 | 1.7 |
| yapi | 14300 | 0.42 | 0.72 | 0.06 | 0.37 | 0.77 | 8.2 | 8.7 | 0.17 | 3.4 |

## v2 SONRA-1 (sahibin 4 kamerası; ilk ayar) (4 kare)
| kategori | piksel | S ort | S %95 | V %5 | V %50 | V %95 | doku (|∇²|×100) | öğe (px) | çizgi | ton |
|---|---|---|---|---|---|---|---|---|---|---|
| tas | 800321 | 0.22 | 0.36 | 0.24 | 0.34 | 0.72 | 3.5 | 10.3 | 0.01 | 1.0 |
| ahsap | 7210 | 0.63 | 0.77 | 0.25 | 0.37 | 0.64 | 3.1 | 9.1 | 0.11 | 1.0 |
| zemin | 1409911 | 0.32 | 0.38 | 0.45 | 0.55 | 0.60 | 1.2 | 14.6 | 0.00 | 1.2 |
| kumas | 21258 | 0.35 | 0.68 | 0.65 | 0.95 | 1.00 | 10.5 | 12.7 | 0.00 | 1.0 |
| yapi | 14340 | 0.43 | 0.74 | 0.05 | 0.35 | 0.75 | 8.2 | 8.9 | 0.18 | 3.2 |

## Fark (ilk okuma)
- Sur taşı: referans S 0,48 / V-orta 0,55 (sıcak, aydınlık kesme taş); v2 S 0,25 / V 0,29 (gri, koyu, gölgede mavi). Doku enerjisi v2 4,2 → 3,5 (referans 2,7): dama gürültüsü indi, hâlâ fazla.
- Zemin: referans V-orta 0,42, doku 2,6; v2 0,55 ve 1,0 (açık, bulanık halı). → zemin ayrıntısı ×1,8, döşeme 2,4 m, tavan V 0,64.
- Kumaş: v2 ÖNCE V%95 1,00 (saf beyaz) ve S%95 0,72 (mavi/kırmızı düz çadır); SONRA-1 S%95 0,68 ama yeni alaçık güneşte V-orta 0,95 → kumaş tavanı 0,84 → 0,74.
- Çizim çağrısı: sahip_03 1243 → 1243, sahip_04 1194 → 1194, s3_hendek 1733 → 1733, hendek_kenar_05 1608 → 1617 (+%0,6); üçgen +%0,2–0,4 (alaçık ağı).
