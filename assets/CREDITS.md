# CREDITS — Görsel ve İşitsel Varlıklar

Bu dosya, `assets/` altındaki tüm sanat ve ses varlıklarının üretim bilgisini ve lisanslarını listeler.
Tüm içerik "Gerçek Tarih Bu Değil" projesi için özgün olarak üretilmiştir; ticari dağıtıma uygundur.
Aksi belirtilmedikçe tüm çizimler, modeller ve sesler proje için sıfırdan üretilmiş özgün çalışmalardır (üçüncü taraf kaynak kullanılmamıştır).

---

## Yazı Tipleri (`assets/fonts/`) — üçüncü taraf, OFL

| Dosya | Ne | Kaynak | Lisans |
|---|---|---|---|
| `ui_regular.ttf` | Arayüz yazı tipi, normal (Comfortaa 400; Türkçe + Yunanca tam destek) | Google Fonts — Comfortaa (alexeiva/comfortaa) | SIL OFL 1.1 (`LICENSE_Comfortaa.txt`) |
| `ui_bold.ttf` | Arayüz yazı tipi, kalın (Comfortaa 700; Türkçe + Yunanca tam destek) | Google Fonts — Comfortaa | SIL OFL 1.1 (`LICENSE_Comfortaa.txt`) |
| `title.ttf` | Bölüm başlığı yazı tipi (Alfa Slab One; Türkçe destekli) | Google Fonts — Alfa Slab One (Sorkin Type / JM Solé) | SIL OFL 1.1 (`LICENSE_AlfaSlabOne.txt`) |

Not: Brief'teki Rye önerisi Türkçe glifleri (ğ, İ, ş) içermediği için Alfa Slab One kullanıldı. UI fontunda Yunanca desteği şartı nedeniyle Nunito/Baloo 2 yerine Comfortaa seçildi (ikisi de Yunanca içermiyor).

## Portreler (`assets/art/portraits/`) — özgün üretim (25 dosya)

`tolga.svg`, `tolga_fez.svg`, `hikmet.svg`, `nihat.svg`, `mufide.svg`, `riza.svg`, `niko.svg` (yeniden çizim),
`kadri.svg` (Aşçıbaşı Kadri), `lutfi.svg` (Tercüman Lütfi), `urban.svg` (Usta Urban), `hasan.svg`, `huseyin.svg` (Yeniçeriler),
`candarli.svg` (Kukuletalı adam), `pasha.svg` (Çandarlı Halil Paşa), `theodoros.svg` (Logothetes Theodoros), `clerk.svg` (Bizans memuru),
`giust.svg` (Giustiniani), `emperor.svg` (Konstantinos XI), `fatih.svg` (Fatih Sultan Mehmet), `cemil.svg` (Hırdavatçı Cemil),
`agent1.svg` (Ajan 7/c), `agent2.svg` (Ajan 12/b), `soldier.svg` (Genç asker), `rower.svg` (Kürekçi), `sinerji.svg` (Sinerji).

512×512 SVG, rx=64 radyal degrade zemin, büst; oyunun çizgi üslubu (kontur `#1d2330`).

## Çanta ikonları (`assets/art/icons/`) — özgün üretim (10 dosya)

`phone.svg` (%1 pil), `lighter.svg`, `book.svg` (fes siluetli), `chickpeas.svg`, `powerbank.svg`,
`tape.svg` (koli bandı — oyun simgesi), `thermos.svg` (ekose), `selfie.svg`, `cologne.svg`, `cube.svg`.
256×256 SVG, krem zemin (rx=40), 52 px'de okunabilir.

## Logo ve afişler (`assets/art/posters/`) — özgün üretim (6 dosya)

`fez.svg` (amblem), `logo.svg` (1024×384 ana logo + "Not a History Game"), `calendar.svg` (Nisan 22 takvimi),
`patent.svg` (Zamanatör 3000 patent başvurusu), `form_z1.svg` (Form Z-1 kuruluş belgesi), `bureau_sign.svg` (Zaman Bürosu tabelası).

## Sembol ikonları (`assets/art/symbols/`) — özgün üretim (17 dosya)

`timer`, `phone`, `clipboard`, `briefcase`, `radar`, `tea`, `folder`, `flashlight`, `card`, `pot`,
`speech`, `bomb`, `columns`, `envelope`, `ice`, `box`, `clock` — 64×64 SVG, şeffaf zemin, krem tek renk + ince kontur.

## Bölüm kapakları (`assets/art/covers/`) — özgün üretim (12 dosya)

`ch1.png` Zamanatör (garaj), `ch2.png` Yağlı Kızaklar, `ch3.png` Vaka 1453-T (Zaman Bürosu), `ch4a.png` İlk Gece (ordugâh),
`ch4b.png` İlk Gece (deniz surları / zincir), `ch5.png` Garajda Gece, `ch6a.png` Ordugâh, `ch6b.png` Surların İçi (kançılarya),
`ch7.png` Saha Çalışması, `ch8.png` Hırdavatçı, `ch9.png` Teklifler, `ch10.png` Huzur.
1920×1080 PNG; elle kodlanmış SVG illüstrasyonlardan rasterize edildi (ara SVG'ler repoya dahil değildir). Alt üçte bir başlık için sade/koyu.

## Akış şeması şeritleri (`assets/art/flow/`) — özgün üretim (9 dosya)

`ch1.png`–`ch9.png`, 1024×256, koyu lacivert (`#141824`) zemin üstüne krem line-art bölüm simgesi
(zaman makinesi, kızak, dosya, meşale, telsiz, mühür, tarayıcı, kondansatör, mühürlü mektup).

## 3B modeller (`assets/models/`) — özgün üretim, prosedürel (21 dosya)

Karakterler (parçalı, iskeletsiz; `Body/Head/ArmL/ArmR/LegL/LegR/Hat` + Head child'ı `Mouth`; pivotlar eklemlerde; ≤3000 üçgen; ~1,75 m):
`tolga.glb`, `tolga_nofez.glb`, `hikmet.glb`, `nihat.glb`, `fatih.glb`, `janissary.glb` (kaftan malzemesi ayrı: `kaftan`),
`kadri.glb` (ArmR child'ı `Ladle`), `lutfi.glb`, `urban.glb`, `niko.glb`, `theodoros.glb`, `emperor.glb`, `giust.glb`,
`agent.glb` (ArmR child'ı `Lamp`, emissive yeşil).

Eşya/araç/yapı (≤5000 üçgen): `zamanator.glb` (`RingA`/`RingB` ayrı, pivot merkezde; koli bandı detaylı),
`otag.glb` (giriş +Z), `cannon.glb` (bantlı çatlak), `tent.glb` (bant ayrı malzeme), `van.glb` (`WheelFL/FR/RL/RR`, `Spotlight`, yan yazı panelleri boş),
`goat.glb` (`Leg0`–`Leg3`), `chicken.glb` (`WingL`/`WingR`).

Hepsi glTF 2.0 binary, Y-yukarı, metre birimi, orijin tabanda, +Z bakış, doku yok (düz PBR malzemeler, malzeme adı = renk adı).
Python (pygltflib) ile prosedürel üretildi; üretici scriptler geliştirme klasöründedir.

## Ses efektleri (`assets/audio/sfx/`) — özgün üretim (33 dosya)

OGG Vorbis, mono, 44,1 kHz, sessizlik kırpılmış, tepe ≈ −3 dB.
Üretim: AI ses efekti sentezi + numpy ile prosedürel sentez/son işlem (bu proje için üretildi; üçüncü taraf kayıt kullanılmadı).

`machine_spin` (döngü), `machine_jump`, `radio_static`, `radio_beep`, `typewriter` (prosedürel), `typewriter_bell`, `stamp`,
`paper_tear`, `cannon`, `chicken`, `goat`, `splash`, `kick_metal` (prosedürel), `door_metal`,
`footstep_grass/stone/wood_1–4`, `crowd_camp` (30 sn döngü), `night_camp` (30 sn döngü), `city_2026` (30 sn döngü),
`fluorescent` (döngü), `ui_select`, `ui_confirm`, `timer_tick`.

## Müzik (`assets/audio/music/`) — özgün üretim (9 dosya)

OGG Vorbis, stereo, 44,1 kHz, kesintisiz döngü (bitiş = baş). Tamamı prosedürel sentez (numpy): ney/ud/kanun/darbuka/mehter
davulu/tuba benzeri sentezler; makam karakterli (Hicaz/Rast) melodiler. Placeholder niteliğinde demoscene tarzı sentezdir;
ileride canlı icra kayıtlarıyla değiştirilebilir.

`theme.ogg` (90 sn), `camp_day.ogg` (120), `camp_night.ogg` (120), `byzantium.ogg` (120), `bureau.ogg` (~90),
`garage.ogg` (~90), `chase.ogg` (60), `tender.ogg` (60, tek ney), `flowchart.ogg` (45).

---

# TUR 2 EKLERİ

## Steam mağaza görselleri (`store/`) — özgün üretim (9 dosya)

`header_capsule.png` (920×430), `small_capsule.png` (462×174), `main_capsule.png` (1232×706),
`vertical_capsule.png` (748×896), `page_background.png` (1438×810, koyu/düşük kontrast),
`library_capsule.png` (600×900), `library_hero.png` (3840×1240, yazısız panorama: 2026 garajı ↔ zaman yarığı ↔ 1453 ordugâhı),
`library_logo.png` (1280×720, şeffaf), `icon.png` (256×256, fes).
Başlık yazısı `assets/art/posters/logo.svg`'den rasterize edildi.

## Bölüm kapakları, tur 2 (`assets/art/covers/`) — özgün üretim (12 dosya)

`ch10a.png` (Bizans arşivi, Theodoros), `ch10b.png` (Urban'ın topu, bantlı), `ch10g.png` (Galata sokakları),
`ch10h.png` (beyaz bayrak heyeti), `ch10z.png` (ordugâh mutfağı), `ch11.png` (gece karşılaşması, form),
`ch12.png` (otağ, Fatih — saygılı), `ch13.png` (garaj, saat 07:15), `ch14.png` (Zaman Bürosu, "VAKA 1453-T"),
`ch15.png` (servis durağı, "1454" tabelası), `ch16.png` (tavuk yüksekliği, çizmeler), `menu_bg.png` (ana menü, sol üçte bir sade).
Tur 1 kurallarıyla aynı: 1920×1080 PNG, elle kodlanmış SVG'den rasterize, yazısız (sahne içi işaretler hariç), alt üçte bir sade/koyu.

## Gazete ön sayfaları (`assets/art/newspapers/`) — özgün üretim (18 dosya)

1024×1400 PNG; "GÜNDEM" (TR) ve "THE AGENDA" (EN) baskıları: `w1`, `w2`, `w3`, `w4`, `w5`, `w5b`, `w10`, `w11`, `w12` + `_en` halleri.
Tarih satırı "25 Mayıs 2026 Pazartesi"; manşet yazıları Alfa Slab One (OFL), küçük yazılar okunmaz dolgu çizgileri; her sayfada tek özgün çizim.

## Patlama/çizgi-film efektleri (`assets/art/vfx/`) — özgün üretim (9 dosya)

Şeffaf zeminli sprite sheet'ler, kare 256×256; 16 kare → 4×4 (1024×1024), 8 kare → 4×2 (1024×512).
`explosion_big.png` (16), `explosion_small.png` (16), `smoke_puff.png` (16), `smoke_ring.png` (8), `sparks.png` (8),
`dizzy_stars.png` (8), `leblebi_burst.png` (16), `wine_splash.png` (16), `soot_face.png` (tek kare 512×512 is maskesi).
Parametrik üretim (her kare elle kodlanmış SVG'den rasterize).

## Portreler, tur 2 (`assets/art/portraits/`) — özgün üretim (10 dosya)

`manager.svg` (müdür), `driver.svg` (servis şoförü), `aga.svg` (Sorucu Ağa), `dervish.svg`, `cameleer.svg` (deveci),
`tailor.svg` (terzi), `captain.svg` (Venedik kaptanı), `merchant.svg` (Ceneviz tüccar),
`nihat_new.svg` (yeni model Nihat, robotik), `tolga_soot.svg` (isli Tolga). Tur 1 portre kurallarıyla aynı.

## Akış şeması şeritleri, tur 2 (`assets/art/flow/`) — özgün üretim (7 dosya)

`ch10.png` (otağ kapısı), `ch11.png` (form), `ch12.png` (taht), `ch13.png` (kırmızı düğme),
`ch14.png` (daktilo), `ch15.png` (servis), `ch16.png` (tavuk ayak izi). 1024×256, `#141824` zemin, krem line-art.

## 3B modeller, tur 2 (`assets/models/`) — özgün üretim, prosedürel (7 dosya)

`kerkoporta.glb` (kemerli kapı; kanatlar `DoorL`/`DoorR` ayrı düğüm, pivot menteşede),
`barrel.glb` (şarap fıçısı; `Lid` ayrı düğüm), `cauldron.glb` (ayaklı dev kazan),
`mold.glb` (döküm kalıbı; `Bronze` ayrı düğüm, emissive), `galley.glb` (Venedik kadırgası, ~500 üçgen; kürekler `Oars` düğüm grubu altında `OarL0-6`/`OarR0-6`),
`newsstand.glb` (gazete standı, raflar boş), `bus.glb` (personel servisi; tekerlekler `WheelFL/FR/RL/RR` ayrı).
Tur 1 teknik kurallarıyla aynı: glTF 2.0 binary, Y-yukarı, metre, orijin tabanda, +Z bakış, doku yok.

## Ses efektleri, tur 2 (`assets/audio/sfx/`) — özgün üretim (15 dosya)

OGG Vorbis, mono, 44,1 kHz, tepe ≈ −3 dB; döngüler kesintisiz (uç-uca çapraz soldurma).
Üretim: AI ses efekti sentezi + son işlem (bu proje için; üçüncü taraf kayıt yok).

`explosion_big` (4 sn), `explosion_small` (1), `ear_ring` (3), `whoosh_fly` (2), `land_thud` (0,5), `land_pot` (1),
`crowd_gasp` (1,5), `cartoon_boing` (0,5), `newspaper` (1), `bronze_pour` (döngü ~2,6), `fuse_burn` (döngü ~1,6),
`church_bell` (4), `save` (0,6), `menu_open` / `menu_close` (~0,3–0,5).

## Müzik, tur 2 (`assets/audio/music/`) — özgün üretim (6 dosya)

OGG Vorbis, stereo, 44,1 kHz; prosedürel sentez (numpy). `menu.ogg` (120 sn döngü), `explosion_slowmo.ogg` (20 sn, tek seferlik, epik koro+mehter parodisi),
`byzantium_evening.ogg` (~88 sn döngü), `galata.ogg` (90 sn döngü, mandolin+akordeon), `kitchen.ogg` (~59 sn döngü, darbuka+kaşık), `credits.ogg` (150 sn).

---

## Lisans özeti

- Fontlar: SIL Open Font License 1.1 — lisans metinleri `assets/fonts/` altında. OFL şartı: fontlar tek başına satılamaz; oyunla birlikte gömülü dağıtım serbesttir. Reserved Font Name'ler (Comfortaa, Alfa Slab) değiştirilmeden kullanılmıştır.
- Diğer tüm varlıklar: proje ekibinin özgün üretimi; oyunla aynı lisansla dağıtılabilir.
