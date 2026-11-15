# TUR-8 durum (her kayıtta güncellenir)

Dal `wip/ist2-tur8`, taban `wip/ist2-birlesik` 28f42bb4 (ÖNCE: depo dışı kopya `~/is/once`, `git archive`).

## Biten
- Kurulum: Godot 4.4.1 resmi, iki kopya içe aktarıldı.
- Kök nedenler (kod okuyarak, karede doğrulanacak):
  - Hendek iç yüzü "dikey şeritli perde": `sur_doku.gd` desen yönü gölgelendirme normalinden alınıyordu; hendek kaplamasının
    normali yukarı yatırıldığı için (y 0,78) yüz "yatay döşeme" sayılıp xz ızgarası dik yüzde dikey şerit çiziyordu. Ayrıca
    köşe tonu 2,5 m'lik sütun başına rastgeleydi.
  - Sur "tek ton": hatıl ve derzler eşikle söndürülüyordu (fy > 0,34 m → ortalama renk); sarı dikdörtgenler "kumtaşı"
    blok tonu (%14 blok sarıya çekik) + geniş ton aralığı.
  - Ordugâh önü palanka: `ordugah_yapi2.gd build_siper` görünüşü 3 m'lik sürekli kalas kutusu.
  - Çukur halkası: `sur_zemin.gd _cukur_ag` 0,24 m kabarık açık renkli kenar.
- Yazılan düzeltmeler (ilk taslak): geometrik normal + kutu süzgeçli hatıl/derz + blok ölçeğinde yumuşak kenarlı ton +
  dökülmüş taş oyukları (`sur_doku.gd`); hendek köşe tonu yumuşak gürültü, dipte dökülmüş taş, dış yaka harpuştası öbek öbek
  eksik/kaymış, kıyıda ot (`sur_zemin.gd`); kazık perde tek tek sivri kazık (`ordugah_yapi2.gd`); çukur alçak düzensiz kenar.

- ÖNCE kareleri alındı (A 12, B 17 + gece 2, C 8, D 4, Bölüm 20 =kare 10) → `~/is/kare/once` (rapora kopyalanacak).
- Bölüm 20 yeni sette sur artık sur taşı gölgelendiricisiyle (önce Props "ashlar" dokusuydu: `_run` uygula'yı çağırmıyordu).
- Gece zemini: `zemin_renk` eşikli koyu leke yumuşak rampa; peribolostaki düz kenarlı koyu levhaların çoğu AY GÖLGESİ
  (kule/sur gölgesi; gölge haritası `Night.environment`, benim dosyam değil → istek).
- Hendek kıyı örtüsü: çökme kenarı artık hendek yüzünü izliyor (TUR-7'de yüzün ~2,5 m üstünde boşlukta sarkıyordu).
- Denetimler temiz: SURSOZLESME PASS kalem=13 kesim=8; SUROYUN havada=0 gomuk=0 katida=0; WALKTHRU yol=7 tamam=7.
- Bölüm testleri 20 / 20o / 26 / 43o AUTOTEST PASS, denetim satırı 0 (ara kod; son kodla yeniden koşulacak).
- Bütçe (bu turun ÖNCE'sine göre): B 17 kare çizim −0,1…+4,0 %, ilkel −0,1…+3,4 %.

## Süren
- k04/k11 bütçe dökümü (`tests/_ist/tur8_butce.tscn`): tur 7'den gelen +%10 aşımın kaynağı.

## Sıradaki
- SONRA kareleri, gece zemini (madde 3), bütçe (madde 5), testler, rapor.
