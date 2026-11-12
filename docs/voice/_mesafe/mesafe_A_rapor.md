# Mesafe haritası — Grup A (dilim 1, 2, 3) raporu

Toplam sınıflanan replik: **1652** (konuşmacısı dolu satırlar; arayüz metni atlandı). `kanit` boş satır: 0.

## Sınıf sayıları

| sınıf | adet |
|---|---|
| yakin | 1026 |
| ic_ses | 326 |
| telsiz | 130 |
| yakin_yuksek | 99 |
| uzak | 47 |
| fisilti | 20 |
| belirsiz | 4 |

## Yöntem ve güven düzeyi (dürüst not)

- Her anahtarın betikteki yeri `grep` ile bulundu; kanıt sütunundaki `dosya:satır` o anahtarın ilk (ipucu tekrarı olmayan, `, 30.0)` içermeyen) kullanım satırıdır.
- Sınıf, o sahnenin betiği (bölüm başlık yorumları, `afar` işaretleri, `bark`/`say`, sahne konumları, replik metnindeki "(Telsiz)", "(Fısıltıyla)", "(Uzaktan)", "(Surun üstünden)" gibi notlar) okunarak **sahne/konuşmacı grubu bazında** verildi; her tek repliğin çevresi tek tek satır satır okunmadı. Aynı sahnedeki aynı tür replikler (ör. D6 eşya tepkileri, D9 teklif konuşmaları, D10x yüz yüze diyaloglar) topluca `yakin` alındı. Bu gruplarda tek tek sapma olma ihtimali var; aşağıda "düşük güven" olarak işaretli.
- `D6_<NPC>_<EŞYA>`, `D4B_NIKO_*`, `D3_N_LOOK_*` gibi koddan biçimle kurulan anahtarlarda kanıt, anahtarı kuran satırdır (`[fmt]` notu). `line_variant` varyantlarında (`_NOFEZ`, `_HUFEZ`, `_H1453`…) taban anahtarın satırı kullanıldı (`[dolaylı]` notu).
- `ton` sütunu `[shouting]` olup sınıfı `yakin` çıkan satırlar `yakin_yuksek` yapıldı (yanındakine sesini yükseltiyor); bu otomatik kuraldır, notunda yazar.
- Hiç dokunulmayan: oyun dosyaları, `VOICE_MAP.csv`, ses üretimi.

## Sahne notları (sınıfı belirleyen betik bulguları)

- **Bölüm 3, 7, 11 (Nihat oynanır) ve Bölüm 5, 8 (Hikmet oynanır):** oyuncunun kendi repliklerinin çoğu rapor/not/iç konuşmadır → `ic_ses`. Burada `ic_ses` "Tolga'nın iç sesi" tanımının Nihat/Hikmet'e genişletilmiş halidir; motor tarafında alçak, kendi kendine okuma anlamına gelir.
- **Surdan/gemiden seslenmeler (`uzak`):** D4B_N_01/02/03/THROW_* (Niko sur tepesinden), D8Y_WALL_* (gözcü, `afar`), D8Y_HASAN/HUSEYIN_WARN/STOP/COME (siperden ölü bölgeye), D10H_N_K* (Niko surun üstünden), D10G_C_MISSED/T_MISSED (kalkan gemi), D10B_KADRI_B3 (mutfaktan), D7_T_FAR_* (Tolga ordugâhta uzaktan), D5_V_* ve D8_V_01 (minibüs hoparlörü), D11_H_01 (karanlıktan), D2_S_ROPE/LOG/BLOCK/06 (kızak kovalamacası), D6B_N_CALL/NK_ROOF, D10L_N_DIG_* (toprağın üstünden).
- **`telsiz`:** Hikmet'in 1453'teki tüm replikleri (D2, D4A/B_H_02, D6_H_*, D9_H_*, D10x_H_RADIO*, D11 hariç yüz yüze olduğu yerler), Müfide'nin "(Büro telsizi)/(Hoparlörden)" satırları, D3 telsiz sahnesi, D5 telefon/telsiz.

## `ton` sütunuyla çelişenler

### `[shouting]` ama `yakin`/`ic_ses`/`telsiz` (ses yüksek, mesafe kısa ya da kimseye seslenmiyor)

| anahtar | sınıf | ton | metin |
|---|---|---|---|
| D2_H_04 | telsiz | [shouting] | Gemi mi? Yokuşta mı? Evlât, 22 Nisan'dasın! Gemiler karadan yürütülüyo |
| D2_H_WARRANTY | telsiz | [shouting] | Garanti bitiyor! Dönmek istersen düğmeyi basılı tut, şimdi! |
| D2_T_08 | telsiz | [shouting] | Su! Soğuk! Nisan'da Haliç soğukmuş! |
| D2_T_18 | telsiz | [shouting] | Zincir! Tuttum! ...Şimdi ne? |
| D2_T_22 | ic_ses | [shouting] | Kaydım. Zincir de mi yağlı?! |
| D5_H_02 | ic_ses | [shouting] | Tavanda projektör. Bir de periskop. Periskop! Karada! |
| D5_H_FOUND_TIN | ic_ses | [shouting] | Kurabiye kutusu... dur. Dikiş setinin altında! Yedek Telsiz-Kumanda! |
| D5_H_FOUND_CALENDAR | ic_ses | [shouting] | Takvimin arkasında, davetiyenin içinde! Yedek Telsiz-Kumanda! |
| D5_H_FOUND_TV | ic_ses | [shouting] | Televizyonun içinde, Dünya Kupası'nın arkasında! Yedek Telsiz-Kumanda! |
| D5_H_FOUND_SLIPPER | ic_ses | [shouting] | Terliğin içinde! Terlik bu sefer sadece terlik değilmiş! |
| D6_T_ANSWER | telsiz | [shouting] | Hikmet Amca! Buradayım! Sabah oldu. Otağa gidiyorum. |
| D6B_T_ANSWER | telsiz | [shouting] | Hikmet Amca! Buradayım! Sabah oldu. Surların içindeyim. |
| D6B_T_PECK | ic_ses | [shouting] | ...(Sinerji mektubu gagalamaya çalışıyor.) Hayır. Hayır! Bu bir impara |
| D2_T_SWIM_NOAIR | ic_ses | [shouting] | Nefesim yok! Önce nefes, sonra dalış! |
| D2_H_SWIM_BOAT | telsiz | [shouting] | (Telsiz) Kayık geliyor! Yaklaşınca dal, evlât, dal! |
| D2_H_SWIM_BOAT_2 | telsiz | [shouting] | (Telsiz) Binme evlât, o devriye! Altından dal, görmesinler! |
| D3_T_RADIO_3 | telsiz | [shouting] | (Cızırtı) Büro mu?! Hikmet Amca, sigortam bunu kapsıyor mu?! Alo? ...A |
| D9_T_HERE | telsiz | [shouting] | ...Hikmet Amca BURADA mı?! Pijamayla mı?! |
| D10B_T_B2_1 | ic_ses | [shouting] | (Top gürler. Gülle... yirmi metre ötedeki çayıra düşer. Bir keçi meler |
| D10B_H_B3_AIR | telsiz | [shouting] | (Telsiz) Ne sesiydi o?! Evlât?! |
| D10Z_H_FIRE | telsiz | [shouting] | (Telsiz) Evlât! Paradoks göstergem kırmızıya döndü! Ne yaptın?! |
| D10G_H_RADIO | telsiz | [shouting] | (Telsiz) Üç ay mı?! Evlât, senin garantin çoktan bitti. Dayan, pencere |
| D10L_T_TRUCE | ic_ses | [shouting] | (Mum ışığında ekmek, peynir, zeytin. Kimse konuşmaz. Yukarıda toplar g |
| D10G_H_RADIO_H1453 | telsiz | [shouting] | (Telsiz) Üç ay mı?! Evlât, senin garantin çoktan bitti. Dayan, Urban'ı |

(toplam 24; `telsiz` olanlar: telsizde heyecanlansa da bağırmaz kuralı gereği, `ic_ses` olanlar: yanında dinleyen yok.)

### `[shouting]` etiketsiz ama `uzak` (surdan/ötesinden seslenen, etiket eksik)

| anahtar | konuşmacı | metin |
|---|---|---|
| D2_S_ROPE | SPK_SOLDIER | Halat geliyor! |
| D4B_N_03 | SPK_NIKO | Gel bakalım, fesli. Surun dibi benim. Tavuğum da benim. |
| D4B_N_03_NOFEZ | SPK_NIKO | Gel bakalım, yabancı. Surun dibi benim. Tavuğum da benim. |
| D4B_N_THROW_CHICKEN_1 | SPK_NIKO | Tavuk geliyor! |
| D4B_N_THROW_CHICKEN_4 | SPK_NIKO | Son tavuk! ...Tavuk? Tavuk nereye gidiyorsun? |
| D4B_T_HIT_2 | SPK_TOLGA | İnciri de mi? İnciri de mi! |
| D5_V_1 | SPK_VAN | Dikkat! Garajda zaman dışı hareket tespit edildi. |
| D5_V_2 | SPK_VAN | ...Pijamalı bir hareket. |
| D5_V_3 | SPK_VAN | Lütfen ışıkta durmayın. Form Z-11: Işıkta durma yasağı. |
| D5_V_4 | SPK_VAN | Kapıyı çalacağız. Çalıyoruz. Çaldık. |
| D7_T_FAR_B | SPK_TOLGA | (Uzaktan) Lütfi, 'poliçe' Frenkçe nasıl denir? ...Sen de mi bilmiyorsu |
| D7_T_FAR_Y | SPK_TOLGA | (Uzaktan) Kasko, konut, keçi. Paket halinde daha uygun! |
| D8_V_01 | SPK_VAN | (Minibüsün hoparlörü) Günaydın, vatandaş. Rutin bir alışveriş, değil m |
| D8Y_WALL_1 | SPK_LOOKOUT | Yayları indirin! Bayrak var. ...Havlu ama bayrak. |
| D8Y_WALL_2 | SPK_LOOKOUT | Hey, Latin! Karşıda kahvaltı varsa bize de getir! |
| D8Y_WALL_WARN_1 | SPK_LOOKOUT | Havlu yukarı! Bir dahaki ok uyarı olmaz! |
| D8Y_WALL_WARN_2 | SPK_LOOKOUT | Yavaşla, Latin! Bizim okçular hızlı hedefi sever! |
| D8Y_HASAN_WARN_1 | SPK_HASAN | Bayrağı kaldır! Biz de görmek istiyoruz! |
| D8Y_HUSEYIN_WARN_2 | SPK_HUSEYIN | Yavaş gel! Teslim olmaya kimse koşmaz! |
| D8Y_T_WARN_1 | SPK_TOLGA | Tamam! Yukarıda! Bakın, yukarıda! |
| D8Y_HASAN_STOP | SPK_HASAN | Dur orada! Olduğun yerde salla şu bezi! |
| D8Y_HUSEYIN_COME | SPK_HUSEYIN | Tamam, gördük. Gel. Yavaş gel. |
| D11_H_01 | SPK_HIKMET | (Karanlıktan, pijamalı) DUR BAKALIM! O benim evlâdım! ...Sen? Büro'nun |
| D10H_N_K | SPK_NIKO | (Surun üstünden) Frenk! Gedik neden parlıyor? ...Yapışkan bez mi o? Ur |
| D10L_N_DIG_1 | SPK_NIHAT | (Yukarıdan, kazma sesi. Bir ışık.) Bay Tolga. Toprak altında kalma for |
| D10L_N_DIG_2 | SPK_NIHAT | (İç çeker, kazmaya devam eder) Madde 9/k: 'Kalemsiz şüpheli sözlü beya |
| D10H_N_K_ALT | SPK_NIKO | (Surun üstünden) Frenk! Gedik neden parlıyor? ...Yapışkan bez mi o? Su |

(toplam 27)

### Etiketsiz ama `yakin_yuksek` (sesini yükseltmeli, etiket eksik)

| anahtar | metin |
|---|---|
| D1_H_30 | Padişah'a benden selam söyle! Bir de sor bakalım, o toplar kaç volt? |
| D2_T_15 | Ben casus değilim, sigortacıyım! |
| D2_S_16 | Sigortacı ne? |
| D2_R_21 | Önüne baksana be adam! |
| D2_S_23 | Islak bir Frenk casusu! |
| D2_T_FALL | Yokuş bitiyor... Yokuş bitti! |
| D2_T_FALL_SCREAM | AAAAAAAA! |
| D1_H_KICK_WEAK | Bu tekme mi? Komşunun kapısını çalıyorsun sanki. Bir daha! |
| D4A_HA_STOP_NOFEZ | Dur! Nereye deli? |
| D4B_T_HIT_1 | Ay! |
| D5_V_KNOCK | (Kapı vurulur) Zaman Bürosu, rutin kontrol! ...Pardon. Yanlış garaj. İ |
| D4B_N_ECLIPSE_1 | Bak! Yukarı bak! Ay kararıyor! Eski kehaneti bilmez misin? Şehir, ay b |
| D3_H_RESIST | O tavuk bizim değil! ...O ok da bizim değil. Ben hiçbir şeyi tanımıyor |
| D3_H_SAW_FLY_2 | Önce siz uçmayı anlatın, sonra ben makineyi anlatırım. ...Neyse, sorun |
| D7_T_CELL | (İçeriden) Niko, yine mi form? 'Fes rengi: kırmızımsı.' Ezberledim art |
| D9_THEO_1 | [Yunanca] Bekleyin! Beyaz bayrak! Form! Çıkış Formu Ζ-12'niz eksik! Su |
| D9_THEO_3 | [Yunanca] Tabii. Form eksikse savaş da eksiktir. (İmzanızı alır, yedi  |
| D8_C_TEA_OFFER | Beyler! Bu saatte fener yakılmaz, çay demlenir. Tezgâha buyurun, taze  |
| D7_T_CELL_NOFEZ | (İçeriden) Niko, yine mi form? 'Şapka: yok.' Ezberledim artık. |
| D7_T_CELL_FIRST | (İçeriden) Niko, bu form ne? 'Fes rengi: kırmızımsı.' Bir zindanda ilk |
| D7_T_CELL_FIRST_NOFEZ | (İçeriden) Niko, bu form ne? 'Şapka: yok.' Bir zindanda ilk kez form d |
| D8Y_NIKO_GATE | Aç kapıyı! Bir kişi çıkıyor. Hayır, geri gelmiyor. |
| D8Y_GUARD_GATE | Havluyla mı? Bu kapı havluya açılmaz. |
| D8Y_NIKO_GATE2 | Havlu değil, bayrak. İmparatorluk havlusu. Aç şunu. |
| D8Y_HASAN_1 | Dur! Kimsin sen, ne sallıyorsun? |
| D11_H_03 | İhlal mi? Garanti belgesi var bende! 'İlk on dakika koşulsuz iade.' İm |
| D11_H_05 | Senin Z-1'inin arkasına bir devre şeması çizerim, anlamazsın bile. |
| D11_H_07 | Yönetmelik 3/a'yı kim yazdı? Ben yazmadım! (Kendi formunu çıkarır: bir |
| D10B_U_CAST_SPILL | Taştı! Az kalsın ayağım... (Macarca uzun ve renkli bir cümle) |
| D10B_U_NAME_4 | KÜP OLMAZ DEDİM! ...(Derin nefes) Tamam. Küp. Ama kimseye söyleme. |
| D10B_U_EARS | KULAKLARI TIKAYIN! |
| D10B_RIDER | Sultanım! Galata'dan haber var! Gülle bir Ceneviz tüccarının şarap fıç |
| D10Z_K_TASTE_BURNT | Yandı! Kokusunu ordugâhın öbür ucundan alırlar. Bir tane daha yakarsan |
| D10Z_BOTH | (Kadri ile Tolga aynı anda) BEN. |
| D10L_D_WARN | Tavan! İki kazma oldu, destek yok. Bir daha kazarsan toprak seni kazar |
| D11_NK_00 | (Yamuk sarılmış bir sarık; altından kızıl bir Bizans pelerini görünüyo |

(toplam 36)

### `[whispers]` ama `fisilti` dışı / `fisilti` ama etiketsiz

- D3_N_EAVES → fisilti (ton: ``) — Kurutma makinesi. Not ettim.
- D7_N_EAVES → fisilti (ton: ``) — Görünmezken dinlemek. Yönetmelik bunu yasaklamıyor. Çünkü kimse düşünm
- D10H_L_FIXED_1 → fisilti (ton: ``) — (Tolga'ya, dişlerinin arasından) Ortak. Ben de tam onu diyecektim. Dah
- D10H_K_SHAME → yakin (ton: `[whispers]`) — (Theodoros'un fısıltılarını dinler, yüzü sertleşir) Bu heyet benimle a
- D10L_T_RETREAT → fisilti (ton: ``) — (Geri geri yürür) Biz... hiç gelmedik. Siz de bizi hiç görmediniz.

## Belirsizler

- `D2_H_AFTER_WARRANTY` (SPK_HIKMET): belirsiz: kodda anahtar hiçbir yerde geçmiyor (ölü anahtar, kullanımdan kalkmış olabilir)
- `D2_T_25` (SPK_TOLGA): belirsiz: kodda anahtar hiçbir yerde geçmiyor (ölü anahtar, kullanımdan kalkmış olabilir)
- `D2_T_FEZ_FOUND` (SPK_TOLGA): belirsiz: kodda anahtar hiçbir yerde geçmiyor (ölü anahtar, kullanımdan kalkmış olabilir)
- `D3_N_KIT_TRY` (SPK_NIHAT): belirsiz: kodda anahtar hiçbir yerde geçmiyor (ölü anahtar, kullanımdan kalkmış olabilir)

## Dolaylı kanıtlı satırlar

499 anahtarın betikte doğrudan değil biçim/varyant yoluyla kullanıldığı görüldü (notlarında yazar).

## Düşük güvenli gruplar (özellikle gözden geçirilmeli)

- D6 `*_PHONE/LIGHTER/BOOK…` eşya tepkileri ve D9 teklif/deneme konuşmaları: `yakin` toplu verildi; konuşanın oyuncuya mesafesi her satırda doğrulanmadı.
- D10A/B/G/H/L/Z ve D11'in yüz yüze diyalogları: ilgili bölümlerin akış yapısından `yakin`; D10H İmparator satırları 5 m kabul edildi (heyet salonu, tercüme).
- D7'de Nihat'ın yalnız rapor/tarama replikleri `ic_ses`; bunlar hologram/tarayıcı anlatısıdır, kimseye seslenmez.
- `yakin_yuksek` ile `yakin` ayrımı (savaş/top gürültüsü ya da öfke/panik) metinden ve sahneden çıkarıldı; sınır satırlarda öznel.
