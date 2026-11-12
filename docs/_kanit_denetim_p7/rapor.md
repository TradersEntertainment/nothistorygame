# P7 bağımsız denetim raporu (Bölüm 26, 0, 21; `assault.gd`)

Denetlenen: `1e3a9b60` (ÖNCE) ↔ `94571766` (SONRA, `wip/yardimci-p7`). Dal: `wip/denetim-p7`.
Godot 4.4.1, başsız testler `--max-fps 20`; ekranlı koşular `xvfb-run` 1280×720 llvmpipe (yazılım çizimi, FPS ~1-10).
ÖNCE: depo dışında kopya proje (`~/w/before`), 4 betik `git show 1e3a9b60:<dosya>` ile eski hâle getirildi (`cmp` ile doğrulandı). Depodaki oyun dosyalarına dokunulmadı.
Kare/ölçüm sondası: geçici `tests/_tmp/pr26.gd`, `pr21.gd`, `pr0.gd` (yalnız olay anında kare alır, ölçüm basar; iş bitince silindi, oyun koduna kanca konmadı). Aynı olay anı = Melee'nin merdiven kaydı (`hold`/`down`), Bölüm 0'da `phase`, Bölüm 21'de delme/madenci olayı; ÖNCE ve SONRA aynı sonda.

## GENEL HÜKÜM: KÜÇÜK DÜZELTMELERLE KABUL

Görünür kazanımlar doğrulandı (26'da merdiven ve eller artık kadrajda, kılıç tutuşta cepte, bakış geri veriliyor; 0'da demet savunucunun elinde ve okçu durumu çalışıyor; 21'de madenci kazması okunuyor). Ama: (a) 26 itmede devrilme anında eller sırıktan kopuyor ve havada kalıyor (raporun "devrilirken eller onunla gider" iddiası ölçümde tutmuyor), (b) devrilmenin ilk ~0,4 sn'sinde çizim/üçgen bütçesi kural dışı (+%25…%31; ÖNCE'de yok), (c) merdiven boyu/eğimi oynanış süresini değiştiriyor (kural: süre değişmez). Aşağıdaki ZORUNLU düzeltmeler küçük ve yerel.

### ZORUNLU düzeltmeler
1. `scripts/chapter26.gd:_ladder_push_tick` ("tip" durumu): devrilme başlar başlamaz eller sırıkta takip edemiyor (`Player._hold_both_points` noktaları erişim kutusuna sıkıştırıyor, `player.gd:2830`). Beklenen görünüm: devrilme başladığı karede eller sırıktan en çok ~20 px uzakta, sonra iner; havada boş duran yumruk yok. Öneri: "tip"e geçerken sabitle ve hemen bırak:
   ```gdscript
   "grip":
       if float(_push["down"]) > 0.0:
           _push_state = "tip"; _push_t = 0.0
           player.release_both()          # kutu sıkıştırması sırığı kaçırır: elleri havada tutma, hemen indir
           player.free_hold = Vector3.INF
   ```
   (ya da `hold_both(..., target=null)` ile devrilmeden önceki kamera-yerel noktalara kilitle ve 0,15 sn'de aşağı çek).
2. `chapter26.gd:_push_aim` ("tip", `step=false`): bakış merdivenin ortasını izlerken pitch −0,95 → −0,3'e çıkıp ovayı kadraja alıyor; bütçe aşımının nedeni bu. Beklenen: devrilme boyunca ova kadraja girmez, çizim ve üçgen ÖNCE'ye göre +%8'i aşmaz. Öneri:
   ```gdscript
   var want_pitch := atan2(to.y, Vector2(to.x, to.z).length())
   if not step: want_pitch = minf(want_pitch, -0.85)     # devrilirken yere (merdiven dibine) bak, ufku gösterme
   player.camera.rotation.x = lerpf(player.camera.rotation.x, want_pitch, k)
   ```
3. `chapter26.gd:_build_walls_scene`: merdiven 9,0 m/16° → 9,8 m/14,5° oldu. Tırmanış süresi uzar (rapor: ~%9), oysa kural "süre değişmez". Ya eski boy/eğim geri gelir ya da Melee'deki tırmanış hesabı eski boydan (9,0 m) yapılır (`Ladder.height` yerine sabit), ve tutuş noktası `_push_grip_pts` mazgal yüksekliğine göre ayrıca ayarlanır. Beklenen: hiçbir bölümde tırmanış/itme süresi ÖNCE'den farklı değil.
4. `chapter0.gd:_hit`: teslimin ilk karesinde (+0,05 sn) demet savunucunun elinde değil, kalçası hizasında yanında duruyor (p05); +0,8 sn'de başının üstünde tek elle tutuluyor. Beklenen: demet ilk karede ona uzanan elde ya da göğüs hizasında, iki elin arasında.
5. `chapter21.gd:_breakthrough` delme anı: ayırt edilebilir kazma karesi yok (toz gizlenince bile çatlak parçalarından ayırt edilmiyor, p10). Beklenen: demir uç ve sap yakından seçilir; yoksa madde "kanıtsız" kalır.

(Zorunlu olmayan: hold_lose ARMAUDIT'i ÖNCE'de de çıkıyor, aşağıda.)

## Madde madde hüküm (geliştirici raporu)

| # | Madde | Hüküm | Kanıt |
|---|---|---|---|
| 1 | 26 itme: merdiven kadrajda, iki el merdivende | **KISMEN** | ÖNCE: kılıç elde, merdiven yok (p01/p03). SONRA: merdiven ve iki el kadrajda, kılıç/kalkan cepte. Avuç–sırık mesafesi tutuşta hold 0,40 sn: sol 32/sağ 213 px; 0,54: 78/16; 0,67: 70/66 px (3B ~10 cm); devrilme +0 sn: 37/36 px. Yani ≤20 px yalnız tek bir örnekte, tek elde sağlandı; çoğu karede 65-80 px. |
| 1a | merdiven başı kadrajda | **DOĞRULANDI (kısmen)** | Tutuşta sırıklar ve basamaklar kadrajın ortasında; sırık ucunun kendisi (tepe) kadrajın altında (`top_in_view=false`), eller ve gövde görünür. |
| 1b | devrilirken eller bırakıyor | **YANLIŞ (iddia)** | `down>0` +0,08 sn: avuç–sırık 196/192 px (0,50 m), +0,12 sn: 207/204 px (0,71 m), +0,3 sn: 209 px (2,0 m); eller +0,35-0,4 sn'ye kadar boşlukta, sonra bırakıyor (p02, p04). Rapor "+0,12 sn'de 0,034/0,039 m" diyor; benim ölçümüm 0,71 m. Ölçüm düşük FPS'te; ama nedeni kod: erişim kutusu sıkıştırması (`player.gd:2830`), 60 FPS'te de ≥0,2 m kayma bekleniyor. |
| 1c | bakış betikle çevriliyor, bitince geri veriliyor | **DOĞRULANDI** | Tutuş öncesi yaw −2,70 / pitch −1,07 / eye 1,62; bitişte aynı değerler (log `pr26_el_sirik_olcum_SONRA.txt`). Toplam denetim kaybı ~1,5 sn (<3 sn). |
| 1d | eldeki eşya cebe gidip geri geliyor | **DOĞRULANDI** | `_held_model.visible`: tutuşta false, sonra true; `_hands_busy`/`_stow_n` 1→0; kılıç/kalkan gizli→görünür. |
| 1e | merdiven 9,0→9,8 m (uç mazgalın üstünde) | **DOĞRULANDI (görünürlük), KURAL İHLALİ (süre)** | p01/p03: ucu görünüyor. Tırmanış süresi artışı doğrudan ölçülmedi (kod farkı: `Ladder.new(9.8, 14.5)`, rapor %9 diyor): kural gereği ZORUNLU 3. |
| 2 | 26 baltalı asker | **BAKILMADI** | Kod değişmedi (diff'te yok); geliştirici de DURUYOR diyor. |
| 3 | 0: okçular / savunucular | **KISMEN** | Sonda günlüğü (`PR0 archers`): 4 okçu `draw` durumunda `Bow.rotation.x` 0,00→1,45, ok sayısı 1 (uçuyor), sonra yere inip siliniyor; kuşbakışı karede (p07) yay kalkmış okçu seçiliyor; ortadaki ikisi oyuncuya dönük (p05/p06, p12). Ok uçuşu karede yakalanmadı; el sallama/göstermesi (`idle_vary`) **KANITSIZ**. Not: otomatik testte koşu ~2 sn sürdüğü için yalnız 2 okçu çekiyor. |
| 4 | 0: demet teslimi | **KISMEN** | ÖNCE: demet uçarak göğüste kayboluyor (p05). SONRA: +0,05 sn'de demet kalçada, +0,8 sn'de başın üstünde tek elde, +1,6 sn'de çömelen savunucunun elinde. Havada değil, elden ele geçiyor; ama ilk an elde değil (ZORUNLU 4). |
| 5 | 0: koşarken eller yükte | **KISMEN** | p12: SONRA'da sağ el demetin üst kenarında açık avuçla duruyor, kavrama yok (rapor da böyle diyor); sol el kalkan altında (ÖNCE'de de vardı). |
| 6 | 21: madenci kazması | **DOĞRULANDI** | p09 (arayüz gizli): SONRA'da demir baş gövdenin önünde, sap sol elde; ÖNCE'de baş gövdenin ardında yalnız çubuk. Gerçek ölçülü (baş ~0,45 m, sap ~0,6 m). Normal oynanışta Nihat'ın altyazı kartı alt gövdeyi örter (ÖNCE'de de). |
| 7 | 21: duvardan çıkan kazma | **KANITSIZ** | Toz gizlendi (CPUParticles kapalı) ve tek kare alınabildi (p10): çatlak kutuları ile kazma ayırt edilmiyor; gerçek ölçü ve vuruş hedefi karede doğrulanamadı. Kodda `tool_model("pickaxe")` ve uç hedef yüzünde (`z+0,2`); karede doğrulanmadı. |
| 8 | assault/garrison donukluğu | **BAKILMADI** | Geliştirici de yapmadı. |
| 9 | Çizim yükü | **KISMEN (aşağıda)** | 0/21'de bütçe içinde (gürültü ±); 26'da itme penceresi +%25…%31 (ZORUNLU 2). |

Açık iki iş (görev metnine göre ölçüldü):

### hold_lose (26, 20×20 başsız, `--max-fps 20`)
| Sürüm | PASS | FAIL |
|---|---|---|
| ÖNCE | 14 | 6 |
| SONRA | 15 | 5 |

Bütün FAIL satırları aynı: `ARMAUDIT unarmed scene=chapter26.tscn foe_dist=<1.4-3.1> duel_active=false` (+ `AUTOTEST PASS ... outcome=26.1`). Ham: `ham/autotest_hold_lose_20x20.txt`. **Gerileme: YOK** (ÖNCE'de aynı oranda; fark gürültü içinde). Uyarı: o sırada makinede aynı anda ekranlı koşu + 2 başsız koşu vardı.
Kök neden (HİPOTEZ, doğrulanmadı): `duel.gd:199` kılıcı yalnız `player.hp > 0.0 and not player.is_down` iken `keep_drawn_blade`'e bırakıyor, dövüş bitince başka durumda kılıç `queue_free` (`duel.gd:213`); `melee.gd:_arm_audit` (`melee.gd:109-130`) ise sadece `is_down` ve `_hands_busy` hâllerini atlıyor. Bitmiş dövüşte 12 m içinde "geri çekilmemiş" düşman kaldıkça ARMAUDIT çıkıyor. Öneri (denetimi susturmadan): `Duel.stop` ele kılıç bırakmadan silerken Melee'nin bunu `duel.active==false and player.hp<=0` ile ayırması ya da dövüş bitince kılıcın `keep_drawn_blade` ile korunması (`player.keep_blade` hep true, `hp>0` koşulunu `hp>0 or foes yakında` yap). Bu P7 değişikliğinden bağımsız ve önceden vardı.

### Bölüm 26 itme performansı (aynı olaya hizalı; sonda `RenderingServer` verisi)
`ham/rinfo_itme_penceresi.txt`; t = ilk tutuş karesinden itibaren sn.

| t (sn) | ÖNCE çizim/üçgen | SONRA çizim/üçgen | Δçizim | Δüçgen |
|---|---|---|---|---|
| 0,0-0,6 (tutuş) | 7456-7523 / 9538-9639k | 7123-6814 / 9580-9053k | −%4…−%9 | −%0,6…−%5 |
| 0,8 | 7168 / 9370k | 6622 / 8192k | −%7,6 | −%12,6 |
| **1,0** | 7536 / 9555k | 9386 / 12011k | **+%24,5** | **+%25,7** |
| **1,2** | 7553 / 9610k | 9657 / 12562k | **+%27,9** | **+%30,7** |
| 1,4-3,0 | 7522-7681 / 9411-9722k | 7227-7527 / 9431-9834k | −%4…−%2 | −%1,7…+%2,0 |

**Gerileme: VAR** (kısa, ~0,4 sn: devrilmenin 0,1-0,3. saniyesi). Geliştiricinin kendi ölçümü (`tip_40 +%27/+%30`) doğrulandı; "grip" aralığı ise ÖNCE'ye göre DAHA HAFİF (rapordaki `grip_a +%16` bu koşuda yok: aralarında kare zamanlaması farkı var). Kök neden: `chapter26.gd:_push_aim(lad, delta, false)` (`chapter26.gd:2179`) "tip" durumunda bakışı merdiven ortasına çevirirken pitch −0,95 → −0,3 (ufuk), ova ve 100 binlik kalabalık kadraja giriyor (p02: sağda dev kalabalık). Düzeltme: ZORUNLU 2.

### Diğer RINFO (aynı replik anı; `screen_*.log`, 2 sn'lik örnekler)
| Bölüm | Örnek sayısı | max Δçizim | max Δüçgen | Not |
|---|---|---|---|---|
| 26 | 11 + 11 (iki koşu) | +%3,2 / ≤0 | +%4,0 / +%1,3 | Merdiven replikleri −%2…−%16 çizim |
| 0 | 4 + 4 | −%1,2 / +%13,6 (ilk koşu) | +%6,1 / +%6,8 | İkinci koşuda aynı an −%1,7/−%0,1: gürültü |
| 21 | 18 | **+%9,6** (D21_G_DIG), +%8,9 (D21_N_WHO), +%5,4 | +%3,7 | Aynı sahnede −%22'ye kadar da düşüyor; sahne küçük (~1300 çizim), örnek zamanı oynak. Çizim artmaz kuralı BELİRSİZ (ihlal olasılığı: DIG anında +125 çizim) |
Üçgen ≤ +%8 hiçbir 0/21 örneğinde aşılmadı.

## Yeni kusurlar (liste dışı)
1. (26, ÖNCE'de YOK) devrilme anında havada duran, hiçbir şeyi tutmayan iki yumruk (p02/p04): madde 1b ile aynı. ZORUNLU 1.
2. (26, ÖNCE'de YOK) devrilirken ova ve kalabalık kadraja giriyor → bütçe. ZORUNLU 2.
3. (0, ÖNCE'de YOK) teslimin ilk karesinde demet kalça hizasında, elde değil: ZORUNLU 4.
4. (0, ÖNCE'de VAR) oyuncunun önünde kameraya bitişik dev bir savunucu başı/gövdesi (p05/p12, ilk replikler): ÖNCE'de de aynı kadraj.
5. (26, ÖNCE'de VAR) dövüşte kameraya bitişik dev yüz/gövde karelerinde (kontak şeritleri) ÖNCE ve SONRA aynı; merdiven kodundan bağımsız.
6. (26) VISAUDIT `sunk` (warn_notrust): ÖNCE'de de çıktı (`OT_26_warn_notrust`: Person, spk=SPK_AZAP, shape=(8.6,0.55,2.4)@(0,2,15.6)); SONRA'da bu koşuda çıkmadı: önceden vardı, gürültülü.
Kalan listedeki türler: "gövdeye giren ip/eşya", "küp gibi ateş", "birden beliren kişi", "dev alet": değişen bölümlerde bu koşularda gözlenmedi (ama bkz. BAKILMADI).

## Kurallara uygunluk
- Replik anahtarı/sırası: diff'te değişmemiş. Tek değişiklik `chapter0.gd:_build`: 4 savunucudan `set_meta("spk","SPK_DEFENDER")` kalktı, yalnız bekleyen ikisinde kaldı (kartın konuşmacısı "en yakın savunucu" olarak hâlâ bir savunucu; sıra aynı).
- Süre: `Ladder.new(9.8, 14.5)` tırmanışı uzatıyor (rapor: ~%9): **İHLAL (ZORUNLU 3)**. Teslim/top süreleri değişmemiş (`0,05/0,5` zamanlayıcı yalnız el hareketi). İtme hold süresi (0,8 sn) aynı.
- Sayaç/sonuç koşulu: değişmemiş (testlerde sonuç satırları ÖNCE=SONRA: `outcome=26.1/26.3`, `gun=3/4`, vb.).
- Kalabalık sayısı: Bölüm 0'da 6 savunucu aynı (4 okçu + 2 bekleyen). Bot yolu: değişmemiş (testler aynı sonuçlarla geçiyor).
- Kanca/DBG/sonda: diff'te `print(`, `DBG`, `no_audit`, `_ok` meta YOK (`git diff 1e3a9b60 HEAD -- scripts | grep` boş). Susturulmuş denetim yok; `_hands_busy`/`_hand_shown` özel alanlarına `set/get` ile erişiliyor (kod kokusu, kural dışı değil: `chapter26.gd:2169-2207`, `chapter0.gd:_hands_on_load`).
- Dosya kapsamı: yalnız izin verilen 4 betik değişmiş.
- Oyuncudan denetim alma: itme ≈1,5 sn (<3 sn).

## Testler (ham: `ham/`)
`parse_check`: PASS (247 betik). SONRA, başsız, `--max-fps 20` (hepsi `AUTOTEST PASS`, yasaklı satır yok): 
- 0: "", next: 2/2
- 21: "", grant, fight, thermos, ear, captive: 6/6
- 26: "", nophoto, hold, hold_box, hold23, hold3, warn_notrust, lighter, isidore, kasim, candle, council_ok, council_bad: 13/13; hold_lose: **15/20** (yukarıda; FAIL'ler ARMAUDIT, ÖNCE'de 14/20)
- 20, 22, 26o, 30: 4/4
ÖNCE (karşılaştırma için 0, 21, 26 varyantları, hold_lose hariç): 20/21 RUNOK; tek FAIL `OT_26_warn_notrust` VISAUDIT sunk (özgün kodda).

## Bakılmadı / sınırlar
- Bölüm 26'nın yalnız dalga 1 merdiveni karelerle sınandı; Ayasofya, giriş alayı, şafak, 26.3 hold yolları, 26o, 30, 20 yalnız başsız testle (görsel BAKILMADI). `assault.gd` merdiven tek ağı (20, 26o, 32o, 37o, ana menü) görsel BAKILMADI.
- Değişen bölümler "baştan sona" ekranlı gezilmedi; 26 ve 0 için otomatik testin 0,5 sn'lik kare akışından örneklenmiş kontak şeritleri incelendi (bot sürekli aynı noktada dövüşüyor). 21 yalnız delme ve madenci anları.
- 26 baltalı asker (madde 2), assault/garrison donukluğu (madde 8), 0'da el sallama/gösterme, ok uçuşu karede: BAKILMADI / KANITSIZ.
- Ekranlı koşular llvmpipe'te çok düşük FPS'te; el–sırık ve devrilme ölçümleri gerçek 60 FPS'te farklı çıkabilir (yön ve neden kodla destekli ama ölçülmedi).
- Çizim/üçgen sayıları RenderingServer karesi; zaman kayması nedeniyle replik hizalı örnekler gürültülü (aynı bölümde ÖNCE/SONRA koşular arası ±%10).

## Paftalar (ÖNCE | SONRA)
p01 26 tutuş (+0,3 sn) · p02 26 devrilme +0,12 sn · p03 26 devrilme +0,4 sn · p04 26 eller havada (+0,1 sn) · p05 0 teslim +0,05 sn · p06 0 teslim +0,8 sn · p07-p08 0 savunucu hattı kuşbakışı (sonda kamerası) · p09 21 madenci · p10 21 delme anı (KANITSIZ) · p11 26 devrilme başlangıcı · p12 0 koşu, eller yükte.
