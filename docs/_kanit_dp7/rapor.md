# P7 düzeltme turu raporu (wip/yardimci-p7)

Kareler: gerçek oyuncu kamerası, sol ÖNCE | sağ SONRA (`docs/_kanit_dp7/*.jpg`). Ölçümler `tests/_tmp/probe` ile (geçici, söküldü).

## Zorunlu liste
1. **26 `_ladder_push_tick` "tip": eller sırıktan kopuyor** — YAPILDI. `scripts/chapter26.gd`: devrilme anında `_push_release_hands()` (yeni; `player.release_both()`, kılıç/kalkan geri), `_push_state="tip"` dalında çağrı; `_push_end()` de çağırır. Kare: `m26_tip000/tip012/tip040/grip055.jpg`. Ölçüm: tutuşta el–sırık 5–25 px (0,02–0,03 m); devrilmede rel 0,01'de sol el 70 px (0,10 m, hedef 20 px üstünde: DÜRÜST NOT), rel 0,05'te eller iniyor, ~0,31'de gizli; ÖNCE'de eller hiç yoktu.
2. **`_push_aim` pitch** — YAPILDI. `chapter26.gd` `_push_aim`: `if not step: want_pitch = minf(want_pitch, -0.85)`. Devrilmede pitch −0,92→−0,86 (önce −0,3). Çizim/üçgen (tip rel 0,3): SONRA ~5909/7,84M, ÖNCE ~6970/9,35M; t=1,0–1,2 SONRA 6565/9,24M, ÖNCE 7009/9,31M → artış yok.
3. **Merdiven tırmanış süresi** — YAPILDI. `chapter26.gd` `_build_walls_scene`: `l.height = 9.0` (geometri 9,8 m/14,5° kalır, `LADDER_VIS_H`). Kayıt: `len=8.700` ÖNCE ve SONRA aynı.
4. **0 `_hit` demet ilk karede** — YAPILDI (kare kanıtı sınırlı). `scripts/chapter0.gd` `_hit`: `pw.hold_item(_carry,false,false)` + 0,4–0,45 sn tween ile oyuncunun elinden savunucunun eline; yedek yol eski `receive_item`. Kare `m0_hit005/hit020.jpg`: SONRA'da demet (oklar) savunucunun kalkan/göğüs hizasında görünür, ÖNCE'de kalçada görünmüyor. Perf (aynı an): draw 8661 vs 8798, prim 12,61M vs 12,60M.
5. **21 `_breakthrough` kazma** — KANITSIZ. `scripts/chapter21.gd` `_breakthrough`: kazma ucu duvar yüzünden +0,6 m (önce +0,2) uzar. Delme anı kareleri (dig030…dig200) yakalanamadı (sonda yalnız `miner04` alındı, delmeden önce); `m21_miner04.jpg` yalnız bağlam. Perf: draw 1799 vs 1796, prim 1,90M vs 2,11M.

## Testler (başsız, `--max-fps 20`, her varyant 2 kez, hepsi PASS, FAIL/SCRIPT ERROR/ARMAUDIT satırı 0)
- `parse_check`: PARSECHECK PASS scripts=247
- 26: "", nophoto, hold, hold_box, hold23, hold3, warn_notrust, hold_lose, lighter, isidore, kasim, candle, council_ok, council_bad
- 0: "", next; 21: "", grant, fight, thermos, ear, captive; komşu 20, 22, 30 (26o koşulmadı)
Loglar sunucuda `/root/w/t/` (repoda yok).

## YAPILAMAYAN / BAKILMADI
- 21 delme anında kazma karesi KANITSIZ; duvardan çıkan kazma kanıtsız.
- 0 okçu germe / ok uçuşu / el sallama kanıtsız.
- 26 baltalı asker, assault/garrison donukluğu BAKILMADI; 26o testi koşulmadı.
- Devrilmede sol el 70 px (>20 px) açık kalan sapma (madde 1).
- hold_lose ARMAUDIT bu turda tetiklenmedi; önceki raporlanan ÖNCE'de de vardı, P7'den bağımsız. Ortak dosya önerisi (yapılmadı): `duel.gd:199/213`, `melee.gd:_arm_audit`.
