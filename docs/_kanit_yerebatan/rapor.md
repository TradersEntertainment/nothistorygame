# Bölüm 44 — Sarnıç (Yerebatan) · rapor

Dal: `wip/bolum-yerebatan`. Tasarım ve araştırma: `docs/BOLUM_YEREBATAN.md` (ilk teslim, kaynaklı).
Sahibin isteği: "hem manzara hayranlık yaratsın hem de heyecanlı bi bölüm olsun"; "ne bizans ne osmanlı bilmiyordu …
tolga kazara bulacak ya da halktan birisi bir şey isterken ona yardım ederken oraya varacak".

## 1. Araştırma notu (özet; tablo ve kaynaklar `docs/BOLUM_YEREBATAN.md` §1)

- **Kesin (birincil kaynak):** Gyllius, *De Topographia Constantinopoleos* II.20 (J. Ball çevirisi, 1729, Project Gutenberg
  #53083): "Ahali, içine açılmış kuyulardan her gün su çektiği hâlde ondan en küçük bir şüphe duymuyordu"; "üstü
  tamamen evlerle kaplıydı"; tesadüfen girdiği bir evden inip küçük bir kayığa biner, ev sahibi meşale yakıp onu
  sütunların arasında küreklerken balık zıpkınlar; "kuyunun ağzından inen küçük bir ışık suya vurur, balıklar hava
  almaya oraya gelir"; 336 sütun, 12 sıra × 28; başlıkların bir kısmı Korint, bir kısmı işlenmemiş; her başlığın üstünde
  ikinci bir yastık taşı; kışın büyük bir borudan gürültüyle dolar.
- **Tutarlı:** Iustinianus, Stoa Basilika'nın altı; ~138 × 65 m, ~80.000 m³, sütun ~9 m (İBB, Kültür Bakanlığı,
  Wikipedia). Medusa başları kuzeybatı köşede iki sütunun kaidesi; 1985–87 İBB temizliğinde 50.000 ton çamur
  çıkarılırken ortaya çıktılar (Milliyet/C. Sadiç; İBB Atatürk Kitaplığı). 1723 III. Ahmed onarımı.
- **Çelişkili / BELİRSİZ:** yapım yılı (527–542); su yolu (Valens kemeri mi, Hadrianus su yolu mu); fetihten sonra
  Topkapı bahçelerine su verdiği (kaynaksız siteler) ile "yerlilerden başka herkesçe unutuldu" (Tonguç & Yale) /
  Gyllius'un "kimse bilmiyordu"su; Gyllius'un keşif yılı (1544, 1545, 1544–47). 1453'te sarnıcı kimin bildiğine dair
  doğrudan kaynak YOK: oyunun "unutulmuş" kurgusu Gyllius'tan geriye çıkarımdır.
- **Uydurma (oyun için, böyle işaretli):** Eudokia, Yakovos ve "cin"; 26 Mayıs'ta sarsıntıyla tuğla düşmesi;
  sarnıçtaki su düzeyi (2,2 m); Medusa'ların suyun ~0,7 m altında görülebilmesi (gerçekte çamura gömülüydüler).

## 2. Tasarım kararları

| Karar | Ne yapıldı | Neden |
|---|---|---|
| Yer | Kimlik 44, `chapter44b` (yalnız Bizans), `Siege.ORDER`'da 43'ün ardı: Bizans sırası 24 → 44 → 25 | 24'ün seli kuyuları taşırdı (balık bahanesi); 24 ve 25 Ayasofya çevresinde; takvim 25 → 26 → 27 Mayıs |
| Giriş | Eudokia'nın kuyusu: "selden beri kovam balıkla çıkıyor, cin var"; Tolga ipe tutunur, ip kopar | Sahibin "halktan birine yardım ederken / kazara" isteği ikisi birden |
| Kulaktaki ses | Hikmet değil Nihat | Kanonda Perde IV zamanın dışında; hiçbir kuşatma sayfasında Hikmet konuşmaz (sahibinin kararına açık) |
| Hayranlık anı | Karanlık → fener (F) → ortam ışığı 2,5 sn'de açılır, müzik "tender"; denetim oyuncuda, kamera çevrilmez | Görevdeki "oyuncu durup bakmalı" |
| Heyecan | Kürek ritmi + dümen, ışık bütçesi (pil %14, çakmak 6 sn), toz-halka uyarılı düşen tuğlalar, kemer çöküşü (meşale söner), süre (95 sn) | Var olan düzenekler: RowMeter/OarGrip (17), set_chase, TespitCam |
| Sonuçlar | 44.1 sırrı korudu · 44.2 ağzından kaçırdı (Paradoks +5) · `cistern_rescued` (süre doldu, Yakovos çekti) | "Keşif SIR kalmalı" ekseni; başarısızlık oyunu kesmez |
| Etkiler | Bölüm 25 son ayin: Eudokia'nın tek repliği (44.1/44.2); Bölüm 15 İnsanların Akıbeti: Yakovos (Gyllius izi / taşla doldurulmuş kuyu); `ACH_CISTERN` | `tests/check_outcomes.py` iki sonucun da okunduğunu doğrular |
| Konuşmacılar | Eudokia `SPK_WOMAN_BYZ`, Yakovos `SPK_FISHMONGER`, Marco `SPK_KID`, komşu `SPK_TOWNSMAN` | Yeni ses kimliği/portre açmamak için var olanlar |

## 3. Teslim edilenler

| Dosya | Ne |
|---|---|
| `scripts/level/cistern.gd` (yeni, `class_name` yok) | Mekân: iç ölçü 137,8 × 65 m, 12 × 28 = 336 sütun (aralık 4,75 × 5,0 m), gövdeler ve üç tür başlık (Korint, İon, yalın) MultiMesh, her başlıkta yastık taşı; çapraz tonozlar ve kemer bantları tek ağ; duvar payeleri; sahte yansıma (bütün sütun/tonoz/duvarların su düzlemine göre ters kopyası + saydam, kırışık, parlak su); tavanda kıpırtılı su yansıması (kostik, gölgelendirici); 7 kuyu bacası, gün ışığı kartları (huzme) + toz + su üstünde ışık havuzu, en yakın iki huzmeye birer zayıf ışık; ip ve kovalar; tavus gözü (gözyaşı) sütunu; iki Medusa (kabartma gölgelendiricisi, biri yan biri ters, çamur tümseğinde); 48 balık (huzmelerin altında toplanır); damla halkaları; çarpışma (336 silindir, duvarlar, dip) |
| `scripts/chapter44b.gd`, `scenes/chapter44b.tscn` (yeni) | Bölüm akışı (aşağıda), otomatik test (`--autotest[=blab|dark|kid|nophone]`), sonda kareleri (`--shots`) |
| `scripts/siege.gd` | `ORDER`'a 44 (43'ün ardına) ve açıklama |
| `scripts/chapter25.gd` | Bağlantı noktası: 44 oynandıysa son ayinde Eudokia (tek replik, `_cistern_neighbor`); test varyantı `cistern`, `cistern_blab` |
| `scripts/ui/people_fates.gd` | Akıbet: Balıkçı Yakovos (44.1 / 44.2 / kurtarma) |
| `scripts/achievements.gd`, `docs/STEAM_ACHIEVEMENTS.md` | `ACH_CISTERN` "Doksan Yıl Erken" (gizli) |
| `scripts/autoload/game_state.gd` (`last_place` listesi), `scripts/level/items.gd` (bölümün eli: çakmak, bant), `scripts/ui/creator_menu.gd` (YENİ rozeti), `scripts/ui/hud.gd` (kapak) | Tek satırlık eklemeler |
| `i18n/strings.csv` (+.translation) | 106 yeni anahtar: 64 replik (62 bölümde, 2 Bölüm 25'te), 42 arayüz/akış/dosya/akıbet/başarım |
| `docs/voice/VOICE_MAP.csv` | 64 replik konuşmacı ve ton |
| `docs/_kanit_yerebatan/yeni_replikler.txt` | Seslendirilecek 62+2 replik (SES ÜRETİLMEDİ) |
| `assets/art/covers/ch44b.png`, `assets/art/journey/ch44b.jpg`, `assets/data/journey.json`, `tools/story_map.py` | Kapak (oyunun kendi karesinden), final yolculuğu haritası, 43o'nun "sıradaki Bizans sayfası" notu |
| `tests/run_tests.sh`, `docs/CHAPTERS.md`, `docs/SIEGE.md`, `docs/BOLUM_YEREBATAN.md` | Test listesi ve belgeler |

## 4. Akış (oynanan hâliyle)

1. Avlu (Ayasofya haritası, `ByzCity(part="aya")`, meydana kurulan duvarlı avlu): Nihat'ın kaydı, Eudokia ("kovam balıkla
   çıkıyor, cin var"), 24.1'de Marco ("atım da düştü"). Kuyuya etkileşim → ipe tutunma, bacadan iniş, ip kopar, suya düşüş.
2. Karanlık: kuyu ağzından bir huzme; "fener [F]". Fener açılınca ortam ışığı 2,5 sn'de açılır, müzik değişir;
   denetim oyuncuda (kamera çevrilmez). Tolga: "Bu bir kuyu değil… Burası Yerebatan… bilet kuyruğu vardı"; Nihat:
   "Kayda geçirmeyin… doksan yıl sonra bir Fransız bulacak".
3. Yüzerek sütuna bağlı kayığa; kürek ritmi + A/D dümenle 60 m ötedeki meşaleye (sütuna çarpan durur).
4. Yakovos (zıpkın, meşale): "cin" odur; kova (ve Marco'nun atı) onda; çıkış onun evinin kuyusu, "taş kadınların yanında".
5. Sarsıntı: top atışı, tavandan toz ve damla; kemer çöker, meşale suya düşer. Tolga ışığıyla önden (95 sn sayaç;
   önce toz ve halka, 1,6 sn sonra tuğla; vuran tuğla kayığı durdurur). Telefon pili %14'ten iner; biterse çakmak/kumanda.
   Süre dolarsa: fener söner, Yakovos ipiyle sayarak çeker (`cistern_rescued`).
6. Medusa köşesi: kayık yan yanaşır, Yakovos kandilini yakar, kandilin önünde su berraklaşır; dipte iki taş yüz.
   Tespit karesi (dosya fotoğrafı). Kuyunun demir basamaklarından tırmanış (Yakovos'un kileri).
7. Avlu: kova teslim; "Cin var mı?" → 44.1 sırrı koru / 44.2 ağzından kaçır. Dosya sayfası, akış şeması, sıradaki: 25.

## 5. Testler (başsız, `--max-fps 20`; son koşular son kodla)

| Koşu | Sonuç |
|---|---|
| `parse_check` | PARSECHECK PASS (250 betik) |
| `--chapter=44b --autotest` (44.1) | PASS, uyarı yok |
| `=blab` (44.2) | PASS |
| `=dark` (süre doldu, Yakovos çekti) | PASS (`WARN_FREE_NO_OBJECTIVE` giderildi) |
| `=kid` (24.1, Marco) | PASS |
| `=nophone` (çakmak / kumanda ekranı) | PASS |
| `--chapter=25` `""`, `caught`, `pass`, `kid`, `osm`, `osm_caught`, `osm_tez`, `cistern`, `cistern_blab` | 9/9 PASS (`cistern` ilk denemede Eudokia İmparator'un görüşünü kapatıyordu: VISAUDIT personhidden; sol öne alındı, temiz) |
| `--chapter=24` `""`, `late`, `niko`, `niko_slow`, `eclipse` | 5/5 PASS |
| `--chapter=23`, `42b`, `36b`, `43o` (Osmanlı'da sıranın komşusu) | 4/4 PASS |
| Ekranlı (`PACE=1`, xvfb, `--dialogshots`): 44b varsayılan ve `blab` | PASS (2 tam koşu, 935 + ~400 kare) |
| `tests/check_*.py` (8 dosya), `tools/journey_data.py --check` | Hepsi PASS (`check_outcomes`: 76 sonucun 76'sı okunuyor; 44.1/44.2 Bölüm 25 ve akıbette) |

Hiçbir koşuda `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `VISAUDIT`, `WARN_VOID_TELEPORT`, `WALKTHRU`, `ARMAUDIT`,
`HELDAUDIT`, `LOOKAUDIT backturn`, `JOURNEY_*` yok (son koşular). Tam `tests/run_tests.sh` paketi KOŞULMADI (yalnız
yukarıdaki bölümler).

## 6. Performans (RINFO, ekranlı `PACE=1 RINFO=1 --hitchaudit`, varsayılan varyant; aynı replik anları)

| An (replik) | çizim | üçgen | görünür | gölge |
|---|---:|---:|---:|---:|
| Avlu, Nihat'ın girişi (D44B_N_01) | 4659 | 1463k | 742k | 720k |
| Kuyuda iniş (D44B_T_DOWN) | 284 | 562k | 561k | 0 |
| Hayranlık anı (D44B_T_AWE_2) | 284 | 844k | 563k | 279k |
| Nihat'ın uyarısı (D44B_N_AWE) | 358 | 844k | 563k | 279k |
| Yakovos (D44B_Y_04) | 400 | 903k | 591k | 311k |
| Sarsıntı (D44B_N_QUAKE) | 404 | 904k | 592k | 311k |
| Medusa (D44B_T_MEDUSA_1) | 317 | 377k | 328k | 48k |
| Avluya dönüş (D44B_T_END) | 4557 | 5715k | 5268k | 446k |

Sarnıç evrelerinde bütçe tutuyor: çizim 213–404 (≤ 600), üçgen 0,37–0,90 M (≤ 1,5 M). Avlu evreleri var olan
Ayasofya haritasının (`ByzCity aya`) yüküdür; son sahnede Ayasofya'ya doğru bakılınca 5,7 M üçgen (harita yükü; bu
bölümün eklediği avlu birkaç yüz üçgen). Avlunun ilk 4 saniyesinde 12 HITCH (city_life kalabalık kurulumu, kararma
sırasında; yazılım çizimi xvfb'de). 60 fps bu makinede ölçülemedi (yazılım çizimi): KANITSIZ.

## 7. Kanıt paftaları (`docs/_kanit_yerebatan/`)

| Pafta | İçerik | Kaynak |
|---|---|---|
| `p01_avlu_kuyu.jpg` | Avlu, Eudokia, ip, kuyuda iniş | oynanış (PACE) |
| `p02_hayranlik_oynanis.jpg` | Karanlık → fener → sütun ormanı (giriş anı) | oynanış (PACE) |
| `p03_hayranlik_sonda.jpg` | Hayranlık anı üç açıdan + kuyu ağzına bakış | sonda_ (`--shots`) |
| `p04_kayik_yakovos.jpg` | Kayıktan orman, kürek ritmi, meşale, Yakovos | oynanış (PACE) |
| `p05_gerilim_dizisi.jpg` | Sarsıntı sayacı, pil %2 → %0 ("tuğla"), karanlık, köşe | oynanış (PACE, ~4 sn arayla) |
| `p06_medusa.jpg` | Medusa kandil ışığında (oynanış) + iki yüz yakın (sonda_) | oynanış (autotest, PACE'siz) + sonda_ |
| `p07_huzme_isik.jpg` | Kuyu huzmesi ışıksız/fenerle; karanlık; çakmak | sonda_ |
| `p08_son_44_1.jpg` | Sonuç 44.1 son kareleri | oynanış (PACE) |
| `p09_son_44_2.jpg` | Sonuç 44.2 son kareleri | oynanış (PACE) |

## 8. Madde durumu

| Madde | Durum |
|---|---|
| Araştırma (kaynaklı, çelişkiler yan yana) | DÜZELDİ (yapıldı) |
| Tasarım belgesi ilk saatte dalda | YAPILDI (0145932e) |
| Gerçek boy mekân, 336 sütun MultiMesh, tek ağ tonoz, bütçe | YAPILDI (RINFO §6) |
| Sahte yansıma, su, kostik, huzme + toz, balık, damla halkası | YAPILDI; kostik yalnız ışığın vurduğu yerde seçiliyor (karelerde zayıf: KISMEN) |
| Hayranlık anı (telefon ışığı) | YAPILDI (p02, p03) |
| Telefon / çakmak / kumanda ışığı, pil | YAPILDI (p05, p07) |
| Sandal + dümen, düşen tuğla (uyarılı), kemer çöküşü, süre | YAPILDI; düşen tuğla karelerde seçilmiyor (kısa ve küçük): KANITSIZ (görsel) — test sayaçları çalışıyor |
| Medusa başları (biri yan, biri ters) | YAPILDI; oynanış karesinde küçük (p06) — KISMEN |
| Tavus gözü sütunu | YAPILDI (sonda karesi: `c44_heneye`, paftada yok) |
| İki sonuç + sonraki bölümlere etki | YAPILDI (25, 15 akıbet, başarım) |
| Oyuncu suya düşerse yüzer, sıkışmaz | Yüzme yalnız düşüş anında (kayığa kadar); kayıktan suya düşme yok (tasarım gereği) |
| Ses | ÜRETİLMEDİ; liste `yeni_replikler.txt` |

## 9. Bilinen kusurlar

- Kayıktaki Yakovos kayıkta ayakta durur (zıpkınla balıkçı); oturur pozu yok.
- Düşen tuğlalar basit kutular; sıçrama yalnız halka (köpük küresi kural 6 gereği kaldırıldı).
- Avluya dönüşte Eudokia bazı karelerde kuyunun arkasında kalıyor (VISAUDIT yok, ama kadrajda küçük).
- Telefon pili sarsıntı evresinin ortasında biter (test botunda hep); bu bilinçli gerilim, ama Medusa'yı kandil aydınlatır.
- İngilizce metinler yazıldı, bir anadil okuması yapılmadı.
- Yeni replikler seslendirilmeden altyazıyla oynar.

## 10. Sahibinin karar vermesi gerekenler

1. **Yer:** Perde IV, 26 Mayıs (Bizans 24 → 44 → 25). Hikmet istenirse bölüm Perde II/III'e taşınmalı (Perde IV'te
   Hikmet konuşmuyor; görevdeki Hikmet yorumları Nihat'a verildi).
2. **Sonuçların ağırlığı:** şimdi yalnız bir replik (25), akıbet ve başarım; dünya sonucuna etki yok. Daha ağır mı?
3. **Süre:** test botuyla ~2,5 dk oyun zamanı (PACE'de ~6 dk); gerçek oyuncu için tahmini 8–10 dk.
4. **Ses kimliği:** Eudokia ve Yakovos şimdilik genel "Kadın" ve "Balıkçı" sesleriyle; kendi sesleri istenirse yeni
   konuşmacı açılmalı.
5. **Medusa'nın görünürlüğü:** tarihte çamura gömülüydü; oyunda kandil ışığında suyun altında seçiliyor (uydurma, ödül anı).
