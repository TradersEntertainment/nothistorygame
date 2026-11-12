# P3 bağımsız denetim raporu — deniz savaşları ve Boğaz şantiyesi (Bölüm 29, 29o, 33o, 38o)

Denetçi: kendi oynanış koşularım (Godot 4.4.1, xvfb, `PACE=1`, 1280x720). ÖNCE = `e551de84` kodu (yalnız altı P3 dosyası
eski hâlinde, geri kalan her şey dalın ucundaki hâlde; ayrı bir kopya dizininde, depodaki dosyalara dokunulmadı).
SONRA = bu dalın ucu (`wip/0.99.119` ucu, `3952adb2`). Kare adları: `t0NNN` = oynanış karesi sayacı (iki koşuda AYNI an;
aynı sayaç = aynı oyun anı), `D..._..` = o replikte alınan kare. Paftalar bu klasörde (`p01..p12`, ÖNCE solda | SONRA sağda).
Ham test ve RINFO satırları: `ham_test_ve_rinfo.txt`.

Denetçi araçları: `tests/_tmp/sonda_29.gd` ve `sonda_rinfo.gd` (geçici; iş bitince silindi, depoya girmedi). Bunlardan gelen kareler
yalnız `sonda_` adıyla anılıyor, oynanış kanıtı sayılmadı.

## (1) Madde madde hüküm tablosu

| Madde | Hüküm | Kanıt (kare / pafta) | Gerekçe |
|---|---|---|---|
| A. 33o kılavuz ipi | **DOĞRULANDI** (kangal KANITSIZ) | `t0188, t0218, t0258, t0300` (p01) | ÖNCE'de sol altta kadraja giren kalın siyah-krem çubuk, havada bitiyordu. SONRA'da ip yuvarlak kesitli, taştan iki yumruğa uzanan ince hat; iki el kadrajda, havada biten uç yok. Kenevir rengi krem güverteye karşı çok düşük karşıtlıkta (ip zor seçiliyor). Ayağın dibindeki kangal kameranın baktığı yerde değil: karede görülmedi. |
| B. 33o kayık, kürek palası halkası | **KISMEN** | `t0470, t0500, t0530, t0560` (p02) | SONRA `t0500`'de teknenin çevresinde beyaz izi/halkalar var (P3'ün `Vfx.wake` eklemesi). Pala halkası ÖNCE'de de var (`t0530` sol alt eliptik halka): pala-su teması P3'ten gelmiş sayılmaz. |
| C. 38o "merdiveni tut" | **KISMEN** | `D38O_T_02 +10` (`t0241`), `+130` (`t0361`), `t0409..t0432`, `t0581..t0681` (p03, p04) | Çömelme + iki el iki dikmede: DOĞRULANDI (ÖNCE'de sol el havada, sağ el boş/telsizli). Ama kadraj bozuldu: kamera merdivene çok yakın, tırmanan tayfanın yalnız bacakları görünüyor, başları ve çatalın geldiği mazgal kadraj dışı (ÖNCE'de tayfa baştan ayağa ve sur başı görünüyordu). Çatal anında (`t0361`) bakış yalnız birkaç derece kalkıyor, çatal görünmüyor, eller bırakınca sağ ele telsiz geri beliriyor. Şehir: gizleme sırasında (merdiven + yangın) kadrajda zaten şehir yok (sur kapatıyor); sur başına çıkışta (`t0629..t0681`) şehir ÖNCE ile aynı anda aynı biçimde beliriyor, kaybolma/birden belirme GÖRÜLMEDİ. Fakat çözüm bütün `world` düğümünü 45 sn kapatıyor (aşağıda 3 numaralı bulgu). |
| D. 38o rıhtım halatı | **DOĞRULANDI** (kovalamada silinme BAKILMADI) | `D38O_R_04 +20, +60, +110` (`t0761, t0801, t0851`) (p05) | ÖNCE'de elde telsiz, ip yok. SONRA'da iki yumruk ipi tutuyor, ip babaya gidiyor; tekneden babaya sarkan halat var. Kovalamada rıhtım halatının silindiği `t1041` civarı karede rıhtım zaten kadrajda değil: kodda var (`_chase`), karede görülmedi. |
| E. 29o kanca ipi sarkıyor, kesilince düşüyor | **DOĞRULANDI** (`sonda_`) | `sonda_29_hook_t1.0`, `sonda_29_cut_t0.15` (p06) | ÖNCE: kancadan kadırgaya düz, gergin, açık renk çubuk; kesilince toz bulutu (`Vfx.dust`) ve anında yok oluş. SONRA: burgulu, sarkan ip; kesilince ip kadırga küpeştesinden sarkıyor, demir kanca düşüyor. Dikkat: bunu OYNANIŞ karesinde göremedim: test botu kamerayı kancaya çevirmiyor ve ip küpeşte duvarının dışına sarktığı için oyuncunun durduğu yerden (içeriden) görünmüyor (bkz. bulgu 4). Kesiliş sonrası ipin ömrü sondada ~1 sn'de bitti, kodda ~3 sn (kare hızı 0,3 fps olduğundan ölçüm güvenilmez): BAKILMADI. Suya düşen kancadaki halka karede görülmedi. |
| F. 29o ip tırmanışı | **DOĞRULANDI** | `D29O_B_CLIMB +10..+22` (`t0208..t0224`) (p07) | ÖNCE'de kadrajı kesen dev, düz krem çubuk ve elde halka. SONRA'da iki yumruk ipi tutuyor, ip yumruklardan geçip küpeşteye çıkıyor. Düşüş anında (`t0220-t0224`) ip, kameraya yakın kısımda geniş krem şerit gibi görünüyor (iç yüz değil, ama 25 cm kuralına sınır). |
| G. 29 tayfa işte | **KISMEN** | `t0040`, `t0080`, `t0100` (p08), `D29_C_FIRE` | Kovalı tayfa, yerde kangal, taş yığınları görünüyor (ÖNCE'de hepsi boş, kollar yanda). Halat çekenin elleri sırttan görünmüyor, kollar yana açık "T" gibi, ipin ucu bacağının arkasında bitiyor (geliştiricinin dediği gibi). Taş atma döngüsünü (taş tutma / atma) karede yakalayamadım: BAKILMADI. |
| H. 29 bordadan fırlayan sopa | **KISMEN** | `D29_C_WIND +10, +16` (`t0458`, `t0464`) (p09) | Renk soluk kenevire döndü, uç inceldi. Ama güneşte hâlâ ~7 m'lik, sivri, açık renk konik bir "mızrak" gibi bordadan öne uzanıyor; ÖNCE'den daha az parlak ama sopa gibi okunuyor. |
| I-1. 29 kanca iplerini görünürlüğü | **KANITSIZ** (oynanışta), `sonda_` ile DOĞRULANDI | bkz. E | Oynanış karelerinde kanca ipi hiç görünmüyor (`t0030..t0100`). |
| I-2. 29 fıçıda kova halkası | **DOĞRULANDI** (`sonda_`) | `sonda_29_bucket_t0.40` (p10) | Fıçı yüzeyinde halka seçiliyor; ÖNCE'de yok. Yan etki: arkada kangallı, işte tayfa görünüyor. Oynanış karelerinde bu an yakalanmadı. |
| I-3. 33o ustaların aletleri | **KANITSIZ** | `t0040, t0070` (p12) | Usta üçlüsü kadrajda uzakta, çekiç/karıştırıcı seçilmiyor. Kodda `give_tool` var; karede yok. |
| I-4. 33o şantiye zemini | **DOĞRULANDI** | `t0040, t0070` (p12) | SONRA'da taş kırığı serpintisi seyrek, düzensiz, ÖNCE düz petek taş. Kuleye yakınlaştıkça azalıyor. |
| I-5. 33o/38o suya düşen gülle/ok/yüzücü halkaları | **KANITSIZ** | 38o `t0160..t0202` (ok anı) | Gece, kadrajın köşesinde piksel büyüklüğünde nokta; oynanışta okun suya düşmesi (`arrows=0`) zaten oluşmuyor. 33o gülle sıçraması ve 38o gülle/yüzücü halkası karede yakalanmadı: BAKILMADI. Kalıcı maliyet: halkalar ve damlalar kısa ömürlü düğümler, kalıcı ağ yok. |
| J-1. 29o pala-su teması ve kadırga izi | **KANITSIZ / DEĞİŞMEDİ** | `D29O_B_02 +30, +70` (`t0054, t0094`) | Kürek çekilirken ÖNCE ve SONRA karelerinde pala-su teması fark edilmiyor; kadırga izi yok. Geliştirici zaten açık bırakmıştı: öyle kalmış. |
| J-2. 33o "Denize mi düştün?" | **ESKİ HATA** (P3'ten gelmiyor) | `D33O_G_REFUSE +12..+62` (p11) | `FLOW LINE D33O_M_WATER` hem ÖNCE hem SONRA, hem `""` hem `fall` koşusunda var (4/4). Faz geçişi karartmasında, ekran kararırken oyuncu suya düşmüş gibi söyleniyor; kareler ÖNCE ve SONRA birebir aynı. P3'ün `_fish_out`'a eklediği halka/damla karartmadan hemen önce çalışıyor, karede yakalanamadı. |

## (2) Yeni bulunan kusurlar

| # | Bölüm, an | Kare | Kaynak |
|---|---|---|---|
| 1 | 38o merdiven tutma (t=36–81 sn), tırmanan tayfa başsız/kadraj dışı, çatal görünmüyor | `t0241, t0291, t0361, t0409..t0432` (p03) | **P3** (`_brace` yeni konum + `BRACE_LOOK`, `eye_height`) |
| 2 | 38o çatal anı: eller dikmeyi bırakınca sağ ele telsiz geri beliriyor | `t0361` (p03) | **P3** (`_ladder_grip(false)` tasarımı) |
| 3 | 38o: merdiven tutarken bütün `world` düğümü gizleniyor (`chapter38o.gd:574`). Görünür etkisi yok ama sahne ağacındaki tüm dünya 45 sn kapalı; kapanış `_ladder_grip(false)` çağrılarına bağımlı | RINFO: `ladder` evresi çizim −57%, üçgen −71% | **P3** |
| 4 | 29 kanca ipleri oyuncunun durduğu yerden (içeriden) küpeşte duvarının arkasında kalıyor; kesmek için gelen oyuncu ipi görmüyor, yalnız demir kancayı görüyor | `sonda_29_hook_t*` ve oynanış `t0030..t0100` | **P3 ile ilgili** (görünmeyen ağ: kural 2) |
| 5 | 29o tırmanış düşüş anında ip kameraya yakın geniş krem şerit | `t0220, t0224` | **P3** |
| 6 | 38o `hooks_bad` koşusunda `VISAUDIT personhidden D38O_S_03` | `ham_test_ve_rinfo.txt` | Belirsiz (bkz. 4. bölüm), P3 şüpheli |
| 7 | 29 halat çeken tayfanın elleri sırttan görünmüyor, kollar yana açık | `t0080` | P3 (geliştirici zaten KISMEN dedi) |

P3 DIŞI: İzlediğim dört bölümde gökyüzü/şehir/kara surlarına ait yeni bir kusur görmedim; dalda süren başka işlerden gelen bir hata ÖNCE|SONRA farkında çıkmadı.

## (3) Kurallara uygunluk bulguları (`git diff e551de84 -- altı dosya`)

- Replik anahtarı/metin sırası: farkta `hud.say/bark` anahtarı ya da sırası değişen satır yok (kontrol edildi). Süre/sayaç/kazanma-kaybetme koşulu değişmemiş.
- **Oyuncu konumu/ kamera**: `chapter38o.gd:544` `_brace()`: oyuncu merdivenden önceki `Vector3(0,0,-7.8)` yerine `BRACE_AT` `(0,0,-9.08)`'e alınıyor, `eye_height = 1.15` (satır 545); oyuncudan alınan kamera pitch denetimi (`_brace_look`, satır ~548) 45 sn sürüyor (kural 9: ≤3 sn). Test botunun durduğu yer değişmiş.
- `chapter38o.gd:574` `world.visible = false` (yorumda "RINFO: çizim ×2" gerekçesi): maliyet gizleme, `chapter38o.gd:569` geri açma tek bir çağrı koluna bağlı.
- **Her karede yeniden kurulan ağ (kural 5)**: `chapter29o.gd:362-372` (`on_rope`) 2,2 sn boyunca her karede `tube_mesh`; `chapter29o.gd:320` (`_fly_hook`) 0,4 sn her karede; `sea_battle.gd` `cut_hook` içinde 0,8 sn her tikte `Stage.rope_to`. Uç değişmediğinde kurulumu atlayan koruma (`33o _guide_lay`, `38o _rope_hands`'teki 5 mm denetimi) 29o'da yok.
- Kare alma kancası: `chapter29/29o/33o/38o.gd` içindeki `save_png(GameState.shots_dir…)` ÖNCE kodunda da var (P3 eklemesi değil). DBG/sonda satırı, `no_audit`, `no_unclip`, `_ok` meta'sı P3 farkında yok. `set_meta("no_walk", true)` (`chapter29o.gd:308,355`, `chapter33o.gd:578`, `chapter38o.gd:1180`) yürünen yüzey taramasından ince ip ağlarını çıkarıyor; başka bölümlerde de bu kullanım var, denetim susturma sayılmadı.
- `sea_battle.gd:~118-130`: küpeşte halkaları dolu kalkan diskine çevrildi (görünüş değişikliği; 29 ve 29o karelerinde fark ediliyor, kabul edilebilir).
- Kalabalık sayısı/ engel yerleşimi: değişmemiş.

## (4) Test sayıları ve hata satırları (başsız, `--max-fps 20`)

SONRA (13 koşu + 2 ek): hepsinde `AUTOTEST PASS`; `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `WARN_VOID_TELEPORT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `JOURNEY_*` yok. Tek istisna aşağıdaki satır:

```
== SONRA ch=38o var=hooks_bad rc=0
VISAUDIT personhidden key=D38O_S_03 scene=chapter38o.tscn speaker=SPK_SAILOR by=@Node3D@24971/@Node3D@27165(spk) at=(18.6, 0.9, 56.2) eye=(14.0, 2.6, 56.2) head=(19.6, 2.6, 56.5) src=Chapter38o>Node3D>Person
AUTOTEST PASS chapter=38o variant=hooks_bad outcome=38O.1 ...
```

| Koşu | SONRA | ÖNCE |
|---|---|---|
| 29 `""` / `lose` | PASS / PASS | (ekranlı PASS) |
| 29o `""` / `lose` | PASS / PASS | (ekranlı PASS) |
| 33o `""` / `wide` / `fall` | PASS / PASS / PASS | `""` ve `fall` PASS |
| 38o `""` | PASS | (ekranlı PASS) |
| 38o `lose` ×3 | **0** VISAUDIT, 3×PASS | **0** VISAUDIT, 3×PASS |
| 38o `hooks_ok` | PASS | — |
| 38o `hooks_bad` | 3 koşuda **1** VISAUDIT `personhidden D38O_S_03` (3 PASS) | 3 koşuda **0** (3 PASS) |

Yani geliştiricinin "lose'ta bir kez gördüm" dediği satırı `lose`'ta 3/3 koşuda hiç görmedim; `hooks_bad`'de SONRA 1/3, ÖNCE 0/3. Kararsız ve örnek sayısı küçük; ÖNCE'de yokluğu P3'ün (yeni durma yeri) etkisi olabileceğini düşündürüyor, kanıtlanmadı.
10 ekranlı koşunun (ÖNCE+SONRA × 29, 29o, 33o, 33o=fall, 38o) hepsi `AUTOTEST PASS`; gerçek hata satırı yok (`WARN_OK` replik anahtarı eşleşmesi yanlış pozitif). run_tests.sh'taki varyant listesi benim koştuklarımla aynı.

## (5) RINFO tablosu

Yöntem: ekranlı koşu, bölüm hızlandırılmış (`--autotest`), `cs.phase` evresine girdikten 2 sn sonra, evre içinde 3 örnek, kamera iki yolla: doğal ve sabit (oyuncu olduğu yerde +x yönüne bakar, pitch 0). Aynı sabit bakışta ÖNCE ve SONRA örnekleri:

| Evre | Bakış | Çizim ÖNCE → SONRA | Üçgen (bin) ÖNCE → SONRA | Hüküm |
|---|---|---|---|---|
| 29 `wind` (rüzgâr) | sabit | 7676 → 7685 (+0,1%) | 8925 → 8951 (+0,3%) | **eşit** (geliştirici +13,7% demişti: örnek hizası) |
| 29o `gun` (top) | sabit | 7695 → 7627 (−0,9%) | 9226 → 9230 (+0,0%) | **eşit** (geliştirici +61% çizim demişti) |
| 29o `hooks` | sabit | 975 → 972 (−0,3%) | 953 → 964 (+1,2%) | eşit |
| 29o `climb` | sabit | 2412 → 2428 (+0,7%) | 1206 → 1215 (+0,7%) | eşit |
| 29o `wind` | sabit | 2489 → 2432 (−2,3%) | 1698 → 1709 (+0,6%) | eşit |
| 38o `climb` (tepe öncesi) | sabit | 6787 → 6746 (−0,6%) | 8180 → 8151 (−0,4%) | **eşit** |
| 38o `explore` (tepe) | sabit | 5207 → 5154 (−1,0%) | 6400 → 6321 (−1,2%) | **eşit** (geliştirici +23% çizim / +47% üçgen demişti) |
| 38o `ladder` (merdiven tut) | doğal | 3174 → 1377 (−57%) | 2484 → 728 (−71%) | **düştü, ama `world` gizlendiği için** (bulgu 3); sabit bakış: 2119 → 975, 1591 → 305 |

Ayrıca tek koşuda, OBJ evresine göre hizalanmış medyanlar (n = 1–21): 33o evreleri çizimde −4%…+3%, üçgende −7%…+4%; 33o `Ambarı gözle` n=2 örnekte üçgen +14% (örnek sayısı çok az, doğrulanamadı); 29o ve 38o'da çizim değişimi −20%…+23%: tek koşu, gürültülü. 33o için sabit bakışlı sonda çalıştırmadım: BAKILMADI. Bölüm 29 için tam koşuda RINFO alamadım (bölüm 29 kare başına ~1,7 sn, tam koşu üç saati aşıyor; yalnız sondalı örnek).
Çizim sayısı hiçbir evrede artmadı, üçgen hiçbir evrede +%8'i aşmadı. Geliştiricinin üç "sınır aşımı" iddiası örnek hizası kaynaklıydı: doğru.

## (6) GENEL HÜKÜM: KÜÇÜK DÜZELTMELERLE KABUL

A, D, E, F, I-2, I-4 gerçekten düzelmiş; ip/el sorunları (en görünür kusurlar) giderilmiş; test bütünlüğü ve performans bütçesi tutuyor. Reddedilecek bir bozulma yok, ama aşağıdakiler yapılmadan "DÜZELDİ" yazılamaz.

ZORUNLU düzeltmeler:

1. `chapter38o.gd:_brace / _brace_look (BRACE_AT, BRACE_LOOK, eye_height)`: merdiven tutarken tırmanan tayfa baştan ayağa ve çatalın geldiği mazgal kadraja girmeli. Beklenen görünüm: `t0241/t0361`'de iki el dikmede, merdivenin üst yarısındaki tayfa ve sur başı kadrajda, çatal geldiğinde çatal görünüyor.
2. `chapter38o.gd:_ladder_grip` (satır 574): `world.visible = false` kaldır; şehir/kara düğümünü yalnız kısıtlı bir uzaklık/görüş kapatmasıyla ya da kamera kırpmasıyla gizle, ve tutuş hangi yolla biterse bitsin geri açıldığını güvenceye al. Beklenen: `ladder` evresinde çizim ÖNCE'nin %60'ından fazla aşağı inmesin diye değil, dünya düğümü hiçbir koşulda kapalı kalmasın.
3. `chapter29.gd:_spawn_hook` / `sea_battle.gd:hook_line`: kanca ipi oyuncunun kancayı kestiği yerden (içeriden, `stand` konumundan) görünür olmalı: ip küpeşte üstünden gözükecek biçimde yukarı kaldırılsın ya da kancanın ipi içeri sarkıtılsın. Beklenen: oynanış karesinde (`t0030..t0100` aralığı) ip seçiliyor.
4. `chapter29o.gd:_climb (on_rope), _fly_hook`: her karede `tube_mesh` kurma; uçlar 5 mm'den az oynadıysa atla (33o/38o'daki koruma gibi). Düşüş anındaki yakın şerit için kameradan ≥25 cm ve daha ince kesit.
5. `sea_battle.gd:war_galley` (seren/sarılı yelken): ~7 m konik demet kısalsın veya serene yaslansın; beklenen: `t0458/t0464` karelerinde "mızrak" gibi bordadan fırlayan açık renk çubuk kalmasın.
6. `chapter29.gd:_crew_jobs` (halat çeken): eller sırttan görünür olacak şekilde kol/halat yönü; ipin ucu bacağın arkasında bitmesin.
7. `38o hooks_bad` `VISAUDIT personhidden D38O_S_03`: aynı koşuyu ≥10 kez çalıştırıp ÖNCE/SONRA sayısını raporla; SONRA'da fark çıkıyorsa `_brace` durma yerinden kaynaklanıp kaynaklanmadığına bak. (D38O_S_03'te konuşan denizci (18.6, 0.9, 56.2) oyuncunun görüş dışında kalıyor.)

Bakamadığım şeyler: BAKILMADI olarak işaretlenenler (29 taş atma döngüsü, kanca halkası/ip ömrü, 33o ustaların aletleri, 33o ve 38o gülle/yüzücü halkaları, 38o kovalamada halat silinmesi, 33o sabit bakışlı RINFO). Dört bölümü her saniyesiyle gezmedim: 10 karede 1 örnekleme kontak sayfaları ve yukarıdaki anlar.
