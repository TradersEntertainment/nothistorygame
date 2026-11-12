# İstanbul 1453 — SURLAR parçası (dal `wip/ist-surlar`)

Dosyalar: `scripts/world/ist/surlar.gd` (`IstSurlar`: ölçüler, yerleşim, sur dilimi, kuleler, hendek, kayıt, sarmalayıcılar),
`surlar_kapi.gd` (`IstSurlarKapi`: kemer, kapı kanatları, mermer kaplama, Romanos koridoru),
`surlar_ayrinti.gd` (`IstSurlarAyrinti`: Nisan 1453 izleri), `tests/_ist/surlar_onizleme.{gd,tscn}`.
Var olan hiçbir dosya değiştirilmedi.

## 1. Araştırma özeti
Kaynaklar: Wikipedia "Walls of Constantinople" (kesit, kule sayıları, kapı listesi; depodaki `docs/ISTANBUL_1453.md` §3 de
aynısını aktarıyor), Livius.org "Theodosian walls" fotoğraf notları, worldhistory.org "Theodosian Walls", Byzantine Legacy
"Golden Gate". Koordinatlar: `CityGeo.ANCHORS` (golden_gate, pege, romanos, harisios) ve aralarında doğrusal kestirim.

- **İç sur:** ~5 m kalın, ~12 m yüksek, kireçtaşı kaplama + tuğla kuşakları (7–11 sıra), harç/kırık tuğla çekirdek. 96 kule,
  çoğu kare, 15–20 m, aralık 21–77 m (ortalama ~55 m). Kule yüksekliği ve aralığı kaynaklarda değişiyor: ortalama alındı.
- **Peribolos:** iki sur arası teras, ~15–20 m (15 alındı).
- **Dış sur:** ~2–2,5 m kalın, 8,5–9 m yüksek, kuleleri 12–14 m, ~4 m geniş, iç kulelerin arasına denk gelir.
- **Parateikhion + hendek:** dış surun önünde teras ve alçak sur; hendek ~20 m geniş, 6–10 m derin (kaynaklar 6–7 ile
  10 arası; 6 alındı), iç yüzünde istinat duvarı, enine bölmeli. Görev metnindeki "18 m" yerine kaynaklardaki 20 m kullanıldı.
- **Kapılar (kuzeyden güneye):** Kharisios (Edirnekapı), Pempton/5. Askerî (Sulukule), Aziz Romanos (Topkapı; ~26,5 m derin
  kapı yapısı), Rhegion (Mevlanakapı; en iyi korunan), Pege (Silivrikapı), Ksylokerkos (Belgrat; 1189'da örülmüş), Altın
  Kapı (mermer üçlü kemer, iki mermer kule; 1453'te kapalı olduğu BELİRSİZ, kapalı alındı), Kaligaria/Eğrikapı (Blakhernai
  kesimi, hendeksiz), Kerkoporta (kule 96 yakını; yeri kazıyla doğrulanmadı, kestirim).
- **Mesoteikhion:** Lykos vadisinin sura değdiği alçalan kesim; 1453'te en ağır bombardıman burada. Yükseklik farkı kaynakta
  yok: kestirim olarak aynı kesit + en yoğun hasar/stauroma + vadi suyu geçidi (BELİRSİZ) yapıldı.
- **Nisan 1453:** top oyukları, kazık-fıçı-toprak onarımı (stauroma; Barbaro/Kritovulos anlatımı), iskeleler, mancınık ve taş
  gülle yığınları; sancaklar kestirim (kırmızı-altın Palaiologos, mavi-beyaz Ceneviz payı).
- **Anakronizm taraması:** minare, cam, barut varil/siper yok; tüfek/humbara yok (top gülleleri yalnız iz olarak).

## 2. Oyuncu ölçüleri (hesap)
`player.gd`: `JUMP = 3.6`, yerçekimi 9,8 → zıplama yüksekliği 3,6² / (2 · 9,8) = **0,66 m**; `STEP_H = 0,42 m` (basamak
zıplamadan çıkılır); `traversal.gd`: `REACH = 2,3 m`, `VAULT_MAX = 1,1 m`. Basamaklar 0,26 m yükseklik × 0,42 m ayak (< 0,42).
Korkuluk 1,2 m (> VAULT_MAX: aşılamaz), sur gövdeleri `no_climb`: yüksek yüz düz ve tutunmasız.
