# F02_bolum0-5: 16 bulgu

## 1. [YÜKSEK] [mantık] [Bölüm 3]
"Samimi" sorgu yolunda "kurutma makinesi" yalanı hiç söylenmeden ona atıf yapılıyor

Samimi yaklaşımda Hikmet'in yalanı D3_H_LIE_KIND ("Tolga tatile gitti, Antalya'ya"), kurutma makinesi lafı hiç geçmiyor. Ama aynı yolda devam eden replikler kurutma makinesine dayanıyor: D3_N_EVIDENCE_HIKMET ("Kurutma makinesi mi? ..."), D3_N_EAVES_CALL ("Kurutma makinesi diyeceğinizi biliyordum"), D3_H_DOUBLE_DOWN ("isterseniz pijama kurutayım"), 3.4 sonu D3_N_END_34 ("...Kurutma makinesi. Anlaşıldı."), D3_H_END_34B ("Kurutma makinesi dedim. Yuttu."), UI_CH3_REPORT_3_4 ve akış şemasında kind→3.4 "Kurutma makinesi". Oyuncu, söylenmemiş bir yalanın "yakalandığını" ya da "yutulduğunu" duyuyor. Kanıt: scripts/chapter3.gd:661-667 (kind dalı), :696-724, :1134. Öneri: kind dalı için ayrı replikler yaz (Antalya yalanına göre: "Antalya mı? Paradoks İzi başka söylüyor", "Antalya dedim, yuttu") ya da kind dalında da Hikmet'e kurutma makinesi yalanını söylet.

## 2. [ORTA] [mantık] [Bölüm 1]
Zaman kartı geriye akıyor (03:12 → 03.00)

Garaja dönüşte önce "BÖLÜM 1 — ZAMANATÖR / Tolga · Pazar gecesi, 03:12" kartı gösteriliyor, hemen ardından yatak odası sahnesi "Gece 03.00" kartıyla ve saat 03:00 gösteren komodin saatiyle açılıyor; Hikmet telefonda "beş dakikan var" diyor. Oyuncu önce 03:12'yi, sonra 03:00'ı görüyor. Kanıt: scripts/chapter1.gd:87-95 (UI_CH1_SUB) ve :275 (UI_BED_TIME), scripts/level/bedroom.gd:108. Öneri: UI_CH1_SUB'u "Pazar gecesi, 03:00" yap ya da bölüm kartını yatak odasından sonra, garaja geçişte göster.

## 3. [ORTA] [mantık] [Bölüm 2]
"Garantinin bitmesine iki dakika!" uyarısından ~5 saniye sonra garanti bitiyor

Uyarı s=36 m'de, bitiş s=70 m'de; koşu hızı 7,4 m/sn olduğundan arada yaklaşık 4,6 sn var. Hikmet Bölüm 1'de ilk 10 dakika garanti demişti. Kanıt: scripts/chapter2.gd:17-18, :194-199 / D2_H_WARRANTY, D2_H_WARRANTY_END. Öneri: replikteki süreyi "beş saniye" gibi gerçeğe uygun bir şeyle değiştir ya da uyarıyı daha erken ver.

## 4. [ORTA] [görsel] [Bölüm 2]
Zincirden düşen Tolga ışınlanıp Kasımpaşa kıyısında beliriyor

2.4 yolunda zincir Haliç'in ağzında (World1453 chain_n/chain_s, sur önü), ama "Kaydım. Zincir de mi yağlı?!" repliğinden sonra karartma ile oyuncu kızağın dibindeki kıyıya (shore_point) konuyor ve "Islak bir Frenk casusu!" diyen kıyı askerleri onu yakalıyor. Haliç boyunca kilometrelerce geri dönüş açıklanmıyor. Kanıt: scripts/chapter2.gd:432-457, scripts/level/slipway.gd:133-148. Öneri: düşüşten sonra "akıntı geri sürükledi" gibi bir bark ya da kart ekle, ya da yakalanmayı zincirin yakınında (kayıkla) göster.

## 5. [ORTA] [eksik] [Bölüm 1]
Tolga'nın aldığı terlik Hikmet'e verilmeden Hikmet'in yanında beliriyor

Yatak odasında Tolga terliği alıyor (Interact_bed_slipper siliniyor, D1P_T_10). Garajda ise teslim anı yok: _slipper_demo yeni bir terlik düğümü yaratıp Hikmet'in kalçası hizasında havaya koyuyor (hikmet + (0.3, 0.9, 0.2), ele bağlı değil) ve Hikmet "Şu terliği yolluyorum" diyor. Kanıt: scripts/chapter1.gd:334-358, :407-414. Öneri: giriş diyaloğunda kısa bir teslim anı ekle (Tolga uzatır, Hikmet alır, bark) ve terliği Hikmet'in el kemiğine bağla.

## 6. [ORTA] [görsel] [Bölüm 1]
"Kostüm" değişimi görsel olarak sadece fes

Hikmet "o kıyafetle mi?" diyor, Tolga Osmanlı Gecesi kostümünü giyiyor ("Beş dakika sonra..." kartı), ama birinci şahıs kol baştan beri "redingot" (player.gd:62, :856-866) ve aynadaki Tolga modeli kostümden önce de sonra da aynı 23262d ceketi giyiyor (player.gd:1093). Kostüm öncesi aynaya bakınca D1_T_MIRROR "Redingot... Kostüm partisi için almıştım" deniyor, yani Tolga henüz giymediği kostümü tarif ediyor. Ayrıca bu replik, 'dönem' sözünü Hikmet'e atfediyor; oysa D1_T_11'de bunu kostümcü söylemişti. Kanıt: scripts/chapter1.gd:757-759, :128-133; scripts/player/player.gd:1093. Öneri: kostümden önce Tolga'ya farklı kıyafet ver (pijama ya da takım) ve kostüm sonrası redingota geç; kostüm öncesi ayna için ayrı bir replik yaz; repliği D1_T_11 ile uyumlu hâle getir.

## 7. [ORTA] [görsel] [Bölüm 4]
Niko 11 m'lik surun tepesinden kapının önüne ışınlanıyor

Rıhtım boyunca Niko sur tepesinde (QUAY_Y + WALL_H) yürüyor; kapıya varınca _gate() onu karartma ya da iniş olmadan anında rıhtım seviyesine, kapının önüne koyuyor ve oyuncunun kamerası ona çevriliyor. Kanıt: scripts/chapter4.gd:665-667, scripts/level/sea_walls.gd:47. Öneri: kısa bir karartma ya da "aşağı iniyorum" bark'ı ekle; Niko'yu kapı kulesinden inen merdivenle getir ya da kapı önünde ikinci bir nöbetçi kullan.

## 8. [ORTA] [mantık] [Bölüm 4]
Perde I kapanışında Nihat her rotada Osmanlı ordugâhındaki bir fese bakıyor

Kapanış sahnesi rotadan bağımsız kuruluyor: çadırların yanında kamp ateşi ve büyük kırmızı bir fes (r=0,35 m) var, Nihat "uzaktaki fese bakar ve yazar". 4b rotalarında ise Tolga surların içinde (4b.1/4b.2) ya da zindanda (4b.3); 4b.2'de fes cebinde. Kanıt: scripts/chapter4.gd:821-824, :877-881. Öneri: 4b rotasında işareti şehrin içine (sur kapısı ya da zindan penceresi) koy; fessizken fes yerine fener ya da telefon ışığı kullan.

## 9. [ORTA] [metin] [Bölüm 2/3/5]
Makinenin yapım süresi çelişiyor: bir yıl mı kırk yıl mı

D2_H_24 "Makineyi bir yılda yaptım"; D5_H_DISMANTLE "Kırk yıl yaptım, yarım saatte sökeceğim"; D5_H_CONF_3 "Kırk yıl o geceye dönmek için çalıştım"; D3_H_KIND "Kırk yıldır ... patent". Öneri: D2_H_24'ü "Makineyi kırk yılda yaptım" yap (TR ve EN birlikte).

## 10. [ORTA] [oyun] [Bölüm 5] (şüpheli)
Kapı çalma, telsiz ayarıyla üst üste binebilir

_knock() 3,6 sn bekleyip sonunda koşulsuz olarak player.frozen=false ve _busy=false yapıyor. Üçüncü yakalanma telsize varmadan hemen önce olursa, bu süre içinde frekans ayarı (_start_tuning: _busy=true, frozen=true) başlayabilir; kapı çalma bitince oyuncu ayar sırasında çözülür (A/D hem kadranı çevirir hem yürütür), _busy de erken false olur. Bölüm sonu (_drop_part'ın son kısmı) için de aynı risk var. Kanıt: scripts/chapter5.gd:349-381, :592-617. Öneri: _knock önceki _busy/frozen durumunu saklayıp geri yüklesin, ya da phase "protect"/"to_radio" değilse çalışmasın.

## 11. [ORTA] [metin] [Bölüm 2]
"Garantinin bitmesine iki dakika" uyarısı ile garantinin bitmesi arasında ~5 saniye var

D2_H_WARRANTY koşuda s>36'da, D2_H_WARRANTY_END s>70'te çalıyor; RUN_SPEED 7.4 m/sn → 34 m ≈ 4.6 sn (tökezlemeyle biraz fazlası). Oyuncu "iki dakikam var" sanıp kırmızı düğmeyi erteliyor, ardından garanti bir anda bitiyor. Kanıt: scripts/chapter2.gd:16-17 (WARRANTY_WARN_S=36, WARRANTY_END_S=70), _run_step "İade garantisi" bloğu; i18n D2_H_WARRANTY. Öneri: repliği "Garanti bitiyor! Dönmek istersen şimdi bas!" gibi süresiz yap ya da uyarıyı koşunun başına çek.

## 12. [ORTA] [eksik] [Bölüm 4 · 4a.3]
Bulaşık sahnesinde konuşan Aşçıbaşı Kadri sahnede yok

_dishes() kararıp "Aşçıbaşı Kadri'nin mutfağı" kartı gösteriyor, ordugâhın ortasına (camp, -6.5,0,-8) bir tencere yığını kuruyor; ama hiçbir Kadri/aşçı modeli eklenmiyor (camp.gd'de de Kadri yok). D4A_K_DISHES / D4A_K_DISHES2 boşluğa söyleniyor; "mutfak" denen yer çadırsız açık ordugâh. Kanıt: scripts/chapter4.gd:433-455; grep -i kadri scripts/level/camp.gd → boş; render: renders/v1_c4caught/dlg/D4A_K_DISHES2.jpg (çit dibinde tencere yığını, kimse yok), log.txt'te WARN_PORTRAIT_STUDIO speaker=SPK_KADRI key=D4A_K_DISHES/D4A_K_DISHES2. Öneri: tencere yığınının yanına önlüklü Kadri (Person, face kadri) koy, mümkünse kazan/ocak ekle.

## 13. [ORTA] [mantık] [Bölüm 3 · 3.4]
Nihat "İyi geceler" deyip gitmiyor; Hikmet onun gözünün önünde telsize fısıldıyor

3.4'te Nihat vedalaşıyor (D3_N_END_34), kod yorumu "Nihat gidince Hikmet telsize fısıldar" diyor ama oyuncu (Nihat) yerinden kıpırdamıyor, kararma/çıkış yok; player.face(hikmet) ile Hikmet'e bakarken Hikmet "Fötr şapkalı bir memur geldi, kurutma makinesi dedim, yuttu" diyor. Denetçinin bunu duyması yalanın yakalanması demek; sahne kendi sonucuyla çelişiyor. Kanıt: scripts/chapter3.gd:716-723; D3_H_END_34B. Öneri: Nihat kapıya yürüsün/asansör ışığıyla kaybolsun, sonra kamerayı Hikmet'e çeviren kısa ara kamera ile fısıltıyı ver (ya da Nihat Zaman Perdesi'yle görünmez dinliyor diye göster).

## 14. [ORTA] [görsel] [Bölüm 2 · 2.1/2.4]
Kıyıda yakalanma sahnesinde kamera kumun hizasında, bir sandığa yapışık; askerlerin yalnız gövde/bacakları görünüyor

_to_shore() ve 2.4 dalı oyuncuyu sabit Vector3(sp.x-1, water_y+0.2, sp.z+3.2)'e koyuyor; _swim()'de kapatılan gravity_on bir daha açılmıyor ve kıyı zemini yüksekliği okunmuyor. Sonuç: göz kumun içinde/üstünde ~20-30 cm, sağ yarı turuncu bir kutu duvarı, sol üstte kesik iki asker; "Yakalayın! Frenk casusu!" (D2_S_14) yüzsüz bir kadrajda geçiyor. Kanıt: scripts/chapter2.gd _to_shore (player.global_position = Vector3(sp.x - 1.0, level.water_y + 0.2, sp.z + 3.2)) ve _to_chain 2.4 dalı; renders/v1_c2/t00344.9.jpg. Öneri: zemine ışınla oturt (Unclip.floor_y) + gravity_on = true, askerleri oyuncunun 2-3 m önüne yüzleri görünecek şekilde koy, kutudan uzak bir nokta seç.

## 15. [ORTA] [görsel] [Bölüm 0] (şüpheli)
Ok teslim noktası savunucu kalabalığının içinde: teslim anında kamera bir askerin kafasının içine/dibine giriyor (ekranın yarısı mavi kask ve ense). Otomatik test oyuncuyu LINE+(0.8,0,-2)'ye ışınladığı için kısmen test k



## 16. [ORTA] [görsel] [Bölüm 5] (şüpheli)
"Bodruma kondu: 3/3" istemi ekranın ortasında itirafın sonuna dek kalabiliyor

_drop_part() üçüncü parçada hud.set_prompt(UI_CH5_HIDDEN_N) yazıp oyuncuyu donduruyor, sonra temizlemiyor; istem ancak odak değişince siliniyor. Renderda 1977 itirafının tüm replikleri (D5_H_CONF_0…4, D5_H_NO_CALL) "Bodruma kondu: 3/3" yazısının altında geçiyor. Gerçek oyunda oyuncu yürüyünce silinir; ama telsize basınca da odak "radio_set" kalıp "Telsizi aç" istemi ayar/itiraf boyunca kalabilir. Kanıt: scripts/chapter5.gd:492; renders/v1_c5/dlg/D5_H_CONF_0.jpg, D5_H_CONF_4.jpg. Öneri: _start_tuning() ve _confession() başında hud.set_prompt("").

