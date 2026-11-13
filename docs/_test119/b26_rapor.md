# Bölüm 26 `hold_box` — ara görsel denetim düşüşü (VISAUDIT) raporu

> ARA KAYIT — ikiye bölme koşuları sürüyor; tablo yarım. Son hali bu dosyanın yerine gelecek.

Komut (her koşu): `timeout 300 godot --headless --max-fps 20 --path . -- --chapter=26 --autotest=hold_box`
Godot 4.4.1.stable.official (linux x86_64), 4 çekirdek, aynı anda 5 süreç.

## İkiye bölme (ara)

| kayıt | ne | biten koşu | VISAUDIT'li koşu |
|---|---|---|---|
| `e551de84` | origin/main (v0.99.118) | 10 | 0 |
| `4fdb4db8` | tırmanma birleşmesinden hemen önce | 10 | 1 (Squad çifti, `(23.6, 0, 9.0)`) |
| `c7256660` | tırmanma birleşmesi | 10 | 0 |
| `482c5acf` | bakış birleşmesi | 10 | 0 |
| `2e36e8b7`+günlük | HEAD (yalnız `~/is` kopyasında geçici günlük) | 9 | 1 (Squad çifti, `(23.4, 0, 7.9)`) |

İlk bulgu: tırmanma birleşmesinden ÖNCEKİ kayıtta da aynı tür satır çıkıyor; suç bu iki birleşmeye ait görünmüyor.

## Kök neden (ön bulgu, günlükle doğrulanıyor)

`Melee` RALLY bölük üyesini (Garrison.squad, `reserve_loop`) düellocuya çevirirken kaynak kişiyi yerinde gizler
(`scripts/combat/melee.gd:526`, `n.visible = false`). Bu sırada komşunun `reserve_loop._step`'i boş yer denetimini
`Unclip.crowded` ile yapar; o görünmeyeni saymaz ve komşu gizli kişinin yerine adım atar. Dövüş bitince gizli kişi aynı
yerde yeniden görünür (`melee.gd:573/589`) → iki kişi iç içe. Günlük: `RSTEPNEAR ... d=0.66 vis=false crowded=false`.
