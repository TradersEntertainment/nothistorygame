# Sur sözleşmesi (dondurulmuş ölçüler) — İstanbul v2 kara suru

> Sürüm **2026-11-13** · Tek kaynak: `scripts/world/ist/sur_sozlesme.gd` (kurallar + canlı hesap) ve
> `scripts/world/ist/sur_sozlesme_donmus.json` (donmuş tablo). Denetim: `tests/_ist/sur_sozlesme.tscn`
> (son satır `SURSOZLESME PASS|FAIL …`), beklenen özet `tests/_ist/sur_sozlesme_beklenen.txt`.
> Oynanış arayüzü (`scripts/world/ist/sur_oyun.gd`) **yalnız donmuş tabloyu** okur.

## Kural

1. Bu sayılar **görünüş turlarında değişmez**. `surlar.gd`'de bir değişiklik bu sayılardan birini değiştirirse
   `sur_sozlesme.tscn` FAIL verir ve değişen kalemi adıyla yazar (`SURSOZLESME fark kesim/mesoteikhion/gedik/x[0] canli=12.0 donmus=0.0` gibi; bu satır
   gerçekten denendi, bkz. `docs/_kanit_ist2_sur_arayuz/rapor.md`).
2. Tablo elle değiştirilirse kalem özeti beklenen özetle uyuşmaz → FAIL (`ozet:<kalem>`).
3. Değişmesi gerekirse: sahibin kararı → `-- --uret` ile tablo + beklenen özet birlikte yeniden üretilir → bu belge
   ve bölümlerin taşıma denetimleri yeniden koşar. Eski tablo git geçmişinde kalır.
4. Kule x'leri `_layout`'un rng sırasından bir kez hesaplanıp tabloya yazıldı; arayüz rng'ye bakmaz. Rng sırası
   değişirse kurulan sur tablodan ayrılır → FAIL (sessizce kaymaz).

## Kesit (k = `IstSehir.K_SUR` = 1,0; yerel eksen: +x sur boyunca, +z ova, z = 0 iç sur ortası, y = 0 dilim tabanı)

```
 y
 19 ┤      ┌──┐ iç kule tepesi (HT 19)
    │      │  │
 13 ┤      │  │                    ┌┐ dış kule tepesi (OTH 13)
 12 ┤ ┌─┬──┘  │ iç sur (HW 12)      ││
    │ │ │ yol 4,1                  ││
8,5 ┤ │ │                     ┌──┬─┘│ dış sur (OH 8,5), yol 1,7
    │ │ │                     │  │  │
1,6 ┤ │ │                     │  │  │        ┌┐ parateikhion (1,6)
  0 ┼─┴─┴─────────────────────┴──┴──┴────────┴┴─┐                    ┌──── ova
    │  iç sur      peribolos 15        dış sur   teras 10   hendek 20 × 6 derin
 -6 ┤                                               └────────────────────┘
    └──┬────┬──────────────────────┬────┬────────────┬────────────────────┬──→ z
     -2,5  2,5                   17,5  20,1        30,1                 50,1
```
(Dış kuşak — teras, hendek, ova — kesimin dış kademesi `dy` kadar aşağıdadır; Mesoteikhion'da −3,67 m.)

| Ölçü | Değer | Kaynak |
|---|---|---|
| İç sur kalınlık / yükseklik (T / HW) | 5,0 / 12,0 | `surlar.gd dims()` |
| İç kule en / çıkıntı / tepe (TW / TP / HT) | 9,0 / 6,0 / 19,0 | 〃 |
| Peribolos (PW) | 15,0 | 〃 |
| Dış sur kalınlık / yükseklik (OT / OH) | 2,6 / 8,5 | 〃 |
| Dış kule en / çıkıntı / tepe (OTW / OTP / OTH) | 4,5 / 4,0 / 13,0 | 〃 |
| Teras (PTW) / hendek en (MW) / derinlik (MD) | 10,0 / 20,0 / 6,0 | 〃 |
| Kule aralığı (S, hedef) | 55,0 | 〃 |
| z şeritleri | zi0 −2,5 · zi1 2,5 · zo0 17,5 · zo1 20,1 · zm0 30,1 · zm1 50,1 | 〃 |
| Korkuluk kalınlık × yükseklik | 0,45 × 1,2 | `PARAPET_T/H` |
| Basamak yüksekliği | 0,26 (taş merdiven derinliği 0,42) | `STEP_RISE` |

## Çarpışma

| Ölçü | Değer |
|---|---|
| İç sur yürüme yolu eni | 4,1 m (5,0 − 2 × 0,45) |
| Dış sur yürüme yolu eni | 1,7 m (2,6 − 2 × 0,45) |
| İç kule geçidi | 2,2 × 3,0 m (`sur_kule.gd` kapi_z0/z1, kapi_h) |
| Dış kule | sur yolu kule tepesine 18 × 0,42 m basamakla çıkar (13 m), tepede korkuluk geçidi 1,8 m |
| Gedik eni | 8,0 m (`GEDIK_W`) |
| Poterna boşluğu | 1,4 × 2,3 m (`POTERNA_W/H`; yalnız oyun kesiminde oyulur) |

## Kesimler (donmuş)

Şehirdeki gerçek yer: hat `kara_suru` (sade) üstünde yay boyu `s` (m). Kapı kesimleri şehirdeki kapı koşusuyla **aynı
dilim** (60 m = `IstSehir.GATE_L`, aynı tohum `1000 + id.hash() % 997`, aynı seçenek). Mesoteikhion: 190 m dilim,
Romanos kapı koşusunun güney ucunda biter; kuzey yan dilimi şehirdeki Romanos kapı koşusunun kendisi.

| Kesim | L | Köken (dünya x, y, z) | yaw° | dy | Kapı en×boy | Gedik x (oyun, dekor) | Poterna x |
|---|---|---|---|---|---|---|---|
| mesoteikhion | 190 | −1717,37; 14,41; −190,37 | −98,37 | −3,67 | — | **−67,7**, 34,87 | −85,6 |
| romanos | 60 | −1691,73; 14,21; −312,34 | −108,08 | −3,55 | 5,0 × 4,6 | — | −20,6 |
| pege | 60 | −1738,98; 15,97; 473,53 | −80,34 | −5,53 | 4,2 × 4,2 | — | −20,6 |
| rhegion | 60 | −1738,75; 15,68; 173,35 | −99,99 | −5,33 | 4,0 × 4,0 | — | −20,6 |
| pempton | 60 | −1466,67; 16,00; −640,24 | −128,74 | −8,81 | 3,6 × 3,6 | — | −20,6 |
| kharisios | 60 | −1276,29; 18,58; −897,64 | −146,20 | −11,14 | 5,0 × 4,4 | — | −20,6 |
| altin_kapi | 60 | −1700,06; 9,99; 594,23 | −158,36 | 0,00 | 6,4 × 5,2 (kapalı) | — | −20,6 |
| ksylokerkos | 60 | −1729,62; 14,84; 528,53 | −80,34 | −4,77 | 3,6 × 3,4 (kapalı) | — | −20,6 |

Hat üstü yay boyları: gedik 1 / 2 / 3 = 898,6 / 793,6 / 678,6; Romanos kapısı 955,9 (koşu 925,9–985,9). **Oyun gediği
Romanos kapısının 57 m güneyinde** (belgedeki "170 m" tahmini katalog noktasından ölçülmüştü; şehir kapıyı `YER2`'ye
koyar).

### Mesoteikhion (oyun dilimi, yerel x)

| Kalem | Değer |
|---|---|
| İç kuleler (x / en / çıkıntı) | −63,0 / 9 / 6 · −1,6 / 9 / 6 · 59,6 / 9 / 6 |
| Dış kuleler | −32,31 (kurulu) · 28,96 (**yıkık**: 2. gediğe yakın; tepe basamakları yine kurulu — v2 bulgusu) |
| İç sura taş merdiven | x −57,47 → −37,73 (47 basamak × 0,42), şehir yakasında z −3,4 |
| Dış sura taş merdiven | x −15,53 → −1,67 (33 basamak × 0,42), peribolosta z 16,6 |
| Hendek rampaları | yakın yaka x −60,8 (ayak −77,5), uzak yaka x 60,8 (ayak 77,5); boy 16,7, en 2,6 |
| Dayama noktaları (5) | x −55,91 · −20,02 · 5,37 · 48,92 · 74,31; eğim 16°, tepe korkuluğun 1,5 m üstü (OH + 1,5) |
| Hendek geçişleri | dolgu x −67,7 (gediğin önü, en 10) · kalas x −85,6 (poterna önü, en 1,6) |
| Batarya yuvaları | (−91,7; 95,1) · (−49,7; 95,1) (hendek dış yakasından 45 m) |
| Yan dilimler | kuzey (−x): Romanos kapı koşusu, orta x −125; güney (+x): 110 m dilim, orta x 150 (3. gedik dekor) |

Kapı kesimlerinde (60 m) taş merdiven ve dış kule yoktur (şehirde de yok; merdivenler yan dilimlerde, arayüz
`cikislar()` onları da verir). Kısa koşuda hendek rampasının ayağı komşu dilimin hendek uç bölmesine düşer: arayüz
bu rampaları **vermez**; hendek geçişi kapı köprüsü / dolgu / kalasla.

## Kalem özetleri (beklenen)

`tests/_ist/sur_sozlesme_beklenen.txt` — 13 kalem: carpisma, gedik, gedik_kural, hendek, kapi, kapi_olcu, kapi_yer,
kesit, kule, merdiven, oyun, yan, yer.

## Oynanış arayüzü (`scripts/world/ist/sur_oyun.gd`, class_name yok)

```gdscript
const SurOyun := preload("res://scripts/world/ist/sur_oyun.gd")
var a = SurOyun.arayuz("mesoteikhion")             # yalnız veri (donmuş tablo), kurulum yok
var k = SurOyun.kur("mesoteikhion", {"ebeveyn": self, "dunya": false, "asama": 2, "dolgu": 0.5,
		"kalas": true, "poterna_acik": true, "merdiven": [0, 1, 2]})
# k = {"kok": Node3D, "arayuz": a, "parca": {...}, "ms": {oyun_ms, yan_ms, uzak_ms, zemin_ms, parca_ms, toplam_ms}}
```

Her nokta `{"yerel": Vector3, "dunya": Vector3}`; `dunya = a.xf * yerel`. `"dunya": false` ile kök orijinde kurulur
(bölüm yerel çalışır), `true` ile kesimin şehirdeki yerine. **`ebeveyn` verilmeli**: kurucu dış kademeyi (dy) kurulum
anında `OTURTMA.dy_kayit`'tan okur; SurOyun bütün dilimler için sözleşmedeki dy'yi oraya yazar.

| Sorgu | Döndürür |
|---|---|
| `yol("ic"/"dis")` | `y`, `en`, `z`, `nokta` (çoklu çizgi; dış surda kule tepesine basamakla çıkıp iner), `gecit` (kule geçidi/üstü, dekor gedik tahtası), `kesik` (oyun gediği aşama < 4, yıkık dış kulenin basamakları) |
| `cikislar()` | taş merdivenler (ana + yan dilimler): `alt`, `ust`, `yol`, `en`, `basamak` [n, derinlik, yükseklik], `taraf` |
| `dayamalar()` | 5 dayama: `x`, `ayak`, `tepe`, `egim` (Ladder.tilt), `boy` (Ladder.height), `yol`, `basamak_araligi` 0,36, `en` 0,8 |
| `mazgallar("ic"/"dis")` | diş arası açıklık `p`, savunucu yeri `ayak`, `bakis` (+z) |
| `bataryalar()` | ovada top yuvası `p`, `bakis` (gediğe) |
| `gedik()` | `x`, `dikdortgen` (Rect2 x/z), `asama`, `moloz` {peri, tepe, teras, hendek} |
| `hendek()` | kıyılar, dip, `rampa` (yalnız ayağı dilim içinde olanlar), `gecis` [{tur: dolgu/kalas/kapi_kopru, x, en, yakin, uzak}] |
| `kapi()` | `en`, `boy`, `kapali`, `ic_esik`, `peri`, `dis_esik`, `kopru_yakin`, `kopru_uzak` |
| `poterna()` | `x`, `en`, `boy`, `ic`, `esik`, `sahanlik`, `dis` (dış basamağın teras ucu) |
| `alanlar()` | şehir / peribolos / teras / ova / hendek dibi: Rect2 (x/z) + y (sur dibi eteği şeritleri dışında) |
| `engeller()` | kişi konamayacak taban dikdörtgenleri |
| `dogma(alan, n, tohum)` | güvenli doğma noktaları (engeller dışında, ışınla denetlenir) |
| `noktalar()` | denetim listesi (hepsi, tür etiketiyle) |

Parçalar (`sur_oyun_parca.gd`): `Poterna.ac(bool)`, `KalasKopru.tak()/sok()`, `Dolgu.doluluk(0..1)`,
`KapiKopru.hal("saglam"|"yikik")`, `KapiKanat.ac(bool)`, `HucumMerdiveni.it()/devir()/dik()/cizgi()` (içinde gerçek
`Ladder`: `climb_anim.attach(kişi, m.lad, at)` doğrudan çalışır), `GedikOnarim.asama(1..4)`.

## Bölüm bağdaştırıcısı (`SurSet`, `scripts/world/ist/sur_set.gd`) — pilot 20

Ortak yardımcılar (`Assault`, `Garrison`, `WallFight`, `SiegeChaos`) ve bölümler sura sabit koordinat yazmaz, `SurSet`'e
sorar. İki uygulama:

```gdscript
var sur := SurSet.sec("20", ESKI_SUR)      # --eskisur (ya da --eskisur=20,20o) ya da bölüm sabiti → eski; yoksa yeni
# sur = SurSet.eski()                → LandWalls sabitlerinin AYNISI (eski set, davranış birebir)
# sur = SurSet.yeni("mesoteikhion")  → SurOyun.arayuz(kesim) sorguları
walls = LandWalls.new() if sur.eski_mi else SurSetSahne.new()   # SurSetSahne extends LandWalls (fire_flash, make_dawn… aynı)
fight.sur = sur; assault.sur = sur; Garrison.land_walls(…, sur)  # verilmezse (null) bugünkü kod yolu
```

**Bölüm çerçevesi** eski setle hizalıdır: x = 0 oyun gediğinin ortası, y = 0 peribolos toprağı, z = 14 dış surun iç yüzü,
+z ova. Yeni sette `cerceve = SurOyun yereli + ofs`, Mesoteikhion'da `ofs = (67,7; 0,12; −3,5)` (kesim kökü `SurCerceve`
düğümüne `dunya: false` ile kurulur). Böylece peribolostaki bölüm sayılarının çoğu iki sette de anlamlıdır; surun DIŞI
(teras, hendek, ova) ancak bağdaştırıcıdan okunursa doğru düşer (yeni sette ova peribolostan 3,57 m aşağıda, hendek 20 × 6).

**Ova kaydırması** (`ova_ofs()`; eski 0, yeni (0; −3,54; 10,6)): eski ovanın koordinatları (z ≥ 36 düz y = 0: SiegeField,
Assault'un ordusu, bataryaları, mancınıkları, kalkan siperleri, merdiven takımları, büyük top) bir düğümle yeni ovaya
iner (eski z 36 ↔ yeni hendeğin uzak yakası). Bölümün ova sayıları bu yüzden değişmez; sura yakın olanlar değişir.

| Sorgu (çerçevede) | Eski karşılığı | Yeni (Mesoteikhion) |
|---|---|---|
| `gedik()`, `gedik_en()`, `gedik_bosluk()` | `BREACH` (0;0;15), `BREACH_W` 7, `BREACH_W/2+EDGE_W` 6,5 | (0;0;15,3), 8, 4,5 |
| `gedik_onu()`, `barikat()`, `moloz_sirti()` | `BREACH+(0;0;−3,4)`, `BREACH+(0;2,2;−1,2)`, `on_rubble(BREACH+(0;0;1,2))` | (0;0;9,6), (0;1,5;10,3), sırt z 15,1 |
| `moloz_y(x,z)`, `on_rubble(p)` | `rubble_y`, `on_rubble` | `SurOyunAg.moloz_profil` + `_tumsek` kesiti |
| `zemin_y(x,z)` / `dis_zemin_y` | `Assault.ground_y` (= `_ground_y_eski`) / `outside_y` | teras, parateikhion (geçişlerde açık), hendek dibi, dolgu ve kalas üstü, ova, moloz |
| `dis_sur_z0/z1`, `dis_yol_y/z`, `dis_yol_ic_z/on_z` | 14 / 16, 8 / 15, 14,72 / 15,28 | 14 / 16,6, 8,62 / 15,3, 14,77 / 15,83 |
| `ic_yol_y/z`, `ic_sur_z1` | 12 / −2,1, −0,6 | 12,12 / −1,95, −1,0 |
| `dis_kuleler()`, `dis_kule_bosluk()`, `dis_kule_tepe(x)` | ±16, 3,3, y 11 | 35,4 (+ yıkık 96,7), 10,4 (tepe basamaklarıyla), y 13,12 |
| `ic_kuleler()`, `ic_kule_tepe(x)` | ±24, y 18 | 4,7 · 66,1 · … (yan dilimler dâhil), y 19,12 |
| `dis_yol_x(x)`, `dis_yol_bos(x)`, `ic_yol_bos(x)` | `walk_x`, `|x|−16` boşlukları | gedik + kule + tepe basamakları dışı |
| `teras()`, `hendek_z0/z1/z(t)`, `hendek_dip_y()`, `ova_z0/y()` | set z 16–18,4, hendek 20–36 / −2,9, ova 36 / 0 | teras 16,6–24,8 y −3,67; hendek 26,6–46,6 / −9,55; ova 46,6 / −3,57 |
| `gecisler()`, `kosu_yolu(a,b)` | yok, düz çizgi | dolgu (x 0, en 10), kalas (x −17,9); koşu ova → dolgu → teras → hedef |
| `hucum_merdivenleri(xs, span)` | Assault'un 8 merdiveni (ayak z 18,35, tepe y 7,7) | önce sözleşmenin dayamaları, sonra eski x'ler engelden kaydırılarak (sayı aynı), dayama kuralıyla |
| `top_yuvalari(liste)` (ova koord.) | `gun_spots` | sözleşmenin 2 bataryası + aynı aralıkla iki yan (4) |
| `peribolos()`, `peribolos_engelleri()` | `SiegeChaos.area` Rect2(−44;1,4;88;10,6), — | `alanlar()["peribolos"]` (z 2,4–10,6), iç kule + poterna çemberleri |
| `depo()`, `dogus()`, `siperler()`, `top()` | `DEPOT`, `SPAWN`, `MANTLETS`, `CANNON` | (−11,5;0;4,2), (−9,6;0,05;7,2), (±5,5;0;10,5), CANNON + ova_ofs |
| `engelde(p)`, `dogma(alan, n)` | — | `SurOyun.engeller()/dogma()` çerçevede |
| `SurSet.asama_of(n)` | — | onarım sayacı 0–2 → 1, 3–5 → 2, 6–8 → 3, 9–10 → 4 (karar 5-B) |

**Kancalar (varsayılan davranış aynı):** `Assault.sur` (+ statik `Assault.ground_y` → `SurSet.etkin`, yeni set sahnesi
kurulunca dolar, ağaçtan çıkınca boşalır), `WallFight.sur` (moloz yüksekliği), `Garrison.land_walls(…, sur)` (yeni sette
`_land_walls_sur`), `SiegeField.sur_yeni` (sur uzantısı, şehir ve şehir arazisi kurulmaz), `SiegeChaos` zaten
parametreli (`area`, `avoid`). Sahne: `SurSetSahne` (gece ortamı, kesim, depo, teslim alanı, siperler, meşaleler, ova,
büyük top; `set_repair(n)` → `GedikOnarim.asama(asama_of(n))`).
