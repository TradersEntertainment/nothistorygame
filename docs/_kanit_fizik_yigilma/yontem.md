# Fizik-yığılma: yöntem

Kaynaklar (yöntemin dayandığı genel bilgi): T. Jakobsen, "Advanced Character Physics" (GDC 2001: Verlet tümlevi,
çubuk kısıtlarının yinelemeli çözümü, bez bebek); M. Müller vd., "Position Based Dynamics" (2006: konum düzeltmesi,
kütleyle ağırlıklı dağıtım, sürtünme). "Active ragdoll" (kaslı, poz izleyen) bu turda yok: ölü/yere serilen gevşek.
Godot'nun kendi katı cisim fiziği (gövde başına 10+ RigidBody3D + eklem) kullanılmadı: karakterler iskelet değil Node3D
hiyerarşisi, sahnelerin çoğu çarpışmasız görünen ağ + ayrı çarpışma (yeni sur seti) ve 8 kişilik bütçe GDScript'te
düşük parçacık sayısıyla daha öngörülebilir.

## Bez bebek — `scripts/npc/yigilma.gd`

**Parçacıklar (13)**: iki kalça, iki omuz, baş, iki diz, iki ayak bileği, iki dirsek, iki el; başlangıçta eklem düğümlerinin
dünyadaki yeri (ölüm anındaki duruş: klip, bitiricinin "saplanmış" pozu, havadaki çırpınma neyse ondan). Kütle gövdede
(kalça/omuz 3, baş 1,5, diz 1,2, ayak 0,8, dirsek 0,6, el 0,4).

**Kısıtlar**: gövde (kalçalar + omuzlar) altı çubukla katı; uzuvlar kemik boyunda (uyluk, baldır, pazu, önkol);
diz ve dirsek bükülme sınırı (kalça–ayak uzaklığı bacağın %42–100'ü, omuz–el kolun %30–100'ü); diz yalnız öne bükülür
(menteşe: diz kalça–ayak çizgisinin gövde önü tarafında); uyluk kalça ekleminin konisinde (geri ≤ ~33°, yukarı ≤ ~30°,
içe çapraz ≤ ~15°, dışa ≤ ~45°); boyun: baş omuzlara ve kalçalara aralıklı bağlı (öne/yana sarkar); iki ayak/iki diz,
el–baş en az uzaklık. Çözüm: adım başına 3 yineleme (Gauss–Seidel), aralığın içindeki çubuk kök almadan atlanır.

**Tümlev**: Verlet, 30 Hz sabit adım (karede en çok 2 adım), görüntü iki adımın arası (her karede ara değer). Yerçekimi
13 m/sn² (düşüşte oyunun düşüş ivmesi 16). Hız sönümü %0,5/adım.

**Başlangıç hızı**: gövdenin hızı (düellocunun geri savrulması `_kb`, düşüşün hızı) + darbe: darbe yüksekliğine göre
dağılır (göğüs 1,35 m: kılıç, ok/tüfek; kalça 1,1: tekme) — üst gövde çok, ayaklar az alır (ağırlık merkezinden
devrilme). Ölümde "dizler çözülür": diz öne, kalça aşağı küçük hız (tahta gibi değil, çökerek). Patlama/düşüşte gövde
ekseni çevresinde dönüş.

**Zemin**: GÖRÜNEN zeminin yükseklik ızgarası (0,25 m hücre), hücre ilk gerektiğinde bir ışınla (yukarıdan aşağı;
Unclip.standable ölçüsü; yeni sur setinde `dusus_her_kati` sahnesinde her StaticBody3D, düellocunun düşüşü gibi).
İçinden başlanan görünen katı ve dik yüz (normal y < 0,5) **duvar** sayılır. Çift doğrusal ara değer (basamak, duvar
dibi gibi 12 cm'den büyük sıçramalarda kendi hücresi: keskin kenar rampaya dönmez). Kare başına bütün yığılanlar için
en çok 10 yeni ışın; ışınlanmamış hücreye parçacık o adım yatayda girmez.
- **Duvar**: hücrenin zemini parçacığın altından yüksek ve son zemininden 10 cm'den fazla yüksekse yatayda geçilmez
  (taşın, basamak yüzünün, korkuluğun içine girmez; üstündeyse üstüne düşer).
- **Kenar**: yere indikten sonra ayağın altı birden 60 cm'den çok iniyorsa ya da zemin yoksa geçilmez (ceset sur
  yolunun, molozun, set kenarında kalır; sarkmaz).
- **Gövde küreleri** (göğüs, karın; r 0,2): merkezleri omuz ve kalça noktalarının ağırlıklı ortası; gömülürse düzeltme
  kaldıraçla dağılır (gövde döner, dik oturup kalmaz).
- **Sürtünme**: zemine değen parçacığın yatay hızı adım başına %25 azalır; yere değiş anında düşey hız sıfırlanır.

**Düşüş (kenardan atılan, merdivenden düşen)**: iki evre. Havada bez bebek kökü (düellocu / asker) izler — kökün yolu,
duvarlar ve su kökün kendi ışınlarıyla çözülür (oynanış aynı) — bez bebek kökün çevresinde döner, kollar ve bacaklar
çırpınır (rastgele değişen itmeler). Kök yere inince (düellocuda `_fall_land`, askerde kökün düşüşü durunca) gövde kökün
üstüne alınır, kökün son hızıyla zemine çarpar ve yığılır.

**Bitiş ve donma**: uyku (15 adım boyunca hiçbir parçacık 2,5 mm/adımdan hızlı değil; en erken 0,45 sn) ya da süre
(2 sn; düşüşte inişten sonra ~2,9 sn; merdivenden düşen askerde 1,1 sn, çünkü Assault cesedi 2,2 sn'de batırıp yeniden
kullanıyor). Son oturtma: her parçacığın ve gövde küresinin altına tam ışın (uzvun 0,6 m üstünden), yerçekimi gibi
inme/çıkma + kısıt 14 yineleme, sonra hiçbiri gömük kalmasın. Sonra işlem durur: düğümler o duruşta kalır, kök (düellocu)
kalçanın altına taşınır (gövde yerinde), kan lekesi ve ceset sayacı eskisi gibi.

**Görüntü**: gövde düğümü katı gövdenin dönüşümüyle (sağ = kalça+omuz ekseni, yukarı = kalçadan omza), kol/bacak
eklemleri uzuv yönleriyle (LimbAnim._limb'in kurgusu: omuz/kalça ekseni üst uzva, dirsek/diz bükülme açısı), baş boyun
parçacığının yerine taşınır ve boyun yönüne döner. Rig.lock tutulur, LimbAnim durur, Person/Soldier'ın gövde sallanması
(`_body.rotation.z`) yığılan bedende yazılmaz.

**Kalkma (tekmeyle yere serilen)**: aynı bez bebek, donunca kilit kalır; `DOWN_LIE` dolunca kök kalçanın altına ve
ayakların yönüne alınır, yerdeki duruşun uzuv yönleri LimbAnim'in harman belleğine (`_cur`) yazılır ve eski kalkış klibi
("Roll" 0,8'den) başlar: klip yerdeki gerçek duruştan harmanlanarak kalkar (eskiden yatış klibinin son karesinden).

**Bütçe**: aynı anda en çok 8; sınır doluyken yeni gelen eski yoldan (klip). Merdivenden düşen asker yalnız kameranın 30 m
içinde ve görüşündeyse (uzaktakiler eski yol). Işın bütçesi kare başına 10. Uykudaki bedende görüntü yazılmaz.

## Kancalar
- `Duelist.collapse` (ölüm, bitirici, yerdeyken saplama) → `_yig_olum`: darbe yönü `_kb`'den ya da vurandan uzağa.
- `Duelist.fall_off` → havada izleyen bez bebek; `_fall_land` → `indi`; `_fall_splash` → `durdur` (gövde kökle batar).
- `Duelist.knock_down` → bez bebek (kök `_kb` ile kayar: kenardan düşüş aynı) → `_yig_kalk` (DOWN_LIE'de).
- `_freeze` (ceset): bez bebekte `_lift_over_ground` yok (gerek yok); eski yolda YIGILMAAUDIT `klip` etiketiyle.
- `Soldier.shot` / `Person.shot` (Handgun._down'ın zaten sorduğu yöntem): tüfekle vurulan atıcıdan uzağa yığılır, eski
  devrilmenin süresinde (2,45 sn) gizlenir; kapalıyken Handgun'ın eski devrilmesi birebir.
- `Assault._climber_step`: düşüş başında `baslat` (LOD 30 m), yeniden tırmanışa dönerken `birak_kisi`.
- `Rig._activity "fall"`: havada savrulma duruşu (kişiye göre evre/genlik; zaman durunca o anda kalır: Bölüm 0 donma karesi).

## Denetim — YIGILMAAUDIT
Otomatik testte her yığılmanın sonunda (bez bebek: donunca; eski yol: `_freeze`'de) cesedin baş (r 0,2), gövde (göğüs ve
karın, r 0,2), eller (r 0,05) ve ayakların (bilek, r 0,07) altındaki görünen zemine uzaklığı (uzvun 0,6 m üstünden 1,8 m
aşağıya ışın; aynı katı ölçüsü). Havada > 8 cm ya da gömük > 8 cm ise kişi başına bir satır:
`YIGILMAAUDIT fizik|klip scene=… who=… at=… bas=+0.12 el_l=-0.10 …`. Testi düşürmez.

## Ölçüm — YIGPERF (`--yig-olc`)
10 sn'de bir: kare başı işlem süresi (Performance.TIME_PROCESS), yığılmanın kare başı µs'si, ortalama ve en çok aynı
anda yığılan, en kalabalık karede yığılma µs'si ve o karenin işlem süresi.

## Ayak IK kalanları — `scripts/npc/ayak.gd`
- **Dik moloz yüzü** (taban ortasının altındaki yüz > 56°): topuk ve burun altına iki ışın daha; taban ikisinin
  arasına yatar (±0,6 rad), yükseklik iki ucun ortası (sınırda yüksek ucu taşa girmez; ortası çıkıksa ortaya basar).
- **Yokuş aşağı hızlı koşu**: basan ayak kökün altındaysa kalçanın adım ucundaki yuvarlanma payı 0,6 → 0,9'a çıkar
  (kalça yetişecek kadar iner).
- İkisi de `--yigilma=0` ile kapalı (ÖNCE ölçümü).
