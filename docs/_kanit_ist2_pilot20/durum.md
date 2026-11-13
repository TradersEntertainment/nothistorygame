# PİLOT-20 doğrulama — durum (her kayıtta güncellenir)

Taban kayıt: `9f32c394` (önceki oturum; kanıtsız).

## Biten
- 1. Kurulum + ayrıştırma: Godot 4.4.1 (`~/is/godot/godot`), `--import` tamam, `PARSECHECK PASS scripts=354`.
  Bölüm 20 yeni sette başsız ilk koşu: `AUTOTEST PASS … sur=yeni`, denetim satırı 0.

## Süren
- 2. Test matrisi (66 koşu, 4'er paralel; çıktılar `~/is/out`, sonra `testler/` altına).
- Görsel teşhis aracı `tests/_ist/pilot20_teshis.tscn` (düğüm gizleyerek kusur kaynağı bulma) yazıldı, henüz koşulmadı.
- Küçük düzeltme: `assault.gd` yeni sette tabya ve mancınık yönü ova kaydırmasını hesaba katıyor (bataryayla aynı).

## Sıradaki
- 3. öteki bölümler, 4. sözleşme denetimleri, 5. yürüyüş, 6. kareler, 7. görsel kusurlar, 8. bütçe, 9. rapor.
