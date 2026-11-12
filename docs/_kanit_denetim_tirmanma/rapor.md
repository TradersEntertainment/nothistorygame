# Tırmanma animasyonu — BAĞIMSIZ DENETİM RAPORU (dal `wip/tirmanma` ucu `ad5b2bd4`)

**HÜKÜM: KÜÇÜK DÜZELTMELERLE KABUL** — yayına engel olacak bir bulgu YOK; ama aşağıdaki "kanıtsız" sahneler (30'un kendi askeri, 30o geç kalan azap, düellocu, 29o dışındaki NPC'ler, oyuncu bakışından hücum) bu denetimde karede görülemedi; bunlar kabulü koşula bağlar (bkz. §8).

Ortam: Godot 4.4.1 resmi linux x86_64, xvfb 1280×720, `--rendering-driver opengl3`, yazılım çizim (kare ≈ 0,1–3 sn). Oyun dosyalarına DOKUNULMADI (`git status` yalnız Godot'nun ürettiği `.import`/`.translation`). Sonda: `tests/_tmp_denetim/probe.gd` (SceneTree ana döngüsü; oyunu kendi ekler, tırmanış başlayınca `Engine.time_scale=0,25` ile her karede tam boy kare alır, yan kamera tırmananın merdiven yerelinde 4,2 m yanda, HUD gizli). Betik KAYDA EKLENMEDİ.
Kare adları: `k_<sahne>_side_NN.jpg` (yan, sonda), `k38o_oyuncu_NN.jpg` (oyuncu kamerası), paftalar `p01…p13`. Her `side_00` karesi oyuncu kamerasıdır (sonda kamerayı henüz almadı) → tırmanış karesi değil, sayılmadı.

## 1. Ne değişti (`git diff origin/main...HEAD`)
381 dosya, +8392/−324; bu dalın (tırmanma, taban `8cfc996a`) payı: `scripts/` altında 11 dosya (chapter29o/30/30o/33o/38o/42b, combat/duelist, level/assault, level/blachernae, player/player, **yeni** npc/climb_anim.gd 614 satır). Geri kalanı P3 + önceki turlar, ses (`assets/audio/voice/en`), `i18n/strings.csv` (+37), `docs/_kanit_*`.
Denge / gizli süre / sayaç / kazanma-kaybetme / replik / kalabalık sayısı — tırmanma payında DEĞİŞMEMİŞ: `git diff 8cfc996a..HEAD` satır satır okundu; `HOLD_TIME` (`chapter38o.gd:24`, 45,0), `fork_at`, `pot_at`, `FORK_WINDOW`, `CLIMB_TIME` (30), 33o merdiven süresi (1,2 sn / 3 m), 42b `_climb_t`, assault sıra/çarpışma kararları (`lp` ile ayrı tutuldu) aynı. Replik anahtarı/metni değişmedi (tırmanma payında `i18n` yok).
Değişen sabitler (yerleşim/kamera; oyun mantığı değil), main'e göre:
- `chapter38o.gd:548-549` `CLIMB_AT` 2,6 → 3,5; `CLIMB_GAP` 2,8 → 3,5 (tayfa merdivendeki başlangıç yeri).
- `chapter38o.gd:543` `BRACE_LOOK` yeni 3,2 (eski: `player.face(point_at(h*0.6))`), bakış açısı.
- 38o `_climb_side` ±0,1 → ±0,3 → `side` ±0,12 (climb_anim'e).
- 38o: tutma bitince eskiden `queue_free` ile birden yok olan tayfa artık mazgala geçip yürüyerek ayrılıyor (`_crew_over`/`_crew_mantle`, ~3,4 sn ek süre; oyuncu akışı bekletilmiyor).
- RNG: `chapter38o.gd _crew_tick` `randi_range` / `randf` çağırıyor (global RNG'yi tüketir; kazanma/kaybetme etkisi yok, ama aynı tohumla önceki dizi birebir tekrarlanmaz).
- Test/denetim gevşetilmemiş: `tests/` ve `run_tests.sh` bu dalda DEĞİŞMEMİŞ (`git diff origin/main...HEAD --stat -- tests` boş); `CLIMBAUDIT` susturma işareti yok (`climb_anim.gd:_audit`). Denetim eşikleri (el 0,06 m, ayak 0,06 m, 8°, göğüs 0,15–0,35 m) dev tarafından seçilmiş; gevşetilip gevşetilmediği geçmişe bakılmadı (yeni kod, karşılaştıracak eski eşik yok).
- Oyuncu merdiven elleri: `player.gd:_ladder_hands_tick` `stow_hands(true/false)` ile eşyayı cebe alıp çıkarıyor (stow sayacı dengede; tutma/hız değişmedi).

## 2. Her tırmanış sahnesi — kare bulguları
Her pafta kare numaralarıyla; "karelerde tek tek" yerine pencere bazında (kareler ≈0,1 oyun-sn arayla, ardışık ve neredeyse aynı olduğu için tekrar yazmadım; aralıklı farklar ayrıca anıldı). Ölçüt başlıkları: E=eller basamak/dikmede, A=ayaklar basamakta, G=gövde yaslı, B=boşlukta uzuv, U=ucun üstünde havada, İ=uzuv gövdeden geçiyor, T=ters dirsek/diz, S=sıçrama, Y=yok olma/belirme, SL=sallanınca döner.

| Sahne | Kare | E | A | G | B | U | İ | T | S | Y | SL |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 38o tayfa (yan) | `p03`, `k_38o_side_01…11` | ✔ (05,07,08 uzanma; 01–03,09–11 dikme/basamak) | ✔ (01,04,06 net) | ✔ yaslı | yok | yok | yok | yok | yok (≤0,09 m/kare) | yok | KANITSIZ (ibre sabit) |
| 38o tayfa (oyuncu kamerası) | `p01`, `k38o_oyuncu_01` | görünmez (gövdenin ardı) | ✔ (yakın kesit `p02`) | ✔ | yok | yok | seçilmiyor | seçilmiyor | 6 kare ≈4 sn, tayfa tepede bekliyor | yok | KANITSIZ |
| 20 hücum (yan) | `p05`, `k_20_side_01…10` | KISMEN (bir el dikmede; öbürü gövde ardında) | **SEÇİLMİYOR** (kaftan etek örtüyor) | ✔ baş/omuz dikmede | yok | yok | yok | seçilmiyor | yok | yok | KANITSIZ |
| 26o hücum (yan) | `p11`, `k_26o_side_01…11` | ✔ (01,03,05,10 uzanma) | ✔ (ayak basamakta 02,04,08,10) | ✔ | yok | yok | yok | yok | yok | **09'da yatay uzanmış gri kaftanlı figür** (aşağıya bak) | KANITSIZ |
| Blakherna arka plan fesli (30o/30 koşuları) | `p04`, `k_30o_blk_side_01…11` | ✔ (02,05,07,10 net) | ✔ | ✔ | yok | yok | yok | yok | yok | yok | KANITSIZ |
| 42b gönüllü (yan) | `p06`, `k_42b_side_01…11` | ✔ (02,04,08) | ✔ (06,07,11) | ✔ | yok | yok | yok | yok | yok | yok | KANITSIZ (itilme yok) |
| 33o işçi (yan) | `p07`, `k_33o_side_01…03` | seçilmiyor (iskele kafesi) | seçilmiyor | görünür yaslı | yok | yok | seçilmiyor | seçilmiyor | 4 kare | hedef 1,2 sn sonra bitti (beklenen) | KANITSIZ |
| Oyuncunun kendi tırmanışı (`tests/ladder_test.tscn`) | `p08`, `k_oyuncu_player_00…07` | sol el ✔ her karede basamakta/hizada; sağ el HİÇ görünmüyor | – | – | sağ el kadraj dışı | – | – | – | – | – | – |
| 29o ip (oyuncu, `--dialogshots`) | `p10` (t0213–t0224) | ✔ iki el ipte, dönüşümlü (kare 214, 217, 220 alt-üst el değişiyor) | – (ayaklar görünmüyor) | – | yok | – | – | – | 12 kare ≈ 0,6 sn aralık | yok | – |

Ek bulgular:
- **26o `side_09`** (`k_26o_side_09.jpg`, `p11`): merdivenin önünde YATAY (başı sağda) gri kaftanlı figür görünüyor, alttaki karede (10) gidiyor. Düşme ("fall") animasyonu olması muhtemel; ama merdivende kalan askerle çakışıyor, 1 karelik. Kök neden araştırılmadı → isteğe bağlı.
- Hücumda (20 ve 26o) alttaki ve üstteki askerin göz hizası arası yakın (≈0,8 m); baş/gövde birbirine değiyor gibi (iki asker `p05` 05–10), `İ` olarak işaretlenmedi ama sıkışık.
- 38o börk 08–11'de merdivene doğru eğiliyor, dikmeye değip değmediği seçilemedi.

**Karede GÖRÜLEMEYEN (KANITSIZ):** 30'un kendi askeri (`s30_side` yalnız `tag=blachernae` yakaladı; 30'un `tag=30` hiç belirmedi), 30o geç kalan azap/`peek` (`tag=30o` belirmedi), 33o ayrıntısı (kafes), düellocu (26/26o koşularında yalnız `assault` etiketi), oyuncu bakışından hücum (`p09`: bot ok sandığı peşinde, tırmanan kareye girmedi), 38o'da sallanma/kayış/yeniden tutunma (`_crew_remount`: testlerde `slips=0`), 29o dışında ipte NPC yok. Yan kamera 38o'da 4 karelik ilerlemeyi gösteriyor, ama merdivenin sallanması hiç tetiklenmedi.

## 3. Sahibinin karesi (38o, tutma evresi, oyuncu kamerası, 8 kare, ≈0,66 sn arayla) — `p01_38o_oyuncu_8kare.jpg`, `p02_…yakin_kesit.jpg`
Günlük: `probe_log` START t=51,98; kareler t=52,11…56,78.
- 00: tutma öncesi (güverte replik).
- 01: iki tayfa merdivenin en üst ucunda, mazgal siperinin hizasında; üstteki (bordo) öne eğik, bacakları merdivende, ayaklar basamakta. Eller görünmez.
- 02–07: tayfalar "2 · MERDİVENİN AYAĞINI TUT" bandının ARKASINDA; yalnız ayak uçları seçiliyor.
**Dürüst yargı:** "Boşluğa/gökyüzüne tırmanıyor" izlenimi 01'de YOK (ayaklar basamakta, gövde yaslı, ve yandan kare `p03` bunu tam doğruluyor). Ama oyuncunun gerçek kamerasından 02–07'de tayfa bandın altında kaldığı için okunmuyor; yani sahibinin göreceği kadrajda hâlâ pek görünmüyor — bu HUD bandının işi (dev raporu da bunu yazıyor); animasyon olarak iyi, oyuncu karesinde zayıf.

## 4. Testler (başsız, `--max-fps 20`; ham: `ham/`)
- `parse_check`: `PARSECHECK PASS scripts=249`.
- Değişen bölümlerin TÜM `run_tests.sh` varyantları ×3 (+38o `hooks_bad` toplam ×10): 38o (4 varyant ×3 + 7), 33o (3 ×3), 29o (2 ×3), 30o (4 ×3), 42b (2 ×3), 30 (4 ×3), 20, 26, 20o (varsayılan ×3): **73 koşu, 73 `AUTOTEST PASS`**, `SCRIPT ERROR`/`WALKTHRU`/`HELDAUDIT`/`WARN_*`/`VISAUDIT`/`CLIMBAUDIT`: 0; `TIMEOUT`: 0.
- Tek yasak satır: `ARMAUDIT unarmed scene=chapter30o.tscn foe_dist=2.0 duel_active=false` — `30o =lose`. Karşılaştırma (aynı komut, `--max-fps 20`, 8'er koşu): **origin/main 3/8, bu dal 5/8** (+ ilk üç koşuluk pakette 1/3). Yani önceden de var; dalda biraz yüksek ama 8 örnekle fark anlamlı değil (aynı bölüm aralıklı). `ham/arm_main.txt`, `ham/arm_branch.txt`.
- Son satırlar (örnek): `AUTOTEST PASS chapter=38o variant=hooks_bad outcome=38O.1 …`, `AUTOTEST PASS chapter=30o variant=lose outcome=30O.2 …`, `AUTOTEST PASS chapter=20 variant= outcome=20.1 repair=10 …` (hepsi `ham/t*.txt`, `ham/e*.txt`).
- ÇalıştırılMADI: 21/22/22o/25/26 diğer varyantları, 28o, 31o, 32o, 36b, 37o, 41o, 20 diğer varyantları (dev bunları 106 koşuda geçirdiğini yazıyor; ben yeniden koşmadım). Kararsız olanı (ARMAUDIT) 10 yerine 8+8 koştum.

## 5. Kare hızı (hücum, bölüm 20, t=5…15 oyun-sn, aynı makine, ÖNCE=origin/main `git archive` kopyası `~/is/main_tree`, SONRA=dal; yazılım çizim, aynı anda 3 başka süreç koşuyordu — çok gürültülü)
| koşu | kare | ort. kare süresi | p95 | en kötü |
|---|---|---|---|---|
| ÖNCE 1 | 27 | 3304 ms | 3864 | 3953 |
| ÖNCE 2 | 27 | 3069 | 3746 | 4330 |
| SONRA 1 | 27 | 3283 | 4446 | 4568 |
| SONRA 2 | 27 | 3094 | 3576 | 3807 |
Ortalamalar ÖNCE 3186 / SONRA 3188 ms: fark gürültü içinde (±%7). En kötü kare SONRA 1'de +%15 (4568 vs 3953) ama SONRA 2'de −%12; tutarlı artış yok. Bu ölçüm yazılım çiziminin CPU yüküdür, GPU yüklü gerçek donanımda anlamlı değil; dev raporu kişi başı ≈0,6 ms/24 tırmanan der, bu ölçümle çelişmiyor, doğrulamıyor da (**KISMEN**).

## 6. P3 maddeleri (`docs/_kanit_dp3/rapor.md`) — kendi karemle
| # | Madde | Karem | Durum |
|---|---|---|---|
| 1 | 38o tutma kadrajı | `p01` 01–07: oyuncu merdiven ayağında, ibre bandı, tayfa görünür (01), 02–07 görev bandı altında | KISMEN (bant tayfayı kapatıyor; dev de bildirmişti) |
| 2 | 38o `world.visible=false` yok | `grep "world.visible" scripts/chapter38o.gd` → yok; 38o karelerinde dünya her karede çiziliyor | DÜZELDİ |
| 3 | 29 kanca ipi içeriden | `p13` (D29_C_FIRE civarı) — kanca ipi/küpeşte yakın karesi alınamadı | KANITSIZ |
| 4 | 29o ip ağı / düşüşte şerit | `p10` t0213–t0224: iki el ipte, ip ince düz çizgi, yakın krem şerit yok | DÜZELDİ (tırmanış); düşüşte karede bakılmadı |
| 5 | 29 seren demeti "mızrak" | `p12` (D29_C_WIND +0…+11): beyaz konik "mızrak" yok; demet de seçilmiyor (seren görünmüyor) | KISMEN (mızrak yok; demet yerinde KANITSIZ) |
| 6 | 29 halat çeken tayfa | `p13`: arkada mavi/beyaz tayfalar ip tutuyor, uzak; yakın kesit yok | KANITSIZ |
| 7 | 38o `hooks_bad` `VISAUDIT personhidden` | `hooks_bad` ×10 (3+7): 10/10 PASS, `VISAUDIT` 0 | DÜZELDİ |

## 7. KUTU bakışı (bu dalın işi değil; gördüklerim)
- `k_42b_side`: gönüllünün gövdesi (beyaz önlük) düz dikdörtgen blok (kutu gövde), dar bacaklar — "kutudan yapılmış canlı".
- `k_20_side`, `p05`: hücum askerinin kaftanı çan/kutu şeklinde (yassı kare kesit), bacaklar tamamen gömülü.
- `k_26o_side_09`: yatay figür kutu gövdeli, düz.
- `p12`: gemi kenarında düz renkli yuvarlak diskler (kalkan/çıkma) — canlı değil, yuvarlak nesne.
- 33o'da sarı kalas/kutu yığınları (balya) — canlı değil.

## 8. HÜKÜM: KÜÇÜK DÜZELTMELERLE KABUL
**Zorunlu (yayına engel): yok** — `CLIMBAUDIT` 73 koşuda 0; 38o, 26o, 30o arka plan, 42b yan karelerinde tırmanış net (eller/ayaklar basamakta, gövde yaslı, boşlukta uzuv yok).
**Kabul koşulu (kanıtsız kalan sahnelerin teslim edilmesi, engel değil ama açık):**
1. 30'un kendi askeri, 30o geç kalan azap (`peek`), düellocu, 33o ayrıntısı, 38o sallanma/kayış/yeniden tırmanma karede doğrulanmadı (§2).
**İsteğe bağlı:**
1. 38o: tutma bandı (HUD) tayfayı kapatıyor (`k38o_oyuncu_02…07`); bantı yukarı al ya da tayfayı kadraja kaydır.
2. Oyuncunun kendi tırmanışında sağ el hiç kadrajda değil (`k_oyuncu_player_00…07`).
3. Hücumda (20/26o) kaftan bacakları gizliyor (`p05`, `p11`); iki asker aynı merdivende üst üste (`p05` 05–10).
4. 26o `side_09`: yatay figür merdivenin önünden geçiyor (düşme geçişi?) — bakılsın.
5. `ARMAUDIT` 30o `=lose` ara sıra (main 3/8, dal 5/8) — dalın artırıp artırmadığı 8 örnekle ayrılamadı; ≥30 koşuyla bakılsın.
6. 38o `_crew_tick` global RNG'yi kullanıyor; kararlı tohum isteniyorsa yerel `RandomNumberGenerator`.

## 9. Kural sapmaları / dürüst notlar
- `timeout 590 bash -c 'until …'` bekleme döngüsü iki kez kullandım (kural: yasak); sonra düz `until` ile değiştirdim.
- Aynı anda en çok 3–4 süreç (ekranlı + başsız) koştu → kare hızı/PERF ölçümleri gürültülü; kare yakalama `Engine.time_scale` 0,2–0,5 ile alındığından karelerin oyun-saati aralığı ≈0,03–0,13 sn (günlük `t=`).
- İlk kare koşusu 38o'da `PACE=1` ile tayfayı kaçırdı (oyuncu merdiveni değişkeni beklendi), düzeltilip yeniden alındı; sonraki koşularda `PACE` kullanılmadı.
- 38o yan koşusunun ilk kısmı (ilk ekranlı koşu) merdiven başındaki bekleme anına denk gelip hareketsiz kareler verdi; atıldı, hareket tetikleyicisiyle yeniden alındı.
- `tests/_tmp_denetim/` altında `probe.gd` var, depoda değil; yalnız `docs/_kanit_denetim_tirmanma` eklendi.

---


# EK: ara kayıt notları (önceki sürümler, aynı koşulara dayanır)

# Tırmanma denetimi — ARA KAYIT 1 (devam ediyor)

Denetçi koşusu: Godot 4.4.1, xvfb 1280×720, `--rendering-driver opengl3`, `PACE=1`, `-s tests/_tmp_denetim/probe.gd` (kayda eklenmedi).
Oyun dosyalarına dokunulmadı. Bu kayıt yalnız 38o oyuncu kamerası karelerini içerir; sürüm hükmü sonraki kayıtta.

## 38o — tutma evresi, oyuncu kamerası, 0,6–0,7 sn arayla 8 kare (`p01_38o_oyuncu_8kare.jpg`, tekil: `k38o_oyuncu_00..07.jpg`)
Günlük: probe_log START t=51,98; kareler t=52,11 … 56,78 (≈0,66 sn aralık), tutma sayacı 45→42 sn.
- k00: tutma henüz başlamadı (güvertede replik, tayfalar görünmüyor).
- k01: iki tayfa merdivenin en üst ucunda, mazgal siperinin hizasında. Üstteki (bordo) öne eğik, bacakları merdivende; ayaklar basamaklarda görünüyor (yakın kesit `p02`, sol üst). Eller kadrajda DEĞİL (gövdenin arkasında/üstte), seçilemiyor. Boşlukta asılı uzuv yok. Ucun üstünde havada duran yok (kalça siper hizasında).
- k02–k07: tayfalar "2 · MERDİVENİN AYAĞINI TUT" bandının ARKASINDA, yalnız bacak/ayak uçları seçiliyor (baş-gövde bandın altında). Ayaklar basamakta gibi, ama bu karelerde el ve gövde değerlendirilemez. Kareler arası hareket: 6 karede (≈4 sn) belirgin yükselme yok; tayfa tepede bekliyor (üstteki zaten tepenin iki basamak altında).
- Dürüst hüküm (ara): "gökyüzüne/boşluğa tırmanıyor" izlenimi k01'de YOK (basamaklarda, merdivene yaslı); ama 6 karede okunmuyor çünkü görev bandı tayfayı kapatıyor (rapor 3 zaten bildirmişti; bant HUD'un işi). Alt tayfa bu karelerde görünmüyor ya da üsttekinin arkasında.
- Not: tayfa t=52'de başlangıçta zaten merdivenin tepesinde; "3,5 m'den başla" beklentisi oyuncu bakışından görünmüyor (merdiven bakış çizgisine paralel).

---
# ARA KAYIT 2 — yandan (sonda kamerası) kareler

Yöntem: `tests/_tmp_denetim/probe.gd` (kayda eklenmedi) oyunu kendi ana döngüsünden açar, tırmanış başlayınca `Engine.time_scale=0,25` ile
her karede (≈0,1 oyun sn) 1280×720 kare alır; yan kamera tırmananın merdiven yerelinde (`_r` yönünde 4,2 m, HUD gizli). Ham günlük satırları (`probe_log`) için kareler `k_*` adlarıyla.
Her pafta içindeki kare numarası `side_NN`; 00 numaralı kare her koşuda oyuncu kamerasıdır (sonda henüz kamerayı almamış) — tırmanış karesi sayılmaz.

## 38o — yan, 11 kare (`p03_38o_yandan_12kare_sonda.jpg`, `k_38o_side_01..11.jpg`), günlük: s=9,30→10,00, 1 adım ≈1,4 sn
Tüm karelerde (01–11): ellerden biri basamakta/dikmede (kare 05, 07, 08: sağ el bir üst basamağa uzanmış; 01–03, 09–11: dikme/basamak üstünde); diz bükük, ayak basamağın üstünde (01, 04, 06 net); gövde yatık merdivene yaslı, göğüs ile merdiven arası dar; boşlukta asılı uzuv yok; merdivenin ucundan yukarıda havada duran yok (tayfa orta boyda, ucun çok altında); uzuv gövdeden geçmiyor (kollar gövde önünde); dirsek/diz ters kırılmıyor. Kareler arası sıçrama yok (konum her karede ≤0,09 m, günlük `who=`). Börk 08–11'de hafif öne devriliyor, dikmeye değip değmediği seçilemiyor. Yok olma/belirme yok. Merdiven sallanması bu pencerede ≈0 (ibre sabit) → "sallanınca birlikte döner" bu karelerde KANITSIZ.
HÜKÜM: bu kamera açısından "boşluğa tırmanma" yok; gerçekten merdivende.

## 20 hücum (assault) — yan, 10 kare (`p05_20_hucum_yandan_11kare.jpg`)
Üstteki asker (kahverengi kaftan, günlük s=10,8→12,9) 01–10'da: baş ve omuz merdiven dikmesinde, gövde merdivene yaslı, alttaki sarıklı yalnız baş+kol görünüyor (2 asker aynı merdivende, ≈0,8 m görünüş aralığı). **Kaftan etek bacakları ve ayakları tamamen örtüyor: ayakların basamakta olup olmadığı KARELERDE SEÇİLMİYOR (KANITSIZ).** El: yalnız bir el dikmede seçiliyor, öbürü gövdenin arkasında. Kamera orta-yakın; tırmananın bacağı ve basamak teması denetim ölçüsüyle (CLIMBAUDIT 0) doğrulanıyor, gözle değil.
Oyuncu kamerası 20'de (`p09_...`): tırmanan yok; oyuncu bot ok sandığı peşinde, kare tırmanışı kapsamıyor → **oyuncu bakışından hücum tırmanışı KANITSIZ**.

## 30o (Blakherna arka plan tırmananı; azap/peek DEĞİL) — yan, 11 kare (`p04_30o_blakherna_arkaplan_yandan_12kare.jpg`)
Fesli tırmanan: sol/sağ el dikme ve basamakta (02, 05, 07, 10 net uzanma), dizler bükük, ayaklar basamakta, gövde yatık merdivene yaslı; hareket akıcı. En iyi kareler bunlar. 30o'nun kendi geç kalan azabı (`peek`) ve 30 askeri bu koşuda yakalanmadı (günlük `tag=blachernae`; `tag=30o` hiç belirmedi) → **peek KANITSIZ**. 30 (`s30_side`): yalnız `tag=blachernae` arka plan; bölümün kendi askeri yakalanmadı → **KANITSIZ**.

## 42b — yan, 11 kare (`p06_42b_gonullu_yandan_12kare.jpg`)
Beyaz önlüklü gönüllü: sol el basamakta üst, sağ el dikmede (02, 04, 08 uzanmış), bacak bükük, ayak basamakta (06, 07, 11 net), gövde merdivene yaslı. Boşlukta asılı uzuv yok; hareket akıcı. Önceki raporun "42b KANITSIZ (üstten)" yan karede doğrulandı.

## 33o — yan, 4 kare (`p07_33o_isci_yandan_4kare.jpg`)
Tırmanan işçi iskele kafesinin ardında kısmen kapalı, merdiven üstünde yaslı görünüyor; hedef 4. karede bitti (1,2 sn). Ayak/el ayrıntısı seçilmiyor → **KISMEN/KANITSIZ**.

## Oyuncunun kendi tırmanışı (`p08_oyuncu_kendi_tirmanisi_8kare.jpg`, `tests/ladder_test.tscn`)
Ana oyun yerine merdiven test sahnesi (bot tırmanıyor). 8 karede yalnız SOL kol kadrajda (diğeri kadrajın altında); sol el her karede bir basamağın üstünde/hizasında, bir üst basamağa yükseliyor. Sağ el hiç görünmüyor (önceki raporun "bir el kadrajın altında" notu doğrulandı: KISMEN).
