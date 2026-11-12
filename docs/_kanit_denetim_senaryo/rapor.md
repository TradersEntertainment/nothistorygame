# Denetim raporu: "kuralı çiğneyen oyuncu" senaryo paketi

Denetçi: bağımsız oturum. Dal: `wip/denetim-senaryo`. Denetlenen: `wip/senaryo-kacak` (ucu `db6e50dd`).
ÖNCE = `f0250c48` (`wip/0.99.119` ile ortak atası; `git merge-base HEAD origin/wip/0.99.119`). SONRA = dalın ucu.
Oyun kodu DEĞİŞTİRİLMEDİ (probe/ÖNCE için geçici değişiklikler `git checkout` ile söküldü; `git status`: yalnız Godot'un
ürettiği `.import`/`.uid` dosyaları, kaydedilmedi). Ses üretilmedi. Alt ajan/zamanlayıcı yok.

Kurulum: Godot 4.4.1, `parse_check` PASS (249 betik). Ekranlı koşular xvfb 1280x720, `PACE=1 --dialogshots --shotevery=1 --snapevery=0.5`.
Kare adları: `/root/calisma/f41k`, `f_s24hit`, `f_s24soft`, `f_s6animal`, `f_s6sold`, `f_s41iade`, `f_s42kacak` (depo dışı); depodaki paftalar bu klasörde.

## Değişenler (`git diff --stat f0250c48 HEAD`)
26 dosya, +1645/−23: `scripts/level/kural.gd` (yeni, 984 satır, `class_name` yok), 10 bölüm betiği (6, 10g, 24, 24o, 31o, 36b, 37o, 39o, 41o,
42b: bağlantı + test raporu), `achievements.gd`, `i18n/strings.csv` (+94), `docs/voice/VOICE_MAP.csv` (+75), `tests/*`, belgeler,
derlenmiş `i18n/*.translation`.

## Madde madde hüküm

### (1) Talimden kaçış (41o, 42b)
**DOĞRULANDI (kısmen kanıtlı).** Kare: `pafta01`, `pafta02`, `pafta04`.
- Alan: merkez = meydan, yarıçap 18,5 m (`chapter41o.gd:161`, `chapter42b.gd:143`; `kural.gd:176-209`). Kum zemin 24x28 m (±12 m): ilk uyarı
  kum kenarından ~6 m ötede, görünür bir sınır işareti yok (yalnız halka çiti var). Tasarım notu, kusur değil.
- Kademeler sırayla ve karelerle görüldü (41o): "Kâtip! Meydan bu yanda…" (2 sn) → "Kalk bre! Getir şu kâtibi…" → balyadan kalkan azap koşuyor
  (kare dizisi: uzaktan koşu, boyu büyüyen yaklaşma) → "Yakaladım ağam!" → kararma → (kart) → meydan. 42b aynı: "Tercüman. Talim burada…" →
  "Getirin onu. Nazikçe; şimdilik." → gönüllü koşuyor → "Kumandanım, kaçak burada…".
- Dönüş: kararma altında, kaçtığı yerin son iç noktasına (41o'da iskele tepesi/halka); ışınlanma karartmasız yok, havada duran kişi yok;
  azap balyasına geri oturuyor (kare: `pafta02`). Ders akışı (Turgut "Son iş…") bozulmadan sürüyor.
- Üstelemek (2. kaçış, "Yine mi?"), 37o/36b göndermesi: **KANITSIZ** (kodda `kural.gd:192-195`, `chapter37o.gd:256`, `chapter36b.gd:215`; kaçan
  rotada koşu yok, ben de koşturmadım; yalnız eski varyantlar PASS).
- CEZA kartı ve Turgut/Giustiniani'nin ceza sözleri karelerde **SEÇİLMİYOR** (kart sırasında `--snapevery` kareleri düşüyor; `PACE say` günlüğünde
  `KRL_TALIM_O_PUN_1/T_PUN_O/PUN_2`, `KRL_TALIM_B_PUN_*` söylendiği görülüyor). Görsel olarak KANITSIZ.
- **Kusur (küçük):** `firar` sayacı ve `firar_41o/42b` bayrağı alandan 2 sn çıkınca yazılıyor (`kural.gd:187-191`), oyuncu hemen dönse bile.
  Böylece 2 sn gezinip dönen oyuncu "kaçmış" sayılıyor: ACH_FIRAR'a bir adım, 37o/36b'de "Talimden kaçan…" sözü. (ÖNCE'de yoktu: özellik yeni.)
- **Kusur (test):** `kacak_iade` varyantı botu alan merkezinden 65,5 m uzağa ışınlıyor; orada zemin yok (`pafta03`: Hikmet/Nihat sözleri
  sırasında karenin alt yarısı gri boşluk). `WARN_VOID_TELEPORT pos=(-46.9,-1.5,193.5)` 4 koşunun 2'sinde çıktı (başsız 1. tur; ekranlı).
  Yasak satır; 2. başsız tur temiz (kararsız). Gerçek oyuncuda bu uzaklığa gidilebiliyorsa aynı boşlukta Büro sözlerini dinler: BAKILMADI.
- Dövüş (spar) sırasında kaçış: probe (`probe_spar_kacis.log`) KISMEN/KANITSIZ: kaçan bot yakalanmadan bölüm bitti (spar botu uzaktan vurmaya devam
  ediyor, test yapay); gerçek oyuncuyla yakalanmanın dövüşü kesip kesmediği bilinmiyor.
- Geri dönen oyuncuya ceza: 7 sn içinde dönerse sessiz sıfırlanma (`kural.gd:182-184`), ceza yok: adil. Sıkışma yok: dönüş noktası son iç nokta,
  kararmada yerleştiriliyor.

### (2) Halka / asker / hayvan / hükümdar
- **Erkek sivil, 24 (ressam)** — `pafta05..07`: **DOĞRULANDI.** 1. vuruş: vurulan döner, kollarını kaldırır (şaşkınlık), "Hey! Ne yaptın sen? Beni katır mı
  sandın?" → Tolga "Pardon! Refleks. Sigortacı refleksi." 2. vuruş: "Al sana! Bu da benden!" + Tolga yere (kırmızı ekran, Nihat'ın sözü). 3. vuruş: muhafız
  arkadan koşarak geliyor (görüş dışı), kamera ona dönüyor "Dur! İmparator'un kanunu adına!" → kararma → zindan kartı + 3 söz (günlükte
  `KRL_ZINDAN_G/T/N`) → aynı sokak. Kademe artıyor (3 basamak). **Gözlem:** vurulanın karşı tekmesi karelerde yakalanmadı (ayakta duruyor, arkasını dönüyor,
  işine dönüyor); tekme animasyonu 0,5 sn'lik karelere sığmıyor: KISMEN. **Kusur:** muhafız yaklaşırken oyuncunun kamerası ona tek karede 180° atlıyor
  (`player.face(g…)`, `kural.gd:667-668`): görsel sıçrama (kararma yok).
- **Kadın (24, mum yakan)** — `pafta08`: **DOĞRULANDI.** Bacak kalkıyor/iniyor (birinci şahıs, bacak karelerde seçilmiyor), kadın elini başına götürüyor, Tolga
  "Yok. Annem duysa beni Zamanatör'le kendisi geri yollar.", vuruş işlemiyor, şiddet yok. Sıradaki kademeler (araya girme, Hikmet): `krl_soft` 2 tur PASS (2 durdurma).
- **Hayvan (6, keçi)** — `pafta09`: **DOĞRULANDI.** Keçi kafa atıyor, Tolga yere (zemin hizasında kamera). Tavuk/at/öküz/kedi: koşulmadı (KANITSIZ; kodda).
- **Asker (6)** — `pafta10`: **KISMEN.** "Asker: Bre! Askere ayak kaldırılmaz!" → Tolga yere → kararma → kadı kartı → sürüyor (`arrests=1`). Kurban ocak başında
  oturan bir ordugâh işçisi (rolü OSMSOL sayıldı); "ayağı yakalar" hareketi karelerde yok (`_leg_abort` yalnız Tolga'nın bacağı).
- **Komutan** (`_commander`): KANITSIZ (koşturmadım; geliştirici de koşturmadı).
- **Hükümdar** — **DOĞRULANDI (probe).** Geçici kanca (söküldü; çıktı `probe_hukumdar.log`) ile 6b'de İmparator'un 1,7 m önüne ışınlanıp tekme: `KURAL ruler face=emperor`,
  `replay_scene` çağrıldı, bölüm 6b baştan kuruldu (HELDDEFAULT, CYPRESS, LORE sırası, hata yok), `tarihe_tekme` her denemede +1 (0→9, probe 10 kez
  döndürdü); kayıt/akış bozulmadı, bölüm tekrar normal açıldı. Bir uyarı: `WARNING: Target object freed before starting, aborting Tweener` (`_leg_abort`
  tween'i sahne sökülürken; zararsız). Kart/Nihat-Hikmet sözleri karede yakalanmadı (KANITSIZ). Fatih için yol aynı kod (`RULERS`), ayrı koşu yok.
  Not: otomatik testte bu yol bilerek kapalı (`kural.gd:762-766`): bu yüzden hiçbir test onu sınamıyor.

### (3) Kuralı çiğnemeyen oyuncu
**DOĞRULANDI.** Varsayılan varyantlar 41o, 42b, 24, 10g, 6 (+b/c/y/letter/byz*/next), 24o, 31o, 39o, 36b, 37o: bütün sonuçlar eski PASS ile aynı
(`testler_ham.txt`), `KURAL` günlük satırı 0 (varsayılanda hiç devreye girmiyor). ÖNCE kodla (`scripts` f0250c48'e alınıp) 41o/24/6/10g/24o varsayılan koşuldu: replik
anahtar sırası (`SAYDIST`) 24, 10g, 24o, 6'da birebir; 41o'da SONRA'da iki ek satır (`D41O_H_KICK_FOLLOW_OK`, `D41O_H_KICK_DOWN_1`): bunlar bölümün kendi
tekme evresi, botun zamanlamasına bağlı (ÖNCE'nin kendi iki koşusu ve SONRA'nın üç koşusu `spar=4/0`, `1/0`, `3/0` gibi oynuyor); Kural günlüğü boş. Süre ölçümü yapılmadı (BAKILMADI).
**Risk (kanıtsız, kodla):** `kick` = F / SOL TIK ve `Traversal._click` ile aynı girdi. Bağlı bölümlerde 2,3 m önünde biri varken tırmanma/atlama tıklayan
oyuncuya da Kural'ın tekmesi çalışır (`kural.gd:338-352`; `traversal.gd:134` `focus_id==""` iken tıkı tırmanmaya veriyor). `traversal.wall_ahead()` ile
duvar varsa Kural geri çekilmeli.

### (4) Başarımlar / sayaçlar
**KISMEN.** `tests/ach_check.gd` ACHCHECK PASS: `ACH_FIRAR` (`firar≥3`), `ACH_KADI` (`tutuklama≥1`), `ACH_TARIHE_TEKME` (`tarihe_tekme≥1`) bir kez (`unlock_achievement`
zaten tekrar vermez, `game_state.gd:1934`), `Hud` her turda `Achievements.check()`. Sayaçlar `GameState.stats` içinde, `bump_stat` ile `_save_meta` (kalıcı). Kayıt/yükleme
sonrası sayaç değerleri bir oyun koşusuyla sınanmadı (BAKILMADI; `stats` meta dosyada tutuluyor, `prepare_load` onlara dokunmuyor). Tarihe tekme replay'inde sayaç
artıyor, başarım bir kez (probe: 10 replay, yeniden açılma yok). Yanlış an: `firar` erken sayılıyor (bkz. (1)). Başarım AÇILMA TOAST'ı karede görülmedi.

### (5) 75 yeni replik
- `git diff f0250c48 HEAD -- i18n/strings.csv`: **silinen/değişen satır 0**, 94 eklenen (75 sesli + 19 arayüz/başarım); `VOICE_MAP.csv` +75, silinen 0;
  `yeni_replikler.txt` (75) = VOICE_MAP'e eklenen anahtarlar (eşit, `diff` boş). Her anahtarın `en` karşılığı var (94/94).
- `tests/check_keys.py` (6819, 0 sorun), `check_speakers`, `check_voice_rules` (9759), `check_inline` (723), `check_export_refs`, `check_outcomes` (74/74),
  `check_consequences` (0 sorun), `check_tween_await`: hepsi PASS.
- Dil/canon notları: Osmanlı tarafı ("bre", "ağam", "kâtip", "lâkin", "falaka", "kadı") ve Cenevizli/Bizans tarafı dönemine uygun; Tolga'nın sigortacı jargonu
  ("hasar tespiti", "kapsam dışı", "poliçe", "temassız") tutarlı; Hikmet "Evlât", Nihat form/Büro dili tutarlı. Küçük notlar (zorunlu değil):
  `KRL_ZINDAN_N` "Ücretim formdur." (ek "-dur" bürokrat esprisi ama okunuşta tuhaf; "Ücretim bir form." daha akıcı); `KRL_TOWNB_HIT_2` "Kuşatma yetmiyor,
  bir de sen mi?" kuşatma öncesi bir sokakta (6. bölüm Mart sonu) çelişebilir; `KRL_JAN_ARREST` fetih sonrası sokakta ("Subaşıya gidiyoruz") uygun.
  `KRL_TALIM_O_1/2` Turgut'un "Kâtip" hitabı 41o'nun kendi hitabıyla ("kâtip") uyumlu.

### (6) `scripts/level/kural.gd`
- Kare başı: `_physics_process` iki-üç karşılaştırma + `_free_to_act` (ucuz). Bölüm çıkışında temizlik: düğüm sahnenin çocuğu (sahneyle gider); koşturucu tween'i
  `_home_back`te öldürülüyor; muhafız `queue_free` (`kural.gd:614`); bekleyen `await`lar sahne gidince sönüyor. Sızıntı bulunmadı (probe'ta 10 replay temiz).
- **Kusur (orta):** her tekme/tık basışında `_target()` içindeki hayvan taraması `scene.find_children("*","Node3D",true,false)` ile BÜTÜN ağacı geziyor
  (`kural.gd:381`), kişi bulunmuş olsa bile ve 24'te binlerce düğüm var; tırmanma tıklarında da basışta çalışır. Hayvanları grupla tutun ya da yalnız
  kişi bulunamadığında ve hayvan gruplarıyla tarayın. RINFO ölçmedim (geliştirici de ölçmemişti): BAKILMADI.
- **Kusur (küçük):** `_civilian` yürüyen vurulana `look_target = player` veriyor (`kural.gd:486-488`) → `LOOKAUDIT raw Person … kind=walk` (24'te 3 satır, 6'da 2, 10g'de 2;
  ÖNCE'de yok). Yasak listede değil ama denetim satırı; `_look()` (Rig.stare_t) zaten var. Ölçüm: ressama/yürüyene `look_target` yerine baş çevirme.

## Yeni kusurlar (özet; "ÖNCE'de var mıydı?")
| # | Kusur | Yer | ÖNCE'de? |
|---|---|---|---|
| K1 | `LOOKAUDIT raw` (vurulan yürüyene look_target) | `kural.gd:486-488` | yok (yeni) |
| K2 | `kacak_iade` botu zeminsiz noktada: `WARN_VOID_TELEPORT` (kararsız) | `kural.gd:939-945` | yok (yeni) |
| K3 | `firar` sayacı/bayrağı 2 sn dışarıda hemen yazılıyor (geri dönse de) | `kural.gd:187-191` | yok (yeni) |
| K4 | Tekme/tık basışında tüm sahne ağacı taraması; tırmanma tıkıyla çakışma riski | `kural.gd:338-394` | yok (yeni) |
| K5 | Muhafız gelince kamera tek karede 180° atlıyor | `kural.gd:667-668` | yok (yeni) |
| K6 | Kart/ceza kareleri ve karşı tekme karelerde doğrulanamadı | — | — |
| K7 | Ekranlı günlüklerde `ERROR: Lambda capture at index 0 was freed` (24; CITYLIFE sonrası, Kural satırından önce) ve `VISAUDIT offview D41O_H_PARRY_SOFT` (41o, Kural'dan önce) | Kural dışı olasılıkla | ÖNCE'de var mı: BAKILMADI |

## Kurallara uygunluk (`git diff f0250c48 HEAD`)
Var olan replik metni/sırası/süre/sayaç/sonuç/kalabalık/bot yolu: değişmedi (bölüm diff'leri yalnız bağlantı, `bot_window` penceresi ve `test_ok`/`test_line`; `i18n/strings.csv` ve `VOICE_MAP.csv` yalnız ekleme). `no_audit`/`_ok` meta/filtre YOK.
Kanca/sonda kalmadı: depoda `PROBE`/`DENETIM` araması 0, `git status` oyun kodu temiz. Geliştirici ekranlı kare için kanca da bırakmamış. 31o'ya bağlandı ama varyant/`bot_window` yok;
39o bağlı ama sokakta rol taşıyan kişi olmadığı için (geliştirici varyantı kaldırdı) sınanmıyor: o bölümlerde tekme yolu KANITSIZ.

## Test satırları (özet; ham: `testler_ham.txt`)
- Yeni varyantlar (`kacak`, `kacak_iade` x 41o/42b; `krl_hit` x 24/10g/24o/6; `krl_soft` 24; `krl_soldier`, `krl_animal` 6) **2 turda 22/22 PASS**; yasak satır: yalnız `y1_41o_kacak_iade` `WARN_VOID_TELEPORT` (1). Ekranlı: 41o kacak, 41o kacak_iade, 42b kacak, 24 krl_hit, 24 krl_soft, 6 krl_animal, 6 krl_soldier hepsi PASS; yasak satır: `WARN_VOID_TELEPORT` (41o iade), `VISAUDIT offview` (41o, Kural dışı).
- Eski varyantlar: 41o (-, lose), 42b (-, lose), 24 (-, late, niko, niko_slow, eclipse), 10g (-, fatih, late, next), 6 (-, b, c, y, letter, byz, byzmistake, byzfail, byzclimb, byzgive, next),
  39o (-, late, tezkire, pass, sailor_ok, sailor_bad), 31o (-, late, petrion_ok, petrion_bad), 24o (-, late, thermos, tea, menu, eclipse), 36b (-, leave), 37o (-, lose, trespass): **tümü PASS, yasak satır 0.**
- `parse_check` PASS (249), `ach_check` PASS, `tests/check_*.py` PASS.
- Not: harness'im ilk turda boş varyantlı satırları bir sonrakiyle birleştirdi; `testler_ham.txt`te `variant=e_…` yazan satırlar bu yüzden geçersiz sayıldı, aynı koşular `e_*_-` ve `e3_*` ile temiz yeniden koşuldu.

## Replik notları
Bkz. (5). Sahibin kararı gereken yer (geliştiricinin §6'sı): hükümdar tekmesi bölümü baştan başlatıyor: mekanik olarak güvenli çalıştığı doğrulandı (probe), "sert mi" tasarım kararı sahibin.

## GENEL HÜKÜM: KÜÇÜK DÜZELTMELERLE KABUL

Gerekçe: talim kaçışı, sokak tekmesi (3 basamak + tutuklanma), kadın/hayvan/asker/hükümdar tepkileri çalışıyor; eski varyantların hepsi PASS ve değişmeden; replik/çeviri/ses haritası temiz;
başarımlar doğru. Yakalanan kusurlar küçük/orta; hiçbiri akışı kırmıyor.

### Zorunlu düzeltme listesi
1. `kural.gd:_civilian` (486-488): vurulana `look_target` verme; `_look(n)` (Rig.stare_t) kullan. Beklenen: 24/6/10g `krl_hit` günlüğünde `LOOKAUDIT raw` 0.
2. `kural.gd:_bot_tick` "kacak_iade" (939-945): kaçış noktasını zeminli yere sınırla (ışın kontrolü; zemin yoksa uzaklığı azalt). Beklenen: `kacak_iade` 10 koşuda `WARN_VOID_TELEPORT` 0 ve iade karelerinde ufuk/zemin görünür.
3. `kural.gd:_area_tick` (187-191): `firar` sayacı/bayrağı yalnız 2. basamakta (seslenme, kovalayan koşarken) yazılsın ya da oyuncu laf sırasında dönünce geri alınsın. Beklenen: 2 sn çıkıp dönen oyuncuda `firar` ve 37o/36b sözü yok.
4. `kural.gd:_target` (381) + `_hits_tick`: hayvan taramasını ağaç gezmeden yap (grup), ve `player.traversal.wall_ahead()` doluysa tırmanma tıkını Kural işlemesin. Beklenen: duvara tırmanırken yanındaki sivile tekme/ceza yok; tık başına tarama maliyeti yok (RINFO üç örnek).
5. `kural.gd:_guard_run` (667-668): `player.face(guard)` yerine yumuşak dönüş (0,3-0,5 sn). Beklenen: muhafız belirişinde kamera sıçraması yok.
6. (Kanıt) Ceza/iade/zindan/kadı/hükümdar kartlarının ve Turgut sözlerinin kareleri: kart sırasında kare alımı sürsün ya da test kancasıyla kart anı kaydedilsin; 31o ve 39o'ya (ya da en az 31o'ya) `krl_hit` varyantı eklensin.
