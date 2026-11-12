# P8 bağımsız denetim raporu (şehir içi: 10h, 12b, 23, 24, 25, 31o, 39o)

Denetlenen: `1e3a9b60` (ÖNCE) → `10c615b0` (SONRA, dal `wip/yardimci-p8`). Denetçi dalı: `wip/denetim-p8`.
Oyun kodu değiştirilmedi (`git status`: izlenen dosyada değişiklik yok; `tests/_tmp` açılmadı, sonda yazılmadı).
ÖNCE = `git archive 1e3a9b60` ile depo dışında kurulan kopya (`/home/user/w/base`), SONRA = depo.

## Yöntem
- Başsız: `--headless --max-fps 20`, 43 koşu (aşağıda).
- Ekranlı: `PACE=1 xvfb-run … --dialogshots --shotevery=1 --snapevery=0.5`, bölüm başına ÖNCE ve SONRA birer tam koşu
  (24, 23, 25, 31o, 39o, 10h, 12b). Kare çiftleri aynı replik anahtarı ya da aynı kare sırası (`tNNNN`) ile eşlendi;
  bu makinede snap kareleri ~1 sn/kare olduğundan eşleme ±1-2 kare kayıklıdır. Paftalar bu karelerdendir; sonda karesi yok.
- RINFO: ekranlı koşularda `RINFO=1 --hitchaudit` (sahne süresi `t` aynı olan satırlar eşlendi; ham: `rinfo_ham.txt`).

## 1. Madde madde hüküm
| # | Madde (geliştirici no) | Hüküm | Kanıt (pafta) ve not |
|---|---|---|---|
| 1 | 24 taşıyıcı elleri sırıkta | **DOĞRULANDI** (oyuncuya yakın taşıyıcı) | 01: ÖNCE'de el sırığın altında/yanında havada, SONRA'da yumruk sırığın üstünde ve sırıkla birlikte hareket ediyor. Sırık omuzda kalıyor, gövdeye giren kısım yok. Uzak taşıyıcıların elleri oyuncu karesinde seçilmiyor: BAKILMADI. |
| 2 | 24 birikinti (tek MultiMesh, açık gri-mavi) | **KISMEN** | 02, 12: ÖNCE'deki kara delik gitti ama SONRA'da hâlâ düz, yumuşak kenarlı gri-leylak disk; sel evresinde (t0107) uzak sokakta gökyüzü renginde yarı saydam bir disk zemin/duvar arasında "asılı" gibi okunuyor (ÖNCE'de de koyu halde vardı, yani yeni değil, ama düzelmedi). Z-çakışması/ızgara yaması görülmedi. Çizim: 34 → 1 olduğu kodda doğru (`chapter24.gd:_wet`). |
| 3 | 24 yere sıçrayan damla, halkalar | **KISMEN** | 01, 02, 12: sıçrama ince beyaz çizgiler, ÖNCE'deki soluk küplerden daha az kaba. Birikintide halka (`Vfx.water_ring`) hiçbir karede SEÇİLMEDİ → KANITSIZ. Havada asılı kalan çizgi parçacıkları görünüyor (gökte değil, zemin üstü 0-30 cm) kabul edilebilir. |
| 4 | 24 ıslak kaldırım (DURUYOR) | **DOĞRU** (iki sürümde aynı) | 12 |
| 5 | 24 D24_M_STOP | **KISMEN** | Dev raporunun dediği gibi kadrajda zemin yok. |
| 6 | 25 cemaat: diz çökme, boy farkı | **KISMEN** | 05 (arkadan oyuncu bakışı): boy farkı ve çömelmiş figürler SONRA'da görülüyor, ÖNCE'de herkes aynı boyda dik. Diz-yer teması, el kavuşturma ve elde mum yüzü arkadan görünmüyor: BAKILMADI. Haç/baş sallama: tek karede kanıtlanamaz, KANITSIZ. Eşzamanlı robot hareketi ya da titreme bu karelerde görülmedi (fakat hareket örneklemesi 1 kare/sn; KANITSIZ). |
| 7 | 25 "−80 çizim" | **YANLIŞ/KANITSIZ** | RINFO: ayin evresinde çizim ÖNCE 11.5k, SONRA 11.5k (−0,4…+0,5 %; tek geçiş örneği +6,1 %); üçgen +0,2…+0,6 %. Azalma yeniden üretilemedi; artış da yok. |
| 8 | 23 kartvizit iki elde, elden ele | **DOĞRULANDI** (tutuş) / **KISMEN** (geçiş anı) | 03, 04: kart iki elin parmak uçları arasında, kameradan ~44 cm önde, gerçek boyutta (~9×5,5 cm), havada asılı kalma yok. ÖNCE'de kart elsiz 4 sn havada ve sonra İsmail'in yanında uçarken görülüyor. İsmail yaklaşıp kartı alıyor; D23_I_CARD karesinde kart İsmail'in yumruğunda (04 son kare). Alma anının kendisi 1 kare/sn'de yakalanamadı: BAKILMADI. Kart üzerindeki "TOLGA / Sigorta · Hayat, Kasko, Konut / Tel: 0532 ···" yazıları kodda sabit (`chapter23.gd:_offer_card`), strings.csv dışı yeni metin; küçük kural sapması. |
| 9 | 23 muhafız/erkân kıpırtısı | **KANITSIZ** | Hareket tek kareden doğrulanamaz. |
| 10 | 10h elçi bayrak sırığı elde | **KISMEN** | 10: ÖNCE karelerinde de el sırığın yanındaydı; SONRA'da fark kareden seçilmiyor (el sırık hizasında, boşluk yok). Düzeldi diyemem, bozulma da yok. |
| 11 | 10h maiyet kıpırtısı | **KANITSIZ** | |
| 12 | 12b Sfrancis rulosu avuçta | **DOĞRULANDI** (zayıf) | 11: SONRA'da rulo elin ucunda; kol bükülünce el ile birlikte hareket ediyor (K_COUNT2/K_Q). ÖNCE'de rulo üst kolda, kadrajda ince çizgi. |
| 13 | 31o kiriş iki elde | **KISMEN** | 06: kolonya şişesi elden kalktı (iyi). Eller kirişin altında kadrajın alt kenarında; 0/3 karesinde yalnız bir el/kolluk, 1/3 karesinde bir el kirişin alt kenarına değiyor; iki elin kirişi tuttuğu ayırt edilemiyor. |
| 14 | 31o kazı: elde kürek, toprak, zemin | **DOĞRULANDI** (kürek elde, kolonya yok; çevre zemini) / **KISMEN** (kürek ağzı çukura inmiyor) | 08: iki el sapta, kürek gerçek boyda, çevresinde çamur lekeleri ve yanında toprak yığını; ağzın çukura indiği an seçilmedi (kürek ağzı elin hizasında). Çukur hâlâ düz kahverengi disk. |
| 15 | 31o mezarlık/tepe zemini | **DOĞRULANDI** | 08: SONRA'da çimen/taş öbekleri var, ÖNCE'de çıplak; ızgara yok, seyrek. |
| 16 | 31o `_rope_between` → Stage.rope, "eller ipte" | **YANLIŞ (eller kısmı) / DOĞRULANDI (ip kendisi)** | 07 (geliştiricinin 10 numaralı paftasında da aynı): ip burgulu, pencere eşiğinden çocuğa sarkık ve iki uçlu (ÖNCE'deki üstü havada düz silindir gitti). Ancak ellerle eşik arasındaki parça görünmüyor: ip eşikte koyu bir uçla bitiyor, eller ayrı, aralarında boşluk. Kod nedeni: ip ucu `player.global_position + (eye_height−0.42) + ileri×0,46` (gövdeye göre), eller ise `hold_both(Vector3(-0.07,-0.3,-0.46), …)` (kameraya göre). Kamera yere ~55° bakarken (kareden tahmin; ölçülmedi) iki nokta ≈ 0,4-0,45 m ayrışıyor. |
| 17 | 31o Kadri kepçesi | **KANITSIZ** | Kuyruğun arkasında, seçilmiyor. |
| 18 | 39o ip | **DOĞRULANDI** | 09: kalın (~5 cm), turuncu-koyu bantlı yuvarlak ip, kadrajın altında iki elin arasından çıkıp pencere direğinden geçerek adama iniyor; sarkma az, iki ucu bağlı, havada biten uç yok. Sokak tarafı (tayfa elleri, kangal) oyuncu karesinden görünmüyor: BAKILMADI. |
| 19 | ressama fırça | **DURUYOR** (beyan doğru) | Kod farkında yok. |

## 2. Yeni kusurlar (liste dışı)
1. **31o ip elde bitmiyor** (madde 16): "havada biten uç / elsiz ip" sınıfı.
2. **31o iki elli anlarda çizim artışı** (geliştirici de kabul etti): RINFO kazı evresinde çizim +85…+288 (%1,6-5,4), üçgen ≤ +%2,7; aynı evre eşlenemeyen iki örnekte +%8,2/+%9,8 (evre kayması olabilir, KANITSIZ). Kural "çizim artmaz" ihlal.
3. **39o üçgen bütçesi**: RINFO t=40-42'de üçgen +%12,2/+%12,3, çizim +%14/+%18 (yalnız bir koşu çifti; sokak/tayfa evresi); t=46-52 +%5,2…+%7,4; t=69-73 çizim +%7…+%10. Evre tam eşlenemedi ama iki ardışık örnek tutarlı → bütçe sınırı (+%8) aşılmış olabilir.
4. 24 sel evresindeki pastel disk (madde 2) ÖNCE'de de vardı; yeni değil.
5. Başka havada/gömülü nesne, eli boş çalışan kişi, birden beliren kişi, yanlış yöne bakan kişi, küp ateş, dev alet **görülmedi** (yalnız yukarıdaki kare kümesi taranabildi).

## 3. Kurallara uygunluk
- Replik anahtarı/sırası, süre, sayaç, sonuç koşulu, kalabalık sayısı (cemaat 22, birikinti 34, muhafız sayıları) değişmemiş. Bot yolu değişmemiş. Küçük süre değişikliği: 23 kart verme (`_give_card`: ~1,1 sn, eskiden `Handover.pass_to` 0,45 sn) — oynanışı etkilemez.
- Kanca/sonda: `grep P8SONDA|P8DBG|_p8(` boş. Yeni `no_audit`/`_ok` yok; yeni `set_meta` yalnız `no_walk` (`chapter24.gd:_wet`). `no_audit` satırları (`chapter12b.gd:314`, `chapter31o.gd:588,629,634`) ÖNCE'de de var.
- Yeni sabit metin: `chapter23.gd:_offer_card` kart etiketleri (yukarıda).
- `chapter31o.gd` `_rope_between(m, _a, b)`: kullanılmayan imza parametresi, zararsız.

## 4. Testler
Başsız, 43 koşu, hepsi **AUTOTEST PASS**; yasaklı satır (SCRIPT ERROR, WARN_FX_STUCK, WARN_FLY_ITEM, VISAUDIT, WARN_VOID_TELEPORT, WALKTHRU, ARMAUDIT, HELDAUDIT, JOURNEY_MISS, JOURNEY_OVERLAP) **0** (ham: `autotest_ham.txt`):
24 (5/5), 25 (7/7), 23 (6/6, `osm` dahil), 10h (7/7), 12b (5/5), 31o (4/4), 39o (6/6), 6 (1), 26 (1), 30 (1).
Ekranlı koşular (24, 23, 25, 31o, 39o, 10h, 12b; her biri ÖNCE+SONRA) de AUTOTEST PASS verdi. ÖNCE başsız koşuları yapılmadı: BAKILMADI (gerekmedi).

## 5. RINFO (ham: `rinfo_ham.txt`; çizim = draws, üçgen = prims)
| Bölüm | Evre | Çizim | Üçgen | Hüküm |
|---|---|---|---|---|
| 24 | sağanak/taşıma t=7-17 | −4,4…+2,6 % | ortalama ≈ −0,5 % (−9,7…+5,3) | ≤ +%8, çizim artmadı |
| 24 | sel/sis t=26-38 | ±0,3 % | ±0,8 % | tamam |
| 25 | ilk evre t=5-21 | −1,1…+0,2 % | −0,9…+0,3 % | tamam |
| 25 | ayin t=23-34 | −0,4…+0,5 % (t=23 geçişi +6,1) | +0,2…+0,6 % | tamam; "−80 çizim" doğrulanmadı |
| 23 | tümü t=1-38 | −5…+4 % (gürültü, yönsüz) | −2,5…+1,4 % | tamam |
| 31o | ev içi t=58-78 | +0,1…+0,8 % | +0,4…+0,7 % | tamam |
| 31o | kiriş evresi t≈82-91 | +70, −11, −10 (en çok +%9,6 tek örnek) | +1,1…+1,6 % | sınırda (çizim) |
| 31o | kazı evresi t≈145-153 | +85…+288 (+%1,6…5,4) | −0,7…+2,7 % | çizim artıyor (kural ihlali, geliştirici de yazmış) |
| 39o | t=40-42 | +%14…+18 | **+%12,2…12,3** | **bütçe aşımı olası** |
| 39o | t=46-52 (indirme) | −0,2…+2,5 % | +%5,2…+7,4 | sınırda |
Not: 31o ve 39o'da sahne geçişlerindeki satırlar (örn. t=54, 95, 116) evre kayması olduğundan anlamsız, yukarıda kullanılmadı.

## 6. GENEL HÜKÜM: **KÜÇÜK DÜZELTMELERLE KABUL**
Taşıyıcı elleri, 23 kartvizit tutuşu, 31o mezarlık zemini ve kürek, 39o ipi gerçekten düzelmiş; testler temiz.
Aşağıdakiler giderilmeden "DÜZELDİ" yazılamaz:

### ZORUNLU düzeltmeler
1. `chapter31o.gd:_rope_between` (ve `_house_loop` içindeki `player.hold_both(Vector3(-0.07,-0.3,-0.46), Vector3(0.08,-0.33,-0.5))`): ip ucu elin gerçek dünya konumundan alınmalı (`player.camera.to_global(…)` ile hold_both'taki kamera-yerel avuç noktalarının ortası; 39o `_hands_point` de aynı biçimde). Beklenen: pencere eşiğinden ellere kesintisiz sarkık ip, iki el ipin ucunu tutuyor, ucun ile eller arasında boşluk yok (kamera aşağı bakarken de).
2. `chapter39o.gd:_start_rope`/`_fire` (sokak tayfası + kılavuz ip + kangal evresi, RINFO t≈40-42): üçgen ≤ +%8 olacak şekilde düşürülmeli (ip ağı `n`/halka sıklığı, kangal turu, ek ip tek ağa birleştirilsin); yeniden RINFO ile aynı evrede doğrulanmalı.
3. `chapter31o.gd` iki elli anlar (kiriş, ip, kazı): çizim sayısı artmamalı. Önerilen: `_hands_under_beam`/ip/kürek sırasında ek el ağları yerine mevcut tek el + kolluğa dönmek, ya da ortak `player.gd` sol el ağlarını birleştirmek (geliştiricinin önerisi). Beklenen: aynı evrede çizim ±%1 içinde.
4. `chapter31o.gd:_hands_under_beam`: kiriş kaldırılırken iki elin kirişin altında göründüğü bir kare kanıtlanmalı (eller kadrajın ortasına yakın tutulsun); kirişi alt kenarından kavrayan iki el beklenir.
5. `docs/_kanit_p8/rapor.md`: madde 7 ("−80 çizim"), 16 ("eller ipte"), 10 ("DÜZELDİ" yerine KISMEN) ve 3 (halka) düzeltilmeli.

### Önerilen (zorunlu değil)
- `chapter24.gd:_wet/_puddle_mesh`: birikinti diski yine düz gri; kenar-merkez renk farkı artırılıp yağmur halkaları sıklaştırılırsa oyuncu karelerinde okunur.
- `chapter23.gd:_offer_card`: kart yazıları `tr()` anahtarına bağlanmalı ya da kaldırılmalı.
- `chapter31o.gd:_shovel_place`: itme evresinde kürek ağzının çukura değdiği kare kanıtlanmalı.

## 7. Bakılmadı
Cemaat/muhafız/maiyet/nöbetçi kıpırtısı (hareket), Kadri kepçesi, 25'te elde mum yüzü ve diz-yer teması, 24 uzak taşıyıcıların elleri, 23 kartın İsmail'e geçtiği an, 39o sokak tarafı, 31o kazıda ağzın çukura inişi, 24 birikinti halkaları. 31o ip uç boşluğu için sayısal ölçüm yapılmadı (kamera eğimi kareden tahmin edildi); hüküm kare ve kod okumasına dayanır.

## Pafta listesi
01 24 taşıyıcı elleri · 02 24 sel evresi disk · 03-04 23 kartvizit · 05 25 cemaat · 06 31o kiriş · 07 31o ip · 08 31o kazı · 09 39o ip · 10 10h bayrak · 11 12b rulo · 12 24 sağanak ilk evre
