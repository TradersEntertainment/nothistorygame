# G7 — Lağım tünelleri (10l, 21o) tek haritaya: rapor

Dal: `wip/tekharita-g7` (taban: 3c9e7977). Kanıt: bu klasör (`p01…p12`, JPEG). Koşular Godot 4.4.1, başsız + xvfb (yazılımla çizim,
4 çekirdek). Kanıtsız hiçbir şeye "düzeldi" denmedi; görülmeyen "KANITSIZ", bakılmayan "BAKILMADI" yazıldı.

## 1. Önce okuma: tünel bölümlerde nasıl kuruluyor

**Ortak kurulum.** İki bölüm de sahneyi kendi yerel çerçevesinde kurar (başlangıç `(0,0,0)`, tünel yerel −z'ye kazılır), dünya
(World1453) yok; ortam: siyah zemin (`0a0806`), yoğun sis, mum ışığı. Yeryüzü yalnız bir "kuyu": 3 m yüksekliğinde dört duvar
(arka duvar dâhil), üstü açık, tepesinde yukarıdan inen sarı bir ışık kutusu + `SpotLight3D` (güneş). Kuyunun dışı hiç kurulmaz.

| | 10l (25 Nisan) | 21o (16 Mayıs) |
|---|---|---|
| Kuyu (yerel) | 3,0 × 3,0 m, z 0…3 (`chapter10l.gd:_build`) | 3,0 × 4,0 m, z 0…4 (`chapter21o.gd:_build`) |
| Bölüm | `SEG` 2 m, `GOAL` 6 → 12 m kazı; sonda karşı lağım odası 5×5 m (`z −15,6`) | `SEG` 2,5 m, `GOAL` 6 → 15 m kazı; 9 bölüm baştan kurulu, yüz ilerler |
| Oyuncu girişte | `(-0.2, 0.1, 2.7)` kuyunun içinde | `(0.3, 0.05, 2.0)` kuyunun içinde; Zağanos "kuyudan çıkar" |
| Çıkışta | çöküşte (10L.3) Nihat ışık deliğinden iner; sulh/geri çekilmede tünel içinde biter | duman gelmeden `z > 1,5` = kuyu; Dragan kuyuda "çıktık" der (`_escape`) |
| Dışarısı görünür mü | Hayır: kuyu duvarı 3 m, tepede siyah; yukarı bakınca yalnız ışık kutusu | Hayır: aynı |

**Hikâyeye göre yer.** Replik metninde kapı ya da gedik anılmıyor (`D10L_*`, `D21O_*`, `SIEGE_NOTE_21O_*` tarandı). Anılanlar:
10L `UI_OBJ10L` "Surların dibine kaz"; `D10L_D_DIG_3` "Surların altına girdik sayılır" (6 m); 21O `D21O_DIG_3` "Hendeğin altındayız.
Üstümüzde su var" (7,5 m), `D21O_DIG_4` "Surun temeli" (10 m), `D21O_D_FIRE` "Grant'in adamları", `SIEGE_NOTE_21O` "surların altına
lağım". 21O sonunda Dragan "bu lağım gitti; yarın yenisini kazarız" der ve bölümler 3 hafta arayla: **iki ayrı tünel, iki ayrı ağız**.
Tarihî çerçeve (kod yorumları, `D21O_N_END`): Osmanlı lağımcıları (Novo Brdo) ovadan kara surlarının altına kazar, Grant karşı lağımla
bulur. Dolayısıyla ağız ovada, surların önünde; eksen surlara doğru.

## 2. Karar: tünelin dünyadaki yeri

Kara surları (SiegeField/LandWalls yerel = dünya koordinatı): iç sur z −4…−0,6 (kuleler z −4…4, `x = 79 + 55k`), dış sur z 14…16,
set 16…20, hendek 20…36 (dibi −3), ova z ≥ 36, Osmanlı seti z 112.

| Ağız | Dünya konumu (kuyu tabanı, kuyu duvarı tepesi = ova yüzü) | Eksen | Gerekçe |
|---|---|---|---|
| `tunnel_10l` | **(134, −0,03, 44)** | yerel −z = dünya −z (surlara) | x 134 = iç sur kulesi; hendeğin dış kenarından 8 m ötede |
| `tunnel_21o` | **(189, −0,03, 44)** | aynı | x 189 = bir sonraki iç sur kulesi |

Neden x 134/189: gedik (x 0) ve oynanış alanları (`field.open` ±36, 26o `assault.keep` ±32 z 36…78, 36b şeridi x −38…−10,
Assault bölükleri |x| ≲ 92) boş kalsın; iki ağız birbirinden bir kule aralığı (55 m) uzak. Neden z 44: hendeğin hemen ötesi, mantolu
okçuların zaten durduğu ölü bölge (z 44…82) şeridi; 21o `D21O_DIG_3` "hendeğin altındayız" anında kazı yüzü z 33,8'dedir (hendek 20…36).

**Ölçüm (uzunluk tutarlılığı; oynanış uzunluğu DEĞİŞTİRİLMEDİ).**

| | 10l | 21o |
|---|---|---|
| Ağızdan hendek kenarına (z 36) | 8 m | 8 m |
| Ağızdan dış surun ova yüzüne (z 16) | 28 m | 28 m |
| Ağızdan iç sur kule yüzüne (z 4) | 40 m | 40 m |
| Oynanan en derin nokta (dünya z) | 25,9 (karşı lağım odasının arka duvarı) | 26,3 (kazı yüzü) |
| Surun dibine (z 16) kalan | **≈ 10 m kısa** | **≈ 10 m kısa** |
| "Altından geçiyor" repliği (yüz, koddaki `−SEG·(n+1)−0,2`) | 10l DIG_3 "surların altına girdik" (yüz z 35,8: hendeğin dış kenarı, sura 20 m): **tutarsız** | 21o DIG_3 "hendeğin altındayız" (yüz z 33,8: hendek 20…36): tutarlı; DIG_4 "surun temeli" (yüz z 31,3, hâlâ hendekte; sur z 14…16): **tutarsız** |

Yani iki tünel de hendeğin altında kalıyor, sura değmiyor; tünel sur dibine ulaşsın diye 28 m gerekir (iki oyunun 12/15 m'si
yetmez). Ağzı hendeğe sokmadan (z 36'dan öteye) bunu çözmenin yolu yok; oynanış uzunluğu değişmeyeceği için **açık kaldı**,
metin tarafı (replik) bu görevin dışı.

## 3. Ne taşındı / eklendi (dosya:işlev)

- `scripts/chapter10l.gd:663–740` (dosya sonuna eklenen blok; yeni `class_name` yok): `MOUTH_SURF`, `MOUTH_KEEP`,
  `mouth_parts(d, variant, rim_only)` (tek kurucu: toprak set + kalaslar, çıkrık/makara/ip/kova, koyu açıklık, çıkarılmış toprak
  yığınları, sepet siper sıraları [sura bakan yanda], kazma, sepetler; 21o'da direk yığını) ve `add_mouth(parent, xf, variant,
  rim_only)` (Dressing ile birleşik ağ, 160 m hücre; `visibility_range_end 1500 / margin 150`; ağ başına tek çizim hücresi).
- `scripts/chapter10l.gd:111` ve `scripts/chapter21o.gd:96` (+ `chapter21o.gd:18` `preload` sabiti): bölümün içinde kuyunun üstü
  **aynı kurucuyla**, yalnız `rim_only` (set, kalaslar, çıkrık, kova; 396 üçgen, 1 ağ). Yukarı bakan oyuncu dünyadaki çıkrığı görür.
  Dünyada ağız 3,4 bin üçgen (10l 3 362, 21o 3 482), 1 ağ.
- Tünelin kendisi (yeraltı) dünyada kurulmaz; dünya tünelin içine kurulmaz (§6).

### Ortak dosyalara eklenen satırlar (yalnız ekleme)
- `scripts/world/world1453.gd:107–117`: `REGIONS` içine `"tunnel_10l"` (134, −3,03, 44) ve `"tunnel_21o"` (189, −3,03, 44); `TUNNEL_MOUTHS`
  sözlüğü; `_CH10L` preload sabiti. `world1453.gd:336–358`: `tunnel_keep(field)` (ağız çevresini `keep`'e ekler, bölümün kendi
  `keep`'iyle kesişirse atlar, `lite` menü arka planında atlar) ve `tunnel_build(field)`.
- **`scripts/level/siege_field.gd:112` ve `:131`** (izin listesi dışı, 2 satır; gerekçe aşağıda): `World1453.tunnel_keep(self)` (`build()`
  başı, `_terrain()` öncesi) ve `World1453.tunnel_build(self)` (`_no_mans_land()` sonrası). **Sapma:** bu dalda `FAR_REGIONS` /
  `World1453.bake` / `far_hub` arayüzü YOK (`grep` boş), ayrıca kara surları bölümleri (0, 20, 22, 26o, 36b…) `World1453.build`
  değil `LandWalls._build_field` → `SiegeField.build()` çağırıyor; dünyaya bağlanabilecek tek ortak nokta `SiegeField.build`. İki satır
  olmadan ağız ne surlar bölümlerinde ne uçuşta (7, 11: `CampDay` → `World1453.build("camp")` → `SiegeField.build`) görünürdü.
  Sahibi karar versin; FAR_REGIONS inince bu iki satır ve `tunnel_*` işlevleri aşağıdaki kayda taşınır (öneri §9).
- Eklenmeyen: `FAR_REGIONS` (yok), `bake` (yok; Dressing zaten birleşik ağ üretiyor).
- Test yardımcıları (yeni): `tests/sonda_g7.gd/.tscn` (serbest kamera sondası: `--mode=walls|camp|chapter`, kare üstüne dünya
  koordinatı yazdırır), `tests/sonda_load_g7.gd/.tscn` (sahne açılış süresi; eski `tests/load_time.gd` bu ortamda `add_child`
  "Parent node is busy" ile hiçbir şey ölçmüyor: `ready=0`).

## 4. "Aynı yer" çiftleri (kare üstüne koordinat yazılı)

Dünya koordinatı: x sur boyunca, +z ova, y yukarı. İki dünya: kara surları bölümlerinin dünyası (LandWalls+SiegeField: 0, 20, 22, 26o, 36b)
ve uçuş bölümlerinin dünyası (7, 11: `CampDay` → `World1453.build("camp")`). Karşılaştırma, aynı serbest kamera sondasıyla (`sonda_g7`).

| Pafta | İçerik |
|---|---|
| `p01_yer_sur_ustu.jpg` | ÖNCE\|SONRA, sur üstünden (118, 9.7, 14) → ağız (134, 1.0, 44) |
| `p02_yer_ova_10l.jpg` | ÖNCE\|SONRA, **yerden** oyuncu gözü (112, 1.7, 62) → 10l ağzı (134, 1.4, 46) |
| `p03_yer_ova_21o.jpg` | ÖNCE\|SONRA, yerden (168, 1.7, 62) → 21o ağzı (189, 1.4, 46) |
| `p04_hava_yakin_surlar_dunyasi.jpg` | ÖNCE\|SONRA, havadan (134, 22, 70) → (134, 0, 45), surlar dünyası |
| `p05_hava_yakin_ucus_dunyasi.jpg` | ÖNCE\|SONRA, **aynı kamera**, uçuş dünyası (7/11) |
| `p06_ayni_yer_iki_dunya_hava.jpg` | SONRA: surlar dünyası \| uçuş dünyası, (160, 55, 115) → (160, 0, 44): iki ağız |
| `p07_ayni_yer_iki_dunya_yer.jpg` | SONRA: surlar dünyası \| uçuş dünyası, yer (112, 1.7, 62) → (134, 1.4, 46) |
| `p12_yakin_iki_agiz.jpg` | yakın: 10l ve 21o ağzı, (134|189, 1.7, 53) → (·, 1.0, 45.5) |

Okuma: iki dünyada ağız aynı yerde, aynı biçimde (toprak set + çıkrık, sura bakan sepet siper sırası, sağda toprak yığınları,
21o'da solda direk yığını), x 134 / 189 iç sur kulelerinin hizasında. Kareleri tek tek inceledim: havada duran, gömülü, küp gibi
kalan, titreyen (z-fighting) bir şey **görmedim**; dünyanın ev/çadırının içine giren bir şey yok (ağzın çevresi `keep`'te; ova boş).
Uçuş dünyasında (camp) gece görünümüyle baktım.

Bölümün içinden ağız (kuyunun üstü): `p08_kuyu_ici_chapter10l.jpg`, `p09_kuyu_ici_chapter21o.jpg` (ÖNCE\|SONRA, kuyu tabanından
yukarı: çıkrık, ip, kova ışık kutusunun önünde; kamera koordinatları karede). 10l/21o açılış-kapanış ÖNCE\|SONRA diyalog kareleri:
`p10_10l_acilis_kapanis.jpg`, `p11_21o_acilis_kapanis.jpg` (iç mekân aynı: yeraltı değişmedi, olması gereken bu).

## 5. Testler (SON kod; satırlar aynen)

`timeout 600 godot --headless --max-fps 20 --path . -- --chapter=N --autotest[=v]` — her koşuda `SCRIPT ERROR`, `WARN_FX_STUCK`,
`WARN_FLY_ITEM`, `VISAUDIT`, `WARN_VOID_TELEPORT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `JOURNEY_MISS`, `JOURNEY_OVERLAP`
satırlarından **hiçbiri yok** (grep sonucu boş).

```
AUTOTEST PASS chapter=10l variant= outcome=10L.1 progress=6 candle=3.5 heard=true
AUTOTEST PASS chapter=10l variant=collapse outcome=10L.3 progress=3 candle=9.5 heard=false
AUTOTEST PASS chapter=10l variant=retreat outcome=10L.2 progress=6 candle=3.5 heard=true
AUTOTEST PASS chapter=10l variant=leb outcome=10L.1 progress=6 candle=3.5 heard=true
AUTOTEST chapter=10l -> 11 outcome=10L.1      (next)
AUTOTEST PASS chapter=11 variant= outcome=11.2 persuade=25 sadakat=55 baski=1
AUTOTEST PASS chapter=21o variant= outcome=21O.1 dug=6 raid=true ear=false
AUTOTEST PASS chapter=21o variant=smoke outcome=21O.2 dug=6 raid=true ear=false
AUTOTEST PASS chapter=21o variant=lose outcome=21O.1 dug=6 raid=false ear=false
AUTOTEST PASS chapter=21o variant=ear outcome=21O.1 dug=6 raid=true ear=true
AUTOTEST PASS chapter=20 variant= outcome=20.1 repair=10 knocks=0 arrows=true gun=3/4 gunner=3/3 niko=0
AUTOTEST PASS chapter=22 variant= outcome=22.1 hits=2 singed=false window=0.42-0.68
AUTOTEST PASS chapter=26o variant= outcome=26.1 water=3 ladders=3 gun=3/4 stones=1/1 gunner=5/5 oil=1/1 turgut=no
AUTOTEST PASS chapter=36 variant= outcome=36.1 burned=3 fights=1 kills=5       (36b)
AUTOTEST PASS chapter=7 variant= branch=7a outcome=7.1 extras=[] sadakat=60 baski=0 hour=13.5
AUTOTEST PASS chapter=11 variant= outcome=11.2 persuade=25 sadakat=55 baski=1
AUTOTEST PASS chapter=0 variant= froze=true
PARSECHECK PASS scripts=247
WORLDCHECK PASS regions=15 landmarks=35        (bölge sayısı 13 → 15: tunnel_10l, tunnel_21o)
FLIGHTCHECK camp landmarks=9 forms=12 perches=3 / FLIGHTCHECK walls landmarks=9 forms=12 perches=3 / FLIGHTCHECK PASS
EXPORTREFS PASS
```
`city_check`: PASS/FAIL satırı yazmıyor; çıktısında hata/uyarı satırı yok (yalnız SSAO/SSIL renderer uyarıları, ÖNCE'de de var).
ÖNCE (taban) koşuları: 10l, 21o, 20 varsayılan yol `AUTOTEST PASS` (aynı sonuçlar; 20'de `gunner` 4/4 → 3/3: bu, koşu
hızına bağlı kaçınma sayacı; her iki durumda `PASS`). Not: 26o ve 36b için ayrı ÖNCE koşusu yapmadım (yalnız 10l, 21o, 20). Bu iki bölümün `gunner`/`kills` sayaçları da zamana bağlı: ilk SONRA
koşusunda 26o `gunner=6/6`, 36b `kills=4`, son kodda `gunner=5/5`, `kills=5` (aynı kodla bile koşudan koşuya değişiyor); ikisi de `PASS`.
Betik sonunda "resources still in use at exit" satırı ÖNCE'de de var.

## 6. RINFO ve yükleme süresi (ÖNCE\|SONRA)

`--hitchaudit` + `RINFO=1`, xvfb, `--max-fps 20`. Aynı sahne zamanında (t sn) örnekler. (Not: RINFO zamana göre örnekler, replik anına
değil; "aynı replik anı" için sahne zamanı t ile eşledim, iç mekân kareleri iki durumda aynı sırada.)

**Tünel bölümleri (ağzın bölüm içi kısmı: +1 ağ):**

| | ÖNCE çizim / üçgen (bin) | SONRA çizim / üçgen | Fark |
|---|---|---|---|
| 10l t=5 | 610 / 96 | 612 / 97 | +2 çizim, +1k |
| 10l t=11 | 610 / 96 | 612 / 97 | +2, +1k |
| 10l t=17 | 508 / 95 | 510 / 96 | +2, +1k |
| 10l medyan (77 örnek) / tepe | 546 / 96k · 700 / 121k | 550 / 97k · 702 / 121k | +4, +1k |
| 21o t=11 | 512 / 37 | 514 / 38 | +2, +1k |
| 21o t=17 | 560 / 37 | 562 / 38 | +2, +1k |
| 21o medyan (65 örnek) / tepe | 508 / 37k · 652 / 134k | 510 / 38k · 638 / 139k | +2, +1k |

Tünelin kendi çizimi artmadı denemez: +2 çizim (≈ +0,4 %), +≈1 bin üçgen (≈ +1 %) — `rim_only` ağı. Tavan (≤ 900 çizim, ≤ 2,5 M) altında,
bugünkü değerin +%10'u içinde. (İlk denemede ağ orijinde dört hücreye bölünüyordu: +6 çizim; hücre ortasına kaydırıp düzelttim.)

**Yükleme** (`tests/sonda_load_g7`, başsız, 7 örnek, ilk soğuk açılış atıldı; ms, sahne düğümünü ağaca eklemek = `_ready`/kurulum):

| | ÖNCE medyan (tepe) | SONRA medyan (tepe) |
|---|---|---|
| 10l `_ready` | 37,3 (41,0) | 38,5 (39,8) |
| 10l ilk kare | 8,6 | 8,9 |
| 21o `_ready` | 51,6 (114,1) | 40,0 (42,2) |
| 21o ilk kare | 14,2 | 8,4 |

Fark gürültü içinde (21o ÖNCE'deki 114 ms tek bir ölçüm sıçraması); artış yok. Dünya tarafı: `tunnel_build` iki ağız için
2–4 ms (`MOUTHTIME` ölçümü, 5 örnek); `SiegeField.build` karelere yayılıyor, ağız ölü bölgeden sonra tek adım.

**Dünya bölümleri** (20 surlar; 7 ve 11 uçuş; 270 sn'lik koşu, ortak t örnekleri): ağız yalnız bakıldığında çiziliyor (2 ağ, 6,8 bin
üçgen, kamera görmüyorsa 0). Ölçülen medyanlar: 20: 5 674 → 5 733 çizim, 7,90 M → 7,84 M üçgen; 7: 2 712 → 2 774, 4,41 M → 4,73 M;
11: 4 545 → 4 628, 7,18 M → 7,26 M (tepe 7 512 → 7 566). Bu sahnelerin bugünkü değeri tavanın (900 / 2,5 M) zaten çok üstünde
(ÖNCE'de de); artış %1–2 ve aynı t örneklerinin kendi dalgalanması (±100–460 çizim) içinde ayrışmıyor → **bu sahnelerde ağzın
maliyeti ölçümle ayrıştırılamadı** (analitik üst sınır: görüşteyken +2 ağ). KANITSIZ: ağız görüşteyken tam fark (ayrı kare
koşusu yok).

## 7. Performans yöntemi (uzakken yüklenmez)
- Tünelin içindeyken dünya KURULMAZ (10l/21o sahnelerinde `World1453.build`/`SiegeField` yok; yalnız `rim_only` ağı).
- Dünyada ağız tek birleşik ağ (Dressing, 160 m hücre = ağız başına 1 `MeshInstance3D`), `visibility_range_end 1500` + `margin 150`
  (ufka yakın görünmez; kenar payı histerezis, **birden belirme/kaybolma KANITSIZ**: o mesafede sondayla bakılmadı).
- Ağızın çevresi `keep`'te: ev/çadır/mantolu okçu/asker/çukur konmaz.

## 8. Açık kalanlar
1. **Tünel uzunluğu / replikler tutarsız** (§2): iki oynanış 10 m kısa; 10l DIG_3 ve 21o DIG_4 repliği yanlış yerde. Replik DEĞİŞMEZ kuralı gereği dokunulmadı.
2. **Tarih:** iki ağız her bölümde (tarihten bağımsız) açık duruyor; 26o (29 Mayıs) / 36b'de "25 Mayıs'a kadar tek tek bulunup kapatıldı"
   (`D21O_N_END`) uyarınca kapalı/çökmüş ağız yok. Yapılmadı.
3. **Ağızdan dışarının görünmesi:** tünel kuyusu 3 m duvarlı, üstü siyah ortam; dışarıdan hiçbir ufuk görünmüyor (ÖNCE'de de yoktu).
   Yalnız yukarı bakınca dünyadaki çıkrık/set görünüyor. "Ağzın gördüğü dilim" (ufuk/sur) kurulmadı. BAKILMADI/yapılmadı.
4. **Gündüz görünümü** (CampDay gündüz modu, 0/20 gündüz sürümleri) BAKILMADI; kareler gece.
5. Koyu açıklık bir levha: arazide delik yok; oyuncu/Nihat ağzın üstünden yürürse levhanın üstünde yürür (WorldWalk zemini sürekli). Yürünüp bakılmadı
   (`WALKTHRU` yok ama bu yolu yürüyen test de yok): BAKILMADI.
6. Uçuşta (7/11) ağıza konma/çarpışma (flight solids) BAKILMADI; `flight_check` PASS.
7. Ortak dosya sapması: `siege_field.gd` 2 satır (§3). Başka bir yardımcının 10l/21o'daki görsel düzeltmeleriyle çakışma yok: bende
   `chapter10l.gd` sonuna blok + `_build` içinde bir satır, `chapter21o.gd`'de bir `preload` + `_build` içinde bir satır var.

## 9. Ortak dosyalar için öneri (FAR_REGIONS geldiğinde)
```gdscript
# world1453.gd
const FAR_REGIONS := { ..., "tunnel_10l": Rect2(-8, -3.4, 16, 11), "tunnel_21o": Rect2(-8, -3.4, 16, 11) }
# build() içindeki match:
	"tunnel_10l": Chapter10l.add_mouth(f, region(fr), "10l")     # tunnel_build'in yerine
	"tunnel_21o": Chapter10l.add_mouth(f, region(fr), "21o")
```
`tunnel_keep/tunnel_build` ve `siege_field.gd`'deki iki satır kalkar; landwalls bölümleri `World1453.build` kullanmadığı için FAR_REGIONS
döngüsü `LandWalls._build_field` içinde de çalışmalı (aksi hâlde surlar bölümlerinde ağız görünmez).
