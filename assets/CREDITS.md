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

## Lisans özeti

- Fontlar: SIL Open Font License 1.1 — lisans metinleri `assets/fonts/` altında. OFL şartı: fontlar tek başına satılamaz; oyunla birlikte gömülü dağıtım serbesttir. Reserved Font Name'ler (Comfortaa, Alfa Slab) değiştirilmeden kullanılmıştır.
- Diğer tüm varlıklar: proje ekibinin özgün üretimi; oyunla aynı lisansla dağıtılabilir.
