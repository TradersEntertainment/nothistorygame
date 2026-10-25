# F05_finaller_sureklilik: 23 bulgu

## 1. [YÜKSEK] [mantık] [Bölüm 13]
8.4 + 12.4 rotasında Hikmet hem 1453'te hem 2026 garajında

Bölüm 8'de Hikmet makineye binip 1453'e gittiyse (8.4) ve huzurda Fatih Telsiz-Kumanda'yı tamir ederse (12.4, "E" seçeneği Hikmet'in varlığına bağlı değil), `version` önceliği 12.4'ü 8.4'ün önüne koyar ve W4 sürümü oynanır: kart "Hikmet · 2026, pazartesi 07:15", Hikmet garajda tek başına "Makine kendiliğinden ısınıyor?" der, Tolga gelir. Oysa Hikmet o sırada pijamasıyla 1453'tedir (Bölüm 12'de huzurda yanındaydı). hikmet_fate de hiç yazılmaz. Kanıt: scripts/chapter13.gd:43-52 (12.4 → "w4" önce gelir), scripts/chapter12.gd:351-355 ve 392-393 (repair_ok Hikmet'ten bağımsız), D13_W4_1/D13_W4_2. Öneri: 8.4'te W4'ü 1453 sürümüne bağla (Fatih'in tamir ettiği kumandayla ikisi birlikte döner, 13.4) ya da 8.4 iken 12.4 seçeneğini kapat.

## 2. [YÜKSEK] [mantık] [Bölüm 15]
"Boş Masa" finalinde Hikmet "Evlât servise yetişti" diyor

T2 (pencere kaçtı, Tolga 1453'te kaldı) ve H1 iken final_id = empty_desk olur; garaj sahnesindeki match'te empty_desk için dal yok, anahtar varsayılan D15_G_H1 kalır: "(Çayını karıştırır) Evlât servise yetişti. Kimse bir şey fark etmedi." Hemen ardından durakta D15_S_T2 "Servis bekledi. Kimse binmedi." ve müdür D15_O_T2 "Hiç gelmedi mi?" der. Hikmet Bölüm 13'te telsizden "Kaçırdık. Yarın yeniden açarım" demişti (D13_H_MISSED). Kanıt: scripts/chapter15.gd:340-346, 378-399, 232-233; UI_CH15_FINAL_EMPTY_DESK_SUB ("Hikmet telsizi açık bıraktı"). W5–W13 dünyalarında da D15_G_W* ("Evlât, ne yaptın?") Tolga dönmüş gibi konuşur. Öneri: T2 için ayrı replik (D15_G_T2: telsiz başında bekleyen Hikmet, "Yarın yine açarım") ve W varyantlarının T2'de devre dışı kalması.

## 3. [YÜKSEK] [mantık] [Bölüm 13→16]
Gıdak, pencere zaten kapandıktan sonra "kapanmak üzere" diye geri sarıyor ve Tolga'yı başka bir yere ışınlıyor

Bölüm 16'ya geçiş koşulu yalnız `_outcome == "13.2" and sinerji` (chapter13.gd:845). 13.2'ye her yoldan varılır: Tolga D13_T_MISSED "...Kapandı. Pencere kapandı. Işık söndü." der, Fatih "Otur" (otağda), Niko "Kal" (Bizans şehrinde), Kadri "Doğra" (mutfakta) ya da Galata'da "Galata'da kaldım" der. Sonra kart UI_CH13_GIDAK "Pencere kapanmak üzere..." / "Telsiz-Kumanda yerde. Tolga iki yeniçerinin omzunda." gelir ve Bölüm 16 her zaman CampDay ordugâhında, Hasan ile Hüseyin'in omzunda taşınan Tolga ile açılır (chapter16.gd:52-57, 95-110). Şehirde/Galata'da/otağda oturan Tolga'nın yeniçerilerin omzuna nasıl çıktığı gösterilmez; kapandığı söylenen pencere 90 saniye daha açıktır. Öneri: Gıdak'a giderken "kaçırdık" repliklerini atla (kırmızı düğme süresi biterken doğrudan karta geç) ve Bölüm 16 sahnesini _place'e göre kur ya da Gıdak'ı yalnız camp/kitchen yerinde aç.

## 4. [YÜKSEK] [mantık] [Bölüm 13]
Kuşatmadan dönüşte geri çağrı her zaman Galata'da (ya da Bizans şehrinde) oluyor; otağ ve mutfak sürümleri normal oyunda hiç oynanmıyor

Bölüm 12/12B/10A/10G'den 13'e giden yol Siege.gate ile kuşatmaya sapar; kuşatma Siege.ORDER'ın sonundaki Bölüm 27 (Galata, 1 Haziran) ile, şehir düşmediyse Bölüm 26 ile biter ve 27 doğrudan Siege.return_path() = chapter13'e geçer. Bölüm 13 yeri GameState.last_place() ile, yani bir önceki sahnenin adıyla seçer: "chapter27" → "galata", "chapter26" → "city". Nihat 27'nin sonunda "Şimdi sizi 26 Nisan öğlesine bırakıyorum" der (D26_N_RETURN); Tolga 26 Nisan'da Fatih'in otağındaydı (Bölüm 12) ya da mutfağa gönderilmişti (12.5). Ama kart "— Tolga · 1453 —" sonrası Galata'da, balık tezgâhına bakarak uyanır; pencere kaçarsa "Galata'da kaldım" der (D13_T_MISSED_GALATA). Fatih'in D13_F_MISSED / _NONAME ve Kadri'nin D13_K_MISSED replikleri yalnız siege_done önceden true ise (doğrudan bölüm başlatma) oynanır. Kanıt: scripts/chapter13.gd:41, 171-198, 218-226; scripts/autoload/game_state.gd:457-465; scripts/siege.gd:15, 91-112, 267-273; scripts/chapter27.gd:437, 563. Kuşatmanın Büro'ya çıktığı yer (flags.bureau_from: audience/walls/elsewhere/arrest) zaten kayıtlı. Öneri: Bölüm 13'te yeri bureau_from'dan (ya da kuşatmaya girmeden önceki cur_scene'den) seç.

## 5. [YÜKSEK] [mantık] [Bölüm 27→14]
Tutuklanan Tolga (11.1) kuşatmadan sonra "26 Nisan öğlesine, Hikmet'in penceresine" gönderiliyor ama Bekleme Salonu'nda uyanıyor

11.1'de Siege.gate("chapter14", "arrest") kuşatmaya sapar; Nihat 17'de "Formu imzalarsanız bir aylığına tanık statüsüne geçersiniz" der (D17_N_ARREST). 27'nin sonu her rotada aynıdır: D26_N_RETURN "Şimdi sizi 26 Nisan öğlesine bırakıyorum. Hikmet Bey birazdan pencereyi açacak.", D26_T_RETURN, kart UI_ACT4_END_SUB "Tolga 26 Nisan öğlesine dönüyor". Sonraki sahne Bölüm 14'ün Bekleme Salonu'dur: Tolga 4.582.119 numaralı sırada "Sıra ne zaman gelir?" der, Nihat onunla bir ay birlikte çalışmamış gibi "Size bir teklifim var… Form doldurmayı ben öğretirim" (D14_N_W2/D14_N_W4) diye konuşur; Tolga az önce Hasar Tespit Dosyası'nı doldurmuştur. Kanıt: scripts/chapter11.gd:536-538; scripts/chapter27.gd:436-442; scripts/chapter14.gd:93-94, 124-147; strings.csv:4315, 4326, 4014, 1695-1698. Öneri: tutuklama rotasında D26_N_RETURN_ARREST ("Sizi Bekleme Salonu'na geri götürüyorum; sözleşme bitti, tutukluluk sürüyor") ve kart varyantı; Bölüm 14'te Nihat'ın teklifi kuşatmaya atıf yapsın ("Bir ay tanıklık ettiniz; şimdi sıranın öbür tarafına").

## 6. [YÜKSEK] [mantık] [Kuşatma 26o / Final]
Osmanlı tarafında tanıklık eden "Bizans'a yardım etmiş" Tolga "Bir Akşam" finaline hiç ulaşamıyor

docs/FINALS.md:42 ve siege.gd:286-287 yorumu "Tutmazsa (Osmanlı tarafında tanıklık da dahil) fetih 1453'te olur: dünya W1'e döner, final 'Bir Akşam'" diyor; Nihat da Büro'da (D17_N_CLAIM*) "Dışında olursanız [tarih] dinlemez" diye uyarıyor. Ama Siege.resolve() yalnız scripts/chapter26.gd:994 ve :2019'da (Bizans sayfası) çağrılıyor; chapter26o.gd, 38o, 39o, 31o, 27'de hiç çağrılmıyor. Sonuç: Direniş ≥ 1 + Osmanlı tarafı oyununda byz_reasserted ve world10 hiç yazılmıyor; chapter15.gd:213-214 dünyayı "12B.x"ten W1 sayıyor, chapter15.gd:249 one_evening dalı tetiklenmiyor, final water_bearer/ordinary_monday vb. oluyor. Üstelik final_review.gd ROUTES["one_evening"] koşulu ({"ch":26,"not":["26.3"]}) "26O.x" için de doğru döndüğünden Vaka Dosyası bu oyuncuya "Bir Akşam rotasının bütün adımlarını tamamladın" gösterip finali vermiyor. Kanıt: scripts/siege.gd:286-310, scripts/chapter26o.gd (resolve yok; grep), scripts/chapter15.gd:213-250, scripts/ui/final_review.gd:31. Öneri: Osmanlı tarafının son hücum sayfasında (26o sonu ya da 27) `if Siege.has_claim(): Siege.resolve(false)` çağrılsın; ya da chapter15._resolve_fates'te `has_claim() and siege_side=="O"` için byz_reasserted kurulsun.

## 7. [YÜKSEK] [mantık] [Bölüm 13 / kuşatma dönüşü]
Dönüş Penceresi'nde Tolga neredeyse her oyunda Galata'da başlıyor; otağ (huzur), mutfak (12.5) ve surlar (12B) sürümleri pratikte ulaşılamaz

chapter13.gd:41 `_place = GameState.last_place()` "önceki bölümün" sahnesine (flags["cur_scene"]) bakıyor. Ama artık Bölüm 13'e giden her yol önce kuşatmadan geçiyor (Siege.gate) ve kuşatmanın son sahnesi chapter27 (Galata, ahitname; iki tarafta da ortak) ya da şafak tuttuysa chapter26. last_place() "chapter27" için "galata", "chapter26" için "city" döndürüyor (game_state.gd last_place). Siege.gate yorumu ve UI_JUMP_RETURN ("26 Nisan 1453") ise Büro'nun Tolga'yı ayrıldığı ana (26 Nisan öğlesi, huzurdan çıkış; 12B'de gün batımı surlar) geri bıraktığını söylüyor. Sonuç: Fatih'in huzurundan çıkan Tolga pencereyi kaçırınca "Kaçırdım. Galata'da kaldım. En azından balık taze." (D13_T_MISSED_GALATA) diyor; D13_F_MISSED / D13_F_MISSED_NONAME (Fatih) ve D13_K_MISSED (Kadri, 12.5 mutfak) normal oyunda hiç oynanmıyor; 12.5'in mutfak sahnesi kaybolur. Otomatik test "city" varyantı cur_scene'i elle yazdığı için (chapter13.gd:86-89) bu yakalanmıyor. Kanıt: scripts/chapter13.gd:41, :171-198, :218-228; scripts/autoload/game_state.gd last_place(); scripts/siege.gd:262-272 (gate) ; scripts/chapter27.gd:2-9 (son sayfa Galata). Öneri: Siege.gate() çağrısında o anki sahneyi `flags["pre_siege_scene"]` olarak sakla, last_place() siege_done ise ona baksın (ya da gate'te `cur_scene`'i kuşatma bitince geri yaz).

## 8. [YÜKSEK] [mantık] [Bölüm 12.4 → 13]
"Sultan'ın Tamiri" sürümü Hikmet 1453'teyken (8.4) ya da makineye el konulmuşken (8.3) de garajda oynanıyor

chapter13.gd:44-51 sürümü önce Bölüm 12'ye göre seçiyor (12.4 → "w4"), 8.4/8.3'e sonra bakıyor. chapter12.gd:352-357'de 12.4 seçeneği (UI_CH12_KEY_E) Hikmet'in huzurda olup olmamasından bağımsız açılıyor (chapter12.gd:51: 8.4'te Hikmet otağda, tüfeğiyle duruyor). Sonuç: 8.4 + 12.4 oyununda 1453'te Fatih'in yanında duran Hikmet bir sonraki sahnede 2026 garajında "Makine kendiliğinden ısınıyor? ... Ben dokunmadım" diyor (D13_W4_1/2), Tolga "Hikmet Amca! Fatih tamir etti!" diye ona dönüyor (D13_W4_3); Hikmet'in 1453'ten nasıl döndüğü hiç gösterilmiyor, hikmet_fate H1 kalıyor. 8.3 + 12.4'te ise makine Büro deposundayken garajda dönüyor. (12.6 Mühendisler Meclisi bu durumu "birlikte dönüş" ile çözüyor; 12.4 çözmüyor.) Kanıt: scripts/chapter13.gd:44-51, :745-772; scripts/chapter12.gd:51-56, :351-357, :391-393. Öneri: 8.4'te KEY_E'yi gizle ya da 12.4+8.4'ü meclis/1453 sürümüne yönlendir; 8.3'te w4 sürümünü depo sahnesine uyarla.

## 9. [YÜKSEK] [mantık] [13→16]
Gizli Bölüm 16'ya geçiş öncesindeki sahne ile 16'nın kurgusu çelişiyor

13'te pencere kaçınca (gidak yolu) Tolga otağda Fatih'in karşısındadır; önce "...Kapandı. Pencere kapandı. Işık söndü." (D13_T_MISSED), Hikmet "Kaçırdık. Yarın yeniden açarım" (D13_H_MISSED), Fatih "Gidemedin... Otur." (D13_F_MISSED) der. Hemen ardından kart "Pencere kapanmak üzere... Telsiz-Kumanda yerde. Tolga iki yeniçerinin omzunda." (UI_CH13_GIDAK/_SUB) gelir ve Bölüm 16'da pencere hâlâ açık (90 sn), Tolga ordugâh sahasında Hasan-Hüseyin'in omzunda taşınıyor. Kumandanın düşmesi, Tolga'nın omza alınması hiç gösterilmez; kapanmış pencere yeniden açık sayılır. Kanıt: scripts/chapter13.gd:215-228 ve 845-853, scripts/chapter16.gd:95-110, 221-224. Öneri: gidak yolunda 13'teki "kaçtı" repliklerini atlayıp pencere kapanmadan 16'ya kesmek (ya da kumandanın düşüp Tolga'nın taşındığı kısa bir sahne eklemek); otağ/şehir/Galata konumuna göre 16'nın mekânını uydurmak.

## 10. [ORTA] [mantık] [Bölüm 13]
8.3 + 12.4 rotasında el konulmuş makine garajda

8.3'te makineye Büro el koymuştur (depo sürümü bunun için var), ama 12.4 seçildiyse W4 sürümü makineyi garajda kendiliğinden döndürür. Kanıt: scripts/chapter13.gd:47-52, 745-756. Öneri: 8.3+12.4'te W4'ü Büro deposunda oynat (Rıza'nın rafındaki makine kendiliğinden döner) ya da ayrı bir replik ekle.

## 11. [ORTA] [mantık] [Bölüm 14/15]
Tolga 1977'de (T3) ya da 1453'te (T2) iken "Büro'ya alınsın" raporu onu ışınlayıp gece mesaisine sokuyor

Öneri raporu yalnız tutuklamada değil 10A rotasında da açılır (chapter14.gd:244). Bölüm 13'te yanlış yıla düşen (T3) ya da pencereyi kaçıran (T2) Tolga için Müfide hemen önce "şüpheli 1977'de, halayın kuyruğunda" dedikten sonra bile seçilebilir; seçilince tolga_fate = "T4" yazılır (chapter14.gd:286) ve Bölüm 15'te 1977 sahnesi atlanır, Tolga açıklamasız biçimde 2026 durağında ve ofiste belirir (chapter15.gd:201-203, 305-308). Ayrıca 10A rotasında hiç tutuklanmayan Tolga için rapor metni "Sırada bekledi." der (UI_CH14_R_RECRUIT / _GOOD / _BAD) ve Nihat "Madde 7/d: 'Sırada sabırla bekleyen şüpheli…'" der; Bekleme Salonu sahnesi yalnız tutuklamada oynanır (chapter14.gd:93-94). Öneri: T2/T3'te öneriyi kapat ya da Büro'nun onu geri getirdiğini gösteren bir satır ekle; tutuklanmamış Tolga için "Sırada bekledi"siz bir metin (ör. "Form Z-1'i imzaladı") kullan.

## 12. [ORTA] [mantık] [Bölüm 14/15]
Hikmet 1453'te kaldıysa (13.5, H3) "Zaman Tamir Servisi" finali boş garajda

hn_rel ≥ 1 Bölüm 3/5/8'de 8.4'ten bağımsız kazanılır; 13.5'te (Hikmet kaldı, Tolga döndü) istifa seçilebilir. Nihat "Bir garajda çay beni bekliyor" der (D14_N_RESIGN_1), final time_repair olur; garaja Nihat konur ve "HİKMET & NİHAT · ZAMAN TAMİR SERVİSİ" tabelası asılır, ama H3 olduğu için Hikmet yoktur ve anahtar D15_G_H3 "(Garaj boş. Radyo açık. Çayın buharı yok.)" ile ezilir (chapter15.gd:330, 344-350, 366-367). Nihat boş garajda dikilir; Hikmet'e ait tabela ve "Hikmet & Nihat" alt yazısı (UI_CH15_FINAL_TIME_REPAIR_SUB) yaşanmamış bir ortaklığı anlatır. Öneri: H3'te istifa seçeneğini gizle ya da time_repair'i H3'te devre dışı bırak (_named_final'de N4 koşuluna H != "H3" ekle).

## 13. [ORTA] [metin] [Bölüm 15]
Ofisteki "kuşatmada tanıklık yaptım" cevabı her rotada aynı

D26_T_HONEST: "Her şeyi gördüm, hiçbir şeyi değiştiremedim. Ama birkaç kişiyi sudan çektim." Kuşatma tuttuysa (W10/W11/W12: fetih ertelendi; ofiste iş arkadaşları az önce "1454" konuştu) Tolga tarihi değiştirmiştir; ayrıca "sudan çektim" yalnız 17.1 (denizciler) yapıldıysa doğrudur, Osmanlı tarafında ya da 17.2'de yaşanmamıştır. Kanıt: scripts/chapter15.gd:547-558, strings.csv:4007. Öneri: W10–W12 ve 17.1 olmayan rotalar için _CHANGED / _PLAIN varyantları.

## 14. [ORTA] [mantık] [Bölüm 13→16]
1453 sürümünde frekans kaçınca hiç açılmamış pencere Sinerji'yle açılıyor; Hikmet de geride kalıyor

Urban'ın atölyesinde frekans tutmazsa (D13_H3_FAIL "Kaçırdık. Frekans gitti.") pencere hiç açılmaz, top ateşlenmez, ama _outcome 13.2 olduğu için Sinerji varsa Gıdak açılır ve "Pencere: 90 sn" sayılır. Kazanılırsa Tolga T1 olur, hikmet_fate "H3" kalır: Hikmet'in ("burada biraz daha kalacağız, evlât") yanından Tolga tek başına ve açıklamasız ayrılır; Bölüm 15'te garaj boş görünür. Kanıt: scripts/chapter13.gd:673-680, 703-710, 845-853; scripts/chapter16.gd:252-254. Öneri: 1453 sürümünde (en azından frekans kaçtığında) Gıdak'ı kapat ya da Bölüm 16'yı atölyede, Hikmet'le birlikte dönüşle kur.

## 15. [ORTA] [mantık] [Bölüm 27]
Galata'nın "tanıdık yüzleri" yalnız 10G rotasında tanıdık

Şarapçı Spinola "Siz! Kuşatmadan önceki kurye!" (D27_W_1), Tolga "Bir ay önce burada balık ve şarap pazarlığı vardı" (D27_T_01), Nihat "Tanıdık yüzler var" (D27_N_02) der. Bu kişilerle Galata'da yalnız Bölüm 10G'de (9.3: Çandarlı'nın mektubunu Venedik gemisine götüren kurye) karşılaşılır; 10G bir dal bölümüdür (chapter9.gd:26), diğer bütün rotalarda Tolga Galata'yı ilk kez görür. Bölüm 27'de 10G koşulu ya da varyantı yok. Kanıt: scripts/chapter27.gd:5, 238-240, 296-298; strings.csv:5026-5028. Öneri: chapter_outcomes[10] 10G değilse _STRANGER varyantları ("Siz Büro'dan mısınız? Gemi yarım saate kalkıyor...") ve Tolga'nın açılış satırını değiştir.

## 16. [ORTA] [mantık] [Bölüm 13 → Gizli Bölüm 16]
Gıdak'a geçişte yer sıçraması

Bölüm 13'te pencere kaçınca Tolga, bulunduğu yere göre (Galata/şehir/otağ; yukarıdaki bulgu yüzünden çoğu zaman Galata) "kaçırdım" repliğini söylüyor (chapter13.gd:218-227: D13_T_MISSED_GALATA, D13_N_MISSED, D13_F_MISSED). Hemen ardından Sinerji bayrağı varsa kart "Telsiz-Kumanda yerde. Tolga iki yeniçerinin omzunda" (UI_CH13_GIDAK_SUB) diyor ve Bölüm 16 her zaman ordugâhta (CampDay) başlıyor, Hasan ile Hüseyin Tolga'yı mutfağa taşıyor. Sinerji yalnız 4b (Bizans) yolunda kazanıldığı için bu oyuncular sıklıkla 12B (surlar) ya da kuşatma sonrası Galata/şehirde. Kanıt: scripts/chapter13.gd:845-853, scripts/chapter16.gd:52 (CampDay), UI_CH13_GIDAK_SUB. Öneri: 16'ya yalnız _place=="camp" iken git, ya da 16'nın kartını/sahnesini yere göre kur (şehirde Niko'nun avlusu vb.).

## 17. [ORTA] [oyun] [Kayıt / Gizli Bölüm 16 → 14 → 15]
Gıdak'a (16) geri dönüp farklı sonuç alınca 14 ve 15 eski durumla açılıyor

Oynanış sırası 13 → 16 → 14 → 15, ama GameState.play_order(16) = 16.0 (14 ve 15'ten büyük). prepare_load(data, 16) `play_order(k) <= play_order(16)` olan bütün kayıtları, yani 14 ve 15'in eski başlangıç kayıtlarını da koruyor; snapshot(16) yalnız play_order > 16 olanları siliyor (hiçbiri). Oyuncu 16'yı yeniden oynayıp bu kez kaybederse (16.2 → 13.2, T2) Bölüm 14 açılırken snapshot(14) eski kaydı geri yüklüyor: tolga_fate T1, 13.6/16.1 geri geliyor, yeni sonuç siliniyor. Bölüm listesinde (reached_chapters) de 16, 15'ten sonra sıralanıyor. Kanıt: scripts/autoload/game_state.gd play_order() (~655-661), snapshot() (~664-680), prepare_load() (~861-880), reached_chapters(); scripts/chapter16.gd:40, :252-273. Öneri: play_order'a `if ch == 16: return 13.5` ekle (13 ile 14 arası).

## 18. [ORTA] [mantık] [10L.3 → Bölüm 11 / Büro]
Lağımda Tolga'yı toprağın altından kazıp çıkaran Nihat, birkaç saat sonra Yüzleşme'de kendini ilk kez tanıtıyor

10L.3'te Nihat yüz yüze konuşuyor ("Bay Tolga. Toprak altında kalma formu..." D10L_N_DIG_1/2, chapter10l.gd:283-288). Bölüm 11 yalnız 10A.2 için "yine karşılaştık" (D11_N_KNOWN) diyor (chapter11.gd:232-234); 10L.3 sonrası doğrudan D11_N_01 + D11_N_03 ("Zaman Bürosu. Denetçi Zamanoğlu...") ile tanışma yapılıyor. Aynı şekilde Büro önsözündeki _met_nihat() (chapter17.gd:422-428) 10L.3'ü saymıyor: 10L.3 + 11.4 (iz kaybedildi) oyununda Nihat "Tanışmadık" (D17_N_INTRO_1) diyor. Öneri: 10L.3 için D11_N_KNOWN benzeri bir sürüm ("Tünelden beri...") ekle; _met_nihat'a `chapter_outcomes[10] == "10L.3"` koşulu ekle.

## 19. [ORTA] [metin] [10A/10B/10G/10H/10L/10Z/12B, 8.4 yolu]
Hikmet 1453'teyken (8.4: makineye bindi, Bölüm 9'da pazarda pijamayla görülüyor) dal bölümlerinde telsizden garajdaymış gibi konuşuyor

Hiçbir dal bölümünün telsiz sahnesi Bölüm 8'in sonucuna bakmıyor (grep "8.4": chapter10*.gd ve chapter12b.gd'de yok). Örnekler: D10Z_H_RADIO "Pencere için hazırlanıyorum. Yemek kokusu mu alıyorum telsizden?" (Hikmet aynı ordugâhta), D10H_H_RADIO "Paradoks göstergem tık tık ediyor" (gösterge garajda), D12B_H_RADIO "(Telsiz, çok uzaktan) ... pencere yarın sabah. 07:15" (oysa 8.4'te pencere Bölüm 13'te Urban'ın topuyla, ordugâhta açılıyor; chapter13.gd _h3_version). Kanıt: chapter10a.gd:432, chapter10b.gd:653-659, chapter10g.gd:270, chapter10h.gd:436, chapter10l.gd:355, chapter10z.gd:270, chapter12b.gd:297. Öneri: 8.4 için _1453 sürümleri ("Evlât, Urban'ın atölyesindeyim...") ekle ya da GameState.line_variant'a 8.4 son eki tanımla.

## 20. [ORTA] [mantık] [6b → Kuşatma 20/26]
6b'de Giustiniani'ye yapılan açık uyarı ("29 Mayıs'ta yaralanacaksınız. Surları bırakmayın.", Paradoks +30, Büro Baskısı +2) kuşatmada hiç anılmıyor

Bu seçim `giustiniani_warned` bayrağına yazılıyor (chapter6.gd:829-835) ve yalnız Bölüm 6'nın şeması ile Bölüm 7'de (Nihat'ın sorgusu, D7_GIUST_WARNED) okunuyor. Kuşatmadaki "uyarıldın" replikleri (D20_G_01_KNOWN_WARNED, D26_G_DUCK_WARNED, D26_G_HURT_WARNED "Nisan'da söylemiştin, Frenk. Dinlemedim", D26_G_NOTRUST_WARNED) ve İnsanların Akıbeti (people_fates.gd:103) yalnız 10H'deki `giust_warned` bayrağına bakıyor (game_state.gd _flag_variant "_WARNED"). 6b'de uyarıp 10H'ye gitmeyen oyuncu 29 Mayıs'ta yaralanan Giustiniani'den hiçbir hatırlama duymuyor. Kanıt: scripts/chapter6.gd:827-835, scripts/chapter7.gd:646-648, scripts/autoload/game_state.gd (FLAG_VARIANTS/_flag_variant), scripts/chapter26.gd:17. Öneri: 6b uyarısı için ayrı bir son ek (_WARNED6B: "29 Mayıs dedin...") ekle ya da _WARNED koşuluna giustiniani_warned'ı da kat (replik metnini "omuz"dan bağımsız yaparak).

## 21. [ORTA] [mantık] [16]
Kazanınca "tavuk da yok" denir ama kamera hâlâ tavuğun gözünde, ordugâhta

16.1'de Tolga beyaz flaşla kaybolur (tolga_npc.visible=false), sonra Hasan/Hüseyin "Tavuk da yok. İkisi birden." der; oysa oyuncu (Sinerji) yerinde kalır, kamera tavuk yüksekliğinde muhafızlara bakar. Kanıt: scripts/chapter16.gd:233-250 (D16_HU_GONE); /tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/audit/renders/v3_16/dlg (D16_H_GONE karesinde konuşan Hasan kadrajda bile yok: ekranda tercüman çadırı ve oturan bir kâtip). Öneri: Sinerji'yi de ışınlanmış göster (kamerayı flaş sonrası üçüncü şahsa/muhafızların arkasına al) ya da repliği değiştir.

## 22. [ORTA] [ses/metin] [15]
Hikmet'in olmadığı garajda "Hikmet" konuşmacısıyla sahne betimlemesi

H3 (Hikmet 1453'te kaldı) ve İki Komşu finallerinde garajda Hikmet yok (hikmet=null), ama "(Garaj boş. Radyo açık. Çayın buharı yok.)" ve "(Garaj boş... iki adam koli bandı üzerine tartışıyor.)" satırları SPK_HIKMET etiketi ve Hikmet portresiyle altyazıya basılır. Kanıt: scripts/chapter15.gd:329-345, 366-367, 399; D15_G_H3, D15_G_TWO (VOICE_MAP'te SPK_HIKMET). Aynı sorun: D15_S_T2 (SPK_DRIVER, "(Servis bekledi... Şoför omuz silkti ve gitti.)" — otobüs aslında gitmiyor, :480-494), D15_S_N3 (SPK_NIHAT anlatıcı satırı; "Yeni Nihat yanından geçer" hiç gösterilmez, yalnız eski Nihat durakta dikilir, :474-498). Öneri: anlatıcı/başlık kartı kullan ya da hud.think benzeri konuşmacısız altyazı; S_N3'te yeni Nihat'ı yürüt.

## 23. [ORTA] [eksik] [13]
13.5'te (Hikmet 1453'te kalır) Tolga'nın dönüşü hiç gösterilmiyor

kırmızı düğmeye basılınca beyaz ekran + "Hikmet 1453'te kaldı" kartı, ardından doğrudan akış şeması; birlikte dönüş (13.4) ve tek başına dönüş (13.1) garaj sahnesiyle bitiyor, burada Tolga'nın boş garaja tek başına inişi ve vedanın karşılığı yok. Kanıt: scripts/chapter13.gd:711-717. Öneri: boş garajda kısa bir iniş sahnesi (Hikmet'in soğumuş çayı, servis saati) ekle.

