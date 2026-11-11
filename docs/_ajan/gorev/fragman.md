Türkçe çalış. Bu depo Godot 4.4.1 ile yazılmış Türkçe birinci şahıs komedi oyunu "Gerçek Tarih Bu Değil" (1453 kuşatması; her şey GDScript ile üretiliyor). Sen bir yardımcı oturumsun ve bu oyunun yeni OYNANIŞ FRAGMANININ yönetmenisin. Ana makinede başka bir yönetmen bu işin yarısını yaptı ama o makine aşırı yüklü; sen kendi makinende işi baştan sona bitireceksin. Soru sorma, plan onayı bekleme; başla, bitir, kanıtla, gönder.

## Oyun sahibinin isteği (aynen)
"en son yönetilen fragmanda ters ve alakasız yürümeler, boşluğa vurmalar vs vardı. bi oynanış fragmanı: absürt hareketler ve hikayeden komik ve ilgi uyandırıcı sahneler. zaman bürosundaki hitler ve napolyon atışması mantıklı olurdu."

## Kurulum
1. Godot 4.4.1 (Linux, x86_64): https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_linux.x86_64.zip → aç, yolu `G`. xvfb-run ve ffmpeg yoksa kur (apt).
2. Depo kökünde bir kez: `$G --headless --import`.
3. Önceki yönetmenin notları ve betikleri depoda: `docs/_ajan/fragman/` → `gorev.md` (görev ve kurallar; BAĞLAYICI), `liste.md` (ilerleme günlüğü: hangi çekim uygun bulundu, hangisi neden atıldı, kurgu sırası), `cekim_listesi.md`, `kaydet.sh`, `sirali.sh`, `pafta.sh` (içlerindeki yollar ana makineye ait: kendi makinene göre düzelt; çalışma klasörün `/tmp/fragman2/`). Araçlar: `tools/trailer/montage.gd` (çekim setleri; `set=story2` ikinci kurgunun çekimleri, "drive" adımları), `tools/trailer/story_cut.py` (kurgu: altyazı ASS, tek müzik), `tools/trailer/gameplay.tscn`, Godot `--write-movie`.

## Durum (önceki yönetmenden)
- İlk kurgu reddedildi: 57 saniyenin 44'ü durağan konuşmaydı.
- İkinci kurgu hedefi: 60–75 sn, 12–16 çekim, yarısı HAREKET (oyuncu bir şey yapıyor), konuşma çekimleri en çok 4–5 sn, Büro'da Hitler–Napolyon atışması (en çok 7 sn), kapanış kartı.
- Uygun bulunan çekimler (yeniden kaydedeceksin, kayıtlar o makinede kaldı): kanca "Evet. Bu benim." (kare donar), Vlad "Kazık." / "Hayır, poliçe.", otağda Fatih "29 Mayıs'ta. Salı günü…", Hikmet 1977, Nihat'ın uçuşu, kapanış kartı, kızak (kayış), beyaz havlu ve ok (havlu_ok2), Şahi topunun çekilişi (sahi_hey), fren ipi (hız ibresi gizli olmalı; doğrula), gece kürek (kurek17), Büro atışması (buro_atisma2: Hitler'in sırt kâğıdı artık sırta sarılı ve okunuyor; Hitler kesmesi için konum (-6.6,-6.9), fov 40 denendi).
- Atılanlar ve nedenleri liste.md'de (bot ışınlanıyor, kamera kalabalığın içinden geçiyor, elde koli bandı, durağan kadraj). Aynı hataları yineleme.
- Önerilen sıra: kanca → kızak → havlu → Vlad → Şahi → Büro → kürek → Fatih → fren → 1977 → uçuş → kart. Süre 60 sn'nin altında kalırsa yeni HAREKETLİ çekim ekle (oyunun 40'tan çok bölümü var; `tests/run_tests.sh` ve `docs/` altındaki bölüm özetlerinden seç: absürt, komik, merak uyandıran anlar).

## Kalite kuralları (kesin)
- Geriye ya da alakasız yöne yürüme, boşluğa yumruk/vuruş, havada duran el ya da eşya, kameranın içinden geçen kişi, ışınlanma, donuk bekleme, yarım kesilen replik YOK. Elde alakasız eşya (simit, koli bandı) YOK.
- Her çekimi 1920x1080 kaydet; kayıttan sonra saniyede 2 kare çıkarıp KENDİN bak; kusurlu çekimi kurguya koyma, düzelt ya da at.
- Oyun kodunu değiştirme (yalnız `tools/trailer/*`); çekimde bir oyun kusuru görürsen raporda yaz (bölüm, an, ne görünüyor).
- Var olan seslendirme ve müzik kullanılır; yeni ses üretme. Altyazılar Türkçe, replikle aynı metin.
- Alt ajan başlatma; PR açma; `main` dalına dokunma.

## Teslim
1. `fragman_tr_v2.mp4` (1080p, H.264, 60–75 sn, ≤ 45 MB) ve bütün fragmanın saniyede 2 karelik paftaları `son_pafta2_1.jpg`, `son_pafta2_2.jpg`, … (her biri ≤ 400 KB) → depoda `docs/_kanit_fragman/` altına koy, `wip/yardimci-fragman` dalına kaydet ve gönder. `tools/trailer/` değişikliklerini de aynı dala kaydet.
2. `docs/_kanit_fragman/rapor.md`: çekim tablosu (sıra, bölüm, süre, hareket/konuşma, neden seçildi), toplam süre, hareketli çekim oranı, kendi baktığında gördüğün kalan kusurlar (dürüstçe), çekim sırasında bulduğun oyun kusurları, İngilizce sürüm için gerekenler.
Kusurlu bir fragmanı "hazır" diye teslim etme; emin olmadığın çekimi raporda işaretle.
