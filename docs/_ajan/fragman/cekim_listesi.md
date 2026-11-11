# Çekim listesi — son hâl (fragman_tr.mp4, 56,8 sn, 1920×1080, 30 fps, H.264 + AAC)

Set: `gameplay.tscn -- set=story` (tools/trailer/montage.gd STORY_CLIPS, yazısız kayıt; HUD, eller, uçuş göstergesi gizli).
Kurgu: `tools/trailer/story_cut.py` (ASS altyazı + üst yazı, oyunun müzik yolu kayıtta susturuldu; alta tek parça theme.ogg,
replik geldikçe kısılır; -14 LUFS). Ham kayıtlar: kayit/f_A…f_E (1080p), günlükler aynı adla.

## Fragmana girenler (sırayla)
| # | id | bölüm | an | süre | tetik |
|---|----|-------|----|------|-------|
| 1 | kanca_bu_benim | 0 | top patlar, kare donar, Tolga havada: "Evet. Bu benim. Havada olan. Fesli olan." | 3,2 | bot + phase=='freeze' (baştan 0,95 sn yer yazısı söndüğü için kırpıldı) |
| 2 | buro_atisma | 3 Büro | Napolyon: "Rusya'ya kışın girilmez…ayaklarımla yazdım!" → Hitler (köşede, sırtında "REDDEDİLDİ. Lütfen beslemeyin."): "Ben... okumadım." → "Belli." Üst yazı: "Zaman Bürosu, bekleme salonu" | 10,9 | drive steps: ışınlama, fov 46, `bureau._fg_seq`, Hitler konuşunca 0,8 sn dönüş |
| 3 | vlad_kazik | 17 Edirne 1444 | "Prim, teminat, muafiyet." / Vlad: "Kazık." / "Hayır, poliçe." / "Kazık. Beğendim…" | 10,2 | bot edirne_policy + said(D17E_T_POL_2) |
| 4 | otag_sali | 12 otağ | Fatih: "Bu şehir alınacak mı?" / Tolga: "Evet. 29 Mayıs'ta. Salı günü. Sabah. Lisede ezberlettiler." | 11,9 | bot leblebi + pre unbag(book), eller gizli, fov 24 Fatih'e |
| 5 | bogaz_prim | 33o Boğaz | "Yelken indir, beyan et, prim öde. Ağam, siz sigortacılığı icat etmişsiniz." | 5,4 | bot + said(D33O_T_05), eller gizli |
| 6 | hikmet_1977 | 15 (1977) | genç Hikmet: "İleride bir garajım olacak. İçine bir makine yapacağım. Onu da sigortalar mısın?" | 5,7 | bot wrong_stay + said(D15_S7_YH_5) |
| 7 | flight | 7 | Nihat ordugâhın üstünde uçar, görünmez olur; üst yazı "Uç. Görünmez ol." | 5,5 | drive fly; oyun sesi atıldı (pencereye yarıda kalan telsiz repliği taşıyordu), yalnız müzik |
| 8 | card | — | "Gerçek Tarih Bu Değil" · "Tarih böyle değildi. Artık böyle." · 27 final… · Steam'de istek listene ekle | 4,0 | set=story kapanışı |

## Atılanlar ve nedenleri
- garaj_tekme (1): kamera sıçrıyor, kadraj ışık sütunu/bobinlerin içinde, tekme seçilmiyor.
- kizak_sigortaci (2): yakalayan askerler kameranın içinden geçiyor, Tolga konuşurken kadraj boş çayır.
- buro_nasreddin (3): açıdan ters oturduğu anlaşılmıyor. buro_kamera (17): fotoğraf görünmüyor, şaka anlaşılmıyor.
- buro_numara (3, Napolyon–Cengiz): iki açı denendi; tavandaki kara pano kadrajda, Napolyon kafası kesik/dönüp duruyor.
- buro_sokrates (3): seçilen kamera yeri binanın dışı (oyuncu düştü). buro_robot (3, Hitler–stajyer): iki açıda da konuşan robot Nasreddin'in sarığının arkasında.
- kayik_ters (17): kürekçilerin enseleri kaptanı kapatıyor, "ters oturma" görünmüyor.
- havlu_ok (8y): uyarı oku seçilmiyor, botun yolu mantolara sapıyor.
- duel (20): savaş HUD yazıları, figür kameranın içinden geçiyor. cannon (20o): robot gibi ani dönüşler, görev kutusu.
- giust (6, eski kayıttan bakıldı): Giustiniani uzak, elde eşya kadrajı kapatıyor. tunel (10l): madenciler küçük, elde lamba.
