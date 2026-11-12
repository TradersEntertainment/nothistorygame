# Düzeltme turu: fragman kusurları (Bölüm 0, 2, 8y) — GELİŞTİRİCİ

Önce `docs/_ajan/gorev/_ortak2.md` dosyasını oku ve uy. Dalın: `wip/duzeltme-kusur`. Kanıt klasörün: `docs/_kanit_dkusur/`.
Bağımsız denetçinin raporu: `docs/_ajan/denetim/kusur.md` (tamamını oku; bölüm 5'teki liste bağlayıcı).
Önceki geliştirici raporları: `docs/_kanit_kusur/rapor.md`, `docs/_kanit_kusur2/rapor.md`.

Düzenleyebileceğin dosyalar: `scripts/chapter2.gd`, `scripts/chapter0.gd`, `scripts/chapter8y.gd`. Başka dosya yok.

## Yapılacaklar
1. **B2 yakalama bakışa duyarlı olsun (ZORUNLU).** `chapter2.gd:_seize`: yakalama boyunca `player.look_lock = true`,
   `fwd` kameranın anlık yatay yönünden; `_grab_arms` bitince (her çıkış yolunda) `look_lock = false`. Kabul: oyuncunun
   bakışı 0°, 90°, 180° çevrilmiş üç sonda koşusunda avuç-bilek hatası ≤ 0,10 m, asker kameraya ≥ 0,65 m, `WALKTHRU` yok.
   Üç bakış için kare çifti. Bakış kilidi 3 sn'yi geçiyorsa süreyi yaz (yakalama zaten denetimi alıyor; götürme evresi
   eskisiyle aynı kalmalı).
2. **`_seize_audit` günlüğü (ZORUNLU).** `part.name` yerine sabit adlar (`head`, `arm_l`, `arm_r`, `elbow_l`, …); ilk
   ihlalde çıkmak yerine süre boyunca en kötü değeri bir kez bassın. Yalnız `GameState.autotest` altında kalsın.
3. **B0 donmada düşme.** `chapter0.gd:_freeze` içinde `_pause_world(true)` ardından `player.gravity_on = false;
   player.velocity = Vector3.ZERO`; `_rewind` içinde `_pause_world(false)` ardından `player.gravity_on = true`.
   Kabul: `PACE=1 --chapter=0` başsız koşuda `WARN_VOID_TELEPORT` yok; `--autotest=next` zinciri PASS.
4. **B0 yer/tarih yazısı okunurluğu.** Yazı tam yazıldıktan sonra en az 2,0 sn ekranda kalsın (koşan oyuncuda da),
   ama patlamanın ve "TOLGA" kartının üstüne taşmasın (taşacaksa patlamadan 0,2 sn önce sönsün). Ölç ve yaz.
5. **8y uyarı oku keçi repliğini kesmesin.** `docs/_kanit_kusur2/rapor.md` 4. maddedeki öneriyi uygula
   (`_yorum_until` ile `_warn_lines` Tolga'nın hikâye yorumu bitene dek SÖZÜ erteler; ok yine anında saplanır).
   Dikkat: `chapter8y.gd` bu dalda bakış düzeltmesiyle (kapı nöbetçisi) değişti; o değişiklikleri bozma. Kabul: uyarı
   keçi repliğinin ilk saniyesinde zorlanınca (geçici sonda) keçi repliği sonuna kadar çalıyor, uyarı arkasından geliyor;
   8y'nin bütün varyantları PASS.

## Testler
0 (bütün varyantlar + `PACE=1`), 2 (8 varyant × 2 tur), 8y (bütün varyantlar), 8, 9, 3, 17 `edirne_policy`.
