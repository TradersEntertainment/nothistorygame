# QA dersleri: bölüm bölüm denetimde bulunan hata türleri ve kontrol listesi

Her bölüm denetiminde ve her düzeltmede bu listeyi baştan uygula. Yeni bir hata türü bulunca buraya ekle
(ne oldu, nasıl anlaşıldı, nasıl önlenir). Bölüm 1 ve 2 denetimlerinden (v0.99.35-36) çıkarıldı.

## 1. Kamera ve kadraj
- **Oyuncuyu bir noktaya taşırken zemini gerçek, görünen çarpışma yüzeyinden ölç.** Seviyenin çizim işlevi (ör.
  `Slipway.surface_h`) tek haritada (World1453) dünyanın arazisiyle uyuşmaz: Bölüm 2'de oyuncu kıyı yerine su altındaki
  kuma iniyordu; kamera su yüzünün altında kalınca gök "gece" gibi lacivert görünüyordu. Görünmeyen çarpışma kutularını
  atla (`hud._is_visible_occluder`, `hud._is_person_part` → `chapter2._ground_y`).
- **Kameranın baktığı yönde ne var, kareye bakarak doğrula.** Bölüm 2 zincir sahnesinde oyuncu kütük hattının tam
  ekseni üzerine kondu: kamera kütüklerin oluşturduğu tüpün içinden karanlığa bakıyordu. Uzun bir nesneye (zincir,
  duvar, gemi) yanından ve çapraz bakılır.
- **Seçilen yerin üstü ve önü boş mu**: fizik ışını yalnız çarpışması olan nesneleri görür; tezgâh damı, sundurma gibi
  çarpışmasız modeller için görünen nesnelerin sınır kutusuna da bak (`chapter2._spot_clear`).
- **Yamaçta yan yana duranlar**: dik arazide yan yana konan iki karakter arasında metrelerce yükseklik farkı olur;
  yükseklik çizgisi boyunca diz, düzlüğü (en çok ~0,6 m fark) kontrol et.
- **Konuşan kadrajda olmalı.** Replik söyleyen karakter sahnede yoksa (Bölüm 2.2: Hasan ile Hüseyin hiç yaratılmamıştı)
  ya da kameranın arkasında kalıyorsa düzelt. Önceki turlarda "TUTMAMIŞ" diye dönen bulguların çoğu bu türdendi.
- **Replik ekrandakiyle çelişmesin**: "Arkamda bir gemi var" derken gemi önde; "kimse görmedi" derken askerler
  Tolga'ya bakıyor (HUD konuşanı oyuncuya çevirir: birbirlerine bakacaklarsa `look_target` ver).

## 2. Animasyon: her hareketin bir hareketi olsun
- Kullanıcı notu (Bölüm 2): "Zincire tutunma animasyonu yok; elimiz hep dimdik duran çubuk gibi." Birinci şahıs elin
  kendi hareketi olmalı: nefes, yürüme/koşma salınımı, bakışla gecikme, zıplama/düşme, suda kulaç, uzanıp tutunma.
- Senaryoda bir eylem anlatılıyorsa (tutunur, tırmanır, düşer, uzatır, verir, alır) ekranda o hareket görünmeli.
  Kontrol: replik ya da sahne notunda fiil var mı → `player` tarafında karşılığı (`reach_grab`, `flail`, `show_prop`,
  `hand_gesture`) çağrılıyor mu.
- Karartmayla geçilen hareketler (kıyıya çıkış) için en azından karartma olmalı; göz önünde ışınlanma olmaz.
- Oyuncuyu yürütmek gerekirse tween'le kaydırma: `move_mode = "script"` + `script_velocity` (adım sesi, kafa ve el
  salınımı gelir; Bölüm 4 `_walk_to`).
- Denge (zincir, ip): `player.balance_arms(eğim)`, bitince `balance_arms(INF)`; düşüşte `flail` + çığlık + su sesi.
- Eşya göstermek (`show_prop`, `show_badge`): sol el eşyayı tutar; kart, kitap, çay havada asılı durmaz (v0.99.37).
- Karakterler arası eşya: verilen şey alanın elinde görünür (`rig.hold_item`, okurken `read = true`); taşınan şey
  taşıyanın elinde yürür (Hikmet'in çay tepsisi), havada süzülmez.
- Yürüyen karakter gideceği yöne döner (`face_toward`); sabit açıyla geri geri yürümez. Bölümlerde ortak yardımcı
  (Bölüm 3: `_walk_hikmet`).
- Sahne notundaki fiil (eğilir, süpürür, bırakır, telsize atılır) bir `emote` ya da hareketle karşılanır.
- Birinci şahıs kol: kolluk omuzdan ele doğru yönelmeli (`Player.FREE_SHOULDER`); sabit açılı kol uzanınca kolluğun ağzı
  kameraya döner. Ekranın kenarına yakın çizilen el geniş açıda devleşir: uzanma noktası ortaya yakın sıkıştırılır.
- Hazır araçlar: `player.reach_grab(nokta)` / `release_grab()` (sol el uzanır, tutunur), `player.flail(sn)` (kollar
  savrulur), suda sol el kendiliğinden kulaç atar; sağ el nefes alır, yürürken/koşarken salınır, bakışla gecikir.
- Eşya alışverişi iki yönlü (Bölüm 6): Tolga'nın verdiği eşya karşıdakinin eline uçar ve repliği boyunca orada durur
  (`_hand_to`, `_pass_to`: Person `receive_item`, Soldier `rig.hold_item`); karşıdakinin verdiği şey önce onun elinde
  görünür, Tolga'ya gelir, sonra Tolga'nın elindedir (`_take_from`: kaftan, önlük, mektup). Yalnız gösterilen eşya
  Tolga'nın elinde kalır (`show_prop`). Konuşma menüsünden ve sağ tıktan giden iki yol da aynı yardımcıdan geçmeli:
  biri jestli, öteki jestsiz kalıyordu.
- Repliğin söylediği nesne elde olmalı: "tepsiyi al" diyorsa tepsi otağ yolunda Tolga'nın elinde (`hold_model`),
  "izin elimde" diyorsa izin görünür, "kitabı bıraktım" derken kitap hâlâ elde olmamalı (`drop_prop`).
- Toplanan şey bir anda kaybolmaz: yüzük alınır (uzan, tut, elde göster), keçi yakalanıp sahibine götürülür.
- Yeni jestler: `hand_gesture("write")` (yazar), `hand_gesture("throw")` (atar; leblebi yere saçılır); Sinerji `peck()`.
- Bölüm 7: karakter emote "cross_self" (haç çıkarır), birinci şahıs "(Eğiliyor)" = `duck`; form `show_prop("form")` ve
  `receive_item(.., read=true)` ile doldurulur. "(Hologram) ..." notları konuşanın (Nihat) değil hologramın işi:
  hud bunları birinci şahıs jestine çevirmez; hologram izin işini yapar (karıştırır, okur, sarar, mühürler).
- Birinci şahıs el bölüm başında açılmalı (`player.show_remote(true)`; eli boşsa `set_holding_remote(false)`):
  Bölüm 8'de hiç açılmamıştı, bütün jestler ve gösterilen eşyalar elsiz/havada kalıyordu.
- Rafından alınan eşya: el uzanır, eşya bir an elde görünür, sonra sepete iner (Bölüm 8 `_take_in_hand`).
- Konuşanla oyuncu arasına başka bir NPC girdiyse onu yana çektir (`_clear_line`), ama hedef noktanın boş olduğunu
  denetle (rafın içine itiyordu).
- Elinde eşya tutan karakterin "read" jesti kâğıt üretmez (küpü çeviren Hüseyin'in elinde kâğıt beliriyordu).
- İz/kanıt nesnesi okunan metinle aynı olmalı (metin "kartvizit", yerde kabuk duruyordu).
- Bölüm 9: "Bu mektup" diyen karakter mektubu elinde tutar; kabulde uzatır, Tolga alır; "geri ver" denince Tolga
  geri verir. Bir eşyanın kimde olduğu bayrakla tutulur ve sonraki replik ona göre seçilir ("Mektup hâlâ bende").
- Bir denemede (menü, açı hesabı, toprağa kulak, selam) Tolga'nın da bir hareketi olsun: telefon elde, çömelme,
  eğilme; kabulde verilen eşya (önlük) elden geçer, imza atılınca yazma jesti.
- Bir hayvanın "kovalıyor/peşimden geliyor" denmesi davranışla tutmalı: keçi yalnız kaçıyordu (`Goat.follow`
  eklendi); kovalanan karakter de yerinde durmasın, ara ara kaçsın.
- Uzun nesne (termos, kolonya) birinci şahısta küçük ve sağ altta gösterilir: ekranın ortasını boydan kapatıyordu.
- Eşya alışverişi için ortak yardımcı: `Handover.take_from` / `pass_to` / `release` (scripts/level/handover.gd; modeller
  letter/kaftan/form/item_model). Yeni bölümde kopyalama yapma, bunu kullan (Bölüm 10'un yedi dalında eşyalar elden
  geçmiyordu: mektup, kaftan, powerbank, leblebi, form, kalem, tepsi, tabak, kepçe).
- Telsiz-Kumanda Bölüm 1'den sonra cepte (kullanıcı: "bölüm bitmiş hâlâ elinde kumanda var, saçma"). El boş görünür;
  telsiz notlu replikte (`radio_listen`), kırmızı düğmede ya da oyuncu seçince çıkar. Bir şeyi sürekli elde tutmak
  doğal değil: elde yalnız o an kullanılan eşya dursun.
- Sahne yönergesinden ibaret replik ("(Formu alır, okur. Üç dakika.)") bir karakterin balonunda mırıltıyla okunur:
  ya gerçek replik yap (Tolga'nın fısıltısı) ya da animasyona çevir.

## 3. Zamanlama ve ses
- **Bark sırası HUD'da (v0.99.37):** `hud.bark` çalan bir ayak üstü sözün sesini bekler (en çok 3,5 sn), `hud.say` da
  başlamadan bekler (en çok 3 sn); hemen söylenmesi gereken (çığlık, darbe) `bark(..., true)`. `cut_voice` bekleyen
  bayat sözleri düşürür. Bölüm 3 ses denetimi kesilmelerin çoğunun tek kökten geldiğini gösterdi.
- **Bark'lar birbirini keser.** Aynı karede iki `hud.bark` → ilki duyulmaz. Sonrakini öncekinin ses süresine bağla
  (`_voice_len`, `_delayed_bark`). Önemli satır (garanti uyarısı) sürerken tökezleme repliği atlanır.
- **Duraklatma**: `await get_tree().process_frame` döngüleri menü açıkken de döner; döngü başında
  `get_tree().paused` kontrolü yap. Bekleme süreleri `create_timer(s, false)` (duraklatmada durur).
- **İstem zamanlaması fiziğe uysun**: halat istemi geçerli sıçrama aralığından önce çıkıyordu (erken basan tökezliyor).
- Metin değişince: `docs/voice/INLINE.json` güncelle, değişen anahtarı seslendirme listesine ekle (ses eski metinle
  kalır; altyazı ile ses ayrışır).
- Kayıtlı ama hiç çalınmayan replik (ölü anahtar): ya kullan ya not et. Tersi de var: çalınan ama hiç
  seslendirilmemiş replik (Bölüm 3 Samimi yolunun dört satırı) mırıltıyla geçer; seslendirme listesine ekle.
- Samimi an: tasarım "sessizlik" diyorsa müzik ve ortam da susar (Bölüm 5: itirafta tek ney, sessizlikte hiçbir şey).
- Seslerin sonundaki uzun sessiz kuyruklar ölü hava yapar (ffmpeg silenceremove ile kırpılır).
- Eylemin sesi: mühür, kâğıt, kapı, asansör, çay. Altyazı "gıcırdar" diyorsa ses de gıcırdasın.
- Uyarı ve darbe sözleri (atış uyarısı, "Ay!") `bark(..., true)`: sıra beklerse olaydan sonra gelir (Bölüm 4 rıhtım).
- Dal başına ortam: aynı bölüm dosyası iki yere gidiyorsa (4a ordugâh / 4b deniz surları) sahne `set_meta("ambience")`
  ve `Audio.step_surface` dala göre verilmeli; yoksa denizde ordugâh gecesi, taşta çim adımı çalar.

## 3b. Hikâye bağları
- **Bir bölümün sonucu sonraki bölümlerde okunmalı.** Bölüm 5'in 5.1/5.2 sonuçları (bodrum, yedek kumanda) hiçbir
  yerde kullanılmıyordu; `tests/check_consequences.py` izin listesine eklenen bayraklar "sonra bağlanacak" demektir,
  her bölüm denetiminde bu listeye bak.
- Karakterin elinde ne var: Telsiz-Kumanda Tolga'dayken Hikmet'in elinde de aynısı duruyordu. Eşya kimdeyse yalnız
  onda görünür (`player.set_holding_remote`).
- Hitap: "evlât" yalnız Tolga'ya; Nihat'a "Nihat Bey".

## 3c. Dal mantığı (Bölüm 6)
- Bir sonucu iki ayrı yoldan veren tasarımda (6a.4: pazarın üç işi ya da Kadri'nin termos takası) sonraki bölümler
  sonuca değil olayın bayrağına bakmalı (`goat_caught`): "keçiyi bile sigortaladın" keçisiz yolda söylenmez.
- Aynı yardımcı iki dalda çağrılıyorsa (telsiz çağrısı 6a ve 6b) replik dalın yerini anmamalı ("otağa gidiyorum"
  surların içinde): dal başına anahtar.
- Sağ tık (eşya kullan) yolu konuşmadaki kapıları (izin, sıra) atlamamalı: `_on_item_used` aynı kapıları denetler.
- Bir koşula bağlı şaka (Sinerji "tavuk kokuyor") koşul yoksa nötr sürüme düşmeli.
- Tanık "buraya gelmedi" demeden önce Tolga'nın o kişiye bir şey gösterip göstermediğine bak (`GameState.showed`):
  yol açılıp tamamlanmamış olabilir (Bölüm 7: Kadri, Urban). Bölüm 4 sonucu da tanıklık sayılır (4a.3 bulaşık).
- İkinci konuşma repliği (…_AGAIN) ilk konuşmada ne olduğuna göre: form verilmeden "kâğıdın bende", çay içilmeden
  "çay bitti" denmez.
- Kartlar ve daktilo metni (`hud.card`, `hud.typewriter`) `line_variant`'tan geçmez: fes/varyant gereken metni
  `GameState.line_variant(KEY)` ile çöz (rapor kartı "Fes: kırmızımsı").
- Aynı yere atıf yapan iki sahne aynı mekânı kullanmalı (Bölüm 6 zindanı ile Bölüm 7 zindanı ayrı yerdeydi).
- Seçenek etiketindeki süre ("1 saat") oyunun düştüğü süreyle aynı olmalı (sohbetin kendi maliyeti de sayılır).
- Değişken bir değeri (saat, sayaç) anan sabit metin yazma: garaj kartı "07:10" diyordu, oyun saati başkaydı.
  Kartı/repliği değerden üret (Bölüm 8 UI_CH8_GARAGE %s, %d).
- Bir ipucu yalnız bu oyunda var olan şeyleri anmalı (Cemil kaldırılmış parçaları da tarif ediyordu): parça başına
  kısa anahtar, yalnız gerekenler söylenir.
- Önceki bölümde saklanan/kurtarılan bir nesneyi (5.1 bodrumdaki anten) sonraki bölüm yeniden istemeden önce
  metinde gerekçe olsun ("anten paslanmış").
- Aynı sonuca iki yoldan gelinirse (8.2: geç kalma ya da yakalanma) sonraki bölüm nedeni okur (ch8_reason).
- Bir eşyanın kaynağı birden fazlaysa (kaftan: tüccar ya da termos takası) kaynağı bayrağa yaz (`kaftan_src`);
  başka bir bayraktan tahmin etme (goat_caught).
- Açılış repliği bir yer söylüyorsa ("Mutfakta sabah", "çadırında uyandım") oyuncu orada başlar.
- Başka bir karaktere yönlendiren replik ("Paşa seni bekliyor") o karakter yokken söylenmez; gidilmiş, reddedilmiş
  ya da hiç gelmemiş durum için ayrı replik.
- Bir kez verilmesi gereken karar (Fatih'e mektup sözü, Merak +1) tekrar konuşmada yeniden sunulmaz; sonradan başka
  bir dal seçilirse söz düşer ve sayaç geri alınır. "Dur, bir düşüneyim" reddetmek değildir.
- Aynı kişiyle ikinci karşılaşma tanışmayı baştan oynamaz (kapı muhafızları: kısa AGAIN repliği).
- Rastgele seçilen bir şeyi (Ağa'nın üçüncü sorusu) anan replik sabit olmasın: deveci "deveyi soruyor" diyordu, soru
  otağ direği ya da kavuk da olabiliyordu. Otomatik test hep aynı seçeneği kullanıyorsa öteki seçenekleri elle oku.
- Aynı ödül iki yerde "ilk kez" diye anılıyorsa (iki "bilmiyorum") ikincisi için ayrı replik; sayaç bir kez artar.
- Bir yolda yazılan bayrak sonraki bölümün açılış cümlesini değiştirir: elçi töreninden gelen için "üç soruya da
  cevap verdin" denmez (ch10_envoy); "huzurdan çıktınız" yalnız huzurdan gelene (Siege.gate from).
- Tanışma (`meet`) yalnız gerçekten yüz yüze tanışılan yolda yazılır (10L geri çekilmede Grant "görmediğimiz Frenk").
- Not ile anahtar kelime eşleşmesi alt dizeye takılabilir: "küpeşte" içinde "küp" Rubik küpünü gösteriyordu.
- 8.4'te Hikmet 1453'te: telsiz konuşmaları kapanmaz, "_H1453" replikleri çalar (yazılmış ama ölüydü).

## 4. Arayüz
- Seçim kutusu açıkken HEDEF ve Tarih Defteri kartı saklanır (çok satırlı seçim yukarı çıkınca üst üste biniyordu);
  satırlar koyu ve opak (`_choice_style`), parlak gökyüzünde okunur.
- Tarih Defteri kartı sağda: solda konuşan karakteri örtüyordu.
- Yazı tiplerinde olmayan karakter (emoji, ✓ ★ ⏱ ▮ ◆) kutu çıkar; test makinesinde sistem yazı tipinden gelip
  oyuncunun makinesinde gelmeyebilir. Oyunla gelen yedekler: assets/fonts/ui_symbols.ttf (DejaVu) ve ui_emoji.ttf
  (Noto Color Emoji), GameState._font_fallbacks. Yeni bir sembol ya da emoji eklersen bu iki dosyayı yeniden
  alt kümele (fontTools subset; emoji içe aktarımında disable_embedded_bitmaps=false). Yüklenen Font'u bellekte tut:
  bırakılan kaynak yeniden yüklenince yedeksiz gelir (kalın yazıda emoji kutu çıkıyordu).
- Bir gösterge (`set_chase`) kovalamaca değilse müziği değiştirmemeli (Bölüm 7 tarayıcısı bütün bölüm kovalamaca
  müziği çaldırıyordu): `set_chase(.., chase, music=false)`.
- "Elde" satırı ve bildirimler karartmanın altında çizilir (siyah karede parlak kalıyordu); altyazı ise üstünde kalır.
- Tam ekran katman (Yönetmelik Duvarı) altyazıyı ve QTE yazısını örtmemeli; süreli QTE kalan süreyi gösterir.
- Bir sesli replik bark ile çalınıp ardından `say` gelirse bark sesi en çok 3 sn beklenir: uzun anlatım (hologram)
  `say` olmalı, yoksa kesilir.
- Telsiz notlu replikler ("(Telsiz)", "(Büro telsizi)") hud'da otomatik bip ve cızırtı çalar; elle eklemeye gerek yok.
- Sahne zemini `set_meta("steps", ...)` ile seçilir (Bizans dalında çimen adımı çalıyordu); açık alanda bölüm
  tablosundaki iç mekân ortamı (floresan) `set_meta("ambience")` ile ezilir.
- Biçimli replik (`tr(KEY) % arg`) seslendirilemez: yer adı repliğin içinde olacak şekilde ayrı anahtarlar yaz.
- Duraklatma menüsü açıkken kovalamaca sayaçları akmamalı (`get_tree().paused` kontrolü; `create_timer(s, false)`).
- Kolla oynanınca tuş yazıları: `GameState.tr_pad(KEY)` ve `KEY_PAD` çevirisi. Yeni bir istem eklerken ikisini de yaz.
- `tr()` dışında sabit metin olmasın ("Fes: ✓").
- Kartta da varyant: fes kapalıyken "fesli adam" yazmasın (`GameState.line_variant`).
- HUD öğeleri fesin altında okunmuyor: üst ortaya bir şey koyarken fes şeridini ve "Elde" satırını hesaba kat.
- Seçim satırları 520 px'te kalır ve uzun seçenek alt satıra iner (`autowrap_mode`): Bölüm 9 onay seçeneği sağdan
  taşıp kesiliyordu. Yine de seçenek metnini kısa tut.
- Tarih Defteri sayfası konuşma sürerken toplanmaz (kart konuşanın üstünde açılıyordu).
- E ile bakılan her nesnenin istemi olsun (keçi, top, mektup askeri sessizdi).
- "Kalan deneme" gibi sayaçlar replikten önce güncellenir.

## 5. Denetim süreci
- Oyuncu tarafındaki "anında yap" kapıları `GameState.autotest` değil `Player._instant()` (PACE'te jestler oynar);
  bölüm betiklerinde de animasyonu atlayan `if GameState.autotest` kapıları PACE'i hesaba katmalı.
- PACE çekiminde seçimler 1,2 sn ekranda kalıp testin seçimini yapar (önceden süresiz seçimde sonsuza dek bekliyordu).
- Otomatik test karelerinde jestler, el hareketleri ve bazı eşyalar görünmez (`hud._fast()`): animasyon denetimi için
  `PACE=1` ile çek (`PACE=1 rshot.sh AD --chapter=N --autotest`), replikler gerçek hızda akar.
- Öldürülen tween `finished` sinyali yaymaz: `kill()` edilebilecek bir tweeni `await tw.finished` ile beklemek oyunu
  dondurur (Bölüm 3 sabotajı). `while tw.is_valid() and tw.is_running()` ile bekle.
- Ajanların "bozuk kare", "karanlık" gibi iddialarını kareye kendin bakarak doğrula (Bölüm 2 dalış karesi sualtıydı,
  bozuk değildi). Kaynağını bulmadan düzeltme: karanlık gök iki ayrı nedenden (su altı kamera, kütük tüpü) çıktı.
- Düzeltmeden sonra aynı sahneyi yeniden çek ve kareye bak; testin geçmesi görüntünün doğru olduğu anlamına gelmez.
- Rastgeleliğe bağlı test botları kararsızdır: varsayılan yolda `seed()` ile sabitle (34o). Bilinen kararsızlar:
  34o `=bad` (kayma bazen olmuyor), 6 `byzclimb` ve 24 RearLife "float" (yük altında). Yük altında düşen testi tek başına
  ve değişiklik olmadan (`git stash`) da çalıştırıp karşılaştır.
- CI'da görülen VISAUDIT personhidden: konuşmadan önce oyuncuyu konuşana çevir (29o Baltaoğlu).
- Arka planda bekleme döngüsünde `pgrep -f "[r]shot.sh"` kendi komut satırını da yakalar (kilitlenir): beklenen
  işi PID ile bekle. Aynı sebeple `pkill -f` komutu çalıştıran kabuğu da öldürür: süreçleri PID ile durdur (iki kez
  oldu; `pkill -f` hiç kullanma).
- Arka planda çekim sürerken betik dosyasına yarım bir düzenleme yazılırsa o sırada başlayan çekim derlenemez:
  toplu düzenlemeden sonra önce PARSE, sonra çekim başlat.
- Ses ajanının "sonda 3 sn sessizlik" bulgusu anahtarsız da düzelir: `ffmpeg -nostdin` ile sondaki sessizliği kırp
  (döngüde `-nostdin` yoksa ffmpeg okunan listeyi yutar). Yanlış sesle üretilmiş kayıt (Urban sesiyle Tolga
  repliği) yeniden üretilene dek silinir: yanlış ses, sessizlikten kötüdür.
- Otomatik testte bot konuşulacak kişinin yanına konur (`_auto_stand_near`): uzaktan konuşulan çekimde kadraj bulgusu
  gerçek mi test kaynaklı mı ayırt edilemiyordu.
- Yaklaşma noktası başka bir kişinin dibinde olmasın; konuşanın yanında duran figüran (kukuletalı adam) kadrajın
  yarısını örtüyordu: figüranı konuşanın arkasına al. Muhafızlar dahil herkese yaklaşılır (kapı replikleri pazardan
  çekiliyordu).
- Ajanlar eski derlemenin karelerine bakarken kod değişmiş olabilir: rapordaki bulguyu güncel koda göre ele ve
  düzeltmeden sonra yeni adla (eski klasörü silmeden) yeniden çek.
- Ölü anahtarlar (eski tasarım kalıntısı, seslendirilmiş ama hiç çalmayan) silinir: strings, voice_gain, VOICE_MAP,
  CONSISTENCY ve mp3'leri birlikte.
- docs/voice/*.csv satır sonları CRLF: Python'da metin kipinde açıp yazmak bunları LF'ye çevirir ve bütün dosya
  değişmiş görünür (v0.99.40'ta 9000 satırlık fark). Bu dosyaları `newline=''` ile ya da bayt olarak düzenle;
  commit'ten önce `git diff --stat` ile beklenmedik büyüklükte fark var mı bak.
- strings.csv değişince çeviri dosyaları (i18n/strings.*.translation, depoda) kendiliğinden yenilenmez: çekimden ve
  commit'ten önce `godot --headless --import --path .` çalıştır. Yoksa yerel çekimde yeni anahtar ham çıkar
  ("Elde: UI_HELD_POCKET"); CI testten önce import ettiği için yayın etkilenmez ama yerel kareler yanıltır.
- Yeni `class_name` eklenince yerel global sınıf önbelleği yenilenmeli (`--import` ya da `--editor --quit`); yoksa
  PARSE "Identifier not declared" der.
- Kod çok değiştiyse yarıda kalan çekim toplusunu durdur (süreç grubu: `kill -- -PGID`; `timeout` her çekimi ayrı
  grupta açar) ve güncel kodla baştan çek: karışık derlemenin karelerine bakan ajan eski hatayı yeniden yazar.
- Ses ajanının listesindeki baş/son sessizlik `tails.py`/`heads.py` çıktısından topluca kırpılır (≥1,2 sn).
- Değişiklik olmadan geçen ama değişiklikle düşen bir test (Bölüm 20 d=0 "overlap") "kararsız" sayılmaz: `git stash`
  ile karşılaştır; zamanlama kayınca gizli bir hata ortaya çıkıyor olabilir. Kalabalıkta kök neden: aynı yöne aynı
  hızda yürüyen iki ayrı yürüyen (iki devriyenin reisi) itişmeyle ayrılmıyordu; aynı devriyenin iki eri reis dönünce
  yer değiştirirken kesişiyordu. Çözüm: biri bir an durur; erler kademeli (1,6 / 2,3 m).
- Elde gösterilen eşya (show_prop) ekranın ortasını kapatmasın: kâğıt, uzun eşya ve büyük nesne sağ altta ve küçük.
  Elde sürekli tutulan alet (kepçe, kazma) de küçük ve sağ altta.
- Konuşan kadrajda değilse ona dönülür (`camera.is_position_in_frustum` ile; arkadan bağıran Kadri).
- Bir sahnede yalnız ses veren iş (fitil, döküm, barut) görsel de olsun: kıvılcım, kalıp ağzında dolan bronz, el.
- CI'da iki kez çıkan VISAUDIT "kararsız" değildir (30 float: v0.99.39 ve v0.99.43). Yerelde çıkmıyorsa noktayı ölç
  (o koordinatta aşağı ışınla altındaki gövdeleri yazdır) ve hareket kodunu oku: düellocunun adımı vardığı zemini
  hesaplıyor ama uygulamıyordu, yükseklik 0,3 sn'de bir düzeliyordu. Denetim kuralını gevşetmek yerine (bir denemede
  2, 4, 17o, 37o, 39o'da yeni yanlış alarmlar çıktı) hareketi düzelt; yerelde CI paketinin tamamını
  (`QUICK=1 tests/run_tests.sh`) çalıştır, hızlı liste her şeyi kapsamaz.
- Ertelenmiş çağrıya (`call_deferred`) giden düğüm o arada silinebilir: alıcı fonksiyonun parametresi türlü
  (`w: WorldEnvironment`) olursa Godot "Cannot convert argument 1 from Object to Object" basar. Parametre türsüz,
  içeride `is_instance_valid` ve `is` ile denetle (Bölüm 11, gece kurulurken her koşuda).
- Sahne eylemi eşleştirmesi alt dizeyle yapılır: "ağlar" anahtarı "bağlar"ı da yakalıyordu (Nihat form bağlarken
  ağladı). Fiil anahtarlarının başına boşluk koy ya da sözcük sınırına bak.
- Ekranı kaplayan bir panel (`move_to_front`) QTE talimatını ve altyazıyı da örter: paneli talimat düğümünün altına
  koy (`move_child(w, qte.get_index())`).
- Seçim menüsü kolda en çok 6 tuş: eşya listesi menüyü uzatıyorsa önce sözlü seçenekleri say, eşyaları kalan yere
  öncelik sırasıyla (eldeki, verilebilen, kalanlar) koy. Sınır otomatik testin seçtiği eşyayı düşürürse sonuç değişir
  (11 persuade 70 → 60): sınır koyduktan sonra bütün dalları yeniden koştur.
- Metin "elinde form" diyorsa kâğıt kadrajda olsun; "takip ediyordu" diyorsa hayvan yanında olsun (keçi 55 m ötedeydi).
- Bir el aynı anda iki şey tutmaz: kâğıt, form ya da mektup ele geldiğinde (show_prop, hold_model) eldeki telefon ya
  da kumanda cebe iner, kâğıt gidince geri çıkar (player._stow). Bölüm 11'de bileğe bağlanan form telefonun yanında
  aynı elde görünüyordu; kareye bakarken "elde kaç şey var" diye say.
- Yanındaki konuşan karakter (Hikmet, Nihat) oyuncunun arkasında kalıyorsa ona kısa bir dönüşle bakılır; denetim
  (VISAUDIT) kadrajı denetlemez, kareye bakan göz denetler.
- Eşya uzaktaki birine havada uçarak gitmez: arada mesafe varsa biri taşır. Huzurda (Bölüm 12) Sultan'a kimse
  yaklaşmaz; iç oğlanı eşyayı Tolga'dan alır, tahtın önünde eğilerek sunar, Fatih'in verdiğini geri getirir.
- Uçan eşya artık denetleniyor: Handover.audit_distance (Person.receive_item, Handover.pass_to/take_from ve bölüm
  içi kopyaları) arada 2,2 m'den uzun mesafe varsa WARN_FLY_ITEM basar ve test düşer. İlk taramada dört yer çıktı:
  Bölüm 3 şapka (Tolga tezgâha bir adım atar), 10A form (iç oğlanı sunar), Edirne şişleri (Vlad ve Şehzade mangala
  gelir), Bölüm 12 bütün huzur alışverişi (iç oğlanı). Yeni bir eşya alışverişi yazarken veren ile alanı yaklaştır.
- Denetimin "kim" yazdığı yetmezse (adı @Node3D olan kişi) üst düğümün betiğini ve konuşmacı etiketini yazdır:
  Bölüm 17 testinde yakalanan uçuş aslında Edirne ara bölümündeydi.
- Oyuncu kimi oynuyorsa onun eli görünsün: Bölüm 13'ün garaj, depo ve W4 sürümlerinde oyuncu Hikmet'ti ama el hiç
  açılmıyordu; iki ajan da "Hikmet kadrajda yok, boş odaya konuşuyor" diye yazdı. Pijama kolu görünmeyince oyuncu da
  kim olduğunu anlamaz. Ajan bulgusunu düzeltmeden önce "oyuncu kim" diye kodu kontrol et (sahte bulgu olabilir),
  ama bulgunun arkasındaki gerçek sorunu (görünmeyen el) da düzelt.
- Basılı tutma çubuğunun etiketi işi söylesin ("KOL", "FİTİL"); her şeye "KIRMIZI DÜĞME" yazıyordu. Kol yazıları
  tr_pad ile ([R] ve E kolda B ve X).
- Metinde "işte orada" denen nesne sahnede olsun (Büro deposundaki makine yoktu).
- Hızlı pakette bir kez çıkan VISAUDIT'i "yük" diye geçme: aynı yükte değişikliksiz kodla karşılaştır. Bölüm 36b'de
  geri dönen savunucular farklı yerlerden çıkıp aynı hızla aynı şeritten iniyor, köprünün dibinde iç içe giriyordu;
  Giustiniani'nin şeridi de savunucuların dönüş yolunu kesiyordu. Şeridi hedefin tarafından seç, aynı şeritte
  öndekine yetişen yavaşlasın. Leon izden yürürken yüksekliği izden alıyordu (rampadan köşe kesince havada).
  8 paralel koşuda çıkan "below=none" (zemin yok) uyarıları ise değişikliksiz kodda da 8/8 çıkıyor: yük ürünü.
- Uzun ekran yazısı (hud.typewriter) satır sarmalı: Bölüm 14'ün öneri raporu tek satırda ekrandan taşıyordu.
- Sahnedeki işlevsiz dekor bir işe yarasın: Büro'daki pnömatik boru "sarı direk" diye iki turda bulgu oldu; artık
  Müfide'nin dosyası onun içinden masaya düşüyor (kapıdan 5 m uzatılıyordu).
- Sahnedeki yazılar (Props.label) İngilizcede LABEL_EN'den çevrilir; yeni etiket yazınca oraya da ekle.
- Süre kısaltması "GameState.autotest" ile yazılırsa gerçek hızlı çekimde (PACE) de kısalır: elde gösterilen not ve
  kart 0,05 sn'de silinip karede hiç görünmüyordu. Görsel süreler için `autotest and not pace` kullan.
- Bekleme döngüsünde `pgrep -f AD` kendi komut satırını da bulur ve döngü bitmez: PID ya da işaret dosyası bekle.
- Para, gazete, çay gibi küçük alışverişler de el değiştirsin: Bölüm 15'te banknot 3 sn sonra Tolga'nın elinden
  siliniyor, gazete hiç ele gelmeden ekranda beliriyor, "Nihat Bey, çayınız" denen bardak hiç yoktu. Satan alır
  (Handover.pass_to), veren uzatır (take_from), konuşmada "buyurun" denen şey birinin elinden diğerine geçer.
- Garajdaki Hikmet bir Person değil: el işleri `hikmet.rig.hold_item` ile (Person'ın kısayolu yok). Ortak yardımcı
  yazınca her iki türle de bir varyant koştur.
- Gizli bölüm bitince ana yolun sahnesi atlanmasın: Bölüm 16 kazanılınca 13.1'in garaj dönüşü hiç oynanmıyor,
  kart sonrası doğrudan 14'e geçiliyordu. Yan yoldan ana yola dönerken "ana yolda bu noktada ne görülüyordu" diye bak.
- Oyuncu insan değilse (tavuk) adım sesi, göz yüksekliği, "eli" de ona göre: gaga kadrajın altında, adım tıpırtı.
  Kamera kahraman gidince de onun gözünde kalmasın.
- Kameraya bağlı yeni bir model (gaga) bölüm sonunda gizlenmezse HELDAUDIT testi düşürür.
- Ortak yardımcı "olağan" değere dönüyorsa (player.duck göz hizasını 1,62'ye döndürüyordu) olağan dışı oyuncu (tavuk)
  sahne notunda eğilince insan boyuna fırlar. Dönüş değerini sabitten değil oyuncunun kendi dinlenme değerinden al
  (eye_rest). Gerçek hızlı çekimde karenin birden yükseldiğini görürsen kamera yüksekliğini yazdırıp bak.
- Devriye yönünü sinüsün işaretinden alma: dönüş anında iki kişi yer değiştirip 180° sıçrar. Yönü hızdan al ve
  lerp_angle ile döndür.
  Aynı sabit oyuncu serbest kalınca da (_on_released) uygulanıyordu: tavuk ilk kontrol anında 1,62 m'ye çıkıyordu.
  Bir oyuncu özelliğini değiştiren bölüm, o özelliği "olağana döndüren" bütün yolları da aramalı (grep EYE).
- Bölüm 17 Büro'sunda fotoğraf makinesi Nihat'ın masasından Tolga'nın eline 2,3 m uçuyordu: Nihat makineyi elinde
  tutarak Tolga'nın önüne yürür. camera_hold da artık uçuş mesafesini denetler (WARN_FLY_ITEM).
- Sonuca göre değişen olayı (kadırga söndü/yandı) anlatan sabit replik ve sonraki bölümün özeti iki sonuca göre de
  okunmalı: 17O.1'de "kadırgamız yandı" deniyordu.
