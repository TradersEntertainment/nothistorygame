# Oyuna yayma: paket ajanı kuralları (hepsi bağlayıcı)

Proje: /home/user/nothistorygame (Godot 4.4.1, GDScript, gl_compatibility; birinci şahıs komedi oyunu, 1453; her şey
kodla çizilir; düşük poligon, dış çizgili çizgi film üslubu).
S=/tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad ; Godot: $S/godot/godot
Test koşusu: `$S/prun_say.sh --chapter=N --autotest[=varyant]` (RUNOK/RUNFAIL basar).

## Amaç
Oyun sahibi Bölüm 2 için şunu dedi: "herkes hareketlerini havaya yapıyor", "havada duran şeylere dikkat et",
"grafiklere daha dikkatli bak", "daha fazla detay ve gerçekçilik"; ve "burada düzelttiğin her şeyi de oyuna yay".
Bölüm 2 ölçütü: $S/b2/tur3/vitrin_pafta.jpg ve $S/b2/tur3/karsilastirma/ (önce|sonra). Önce bunlara bak.

## Okunacaklar
- $S/yayma/envanter.md (bölüm bölüm kusurlar), $S/yayma/paketler.md (senin paketinin madde listesi ve kabul ölçütü).
- Ortak parçalar: $S/b2/ortak_parcalar.md ve $S/yayma/ortak_parcalar2.md (imza, örnek çağrı, UYARILAR). Kareleri
  $S/yayma/p0/. Örnek kullanım: scripts/level/slipway.gd, scripts/chapter2.gd, tests/_tmp/ortak_demo.gd.
- Envanter çoğunlukla 30 Ekim tarihli eski karelere dayanır: her maddeyi ÖNCE taze oynanış karesiyle doğrula;
  düzelmişse "zaten düzelmiş" yaz ve geç.

## Kusur türleri
A havaya yapılan iş (el nesnede değil, alet yok, halat bağlı değil) · B zemin teması (havada/gömülü) · C donmuş ya da
aynı fazda figürler, tepkisizlik · D çıplak zemin/kıyı, düz levha yüzeyler · E su tepkisi yok · F oyuncunun elinde
eşyayla yapılan iş · G uzaktan "tutuyormuş gibi" yakalama/verme · H bakış alanı dışında kalan ana olay.

## Değişmeyecekler
Replik metni ve sırası; oynanış kuralları, süreler, engel/hedef yerleşimi ve çarpışmalar, sonuçlar, hedef metinleri;
test botunun yolu; kalabalık sayısı; karakterlerin tanınan görünüşü. Yeni metin (strings.csv) yok. Üslup aynı:
istenen foto-gerçekçilik değil; dolu, özenli, fiziksel olarak inandırıcı sahne.

## Dosyalar
Yalnız paketinde yazan bölüm betikleri ve onların scripts/level dosyaları. Ortak dosyalarda (stage.gd, nature.gd,
vfx.gd, crowd.gd, items.gd, person.gd, soldier.gd, rig.gd, player.gd, oar_grip.gd, bogaz.gd, cannon_crew.gd) yalnız
EKLEME; mevcut işlev ve imzalara dokunma; eklediğin her şeyi raporda yaz. Başka paket ajanları aynı anda başka
bölümlerde çalışıyor ve ortak dosyalara ekleme yapabilir: ortak dosyada her düzenlemeden önce ilgili yeri yeniden oku,
yalnız hedefli Edit, toptan yeniden yazma yok. Bir koşu başkasının yarım düzenlemesi yüzünden betik hatası verirse
2-3 dakika bekleyip yeniden dene; onun dosyasını düzeltme.

## Yasaklar
git yok (salt okunur `git diff -- <dosya>` serbest); oturum/tetikleyici/zamanlama/bildirim/ajan başlatma araçları
yok; pkill/killall yok (kendi sürecini pid ile bitir); `--import` yok; `class_name`'li yeni dosya yok; denetimleri
susturmak (`no_audit`, `no_unclip` vb. ile) yok. Aynı anda en çok 1 ekranlı + 1 başsız Godot. tests/perf_run.sh
kullanırsan PERF_OUT ve PERF_MD'yi $S/yayma/PAKET/ altına ver.

## Kanıt
- Kanıt OYNANIŞ sırasında alınmış karedir (ekranlı `xvfb-run -a`, PACE gerçek hız; depodaki kare alma düzeni:
  GameState shots_dir / `--shots`, $S/yayma/bin/kare.sh). Sondayla yerleştirilmiş yakın plan tek başına yetmez.
  Ekranlı koşunun BİTMESİNİ bekle (ağır kuşatma sahneleri bu makinede çok yavaş: onlarda ilgili evrenin kareleri
  yeter, zaman aşımını uzun tut).
- Her madde için önce|sonra çifti: $S/yayma/PAKET/karsilastirma/. Kareleri kendin aç ve sor: "havada duran, gömülü,
  düz levha gibi, donmuş, kaba ya da el değmeyen bir şey var mı?" Varsa listeye ekle ve düzelt.
- İlerlemeyi madde bittikçe $S/yayma/PAKET/liste.md'ye yaz (makine yeniden başlayabilir; bir sonraki ajan oradan
  devam eder). Paket sonunda 6-8 karelik vitrin paftası: $S/yayma/PAKET/vitrin_pafta.jpg.

## Testler
parse_check PASS; paketindeki her bölümün tests/run_tests.sh'ta geçen bütün autotest varyantları RUNOK
(VISAUDIT/WALKTHRU/HELDAUDIT/ARMAUDIT/SCRIPT ERROR yok); ortak dosyaya ekleme yaptıysan bölüm 2, 17, 20 de.
Performans: paketindeki en ağır iki bölümde önce/sonra RINFO: çizim sayısı artmasın (MultiMesh/birleşik ağ kullan),
üçgen artışı ≤ %8.

## Rapor (en çok 500 kelime + tablo)
Madde tablosu (bölüm, kusur, ne yapıldı dosya:işlev, önce/sonra kare, oynanış karesi, durum
DÜZELDİ/KISMEN/AÇIK/ZATEN DÜZELMİŞ + neden); ortak dosyalara eklenenler; testler; RINFO; açık kalanlar.
Yanlış "DÜZELDİ" tek kabul edilmeyen şeydir: bağımsız denetçi kareleri ve kodu karşılaştıracak.

## DALGA 1'DEN ÇIKAN EK KURALLAR (0.99.118; bağlayıcı)
İlk üç paket ikişer üçer kez reddedildi. Aynı hataları yapma:
1. KANIT: önce|sonra çifti AYNI oynanış koşusundan, AYNI replik anından/sayaçtan alınır. Önce karesi için dosyanı
   geçici olarak özgün hâline döndür (`git show e551de84:<dosya> > …` ile kopya al; koşu bitince kendi sürümünü geri koy
   ve `cmp` ile doğrula). Farklı yerden/farklı andan alınmış çift ve sonda karesi kanıt değildir (sonda yalnız ek,
   adı `sonda_` ile).
2. "Karede seçilmiyor" bir sonuç DEĞİLDİR. Ya seçilir kıl, ya (bir maliyeti varsa) kaldır, ya "DURUYOR, KANITSIZ" yaz.
   Görünmeyen efekt/ağ bırakma. Hiçbirine "düzeldi" deme.
3. Kare almak için oyun koduna kanca/etiket koyduysan iş bitince SÖK (`grep` ile doğrula). Sürüme test iskelesi girmez.
4. Bağımsız denetçi kendi oynanış koşusunu yapacak; vitrin paftasına göre değil ona göre kabul edilir. Vitrine en iyi
   kareni değil, oyuncunun en çok göreceği anı koy.
5. Yakın plan ip/halat: elden çıkan parça kameradan en az 25 cm önde ve aşağıda başlar; yuvarlak kesit, kenevir rengi,
   üçgenler dışa dönük, yüz ayıklama AÇIK (iç yüz "gri şerit" olur). Her karede ağ kurma; uçlar oynayınca kur.
6. Oyuncunun KENDİ suya düşüşünde `Vfx.water_entry`/`splash` çağırma: köpük küreleri kameranın içine düşer ("buz
   kütlesi"). Sıçramayı kameradan en az 1 m ötede, su hizasında halka ve damla olarak kur (bkz. chapter17.gd
   `_splash_around`). Başkasının düşüşünde ortak işlev uygundur.
7. Zemin ayrıntısı leke olmasın: `camp_mud` ve `footprint` görünüşü yumuşatıldı (nature.gd); yine de dikdörtgen ya da
   düzenli aralıklı dizme, seyrek ve düzensiz yerleştir. Kuşbakışında ızgara gibi yama olmaz.
8. Alet ve eşya gerçek ölçüde: tokmak başı ~18×12 cm, sap ~90 cm; mektup ~14×9 cm. Dev alet reddedilir. Vuruş hedefe
   iner (oyuncu önce hedefin başına getirilir), havaya vurulmaz.
9. Bakışı değiştiriyorsan (yaklaşma, `face`) yumuşak çevir; ani dönüş, göğe sıçrama, FOV yakınlaşması yok; oyuncudan
   alınan denetim 3 sn'yi geçmesin. Bakış değişince RINFO da değişir: bütçeyi EVRE EVRE ve aynı ana hizalı ölç
   (çizim artmaz, üçgen her evrede en çok +%8).
10. Uzak kalabalık (sürü, bölük) için düşük ayrıntılı ayrı ağ ve tek MultiMesh; gölgesiz.
11. Düzenleme sırasında dosyayı ayrıştırılamaz bırakma (başka ajanların koşuları düşüyor). Başkasının hatası yüzünden
    koşun düşerse bekle, `parse_check` geçince yeniden koş; o dosyaya dokunma.
12. Rapora "yaptım" yazdığın her şey dosyada ve karede olmalı; yapılmayanı "YAPILMADI" yaz.
Karşılaştırma için özgün kod: main `e551de84` (0.99.118).


## İZİN KUTUSU YASAĞI (zorunlu)
Kullanıcıya izin kutusu çıkaran komut yazma; kutu çıkarsa iş kilitlenir.
- `rm -rf`, `rm -r`, `mv`, `cp -r` hedeflerinde kabuk değişkeni (`$d`, `${v}`) KULLANMA. Silme gerekiyorsa tam açık (literal) mutlak yol yaz ya da hiç silme: yeni, benzersiz adlı klasör aç. Python `shutil.rmtree("/tam/yol")` olur.
- Çalışma klasörün ve depo dışına yazma/silme yok. sudo, curl|sh, chmod -R yok.
- Silmeyi uzun zincirlerin ve heredoc içeren komutların içine gömme; ayrı, kısa komut yap.
- Bir komut reddedilirse aynısını tekrar deneme, başka yoldan yap.
