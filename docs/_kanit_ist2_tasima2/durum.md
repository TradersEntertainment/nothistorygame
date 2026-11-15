# TAŞIMA-2 — durum (her kayıtta güncellenir)

Dal `wip/ist2-tasima2` (taban `wip/ist2-birlesik` 28f42bb4).

## Biten
- Kurulum: Godot 4.4.1 resmi, `--import`.
- Okuma: pilot raporu, SUR_SOZLESME (oynanış arayüzü, bağdaştırıcı), SUR_BOLUM_TASIMA §2/§4.3/§6, sur_set*.gd, GedikOnarim.

## Süren
- 1. Kazık çit: kök neden incelemesi. Bulgu (koddan): otomatik testte oyuncu Bölüm 20'de doğuşta kalır; 2. dalganın azapları
  `moloz_sirti()` (dış yüz + 1,4) üstünde, aşama 4'ün dış çitinin ova tarafında doğar ve çitin içinden peribolosa geçmek
  zorundadır. 20o'da `Melee.auto_entry` giriş noktasını düello yerinin ötesinde (peribolos) arar; çitin çarpışma kutusu
  görünmez sayıldığından (`Unclip.visible_body`: ağ çocuğu yok, meta yok) giriş çitin arkasından seçilir. Ölçümle doğrulanacak.

## Sıradaki
- 1. çit (önce/sonra ölçüm) → 2. Bölüm 20 kalanları (=hit personhidden, gökteki koyu biçim) → 3. Bölüm 21 taşıması → (0, 25).
