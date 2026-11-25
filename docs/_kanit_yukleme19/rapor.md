# G19 — Yükleme: "Yanıt vermiyor" ve bölüm yükleme süresi

Dal: `wip/yukleme19` (taban `wip/ist2-birlesik` b583705a, 0.99.127). Bütün ölçümler bu makinede (4 çekirdek, başsız,
`--max-fps 20`, tek başına koşu); pencereli kanıtlar xvfb + llvmpipe (yalnız önce|sonra kıyası).

## Özet (sahibine)

- **Bölüm açılışında ana iş parçacığının en uzun donması 29–37 sn'den 0,6–1,0 sn'ye indi** (v2 bölümleri 8y, 10h, 11, 12b,
  23, 24, 31o; başsız ölçüm). Windows "Yanıt vermiyor" uyarısı 5 sn'de gelir; artık hiçbir bölüm açılışında 1 sn'yi geçen
  boşluk yok.
- **Yükleme perdesi artık gerçekten canlı**: önce çark ve çubuk kurulum boyunca aynı karede donuk kalıyordu (eski `pump()`
  bile perdeyi çizse de çarkın yeniden çizimi ertelenmiş kuyrukta bekliyordu). Şimdi çark döner, çubuk ilerler
  (`kare/sahip_24_cark_cubuk.jpg`, `kare/sahip_31o_cark_cubuk.jpg`).
- **Bölümler daha hızlı yükleniyor**: v2 bölümlerinde `_ready` soğukta ~53 → ~40 sn, ılıkta ~37 → ~29 sn (başsız).
  Bölge değiştirince (8y → 10h → 8y) önbellek artık silinmiyor.
- Görüntü ve çarpışma aynı: sözleşme altılısı birebir; bölüm sahnelerinin çizilen düğüm/üçgen sayısı ve çarpışma karması
  tabanla aynı (8y, 10h, 12b, 24, 31o).
- Hâlâ kötü olanlar (aşağıda ayrıntı): eski dünyalı bölüm ortası evreler (24 → Ayasofya, 26 → Ayasofya, 31o Eyüp) ve 13
  `=city` evresi 1,2–1,8 sn'lik bir tepe taşıyor; kök neden `horn_world.gd` / `crowd.gd`, bu görevin dosya sahipliği dışında.
  13'ün beyaz kararma altındaki kurulumu ~31 sn: **sahibine karar**.

## KESME A — "Yanıt vermiyor" hiç olmasın

| Madde | Durum | Not |
|---|---|---|
| A1 Genel nabız (`LoadingScreen.nabiz`) | **TAMAM** | 195 nabız noktası (`nabiz_noktalari.txt`); kapsam/perde/ölçüm dışında tek `if` ile döner |
| A2 Bölüm ortası perde | **TAMAM** | 31o Eyüp + Ayasofya iskelesi, 24 → Ayasofya, 13 h3 (siyah: perde); 13 Tolga anı ve 26 → Ayasofya (beyaz: yalnız nabız); çekim yolları yalnız nabız. `boot.gd`'ye dokunulmadı (C: chapter1 `ready` 129–171 ms < 700) |
| A3 `YUKLEMEAUDIT` | **TAMAM** | `_ADAY` ≥ 1000 ms listelenir, `_KESIN` ≥ 2500 ms `run_tests.sh`'te düşürür; `YUKLEMEAUDIT_PENCERE` pencereli koşuda |

### Kurallar nasıl uygulandı (DÜZELTMELER A/B/E)

- Kapsam (`kurulum_basla/bitir`, sayaçlı): nabız yalnız kapsam, perde (`current`) ya da ölçüm penceresi açıkken çalışır.
  `_last_pump` kapsam ve ölçüm başında sıfırlanır. Başlık menüsü (TitleBackdrop) kapsam dışında: `Props._place` orada tek
  `if` ile döner.
- Perdesiz kipte `force_draw` yok; perdeli kipte `disable_3d` ile yalnız perde çizilir.
- `_show_loader(false)` ilk iş `LoadingScreen.current = null` yapar (solmada titreme yok).
- Kapsam açıkken `GameState.changing = true` (kapanınca eski değeri döner); `Hud._ready`'nin erken `changing = false`'ı
  kapsam açıkken atlanır. Kapatma isteği ertelemesine dokunulmadı.
- Ana iş parçacığı denetimi + `_nabizda` bayrağıyla iç içe çağrı yok.
- Otomatik testte `process_events` çağrılmaz, yalnız saat tutulur; pencereli kanıt koşusu `YUKLEME_OLAY=1`.
- Bölüm ortası perde eşzamanlı (`GameState.kurulum_perdesi_ac(path, evre, perde, oyuncu)` / `kurulum_perdesi_kapat()`),
  çağıranlara yeni `await` eklenmedi. Oyuncu kurulum öncesi donuk değilse donar, kapattıktan 2 kare sonra çözülür
  (çağıranı bekletmeyen ayrı eşyordam). 24 ve 31o'da oyuncu zaten donuk (`chapter24.gd:811`, 31o ev evresi sonu).
- `_input` taraması (kural 6): `chapter34o/33o/21/18/22/35o`, `duel.gd`, `cannon_crew.gd` yalnız "basıldı" olaylarına
  bakıyor; yutulan bırakma olayıyla açık kalan tuş durumu yok (düelloda blok `Input` yoklamasıyla).
- Konuşma kartı/portre (kural 4): 24'te kart `hud.clear_card()` ile perdeden önce kapanıyor; 31o evreleri `fade_to(1.0)`
  + `_clear_stage` sonrası. Portre (`LivePortrait`) bu anlarda açık değil (kodda bakıldı, ekranda doğrulanmadı).
- Kurulumdan sonraki ilk karenin `delta`'sı ve perdenin 0,35 sn solması: değiştirilmedi (kural 12; solma kurulum
  karesinde yutulabilir).
- `mahalle_doku.gd` 8000 ms bütçe döngüsüne nabız kondu (kural 10): açılışta biten iş sayısı makineye göre değişebilir.

### En uzun boşluk — `YUKLEMEAUDIT en_uzun_bosluk_ms` (başsız, `--max-fps 20`, tek başına)

"Önce" = aynı kod `YUKLEME_ONCE=1` (nabızsız; yalnız kareler canlılık noktası; tabanda bugün de böyle). Ham satırlar:
`testler/yuklemeaudit_once.txt`, `testler/yuklemeaudit_sonra.txt`.

| Bölüm / evre | Önce (ms) | Sonra (ms) | Sonra kaynağı | Hedef < 1000 |
|---|---:|---:|---|---|
| 8y açılış | 29 391 | **711** (soğuk 727) | props>kare | ✔ |
| 10h açılış | 30 834 | **814** | sehir>kare | ✔ |
| 11 açılış | 29 933 | **998** | props>solidify | ✔ (sınırda) |
| 12b açılış | 29 729 | **889** | sehir>kare | ✔ |
| 23 açılış | 31 306 | **850** | sehir>kare | ✔ |
| 24 açılış | 31 308 | **943** | sehir>kare | ✔ |
| 31o açılış | 37 645 | **723** | sehir>kare | ✔ |
| 26 açılış | 5 633 | **747** | açılış>kare | ✔ |
| 20 açılış | 5 143 | **579** | açılış>kare | ✔ |
| 0 açılış | 5 970 | **601** | props>kare | ✔ |
| 13 açılış | 306 | 225 | | ✔ |
| 24 → Ayasofya (orta) | 5 694 | 1 358 | HornWorld | ✘ (ADAY) |
| 31o Eyüp (orta) | 6 285 | 1 464 | HornWorld | ✘ (ADAY) |
| 31o Ayasofya iskelesi (orta) | 4 085 | **552** | | ✔ |
| 26 → Ayasofya (orta, beyaz) | 4 870 | 1 682 | HornWorld | ✘ (ADAY) |
| 13 `=city` Tolga anı (orta, beyaz) | 29 482 | 1 446 | crowd/camp | ✘ (ADAY) |

Hiçbir satır `_KESIN` (≥ 2500) değil. İlk kare (`ilk_kare_ms`, başsız): v2 bölümlerinde 0,8–1,1 sn (önce de aynı).

### Pencereli kanıt (xvfb, opengl3/llvmpipe; yalnız önce|sonra)

- `kare/sahip_24_cark_cubuk.jpg`, `kare/sahip_31o_cark_cubuk.jpg`: perdenin çark+çubuk bölgesi 10/15/20/25. saniyede.
  **Önce**: dört kare aynı (çark ve çubuk donuk). **Sonra**: çark her karede farklı açıda, çubuk ilerliyor.
- Tam kareler: `kare/once_24/`, `kare/sonra_24/`, `kare/once_31o/`, `kare/sonra_31o/` (0,5 sn arayla örnekler, küçültülmüş);
  `kare/sahip_once_24.jpg` (donuk perde), `kare/sahip_sonra_24.jpg`.
- `YUKLEMEAUDIT_PENCERE`/pencereli satır: 24 `toplam 48,9 sn, en uzun boşluk 2,76 sn, ilk_kare 3,07 sn, olay=176
  perde_cizim=176`; 31o `toplam 52,6 sn, en uzun 2,2 sn, ilk_kare 2,58 sn, olay=209`. llvmpipe her şeyi CPU'da çizdiği için
  boşluklar başsızdan ~2,5 kat uzun (aynı makinede başsız 24: 943 ms); gerçek ekran kartında başsıza yakın beklenir.
  Önemli: CPU'yu başka bir Godot koşusuyla paylaşan pencereli ölçüm 35 sn'lik sahte boşluk verdi — pencereli ölçüm
  yalnız tek başına anlamlı.
- **Bulunan ve düzeltilen hata**: eski `pump()` 150 ms'de bir `force_draw` yapıyordu ama çark (`queue_redraw`), çubuk
  (`ColorRect` boyutu) ve etiket ertelenmiş ileti kuyruğuyla güncellenir; kurulum ortasında kuyruk işlenmediği için perde
  hep aynı kareyi çiziyordu (önce kareleri). Çark ve çubuk artık doğrudan RenderingServer tuval öğesine çiziliyor
  (`loading_screen.gd` `_draw_spinner`, `_rs_bar`). "Yükleniyor..." noktaları kurulum ortasında ilerlemez (Label).
- Çubuk: dosya yüklemesi ilk %40, kurulum zamanla %95'e yaklaşır. Kozmetik açık: pencereli koşuda çubuk kurulumun ikinci
  yarısında beklenenden erken doluyor (nedeni bulunmadı).
- Gölgelendirici ısınması (kural 24): pencereli `ilk_kare_ms` 2,6–3,5 sn (llvmpipe). `ShaderWarmup.after_world` v2'ye
  **eklenmedi** (ADAY): llvmpipe'ta ilk kare ölçümü gerçek ekran kartını temsil etmiyor; sahibin makinesinde ölçülmeli.

## KESME B — Yükleme süresi

| Madde | Durum | Not |
|---|---|---|
| B4 İsraf (silinecek öğelerin ağı) | **KISMEN** | ölçüt tek işlev `IstBaglama.silinecek_mi`; `_temizle` de onu kullanır. **hub_sehir atlanmaz** (ölçüldü: görüntü değişiyor) |
| B5 Önbellek | **TAMAM** | çok girdili LRU (`dizin.cfg`), sürüm anahtarı düzeltmesi, büyük yazımlar arka iş parçacığında, okuma nabızlı |
| B6 Uzak ordugâh / kalabalık | **YAPILMADI** | süre; aşağıda gerekçe |
| B7 Ölçüm | **TAMAM** | tablolar aşağıda |

### B4 ayrıntı

- `sehir.gd`: `_place_v2` (kapı öğeleri), `_v2_item`, `_item` (doku tekil öğesi) ve `_on_pisir` içindeki `_build`
  çağrıları `IstBaglama.atlanabilir_mi(it)` ile atlanır; öğe sözlüğü, tutucu, `duzle`, `cand`, `items.append`,
  `_perch_pad`, `_hat_far_add` aynen. `_on_pisir`'de atlanan öğenin kayıt durumu (`pre`, `want`, `_show`) aynı yazılır.
- hub'ın yeri: `ISTBAGLAMA sil_hub place=(-1660.161, 14.088, -296.2439) olcut=(-1660.161, 14.088, -296.2439) ayni=true`.
- **hub_sehir neden atlanmıyor**: ilk denemede hub da atlandı; `tests/_yukleme19/sahne_karma` 8y'de üçgen sayısı
  6 075 731 → 6 075 303 oldu (çarpışma karması aynı). `--sil-atla=0` ve hub'ı atlamadan: 6 075 731 (taban). Kural 18'deki
  risk (ByzCity kurucuları genel RNG'yi tüketiyor / Props önbelleklerini ısıtıyor) gerçekleşti. Sonuç: hub'ın üç katmanı
  bugün de kuruluyor; 8y'de atlanan yalnız 2 öğe (`sil_atlanan=2`), kazanç küçük.
- Sayım kuralı: `ISTSEHIR2 yer=832 hat=550` ve `ISTBAGLAMA temizle bolge=gate8y sehir_oge=2 ordugah_oge=5` aynı.
- "Doku öğeleri `_on_pisir` dışı" önerisi: tartılmadı (süre).

### B5 ayrıntı (önbellek kararı ve riski)

- **Bölgeler arası silme kanıtı** (`sokak.gd` eski `onbellek_yaz`): aynı adın öteki dosyaları siliniyordu; sokak imzası
  bölgeye bağlı (`_build_imza` bölgenin taban kayıtlarını içerir) → 8y'den 10h'ye geçmek 8y'nin `sokak/zemin/avlu/hayat/
  sokak_esya` önbelleğini siliyordu. Ayrıca `"sokak_"` öneki `sokak_esya_*` dosyalarını da siliyordu, ve `evler.gd`'nin
  oturum başı temizliği `<imza>v2_*` adlı v2 ev ağlarını (`begins_with(imza + "_")` tutmadığı için) **her oturumda**
  siliyordu. Yeni düzen: `ls` (soğuk 8y sonrası): `avlu_09b0….bin dizin.cfg dosek_643a….png ev/ hayat_5ec7….bin
  sokak_bf91….bin sokak_esya_90db….bin zemin_7d0e….bin`.
- **Yeni**: her ad (sokak, zemin, avlu, hayat, sokak_esya, dosek, ev) için en son kullanılan 4 imza saklanır. Son kullanım
  dosya zamanıyla değil `user://ist_onbellek/dizin.cfg`'deki sayaçla (okuma ve yazma işaretler); silme eksik dosyaya
  dayanıklı (paralel test parçaları). Dosya adı eşleşmesi tam (`ad_<20 onaltılık>.bin`).
- **Sürüm anahtarı**: imzaya bugüne kadar `application/config/version` giriyordu; bu ayar `project.godot`'ta **yok** (""),
  yani sürüm aslında anahtarda değildi. Paketli oyunda (`script_export_mode=2`) `.gd` md5'i okunamazsa ("") kod değişikliği
  önbelleği geçersiz kılmıyordu → güncellemeden sonra eski önbellek okunabilirdi (gizli risk). Şimdi: herhangi bir betiğin
  md5'i boşsa `res://VERSION` imzaya girer; md5 doluysa (geliştirme makinesi) sürüm girmez. Kazanç: geliştirme makinesinde
  sürüm yükseltmesi soğuk yükleme demek değil; **oyuncuda her güncelleme yine soğuk yükleme** (bilerek, güvenli yol).
  Risk: ilgili betik listesi her imzada çıktıyı etkileyen bütün betikleri kapsamıyor olabilir (imzalar zincirli: zemin/avlu
  imzası sokak imzasını içerir); bu bugünkü durumla aynı.
- Büyük önbellek yazımları (avlu 1,4 sn, zemin 0,5 sn) arka iş parçacığında: veri ana iş parçacığında derin kopyalanır,
  `.yaz` geçici dosyaya yazılıp adı değiştirilir (yarım dosya okunmaz). Okuma, kapsam/perde/ölçüm açıkken iş parçacığında
  yapılıp beklerken nabız atılır (`ISTONBELLEK oku_bekle`). Kural 8'deki `wait_for_task_completion` satırları: bekleme
  döngüsü `is_task_completed` + nabız, sonra tamamlanmış işe `wait` (ölçümde ayrı `ISTONBELLEK oku_bekle ad= ms=` satırı).

### Yükleme süresi — bölümün `_ready` kurulumu (sn; başsız, tek başına)

**Önemli bulgu:** `tests/load_time.gd` bölümü kendi `_ready`'si içinde köke eklemeye çalışıyor; Godot reddediyor ("Parent
node is busy setting up children") ve **hiç ölçmüyor** (8y `ready=2 ms`). Düzeltilmiş eşleri: `tests/_yukleme19/
load_time_duz.gd` (taban; LoadingScreen'e dokunmaz) ve `load_time19.gd` (yeni; kapsamlı/kapsamsız, en uzun boşluk).
`tests/load_time.gd`'ye dokunmadım (sahiplik dışı); tek satırlık düzeltme önerisi: `_ready`'de `_kos.call_deferred()`.

Soğuk = `user://ist_onbellek` silinmiş (tam yolla). "A'nın etkisi" = aynı yeni kodda ılık, kurulum kapsamı açık / kapalı
(kapalıda da ölçüm saati çalışır) — fark ölçüm gürültüsü içinde (−5 … +5 %, ortalama ~0).

| Bölüm | Soğuk önce | Soğuk sonra | Ilık önce | Ilık sonra | Ilık, kapsam kapalı | A'nın etkisi |
|---|---:|---:|---:|---:|---:|---:|
| 8y | 60,8 | 40,1 | 36,9 | 29,3 | 28,6 | +2,4 % |
| 10h | 52,1 | 39,6 | 36,5 | 29,2 | 29,1 | +0,4 % |
| 11 | 55,3 | 40,4 | 38,3 | 30,3 | 29,5 | +2,5 % |
| 12b | 52,7 | 39,2 | 36,7 | 29,0 | 28,5 | +1,5 % |
| 23 | 53,4 | 39,1 | 37,2 | 29,2 | 30,0 | −2,6 % |
| 24 | 53,3 | 40,2 | 37,2 | 29,7 | 29,5 | +0,5 % |
| 31o | 52,7 | 39,2 | 36,1 | 28,7 | 30,2 | −4,9 % |
| 26 | 6,6 | 5,4 | 6,2 | 5,2 | 5,0 | +3,6 % |
| 20 | 5,4 | 4,9 | 5,6 | 4,6 | 4,4 | +5,3 % |
| 0 | 19,8 | 5,4 | 6,3 | 5,3 | 5,6 | −5,3 % |
| 13 | 0,1 | 0,1 | 0,1 | 0,1 | 0,1 | – |
| 1 | 0,2 | 0,1 | 0,2 | 0,1 | 0,1 | – |

Kazancın kaynağı (çıkarım, ayrı ayrı ölçülmedi): ılıkta ~7 sn büyük olasılıkla v2 ev ağı önbelleğinin artık her oturumda
silinmemesi (B5); soğukta ek olarak büyük önbellek yazımlarının arka iş parçacığına alınması. B4'ün payı küçük.
Hedef "A ready +%2'den az": ortalama karşılanıyor, tek tek satırlar gürültü sınırında (±5 %).
`tests/city_check`: açılış yüklemesi 24 v2 9,1 → 9,4 sn, 31o v2 8,4 → 8,0 sn (önbellek ılık; değişmedi).

## B6 — Uzak ordugâh ve kalabalık: YAPILMADI

Süre yetmedi. Disk önbelleği (hücredeki öğeler + `it["y"]` + gece imzası) ve görünmeyen hücrelerin ertelenmesi kural 21'in
bütün tuzaklarıyla (birak/kur iptali, yerel koordinat, `akis_bitti`) ayrı bir iş. Ölçüm: ordugâh `_ekle`/`_pisir`
döngülerine nabız kondu (sayaçlı, `(k & 4095) == 0`); ordugâh artık en uzun boşluk listesinde görünmüyor.

## Doğrulama

- Ayrıştırma: `PARSECHECK PASS scripts=369`.
- Sözleşme altılısı (`testler/sozlesme_altilisi.txt`): `SURSOZLESME PASS kalem=13 kesim=8`, `SUROYUN nokta=519 havada=0
  gomuk=0 katida=0`, `WALKTHRU OZET yol=7 tamam=7 takilma=0 dusme=0`, `ESYATEST PASS`, `HALICSONDA OZET carp=661
  karma=3854034809`, `MARMARASONDA OZET carp=1837 karma=2250736444` — birebir aynı.
- Sahne karması (`testler/sahne_karma.txt`, `tests/_yukleme19/sahne_karma.gd`): 8y, 10h, 12b, 24, 31o'da çizilen düğüm,
  üçgen, çarpışma şekli sayısı ve çarpışma karması tabanla aynı. Görünüş karması tabanda da koşudan koşuya değişiyor
  (iş parçacıklı akış), ölçüt alınmadı. 8y'de taban da yeni kod da 1. koşuda (önbellek yazılır) 3876/6 075 731, 2. koşuda
  (önbellek okunur) 3854/5 415 909 veriyor: önceden var olan önbellek-durumu farkı, G19 ile değişmedi.
- Bölüm testleri ×2 (`testler/bolum_testleri.txt`): 8y, 10h, 11, 12b, 13 (``, `=city`, `=kitchen`), 23, 24 (``, `=late`,
  `=niko`), 26 (``, `=hold`, `=council_ok`), 31o (``, `=late`, `=petrion_ok`), 6 `=byz`, 7 `=byz`, 17o, 19, 20, 0, 1 —
  hepsi iki kez PASS; VISAUDIT/WALKTHRU/HELDAUDIT/ARMAUDIT/YUKLEMEAUDIT_KESIN satırı yok. (26'da bir `VISAUDIT_ADAY float`
  at satırı görüldü; aday, düşürmez; tabanda bakılmadı.)
- `tests/city_check.tscn` CITYCHECK PASS; `tests/street_check.tscn` STREETCHECK PASS; ZFIGHT 0 (24, 31o, 26, 13, 8y);
  `tests/menu_return.tscn` 26 ve 20o PASS.
- `run_tests.sh`: `bash -n` temiz. `SHARD=0 SHARDS=8` 51 koşu (≈2,5 saat) bu oturuma sığmadı; `SHARD=0 SHARDS=120`
  koşusu ön testleri (PARSECHECK, ESYATEST, UIFIT, GUNCELLEMECHECK, PLAYCHECK, ROUTECHECK, SNAPCHECK, WORLDCHECK) ve
  bölüm koşularını geçti, 15 dakikalık arka plan sınırında durduruldu (`testler/run_tests_shard0_yarim.txt`).
  `YUKLEMEAUDIT_ADAY` satırları listelendi (10b 1919 ms, 39o 1757 ms — o sırada CPU pencereli koşuyla paylaşılıyordu),
  düşürmedi; `_KESIN` yok.

## Hâlâ kötü olanlar (dürüst)

1. **Eski dünyalı bölüm ortası evreler 1,3–1,7 sn**: 24 → Ayasofya 1 358, 31o Eyüp 1 464, 26 → Ayasofya 1 682 ms.
   İzleyiciyle kesinleşti: boşluk `HornWorld` kurulumunda (`scripts/world/horn_world.gd`; 26'da `SiegeField._step
   ("_wall_extension()")`'dan hemen sonraki `horn.build()`, 31o'da Galata gece ışıklarından sonraki Osmanlı yakası/Asya
   kısmı). Dosya bu görevin sahipliğinde değil; öneri: `horn_world.gd` build adımları arasına 4–6 tek satır
   `LoadingScreen.nabiz("horn_…")`.
2. **13 `=city` Tolga anı 1,45 sn**: `crowd.gd:241`/`camp_day.gd:320` çevresi (Scenery.solidify öncesi), sahiplik dışı.
3. **13 `=city` beyaz kararma altında ~31 sn kurulum** (v2 şehri, perdesiz; kural 13 gereği koyu perde açılmadı, yalnız
   nabız): pencere artık yanıt veriyor ama oyuncu 30 sn beyaz ekran görüyor → **sahibine karar** (kısa bir perde mi,
   kurulumu bölüm açılışına almak mı). 26 → Ayasofya beyaz kararma kurulumu ~5 sn (> 3 sn) → aynı karar.
4. 11 açılışı 998 ms ile sınırda (`Scenery.solidify` öncesi; dışbükey kabuk/örnek kutuları).
5. Pencereli ilk kare 2,6–3,5 sn (llvmpipe); v2 yolunda gölgelendirici ısınması yok (kural 24, ADAY bırakıldı).
6. "Yükleniyor..." noktaları kurulum ortasında ilerlemiyor; çubuk ikinci yarıda erken doluyor.
7. Diğer bölümler (G19 kapsamı dışı, 10b/39o gibi Props-ağırlıklı eski bölümler) pakette `_ADAY` verebilir.
8. İlk ara kaydın iletisinde ek satırında model adı geçti (geçmiş yeniden yazılmadı; sonraki kayıtlarda yok).

## Değişen dosyalar

- `scripts/ui/loading_screen.gd`: `nabiz`, kapsam, `YUKLEMEAUDIT` (+ `_Olcer`), RS çizimli çark/çubuk, `nabiz_acik`.
- `scripts/autoload/game_state.gd`: `kurulum_perdesi_ac/kapat`, `_show_loader(false)` `current = null`, `bosalt_ms`,
  `olcum_ac`, ilerleme %40.
- `scripts/boot.gd`: yalnız `olcum_ac("acilis")` (perde yok; kural C).
- `scripts/ui/hud.gd`: `changing` sıfırlaması kapsamda atlanır.
- Bölüm ortası sarmalama: `chapter31o.gd`, `chapter24.gd`, `chapter26.gd`, `chapter13.gd`.
- Nabız: `level/props.gd`, `level/byz_city.gd`, `level/siege_field.gd`, `level/scenery.gd`, `world/world1453.gd`,
  `world/ist/{dunya,sehir,sokak,mahalle_doku,ordugah_yonetici,hayat,hayat_yakin,baglama,sur_oyun,evler}.gd`
  (liste: `nabiz_noktalari.txt`, dosya:satır).
- B4: `baglama.gd` (`silinecek_mi`, `atlanabilir_mi`, `_temizle`), `sehir.gd`. B5: `sokak.gd`, `mahalle_doku.gd`, `evler.gd`.
- `tests/run_tests.sh`: yalnız `YUKLEMEAUDIT_(ADAY|KESIN)` listeleme ve `_KESIN` düşürme.
- Yeni: `tests/_yukleme19/` (`load_time19`, `load_time_duz`, `sahne_karma`, `perde_kare`).
- Ölçüm anahtarları: `YUKLEMEAUDIT=1` (otomatik test dışında ölçüm), `YUKLEME_IZ=<ms>` (boşluk izi), `YUKLEME_ONCE=1`
  (nabızsız "önce"), `YUKLEME_OLAY=1` (testte olay işleme), `--sil-atla=0` (B4 kapalı).
