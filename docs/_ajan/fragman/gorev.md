# YENİ OYNANIŞ FRAGMANI — yönetmen görevi

Oyun sahibinin sözü: "en son yönetilen fragmanda ters ve alakasız yürümeler, boşluğa vurmalar vs. vardı. Bir oynanış
fragmanı: absürt hareketler ve hikâyeden komik ve ilgi uyandırıcı sahneler. Zaman Bürosu'ndaki Hitler ve Napolyon
atışması mantıklı olurdu."

## Ne isteniyor
60–75 saniyelik, 1920×1080, 30 fps, Türkçe sesli ve Türkçe altyazılı bir oynanış fragmanı (ardından aynı kurgunun
İngilizce sürümü). Ton: kuru, absürt komedi; "1453'e düşen sigortacı". İzleyen şunu anlamalı: (1) bu bir birinci şahıs
hikâye oyunu, (2) komik, (3) tarihin içinde saçma şeyler yapıyorsun, (4) merak ettiren bir hikâyesi var.

## Kesin yasaklar (önceki fragmanın kusurları)
- Ters, yan yan, amaçsız ya da duvara doğru yürüme; yerinde dönme; test botunun "robot" hareketleri.
- Boşluğa vurma, havaya yapılan hareket, tutulmayan alet, elde alakasız eşya (ör. ciddi sahnede leblebi).
- Boş kadraj, bir şey olmayan saniye, kararmada bekleme, ham çeviri anahtarı (D8Y_... gibi) görünen yazı.
- İçinden geçme (figür–figür, figür–nesne), havada duran nesne, titreyen/bozuk kamera.
Bir çekimde bunlardan biri varsa o çekim fragmana GİRMEZ; düzeltilemiyorsa başka çekim seçilir.

## Araçlar (oku, anla, kullan)
- `tools/trailer/gameplay.gd`, `tools/trailer/montage.gd` (çekim listesi: bölüm + test botu varyantı + "ne zaman"
  koşulu + süre + üst yazı; `drive` ile botu kapatıp oyuncuyu betikten sürmek; `set=` ile ayrı çekim setleri: "feel",
  "shorts clean"), `tools/trailer/gameplay_cut.py`, `tools/trailer/cut.py`, `tools/trailer/trailer.gd/.tscn`,
  `docs/voice/LOCAL_TRAILER.md`. Önizleme: "-- shots=/klasör" (her saniye bir PNG), "-- only=N" (tek çekim).
- Kayıt: `xvfb-run -a -s "-screen 0 1920x1080x24" $S/godot/godot --path . --write-movie <dosya>.avi --fixed-fps 30
  --resolution 1920x1080 res://tools/trailer/gameplay.tscn -- set=<ad> > <günlük>`; kurgu `ffmpeg` ile (kurulu).
  Yazılımla çizim yavaş: önce 640×360 "shots" önizlemesiyle çekimi doğrula, sonra yalnız seçilen çekimleri tam
  çözünürlükte kaydet. Bir kayıt 40 dakikayı geçerse çekimi kısalt ya da böl.
- Eski çıktılar (ne yapılmaması gerektiğini görmek için kare çıkar ve bak): `/home/user/nothistorygamedemo/video/`,
  `$S/trailer/`.

## Yönetmenlik
1. ÖNCE ÇEKİM LİSTESİ (`$S/fragman2/cekim_listesi.md`): 12–16 çekim, her biri 3–7 sn. Her çekim için: bölüm, an
   (hangi replik/olay), neden komik ya da merak uyandırıcı, kamera nereye bakıyor, ekranda hangi replik/altyazı var,
   nasıl tetiklenecek (bot + koşul, ya da `drive` ile betikten). Oyunun gerçek sahnelerinden seç; aşağıdakiler aday
   (kodda ve `i18n/strings.csv`'de yerlerini bul, en iyilerini seç, daha iyisini bulursan onu kullan):
   - Soğuk açılış (Bölüm 0): top atışı, kare donar, Tolga havada, "evet, bu benim" türü anlatım.
   - Garaj ve zaman makinesi (Bölüm 1): Hikmet Amca, koli bantlı telsiz-kumanda, tekme.
   - Yağlı kızaklar (Bölüm 2): gökten kızağa düşüş, kadırganın önünden kaçış.
   - Zaman Bürosu bekleme salonu: HITLER (duvara dönük, sırtında "REDDEDİLDİ. Lütfen beslemeyin." kâğıdı) ile
     NAPOLYON atışması (bureau.gd `_amb_*`, `_FG`; replikleri bul), ters oturan Nasreddin Hoca, sıra bekleyen tarihî
     figürler. Otomatik testte atışma kapalı: bu çekim için oyuncuyu betikten sür (salona gir, Hitler'in köşesine ve
     Napolyon'a bak), atışmayı tetikle, konuşana dönen kadraj kur. Sahibinin özellikle istediği çekim bu.
   - Ordugâh: Kadri'nin mutfağı, Urban'ın topu ("Altmış öküz bunu Edirne'den getirdi"), Sorucu Ağa'nın üç sorusu.
   - Ara bölüm "Beyaz Havlu" (8y): havluyla iki ordunun arasında yürümek, ayağının dibine saplanan uyarı oku,
     "İki taraf da bana nişan aldı. Bütün kuşatmada ilk kez bir konuda anlaştılar."
   - Eşya saçmalıkları: Bizans askerine selfie çubuğu, koli bandıyla top tamiri, leblebiyle rüşvet, sokakta tuhaf
     davranınca dönüp bakan halk (street_eye otomatik testte kapalı; gerekirse `drive`).
   - Oynanış çeşitliliği için 2–3 kısa mekanik anı (kürek, top nişanı, düello, tırmanma) — yalnız temiz olanlar.
   - Kapanış: oyunun adı, "Tarih böyle değildi. Artık böyle." türü tek cümle (var olan başlık kartı düzenini kullan),
     Steam/istek listesi çağrısı için var olan kart neyse o.
2. Akış: ilk 5 saniyede kanca (en komik ya da en tuhaf an), ortada hikâye + mekanik çeşitliliği, sona doğru tempo
   artar, kapanış kartı. Çekimler arasında sert kesme; her çekimde ne olduğu bir bakışta anlaşılır.
3. Ses: oyunun kendi seslendirmesi ve müziği. Replik yarıda kesilmesin; kesim replik bitiminde ya da nefes yerinde.
   Müzik tek parça olarak alta yatsın (var olan fragman düzeni nasıl yapıyorsa).
4. Yeni replik ya da yeni ses YOK. Var olan replikler ve üst yazılar kullanılır; üst yazı gerekiyorsa çeviri
   dosyasına `python3 $S/add_string.py KEY "tr" "en"` ile ekle (kısa, 2–5 sözcük) ve bana "içe aktarma gerekli" de.

## Kalite kapısı (her çekim için, atlanamaz)
- Çekimi kaydettikten sonra `ffmpeg` ile saniyede 4 kare çıkar, kareleri montaj paftası yap ve KENDİN bak (Read).
  Yukarıdaki yasakların her birini tek tek ara. Kusurlu çekimi düzelt ya da at; "idare eder" yok.
- Son kurgudan saniyede 2 kare çıkar, paftaya dök (`$S/fragman2/son_pafta_*.jpg`), baştan sona bak.
- Bulduğun oyun kusuru (ör. bir sahnede gerçekten içinden geçme) fragman işinin dışındadır: düzeltme, raporda bana
  bildir; o sahneyi kullanma.

## Dosya kuralları
- Senin dosyaların: `tools/trailer/*` (yeni çekim seti ekle: "set=story"; var olan setleri bozma), `$S/fragman2/`.
- Oyun kodunu DEĞİŞTİRME (scripts/ altı yasak). Çekim için gereken her şeyi montage.gd'nin `drive` düzeniyle dışarıdan
  yap. Çeviri dosyasına yalnız add_string.py ile ekleme.
- Yasak: git yazma komutları, `--import`, pkill/killall (yalnız `kill <pid>`), oturum/zamanlama/bildirim/ajan araçları.
- Başka ajanlar başka dosyalarda çalışıyor; bir kaydın betik hatasıyla düşerse (başkasının yarım düzenlemesi)
  bekle ve yeniden kaydet. Aynı anda en çok BİR Godot süreci.
- İlerlemeyi `$S/fragman2/liste.md` dosyasına işle (makine yeniden başlarsa oradan sürülecek).

## Teslim
- `$S/fragman2/fragman_tr.mp4` (H.264, 1920×1080, 30 fps, ses AAC) ve mümkünse `fragman_en.mp4`.
- `$S/fragman2/cekim_listesi.md` (son hâli: giren ve atılan çekimler, neden).
- `$S/fragman2/son_pafta_*.jpg`.
- Rapor (Türkçe, en çok 35 satır): süre, çekim sırası, atılan çekimler ve nedenleri, kendi gördüğün ama gideremediğin
  kusurlar (dürüstçe), bulduğun oyun kusurları, İngilizce sürümün durumu. Fragmanı siteye KOYMA; ben bakıp koyacağım.

S=/tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad
Depo: /home/user/nothistorygame (dal wip/0.99.119; git'e dokunma)
