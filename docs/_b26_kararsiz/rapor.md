# Bölüm 26 kararsız görsel denetim satırları — rapor (ara kayıt)

## 1. Ölçüm (önce) — değişmemiş kod, 4 süreç eşzamanlı, `--max-fps 20`

| Test | Koşu | AUTOTEST PASS | Satır çıkan koşu | Satırlar |
|---|---|---|---|---|
| hold_box | 30 | 30 | 1 | 1× `VISAUDIT overlap` (SPK_DEFENDER ↔ WallFight kazıkçısı `chop`) |
| hold_lose | 30 | 30 | 6 | 4× `ARMAUDIT unarmed` (foe_dist 2.5 / 5.0 / 2.5 / 3.1; duel_active=false), 2 koşuda 3× `VISAUDIT personhidden` (D26_G_HURT, D26_G_WOUND_COLOGNE; aynı WallFight kişisi) |

Ham satırlar: `olcum_once.txt`.

Not: görevdeki `personhidden key=D26_G_BOX/STAY/D26_K_HOLD_1` satırı ×30'luk koşuda `hold_box`ta çıkmadı (bugünkü tam testte 1 kez çıkmıştı); aynı kişi/aynı mekanizma `hold_lose`ta (D26_G_HURT/WOUND_COLOGNE) 2/30 koşuda yeniden üretildi. Ayrıca `hold_box`ta bir `overlap` satırı görüldü.

## 2. İlk bulgu (A) — günlükle

`wall_fight.gd`'nin `add_builders` kişisi (kazık çakan `chop`, elinde balta: meta `no_talk,garrison,armed,tool_armed`), gedikteki
yerinden (2,4; 11,8) dalgalar boyunca dövüşenlerin itmesiyle yavaş yavaş oyuncunun `_dawn_shot` noktasına (−0,6; 9,8) doğru kayıyor;
`D26_T_SEE_GUN` karesinde `_clear_line` onu tek karede (1,86; 9,53) → (0,3; 9,5)'e, yani oyuncu–Giustiniani çizgisinin üstüne alıyor.
(Ayrıntı ve düzeltme sonraki sürümde.)
