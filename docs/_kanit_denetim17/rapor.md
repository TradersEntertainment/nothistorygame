# G17 — "HAVADA DURAN HİÇBİR ŞEY OLMAZ": denetim genişletmesi (rapor)

Dal `wip/denetim17`, taban `f957694c`. Denetimlerin kodu `tests/_denetim17/denetim17.gd` dosyasında. Hud bu dosyayı
yalnız otomatik testte yükler (`Hud._denetim17`; dosya `tests/` altında olduğu için paketli oyuna girmez,
`NO_DENETIM17` ortam değişkeni denetimi kapatır).

## Özet

| Denetim | Durum | Pakette | Kalan |
|---|---|---|---|
| 1. Hayvan havada/gömük (`VISAUDIT float/sunk who=<sınıf>`) | **KISMEN** | ADAY (paketi düşürmüyor) | 26 ve 26o'da Sultan'ın atı (aşağıda) |
| 2. Görünmez zemin (`GORUNMEZZEMIN`) | **TAMAM** | KESİN (`fail=1`) | 0 (son tur sonucu aşağıda) |
| 3. İş istasyonu aleti (`ALETAUDIT`) + aşçı | **TAMAM** | KESİN | 0; aşçının kök nedeni bulundu, yeniden üretildi ve düzeltildi |
| 4. Donuk bekleme (`DONUKAUDIT`, PACE) | **KISMEN** | KESİN (8y PACE bloğu) | Bütün bölümlerin PACE taraması koşulmadı (betik hazır) |
| Kareler ve rapor | TAMAM | — | Aşçı için kare yok (sayısal kanıt var) |

## Denetimler: ölçüt ve neyi kaçırabilir

Bütün denetimler yalnız otomatik testte çalışır. Örnekleme gerçek zamanla yapılır (0,5 sn; donuk ölçümü 0,1 sn). Ekran
kararmışken (> 0,95) ve oyuncu yokken örnek alınmaz. Satırlar önce `_ADAY` ekiyle basılır. `KESIN` tablosunda açılan
tür eksiz basar ve paketi düşürür.

### 1. Hayvanlar
- **Kapsam:** "hayvanlar" grubu. `CanliKit.dugum` her canlı kökünü bu gruba ekler. Bu tek satır sınıflı (Goat, Chicken,
  Cat, Horse, Ox, ThiefGull) ve sınıfsız bütün canlıları (deve, kedi, kızak öküzü, hayat eşeği) kapsar; hipodromun
  ağlarına grup ayrıca eklendi. **Sapma:** talimat grubu sınıfların `_ready`'sine yazmayı söylüyordu; tek kurucu daha az
  değişiklikle hepsini kapsadığı için bu yol seçildi. `canli_kit.gd` sahiplik listesinde açıkça yazmıyor.
- **Ölçüt:** Her ağın yerelindeki en alçak köşeler önbelleğe alınır, dünyaya çevrilir ve en alçak nokta bulunur.
  Altındaki görünen katı zemin `Unclip.standable` ile aranır (hayvanın kendi gövdesi ve içinde başlanan katı sayılmaz).
  Fark aralıksız ≥ 1 sn > 0,15 ise havada, < −0,10 ise gömük sayılır. Oyuncunun ya da kameranın 30 m yakınında
  ölçülür, hayvan başına bir kez basılır.
- **Sayılmayanlar (gerekçeli):** uçan martı (`ThiefGull.flying`), `Gulls`, `airborne`/`no_audit` metalı, yatan öküz,
  kucakta taşınan, gemide fizik yeri bir kare geride olan. Çarpışmasız görünen bir yüzeyin üstünde duran da havada
  değildir (aşağıda "ölçüt düzeltmeleri").
- **Pişmiş hayvanlar** (`CK.bld_ekle` → `Bld.hayvan_noktalari` → "pismis_hayvan" grubu): kurulumdan 3 sn sonra bir kez,
  her ayak noktası ölçülür.
- **Kaçırabilir:** MultiMesh'e pişmiş hayvanlar (`Scenery` at ağı; phys_audit'in MMFLOAT'ı bakar). 30 m'nin dışında
  kalanlar. Ayak ucu değil gövde tabanı en alçak olan duruşlar. Bot yolunun hiç yaklaşmadığı hayvanlar.

### 2. Görünmez zemin
- **Yöntem:** `tests/phys_audit.gd`'ninki. Görünen ağlar (MeshInstance3D ve MultiMesh örnekleri; başsızda örnek
  dönüşümü `WorldWalk.inst_xf` ile) üçgen olarak ayrı bir fizik uzayına kopyalanır. Kopyalama tembeldir: yalnız sorulan
  noktayı kapsayan ağlar.
- **Ölçüt:** Oyuncu yürür kipteyken her 0,5 sn ayağının altındaki gerçek çarpışma noktası bulunur. Bu noktanın
  ±0,35 m'sinde görünen yüzey yoksa `GORUNMEZZEMIN … collider=<kaynak>` basılır (WorldWalk'ta kaynağı `_src`).
  Görünürlük her soruda yeniden denetlenir: gizlenen, kıpırdayan ya da ağı değişen kopya eskimiş sayılır.
  `Unclip.standable` kısayolu **kullanılmaz**.
- **Kapsam dışı:** merdiven, yüzme/uçuş/betik kipi, `pinned`, `floating`, kıpırdayan taşıyıcı (iki örnek arasında yer
  değiştiren gövde: 29'un gemisi, 37o'nun yalpalayan kalası), Rigid/Character/Animatable gövdeler, ilk 3 sn ve dünya
  kurulumu sürerken. Görünmez sınır duvarının üstü (ince, ≥ 1,5 m yüksek, görünmez kutu) zemin sayılmaz; bilgi satırı
  `GORUNMEZSINIR` basılır (30o'da bot kule merdiveninin başında korkuluğun görünmez duvarının üstündeydi).
- **Kaçırabilir:** saydam/su ağları görünen sayılır (bilerek gevşek). Gölgelendiricide yer değiştiren ağlar ölçülmez.
  Botun hiç basmadığı yerler (taşkın taraması `PHYS=1` ile ayrı koşuyor). 3 m'lik hücre başına tek satır basılır.

### 3. İş istasyonu aleti
- **İş noktası:** `Stage.station` her türde kökün yereline `is_noktasi`/`is_yaricap` yazar. Örneğin kazan: (0, 0,7, 0,8)
  noktası, pay 0,33.
- **Ölçüt:** Uç `t.global_transform * (0, 0, len)` ile hesaplanır; testere ve fırçada ("fwd") sap–uç doğru parçasının en
  yakın noktası alınır, çünkü ağzın tamamı işe değer. `stir` için kepçe 1 sn aralıksız kazanın dışındaysa bulgu
  sayılır; öbür türlerde 3 sn'lik pencerenin en küçük uzaklığı payı aşarsa.
- **Kaçırabilir:** `live:false` (Crowd'a pişmiş) figürler. Bunların "is_istasyonu_donuk" grubu var, ama pişmiş aletin
  ucu (`is_baked_tip`) yazılmadığı için **ölçülmüyorlar**.

### 4. Donuk bekleme
- **Ne zaman:** yalnız PACE'te (gerçek hızda), 0,1 sn'de bir.
- **Ölçüt:** Oyuncu `frozen`, ama meşru bir sebep yok. Meşru sayılanlar: `street_busy` (replik, seçim, ses),
  `is_faded`/kart, `cinematic`, `move_mode=="script"`, `pinned`, mini oyun (Drill, CannonCrew, Duel, GunDrill, Arena),
  akış şeması ve "izlenen iş". Bu durumda oyuncunun yeri ve kamerası da kıpırdamıyorsa ve süre > 4 sn ise bulgu sayılır.
- **"İzlenen iş":** 8 m içinde ve bakış konisinde, sahne betiğinin yürüttüğü (`stage_walk`) ya da işe tuttuğu (`grip`)
  biri. Gerekçe: 8y'de nöbetçinin kapıyı açması 7 sn sürüyor ve oyuncu onu izliyor; bu donup bekleme değil.
- **Pakette:** yalnız 8y PACE koşusu, kendi 900 sn bekçisiyle (`run_tests.sh`, SHARD boş ya da 3).
- **Kaçırabilir:** kamera hafifçe sallanıyorsa (bakış farkı > 0,03°) donukluk görülmez. "İzlenen iş" kuralı yakında
  yürüyen biri varken beklemeyi gizleyebilir.

## Yakalama kanıtları (geri alma yalnız `~/is/geri` eşinde; kayda girmedi)

| Bilinen hata | Geri alınca | Düzeltmeyle | Dosya |
|---|---|---|---|
| Rampa (`sur_oyun_ag.pis` tek ağ) | `GORUNMEZZEMIN_ADAY … collider=…Ahsap_KapiKopru>Toprak_KapiRampasi_Carp` | rampa satırı yok | `testler/yakalar_rampa_geri_alinmis.txt` |
| Keçi (`goat.zemin` kaldırıldı) | `VISAUDIT_ADAY float … who=Goat … gap=3.51` | 0 | `testler/yakalar_keci_zemin_kaldirilmis.txt` |
| Hasan (1,35 m/sn + `and not _hasan_walking` birlikte, PACE) | `DONUKAUDIT_ADAY … len=11.6 after=D8Y_HASAN_END` | 0 | `testler/yakalar_hasan_geri_alinmis_pace.txt`, `testler/8y_pace_duzeltmeli.txt` |
| Aşçı kepçesi (`_face_listeners` düzeltmesi geri alındı, PACE) | `ALETAUDIT_ADAY kind=stir_pot … d=0.62 pay=0.33 yaw=1.15 kok=(0,0,0) look=var` | 0 (aynı rota) | `testler/asci_yeniden_uretim_duzeltmesiz.txt`, `testler/asci_ayni_rota_duzeltmeli.txt` |

## Aşçı kepçesi: kök neden (ölçüldü)

- **Mekanizma:** `Hud._face_listeners` her replikte 4,5 m içindeki adayları alır. Ayrıca 9 m içindeki **en yakın**
  boştaki kişiyi de listeye ekler ve ona `look_target` verir. Soldier için yalnız `pose != "stand"` soruluyordu.
  İstasyon askeri `Soldier.new(coat, "stand", hat)` ile kurulur ve işi yalnız `rig.activity`'dedir, yani "boşta"
  sayılıyordu.
- **Sonuç:** Asker dönüyor. Replik bitince `_release_listeners` `look_target`'ı siliyor, ama işe dönüş kolu
  (`gaze_dir`) yalnız `look_target` varken çalıştığı için asker dönük kalıyor. Kepçe "aim" kipinde: yönü kazana bakıyor
  ama boyu 0,62 sabit, bu yüzden kepçe kazanın dışında havada kalıyor.
- **Yeniden üretim:** PACE'li bot kazanın 2 m yanından geçti ve son sahneyi kazana ~6 m uzaktan dinledi
  (`D8Y_HASAN_MARKET`, bölüm sonu repliği `D8Y_T_END`).
  - Ölçüm: gövde istasyon yönünden **1,15 rad (66°)** dönmüş; kök kaymamış (0, 0, 0), yani `plant_feet` adayı elendi;
    `look_target` var; el–hedef 1,24 m; kepçe ucu kazan merkezinden **0,62 m** uzakta (pay 0,33).
  - Sahibinin karesiyle aynı an: bölüm sonu repliği.
  - Yöneticinin üretememesinin nedeni: varsayılan bot yolu kazana 10 m'den uzak geçer, 9 m kuralına girmez.
- **Düzeltme:** `_face_listeners` Soldier'da da `rig.activity != ""` olanı atlıyor (Person için zaten öyleydi). Aynı
  rotada ALETAUDIT 0.
- **Yapılmayanlar:** talimatın önerdiği "kepçe ucu hedefe kilitlensin (`Rig.reach`)" ve `work_begin` yapılmadı, çünkü
  ölçülen kök neden dönmeydi. Kepçe boyunun sabit olması yapısal zayıflık olarak duruyor; gövde başka bir sebeple
  dönerse yine olabilir.

## Bulgu tablosu (kök nedene göre kümelenmiş)

| Bölüm | Tür | Kök neden | Düzeltme | Kanıt |
|---|---|---|---|---|
| 8y (ve sağlam kapı köprülü her kesim) | GORUNMEZZEMIN + hayvan float (tavuk 3,8 m) | Hendek geçidinde köprünün iki yakasındaki ayakların çarpışması düz ve sağlam (surlar `_build_moat`, DONMUŞ). Görünen ise kuşatmanın **yıkık** ayağı: sıra sıra 2 m'ye dek alçalıyor. Oyuncu, Hasan ve tavuk köprüye inip çıkarken 0,4-2 m havada yürüyordu. | `KapiKopru` sağlam hâlinde iki yakada tam boy taş ayak (`Tas_KapiKopruAyak`, sur taşı malzemesi). Üstü çarpışma düzleminde, aralıksız; yıkık hâlde gizli. Çarpışma ve ölçü değişmedi; sözleşme altılısı aynı. | `kare/8y_hendek_yan_once_sonra.jpg`, `kare/8y_hendek_ust_once_sonra.jpg` |
| 8y (ordugâh; batarya ve şahi topu bulunan her bölüm) | sunk (pişmiş öküz, 22 öküz, 0,22-0,42 m) | `Y._okuz` çağrılarının çoğu y=0 veriyor; öküzler düzlenmiş alanın dışında, eğimli arazide. | `_okuz` ayak noktasını `K.gy` ile zemine oturtuyor (zemin işlevi yoksa eskisi gibi). | `kare/8y_okuz_once_sonra.jpg` |
| 2 | sunk (kızak öküzleri, 0,11-0,12 m) | Takım düğümü yokuşa tek düzlem olarak oturuyor; yamacın kavisinde toynaklar gömülüyor. | Her öküz `AyakHayvan` ile kendi toynaklarının zeminine oturuyor (Goat/Ox ile aynı modül). | `slipway.gd` |
| 8y (test botu) | PACE koşusu takılıyordu (**tabanda da**) | Dış kapının eşiği görünmez çarpışma (üstü ≈ 0,17). PACE botu oyuncuyu `_gy`+0,05'e koyuyor, eşiğe gömülüp geri itiliyor, z 17,3'te 240 sn takılıyordu. | PACE adımı, kapsülün önünde yoklanan çarpışma zeminin üstüne basıyor (yalnız bot). | `testler/8y_pace_duzeltmeli.txt` |
| 8y | ALETAUDIT (aşçı) | Yukarıda. | `_face_listeners` | Yukarıda |
| 26, 26o | float (Sultan'ın atı 0,55-0,93 m) | Gediğin onarım molozu ~29° eğimli. `AyakHayvan` eğim sınırı 17° (binicinin POSEAUDIT sınırı 20°'nin altında kalsın diye). At ön toynaklarıyla havada iniyor. | **Düzeltilmedi:** eğim sınırını açmak biniciyi POSEAUDIT'e takar; yolu değiştirmek sahne kurgusunu değiştirir. | `testler/paket1/` |

## Ölçüt düzeltmeleri (denetimin kendi yanlış alarmları)

| Yanlış alarm | Örnek satır | Ölçüt düzeltmesi |
|---|---|---|
| Pişmiş öküzün zemin ışını kendi gövde kutusunun (`Bld.solid_box`) içinde başlıyordu | `VISAUDIT_ADAY sunk … who=pismis … gap=-0.60 by=…ahsap2_katı` | İçinde başlanan katı zemin sayılmıyor |
| Dünya arazisinin parçası yeniden kurulurken (hızlı testte yürüyüş kurulumdan hızlı) görünen arazi eskiydi | `GORUNMEZZEMIN_ADAY … OvaZemini … HeightMapShape3D` (`lod=-1 jobs=17`) | Dünya kuruluyorsa ve nokta `IstGeo.h`'nin ±0,35 m'sindeyse bulgu sayılmıyor; PACE'te (dünya kurulu) ova temiz. Bu kuralla rampa yine yakalanıyor |
| Arazi parçası yeni ayrıntı düzeyiyle kurulunca kopya eskiyordu | `(0,0,-7.9) Chapter8y>StaticBody3D` | Kopyanın ağı değiştiyse eskimiş sayılıyor |
| 10a'da raftaki tavuk havada görünüyordu; kare gösterdi ki etiket tahtasının üstünde duruyor | `VISAUDIT_ADAY float … who=Chicken … gap=3.53` | Ayağın 0,15 m altında görünen ağ yüzeyi varsa havada değil (çarpışmasız eşya). Bu kural 10b'de patlamayla çadırın tepesine uçan keçiyi de kapsıyor. Bölüme yanlışlıkla yapılan değişiklik geri alındı (`kare/10a_tavuk_olcut_hatasi_kanit.jpg`) |
| 29'da kıpırdayan gemi, 37o'da yalpalayan kalas | `GORUNMEZZEMIN_ADAY … Chapter29>Node3D>StaticBody3D` (gemi rotasında 6 farklı yer) | İki örnek arasında yer değiştiren gövde taşıyıcı sayılıyor |
| 8y kapı açılışında 7 sn izleme | `DONUKAUDIT_ADAY … len=7.1 after=D8Y_NIKO_RULES` | "İzlenen iş" kuralı |

Eşikler (0,15/0,10/0,35/4 sn/30 m) değişmedi.

## Paket

- **1. tur** (0-2. parçalar eski denetim koduyla, 3. parça ara kodla): bütün parçalar `fail=0`, menüye dönüş 2/2,
  `ZFIGHT` yok. Satırlar `testler/paket1/`.
- **Son tur** (son kod, 4 parça): sonuç `testler/paket2/` altında; özet bu bölümün sonunda.
- **Paket süresi önce|sonra:** 1. turda 0-2. parçalar 05:16 → 06:43-06:47, yani ~1 sa 30 dk. Aynı makinede aynı
  anda başka koşular da sürüyordu. Önceki tam paket ≈ 1 sa 50 dk. Tek koşu ölçümü: 26 → 115 sn (denetimle) | 127 sn
  (`NO_DENETIM17`); 8y → 85 | 88 sn. Fark ölçüm gürültüsü içinde, +%15 bütçenin çok altında. 8y PACE bloğu pakete
  3. parçada ~6 dk ekliyor.
- **Sözleşme altılısı** (her kayıttan önce aynı):
  - `SURSOZLESME PASS kalem=13 kesim=8`
  - `SUROYUN nokta=519 havada=0 gomuk=0 katida=0`
  - `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0`
  - `ESYATEST PASS`
  - `HALICSONDA OZET carp=661 karma=3854034809`
  - `MARMARASONDA OZET carp=1837 karma=2250736444`

## Hâlâ kötü olanlar

1. **26 ve 26o:** Sultan'ın atı gediğin moloz rampasından inerken ön toynakları 0,5-0,9 m havada (1. turda 26'da 8,
   26o'da 4 satır). Kök neden: `AyakHayvan` eğim sınırı. Hayvan denetimi bu yüzden ADAY'da kalıyor (KISMEN).
2. **Bütün bölümlerin PACE taraması** (`tests/_denetim17/pace_tarama.sh`) koşulmadı. Bölüm başına 5-15 dk sürüyor,
   65 bölüm toplam ~6-8 saat. Pakette yalnız 8y var; öbür bölümlerin donuk beklemeleri **ölçülmedi**.
3. **Donuk (pişmiş) istasyon figürlerinin aleti ölçülmüyor** (`is_baked_tip` yazılmıyor).
4. **30o:** bot kule merdiveninin başında görünmez korkuluk duvarının üstünde duruyor (`GORUNMEZSINIR`, bilgi). Gerçek
   oyuncu da merdivenden oraya çıkabilir mi, ölçülmedi.
5. **Kepçenin boyu sabit** (0,62): gövde başka bir sebeple dönerse kepçe yine kazandan çıkar. Uç kilidi yapılmadı.
6. Kızak öküzleri (Bölüm 2) için kare alınmadı. Takım kızak yolunda yürüdüğü için kare aracının sabit bakışı onları
   yakalamıyor. Düzeltme yalnız paket satırıyla doğrulandı.
