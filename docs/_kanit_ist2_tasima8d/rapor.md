# TAŞIMA 8D — 26o tırmanış takılması, sur yolu fıçıları, Bölüm 26 iç içe geçmeler

Dal `wip/ist2-tasima8d` (taban `wip/ist2-taban15` = aec59c9f). Godot 4.4.1 resmi, başsız, `--max-fps 20`, 4 süreç aynı anda,
tam süzgeç (`AUTOTEST (PASS|FAIL)|SCRIPT ERROR|VISAUDIT|WALKTHRU|HELDAUDIT|ARMAUDIT|WARN_FX|WARN_FLY|WARN_VOID|
^ESYAAUDIT (dusme|havada|gomuk|tikama|sinir)`). Süzülmüş satırlar `testler/` altında (ham günlükler silindi).
Kök nedenler geçici tanı satırlarıyla (`TMP8D …`, kaldırıldı) gösterildi; o satırlar aşağıda alıntılandı.

## Özet

| Bulgu | Durum | Kök neden (kısa) | Düzeltme |
|---|---|---|---|
| 1. 26o tırmanış bitmiyor | **TAMAM** | `Ladder.top_exit()` mazgal eşiğinin (korkuluğun) ÜSTÜNE bırakıyordu (y 10,03; sur yolu 8,62); bot merdiven tepesine bakıp W'ye bastığı için eşikten merdivene geri yürüyüp yeniden tutunuyordu; 40 sn yedeği her kare eşiğe ışınlıyordu | 26o'nun merdiveni `SurMerdiveni` (tepe çıkışı sur yolu ZEMİNİ); bot tepede merdivene bakmaz; yedek ışınlama tek sefer; eşikte/dişte duran gerçek oyuncu 1,5 sn sonra bir kez sur yoluna |
| 2. 26o sur yolu fıçıları geçidi tıkıyor | **TAMAM** | 26o dekor patlamaları eski koordinatla yeni surun gövdesinde/sur yolunun altında; `EsyaFizik._patlama` siper bilmiyordu: korkuluğun ardındaki fıçılar uyanıp yolun ortasına savruluyordu | Patlamada siper kuralı (`_siperde`); 26o patlamaları dış yüze; dar geçitte yavaşlayan gövde yakın duvara yaslanır. Sondanın bulduğu iki uyanış kusuru da düzeltildi (aşağıda) |
| 3. Bölüm 26 iç içe geçmeler | **TAMAM** | (a) öldürme kamerası ve dövüşte ayaklandırma kişileri gizliyor, gizliyken yürüyenler (dost düellocu, `Unclip.spread`, yerinde adım) onları saymıyor; (b) kargaşada koşanlar ve 4. savaş şeridi yedek bölüğün içinden geçip askerleri itiyor | (a) `_dostlari_dagit` kamera dönünce; kamera bekçisi ve göründü-bekçisi; (b) yedek bölük askerleri kargaşanın yolsuz alanında, 4. şerit bölüğün dışında |

## Sözleşme üçlüsü ve deney sahnesi (son kod)
```
SURSOZLESME PASS kalem=13 kesim=8
SUROYUN nokta=519 havada=0 gomuk=0 katida=0
WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0
ESYATEST PASS
PARSECHECK PASS scripts=364
```
Deney sahnesinin ölçüleri eşya fiziği raporundakiyle aynı: tekme fıçı 0,74 m yan yatık; eğimde dz 15,86 / dy −2,62; merdivenden
dy −1,38; patlama uyanan 6; `uyanan=33 patlama=22 en_cok_uyanik=12 sorun=0`.

## 1. Bölüm 26o: tırmanış döngüsü

### Kök neden (günlük)
`_wall_climb` döngüsüne yarım saniyede bir durum satırı eklendi (`TMP8D t pos lad lt floor vel`). `turgut_bad` ×4 (4 süreç):
3/4 81–91 sn PASS (`CLIMB t=11.9`, `t=18.9`), **1/4 300 sn'de bitmedi**. Bitmeyen koşu:
```
TMP8D t=10.5 pos=(10.24, 8.81, 17.53)  lad=true  lt=12.87 floor=true            ← merdivende, tepeye 1,3 m
TMP8D t=11.1 pos=(10.24, 10.03, 16.05) lad=false lt=14.19 floor=true vel=(0,0,-2.0)   ← Ladder.top_exit: y 10,03
TMP8D t=11.6 pos=(10.24, 10.12, 16.83) lad=false floor=true vel=(0,0,3.2)       ← bot +z'ye (merdivene) yürüyor
TMP8D t=14.6 pos=(10.24, 9.53, 17.33)  lad=true  lt=13.62                       ← yeniden tutundu
… (12 sn boyunca aynı salınım) …
TMP8D t=817.6 pos=(10.24, 9.82, 16.3)  lad=false floor=true                     ← t > 40: her karede top_exit
```
- **(a) Bot neden çıkamıyordu:** çıkamamak değil; 11 sn'de tepeye varıyordu. `Ladder.top_exit()` = tepe − öne 0,7 m. Merdivenin
  tepesi sur yolunun 1,5 m üstünde (`dayama_ust_pay`), bu nokta mazgal açıklığının **eşiğine** (korkuluğun üstü, sur yolunun
  1,2–1,4 m yukarısı) düşüyordu. Taşıma 8'in koşulu (`is_on_floor` ve `y < dis_yol_y + 0,5`) eşikte sağlanmaz. Bot her karede
  `point_at(_ladder_t + 2)` = merdivenin tepesine bakıp W bastığı için eşikten merdivene doğru yürüyor, merdivenin alanına girip
  yeniden tutunuyor, tepede yine eşiğe çıkıyordu. Bazen çıkıştaki −z hızıyla eşikten sur yoluna düşüp bitiyordu (PASS koşuları
  `CLIMB at=(10.2, 8.6, 15.8)`); düşmezse 40 sn sonra yedek **her karede** eşiğe ışınladı: zemine hiç inmedi, sonsuz döngü.
  Taş/yağ beklemesi, mazgal dişi (`_mazgal_x` doğru açıklığı veriyor: x 10,2) neden değil.
- **(b) Gerçek oyuncu:** aynı çıkış oyuncuyu da eşiğe koyuyordu; ileri yürüyen iner (biter), geri yürüyen merdivene yeniden
  tutunur, eşikte duran bekler (döngü takılmaz ama sahne ilerlemez).

### Düzeltme (`scripts/chapter26o.gd`)
- Yeni sette merdiven `SurMerdiveni extends Ladder` (bölüm içi sınıf): `top_exit()` = merdivenin x'inde **sur yolunun zemini**
  (`dis_yol_y + 0,05`, `dis_yol_on_z`). `Player` tepede `ladder.top_exit()`'i çağırdığından oyuncu mazgal açıklığından geçip
  sur yoluna basar. `ladder.gd`/`player.gd` değişmedi. Eski sette düz `Ladder` (aynı).
- Döngü koşulu `_tirmandi()`: merdivende değil, dış surun içinde, yerde ve sur yolunun 0,5 m içinde (eski sette eskisi gibi).
- Eşikte/dişte (`_sur_ustunde`: sur yolunun 0,5–4 m üstü, dış surun z aralığı, merdivenin ±6 m'si) yerde duran 1,5 sn içinde
  kendisi inmezse **bir kez** merdivenin sur yolu çıkışına konur (`CLIMB ustten` satırı).
- Bot tepede (merdivende değil, sur yolu yüksekliğinde) W'yi bırakır, merdivene bakmaz.
- 40 sn yedeği **tek sefer** (`CLIMB yedek` satırı): oyuncu merdivenden ayrılır, sur yolu çıkışına konur.

### Gerçek oyuncu sondası (`--autotest=dis_in | dis_dur | esik_dur`)
Merdivenden çıkınca oyuncu dişin/eşiğin üstüne konur (ışınla bulunan en yüksek nokta):
| Sonda | Ne yapar | Sonuç |
|---|---|---|
| `dis_in` | dişin üstünden (10,84; 9,82; 16,38) sur içine yürür | 0,7 sn'de sur yoluna atladı, döngü kendiliğinden bitti (`ustten=0`), PASS |
| `dis_dur` | dişin üstünde dikilir | 1,5 sn sonra bir kez sur yoluna kondu (`ustten=1`), PASS |
| `esik_dur` | mazgal eşiğinde (10,24; 9,82; 16,38) dikilir | 1,5 sn sonra bir kez sur yoluna kondu (`ustten=1`), PASS |

## 2. Bölüm 26o: sur yolu fıçıları

### Kök neden (günlük)
ÖNCE (yalnız bulgu 1 düzeltilmiş kod, 26o 5 çeşit ×2): `lose_2`
`ESYAAUDIT tikama_gecit tur=fici id=23 at=(-11.2,8.9,15.1) zemin=8.63`; on koşuda `uyanan` 1–12, nedeni hep `patlama`
(`tekme=0 kosu=0 itme=0`). Patlamalara tanı satırı (`TMP8D patlama p= c=`): hepsi 26o `_process`'in dekor patlaması
`Vfx.explosion(walls, (x −14…18, y 2…8, z 14…20))`. Bu eski setin koordinatı (dış sur z 14–16, boy 8); yeni sette dış sur
z 15–16,9, sur yolu y 8,62: patlama **surun gövdesinin içinde, sur yolunun altında**. `EsyaFizik._patlama` yalnız uzaklığa
bakıyordu (r = 3 m): korkuluğa yaslı fıçılar uyanıp patlama merkezinden uzağa, sur yolunun ortasına (−z) savruluyor, orada
donunca denetim itip `tikama_gecit` yazıyordu.

### Düzeltme
- `esya_fizik.gd` **siper kuralı** `_siperde`: patlamanın ateş topundan (+0,5 m) eşyanın merkezine ve üstüne iki ışın; ikisi de
  durağan bir katıya (eşya olmayan; katının içinden başlayan ışın da sayılır) çarparsa eşya uyanmaz (`siper=` sayacı, OZET
  satırının sonunda). Kayıtlı eşyanın uyurkenki katısı ve yığın kutusu `esya_statik` işaretlidir: siper sayılmaz.
- `chapter26o.gd`: dekor patlamaları yeni sette aynı oranla dış surun **ova yüzüne ve önüne** (y teras…sur yolu, z dış yüz + 0,2…).
- `esya_fizik.gd` **donma/yaslanma kuralı**: dar geçitte (sur yolu) yavaşlayan (< 0,8 m/sn) gövde yolun ortasında kalacaksa
  yakın duvara doğru sürtünmeyi az aşan kuvvetle kayar/yuvarlanır; duvara değince kuvvet kalkar, orada donar (`yasla=`). Denetimin
  ölçüsü (`_gecit_yan`, eşik 0,75 m) değişmedi; yarı en artık gövdenin o eksendeki gerçek yarı eni (`_yari_en`: enine yatan fıçı
  boyu kadar yer kaplar).

### Sondanın bulduğu iki eşya fiziği kusuru (yeni sonda `tests/_ist/tasima8d_tekme.tscn`)
Sonda bölümü oyunun açılışıyla açar, dış sur yolundaki üç stauroma dizisinin uçtaki fıçısını gerçek `Player.kick` ile tekmeler:
(1) dizinin dışından boyuna, (2) iç yandan korkuluğa doğru, (3) yeniden boyuna; (4) dizinin ikinci fıçısı yolun ortasına
savrulur (gülle itkisi benzetimi). İlk koşuda:
1. **Uyanan gövde fırlıyordu**: (4)'te fıçı ilk fizik adımında `v=(−54, 2.5, 48)`, açısal `(−70, 87, −53)` ile korkuluğun
   üstünden ovaya, **269 m** öteye. Kök: GodotPhysics yeni gövdenin kütle/eylemsizliğini bir adım sonra işler (dosyadaki notta
   yazılı, itkiler bu yüzden bekletiliyordu); o ilk adımda korkuluğa ve komşusuna değen gövde (uyurkenki katı 0,29 m, gövde
   0,31 m: korkuluğa 3 cm, tekmeyle kaymış komşuya birkaç cm girer) dev bir dönüşle fırlıyordu. Şekilden açık eylemsizlik vermek
   düzeltmedi (dönüş 366 rad/sn'ye çıktı). **Düzeltme:** gövde ilk iki fizik adımı donuk (durağan) kurulur, 2. karede çözülür,
   bekletilen itkiler 3. karede uygulanır (çözülmenin güncellemesi de bir adım sürer; 2. karede uygulanınca açısal itki boşa
   gidiyor, deney sahnesinde fıçı devrilmiyordu). Ayrıca kurulurken kesişen gövde temas çiftlerinin ortalamasıyla kesişmenin
   dışına konur (`_kesisme_ayir`; çift sırası ölçüldü: küre-kutu 0,1 m iç içe → `[(1,0,0), (0.9,0,0)]`, kayma ikinci − birinci).
   Sonrası: ilk adım hızı tam itkinin verdiği 1,55 m/sn, dönüş yok, savrulma 0,2–0,9 m.
2. Sondanın kendi ölçüm hatası (tekme hareketi oyuncuyu geri çekerken ışın oyuncuya çarpıyordu) düzeltildi.

### Sonda sonuçları (son kod; `testler/tekme_sonda.txt`)
| Bölüm | (1) tekme boyuna | (2) korkuluğa | (3) yeniden | (4) savrulma | Denetim | Sonuç |
|---|---|---|---|---|---|---|
| 26o, 20, 22, 26, 37o | 0,03–0,25 m kaydı, iç yanında 1,04–1,09 m | 0,01–0,04 m, 1,08 m | 0,01–0,26 m, 1,06–1,09 m | 0,85–0,94 m, fıçı devrildi, iç korkuluğa yaslandı (0,03–0,08 m) | 0 | PASS ×5 |

## 3. Bölüm 26: iç içe geçmeler

### Kök neden (günlük)
Geçici izleyici (`T8D_IZLE`: 0,25 sn'de bir görünür herkesin konumu, 0,35 m'ye üç kez giren çiftin son 3,5 sn izi):
- **`SPK_DEFENDER|Duelist`** (`isidore`, ÖNCE 12 koşuda 1): `VISAUDIT overlap a=Chapter26(SPK_DEFENDER) b=Duelist at=(-3.2, 0.4, 11.5)`.
  İz: savunucu k 187–190 **görünmez** (kayıt yok), dost düellocu (team 0, IDLE) aynı aralıkta (−3,5; 11,1) → (−3,1; 11,75).
  Hemen önce `FINISHER` (öldürme kamerası): `duel.gd _killcam_occlusion` kadrajı kapatanları gizler. Dalga biter bitmez
  `_dostlari_dagit()` → `Unclip.spread(d, 0.6)`; `Unclip.crowded` gizliyi saymaz: düellocuyu gizli savunucunun 0,27 m dibine
  koydu; kamera bitince ikisi görünür, iç içe.
- **`WallFight{chop}|Duelist`** (`hold_box`, 12 koşuda 1, yukarıdaki düzeltmeden sonra): `at=(2.6, 0.5, 11.6)`. İz: onarımcı
  (2,65; 11,65) k 366–370 gizli; dövüşen dost düellocu (st WINDUP) 3,5 → 2,55 adım attı (`Unclip.blocks_step` de gizliyi
  saymaz). Aynı mekanizma, başka yürüyen.
- **`Squad|Squad`** üç ayrı yoldan:
  1. *İtilme* (izli koşu): yedek bölüğün bir askeri evinden (z 5,4–6,6) adım adım 2–3 m uzağa itilmiş:
     `(-17.65, 4.55) → (-17.9, 4.4) → (-18.35, 3.95) → (-18.7, 3.7)`. Kargaşada koşanların yolu (`SiegeChaos._clear_line`) bir
     insandan yalnız 0,6 m uzak tutulur; yürüyen (`Person._clear_way`) 0,7 m'deki ayaktakini yana iter.
  2. *Şerit bölüğün içinde* (son kodun ilk doğrulamasında yakalandı): `VISAUDIT overlap a=@Node3D@28567 b=@Node3D@28567
     at=(24.6, 0.0, 6.0)` (`hold_box`; ikinci `Squad` düğümünü Godot `@Node3D@…` diye yeniden adlandırır). Taşıma 8'in
     yerleşiminde BattleExtras'ın dördüncü şeridi (z 5,4–5,6, en 1,6 → z 4,7–6,3) ikinci yedek bölüğün (24; 7,4) arka
     sırasının (z 6,2) **içinden** geçiyordu.
  3. *Ayaklandırılıp geri gelen* (`isidore`): `RALLY scene=chapter26.tscn allies=5 cands=13` → `WAVERUNNER … won` → hemen
     ardından `VISAUDIT overlap a=Squad{crouch} b=Squad{crouch} at=(-20.1, 0.0, 5.1)`. `melee.gd _raise`: ayaklandırılan
     asker dövüş boyunca gizlenir; komşusunun yerinde adımı (`reserve_loop._step`, `Unclip.crowded` gizliyi saymaz) onun
     evine girer; `_tick_return` dövüş bitince askeri evinde yeniden görünür yapar → iç içe.

### Düzeltme (`scripts/chapter26.gd`; kamera, düellocu, Unclip, reserve_loop değişmedi)
- `_dostlari_dagit`: oyuncunun kamerası dönene (gizlenenler geri gelene, en çok 6 sn) kadar bekler; çağıran beklemez (akış süresi
  aynı).
- **Kamera bekçisi** `_kamera_bekci`: kamera oyuncuya her döndüğünde (bir kare sonra) oyuncunun 30 m çevresinde, denetimin
  saydığı ayakta duranlardan 0,4 m'den yakın çiftin yürüyenini (düellocu; yoksa `no_yield` olmayanı) `Unclip.spread` ile boş yere
  ayırır (`BEKCI26 ayir` satırı). Sürekli bir "iç içe temizleyici" değil: yalnız gizleme biten anda.
- Yedek bölüklerin her askeri kargaşanın kaçınma listesinde (1,3 m: itme erimi 0,7 + yerinde adım 0,4 + pay); bölüğün önünde ve
  ardında peribolosun geçişi açık.
- Dördüncü savaş şeridi bölüğün güneyine: (21…31; 3,6), en 1,2 (arka sıradan 1,5 m; batı ucu poterna fıçılarının yuvarlandığı
  yerin ötesinde).
- **Göründü-bekçisi** `_gorunce_ayir`: gizlenebilen kişiler (yedek bölükler, savunucu sırası, onarımcılar, taşıyıcılar)
  yeniden görünür olunca 0,5 sn sonra yanlarında hâlâ 0,4 m'den yakın ayakta duran varsa yürüyeni ayrılır (`BEKCI26 gorunce`;
  yanından geçen, evine koşan geçicidir; denetim 1 sn ister).

## ÖNCE | SONRA

| Bulgu | ÖNCE (koşu / bitmeyen / denetim) | SONRA (koşu / bitmeyen / denetim) |
|---|---|---|
| 1. 26o bitmeyen | yönetici: `turgut_bad` 5'te 2 ×2 set; benim: `turgut_bad` 4 / 1 / 0 | 26o 5 çeşit ×5 = 25 / **0** / 0 (`CLIMB t=11,0–11,3`, yedek ve "üstten" ışınlama hiç gerekmedi; en uzun koşu 84 sn); sondalar `dis_in`, `dis_dur`, `esik_dur` ×1 PASS |
| 2. 26o `ESYAAUDIT` | 10 / 0 / 1 (`tikama_gecit`), uyanan 1–12 (patlama) | 26o 25 / 0 / **0** (`uyanan=0`, `siper=` 0–9); sur yolu fıçılı 20 (7 çeşit), 22, 26 (31 koşu), 37o: denetim 0; tekme sondası 5 bölüm PASS |
| 3. 26 iç içe (`hold`,`isidore`,`hold_box`) | yönetici ~1/15; benim 24 izsiz + 12 izli (bulgu 3 düzeltmesinden önce): 36 / 0 / 1 (`SPK_DEFENDER`); `_dostlari_dagit` düzeltmesinden sonra 12 / 0 / 1 (`chop`) | `hold`, `isidore`, `hold_box` ×8 = 24 / 0 / **0**; öteki 11 çeşit ×2 = 22 / 0 / 0 (bekçiler 24 koşuda 8 kez ayırdı: `BEKCI26`) |

## Çeşit tabloları (son kod)
#### 26 (yeni set; `hold`, `isidore`, `hold_box` ×8, öteki çeşitler ×2)
| Çeşit | Koşu | PASS | Bitmeyen | Denetim | Süre (sn) |
|---|---|---|---|---|---|
| hold | 8 | 8/8 | 0 | 0 | 65–74 |
| hold_box | 8 | 8/8 | 0 | 0 | 64–75 |
| isidore | 8 | 8/8 | 0 | 0 | 103–112 |
| candle | 2 | 2/2 | 0 | 0 | 115–118 |
| council_bad | 2 | 2/2 | 0 | 0 | 109–118 |
| council_ok | 2 | 2/2 | 0 | 0 | 108–108 |
| def | 2 | 2/2 | 0 | 0 | 130–132 |
| hold23 | 2 | 2/2 | 0 | 0 | 75–80 |
| hold3 | 2 | 2/2 | 0 | 0 | 73–77 |
| hold_lose | 2 | 2/2 | 0 | 0 | 98–101 |
| kasim | 2 | 2/2 | 0 | 0 | 111–121 |
| lighter | 2 | 2/2 | 0 | 0 | 113–114 |
| nophoto | 2 | 2/2 | 0 | 0 | 130–132 |
| warn_notrust | 2 | 2/2 | 0 | 0 | 114–118 |

#### Eski set
| Çeşit | Koşu | PASS | Bitmeyen | Denetim | Süre (sn) |
|---|---|---|---|---|---|
| e26 | 1 | 1/1 | 0 | 0 | 104–104 |
| e26o | 1 | 1/1 | 0 | 0 | 92–92 |

#### 26o (yeni set, ×5, 4 süreç)
| Çeşit | Koşu | PASS | Bitmeyen | Denetim | Süre (sn) |
|---|---|---|---|---|---|
| def | 5 | 5/5 | 0 | 0 | 78–81 |
| lose | 5 | 5/5 | 0 | 0 | 69–70 |
| nophoto | 5 | 5/5 | 0 | 0 | 80–82 |
| turgut | 5 | 5/5 | 0 | 0 | 80–82 |
| turgut_bad | 5 | 5/5 | 0 | 0 | 80–84 |

#### Bağımlı bölümler (×1)
| Çeşit | Koşu | PASS | Bitmeyen | Denetim | Süre (sn) |
|---|---|---|---|---|---|
| 0 | 1 | 1/1 | 0 | 0 | 18–18 |
| 1 | 1 | 1/1 | 0 | 0 | 18–18 |
| 17o | 1 | 1/1 | 0 | 0 | 21–21 |
| 18 | 1 | 1/1 | 0 | 0 | 18–18 |
| 18b | 1 | 1/1 | 0 | 0 | 24–24 |
| 2 | 1 | 1/1 | 0 | 0 | 29–29 |
| 20_def | 1 | 1/1 | 0 | 0 | 42–42 |
| 20_hit | 1 | 1/1 | 0 | 0 | 42–42 |
| 20_idle | 1 | 1/1 | 0 | 0 | 83–83 |
| 20_late | 1 | 1/1 | 0 | 0 | 50–50 |
| 20_lose | 1 | 1/1 | 0 | 0 | 52–52 |
| 20_niko_idle | 1 | 1/1 | 0 | 0 | 65–65 |
| 20_tape | 1 | 1/1 | 0 | 0 | 44–44 |
| 20o | 1 | 1/1 | 0 | 0 | 44–44 |
| 21 | 1 | 1/1 | 0 | 0 | 17–17 |
| 22 | 1 | 1/1 | 0 | 0 | 17–17 |
| 22o | 1 | 1/1 | 0 | 0 | 44–44 |
| 25 | 1 | 1/1 | 0 | 0 | 24–24 |
| 28o | 1 | 1/1 | 0 | 0 | 22–22 |
| 29 | 1 | 1/1 | 0 | 0 | 37–37 |
| 30 | 1 | 1/1 | 0 | 0 | 39–39 |
| 30o | 1 | 1/1 | 0 | 0 | 57–57 |
| 31o | 1 | 1/1 | 0 | 0 | 60–60 |
| 32o | 1 | 1/1 | 0 | 0 | 45–45 |
| 36b | 1 | 1/1 | 0 | 0 | 37–37 |
| 37o | 1 | 1/1 | 0 | 0 | 77–77 |
| 38o | 1 | 1/1 | 0 | 0 | 66–66 |
| 6 | 1 | 1/1 | 0 | 0 | 20–20 |
| 8y | 1 | 1/1 | 0 | 0 | 28–28 |

`menu_return --chapter=26`: `MENURETURN PASS from=res://scenes/chapter26.tscn` (orphans 0).


## Hâlâ kötü olanlar
0. **Son kodla değil, ara ölçümlerde birer kez görülenler** (son doğrulamanın 103 koşusunda yinelenmedi; kaynak benim
   dosyalarımın dışında, düzeltilmedi): `VISAUDIT insolid who=Duelist at=(-4.2, 0.3, 13.9) by=Mesoteikhion` (26 `hold`, ham
   günlük saklanmadan silindi; bekçi o koşuda çalışmamıştı: gedik kenarında dövüşen düellocu surun iç yüzüne 4 cm girmiş);
   `WARN_FX_STUCK scale=0.82 base=3.00` (26 `hold`: iki öldürme kamerası ve bir fırlatma art arda, `fx.gd` yavaşlatma
   zinciri 6 sn'yi aştı).
1. **Savrulan fıçı enine yatınca** (yalnız sondanın gülle benzetiminde; oyunda gülle siper yüzünden sur yolu fıçısına değmiyor,
   oyuncu tekmesi devirmiyor): iç korkuluğa yaslanıyor ama karşısındaki stauroma dizisiyle arasında **0,65–0,74 m** kalıyor
   (denetimin 0,75'i "yaslanacak yer kalmadı" diye saymıyor). Dikey eksende torkla yolun boyuna çevirmek denendi: fıçı korkuluk
   ile dizi arasında dönemedi, 9 sn sınırında zorla donup denetime düştü (`tikama=3`); kaldırıldı.
2. **Bekçiler belirtiyi kapatır, gizleme mekanizmasını değil**: gizlenen kişiyi saymayan yürüyenler (`Unclip`) benim
   dosyam değil; bölüm, gizleme bittiği anda ayırıyor (aşağıdaki istek 1 kökten çözer).
3. **Kök neden benim dosyalarımın dışında kalanlar** (bölümde çevresinden dolanıldı): öldürme kamerasının gizlediği kişiyi
   `Unclip.crowded/blocks_step` saymıyor (`scripts/combat/duel.gd`, `scripts/npc/unclip.gd`); `reserve_loop._step` hedefi yalnız
   adımın başında denetliyor; `SiegeChaos._clear_line` insandan 0,6 m geçiyor ama yürüyenin itme erimi 0,7 m.

## Başka dosyaya istek
1. `scripts/npc/unclip.gd` (`crowded`, `blocks_step`): öldürme kamerasının gizlediklerini (`duel.gd _fin_hidden`) saysın (ör.
   `Duel` gizlerken `set_meta("fin_hidden", true)`, Unclip bu işaretliyi görünür say). Bugün her bölümde aynı risk var.
2. `scripts/npc/reserve_loop.gd` `_step`: tween sürerken hedefe başkası girerse dursun (ya da hedefi bölükte ayırtsın).
3. `scripts/level/siege_chaos.gd` `_clear_line`: insandan geçme payı 0,6 → `Person._clear_way` erimi (0,7) + 0,2.
4. `scripts/level/ladder.gd`: `top_exit()` sur gibi kalın korkuluklu yüzlerde eşiğe düşüyor; çağıran bölüm bir "çıkış noktası"
   verebilsin (26o'da alt sınıfla çözüldü). 30o/38o'nun yeni set taşımasında aynı tuzak var.

## Değişen dosyalar
| Dosya | Değişiklik |
|---|---|
| `scripts/chapter26o.gd` | `SurMerdiveni` (tepe çıkışı sur yolu zemini), `_tirmandi`, `_sur_ustunde`, bot tepede, yedek tek sefer, sonda çeşitleri (`dis_in`, `dis_dur`, `esik_dur`), dekor patlamaları dış yüze |
| `scripts/chapter26.gd` | `_dostlari_dagit` kamera dönünce, `_kamera_bekci`/`_ic_ice_ayir`/`_ayrilan`, `_gorunce_ayir`/`_yakin_ayir`, yedek bölük askerleri kargaşanın kaçınma listesinde, 4. savaş şeridi (21…31; 3,6) |
| `scripts/level/esya_fizik.gd` | `_siperde` (patlamada siper), `esya_statik` işareti, `_gecit`/`_gecit_yan`/`_yari_en`, dar geçitte yaslanma, uyanışta donuk ilk adımlar + itkiler 3. karede, `_kesisme_ayir`, OZET satırına `siper= yasla=` |
| `tests/_ist/tasima8d_tekme.gd/.tscn`, `tasima8d_tekme_sonda.gd` (yeni) | sur yolu tekme sondası |
| Dokunulmayan | `surlar_ayrinti.gd` (fıçı kaydı değişmedi), `garrison.gd`, `wall_fight.gd`, `siege_chaos.gd`, `assault.gd`, `sur_set*.gd`, görünüş dosyaları, `scripts/player/`, `scripts/npc/`, `scripts/combat/` |
