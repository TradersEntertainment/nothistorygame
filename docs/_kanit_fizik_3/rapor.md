# FİZİK-3 — 37o ayak gerilemesi, giysi kumaşı, yığılma kalanları

Dal `wip/fizik-3` (taban `wip/fizik-taban3` 758502cd). Yöntem: [`yontem.md`](yontem.md). Süzülmüş günlükler:
[`gunluk/`](gunluk/). Kareler: [`kare/`](kare/). Durum: [`durum.md`](durum.md).

## Özet

| # | İstek | Durum | Not |
|---|---|---|---|
| 1 | 37o eski sette ayak IK açıkken asker havada/gömük (gerileme) | **TAMAM** | İki kök neden (bayat IK yazımı + `Stage.plant_feet` ile çift denetleyici); ikisi de `scripts/npc/` içinde kökten düzeltildi, denetime dokunulmadı. Eski set 37o (bütün çeşitler) 15 koşu, yeni set 37o 9 koşu, eski set 20/20o/22/22o/26/0/25: VISAUDIT **0** (taban: 37o'da her koşuda 1–3). Bir `=lose` koşusunda FAIL (düello kazanıldı): oyunun rastgeleliği, aşağıda. |
| 2 | Giysi kumaşı (kaftan, cüppe, etek, bel eteği, pelerin, yen, yatırtma, püskül) | **TAMAM** (oyun içi kanıt KISMEN) | Köşe gölgelendiricisi + kişi başı yaylı sarkaç + bacak zarfı + zemin düzlemleri + eklem uzayında yerçekimi (sarkan uçlar). Yeni çizim çağrısı yok. Kumaşın kendi payı kalabalık bölümlerde kare betik süresinin **%0,4–0,6**'sı. Deney sahnesinde bütün istenen durumlar ÖNCE\|SONRA; oyun içinde 4 yer. |
| 3 | Yığılma kalanları; 26 iş pozu (`Stage.grip_hold`) | **KISMEN** | Tutuş duruşunda ayak izdüşümü: IK kilitli kişide her karede kapanıyordu → Rig.update'te tutuş için izdüşüm. YIGILMAAUDIT kalanları (yaslanan gövde, sarkan/taşa giren uzuv, taşta başlayan kök, Assault okla vurulanlar) **YAPILMADI**. |

---

## 1. 37o eski sette ayak IK gerilemesi — TAMAM

### Kök neden (günlük: [`gunluk/m1_37o_eskisur_kok_neden.txt`](gunluk/m1_37o_eskisur_kok_neden.txt))
VISAUDIT satırındaki asker 37o'nun **ip çeken üç azabından** biri (`meta=no_rally,no_talk`, `_haulers`; yerleri
`BARREL_Z + 4,15 / 2,2 / 1,4` → z 20,75 / 18,8 / 18,0 ve fıçı devrilince geri çekildikleri `SPOT_Z + 2,8` → z 25,4).
VISAUDIT kökü (`global_position`) ölçer; IK kökü hiç yazmaz, yalnız gövdeyi (`Rig.body.position.y`) kaydırır. Kökü
yazan, bölümün her karede çağırdığı `Stage.plant_feet(s, _floor_y)`: **en alçak tabanı** zemine değdirecek kadar kökü
dikine kaydırır. Tabanın yeri IK'nın gövde inişine bağlı olduğundan iki ayrı yoldan gerileme doğuyor:

1. **Bayat IK yazımı (havada, 12–15 cm).** Kanca takılınca azap `pose = "haul"`a geçer. Soldier bu pozda
   `Rig.update`'i hiç çağırmaz (yalnız `Rig.extremities`): IK'nın her karenin başındaki geri alması da, kapsam denetimi de
   çalışmaz; son duruş karesinde yazdığı gövde inişi donup kalır. Tanı satırı (taban kodu):
   `pos=(-0.24, -0.18, 20.75) pose=haul … fy=-0.32 … ik=w1.00 m1 pel-0.15 by=-0.15` — gövde 15 cm aşağıda donuk,
   `plant_feet` alçalmış tabanı zemine koyunca kök görünen zeminin (−0,32) 14 cm üstünde: VISAUDIT'in
   `feet=(-0.2, -0.2, 20.7) floor=-0.32`'si. Gövdeyi +0,11 yukarıda bırakan karede tersi (gömük).
2. **Çift denetleyici (gömük, 25–35 cm).** Birinci düzeltmeden sonra kalan satır: azap ayakta dururken de
   `plant_feet` kökü tabana göre, IK da kalçayı/dizleri tabanı kendi zemin ölçüsüne koyacak kadar oynatıyor. İkisi aynı
   serbestliği iki ayrı yerden sürüyor; zemin ölçülerinin (bölümün `_floor_y` ışını ↔ IK'nın görünen-zemin ışını;
   `plant_feet`'in taban noktası ↔ IK'nın tabanı) milimetrelik farkı her karede birikiyor:
   `pos=(-3.2, -2.85, 25.4) … ik=w1.00 m1 pel-0.01` → 0,5 sn sonra `pos y -3.05, pel+0.16` → `-3.20, pel+0.35`.
   `--ayak-ik=0` ile IK yazmadığından iki gerileme de yoktu (0/3).
Kalas/rampa `ConvexPolygonShape3D` yüzeyi neden değil: VISAUDIT'in bulduğu zemin (−0,32 / −2,85) görünen yüzeyin
doğru yüksekliği; bozuk olan kökün yüksekliğiydi.

### Düzeltme (yalnız `scripts/npc/ayak.gd`, `scripts/npc/rig.gd`)
- `Ayak.bayatsa_birak()` (`Rig.extremities`'in başında): IK son iki karede çalışmadıysa yazdıkları FK'ye döner (gövde
  yüksekliği, bacak açılarının iş pozunun yazmadığı yan bileşenleri, bilek z'si) ve IK kapanır.
- Kökü yerinde dururken dışarıdan dikine yazılan kişi (iki ardışık karede yatay kayma < 2 mm, dikey > 0,3 mm; 1 sn
  içinde) IK kapsamı dışına alınır (`ayak_kok_dis`; kapsam ve AYAKAUDIT aynı ölçüyü kullanır). `plant_feet` FK tabanını
  zemine koyar (= `--ayak-ik=0` davranışı). Kişi o yerden 30 cm ayrılınca (yürüyüş) IK geri gelir. `rest_settle`'ın tek
  seferlik oturtması (1,5 sn'de en çok bir) tetiklemez. `plant_feet` kullanan öteki yerler (2 kızak iticileri, 28o)
  yürürken etkilenmez.
- Denetim, eşik, muafiyet: değişmedi.

### Ölçüm (VISAUDIT ÖNCE → SONRA)
ÖNCE: taban kodu (758502cd). `--max-fps 20`, ekransız, tam süzgeç. "öteki" = SCRIPT ERROR, WALKTHRU, HELDAUDIT, ARMAUDIT,
WARN_FX/FLY/VOID.

| Koşu | ÖNCE (taban) sonuç / VISAUDIT | SONRA sonuç | SONRA VISAUDIT | SONRA öteki | SONRA AYAKAUDIT yakın | SONRA YIGILMAAUDIT |
|---|---|---|---|---|---|---|
| eski set 37o ×3 | PASS ×3 / **1, 2, 1** | PASS ×3 | **0, 0, 0** | 0 | 0 | 2, 3, 2 (taban 2, 3, 1) |
| eski set 37o =lose ×9 (taban ×5) | PASS ×5 / **3, 3, 2, 1, 3** | PASS ×8, **FAIL ×1** | **0** ×9 | 0 | 0–2, bir koşuda 7 (yürüyen bölük, aşağıda) | 0 |
| eski set 37o =trespass ×3 | — | PASS ×3 | **0** | 0 | 0, 0, 1 | 1, 2, 2 |
| yeni set 37o ×3 | — | PASS ×3 | 0 | 0 | 0, 1, 0 | 2, 0, 0 |
| yeni set 37o =lose ×3 | — | PASS ×3 | 0 | 0 | 1, 0, 0 | 0 |
| yeni set 37o =trespass ×3 | — | PASS ×3 | 0 | 0 | 0 | 1, 0, 0 |
| eski set 20 | PASS / 0 | PASS | 0 | 0 | 8 (taban da **8**: aynı işçiler) | 1 (taban 1) |
| eski set 20o, 22, 22o, 0, 25 | — | PASS ×5 | 0 | 0 | 0 | 20o 1, öteki 0 |
| eski set 26 | — | PASS | 0 | 0 | 4 | 5 |

- **=lose FAIL (1/9)**: `duel=true` (bot düelloyu kazandı; çeşit kaybetmeyi bekliyor). Oyunun RNG'si tohumlanmıyor:
  çekişin "kesilme" sayısı (`cuts`) tabanda 2–32, bende 5–35 arası değişiyor (aynı dağılım; IK kapalı `--ayak-ik=0` ve
  kumaş kapalı `--kumas=0` koşularında da 18–28). Düello (`WaveRunner`, `duelist.gd`) bu turda değişmedi; IK ve kumaş
  oyunun küresel rastgele dizisini tüketmiyor (kumaş kendi üretecini kullanıyor). Gerileme değil, rastgelelik; tabanda
  5 koşunun 5'i PASS'ti — **izlenmeli**.
- Eski set 20'nin 8 AYAKAUDIT satırı (gediğin önündeki çekiç/balta işçileri, `ik=yok`, taban −0,07…−0,13) tabanda da
  birebir aynı (gerileme değil; "hâlâ kötü" 4).
- =lose'un bir koşusundaki 7 satır: kızağı çeken yürüyen bölük, sol ayak +0,07 (yürüyüş basma ortası); tabanda da
  aynı türden satırlar var (önceki turun kalanı: "koşuda basma").

Günlükler: [`gunluk/m1_*`](gunluk/).

---

## 2. Giysi kumaşı — TAMAM (oyun içi kanıt KISMEN)

Yöntem ayrıntısı: [`yontem.md`](yontem.md) §2. Kısaca: kumaş parçaları kurulurken işaretlenir; `CharKit.bake` onların
köşelerine `UV = (h, kip)` yazar; o eklemin pişmiş ağı kumaş gölgelendiricisini alır (dış hattı da aynı bükümle). Kişi başı
kare başı GDScript yalnız birkaç sayı hesaplar (yaylı sarkaç, burulma, açılma, bacak noktaları, zemin düzlemleri) ve
örnek uniform'u olarak yazar; köşeleri gölgelendirici büker. **Etek h² ile bükülür** (bel sabit, uç savrulur: tek parça
kutu gibi dönmez), **bacak zarfı** her yükseklikte iki uyluk ve iki baldır kapsülünün kesitini sarar (bacak kumaşın
içinden geçmez), **zemin düzlemi** (ayak IK'nın ışını) etek ucunu yerde/basamakta tutar, oturanda kumaş oturağın
içine girmez, dizlerin üstünden sarkar. Pelerin kapsüllerin dışına itilir. Sarkan uçlar (yatırtma, yen, püskül)
bağlı oldukları eklemin uzayında yerçekimiyle sarkar.

Kapsam: Person: uzun kaftan/cüppe (ve ucundaki şerit), kadın eteği, gambeson/zincir zırh etekleri, padişah kaftanının kürk
şeritleri/çintemani benekleri/**yenleri**, vezir yenleri, imparatorun loros'u, Minotto'nun stolası, kaftanlıda önlük,
Giustiniani'nin **pelerini**, Urban'ın mentesi, kardinal püskülleri, börk/azap börkü **yatırtması**. Soldier: kaftan **bel
eteği**, yatırtma. Hikmet, Büro, Tolga: yok. **Kuşak uçları**: oyunda sarkan kuşak ucu yok (kuşaklar bel halkası) — yeni
parça eklenmedi.

### Kareler — deney sahnesi ([`tests/_fizik/fizik3_kumas_sahne.tscn`](../../tests/_fizik/fizik3_kumas_sahne.tscn); 0,15 sn arayla 6 kare; üst ÖNCE `--kumas=0`, alt SONRA)

| Pafta | Durum | Tek cümle (SONRA) |
|---|---|---|
| [`sahne_kaftan_yuru_yan`](kare/sahne_kaftan_yuru_yan.jpg) | **Yürüyen kaftanlı**, yandan | Sallanıyor: bel sabit, etek ucu adımla geri savrulup öne dönüyor; bacak kumaştan çıkmıyor; kutu değil (bükülüyor). |
| [`sahne_kaftan_yuru_arka`](kare/sahne_kaftan_yuru_arka.jpg) | Yürüyen kaftanlı, arkadan | Etek ucu adımla sağa-sola salınıyor (hafif); bacaktan geçmiyor; kutu değil. |
| [`sahne_asker_kos_yan`](kare/sahne_asker_kos_yan.jpg) | **Koşan asker** (bel eteği) | Bel eteği koşuda arkaya açılıyor, adımda dalgalanıyor; bacaklar eteğin altından çıkıyor ama içinden geçmiyor; kutu değil. |
| [`sahne_pelerin_kos_yan`](kare/sahne_pelerin_kos_yan.jpg) / [`_arka`](kare/sahne_pelerin_kos_arka.jpg) | **Koşan pelerinli** | Pelerin arkaya savruluyor ve bükülüyor; ÖNCE'de koşan bacaklar katı panonun içinden çıkıyordu (arkadan beyaz yamuk), SONRA bacakların arkasına itiliyor; tek parça değil. |
| [`sahne_padisah_ruzgar_yan`](kare/sahne_padisah_ruzgar_yan.jpg) / [`_arka`](kare/sahne_padisah_ruzgar_arka.jpg) | **Duran kişi rüzgârda** (padişah: kaftan + yenler) | Hafif dalga ve rüzgâraltına küçük kayma (bilerek hafif); yenler sallanıyor; bacaktan geçmiyor. |
| [`sahne_oturan_yan`](kare/sahne_oturan_yan.jpg) | **Oturan kaftanlı** (tabure) | ÖNCE kaftan tüp gibi tabureyi ve bacakları içine alıyordu; SONRA uyluğun üstünden dizlere oturup önden sarkıyor, arkası taburenin üstünde; bacaktan geçmiyor. |
| [`sahne_bagdas_yan`](kare/sahne_bagdas_yan.jpg) | Yerde bağdaş | Etek yere yayılıyor, ayak uçları önde görünüyor; yerin içine girmiyor. |
| [`sahne_yigilan_yan`](kare/sahne_yigilan_yan.jpg) / [`_son`](kare/sahne_yigilan_son.jpg) | **Yığılan kaftanlı** (tüfekle vurulur) | Bez bebekle birlikte devriliyor, etek bacakların üstünde yere oturuyor; bacak dışarı çıkmıyor. |
| [`sahne_merdiven_yan`](kare/sahne_merdiven_yan.jpg) | Merdiven çıkan kaftanlı | Etek ucu basamağa oturuyor, öndeki basamağın içine girmiyor (bu açıdan basamağın yan yüzü bir kısmını örtüyor). |
| [`sahne_etek_yokus_yan`](kare/sahne_etek_yokus_yan.jpg) | Yokuşta duran kadın (etek) | Kısa etek yokuşta düz duruyor, hafif dalga; yere değmiyor. |
| [`sahne_bork_otur_yan`](kare/sahne_bork_otur_yan.jpg), [`_arka`](kare/sahne_bork_otur_arka.jpg), [`sahne_bork_asker_yan`](kare/sahne_bork_asker_yan.jpg) | Börk yatırtması | Enseye düşen yatırtma sarkıyor, hafif sallanıyor. |

Tam boy tek kareler: [`tam_kaftan_yuru_yan_0`](kare/tam_kaftan_yuru_yan_0.jpg), [`tam_oturan_yan_2`](kare/tam_oturan_yan_2.jpg),
[`tam_pelerin_kos_yan_3`](kare/tam_pelerin_kos_yan_3.jpg).

### Kareler — oyun içi (tanık kamera kumaşlı bir kişiyi yandan izler; `tests/_fizik/fizik3_gez.gd`)
Pencereli koşu yazılım OpenGL'inde (xvfb) çok yavaş (kare başı ~0,5–1 sn): "0,15 sn arayla" diziler oyun zamanında
kare başına ~0,5–1 sn aralıklı ve bot konuşmaları hızla geçtiğinden kadraj değişiyor.

| Pafta | Yer | Tek cümle |
|---|---|---|
| [`oyun_10_sorucu_aga`](kare/oyun_10_sorucu_aga.jpg) | **Paşa** (Bölüm 10, Sorucu Ağa; yanında bel etekli asker) | Kaftan düz sarkıyor, asker bel eteği doğal; Fatih bu koşuda kadraja girmedi (tanık en yakın kumaşlıyı seçti). |
| [`oyun_24o_ordugah`](kare/oyun_24o_ordugah.jpg) | **Ordugâh** (24o, ateş başında oturan börklü) | Kaftan/etek doğal; ama çorbaya eğilen askerin yatırtması başla birlikte geriye kalkmış — eski katı davranış; bu kareden **sonra** sarkan uçlara eklem uzayında yerçekimi eklendi (yeniden çekilmedi). |
| [`oyun_24_sehir`](kare/oyun_24_sehir.jpg) | **Şehir** (24, yağmurda alay) | Cüppeler kalabalıkta doğal sarkıyor, bozulma yok; sallanma yavaş yürüyüşte hafif. |
| [`oyun_26_sur`](kare/oyun_26_sur.jpg) | **Sur** (26, sandık taşıyan işçi, peribolos) | Yürüyen işçinin eteği doğal; bacaktan geçme görülmedi. |
| [`oyun_10_eski_kararsiz_yay`](kare/oyun_10_eski_kararsiz_yay.jpg) | (hata kanıtı, düzeltildi) | İlk sürümde yavaş karede (0,5 sn) yay kararsızlaşıp askerin eteğini yelken gibi açıyordu → alt adımlı tümlev. |

### Bütçe (kare betik süresi)
Ölçü kumaşın **kendi** süresi (`--kumas-olc`, KUMASPERF: `Kumas.uygula` µs/kare) ve bunun o koşunun kare betik süresine
(Performance.TIME_PROCESS) oranı; otomatik testte koşudan koşuya ±%20 oynayan işlem süresi farkı gürültü (önceki turlar
gibi). ÖNCE (`--kumas=0`) ve SONRA aynı anda koşuldu.

BUTCE_TABLO

Kişi başı ~30–45 µs/kare (GDScript; dönüşümler + uniform yazımı). Uzakta (> 26 m) ve görüş dışında **donar** (yazım yok,
dinlenme duruşu); 12 m'den uzakta iki karede bir. Çizim çağrısı ve üçgen sayısı aynı (kumaş var olan pişmiş ağda;
etek/pelerin parçaları 1 halka yerine 5–11 halka: kişi başı +~300 üçgen).

---

## 3. Yığılma kalanları ve 26 iş pozu — KISMEN

- **`Stage.grip_hold` tutuş duruşunda ayaklar**: kök neden — tutuşta iskelet kilitli (`Rig.lock > 0`), `Rig.update` ayak
  IK'yı her karede kapatıyordu (`_kapat`: ağırlık 0); bu turun ilk sürümünde tween'den çağrılan izdüşüm %20 ağırlıkta
  kalıyordu (burun −0,06/−0,07). Düzeltme: tutuştaki kişide `Rig.update` IK'yı izdüşüm kipinde çalıştırır, tutuşun öne
  eğilmesi IK'dan önce uygulanır. TUTUS_OLCUM
- **YIGILMAAUDIT 15 → 0, taşta başlayan kök, Assault okla vurulanlar**: **YAPILMADI** (süre madde 1'in ölçümüne ve kumaşa
  gitti). Bu turun koşularındaki YIGILMAAUDIT sayıları tabanla aynı düzeyde (37o 0–3, 26 hold 3–7).

---

## Ortak dosyalar (varsayılan çeşit, tam süzgeç)

ORTAK_TABLO

---

## Hâlâ kötü olanlar
1. **37o =lose düello sonucu rastgele**: 9 koşunun birinde bot düelloyu kazandı (FAIL). Tabanda 5/5 PASS; koddan kaynaklandığı
   gösterilemedi (RNG tohumlanmıyor). İzlenmeli.
2. **Kök dışarıdan sürülen kişide IK yok** (`ayak_kok_dis`): 37o'nun ip çeken azapları duruşta `plant_feet`'in FK
   tabanıyla basıyor (eğimde iki ayak aynı yükseklikte olabilir). Kökten çözüm `Stage.plant_feet`'in IK'lı kişide FK
   tabanını (`Ayak._fks`) ölçmesi — `plant_feet` bu turda madde 1 için benim dosyam değildi; istek olarak yazıldı.
3. **YIGILMAAUDIT** kalanları (yaslanan gövde, sarkan/taşa giren uzuv), taşta başlayan kök, Assault okla vurulanlar: yapılmadı.
4. **Eski set 20 gedik işçileri** (çekiç/balta, `ik=yok`): tabanları 7–13 cm gömük (8 AYAKAUDIT, tabanda da 8). Bu kişilerde
   ayak IK hiç kurulmuyor; neden bulunamadı (sahne `wall_fight.add_builders`; `_busy` değil).
5. **Kumaş**: yürüyüşte sallanma bilerek hafif (kalça ±4 cm, adım ±1,8 cm); rüzgâr sahnede tek yön ve sabit şiddet
   aralığı (bayrakların rüzgârıyla — başka oturum — henüz bağlı değil). Pelerin/etek kendi kendisiyle ve öteki kişilerle
   çarpışmaz; kollar eteği itmez (kol etek arasında). Oturanda "oturak" yüksekliği sabit (0,55 gövde uzayında): yüksek
   tabure/bankta etek arkası oturağın altında kalabilir.
6. **Oyun içi kumaş kareleri yavaş pencereli koşuda**: diziler 0,15 sn değil ~0,5–1 sn aralıklı; Fatih kadraja girmedi;
   24o karesi yerçekimi düzeltmesinden önce.

## Dokunulan dosyalar
`scripts/npc/ayak.gd` (bayat IK, kök dışarıdan sürülüyor, tanı argümanları), `scripts/npc/rig.gd` (extremities'te bayat
IK, tutuşta izdüşüm, kumaş kancası, ayak bilekleri ayrı işlev), `scripts/npc/kumas.gd` (yeni), `scripts/npc/char_kit.gd`
(bake: kumaş UV'si ve malzemesi), `scripts/npc/person.gd` ve `scripts/npc/soldier.gd` (kumaş parçaları; durağan görünüş
aynı), `scripts/level/stage.gd` (yalnız `grip_hold`/`grip_release`: tutuş eğilmesi işareti), `assets/shaders/giysi_kumas.gdshader`,
`giysi_kumas_hat.gdshader`, `giysi_kumas.gdshaderinc` (yeni), `tests/_fizik/fizik3_*` (deney sahnesi, koşu/kare/pafta/
tablo betikleri, tanı). Bölüm dosyaları, `scripts/world/ist`, `scripts/player`, `scripts/ui`, `scripts/combat`,
`tests/run_tests.sh`, `project.godot`, bayrak/sur dosyaları: dokunulmadı. Replik, ses, denge, sayaç değişmedi.
Kapatma: `--kumas=0`, `--ayak-ik=0`.
