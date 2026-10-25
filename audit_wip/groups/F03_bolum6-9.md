# F03_bolum6-9: 15 bulgu

## 1. [YÜKSEK] [eksik] [Bölüm 6b]
"Zindan" sahnesi açık caddede geçiyor, hücre yok

6b.3 kaybında kart "Kançılaryanın zindanı · Öğleden sonra" gösteriliyor, kod yorumu "hücrede uyanır, Niko parmaklığın önünde" diyor; ama oyuncu ByzCity.CELL_START=(-7,0,14) noktasına ışınlanıyor ve bu nokta START'ın (0,0,12) 7 m yanındaki sokak. byz_city.gd'de hiçbir hücre, parmaklık ya da zindan geometrisi yok (grep "zindan/cell/parmaklık": yalnız kapı parmaklığı). Oyuncu "İlk zindanım" derken güneşli caddede, Niko yanında dikiliyor. Kanıt: scripts/chapter6.gd:782-793, scripts/level/byz_city.gd:10-11 / D6B_T_DUNGEON_FIRST, D6B_N_DUNGEON_FIRST. Öneri: kançılarya altına küçük bir hücre (duvar + parmaklık + saman) kur, CELL_START'ı oraya taşı.

## 2. [YÜKSEK] [mantık] [Bölüm 6a]
Mutfaktan (4a.3) başlayınca Kadri, hiç gösterilmemiş çakmağı övüyor

4a.3'te _open["A"] baştan açık; fesi çıkarıp Kadri'yle konuşunca _try_complete hemen biter ve leblebi_given false olduğu için D6_KADRI_DONE_FIRE okunur: "Ocağı tek hamlede yakan sensin". Oyuncu çakmağı hiç göstermedi. Ayrıca bu yolda yol sonu satırı D6A_T_ROAD_A "Elimde leblebi tepsisi" diyor. Kanıt: scripts/chapter6.gd:148-152, 391-397, 487 / D6_KADRI_DONE_FIRE, D6A_T_ROAD_A. Öneri: mutfak girişi için ayrı D6_KADRI_DONE_KITCHEN ("bulaşığı bitiren sensin") yaz ya da 4a.3'te yolu ancak bir eşya gösterilince aç.

## 3. [ORTA] [eksik] [Bölüm 6b]
4b.3'ten gelince "Kalk" diyen Niko 40 m uzakta, ortada hücre yok

4b.3 açılışında oyuncu CELL_START'ta (sokak, z=14) başlıyor, Niko ise NIKO_POS'ta (1.5,0,-27; kançılarya önü) duruyor. D6B_N_CELL_MORNING ("Sabah oldu, casus. Kalk. Zindan formunu ben doldurdum") 41 m öteden, görünmeyen bir hücre için söyleniyor; yüz kameraya Niko'ya döndürülse de o çok uzakta. Kanıt: scripts/chapter6.gd:514-525, byz_city.gd:11-12. Öneri: açılışta Niko'yu oyuncunun yanına koy (ya da hücrede başlat), satırdan sonra kançılaryaya yürüsün.

## 4. [ORTA] [mantık] [Bölüm 6a]
A yolu çakmakla açılınca yol satırında hâlâ "leblebi tepsisi" var

Kadri'ye çakmak gösterilerek A tamamlanırsa (leblebi_given=false) D6A_T_ROAD_A "Elimde leblebi tepsisi. ... Arkamda Kadri: 'Düşürme!'" okunuyor; leblebi verilmedi, Kadri de "tabağı" dedi. Kanıt: scripts/chapter6.gd:333-334, 396, 487 / D6A_T_ROAD_A. Öneri: D6A_T_ROAD_A_FIRE ("Elimde bir tabak...") varyantı.

## 5. [ORTA] [eksik] [Bölüm 6a]
Pazar yolunun "tüccarı" sahnede yok, kimse görev vermiyor

D6A_T_KAFTAN "Tüccar teşekkür için bir kaftan verdi" diyor, ama camp_day.gd'de tüccar NPC'si yok; keçinin, yüzüğün sahibi de yok (D6A_T_RING "Sahibi çok sevinecek" deniyor, yüzük hiç geri verilmiyor). Üçüncü iş bitince kaftan bir anda giyilmiş oluyor. Hedef yazısı da yalnız "Y 0/3"; oyuncuya keçi/yüzük/mektubun pazar yolu olduğunu söyleyen satır yok. Kanıt: scripts/chapter6.gd:439-442, scripts/level/camp_day.gd:743-797 / D6A_T_KAFTAN, D6A_T_RING, UI_OBJ6A. Öneri: pazara bir kumaş tüccarı koy (görevleri o versin, yüzük ve keçi onun olsun); kaftan teslimini kısa bir sahneyle göster; hedef satırına "Pazar: tüccarın üç işi" ekle.

## 6. [ORTA] [görsel] [Bölüm 6b]
İmparator sahnesinde oyuncu ve Niko kararmadan ışınlanıyor

_emperor() ilk satırda Niko'yu kançılarya önünden (ya da nerede kaldıysa) saray avlusuna, oyuncuyu da EMPEROR_POS+(1.8,0,0)'a fade olmadan taşıyor. Niko 40 m öteden bir karede İmparator'un yanında beliriyor. Kanıt: scripts/chapter6.gd:855-858. Öneri: kısa fade_to(1)/fade_to(0) ya da Niko'yu İmparator'a giderken oyuncunun peşine takmak.

## 7. [ORTA] [oyun] [Bölüm 6b]
Martı kaçırma replikleri hiç okunamıyor

kaçırmada hud.bark(D6B_T_MISS / D6B_N_MISS) çağrılıyor, aynı karede döngü i+1'e geçip hud.bark(D6B_T_CHASE_i) çağırıyor. bark beklemeden yeni satırı gösterdiği için kaçırma satırı ve sesi aynı karede eziliyor. Kanıt: scripts/chapter6.gd:651, 685, 688; hud.gd:2568-2595. Öneri: kaçırmadan sonra CHASE bark'ını atla ya da MISS'i bitene kadar bekle.

## 8. [ORTA] [eksik] [Bölüm 7a]
"Kancadaki fes" sahnede yok

A yolunda Kadri D7_KADRI_PROTECT'te "(Arkasında, bir kancada, bir fes asılı.)" diyor, Nihat da "Kancadaki fes. Kırmızımsı. Not ediyorum." diye cevap veriyor; ama ne chapter7.gd _build_camp'ta ne camp_day.gd'de Kadri'nin arkasına fes konuyor (camp_day'deki tek "kanca" kandil direği). Kanıt: scripts/chapter7.gd:162-194, 480-482 / D7_KADRI_PROTECT, D7_N_KADRI_FEZ. Öneri: _route=="A" iken KADRI_POS arkasına bir çivi + Props fes modeli koy.

## 9. [ORTA] [eksik] [Bölüm 7a]
İkizlerin "arkasında parlayan" termos/küp/bant yok

D7_HUSEYIN_FAN "(Arkasında bir termos parlıyor.)", _CUBE "(Arkasında renkli bir küp parlıyor.)", _TAPE "(Kalkanı gri bantla tamir edilmiş.)". _build_camp nöbetçilerin yanına yalnız tepsi, demlik ve üç bardak koyuyor; termos, küp ya da bantlı kalkan yok. Kanıt: scripts/chapter7.gd:171-188, 538-546 / D7_HUSEYIN_FAN, D7_HUSEYIN_FAN_CUBE, D7_HUSEYIN_FAN_TAPE. Öneri: guards_break/distracted/taped bayrağına göre Hüseyin'in arkasına ilgili eşyayı koy.

## 10. [ORTA] [metin] [Bölüm 7b]
Theodoros eski labirent kuralını anlatıyor: "dört hata"

D7_THEO_TRUTH_CELL "Aradığınız kişi dört hata yaptı. Zindanda." Bölüm 6b'de artık yedi oda/dört hata labirenti yok; Theodoros tek mühürle izni veriyor, zindana düşüş martıyı üç kez kaçırmaktan oluyor (MAX_MISTAKES=3). Theodoros izni hatasız verdi. Aynı eski kalıntı D6B_THEO_FAIL/D6B_THEO_DONE/D6B_C_OK_* metinlerinde de kullanılmadan duruyor. Kanıt: scripts/chapter6.gd:26, 595-607; chapter7.gd:626,633 / D7_THEO_TRUTH_CELL. Öneri: "İzni aldı, sonra bir martıya kaptırdı. İzinsiz yakalandı, zindanda." gibi yeniden yaz.

## 11. [ORTA] [mantık] [Bölüm 8]
Bandı "az önce" alan iki adam, Cemil konuşurken dükkâna giriyor

Tolga bandı götürdüyse Cemil D8_C_TAPE'te "Son ruloyu az önce iki adam aldı, gri çantalarına koydular. Çanta arka masada." diyor; ajanlar ise bu satırdan SONRA _spawn_agents ile kapıdan giriyor ve "İyi sabahlar. Zaman Bürosu. Rutin kontrol." diye ilk kez kendilerini tanıtıyor. Çanta onlar gelmeden arka masada duruyor. Kanıt: scripts/chapter8.gd:203-212 / D8_C_TAPE, D8_A1_ENTER. Öneri: D8_C_TAPE'i ajanlar girdikten sonra söylet ("Bu beyler bandı aldı, çantaları arka masada") ya da ajanları başta dükkânın içinde başlat.

## 12. [ORTA] [mantık] [Bölüm 9]
Çandarlı'nın mektubu cepteyken Paşa aynı mektubu yeniden veriyor

6a'da kukuletalı adamdan mektup alınırsa (candarli_letter, D6A_T_C_TAKEN "Cebimde gizli bir mektup var", "otağda doğru kişiye ver") Bölüm 9'da Paşa bu yüzden tekrar çıkıyor; ama D9_P_1_ALT/D9_P_3 mektubu ilk kez veriyormuş gibi anlatıyor ("Bu mektup Galata'daki Cenevizlilere"), reddedilince de D9_P_AGAIN "Mektup hâlâ bende" diyor. Tolga'nın cebindeki mektup hiç anılmıyor; ayrıca 6a'da "otağda", 9'da "Galata'ya" deniyor. Kanıt: scripts/chapter6.gd:460-464; chapter9.gd:59-60, 352-384 / D9_P_3, D9_P_AGAIN. Öneri: candarli_letter iken "Mektubu aldın ama otağa götürmedin; asıl adres Galata" diyen bir varyant; reddedince mektup geri istensin.

## 13. [ORTA] [mantık] [Bölüm 9→10B]
Büyük Atış'ın günü tutmuyor

Bölüm 9 (25 Nisan sabahı) D9_URBAN_OFFER_2 "Yarın büyük atış var, Sultan izleyecek", D9_URBAN_YES "Düşün. Yarına kadar." diyor. 10B'nin alt başlığı da "25 Nisan 1453" ve atış aynı gün yapılıyor; üstelik Urban D10B_U_01 "Çırak! Uyandın mı?" ile sabahı yeni başlatıyor, D10B_U_NAME "Dün söz verdin" diyor (söz aynı sabah verildi). D10B_U_POWDER_3 "dün hissettim" powerbank'ı ona hiç göstermemiş oyuncuya da okunuyor. Kanıt: UI_CH9_SUB, UI_CH10B_SUB / D9_URBAN_OFFER_2, D9_URBAN_YES, D10B_U_01, D10B_U_NAME, D10B_U_POWDER_3; scripts/chapter10b.gd:200, 277, 361. Öneri: 10B'yi 26 Nisan sabahına al (ya da 9'daki "yarın"ı "öğleden sonra" yap); POWDER_3'ü showed("urban","powerbank")'a bağla.

## 14. [ORTA] [görsel] [Bölüm 6b]
Niko'nun veda repliği kapkara ekranda

_exit(): fade_to(1.0) → "Beyaz bayrak altında..." kartı → clear_card() → D6B_N_BYE ("Git, casus! Annene selam söyle!") ekran açılmadan söyleniyor; arada fade_to(0) yok, ardından _end_chapter yine karartıyor. Oyuncu Niko'yu ve kapıyı/beyaz bayrağı hiç görmüyor; bölüm konuşan yüzü olmayan siyah ekranla bitiyor. Ayrıca WARN_SAY_ON_FADE denetimi bunu yakalamıyor: clear_card() çocukları queue_free ile siliyor, aynı karede _card.get_child_count() hâlâ >0 olduğu için uyarı susuyor. Kanıt: scripts/chapter6.gd:892-895; scripts/ui/hud.gd:1484 ve 2918-2920. Öneri: kart sonrası Tolga'yı kapıya (beyaz bayraklı Niko yanında) koyup fade_to(0.0) ile aç, sonra D6B_N_BYE; denetimde get_child_count yerine kuyruğa alınmamış (is_queued_for_deletion) çocukları say.

## 15. [ORTA] [oyun] [Bölüm 8]
Büro ajanları "yoldan geçen" olarak konuşulabilir; E'ye basınca 2026 hırdavatçısında Bizanslı kasabalı repliği çıkıyor

_spawn_agents() ajanlara "spk" değil "speaker" meta'sı veriyor, face_id boş; Person._crowd_talk() bu yüzden onlara "npc:crowd" etkileşimi ekliyor. Ekranda "E · Konuş: yoldan geçen" çıkıyor; SideEvents.crowd_set() hırdavatçıda ByzCity/Galata/Camp bulamayınca "BYZ" döndürüyor ve SPK_TOWNSMAN "Frenk misin, Latin misin? Neysen ol, ekmek pahalı." (NPC_CROWD_BYZ_*) diyor. Gizlilik bölümünde, seni arayan ajanla sohbet istemi de çelişik. Kanıt: scripts/chapter8.gd:235-238 (set_meta("speaker")); scripts/npc/person.gd:1066-1078; scripts/side_events.gd:29-41, 65-75; renders/v1_c8/dlg/D8_H_GOT_ANTENNA.jpg ve t00016.0.jpg (istem görünüyor). Öneri: ajanlara set_meta("no_talk", true) (ya da "spk"); crowd_set'te tanınmayan sahnede "" döndürüp konuşmayı kapat.

