# İSTANBUL v2 — ÇATI ROTASI: durum

Dal: `wip/ist2-cati` (taban `wip/ist2-birlesik`).

## Biten
- Kurulum: Godot 4.4.1 (`~/is/godot/godot`), içe aktarma.
- Hareket sondası `tests/_ist/cati_hareket.tscn` (gerçek Player, iki kip) — ölçüm sürüyor (ara sonuçlar aşağıda).
- Şehir sondası `tests/_ist/cati_sehir.tscn`: envanter (`cati_envanter_ONCE.md`), üstten harita (`harita_ONCE.png`),
  ışın doluluk haritası (`dolu_ONCE.png`), nokta yükseklikleri.
- Bulgu: Ayasofya–Yerebatan–Hipodrom arası bugün EV YOK (94 ev zonda ama hepsi batıda/kuzeyde; arası anıt daireleri,
  meydan oyun alanı, Augustaion döşemesi, Hipodrom). Çatı rotası için yeni ev kümeleri gerekiyor.

## Süren
- ÖNCE kareleri (14 kare: sokak 6, çatı 6, hava 2) + çizim/ilkel bütçesi.

## Sıradaki
- `scripts/world/ist/cati.gd`: yeni kümeler (E: meydan doğu kıyısı, M1/M2: meydan güney kıyısı–Milion, D: Hipodrom doğu
  yakası), düz damlar (`~dam`), kalas köprü, dam merdiveni, dış merdiven, bakış kulesi, saman.
- `docs/ISTANBUL_CATI.md` kural belgesi.
- Bot ÖNCE|SONRA, testler, rapor.

## Ara ölçümler (KAPALI / AÇIK)
- zıplama tepesi 0,68 / 0,68 m · yürüyerek basamak 0,48 / 0,48 · koşup zıplayarak çıkılan basamak 0,75 / 2,55
- koşarak atlama aralığı 4,2 / 5,9 m · yürüyerek atlama 2,6 / 2,6 m · aşağı atlama dh 1,0 → 5,2 / 6,6 m; dh 2,4 → 6,2 m
