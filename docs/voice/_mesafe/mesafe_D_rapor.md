# Mesafe haritası — Grup D (dilim 7 ve 8)

Kapsam: `ceviri_dilim.py 7` ve `8` çıktısında konuşmacısı dolu **1318** replik (BUR_*, QUEST_*, REACT_*, DST_*, MG_*). Teslim: `docs/voice/_mesafe/mesafe_D.csv` (her satırda `kanit` dolu; `belirsiz` yok). Oyun dosyalarına ve VOICE_MAP.csv'ye dokunulmadı.

## Sınıf sayıları

| sınıf | adet |
|---|---|
| yakin | 977 |
| ic_ses | 191 |
| yakin_yuksek | 139 |
| fisilti | 8 |
| uzak | 3 |

### Aileye göre

| aile | fisilti | ic_ses | uzak | yakin | yakin_yuksek |
|---|---|---|---|---|---|
| QUEST | 0 | 27 | 0 | 0 | 0 |
| BUR | 0 | 94 | 0 | 13 | 1 |
| BUR_FG | 0 | 0 | 0 | 144 | 1 |
| BUR_DOOR | 0 | 61 | 0 | 0 | 0 |
| BUR_AMB | 0 | 0 | 3 | 312 | 75 |
| REACT | 4 | 0 | 0 | 274 | 17 |
| MG | 0 | 4 | 0 | 55 | 16 |
| REACT_CROWD | 0 | 0 | 0 | 21 | 0 |
| DST | 0 | 0 | 0 | 126 | 4 |
| DST_ODD | 0 | 0 | 0 | 24 | 18 |
| DST_WARN | 0 | 0 | 0 | 0 | 7 |
| DST_WHISPER | 4 | 0 | 0 | 0 | 0 |
| DST_T_ | 0 | 5 | 0 | 8 | 0 |

## Kod yolu → sınıf kuralları (kanıt özeti)

- **BUR_AMB (390)**: `bureau.gd` `_AMB`/`_amb_play`/`_amb_say`: figürler birbirine atışır, ses konuşanın ağzından 3B gelir, oyuncu en çok ~6,5 m yakından dinler. Sınıf, konuşan ile karşısındaki figürün `_FG` konumları arası mesafeden çıkarıldı (<4,5 m `yakin`; 4,5-8 m `yakin_yuksek`; ≥8 m `uzak`). Tek konuşmacılı G11 (rehber turu) `yakin_yuksek`, G12 (arkeolog anlatımı) `yakin`.
- **BUR_FG (≈110)**: figüre E ile yaklaşınca konuşur (`_fg_talk`) → `yakin`; rehberin "Grup, buraya!" satırı `yakin_yuksek`.
- **BUR nesne/kapı/ilan/saat (≈190)**: Nihat nesneye bakıp kendi kendine yorum yapar (`_say` → `hud.bark(bark_speaker)`) → `ic_ses`. Memurlar (Cemal, Zeki, Necmi, Sabri, Hatice, Nuran) yanındaki oyuncuya konuşur → `yakin`.
- **REACT_* (≈310)**: eşya elde gösterilir (`player.gd` E, `hud.show_reaction`) → hep yanında, `yakin`. Ünlemli uyarı/emir/tezgâh bağırışı olanlar `yakin_yuksek`; Çandarlı'nın "(Fısıldar)" notlu satırları `fisilti`. REACT_CROWD_* sokak kişisi 4 m içinde (`TALK_R`) → `yakin`.
- **DST_* sokak sözleri**: IDLE/FEZ/AGAIN/CONQ/NIGHT/GAL = E ile sohbet (`street_talk`) → `yakin`. `DST_ODD_*` tepki sözü: yarıçap 6-14 m olabildiği için ünlemli olanlar `yakin_yuksek` (hud.gd `_say_staging` da ünlemi bağırış sayar), diğerleri `yakin`. `DST_WARN_*` nöbetçi uyarısı (8-18 m) `yakin_yuksek`. `DST_WHISPER_*` komşuya fısıltı (<2,4 m) `fisilti`. `DST_T_ODD_*` Tolga'nın kendi kendine lafı `ic_ses`.
- **MG_***: mini oyun masasında karşılıklı konuşma → `yakin`; ünlemli/emirli/öfkeli satırlar `yakin_yuksek`; oyun sonrası Tolga yorumları `ic_ses`; `MG_ARC_H_AFTER_*` Hasan yanında `yakin`.
- **QUEST_*_DONE**: görev bitince Tolga'nın kendi yorumu (`hud.quest_update`) → `ic_ses`.

## `ton` sütunuyla çelişenler

**1. `[shouting]` etiketli ama sahnede yakın ve normal sesle (12):** etiket "yüksek ses" demek, mesafe değil; bu satırlar yanındakine söylendiği için bağırma gerekmez ya da heyecanlı-yüksek yeterli.

- `REACT_LUTFI_THERMOS` (SPK_LUTFI, yakin): "'Termos'... Rumca 'sıcak' demek! Sonunda bildiğim bir kelime!" — eşya elde gösterilir (Player E, player.gd:2404), yanında normal konuşma
- `REACT_NIKO_PHONE` (SPK_NIKO, yakin): "Küçük ayna ama içinde adam var! Hey adam! Annen de mi ayna?" — eşya elde gösterilir (Player E, player.gd:2404), yanında normal konuşma
- `REACT_NIKO_CHICKPEAS` (SPK_NIKO, yakin): "Nohut! Kavrulmuş! Kırk gündür kuru ekmek yiyorum. Sen... sen iyi casu — eşya elde gösterilir (Player E, player.gd:2404), yanında normal konuşma
- `REACT_DERVISH_TAPE` (SPK_DERVISH, yakin): (Bant rulosu kendi etrafında döner) Bak! O da dönüyor! Kardeşim. — eşya elde gösterilir (Player E, player.gd:2404), yanında normal konuşma
- `REACT_CAMELEER_COLOGNE` (SPK_CAMELEER, yakin): (Koklar) Deve kokusu gitti! Üç gündür gitmiyordu! Bu ne büyü! — eşya elde gösterilir (Player E, player.gd:2404), yanında normal konuşma
- `REACT_KID_LIGHTER` (SPK_KID, yakin): Ateş! Ben de istiyorum! ...Annem istemez. Annem hiçbir şey istemez. — eşya elde gösterilir (Player E, player.gd:2404), yanında normal konuşma
- `REACT_KID_TAPE` (SPK_KID, yakin): Bununla uçurtma yaparım! Kuyruğu olur! ...Uçurtman yok mu? O zaman ban — eşya elde gösterilir (Player E, player.gd:2404), yanında normal konuşma
- `REACT_KID_SELFIE` (SPK_KID, yakin): Beni de çek! Gato'yu da! Gato nerede? Önce Gato'yu bul! — eşya elde gösterilir (Player E, player.gd:2404), yanında normal konuşma
- `REACT_KID_COLOGNE` (SPK_KID, yakin): Limon! Annemin kokusu! ...Annem limon satıyor. — eşya elde gösterilir (Player E, player.gd:2404), yanında normal konuşma
- `REACT_KID_CUBE` (SPK_KID, yakin): Renkli küp! Çevireyim! ...Bozdum. Babama söyleme, babam da bozar. — eşya elde gösterilir (Player E, player.gd:2404), yanında normal konuşma
- `REACT_URBAN_REPLAY_1` (SPK_URBAN, yakin): Bunu bana daha önce gösterdin! Top da daha önce patladı mı? Söyleme! S — karakter eşya gösterilirken yanında
- `DST_CHILDB_AGAIN_1` (SPK_CHILD_BYZ, yakin): Yine geldin! Saklambaç mı oynuyoruz? Sen ebesin! — oyuncu E ile konuşur (street_talk), TALK_R 4 m

**2. `[whispers]` etiketli ama fısıltı sınıfında olmayan: 0.**

**3. Etiketsiz ya da farklı etiketli ama `uzak` çıkan (3):** `BUR_AMB_G13_6_1`, `BUR_AMB_G13_6_2`, `BUR_AMB_G13_6_3`. Bu üçü Büro'da Einstein ile Tesla/Edison arasındaki salon karşısı atışması (11-13 m).

**4. `[hesitant]` etiketli ama `fisilti` çıkan:** `DST_WHISPER_B_1` (Çandarlı'nın "(Fısıldar)" notu).

**5. Etiketsiz ama `yakin_yuksek` çıkan (101):** `ton` boş fakat ünlem/emir/öfke/uzaktan tepki içerdiği için yüksek sesle okunmalı:

`BUR_TROLLEY_2`, `BUR_FG_GUI_1`, `BUR_AMB_G9_1_1`, `BUR_AMB_G9_1_2`, `BUR_AMB_G9_1_3`, `BUR_AMB_G9_2_1`, `BUR_AMB_G9_2_2`, `BUR_AMB_G10_1_1`, `BUR_AMB_G10_1_2`, `BUR_AMB_G10_1_3`, `BUR_AMB_G10_2_1`, `BUR_AMB_G10_2_2`, `BUR_AMB_G10_2_3`, `BUR_AMB_G10_2_4`, `BUR_AMB_G11_1_1`, `BUR_AMB_G11_1_2`, `BUR_AMB_G11_2_1`, `BUR_AMB_G11_2_2`, `BUR_AMB_G9_3_1`, `BUR_AMB_G9_3_2`, `BUR_AMB_G9_3_3`, `BUR_AMB_G9_4_1`, `BUR_AMB_G9_4_2`, `BUR_AMB_G9_4_3`, `BUR_AMB_G9_5_1`, `BUR_AMB_G9_5_2`, `BUR_AMB_G9_5_3`, `BUR_AMB_G9_6_1`, `BUR_AMB_G9_6_2`, `BUR_AMB_G9_6_3`, `BUR_AMB_G9_7_1`, `BUR_AMB_G9_7_2`, `BUR_AMB_G9_7_3`, `BUR_AMB_G9_8_1`, `BUR_AMB_G9_8_2`, `BUR_AMB_G9_8_3`, `BUR_AMB_G10_3_1`, `BUR_AMB_G10_3_2`, `BUR_AMB_G10_3_3`, `BUR_AMB_G10_4_1`, `BUR_AMB_G10_4_2`, `BUR_AMB_G10_4_3`, `BUR_AMB_G10_5_1`, `BUR_AMB_G10_5_2`, `BUR_AMB_G10_5_3`, `BUR_AMB_G10_6_1`, `BUR_AMB_G10_6_2`, `BUR_AMB_G10_6_3`, `BUR_AMB_G10_7_1`, `BUR_AMB_G10_7_2`, `BUR_AMB_G10_7_3`, `BUR_AMB_G10_7_4`, `BUR_AMB_G10_8_1`, `BUR_AMB_G10_8_2`, `BUR_AMB_G10_8_3`, `BUR_AMB_G11_3_1`, `BUR_AMB_G11_3_2`, `BUR_AMB_G11_4_1`, `BUR_AMB_G11_4_2`, `BUR_AMB_G11_5_1`, `BUR_AMB_G11_5_2`, `BUR_AMB_G11_6_1`, `BUR_AMB_G11_6_2`, `BUR_AMB_G11_7_1`, `BUR_AMB_G11_7_2`, `BUR_AMB_G11_8_1`, `BUR_AMB_G11_8_2`, `BUR_AMB_G15_2_2`, `BUR_AMB_G15_2_3`, `BUR_AMB_G15_4_2`, `BUR_AMB_G15_4_3`, `BUR_AMB_G15_7_1`, `BUR_AMB_G15_7_2`, `BUR_AMB_G15_7_3`, `REACT_GUARDS_LIGHTER`, `REACT_URBAN_LIGHTER`, `REACT_MINER_LIGHTER`, `REACT_WINE_LIGHTER`, `MG_CAUL_K_BAD`, `MG_CAUL_K_PICK`, `MG_ARC_H_APPLE`, `DST_ODD_JUMP_B_2`, `DST_ODD_JUMP_O_2`, `DST_ODD_BUMP_B_1`, `DST_ODD_PHONE_B_1`, `DST_ODD_PHONE_O_1`, `DST_ODD_SELFIE_B_2`, `DST_ODD_SPIN_O_1`, `DST_ODD_SPIN_O_2`, `DST_ODD_SWORD_B_1`, `DST_ODD_COLOGNE_O_1`, `DST_ODD_LIGHTER_B_1`, `DST_ODD_CHICK_B_1`, `DST_WARN_B_1`, `DST_WARN_B_2`, `DST_WARN_B_3`, `DST_WARN_O_1`, `DST_WARN_O_2`, `DST_WARN_O_3`, `DST_WARN_G_1`, `DST_CHILD_COPY_2`

## Belirsizler

`belirsiz` satır yok (1.318 replikte `kanit` dolu). Dürüst notlar:

- `DST_ODD_*`/`DST_WARN_*`: konuşanın oyuncuya gerçek uzaklığı sahneye ve kişiye bağlı (yarıçap 6-14 m, uyarıda 8-18 m); sınıf yarıçap ve ünleme göre verildi, `metre` aralığı tahmindir. 8 m üstü olursa `uzak` okuması gerekir.
- `BUR_AMB_G13_6_2` ve `_6_3`: kod karşıyı sıradaki konuşan (Edison, 1,7 m) sayıyor; içerik Einstein'a yanıt olduğu için `uzak` verildi.
- Aynı anahtar birden çok yerde kullanılmıyor; çoklu kullanım bulunmadı.
- `BUR_*` nesne yorumları Nihat dışında biri (Bölüm 13/17) Büro'dayken sessiz kalıyor (bureau.gd başlık notu); sınıf yine `ic_ses`.
