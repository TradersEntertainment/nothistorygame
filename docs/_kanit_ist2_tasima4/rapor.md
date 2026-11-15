# TAŞIMA-4 — Bölüm 20 düellosu (sahibinin kararı), ceset düşüşü, çuvallar, Bölüm 0 açılışı, Bölüm 21 kap yeri karesi

> Dal `wip/ist2-tasima4`, taban `wip/ist2-tasima3` 6f92f921. Makine: 4 çekirdek; ekransız testler `--max-fps 20`, kareler
> xvfb + Mesa llvmpipe (yazılımsal GL), 1280×720 jpg 85. Ham günlükler `testler/` (`*.ham` tam günlük; yanındaki süzülmüş
> dosya `testler/kos1.sh`'in süzgeci). Süzgeç: `AUTOTEST (PASS|FAIL)|SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|WARN_FLY|WARN_VOID`.
> Tablolar `testler/dalga.py` ile ham günlüklerden üretildi (denetim sütunu = süzgeçteki denetim satırı sayısı).
> **ŞİMDİ** ölçümü tabanın kopyasında (`~/is/taban`, aynı içe aktarma önbelleği): bu dalın ölçüm kancaları var (ceset sayacı),
> ama ceset düzeltmesi KAPALI, `Duelist` tabandaki gibi, düello yolu yok — yani taban davranışı. **ESKİ** = `--eskisur`.
> Dokunulmayanlar: A'nın ve B'nin dosyaları, `scripts/npc/`, `scripts/ui/`, `scripts/player/`, `byz_city.gd`, `sur_sozlesme*`,
> `tests/run_tests.sh`, `project.godot`, `game_state.gd`; replik metni, ses, can, hasar, dalga sınırı (60 sn), dalga ve
> düşman sayısı, gizli süreler, sayaç. Yeni sesli replik yok.

## Özet

| # | Madde | Durum | Kısa |
|---|---|---|---|
| 1 | Bölüm 20 düellosu "çok kısa" | **TAMAM** | azaplar ovadan gelir (hendek dolgusu → teras → moloz yamacı → gedik ağzı → barikatın ucu), 2. dalgada önce iki azap, ötekiler kademeli. 2. dalga medyan **8,3 → 21,2 sn** [17,7–26,2] (eski 22,7); 1. dalga 4,1 → 11,4 (eski 9,0). 20o `=wide` (kök neden: kapalı barikatta savunanın giriş noktası bulunamayıp oyuncunun 3 m önünde doğuyordu) → bkz. §1 tablo. Can/hasar/`Duelist` temposu DEĞİŞMEDİ |
| 3a | Cesetler boşluğa düşüyor | **TAMAM** | kök neden: yeni setin zemin/duvar gövdeleri `Unclip.visible_body` değil (görünen ağ pişmiş kardeş düğümde); `Duelist._fall_tick` konmak için bunu şart koşuyor → atılan düellocu molozun/peribolosun içinden 4 sn düşüyor (−128 m = ½·16·4²). Düşen ceset: ŞİMDİ 19/24 koşu (20), 13/20 (20o) → SONRA **0/27**, 20o bkz. §3 |
| 3b | Çuvallar yassı disk | **TAMAM** | dolgun, ağzı iple bağlı, püsküllü kum çuvalı (kendi ağı, yumuşak normal), tuğla dizisi gibi alttakilerin üstüne oturur; havada yok |
| 3c | Bölüm 21 an_03 SONRA karesi | bkz. §3c | |
| 2 | Bölüm 0 açılışı destanı | bkz. §2 | |
| 4 | Bölüm 22 / 22o taşıması | **YAPILMADI** | süre §1–3'e harcandı; bkz. "Sonraki taşıyana" |

## 3a. Cesetler boşluğa düşüyor — kök neden ve düzeltme

### Kök neden (sonda: `testler/sonda/zemin_once.txt`, `tests/_ist/tasima4_zemin.tscn`)
- Düşüş yalnız **kenardan atılan** düellocuda (`Duelist.fall_off` → `_fall_tick`): her karede bir ışın, çarptığı gövde
  `Unclip.visible_body` ise ve yüzey basılabilirse konar; değilse **içinden geçer**; 4 sn sonra "altında zemin yok" deyip
  gizlenir. 4 sn × g 16 → y ≈ −128: tasima3 sondasındaki `y −70…−128` tam bu (−70 = düşüşün 3. saniyesi).
- Zemin sondası (yeni set, aşama 4; gedik çevresinde 1 m ızgara, 3.087 nokta): `_fall_tick`'in şartıyla **konulabilecek zemin
  3.063 noktada YOK**; 922 noktada ışın boyunca yürünebilir (basılabilir, `ConcavePolygonShape3D`) bir yüzey var ama görünen
  gövde sayılmıyor. İlk çarpılanlar: `Toprak_GedikMolozRampa_Carp` (moloz rampası), `Toprak_DolguSet_Carp` (hendek dolgusu),
  `SurDibiEtekGovde`, peribolos zemini, sur gövdeleri. Sebep: yeni setin görünen ağları pişirilmiş (`PARCA_.pis`) kardeş
  düğümde; gövdelerin ağ çocuğu ya da `wall`/`ground` metası yok. Yürüme (`_floor_at`) yalnız `standable`'a baktığı için
  yürüyüş çalışıyor; düşüş çalışmıyor. Eski sette (LandWalls) gövdeler görünen ağın çocuğu → sorun yok.
- `_retreat_step` ve teras/moloz çarpışması kök değil: düşenler geri çekilenler değil, atılanlar (`thrown=1..3` olan her
  koşuda düşen var; ŞİMDİ tablo).

### Düzeltme (kök: set ↔ düşüş)
- `SurSetSahne._enter_tree`: bölüm düğümüne `dusus_her_kati` metası ("bu setin her StaticBody3D'si görünen bir katıdır").
- `Duelist._fall_solid(c)`: önce eskisi gibi `visible_body`; değilse düellocunun atalarından biri bu metayı taşıyorsa her
  `StaticBody3D` durdurur (zemine konar, duvardan seker). Metasız sahnede davranış **bit bit aynı** (aynı dallar).
- Susturma/eşik/muafiyet yok; `scripts/npc/unclip.gd`'ye dokunulmadı (kök orada değil: `visible_body` doğru söylüyor, setin
  gövdeleri gerçekten ağsız).
- Ölçüm kancası (yalnız autotest): `SurSetSahne.CesetSayac` sahnedeki her düellocunun (yaşayan, ölü, gizlenmiş) zemine
  (`SurSet.zemin_y`) göre en derin yerini tutar → bölüm sonunda `CESET4 … dusen=N en_derin=…` (eşik −2 m). `--sonda4` ile
  saniyede bir yerleri yazar (`SONDA4`; yaklaşma yolu bu sondayla kuruldu).

### Ölçüm (CESET4, eşik zeminin 2 m altı)

| küme | koşu | düşen olan koşu | en derin (m) |
|---|---|---|---|
| Bölüm 20 ŞİMDİ (×3, 9 çeşit) | 24 | **19** | −128,9 |
| Bölüm 20 SONRA (×3, 9 çeşit) | 27 | **0** | −0,4 |

## 1. Bölüm 20 düellosu "çok kısa olmuş" (sahibinin kararı)

### Kök neden (sonda `SONDA4`, `testler/sonda/`)
- **Bölüm 20:** azaplar `Melee.auto_entry` ile dövüş yerinin 6–10 m ötesinde, gedik ağzında (moloz sırtı) doğup iki adımda
  oyuncuya varıyordu; ikinci dalganın bütün azapları birlikte. Eski sette sürenin bir kısmı barikata takılmadan geliyordu
  (geri getirilmedi).
- **20o `=wide` (20O.2, barikat kapalı, aşama 4):** savunanların girişi düello yerinin ötesinde, gediğin içinde aranır;
  kapalı barikattan geçen yol (`Melee.walkable`) bulunamayınca giriş yok sayılıp savunan **oyuncunun 3 m önünde, moloz
  sırtında doğuyordu** (sonda: `tk=1 yol=0 p=(-1.2, 0.5, 17.7)`, oyuncu z 19,4). 20O.1'de (gedik açık) giriş içeriden
  bulunuyor: süreler eskiyle aynıydı, dokunulmadı.

### Düzeltme (kaldıraç a + b; c ve can/hasar DEĞİŞMEDİ)
- **(a) Yaklaşma** — `chapter20._yaklasma` (yalnız yeni set): azaplar hendek dolgusunun üstünden (1. dalga dolgunun yakın
  ucu, 2. dalga uzak ucu; x ±1,6–1,8 iki şerit) koşar, teras eteğinden moloz yamacını tırmanır, sırttan gedik ağzına iner ve
  barikatın oyuncu yanındaki ucundan (köşe noktası) peribolosa girer. İlk denemede köşe yoktu: azaplar barikatın ova yüzüne
  çarpıp ~3 sn yana kayıyordu (`testler/sonda/c20_def_s1` yok; `SONDA4 t=33–36 p=(-3.4…-4.3, 13.7)`) — köşe noktasıyla
  kalktı. Tüfekle vurulamayan ek azaplar (gediğe zaten varmıştı) teras eteğinden tırmanır.
- **20o** `_savunan_yolu` (yalnız yeni set, barikat aşama ≥ 3): savunanlar peribolostan (gediğin 11,5 m yanı, siperin
  ardı) koşar, barikatın ucundan dolanıp gedik ağzından sırta çıkar, yamaçtan oyuncuya iner.
- **(b) Sırayla gelme** — `WaveRunner`'a iki parametre (varsayılan davranış aynı): `"stagger"` (ilk bölüğün i. rakibi
  i × stagger sn sonra çıkar; takviye beklemez) ve giriş başına yol (`"via": [[...], [...]]`, `from` ile eşli). Bölüm 20:
  1. dalga 2,0 sn arayla; 2. dalga önce iki azap (`"group": 2`), 2,5 sn arayla, düşenin yerine sıradaki aynı yoldan.
  20o kapalı barikat: 1. dalga 2,0, 2. dalga 2,5 sn, `group` 2.
- `Duelist` temposu (c), can, hasar, dalga sınırı, düşman sayısı: **değişmedi**.

## 3b. Çuvallar (`GedikOnarim._cuval`, `_cuval_duvar`; `sur_oyun_parca.gd`, yalnız `GedikOnarim`)
- Eskiden tek tek basık top (`Props.ball` 0,58×0,33×0,43, yığının sırtına serpiştirilmiş): karede "yassı disk/somun", bir
  kısmı havada duruyor gibiydi.
- Şimdi: kendi ağım (A'nın yardımcıları değişmedi; `KULE.Ag`'ye yalnız köşe eklendi). Her çuval: süperelips kesitli dolgun
  gövde (boy 0,56–0,64, en 0,34–0,39, yükseklik 0,21–0,25 m), altı yükle basık, uçları büzük; bir ucunda büzük boyun, iple
  sarılı halka ve püskül (ağzı bağlı); yumuşak normaller. **Tuğla dizisi**: alt sıra yığına 3 cm gömülü (çuvalın ayak izinin
  en alçak zemini), üst sıradaki her çuval alttaki iki komşunun alçak sırtına oturur → havada çuval yok. İki duvar: fıçıların
  ardında 3 sıra (ortada), yığının sırtında 2 sıra. Bütün çuvallar tek ağ (aşamanın pişmiş ağına katılır; çizim çağrısı
  aynı). Renk bir ton açık (bez topraktan ayrılsın).
- Kareler: `kare/c20_once/an_06_onarim_asama3.jpg` ↔ `kare/c20_sonra/an_06_onarim_asama3.jpg`, yakın kırpım
  `kare/kirp_cuval_once.jpg` ↔ `kare/kirp_cuval_sonra.jpg`; ayrıca `kare/c20_sonra/an_09_hucum_baslangici.jpg` (bu kareler renk açılmadan önce çekildi).

| kare | SONRA tek cümle | hüküm |
|---|---|---|
| an_06 (aşama 3) | fıçıların ardında iki-üç sıra, birbirinin üstüne oturan yuvarlak koyu çuvallar; kazıklar aralarından çıkıyor; havada duran yok, kutu yok, toprak yığına oturuyor | iyi (gece karesinde koyu → renk açıldı) |
| an_09 (hücum, aşama 4) | fıçıların ardında tuğla dizisi gibi üç sıra açık kahverengi dolgun kum çuvalı, üstünde kazık çiti; aynı ressamın elinden | iyi |
| an_05 (top uyarısı, aşama 2) | aşama 2'de çuval yok (doğru); fıçı sırası ve kazıklar aynı | aynı |
