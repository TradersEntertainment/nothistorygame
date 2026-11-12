# P3 düzeltme turu — ikinci (son) küçük tur: geliştirici raporu

Dal `wip/duzeltme-p3` (taban: `613a3019`, denetçinin ucu). Godot 4.4.1, xvfb 1280x720, `PACE=1 RINFO=1 --hitchaudit --dialogshots --shotevery=1 --snapevery=0.5`.
Yalnız `scripts/chapter29o.gd` ve `scripts/chapter38o.gd` değişti. Replik metni, süre sabiti (`HOLD_TIME`, `fork_at`, `pot_at`,
`FORK_WINDOW`), sayaç, kazanma/kaybetme koşulu, kalabalık sayısı ve denetim ayarı değişmedi; susturma yok.
ÖNCE = bu dalın şimdiki ucu (`613a3019`) ekranlı koşusu (aynı koşu düzeni), SONRA = bu tur. Kare adı `tNNNN` = koşunun kare sayacı;
`+N` = ilgili replik anahtarının karesinden N kare sonrası. Ham veri: `ham_test_r2.txt`, `ham_rinfo_r2.txt`.

## Maddeler

### [1] 29o ip ağı her karede kurulmuyor — **DÜZELDİ** (ölçüldü)
- `chapter29o.gd:421-460` (`_seg_mesh`, `_rope_pool`, `_rope_set`): `_tube_to` silindi. Birim boy (−z yönünde 1 m) yuvarlak kesitli tek ağ
  yarıçap başına **bir kez** kurulur (`ThraceRoad.tube_mesh` yalnız `_seg_mesh` içinde); ip parçaları bu ağı paylaşır, kare başı yalnız
  `Transform3D` (uzunluk = z ölçeği) yazılır. `_climb` (`:354-366`, `:401-403`): 3 parça (küpeşte → üst yumruk → alt yumruk → halka),
  düşüşte `_rope_clear` noktaları aynı havuza; `_fly_hook` (`:307-316`): 8 parçalı sarkık ip. Eski ip malzemesi/renk/yarıçap (0,012 ve 0,014) aynı.
- **Sayaç** (geçici; ağ kurma = `tube_mesh` çağrısı, geri alındı: `grep "_dbg\|ROPECOUNT"` 0), `PACE=1` başsız koşu, 29o varsayılan:

  | | tırmanış (2,2 sn, tween karesi) | kanca uçuşu (5 atış, her biri) | bütün bölüm |
  |---|---|---|---|
  | ÖNCE ağ kurma / kare | **44 / 44** | **8 / 9** | 84 / 89 |
  | SONRA ağ kurma / kare | **0 / 44** (ağ önbellekte) | **0 / 9** | **2 / 89** (iki yarıçap, ilk kullanımda) |

  Ölçüt (kare sayısından belirgin az) karşılandı: kare başı ağ kurma sıfır.
- Görünüş: **p03** `r2_p03_29o_tirmanis_once_sonra.jpg` (ÖNCE `t0196/t0197/t0199` | SONRA `t0195/t0197/t0199`, `D29O_T_CLIMB` sonrası):
  iki el ipte, ip düz ince çizgi, düşüşte yakın şerit yok; fark gözle ayırt edilmiyor. Dönüşte (el noktalarında) ip artık yumuşak değil,
  3 doğru parçası; yarıçap 1,2 cm'de kırık görünmüyor (**KANITSIZ**: kanca uçuşunun kendi karesi alınmadı; kod yolu aynı havuz).
- RINFO 29o (`D29O_T_CLIMB` sonrası üç örnek; çizim / üçgen bin): ÖNCE 2782/1257, 630/403, 1381/1213 → SONRA 2792/1264, 626/393, 1336/1149.
  Bütün koşu (47 örnek) ortalaması: çizim 2692 → 2636 (−%2,1), üçgen 2115 → 2079 (−%1,7). Çizim artmadı.

### [2] 38o ikinci tırmanan tayfa / çatal — **DÜZELDİ** (küçük kalan: gövdeler tutuş başlığının altında, bk. not)
- `chapter38o.gd:548-554`: `CLIMB_AT` 4,4 → 3,5, `CLIMB_GAP` 3,0 → 3,5, `_climb_side` ±0,1 → ±0,3 m (dikme ±0,4; iki gövde 0,6 m yan yana, merdivene/birbirine
  girmiyor, eller basamakta). Geometri: kamera 2 m, merdiven 25° yaslı → iki tayfa 58–71° yükseklik açısında; dik açı yüzünden önceki konumda
  ikincisi öndekinin arkasında kalıyordu.
- Çatal (`_fork_visual`, `:795-802`): (a) renk `9a7a50`/`3a3a40` → `f0e0b0`/`e8ecf0`, sırık yarıçapı 0,055 → 0,11, dişler 0,018 → 0,035;
  (b) başlangıç noktası `tip + rx*1,1 + (0,2,1,0,5)` → `tip + rx*2,4 + (0,1,9,0,6)`: eski konumda sırık bakış çizgisine paralel kalıp tek noktaya düşüyordu
  (ayaktan bakışta yükseklik açısı ≈ 61°), yandan uzanınca gökyüzüne karşı açık renkli yatay/çapraz sırık olarak seçiliyor.
- Kare: **p01** `r2_p01_38o_ladder_once_sonra.jpg` — üst sıra ÖNCE `D38O_T_02` +20/+40/+66 (`t0264/t0284/t0310`), alt sıra SONRA (`t0249/t0269/t0295`).
  SONRA +66'da iki baş + iki gövde ayrı (kahverengi öndeki sağda, mavi arkadaki solda), çatal sırığı başın üstünde. **p02** üst: SONRA `t0298` yakın kesit (çatal açık sırık);
  alt: `t0329` (+100) iki tayfa baştan ayağa ve mazgal.
- **Not (KISMEN +40)**: `D38O_T_02` +40 karesinde (`t0269`) iki **baş** seçiliyor, iki gövdenin üst yarısı tutuş görevi başlığının
  ("2 · MERDİVENİN AYAĞINI TUT" bandı, kadrajın tam ortasında, ilk ~12 sn) altında kalıyor; bant kalkınca (+66, +100) iki baş + iki gövde tam seçiliyor. Bandı taşıma ortak dosya (HUD) işi; yapılmadı.

### [3] 38o `_brace`/`BRACE_LOOK`: sur askerleri + mazgal kadrajda — **KISMEN**
- `BRACE_LOOK` 2,75 → 3,2 (`:543`): bakış ≈ 42° (önceki 38°; ara denediğim 5,2 m'de 55° bakış mazgalı kadraj ortasına, tayfanın gövdelerini tutuş bandının altına itiyordu, geri alındı).
  Bakış denetimi aynı: `_look_soft` 0,8 sn tween, ≤ 1 sn; sonra oyuncunun (`free_look`). `_brace` dışında bakış çağrısı eklenmedi.
- Kök neden (kamera 2,06 m, sur yürüyüş yolu 9,6 m, duvara 5,4 m: yükseklik açısı ≈ 54°): mazgal merlonları (1,2 × 1,1 m, 2,5 m aralıklı) askerin (merlonun 0,75 m
  gerisinde) gövdesini alttan bakışta tamamen kapatıyordu; boşluklara denk gelmeyen askerler hiç görünmüyordu. Yayındaki (`e551de84`) kadraj
  1,4 m daha geriden bakıp aynı sorundan kaçınıyordu ama merdivenin ayağına eller yetişmiyordu; geri durma bu yüzden yapılamadı.
- Çözüm: `:160-164` asker yerleri **en yakın mazgal boşluğunun ortasına** çekildi (`gap_x`, en çok 0,85 m kayma; sayı, sıra, z, bakış değişmedi). **Dikkat:** bu bir yerleşim
  değişikliği (oyun mantığı değil); istenmezse bu 2 satır geri alınır.
- Kare: **p02 alt** (`t0329`, +100): mazgal dizisi tam kadrajda, iki tayfa baştan ayağa; boşluklardaki askerlerin yalnız **başı/miğferi ve mızrak ucu**
  görünüyor (5,4 m'den 54° bakışta merlonun gerisindeki gövde fiziksel olarak kapalı). `main` karesindeki gibi gövdeleriyle seçilen asker **YAPILAMADI**.

## Testler (başsız, `--max-fps 20`; 32 koşu hepsi `AUTOTEST PASS`)
`SCRIPT ERROR / WARN_FX_STUCK / WARN_FLY_ITEM / VISAUDIT / WARN_VOID_TELEPORT / WALKTHRU / ARMAUDIT / HELDAUDIT / LOOKAUDIT backturn / JOURNEY_MISS / JOURNEY_OVERLAP` toplamı: **0**.

| Bölüm | Varyant | Sonuç |
|---|---|---|
| 38o | `""`, `lose`, `hooks_ok`, `hooks_bad` × 2 | 8/8 PASS |
| 38o | `hooks_bad` × 10 | 10/10 PASS; `VISAUDIT personhidden` **0** (denetçi: ÖNCE-main 0/10, ÖNCE-ef 1/10, tip 0/10) |
| 29 | `""`, `lose` × 2 | 4/4 PASS |
| 29o | `""`, `lose` × 2 | 4/4 PASS |
| 33o | `""`, `wide`, `fall` × 1 | 3/3 PASS |
| 28o, 34o, 19 | `""` | 3/3 PASS |
| `parse_check` | — | `PARSECHECK PASS scripts=248` (son yorum düzeltmesinden sonra da) |

## RINFO 38o `ladder` (`D38O_T_02` sonrası üç örnek; çizim / nesne / üçgen bin)
ÖNCE (bu dalın ucu, denetçi `ham_rinfo.txt` `sonra_38o`): 2726/3026/2205, 2991/3466/2196, 2958/3433/2154.
SONRA: 2669/3144/2059, 2622/3097/2024, 2545/3020/1973 (üçgen −%6,6…−%8,4, çizim −%2…−%14; örnek hizası ±%10 oynar). Çizim ve üçgen **artmadı**. (ÖNCE bu turda kendi koşumla alınmadı; denetçinin ölçümü, aynı kod ucu.)

## Yapılamayan / kanıtsız / dürüst notlar
- ÖNCE 38o RINFO'yu kendi koşumda almadım (ilk ÖNCE koşusunda `--hitchaudit` yoktu); yukarıdaki ÖNCE sayıları denetçinin aynı uç için ölçümü.
- 29o SONRA ekranlı kareler ve RINFO, sayaçlı (görüntüyü etkilemeyen) kod sürümünden; sayaçsız son sürüm 29o başsız ×2 + `parse_check` ile doğrulandı, ekranlı yeniden alınmadı.
- Ekranlı 29o/38o koşularında bazı kısa süreler aynı anda ikinci bir ekranlı denemeyle (tanı koşusu, kanıt değil) çakıştı; kanıt kareleri tek ekranlı koşudan.
- Kare hızı ekranlı koşuda ≈ 1,7 kare/sn; `+N` kare ≈ 0,6 sn. Çatal ≈ 1,3 sn görünür (otomatik test 0,4 sn'de bastırır), kare yakalaması 2–3 kare.
- Serbest bakış (fare) yine denenmedi (bot fareyi oynatmıyor). 33o ekranlı kare ve 29o kanca uçuşu karesi alınmadı (KANITSIZ).
- Çatal sırığı artık yandan geldiği için mazgalı bir an kısmen örtüyor (görsel, kısa); oyun akışı etkilenmiyor.
- Bu tur (`ham_*` dışında) `i18n/*.translation` ve `.import` üretilmiş dosyaları kaydedilmedi.
