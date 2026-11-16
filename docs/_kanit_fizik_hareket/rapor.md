# Hareket hissi (Tolga) — rapor

Dal `wip/fizik-hareket` (taban `wip/fizik-taban5` 0ef7b470). Ölçüm dökümü: `dokum.md`. Kareler: `kare/` (1280×720,
jpg 85; her senaryo `<ad>_ONCE_<i>.jpg` / `<ad>_SONRA_<i>.jpg`, 0,1 sn arayla; `pafta_<ad>.jpg` yalnız özet — kararlar tam
boy karelere bakılarak verildi).

Yeni/değişen dosyalar:
- `scripts/player/hareket_his.gd` (yeni, `HareketHis`): kamera (görüş açısı, eğilme, yatış, iniş çökmesi, nefes),
  iniş (toz, ses, "Ay!"), serbest düşüş (kollar, rüzgâr, sarsıntı, çığlık), `dusus()`, `HAREKETAUDIT`.
- `scripts/player/player.gd`: `_ivmelen` (yerde ivme eğrisi), `_zipla_iste`/`_zipla_hiz` (coyote + tampon), havada
  kollar (sağ el + sol el), merdiven tepesinde kamera yetişmesi, `dusus_hissi()`, bütçe ölçüm kancası
  (`--hareket-butce`) ve kare aracı kancası (`--hareket-kare=`). `kick()` / `EsyaFizik.darbe` dokunulmadı.
- `scripts/player/traversal.gd`: yakalama darbesi, kenardan çıkışta kamera eğilmesi, yorgunlukta el titremesi ve göz
  nefesi, aşmada eller ve eğilme. `_click`'teki eşya tekme dalı dokunulmadı; tüm sabitler aynı.
- `scripts/chapter2.gd`, `scripts/chapter44b.gd`: yalnız birer `player.dusus_hissi(…)` satırı.
- `scripts/ui/game_menu.gd`: ayarlara bir anahtar (`UI_SET_MOVE_CAM`); `i18n/strings.csv`: o anahtar.
- `tests/_fizik/hareket_sahne.*` (ölçüm + kare), `hareket_gez.gd` (bölüm içi kare), `hareket_pafta.py`.

## Madde madde

| madde | durum | not |
|---|---|---|
| 1. ölç ve dök | **TAMAM** | `dokum.md`; ÖNCE ölçümleri taban kopyasında (yalnız ölçüm kancası eklenmiş) |
| 2. koşu ve duruş | **TAMAM** | ivme 0,10 → 0,15 sn, duruş 0,17 → 0,23 sn, ters dönüşte 0,22 sn savrulma; koşuda FOV +5° (ayara göre göreli), 1,1° öne eğilme, dönüş/yana yürüyüş yatışı ≤ 1,6°; koşuda her ikinci adımda takım elbise hışırtısı (`cloth`). Ayar: "Koşu, zıplama ve iniş kamera efektleri" |
| 3. zıplama ve iniş | **TAMAM** | coyote 0,1 sn, tampon 0,1 sn; havada iki kol hafifçe açılır; inişte yüksekliğe göre yaylı çökme (1 m: 2,4 cm, ≥ 2,5 m: 16 cm + 0,16 sn çömelme), ≥ 1 m toz, kapalı kipte iniş sesi, ≥ 2,5 m'de "Ay!" (var olan `D4B_T_HIT_1`, 25 sn'de bir). `STAGGER_FALL`, sendeleme ve hasar aynı |
| 4. düşüş | **TAMAM** | ≥ 3 m serbest düşüşte kol savrulur, hafif sarsıntı, rüzgâr (`whoosh_fly` döngü, hızla yükselir); öngörülen düşüş ≥ 6 m ise Bölüm 2 çığlığı (`D2_T_FALL_SCREAM`), inişte kesilir. Ortak `Player.dusus_hissi(sure, bagir)`; 2 (rüzgâr + sarsıntı; çığlık bölümde zaten var) ve 44b (kollar + rüzgâr + çığlık) birer satırla çağırır, süre/akış aynı |
| 5. tırmanma ve kenar | **KISMEN** | yakalama darbesi (eller duvara çarpıp oturur, kamera bir an çöker, hışırtı), kenardan çıkışta kamera kenara yükselip 8°'ye kadar öne eğilir, nefes < %45'te ellerde titreme ve göz hizasında nefes salınımı; aşmada eller engelin üstünde + 5° eğilme. **Nefes SESİ yok**: kitaplıkta nefes efekti yok, yeni ses üretilmedi (bkz. kalanlar). Süre ve dayanıklılık aynı (kenar 0,68 sn, 7 m duvar 3,90 sn / kalan nefes 0,53) |
| 6. kanıt | **TAMAM** | 9 sahne senaryosu + Bölüm 2 + 44b kare dizileri ÖNCE\|SONRA; çatı botu R1–R3 ve sur yürüyüşü ÖNCE = SONRA |
| 7. denetim | **TAMAM** | `HAREKETAUDIT` (zıplama tepesi, menzil, iniş sonrası takılma, kamera duvarda, FOV dönmedi); ara bölüm koşularında 0 satır; tam paket sonucu aşağıda |
| 8. bütçe | **TAMAM** (sınırda) | +0,09 / +0,12 / +0,27 ms/kare (≤ 0,3); ayrıntı aşağıda |
| 9. rapor | **TAMAM** | bu belge |

## Ölçüm tablosu (ÖNCE = SONRA olması gerekenler)

| ölçü | ÖNCE | SONRA |
|---|---|---|
| yürüme / koşu hızı | 3,20 / 5,20 m/sn | 3,20 / 5,20 |
| yerinde zıplama tepesi | 0,692 m (0,68 çatı sondası) | 0,692 (0,68) |
| havada kalış | 0,77 sn | 0,77 |
| koşarak atlama aralığı KAPALI / AÇIK | 4,2 / 5,9 m | 4,2 / 5,9 |
| yürüyerek atlama | 2,6 m | 2,6 |
| basamak (yürüyerek / koşup zıplayarak KAPALI / AÇIK) | 0,48 / 0,75 / 2,55 m | 0,48 / 0,75 / 2,55 |
| yukarı atlama dh 0,3/0,5/0,6 KAPALI | 3,8 / 3,4 / 3,1 m | 3,8 / 3,4 / 3,1 |
| eğim, duvara çıkış, sendeleme eşiği | 44°, 0,70 / 3,90 m, 4,0 m | aynı |
| **menzil, kenardan koşu zıplaması** (kare hizasından bağımsız, kalkıştan; dh 0/1/2,4/3,4/5,8 m) | 3,99 / 5,10 / 6,17 / 6,79 / 8,03 m | 3,99 / 5,10 / 6,17 / 6,79 / 8,03 |
| coyote (kenardan 0,05 sn sonra zıplama), aynı | — (zıplamıyor: 0 / 2,31 / 3,60 / 4,29 / 5,61) | 3,34 / 4,64 / 5,79 / 6,44 / 7,71 (hepsi kenarınkinden kısa) |
| düşüş süreleri 1 / 2,5 / 3,5 / 6 m | 0,47 / 0,72 / 0,85 / 1,12 sn | aynı |
| sendeleme (AÇIK, 6 m) | 0,68 sn, falls=1 | 0,68, falls=1 |
| merdiven 3,4 m | 1,47 sn | 1,47 |
| kenara tutunup çıkma 2,2 m | 0,68 sn | 0,68 |
| 7 m tırmanış / kalan nefes | 3,90 sn / 0,53 | 3,90 / 0,53 |

Not (dürüstçe): `cati_hareket` sondasının aşağı atlama satırları iki yerde kaydı: KAPALI dh 5,8 m 7,9 → 8,2; AÇIK
dh 2,4 m 7,3 → 7,6 (dh 5,8 AÇIK 7,9 = 7,9). Sonda kenara `z < 0,15` iken (karede 8,7 cm ilerleyerek) zıplıyor ve aralığı
0,3 m adımla arıyor; ivme eğrisi değişince kalkış noktası kare içinde kayıyor. Kalkıştan ölçülen yol (yukarıdaki
"menzil" satırı) ÖNCE ile santimine kadar aynı; havadaki ivme, `JUMP`, `RUN` dokunulmadı. İlk coyote sürümü derin
inişte gerçekten uzatıyordu (dh 5,8'de +0,3 m); düzeltildi (coyote hızı = kenar zıplamasının o anki hızı, yol aşağı
kaymış kenar yolu) ve `HAREKETAUDIT menzil` eklendi.

| his (yeni) | ÖNCE | SONRA |
|---|---|---|
| duruştan %90 hıza | 0,10 sn | 0,15 sn |
| koşudan duruşa | 0,17 sn | 0,23 sn |
| koşuda görüş açısı (ayar 72°) | 72° | 77° (0,25 sn'de 76,5) |
| ani dönüşte yatış | 0° | ≤ 1,6° (sondada anlık 90° dönüş "face" sayıldığından 0,19°) |
| zıplama inişinde kamera çökmesi | 0 | 1,6 cm |
| 1 / 2,5 / 3,5 m düşüşte kamera çökmesi | 0 / 0 / 0 | 2,4 / 15,6 / 15,6 cm |
| coyote 0,07 sn / tampon 0,08 sn | yutuluyor / yutuluyor | zıplar (vy 2,62) / zıplar |

## Kareler (`kare/`)

| senaryo | dosya | gözlem (tam boy) |
|---|---|---|
| koşuya başlama | `kosu_*`, `kosu_surer_*` | SONRA sütunlar küçülür (FOV 77°), ufuk ~5 px yukarı (öne eğilme). Fark hafif; hareket hastalığı için bilerek küçük |
| ani dönüş | `donus_*` | SONRA dönüşte ufuk ~1° yatar; sondadaki dönüş tween'i hızlı olduğundan ancak 2. karede okunur. **Zayıf kanıt** |
| zıplama + iniş | `zipla_*` | SONRA havada sol kol yana açılır (0–3. kareler), inişte iner; inişte kamera hafifçe çöker |
| 3,5 m düşüş | `dusus3_*` | SONRA kol savrulur, inişte kamera ~16 cm çöker ve toparlanır. ÖNCE hiçbir şey olmuyor |
| 8 m düşüş | `dusus8_*` | SONRA kol savrulur, iniş çökmesi. Toz: ayağın dibinde/bakış yönüne 0,35 m; aşağı bakmayınca kadraja girmiyor (**karede görünmüyor**) |
| merdiven tepesi | `merdiven_*` | ÖNCE 3. karede görüntü bir karede sıçrıyor; SONRA kamera ~0,3 sn'de kayarak yetişiyor (fark küçük ama okunur) |
| kenara tutunup çıkma | `kenar_*` | SONRA kamera kenara yükselip öne eğiliyor (2. karede damın üstü ve eller), sonra doğruluyor |
| tırmanma (nefes %30) | `tirman_*` | SONRA ellerde titreme ve göz salınımı; kare dizisinde ince (titreme 6 mm). **Zayıf kanıt** |
| Bölüm 2 kızaktan uçuş | `chapter2_ucus_*` | ÖNCE ve SONRA neredeyse aynı (bölümün kendi kol savrulması zaten vardı); eklenen rüzgâr sesi ve ±6 mm sarsıntı karede okunmaz. Sevilen düşüş bozulmadı |
| 44b kuyu düşüşü | `chapter44b_kuyu_*` | ÖNCE: kollar yok, ses yok, sessizce iniyor. SONRA: "AAAAAAAA!" (Bölüm 2'nin çığlığı, altyazı karede), kol savrulur, rüzgâr; suya çarpınca kesilir |

Kareler yazılım çiziminde (xvfb, llvmpipe) çekildi; bölüm içinde oyun çekim boyunca ağır çekime alındı
(`hareket_gez.gd`), kare aralıkları oyun zamanında 0,1 sn. Sentetik sahnede ışık/sis aşırı parlak (gökyüzü beyaz):
kötü ama ölçüm için yeterli.

## Botlar (gerçek girdi)

| koşu | ÖNCE | SONRA |
|---|---|---|
| çatı R1 KAPALI / AÇIK | tamam 12/12, takılma 0, düşme 0 (10,8 / 10,7 sn) | tamam 12/12, 0 / 0 (12,4 / 10,9 sn) |
| çatı OZET KAPALI / AÇIK | rota 3/3, takılma 0, düşme 0, sıkışma 0 | aynı |
| sur yürüyüşü | `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` | aynı |
| sur sözleşmesi | `SURSOZLESME PASS kalem=13 kesim=8`, `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` | aynı |
| eşya fiziği | `ESYATEST PASS` | `ESYATEST PASS` |

Süreler (KAPALI, ÖNCE → SONRA): R1 10,8 → 12,4 sn, R2 12,3 → 16,0, R3 11,6 → 15,1; AÇIK: 10,7 → 10,9, 12,7 → 12,5,
12,4 → 12,3. KAPALI kipte uzama gerçek: bot son hedef noktasının (merdiven dibi, kot farkı) çevresinde koşu hızıyla
ileri geri salınıyor (iz `CATIIZ`: hedefi 0,3 m aşıp geri dönüyor, ters dönüşte hız 0,22 sn'de dönüyor; ÖNCE 0,08 sn).
Takılma/düşme sayısı aynı (0). Oyuncu için bu "savrulma" isteğin parçası; süreli görev etkisi kaba hesapla durup
dönme başına ≈ +0,1 sn. Eğer sahibi bunu fazla bulursa `Player._ivmelen` içindeki ters dönüş oranı (`speed / 0.22`)
`speed / 0.16`'ya indirilebilir (tek sayı).

## Bütçe (`--hareket-butce`, `--max-fps 20`, ÖNCE ve SONRA aynı anda koşturuldu)

| bölüm | ÖNCE ms/kare | SONRA ms/kare | fark | bunun `HareketHis.adim` payı |
|---|---|---|---|---|
| 1 | 0,444 | 0,536 | +0,09 | 0,108 |
| 20 | 0,700 | 0,817 | +0,12 | 0,109 |
| 6 =byzclimb | 0,837 | 1,103 | **+0,27** | 0,145 |

Sınır (≤ 0,3) içinde, 6=byzclimb'de sınıra yakın. Ölçüm makinesi aynı anda başka koşular da taşıyordu (gürültü
±0,1). Sonrasında görüş açısının her karede yeniden yazılması kaldırıldı (yalnız değişince); bu son ölçüme
girmedi.

## Denetim (HAREKETAUDIT)

Türler: `zipla_tepe` (kalkış hizasından tepe > JUMP²/2g + 6 cm), `menzil` (kalkış hizasına inince yatay yol > hız ·
2·JUMP/g + 0,2 m), `inis_takilma` (hızla inip ileri basılıyken 0,35 sn duruyor, önde duvar yok), `kamera_duvar` (gövde
ekseninden kameraya ışın 3 kez üst üste bir yüzeye çarpıyor), `fov` (koşu bitti, katkı 1,5 sn'de sıfırlanmadı).
Sahnede ilk sürüm `menzil` için yanlış alarm verdi (ışınlanma sonrası eski kalkış noktası); kök neden düzeltildi
(ışınlanmada kayıtlar sıfırlanır), eşik gevşetilmedi.

Ara koşular (`--max-fps 20`): 1, 2, 6, 6=byzclimb, 20, 26, 30, 38o, 43o, 44b → hepsi `AUTOTEST PASS`, `SCRIPT ERROR`
0, denetim satırı 0.

Tam paket (`SHARD=0..3 SHARDS=4 MAXFPS=20`, 4 parça aynı anda, son kayıttaki kodla — `f5ac161e`): **456 `AUTOTEST
PASS`, `AUTOTEST FAIL` 0, `TIMEOUT` 0, `SCRIPT ERROR` 0, HAREKETAUDIT 0** (`user://hareketaudit.log` oluşmadı). Parça
sonuçları: 1 ve 3 `fail=0`, parça 2 `fail=1` (aşağıdaki CITYCHECK), parça 0 sonu menü dönüşü `MENURETURN PASS`. Paket süzgecinde üç satır çıktı, **hiçbiri oyuncu hareketiyle ilgili
görünmüyor ve tek başına koşunca tekrarlanmadı**:

| satır | koşu | tek başına (ÖNCE ×2 / SONRA ×2–3) |
|---|---|---|
| `VISAUDIT meshhidden key=D10O_CAMELEER_1 … by=bas/Ag` (devenin başı deveciyi kapatıyor) | `--chapter=10 --autotest=fail` | yok / yok (SONRA 3 koşu) |
| `VISAUDIT overlap scene=chapter36b.tscn` (iki savunmacı iç içe) | `--chapter=36b --autotest` | yok / yok |
| `CITYCHECK FAIL: 24 … porter gövde yerinden kopuk (1.07 m)` (sivil, oyuncusuz denetim) | `tests/city_check.tscn` (parça 2'nin `fail=1`'i) | PASS / PASS |

Dördü aynı anda çalışırken yük altında çıkan, deve yürüyüşü/kalabalık zamanlamasına bağlı satırlar; dosyaları
(`chapter10`, `chapter36b`, şehir sivilleri) bu işin sahipliğinde değil, kök nedene dokunulmadı. Tekrarlanmadığı için
"kök neden düzeltildi" denemez: **açık kalan** olarak yazıldı (kalanlar).

## Kalanlar

- Tam paketteki üç denetim satırı (yukarıda): tek başına tekrarlanmıyor, oyuncu dosyalarıyla bağı bulunamadı; ilgili
  bölüm/şehir sahipleri yük altında (4 süreç) bakmalı.

- **Nefes sesi**: kitaplıkta nefes/soluma efekti yok; yeni ses üretilmedi. Var olan `D_CLIMB_TIRED_*` repliği nefes
  tükenince çalıyor. Bir nefes efekti (kısa, 3–4 varyasyon) eklenirse `HareketHis.nefes()` buna bağlanabilir.
- Dönüş yatışı ve tırmanma titremesi karede zayıf okunuyor (bilerek yumuşak); oyunda hissedilir mi, oyun sahibinin
  denemesi gerek.
- İniş tozu birinci şahısta çoğu zaman kadraj dışında (ayağın dibinde).
- Sol el havada açılıyor; sağ elde eşya yoksa (kumanda cepte) yalnız sol kol görünüyor.
- `climb_anim.gd` (oyuncu tırmanma pozu) değiştirilmedi: gerek görülmedi.

## run_tests.sh isteği

`tests/run_tests.sh` `run()` süzgecine `HAREKETAUDIT` eklensin ve hata sayılsın:
`grep -E "AUTOTEST|…|JOURNEY|HAREKETAUDIT"` ve `echo "$out" | grep -q "^HAREKETAUDIT " && fail=1`. O zamana dek
denetim satırları otomatik testte `user://hareketaudit.log`'a da yazılıyor.

## Başka dosyaya istek

- `scripts/autoload/game_state.gd` `settings` varsayılanlarına `"hareket_kamera": true` (yeni ayar şimdilik
  `HareketHis.acik()` içinde kayıtlı ayar dosyasından tembelce okunuyor; varsayılanlarda olunca `_load_settings`
  kendisi okur).
- `i18n/strings.*.translation` yeni `UI_SET_MOVE_CAM` anahtarı için yeniden üretilmeli (yönetici; kayda eklenmedi).
- Yeni `class_name HareketHis`: temiz klonda bir kez `--import` (global sınıf önbelleği) gerekiyor; `run_tests.sh`
  zaten yapıyor. `.uid` yan dosyası kayda eklenmedi.
