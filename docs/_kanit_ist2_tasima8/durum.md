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

- 26o iki yollu (yeni set varsayılan, `--eskisur=26o` eski): yeni `""` ×2, `lose`, `turgut` PASS; eski `""` PASS.
- `=yuru` takılmasız: 26 yeni (100,5 m) / eski (91,8 m), 26o yeni (98,2 m).
- Kökü bulunup düzeltilenler: savunucu üst üste (yardımcı taşıyıcının çekilme yönü), kafile başı kilise basamağında,
  taşıma yolu sıraya yakın, fıçılar yola yuvarlanıyordu, 26o hendek engeli hiç kalkmıyordu (32 bit eşitlik), 26o tırmanış
  dişin önündeydi, 26o kazan sancak yolunu kapatıyordu, 26 merdiven başı stauroma fıçılarına/kazana dayanıyordu.

- Kareler: 26 (8 çift), 26o (6 çift) `kare/` altında; bütçe tabloları raporda.
- Son düzeltmeler: merdivenler mazgal açıklığında, stauroma/kazan kaçınma; `SurSetSahne.govde_gorunur` (düellocu sur yolunun
  korkuluğunu görür: 26o sur yolu dövüşü 2–3 sn'de "atılarak" bitiyordu); saldıranlar hendek duvarına yürümüyor; İmparator
  kulenin önünde; dost düellocular dağıtılıyor.

## Süren
- Son kodla tam liste: `testler/` (80 koşu: 26 ×2 + kararsız üçlü ×5, 26o ×2, eski kalanlar, =yuru ×4, bağımlı bölümler ×1).

## Sıradaki
- menu_return 26; sözleşme üçlüsü; rapor son hâli.
