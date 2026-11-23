# TAŞIMA 12 — durum (her kayıtta güncel)

Dal `wip/ist2-tasima12`, taban `wip/ist2-taban19` = a38ad405.

| # | Madde | Durum |
|---|---|---|
| 0 | 8y | TAMAM (×3 + eski + yuru; denetim 0) |
| 1 | 13, 23, 24 | TAMAM |
| 2 | uzak hub | TAMAM |
| 3 | 31o | TAMAM |
| 4 | 41o, 42b | TAMAM |
| 5 | 21o, 17o | TAMAM (21o: taşınacak yok; 17o: görünüşe istek) |
| 6 | 10h moloz | TAMAM |

Son kayıt: bütün çeşitler ve bağımlılar PASS, sözleşme dörtlüsü + ESYATEST + T8DTEKME + PARSECHECK aynı. Ayrıntı `rapor.md`.
## 8y kök neden (kısa)
`VISAUDIT float Station_coil_rope` iki ızgaranın farkı DEĞİL. Günlük (`testler/gunluk_8y_*`): ayak altında OvaZemini
y −3,076, AraziCarpisma y −3,066 (fark 0,01 = bilinçli −0,01); kök 0,3 sn'de −3,065 (zeminde), 2 sn'de −2,885 (+0,18).
ESKİ sette de aynı +0,18 (kök −0,03 → 0,15; denetçi orada görünür zemin bulamadığı için satır yazmıyordu).
Kaldıran: `Stage.station` (yer çağrısı verilince) her 0,5 sn `Stage.plant_feet` → "crouch" pozunun FK tabanı kökün
0,12/0,18 m altında → kök 0,18 kalkar. Çözüm: halatçı istasyonu yer çağrısız, y elle (`chapter8y.gd _build_lines`).
