# İstanbul v2 — DOKU-4 raporu (dördüncü tur) — ÖN SÜRÜM (kareler geliyor; son sürüm bunun yerini alacak)

Dal `wip/ist2-doku4` (taban `wip/ist2-taban4`; SUR-4, ORDUGÂH-4, ÇEVRE-4, BAĞLAMA-4 birleştirildi).

## 1. Yükleme ve takılma — ÖNCE | SONRA (ilk ölçüm)

Komut (aynı, başsız): `godot --headless --max-fps 60 --path . res://tests/_ist/baglama_ucus.tscn -- bolum=11 kip=olc`
(`BAGLAMA_YUKLE` = bölüm sahnesinin eklenmesinden ilk kareye; `BAGLAMA_TAKILMA` = 60 sn uçuşta > 50 ms kare).

| | ÖNCE (taban4) | SONRA-1 (yalnız DOKU-4, `9bf8ac2b`, önbellek dolu) |
|---|---|---|
| yükleme (3 koşu) | 44,6 / 37,8 / 34,4 sn → **37,8** | 20,7 / 19,7 / 21,0 sn → **20,7** |
| uçuşta > 50 ms (3 koşu) | 22 / 22 / 20 → **22** | 12 / 18 / 19 → **18** |

Son ölçüm (birleşik dal, üç koşu, yalnız başına) son sürümde.

Paftalar: `p00_once_ozet.jpg` (ÖNCE kareleri). SONRA kareleri ve ÖNCE | SONRA paftaları koşuyor.
