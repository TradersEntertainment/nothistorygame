# G23 — Eski dünyanın kara surları yeni kalemle: rapor

Taban `dd0f6dd1` (0.99.129) → dal `wip/sur23`. Plan: `plan.md`. Envanter sondası: `envanter_sonda.txt`.

## Ne yapıldı

- **Yeni dosya `scripts/world/ist/eski_sur.gd` (EskiSur, class_name yok).** Eski dünyanın düz sur hattını (x −578 Blakherna köşe
  kulesi … 700 Marmara) İstanbul v2'nin sur kalemiyle (`IstSurlar._run_ic`) 16 dilimde kurar. 9 sur dilimi ve 7 kapı dilimi var.
  Kapı dilimleri kalemin kapı seçenekleriyle ve aynı tohumla kuruluyor. Tuğla hatıllı taş, gerçek kule biçimleri, mazgallar,
  sur yolu ve hendek kıyıları yeni kalemden geliyor. `sur_doku` gölgelendiricisi ve v2 zemin dili de aynı.
  Böylece görsel dil tek: kutu sur kalmadı.
- **Kesit (K1).** Kalemin yereli dönüşsüz oturuyor. Kesim z 0 dünya z −1,3'e düşüyor: iç surun şehir yüzü −3,8'de, SurHub
  hizasında. dy 0. İç sur, peribolos ve dış sur sözleşme ölçüsünde: dış sur z 16,2…18,8, sur yolu y 8,5.
  Teras ve hendek seçmeli enle kuruluyor (`o["ptw"]` = 7, `o["mw"]` = 9,3):
  - hendek z 25,8…35,1 × 6 derin;
  - kıyı örtüsü z 36,0'da biter, 36'yı geçmez;
  - `ova_ofs` yok.
- **Kapılar (K2).** 7 kapı da açık ve yürünür.
  - Seçmeli açık kopya: `kapali` false, `gw` ≥ 7, `gh` ≥ 4,4, kanatsız.
  - Hendekte yeni seçmeli toprak dolgu geçit var (`o["kapi_dolgu"]`, `IstSurlar._kapi_dolgu`). Görünen ve çarpışan aynı
    dışbükey gövde.
  - Altın Kapı mermersiz açık kapı oldu; `Landmarks1453._golden_gate` kutusu yeni kalemde kurulmuyor.
- **Uçlar.**
  - Kuzey: kesik bulundu. Blakherna'nın uzak kabuğu (`FarBlachernae`) TAŞIMA-9'dan beri sur ve köşe kulesi içermiyordu.
    Katı parçalar yeni sette gizli olduğundan pişiriciye girmiyordu ve kara surları kuzeyde boşluğa bitiyordu (ÖNCE
    karesinde de böyle). `HornWorld._blak_yeni` (ek yeri) bu suru, iki köşe kulesini ve korkuluğu Blakherna kalemiyle
    kuruyor; çarpışma kabuk ölçüsünde. Dış sur, köşe kulesinin önünden bir dönüş duvarıyla kapanıyor.
  - Güney: iç surun ucunda köşe kulesi var; peribolos ve dış sur dönüş duvarıyla kapanıyor. Hendek uçlarında bölme var.
- **Hub (D9).** `ByzCity.far_hub` seçmeli `eski_yeni` bayrağıyla kurulunca:
  - kutu iç suru, kuleleri, mazgalları ve süslü kapıyı kurmuyor;
  - döşeme iç surun şehir yüzünde bitiyor;
  - iskele ve nöbet yeri kalıyor; iç sur kesintisiz.
  Kendi hub'ını eski dünyada kuran bölüm (`--eski-dunya`, test) de çifte sur kurmuyor; çıkış kapısı etkileşimi yerinde kalıyor.
- **Lykos (K5).** Dış surda x 1…19 tek açıklık var (seçmeli `gedik_w`). WallRear barikatı yeni dış sur yüzüne oturuyor (+2,5 m).
- **Rng (D11).** `_wall_extension` döngüsü kuru çekimle aynı sırayla dönüyor. Savunanlar, sancaklar (yeni iç kulelerin
  tepesinde) ve nöbet ateşleri aynı çekimlerle yeni sur yollarına oturuyor: kule, basamak ve kapı aralıkları atlanıyor,
  atlananın çekimi yine yapılıyor.
- **Sur üstü (D10).**
  - WallRear `WALK_Y/WALK_Z` ve sur işleri (ayrıntılar, kızgın yağ ocakları, merdivenler) yeni yüzlere taşındı.
  - Yağ rampası iç korkuluğun tepesine çıkıyor.
  - DroneDefense iç ve dış sur hizası 419,3 / 400,5.
- **Ayrıntı ve akış (D13, K4).**
  - lod 0 yalnız bölümün oynanış alanına 120 m'ye kadar olan dilimlerde. 43o'da drone'un alçaldığı Romanos dilimi de lod 0.
  - Öteki dilimler lod 1: pişmiş, kutu değil (kule çokgenleri, korkuluk ve diş silueti).
  - lod 2 hiç kullanılmadı.
  - lod 1 dilimler yüklemeden sonra kare başına bir dilim akışla kuruluyor (≈ 50 ms/dilim). Çarpışma kalemin gövdelerinde,
    WorldWalk'a bağlı değil; görünen ağ `no_walk`.
- **Kutu yolu (K6).** `--eskisur` (çıplak ya da bölüm listede), LandWalls'ın kendi alanı ve `--eski-kalem` (hata ayıklama)
  kutuda kalıyor. Eski kod silinmedi.
- **Harita (D14).** `tools/map_bake.gd` yeni kesitle çiziyor (kuleler kalemin yerleşiminden) ve yeniden pişirildi.
  `compare -metric AE` farkı **6583** piksel.

### Kalemdeki seçmeli anahtarlar (`surlar.gd`; verilmezse davranış bit bit aynı)

`ptw`, `mw` (`_layout`), `uc_dolgu`, `kapi_dolgu` (`_build_moat`), `gedik_w` (`_run_ic`, `_gedik`).

## Envanter (koşulardan)

```
# G23 envanter sondası: eski dünyayı (SiegeField world, yeni kalem) kuran bölüm/evreler — bölüm koşularının ESKISUR satırlarından
# sayı  bölge  bölüm  lod0(eşzamanlı)  lod1(akış)
      8 region=blachernae bolum=30 lod0=2 lod1=14
      8 region=blachernae bolum=30o lod0=2 lod1=14
      1 region=byz_aya bolum=24 lod0=0 lod1=16
     12 region=byz_aya bolum=25 lod0=0 lod1=16
      1 region=byz_aya bolum=26 lod0=0 lod1=16
      1 region=byz_aya bolum=26o lod0=0 lod1=16
      1 region=byz_aya bolum=31o lod0=0 lod1=16
      2 region=byz_aya bolum=44b lod0=0 lod1=16
     14 region=camp bolum=10 lod0=0 lod1=16
     12 region=camp bolum=10b lod0=0 lod1=16
      8 region=camp bolum=10z lod0=0 lod1=16
     14 region=camp bolum=13 lod0=0 lod1=16
      6 region=camp bolum=16 lod0=0 lod1=16
     12 region=camp bolum=24o lod0=0 lod1=16
      6 region=camp bolum=25 lod0=0 lod1=16
      8 region=camp bolum=43o lod0=1 lod1=15
     10 region=camp bolum=6 lod0=0 lod1=16
     24 region=camp bolum=9 lod0=0 lod1=16
      1 region=eyup bolum=31o lod0=3 lod1=13
      1 region=galata bolum=27 lod0=0 lod1=16
     12 region=horn_bridge bolum=18 lod0=1 lod1=15
      1 region=horn_bridge bolum=18b lod0=1 lod1=15
      1 region=horn_chain bolum=17 lod0=0 lod1=16
      2 region=horn_chain bolum=19 lod0=0 lod1=16
      1 region=horn_chain bolum=29 lod0=0 lod1=16
      1 region=horn_wall_o bolum=38o lod0=0 lod1=16
     12 region=petrion bolum=39o lod0=0 lod1=16
      1 region=slipway bolum=2 lod0=0 lod1=16
      1 region=springs bolum=17o lod0=0 lod1=16
```

Sur kameraya en yakın yerler:
- 30/30o (kuzey uç, göz hizası);
- 18/18b (köprüden ~150 m);
- 31o Eyüp evresi;
- 43o drone.
Ordugâh bölümlerinde sur 300 m+ uzakta; byz_aya, Haliç ve Galata bölgelerinde 1 km+ uzakta.

## Sayılar

**Sözleşme altılısı:**
- `SURSOZLESME PASS kalem=13 kesim=8`
- `SUROYUN nokta=519 havada=0 gomuk=0 katida=0`
- `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0`
- `ESYATEST PASS`
- `HALICSONDA OZET carp=661 karma=3854034809`
- `MARMARASONDA OZET carp=1837 karma=2250736444`

**Denetimler:**
- WORLDCHECK PASS regions=13, MAPCHECK PASS, WALKCHECK PASS.
- FLIGHTCHECK PASS. Yeni ışın: camp ve walls hub'larında 126/126 sur ışını çarpıyor.
- ZFIGHT 0: 43o, 30, 30o, 9, 10, 10b, 10z, 16, 24o, 25, 6, 18, 39o.
- menu_return PASS (26, 20o).

**Bölüm koşuları (`--max-fps 20`):** 199/200 PASS. Tek düşen 6=byz_1, paralel koşu sırasında bellek yetersizliğinden
öldürüldü. Tekrarı PASS.
- Eski dünya bölümleri bütün çeşitleriyle ×2: 6, 9, 10, 10b, 10z, 13, 16, 24o, 25, 43o, 30, 30o, 18, 39o.
- ×1: 17o, 18b, 38o, 31o, 2, 27, 44b, 17, 19, 29.
- Yeni set ve v2 ×1: 20, 26, 26o, 36b, 22o, 8y, 23, 24.

"SCRIPT ERROR" 0. VISAUDIT, WALKTHRU, HELDAUDIT, ARMAUDIT, GORUNMEZZEMIN, ALETAUDIT, DONUKAUDIT, ESYAAUDIT
(dusme/havada/gomuk/tikama/sinir) ve JOURNEY'de yeni satır yok. İstisnalar:
- 27'de `VISAUDIT float` (Galata yürüyeni) ÖNCE'de de aynı biçimde çıkıyor (2/2).
- `YUKLEMEAUDIT_KESIN` iki satır (6=byzfail ×2) bellek yetersizliği anında (toplam 150 sn). Tekrarında yok.

**D11 rng** (`tests/_ist/sur23_rng.tscn`, ÖNCE = SONRA):

| bölge | rng.state | ova/siper/ordugâh karması |
|---|---|---|
| camp | 6402249392528948907 | 511323071 |
| blachernae | −7623380617570156364 | 3345272649 |
| byz_aya | 6402249392528948907 | 1690531670 |
| landwalls | 9042686814049240346 | 984029812 |

Çoklu ağ sayısı 2 azaldı (kutu mazgal dağılımları).

**D18 bit bit aynı** (`tests/_ist/sur23_karma.tscn`): SurOyun_* sur ağı karması (yol, köşe, konum) 9 bölümün hepsinde
ÖNCE = SONRA: 20, 26, 26o, 36b, 22o, 8y, 23, 24, 31o. SURSET/SURHUB/ISTBAGLAMA satırlarında yalnız ms farkı var.
"Durgun ağ" sayısı iki kurulumda da koşudan koşuya ±1–40 oynuyor (kişi, eşya akışı); karar ölçütü sur karması.

**Yükleme (`tests/load_time.tscn`, ÖNCE | SONRA, iki koşu ortalaması):**

| bölüm | toplam ms ÖNCE | SONRA | fark |
|---|---|---|---|
| 9 | 7790 | 8050 | +260 (+%3,3) |
| 10 | 8073 | 8168 | +95 (+%1,2) |
| 30 | 8354 | 8640 | +286 (+%3,4) |
| 43o | 8162 | 8779 | +617 (+%7,6) |
| 25 (açılış evresi yeni sette) | 4890 | 5090 | gürültü |

EskiSur eşzamanlı kurulumu 336–474 ms (lod 0 dilimleri). Eski kutu `_wall_extension` 134 ms sürüyordu. Akış 14–15 dilimi
yüklemeden sonra kurar; kare başına ≈ 50 ms, YUKLEMEAUDIT_KESIN 0.

**Çizim çağrısı ve ilkel (milyon), aynı kamera, ÖNCE | SONRA** (`kare/<bölüm>_<ad>_once_ust_sonra_alt.jpg`):

| bölüm | bakış | çizim ÖNCE | SONRA | ilkel ÖNCE | SONRA |
|---|---|---|---|---|---|
| 10 | acilis | 1728 | 1730 | 1.80 | 1.80 |
| 10b | acilis | 1901 | 1901 | 2.45 | 2.45 |
| 10z | acilis | 2559 | 2533 | 3.66 | 3.67 |
| 16 | acilis | 4087 | 4074 | 3.98 | 3.98 |
| 18 | acilis | 5435 | 5391 | 7.52 | 7.63 |
| 24o | acilis | 1912 | 1919 | 2.37 | 2.37 |
| 25 | acilis | 1428 | 1426 | 2.26 | 2.26 |
| 30 | acilis | 1939 | 1939 | 3.17 | 3.18 |
| 30 | uc_dis_goz | 2133 | 2390 | 2.14 | 2.41 |
| 30 | uc_ic_goz | 5511 | 5433 | 7.23 | 7.39 |
| 30 | uc_ust | 2498 | 2508 | 1.71 | 1.74 |
| 30o | acilis | 973 | 951 | 1.75 | 1.72 |
| 30o | uc_dis_goz | 2967 | 3229 | 2.31 | 2.67 |
| 30o | uc_ic_goz | 5642 | 5560 | 7.25 | 7.39 |
| 30o | uc_ust | 3321 | 3345 | 1.95 | 1.99 |
| 43o | drone70_romanos | 1234 | 1199 | 1.59 | 1.61 |
| 43o | hub_birlesim | 3732 | 3764 | 7.28 | 7.40 |
| 43o | hub_ust | 4099 | 3990 | 6.51 | 6.52 |
| 43o | kapi_pempton | 1709 | 1559 | 1.79 | 1.75 |
| 43o | kapi_romanos | 1562 | 1785 | 1.78 | 1.88 |
| 43o | lod_gecis | 1338 | 1300 | 1.62 | 1.65 |
| 43o | olu150_goz | 1750 | 1673 | 2.61 | 2.62 |
| 43o | olu50_goz | 1248 | 1185 | 1.59 | 1.57 |
| 43o | uc_guney | 396 | 301 | 0.46 | 0.43 |
| 43o | uc_kuzey | 779 | 779 | 1.15 | 1.16 |
| 43o | uzak1km | 6190 | 6067 | 8.83 | 8.96 |
| 43o | view1 | 1344 | 1317 | 2.26 | 2.27 |
| 43o | view2 | 709 | 668 | 1.09 | 1.09 |
| 43o | view3 | 319 | 296 | 0.72 | 0.73 |
| 43o_v2 | drone70_romanos | 2452 | 2401 | 1.77 | 1.80 |
| 43o_v2 | hub_birlesim | 3909 | 3762 | 7.46 | 7.46 |
| 43o_v2 | hub_ust | 4147 | 4030 | 6.52 | 6.53 |
| 43o_v2 | kapi_pempton | 3049 | 3189 | 1.98 | 2.03 |
| 43o_v2 | kapi_romanos | 3281 | 3279 | 2.11 | 2.13 |
| 43o_v2 | lod_gecis | 2496 | 2455 | 1.86 | 1.89 |
| 43o_v2 | olu150_goz | 2522 | 2439 | 2.82 | 2.83 |
| 43o_v2 | olu50_goz | 2564 | 2481 | 1.82 | 1.79 |
| 43o_v2 | uc_guney | 443 | 358 | 0.45 | 0.43 |
| 43o_v2 | uc_kuzey | 1460 | 1460 | 1.28 | 1.28 |
| 43o_v2 | uzak1km | 6623 | 6529 | 9.03 | 9.17 |
| 43o_v2 | view1 | 2568 | 2549 | 2.46 | 2.47 |
| 43o_v2 | view2 | 1725 | 1680 | 1.24 | 1.24 |
| 43o_v2 | view3 | 450 | 419 | 0.71 | 0.71 |
| 6 | acilis | 4504 | 4506 | 2.87 | 2.87 |
| 9 | acilis | 2435 | 2434 | 2.66 | 2.66 |
| 9 | ordugah_surlar | 2402 | 2274 | 3.51 | 3.51 |

- Açılış karelerinde çizim artışı ≈ %0. En büyük artış 43o Romanos kapısı yakını (+%14) ve 30 dış uç (+%12): ikisi de
  %15 eşiği içinde.
- 43o_v2 satırları "önce bir v2 bölümü kurulmuş süreç" (D6) yolundan.

## Kanıt kareleri

- `kare/`: bütün bakışlar ÖNCE üstte, SONRA altta, aynı araçla (`tests/_ist/sur23_kare.tscn`).
  - 43o: drone70 (taze ve v2), Sultan VIEW1–3, ölü bölgeden göz hizası 50 m / 150 m, Romanos ve Pempton kapıları, iki uç,
    hub birleşmesi (göz ve üst), 1 km uzak bakış, lod 0 / lod 1 sınırı (`lod_gecis`, x 75).
  - Ordugâh bölümleri: 9 ordugâhtan surlar; 10, 10b, 10z, 16, 24o, 25, 6 açılış bakışları.
  - 30/30o: kuzey uç, göz hizası (içten ve dıştan) ve üstten.
  - 18: açılış (köprü).
  - Akış bitmeden çekilmedi: araç `EskiSurAkis`'in bitmesini bekliyor.
- Sahibe: `kare/sahip_1…4_*_once_ust_sonra_alt.jpg`:
  1. 43o drone taze;
  2. 43o drone v2 öncesi;
  3. Sultan VIEW1;
  4. Romanos kapısı göz hizası.

## Dürüst "hâlâ kötü"

- **Teras dar.** Dış kulenin önü ile parateikhion arasında 1,2 m geçit kalıyor (hendek z 36 sınırı yüzünden teras 7 m).
  Hendek 9,3 m: sözleşmenin 20 m'sinin yarısı. Kalemin hendek rampaları (dilim başına iki) yakından büyük toprak kama gibi
  okunuyor.
- **Kapılar kanatsız.** Kanat kalemin oynanış parçası (KapiKanat) ve arayüz ister. Kapılar açık ve boş; eskisinde iki yana
  yaslı açık kanatlar vardı. Altın Kapı'nın mermer cephesi (kör orta kemer) açık geçitle çeliştiği için kurulmadı.
- **Yağ ocağı rampası** iç korkuluğun tepesine çıkıyor, oradan sur yoluna iniliyor. Taşıyıcının yolu korkuluğun üstünden
  geçiyor (canlandırma).
- **Kuzey uç.** İç surun şehir yüzü Blakherna köşe kulesinin 1,6 m önüne taşıyor (köşe kulesi z −2,2'de, iç sur −3,8'de):
  kuleye yaslı kısa bir çıkıntı gibi görünüyor.
- **Marmara surları** (HornWorld, `marmara_walls`) ve Haliç surları hâlâ kutu. Kapsam kara surlarıydı; güney uçtaki köşe
  kulesinin yanında kutu deniz suru başlıyor (`43o_uc_guney`). Tek görsel dil için sıradaki iş bu.
- **lod 1 yakından.** 43o'da drone Romanos dilimi dışına alçalırsa lod 1 görür: kule pencereleri ve diş ayrıntısı yok,
  gövde aynı. Bunu kanıtlayan kare: `43o_lod_gecis`.
- **Çarpışma sondası.** D12'nin 7 kapıdan iki yönde yürüyüş ve 10 m'de bir ışın sondası ayrıca yazılmadı. FLIGHTCHECK'e
  20 m'de bir iç ve dış sur ışını eklendi (126/126), kapı geçitleri 7 kapıda dolgu gövdesiyle kuruldu. Bölüm koşularında
  takılma ya da düşme yok; ama kapıdan geçiş otomatik yürüyüşle ayrıca denenmedi.
- Kendi hub'ını `--eski-dunya` ile kuran bölümlerde süslü çıkış kapısının karanlık geçit levhası iç sur yüzüne 5 mm
  yakın. ZFIGHT bu kipte koşulmadı (varsayılan kip v2).
