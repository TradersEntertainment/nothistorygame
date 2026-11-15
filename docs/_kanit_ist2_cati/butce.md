# Bütçe: aynı kameralar, ÖNCE (`--cati=0`: küme kurulmaz = bugünkü şehir) | SONRA

1280×720, xvfb opengl3, `--max-fps 20`. Bekleme belirlenimci: en az 90 kare ve akış kuyruğu (`IstSehir._queue`) 10 kare
üst üste boş. Gruplar aynı (5+5+4 kamera, aynı sıra), başka süreç koşmazken.

| kamera | çizim ÖNCE | çizim SONRA | Δ% | ilkel ÖNCE | ilkel SONRA | Δ% |
|---|---|---|---|---|---|---|
| sokak1_meydan_gd | 496 | 512 | +3.2 | 994903 | 1032310 | +3.8 |
| sokak2_yerebatan | 597 | 624 | +4.5 | 1331332 | 1377653 | +3.5 |
| sokak3_milion | 685 | 690 | +0.7 | 1186953 | 1208740 | +1.8 |
| sokak4_hip_kuzey | 617 | 629 | +1.9 | 2522722 | 2536086 | +0.5 |
| sokak5_hip_orta | 792 | 831 | +4.9 | 3118099 | 3133615 | +0.5 |
| sokak6_hip_guney | 916 | 940 | +2.6 | 2314147 | 2346079 | +1.4 |
| cati1_e_sirasi | 706 | 683 | -3.3 | 1584926 | 1629418 | +2.8 |
| cati2_m1 | 823 | 818 | -0.6 | 3150051 | 3187827 | +1.2 |
| cati3_m2_bakis | 540 | 566 | +4.8 | 1213833 | 1255769 | +3.5 |
| cati4_d_kuzey | 486 | 502 | +3.3 | 1004060 | 1024292 | +2.0 |
| cati5_d_bakis | 764 | 784 | +2.6 | 3070152 | 3091264 | +0.7 |
| cati6_d_ayasofya | 856 | 874 | +2.1 | 1535366 | 1557000 | +1.4 |
| hava1_mahalle | 521 | 519 | -0.4 | 930396 | 939494 | +1.0 |
| hava2_hipodrom | 605 | 589 | -2.6 | 859324 | 863566 | +0.5 |

En büyük artış: +4.9 % (sınır ≤ +5 %).

**Ölçüm gürültüsü (dürüst not):** sabit 90 kare beklenince aynı kameranın çizim sayısı akış durumuna göre ±%20
oynuyordu (ÖNCE sokak3: 615 / 745; SONRA sokak3: 563 / 690 / 701 / 780 — 780 paralel sur testleri CPU'yu yüklerken).
Arazi parçaları ve NPC katmanı zamana bağlı akıyor; kuyruk-boş beklemesi bunu tam sabitlemiyor. Tablodaki değerler
yüksüz son koşular; tek kamerada ±%5'lik fark ölçüm gürültüsü içinde. Yeni küme 12 ev + 12 parça; yeni malzeme yok
(parçalar evlerin ashlar/Dressing malzemelerini kullanır; kule başlığı kiremit `tiles`).
