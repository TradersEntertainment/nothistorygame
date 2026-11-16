| Bölüm | ÖNCE sonuç | ÖNCE YIGILMAAUDIT | SONRA sonuç | SONRA YIGILMAAUDIT | öteki denetim ÖNCE → SONRA | AYAKAUDIT yakın ÖNCE → SONRA |
|---|---|---|---|---|---|---|
| 0 | PASS | 0 | PASS | **0** | 0 → 0 | 0 → 0 |
| 20 | PASS | 5 | PASS | **0** | 0 → 0 | 0 → 0 |
| 20:tape | PASS | 5 | PASS | **0** | 0 → 0 | 0 → 0 |
| 20:late | PASS | 5 | PASS | **0** | 0 → 0 | 0 → 0 |
| 20:hit | PASS | 5 | PASS | **0** | 0 → 0 | 0 → 0 |
| 20:lose | PASS | 0 | PASS | **0** | 0 → 0 | 0 → 0 |
| 20:niko_idle | PASS | 5 | PASS | **2** | 0 → 0 | 0 → 0 |
| 20:idle | PASS | 5 | PASS | **2** | 0 → 0 | 0 → 0 |
| 20o | PASS | 5 | PASS | **1** | 0 → 0 | 0 → 0 |
| 22o | PASS | 2 | PASS | **0** | 0 → 0 | 0 → 0 |
| 26:hold | PASS | 18 | PASS | **2** | 0 → 0 | 5 → 0 |
| 26:hold_box | PASS | 18 | PASS | **3** | 0 → 0 | 1 → 1 |
| 26:hold_lose | PASS | 2 | PASS | **0** | 0 → 0 | 7 → 19 |
| 26o | PASS | 6 | PASS | **3** | 0 → 0 | 2 → 4 |
| 30o | PASS | 7 | PASS | **1** | 1 → 1 | 0 → 0 |
| 32o | PASS | 0 | PASS | **0** | 0 → 0 | 0 → 0 |
| 37o | PASS | 3 | PASS | **0** | 1 → 1 | 2 → 0 |
| 37o:trespass | PASS | 3 | PASS | **1** | 1 → 1 | 0 → 0 |
| 25:caught | PASS | 0 | PASS | **0** | 0 → 0 | 0 → 0 |
| 28o | PASS | 0 | PASS | **0** | 0 → 0 | 0 → 0 |
| **toplam** | | **94** | | **15** | | 17 → 24 |

SONRA satırları:
- 20:niko_idle: `YIGILMAAUDIT fizik scene=Chapter20 who=Soldier/@Node3D@26934(@Node3D@24160) at=(11.8, -3.7, 18.0) bas=+0.41 govde=+0.31 el_r=+0.33`
- 20:niko_idle: `YIGILMAAUDIT fizik scene=Chapter20 who=Person/@Node3D@34407(@Node3D@34408) at=(-3.4, 0.5, 13.5) govde=+0.23 ayak_l=+0.21 ayak_r=-0.25`
- 20:idle: `YIGILMAAUDIT fizik scene=Chapter20 who=Person/@Node3D@33204(@Node3D@33205) at=(-6.0, 0.0, 12.6) el_r=+0.15`
- 20:idle: `YIGILMAAUDIT fizik scene=Chapter20 who=Person/@Node3D@34230(@Node3D@34231) at=(-3.0, 0.7, 13.0) govde=+1.07 el_l=+1.45 ayak_l=+0.56`
- 20o: `YIGILMAAUDIT fizik scene=Chapter20o who=Person/@Node3D@24358(@Node3D@24359) at=(-1.6, 0.5, 16.9) bas=+0.31 govde=-0.50 el_l=-0.11`
- 26:hold: `YIGILMAAUDIT fizik scene=Chapter26 who=Person/@Node3D@45724(@Node3D@45725) at=(-10.5, 0.0, 19.9) ayak_l=+1.67 ayak_r=+1.67`
- 26:hold: `YIGILMAAUDIT fizik scene=Chapter26 who=Person/@Node3D@59681(@Node3D@59682) at=(-6.1, 0.3, 11.4) el_l=+1.11`
- 26:hold_box: `YIGILMAAUDIT fizik scene=Chapter26 who=Person/@Node3D@62807(@Node3D@62808) at=(-4.8, 1.8, 16.4) bas=+0.19 govde=+0.11`
- 26:hold_box: `YIGILMAAUDIT fizik scene=Chapter26 who=Person/@Node3D@72524(@Node3D@72525) at=(5.4, 1.3, 13.0) govde=+0.20 govde=+0.27 el_r=+0.55 ayak_r=-0.27`
- 26:hold_box: `YIGILMAAUDIT fizik scene=Chapter26 who=Person/@Node3D@72913(@Node3D@73267) at=(5.4, 1.3, 13.4) govde=+0.25 govde=+0.50 ayak_r=+0.49`
- 26o: `YIGILMAAUDIT fizik scene=Chapter26o who=Soldier/@Node3D@28619(@Node3D@25886) at=(12.0, -0.2, 21.2) bas=+0.58 govde=+0.09 el_l=+0.30`
- 26o: `YIGILMAAUDIT fizik scene=Chapter26o who=Person/@Node3D@60182(@Node3D@60465) at=(6.2, 0.3, 12.3) el_l=-0.30`
- 26o: `YIGILMAAUDIT fizik scene=Chapter26o who=Person/@Node3D@63604(@Node3D@63605) at=(23.7, 0.0, 18.7) govde=+0.23`
- 30o: `YIGILMAAUDIT fizik scene=Chapter30o who=Person/@Node3D@40399(@Node3D@40400) at=(8.6, 12.0, 4.2) govde=-0.25`
- 37o:trespass: `YIGILMAAUDIT fizik scene=Chapter37o who=Person/@Node3D@24998(@Node3D@24999) at=(-2.6, 0.2, 16.5) govde=+0.34`

| Bölüm | ÖNCE işlem ms/kare | SONRA işlem ms/kare | fark | SONRA yığılma µs/kare (ort.) | en kalabalık an: yığılan | o karede yığılma µs | o karenin işlem ms | pay |
|---|---|---|---|---|---|---|---|---|
| 20 | 40.7 | 40.8 | +0.3% | 209 | 3 | 506 | 35.3 | 1.4% |
| 20:tape | 42.0 | 47.0 | +12.0% | 222 | 3 | 1074 | 44.5 | 2.4% |
| 20:late | 49.7 | 56.4 | +13.5% | 362 | 6 | 1492 | 38.4 | 3.9% |
| 20:hit | 47.4 | 40.9 | -13.7% | 152 | 3 | 1320 | 36.0 | 3.7% |
| 20:lose | 50.7 | 45.0 | -11.3% | 56 | 3 | 1096 | 186.1 | 0.6% |
| 20:niko_idle | 44.6 | 51.6 | +15.6% | 135 | 3 | 1352 | 48.4 | 2.8% |
| 20:idle | 37.5 | 33.0 | -12.0% | 123 | 4 | 1252 | 32.8 | 3.8% |
| 20o | 30.5 | 30.0 | -1.8% | 120 | 2 | 1653 | 53.9 | 3.1% |
| 22o | 43.2 | 43.0 | -0.4% | 56 | 1 | 1773 | 145.6 | 1.2% |
| 26:hold | 107.4 | 96.4 | -10.2% | 397 | 5 | 669 | 170.6 | 0.4% |
| 26:hold_box | 98.5 | 96.4 | -2.2% | 354 | 5 | 1537 | 63.0 | 2.4% |
| 26:hold_lose | 205.9 | 101.0 | -51.0% | 155 | 5 | 1567 | 96.1 | 1.6% |
| 26o | 115.7 | 115.3 | -0.4% | 258 | 5 | 1406 | 90.2 | 1.6% |
| 30o | 43.7 | 40.7 | -6.8% | 155 | 2 | 1858 | 21.9 | 8.5% |
| 32o | 35.8 | 39.8 | +10.9% | 0 | 0 | 0 | 0.0 | 0.0% |
| 37o | 30.4 | 29.7 | -2.1% | 24 | 2 | 1705 | 56.9 | 3.0% |
| 37o:trespass | 29.6 | 32.4 | +9.4% | 34 | 2 | 868 | 58.1 | 1.5% |
| 25:caught | 340.6 | 349.7 | +2.7% | 0 | 0 | 0 | 0.0 | 0.0% |
