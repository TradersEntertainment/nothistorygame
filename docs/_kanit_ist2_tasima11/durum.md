# TAŞIMA 11 — durum

- Dal `wip/ist2-tasima11`, taban `wip/ist2-taban18` = bb334de7.
- Sözleşme (taban): SURSOZLESME PASS kalem=13 kesim=8 · SUROYUN nokta=519 havada=0 gomuk=0 katida=0 · WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0 · ESYATEST PASS · T8DTEKME PASS
- 1 ÖLÇ: `dokum.md` yazıldı.
- 2 ortak kalem `scripts/world/ist/deniz_set.gd`: govde, korkuluk, disler, konsol, kule (geçit + teras ağzı), rihtim, kapi_kemer, uzak_parca, uzak_kule, gizle, bitir.
- 2 şehir `IstHalicSur`: yeni kalemle; çarpışma dökümü eski = yeni (661 şekil, aynı karma).
- 2b `HornWorld._wall_run` + `Horn._sea_wall`: ≤ 250 m / tek harita devamı yeni kalemle.
- 3 SeaWalls: 4 (16 PASS), 17 (39 PASS + 4 yeniden; 1 WALKTHRU eski koşuda Büro'da, SeaWalls'tan önce), 19/19o/29/29o sırada.
- 4 18b: 6 PASS. 5 38o: ilk 6 PASS (+ eşik/diş sondası), ×5 turu sürüyor (kopyadan).
- Testler `~/is/kopya` (çalışma ağacının eşi) üzerinden: düzenleme sürerken koşu bozulmasın (bir turun 5 koşusu ayrıştırma hatası penceresine düştü: yeniden koşuldu).
