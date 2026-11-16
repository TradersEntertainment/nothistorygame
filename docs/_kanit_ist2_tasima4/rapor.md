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
| 3c | Bölüm 21 an_03 SONRA karesi | **TAMAM** | kap yeri açık, depo solda; iyi |
| 2 | Bölüm 0 açılışı destanı | **TAMAM** (açılış iyi; eskinin sur yolu kalabalığı yeni setin yüksek iç korkuluğu yüzünden görünmüyor) | ek hücum merdivenleri (uçları kadrajda), yaralı/koşan şeritleri, sur yolu meşaleleri, duman, kuleye dayalı merdiven; donma karesinde yaralı, merdiven, tek tek kalas; bütün anlar eski setin çizim ve ilkel sayısının altında; yeni ×2 + eski ×1 PASS, `=yuru` takılma 0 |
| 1-kare | 2. dalga kareleri | **KISMEN** | başlangıç karesi var (kötü kadraj), orta kare alınamadı |
| — | Sözleşme | **TAMAM** | `SURSOZLESME PASS kalem=13 kesim=8` · `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` · `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` (`testler/soz/`) |
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
| 20o ŞİMDİ (×2, 10 çeşit) | 20 | **13** | −129,5 |
| 20o SONRA (×2, 10 çeşit) + `=wide` son ×6 | 26 | **0** | −1,1 |
| eski set `--eskisur` (20 ×4, 20o ×2) | 6 | 0 | −1,2 |

(Eşik −2 m; −1,1 m = moloz yamacına uzanmış ceset, sayaç zemini moloz profilinin pürüzsüz hâlinden okuyor.)

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

### Ölçüm (`WAVERUNNER t=`, sn; medyan [aralık] (n); `testler/simdi`, `testler/sonra`, `testler/eski`, `testler/sonra_wide`)

**Bölüm 20** (eski | şimdi | sonra). "Eski" sütunu tasima2'nin pilot ölçümü (×1, n 8–9) ve bu dalda `--eskisur` ×1
(def, tape, hit, late; `testler/eski/`).

| küme | 1. dalga | 2. dalga | tüfekçi `gunner=` |
|---|---|---|---|
| eski (tasima2 pilot) | 9,0 [8,4–15,6] (n 9) | **22,7** [18,9–34,2] (n 8) | 3/3 (tasima2 `son_c20_eski_def`) |
| eski (bu dal `--eskisur`, 4 çeşit) | 9,4 [8,8–16,4] (n 4) | 19,5 [16,1–24,8] (n 4) | 4/4 4/4 3/3 4/4 |
| şimdi (taban, 9 çeşit ×3; 3 koşu eksik: idle, d0, d2 ×2) | 4,1 [1,8–11,8] (n 24) | **8,3** [4,3–30,0] (n 21) | çoğu 2/2 (1/1…4/4) |
| **sonra** (9 çeşit ×3) | **11,4** [9,3–18,9] (n 27) | **21,2** [17,7–26,2] (n 24) | çoğu **4/4** (3/3; lose 0/2, 1/2) |

Çeşit başına sonra (×3): def 10,7 / 20,8 · tape 10,6 / 24,3 · hit 14,8 / 22,3 · idle 11,2 / 20,7 · niko_idle 11,6 / 21,3 ·
late 12,0 / 18,9 · d0 9,9 / 20,4 · d2 10,2 / 23,1 · lose 18,4 / — (1. dalgada yenilir; şimdi 10,0). 2. dalga hiçbir koşuda 60 sn
sınırına yaklaşmadı (en çok 26,2). 27/27 PASS, denetim 0, `outcome`/`repair`/`knocks`/`arrows`/`gun` alanları tabanla aynı.

**20o** (wide hariç 9 çeşit ×2; kod yolu bu çeşitlerde değişmedi — gedik açık, `auto_entry` içeriden getiriyor):

| küme | 1. dalga | 2. dalga | tüfekçi |
|---|---|---|---|
| eski (tasima2 pilot) | 11,0 [9,0–13,7] | 14,2 [11,9–15,1] | — |
| eski (bu dal `--eskisur` def ×1) | 14,4 | 12,1 | 1/2 |
| şimdi (×2) | 10,0 [6,1–14,1] (n 18) | 14,7 [10,2–17,8] (n 16) | 2/2 (lose 0/1) |
| sonra (×2) | 10,3 [6,4–14,8] (n 18) | 13,9 [10,6–17,9] (n 16) | 2/2 (lose 0/1) |

**20o `=wide`** (20O.2, barikat kapalı):

| küme | 1. dalga | 2. dalga | tüfekçi |
|---|---|---|---|
| eski (tasima2) / bu dal `--eskisur` ×1 | 9,3 / 8,5 | 22,3 / 35,2 | 2/2 / 2/4 |
| şimdi (×2) | **6,4** [4,5–8,3] | 11,1 [10,2–12,0] | 2/2 |
| ara turlar (×2–4, `sonra_wide/tur2..5`, ayar denemeleri) | 12,4 · 13,0 · 13,9 · 7,5 · 13,1 | 17,2 · 12,4 · 14,8 · 11,6 · 16,2 | 2/2 |
| **sonra (son ayar ×6, `sonra_wide/tur6`)** | **8,6** [7,5–13,1] | 12,9 [10,2–17,5] | 2/2 ×6 |

Ayar geçmişi (`=wide`): peribolostan koşu + 2,0 sn kademe → 12,4; yakın çıkış + 1,5 → 13,0; 0,7 → 13,9 (sonda
`testler/sonda/wide_s3.ham`: varış ~4 sn, gerisi tek savunanla 8 sn düello — süreyi düello belirliyor). Son: 1. dalga
barikatın ucundaki toplanma yerinden 1,0 sn kademeyle, 2. dalga peribolostan uzun yol + 3,0 sn kademe. 2. dalga 12,9 sn:
şimdiden (11,1) uzun, eski 22,3'ten kısa — **kısmen** (dalga sınırı/düşman sayısı/can değişmeden 2. dalgayı uzatacak kaldıraç
kalmadı: savunanlar zaten en uzak yoldan geliyor; ötesi `Duelist` temposu ya da can, ikisine dokunulmadı).

### Ortak sınıflar (`WaveRunner`, `Duelist`, `Assault`) — varsayılan ×1 (`testler/ortak/`)
Değişiklikler varsayılanda aynı dalları çalıştırır (`stagger` 0, `via` düz dizi, `ek_merdiven` boş, `dusus_her_kati` metası
yalnız `SurSetSahne`'li sahnede). Bu sınıfları kullanan bölümler ×1: 21, 21o, 22o, 25, 26, 26o, 29, 30, 30o, 32o, 36b, 37o,
41o, 42b — **14/14 AUTOTEST PASS, denetim 0**. (0, 20, 20o yukarıda.)

### Kareler (oyuncu kamerası) — 2. dalga başlangıcı ve ortası (`=kare`, `kare/c20_sonra/`)

| an | tek cümle | hüküm |
|---|---|---|
| `an_12_duello` (1. dalga) | gedik önünde düello; arkada fıçılar, tuğla dizisi çuvallar, kazık çiti | kabul |
| `an_13_dalga2_baslangic` | kameranın dibinde kalas taşıyan bir işçi ve bir dost asker kadrajı kesiyor; arkada fıçılar, çuvallar, kazıklar, bir azap; o anda gelen azaplar dolgu/yamaçta, aşama 4 barikatının ardında kaldığı için peribolostan görünmüyor | **kötü kadraj** (oynanışta oyuncu dönüp bakabilir; =kare'nin sabit bakışı kalabalığın içinde) |
| `an_14_dalga2_orta` | çekilemedi: yazılımsal GL'de `=kare` 1.400 sn sınırına takıldı (makine bir kez yeniden başladı, ilk çekim yarıda kaldı); 2.400 sn ile yeniden çekim rapor yazılırken sürüyordu | **YAPILMADI** (bkz. durum.md) |

### Bütçe (çuvallar; Bölüm 20 `=butce --butce_onarim=7`, aşama 3, aynı kameralar, 10 kare ortalaması)
ÖNCE = tasima3 SONRA (`docs/_kanit_ist2_tasima3/testler/butce/sonra_onarim7.ham`; çuval dışında set kodu aynı), SONRA
`testler/butce/sonra_onarim7.log`. Düello yolu çizim bütçesine dokunmaz.

| bakış | çizim önce → sonra | ilkel önce → sonra |
|---|---|---|
| peribolos | 3.546 → 3.547 (+%0,0) | 6,154 M → 6,182 M (+%0,5) |
| gedik ağzı | 4.350 → 4.357 (+%0,2) | 8,151 M → 8,275 M (+%1,5) |
| sur yolu | 4.238 → 4.270 (+%0,8) | 5,169 M → 5,242 M (+%1,4) |
| hava | 9.907 → 9.963 (+%0,6) | 8,203 M → 8,270 M (+%0,8) |

Çuvallar aşamanın pişmiş ağına katıldığı için çizim çağrısı artışı çuvaldan değil (gedik ağzında +7; kalas yığını ve
ölçüm gürültüsü); ilkel artışı ≈ 120 bin üçgen (≈50 çuval × ~220 + bağlar).

## 3c. Bölüm 21 an_03 (kap yeri) SONRA karesi — `kare/c21_sonra/an_03_lagim_kap.jpg`
Tek cümle: lağımın üstündeki kap yeri geniş ve boş toprak; depo yığınları (toprak yığını, kısa fıçılar, tek tek kalaslar) 7 m
solda geride, sağda dış surun eteği; kutu yok, havada duran yok, yığınlar zemine oturuyor, aynı ressamın elinden. Hüküm: **iyi**
(tasima2'deki "kap yeri kalabalık" sorunu yok). Kare `=kare` kipiyle, bu dalın kodu (kalas yığını yeni biçimde); bütçe
`testler/kare_c21_sonra.log` (an_03 çizim 528, ilkel 0,61 M).

## 2. Bölüm 0 (soğuk açılış) — eskisi kadar destansı

### Neden boştu (kadraj sondası `tests/_ist/tasima4_kadraj.gd`, çizimsiz izdüşüm)
- Açılış kamerası (START → LINE) yeni sette dış surun x > 4,5 kesimine (kadrajın üst ortası, yer yazısının hemen üstü) ve
  gediğin sağ burcuna bakıyor; x < −4,5 kesimi kadrajın sol üst köşesinin dışında. Eskinin `Garrison` boşlukları (kazanlar için
  x ±6,8…10,4, eski kule 13–19) yeni sette görünen sur yolunun çoğunu boşaltıyordu; ayrıca yeni dış surun **iç korkuluğu
  yüksek** (A'nın sur ölçüsü, dondu): sur yolundaki savunucular peribolostan çoğunlukla görünmüyor.
- Hücum merdivenlerinin tepesi korkuluğun 1,5 m üstünde, kadrajdaki kesimde merdiven yoktu (x 11,8 / 17 / 22'dekiler yer
  yazısının arkasında kalıyordu).
- Yaralı/koşan şeritleri (BattleExtras) kadrajın dışındaydı; donma karesinde patlamaya 3 m'den yakın herkes gizleniyor.

### Yapılan (yalnız yeni set; `--eskisur` yolu aynı)
- `Assault.ek_merdiven` (kanca, varsayılan boş) + `SurSet.merdiven_dayama(x, uzat)` (dayama kuralının tek merdivenlik hâli):
  Bölüm 0 üç ek hücum merdiveni koyar — x 6,4 (uç korkuluğun 1,8 m üstü: açılış kadrajında gedik burcunun üstünde) ve 14,4,
  donma kadrajı için −20,6. Tırmananlar tepeye varınca savunanın mızrağıyla geri düşer (Assault'un kendi akışı): tepede
  çatışma.
- `Garrison` boşlukları yeni sette yalnız kazanların yanı (±7,7…9,5); kazan yanlarına sur yolu meşaleleri; surun ardından
  (teras, hendek) yükselen üç duman sütunu (`Vfx.smoke_wisp`).
- Dört yaralı/koşan şeridi (`SERIT_YENI_EK`): dış sur eteğinin önü (gediğin iki yanı), donma karesinde patlamanın 3 m dışı,
  kalas yığınının yanı (oyuncu yolundan ≥ 2,2 m; taşıyıcı şeridinin dışında).
- İç kulenin batı yüzüne dayalı dekor merdiveni (tek ağ, yuvarlak dikme/basamak, tırmanılmaz, çarpışmasız).
- Donma karesindeki kalas yığını (`SurSetSahne._kalas_yigini`, depo dekoru — 20/20o/21'de de): altı eşit `Props.box` yerine
  tek tek kalaslar: boy/en/renk farklı, kenarları pahlı (sekizgen kesit), iki sırada bir enine takoz, üstte yamuk bir kalas,
  ucunda yere bırakılmış bir kalas; tek ağ. Çarpışma/etkileşim kutusu aynı.
- Bütçe: donma anında yeni sette kameradan 22 m'den uzak figüranlar gizlenir (koridorun dibinde okunmayan küçük figürler;
  tasima3'te bile donma karesi eski setin üstündeydi: 4.643 > 4.363).

### Kareler ESKİ | YENİ(önce) | YENİ(sonra) — `kare/c0_eski`, `kare/c0_once` (tasima3), `kare/c0_sonra` (son tur); ara turlar `kare/c0_sonra_tur1`

| an | SONRA tek cümle | hüküm |
|---|---|---|
| `an_01_acilis` | gedik burcunun üstünde korkuluğu aşan hücum merdiveninin ucu, solda kuleye dayalı merdiven, havada oklar, koşan savunucu, sağda siperin dibinde yerde oklanmış yaralılar ve çömelmiş asker, sol alt ön planda yerde iki yaralı, sur yolunda meşale; kutu yok, havada duran yok, herkes zemine oturuyor, aynı ressamın elinden | **iyi** (önceye göre belirgin dolu ve hareketli; eskinin sur yolu kalabalığı yeni setin yüksek iç korkuluğu yüzünden görünmüyor) |
| `an_02_kosu_orta` | savunucular ve taşıyıcılar, solda peribolos boyunca yedek bölük ve uzakta yerde yaralılar, sağda fıçılar ve çuvallar | kabul (önceyle hemen aynı; kadraj kişilerle dolu) |
| `an_05_gun` | gediğin içinden gökyüzü; gedik ağzında azap, fıçıların ardında tuğla dizisi çuvallar, sağda surun ardından yükselen duman | iyi |
| `an_06_donma` | havada Tolga, arkasında patlama ve savrulan oklar/kalkan, solda savrulan askerler, sağda iç kuleye dayalı merdiven, merdivenin dibinde yerde yaralı, tek tek kalaslardan yığın (takozlu, biri yamuk, biri yerde), yere saplı oklar, koşan asker | **iyi** (önce: boş, kalas yığını kutu; eskisi kadar dolu değil ama yaralı, merdiven, kalas var) |

### Bütçe (`=kare`, 4 kare ortalaması; ESKİ `--eskisur` tasima3 `kare_c0_eski.log`, önce tasima3 `kare_c0_yeni2.log`, sonra `testler/kare_c0_sonra.log`)

| an | çizim eski / önce / **sonra** | ilkel eski / önce / **sonra** |
|---|---|---|
| an_01 | 11.409 / 7.030 / **8.882** (−%22) | 13,90 M / 9,11 M / **10,69 M** (−%23) |
| an_02 | 10.181 / 6.399 / **7.268** (−%29) | 13,31 M / 8,83 M / **9,58 M** (−%28) |
| an_03 | 9.114 / 6.838 / **7.816** (−%14) | 13,10 M / 10,63 M / **11,92 M** (−%9) |
| an_04 (aynı kamera) | 9.344 / 7.054 / **8.556** (−%8) | 11,09 M / 9,51 M / **11,03 M** (−%0,6) |
| an_05 | 8.142 / 5.080 / **5.739** (−%30) | 10,97 M / 8,42 M / **9,08 M** (−%17) |
| an_06 | 4.363 / 4.643 / **3.792** (−%13) | 8,07 M / 6,78 M / **5,40 M** (−%33) |

Hepsi eski setin altında (an_04 ilkel en dar: −%0,6; ara turda x −6,3 ek merdiveni ve 3 tırmananıyla +%0,2 idi → kaldırıldı).

### Testler (`testler/c0_son/`)
Yeni ×2, `--eskisur` ×1: **3/3 AUTOTEST PASS `froze=true`, denetim 0**; `TASIMA0ENGEL OZET nokta=14 engelde=0`; `=yuru` (gerçek
bot) yeni: takılma 0, düşme 0, teslim tamam, 2,5 sn / 7,2 m (eski `--eskisur` 3,6 sn / 8,2 m, takılma 0).

## 4. Bölüm 22 / 22o taşıması — YAPILMADI
Süre §1–3'e (sahibinin kararı zorunluydu) ve makinenin bir kez yeniden başlamasıyla yarıda kalan ölçümlerin yinelenmesine gitti.
22/22o'nun sabit noktaları (tasima belgesi §4.3: CHUTE, BARRELS, TOWER (−3;0;40), PILE (9;0;56), WATER (−11;0;52), HIDE_PILE)
taranmadı.

## Değişen dosyalar
- `scripts/chapter20.gd`: `_yaklasma` (yalnız yeni set), `YAKLASMA_*` sabitleri; `=kare`'ye 2. dalga kareleri; autotest ceset sayacı.
- `scripts/chapter20o.gd`: `_savunan_yolu` (yalnız yeni set, barikat aşama ≥ 3), `SAVUNAN_ARA_*`; autotest ceset sayacı.
- `scripts/chapter0.gd`: ek merdivenler, Garrison boşlukları, yaralı şeritleri, meşale, duman, dekor merdiven, donma bütçesi (yalnız yeni set).
- `scripts/combat/wave_runner.gd`: `stagger`, giriş başına `via` (varsayılan aynı). `scripts/combat/duelist.gd`: `_fall_solid`
  (`dusus_her_kati` metası yoksa aynı). `scripts/level/assault.gd`: `ek_merdiven` (varsayılan boş).
- `scripts/world/ist/sur_set.gd`: `merdiven_dayama`. `sur_set_sahne.gd`: `dusus_her_kati` metası, `CesetSayac` (autotest,
  `--sonda4`), kalas yığını. `sur_oyun_parca.gd`: yalnız `GedikOnarim` (çuvallar).
- Testler (yalnız yeni dosya): `tests/_ist/tasima4_kesit.gd`, `tasima4_zemin.gd/.tscn`, `tasima4_kadraj.gd`.

## run_tests.sh isteği
Paket değişmedi. Öneri: Bölüm 20/20o çeşitlerinin çıktısında `CESET4 … dusen=0` aranması (ceset düşüşü yeniden gelirse
yakalansın); `--chapter=0 --autotest=yuru` (tasima3'ün isteği hâlâ geçerli).

## A'ya istek (görünüş dosyaları)
- **Sur gövdeleri "görünmez" sayılıyor:** yeni setin zemin/duvar çarpışma gövdelerinin (ör. `Toprak_GedikMolozRampa_Carp`,
  `Toprak_DolguSet_Carp`, `SurDibiEtekGovde`, peribolos ve sur gövdeleri) ne ağ çocuğu ne `wall`/`ground` metası var
  (`testler/sonda/zemin_once.txt`). Bu dalda `Duelist` düşüşü sahne metasıyla çözüldü; ama `Unclip.visible_body`'ye dayanan her
  şey (görüş denetimi `VISAUDIT hidden`, `Melee.auto_entry`'nin "arada duvar yok" ışını, `_see_giust`) yeni sette sur
  gövdelerini görmüyor. Kalıcı çözüm A'nın gövde kurucusunda `wall`/`ground` metası.
- **Dış surun iç korkuluğu yüksek:** peribolostan sur yolundaki savunucular görünmüyor (Bölüm 0 açılışı, kare
  `kare/c0_sonra/an_01_acilis.jpg`; tasima3'te Bölüm 25'te de). Eski setteki "sur üstünde kalabalık" ancak korkuluk alçalırsa döner.

## Sonraki taşıyana
1. **Düşüş zemini:** yeni sette düşen/atılan her şey `SurSetSahne`'nin `dusus_her_kati` metasına güveniyor; başka bir düşen
   nesne yazarsan (`_fall_tick` benzeri) `Unclip.visible_body` yerine `Duelist._fall_solid` mantığını kullan.
2. **Düello girişi:** `WaveRunner`'a `from` + giriş başına `via` + `stagger` + `group` ver; `Melee.auto_entry` kapalı barikatta
   giriş bulamayınca rakibi oyuncunun dibinde doğurur (20o kökü). `--sonda4` (bölümde `SurSetSahne.ceset_sayac`) ile saniyede
   bir yerleri gör.
3. **Kadraj sondası:** `tests/_ist/tasima4_kadraj.gd -- --kamera=x,y,z --bak=x,y,z` bir noktanın ekranda nereye düştüğünü
   çizmeden söyler (Godot'da kamera +z'ye bakarken ekranın sağı −x'tir; elle hesap yanıltıyor).
4. **Yazılımsal GL:** Bölüm 20 `=kare` tam akış ≥ 25 dk; `KT=2400 ~/is/kare.sh …` (`testler/kare.sh`).
5. **Düello süresinin oynaklığı:** `=wide` 1. dalga ×2–4'lük turlarda 7,5–13,9 arasında oynadı; ölçüm en az ×6.

## Hâlâ kötü olanlar (dürüst)
- Bölüm 20 2. dalga başlangıç karesi kötü kadraj; orta kare alınamadı. Aşama 4'te azapların ovadan gelişi peribolostan
  görünmüyor (barikat ve sur yolu tahtası kapatıyor); yaklaşma sur yolundan ya da gedik ağzından bakınca görünür.
- 20o `=wide` 2. dalga 12,9 sn: tabandan (11,1) uzun ama eskiden (22,3) kısa (kaldıraç a/b tükendi; c/can'a dokunulmadı).
- Bölüm 20 1. dalga 11,4 sn: eskiden (9,0) biraz uzun (yaklaşma yolu); `lose` çeşidinde 18,4.
- Bölüm 0 açılışında sur yolu kalabalığı görünmüyor (A'nın korkuluğu); donma karesi eskisinden hâlâ seyrek; `an_04` sabit bakışta
  kask kameranın dibinde (tasima3'ten beri).
- Bölüm 0'da ön planda yerde yatan yaralılar (kalas yığınının yanı) açılış karesinin sol altına giriyor: kasıtlı ama kalabalık.
- Bir dost asker 2. dalgada gediğin dış yanından terasa (y −3,1) iniyor (sonda `c20_def_s1`); ceset değil, düşme değil, ama
  dövüşten çıkıyor — araştırılmadı.
- Bölüm 22/22o yapılmadı.
