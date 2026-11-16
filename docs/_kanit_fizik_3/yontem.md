# Fizik-3: yöntem

## 1. 37o eski set gerilemesi (ayak IK) — `scripts/npc/ayak.gd`, `scripts/npc/rig.gd`

Kök neden iki parça (günlük: [`gunluk/m1_37o_eskisur_kok_neden.txt`](gunluk/m1_37o_eskisur_kok_neden.txt)):

1. **Bayat IK yazımı.** Bölüm 37o'nun ip çeken üç azabı (`_haulers`, `no_rally,no_talk`) kanca takılınca `pose = "haul"`a
   geçer. Soldier bu pozda `Rig.update`'i çağırmaz (yalnız `Rig.extremities`): ayak IK'nın her karenin başında yaptığı
   geri alma (`Ayak.geri_al`) da, kapsam denetimi de çalışmaz. IK'nın son karede yazdığı gövde inişi (`pel` −0,15 ya da
   +0,11) ve bacak yan açıları donup kalır. Bölüm her karede `Stage.plant_feet(s, _floor_y)` çağırır: en alçak tabanı
   zemine değdirecek kadar **kökü** kaydırır → kök bu bayat inişin tersi kadar havada (−0,17'de, zemin −0,32: VISAUDIT
   float) ya da gömük (VISAUDIT sunk). `--ayak-ik=0` ile IK hiç yazmadığından 0/3.
   **Düzeltme:** `Ayak.bayatsa_birak()` — `Rig.extremities`'in başında; IK son iki karede çalışmadıysa yazdıkları FK'ye
   döner (gövde yüksekliği, bacak açılarının iş pozunun yazmadığı yan bileşenleri, bilek z'si) ve IK kapanır.
2. **İki denetleyici aynı serbestlikte.** Azap ayakta (`stand`) dururken de `Stage.plant_feet` kökü her karede en alçak
   tabana göre kaydırır; ayak IK ise kalçayı/dizleri tabanı kendi zemin ölçüsüne koyacak kadar oynatır. İki zemin ölçüsü
   (bölümün `_floor_y` ışını ile IK'nın görünen-zemin ışını, `plant_feet`'in taban noktası ile IK'nın tabanı) arasındaki
   milimetrelik fark her karede birikir: kök 1,3 sn'de −2,85'ten −3,20'ye gömüldü, kalça +0,35 çıktı (VISAUDIT sunk).
   **Düzeltme:** kökü yerinde dururken dışarıdan dikine yazılan kişi (iki ardışık karede yatay kayma < 2 mm, dikey
   > 0,3 mm) IK kapsamı dışına alınır (`ayak_kok_dis` işareti; kapsam denetimi ve AYAKAUDIT aynı ölçüyü kullanır):
   `plant_feet` FK tabanını zemine koyar (`--ayak-ik=0` davranışı). Kişi o yerden 30 cm ayrılınca (yürüyüş) IK geri
   gelir. `Unclip.rest_settle`'ın tek seferlik oturtması (1,5 sn'de en çok bir) sayılmaz.
Denetim değişmedi (eşik, muafiyet yok): VISAUDIT kökü ölçer, kök artık zeminde.

## 2. Giysi kumaşı — `scripts/npc/kumas.gd`, `assets/shaders/giysi_kumas*.gdshader*`, `scripts/npc/char_kit.gd`

**Neden gölgelendirici:** karakterler parça parça kurulup her eklemde tek ağa pişiriliyor (`CharKit.bake`: köşe renkli
tek yüzey, ~9 çizim). Kumaşı ayrı düğüm zincirleriyle (yaylı kemik) yapmak her kişiye yeni çizim çağrıları ve düğüm
dönüşümleri eklerdi; köşe gölgelendiricisi ise var olan pişmiş ağı yerinde büker: **yeni çizim çağrısı yok**, CPU'da kişi
başına kare başına yalnız birkaç sayı.

**İşaret:** kumaş parçaları kurulurken `Kumas.silindir` (Props.cyl'in eşi, boyuna 1→N halka), `Kumas.pano` (Props.box'ın
eşi, boyuna/enine bölünmüş) ya da `Kumas.isaretle` (eteğin üstündeki süsler) ile işaretlenir: kip, bağlandığı yükseklik,
boy. `CharKit.bake` işaretli parçaların köşelerine `UV = (h, kip)` yazar (h: bağlandığı yerde 0, uçta 1; eklem
uzayında), öteki köşelere (0, 0); kumaşlı ağ `Kumas.malzeme` (vc_mat'ın eşi: köşe rengi, lambert wrap, rim, gölge
almaz; dış hattı aynı bükümle) alır. Durağan görünüş eskisiyle aynı (aynı ölçü, aynı renk).

**Kişi başı (kare başı, `Kumas.uygula`, Rig.update'in sonunda; Rig.update'siz iş pozlarında Soldier'ın _process'inden):**
- Gövdenin dünya hızı ve ivmesi (kökün yolu), gövde uzayına çevrilir.
- **Yaylı sarkaç** (etek ucunun 2B salınımı, gövde uzayında; ~1,1 Hz, az sönümlü):
  `s'' = K (hedef − s) − C s' − 0,9 a_gövde`. Hedef: göreli rüzgârın sürüklemesi (rüzgâr − gövde hızı, × 0,045, ≤ 0,24 m;
  koşarken arkaya, dururken rüzgâraltına), yerçekiminin gövde uzayındaki yatay bileşeni (yatan kişinin eteği yere sarkar),
  yürüyüşte kalçanın yana salınımı (Rig'in yürüyüş evresi). Eylemsizlik: yürümeye başlayınca etek geri savrulur, durunca
  öne salınıp oturur.
- **Burulma** (dönüşte etek geride kalır: yay, açısal hızdan) ve **açılma** (hızlı dönüşte ve koşuda).
- **Dalga genliği** göreli rüzgârdan (dalga gölgelendiricide zamanla akar: CPU yazmaz).
- **Bacaklar**: kalça, diz, bilek (gövde uzayı), **zemin düzlemleri**: her ayağın altındaki zemin (ayak IK'nın ışını;
  yoksa kökün düzlemi); oturan: oturak yüksekliği; yığılan/yatan: gövdenin altındaki görünen zemin (yarım saniyede bir ışın).
- Örnek uniform'ları (`set_instance_shader_parameter`: malzeme paylaşılır, değerler ağ örneğinin): değişmeyen değer yazılmaz.

**Gölgelendirici (köşe başı):**
- *Etek/kaftan* (kip 1): köşenin eksenden yönü ve yarıçapı; salınım h² ile (etek ucu çok, bel hiç: **bükülür, tek parça
  kutu gibi dönmez**), burulma h², açılma h², kıvrımlı dalga (açıya ve h'ye göre akan iki sinüs, rüzgâraltında güçlü);
  sarkacın kısalması (salınan uç yükselir). **Bacak zarfı**: her köşenin yüksekliğinde dört bacak kapsülünün (iki uyluk,
  iki baldır; yarıçap Person 0,088, Soldier 0,1) kesiti hesaplanır, eteğin o yöndeki yarıçapı kesiti saracak kadar açılır
  (adım atan diz eteği önden iter; bacak kumaşın içinden geçmez). **Zemin**: köşe, yakınındaki ayağın zemin düzleminin
  1,5 cm altına inemez (basamakta, yokuşta, yerde etek ucu yere oturur). **Oturan**: dizlerin gerisindeki kumaş oturak
  yüksekliğinin altına inmez (oturağın içinden geçmez), önü dizlerin üstünden sarkar.
- *Pelerin* (kip 2): salınım + çırpınma (yatay dalga), gövde ve bacak kapsüllerinin dışına itilir.
- *Sarkan uç* (kip 3: yen, sarık/börk yatırtması, püskül): salınım + dalga (bacak/zemin yok).

**Kapsam:** Person: uzun kaftan/cüppe (ve uçtaki şerit), kadın eteği, gambeson ve zincir zırh etekleri, padişah
kaftanının kürk şeritleri/çintemani benekleri/yenleri, vezir yenleri, imparatorun loros'u, Minotto'nun stolası, önlük
(kaftanlıda), Giustiniani'nin pelerini, Urban'ın kürk yakalı mentesi, kardinal şapkasının püskülleri, börk ve azap
börkünün yatırtması. Soldier: kaftan bel eteği, börk/azap yatırtması. Hikmet ve Büro/Tolga: yok (uzun giysileri yok).
Kalabalığın pişmiş kopyaları (Crowd, MultiMesh) dinlenme duruşunda (uniform'u yok).

**Bütçe:** kameraya ≤ 26 m ve görüş konisinde; ötesinde **donar** (uniform yazılmaz, son hâlinde kalır). 12 m'den uzakta
iki karede bir. Kendi rastgele üreteci (oyunun küresel dizisini tüketmez).

**Kapatma / ölçüm:** `--kumas=0` (parçalar eskisi gibi kurulur, ÖNCE), `--kumas-olc` (KUMASPERF: kare başı betik süresi,
kumaş µs, kişi).

## 3. Tutuş duruşunda ayaklar — `scripts/npc/rig.gd`, `scripts/level/stage.gd` (`grip_hold`/`grip_release`)
Tutuşta iskelet kilitli (`Rig.lock > 0`); `Rig.update` ayak IK'yı kilitli kişide her karede kapatıyordu (`_kapat`).
- Kişinin `_process`'i çalışıyorsa: `Rig.update` tutuştaki kişide (`grip_lean` işareti) IK'yı izdüşüm kipinde çalıştırır
  (`Ayak.uygula(anim=true)`: FK'nin ayak yerleri korunur, her taban kendi zeminine, kalça gerekirse iner); tutuşun öne
  eğilmesi IK'dan **önce** uygulanır (tween onu sonra aynı değerle yeniden yazar: ayak kaymaz).
- Süreci kapalı figürde (`_process` çalışmıyor, yalnız tutuş tween'i): tween, o karede IK çalışmadıysa önce bir önceki
  karenin yazdıklarını geri alır, sonra izdüşüm yapar ve ayak bileklerini taban eğimine çevirir (`Rig.ayak_bilekleri`;
  el bilekleri ikinci kez yumuşatılmaz).
