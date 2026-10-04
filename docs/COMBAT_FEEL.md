# Dövüş hissi: tekme, bitirici, ölüm

Kılıç dövüşünde (hikâye düelloları 20, 20o, 21o, 22o, 26, 26o, 29, 30, 30o, 37o ve Sonsuz Kuşatma) tekmenin ve
bitiricinin "oturması", ölen askerin yerde ölü kalması için yapılan araştırma ve verilen kararlar.
Kod: `scripts/combat/duel.gd` (oyuncu tarafı, öldürme kamerası), `scripts/combat/duelist.gd` (rakip: sendeleme,
yere serilme, ölüm, ceset), `scripts/npc/limb_anim.gd` (iskelet klipleri), `scripts/npc/person.gd` (`dead_face`).

## Araştırma: başkaları nasıl yapıyor

- **Assassin's Creed II / Brotherhood / Revelations**: karşı saldırı ve "kill streak" bitiricileri bağlama göre seçilir
  (silah, düşmanın yönü, düşman yerde mi). Kamera bitiricide kısa bir an yan açıya ve yakına geçer, sonra
  kendiliğinden döner; oyuncu bir şey yapmaz. Düşman bitiricide gerçekten ölür ve ceset yerde kalır. Tekme
  (Brotherhood) kalkanlı ve muhafızı sağlam düşmanı açar: düşman geriye sendeler, kolları açılır, sonra tek darbe.
- **For Honor**: muhafız kırma → sendeleme → idam (execution). Duvara itilen düşman çarpar ve daha uzun sersem kalır
  ("wall splat"). İdam sırasında yakındaki öbür düşmanlar saldırmaz.
- **Ghost of Tsushima**: ağır vuruşta çok kısa donma (hit-stop), ardından ağır çekim; ölümcül darbede ses neredeyse
  kesilir, tek bir keskin darbe sesi kalır (müzik kısılır).
- **Skyrim** (birinci şahıs oyunda bitirici): son düşmanda birinci şahıstan kısa bir üçüncü şahıs "kill cam"e geçer,
  sonra birinci şahsa döner. Bizim oyun birinci şahıs olduğu için en yakın örnek bu.
- **Oyun hissi kaynakları** (Vlambeer "The Art of Screenshake", Steve Swink "Game Feel", Masahiro Sakurai'nin
  hit-stop anlatımları, GDC "Juice it or lose it"): her darbe üç evrelidir: **beklenti** (hazırlık, okunur poz) →
  **darbe** (60–100 ms donma, sarsıntı, görüş darbesi, parçacık, katmanlı ses) → **takip** (savrulma, toparlanma).
  Ses katmanları: tok gövde sesi (alçak perde) + bas/ağırlık + malzeme (metal kalkan, çelik) + hışırtı.
  Ölüm: ragdoll yoksa bile "son poz" yere oturmalı; ölü kıpırdamamalı (nefes, göz kırpma yok).

## Kararlar

### Tekme (F)
- **Beklenti 0,14 sn**: kamera ~4° yukarı (geriye yaslanma), kılıç kolu dengede yana açılır, kalkan dışarı, bacak
  toplanır; kumaş hışırtısı.
- **Darbe**: bacak öne-aşağı açılır (ayak rakibin karnı hizasında), 70–90 ms donma (`Fx.hitstop`), sarsıntı, 4–6°
  görüş darbesi, kamera hafif yatar, göğüste ve ayakta toz. Ses: `land_thud` (tok) + `drum_boom` (bas) + kalkanlıysa
  `kick_metal`; müzik bir an kısılır. Oyuncu yarım adım öne.
- **Rakip**: geriye ~1,2 m sarsak adımlarla savrulur (`Idle_Shield_Break`, gövde geriye eğik), kalkanı yana savrulur.
  Arkası duvarsa çarpar: gümleme, toz, daha uzun sersemlik. Uçurumdan atma yok (güvenli değil: sur yolu, gedik).
- **Yere serme**: rakip saldırı hazırlığındayken (kırmızı ok dolarken tekme = karşı hamle), zaten sendelerken ya da
  canı %35'in altındayken tekme onu sırtüstü yere serer (`Hit_Knockback`), sırtı yere çarpınca toz ve gümleme, ~2 sn
  yatar (yerdeki bitirici penceresi), sonra kalkar (`Roll` klibinin son yarısı).

### Bitirici (E) — bağlama göre dört hamle
| Durum | Hamle | Rakip |
|---|---|---|
| Yerde yatıyor | **ground**: üstüne eğilip aşağı saplama | yerde son bir sarsılma, kalır |
| Tekmeyle sendeliyor | **thrust**: öne atılıp gövdeden saplama | kılıca saplı iki büklüm, kılıç çekilince geriye yığılır |
| Nişan sol/sağ (A/D) | **slash**: o yandan kesiş | darbeyle döner, başı geri savrulur, yığılır |
| Nişan yukarıda | **bash**: kabzayla yüze, sonra yerdekine saplama | sırtüstü düşer, yerde ölür |

- **Öldürme kamerası** (~1,5 sn): dövüşün açık olan yanından, göğüs hizasında, darbeye doğru yavaşça yaklaşan kamera;
  oyuncunun üçüncü şahıs ikizi (fotoğraf modundaki model) kılıç ve kalkanla hamleyi yapar. Darbe anında 100 ms donma,
  ~0,5 sn %28 ağır çekim, kamera ofset sarsıntısı, koyu kırmızı toon kan (damlalar + kısa buğu, abartısız), ekran
  kenarı koyu kırmızı. Kamera hamleden sonra birinci şahsa döner, oyuncu ikizinin bitirdiği yerde ve cesede bakar.
- **Atlanabilir**: öldürme kamerası sırasında sol tık / F / E / devam tuşu hemen bitirir (rakip yine ölür).
- **Hiç takılmaz**: bütün beklemeler oyun zamanıyla ve "atla / düello bitti / sahne kapandı"da hemen döner; kamera
  yalnız hâlâ bizimkiyse geri verilir (bölüm bu arada kendi kamerasına geçtiyse dokunulmaz); oyuncunun `frozen`
  durumu ve HUD sinematik durumu önceki değerine döner. Son rakipte zafer akışı kamera bitene kadar bekler.
- **Birinci şahıs yedeği**: dar yerde (kameraya 1,8 m açık yer yoksa ya da rakip görünmüyorsa) ya da hareket
  hassasiyeti ayarı (fx = 0) açıksa hamle birinci şahısta kılıç pozlarıyla oynanır.
- Bitirici sürerken öbür rakipler saldırmaz (hazırlık bozulur, beklerler).
- Hikâye düellolarında normalde rakip teslim olup geri çekilir; **bitiriciyi oyuncu seçtiyse rakip gerçekten ölür**.

### Ölüm ve ceset
- **X X gözler** (`Person.dead_face`): gözlerin yerine iki koyu çarpı, ağız düz çizgi; kişinin işlemi kapanır
  (nefes salınımı, göz kırpma, sohbet, bakış durur).
- Kılıç ve kalkan elden düşer, yere yatar (metal tıngırtısı).
- Ölüm klibi bitince **ceset zemine oturur**: kök yerden ışınla bulunan zemine, eğimde zemin normaline (en çok ~25°),
  en alçak uzuv tam zemine (ne gömülür ne havada); gövdenin altında moloz/basamak varsa üstüne kalkar. Sonra
  animasyon, yapay zekâ ve bütün işlem durur. Altında yavaşça büyüyen koyu kırmızı leke.
- Çarpışma yok: oyuncu cesede takılmaz (`no_block`).
- Cesetler dövüş boyunca kalır; sahnede en çok 8. Fazlası (en eskiler) oyuncunun görüşünden çıkınca yere batıp silinir.

## Düzeltilen hata: yere düşen asker yerin dibine giriyordu ve kıpırdıyordu
- **Sebep 1 (gömülme)**: `LimbAnim` gövdeyi **ayak tabanından** döndürüyordu, üstüne kalça oranıyla gövdeyi 0,9 m
  aşağı indiriyordu. Sırtüstü pozlarda (Hit_Knockback, Death01) belden aşağısı zeminin altına giriyordu.
  Şimdi gövde **kalçadan** döner; kalça yüksekliği = klibin kalça oranı × bacak boyu. Ek olarak hiçbir pozda uzuv
  zeminin altına inmez (`ground_mode = 1`), yerde yatarken en alçak uzuv tam zemindedir (`ground_mode = 2`).
- **Sebep 2 (kıpırdama)**: savuşturma sendelemesi bile `Hit_Knockback` (sırtüstü düşme) oynatıyordu; asker yerde
  yatarken her karede oyuncuya dönüyordu (yerde fırıl fırıl), 1 sn sonra yatar pozdan ayağa "ışınlanıyordu".
  Şimdi sendeleme ayakta (`Idle_Shield_Break`), yere serilme ayrı durum (DOWN): yatarken dönmez, yürümez, sonra
  gerçekten kalkar. Savrulma zemini izler (`_ground_y`) ve duvarları dinler (`_walk`).
- **Sebep 3 (ölü kıpırdama)**: ölünce `Person._process` (nefes salınımı, göz kırpma) sürüyordu; şimdi ceset donar.

## Zaman ölçeği ve testler
- Donma ve ağır çekim yalnız `Fx` üzerinden: Fx bölümün yazdığı ölçeği (testte 2,5–3×) taban sayar, etki bitince
  tabana döner, sahne değişince sıfırlar, 6 sn'den uzun süren etkiyi kendiliğinden kapatır. `Engine.time_scale`'e
  doğrudan dokunulmaz.
- Otomatik test botu tekmeyi kalkanlıya ve (her ikinci tekmede) savuşturmayla sersemleyene kullanır, bitirici
  dört hamlenin hepsini dener; testte `KICK result=…` ve `FINISHER kind=… cam=…` satırları basılır.
