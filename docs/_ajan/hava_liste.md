# Havadan bakış (Nihat) — ilerleme listesi
Depo: /home/user/nothistorygame. Kare aracı: tests/_tmp/hava_shot.gd/.tscn (git dışı; iş bitince SİL), koşturucu $S/nihat/hava/hs.sh
(CH=.. PRE=.. VIEWS="ad:x,y,z:lx,ly,lz;..." y = yüzeyin üstü; ! mutlak). Kareler kare/, çiftler cift/.

## Durum
- [ ] Aşama 1 araştırma (kareler)
- [ ] rapor.md
- [ ] Aşama 2 düzeltmeler
- [ ] testler

## Kod bulguları (ilk okuma)
- 7a ve 11 CampDay (in_world=true) -> World1453.build("camp"); 7b ByzCity part "walls" -> World1453.build("byz_walls"). CityPanorama yalnız in_world=false (kullanılmıyor). Bölüm 3 Büro içi (İstanbul yok).
- Ateş küpleri: siege_field.gd:974-975, 1173 (ring fires) ve wall_rear.gd:247, 826; horn_world.gd:186 -> Dressing.glow = emisyonlu KUTU. siege_field.gd benim listemde yok.
- Flame mode 0 (y ekseninde dönen dörtgen) tepeden bakınca bozulur (cross(up, cam_z) ~ 0).
- Hipodrom: kutular (horn_world.gd:272-282); Konstantin Sütunu: düz silindir (285); Büyük Saray: kutular (287-291); kiliseler kutu+silindir+küre (247-257); Havariyun kutu+silindir+küre (_monuments 724); Bozdoğan: kutu ayaklar + kutu kuşak, kemer yok (736-749); Blakherna uzak: kutular (_blachernae 641); Kuzey çadırları prism (184).

## RAPOR HAZIR (A tablo, B mimari, C hedef, D göç planı) -> rapor.md  [kare kanıtlı kusur listesi §E koşular bittikçe güncellenir]
- wip/ altında taslaklar: horn_world.gd (kilise/hipodrom/saray/havariyun/bozdoğan/çadır/blakherna), blachernae.gd (shell_parts). Henüz depoya yazılmadı.
- flame.gd'ye Flame.from_glow_boxes EKLENDİ (çağrılmıyor henüz). flame_new.gdshader taslak (tepeden bakış).
- Kare: kare/c11o_* (11 önce) koşuyor.
## 11 ÖNCE kareleri (kare/c11o_*) bulguları
- ring15/ringtop: halka askerlerin ortasında sarı/turuncu KUTU ateşler (siege_field Dressing.glow) -> DOĞRULANDI
- camp50: uzak ordugâh ateşleri turuncu kareler; yandan alevler yatay şerit gibi
- aya/hipp/column: Ayasofya kızıl kutu yığını + mavi küre kubbeler (hagia_merged); Hipodrom düz kutu duvarlar; sütun düz pembe silindir
- apost: Havariyun pembe kutu haç + silindir/küre; yanında kilise kutu+silindir+küre
- aqued: Bozdoğan görünmüyor (toprağa gömülü: zemin 18-22 m, tepe mutlak 20 m)
- blach: Tekfur Sarayı desenli kutu, ölçüler bölümünkinden farklı
- galata: GalataView evleri beyaz kutular (pencereli kutu, çatı mor)
- romanos: surun içi tarla/boş; 7b'deki hub burada yok
- RINFO (11, ÖNCE, ekranlı): camp50 3952 çizim/3.66M, camp15 3981/6.97M, walls 1557/1.70M, city 1053/1.15M, aya 403/0.64M, romanos 3598/5.84M
## Yapılanlar (depoda, koşulmadı henüz)
- flame.gdshader tepeden bakış; Flame.from_glow_boxes World1453.build'de
- World1453: AYA_Y bölge yüksekliği, city_ground pad, far_aya, bake (doku gruplu), FAR_REGIONS + ByzCity.far_hub
- ByzCity: aya_exterior static, column_parts, far_hub; Blachernae.shell_parts; HornWorld kilise/hipodrom/saray/havariyun/bozdoğan/çadır/blakherna; skyline Ayasofya/sütun/kemer; WorldFlight Ayasofya trimesh; flight_check PASS
## SONRA kareleri c11s (ilk) / c11t (hub impostor, blakherna bake, galata Kit evleri)
- ateşler: alev+hale (ring15/ringtop) DÜZELDİ (kare çifti c11o/c11s ring15, ringtop)
- Ayasofya: yerdeki model (aya) ; hub: romanos'ta FarHub ; Havariyun, Bozdoğan (görünür, kemerli), Blakherna (bölümün kabuğu, dokulu), Galata Kit evleri
- RINFO tek kare gürültülü -> hava_shot 5 kare ortanca; p11o (ÖNCE, swap) koşuyor, sonra p11s (SONRA)
- headless RUNOK: 3,4(=,chain,market),6byz,7(=,byz,byzniko,tea,form,wall),8,8y,9,10,11(hepsi 10 varyant),17,17o,18,24,24o,25,26,27,30,31o,32o,39o,43o (son koddan önceki sürümle; son testler sonda tekrar)
- before.sh: swap ile ÖNCE koşusu (sahne kurulunca geri koyar)
- ARAYÜZ GENİŞLEDİ: World1453.bake(..., max_tris := 0) -> bake(..., max_tris := 0, flat := false) (sona isteğe bağlı parametre; eski çağrılar aynı)
## P0 HAZIR (son kodla testler: tests_final.log — 48/48 RUNOK, 0 RUNFAIL; flight_check PASS; parse_check PASS)
- P0.1 FAR_REGIONS + ByzCity.far_hub; P0.2 World1453.bake (+flat); P0.3 Flame.from_glow_boxes + flame.gdshader tepeden; P0.4 aya_exterior/far_aya, column_parts, Blachernae.shell_parts
## BİTTİ (03:05): rapor.md güncel (A–I), vitrin_1.jpg / vitrin_2.jpg, cift/ 46 çift; geçici kare aracı tests/_tmp/hava_* SİLİNDİ
- son koddan sonra yeniden: parse PASS, 7/11/6byz/25/27/30 RUNOK (tam takım tests_final.log 48/48, görünürlük payı ve doku ortalaması düzeltmelerinden önce)
