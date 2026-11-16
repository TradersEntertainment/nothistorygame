# TAŞIMA 8 — durum (Bölüm 26 / 26o)

Dal: `wip/ist2-tasima8` (taban `wip/ist2-taban13` c6ab0f7b).

## Biten
- (a) ekleri, varsayılan kurulum aynı (sözleşme üçlüsü: `SURSOZLESME PASS kalem=13 kesim=8`, `SUROYUN nokta=519 havada=0 gomuk=0 katida=0`,
  `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0`; `PARSECHECK PASS scripts=363`):
  - `SurOyun.ic_poterna()` sorgusu + `kur(…, {"ic_poterna": true})` → `Poterna.kur_ic` (iç surun peribolos yüzü)
  - `kur(…, {"romanos_kanat": true[, "romanos_kopru": true]})` → yan dilime `kanat_disarida` (kopya seçenek) + `KapiKanat`
  - `SurSet.ic_poterna()`, `romanos()`, `sehir_ofs()`, `dolgu_ust()`, `dolgu_y()`
  - `SurSetSahne.ic_poterna/romanos_kanat/romanos_kopru`, `open_inner_gate()` (Romanos kanatları), `ic_poterna_ac()`
  - `SiegeChaos.sur` kancası; `FallenCity.yer` konum parametresi (varsayılan ZERO = eski)
- Taban ölçümü (eski set, değişiklikten önce): 26 `""` PASS (142 sn), 26 `hold` PASS, 26o `""` PASS, **26o `lose` FAIL (tabanda da)**

- 26 iki yollu (yeni set varsayılan, `--eskisur=26` eski): yeni sette `""` ×2, `hold`, `hold_box`, `nophoto`, `council_bad` PASS;
  eski sette `""` PASS; 26o (eski set, aynı dosyadan türer) `""` PASS.
- İç poterna eteğe oturur (ışınla), gediğin +x yanında (x 14,25); Romanos kanatları açılır; final yolu: dolgu → gedik tepesi →
  karartma → Romanos koridoru → iç kapı → cadde (FallenCity.yer).
- `=yuru` / `=kare` kipi (26).

## Süren
- Denetim satırları (yeni sette): savunucu üst üste binmesi (1,5; 0,5; 10,6) her koşuda; kafile başı caddede kirişe gömülü
  (nophoto, council_bad). Sonda (`--sonda8`) ile kök neden.
- `=yuru` iki takılma bot betiğindendi (fıçılar çekilmeden poterna, kazanın öbür yanı): düzeltildi, yeniden koşuyor.

## Sıradaki
- 26'nın bütün çeşitleri yeni ×2 + eski ×1; kareler (8 çift); 26o (d)
