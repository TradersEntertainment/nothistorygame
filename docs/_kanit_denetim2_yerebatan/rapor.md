# Bağımsız denetim, 2. tur — Bölüm 44 Sarnıç (`chapter44b`)

Denetlenen: `wip/bolum-yerebatan` ucu `888a070a`. Denetçi dalı `wip/denetim2-yerebatan`. Oyun koduna dokunulmadı
(`git status`: izlenen dosyada değişiklik yok; yalnız Godot'un ürettiği `.import` dosyaları, kaydedilmedi).

Yöntem (hepsi KENDİ koşularım; geliştiricinin paftasına göre hüküm vermedim). Godot 4.4.1, `parse_check` PASS (250 betik).
- Ekranlı: `PACE=1 xvfb-run 1280x720 … --chapter=44b --autotest --dialogshots --shotevery=1 --snapevery=0.5 --hitchaudit RINFO=1`
  → 1210 kare (`t0001…t1210`, 640×360, 0,5 sn oyun zamanı), AUTOTEST PASS. İkinci ekranlı koşu `--autotest=hit` (968 kare).
  Kare adları aşağıda `tNNNN` (taban koşu) ya da `hit tNNNN`. Sonda karesi kullanılmadı; kamera oyuncu kamerasıdır.
- Başsız (`--max-fps 20`): 44b `""`, blab, dark, kid, nophone, hit; komşular 24 (5 varyant), 25 (7 varyant, cistern dahil), 43o (4), 12b.
- Evre sınırları (kare aralığı, mtime ile diyalog karelerinden çıkarıldı): iniş 49–140 · hayranlık/sandal 141–232 · ilk kürek 232–400 ·
  Yakovos konuşması 400–544 · sarsıntı küreği 544–952 · Medusa 952–1050 · tırmanış 1050–1127 · avlu/sonuç 1127–1210.
  Oyun zamanı ≈ 605 sn (≈ 10 dk; PACE `T_END` t=648,7). Gerçek oyuncu bunun üstündedir.

## GENEL HÜKÜM: **KÜÇÜK DÜZELTMELERLE KABUL**

Ölçülen ilerleme gerçek: karanlık ölü alan yarıya indi, sütun ormanı artık "sandaldan oynanırken" de okunuyor, çöküş + gün ışığı
doruğu gerçekten nefes kesiyor, kuyu inişi ve Medusa kutudan kabartmaya çıkmış. Ama geliştiricinin "DÜZELDİ" dediği iki iş KISMEN:
**kiler (K3) boş bej duvar + yanmış beyaz kapıya bakıyor**, **Medusa yüzleri 640×360'ta yine okunmuyor**; ayrıca ikinci turun parlaklık
artışı **duvar payelerini siyah dikdörtgen** olarak ortaya çıkardı (yeni kusur). Balık sürüsü hâlâ okunmuyor.

## 1. K1–K9 (kendi karelerimle)

| # | Madde | Hüküm | Kendi karem ve gerekçe |
|---|---|---|---|
| K1 | Kuyu inişi düz kahverengi | **DOĞRULANDI** (küçük artık) | `t0058`, `t0075`: örme taş baca, derz ve gölge, parlak ışık dairesi küçülüyor; `t0112`, `t0126`: bacadan tonoza açılış, tuğla kemer. Artık: `t0126–t0138` sütunlar yatık ve zeminsiz, boşlukta asılı (kamera yuvarlanması, "havada duran" gibi okunuyor, kısa); `t0057` tam siyah kesme karesi. Pafta `p01`. |
| K2 | Dış çizgili beyaz oval "balonlar" | **DOĞRULANDI** | `t0100–t0146`, `t0148–t0156` (koyu evre): yalnız küçük yumuşak noktalar, çerçeveli oval yok. Pafta `p01`, `p02`. |
| K3 | Çıkış tırmanışı siyah ekran | **KISMEN** | Siyah ekran gitti (tam siyah tek kare: `t1120`). AMA: `t1105–t1119` (≈ 15 kare, 7 sn; "Kırk basamak… turşu kokusu" burada söyleniyor) kamera **düz bej bir duvara ve aşırı pozlanmış beyaz bir dikdörtgene** bakıyor; geliştiricinin anlattığı tahta döşeme, kuyu bileziği, turşu küpleri, fıçı **hiçbir karede yok**. `t1075–t1090`: bacada dev bir "yumurta" biçimli ışık lekesi ve ince bir basamak; okunmuyor. Pafta `p09`. |
| K4 | Medusa kutu, ~40 px, yön okunmuyor | **KISMEN** | Artık küp değil: kaide + gerçek kabartma, yılan saç halkası, oval yüz (`t0950–t1040`). Ama yüz yatay genişliğin ≈ %8'i (≈ 50 px / 640), kaide dahil kadraj yüksekliğinin ≈ %24'ü; **göz, burun, ağız seçilmiyor** (`p12` yakın kesit: "yılanlı yumurta"). Sol baş yan, sağ baş ters olarak ayırt EDİLEMİYOR; ayrım ancak diyalogdan bilinir. Su: Medusa görünümünde su düzlemi dairesel kesilmiş, düz çamur diski ve kuru çukur gibi (t0975); suyun içinde dururken su görünmüyor. Pafta `p08`, `p12`. |
| K5 | İlk kürek 124 sn tehdit yok | **KISMEN** | Süre: 232→400 = 84 sn oyun zamanı (önce ≈ 124). Olaylar: balık (`t0326`, `t0345`: işaretin altında ≈ 10 px'lik ışıltı lekeleri, seçilmiyor), uzak top/toz (kareden ayırt edemedim; yalnız Nihat satırı `t0376`), şıpırtı. Üçü de **diyalogla taşınıyor, görselle değil**. Gerilim hâlâ düşük. Pafta `p04`. |
| K6 | Medusa/balıkçı replik çelişkisi | **DOĞRULANDI** (metin) | CSV'de `D44B_Y_STONE`, `D44B_Y_MEDUSA`, `D44B_N_MEDUSA` yeni hâlinde; "çamur silkelendi, sabaha örter, 1985" tutarlı. Kalan küçük: Yakovos "kırk yıldır bu köşede balık tutarım" derken Gyllius'un "kimse bilmiyordu"sunu zayıflatmaz (yalnız köşe), tamam. |
| K7 | VOICE_MAP satır sonu | **DOĞRULANDI** | `git diff --numstat 99df39c5`: `VOICE_MAP.csv` 74 ekleme / 0 silme; `strings.csv` 116 / 0. |
| K8 | "Pil %N" ekran ortasında | **DOĞRULANDI** | Sağ alt köşe, telsiz çubuklarının üstünde (`t0255`, `t0301`, `t0900`). Üst üste binme yok. |
| K9 | `_run_shots` sürümde | **DOĞRULANDI** | `grep -n "_run_shots\|shots_dir" scripts/chapter44b.gd` → yalnız `:1761` (`_capture_mouse` içindeki ortak denetim). İskele `tests/cistern_shots.gd`'de. |

## 2. Yeniden puan

### HAYRANLIK: **8 / 10** (ilk denetim 7)
- Kare `t0160` (telefon ışığı ilk kez açılıyor), `t0182` (diyalogsuz geniş plan), `t0665` (çöken gözden gün ışığı sütun ormanını boydan boya doldurur).
- Sütun ormanı ve tuğla çapraz tonoz artık fener konisinin dışında da okunuyor, sudaki ters yansıma ve su çizgisi güçlü, gözyaşı
  sütunu (`t0760`) gerçekten göze çarpıyor, ışık huzmesi + toz + halka (`t0600–t0625`) çarpıcı. Eksi: duvar payeleri siyah dikdörtgen (aşağıda),
  Medusa yüzü okunmuyor, Medusa evresi suyun "kesilmiş" görünmesiyle kuru çukur gibi, ölçek (138×65 m) sandaldan ≈ 35–40 m'den ötesi sise gömülü.
- Fark: +1. İniş ve açılış kusurları (düz kahverengi, baloncuk) kalktı; açılış anı ilkine göre çok daha dolu.

### HEYECAN: **6 / 10** (ilk denetim 5)
- Kare `t0625` (huzme + sudaki halka: "oraya taş düşecek"), `t0645–t0676` (çöken tonoz, `t0665` gün ışığı), `hit t0560/t0608` (isabet: ışık gitti, bakış Yakovos'a döner).
- Gerilim doruğu (çöküş + gün ışığı + dar geçit + titreyen fener) gerçekten çalışıyor ve sürükleyici. Ama ilk kürek 84 sn ve sarsıntı küreği 204 sn
  (toplam ≈ 290 sn) hâlâ aynı koridor; düşen parçalar `t0685–t0706`'da büyük ve görünür, ama bot hiç isabet almıyor (`hits=0`, yalnız `hit` varyantında 1).
- **Gizli süre YOK kuralı korundu:** tek sayaç görünür çubuk "Sarsıntılar sıklaşıyor · N sn" (`t0560…t0900`), `dark` varyantında süre dolunca kayıp yok, Yakovos çeker (rescued=true). `COLLAPSE_LATEST` olay zamanıdır, kayıp süresi değil.
- Fark: +1; tehlike görünür ama tırmanış ve kürek ritminin ortası hâlâ uzun.

### Karanlık sınaması (kürek evresi; kare 232–400 ve 544–952, 576 kare; 8-bit gri, HUD dahil)
| Ölçü | Değer |
|---|---|
| Kare ortalamasının ortancası | 23 |
| Havuzlanmış piksel ortancası | **26** (ilk kürek 22, sarsıntı küreği 28) |
| Ortalama | 44,7 |
| En karanlık %10'un ortalaması / p10 | **3,5 / 6** |
| <20 piksel oranı | %40 (en kötü kare: `t0950`, %61; ilk kürekte `t0340`, %50) |
| (ilk denetim: ortanca 3, <20 oranı %73–79) | |

Oyuncu nereye gideceğini görebiliyor: (a) altın elmas hedef işareti + mesafe ("37 m"), kıyıda sarı ok (`t0345`, `t0520`), (b) uzaktaki meşale, (c) kürek
çubuğu. Karanlık dilim (%10) gerçekten siyah (3,5) ama bu su/duvar tabanı ve kenar; yol okunuyor. Pafta `p03` (`t0301`, `t0480`, `t0700`, `t0900`).
Karanlık varyant (`dark`, uzaktan kumanda, pil 0) başsız PASS, ekranlı koşmadım (KANITSIZ görüntü).

## 3. Kusur avı (ÖNCE = `33662898`; geliştirici ilk tur karelerine göre)

| # | Kusur | Kare | ÖNCE'de var mıydı? |
|---|---|---|---|
| D1 | **Duvar payeleri siyah dikdörtgen**: su çizgisinde dikey, ≈ 1 × 2 m kapkara paneller, bütün kürek evresinde (iki yan ve uzak sıra); "kapı/boşluk" gibi okunuyor, sandal "kapıya" yönleniyor sanılır | `t0255`, `t0345`, `t0520`, `t0745`, `t0900` (pafta `p07`) | İlk tur karelerde (`p04_kayik_yakovos`) ortam koyu olduğu için görünmüyordu; 2. turun ortam ışığı artışıyla (`AMBIENT_LIT` 0,75, sis) **ortaya çıktı**. Kaynak: `cistern.gd:_build_walls`/`_brick_shader` payeleri (`:563–606`), gölgede ışık almıyor. **ZORUNLU** |
| D2 | Kilerde boş bej duvar + yanmış beyaz kapı, ≈ 7 sn | `t1105–t1119` (pafta `p09`) | Önce siyah ekrandı; yeni kusur. **ZORUNLU** |
| D3 | Tırmanışta "yumurta" ışık lekesi, basamak okunmuyor | `t1075`, `t1090` (`p09`) | Önce yok (siyahtı) |
| D4 | İniş: sütunlar yatık ve zeminsiz, boşlukta | `t0126`, `t0138` (`p01`) | Önce düz kahverengiydi; yeni kısa |
| D5 | Siyah kesme kareleri: baca→tonoz kesmesi `t0057` (1 kare), sandala biniş `t0227–t0228` (≈ 1 sn), tırmanış `t1120` (1 kare) | | Hepsi ≤ 1 sn, kabul; `t0227` biniş "kesme" hissi küçük |
| D6 | Medusa evresinde su yok: çamur diski dairesel kesik, kuru çukur görüntüsü; yüz okunmuyor | `t0950–t1040`, `p12` | Önce kutu; kısmen düzeldi |
| D7 | Gri silindir (kürek mili/kürek) kayığın borda tahtasından geçiyor, kayık yalpada devasa turuncu levha | `t0686`, `t0694`, `t0706` (`p06`) | Önce yok (yalpa yeni); **şüpheli**, kürek görselinin tahtaya girdiği KISMEN doğrulandı; kayığın ayrı bir nesnesi olduğunu kanıtlayamadım |
| D8 | Avlu sonunda konuşanlar (Eudokia, Yakovos, kasabalı) kuyunun ahşap çatısının arkasında, ayakları gizli; kamera kuyuya bakıyor | `t1135–t1160` (`p11`) | ÖNCE ile karşılaştırmadım (BAKILMADI); sahne bu turda değişmedi |
| D9 | Balık sürüsü okunmuyor (≈ 10 px) | `t0326`, `t0345` (`p04`) | Önce yoktu; geliştirici de KISMEN dedi, **doğru**. |
| D10 | Fener elinden kaydı → "ışık bulundu": ışık kayığın dibinde beyaz dikdörtgen (telefon) tamam; isabet sonrası bakış Yakovos'a dönüyor, kayık/kişi sahnesi sorunsuz | `hit t0560–t0632` (`p10`) | Yok; çalışıyor |

Aranıp BULUNMAYANLAR: sütunun içinden geçen kamera (karelerde görülmedi; sütunlar kadrajı kapatıyor ama kamera içlerine girmiyor, `t0345`, `t0560`), çifte gölge (yok; fener gölgesiz, tek gölge), küp gibi ateş
(yok; meşale/kandil alevi yumuşak, `t0400`, `t0520`), suyun içinden geçen kayık (yok; Yakovos kayığı su çizgisinde, `t0400`), birden beliren kişi (Yakovos
uzaktan meşaleyle görünüyor, `t0345` 22 m, `t0376` 11 m; yok), yanlış yöne bakan kişi (yok), elinde bir şey olmadan iş yapan kişi (Yakovos kürek/sırık
tutuyor `t0400`; yok). İsabet varyantında Yakovos'un kayığı kameranın 1,5 m'ine giriyor (`hit t0632`) ama geçmiyor.

## 4. Metin (D44* anahtarları; CSV ile `yeni_replikler.txt` birebir aynı: 74/74, fark 0)

Genel: ses tutuyor. Tolga ("navigasyonsuz otopark", "'Herhalde' kelimesini poliçede sevmem", "kapsam dışı", "kullanıcı hatası"), Nihat (kulaklıkta, "Tolga Bey", "kayıtlarda cin yok, balık deyip geçin"),
Eudokia ("İp babamdan kalma. Sağlamdır. Herhalde."), Yakovos ("Cin misin, Türk mü?", "Sütun yalan söylemez") ve komşu (`cin çarpmış bunu`) yerinde. İngilizce
genelde İngilizce düşünülmüş ("Which one's that?", "Not the time for crying"). Kötü/zayıf olanlar (metni DEĞİŞTİRMEDİM):

| Anahtar | Şimdiki TR | Neden | Öneri |
|---|---|---|---|
| `D44B_E_01` | "Tolga, Büro'nun tercümanı sen misin? Ben Eudokia…" | 1453 kasabalısı "Büro"yu bilmez, adını da tanışmadan söylüyor; `D25_E_CISTERN_2`'de aynı kadın "saraylı tercüman" diyor: iç tutarsızlık | "Sen şu Latin tercüman mısın, Tolga mı neydi? Ben Eudokia. Selden beri kovam kuyudan balıkla çıkıyor." |
| `D44B_Y_02` | "…cin olsan kürek çekmeyi bilirdin." | Mantık yok (cin neden kürek çeksin); EN "a djinn could row" da öyle | "Neyse, cin olsan bu kadar şapırdatmazdın." / EN "A djinn wouldn't splash like that." |
| `D44B_T_DARK` | "Yukarıda bir delik kadar ışık." | EN "a hole's worth of light" çevirisi gibi, Türkçede kimse "delik kadar ışık" demez | "Tepede kuyu ağzı kadar bir ışık kalmış. Sakin ol, Tolga." |
| `D44B_T_ROPE` | "Bir el yukarıda, bir el ipte." | Ne demek istediği belirsiz (EN "One hand up top" de) | "Bismillah. Bir el ipte, öbür el dua da." (ya da: "Bir el ipte, öbür el sigorta kâğıdında.") |
| `D44B_T_AWE_3` | "…Bu hiç başıma gelmedi." | Çeviri kokusu ("That has never happened to me"), zayıf kapanış | "Kimse bilmiyor, bir ben biliyorum. Ömrümde ilk kez dosyanın önündeyim." |
| `D44B_Y_03` | "Biraz cin olur, o kadar." | Espri oturmuyor (EN "a little bit of djinn" da) | "Kova iner, balık çıkar. Mahalle cin der, ben sofra." |
| `D44B_N_QUAKE` | "Top sizi duymuyor, Tolga Bey; tavan duyuyor." | Atasözü gibi kuruldu ama anlamı bulanık (top neden sizi duysun) | "Top tavanı dövüyor, tavan da size mırıldanıyor. Önce toz iner, sonra taş." |
| `D44B_T_HIT_1` (EN) | "…And the boat's not insured either." | "either" boşta kalıyor | "Not my head, the boat. Which isn't insured either." (ya da "…the boat. Uninsured, naturally.") |
| `D44B_Y_KEEP` | "Torunumun torunu bir gün bu suyu birine gösterecek. Senin gibi bir yabancıya." | Kâhin gibi, fazla bilir; sır teması için zorlama | "Sağ ol, sigortacı. Bu suyu çok kişi bilmesin, balık da bilmesin." |
| `D44B_N_MEDUSA` | "…Ben de form doldurmuyorum." | Şaka havada kalıyor (hangi form?) | "…Ben de form doldurmuyorum, Tolga Bey; çamurun da mührü yok." |

Kaynak sorunu yok: Gyllius/1985/336 sütun/"Fransız" doğru. `D44B_N_AWE` "yukarıdakiler kuyu sanıyor" doğru. `D44B_T_BLAB`/`D44B_TW_LAUGH` en iyi satırlar.

## 5. Kurallar (taban `99df39c5`; yayın tabanı `e551de84`)
- `git diff 99df39c5` yalnız 57 dosya: yeni bölüm dosyaları + ortak noktalar. Var olan bölümlerin replik/süre/sayaç/sonuç/kalabalık/bot yolu **değişmemiş**:
  `strings.csv` 116 ekleme / **0 silme**; `chapter25.gd:76-77,623-749` (yalnız 44 oynandıysa Eudokia'nın bir repliği + `_cistern_spoke`; 44 oynanmadıysa
  akış aynı), `siege.gd:ORDER` (44 eklendi, 43'ten sonra, 25'ten önce), `achievements.gd`, `people_fates.gd`, `creator_menu.gd`, `hud.gd` (kapak), `items.gd`, `game_state.gd` (`last_place`),
  `tests/run_tests.sh`, `tools/story_map.py`: hepsi yalnız eklenti.
- `e551de84` tabanına göre daha geniş fark (59 dosya, 6482+/262−) başka dalın (`0.99.119`) işidir; bu bölümün parçası değil. Kapsama aldım: bu dalın
  eklediği **hiçbir** var olan replik/süre değişmemiş.
- Kanca/susturma: `git diff 99df39c5 | grep -nE "no_audit|_ok|AUDIT|skip|--shots"` → bulgu yok (yalnız `mouse_filter` ve bir `skip` yerel sözlüğü). Sürümde test iskelesi yok.
- Yasak satırlar: bütün başsız ve ekranlı koşularda `SCRIPT ERROR`, `WARN_*`, `VISAUDIT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `JOURNEY_*` = **0**. Tek `LOOKAUDIT raw`
  (`25_pass`, İmparator, `chapter25.tscn 141`) yasak listede değil (yalnız `backturn` yasak); `25_pass` bilgi satırı, PASS.
- Başsız sonuçlar (hepsi 1/1 PASS): 44b `""`, blab, dark, kid, nophone, hit; 24 `""`, late, niko, niko_slow, eclipse; 25 `""`, caught, pass, kid, cistern, cistern_blab, osm; 43o `""`, bad, miss, dive; 12b `""`. Toplam 23/23.
  Her 44b varyantı bir kez koştum (üç tekrar yapmadım): çıktılar `ham_test_satirlari.txt`. `tests/check_*.py`, tam `run_tests.sh`, `creator_check`: KOŞULMADI.
- İki sonuç ayrışıyor ve karşılığı var: 44.1 → `D25_E_CISTERN_1`, 44.2 → `_2`; ağırlık hâlâ hafif (dünya sonucuna etki yok), tasarım gereği.

## 6. Performans (RINFO, ekranlı taban koşu; 79 örnek, 68'i sarnıç)
Sarnıç evreleri (örnek: t, çizim, üçgen K):
| Evre | 3 örnek (t, çizim, üçgen K) | çizim ortanca/en çok | üçgen ortanca/en çok | gölge |
|---|---|---|---|---|
| iniş+hayranlık | (11,50,283) (21,292,564) (31,294,564) | 204 / 351 | 564K / 564K | 0 |
| ilk kürek+Yakovos | (33,457,592) (54,417,604) (73,356,604) | 356 / 457 | 604K / 604K | 0 |
| sarsıntı küreği | (75,356,603) (101,240,571) (127,238,570) | 252 / 464 | 571K / 603K | 0 |
| Medusa | (129,165,601) (135,279,331) (140,323,331) | 278 / 329 | 331K / 601K | 0 |
| tırmanış | (142,324,332) (146,26,280) (150,242,562) | 31 / 324 | 322K / 562K | 0 |

Sarnıç çizim ≤ 464 (≤ 600 ✔), üçgen ≤ 604K (≤ 1,5M ✔); ışık `max_lights=7` (≤ 8 ✔). **> 50 ms kare: örneklerin 79/79'u** (yazılım çizimi, llvmpipe; ortanca 107–750 ms; 60 FPS KANITSIZ).
13 `HITCH` satırı (hepsi avlu/yükleme, t ≤ 5 sn: 700–860 ms). Avlu evresi çizim ≈ 4.600–5.000, üçgen ≈ 5,9 M ortak `ByzCity(part="aya")`: öncekiyle aynı, bu bölümün işi değil.

## 7. ZORUNLU düzeltmeler
1. **Kiler (K3/D2)** `chapter44b.gd:_climb` + `cistern.gd:_build_cellar`: `t1105–t1119` sırasında kamera kilerin içine baksın (tahta döşeme, kuyu bileziği, rafta turşu küpleri, fıçı, yandaki açık kapıdan avlu ışığı); kapı düz beyaz dikdörtgen olmasın (pozlama düşür, çerçeve + derinlik). Beklenen: "Kırk basamak… turşu kokusu" söylenirken ekranda turşu küpleri görünsün.
2. **Siyah payeler (D1)** `cistern.gd:_build_walls` (`:563–606`, payeler `:579–585`) / `_brick_shader`: payeler tuğla rengini ve hafif dolgu ışığı almalı (gölgede bile ≥ ~15/255 ve tuğla dokusu); su çizgisinde siyah dikdörtgen kalmamalı. Beklenen: `t0255/t0345/t0520/t0900`'de yan sıralar tuğla pilastr olarak okunur.
3. **Medusa okunurluğu (K4/D6)** `chapter44b.gd:_medusa` (`MEDUSA_STOP`) + `cistern.gd:_build_medusa`: kamera yüzlere ≥ 2× yaklaşsın (yüz en az kadraj genişliğinin %15'i) ya da kandil/yan ışık yüzü seçtirsin; yan ve ters baş ayrıştırılabilsin; su çamurla dairesel kesilmesin (kenarda yumuşak geçiş). Beklenen: `t0975`'te göz, burun, ağız ve "ters" olan baş seçilsin.
4. **Tırmanış (D3)** `_climb`/`cistern.gd` bacası: basamaklar okunur, "yumurta" ışık lekesi (muhtemelen spot koni/kapak) kalksın; kareler `t1075–t1100`.
5. **Balık sürüsü (K5/D9)** `chapter44b.gd:_ev_fish`: sürü kadrajın ortasında, kayığa 3–4 m yakın, ≥ %5 genişlikte okunur olsun; yoksa olayı sayımdan çıkar ve "3 olay" iddiasını düşür.
6. **Metin**: en azından `D44B_E_01`, `D44B_Y_02`, `D44B_T_DARK`, `D44B_T_ROPE`, `D44B_T_AWE_3`, `D44B_N_QUAKE` (tablo, §4); `VOICE_MAP.csv` ve `strings.csv` birlikte, yalnız bu anahtarlar.
7. (Küçük) iniş `t0126–t0138` yatık sütunlar: ya kamera yuvarlanmasını azalt ya da zemin/su göstererek "boşlukta" duygusunu kaldır; `t0227` biniş kesmesine 0,3 sn fade.

## 8. Sahibine gösterilecek 6 kare (`shots_a` taban koşu)
1. `t0182` (+ `t0160`): telefon ışığıyla ilk sütun ormanı ("Yerebatan" repliği): **hayranlık anı** (`p02`)
2. `t0665`: çöken gözden gün ışığı, sütun ormanı boydan boya aydınlık (`p05`)
3. `t0625`: ışık huzmesi, toz ve sudaki halka (taş düşecek) (`p05`)
4. `t0760`: gözyaşı sütunu ve tonoz (`p06`)
5. `t0058`: kuyu bacasında inerken ışık dairesi (`p01`)
6. `t0975`: Medusa köşesi (ters ve yan baş) **kusurlu: yüz okunmuyor** (`p08`, `p12`), kararı sahibi versin

## 9. Bakılamayanlar / yapılmayanlar
60 FPS (yazılım çizimi), ses (çıkış yok), ekranlı `dark`, `blab`, `kid`, `nophone` (yalnız başsız PASS), 44.2 sonu kareleri, `tests/check_*.py`, tam `run_tests.sh`, `creator_check`, kapak görseli,
İngilizce anadil okuması, bot dışı oyuncu (isabet sıklığı).

## Paftalar (JPEG ≤ 300 KB)
`p01_K1_inis`, `p02_hayranlik_acilis`, `p03_kurek_karanlik`, `p04_ilk_kurek_balik`, `p05_sarsinti_cokus`, `p06_gozyasi_dusen`, `p07_kusur_siyah_dikdortgen`,
`p08_medusa`, `p09_tirmanis_kiler`, `p10_isabet_hit`, `p11_ayrilis_son`, `p12_medusa_yakin`. Ham: `ham_test_satirlari.txt`.
