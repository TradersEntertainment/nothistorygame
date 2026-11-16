# FİZİK-YIĞILMA — düşen/ölen bez bebek gibi yığılsın

Dal `wip/fizik-yigilma` (taban `wip/fizik-ayak` 2ec2d1db). Yöntemin ayrıntısı: [`yontem.md`](yontem.md). Tablolar:
[`tablo.md`](tablo.md). Süzülmüş günlükler: [`gunluk/`](gunluk/). Kareler: [`kare/`](kare/).
Sahibin sözü: "vurulan, itilen, surdan düşen asker tahta gibi devrilmek yerine bez bebek gibi yığılsın; kollar bacaklar
savrulsun, ceset yere otursun".

## Özet

| # | İstek | Durum | Not |
|---|---|---|---|
| 1 | Yığılma sistemi (Verlet bez bebek, eklem sınırları, eğime göre yatma, çarpma yönünde kayma, 1–2 sn'de durma, donma) | **TAMAM** | `scripts/npc/yigilma.gd`. 13 parçacık, katı gövde, diz menteşesi, uyluk konisi, boyun; görünen zeminin ızgarası; duvar/kenar; sürtünme; uyku + son oturtma + donma. |
| 2 | Kapsam | **KISMEN** | Düellocu ölümü, bitirici (saplama dahil), kenardan atılan (havada çırpınma + inişte yığılma), tekmeyle yere serilip **kalkma**, tüfekle vurulan asker/kişi (`shot`), merdivenden düşen saldırgan (Assault, kameranın 30 m içi), Bölüm 0 donma karesindeki savrulanlar (dinamik savrulma duruşu). **Yok**: ok isabeti bir kişiyi öldürmüyor (Assault'ta okla vurulan koşanlar MultiMesh kopya: bez bebek olamaz); SiegeChaos'ta patlamada savrulan kimse yok (koşanlar MultiMesh, yerdeki ölüler pişmiş poz); `battle_extras.gd` devirmeleri (benim dosyam değil). |
| 3 | Oynanış aynı | **TAMAM** | Ölüm anı, dalga, sayaç, `died` sinyali, düşüşün kökü (kenardan düşüş, su, iniş) eski kod; yalnız görüntü. Ceset `no_block`/`corpse` aynı; tüfekle vurulan eskisi gibi 2,45 sn sonra gizlenir. 20 + 7 bölüm koşusu PASS, öteki denetimler ÖNCE = SONRA. |
| 4 | Bütçe (≤ 8 kişi, ≤ 2 sn, en kalabalık anda ≤ %5) | **KISMEN** | Sınır 8 (doluyken eski yol), 2 sn (düşüşte inişten sonra), kare başı toplam 1,2 ms sınırı, ışın bütçesi, 30 Hz + ara değer. En kalabalık anlarda pay %0,4–3,9; **bir istisna: 30o %8,5** (2 kişi, kısa bir 22 ms karede 1,9 ms; sınır eklenmeden önceki ölçüm — aşağıda). |
| 5 | YIGILMAAUDIT ÖNCE\|SONRA, hedef 0 | **KISMEN** | **94 → 15** (20 koşu). Hedef 0'a ulaşılmadı: kalan 15'in türleri aşağıda (duvara/korkuluğa yaslanan gövde, basamak/kenardan sarkan uzuv, taşa giren uzuv). |
| 6 | Ayak IK kalanları | **TAMAM (kod) / KISMEN (kanıt)** | Dik molozda topuk-burun iki ışın; yokuş aşağı koşuda kalça. 37o `=trespass` AYAKAUDIT yakın **0** (ÖNCE bu koşuda da 0: dik yüze denk gelmedi); koşu düzeltmesinin kare kanıtı yok. `Stage.grip_hold` iş pozlarına dokunulmadı. |
| 7 | Kanıt kareleri | **KISMEN** | Deney sahnesinde 9 tür ÖNCE\|SONRA, 6 an (bazıları 9 an) tek paftada; Bölüm 0 donma karesi ÖNCE\|SONRA. Oyun içinde oyuncu kamerasından kareler denendi (tanık kamera, `--yig-kare`): botun kamerası kalabalığın/kendi kalkanının içinde, ceset seçilmiyor — **kullanılamaz**; pencereli 20 koşusu 9,5 dk'da dövüşe varmadı. |

## Yöntem (kısa)
Verlet (Jakobsen 2001) + konum tabanlı kısıtlar (Müller 2006). 13 parçacık; gövde (kalçalar + omuzlar) altı çubukla
katı, boyun aralıklı; uzuvlar kemik boyunda, diz/dirsek bükülme aralığı, diz yalnız öne, uyluk konisi. Yerçekimi, darbe
yüksekliğine göre dağılan başlangıç hızı ("göğsünden vurulan devrilir, dizleri çözülür"). Zemin: görünen zeminin 0,25 m
ızgarası (ışın), duvar (10 cm'den yüksek sıçrama, dik yüz, içinden başlanan görünen katı) ve kenar (60 cm'den derin iniş)
yatayda geçilmez; göğüs/karın küreleri kaldıraçla. Uyku ya da süre → son oturtma (her parçacığa tam ışın, karelere
yayılmış) → donma. Görüntü: gövde düğümü katı gövdenin dönüşümü, uzuvlar LimbAnim'in uzuv-yönü kurgusuyla; Rig kilitli.
Düşüşte havada kökü izler (kökün yolu eski kod), inince yığılır. Kalkış: yerdeki duruş LimbAnim'in harman belleğine,
eski kalkış klibi oradan başlar. Ayrıntı: [`yontem.md`](yontem.md).

## YIGILMAAUDIT ve AYAKAUDIT ÖNCE | SONRA
ÖNCE: aynı kod `--yigilma=0` (eski klip yolu + bu turun ayak düzeltmeleri kapalı). `--max-fps 20`, ekransız, `--autotest`.
ÖNCE satırları yalnız düellocu cesetleri (eski yolda tüfekle vurulan/merdivenden düşen ölçülmüyor); SONRA bez bebeğe
dönen herkes (düellocu, merdivenden düşen yakındaki asker, tüfekle vurulan) ölçülür.

| Bölüm | ÖNCE sonuç | ÖNCE YIGILMAAUDIT | SONRA sonuç | SONRA YIGILMAAUDIT | öteki denetim ÖNCE → SONRA | AYAKAUDIT yakın ÖNCE → SONRA |
|---|---|---|---|---|---|---|
| 0 | PASS | 0 | PASS | **0** | 0 → 0 | 0 → 0 |
| 20 | PASS | 5 | PASS | **0** | 0 → 0 | 0 → 0 |
| 20:tape | PASS | 5 | PASS | **0** | 0 → 0 | 0 → 0 |
| 20:late | PASS | 5 | PASS | **0** | 0 → 0 | 0 → 0 |
| 20:hit | PASS | 5 | PASS | **0** | 0 → 0 | 0 → 0 |
| 20:lose | PASS | 0 | PASS | **0** | 0 → 0 | 0 → 0 |
| 20:niko_idle | PASS | 5 | PASS | **2** | 0 → 0 | 0 → 0 |
| 20:idle | PASS | 5 | PASS | **2** | 0 → 0 | 0 → 0 |
| 20o | PASS | 5 | PASS | **1** | 0 → 0 | 0 → 0 |
| 22o | PASS | 2 | PASS | **0** | 0 → 0 | 0 → 0 |
| 26:hold | PASS | 18 | PASS | **2** | 0 → 0 | 5 → 0 |
| 26:hold_box | PASS | 18 | PASS | **3** | 0 → 0 | 1 → 1 |
| 26:hold_lose | PASS | 2 | PASS | **0** | 0 → 0 | 7 → 19 |
| 26o | PASS | 6 | PASS | **3** | 0 → 0 | 2 → 4 |
| 30o | PASS | 7 | PASS | **1** | 1 → 1 | 0 → 0 |
| 32o | PASS | 0 | PASS | **0** | 0 → 0 | 0 → 0 |
| 37o | PASS | 3 | PASS | **0** | 1 → 1 | 2 → 0 |
| 37o:trespass | PASS | 3 | PASS | **1** | 1 → 1 | 0 → 0 |
| 25:caught | PASS | 0 | PASS | **0** | 0 → 0 | 0 → 0 |
| 28o | PASS | 0 | PASS | **0** | 0 → 0 | 0 → 0 |
| **toplam** | | **94** | | **15** | | 17 → 24 |

Ek PASS (SONRA, varsayılan yol): 3, 8, 12, 24, 29, 41o, 42b — hepsi PASS, SCRIPT ERROR 0, denetim satırı 0.

**ÖNCE'nin satırları** (eski klip yolu): ölüm klibinin son karesi düz zeminde bile baş +0,19, eller +0,22–0,25, ayaklar
+0,11–0,15 havada (deney sahnesinde 7 ölümün 7'si; oyunda bölüm başına 5–18). Merdivende ayaklar +0,56, molozda baş −0,27.

**SONRA'da kalan 15 satır** (koşudan koşuya yeri değişiyor; tür olarak):
1. **Duvara/korkuluğa/kenara yaslanan gövde** (gövde +0,1–0,5; 26 sur yolu y 8, 37o, 26o, 20o): ceset korkuluğa ya da moloz
   basamağına yaslanmış, gövdenin ortası altındaki zeminden yüksekte. Gövde tek katı düğüm (bel eklemi yok): sarkamıyor.
2. **Kenardan/basamaktan sarkan uzuv** (el/ayak +0,2–1,7; 26'da kenardan atılan (−10,5, 0, 20) iki ayak +1,6 her
   koşuda): bacaklar duvar dibindeki çıkıntıya/duvarın eğik yüzüne dayalı. Dik yüzü duvar sayma ve inişte gövdeyi kökün
   üstüne alma bu satırı kaldırmadı — **kök neden bulunamadı**.
3. **Taşa/basamağa giren uzuv ya da gövde** (−0,1…−0,5): yatay girişte ızgaranın 25 cm çözünürlüğü dar taş kenarını
   kaçırıyor; son oturtma uzvu yukarı itiyor ama kısıtlar geri çekiyor.
4. Merdivenden düşen yakın asker (20, 26o: 2 satır): baş/gövde +0,3–0,6, hendek kıyısındaki çıkıntıya yaslı.

## Kare süresi (ÖNCE | SONRA)
Otomatik test, ekransız, 20 FPS; işlem süresi (Performance.TIME_PROCESS) koşudan koşuya ±%15 oynuyor (iki koşunun farkı
gürültü). Asıl ölçü yığılmanın kendi süresi (`--yig-olc`, YIGPERF; kare başı µs) ve **en kalabalık karede** (en çok kişinin
aynı anda yığıldığı kare) yığılmanın o karenin işlem süresine oranı.

| Bölüm | ÖNCE işlem ms/kare | SONRA işlem ms/kare | fark | SONRA yığılma µs/kare (ort.) | en kalabalık an: yığılan | o karede yığılma µs | o karenin işlem ms | pay |
|---|---|---|---|---|---|---|---|---|
| 0 | — | — | — | 0 | 0 | — | — | — |
| 20 | 40.7 | 40.8 | +0.3% | 209 | 3 | 506 | 35.3 | 1.4% |
| 20:tape | 42.0 | 47.0 | +12.0% | 222 | 3 | 1074 | 44.5 | 2.4% |
| 20:late | 49.7 | 56.4 | +13.5% | 362 | 6 | 1492 | 38.4 | 3.9% |
| 20:hit | 47.4 | 40.9 | -13.7% | 152 | 3 | 1320 | 36.0 | 3.7% |
| 20:idle | 37.5 | 33.0 | -12.0% | 123 | 4 | 1252 | 32.8 | 3.8% |
| 20o | 30.5 | 30.0 | -1.8% | 120 | 2 | 1653 | 53.9 | 3.1% |
| 26:hold | 107.4 | 96.4 | -10.2% | 397 | 5 | 669 | 170.6 | 0.4% |
| 26:hold_box | 98.5 | 96.4 | -2.2% | 354 | 5 | 1537 | 63.0 | 2.4% |
| 26o | 115.7 | 115.3 | -0.4% | 258 | 5 | 1406 | 90.2 | 1.6% |
| 30o | 43.7 | 40.7 | -6.8% | 155 | 2 | 1858 | 21.9 | **8.5%** |
| 37o | 30.4 | 29.7 | -2.1% | 24 | 2 | 1705 | 56.9 | 3.0% |

(Bütün satırlar: [`tablo.md`](tablo.md). Bölüm 0'da yığılan yok: açılıştaki merdiven düşüşleri kameranın 30 m'sinin
dışında; donma karesi duruş.) En kalabalık an 6 kişi (20:late) %3,9. Hedefi aşan tek ölçüm **30o %8,5**: iki kişi,
o kare kısa (21,9 ms). Bunu gören kare başı toplam süre sınırı (1,2 ms; aşılınca adım sonraki kareye kalır) bu ölçümden
**sonra** eklendi; son kodla yeniden ölçüm aşağıda "son doğrulama"da. Kişi başı maliyet: adım ~150–200 µs (13 parçacık,
3 yineleme, 30 Hz), görüntü yazımı ~45 µs/kare, ışın ~30 µs (kare başı en çok 10 yeni ışın). Uykudaki/donmuş ceset 0.

### Son doğrulama (son kodla: kare bütçesi, hız sınırı, kök duvar dibi; 4 bölüm)
| Bölüm | sonuç | YIGILMAAUDIT (ÖNCE → SONRA) | öteki denetim | en kalabalık an: yığılan | o karede µs | o karenin ms | pay |
|---|---|---|---|---|---|---|---|
| 20 | PASS | 5 → **0** | 0 → 0 | 5 | 1605 | 40.0 | 4.0% |
| 26:hold | PASS | 18 → **4** | 0 → 0 | 7 | 1364 | 85.4 | 1.6% |
| 30o | PASS | 7 → **0** | 1 → 1 | 2 | 1389 | 22.7 | **6.1%** |
| 20o | PASS | 5 → **0** | 0 → 0 | 2 | 1179 | 18.9 | **6.2%** |

Kare bütçesi (1,2 ms) en kalabalık anı sınırlıyor (7 kişide 1,4 ms) ama kısa karelerde (19–23 ms) iki kişi bile %6'yı
buluyor: **%5 hedefi kısa karelerde aşılıyor**. Sınırı 0,9 ms'ye indirmek (ağır çekim artar) denenmedi.

## Kareler — [`kare/`](kare/)

### Deney sahnesi (`tests/_fizik/yigilma_sahne.tscn`; üst sıralar ÖNCE, alt sıralar SONRA; anlar 0 · 0,2 · 0,45 · 0,8 · 1,3 · 2,4 sn)
| Kare | Sahne | SONRA (tek cümle) |
|---|---|---|
| [`sahne_duz_kilic`](kare/sahne_duz_kilic.jpg) | **Düelloda ölüm**, düz zemin | Dizleri çözülüp çöker, geriye yan yatar, kollar gövdeye dağılır: doğal; ÖNCE klip yere değmeden yan yatıyor (baş +0,19, eller +0,22 havada). |
| [`sahne_bitirici`](kare/sahne_bitirici.jpg) | **Bitirici** (saplanma duruşundan yığılma) | Saplanmış duruştan öne doğru çöküp yatıyor: doğal; ölü duruş kutu gibi değil. |
| [`sahne_tekme_kalk`](kare/sahne_tekme_kalk.jpg) | **Tekmeyle yere serilip kalkma** | Geriye savrulup sırtüstü düşüyor, kollar açılıyor: doğal; bu çekimde kalkış son karelerin dışında kaldı (önceki deneme çekiminde kalkış yerdeki duruştan başlıyordu) — kalkış kanıtı **zayıf**. |
| [`sahne_yokus_kilic`](kare/sahne_yokus_kilic.jpg) | **Yamaçta** (25°) ölüm | Çöker, yokuş aşağı yan yatar, gövde yamaca paralel: iyi; çöküşün ilk 0,5 sn'si biraz ağır (oturur gibi). |
| [`sahne_merdiven`](kare/sahne_merdiven.jpg) | **Merdivende** ölüm | Basamaklara uzanıyor, ayaklar alt basamakta: iyi; bir elin basamağa 16 cm girdiği koşu oldu. |
| [`sahne_moloz`](kare/sahne_moloz.jpg) | Molozda ölüm | **Kötü**: kök taşların içinde başladığında (deney sahnesinin yerleştirmesi) gövde havaya fırlıyor ve taşların üstünde 1 m havada kalıyor; hız sınırı sonradan eklendi, sorun sürüyor. Oyunda kök taşın üstünde başladığından bu biçimde görülmedi. |
| [`sahne_kenardan`](kare/sahne_kenardan.jpg) | **Surdan/kenardan atılma** | Kamera duvarın arkasında kaldı: düşüş görünmüyor — **kanıt yok** (oyunda 20/26'da THROWN koşuları PASS, ceset hendekte; 26'da ayaklar duvara yaslı). |
| [`sahne_surda_olum`](kare/sahne_surda_olum.jpg) | Sur yolunda korkuluk dibinde ölüm | Korkuluğa yaslanıp yığılıyor; gövdenin ortası korkuluğa dayalı (+0,4): yaslanma doğal ama denetimde "havada" satırı. |
| [`sahne_tufek`](kare/sahne_tufek.jpg) | **Tüfekle vurulan** asker | Atıcıdan uzağa geriye savrulup yığılıyor, 2,45 sn sonra gizleniyor (eski süre); ÖNCE tahta gibi 85° devriliyordu. |

### Oyun içi
| Kare | Sahne | SONRA (tek cümle) |
|---|---|---|
| [`c0_donma_once_sonra`](kare/c0_donma_once_sonra.jpg) | **Bölüm 0 donma karesi** (sol ÖNCE, sağ SONRA) | Savrulanlar kadrajın sağ kenarında ve gölgede; kollar yukarı savrulmuş, kişiden kişiye farklı — fark bu kadrajda **küçük, zor seçiliyor**. |
| — | Oyuncu kamerasından ölüm/düşüş dizileri (26 hold) | Denendi (`tests/_fizik/yigilma_kare.sh`, `--yig-kare`): test botunun kamerası ya kendi kalkanının ya kalabalığın içinde; ceset seçilemiyor — **kullanılamaz**, rapora konmadı. |

## Ayak IK kalanları
- Dik moloz yüzü: kod tamam (topuk-burun iki ışın; yalnız taban ortasının altındaki yüz > 56° iken). 37o `=trespass` bu
  koşuda AYAKAUDIT yakın 0 (ÖNCE de 0: o koşuda asker dik yüze denk gelmedi) — düzeltmenin denetim kanıtı **yok**.
- Yokuş aşağı hızlı koşu: kod tamam; kare/denetim kanıtı **yok** (denetim penceresi adım ortası).
- 26 =hold_lose AYAKAUDIT yakın 7 → 19 ve 26o 2 → 4: satırların hepsi bu turun dokunmadığı kişiler — IK'sı kapalı (`ik=w0`)
  sahne kişileri ve "crouch" duruşundaki bölük; koşudan koşuya kameranın baktığı yere göre değişiyor (26:hold 5 → 0 ters
  yönde). Bu turun ayak değişiklikleri yalnız dik yüzde ve yokuş aşağı koşuda çalışıyor.

## Hâlâ kötü olanlar
1. YIGILMAAUDIT hedefi 0 değil, **15**: yaslanan gövde (bel eklemi yok: Person tek gövde düğümü), kenardan sarkan uzuv
   (26 kenardan atılan: iki ayak +1,6, kök nedeni bulunamadı), taşa giren uzuv (ızgara çözünürlüğü).
2. Deney sahnesinde **kök taşın içinde başlarsa** gövde fırlıyor ve havada kalıyor (molozda).
3. Bütçe: 30o'da bir karede %8,5 (sınır eklenmeden önce). Kişi başı adım ~0,2 ms (GDScript): 8 kişi 60 FPS'te ~1,5 ms.
4. Oyun içi kanıt kareleri yok (botun kamerası); deney sahnesinde kenardan atılma ve kalkış kareleri zayıf.
5. Kapsam dışı kalanlar: Assault'ta okla vurulan koşanlar ve SiegeChaos (MultiMesh kopyalar), `battle_extras.gd`
   devirmeleri, 30 m'den uzaktaki merdiven düşüşleri (eski yol), hayvanlar, Tolga.
6. Merdivenden düşen asker 1,1 sn'de donar (Assault onu 2,2 sn'de batırıp yeniden kullanıyor); yere çarpışta hafif
   "ağır çekim" olabilir (kare bütçesi aşıldığında adım bir sonraki kareye kalır).
7. `Stage.grip_hold` iş pozları (önceki turdan): dokunulmadı (başka oturumun dosyası).

## run_tests.sh isteği (yönetici için; dosyaya dokunulmadı)
Süzgece `YIGILMAAUDIT` eklenmesi (bilgi; testi düşürmesin): `grep -E "…|YIGILMAAUDIT"`. Satırın biçimi
`YIGILMAAUDIT fizik|klip scene=… who=Sınıf/ad(üst) at=… bas=±… govde=±… el_l|el_r=±… ayak_l|ayak_r=±…`. Hedef 0'a
ulaşılmadığı için düşürücü yapılmamalı.

## Dokunulan dosyalar
`scripts/npc/yigilma.gd` (yeni), `rig.gd` (savrulma duruşu "fall", YIGPERF kancası), `person.gd` ve `soldier.gd`
(`shot()`; yığılan bedende gövde sallanması yok), `ayak.gd` (dik moloz, yokuş aşağı koşu);
`scripts/combat/duelist.gd` yalnız `knock_down`, `collapse`, `_freeze`, `fall_off`, `_fall_land`, `_fall_splash`, DOWN
kalkışının bir satırı ve yeni yardımcılar (`_yig_*`); `scripts/level/assault.gd` iki kanca satırı (+ preload);
`tests/_fizik/yigilma_*` (deney sahnesi, koşu/kare betikleri, pafta, tablo). Bölüm dosyaları, `scripts/world/ist`,
`scripts/player`, `scripts/ui`, `tests/run_tests.sh`, `project.godot`: dokunulmadı. Replik, ses, denge, sayaç değişmedi.
Kapatma: `--yigilma=0` (ÖNCE ölçümü).
