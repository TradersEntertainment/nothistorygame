# CANLI — ara gönderim 1 (öküz, at, deve, koyun: kit + ordugâh işlevleri)

Bu ARA rapordur; son rapor aynı dosyanın üstüne yazılacak. Oyun içi ordugâh kareleri (Şahi, at bağı) koşuyor: BAKILMADI.

## Öküz ÖNCE | SONRA
`sonda_01_okuz_once_sonra.jpg` (üst satır ÖNCE = `e106a7e1` depo dışı kopya, alt satır SONRA; sütunlar: 5 m yandan,
çapraz önden, önden, 60 m, sürü). Kaynak: `ordugah_yapi.gd:_okuz` (Şahi topu ve öküz sırası bunu çağırır).

## Kendi karelerime bakınca hâlâ kötü olanlar
- 60 m karesinde hayvan birkaç piksel: siluet bu karede okunmuyor (ölçeği gerçek); uzak katman ayrıca bakılacak.
- Devenin başı küçük, hörgücü yakında hâlâ hafif köşeli; öküzün boyunduruğu önden bakınca başın üstünde çubuk gibi.
- Yakında 10 kesimli halka: siluet kenarında çokgen kırığı seçiliyor (kutu değil ama pürüzsüz de değil).

## Durum
- A. `scripts/world/ist/canli_kit.gd` (class_name yok; `preload`): KISMEN (13 tür; üçgen yakın 1 086–1 338, orta 108–297, uzak 61–88).
- C. Ordugâh: `_okuz`, `_at`, `_deve_yatan`, `_koyun` (gövde), `_kopek`, `build_agil` (koyun çizimi) kite çevrildi: KISMEN (sonda karesi var, oyun içi kare yok).
- B, D: YAPILMADI (sürüyor).
