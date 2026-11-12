# Düzeltme turu: bakış yönü (oyun geneli) — GELİŞTİRİCİ

Önce `docs/_ajan/gorev/_ortak2.md` dosyasını oku ve uy. Dalın: `wip/duzeltme-bakis`. Kanıt klasörün: `docs/_kanit_dbakis/`.
Bağımsız denetçinin raporu: `docs/_ajan/denetim/bakis.md` (tamamını oku; "ZORUNLU düzeltmeler", "KÜÇÜK" ve "ORTAK DOSYA
ÖNERİSİ A" bölümleri bağlayıcı). Hükmü: "küçük düzeltmelerle kabul". İlk geliştirici raporu: `docs/_ajan/rapor/bakis.md`.

Düzenleyebileceğin dosyalar: `scripts/level/stage.gd` (`gaze_dir` ve yardımcıları), `scripts/autoload/game_state.gd`
(`_look_audit`; yolu `grep -rn "_look_audit" scripts/` ile bul), `scripts/chapter9.gd`, `scripts/chapter10.gd`,
`scripts/chapter4.gd`, `scripts/chapter8y.gd`, ve denetçinin ORTAK DOSYA ÖNERİSİ A'sında adı geçen dosya (yalnız o
önerinin gerektirdiği satırlar).

## Zorunlu
1. Yürüyüş eşiği: `gaze_dir` içinde yürüme eşiği 0,35 m/sn (çıkışta 0,25: histerezis, titreme yok); `_look_audit` walk
   eşiği aynı. Kabul: Bölüm 20 Giustiniani (0,46–0,55 m/sn) yürürken hareket yönüne göre açı ≤ 35°; "ay yürüyüşü" yok;
   17 (Radu/Vlad), 26, 28o, 35o, 31o yürüyenleri için birer kare ya da ölçüm.
2. `D9_KADRI_OFFER_1` ve `D9_URBAN_OFFER_1_PLAIN` SAYFACE: denetçinin bulduğu kök neden ve ORTAK DOSYA ÖNERİSİ A'yı
   uygula; `chapter9.gd:1005` ve `chapter10.gd:837` civarındaki işe yaramayan `face_toward` satırlarını kaldır.
   Kabul: Bölüm 9 ve 10'un bütün varyantlarında bu iki SAYFACE satırı yok; yeni SAYFACE yok.
3. Süre kuralı: `chapter4.gd:_niko_opens_gate` (+0,7 sn) ve `chapter8y.gd:_open_gate` (+0,6 sn) ara sahne süreleri
   özgün süreye insin (hareketi kısaltarak ya da eşzamanlı yaparak; kişi yine işine dönük çalışsın). ÖNCE | SONRA süre ölç.
4. Bağımsız gölge denetçisinin notu: Bölüm 20'de `LOOKAUDIT backturn` (Giustiniani) 4 koşuda 1 çıktı: düzeltmeden
   sonra 20'yi on kez koş, sayıyı yaz; 0 olmalı.

## Testler
Bütün bölümler varsayılan varyantla birer kez (`tests/run_tests.sh` listesi) + 4, 8y, 9, 10, 10b, 17, 20 bütün
varyantlar; `SAYFACE` anahtar listesi ÖNCE (bu dalın başlangıcı) | SONRA.
