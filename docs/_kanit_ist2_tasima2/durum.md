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

## Güncelleme (çit)
- Çit kök nedeni ölçüldü (`testler/sonda_*`): Bölüm 20 2. dalga azapları sırtta doğup dış yüzdeki çite çarpıyor, terasa
  (y −2,9) kayıp dış surun dibinde oyuncuyu x'te izliyor (60 sn'ye dek); 20o `=wide`'da bir savunanın girişi barikatın
  arkasından seçiliyor (z 11,7'de 30 sn takılı). Düzeltme: çit şehir tarafına (teslim yerinin 2,8 m gerisi), çit ve toprak
  set kutuları `wall` (görünen katı), moloz sırtı dış yüz + 0,2. İlk sınama: 20o `=wide` 1. dalga 33–39 → 8,6–9,2 sn.
- Taban (önce) matrisi bu dalın tabanında (28f42bb4, ayrı klasör) 19/19 PASS, denetim 0. "Sonra" matrisi koşuyor.
- Bölüm 21 bağdaştırıcıya bağlandı (sınanmadı).
