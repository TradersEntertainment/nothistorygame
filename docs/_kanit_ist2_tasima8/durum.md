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

## Süren
- 26'nın iki yollu bağlanması (yeni set / eski set)

## Sıradaki
- 26 ve 26o eski sette PASS kontrolü; 26 savaş evreleri yeni sette
