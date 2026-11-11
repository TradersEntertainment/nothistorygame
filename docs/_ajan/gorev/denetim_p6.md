Türkçe çalış. Bu depo Godot 4.4.1 ile yazılmış Türkçe birinci şahıs komedi oyunu "Gerçek Tarih Bu Değil" (1453; her şey GDScript ile çizilir; gl_compatibility). Sen BAĞIMSIZ DENETÇİSİN: başka bir ajanın "P6 — kara surları, gece ve hücum (Bölüm 20, 22, 22o, 26o, 36b, 37o; ortak `land_walls.gd`, `wall_fight.gd`)" işinin ÜÇÜNCÜ turunu kendi koşularınla sınayacaksın. İlk iki tur reddedildi. Soru sorma, onay bekleme; başla, bitir, raporu gönder. Görevin hata bulmak. Yanlış "doğrulandı" tek kabul edilmeyen şeydir.

## Kurulum
1. Godot 4.4.1: https://github.com/godotengine/godot/releases/download/4.4.1-stable/Godot_v4.4.1-stable_linux.x86_64.zip → aç, yolu `G`. xvfb-run, ffmpeg, imagemagick yoksa kur (apt).
2. Depo kökünde bir kez `$G --headless --import`.
3. Başsız test: `timeout 900 $G --headless --max-fps 20 --path . -- --chapter=N --autotest[=varyant]` → `AUTOTEST PASS`; şu satırlar OLMAMALI: `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `VISAUDIT`, `WARN_VOID_TELEPORT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `JOURNEY_MISS`, `JOURNEY_OVERLAP`. Varyantlar: `tests/run_tests.sh`.
4. Ekranlı: `PACE=1 timeout 2400 xvfb-run -a -s "-screen 0 1280x720x24" $G --path . --resolution 1280x720 -- --chapter=N --autotest[=varyant] --dialogshots=KLASÖR --shotevery=1 --snapevery=0.5`.
5. Oku: `docs/_ajan/ajan_kurallari.md` (sondaki ek kurallar dahil), `docs/_ajan/paketler.md` "P6", `docs/_ajan/envanter.md` ilgili bölümler.

## Denetlenen iş
ÖNCE: `main`, kayıt `e551de84` (`git fetch origin main`). SONRA: bu dalın ucu. P6 dosyaları: `scripts/level/land_walls.gd`, `scripts/level/wall_fight.gd`, `scripts/chapter20.gd`, `chapter22o.gd`, `chapter26o.gd`, `chapter36b.gd`, `chapter37o.gd`. ÖNCE koşusu için yalnız bu yedi dosyayı `git show e551de84:<dosya> > <dosya>` ile geçici eski hâline koy, koş, `git checkout -- <dosyalar>` ile geri al. Dalda başka ajanların süren işleri de var (bakış denetimi `person.gd`/`stage.gd`/`soldier.gd`, havadan şehir `scripts/world/*`): onlardan gelen hatayı "P6 DIŞI" başlığına yaz. Bir hatanın P6'dan mı geldiğini ayırmak için gerekirse üçüncü düzen kur: yalnız P6 dosyaları yeni, geri kalan her şey `e551de84` (ya da tersi).

### 1. EN ÖNEMLİ: kararsız testler gerçek bir gerileme mi? (istatistik)
Geliştirici kendi (çok yüklü) makinesinde şunu ölçtü: 37o `lose` SONRA 13/14 (hata: `AUTOTEST FAIL chapter=37o variant=lose outcome=37O.2 … barrels=1/5 … duel=true`), ÖNCE 28/28; 26o `lose` SONRA 4/6 (hata: nopass `oil=1/1`: yanan yağ oyuncuyu ıskalıyor), ÖNCE 4/4. Kök neden bulunamadı. Sen yüksüz makinede, aynı anda en çok 3 başsız koşuyla:
- 37o `lose`: ÖNCE 20 koşu, SONRA 20 koşu. 26o `lose`: ÖNCE 20, SONRA 20. Her koşunun `AUTOTEST` satırını aynen sakla; PASS/FAIL sayısını ve FAIL satırlarını tabloyla ver.
- SONRA'da FAIL varsa: üçüncü düzenle (yalnız `chapter37o.gd` yeni / yalnız `land_walls.gd`+`wall_fight.gd` yeni / hepsi yeni) 10'ar koşuyla hangi dosyanın getirdiğini daralt; `git diff e551de84 -- <dosya>` içinde oynanışa dokunan satırları (azapların sayısı/yeri/pozu, `rally`, zamanlayıcı, `await`, rastgele sayı çağrılarının sırası ve sayısı: yeni bir `randf/randi` çağrısı tohumlu diziyi kaydırır mı?, fizik katmanları, yeni çarpışma cisimleri, oyuncuyu iten şeyler) dosya:satırla listele ve en olası kök nedeni yaz. Düzeltme önerini kod parçasıyla ver ama UYGULAMA.
- 37o varsayılan ve `trespass`, 26o `""`, `nophoto`, `turgut`, `turgut_bad` beşer kez (ÖNCE ve SONRA).

### 2. Görsel maddeler (kendi ÖNCE|SONRA karelerinle, aynı an)
- 37o ip çekişi: üç ayrı ip çeken azap; kameranın yüzünde değiller, kılıçsız, tutuş sabit, ayaklar yerde (havada/gömülü değil), ip ellerinden geçiyor; ikinci ve sonraki çekişlerde de aynı. Geliştiricinin notu: bir karede öndeki azabın kolları yana açık. Oyuncu 3 m'den fazla yana kayınca azaplar ipi bırakıyor: o anda ip havada mı kalıyor?
- 37o kalkan ipi: iki el ipte, eller kapalı mı, ipin kalkan ucu nereye bağlı.
- 37o kazanılan çıkıştan sonra: müttefikler kameranın önünden kılıçla geçiyor mu (kararmada yerlerine dönüyorlar mı, ışınlanma görünüyor mu).
- 37o ip çeken azaplar gölgesiz bırakılmış: gece sahnesinde yerde süzülüyor gibi görünüyorlar mı?
- 20/22/22o/26o/36b: `land_walls._wear_props` ile konan sedye, kova, kırık merdiven; peribolos ve hendek zemini (geliştirici "hâlâ düz, eşyalar hiçbir karede yok" diyor): görünüyor mu, havada/gömülü mü, yürüme yolunu kapatıyor mu?
- 22o makara ve marangoz baltaları, 36b kazıcıların aletleri, 37o ıskalanan kanca: geliştirici "kanıt yok" dedi. Sen bak: var mı, elde mi, havada mı?
- 26o açılışta elde eşya (düzeltme geri alındı): durum ne?
- Altı bölümü baştan sona gez; liste dışı yeni kusur ara (havada duran/gövdeye giren nesne ve ip, eli boş çalışan asker, birden beliren kişi, yanlış yöne bakan kişi, küp gibi ateş). P6 kaynaklı mı, ÖNCE'de de var mıydı, ayır.

### 3. Kurallara uygunluk ve performans
- `git diff e551de84 -- <yedi dosya>`: replik anahtarları/sırası, süreler, sayaçlar, sonuç koşulları, kalabalık sayısı (üç yeni ip çeken azap kalabalık/denge sayılır mı: `Melee`/`rally`/hedef seçimi onları görüyor mu?), test botunun yolu değişmiş mi? Kanca/DBG/`P6JUMP`/sonda satırı, susturulmuş denetim (`no_audit`, `no_unclip`, `set_meta("..._ok")`, `no_rally`, `no_talk` gerçekten yalnız yeni azaplarda mı) kalmış mı?
- Testlerin tamamı birer kez: 20 (9 varyant), 22 (7), 22o (6), 36b (2), 0, 28o (4), 41o, 42b, 32o, 21, 26o, 37o.
- RINFO (aynı replik anı, üçer örnek): 20, 22o, 36b, 37o, 0: çizim artmamalı, üçgen ≤ +%8. Geliştirici: 22o çizim bazı saniyelerde +%3; 37o üçgen +%5-6.

## Yasaklar
Oyun kodunu DEĞİŞTİRME (geçici ÖNCE/üçüncü düzen kopyaları ve `tests/_tmp/` sondaları dışında; bitince geri al/sil, `git status` ile doğrula). Alt ajan başlatma. PR yok, `main`e dokunma. Ses üretme. İzin kutusu çıkaracak komut yazma: `rm -rf`/`mv`/`cp -r` hedefinde kabuk değişkeni kullanma; sudo yalnız apt için.

## Teslim
`docs/_kanit_denetim_p6/rapor.md` + en çok 12 pafta (ÖNCE | SONRA, üstünde madde ve an; JPEG ≤ 300 KB) + `kosular.txt` (bütün AUTOTEST satırları). Raporda: (1) istatistik tablosu ve hüküm: gerileme VAR / YOK / BELİRSİZ, kök neden ve önerilen düzeltme; (2) görsel maddeler: DOĞRULANDI / KISMEN / YANLIŞ / KANITSIZ, kendi kare adınla; (3) yeni kusurlar; (4) kurallara uygunluk (dosya:satır); (5) testler ve RINFO; (6) GENEL HÜKÜM: KABUL / KÜÇÜK DÜZELTMELERLE KABUL / RET + numaralı ZORUNLU düzeltme listesi. Bakamadığını "BAKILMADI" yaz. Yalnız `docs/_kanit_denetim_p6/` klasörünü `wip/denetim-p6` dalına kaydet ve gönder. Arka plan koşularının bitmesini bekle; rapor gönderilmeden durma.
