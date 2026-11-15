# TUR-9 durum (her kayıtta güncellenir)

Dal `wip/ist2-tur9`, taban `wip/ist2-birlesik` ee2ee089.

## Biten
- Kurulum (Godot 4.4.1, ÖNCE kopyası `git archive ee2ee089`).
- Madde 1 (c5, köşe dolgusu `Ist_kdolgu_kara_suru_16`): havadaki yeşil levha = `Karsi_cali` (dunya.gd) köşe kuşak maskesi
  dışında kalıyordu → `sur_oturtma.gd` köşe açıortay kuşak kaydı; beyaz taşlar aynı kaynakla kalktı; üçgen çentik = arazi
  kesim bandının kırıkta dikdörtgen uzaması → gönye yarım düzlemi (`_bant_kur`, `kes_ucgen`, `bant_ici`); köşe hendek alt
  parçalarına kırık açısından gönye payı (`sehir.gd _kose_hendek`).
- Madde 3 (gölgelendirici, `sur_doku.gd`): hendek yüzü oyukları seyrek/yumuşak; tuğla hatılı kutu süzgeçli (c2 kesimi).
- Sözleşme denetimleri bu kayıtta aynı: SURSOZLESME PASS 13/8, SUROYUN 519 0/0/0, WALKTHRU 7/7/0/0 (`testler/den_*`).

- Madde 2 (ay gölgesi): kök neden ölçüldü (`deney_ay/`, `tests/_ist/tur9_gece`: D kameraları + Night.environment):
  blur etkisiz (piksel farkı 0), split_1 etkisiz, yalnız mesafe → `night.gd` ay gölgesi 35 → 22 m, solma 0,55.
- Madde 4 (sur dibi eteği): gövde köşe alfası 1 (otlu desen) → çıplak; kesimde uç rengi zeminin paletinden; kesik
  aralık kıyısında etek 3 m'de söner, dip bandı 1,8 m'de söner (`sur_oturtma_ag.gd`).
- Denetimler yine aynı (`testler/den2_*`).

## Süren
- Madde 1 kalan: c5 yakın yakadaki düz kenar (köşede kıyı örtüsü denemesi görünür katkı vermedi / yama yaptı → geri alındı).

## Sıradaki
- Madde 2 ay gölgesi (Night.environment / look.gd), 4 sur dibi eteği, 5 çit yakın kare; ÖNCE/SONRA kare setleri; 6 Blakherna.
