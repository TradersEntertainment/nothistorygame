# Bölüm 44 Sarnıç — 2. tur (denetim sonrası düzeltme ve güçlendirme)

Dal `wip/bolum-yerebatan`. Taban: denetlenen kayıt `33662898` (ÖNCE). Denetim: `origin/wip/denetim-yerebatan:docs/_kanit_denetim_yerebatan/rapor.md`
(HAYRANLIK 7/10, HEYECAN 5/10, K1–K9).

Kanıt yöntemi: ekranlı koşular (xvfb 1280×720, `PACE=1`, `--dialogshots --snapevery=0.5`, `RINFO=1 --hitchaudit`); bot oyuncudur,
kamera oyuncu kamerasıdır. **ÖNCE** koşusu aynı ayarla `33662898`'in depo dışı kopyasında (`git worktree`) alındı. `sonda_` adlı
kareler (`tests/cistern_shots.gd`) yalnız ayar içindir, kanıt sayılmadı. Kare adları `tNNNN` = koşunun 0,5 sn'lik oyun zamanı
karesi (ÖNCE: `once`, SONRA: `s3`; isabet/balık: `s4`). Parlaklık: 8-bit gri, karenin tamamı (HUD dahil), evre aralığındaki bütün
kareler.

Bot için PACE koşusu: bölüm ≈ 7,8 dk (N_01 27,7 sn → T_END 495 sn; ÖNCE ≈ 6,9 dk). Gerçek oyuncu tahmini 9,5–11,5 dk (kürek ve
dümen botun alt sınırı; okuma süreleri). Gizli süre eklenmedi; tek sayaç var olan sarsıntı sayacıdır (95 sn, dolarsa kayıp yok).

## Özet: ÖNCE → SONRA (ölçülen)

| Ölçü | ÖNCE | SONRA |
|---|---|---|
| İlk kürek evresi (T_BOAT → Yakovos), PACE duvar saati | 96,8 sn, olaysız | **56,8 sn**, 3 olay (balık sürüsü, uzak top+toz, şıpırtı+Nihat) |
| İlk kürek evresi, oyun zamanı (kare sayısı ×0,5) | ≈120 sn (kare 200–440) | ≈50 sn (kare 240–340) |
| Kürek evresi parlaklık: ort · <20 oranı | 22,6 · %74,2 (en kötü %81,3) | **34,3 · %44,3** (en kötü %49,0) |
| Açılış anı parlaklık | 30,7 · %58,6 | 41,3 · %34,1 |
| Sarsıntı evresi parlaklık | 17,5 · %81,4 | 54,3 · %31,2 (en kötü %60,3, tek kare) |
| Medusa anı parlaklık | 18,2 · %79,7 | 31,1 · %55,6 |
| Tırmanış: kararma | siyah ekranda replik (kare 782–794: ort 4–8/255, ≈6 sn oyun zamanı; denetçi videosunda ≈20 sn) | **tek kare (≤0,5 sn)**, kare 822 |
| Sarnıç çizim çağrısı (RINFO, en çok / medyan) | 411 / 297 | 460 / 277 |
| Sarnıç üçgen (en çok / medyan) | 906k / 846k (gölge 311k) | **621k / 571k** (gölge ≤109k) |
| Aynı anda ışık (Omni+Spot, ana dünya; ölçüldü) | bakılmadı (kodla ≈7–8) | **en çok 7** (Medusa anı), testte ≤8 denetleniyor |

## ZORUNLU maddeler (denetçinin 1–6 + K8, K9)

### K3 — Çıkış tırmanışında siyah ekran: DÜZELDİ
- `scripts/chapter44b.gd:1025 _climb`: sudan tonoza **ip merdiven**, bacada **demir basamaklar**, yukarıda **Yakovos'un kileri**
  (tahta döşeme, kuyu bileziği, rafta turşu küpleri, fıçı, açık kapıdan avlunun **gün ışığı**, kilerin ışığı). Kamera yukarı bakarak
  tırmanır (`CLIMB_SECS` = 6,5 sn), kilerin ağzından çıkıp kapıya döner, "Kırk basamak…" repliği kilerde, sonra 0,5 sn kararma.
- Kiler ve merdiven tek ağ: `scripts/level/cistern.gd:888 _build_cellar` (çizim +1); ışığı yalnız tırmanışta (`cellar_on`).
- Kanıt `p11_K3_tirmanis.jpg`: SONRA `s3 t0800` (merdiven/baca), `t0812` (kiler, replik), `t0822` tek kararma karesi, `t0826` avlu.
  Kararma ölçümü: kare 822 ort 0, 821 ve 824 aydınlık → ≤ 0,5 sn (≤ 2 sn ✔).
- Not: PACE'te canlandırma gerçek hızda oynar (`not GameState.autotest or GameState.pace`); hızlı başsız testte atlanır (önceden de öyleydi).

### K1 — Kuyu inişi: DÜZELDİ
- `cistern.gd:848 _well_stone_mat`: bacanın içi örme taş (sıra ~26 cm, harç derzi, aşağısı ıslak ve yosunlu); baca alta doğru
  **genişleyen** bir ağızla tonoza açılır (`_lathe` halkaları 0,56 → 1,05 m).
- `chapter44b.gd:328 _descend`: kamera önce **yukarı** bakar (ip ve ağızdaki gün ışığı dairesi; indikçe küçülür), sonra aşağı döner,
  "bu genişliyor" repliği ağız genişlerken ve altında tonozun karanlığı açılırken söylenir; düşüş kuyusunun huzme kartı iniş
  boyunca gizli (kamera içinden geçerken yatay çubuk gibi görünüyordu; `cistern.gd:1012 beam_visible`).
- Kanıt `p01_K1_inis.jpg`: ÖNCE denetçi p01 | SONRA `s3 t0098` (yukarı), `t0124` (replik, genişleyen ağız), `t0142` (tonoza açılış).
- KISMEN: ışık dairesinin "küçülmesi" tek karede değil art arda karelerde görülür; pafta yalnız yukarı bakış anını gösteriyor.

### K2 — Dış çizgili oval "balonlar": DÜZELDİ
- Kök neden: bunlar toz değil, ortak `Hud.wet()`'in çerçeveli damla panelleriydi (suya düşüş). Ortak dosyaya dokunmadan bölüm
  kendi yumuşak damlasını kullanıyor: `chapter44b.gd:385 _soft_wet` (5–11 px, radyal geçişli, çerçevesiz, kenarlarda; hafif buğu).
- Ek: huzme tozları kameranın 0,5 m dibinde görünmez (`cistern.gd:716` uzaklık solması); sarsıntı tozları aynı yumuşak malzemeyi kullanır.
- Kanıt `p02_K2_zerre.jpg`: ÖNCE denetçi p01 sağ üst + kendi `once t0100` | SONRA `s3 t0150`, `t0156`.

### K4 — Medusa: DÜZELDİ (ölçüm kaba)
- `cistern.gd:1236 _relief_cpu`, `:1272 _medusa_face_mesh`, `:1306 _medusa_head`: yüz artık **gerçek kabartma ağı** (44×44 ızgara;
  kaş, göz çukuru, burun, dudak, yanak, yılan saç halkası blokdan ~0,45 m taşar). Kaba blok sütunun kaidesi olarak arkada.
  "side" 90°, "inv" 180° döndürülü; ikisi de kayığın geleceği göze dönük.
- Kayık iki sütunun `MEDUSA_STOP` = 4,4 m güneyinde durur, **iki yüz aynı kadrajda**; kürekler içeri alınır (`_animate_oars`,
  `_medusa` başında `visible=false`), Yakovos'un kandil ışığı iki yüzün önünde ve **yanından** vurur (kabartmayı yan ışık seçtirir).
- Berrak suyun altında sahte yansıma kopyası artık çizilmiyor (`cistern.gd:165` ve tuğla gölgelendiricisinde `clear_zone` → discard),
  yerine köşede çamurlu taban (`_mud_floor`): önceki karmaşık görüntünün (ters tonozlar) kaynağı buydu.
- Kanıt `p10_K4_medusa.jpg`: ÖNCE denetçi p07 + `once t0760` | SONRA `s3 t0735`, `t0750`. Kafa bloğu kadraj yüksekliğinin ≈ %25'i
  (göz kararı ölçüm, piksel sayımı yapılmadı: KISMEN). Yan ve ters baş ayrı ayrı seçiliyor; kayık burnu kadrajın altında küçük bir şerit.
- **Gözyaşı sütunu rotada**: `HEN_EYE` [9, 2] (`cistern.gd:24`); sarsıntı rotası (tonoz gözü sırası 2) sütunun 2,5 m yanından geçer,
  4,5 m'ye girince Tolga'nın repliği `D44B_T_HENEYE` ve 0,7 sn bakış (`chapter44b.gd:710 _quake_tick`). Kanıt `p08_gozyasi_sutunu.jpg`
  (`s3 t0660`). Test: `hen_eye` olayı bütün varyantlarda (dark hariç: orada kayık kürek çekmez) zorunlu.

### K6 — Medusa replik çelişkisi: DÜZELDİ (yalnız bu bölümün yeni replikleri)
- Kurgu: Yakovos taş yüzleri **bu gece ilk kez** görüyor: sarsıntı dipteki çamuru silkelemiş, kandil suya eğilmiş; sabaha çamur yine
  örter; 1985 temizliğine dek kimse görmez (Gyllius'un "kimse bilmiyordu"suyla uyumlu).
- Değişen 4 replik (TR+EN; `i18n/strings.csv`, `docs/voice/VOICE_MAP.csv`): `D44B_Y_05` ("taş kadınların yanında" çıkarıldı),
  `D44B_Y_STONE` ("Kırk yıldır bu köşede balık tutarım, dipte çamurdan başka şey görmedim. Bu ne?"), `D44B_Y_MEDUSA` ("Sarsıntı çamuru
  silkelemiş…"), `D44B_N_MEDUSA` ("Sabaha çamur yine örter; 1985'teki temizliğe dek kimse görmeyecek"). Eski bölümlerin metnine
  dokunulmadı. `D44B_Y_RESCUE_2` ("Kırk yıldır karanlıkta sayarım") çelişmiyor, bırakıldı.

### K7 — VOICE_MAP satır sonları: DÜZELDİ
- CRLF geri getirildi. `git diff $(git merge-base HEAD origin/wip/0.99.119) -- docs/voice/VOICE_MAP.csv`: **74 ekleme, 0 silme**
  (64 ilk tur + 10 yeni; 4 değişen satır da eklenen satırlar arasında).

### K8 — Pil yazısı: DÜZELDİ
- `chapter44b.gd:1483 _battery_label`: sağ alt köşe, telsiz çubuklarının üstü (%5 altı sarı, %3 altı kırmızı); ortadaki istem satırı
  artık kullanılmıyor. Kanıt `p12_K8_pil.jpg` (ÖNCE `once t0240`, `t0680` | SONRA `s3 t0290`, `t0680`).
- Pil yalnız oyuncu denetimdeyken akar (konuşmada akmaz): `DRAIN` aynı, ama bölüm kısaldığı için bu, pilin sarsıntının ortasında
  bitmesini sağlıyor (gerilim anı korunur).

### K9 — `_run_shots` iskelesi: DÜZELDİ
- `chapter44b.gd`'den `_run_shots`/`_shot` ve `--shots` dalı çıkarıldı; sonda kareleri ve kapak `tests/cistern_shots.gd` + `.tscn`'e
  taşındı (mekânı tek başına kurar; kare adları `sonda_*`). `grep -n "_run_shots\|shots_dir" scripts/chapter44b.gd` → yalnız
  `_capture_mouse`'taki var olan denetim (ortak davranış).

## HEYECAN (zorunlu)

| İstek | Durum | Yer | Kanıt |
|---|---|---|---|
| Meşaleye varış ≤ 60 sn | DÜZELDİ: bot 56,8 sn (PACE duvar saati, T_BOAT dahil); Yakovos 45 m'de | `YAKOVOS_BAY`, `chapter44b.gd:524` | `s3` PACE satırları |
| İlk kürekte ≥ 2 küçük olay | DÜZELDİ (balık KISMEN): 3 olay, yolun %20/%45/%70'inde (her oyuncu görür); uzak top/toz ve şıpırtı/Nihat net, **balık sürüsü kadrajda küçük** (≈10 px'lik lekeler, kürek göstergesinin altında; `s5 t0264`) | `_ev_fish` :558, `_ev_far_shot` :612, `_ev_splash` :628 | `p05_ilk_kurek_olaylari.jpg` |
| Büyük, görünür düşen parçalar 2–3 m yakına; önce gölge/toz; sütun gibi sıçrama, halka; kayık sallanır | DÜZELDİ | `_cannon_shot` :741, `_drop` :1551 (toz sütunu + sudaki büyüyen gölge + halka), `_brick_fall` :1602, `_splash_column` :1638, yalpa `_roll` | `p06_sarsinti_dusen.jpg` |
| Top atışlarının ritmiyle dalga; tavan inler | DÜZELDİ: her atışta gümbürtü + tonozun inlemesi + yana iten dalga (`WAVE_PUSH`) ve yalpa; atış arası 8 → 4,5 sn | `_cannon_shot`, `_row_tick` | `p06` |
| Kasnak/payanda çöküp rotayı kapatır, daralan geçitten dümen kırarak geçiş | DÜZELDİ: rotadaki tonoz gözü çöker; kuzey ve güney kemerleri tümüyle, batı kemeri kuzey ucunda 1,8 m geçit bırakarak suya iner; devrilen kasnak; engeller kayığın çarpışmasına eklenir (sıkışma yok: itilir) | `_check_collapse` :770, `_collapse` :791, `cistern.gd:1020 add_obstacle`, `push_out` :1592 | `p07_cokus_gunisigi.jpg` (`t0564` geçit) |
| Su/akıntı kayığı sürükler | KISMEN: çöküşün dalgası kayığı 12 sn boyunca çöküş yerinden uzağa iter (`CURRENT_SPEED`); **su düzeyi yükselmiyor** (su düzlemi, yansımalar ve kayıklar `WATER_Y` sabitine bağlı; YAPILMADI) | `_row_tick` | — |
| Işık kritik anda titrer | DÜZELDİ: çöküşte fener 1,6 sn titrer | `_light_tick`, `FLICKER_SECS` | `p07` (`t0537`) |
| İsabet: su alır, fener düşer, karanlık panik, Yakovos'un ışığına yönelme | DÜZELDİ: kayık su alır (dipteki su yükselir, en yüksek hız −%10/isabet), ışık elden kayar 2,5 sn, bakış Yakovos'un kandiline döner, sonra ışık "kayığın dibinde" bulunur; kalıcı kayıp yok | `_hit` :1673 | `p09_isabet.jpg` (`s4`), test `hit` |
| "Nefes kesen" doruk | DÜZELDİ: çöken gözün yarığından gün ışığı (geniş huzme, toz), güçlü ışık 3,5 sn sütun ormanını boydan boya aydınlatır, sonra kalıcı huzme; yarıktan parça düşmeye devam eder | `_sunburst` :885, `cistern.gd:1035 breach` | `p07` (`t0552`, `t0580`); sarsıntı ort. parlaklık 17,5 → 54,3 |
| Adalet | KORUNDU: süre dolarsa Yakovos çeker (`dark` PASS), engeller itme ile (sıkışma yok), büyük parçalar isabet etmez, küçükler önceden uyarılı | — | testler |

Denetçinin "daha iyi olurdu" listesi: tuğla görünürlüğü, halkalar, daralan geçit, kısa olaylar, meşale ≤ 60 sn, leke deseni, uzak
ışık/sis, pil köşede, gözyaşı sütunu — hepsi yukarıda. "Tespit karesi oynanışta 3 sn": bakılmadı (gerçek oyuncu süresi bota bağlı değil).

## HAYRANLIK

- Uzak sıralar: sis yoğunluğu 0,055 → 0,03, sis rengi zifiri yerine sönük mavimsi gri (`cistern.gd:26 HAZE`, `:133 set_light`; gözün
  alışmasıyla açılır). Suyun uzak parıltısı: yatay bakışta su sisi ve kıpırtılı ışıltıyı yansıtır (`cistern.gd:619 glint`).
- **Açılış anının asıl kusuru**: düşüş kuyusunun huzme kartı kameranın içindeyken bütün ekranı toplamsal ışıkla kaplıyordu; kart 2 m
  içinde saydam (`cistern.gd:1128`). Deneyle ayrıldı: kart açıkken sonda ort. 54, kapalıyken 9.
- Sütun gövdelerindeki siyah "alev" lekeleri: fenerin gölgesi (ışık kameranın 22 cm altından çıktığı için başlık yapraklarının gölgesi
  gövdeye uzuyordu). Fener gölgesiz (`chapter44b.gd:437`); üçgen yükü de düştü (gölge geçişi 311k → ≤109k). Kanıt `p04`.
- Kürek evresi: ortam ışığı 0,35 → `AMBIENT_LIT` 0,75 + uzak sis + su parıltısı. Hedef (ort ≥ 30, <20 en çok %60): **ort 34,3, %44,3**
  (104 kare; en kötü kare %49). Sarsıntı 54,3 / %31,2 (en kötü tek kare %60,3: sınırda). Kanıt `p03`, `p04`.

## Ayar sabitleri (sahibin kararı; hepsi `scripts/chapter44b.gd:31–61`)

| Sabit | Değer | Anlamı |
|---|---|---|
| `BATTERY` | 14 | telefon pili (%) |
| `DRAIN` | 1/6,5 %/sn | fener açık ve oyuncu denetimdeyken |
| `LIGHTER_ON` / `LIGHTER_COOL` | 6 / 2 sn | çakmak |
| `QUAKE_TIME` | 95 sn | sarsıntı sayacı (dolarsa Yakovos çeker) |
| `YAKOVOS_BAY` | (13, 7) | meşalenin yeri (~45 m) |
| `ROW1_EVENTS` | 0,2 / 0,45 / 0,7 | ilk kürek olaylarının yol kesirleri |
| `SHOT_GAP_START` / `SHOT_GAP_END` | 8 / 4,5 sn | atış arası (sıklaşır) |
| `WARN_SECS` | 1,6 sn | düşüş uyarısı |
| `HIT_RADIUS` | 1,5 m | küçük parçanın isabet yarıçapı |
| `HIT_DARK_SECS` | 2,5 sn | isabette karanlık |
| `HIT_SLOW` | 0,1 | isabet başına hız kaybı (en çok 3) |
| `BIG_SIDE_MIN` / `BIG_SIDE_MAX` | 2 / 3 m | büyük parçanın yan uzaklığı |
| `WAVE_PUSH` | 0,8 m/sn | atış dalgası |
| `COLLAPSE_AHEAD` / `COLLAPSE_LATEST` | 3 göz / 32 sn | çöküşün yeri / en geç zamanı |
| `GAP` | 1,8 m | geçidin açıklığı (kayık 1,24 m) |
| `CURRENT_SPEED` / `CURRENT_SECS` | 0,4 m/sn / 12 sn | çöküşün dalgası |
| `FLICKER_SECS` | 1,6 sn | fener titremesi |
| `SUN_PEAK` / `SUN_PEAK_SECS` / `SUN_REST` | 5 / 3,5 sn / 1,3 | gün ışığı |
| `AMBIENT_DARK` / `AMBIENT_LIT` | 0,08 / 0,75 | ortam ışığı |
| `MEDUSA_STOP` | 4,4 m | Medusa'ya bakış uzaklığı |
| `CLIMB_SECS` | 6,5 sn | tırmanış |

Mekân sabitleri (`cistern.gd`): `HAZE`, `FOG_DENSITY` 0,03, `HEN_EYE` [9, 2].

## Replikler
- 10 yeni (TR+EN): `D44B_T_FISH`, `D44B_T_FAR`, `D44B_N_SPLASH`, `D44B_Y_LAMP`, `D44B_T_HENEYE`, `D44B_N_COLLAPSE`, `D44B_T_SUN`,
  `D44B_N_SUN`, `D44B_T_DROP`, `D44B_T_FOUND`; 4 değişen (K6). Liste: `docs/_kanit_yerebatan/yeni_replikler.txt` (74 replik, TR || EN,
  [YENİ]/[DEĞİŞTİ] işaretli). **Ses üretilmedi.** İngilizce anadil okuması yok.
- `i18n/strings.csv`: tabana göre yalnız ekleme (`git diff 99df39c5 --stat`: 116 ekleme; D44B_* ve bölümün UI anahtarları).
- `i18n/strings.{tr,en}.translation` yeniden üretildi (Godot içe aktarması; oyun bunları okuyor, yeni anahtarlar olmadan ekranda anahtar
  adı görünüyordu). Üretilmiş ikili dosya; başka anahtar değişmedi (kaynak CSV'de yalnız D44B ekleme var).

## Testler
- `parse_check`: **PARSECHECK PASS scripts=250**.
- 44b her varyant 3×, son kodla (`""`, `blab`, `dark`, `kid`, `nophone`, yeni **`hit`**): bkz. aşağıdaki tablo. Test artık olayları da
  denetliyor (fish, far_shot, splash, collapse, sun, hen_eye; hit'te hit+found+su alma) ve eşzamanlı ışık ≤ 8.
- Komşular: 24 (`""`, late, niko, niko_slow, eclipse) 5/5; 25 (`""`, caught, pass, kid, cistern, cistern_blab, osm, osm_caught,
  osm_tez) 9/9; 43o (`""`, bad, miss, dive) 4/4 — **18/18 PASS, yasak satır 0**.
- `tests/check_*.py` (8): consequences 0 sorun, export_refs PASS, inline PASS, keys 0 sorun, outcomes 76/76, speakers PASS,
  tween_await temiz, voice_rules PASS.
- Yasak satırlar (`SCRIPT ERROR`, `WARN_*`, `VISAUDIT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `LOOKAUDIT backturn`, `JOURNEY_*`): sıfır.

**44b her varyant 3× (`01d82066`): 18/18 PASS, yasak satır 0.** Sonraki küçük değişiklikler (hit test botu, balık yolu) üstüne ek: `hit` 3× + son kodla `""` ve `hit` birer kez PASS; ekranlı son koşu (`s5`, son kod) PASS.

| Koşu | Varyant | Sonuç | ışık | pil | çarpma | isabet | kurtarıldı | en çok ışık | olaylar | yasak |
|---|---|---|---|---|---|---|---|---|---|---|
| r1 | "" | PASS 44.1 | phone | 3.9 | 4 | 0 | false | 7 | fish,far_shot,splash,collapse,sun,hen_eye | 0 |
| r1 | blab | PASS 44.2 | phone | 4.0 | 5 | 0 | false | 7 | fish,far_shot,splash,collapse,sun,hen_eye | 0 |
| r1 | dark | PASS 44.1 | remote | 0.0 | 1 | 0 | true | 7 | fish,far_shot,splash,collapse,sun | 0 |
| r1 | kid | PASS 44.1 | phone | 4.0 | 4 | 0 | false | 7 | fish,far_shot,splash,collapse,sun,hen_eye | 0 |
| r1 | nophone | PASS 44.1 | remote | 14.0 | 8 | 0 | false | 7 | fish,far_shot,splash,collapse,sun,hen_eye | 0 |
| r1 | hit | PASS 44.1 | phone | 3.1 | 8 | 1 | false | 7 | fish,far_shot,splash,hit,found,collapse,sun,hen_eye | 0 |
| r2 | "" | PASS 44.1 | phone | 3.3 | 9 | 0 | false | 7 | fish,far_shot,splash,collapse,sun,hen_eye | 0 |
| r2 | blab | PASS 44.2 | phone | 3.9 | 4 | 0 | false | 7 | fish,far_shot,splash,collapse,sun,hen_eye | 0 |
| r2 | dark | PASS 44.1 | remote | 0.0 | 1 | 0 | true | 7 | fish,far_shot,splash,collapse,sun | 0 |
| r2 | kid | PASS 44.1 | phone | 4.2 | 4 | 0 | false | 7 | fish,far_shot,splash,collapse,sun,hen_eye | 0 |
| r2 | nophone | PASS 44.1 | remote | 14.0 | 4 | 0 | false | 7 | fish,far_shot,splash,collapse,sun,hen_eye | 0 |
| r2 | hit | PASS 44.1 | phone | 3.8 | 5 | 1 | false | 7 | fish,far_shot,splash,hit,found,collapse,sun,hen_eye | 0 |
| r3 | "" | PASS 44.1 | phone | 4.6 | 3 | 0 | false | 7 | fish,far_shot,splash,collapse,sun,hen_eye | 0 |
| r3 | blab | PASS 44.2 | phone | 4.5 | 3 | 0 | false | 7 | fish,far_shot,splash,collapse,sun,hen_eye | 0 |
| r3 | dark | PASS 44.1 | remote | 0.0 | 1 | 0 | true | 7 | fish,far_shot,splash,collapse,sun | 0 |
| r3 | kid | PASS 44.1 | phone | 3.8 | 3 | 0 | false | 7 | fish,far_shot,splash,collapse,sun,hen_eye | 0 |
| r3 | nophone | PASS 44.1 | remote | 14.0 | 4 | 0 | false | 7 | fish,far_shot,splash,collapse,sun,hen_eye | 0 |
| r3 | hit | PASS 44.1 | phone | 3.4 | 7 | 1 | false | 7 | fish,far_shot,splash,hit,found,collapse,sun,hen_eye | 0 |


## ORTAK DOSYA (en küçük değişiklik)
- `tests/run_tests.sh`: 44b satırına `"=hit"` varyantı ve yorum satırına açıklaması eklendi (yalnız bu bölümün satırı).
- Ortak `Hud.wet()` değiştirilmedi; öneri: çerçeveli damla paneli öbür bölümlerde de karanlık sahnede "balon" gibi okunabilir —
  `StyleBoxFlat` yerine radyal `GradientTexture2D` (bu bölümdeki `_soft_wet` gibi). UYGULANMADI.

## YAPILAMAYAN / KISMEN / BAKILMADI (dürüst liste)
- **Balık sürüsü zayıf okunuyor**: iki deneme (yol, derinlik, boy ×1,7, ışıma) sonrası bile 1280×720'de küçük lekeler; replik ve halkalar olayı taşıyor. Daha iri/yakın geçiş sahibin isteğine göre (`_ev_fish`).
- **Su yükselmesi YAPILMADI** (yalnız sürükleyen dalga var): su düzlemi, sahte yansıma ve kayıklar `WATER_Y` sabitine bağlı.
- **Bot hiç isabet almıyor** (varsayılan varyantta `hits=0`; bot uyarıda durur). İsabet yolu yalnız `hit` varyantında sınanıyor.
  Gerçek oyuncunun isabet sıklığı BAKILMADI (zorluk sahibin kararı: `HIT_RADIUS`, `WARN_SECS`, atış arası).
- Sarnıçta çizim çağrısı en çok **411 → 460** (sarsıntıda düşen parçalar, toz, sıçrama kartları; medyan 297 → 277). "Çizim artmaz"
  kuralı en yüksek değer için **tutmuyor** (+%12); 600 sınırının altında. Üçgen her evrede azaldı.
- Avlu evresinde RINFO çizim ~4.400–5.100 / üçgen ~5,6–5,9 M: ortak `ByzCity(part="aya")`; ÖNCE ve SONRA aynı, bu turda dokunulmadı.
- Medusa kadraj oranı göz kararı (%25); piksel sayımı yapılmadı.
- 60 FPS: KANITSIZ (yazılım çizimi, llvmpipe). Ses: duyulmadı (ses çıkışı yok).
- Fener (Spot) gölgesiz: hayranlık karesinde gölge derinliği biraz azaldı; sahibin tercihine göre geri alınabilir (`_spot.shadow_enabled`).
- Bölüm kapağı (`assets/art/covers/ch44b.png`) yeniden üretilmedi (sonda betiği üretebilir: `tests/cistern_shots.tscn`).
- Tam `tests/run_tests.sh` ve `creator_check` KOŞULMADI.
- İngilizce replikler anadil okumasından geçmedi.

## Paftalar (`docs/_kanit_yerebatan/`)
`t2_p01_K1_inis`, `t2_p02_K2_zerre`, `t2_p03_hayranlik_acilis`, `t2_p04_kurek_parlaklik`, `t2_p05_ilk_kurek_olaylari`, `t2_p06_sarsinti_dusen`,
`t2_p07_cokus_gunisigi`, `t2_p08_gozyasi_sutunu`, `t2_p09_isabet`, `t2_p10_K4_medusa`, `t2_p11_K3_tirmanis`, `t2_p12_K8_pil` (2. tur, 12 pafta;
ilk turun p01–p09'u yerinde).
