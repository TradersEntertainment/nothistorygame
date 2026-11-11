# Fragman 2 — ilerleme
- [x] (a) araçlar ve eski fragmanlar incelendi; montage.gd'ye set=story + drive "steps" eklendi
- [ ] (b) çekim listesi
- [ ] (c) önizlemeler (640x360) — kaydet.sh / pafta.sh
- [ ] (d) 1920x1080 kayıt
- [ ] (e) kurgu
- [ ] (f) son pafta
- [ ] (g) rapor
## Notlar
- montage.gd STORY_CLIPS (set=story) yazıldı: 0 kanca_bu_benim, 1 garaj_tekme, 2 kizak_sigortaci, 3 buro_atisma, 4 buro_nasreddin, 5 otag_sali, 6 kayik_ters, 7 havlu_ok, 8 duel, 9 cannon, 10 flight + kart
- önizleme 1: kayit/p_all.avi (640x360, tüm çekimler) — çalışıyor
- p_all (640x360) bakıldı: kanca_bu_benim UYGUN (ilk 0.8 sn yer yazısı söner → kırp; yalnız FREEZE_1 kullan);
  garaj_tekme ATILDI (kamera sıçrıyor, kadraj ışık sütunu/bobinlerin içinde, tekme seçilmiyor);
  kizak_sigortaci ATILDI (askerler kameranın içinden geçiyor, Tolga konuşurken kadraj boş çayır);
  buro_atisma v1 ATILDI (çok geniş, Napolyon küçük) → v2/v3 kadraj; buro_nasreddin ATILDI (ters oturduğu anlaşılmıyor);
  otag_sali v1 ATILDI (Fatih uzakta küçük, elde küp/kitap kadrajı kapatıyor; kitap karıştırma uzun) → pre unbag(book), nohands, fov 38;
  ch12 kitchen varyantı anahtar soruya gelmiyor (leblebi kullan)
- eklendi: vlad_kazik (17 edirne_policy)
- önizleme 2: kayit/p_b.avi (buro v2, otag v1, kayik, havlu, duel, cannon, flight)
- p_b bakıldı: buro v2 (uzak, Napolyon küçük) → v3 fov 46; otag v1 ATILDI; kayik_ters ATILDI (kürekçilerin ensesi kaptanı kapatıyor, "ters" görünmüyor);
  havlu_ok ATILDI (ok seçilmiyor, bot yolu mantolara sapıyor); duel ATILDI (savaş HUD'u yazıları, figür kameranın içinden geçiyor);
  cannon ATILDI (robot gibi ani dönüşler, görev kutusu); flight zaman aşımında çekilemedi
- yeni liste: kanca, buro_atisma(v3), buro_kamera, vlad_kazik, otag_sali(v2), bogaz_prim, hikmet_1977, flight + kart
- önizleme 3: kayit/p_c.avi (only=1..7)
- p_c bakıldı: buro v3 UYGUN; buro_kamera ATILDI (fotoğraf görünmüyor, şakası anlaşılmıyor); vlad_kazik UYGUN; otag v2 ilk 0.5 sn elde leblebi kutusu → elde tutulan eşyalar da gizlendi, fov 24;
  bogaz_prim UYGUN (5.5 sn'de kesilir); hikmet_1977 yalnız ilk replik (5.7 sn) UYGUN, sonrası durağan daktilo → kesildi; flight: uçuş göstergesi/işaret yazıları görünüyordu → gizlendi
- p_d: buro v4 UYGUN; buro_numara kadrajın üstünde kara tabela → kamera salona alındı; buro_sokrates ATILDI (kamera konumu binanın dışı, düşüş)
- SON LİSTE (only sırası): 0 kanca, 1 buro_atisma, 2 buro_numara, 3 vlad_kazik, 4 hikmet_1977, 5 otag_sali, 6 bogaz_prim, 7 flight, + kart
- 1080p kayıtlar: kayit/f_A (1,2), f_B (0), f_C (3,4), f_D (5,6), f_E (7 + kart)
- f_C: vlad UYGUN (1080p); hikmet'e geçişte Godot 22 dk kare yazmadan takıldı → kill, hikmet f_D'ye
- f_D: hikmet, otag, bogaz UYGUN (1080p). f_E: buro_numara ATILDI (tavandaki kara pano, Napolyon dönüp duruyor), flight UYGUN, kart UYGUN. Ek: buro_robot (f_F)
- f_F buro_robot ATILDI (iki açı). (e) kurgu: fragman_tr.mp4 56,8 sn, -14,8 LUFS. (f) son_pafta_1/2.jpg bakıldı. İngilizce: yapılmadı (süre).
- [x] tamam
## İKİNCİ KURGU (koordinatör geri bildirimi: yarısı hareket, 60–75 sn, 12–16 çekim; 33o vb. bölümler yasak → bogaz_prim çıkar)
- set=story2 (montage.gd STORY2_CLIPS): kizak_kayis, havlu_ok2 (drive), fici, kazik, sahi_hey, fren_ipi, dokum, firtina_ip
- önizleme: kayit/q_a (640x360, hepsi)
- yeniden başlatma: q_a durdu; önizleme çekim çekim (sirali.sh q 640x360 story2)
- kayıt q_0 (640x360, set=story2 only=0) bitti: çıkış=0 süre=901sn id=kizak_kayis
  q_0 kizak_kayis: UYGUN 1.15–6.5 sn aralığı (omuz üstü bakış ani dönüş: hariç; garanti repliği tam)
- kayıt q_1 (640x360, set=story2 only=1) bitti: çıkış=0 süre=656sn id=havlu_ok2
  q_1 havlu_ok2 v1: ok havlunun arkasında kaldı (görünmüyor), yürüyüş olmadı, pencere bir yorum repliğinin ortasında açıldı → v2: konumla sabit hızlı ilerleme (glide), 'run' uyarısı, bakış hafif aşağı, quiet() koşulu
- kayıt q_2 (640x360, set=story2 only=2) bitti: çıkış=0 süre=856sn id=fici
  q_2 fici v1: tetik yanlış (giriş konuşması) → step=='lash' (yuvarlama anı)
- kayıt q_3 (640x360, set=story2 only=3) bitti: çıkış=0 süre=442sn id=kazik
  q_3 kazik ATILDI: bot kazık yığını/delik arası ışınlanıyor (kamera sıçrar), elde koli bandı, tokmak tek elde
- kayıt q_4 (640x360, set=story2 only=4) bitti: çıkış=0 süre=676sn id=sahi_hey
  q_4 sahi_hey v1 ATILDI: durağan, Urban ve öküzler uzakta, kadrajın yarısı boş çimen → v2: çekiş başladıktan sonra (loose)
- kayıt q_5 (640x360, set=story2 only=5) bitti: çıkış=0 süre=212sn id=fren_ipi
  q_5 fren_ipi: iki el ipte, araba yokuştan iniyor; ortada hız ibresi (HUD) → story'de RowMeter/BalanceMeter gizlenir; yeniden çekilecek
- kayıt q_6 (640x360, set=story2 only=6) bitti: çıkış=0 süre=428sn id=dokum
  q_6 dokum ATILDI: 6 sn durağan, elde koli bandı, döküm akışı görünmüyor, ibre
- kayıt q_7 (640x360, set=story2 only=7) bitti: çıkış=0 süre=482sn id=firtina_ip
  q_7 firtina_ip ATILDI: durağan, elde koli bandı, figür elin üstüne biniyor. Ek aday: kurek17 (9). Sıradaki: r (2 fıçı, 1 havlu, 4 sahi), s (9 kürek, 8 büro)
- kayıt r_2 (640x360, set=story2 only=2) bitti: çıkış=0 süre=77sn 
  r_2 fici v2: bot yuvarlamayı çok hızlı geçti, koşul yakalanmadı → BarrelRoll düğümü koşulu; disk 3 GB boş kaldı, eski önizleme avi'leri silindi
- kayıt r_1 (640x360, set=story2 only=1) bitti: çıkış=0 süre=629sn id=havlu_ok2
  r_1 havlu_ok2 v2: düz ilerleme + ok sağ önde saplanıyor; başta keçi yorumu Hüseyin'le kesiliyor → kurguda 1,13 sn'den başlar (Hüseyin + ok + 'İki taraf da bana nişan aldı'). UYGUN (1080p'de ok görünürlüğü yeniden bakılacak)
- kayıt r_4 (640x360, set=story2 only=4) bitti: çıkış=0 süre=342sn id=sahi_hey
  r_4 sahi_hey v2 UYGUN 0.1–4.2 sn (Şahi kızakta, iki sıra halatçı çekiyor, kamera yavaş izliyor)
- kayıt s_9 (640x360, set=story2 only=9) bitti: çıkış=0 süre=116sn id=kurek17
  s_9 kurek17 UYGUN 1.0–5.2 sn (gece kürek, kürekçiler karşıda, iz)
- kayıt s_8 (640x360, set=story2 only=8) bitti: çıkış=0 süre=115sn id=buro_atisma2
  s_8 buro_atisma2: kâğıt artık sırtta (düzeltme geldi); Napolyon kadrajı iyi (başlar alt kenarda); Hitler kadrajında Sinan sol ön planı kaplıyor → konum denemesi (10)
- kayıt t_2 (640x360, set=story2 only=2) bitti: çıkış=0 süre=436sn id=fici
  t_2 fici v3 ATILDI: fıçı kameranın önünde takılı kalıyor, elde koli bandı. Ek aday 11 ok_yagmuru (Bölüm 0, drive)
- kayıt u_10 (640x360, set=story2 only=10) bitti: çıkış=0 süre=53sn id=buro_hitler_deneme
  u_10 Hitler konum denemesi: (-6.6,-6.9) en iyi (kâğıt tam okunuyor) → buro_atisma2 Hitler kesmesi bu konum, fov 40. 1080p sırası: w (0 1 4 5 9 8), sonra 11
- kayıt v_11 (640x360, set=story2 only=11) bitti: çıkış=0 süre=723sn id=ok_yagmuru
  v_11 ok_yagmuru ATILDI: kamera kalabalığın içinden geçiyor (yüzler kameraya giriyor), kadrajın üstünde fes kenarı
- kayıt w_0 (1920x1080, set=story2 only=0) bitti: çıkış=0 süre=1361sn id=kizak_kayis
  w_0 kizak 1080p UYGUN 1.3–5.0 sn (sessiz: garanti repliği yarıda kalırdı)
- kayıt w_1 (1920x1080, set=story2 only=1) bitti: çıkış=0 süre=1400sn id=havlu_ok2
  w_1 havlu 1080p UYGUN 1.13–6.6 sn (ok sağ önde saplanıyor, görünüyor)
- kayıt w_4 (1920x1080, set=story2 only=4) bitti: çıkış=0 süre=795sn id=sahi_hey
## DURAKLATILDI (20:31, koordinatör: makine yüklü). Godot süreci yok, kuyruk durduruldu.
1080p HAZIR (karelerine bakıldı): f_B kanca_bu_benim; f_C vlad_kazik; f_D otag_sali, hikmet_1977; f_E flight + card;
  w_0 kizak_kayis (kullan 1.3–5.0 sn, sessiz); w_1 havlu_ok2 (kullan 1.13–6.6 sn).
1080p KAYDEDİLDİ AMA KARELERİNE BAKILMADI: w_4 sahi_hey (önizlemede 0.1–4.2 uygundu), w_5 fren_ipi (ibre gizleme ilk kez bu kayıtta; doğrula).
EKSİK: w_9 kurek17 (önizleme uygun 1.0–5.2), w_8 buro_atisma2 (Hitler kesmesi (-6.6,-6.9) fov40; önizlemede kâğıdı doğrula).
  Sürdürmek için: TMO=2700 $F/sirali.sh w 1920x1080 story2 '9 8'
KURGU (story_cut.py, sıra önerisi): kanca → kızak → havlu → Vlad (2.87:5.10, "Kazık."/"Hayır, poliçe.") → Şahi → Büro (Napolyon son cümlesi ~4.9 sn'den + Hitler kesmesi, ≤7 sn) → kürek → Fatih (4.70:3.63, altyazı "Evet. 29 Mayıs'ta. Salı günü." için trim_txt) → fren → Hikmet 1977 → uçuş (3–4 sn) → kart. Hedef 60–75 sn; gerekirse ek çekim.
Sonra: son_pafta2_*.jpg, fragman_tr_v2.mp4, rapor.
