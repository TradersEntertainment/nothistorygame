# TAŞIMA 11 — HALİÇ VE DENİZ SURLARI: 4b, 17, 18b, 38o (+ 19, 19o, 29, 29o fon) yeni surda — rapor

Dal `wip/ist2-tasima11`, taban `wip/ist2-taban18` = **bb334de7**. ESKİ = aynı kod `--eskisur` ile (geri dönüş anahtarı:
eski set satır satır eski kod yolundan kurulur), YENİ = anahtarsız. Kareler xvfb + Mesa llvmpipe (yazılımsal GL),
1280×720 jpg 85, hepsine TAM BOY bakıldı (`tests/_ist/tasima11_kare.tscn`: bölümü boot gibi yükler, kurulumdan sonra ağacı
dondurur, HUD'u gizler, verilen kameralardan çeker; her karede çizim çağrısı / ilkel). Ekransız testler `--max-fps 20`, tam
süzgeç; 4 süreç aynı anda; testler çalışma ağacının bir eşinden (`~/is/kopya`) koşar (düzenleme sürerken koşu bozulmasın).

Klasörler: `kare/<bölüm>/eski|yeni/` (tam boy), `kare/sahip_*.jpg` (sahibine gösterilecek 4 kare), `testler/bolum/`
(süzülmüş koşu çıktıları), `testler/kare_*.txt` (kare bütçeleri), `testler/halic_sonda_*.txt` (şehir Haliç dilimi
çarpışma dökümü), `dokum.md` (madde 1).

## Özet

| # | Madde | Durum | Kısa |
|---|---|---|---|
| 1 | ÖLÇ VE DÖK | **TAMAM** | `dokum.md`: sekiz bölümün bağları, çarpışma kutuları, merdiven/çıkış noktaları, v2 karşılıkları; danışmanın iki ölçüsü düzeltildi (SeaWalls x 12 geçidinin gerçek açıklığı 3,0 m — lento kutusu 3,7'de; 18b "11 × 3 m" köprüdür) |
| 2 | Ortak kalem `deniz_set.gd` | **TAMAM** | gövde, korkuluk, diş, konsol/bingi, kule (geçit, teras ağzı), rıhtım, deniz kapısı, uzak katman; SeaWalls, 18b, 38o, Horn, HornWorld ve şehir AYNI işlevleri çağırır |
| 2 | Şehir `IstHalicSur` | **TAMAM** (bütçe **KISMEN**) | yeni kalem; çarpışma dökümü eski = yeni (661 şekil, aynı karma); dönüş değerleri aynı; şehir karesinde bütçe ölçülmedi (dilim başına yakın katmanda +5,7 bin üçgen) |
| 2b | Komşu devam (Horn, HornWorld ≤ 250 m) | **TAMAM** | `Horn._sea_wall` tek haritada baştan sona, `HornWorld._wall_run` keep'e ≤ 250 m parçalar yeni kalemin uzak katmanı; 250 m ötesi eski (görev sınırı) |
| 3 | SeaWalls: 4b | **TAMAM** | yeni görünüş + `--eskisur`; çarpışma aynı; 7 ESKİ\|YENİ kare (3 yakın) + dikiş |
| 3 | SeaWalls: 17 | **TAMAM** | `in_world`; kareler + iki dikiş (dikiş geometrisi eskisi gibi kopuk: "hâlâ kötü" 2) |
| 3 | SeaWalls: 19, 19o, 29, 29o (fon) | **TAMAM** | dönüş sahnesi (8 m), kayıktan, gündüz savaştan uzak (≈ 125 m) kareler |
| 4 | 18b | **TAMAM** | kesim + bingiler + top mazgalı; dış yüz 62,00; çatlak işaretleri açıkta |
| 5 | 38o | **TAMAM** | dış yüz 60,00; merdiven ağzı dişsiz/eşiksiz; `MerdivenCikis` çıkışı (−6; 9,70; 60,60); eşik ve diş sondası yolda, tutunma 0 |
| — | Bütçe | **TAMAM** | bölüm karelerinin hepsinde ilkel ≤ +%4,2, çizim çağrısı 27 karenin 26'sında azaldı |
| — | Testler | **TAMAM** | son kodla 156 koşu: 156 PASS, bitmeyen 0, sorun satırı 0 (4 süreç aynı anda) |
| — | Sözleşme | **AYNI** | `SURSOZLESME PASS kalem=13 kesim=8` · `SUROYUN nokta=519 havada=0 gomuk=0 katida=0` · `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` · `ESYATEST PASS` · `T8DTEKME PASS` · `PARSECHECK PASS` |

## Dosyalar (eski → yeni)
| dosya | değişiklik |
|---|---|
| `scripts/world/ist/deniz_set.gd` (yeni) | ortak deniz suru kalemi (aşağıda) |
| `scripts/level/sea_walls.gd` | `bolum`, `eski_zorla`, `eski`; yeni kipte kutular gizli + meta, görünüş `_yeni_sur` / `_yeni_kapi` / `_yeni_devam` (4b); eski kip satır satır eskisi (`_eski_kapi_cerceve`, `_kapi_kanatlar` yalnız bölündü) |
| `scripts/chapter4.gd`, `17`, `19` (×2), `19o`, `29`, `29o` | yalnız `walls.bolum = "…"` (add_child'dan önce) |
| `scripts/chapter18b.gd` | sur satır arası: kutular aynı; yeni kipte eski diş kutuları kurulmaz, `_yeni_sur` |
| `scripts/chapter38o.gd` | `_build_wall`: kutular aynı; yeni kipte `_yeni_sur` + kanat kuşakları; `MerdivenCikis` + `_merdiven` (iki merdiven kurulumu); `T11CIKIS` satırı ve `=esik_dur`/`=dis_dur` sondası (yalnız autotest) |
| `scripts/level/horn.gd` | yalnız `_sea_wall` (tek haritada `_sea_wall_yeni`'ye geçer; yardımcı `gl_of`) |
| `scripts/world/horn_world.gd` | yalnız `_wall_run` (≤ 250 m parçalar `deniz_set.uzak_parca/uzak_kule`, sonunda tek ağ) + yardımcılar `_deniz_yakin`, `_deniz_kur`; `_horn_walls`, `_marmara_walls`, `_wall_top`, `_chain`, `_horn_shore` DEĞİŞMEDİ |
| `scripts/world/ist/halic_sur.gd` | `build` yakın/orta katman: kutular aynı (`_g` ile gizlenir), görünüş `_yeni_gorunus`; `dims/tower_xs/perches/climbs` aynı. `halic.gd` değişmedi |
| `tests/_ist/tasima11_kare.*`, `tasima11_halic_kare.*`, `tasima11_halic_sonda.*` (yeni) | bölüm kare aracı (bütçe), şehir dilimi karesi, şehir dilimi çarpışma sondası |

## Ortak kalem — `scripts/world/ist/deniz_set.gd` (yeni)

Deniz suru dilimi görünüş kalemi (çarpışmasız); çağıranlar: `SeaWalls` (4b, 17, 19, 19o, 29, 29o), `chapter18b`,
`chapter38o`, `Horn._sea_wall` (18, 18b, 38o devamı), `HornWorld._wall_run` (bölüm kesimine ≤ 250 m), `IstHalicSur.build`
(şehir). Hepsi AYNI işlevleri çağırır; taş sur_doku tur 1 (deniz: kaba gri, moloz yaması, hatıl 3,4 m'de bir, dipte yosun).

| işlev | ne çizer |
|---|---|
| `govde(n, x0, x1, g, acik)` | su altına inen temel (dip), su çizgisinde 0,3 m çıkıntılı yosunlu kaide (pahlı üst; rıhtım varsa rıhtım üstünün altında kalır), düz gövde; taş taş ton (onarım yaması, köşe rengi); kapı açıklıklarında söve iç yüzü, tavan, eşik |
| `korkuluk(n, x0, x1, g, kes)` | sur yolunun deniz kenarında ince taş örgü korkuluk (köşe alfası 0,9; TUR-11); `kes` aralıkları açık (merdiven/top mazgalı) |
| `disler(n, xs, en, boy, g, tohum)` + `dis_dizisi` | `KULE.disler_ag` dişleri (örülmüş gövde, eşek sırtı harpuşta, 2 cm saçak; TUR-11/12/13); diş yerleri bölümün eski dizisi |
| `konsol(n, x0, x1, g, xs)` | sur yolu gövdeden denize taşıyorsa (18b 2,5 m, 38o 0,4 m): yol taşının ön/alt yüzü, dört kademeli taş bingi (diş hizasında) |
| `kule(n, k, g)` | pahlı kare plan (pah 0: ayak izi oyuncunun yürüdüğü yerde), su altına inen kaide, isteğe bağlı şev, silme, ok yarıkları, üç kademe konsol, mazgallı teras (`KULE._disler`); `gecit` (sur yolu koridoru), `teras_kapi` (kule merdiveninin teras ağzı) |
| `rihtim(...)` | kesme taş ön yüz, üstte ince örgülü kenar taşı sırası (0,4 m), döşeme (tam üst y), yosunlu dip |
| `kapi_kemer(...)` | mermer söve ve lento, dönüşümlü tuğla/taş boşaltma kemeri, kör timpan, isteğe bağlı mermer kitabe |
| `uzak_parca`, `uzak_kule` | komşu devamın uzak katmanı (tek ağ): kaideli gövde, korkuluk, kademeli diş; pahlı kule, silme, teras dişleri |
| `gizle(body, zemin)` | eski kutunun ağını gizler, gövde `wall` (`ground`) metası taşır (TAŞIMA-9 "sonraki taşıyana" 4) |
| `bitir(kok, ad)` | `sur_doku.uygula(kok, 1)` + `blak_set.birlestir` (malzeme × 32 m hücre) |
| `sahne_bolumu(n)`, `eski_mi(bolum)` | ortak kurucular (Horn, HornWorld) `--eskisur` seçimini sahnenin bölüm adından alır |

`sur_set*.gd`'ye ekleme YOK; `blak_set.gd`, `sur_kule.gd`, `sur_doku.gd` yalnız ÇAĞRILDI (değişmedi).

## Bölüm 4 (4b) — SeaWalls, `in_world` YOK

**Bağlar (eski → yeni):** bütün çarpışma kutuları aynı (dokum.md §2): rıhtım (x −5…20, z −3,2…0, üst 0,7), gövde iki parça +
x 12 lentosu + eşik, dört kule kutusu (x −22, −6, 30, 58; ön yüz −1,15), meşale direkleri; yeni kipte kutuların ağı gizli,
gövde `wall`/`ground` metası. Zincir kütükleri ve bağlama babası DEĞİŞMEDİ (`_build_chain` aynı; `CHAIN_START→END` denge yolu
aynı). Niko (4,8; 11,7; −3,45) dişlerin önündeki 0,55 m'lik kenarda; yeni korkuluk dişlerle aynı hatta (z −4,35…−3,75):
Niko gömülmez. Kapı x 17: kanatlar, tokmaklar, karanlık geçit, fenerler, meşale, `interactable` aynı yerde; süs yeni kalem
(mermer söve + lento kanatların üstünde = eski kemer başlangıcı 2,7; boşaltma kemeri, kemer içinde mozaik haç: yarım disk,
kutu değil; kitabe; eşik taşı eskisinin ölçüsünde). x 12 geçidi: söve iç yüzleri, tavan (lento kutusunun altı 3,7), eşik;
deniz yüzünde lento + boşaltma kemeri. Devam (±420 m): yeni kalem, kuleler eski rng dizisiyle aynı yer/boy, diş dizisi yakın
kesitin fazında (x = −60 + 1,6 k), nöbetçiler korkuluğun ardında (z −4,8; kulelerin içinde değil).

**Kareler** (`kare/4/eski|yeni/`; gece, ay ışığı; sol eski sağ yeni aynı kamera):
- **a1 zincirden** (oyuncunun denge yolundan sura): taş örgü gövde, su çizgisinde yosunlu kaide, harpuştalı dişler, pahlı
  silmeli kuleler; ESKİ'nin kırmızı şeritli kutu kuleleri ve küp dişleri yok — kutu yok, havada yok (kuleler suya iner; eskide
  x −22/30/58 kuleleri suyun 0,7 m üstünde başlıyordu), aynı ressam (Mesoteikhion taşı, deniz tonu), eskisinden sönük değil.
- **a2 rıhtım yakın (1,5–3 m)**: sur yüzü blok blok ton, seyrek tuğla hatıl, akıntı izi; rıhtım döşemesi tam 0,7'de — kutu yok,
  havada yok; rıhtım döşemesi kiremit-kahveye çalıyor (ortak gölgelendiricinin yatay yüzü, "hâlâ kötü" 3).
- **a3 kapıya yüz yüze (2,6 m; fes kararı)**: mermer söve ve lento, ardında taş örgü; kanatlar eskisinin aynısı — kutu
  çerçeve yok, havada yok; mozaik haç üstte kadrajın dışında (a6).
- **a4 x −3 kule yanağı (1,5 m)**: x −6 kulesinin doğu yüzü sur yüzüyle birleşir, tuğla hatıl kesintisiz; pahsız (ayak izi =
  kutu) — kutu değil (taş örgü), havada yok, yakından koyu (gece).
- **a5 Niko**: Niko kenarda, korkuluk ve dişler ardında — gömülmüyor.
- **a6 kapı genel (6 m)**: iki kapı yan yana: x 12 geçidi (lento + kemer, söve iç yüzü) ve x 17 (mozaik haç, kitabe) —
  tek dil; mozaik altın sönük (doygun sarı değil).
- **d1 dikiş x 80** (yakın kesit + devam aynı kadrajda): gövde, korkuluk ve dişler x 80'de kesintisiz.

## Bölüm 18b — Haliç suru kesimi (satır arası sur) + `Horn._sea_wall` devamı

**Bağlar:** gövde (z 62–65, dış yüz 62,00), yol taşı (z 59,5–63,5, y 9,32–9,62), görünmez korkuluk (`no_climb`, z 59,6),
kuleler (x ±17) AYNI kutular (gizli + meta); eski diş kutuları yeni kipte kurulmaz (zaten çarpışmasızdı). Yeni görünüş:
gövde (su altına 3 m), konsol (yol taşının ön/alt yüzü + diş hizasında 4 kademeli bingi; topun altındaki bölmede bingi yok:
bingiler x −1,5 ve 1,0'da, çatlak işaretleri x −0,85…0,35, z 61,65 açıkta), korkuluk (z 59,5–60,0; görünmez korkulukla aynı
hat), dişler (x −19 + 2,5 k, kulelerin içine düşenler yok), topun mazgalında (x −0,9…0,4) korkuluk açık (namlu ve kundak
korkuluğa girmiyor), kuleler. `SECTIONS 11 / SEC_LEN 3` (köprü) dokunulmadı. Devam: `Horn._sea_wall` tek haritada (E 220 ≤
250) baştan sona yeni kalem: aynı rng dizisi (kule yeri/boyu, sancak), dişler eski dizide (a + 1 + 2,5 k), sancak kumaş
(`kumas.bayrak`; eskisi kutu levha), nöbetçiler korkuluğun ardında (kulelerin içinde değil).

**Kareler** (`kare/18b/`; gündüz):
- **c1 diş yakın (oyuncu yolda, dişe 1,5 m)**: harpuştalı diş, korkuluk taş örgü, yol döşemesi — kutu yok, havada yok, aynı
  ressam; harpuşta gölgede koyu yeşilimsi (ortak `disler_ag`, "hâlâ kötü" 1).
- **c2 döşeme yakın**: yol döşemesi (sur_doku yatay) ve korkuluk — kutu yok, havada yok.
- **c3 köprüden**: kesim + iki kule + devam tek ressam; konsol altı bingilerle dolu — kutu yok, havada yok (gövde ve kuleler
  suya iner); arkadaki pembe kutu ev şehir dünyasının (kapsam dışı).
- **c4 bingi alttan (sudan sura)**: dört kademeli bingiler, ortadaki top mazgalı — kutu yok (kademeli taş), havada yok.
- **c5 top mazgalı**: korkuluk mazgalda açık, iki yanda dişler; namlu boşlukta.
- **d1 dikiş x 20** (kesim + Horn devamı + uzakta HornWorld): kesintisiz; ±20'deki geçiş x ±17 kulesinin ardında.

## Bölüm 38o — Haliç suru, merdiven, deniz kapısı, rıhtım

**Bağlar:** gövde (z 60–64, dış yüz 60,00; kapı x 13,4…16,6), lento kutusu (y 5,4…9,6), eşik (üst 1,18), görünmez kapı engeli
(z 60,1), yol taşı (z 59,6–63,98), kuleler (x ±21), rıhtım (x 6…24, z 57,4…60,2, üst 1,2), babalar, kazan (−6,6; 9,6; 60,7),
savunucu yerleri, kanatlar (z 59,75; açılış tween'i aynı) AYNI. Diş adımı ve fazı aynı (−22,5 + 2,5 k), dişler çarpışmasız
(eskisi gibi). Yeni görünüş: gövde (kapı açıklığı: söve iç yüzü, tavan, eşik), konsol (0,4 m: bingiler), korkuluk + dişler,
kuleler, rıhtım taşı, kapı (mermer söve + lento + boşaltma kemeri; kanatlara demir kuşak ve çivi: SeaWalls kapısının dili).

**Merdiven eşik tuzağı (TAŞIMA-8D isteği 4):** merdiven ağzı x −6 ± 0,65 **dişsiz ve eşiksiz** (diş x −5,0 kurulmaz;
korkuluk −6,9…−5,1 açık; kalın korkuluk/eşik YOK → 26o'daki sonsuz döngü doğmaz); kazanın önü aynı açıklıkta (yağ merdiven
ayağına dökülür). Bölüm içinde `MerdivenCikis extends Ladder` (26o'daki `SurMerdiveni` kalıbı): `top_exit()` =
(ayak.x; **9,70**; **60,60**) — sur yolunun üstü, mazgalın ardında (eski `top_exit` y ≈ 10,2'ye bırakıyordu, oyuncu 0,6 m
düşüyordu). İki merdiven kurulumu da (`_ladder_phase`, `_run_shots`) bu sınıfla; beş çağrı yerinin hepsi aynı noktayı alır:
`player.gd:833` (oyuncu), tayfa aşması (`top_exit() − 0,1` → y 9,60 = yol), 40 sn yedeği (yalnız döngü içinde, koşul
sağlanınca döngü biter: tek sefer; koşularda `yedek=0`), boru dönüşü (`_explore`), kare çekimi.
Sonda: `=esik_dur` (oyuncu mazgal kenarındaki korkuluğun TEPESİNE, (−7,2; 10,17; 59,85)) ve `=dis_dur` (diş tepesine,
(−7,5; 10,82; 59,85)) → 3 sn sonra ikisinde de yolda (y 9,62), merdivene yeniden tutunma 0 (`T11ESIK … yolda=true
tutundu=0`). Bot tırmanışı bütün çeşitlerde çıkış yolun üstünde: `T11CIKIS y=9.62…9.70 z=60.60…60.91` (çıkıştan sonraki ilk adım), `yedek=0` (40 sn yedeği hiç çalışmadı).

**Kareler** (`kare/38o/`; gece):
- **f1 merdiven tepesinden (yola 1–2 m)**: mazgal ağzı açık (diş ve korkuluk yok), yanında harpuştalı diş ve korkuluk, kazan
  açıklıkta, savunucular diş aralarında — kutu yok, havada yok; döşeme kiremit-kahve ("hâlâ kötü" 3).
- **f1b mazgal açıklığından denize**: açıklıkta korkuluk yok, iki yanda korkuluk; ön planda tayfa (kadraj kısmen kapalı).
- **f2 kapıya yakın (2,5 m)**: mermer söve + lento, boşaltma kemeri; kanatlar demir kuşaklı — kutu çerçeve yok, havada yok.
- **f3 sudan genel**: kesim, iki kule, rıhtım, kapı; Horn devamı iki yanda aynı kalem — kutu yok, havada yok (gövde ve kuleler
  suya iner); ESKİ'nin kırmızı şeritli kutu gövdesi ve küp dişleri yok.
- **f4 gemiden sura**: merdivenin dayanacağı kesim, bingiler, diş aralarında savunucular, kazan dumanı.
- **f5 sur yolu yakın**, **f6 rıhtım yakın (1,5 m)**: sur yüzü blok blok, hatıl, rıhtım taşı tam 1,2'de — kutu yok, havada yok.
- **d1 dikiş x 24** (kesim + Horn devamı): ±24'teki 2 m'lik yüz farkı x 21 kulesinin ardında; devam kesintisiz.

## Bölüm 17, 19, 19o, 29, 29o — SeaWalls `in_world` (tek harita) + HornWorld yakın devamı

**Bağlar:** SeaWalls'ın `in_world` dalı yalnız rıhtım + yakın kesiti (x −60…80) kurar; kutular ve bütün bağlar 4b ile aynı
(yukarıda). Ortam/güneş `walls`'ın doğrudan çocukları olarak kaldı (`SeaBattle.make_day/make_dusk`, 17 `_captive_light`,
19o `_make_dawn` aynı düğümleri bulur; yeni görünüş kökü `DenizSetGorunus` ayrı bir çocuk). `walls.lights`, `walls.niko`,
`walls.world`, `gate_leaves`, `open_gate` aynı. 19 SeaWalls'ı iki kez kurar (`:70`, `:525`): ikisine de `bolum = "19"`.
Zincir ve devam `HornWorld`'den: 2b ile bölgenin keep dikdörtgenine ≤ 250 m olan Haliç parçaları yeni kalemin uzak katmanı
(`horn_chain`: Haliç 2 456 + Marmara 1 858 üçgen, tek ağ; `DENIZSET hornworld` satırı).

**Kareler** (`kare/17|19|19o|29|29o/`):
- **17 b1 rıhtım yakın (2 m)**: gövde taş örgü, seyrek hatıl; iki kapı (lento + kemer; mozaik haç) — kutu yok, havada yok, 4b
  ile aynı ressam. Rıhtımın sura yakın şeridini dünyanın gri kıyı arazisi örtüyor (ESKİ'de de aynı: World1453 arazisi rıhtım
  üstüne çıkıyor; "hâlâ kötü" 4).
- **17 b2 sudan genel**: kesim, dört kule, devam aynı kalem — kutu yok, havada yok (kuleler suya iner).
- **17 b3/b4 dikiş x 80 / x −60**: SeaWalls kesimi + HornWorld devamı aynı kadrajda; ESKİ'de devam beyaz kutu gövde + kırmızı
  şerit + kutu kule, YENİ'de deniz suru kalemi (kaideli gövde, korkuluk, diş, pahlı kule). Dikiş geometrisi eskisiyle aynı:
  dünyanın kıyı hattı yerel z −3,2 ile çakışmıyor, kesimin ucunda arazi yamacı başlıyor ve devam yamacın üstünden geçiyor
  ("hâlâ kötü" 4, "başka dosyaya istek" 4).
- **19 g1 dönüş sahnesi (gemiden, sura ≈ 8 m)**: x −6 kulesinin batı yanı, sur yüzü, uzakta kapılar — kutu yok, havada yok.
- **19 g2 sudan genel**, **19 d1 dikiş x −60**: 17 ile aynı.
- **19o h1 kayıktan (≈ 50 m)**: kesim + kuleler + devam tek ressam, gece; **19o d1 dikiş x 80**: devam yamacın üstünde.
- **29 / 29o j1 savaştan (gündüz, ≈ 125 m)**: sur ve kuleler görünüyor (gemilerin ardında), gündüz ışığında kaba gri deniz
  taşı; ESKİ'nin kırmızı şeritli kutu gövdesi gitti — bu uzaklıkta diş ve korkuluk seçiliyor, ayrıntı seçilmiyor.

## Şehir — `IstHalicSur` (96 m'lik Haliç dilimi)

`build` yakın ve orta katmanda: eski K.slab çarpışma kutuları (gövde parçaları, lentolar, iki yüzün korkulukları, kule alt/üst
parçaları + koridor lentosu + teras korkulukları, rıhtım) birebir kurulur ve gizlenir (`wall` metası); görünüş `deniz_set`:
gövde (iki kapı açıklığı), deniz korkuluğu (1,05 m: çarpışmayla aynı) + dişler (eski `K.merlons` dizisi: kesit başı + 0,4,
1,6 m adım), şehir korkuluğu (merdiven ağzı açık), kuleler (pahsız: ayak izi rıhtımda; sur yolu koridoru z ±0,9 × 2,4 m;
teras korkuluğunda kule merdiveninin 2 m'lik ağzı), iki yüzde kapı lentosu + boşaltma kemeri (şehir yüzünde kitabe), rıhtım
taşı. Basamaklar, fıçı/balya yığınları, babalar, rampa, fenerler, sancak aynı. Şehir kurucusu (`_sur_tas`) "ashlar"
yüzeyleri deniz taşı gölgelendiricisine çevirir (tur 1). `dims/tower_xs/perches/climbs` DEĞİŞMEDİ.
**Çarpışma dökümü** (`tests/_ist/tasima11_halic_sonda.tscn`, lod 0/1/2): eski 661 şekil, karma 3854034809 = yeni 661 şekil,
karma 3854034809 (`testler/halic_sonda_*.txt`; dönüş değerleri satırı da aynı).
**Kareler** (`kare/sehir/`, dilim tek başına, gündüz; `tests/_ist/tasima11_halic_kare.tscn`):
- **s1 denizden**: dört kule, iki kapı, rıhtım; ESKİ'nin K.band kırmızı şeritleri ve kutu dişleri yok — kutu yok, havada yok,
  bölüm sahneleriyle aynı ressam.
- **s2 rıhtım yakın (kule köşesi, 2 m)**: taş örgü + tuğla hatıl köşeden döner; rıhtım taşı — kutu yok.
- **s3 sur yolu dişleri yakın**, **s4 kule geçidi**: korkuluk ve harpuştalı dişler, kule koridoru açık (çarpışma koridoruyla
  aynı) — kutu yok; harpuşta gölgede koyu ("hâlâ kötü" 1).
- **s5 kapı şehirden**: lento + kemer + kitabe.
- **s6 kule terası**: teras korkuluğunda merdiven ağzı açık, basamak terasa çıkıyor — ağzın iki ucunda gökyüzü sızan 2–3 cm'lik
  aralık var (kule merdiveni korkuluktan dar; "hâlâ kötü" 6).

## Testler — son doğrulama (son kayıttaki kod; `testler/bolum/S_*.txt`)

Her koşu `--max-fps 20`, 4 süreç aynı anda, ≤ 600 sn zaman aşımı; "sorun satırı" tam süzgeçteki satırlar (SCRIPT ERROR,
VISAUDIT, WALKTHRU, HELDAUDIT, ARMAUDIT, WARN_FX/FLY/VOID, ESYAAUDIT dusme/havada/gomuk/tikama/sinir, HAREKETAUDIT).

| bölüm | çeşit | kip | koşu | PASS | bitmeyen | sorun satırı | süre (sn) |
|---|---|---|---|---|---|---|---|
| 4 | chain | yeni | 2 | 2 | 0 | 0 | 19 · 19 |
| 4 | chain | eski | 1 | 1 | 0 | 0 | 18 |
| 4 | nofez | yeni | 2 | 2 | 0 | 0 | 19 · 18 |
| 4 | nofez | eski | 1 | 1 | 0 | 0 | 18 |
| 4 | fall | yeni | 2 | 2 | 0 | 0 | 11 · 11 |
| 4 | fall | eski | 1 | 1 | 0 | 0 | 11 |
| 4 | "" | yeni | 1 | 1 | 0 | 0 | 11 |
| 4 | caught | yeni | 1 | 1 | 0 | 0 | 11 |
| 4 | fez | yeni | 1 | 1 | 0 | 0 | 12 |
| 4 | item | yeni | 1 | 1 | 0 | 0 | 11 |
| 4 | market | yeni | 1 | 1 | 0 | 0 | 11 |
| 4 | next | yeni | 1 | 1 | 0 | 0 | 12 |
| 4 | wet | yeni | 1 | 1 | 0 | 0 | 11 |
| 17 | "" | yeni | 2 | 2 | 0 | 0 | 56 · 56 |
| 17 | chain | yeni | 2 | 2 | 0 | 0 | 31 · 31 |
| 17 | edirne_none | yeni | 2 | 2 | 0 | 0 | 37 · 36 |
| 17 | edirne_policy | yeni | 2 | 2 | 0 | 0 | 39 · 39 |
| 17 | fall | yeni | 2 | 2 | 0 | 0 | 31 · 30 |
| 17 | lost | yeni | 2 | 2 | 0 | 0 | 31 · 31 |
| 17 | nophoto | yeni | 2 | 2 | 0 | 0 | 32 · 31 |
| 17 | osm | yeni | 2 | 2 | 0 | 0 | 69 · 68 |
| 17 | route | yeni | 2 | 2 | 0 | 0 | 11 · 10 |
| 17 | ship_bad | yeni | 2 | 2 | 0 | 0 | 30 · 31 |
| 17 | ship_ok | yeni | 2 | 2 | 0 | 0 | 30 · 31 |
| 17 | two | yeni | 2 | 2 | 0 | 0 | 30 · 32 |
| 17 | edirne_legend | yeni | 2 | 2 | 0 | 0 | 38 · 39 |
| 17 | "" | eski | 1 | 1 | 0 | 0 | 55 |
| 17 | chain | eski | 1 | 1 | 0 | 0 | 30 |
| 17 | edirne_none | eski | 1 | 1 | 0 | 0 | 36 |
| 17 | edirne_policy | eski | 1 | 1 | 0 | 0 | 39 |
| 17 | fall | eski | 1 | 1 | 0 | 0 | 30 |
| 17 | lost | eski | 1 | 1 | 0 | 0 | 30 |
| 17 | nophoto | eski | 1 | 1 | 0 | 0 | 31 |
| 17 | osm | eski | 1 | 1 | 0 | 0 | 67 |
| 17 | route | eski | 1 | 1 | 0 | 0 | 10 |
| 17 | ship_bad | eski | 1 | 1 | 0 | 0 | 31 |
| 17 | ship_ok | eski | 1 | 1 | 0 | 0 | 31 |
| 17 | two | eski | 1 | 1 | 0 | 0 | 32 |
| 17 | edirne_legend | eski | 1 | 1 | 0 | 0 | 40 |
| 18b | "" | yeni | 2 | 2 | 0 | 0 | 23 · 24 |
| 18b | "" | eski | 1 | 1 | 0 | 0 | 23 |
| 18b | miss | yeni | 2 | 2 | 0 | 0 | 25 · 24 |
| 18b | miss | eski | 1 | 1 | 0 | 0 | 24 |
| 38o | "" | yeni | 5 | 5 | 0 | 0 | 67 · 65 · 67 · 64 · 67 |
| 38o | hooks_bad | yeni | 5 | 5 | 0 | 0 | 65 · 66 · 68 · 65 · 67 |
| 38o | hooks_ok | yeni | 5 | 5 | 0 | 0 | 66 · 66 · 67 · 65 · 67 |
| 38o | lose | yeni | 5 | 5 | 0 | 0 | 73 · 75 · 73 · 74 · 74 |
| 38o | "" | eski | 1 | 1 | 0 | 0 | 66 |
| 38o | hooks_bad | eski | 1 | 1 | 0 | 0 | 66 |
| 38o | hooks_ok | eski | 1 | 1 | 0 | 0 | 66 |
| 38o | lose | eski | 1 | 1 | 0 | 0 | 73 |
| 38o | esik_dur | yeni | 1 | 1 | 0 | 0 | 67 |
| 38o | dis_dur | yeni | 1 | 1 | 0 | 0 | 66 |
| 19 | "" | yeni | 2 | 2 | 0 | 0 | 27 · 26 |
| 19 | captive18 | yeni | 2 | 2 | 0 | 0 | 26 · 26 |
| 19 | flee | yeni | 2 | 2 | 0 | 0 | 26 · 26 |
| 19 | saved | yeni | 2 | 2 | 0 | 0 | 26 · 25 |
| 19 | ship_bad | yeni | 2 | 2 | 0 | 0 | 27 · 25 |
| 19 | ship_ok | yeni | 2 | 2 | 0 | 0 | 26 · 26 |
| 19 | ship_ok_flee | yeni | 2 | 2 | 0 | 0 | 28 · 25 |
| 19 | tezkire | yeni | 2 | 2 | 0 | 0 | 26 · 26 |
| 19o | "" | yeni | 2 | 2 | 0 | 0 | 37 · 35 |
| 19o | hooks_bad | yeni | 2 | 2 | 0 | 0 | 33 · 33 |
| 19o | hooks_ok | yeni | 2 | 2 | 0 | 0 | 37 · 36 |
| 19o | silent | yeni | 2 | 2 | 0 | 0 | 35 · 35 |
| 29 | "" | yeni | 2 | 2 | 0 | 0 | 36 · 37 |
| 29 | lose | yeni | 2 | 2 | 0 | 0 | 41 · 41 |
| 29o | "" | yeni | 2 | 2 | 0 | 0 | 36 · 36 |
| 29o | lose | yeni | 2 | 2 | 0 | 0 | 35 · 34 |
| 19 | "" | eski | 1 | 1 | 0 | 0 | 26 |
| 19 | captive18 | eski | 1 | 1 | 0 | 0 | 26 |
| 19 | flee | eski | 1 | 1 | 0 | 0 | 25 |
| 19 | saved | eski | 1 | 1 | 0 | 0 | 25 |
| 19 | ship_bad | eski | 1 | 1 | 0 | 0 | 25 |
| 19 | ship_ok | eski | 1 | 1 | 0 | 0 | 25 |
| 19 | ship_ok_flee | eski | 1 | 1 | 0 | 0 | 25 |
| 19 | tezkire | eski | 1 | 1 | 0 | 0 | 26 |
| 19o | "" | eski | 1 | 1 | 0 | 0 | 35 |
| 19o | hooks_bad | eski | 1 | 1 | 0 | 0 | 33 |
| 19o | hooks_ok | eski | 1 | 1 | 0 | 0 | 36 |
| 19o | silent | eski | 1 | 1 | 0 | 0 | 36 |
| 29 | "" | eski | 1 | 1 | 0 | 0 | 36 |
| 29 | lose | eski | 1 | 1 | 0 | 0 | 41 |
| 29o | "" | eski | 1 | 1 | 0 | 0 | 35 |
| 29o | lose | eski | 1 | 1 | 0 | 0 | 34 |
| 18 | "" | yeni | 1 | 1 | 0 | 0 | 17 |
| 31o | "" | yeni | 1 | 1 | 0 | 0 | 60 |
| 39o | "" | yeni | 1 | 1 | 0 | 0 | 31 |
| 27 | "" | yeni | 1 | 1 | 0 | 0 | 19 |
| 17o | "" | yeni | 1 | 1 | 0 | 0 | 21 |
| 30 | "" | yeni | 1 | 1 | 0 | 0 | 40 |
| 30o | "" | yeni | 1 | 1 | 0 | 0 | 51 |
| 41o | "" | yeni | 1 | 1 | 0 | 0 | 54 |
| 42b | "" | yeni | 1 | 1 | 0 | 0 | 63 |
| 43o | "" | yeni | 1 | 1 | 0 | 0 | 51 |
| 44b | "" | yeni | 1 | 1 | 0 | 0 | 45 |
| 8y | "" | yeni | 1 | 1 | 0 | 0 | 27 |
| 0 | "" | yeni | 1 | 1 | 0 | 0 | 22 |
| 20 | "" | yeni | 1 | 1 | 0 | 0 | 44 |
| 28o | "" | yeni | 1 | 1 | 0 | 0 | 22 |
| 6 | "" | yeni | 1 | 1 | 0 | 0 | 20 |
| 7 | "" | yeni | 1 | 1 | 0 | 0 | 72 |
| 10h | "" | yeni | 1 | 1 | 0 | 0 | 71 |
| 12b | "" | yeni | 1 | 1 | 0 | 0 | 62 |
| 11 | "" | yeni | 1 | 1 | 0 | 0 | 68 |
| 10 | "" | yeni | 1 | 1 | 0 | 0 | 20 |
| **toplam** | | | **156** | **156** | **0** | **0** | |

**Toplam:** son kodla 156 koşu (8 bölümün bütün çeşitleri yeni ×2 + eski ×1; 4'ün 4a çeşitleri ×1; 38o ×5 + eski ×1 +
iki eşik sondası; 21 gerileme bölümü ×1), **156 PASS, bitmeyen 0, sorun satırı 0**. Önceki turlar (kod donmadan önce):
`testler/bolum/` içindeki S_ öneksiz dosyalar; onlarda tek sorun satırı `e17_bos`'taki Büro WALKTHRU ("hâlâ kötü" 9).

**38o merdiven çıkışı ve sondalar (son tur):** bütün 38o koşularında `T11CIKIS` y 9,62–9,70, z 60,60–60,91, `yedek=0`;
`=esik_dur` ve `=dis_dur`: `yolda=true tutundu=0`.

**Gerileme — HornWorld'ün yeni uzak katmanı hangi bölgelerde kuruldu** (`DENIZSET hornworld` satırları; satır yoksa o bölümde
HornWorld'ün kurduğu sur DEĞİŞMEDİ):

| bölüm | bölge | yeni uzak katman (üçgen) |
|---|---|---|
| 17, 19, 19o, 29, 29o | horn_chain | 1 740 + 716 + 1 858 |
| 38o | horn_wall_o | 3 564 |
| 18 | horn_bridge | 1 836 |
| 31o | eyup + byz_aya | 1 884 + 6 990 |
| 39o | petrion | 3 456 |
| 27 | galata | 2 556 |
| 17o | springs | 3 852 |
| 30, 30o | blachernae | 1 824 |
| 44b | byz_aya | 6 990 (iki kez kurulur) |
| **8y, 20**, 0, 28o, 41o, 42b, 43o, 6, 7, 10h, 12b, 11, 10 | — | **yok** (kara suru / şehir bölgeleri 250 m'den uzak) |

8y ve 20'de (ve TAŞIMA 10'un bölümlerinde: 6, 7, 10h, 12b) HornWorld'ün kurduğu geometri eskisiyle aynı: ESKİ|YENİ bütçe
farkı 0 (kare çekmedim: aynı sahne). Yeni katmanın kurulduğu bölgelerde en çok +7 bin üçgen (byz_aya), aynı parçaların eski
kutuları ve saçılmış dişleri kurulmuyor; ölçtüğüm bölgelerde (horn_chain, horn_wall_o) kare ilkel farkı ≤ +%0,5.

**Sözleşme ve araçlar (son kayıt, kopyadan):** `PARSECHECK PASS scripts=367` · `SURSOZLESME PASS kalem=13 kesim=8` ·
`SUROYUN nokta=519 havada=0 gomuk=0 katida=0` · `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0` · `ESYATEST PASS` ·
`T8DTEKME PASS` (`testler/sozlesme_son.txt`) · `HALICSONDA OZET carp=661 karma=3854034809` (eski ile aynı;
`testler/halic_sonda_son.txt`; görünen üçgen yakın katman 5 978 → 11 674, orta 4 970 → 5 070, uzak 60 → 60).

## Bütçe — ESKİ | YENİ (aynı kamera, 4 karenin ortalaması; `testler/kare_*.txt`)
Kural ≤ +%5 (ilkel); bütün bölüm karelerinde sağlandı. Çizim çağrısı yeni kipte 27 karenin 26'sında eskiden AZ
(birleştirme: eski kesim ≈ yüzlerce ayrı kutu ağı + saçılmış diş, yeni malzeme × 32 m hücre).

| bölüm | kare | çizim | ilkel |
|---|---|---|---|
| 4 | a1 zincirden | 476 → 374 (−21,4 %) | 326 538 → 328 700 (+0,7 %) |
| 4 | a2 rıhtım yakın | 408 → 294 (−27,9 %) | 338 064 → 337 338 (−0,2 %) |
| 4 | a3 kapıya yüz yüze | 337 → 259 (−23,1 %) | 288 146 → 299 094 (+3,8 %) |
| 4 | a4 kule yanağı | 268 → 207 (−22,8 %) | 358 666 → 363 532 (+1,4 %) |
| 4 | a5 Niko | 144 → 122 (−15,3 %) | 313 466 → 318 200 (+1,5 %) |
| 4 | d1 dikiş x 80 | 439 → 352 (−19,8 %) | 325 992 → 336 390 (+3,2 %) |
| 4 | a6 kapı genel | 324 → 243 (−25,0 %) | 279 536 → 291 202 (+4,2 %) |
| 17 | b1 rihtim_yakin | 7613 → 7524 (−1,2 %) | 7 704 283 → 7 718 025 (+0,2 %) |
| 17 | b2 genel_sudan | 1412 → 1310 (−7,2 %) | 1 376 961 → 1 382 717 (+0,4 %) |
| 17 | b3 dikis_x80 | 587 → 526 (−10,4 %) | 604 328 → 603 860 (−0,1 %) |
| 17 | b4 dikis_x-60 | 6594 → 6530 (−1,0 %) | 6 690 286 → 6 690 192 (−0,0 %) |
| 17 | b5 kapi | 1172 → 1091 (−6,9 %) | 1 094 557 → 1 101 295 (+0,6 %) |
| 18b | c1 dis_yakin | 1419 → 1382 (−2,6 %) | 1 642 930 → 1 649 632 (+0,4 %) |
| 18b | c2 doseme_yakin | 1863 → 1828 (−1,9 %) | 1 852 021 → 1 848 069 (−0,2 %) |
| 18b | c3 kopruden | 6069 → 6024 (−0,7 %) | 8 252 852 → 8 268 010 (+0,2 %) |
| 18b | c4 bingi_alttan | 1078 → 1016 (−5,8 %) | 1 596 752 → 1 601 446 (+0,3 %) |
| 18b | d1 dikis_x20 | 6310 → 6267 (−0,7 %) | 8 238 316 → 8 259 308 (+0,3 %) |
| 18b | c5 top_mazgal | 1248 → 1220 (−2,2 %) | 1 069 370 → 1 069 080 (−0,0 %) |
| 19 | g1 donus_gemiden | 4351 → 4242 (−2,5 %) | 6 194 312 → 6 203 452 (+0,1 %) |
| 19 | g2 genel_sudan | 1120 → 1001 (−10,6 %) | 1 442 560 → 1 445 608 (+0,2 %) |
| 19 | d1 dikis_x-60 | 4731 → 4665 (−1,4 %) | 6 611 278 → 6 613 802 (+0,0 %) |
| 19o | h1 kayiktan | 799 → 712 (−10,9 %) | 904 486 → 905 966 (+0,2 %) |
| 19o | d1 dikis_x80 | 390 → 315 (−19,2 %) | 630 222 → 632 870 (+0,4 %) |
| 29 | j1 savastan_uzak | 761 → 708 (−7,0 %) | 656 048 → 655 816 (−0,0 %) |
| 29o | j1 savastan_uzak | 608 → 555 (−8,7 %) | 653 558 → 653 326 (−0,0 %) |
| 38o | f1 merdiven_tepesi | 5376 → 5345 (−0,6 %) | 7 687 927 → 7 704 566 (+0,2 %) |
| 38o | f2 kapi_yakin | 2528 → 2540 (+0,5 %) | 4 007 138 → 4 021 923 (+0,4 %) |
| 38o | f3 sudan_genel | 3865 → 3841 (−0,6 %) | 5 424 934 → 5 454 042 (+0,5 %) |
| 38o | f4 gemiden_sur | 3478 → 3431 (−1,4 %) | 4 985 976 → 5 005 839 (+0,4 %) |
| 38o | f5 yol_yakin | 1843 → 1806 (−2,0 %) | 3 176 083 → 3 186 826 (+0,3 %) |
| 38o | d1 dikis_x24 | 5611 → 5547 (−1,1 %) | 7 476 087 → 7 489 447 (+0,2 %) |
| 38o | f6 rihtim_yakin | 5396 → 5359 (−0,7 %) | 7 669 711 → 7 690 218 (+0,3 %) |
| 38o | f1b mazgal_acikligi | 1175 → 1160 (−1,3 %) | 980 052 → 995 637 (+1,6 %) |

**Şehir Haliç dilimi** (`kare/sehir/`, dilim tek başına; şehirde pişirilir, çizim çağrısı orada birleşir): çizim 968 → 752
(s1), ilkel 20 922 → 30 472 (s1, +%46; dilimin görünen üçgeni yakın katmanda 5 978 → 11 674, orta 4 970 → 5 070: kaideli gövde, harpuştalı dişler, koridorlu/silmeli kuleler,
kemerler). Dilim başına yakın katmanda ≈ +5,7 bin üçgen; şehirde bu dilimden yalnız
96 m'lik Haliç hat parçaları var. Şehir karesinde ESKİ|YENİ ölçülmedi (çıplak `--eskisur` şehirdeki başka setleri de
değiştirdiği için yalıtılamadı) — **KISMEN**.

**HornWorld (2b)**: yeni uzak katman yalnız bölgenin keep dikdörtgenine ≤ 250 m olan parçalarda: `horn_chain` (17, 19,
19o, 29, 29o) Haliç 2 456 + Marmara 1 858 üçgen, `horn_wall_o` (38o) 3 564 üçgen (tek ağ, görüş sonu 1 200 m); bu
bölümlerin karelerinde ilkel farkı ≤ +%0,5 (yukarıdaki tablo; HornWorld dahil). 8y ve 20 (kara suru bölgeleri) ve öteki
gerileme bölümleri: bkz. "Gerileme" (`DENIZSET hornworld` satırı yoksa o bölgede HornWorld'ün kurduğu sur DEĞİŞMEDİ).

## Sonraki taşıyana
1. **Ortak kalem tek yerde:** deniz surunun görünüşü `scripts/world/ist/deniz_set.gd`'de. SeaWalls, 18b, 38o, Horn devamı,
   HornWorld'ün yakın devamı ve şehirdeki 96 m'lik Haliç dilimi aynı işlevleri çağırır; kesit sözlüğü `g` (zf, s, T, H, dip,
   su, lod, kz, PT, PH, yol) dosyanın başında. Deniz yönü `s` ile çevrilir (+1 deniz +z: SeaWalls; −1 deniz −z: Haliç kesimi,
   şehir).
2. **Çarpışma kutuları değişmedi:** her yerde eski kutular gizli + `wall`/`ground` metası (`deniz_set.gizle`). Görünüş hiçbir
   yerde kutudan küçük değil (kule pahı oyuncunun yürüdüğü yerdeki kulelerde 0: SeaWalls x −6, şehir kuleleri).
3. **Dişler çarpışmasız** (eskisi gibi); 18b'de görünmez korkuluk aynı hatta. 38o'da merdiven ağzı x −6 ± 0,65 dişsiz ve
   eşiksiz; çıkış `MerdivenCikis.cikis` (bölüm içinde). Başka bir bölüm deniz suruna merdiven dayarsa aynı kalıp: ağız
   `korkuluk(kes=…)` + `dis_dizisi(bos=…)`, çıkış noktası yolun üstü.
4. **Geri dönüş:** `--eskisur` (hepsi), `--eskisur=4`, `=17`, `=18b`, `=19`, `=19o`, `=29`, `=29o`, `=38o` (SeaWalls `bolum`
   add_child'dan önce; Horn ve HornWorld sahnenin bölüm adından). Şehir dilimi yalnız çıplak `--eskisur` ile eskiye döner.
5. **Bütçe:** yakın kesitler `blak_set.birlestir` (malzeme × 32 m hücre); HornWorld'ün yeni uzak katmanı tek ağ (görüş sonu
   1200 m). `DENIZSET hornworld … ucgen=` satırı hangi bölgede kaç üçgen kurulduğunu yazar.
6. **Testler kopyadan:** uzun koşu turları sürerken ortak bir dosya düzenlenirse (Godot betiği her süreç başında okur) tur
   ayrıştırma hatası penceresine düşer; `~/is/kopya` eşinden koşmak bunu önler.

## Başka dosyaya istek
1. **`scripts/world/ist/marmara_sur.gd` (`IstMarmaraSur.build_run`) — şehir Haliç hattının çoğu:** `sehir.gd:2901-2906`
   yalnız tam 96 m'lik Haliç dilimlerini `IstHalicSur`'a verir; öteki Haliç dilimleri (ve Marmara) `IstMarmaraSur.build_run`
   ile kurulur ve bu görevin dosyası değil. Şehirde aynı kıyıda iki ressam yan yana durur (96 m'lik dilim yeni kalem, komşusu
   eski kutu diş). İstek: `build_run` görünüşü `deniz_set.govde/korkuluk/disler/kule` ile (çarpışma aynı kalarak; bu dalda
   `IstHalicSur` için yapılan kalıp: kutular gizli + meta, `tasima11_halic_sonda` ile döküm eşitliği).
2. **`scripts/world/ist/sur_kule.gd` (`disler_ag` harpuştası):** yakında ve gölgede harpuşta koyu, yeşilimsi (18b c1,
   38o f1); TAŞIMA-9 "hâlâ kötü" 1 ile aynı. Ortak; değiştirmedim.
3. **`scripts/world/ist/sur_doku.gd` (yatay yüz döşeme tonu):** sur yolu ve rıhtım döşemesi yakında kiremit-kahve (4 a2,
   38o f1). Deniz dalında değiştirmedim (kanıtla gösterilecek bir ölçüm yapmadım); ortak döşeme rengi sahibinin kararı.
4. **`scripts/world/horn_world.gd` / `world1453.gd` — tek harita kıyı hattı:** 17/19/19o/29/29o'da SeaWalls'ın kesimi
   (yerel z −3,2) dünyanın kıyı çizgisiyle çakışmıyor: kesimin iki ucunda (x −60, 80) arazi yamacı başlıyor, `HornWorld`
   suru yamacın üstünden geçiyor (17 b3/b4: eski ve yeni AYNI geometri; yeni kipte yalnız görünüş yeni kalem). Kıyı hattını
   hizalamak `World1453` arazisi/`REGIONS` işi (DOKUNMA listesinde).
5. **TAŞIMA 10'a bilgi (8y, 6, 7, 10h, 12b):** `HornWorld._wall_run`'ın yeni uzak katmanı yalnız bölgenin `keep`
   dikdörtgenine ≤ 250 m olan parçalarda kurulur; kara suru bölgelerinde (landwalls, byz_walls) Haliç/Marmara suru 250 m'den
   uzakta → bu bölümlerde HornWorld'ün kurduğu sur değişmedi (`DENIZSET hornworld` satırı yok; bütçe aşağıda).

## Hâlâ kötü olanlar (dürüst)
1. **Harpuşta yakında ve gölgede koyu, yeşilimsi** (18b c1, 38o f1, şehir s3): ortak `sur_kule.disler_ag` + sur_doku harpuşta
   dalı (TAŞIMA-9 "hâlâ kötü" 1 ile aynı); dokunmadım.
2. **Tek harita dikişleri (17, 19, 19o, 29, 29o):** SeaWalls'ın yakın kesiti x −60 ve 80'de bitiyor; dünyanın kıyı hattı
   kesimin çizgisiyle çakışmadığı için uçlarda arazi yamacı başlıyor, HornWorld suru yamacın üstünden devam ediyor. Ressam
   artık aynı ama geometri kopuk (eskide de aynı kopukluk). Kıyı hattı/arazi `World1453`'ün işi.
3. **Sur yolu ve rıhtım döşemesi yakında kiremit-kahve** (4 a2, 38o f1): ortak sur_doku'nun yatay yüzü.
4. **17/19'da dünyanın gri kıyı arazisi rıhtımın sura yakın şeridini örtüyor** (17 b1; eskisinde de): World1453 arazisi rıhtım
   üstünden (y 0,7) yüksek. Oyuncunun basdığı çarpışma rıhtımın kutusu; görünen yüzey arazi.
5. **Kapı kanatları** (SeaWalls x 17, 38o): eskisinin düz tahta kutuları (oynanış düğümleri: `gate_leaves`, `gate_l/r`);
   38o'ya demir kuşak eklendi, SeaWalls'ınki zaten kuşaklı. Tahta dokusu düz.
6. **Şehir kule terası:** teras korkuluğundaki merdiven ağzının iki ucunda 2–3 cm'lik gök aralığı (s6): kule merdiveninin
   eni (1,8) ağızdan (2,0) dar; ağzın yanakları eklendi ama basamak kenarı ile korkuluk arasında ince boşluk kalıyor.
7. **Şehirde Haliç hattının çoğu `IstMarmaraSur.build_run`** (bu görevin dosyası değil): yalnız 96 m'lik `IstHalicSur`
   dilimleri yeni kalemle; komşu dilimler eski kutu dişli (başka dosyaya istek 1).
8. **HornWorld'ün 250 m'den uzak kıyı surları** (Haliç'in öbür ucu, Marmara) eski Dressing kutuları (görev sınırı; bütçe).
9. **17 eski koşusunda 1 WALKTHRU (Büro, Müfide):** `e17_bos` (`--eskisur`), satır SeaWalls kurulmadan ÖNCE (günlük sırası:
   WALKTHRU → `DENIZSET bolum=17`), Büro sahnesinde (`bureau.gd`, bu görevin dosyası değil). Aynı komutla 2 eski + 2 yeni
   yeniden koşuda çıkmadı (`r17_*`), 17'nin öteki 42 koşusunda yok. Kök neden bulunamadı; olası yol: `Person._clear_way`
   (yürüyen biri ayaktaki Müfide'yi yana iter) + `Unclip.walk_audit`'in itilmeyi yürüme sayması (`discount_move`
   `Unclip._wa_last`'ı düzeltmiyor) + itme denetiminin (`in_solid` "zaten içindeyse izin ver") masaya değen kişiyi içeri
   itebilmesi. Doğrulanmadı; "flake" diye geçiştirmiyorum: Büro/kişi dosyalarının sahibine bildirilmeli.

## Replik uyumsuzluğu
Yok. Bütün oynanış yerleri (rıhtım, iki kapı, zincir, Niko'nun kenarı, kuleler; 18b top mazgalı, köprü; 38o merdiven ağzı,
kazan, deniz kapısı, rıhtım halatı, babalar) eski koordinatlarında. "Kapı", "rıhtım", "mazgal", "merdiven", "sur" replikleri
yeni görünüşle de doğru. 4b'nin kapı kitabesi ("ΠΥΛΗ ΤΟΥ ΝΕΩΡΙΟΥ") aynı yazıyla kemerin üstündeki mermer levhada.

## run_tests.sh isteği (EKLEMEDİM)
- `run --chapter=38o --autotest=esik_dur` ve `run --chapter=38o --autotest=dis_dur` (son satırlardan `T11ESIK … yolda=true
  tutundu=0`; merdiven eşik tuzağının gerilemesi).
- `godot --headless --path . res://tests/_ist/tasima11_halic_sonda.tscn` → `HALICSONDA OZET carp=661 karma=3854034809`
  (şehir Haliç dilimi çarpışması değişmedi).
- `=kare` araçları (`tasima11_kare.tscn`, `tasima11_halic_kare.tscn`) yalnız pencereli; pakete değil kanıt koşularına.
