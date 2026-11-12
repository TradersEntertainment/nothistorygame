# Düzeltme turu: P9 Blakhernai (30, 30o) — GELİŞTİRİCİ (ilk tur REDDEDİLDİ)

Önce `docs/_ajan/gorev/_ortak2.md` dosyasını oku ve uy. Dalın: `wip/duzeltme-p9` (ilk turun işi bu dalda birleşik).
Kanıt klasörün: `docs/_kanit_dp9/`. Bağımsız denetçinin raporu: `docs/_ajan/denetim/p9.md` (tamamını oku; 6. bölümdeki
on ZORUNLU madde bağlayıcı). İlk turun raporu: `docs/_kanit_p9/rapor.md`.

Düzenleyebileceğin dosyalar: `scripts/chapter30.gd`, `scripts/chapter30o.gd`, `scripts/level/blachernae.gd` (yalnız
`_field_wear` ve yardımcıları; `shell_parts` ve tek harita kurucularına dokunma). `scripts/player/player.gd` YOK:
`_hold_both_points` kutusu yetmiyorsa tutma noktalarını kutunun içine düşecek biçimde seç; yine yetmezse ORTAK DOSYA
ÖNERİSİ yaz.

## Zorunlu maddeler (denetçinin 1–10'u; özet)
1. 30 merdiven itme: dört konumun (x = −12, −4, 6, 14) hepsinde itişin ortasında merdiven başı ekranın orta üçte
   birinde, mazgal taşına örtülmeden görünüyor.
2. İki avuç dikmelerin üstünde (≤ 20 px), sur taşının içinde değil, dört konumda.
3. Bırakınca bakış geri veriliyor (0,3 sn yumuşak) ya da itiş boyunca bakış hiç çevrilmiyor; `D30_D_DUEL_STAY`da ufukta.
4. `lad.rotation.x` yalnız `stage == "climb"` merdivenlerinde yazılıyor (taşınan merdiven 1,850'de kalıyor).
5. Titreme: merdiven başı ekran sarsıntısı ≤ ±8 px; kamera pitch'i sarsılmıyor.
6. `_field_wear` bütçesi: ağı parçala + `visibility_range_end` ya da seyrelt; 30 `D30_N_END`, 30o `D30O_T_TOWER_WON` ve
   `Z_URBAN` anlarında üçgen ≤ +%8, çizim artmaz.
7. 30o ova zemini oyuncunun gerçekten gördüğü yerde olsun; kabul karesinde ÖNCE | SONRA farkı (iz, çakıl) seçilsin.
8. 30o taşıma: askerlerin avuç hatası ≤ 0,08 m, taban–zemin ≤ 0,05 m, gövdeler iç içe değil.
9. 30o oyuncu çekilişi askerlerin/merdiven ayağının içinden geçmesin (sur tarafından yaklaşan oyuncu için de sına).
10. Rapor dürüstlüğü: doğrulanamayan beyan yazma; betikle oyuncu konumu/bakışı değişiyorsa açıkça yaz.

Not: bu dalda oyuncunun artık yere düşen gölge gövdesi var (`scripts/player/shadow_body.gd`); itme ve taşıma sırasında
gölgenin kolları ellere uzanıyor mu, çifte gölge var mı, karede bak ve yaz (dosyaya dokunma).

## Testler
30 (hepsi), 30o (8 varyant), 24, 25, 26, 31o. RINFO yukarıdaki üç an + 30 itiş anı.
