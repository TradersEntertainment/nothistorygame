# DURUŞ — eklemli oturma/yatma/iş duruşları (dal `wip/ist2-durus`)

Sahibinin sözü: **"bu eğilen karakterler çok kötü duruyor"** (`docs/_kanit_ist2_ordugah5/ilk/cadir_buyuk_25m.jpg`,
`ocak_yeniceri_1_1.jpg`, `ocak_anadolu_4_1.jpg`). Kök neden: ocak başındaki "uyuklayan", "kazan karıştıran",
"kazan/kürek işçisi" kişiler Rig'in eski `doze`/`stir`/`dig` işleriyle kuruluyordu; bu işler gövdeyi (bacaklar
gövdenin çocuğu olduğundan BACAKLARLA BİRLİKTE) bütün hâlde yatırıyor: kişi dimdik bir kukla gibi çapraz duruyor,
ayakları havada kalıyordu.

## 1. ÖNCE | SONRA

ÖNCE kareleri, aynı dalın kodundan duruş kayıtları (`a5b2a403`, `8d7f652a`) geri alınmış depo dışı bir kopyayla
(`~/calisma/once`), SONRA kareleri bu dalın koduyla, **aynı poz dosyasıyla aynı kameradan** çekildi
(`tests/_ist/ordugah5_kare.tscn --poz=…`). Sahibinin karesi önceki turda çekilmişti; o günden beri ORDUGÂH-5 çadır
düzenini değiştirdiği için birebir aynı kare yeniden üretilemedi: aynı sonda işlevinin (`_cadirlar`, `_ocaklar`) bugün
seçtiği aynı tür bakış kullanıldı.

| Pafta | Ne var |
|---|---|
| `01_once_sonra_oba_25m.jpg` | 25 m'den oba (`cadir_buyuk_25m` kamerası); altta ocak bölgesinin 2,4× büyütmesi. ÖNCE: uyuyan kişi kütüğün üstünde 45° çapraz, havada; aşçı dimdik. SONRA: uyuyan yerde sırtüstü (baş altında bohça), aşçı belden eğik, oturan bağdaş kurmuş. |
| `02_once_sonra_ocak_6m.jpg` | İki ocak başı 6 m'den (yeniçeri 1_1, anadolu 4_1). ÖNCE: sol arkada uyuyan çapraz havada, aşçı dimdik çubuk. SONRA: uyuyan yere yatmış, aşçı kalçadan bükülüp kepçeyle kazana uzanıyor, ayakları yerde. |
| `03_sonda_alti_temel_asker.jpg` | Nötr zeminde sonda (yeniçeri): bağdaş, diz üstü, çömelme, yan uzanma, sırtüstü yatma, kazan karıştırma; her biri yandan ve önden, 3 m. |
| `04_sonda_alti_temel_sivil.jpg` | Aynı altı duruş, uzun kaftanlı sivil (etek uyluklara bağlı). |
| `05_sonda_gecis_ayakta_bagdas.jpg` | Ayaktan bağdaşa geçiş, 6 kare (zamanlaması bozuk: bkz. 2. başlık). |
| `06_sonda_crowd_pismis.jpg` | Ordugâhın donmuş kalabalığı (Crowd pişirmesi) aynı duruşlarla: bağdaş, kâseden yiyen, diz üstü, çömelen, sırtüstü, yan uzanan, kazan karıştıran, sırtını yüke dayamış. |
| `07_once_sonra_sehir.jpg` | Şehirden beş yakın kare ÖNCE \| SONRA: tabureye oturan, çamaşır yıkayan, dilenci, sur dibi işçi, iskelede balıkçı. |
| `08_sonda_diger_duruslar.jpg` | Diğer 12 duruş (ateşe üfleme, tek diz, kütüğe oturma, sırtı dayalı, yemek, bileme, yazma, eyere oturma, odun atma, balta, kürek, yük kaldırma). |

## 2. Kendi karelerime bakınca hâlâ kötü olanlar

- **Sivil (uzun kaftan) bağdaşta etek** (`04`, sol üst iki kare): etek artık bacakların içinden geçmiyor ve yere
  gömülmüyor (ölçüm −1,1 cm), ama kucak kısmında eteğin İÇ yüzü koyu lacivert bir leke gibi görünüyor; kucak
  "kumaş" değil "koyu kutu" okunuyor. KISMEN.
- **Sivil diz üstü / çömelme** (`04`): etek dizlerden aşağı dimdik sarkıyor; önden "çuval" gibi. Kukla değil ama
  güzel değil. KISMEN.
- **Geçiş dizisi** (`05`): ilk kare bile neredeyse oturmuş: xvfb'de kare yakalama 160 ms'lik aralığı tutturamıyor.
  Geçişin ~0,7 sn olduğu koddan (`durus_kit.gd:uygula`, kb = 1−e^(−4,6·dt)) biliniyor, karede KANITLANAMADI. KANITSIZ.
- **Şehir** (`07`): dilenci bağdaşta önden "gövdesi yere gömülmüş büst" gibi okunuyor (bacaklar eteğin altında,
  ölçümde gömülme yok, ama görüntü öyle). Oturan (tabure) ve işçi (taş kıran) karelerinde kamera 3 m önden;
  duruş farkı ÖNCE'ye göre zor seçiliyor. KISMEN.
- **25 m karesi** (`01`): kişiler küçük; duruş farkı yalnız büyütmede net. Uzak katmanda oturan/yatan sade siluetler
  var (`ordugah_kisi.gd` `govde_otur/diz/yat/egil`), ama bu karede uzak katman seçilemiyor.
- **anadolu 4_1 ocağı** (`02` sağ alt): ÖNCE'de sağda kütüklerin üstünde yatan uyuyan, SONRA'da çadırın arkasında
  kalıp görünmüyor (yere yattığı için alçaldı); kare onu göstermiyor.
- Birleştirme sonrası (ORDUGÂH-5 karo düzeni) çadır yerleri değişti; `01`/`02` birleştirme ÖNCESİ koddan.
  Birleşik kodun ocak kareleri ayrıca çekildi (bkz. 6. başlık), paftaya konmadı.

## 3. Maddeler

### A. Ortak duruş takımı — KISMEN
- `scripts/npc/durus_kit.gd` (class_name yok; Rig'den `preload`): 27 duruş, kökü YATIRMADAN: gövde kalçadan
  bükülür, bacak ve kollar iki kemikli IK ile hedef noktalara (ayak bileği/avuç) uzanır, ayak tabanı hedef yöne
  döner. DÜZELDİ (kare `03`, `04`, `08`).
- Bu oturumda düzeltilenler:
  - **Etek** (`_etek`, `_etek_mesh`): kaftanın kalça altı kısmı UYLUKLARA BAĞLANDI (her köşe x'ine göre sol/sağ uyluğun
    dönüşünü alır, diz altı yerçekimiyle sarkar, zemin altına inen köşe zemine serilir). Önceki sürümde sivil
    bağdaşta etek 31 cm yere gömülüyor, diz üstünde çan gibi açılıyordu. DÜZELDİ (gömülme) / KISMEN (görünüm, 2. başlık).
  - **Ayak bileği** (`bilekler`): `extremities()` her karede bileği kendi açısına yazdığından takım her karede küçük
    bir adım atıyor, taban hiç hedefe oturmuyordu (diz üstünde ayak ucu 5–11 cm yere giriyordu). Takımın bilek açısı
    ayrıca tutuluyor. DÜZELDİ (ölçüm: diz üstü −11,5 → −1,3 cm).
  - Tek diz, taş kırma, ateşe üfleme hedefleri (arka ayak, eller, kalça) zemine göre ayarlandı.
- Canlılık (nefes, ağırlık değiştirme, baş çevirme, iş eli hareketi) `_hedef` içinde her duruşta var: KANITSIZ
  (tek kare hareketi göstermez).
- Eğimli zemin: hedefler kökün yereline göre; kök arazi yüksekliğinde. Eğimde kalça/diz zemine değiyor mu ölçülmedi:
  BAKILMADI.
- Kıyafet/başlık gövdeye girmez: etek düzeldi; başlık ve kuşak için ayrı denetim yok: KANITSIZ.

### B. Uygula — KISMEN
- Ordugâh (`ordugah_kisi.gd` TIP tablosu): otur→`bagdas`, otur2→`bagdas_ye`, aşçı→`kazan_kar`, kazma→`kazma`,
  balta→`balta`, bileyen→`bagdas_bile`, uyuyan→`sirt_uzan`, namaz→`diz_ustu`, kâtip→`bagdas_yaz`, esir→`diz_ustu`.
  Kişi sayısı, yeri, türü, kıyafeti aynı. DÜZELDİ (kare `01`, `02`).
- Uzak figür: duruş türüne göre beş sade siluet (ayakta/bağdaş/diz/yatan/eğik). **Bu oturumda bulunan hata:** önceki
  oturumun tek ağ birleştirmesi Packed dizileri dizi içinde "as" ile genişletiyordu (değer türü: kopyaya ekleniyordu),
  ağ boş kalıyor ve uzak katmanda kişiler HİÇ çizilmiyordu (her obada `array_len == 0` hatası, ordugâh kurulumunda 193
  satır). Düzeldi: hata 0. ORDUGÂH-5'in yeni karo yolu (`_kur_parcali`) birleştirmede duruş türlü siluete bağlandı
  (eskiden "oturan" = y'si %58 basık dik çubuk). DÜZELDİ (hata sayısı) / KANITSIZ (uzak siluetin karesi yok).
- Şehir (`hayat_yakin.gd`, `hayat_yakin_govde.gd`): tabureye oturan→`otur_tabure`, çamaşırcı→`camasir`,
  dilenci→`bagdas`, balıkçı→`bagdas_olta`, sur işçisi→`tas_kir`/`yuk_kaldir`; donuk ikiz aynı duruşla. KISMEN (kare `07`).
- Gövdeyi yatıran satır: bu dosyalarda kişi köküne `rotation.x/z` veren satır kalmadı (`grep`); eski Rig işleri
  (doze/stir/dig) artık bu kişilerde kullanılmıyor.

### C. Oyun geneli tarama — KISMEN (tablo 5. başlıkta)

### D. Denetim — DÜZELDİ (eksikleriyle)
- `POSEAUDIT tilt <kişi> <derece> <iş> (<üst üst>/<üst>)` (`rig.gd:_egim_denet`): her canlı Rig'de 0,5 sn'de bir,
  kişi başına bir kez. Hariç: işler `fly, hover, swim, fall, dead, lie, sleep`; AÇIK LİSTE `EGIM_SERBEST_SAHNE`:
  `wall_fight.gd` (yanan asker yüzüstü düşer) ve `chapter26.gd` + `giustiniani` (vurulup sırtüstü düşer, sedyeyle
  taşınır). İkisi de Bölüm 26 koşusunda denetimin bulduğu satırlardı (9 + 1); ikisi de görevde sayılan "bilinçli
  düşme/taşınma" türünde.
- `POSEAUDIT ground <kişi> <duruş> <cm>` (`durus_kit.gd:_zemin_denet`): duruş yerine oturunca gövdenin pişmiş
  parçalarının en alçak noktası; oturan/yatan ±6 cm, ayaktaki iş −6 cm.
- Sonda (27 duruş × 2 kişi + geçiş + kalabalık): `POSEAUDIT` 0 satır. Önceki oturumun kodunda 17 satırdı (−31 cm'ye
  kadar).
- Eksik: denetim yalnız canlı Rig'i görür. Pişmiş kalabalık (Crowd/MultiMesh) kopyalarının köküne verilen eğim
  (ör. `siege_chaos.gd:411` yüzüstü ceset) denetlenmiyor. KISMEN.

## 4. Duruş listesi (`DurusKit.ADLAR`)
Oturma: `bagdas`, `bagdas_ye`, `bagdas_bile`, `bagdas_ok`, `bagdas_yaz`, `bagdas_ekmek`, `bagdas_olta`, `diz_ustu`,
`ates_ufle`, `comel`, `tek_diz`, `tas_kir`, `otur_kutuk`, `otur_sandik`, `otur_eyer`, `otur_tabure`, `sirt_dayali`.
Yatma: `yan_uzan`, `sirt_uzan`. Ayakta iş: `kazan_kar`, `odun_at`, `balta`, `kazma`, `yuk_kaldir`, `su_ic`,
`at_timar`, `camasir`. Var olan Rig işlerinin (sit_ground, doze, stir, dig…) davranışı değişmedi (yalnız ekleme).

## Dokunulan işlevler (dosya:satır, bu dalın son hâli)
- `scripts/npc/rig.gd:169 update` (bilekler çağrısı), `:182–194` sabitler (`DurusKit`, `DURUS_SURUM`, `EGIM_SERBEST`,
  `EGIM_SERBEST_SAHNE`), `:199 _egim_denet` (yeni), `:350–353 _update_core` (takıma yönlendirme). Yalnız ekleme.
- `scripts/npc/durus_kit.gd` (yeni): `uygula:59`, `birak:83`, `bilekler:108`, `_hedef:136`, `_uygula_hedef:379`,
  `_etek:489`, `_etek_tak:526`, `_etek_mesh:534`, `_props*:598–740`, `_zemin_denet:753`.
- `scripts/world/ist/ordugah_kisi.gd`: `TIP` tablosunun duruş sütunu (:24–38), `kur:52` (uzak figür ağı),
  `fig_tur:112`, `_ekle:124`, `_kur_parcali:150` (yalnız uzak figür seçimi :176–199), `figur` yeni siluetler.
- `scripts/world/ist/hayat_yakin.gd`: `_spawn_edge:977,984,990`, `_spawn_fisher:1051`, `_spawn_quay:1177`,
  `_spawn_wall:1305` (yalnız duruş adı). `hayat_yakin_govde.gd:twin_mesh:315` (yalnız duruş adı).
- `scripts/level/siege_chaos.gd:_vignette:381–386`, `scripts/world/wall_rear.gd:_tents:252`, `_drill_yard:365`,
  `_aid:479–485`, `scripts/world/rear_life.gd:_wake:115` (önceki oturum).
- Sonda: `tests/_ist/durus_kare.gd` (`_parca_min` parça bazında zemin ölçümü; ışık düşürüldü).

## 5. C: eski bölümler tablosu

| Yer | Ne | Durum |
|---|---|---|
| `level/siege_chaos.gd:381` (_vignette 0) | yaralı: ayakta kalıp `-PI/2` yatırılmış → `sirt_uzan` | YENİ DURUŞA GEÇTİ (önceki oturum) — KANITSIZ (karesi yok) |
| `world/wall_rear.gd:479` (_aid) | sedyedeki yaralı: ayakta kalıp yatırılmış → `sirt_uzan` | GEÇTİ — KANITSIZ |
| `world/wall_rear.gd:252, 365, 485` | `sit_ground` → `bagdas` | GEÇTİ — KANITSIZ |
| `world/rear_life.gd:115` | canlanan figür yeni duruşu alır | GEÇTİ — KANITSIZ |
| `level/siege_chaos.gd:411` (_vignette 4) | yüzüstü ceset: kök `+PI/2`, poz `dead` | YAPILMADI (bilinçli ölü; Crowd kopyası, denetim görmez) |
| `level/battle_extras.gd:286` | ceset: kök ±PI/2, `dead` | YAPILMADI (bilinçli ölü, `dead` hariç listede) |
| `level/assault.gd:502–505` | merdivenden düşen tırmanıcı, `fall` | YAPILMADI (bilinçli düşme) |
| `level/wall_fight.gd:303` | yanan asker yüzüstü düşer | YAPILMADI (bilinçli düşme; açık listede) |
| `chapter26.gd:1197` (_carry_pose) | Giustiniani vurulur, sırtüstü taşınır | YAPILMADI (bilinçli taşınma; açık listede) |
| `chapter2.gd:1041` | Hüseyin ateşe eğilir: `body.rotation.x = 0.32` (bacaklar da 18° yatar) | YAPILMADI — kolu sahne kodu `Rig.reach` ile sürüyor; `kazan_kar`'a geçirmek kol sürmesiyle çakışır, kare alınamadı |
| `chapter2.gd:1033` | Hikmet `body.rotation.x = 0.06` (3°) | gerek yok (fark edilmez) |
| `level/slipway.gd:2798, 2838` | kadırga iten askerler `body.rotation.x = 0.32/0.5` | YAPILMADI — itişte gövde çizgisi bilerek eğik, ayaklar `Stage.plant_feet` ile kızağa basıyor |
| `level/stage.gd:319` (grip_hold lean) | tutarken öne eğilme | YAPILMADI (ortak araç; çağıranlar çok) |

Bu oturumda eski bölümlerden kare ALINMADI: bu maddeler KANITSIZ'dır.

## 6. Test ve performans
- Ayrıştırma: `PARSECHECK PASS scripts=339` (birleştirmelerden sonra).
- Başsız (`--max-fps 20`), ORDUGÂH-5 + CANLI birleştirmesinden SONRA: Bölüm 7, 7 next, 11, 11 next, 0, 2, 2 next, 9,
  12b, 20, 26 → 11/11 `AUTOTEST PASS`; `SCRIPT ERROR`, `WARN_*`, `VISAUDIT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`,
  `LOOKAUDIT backturn`, `JOURNEY_*`, `POSEAUDIT`: 0 satır. (Bölüm 7 ve 11'in `tests/run_tests.sh`'deki varyantları
  yalnız varsayılan ve `next`.)
  Birleştirme öncesi koşu: 7, 7 next, 11, 11 next, 0, 2, 2 next, 9, 12b, 20, 26, 16, 16 next, 36b: hepsi
  `AUTOTEST PASS`, yasak satır 0; 26'da `POSEAUDIT tilt` 10 satır → açık listeyle (bilinçli düşme/taşınma) 0.
- Performans: oyunun RINFO satırı ÖLÇÜLMEDİ (KANITSIZ). Sondanın kendi sayacıyla aynı dört kamerada ÖNCE → SONRA
  (birleştirme öncesi aynı taban): çizim 644→626, 420→412, 862→819, 749→733; üçgen 3,04→2,99 M, 3,91→3,88 M,
  7,08→6,90 M, 9,52→9,47 M. Çizim artmadı, üçgen azaldı.
- Kalabalık pişirme önbelleği: `Crowd._cache_path` `durus_kit.gd`'yi tuzlamıyor; duruş takımı değişince diskte eski
  pişmiş duruş kalıyordu. `rig.gd`'ye `DURUS_SURUM` sabiti eklendi (rig.gd tuzlanır); takım değiştikçe artırılmalı.
  **ORTAK DOSYA ÖNERİSİ** (`scripts/npc/crowd.gd:98`): tuz listesine `"res://scripts/npc/durus_kit.gd"` eklenmeli.
