# Fizik-ayak: yöntem

## Kişi (Person, Soldier, Hikmet, düellocu gövdesi) — `scripts/npc/ayak.gd`

Rig'in kurduğu duruşun (FK) **üstüne** biner; Rig.update'in sonunda, Rig.extremities'ten önce çalışır. Her karenin başında
IK'nın yazdığı değerler FK değerine geri alınır (`geri_al`: Rig ve LimbAnim değerlerini bir önceki karenin üstüne lerp'le
kurduğu için; o arada başka bir sistem yazdıysa onunki kalır).

1. **Zemin ışını** (Unclip.floor_y'nin ölçüsü: yalnız görünen/basılabilir çarpışma; görünmez sınırlar, karakterler atlanır),
   taban ortasının (bileğin 5 cm önü) altında, kökün 0,5 m üstünden 0,9 m altına. Normal de alınır (56°'den dik: düz sayılır).
2. **Kalça**: kök uzayında her ayak için kalçanın en çok ne kadar yüksekte olabileceği (bilek hedefi + √(R² − yatay²),
   R = 0,985 × (uyluk + baldır)); kalça en kısıtlayıcı ayağa göre iner (dururken ayak gömülüyse o kadar çıkar), en çok
   −0,5 / +0,4 m. Gövde **yalnız kaydırılır** (dik kalır). Yumuşatma: inerken 20/sn, çıkarken 8/sn.
3. **İki kemikli IK** (gövde uzayında): diz açısı kosinüs yasasından (uyluk L1 = dizin kalçaya uzaklığı, baldır L2 =
   bileğin dize uzaklığı; CharKit.leg: Person 0,33 / 0,255, Soldier 0,34 / 0,265), uyluk FK'nin bükülme düzlemini
   koruyan en kısa dönüşle (Quaternion(arc_from, arc_to)) hedefe çevrilir. Diz yalnız öne bükülür.
4. **Taban**: ileri eğim Rig.extremities'in bilek açısına eklenir (`ank_ek`), yanal eğim bileğin z'si (±0,4 rad).
5. **Yürüyüş kipi** (Rig yürüyüş salınımını kurduysa): Rig'in evresinden (sol ayak evre −π/2'de basar) her ayak basma
   (pay D: yürürken 0,56, hız arttıkça 0,25'e iner) ve salınım evresine ayrılır. **Basan ayak** ebeveyn uzayında sabit
   noktaya kilitlenir (kayma yok; kilit 0,6 m'yi aşarsa — yerinde dönüş — kalçanın altına alınır). **Salınan ayak**
   kalkış noktasından bir sonraki basma noktasına (şimdiki hızla öngörülür) kalçaya göre aradeğerle (sarkaç) ve
   yay (0,11–0,21 m) çizerek gider. Kalçayı yalnız basan ayak bağlar; adımın iki ucunda topuk/parmak yuvarlanması için
   yatay uzaklık 0,6 ile çarpılır. Kadans: adım boyu hızdan (0,2 + 0,2·v m, 0,28–1,2), `Rig.kadans` (eskiden 3 + 1,6·v
   rad/sn: ayak gövdenin yarı hızında geri gidiyordu, ayaklar kayıyordu).
6. **İzdüşüm kipi** (durunca, iş pozları, LimbAnim klipleri — düello duruşu): FK'nin ayak yerleri korunur, yalnız düşey:
   her ayak kendi zeminine, FK'nin kaldırdığı kadar (tekme, adım pozu) üstünde.

### Kapsam dışı (IK kapalı, Rig'in duruşu olduğu gibi)
Oturan (Rig.SEATED, `sit*`), yatan/ölü/uyuyan, tırmanan (`climb*`, `climber`), ata binen (`ride`, Horse ebeveyni),
taşınan (ebeveyn zincirinde karakter/oyuncu), uçan/yüzen/düşen, sıçrayan (`leap`), DurusKit duruşları (bağdaş, diz
üstü, çömelme…), iskeleti kilitli olanlar (Rig.lock > 0; LimbAnim ile oynatılan ayaktaki klip hariç: onun duruşunda
izdüşüm), kökü 18°'den çok eğik olanlar (devrilen), `corpse/no_ground/hologram/airborne/cameo` işaretliler, iş pozundaki
askerler (Soldier.pose ≠ stand), görünen ama çarpışmasız bir zeminin üstünde duranlar (kökün altındaki çarpışma zemini
12 cm'den alçak ve Unclip.on_mesh: ışın o zemini görmez, IK gövdeyi alttaki çarpışmaya gömerdi).

### Bütçe
- **LOD**: kameraya ≤ 28 m ve görüş konisinde (her karede ucuz koni testi; ≤ 6 m'de koni aranmaz). Uzaktakiler yarım
  saniyede bir yoklanır. Kamera kesmesinde görüşe yeni giren kişide IK anında açılır (bir önceki karede görünmüyordu);
  yürüyerek LOD sınırını geçende 0,25 sn'de yumuşak. Uzaktakiler eski yol (kök Unclip.rest_settle ile zemine oturur).
- **Işın**: dururken ayak başına bir kez (ayak 6 cm kayınca ya da 2–2,5 sn'de bir yeniden); yürürken adım başına
  (basarken bir, salınım başında iniş noktasına bir; iniş noktası 15 cm kayarsa bir daha). Kök başına seyrek bir
  "çarpışmasız zemin" yoklaması (kök 0,5 m yer değiştirince ya da 3–4 sn'de bir).
- **Düzde duran**: iki ayağın zemini kökle aynı (±1,5 cm) ve düzse IK hiçbir şey yazmaz (sonuç FK'nin aynısı).
- Kare başına ara diziler yeniden kullanılır (paketli diziler), ebeveyn dönüşümü yalnız ışın gerekince.

## Hayvanlar — `scripts/npc/ayak_hayvan.gd`
Kökle gövde arasına yalnız bu modülün yazdığı `AyakEgim` düğümü. Dört ayaklıda (at, öküz, keçi) ön ve arka ayak
çiftinin altındaki zeminin farkından gövde eğimi (en çok 17°: binicinin eğimi POSEAUDIT tilt sınırının altında) ve
yüksekliği; bacaklar eğimin tersine dönüp dik kalır. Tavuk, kedi: yalnız yükseklik. ≤ 30 m; ışın yürürken çeyrek
saniyede bir, dururken iki saniyede bir. Binici atın kökünün çocuğu kalır, yalnız yüksekliği gövdeyi izler.
Çarpışma gövdeleri (OxBody) ve kökler yerinde.

## Denetim — `scripts/npc/ayak_denet.gd` (AYAKAUDIT)
Otomatik testte yarım saniyede bir (sırayla en çok 40 kişi): kameranın gördüğü 40 m içindeki ayaktaki insanların
o an basması gereken her ayağı (dururken FK'nin kaldırmadığı ayak, yürürken basma evresinin ortası) için taban ortası
ile altındaki görünen zemin (Unclip.floor_y; taban görünen-çarpışmasız bir ağın üstündeyse fark 0, VISAUDIT float'ın
ölçüsü) arasındaki fark. |fark| > 6 cm iki ardışık ölçümde sürerse kişi-ayak başına bir satır:
`AYAKAUDIT yakin|uzak scene=… who=… ayak=L|R fark=±… d=… at=… durum=dur|yuru|anim act=… ik=w/m/pel/g`.
`yakin`: kameraya ≤ 25 m. Testi düşürmez (run_tests.sh'e eklenmedi: aşağıda istek).
