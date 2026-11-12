# Bağımsız denetim (2. tur) — fragman kusurları: düzeltme turu + "kusur2" · `wip/denetim2-kusur`

Denetlenen: `wip/duzeltme-kusur` ucu (`e2d7455a`). ÖNCE = `main` `e551de84` (yalnız ilgili 7 dosya `git show e551de84:<dosya>` ile depo DIŞI
kopyada eski hâline getirildi: `/root/cal/once`); SONRA = dal ucu (`/root/cal/sonra`; başsız testler depoda, sondasız).
Araç: Godot 4.4.1 resmî sürüm, xvfb + yazılım çizimi, 4 çekirdek. Oyun kodu DEĞİŞTİRİLMEDİ. Sondalar (günlük, fare olayı enjeksiyonu,
iniş sonrası bakış döndürme `PROBE_YAW`, el-bilek günlüğü, 8y zorla uyarı) yalnız depo dışındaki iki kopyada; depoda `grep PROBE|BARK8` boş.
Ham satırlar: `testler.txt`. Kareler: `p01`…`p06` (JPEG ≤ 300 KB).

Yöntem notu — B2 ekranlı PACE=1 koşusu bu makinede ~0,4 kare/sn ve oyun zamanı yavaş çekimde akıyor; bu yüzden "sn" değerleri aksi
yazılmadıkça OYUN zamanıdır. "Bakış 0°/90°/180°": iniş anında oyuncunun yönü `_shore_look` yönüne ek `PROBE_YAW` derece döndürüldü
(0° = oyunun kendi yönü, taban −84,3°; ÖNCE'ye de aynısı uygulandı). Avuç–bilek hatası = `Stage.grip` dönüş değeri (her karede, kopyadaki
günlükten). Kameraya uzaklık = baş/kol/dirsek/gövde noktaları, `Camera3D.to_local` (kendi sondam; oyunun `_seize_audit`'ine bağlı değil).

## 1. Hüküm özeti

| # | Madde | Hüküm |
|---|-------|-------|
| d1 | B2 yakalama bakışa duyarlı: kilit + anlık yön; hata ≤ 0,10 m, asker ≥ 0,65 m, `WALKTHRU` yok | **KISMEN** (kilit ve kameradan uzaklık DOĞRULANDI; avuç–bilek hatası 90°/180°'de **YANLIŞ**; kilit süresi 3 sn'yi aşıyor) |
| d2 | `_seize_audit`: sabit adlar, süre boyu en kötü değer, tek basış, yalnız autotest | **KISMEN** (ok yolu DOĞRULANDI; ihlal yolu KANITSIZ) |
| d3 | B0 donmada düşme yok | **DOĞRULANDI** |
| d4 | B0 yer/tarih yazısı ≥ 2,0 sn tam okunur, patlamaya/TOLGA kartına taşmaz | **KISMEN** (taşma DOĞRULANDI; 2,0 sn bot ve PACE'te YANLIŞ: 1,6–1,9 sn) |
| d5 | 8y uyarı oku keçi repliğini kesmez | **DOĞRULANDI** |
| k1 | B17 Edirne: Vlad dönüp geri dönmüyor | **DOĞRULANDI** (kebap/Radu satırı KANITSIZ) |
| k2 | B10b: Urban "…Hmm." kadrajda | **DOĞRULANDI** (yeni: `D10B_U_EARS` hâlâ kadraj dışı, ÖNCE'de de) |
| k3 | B2 kızak yolundaki asker çekiliyor | **DOĞRULANDI** (işçinin kimliği ve s=47/80 askerleri KISMEN/BAKILMADI) |

GENEL HÜKÜM: **KÜÇÜK DÜZELTMELERLE KABUL** (bölüm 6; zorunlu 1–3).

## 2. Düzeltme turu maddeleri

### d1 — B2 yakalama bakışa duyarlı (`chapter2.gd:_seize`, `_to_shore`, `_to_chain`)
Ekranlı PACE=1, sonuç 2.1 (`--autotest`), ÖNCE | SONRA, her bakışta iki karelik pafta `p01` (satırlar 0°, 90°, 180°; sol çift `D2_T_15`, sağ çift `D2_S_16`; her çiftte ÖNCE solda):

| bakış | | avuç–bilek hatası (asker 1 / asker 2, en çok) | kameraya en yakın nokta | kameranın içi/yanı (baş-kol-dirsek-gövde, kamera yerelinde z>−0,25 ve xy<0,8) |
|---|---|---|---|---|
| 0° | ÖNCE | 0,095 / 0,000 | **0,50 m** | **156 örnek** (baş (−0,45;−0,48;−0,22)) |
| 0° | SONRA | **0,100 / 0,080** | 0,70 m | 0 |
| 90° | ÖNCE | 0,174 / 0,389 | 0,42 m | 200 |
| 90° | SONRA | **0,255 / 0,249** ✗ | 0,88 m | 0 |
| 180° | ÖNCE | 0,597 / 0,448 | 0,49 m | 231 |
| 180° | SONRA | **0,153 / 0,255** ✗ | 0,72 m | 0 |

- Asker kameraya ≥ 0,65 m ve `WALKTHRU` yok: **DOĞRULANDI** (her üç bakışta; oyunun `SEIZE_AUDIT ok closest=0.70/0.88/0.72`).
- Avuç–bilek hatası ≤ 0,10 m: **0°'de sınırda geçiyor (0,100)**, **90°'de 0,25 ve 180°'de 0,15–0,26 ile YANLIŞ**. Geliştirici raporu aynı şeyi (0,256/0,249 ve 0,252) dürüstçe yazmış; kabul ölçütü karşılanmadı. Görünüm: `p01` 90° ve 180° sağ çift — eldivenler bileğe değil yanında havada, 180°'de ikinci asker kadrajın alt kenarında yalnız börkü görünüyor. İyileşme ÖNCE'ye göre büyük (örn. 180°: 0,60 → 0,26), ama ölçüt karşılanmadı.
- Gerçek oynanışta oyuncu yakalama sırasında bakışını çeviremediği için (aşağıya bak) pratikte `_shore_look` yönü geçerli; o yönde başka iniş noktaları: `chainfail` (2.4) 0,100/0,080, `swimshore` (2.1) 0,101/0,084 (başsız PACE=1; ham: `testler.txt`). Yani gerçek yollarda ölçüt ≈ sınırda (swimshore 0,001 m aşıyor); 90°/180° yalnız yapay.
- **Bakış kilidi gerçekten tutuyor:** fare hareketi enjekte edildi (`Input.MOUSE_MODE_CAPTURED`, 120 px, her 8 karede). ÖNCE: replik açıkken `PMOUSE_CHANGED … line_open=true dyaw=−15,13°` (oyuncu bakışı çevirebiliyor — özgün hatanın kaynağı). SONRA: 0 değişiklik / 7 enjeksiyon; `yawdrift=0.00`.
- **Kilit süresi (geliştirici "≥ 10 sn tahmin" demişti, ölçülmemişti):** `look_lock`=true'dan bırakmaya OYUN zamanı **7,7–8,0 sn** (sonuç 2.1, `--autotest`), `chainfail` 9,7 sn, `swimshore` 14,0 sn. ÖNCE'de bu bakış serbestti. `docs/_ajan/ajan_kurallari.md` ek kural 9 "oyuncudan alınan denetim 3 sn'yi geçmesin" → **aşılıyor** (d_kusur.md de süreyi yazmayı istemişti; yazılmış sayılır ama hâlâ kural dışı). Oyuncu bu süre boyunca zaten replik izliyor/`frozen`; yine de kural 9 ihlali.
- Götürme/karartma evresi aynı: 8 varyant × 2 tur PASS, `outcome` ve `telsiz` aynı.

### d2 — `_seize_audit` günlüğü
Kod: sabit adlar (`head, arm_l, arm_r, elbow_l, elbow_r`), parça başına süre boyu en kötü değer, `_seize_report()` ile tek basış, çağrılar `GameState.autotest` altında (`chapter2.gd:1239-1240`, `_seize_report` başında `if not GameState.autotest: return`). 16+ koşuda hepsi `SEIZE_AUDIT ok closest=0.68–0.73`, sahte alarm 0. **İhlal yolu (WALKTHRU çıktısı biçimi, sabit ad) hiçbir koşumda tetiklenmedi** (kilit varken yaw ile ihlal üretilemiyor) → o yol **KANITSIZ**. Zayıflık ÖNCE'den: yalnız baş/kol/dirsek ölçülüyor, börk/gövde ucu değil (benim sondam gövdeyi de kattı: SONRA'da yine 0 ihlal).

### d3 — B0 donmada düşme
`PACE=1 --chapter=0` başsız: ÖNCE'de `WARN_VOID_TELEPORT pos=(0.2, -415.4871, 9.4)` yeniden üretildi (`testler.txt`, "once PACE=1 B0"); SONRA: `AUTOTEST PASS`, `WARN_VOID_TELEPORT` **yok**. Ekranlı PACE=1 (ÖNCE ve SONRA) `WARN` yok. `--autotest=next` zinciri 0→1→2→3 PASS. Kod: `chapter0.gd:_freeze` (`gravity_on=false; velocity=ZERO`), `_rewind` (`gravity_on=true`). Donma sırasında oyuncunun y'sini ayrıca günlüklemedim (uyarının yokluğu + kod) → **DOĞRULANDI** (y sondası BAKILMADI).

### d4 — B0 yer/tarih yazısı
- **Patlama ve "TOLGA" kartı:** ÖNCE'de yazı patlama karesinde ve kartta duruyor, SONRA'da ikisinde yok (`p02`: üst satır ÖNCE, alt satır SONRA; aynı iki an). **DOĞRULANDI.**
- **Okunurluk:** `PLACE_OUT age=… hold=1,00` (yazı 1,4 sn'de tam yazılır; tam görünür kalma = (age−1,4)+hold+0,3):
  başsız bot `age=2,01` → **1,91 sn**; `next` 2,00 → 1,90; başsız PACE=1 `age=1,68` → **1,58 sn**; ekranlı PACE=1 `age=1,87` → **1,77 sn**. İstenen ≥ 2,0 sn bot ve PACE koşusunda **karşılanmıyor** (geliştirici de "bot hızında sığmıyor" yazmış; bu bir kusur sayılır çünkü fragman yaklaşımı botla/PACE ile çekiliyor). Koşan insan için ≈ 2,2–2,5 sn **hesap** (age ≈ 3,1–3,6 → hold 0–0,3), ölçülmedi → KANITSIZ. `age` bekleme alt sınırı `hold ≤ 1,0` olduğundan `age < 2,4` ise 2,0 sn'ye ulaşılamaz.
- `_first_step_hint` çakışması: durağan oyuncuyla ekranlı koşu BAKILMADI.

### d5 — 8y uyarı oku keçi repliğini kesmesin
Kopyada (ÖNCE ve SONRA aynı sonda) `D8Y_T_GOAT` Tolga yorumu olarak söylettirildi, 0,6 sn sonra `_warn("run")` zorlandı (`PACE=1 --chapter=8y --autotest=warn`, başsız):
ÖNCE: yorum t=133,75 → zorlanan uyarı t=134,35, `warn_bark talking=true` (keçi repliğini 0,6 sn'de kesiyor). SONRA: yorum t=135,25 → zorlama t=135,85 → `warn_bark` **t=139,80 `talking=false`** (keçi repliği sonuna kadar çaldı, uyarı 4,55 sn sonra). Ok yine anında atılıyor (`_shoot_arrow` ayrı). 8 varyant PASS (`warn` varyantı `lowered=2`). Not: doğal koşuda uyarı başka bir sesin üstüne (`talking=true`, `_yorum_left=0`) hâlâ binebiliyor — yalnız Tolga'nın hikâye yorumu korunuyor (istenen buydu). Ekranlı kare alınmadı (başsız; altyazı kutusu yok) — kanıt günlük.

## 3. Kusur2 maddeleri

### k1 — Vlad (B17 Edirne, `interlude_edirne.gd:_policy`)
`PACE=1` ekranlı `--chapter=17 --autotest=edirne_policy`, aynı an (`D17E_T_POL_3` → `D17E_V_POL_3`): ÖNCE `p04` alt sıra 2. kare Vlad sırtını/profilini dönmüş, sonraki karede geri dönüyor; SONRA `p05` Vlad bütün karelerde Tolga'ya dönük, mühür vuruşunda da. **DOĞRULANDI.** `_kebab()` Radu `face_toward` satırının kaldırılması: hiçbir varyant kebap yolunu seçmiyor → **KANITSIZ**.

### k2 — Urban (B10b `_explosion`)
`PACE=1` ekranlı `--chapter=10b --autotest=boom`, `D10B_U_B3_1` ("…Hmm.") anı: ÖNCE'de Urban kadrajda yok (Tolga Fatih/yeşil-kırmızı ikiliye bakıyor), ÖNCE günlükte `VISAUDIT offview key=D10B_U_B3_1`; SONRA'da Urban tam kadrajda, bu `VISAUDIT` yok (`p03`: üst ÖNCE, alt SONRA, aynı üç an). **DOĞRULANDI.** Yeni: aynı koşuda `VISAUDIT offview key=D10B_U_EARS speaker=SPK_URBAN` ÖNCE'de de SONRA'da da var (bölüm 4, Y2).

### k3 — Kızak askeri (`slipway.gd:_tick_track`)
`--chapter=2 --autotest=perfect`, ekranlı: yeşil kaftanlı "block" askeri ÖNCE'de oyuncu geçerken şeridin ortasında dikiliyor; SONRA'da oyuncu varmadan şerit dışına sıçrıyor (`p06`: üst ÖNCE, alt SONRA, t0162-0168). **DOĞRULANDI** (gördüğüm figür). İşçi kimliği çıkarım (geliştirici de yazmış); s=47 ve s=80 askerlerini ayrıca karelemedim → KISMEN. Bölüm 2 koşusunda `WALKTHRU/VISAUDIT` yok.

## 4. Yeni kusurlar (ÖNCE'de var mıydı)

- **Y1 — B2 yakalamada kilit 7,7–14,0 sn (> 3 sn kuralı).** ÖNCE'de yoktu (bakış serbestti; bu da özgün hatanın nedeniydi). Kural 9 ihlali; çözüm: aşağıda zorunlu 2.
- **Y2 — B10b `D10B_U_EARS`: Urban konuşurken kadraj dışı (`VISAUDIT offview`).** ÖNCE'de de var (aynı satır); k2'nin "öbür Urban anları sorunsuz" iddiası yanlış. Yalnız ekranlı PACE=1 koşusunda çıkıyor (başsız 10b'de çıkmıyor). Kare: `D10B_U_EARS` anında Fatih/yeşil ikili kadrajda, Urban yok.
- **Y3 — `LOOKAUDIT backturn` (B17, `grip` kişileri: `chapter17.tscn`)** `12 --autotest=next` zinciri ve `17 --autotest=fall` koşularında (SONRA); ÖNCE'de de `12→17` zincirinde aynı üç satır var. Bu işin dosyalarından değil (chapter17 değişmedi); listedeki yasak desen olduğundan not düşüyorum.
- **Y4 — `WARN_PORTRAIT_STUDIO speaker=SPK_KADRI` (B12 `kitchen`, `retry`)** — ÖNCE'de de var (önceki denetim Y6).
- **Y5 — 180°'de ikinci asker kadrajın alt kenarında kesik (`p01` sağ alt)**: yalnız yapay bakışta; gerçek yönde yüzler kadrajda.
- **Y6 — Test iskelesi:** `chapter0.gd:_place_out` içinde `PLACE_OUT` basışı (autotest altında; kural 3 "sürüme test iskelesi girmez" kapsamına girebilir; görev dosyasında istenmedi). Küçük.

## 5. Kurallara uygunluk
- `git diff ef860ea2 HEAD --name-only` (d_kusur geliştiricisi): yalnız `scripts/chapter0.gd, chapter2.gd, chapter8y.gd` + kanıt klasörü → izinli dosyalar.
- Replik metni/sırası, sayaç, kazanma koşulu, kalabalık sayısı, bot yolu: `git diff e551de84 HEAD -- <7 dosya>` içinde değişmemiş. Süre/zamanlama değişenleri: `chapter0.gd` `_place_out` (yazının sönme anı), `chapter8y.gd:_warn_lines` (uyarı SÖZÜ en çok 4,5 oyun sn ertelenir; istenen), `chapter2.gd` bakış kilidi (Y1), `slipway.gd` (asker erken sıçrar; `resolved`/engel yerleşimi aynı), `chapter12.gd` yalnız bot seçimi + test sayacı.
- Kanca/susturulmuş denetim: `no_audit`, `_ok` meta, `DBG`, `BARK8`, `PROBE` 7 dosyanın diff'inde ve `scripts/` altında yok. Yeni basışlar `GameState.autotest` altında (`SEIZE_AUDIT`, `WALKTHRU` biçimi, `PLACE_OUT`).
- Dalda `main`'den farklı çok sayıda başka dosya (45 betik: `player.gd`, `hud.gd`, `stage.gd` …) var; bunlar önceki turlardan geliyor, bu geliştirici turunda dokunulmamış (`ef860ea2..HEAD`). Denetim yalnız istenen 7 dosyaya bağlı; ÖNCE kopyası bu paylaşılan dosyaları SONRA'yla aynı taşıyor.
- `git status`: oyun kodu değişmedi; yalnız Godot içe aktarma artıkları (`*.import`, `i18n/strings.*.translation`, `*.uid`) var, KAYDEDİLMEDİ.

## 6. Test satırları (SONRA, `--headless --max-fps 20`; ham: `testler.txt`)

| Bölüm | Koşu | Sonuç |
|---|---|---|
| parse_check | — | `PARSECHECK PASS scripts=248` |
| 0 | `""`, `next` (0→1→2→3), `PACE=1 ""` | 3/3 PASS; `WARN_VOID_TELEPORT` yok (ÖNCE `PACE=1`: var) |
| 0 | ekranlı PACE=1 ÖNCE+SONRA | 2/2 PASS |
| 2 | 8 varyant × 2 (`""`,perfect,chain,chainfail,red,swimshore,swimchain,next) | 16/16 PASS; `SEIZE_AUDIT ok closest=0.68–0.73`; `WALKTHRU` 0 |
| 2 | ekranlı sonda: 0°/90°/180° × ÖNCE/SONRA; chainfail/swimshore başsız PACE=1 | 8/8 PASS (ölçümler bölüm 2 d1) |
| 8y | 8 varyant (`""`,warn,dep,opened,honest,hikmet,sinerji,next→9) | 8/8 PASS |
| 10b | `""`,eye,boom,untaped,tape,ulighter,cube,next(→11) | 8/8 PASS (`LOOKAUDIT raw` bilgi) |
| 12 | `""`,leblebi,twokings,repair,kitchen,retry,hikmet,nihat,urban,next(→17) | 10/10 PASS (`kitchen key=2`; `WARN_PORTRAIT_STUDIO` Y4; `LOOKAUDIT backturn` Y3) |
| 17 | `""`,two,fall,nophoto,chain,ship_ok,ship_bad,lost,edirne_policy,edirne_none,edirne_legend(--bag),osm,route | 13/13 PASS (`fall`: `LOOKAUDIT backturn` Y3) |
| 3, 8, 9 | `""` birer | 3/3 PASS |
| Ekranlı PACE=1 | B0, 10b `boom`, 17 `edirne_policy`, 2 `perfect` × ÖNCE+SONRA | 8/8 PASS |

`SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `JOURNEY_MISS`, `JOURNEY_OVERLAP`, `WARN_VOID_TELEPORT`: SONRA'da hiçbir koşuda yok. `VISAUDIT`: yalnız ekranlı 10b `boom` (`D10B_U_EARS`, Y2; ÖNCE'de de). `LOOKAUDIT backturn`: Y3 (ÖNCE'de de).

BAKILMADI: gerçek fareyle bakış çevirme (yalnız olay enjeksiyonu); durağan oyuncuyla B0 (`_first_step_hint`); B0 donma sırasında oyuncu y'si; `_seize_audit` ihlal yolu; kebap/Radu satırı; kızak s=47/s=80 askerleri; 8y için ekranlı kare.

## 7. GENEL HÜKÜM: KÜÇÜK DÜZELTMELERLE KABUL

Özgün kusurlar (askerin kameradan geçmesi, Vlad sıçraması, Urban kadrajı, kızak askeri, B0 yazısının patlamaya taşması, B0 donmada düşme, 8y uyarının keçiyi kesmesi) kanıtla düzelmiş; ama d_kusur.md'nin ZORUNLU 1. maddesi ölçütüyle (90°/180°'de hata ≤ 0,10 m) karşılanmadı ve kilit 3 sn kuralını aşıyor.

ZORUNLU düzeltmeler:
1. **`chapter2.gd:_seize/_grab_arms` (avuç–bilek, 90°/180°):** her bakışta ve her iniş noktasında (`swimshore` dahil) `Stage.grip` hatası ≤ 0,10 m olsun (askerin gövde yüksekliği/eğilmesini zemin farkına göre uyarlamak ya da oyuncunun eli askerin omzuna göre ayarlanmak: geliştiricinin önerisi). Beklenen görünüm: `p01` 90°/180° SONRA karelerinde iki yumruk bileklerde. (Dosya kısıtı gerekirse ORTAK DOSYA ÖNERİSİ: `Stage.grip_hold`.)
2. **Bakış kilidi ≤ 3 sn:** kilit yalnız askerlerin yerleştiği/yürüdüğü evrede (kamera yönünü sabitlemesi gereken kısa pencere) tutulsun ya da kilit varken yön sürekli yumuşak izlensin (kilit yerine `_cam_fwd`'i her karede güncelleme); toplam kilit ≤ 3 sn ya da oyuncudan alınan denetim süresi CHAPTERS'ta belgelensin.
3. **B0 yazı süresi:** `chapter0.gd:_place_out` bot/PACE=1 koşusunda da yazı tam yazıldıktan ≥ 2,0 sn görünsün (ör. `hold` üst sınırı 1,0 yerine patlamadan 0,26 sn öncesine dek serbest ya da yazı başlangıcını geciktir) ya da kabul edilen en kısa süre (1,6 sn) CHAPTERS'a yazılsın; ölçüm `PLACE_OUT`.
ÖNERİLEN: (4) B10b `D10B_U_EARS` anında `player.face(urban)` (Y2). (5) `PLACE_OUT` basışını kaldır (Y6). (6) `_seize_audit` ihlal yolu için bir pozitif kontrol.
