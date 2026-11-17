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

(son doğrulamada doldurulur — aşağıya bakın)

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
tutundu=0`). Bot tırmanışı bütün çeşitlerde `T11CIKIS y=9.70 z=60.60 x=-6.00 t≈9,1 yedek=0`.
