# Bağımsız denetim: bakış yönü / iş yaparken oyuncuya dönme — DENETÇİ

Önce `docs/_ajan/gorev/_ortak2.md` dosyasını oku ve uy. Rapor dalın: `wip/denetim-bakis`, klasör `docs/_kanit_denetim_bakis/`.
Geliştirici raporu: `docs/_ajan/rapor/bakis.md`. Denetlenen dosyalar (`git diff e551de84 -- <dosya>`):
`scripts/level/stage.gd` (`gaze_dir`, `work_begin/work_end/work_turn`, `grip_hold`, `reach`), `scripts/npc/person.gd`,
`scripts/npc/soldier.gd`, `scripts/npc/rig.gd` (`_player_glance`), `scripts/npc/crowd.gd` (`look_at_event`),
`scripts/autoload/game_state.gd` (`_look_audit`; yolu `grep -rn "_look_audit" scripts/` ile bul), `scripts/chapter8y.gd`
(`_open_gate`), `scripts/chapter4.gd`, `scripts/chapter9.gd`, `scripts/chapter10.gd`.

Sahibin şikâyeti: "kapıyı açanlar bize bakarak kapıyı açıyor … tüm oyunda mı böyle yaptın?" Kişiler iş yaparken
(kapı açma, döküm, ip çekme, yürüme) gövdeleriyle oyuncuya dönüyordu.

## Sına
1. **Sahibin anı:** 8y kapı (sürgüyü kaldırma, taşıma, kanatları çekme, yol verme) ÖNCE | SONRA; Bölüm 4 deniz kapısı
   (Niko), 10b Urban döküm. Kişi işine dönük mü, eli işte mi, bitince oyuncuya dönüyor mu?
2. **EN ÖNEMLİ, gerileme:** ortak düzenek konuşma bakışını bozdu mu? En az 14 bölümde (1, 3, 4, 6, 8, 9, 10, 10b, 12,
   17, 20, 24, 26, 35o) konuşan kişi konuşurken oyuncuya bakıyor mu; 3 m'den uzaktaki alet işindeki kişi konuşurken
   dönüyor mu; 2,5 sn sonra işine dönüş doğal mı (ani sıçrama, titreme, ileri-geri salınım var mı)? `SAYFACE` satırlarını
   ÖNCE ve SONRA say (bütün bölümler, varsayılan varyant) ve anahtar anahtar karşılaştır. Geliştirici
   `D9_KADRI_OFFER_1`'i AÇIK bıraktı: kök nedeni bul (düzeltme önerini kod parçasıyla yaz, uygulama).
3. **Yürüyenler:** yürürken gittiği yöne bakma (17 Radu/Vlad, 20 ve 26 Giustiniani, 28o/35o Urban, 31o): kareyle
   doğrula; "ay yürüyüşü" (geri geri yürüme), yan yan kayma var mı?
4. **Kalabalık:** `rig.gd`/`crowd.gd`: uyuyan, yatan, yaralı, ölü kişiler oyuncuya bakmıyor; ayakta boş duranlar hâlâ
   bakıyor mu (canlılık kaybolmamalı)?
5. `LOOKAUDIT` denetimi: yanlış alarm ve kör nokta; yalnız testte mi çalışıyor, oyunda maliyeti var mı?
6. 8y nöbetçi mızrağı (yere dikiliyor): havada duruyor mu, gövdeye giriyor mu, sonra eline geri alıyor mu?
7. Oyun geneli tarama: `grep -rn "look_target = player" scripts/ | wc -l` (geliştirici 243 dedi). İş + bakış birlikte
   geçen en az 20 an seç (farklı bölümler), kareyle bak, tabloyla ver.
8. Testler: bütün bölümler varsayılan varyantla birer kez (`tests/run_tests.sh` listesi) + 8y, 4, 9, 10b bütün varyantlar.
