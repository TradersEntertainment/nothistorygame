# BAĞLAMA-3: uçuşta çizim / üçgen (oyun içi, HUD'lu kare anı)

xvfb (llvmpipe) 1280×720; sayaçlar oyunun RINFO'suyla aynı (`RenderingServer` kare toplamı: görünür + gölge geçişi). Bütçe uçuşta ≤ 1 500 çizim / 3,5 M üçgen.
Kırılım (SONRA, `kirilim=1`): aynı bakışta v2 kökü gizliyken (yalnız bölüm sahnesi) ve bölüm sahnesi gizliyken (yalnız v2).

## Bölüm 11 (gece, ordugâh)

| bakış | ÖNCE çizim / üçgen | SONRA çizim / üçgen | SONRA kırılım (yalnız sahne / yalnız v2) |
|---|---|---|---|
| kalkis | 4267 / 5.97 M | 2042 / 3.45 M | 1162 / 1170 |
| ordugah_ustu | 3935 / 3.39 M | 12483 / 2.77 M | 3782 / 8956 |
| sehrin_ustu | 1094 / 1.09 M | 992 / 1.58 M | 420 / 1006 |
| eser_ayasofya | 474 / 0.66 M | 794 / 0.95 M |  |
| eser_hipodrom | 639 / 0.72 M | 759 / 1.07 M |  |
| eser_konstantin | 637 / 1.03 M | 1014 / 1.20 M |  |
| eser_havariyun | 937 / 1.14 M | 2378 / 2.29 M |  |
| eser_bozdogan | 860 / 1.08 M | 1512 / 1.96 M |  |
| eser_zincir | 507 / 0.28 M | 910 / 1.03 M |  |
| eser_galata | 611 / 0.29 M | 2092 / 0.94 M |  |
| eser_blakherna | 706 / 1.03 M | 1656 / 0.92 M |  |
| eser_surlar | 2377 / 2.43 M | 1508 / 2.51 M |  |
| eser_tauri | — | 897 / 1.40 M |  |
| eser_arkadius | — | 673 / 0.86 M |  |
| eser_markianos | — | 1219 / 2.37 M |  |
| eser_anemodoulion | — | 864 / 1.55 M |  |
| eser_studios | — | 599 / 0.63 M |  |
| galata_donus | 6161 / 8.16 M | 748 / 2.57 M | 344 / 563 |
| eve_donus | 3447 / 3.96 M | 4291 / 1.58 M | 3536 / 1104 |

## Bölüm 7a (gündüz, ordugâh)

| bakış | ÖNCE çizim / üçgen | SONRA çizim / üçgen | SONRA kırılım (yalnız sahne / yalnız v2) |
|---|---|---|---|
| kalkis | 4530 / 6.33 M | 2175 / 3.36 M | 1363 / 1225 |
| ordugah_ustu | 3953 / 3.22 M | 4301 / 2.55 M | 3624 / 1153 |
| sehrin_ustu | 1002 / 1.09 M | 867 / 1.53 M | 299 / 845 |
| eser_ayasofya | 844 / 0.73 M | 1091 / 0.93 M |  |
| eser_hipodrom | 924 / 0.77 M | 1174 / 1.03 M |  |
| eser_konstantin | 1075 / 1.05 M | 1225 / 1.21 M |  |
| eser_havariyun | 1044 / 1.13 M | 1388 / 2.27 M |  |
| eser_bozdogan | 970 / 1.06 M | 1324 / 2.07 M |  |
| eser_zincir | 631 / 0.26 M | 932 / 0.97 M |  |
| eser_galata | 726 / 0.28 M | 1102 / 0.95 M |  |
| eser_blakherna | 808 / 1.02 M | 956 / 0.93 M |  |
| eser_surlar | 2518 / 2.56 M | 1669 / 2.52 M |  |
| eser_tauri | — | 986 / 1.37 M |  |
| eser_arkadius | — | 1086 / 0.88 M |  |
| eser_markianos | — | 1307 / 2.32 M |  |
| eser_anemodoulion | — | 960 / 1.50 M |  |
| eser_studios | — | 797 / 0.66 M |  |
| galata_donus | 6458 / 8.49 M | 900 / 2.53 M | 490 / 657 |
| eve_donus | 3726 / 3.97 M | 3454 / 1.41 M | 3362 / 364 |

## Bölüm 7b (gündüz, şehir hub'ı)

| bakış | ÖNCE çizim / üçgen | SONRA çizim / üçgen | SONRA kırılım (yalnız sahne / yalnız v2) |
|---|---|---|---|
| kalkis | 1919 / 3.11 M | 2297 / 3.18 M | 1593 / 1082 |
| ordugah_ustu | 7206 / 6.22 M | 7241 / 4.44 M | 5870 / 1658 |
| sehrin_ustu | 1243 / 1.03 M | 851 / 1.51 M | 293 / 808 |
| eser_ayasofya | 796 / 0.68 M | 1121 / 0.95 M |  |
| eser_hipodrom | 882 / 0.71 M | 1256 / 1.12 M |  |
| galata_donus | 6108 / 8.38 M | 1198 / 2.56 M | 609 / 1132 |
| eve_donus | 6112 / 7.30 M | 5789 / 2.93 M | 4935 / 1088 |
| eser_konstantin | 1070 / 1.04 M | — |  |

