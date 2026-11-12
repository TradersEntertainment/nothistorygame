# Ortak kurallar (yardımcı oturumlar, 2. dalga) — ZORUNLU

Türkçe çalış. Depo: Godot 4.4.1 ile yazılmış Türkçe birinci şahıs komedi oyunu "Gerçek Tarih Bu Değil" (1453 İstanbul
kuşatması; her şey GDScript ile çizilir; gl_compatibility). Soru sorma, onay bekleme, plan sunma: başla, bitir, gönder.
Yanlış "düzeldi/doğrulandı" tek kabul edilmeyen şeydir; emin olmadığını KISMEN / KANITSIZ / BAKILMADI yaz.

## Kurulum
1. Godot 4.4.1: https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_linux.x86_64.zip
   → aç, yolu `G`. `xvfb-run`, `ffmpeg`, `imagemagick` yoksa `apt-get install -y` ile kur.
2. Depo kökünde bir kez `$G --headless --import` (10 dakika kadar sürer; üretilen `.import` dosyalarını KAYDETME).
3. Ayrıştırma: `timeout 200 $G --headless --path . res://tests/parse_check.tscn` → `PARSECHECK PASS`.
4. Başsız test: `timeout 900 $G --headless --max-fps 20 --path . -- --chapter=N --autotest[=varyant]` → `AUTOTEST PASS`.
   Şu satırlar OLMAMALI: `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `VISAUDIT`, `WARN_VOID_TELEPORT`, `WALKTHRU`,
   `ARMAUDIT`, `HELDAUDIT`, `LOOKAUDIT backturn`, `JOURNEY_MISS`, `JOURNEY_OVERLAP`. Varyant listesi: `tests/run_tests.sh`.
5. Ekranlı (kare): `PACE=1 timeout 2400 xvfb-run -a -s "-screen 0 1280x720x24" $G --path . --resolution 1280x720 --
   --chapter=N --autotest[=varyant] --dialogshots=KLASÖR --shotevery=1 --snapevery=0.5`. Aynı anda en çok 1 ekranlı +
   2 başsız koşu.
6. Oku: `docs/_ajan/ajan_kurallari.md` (sondaki ekler dahil). Özgün (yayındaki) kod: `main`, kayıt `e551de84`
   (`git fetch origin main`). ÖNCE karesi/koşusu için ilgili dosyaları `git show e551de84:<dosya>` ile DEPO DIŞINDA bir
   kopyada eski hâline getir (depoyu kirletme).

## Yasaklar (hepsi için)
- Var olan replik metinlerini, replik sırasını, süreleri, sayaçları, kazanma/kaybetme koşullarını, dengeyi, kalabalık
  sayısını değiştirme. Yeni `class_name` dosyası açma. Denetim susturma (`no_audit`, `_ok` meta, filtre) yok.
- Ses üretme. PR açma. `main`e dokunma. Alt ajan / başka oturum / zamanlanmış görev başlatma.
- `pkill`/`killall` yok (yalnız `kill <pid>`). Kare almak için koyduğun kanca/sonda iş bitince sökülür (`grep` ile doğrula).
- İZİN KUTUSU YASAĞI: `rm -rf`, `rm -r`, `mv`, `cp -r` hedefinde kabuk değişkeni kullanma (tam açık yol yaz ya da
  silme; yeni benzersiz klasör aç). `sudo` yalnız `apt-get` için. `curl | sh`, `chmod -R` yok. Silmeyi uzun
  zincirlerin/heredoc'ların içine gömme. Reddedilen komutu yineleme, başka yoldan yap.
- Yalnız görev dosyanda sayılan dosyaları düzenle. Başka dosyada gereken şeyi raporda "ORTAK DOSYA ÖNERİSİ" olarak
  kod parçasıyla yaz, uygulama.

## Geliştirici için ek
- Her madde için aynı an, aynı bakış ÖNCE | SONRA kare çifti (oynanış koşusundan; sonda karesi ise adında `sonda_`).
- Performans: aynı replik anına hizalı üç örnek RINFO; çizim artmaz, üçgen her evrede en çok +%8.
- Değişen bölümlerin bütün varyantları başsız PASS; komşu bölümlerden en az üçü de.
- Teslim: görev dosyasındaki `docs/_kanit_<ad>/` klasörüne `rapor.md` (madde madde DÜZELDİ / KISMEN / YAPILMADI /
  KANITSIZ, test sayıları, RINFO, ortak dosya önerileri, bakamadıkların) + en çok 12 pafta (JPEG ≤ 300 KB). Kendi
  dalına kaydet ve gönder (`git push -u origin <dal>`). Arka plan koşuların bitmeden ve gönderim doğrulanmadan durma.

## Denetçi için ek
- Oyun kodunu DEĞİŞTİRME. Geliştiricinin paftasına göre değil KENDİ koşularına ve karelerine göre hüküm ver.
- Her madde: DOĞRULANDI / KISMEN / YANLIŞ / KANITSIZ + kendi kare adın. Liste dışı yeni kusur ara (havada duran ya da
  gövdeye giren nesne, eli boş iş yapan kişi, birden beliren kişi, yanlış yöne bakan kişi, küp gibi ateş, çifte gölge).
  Her kusur için: ÖNCE'de var mıydı?
- Kurallara uygunluk: `git diff <taban> -- <dosyalar>` içinde replik/süre/sayaç/sonuç/kalabalık/bot yolu değişmiş mi,
  kanca ya da susturulmuş denetim kalmış mı (dosya:satır).
- Teslim: `docs/_kanit_denetim_<ad>/rapor.md` + en çok 12 pafta (ÖNCE | SONRA) + ham test satırları. GENEL HÜKÜM:
  KABUL / KÜÇÜK DÜZELTMELERLE KABUL / RET + numaralı ZORUNLU düzeltme listesi (dosya:işlev, beklenen görünüm).
  Yalnız bu klasörü görev dosyandaki dala kaydet ve gönder. `git status` ile oyun kodunun değişmediğini doğrula.
