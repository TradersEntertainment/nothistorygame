# FİZİK-AYAK — ayaklar yere bassın (oyun geneli ayak yerleştirme)

Dal `wip/fizik-ayak` (taban `wip/ist2-birlesik` 5203a40e). Yöntemin ayrıntısı: [`yontem.md`](yontem.md).
Sahibin sözü (37o an_04): "ayaklar havada falan duruyor … ayaklar hep yere bassın; karakter çapraz mı durur artık, bir
ayağı eğik mi durur".

## Özet

| # | İstek | Durum | Not |
|---|---|---|---|
| 1 | Ayak yerleştirme, bütün insanlar (IK, kalça alçak ayağa, taban eğime, gövde dik, yürürken basan ayak kilitli) | **TAMAM** | `scripts/npc/ayak.gd`; Person, Soldier, Hikmet ve LimbAnim'le oynatılan düellocu gövdesi. Yürüyüş, koşu, merdiven/basamak, rampa, moloz, sur yolu, kalas. Kadans hızdan (ayak kayması bitti). |
| 2 | Kapsam dışı durumlar bozulmasın | **TAMAM** | Oturan, yatan/ölü, tırmanan, binen, taşınan, uçan/yüzen, DurusKit duruşları, kilitli iskelet (LimbAnim'li ayaktaki klip hariç: onun duruşunda izdüşüm), meşgul (sahne betiğinin oynattığı iş), devrilen, çarpışmasız döşemedeki: IK kapalı, duruş aynen. |
| 3 | Hayvanlar | **TAMAM** (basit) | At, öküz, keçi: ön/arka zemin farkından gövde eğimi (≤ 17°) ve yüksekliği, bacaklar dik. Tavuk, kedi: yükseklik. Toynak başına IK yok. |
| 4 | Bütçe (LOD, seyrek ışın, ölçüm ≤ %5) | **KISMEN** | LOD 28 m + görüş konisi, düzde duranda yazma yok, ışın adım başına. Bölümlerde IK payı kare betik süresinin %0,0–1,5'i (işlem süresi farkı koşu gürültüsü içinde: −%30…+%11); ama 68 kişinin hepsinin yakında ve eğimde olduğu deney sahnesinde **+%21** (hedef aşıldı; kişi tavanı önerildi, yapılmadı). |
| 5 | AYAKAUDIT, ÖNCE\|SONRA 15+ bölüm | **KISMEN** | 20 koşu (15 istenen bölüm + ordugâh 24o + şehir 24 + 3 kalabalık çeşit). Yakın satır **87 → 5**; hedef 0'dı: kalan 5'in 2'si IK kapsamı dışındaki meşgul iş pozu (26 =hold), 1'i sur kenarında taban ucu (26 =hold), 2'si dik molozda burun/topuk gömüklüğü (37o =trespass). Kenar kuralı sonradan 30 → 20 cm yapıldı; 20 ve 26 yeniden: 20 → 0, 26 → 1 (asker, dik yüzde burun −0,11). |
| 6 | Kanıt kareleri ÖNCE\|SONRA | **KISMEN** | 37o an_04, 20 gedik, 22o dolgu/kıyı, şehir, ordugâh oyun içinden; yan profil, merdiven, basamak, at deney sahnesinden (oyun içinde bu koşularda kameraya düşmedi ya da gizliydi). 20'nin yan karesi kenar düzeltmesinden önceki sürümle (kötü; düzeltildi, yeniden çekilemedi). |

## Yöntem (kısa)
- **IK**: iki kemikli (uyluk L1, baldır L2 CharKit.leg'den; diz kosinüs yasası, uyluk FK düzlemini koruyan en kısa dönüş).
  Kalça kök uzayında her ayağın erişim sınırına göre iner (en çok 0,5 m), gövde yalnız kaydırılır (dik). Taban
  zemin normaline döner (ileri eğim bilek x'i, yanal eğim bilek z'si).
- **Yürüyüş**: Rig'in evresinden basma/salınım (basma payı 0,56 → koşuda 0,25); basan ayak ebeveyn uzayında kilitli;
  salınan ayak bir sonraki basma noktasına (hızdan öngörü) kalçaya göre sarkaç + yay. Adım boyu hızdan
  (0,2 + 0,2·v m): eski kadans (3 + 1,6·v rad/sn) ayağı gövdenin yarı hızında geri götürüyordu.
- **Işın sıklığı**: dururken ayak başına bir (ayak 6 cm kayınca ya da 1–1,3 sn'de bir yeniden); yürürken adım başına
  iki (basma + iniş öngörüsü). Işın Unclip.floor_y ölçüsü: yalnız görünen/basılabilir çarpışma.
- **LOD**: ≤ 28 m ve görüş konisinde (koni testi her karede, ucuz). Kamera kesmesinde görüşe giren kişide anında,
  yürüyerek sınırı geçende 0,25 sn'de yumuşak. Uzaktakiler eski yol (kök `Unclip.rest_settle` ile zemine).
- **Denetim (AYAKAUDIT)**: yarım saniyede bir, kameranın gördüğü 40 m içinde, o an basması gereken her ayak;
  tabanın topuk/orta/burun noktalarından biri zemine ≤ 6 cm değilse "havada", biri 6 cm'den derinse "gömük"; iki
  ardışık ölçümde süren bir kez yazılır. Ayrıntı `yontem.md`.

## AYAKAUDIT ÖNCE | SONRA (bölüm bölüm)
ÖNCE: aynı kod `--ayak-ik=0` (IK ve yeni kadans kapalı = tabanın davranışı). `--max-fps 20`, ekransız, `--autotest`.
Günlükler (süzülmüş): [`gunluk/`](gunluk/). Satır: kişi-ayak başına bir kez.

| Bölüm | ÖNCE sonuç | ÖNCE AYAKAUDIT yakın / hepsi | SONRA sonuç | SONRA AYAKAUDIT yakın / hepsi | öteki denetim (ÖNCE → SONRA) |
|---|---|---|---|---|---|
| 0 | PASS | 0 / 0 | PASS | **0** / 0 | 0 → 0 |
| 1 | PASS | 0 / 0 | PASS | **0** / 0 | 0 → 0 |
| 2 | PASS | 0 / 0 | PASS | **0** / 0 | 0 → 0 |
| 8y | PASS | 0 / 0 | PASS | **0** / 0 | 0 → 0 |
| 10h | PASS | 0 / 0 | PASS | **0** / 0 | 0 → 0 |
| 12b | PASS | 0 / 0 | PASS | **0** / 0 | 0 → 0 |
| 20 | PASS | 3 / 3 | PASS | **0** / 0 | 0 → 0 |
| 20:hit | PASS | 3 / 3 | PASS | **0** / 0 | 0 → 0 |
| 20o | PASS | 2 / 2 | PASS | **0** / 0 | 0 → 0 |
| 22o | PASS | 0 / 0 | PASS | **0** / 0 | 0 → 0 |
| 26 | PASS | 29 / 32 | PASS | **0** / 0 | 0 → 0 |
| 26:hold | PASS | 27 / 27 | PASS | **3** / 3 | 0 → 0 |
| 30o | PASS | 0 / 0 | PASS | **0** / 0 | 1 → 1 |
| 37o | PASS | 14 / 14 | PASS | **0** / 0 | 1 → 1 |
| 37o:trespass | PASS | 9 / 9 | PASS | **2** / 2 | 1 → 1 |
| 43o | PASS | 0 / 0 | PASS | **0** / 0 | 0 → 0 |
| 44b | PASS | 0 / 0 | PASS | **0** / 0 | 0 → 0 |
| 28o | PASS | 0 / 0 | PASS | **0** / 0 | 0 → 0 |
| 24o | PASS | 0 / 0 | PASS | **0** / 0 | 0 → 0 |
| 24 | PASS | 0 / 0 | PASS | **0** / 0 | 0 → 0 |
| **toplam** | | **87** / 90 | | **5** / 5 | |

**Kalan 5 satır (SONRA, yakın)**
- 26 =hold, `act=hammer` (d 1,4) ve `act=chop` (d 5,4), burun 11–13 cm gömük: kişi Stage'in iş tutuşunda (`_busy`),
  bacakları sahne betiğinin pozu; IK kapsam dışı (ik=w0). Pozun kendisi (öne basan ayağın burnu yere giriyor) — **kötü**,
  benim dosyam değil (Stage), istek olarak yazıldı.
- 26 =hold, duran kişi (d 1,8) sağ ayak −0,09: sur kenarında, tabanın bir ucu taşın içinde.
- 37o =trespass, molozda duran asker (d 6,1) iki ayak −0,10/−0,12: kalça 0,40 inmiş, ayaklar zeminde ama dik moloz
  yüzünde taban düz (normal dik yüzde düz sayılıyor) → burun/topuk taşa giriyor.

## Kare süresi (ÖNCE | SONRA)
Otomatik testte kareler çok uzun (kare başı 40–500 ms işlem: test botu, ekransız) ve koşudan koşuya ±%20 oynuyor:
iki koşunun işlem süresi farkı gürültü. Daha sağlam ölçü **IK'nın kendi süresi** (`Time.get_ticks_usec`, kare başı)
ve bunun SONRA işlem süresine oranı (`--ayak-olc`, `AYAKPERF` satırları).

| Bölüm | ÖNCE işlem ms/kare | SONRA işlem ms/kare | fark | SONRA IK µs/kare | IK'lı kişi/kare | ışın/kare | IK payı (SONRA işlemin %) |
|---|---|---|---|---|---|---|---|
| 2 | 517.72 | 407.82 | -21.2% | 249 | 5.1 | 2.20 | 0.06% |
| 8y | 79.53 | 85.48 | +7.5% | 349 | 1.9 | 0.62 | 0.41% |
| 20 | 72.34 | 72.32 | -0.0% | 832 | 11.4 | 8.09 | 1.15% |
| 20:hit | 76.93 | 71.35 | -7.3% | 699 | 10.3 | 6.60 | 0.98% |
| 20o | 64.76 | 59.93 | -7.5% | 247 | 4.4 | 1.42 | 0.41% |
| 22o | 67.83 | 60.02 | -11.5% | 383 | 4.5 | 3.43 | 0.64% |
| 26 | 115.37 | 109.88 | -4.8% | 980 | 23.9 | 9.72 | 0.89% |
| 26:hold | 118.23 | 114.48 | -3.2% | 1243 | 25.3 | 10.40 | 1.09% |
| 30o | 59.60 | 65.72 | +10.3% | 96 | 3.0 | 0.62 | 0.15% |
| 37o | 41.47 | 36.38 | -12.3% | 548 | 6.0 | 5.40 | 1.51% |
| 37o:trespass | 42.15 | 37.82 | -10.3% | 577 | 6.0 | 5.80 | 1.53% |
| 43o | 50.07 | 46.42 | -7.3% | 48 | 1.1 | 0.37 | 0.10% |
| 44b | 115.38 | 81.27 | -29.6% | 2 | 0.0 | 0.03 | 0.00% |
| 24 | 285.26 | 315.93 | +10.8% | 1071 | 22.3 | 21.75 | 0.34% |

(0, 1, 10h, 12b, 28o, 24o: AYAKPERF satırı yok ya da kişi yok: koşu 10 sn'den kısa ya da Rig'li kişi görünmüyor.)

**Gerçek zamanlı en kötü durum** (deney sahnesi `tests/_fizik/ayak_sahne.tscn --ayak-kalabalik=60`, ekransız, kare
sınırı yok; 60 kişi + 9 denek hepsi kameranın 25 m içinde ve görüşte, yarısı yürüyor, çoğu eğimde/molozda):

| Koşu | işlem ms/kare (10 sn ortalamaları) | IK µs/kare | IK'lı kişi | ışın/kare |
|---|---|---|---|---|
| ÖNCE (`--ayak-ik=0`) | 17,0 · 13,6 · 16,3 (ort. 15,7) | 0 | 0 | 0 |
| SONRA | 20,1 · 18,8 · 18,1 (ort. 19,0) | 1638 · 1701 · 1496 | 68 | 3,1–3,7 |

En kötü durumda betik süresi **+%21** (IK'nın kendi payı %8,6; kalanı yeni yazılan dönüşümlerin alt ağaçta yayılması):
**%5 hedefini aşıyor** — 68 kişinin hepsi aynı anda 25 m içinde, görüşte ve eğimde/yürürken. Bölümlerde (yukarıdaki
tablo) aynı anda IK'lı kişi 1–25 ve IK payı %0,0–1,5. Öneri (yapılmadı): kare başına IK'lı kişi tavanı (en yakın ~24;
12 m içindekiler hep).

Kişi başı IK ~21 µs/kare (iki bacak + kalça + taban; ışınsız), ışın ~30–60 µs (sahnenin karmaşıklığına göre) ama kişi
başı saniyede ~1–5. Düz zeminde duran kişide IK hiçbir şey yazmaz. Çizim çağrısı ve üçgen değişmez (yalnız mevcut
düğümlerin dönüşümü değişir; yeni ağ yok) — 37o `=kare` bütçe satırları (TASIMA37OKARE çizim/ilkel) ÖNCE|SONRA aşağıda.

| Kare | ÖNCE çizim / ilkel | SONRA çizim / ilkel |
|---|---|---|
| 37o an_01 yürüyüş | 1190 / 1 268 342 | 1204 / 1 277 856 |
| 37o an_04 barikat | 1028 / 1 417 962 | 1030 / 1 408 861 |
| 37o an_06 geri bakış | 1342 / 1 436 544 | 1282 / 1 393 224 |
| 22o an_01 açılış | 3474 / 3 361 310 | 3468 / 3 353 058 |
| 22o an_03 dolgu ucu | 2900 / 2 776 141 | 2896 / 2 769 167 |

(Farklar ±%5 içinde ve iki yönde: koşudan koşuya kişilerin yeri/LOD'u; yeni ağ eklenmedi.)

## Kareler (oyuncu kamerası + yandan; 1280×720, jpg 85) — [`kare/`](kare/)

### Deney sahnesi (`tests/_fizik/ayak_sahne.tscn`, yandan; sol ÖNCE, sağ SONRA)
| Kare | Sahne | SONRA (tek cümle) |
|---|---|---|
| [`sahne_yokus25_dik`](kare/sahne_yokus25_dik_once_sonra.jpg) | **Yan profilden yakın kişi, 25° yanal eğim** | Yokuş yukarı bacağın dizi bükük, öteki düz; iki taban yamaçta, gövde dik: doğal. |
| [`sahne_yokus_dik`](kare/sahne_yokus_dik_once_sonra.jpg) | 15° yanal eğim | Fark küçük (ayaklar 0,2 m arayla: 5 cm); iki taban yamaçta. |
| [`sahne_moloz_asker`](kare/sahne_moloz_asker_once_sonra.jpg) | Molozda asker | ÖNCE sol ayak taşın üstünde havada; SONRA sol diz bükük, taban taşa basıyor, sağ ayak alttaki taşta: doğal. |
| [`sahne_merdiven_dur`](kare/sahne_merdiven_dur_once_sonra.jpg) | Basamak kenarında duran | İki ayak basamaklarda (biri bir alttakinde, dizi bükük): iyi. |
| [`sahne_merdiven_yuru_1`](kare/sahne_merdiven_yuru_1_once_sonra.jpg) | Merdiven çıkan | Kadraj kötü (öndeki duran kişi örtüyor); görünen kısımda çıkan kişinin ayağı basamakta: **kabul**. |
| [`sahne_yokus_yuru_1`](kare/sahne_yokus_yuru_1_once_sonra.jpg) | Yokuş yukarı yürüyen | Basan ayak yamaçta kilitli, adım boyu hızla uyumlu, gövde dik: doğal. |
| [`sahne_yokus_kos_1`](kare/sahne_yokus_kos_1_once_sonra.jpg) | Yokuş aşağı koşan | İki ayak yamaçta, adım kısa (bu karede koşu adımının ortası); ÖNCE geniş adımda ayaklar yamacın içinde/üstünde: iyi. |
| [`sahne_at_yokus`](kare/sahne_at_yokus_once_sonra.jpg) | **At eğimde** (25°) | Gövde yokuşa göre eğik (sınır 17°), dört toynak yamaçta, bacaklar dik: iyi; 17°'yi aşan kısım ön bacaklarda birkaç cm gömük. |
| [`sahne_okuz_yokus`](kare/sahne_okuz_yokus_once_sonra.jpg) | Öküz eğimde (15°) | Gövde eğik, toynaklar yamaçta: iyi. |

### Oyun içi (oyuncu kamerası; sol ÖNCE, sağ SONRA)
| Kare | Sahne | SONRA (tek cümle) |
|---|---|---|
| [`c37o_an04_barikat`](kare/c37o_an04_barikat_once_sonra.jpg) | **37o an_04, sahibinin karesi** (oyuncu kamerası) | Soldaki askerin bacakları rampanın kenarının ardındaki alçak molozuna iniyor (dizler bükük, ÖNCE düz bacakla rampa hizasında havadaydı); taban bu açıdan rampanın kenarının arkasında kaldığından tabanın kendisi görünmüyor — havada görünmüyor, ama "ayak yerde" diye de görülmüyor: **kabul**. |
| [`c37o_an04_barikat_yan`](kare/c37o_an04_barikat_yan_once_sonra.jpg) | 37o an_04, aynı anda yandan (arkadan-üstten; kamera duvar yüzünden profil bulamadı) | Rampa yamacındaki askerin bir dizi bükük, ayakları yamaca yakın; açı arkadan-üstten olduğundan tabanın yamaca değip değmediği kesin seçilmiyor (denetim bu kişide 0) — **belirsiz**; kayma tek karede görülmez. |
| [`c20_an03_gedige_tasima`](kare/c20_an03_gedige_tasima_once_sonra.jpg) | **Bölüm 20, gediğe yürüyen işçiler** | İşçiler kaldırımda adım atıyor, basan ayaklar taşta; düz zeminde fark adım boyunda (ÖNCE ayaklar kayıyordu): iyi. |
| [`c20_an03_gedige_tasima_yan`](kare/c20_an03_gedige_tasima_yan_once_sonra.jpg) | 20, platform kenarındaki işçi (yandan) | Bu kare kenar kuralından ÖNCEki sürümle: işçi bir ayağını alttaki toprağa uzatıp iki dizi derin bükük, çömelmiş gibi — **kötü**; düzeltildi (kenar 20 cm: o ayak platformun üstüne çekilir), son kodla yeniden çekilemedi (süre). |
| [`c22o_an03_dolgu_uc_sepet`](kare/c22o_an03_dolgu_uc_sepet_once_sonra.jpg) / [`_yan`](kare/c22o_an03_dolgu_uc_sepet_yan_once_sonra.jpg) | **Bölüm 22o sur yolu/dolgu ucu ve rampa** | Dolgunun tahta ucunda duran işçinin tabanları tahtada, ÖNCE ile fark küçük (zemin farkı 10 cm): iyi. |
| [`c22o_an02_kiyi_sepet`](kare/c22o_an02_kiyi_sepet_once_sonra.jpg) / [`_yan`](kare/c22o_an02_kiyi_sepet_yan_once_sonra.jpg) | 22o kıyı yamacı (çamur, cesetler) | Yürüyen işçinin basan ayağı yamaçta, öteki salınımda; ÖNCE ile çok benzer: iyi. |
| [`c24_t80`](kare/c24_t80_once_sonra.jpg) / [`_yan`](kare/c24_t80_yan_once_sonra.jpg) | **Şehir (24)**, kalabalık sokak | Kaldırım düz: duranlarda IK yazmıyor (düz zemin), görünüş ÖNCE ile aynı; şehirde basamak/eğimde bir kişi bu koşuda kameraya düşmedi — **eksik** (basamak örneği deney sahnesinde). |
| [`c24o_t45`](kare/c24o_t45_once_sonra.jpg) | **Ordugâh (24o)** | Kameradaki asker düz çadır yolunda: IK yazmıyor, ÖNCE ile aynı; yan kare bir arabanın arkasında kaldı (atıldı); ordugâhta eğimde bir kişi bu koşuda kameraya düşmedi — **eksik** (eğim örneği deney sahnesinde ve 37o/22o'da). |
| — | **At eğimde (oyun içi, 28o)** | Koşunun ilk 26 saniyesinde atlar gizli (kare alınamadı) — **eksik**; at eğimde kanıtı deney sahnesinden (aşağıda `sahne_at_yokus`). |
| — | **Merdiven çıkan** | Oyun içinde kameraya düşmedi; deney sahnesinde `sahne_merdiven_yuru_1`. |

## Hayvanlar
Deney sahnesinde 25° yokuşta at ve 15° yokuşta öküz: ÖNCE gövde yatay, arka toynaklar havada/ön toynaklar gömük;
SONRA gövde yokuşa göre eğik (en çok 17°), dört toynak yamaçta (`kare/sahne_at_yokus_*.jpg`, `kare/sahne_okuz_*`).
Keçinin kökü betikte hep y = 0 (düz ağıl varsayımı): yokuşta kök zeminin altında kalıyor, ışın üstündeki zemini görmüyor
→ keçi yokuşta düzelmez (bölümlerde keçi düz ağılda; **hâlâ kötü**: keci yokuşa konursa).

## Hâlâ kötü olanlar
1. **Meşgul iş pozları** (Stage.grip_hold: çekiç, balta; 26): öne basan ayağın burnu 11–13 cm yere giriyor; IK bu
   pozlarda kapalı (sahne betiği bacakları sürüyor). Stage'e (benim dosyam değil) istek: tutuşta `rig.ayak` izdüşümü.
2. **Dik moloz yüzü** (> 56°): taban düz kalıyor, burun/topuk taşa giriyor (37o =trespass, 2 satır). Topuk-burun iki
   ışınla taban eğimi verilebilir (ışın ×2).
3. **Görünen ama çarpışmasız döşeme** (26'da sur içi döşeme ağı): ışın görmediği için IK kapalı; ayaklar o zemine kökün
   yüksekliğiyle (Rig'in eski yolu) basıyor — denetim de VISAUDIT gibi orayı zemin sayıyor.
4. **Uzaktakiler** (> 28 m, görüş dışı): eski yol; eğimde iki ayak aynı yükseklikte (AYAKAUDIT "uzak" satırları).
5. **Kalabalık (Crowd) çoklu ağ figürleri**: donmuş, pişmiş kopya: IK yok (tek ağ); kökleri yerleştirenin verdiği yerde.
6. **Koşuda basma**: kısa (0,25) ve kalça topuk/burun yuvarlanması için az iner; hızlı yokuş aşağı koşuda adımın
   uçlarında ayak 3–5 cm havada kalabiliyor (denetim penceresi dışında).
7. Keçi yokuşta (yukarıda).

## run_tests.sh isteği (yönetici için; dosyaya dokunulmadı)
Süzgece `AYAKAUDIT` eklenmesi önerisi (testi düşürmesin, bilgi): satırın biçimi
`AYAKAUDIT yakin|uzak scene=… who=… ayak=L|R fark=±… d=… at=… durum=… act=… ik=…`. Düşürmesi istenirse yalnız
`AYAKAUDIT yakin` satırları (kameraya ≤ 25 m) sayılmalı; uzaktakiler bilerek ucuz yolda.
Önerilen satır (run() içinde, VISAUDIT'in yanına): `grep -E "…|AYAKAUDIT yakin"`.

## Dokunulan dosyalar
`scripts/npc/ayak.gd` (yeni), `ayak_denet.gd` (yeni), `ayak_hayvan.gd` (yeni), `rig.gd` (kanca, kadans, bilek ek eğimi),
`limb_anim.gd` (kanca), `horse.gd`, `ox.gd`, `goat.gd`, `chicken.gd`, `cat.gd` (eğim düğümü, bacak açısına eğim);
`tests/_fizik/` (deney sahnesi, koşu/kare betikleri, kare aracı, tablo). `scripts/combat/` değişmedi (düellocu LimbAnim
kancasıyla geliyor). Çarpışma, yol, replik, ses, denge, sayaç değişmedi; `unclip.gd` ara sürümde değişip geri alındı.

## Notlar
- 10h'de bir koşuda (SONRA, ara sürüm) çökme: paralel süreçlerin ortak disk önbelleğine (`user://ist_onbellek/ev`)
  aynı anda yazması ("Unrecognized binary resource file"); tek başına iki kez PASS, son tabloda PASS. Kodla ilgisiz.
- Kalabalık pişirme önbelleği (`Crowd._cache_path`) rig.gd'nin içeriğiyle tuzlandığından ilk açılışta yeniden pişer.
