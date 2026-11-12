# Düzeltme turu P6 (kara surları: 20, 22, 22o, 26o, 36b, 37o) — GELİŞTİRİCİ raporu

Dal: `wip/duzeltme-p6` (taban: `ef860ea2`, yani denetçinin "küçük düzeltmelerle kabul" dediği durum). Godot 4.4.1, 4 çekirdek, makine
yüklüyken (ekranlı koşular llvmpipe ile çok yavaş).

**Kare düzenleri.** ÖNCE = taban `ef860ea2` (bu turun başı, `/tmp/once`). SONRA = bu dalın ucu. RINFO için ek olarak denetçinin
düzeni: yayındaki `e551de84` (yedi P6 dosyası oradan: `land_walls`, `wall_fight`, `chapter20/22o/26o/36b/37o`; `/tmp/orig`).
Ekranlı koşular `PACE` olmadan (kare hızı çok düşük olduğu için PACE gerçek hızda 40 dakikayı aşıyordu); replik anına hizalama,
`--dialogshots` karelerinin dosya zamanından ve RINFO satırlarının duvar saatinden yapıldı (`D37O_T_03` vb. anahtar adlı kareler
= aynı replik anı). Replik/süre/sayaç/sonuç/kalabalık sayısı/bot yolu: değişmedi (bkz. "Kurallara uygunluk").

## Madde tablosu

| # | Madde | Durum | Ne yapıldı (dosya:işlev) | Kanıt |
|---|---|---|---|---|
| 1 | 37o RINFO | **KISMEN (kural ≤ +%8 sağlandı, çizim artmadı; hedef ≤ +%5 ilk dört örnekte +%5,6 ile 0,6 puan aşıldı)** | Üç azap zaten gölgesizdi (önceki tur). Bu turda: azaplar kameradan uzaklaştı (aşağıda), böylece kadrajda kapladıkları pay %25 → %9,5. İki deneme **geri alındı**: (a) uzaktaki iki azabın dış çizgisini sökmek (`Props.strip_outlines` Soldier gövdesini beyaza boyuyordu, sonda karesinde görüldü); (b) özgündeki `squad[3..5]`'i barikat evresinde gizlemek (çizimi ~3 puan düşürüyordu ama `lose` koşularında `VISAUDIT overlap` sıklaştı: gizli 5/86, açık 1/82; gerçek neden aşağıda). Ölçülen yük kalemi: bir azabın ağı 19–21 bin üçgen, üçü ≈ +%1,5. | aşağıdaki RINFO tablosu |
| 2 | 37o azap yerleşimi | **DÜZELDİ** (ölçüm); gözle yan kare KISMEN | `chapter37o.gd:_haul_spots` yeniden yazıldı: kameraya en az `HAUL_MIN_DIST` = 2,4 m (`zt = min(basamak z, oyuncu z − 2,4 − 0,9·k)`), yanlama 0,38/−0,36/0,30 (ip kalçanın yanından, iki el ipte, kol yana açılmaz); `_floor_y` artık beş noktalı ayak izinden (±0,18 yan, ±0,22 ön-arka) örnekleniyor, düz yer bulunana dek yüke doğru 0,12 m adımlarla (≤1,08 m) kaydırılıyor, y = beş örneğin ortalaması. Bölük azaplarının (`squad[3..5]`) durağı z 24 → 25 (düellocunun oyuncu ardındaki saldırı yeri z 24'tü; üstlerine biniyordu) | aşağıda ölçüm; `p01`, `p02` |
| 3 | 26o açılışta elde eşya | **DÜZELDİ** | `chapter26o.gd:_ready`: `player.hands_free = true` (bölümde eller merdiven, taş, tüfek, kova işinde; 20/22o/36b/37o ile aynı) | `p04` (ÖNCE: "Elde: Leblebi", avuçta kutu; SONRA: "Elde: boş", eller rahat) |
| 4 | Görünmeyen ayrıntı (sedye/kova/kırık merdiven) | **KISMEN** | `land_walls.gd:_wear_props`: sabit liste 5 → 17 öğe; yeni 12 öğe 20, 22o, 26o, 36b'nin açılış bakışının 3–7 m önünde, yürüme çizgisinin 2–4 m yanında (yerde yassı, çarpışmasız, `no_walk`; yürüme yolunu kapatmaz, `WALKTHRU` yok); `p.y` artık zemin yüksekliğinden (`gy`) | `p04`, `p06`, `p08`, `p09` |
| 5a | 36b kazıcı aletleri | **DÜZELDİ** | `chapter36b.gd`: ortadaki iki kazıcı (i=2,3) oyuncunun yoluna `DIG_FWD_Z = 44,8`'e, ötekiler `DIG_Z = 51`'e çekildi (özgünde 54,6; oyuncu 40'ta dururken 14,6 m → 4–5 m / 11 m); önlerine koyu çukur şeridi; çarpışmada rakiplerin çıkış noktası özgün yerinde (`spawn_z` meta, 56,1) | `p06`: D36_G_GO karesinde kürek elde, 4–5 m'den okunuyor |
| 5b | 37o ıska kancası | **DÜZELDİ** (ek kusur bulundu ve düzeltildi) | Sonda karesinde ıska ipi elden kameranın içinden çıkan **damalı düz şerit** idi; `_throw_hook` ıska dalı artık yakın parçayı kameraya bağlı kenevir tüp (`_haul_near`, elin 1 m önü), uzak parçayı ondan kancaya çiziyor (`_haul_miss`, `_haul_anchor`, `_haul_tick`) | `p02` (sonda_, geçici sonda sökülü) |
| 6 | 37o `lose` botu | **DÜZELDİ** | `chapter37o.gd:_stockade`: `randf() < 0.5` → `_lose_strokes % 4 == 0` (yalnız `autotest and lose`) | son ağaçta 60/60 PASS (önceki ağaçlarda 40/40 ve 40/40) |
| 7 | 26o `lose` yağ yarışı | **DÜZELDİ** | `oil_hazard.gd:_process`: `_live = pour(...) > 0.0 or float(cauldron["t"]) >= 0.0` | 40/40 PASS |
| 8 | `ARMAUDIT unarmed` | **KANITSIZ + ORTAK DOSYA ÖNERİSİ** | aşağıda | aşağıda |

## RINFO (37o, 20, 22o) — medyan, evre içi örnekler; ÖNCE → SONRA

Ham koşular: `/tmp/run/orig37o` (e551de84), `once37o_c` (taban), `sonra37o_d` (son hâl, squad açık); 20: `orig20`/`sonra20`; 22o: `orig22o`/`sonra22o`.
Örnekler 2 sn'de bir; evre içi örnek sayısı koşular arasında değişiyor (kare hızı), bu yüzden **evre medyanı ±%5–10 oynuyor**
(aynı kodla iki ardışık koşu arasında T_03'te çizim +%3,6…+%12 oynadı; 22o'da tabanla son hâl arasında `H_GUN` +%9,3 çıktı, arada yalnız 12 yassı yer parçası farkı var).

37o, **yayındaki e551de84'e göre** (denetçinin düzeni); son hâl `sonra37o_d`:

| Replik anı | örnek | çizim | üçgen (toplam) |
|---|---|---|---|
| D37O_T_03 bütün evre | 19/34 | **−%14,4** | **−%2,5** |
| D37O_T_03 ilk dört örnek (ön çekiş) | 4/4 | **−%2,6** | **+%5,6** |
| D37O_AB_02 | 12/11 | −%2,5 | +%3,4 |
| D37O_T_PLANK | 5/5 | −%4,0 | −%1,2 |
| D37O_AZ_01 | 10/10 | +%0,8 | +%0,4 |

Önceki ara sürüm (`sonra37o_c`, squad gizli): T_03 bütün evre −%2,3 / +%4,9; ilk dört −%3,2 / +%4,6 — yani yöntem değişince üçgen ilk dört örnekte +%4,6 → +%5,6 oynadı
(hedef ≤ +%5'i **0,6 puan aşıyor**, kural sınırı ≤ +%8'in altında; çizim hiçbir ölçümde artmadı).
37o, **tabana (ef860ea2) göre** T_03: ilk dört örnek çizim −%2,4, üçgen +%1,2; bütün evre −%2,0 / −%3,9. T_03 anında aynı hizalı ilk dört örnek (çizim, üçgen k):
e551de84 (4157, 3771) (4268, 3791) (5114, 3946) (5199, 4050); taban (5133, 4046) (4371, 3930) (4418, 4031) (4946, 4140);
SONRA (4497, 4048) (4641, 4122) (4501, 3911) (5272, 4167).
(Son kodda bölük azaplarının z 24 → 25 kaydırılması ayrıca ekranlı ölçülmedi: 3 gizli olmayan soldier aynı sayıda, yalnız 1 m geride.)
Bir azabın ağı 19–21 bin üçgen (sonda): üçü ≈ +%1,5; yani +%5,6'nın çoğu azaplardan değil, tabanda zaten var olan (+%4,4) fark ve örnek gürültüsü.

20 (e551de84 → SONRA): D20_G_ASSAULT (26 örnek) çizim −%1,7, üçgen +%0,8; G_01 −%1,9/+%0,9; G_03 −%1,9/+%0,7; G_DUEL −%5,4/−%3,0 → hepsi ≤ +%8, çizim artmıyor.
22o (e551de84 → SONRA): H_02 −%2,5/+%2,1; H_DUEL −%4,5/−%8,5; T_FIRE +%2,1/−%1,6; H_ALL +%4,8/+%2,5;
**H_GUN: çizim −%5,9, üçgen +%10,6 (bütün evre)** — ilk dört örnekte −%13,7/+%2,0; taban→SONRA aynı evre +%9,3 (yani bu fark P6'dan değil,
nişan alma evresindeki duman/parçacık ve kamera zamanlaması; bu turun 22o'daki tek değişikliği 12 yassı yer parçası). Bunu "gürültü" olarak
yazıyorum, **KANITSIZ (sınırı aşıyor görünüyor)**; aynı hizalı üç örnekle ayrıştıramadım.

## 37o azap yerleşimi — ölçüm (geçici sonda, sökülü)

Bot koşusunda her karede (yürümeyenler): en yakın uzaklık / kadrajın kapladığı en büyük pay (5×3 noktalı çerçeve, görüntü alanına göre):

| | k=0 (kırmızı, önde) | k=1 | k=2 |
|---|---|---|---|
| ÖNCE (taban) | 1,96 m / **%25,0** | 3,83 m / %6,2 | 4,72 m / %3,5 |
| SONRA | **2,90 m / %9,5** | 3,84 m / %6,2 | 4,69 m / %3,6 |

Ayak izi: kaydırma sonrası yayılma (en yüksek−en alçak ayak izi örneği) 24 yerleşimin 22'sinde 0,00 m, ikisinde 0,20 m
(oyuncu 1,3–1,9 m yana kaçıp düz yer bulunamayınca); y'ler 0,28 / 0,78 / 1,28 (üç ayrı basamak). Gerçek oyuncu azaplara yürürse
(0,6 m'den az oynayınca azaplar yer değiştirmez) uzaklık en kötü 2,4−0,6 = 1,8 m'ye iner; bunu kareyle denemedim.
Gözle arkadan/yandan kare: sonda (geçici kamera) karelerinde üç azap ayrı basamakta, ip iki yumruktan geçiyor; ayakların basamakta
olduğunu 1280 px'te kesin okuyamadım (KISMEN); sayısal ölçüm yukarıda. Öndeki azabın kolunun yana açılması: yanlama 0,62 → 0,38
yapıldı, 640 px oynanış karelerinde kol ayrıntısı seçilmiyor, bir sonda karesi (arkadan) iki elin ipte olduğunu gösteriyor (KISMEN).

## Test sayıları (final ağaç)

- parse_check: `PARSECHECK PASS scripts=248`.
- Başsız (`--max-fps 20`): 20 (`""`, tape, late, hit, lose, niko_idle, idle, difficulty=0, difficulty=2: 9/9 PASS), 22 (7/7), 22o (6/6), 26o (5/5), 36b (2/2),
  37o (`""`, lose, trespass: 3/3), komşular 26, 0, 21 (6/6), 28o (4/4): hepsi `AUTOTEST PASS`. `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`,
  `VISAUDIT`, `WARN_VOID_TELEPORT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `LOOKAUDIT backturn`, `JOURNEY_*`: **yok** (yalnız bilgi satırı `LOOKAUDIT raw`, e551de84'te de var). Ham: `testler.txt`.
- **37o `lose` ×60: 60/60 PASS; 26o `lose` ×40: 40/40 PASS** (son ağaç; 37o'da `VISAUDIT`/`ARMAUDIT` satırı 0). Önceki ara ağaçlarda da 37o `lose` 40/40 + 40/40 PASS idi.
- **`VISAUDIT overlap` (37o `lose`, bu turda yeni görülen, tabanda da olası):** `a=Duelist(SPK_GENOESE) b=Soldier at=(0..1.6, −2.1, 24)`. Geçici sondayla
  (`OVLPROBE`) neden bulundu: Cenevizli düellocu oyuncunun (z 22,6) 1,4 m ardındaki saldırı yerine, yani bölük azaplarının (`squad[3..5]`) durduğu z 24 hattına
  yürüyüp üstlerinde ≥1 sn duruyor. Oranlar (`lose`): taban 0/40; ara ağaçlar 1/40, 2/17, 2/29 (+gizli squad), 1/12, 0/30; yani birkaç %'lik rastgele olay (taban örneği
  küçük). Düzeltme (`chapter37o.gd:_stockade`): squad durağı z 24 → 25 (x aynı). Sonrası: **0/60**. Yer değişikliği 1 m, yalnız oyuncu ardında duran, `lose`'da dövüşe
  kalkmayan bölük azapları; çıkışta rally eden azaplar 1 m daha geriden kalkıyor.

## Madde 8 — `ARMAUDIT unarmed` (37o/26o `lose`)

Kök neden **yakalanamadı**. `melee.gd`'e ayrıntı yazdıran geçici sondayla 26o `lose` 140 koşuda (üç ardışık döngü) bir kez bile çıkmadı; sondasız, düzeltmeli ağaçta
40 koşuda 1 kez çıktı (denetçi tabanda 37o/26o'da toplam 4+2 görmüştü): `foe_dist=11.9 duel_active=false`. Kod okumasından hipotez (**KANITSIZ**): yenilgide `WaveRunner.run` düellocuları geri çekiyor
(`withdraw`, `withdrawn` meta) ve kılıcı kınına koyuyor (`duel.stop`), oyuncu kalkıp `await_withdrawn` beklerken `Melee.rally` ile çağrılmış ama
henüz düelloya girmemiş (`pending_foes`) rakip 12 m eşiğine girince `Melee._arm_audit` ateşleniyor (kılıç yok, `withdrawn` işaretsiz, düello etkin değil).
Bölümlerin kendi dosyalarında düzeltilecek bir şey bulamadım; 37o'da deterministik botla 140'tan fazla `lose` koşusunda hiç çıkmadı.
**ORTAK DOSYA ÖNERİSİ** (uygulanmadı), `scripts/combat/wave_runner.gd`, `run()` içinde `if st["lost"]: player.down()` ardından:
```gdscript
if st["lost"]:
    player.down()
    melee.stand_down()        # yenilgide henüz düelloya girmemiş (rally/pending) rakipler de geri çekilsin: ARMAUDIT penceresi kapanır
```
(`stand_down` sonradan zaten çağrılıyor; yalnız `await_withdrawn` beklemesinden önce çalıştırılması öneriliyor; doğrulanmadı.)

## Kurallara uygunluk

- Replik anahtarı/sırası, süreler, sayaçlar, sonuç koşulları, kalabalık sayısı, bot yolu (yalnız `lose` botunda vuruş bozma kuralı): değişmedi.
  Yeni `class_name` dosyası yok; denetim susturma yok. 36b'de tek oynanış etkisi: iki kazıcı ve çukur şeridi yer değiştirdi (rakiplerin çıkış noktası aynı).
- `oil_hazard.gd` görünür davranış değişikliği: kazan o anda **ambiyans dökümüyle** (`chapter26.gd:_pour_loop`, hedef kazanın x±1 m'si, z 18) dökülürken de
  oyuncunun merdivenindeki yağ şeridi canlı sayılıyor. Eskiden bu pencerede (≈2,95 sn) OilHazard'ın dökümü reddediliyor, ama ekranda ambiyans dökümünün
  yağı akıyordu: oyuncu yağın altında merdivende durup yanmıyordu (test de bu yüzden düşüyordu). Şimdi aynı ±3 sn'de merdivende duran oyuncu, akan yağ
  görünürken yanar (hasar 35, aynı süre ve eşikler). Merdivende yağdan kaçma (yana kayma) kuralı aynı.
- Kanca/sonda/etiket: 37o `SONDA_*`, `TRIPROBE`, `VISPROBE`, `HAULMETRIC`, `SPOTPROBE`, 26o `ARMPROBE` ve `POSPROBE` yalnız `/tmp/probe` ve `/tmp/once` kopyalarında
  vardı; `grep -rn "SONDA\|PROBE\|HAULMETRIC" scripts tests tools` depoda **boş**.
- Yan etkiler: `land_walls.gd` yalnız `_wear_props`; yeni ayrıntılar baked tek ağda (ek çizim yok).
- Depoya girmeyenler: `--import` ürünü `.import`/`.translation`/`.uid` dosyaları KAYDEDİLMEDİ.

## Açık / bakılamayan

- 20'de sedye ve kırık merdiven açılış karelerinde Giustiniani'nin arkasında kalıyor; yalnız kova seçiliyor (KISMEN). 26o'da kova ve merdiven seçiliyor,
  sedye altyazı kutusunun arkasında/yan kadrajda (KISMEN). 22o'da sedye ve kova seçiliyor. 36b'de kova seçiliyor.
- Oyuncunun azaplara yürüyerek 1,8 m'ye girmesi, 37o'da gerçek oyuncu elle yürüyüşü: karelenmedi.
- 22o `D22O_H_GUN` evresinde üçgen +%10,6 (e551de84'e göre); nedeni kanıtlanamadı (yukarıda).
- Kareler 640×360 (oyunun `--dialogshots` çıktısı), pafta için yakın kırpımlar 2× büyütülmüş.

## Paftalar (docs/_kanit_dp6)

`p01_37o_azap_yerlesimi.jpg` (ÖNCE|SONRA, T_03 ve çekiş), `p02_37o_sonda_iska_ip.jpg` (sonda_ karesi), `p04_26o_el_ve_yer_ayrintilari.jpg`,
`p06_36b_kazici_aletleri.jpg`, `p08_20_acilis.jpg`, `p09_22o_acilis.jpg`.
