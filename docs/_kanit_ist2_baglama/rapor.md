# İstanbul v2 — BAĞLAMA-3: rapor

Dal: `wip/ist2-baglama` (taban `wip/ist2-taban3`; `wip/ist2-sehir3` ve `wip/ist2-doku3` birleştirildi). Görev:
`docs/_ajan/gorev/ist2_tur3.md` "BAĞLAMA-3". Amaç: sahibi oyunu açıp Nihat'la uçtuğunda yeni İstanbul'u görsün.

Sonuç: **Bölüm 11 ve Bölüm 7'nin (7a ordugâh ve 7b şehir) bütün oynanışı v2 dünyasında**: bölümün kendi sahnesi (CampDay /
ByzCity) olduğu gibi kurulur, çevresindeki dünya eski `World1453` yerine İstanbul v2'dir (IstDunya + IstSehir + ordugâh,
gemiler, yaşam). Uçuşta yer işaretleri, formlar, konma noktaları v2'nin; yan görev (seyir defteri) 9 + 19 = 28 eser.
Güvenlik anahtarı `IstBaglama.acik` (varsayılan AÇIK); `--eski-dunya` ya da `GameState.settings["eski_dunya"] = true` ile
bölümler eski dünyada aynen çalışır. İki yol da testte: **40/40 varyant PASS** (20 v2 + 20 eski), yasak satır 0.

## Durum

| # | Madde | Durum |
|---|-------|-------|
| 1 | Bölüm 11 ve 7'nin uçuşu v2'de (başlangıç, tarayıcı hedefi, ordugâh/otağ, Tolga'nın yeri, yer işaretleri, formlar, konma noktaları, zemin ve su yakalayıcı, tavan, sınır) | DÜZELDİ (aşağıda; 7: 10 varyant, 11: 10 varyant başsız PASS; `flight_check` eski + v2 PASS) |
| 2 | Güvenlik anahtarı `IstBaglama.acik` / `--eski-dunya` | DÜZELDİ (iki yol 20'şer varyant PASS; eski yolda v2 hiç kurulmuyor: `ISTBAGLAMA` satırı 0) |
| 3 | Yerdeki kısımlar | DÜZELDİ: ikisi de **v2'de** (karartmalı geçiş yok). Ordugâh ve hub v2'nin içinde, zemin/çarpışma bölümün; ötesi v2 arazisine yamayla iner. 7b hub'ında KISMEN: aşağıda "bilinen kusurlar" |
| 4 | Performans (RINFO, yükleme, takılma) | ÖLÇÜLDÜ: şehrin üstünde uçuşta bütçe içinde; bölümün kendi ordugâhının üstünde aşıyor (ÖNCE'de de aşıyordu); yükleme 3,3 kat (aşağıda; ORTAK İSTEK) |
| 5 | Kanıt: oyun içi kareler (HUD ile) ÖNCE \| SONRA, 60 sn rota 20 kare | DÜZELDİ (paftalar aşağıda) |
| 6 | Tolga'nın şehir bölümleri: döküm + 12b denemesi | DÖKÜM + DENEME: 12b'nin 5 varyantı v2'de başsız PASS; **varsayılan KAPALI** (`--ist2-deneme=12b`; görsel kusurlar nedeniyle açılmadı) |

## 1. Nasıl bağlandı

**Öteleme (dönüşümsüz).** v2 dünyası yatayda ötelenir: `IstGeo.kaydir(o)` (dünya = gerçek × S + o). Bölümün yerel çerçevesi =
sahne = v2 dünya çerçevesi; hiçbir düğüme dönüşüm verilmez. Neden: v2'nin parçaları (hayat, hayat_yakin, mahalle_doku, ordugâh)
kamerayı/oyuncuyu `global_position` ile izliyor; kök düğüme dönüşüm verilseydi akış yanlış yerde kurulurdu. Öteleme yalnız
`geo.gd` ve `dunya.gd`'de (benim dosyalarım): `w/w2/ll/real/_wl`, `X0/Z0`, bütün `K_*`/`Y_*` tabloları, `IstDunya` parça ızgarası,
ufuk kerterizi, karşı kıyı ızgarası. Öteleme 0 iken (gezi, önizlemeler) her şey eskisi gibi. Önbellekli parça planları
(ordugâh `_plan`, gemiler `_plan_onbellek`), düzleme kayıtları, yer dizini öteleme değişince sıfırlanır.

Sınırlama: yalnız öteleme olduğu için yönler v2'nin (+x doğu) ve deniz düzeyi y = 0. Bölümün zemini (y 0) v2'de deniz
düzeyinde kalır; çevresi bölge yamasıyla (`IstGeo.yama_ekle`) doğal araziye yumuşak geçer ve deniz o alanda çizilmez
(`IstGeo.deniz_yok`, `IstDunya._deniz_izle`; alanın içinde gerçek deniz noktası 0: `ISTBAGLAMA deniz_yok … gercek_deniz_nokta=0`).

**Kanca.** `World1453.build` başında (ekleme): `IstBaglama.istek(bolge)` ise `IstBaglama.build` döner (kurulmamış bir
`SiegeField` kabuğu; `world` değişkeni, `set_mode` için). İstek yalnız Bölüm 7 ve 11 (`IstBaglama.hazirla(7|11)` bölümün
`_ready`'sinde, `birak()` `_exit_tree`'de) ve yalnız "camp" / "byz_walls" bölgeleri için. Öteki bütün bölümler eski dünyayı
kurar (Bölüm 6, 10, 12b, 24 komşu koşuları PASS, `ISTBAGLAMA` satırı yok).

**Yerleşim.**
- **camp (Bölüm 11, 7a):** CampDay'in otağı (yerel 0, −62) v2 ordugâhının otağının yerine (ŞEHİR-3'ün ordugâh planından,
  açılışta okunur: bugünkü öteleme (1963.8, 459.4)). v2 ordugâh planı kurulmadan süzülür: bölümün alanındaki 26 öğe (otağ,
  mescit, pazar, mutfak, kanatlar) çıkar; çadır denizi dışarıda sürer. Yama: iç 170 m bölümün arazisi (`CampDay.height`:
  ızgarada v2 0,35 m altta, dışında bölümün süslerinin oturduğu yüzey), 330 m'ye kadar v2'ye geçiş.
- **byz_walls (Bölüm 7b):** ByzCity'nin sur parçasının ortası (yerel −4, −13) ŞEHİR'in Romanos iç yanı oyun alanının ortasına
  (`IstSehir.oyun_alanlari()` ile 1 m fark; ŞEHİR-3 hub'ı aynı kuralla yerleştiriyor). O alandaki v2 öğesi (uzak hub) kaldırılır.
- Bölümün sahnesine (v2 dışı) görünürlük uzaklığı: 650 m (küçükler 260 m). Galata'dan geri bakışta 6 406 → 1 520 çizim.
- Gök ve ışık bölümün (CampDay/ByzCity gündüzü, Bölüm 11'de `Night.environment`); v2 yalnız gecesini (`gece=true`: pencere
  ışıkları, kandiller) kurar. Sis tavanı (Look `fog_cap`) yerde 0,0009 (gece 0,002), uçuşta 0,00035 (`NihatPowers.ucus_sis`);
  hava perspektifi 0,3 → 0,1 (1–2 km ötedeki şehir gök rengine dönüyordu).

**Uçuş (`IstBaglama.ucus_bagla`).**
- Yer işaretleri: `IstSehir.flight_data_v2`: ilk dokuzu kayıtlı kimlikler (AYASOFYA … SURLAR) aynı sırada, ardından adı yazılı 19
  yeni eser: Theodosius Forumu, Arkadius Sütunu, Kıztaşı, Anemodoulion, Studios, Mokios Sarnıcı, Venedik Mahallesi, Augustaion ve
  Iustinianus Sütunu, Milion, Aya İrini, Küçük Ayasofya, Büyük Saray Harabeleri, Khalke Kapısı, Zeuksippos Hamamı, Nea Ekklesia,
  Pantokrator, Kariye (Khora), Pammakaristos, Blakherna Meryem Kilisesi. Adı yazılmamışlar girmez. Toplam 28 (HUD: "Seyir defteri:
  … (n/28)"); `nihat_seyyah` (ilk dokuzu) aynı.
- 12 form (sayaç `FORMS_TOTAL` aynı) v2 yapılarının konma kapaklarında. Konma noktaları yan görev kimliklerine eşlenir:
  `aya`, `galata` (Galata Kulesi), `column` (Konstantin Sütunu) — `D_PERCH_*` replikleri ve `perch_*` bayrakları aynı; repliği
  olmayan v2 konma noktaları yan göreve girmez (ham anahtar balonu çıkmasın).
- Zemin: v2'nin akışlı arazi çarpışması (izleyiciye göre) + `IstBaglama._physics_process` zemin yakalayıcı (arazinin 1,2 m altına
  inerse yüzeye). Su: `IstGeo.su` üstünde y < 0,4 → `NihatPowers.on_water` (eski su yakalayıcıyla aynı davranış).
- Tavan: bölümlerin verdiği 110 m (değişmedi; Galata Kulesi ~71 m). Sınır: menzil (3 000 m) + v2'de harita dikdörtgeni
  (yarımada + Galata + bütün işaretler + 300 m): dışına taşınca en yakın kenara yumuşak geri çevirme (`NihatPowers.sinir`).
- `ensure_flight_solids` v2 dalını taramaz (`ucus_tarama_yok`): 31 bin düğüm kalkışta 107 ms takılma yapıyordu; v2 kendi
  çarpışmasını kurar.

Replik, süre, sayaç, sonuç ve bot akışı değişmedi (bölüm dosyalarındaki değişiklik: `hazirla`/`birak` ve uçuş bağlama dalı).

## 2. Testler

| koşu | sonuç |
|---|---|
| `parse_check` | PASS (327 betik) |
| Bölüm 7, v2: `- tea lost form wall wallkeep byz byzniko byzcell fez` | 10/10 PASS, yasak satır 0 |
| Bölüm 11, v2: `- arrest escape persuade help helpwall lost fired hikmet niko` | 10/10 PASS, yasak satır 0 |
| Bölüm 7, `--eski-dunya` (10 varyant) | 10/10 PASS, yasak 0, v2 kurulmadı |
| Bölüm 11, `--eski-dunya` (10 varyant) | 10/10 PASS, yasak 0, v2 kurulmadı |
| Komşular (eski dünya): 6, 10, 12b, 24 | 4/4 PASS |
| `flight_check` (eski camp + walls; v2 camp + walls) | PASS: v2'de 28 işaret, 12 form, 3 konma; 43/43 noktanın altında zemin/yapı, konma yüzeyi ≤ 1,5 m; Haliç ortası su; hepsi sınırın içinde |
| Görev 6 denemesi: 12b `- lie year d2 d3` `--ist2-deneme=12b` | 5/5 PASS (v2 hub) |

Yasak satır taraması: `SCRIPT ERROR|WARN_FX_STUCK|WARN_FLY_ITEM|VISAUDIT|WARN_VOID_TELEPORT|WALKTHRU|ARMAUDIT|HELDAUDIT|LOOKAUDIT backturn|JOURNEY_MISS|JOURNEY_OVERLAP`.
Çıkışta sızıntı: v2'nin ağaç dışındaki ön-pişmiş katmanları bölüm biterken serbest bırakılır (`ISTBAGLAMA bosalt dugum≈800`; önce
7 391 fizik gövdesi sızıyordu, şimdi 0–1).

## 3. Performans

Ölçüm: `tests/_ist/baglama_ucus.tscn` gerçek bölümü normal akışında açar (otomatik test değil), Nihat'ı uçurur. Çizim/üçgen:
oyunun RINFO'suyla aynı sayaçlar (`RenderingServer` kare toplamı, gölge geçişi dahil), xvfb 1280×720.

**Yükleme (bölüm sahnesinin eklenmesinden ilk kareye; başsız, iki koşu aynı anda):**

| | ÖNCE (eski dünya) | SONRA (v2) |
|---|---|---|
| Bölüm 7 (7a) | 7,0 sn | 23,1 sn |
| Bölüm 11 | 6,7 sn | 22,8 sn |
| xvfb (yazılımla çizim) Bölüm 11 / 7 / 7b | 9,5 / 7,9 / – sn | 45 (ilk koşu, üç süreç) / 24,7 / 27,4 sn |

v2 kurulumunun kırılımı (Bölüm 11, `ISTSEHIR2`/`IST*` satırları): IstDunya 0,6 sn · IstSehir yerleşim 2,1 + hat 0,5 · **doku 14,3 sn**
(zemin 2,9, sokak 1,5, ön-pişirme 4,1, ordugâh uzak hücre 2,2, gemiler 0,4, yaşam 0,8 …) · toplam `ISTBAGLAMA kurulum_ms` ≈ 21 sn.
Benim payım: ordugâh uzak hücre ağı ikinci kez kuruluyordu (−2,2 sn, düzeldi). Kalan ORTAK İSTEK.

**Kurulum takılması (kare > 50 ms; başsız, oyun kodu):**

| evre | ÖNCE | SONRA |
|---|---|---|
| açılıştan sonraki 20 sn (kart, kararma, konuşmalar) Bölüm 11 / 7 | 2 / 4 (en uzun 307 / 530 ms) | 12 / 7 (en uzun 120 / 206 ms) |
| 60 sn uçuş (kalkış → şehir → Ayasofya, 30 m/sn) Bölüm 11 / 7 | 0 / 0 | 12 / 16 (en uzun 82 / 81 ms) |

Uçuştaki takılmaların kaynağı (`--hitchaudit`): şehre girerken `sehir<dunya` 300–890 düğüm/kare (66–90 ms), `ordugah_yonetici`
442 düğüm (43 ms) → ORTAK İSTEK. Kalkıştaki 107 ms (uçuş katılaştırma taraması) giderildi.

**Uçuşta çizim / üçgen (xvfb, HUD'lu kare anı):** tablo: `rinfo.md`. Özet (SONRA): şehrin üstünde ve eserlere yaklaşırken 567–1 446
çizim, 0,66–2,31 M üçgen (bütçe ≤ 1 500 / 3,5 M: içinde). Bölümün kendi ordugâhının üstünde ve kalkışta 2 250–4 030 çizim (ÖNCE
4 267 / 3 935: kaynak CampDay'in kendisi, aşağıda kırılım). Galata'dan dönüş ÖNCE 6 161–6 458 / 8,2–8,5 M → SONRA 891–1 520 / 2,5–2,9 M.

## 4. Kanıt (paftalar, `docs/_kanit_ist2_baglama/`)

PAFTA_LISTESI

Sahip kareleri (DÜNYA-2'nin 14 bakışı, birleşik dal, gezi sahnesi, öteleme 0): `sahip_<n>_<ad>.jpg`.

## 5. Bilinen kusurlar / BAKILMADI

BILINEN

## 6. Görev 6: Tolga'nın şehir bölümleri (döküm)

| bölüm | sahne | bölge | v2'ye bağlama |
|---|---|---|---|
| 6b, 7b, 10h, 12b, 23 | ByzCity "walls" | byz_walls | Hazır: `IstBaglama` aynı yerleşim (Romanos iç yanı, ŞEHİR'in oyun alanı). 7b açık, 12b deneme (5/5 PASS, kapalı). Öteki üçü için bölümün `_ready`'sine `IstBaglama.hazirla(n)` + `_exit_tree`'ye `birak()` ve `BOLUMLER`'e numara |
| 24, 25, 26, 31o | ByzCity "aya" | byz_aya | Yapılmadı: Ayasofya meydanı oyun alanı (`IstSehir._meydan_rect`, Ayasofya'nın batısı) için `HUB_ORTA` gibi bir çapa (ByzCity.AYA = (−14, −82) → v2 Ayasofya kubbesi) ve v2 Ayasofya öğesinin kaldırılması (bölüm kendi Ayasofya'sını kurar); arazi yamasının y 0'ı birinci tepede (v2 ~12 m) çukur yapar: AYA_Y benzeri bir dikey çözüm gerekir (bkz. kusur 1) |
| 25 | CampDay + ByzCity "aya" | iki bölge | Yapılmadı (iki bölge aynı sahnede: tek öteleme yetmez) |
| 10, 10b, 10z | CampDay | camp | Hazır (Bölüm 11 ile aynı yerleşim); `hazirla` eklenip sınanmalı |
