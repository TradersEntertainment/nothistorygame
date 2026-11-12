# Mesafe haritası — Grup B (dilim 4 ve 5)

Kapsam: `ceviri_dilim.py 4` ve `5` içinden konuşmacısı dolu **1642** replik (6'sı konuşmacı alanında `?`: D18_N_01, D18_N_01_CAPTIVE, D18_HA_01, D18_HA_01_NOFEZ — konuşmacı betikten NIHAT/HASAN olarak yazıldı —, D17E_CAP_GLITCH, D17E_CAP_BACK — ekran altyazısı, `?` kaldı).
Teslim: `docs/voice/_mesafe/mesafe_B.csv` (anahtar, konusmaci, mesafe, metre, kanit, not). Oyun dosyalarına ve VOICE_MAP.csv'ye dokunulmadı; ses üretilmedi.

## Yöntem
Her anahtar için betikte (`scripts/**/*.gd`) geçtiği yer bulundu, çevresindeki sahne kurgusu (konuşanın konumu, `hud.say`/`hud.bark`, `afar`/`cameo` işareti, telsiz/hoparlör, savaş/top/kalabalık gürültüsü, kime seslendiği) okunarak sahne/konuşan bazında sınıflandı. Ünlem/ton ipuçları yalnızca aynı sahne içinde alt-ayrım için kullanıldı (ör. savaş sahnesinde ünlemli emir `yakin_yuksek`, sakin cümle `yakin`). `kanit` sütunu `dosya:satır` + kısa gerekçedir; **362** satırda anahtar dinamik üretildiği için (`"D12_F_ITEM_" + id`, `"D15_S_" + …`, `%d` ekleri, `_key("h_"+k)` gibi) kanıt satırı üretim noktasıdır ve `(dolaylı)` ya da gerekçe metninde belirtilmiştir. `_NOFEZ`, `_DUSK`, `_CAPTIVE`, `_WARNED…` gibi varyantlar taban anahtarın sahnesini izler.

## Sınıf sayıları
| mesafe | adet |
|---|---|
| yakin | 964 |
| ic_ses | 315 |
| yakin_yuksek | 257 |
| uzak | 46 |
| telsiz | 31 |
| fisilti | 24 |
| belirsiz | 5 |

Ağırlık dağılımı: `yakin` normal/varsayılan; `ic_ses` içinde hud.bark ile Tolga'nın kendi kendine yorumları, ayar menüsü şakaları (`DSET_T_*`, 100'e yakın), tırmanma/taşıma/tavuk/uçuş barkları ve parantezli betimleme/hud.think satırları var.

## Dikkat edilecek kararlar (belirsizlik/sınır)
- **Bölüm 23 tercüme salonu (`D23_K_*`, `D23_I_*`, `D23_T_<n>_*`)**: `chapter23.gd:95` İmparator'u bilerek `afar` (tahtla heyet arası 8 m) yapıyor. Tam eşikte olduğu için `yakin_yuksek` (salon boyunca taşan resmî ses, bağırmaz), metre 8.
- **`D_WIT_*` (uçan Nihat'a tanık tepkileri)**: tanık oyuncuya 32 m'ye kadar uzakta olabilir (`nihat_powers.gd:20`). Ünlemli satırlar `uzak` (15–25 m, göğe bakıp bağırır), ünlemsiz yorumlar yanındakine `yakin_yuksek`.
- **`D42B_H_*` talim barkları** (`combat/drill.gd`): düello sürerken öğretmen halka kenarından (5–9 m) seslenir → `yakin_yuksek`; ders anlatımı (`_say_h`) oyuncunun 2,2 m yanına gelerek yapılır → `yakin`.
- **`D_ARENA_N_B/O`**: arenada Nihat sahnede görünmüyor, yalnız bark var; `telsiz` varsayımı (sahneden kanıt dolaylı).
- **`D26_*ALARM*`**: Büro sahnesi ekranda, Tolga'nın sesi surdan; Nihat/Saniye Tolga'ya telsiz/hoparlörle sesleniyor → `telsiz` (Nihat metinde `[shouting while running]` ama telsizden).
- **`D19_P_*`, `D19_T_(SALAM|INSURE|TEZKIRE)`, `D19_C_BROKEN`**: devriye kayığı borda borda yanaşmıyor (`chapter19.gd:202` `afar`) → `uzak`, metre 12–15.
- **`D25_[HZF]_*` meclis**: Tolga çadır bezi ardından dinliyor; konuşanların muhatabı meclis olduğu için `yakin`.
- **`D17E_*` Edirne**: Büro asansörü kabininde (Nihat/Tolga) `yakin`, sarayda `yakin`; `[shouting]` etiketli ama muhatap yanında olan satırlar `yakin` kaldı (aşağıda çelişki listesinde).

## `ton` sütunuyla çelişenler
### 1) `[shouting]/[screaming]` ama `yakin`/`ic_ses`/`telsiz`/`fisilti` (14)
Telsizde bağıran (`D13_H_PRESS`, `D13_T_PRESSED`, `D17E_N_PULL`, `D15_Y_H_RADIO_CALL_DRIFT`, `D15_Y_H_HOLD`, `D26_N_ALARM_*`) mikrofona yakın normal ses olarak işaretlendi (cızırtıyı oyun ekler; sınıf tanımı gereği). Diğerleri:
- `D12_T_SEE_HIKMET` (TOLGA, ton `[shouting]`, mesafe **yakin**): Hikmet Amca?! Pijamayla... Sultan'ın otağında?
- `D13_H_PRESS` (HIKMET, ton `[shouting]`, mesafe **telsiz**): (Telsiz) EVLÂT! BAS! Kırmızı düğme! Basılı tut!
- `D13_T_PRESSED` (TOLGA, ton `[shouting]`, mesafe **telsiz**): Basıyorum! Basıyorum! Sigortacı olarak söylüyorum: bu hiç güvenli değil!
- `D17_TR_NOISE` (TREVISANO, ton `[shouting]`, mesafe **fisilti**): Sessiz! Bütün Haliç duydu!
- `D17_T_PULL_2` (TOLGA, ton `[shouting]`, mesafe **ic_ses**): Gel, gel. Kasko değil ama gel.
- `D15_Y_H_RADIO_CALL_DRIFT` (HIKMET, ton `[shouting]`, mesafe **telsiz**): (Telsiz, cızırtılı ama anlaşılır) EVLÂT! Frekans kayıyor ama bir pencere açıldı!
- `D15_Y_H_HOLD` (HIKMET, ton `[shouting]`, mesafe **telsiz**): (Telsiz) Tutuyorum! Bas evlât, bas! Kırk dokuz yıl ağır!
- `D17E_H_DIVAN` (HALIL, ton `[shouting]`, mesafe **yakin**): Sultanım! Divan toplandı, sizi bekliyor!
- `D17E_R_KEB_2` (RADU, ton `[shouting]`, mesafe **yakin**): Abim gülümsedi! Abim hiç gülümsemez!
- `D17E_N_PULL` (NIHAT, ton `[shouting]`, mesafe **telsiz**): (telsiz) Tolga Bey! Sinyaliniz 1444'ten geliyor! Tutunun, çekiyorum!
- `D17E_CAP_BACK` (?, ton `[shouting]`, mesafe **ic_ses**): Nihat (telsiz): Çekiyorum! Bir daha kalibrasyon yok!
- `D17E_T_WHAT_NONE` (TOLGA, ton `[shouting]`, mesafe **yakin**): Hiçbir şey! Karışmadım! Sadece biraz ıslandım.
- `D17E_R_KEB_BACK` (RADU, ton `[shouting]`, mesafe **yakin**): Aşçıbaşı kuzuyu verdi! Bir de soğan! Ağladım ama getirdim!
- `D17E_R_LEG_0` (RADU, ton `[shouting]`, mesafe **yakin**): Abi! Duvarda yarasa var!

### 2) Etiketsiz/sakin ama `uzak`/`yakin_yuksek` (ünlemsiz) (5 uzak, 54 yakin_yuksek)
`uzak`, etiketsiz olanlar: surdan/kayıktan seslenen sakin cümleler — ses yönetmeni bunları gerçek bağırma olarak okutmalı:
- `D_GAL_NOTARY` (NOTARY, ton `—`, mesafe **uzak**): Kuleye çıkmak için noter onayı gerekir! ...Tepeye kadar çıkmışsın. Onaylıyorum. 
- `D19_P_SALAM` (PATROL, ton `—`, mesafe **uzak**): Gelibolu mu? Hayırlı yolculuklar. Rüzgâr arkanızda olsun.
- `D19_T_INSURE` (TOLGA, ton `—`, mesafe **uzak**): Sigortacıyız reis. Hasar tespitine gidiyoruz. Kaskonuz var mı bu arada?
- `D19_P_INSURE` (PATROL, ton `—`, mesafe **uzak**): Kasko? ...Deli bu. Geçin, geçin. Allah akıl fikir versin.
- `D19_P_BROKEN` (PATROL, ton `—`, mesafe **uzak**): Çok Türk müsünüz? ...Hıh. Gece balığı. Geçin bakalım, ama sabah sizi arayan olur
- `D19_T_TEZKIRE` (TOLGA, ton `—`, mesafe **uzak**): Reis, fenerini şuraya tut. Tuğrayı tanırsın.

`yakin_yuksek` ve ünlemsiz-etiketsiz olanların çoğu: tören/salon hitabı (`D23_*`, `D25_K_1/2`, `D27_Z_*`), `D_WIT_*` yorumları, `D42B_H_*` ring kenarı barkları.

### 3) `[whispers]` ama `fisilti` değil (3)
- `D17_HINT_ROW` (TOLGA, ton `[whispers]`, mesafe **ic_ses**): Yeşilde bas, şapırdatma. Pilates'te de böyle diyorlardı.
- `D26_T_AYA` (TOLGA, ton `[whispers]`, mesafe **ic_ses**): Dün akşam burada mum yakıyorlardı. Şimdi her yer asker. Ve sessizlik.
- `D21_T_WARM` (TOLGA, ton `[whispers]`, mesafe **ic_ses**): Su dalgalanıyor! Çok yakın.

### 4) `fisilti` ama ton `[whispers]` değil (7)
Sahne gizlilik gerektiriyor, etiket eksik:
- `D17_TR_NOISE` (TREVISANO, ton `[shouting]`, mesafe **fisilti**): Sessiz! Bütün Haliç duydu!
- `D17_TR_LIGHT` (TREVISANO, ton `[panicked]`, mesafe **fisilti**): Durun! Işık... Galata'dan. Birisi işaret veriyor.
- `D23_I_ASIDE` (ISMAIL, ton `—`, mesafe **fisilti**): Frenk. Bir de sana söylüyorum, onlara ilet: Sultan kararlı. Bu teklif son teklif
- `D19_C_SHEET` (BRIG, ton `—`, mesafe **fisilti**): Çırak, şu halatı tut. Rüzgâr döndükçe sal ya da çek. Yelken çırpınırsa surdaki f
- `D19_C_TEZKIRE` (BRIG, ton `—`, mesafe **fisilti**): (Dişlerinin arasından) Venedik gemisinde Sultan'ın kâğıdı. Kimin adamısın sen, B
- `D36_G_02` (GIUST, ton `—`, mesafe **fisilti**): Kalas köprüden geçin, ses çıkarmayın. Davullar çalarsa elinizdekini bırakıp geri
- `D36_N_PHOTO` (NIHAT, ton `—`, mesafe **fisilti**): Tespit karesi, Tolga Bey: yanan kalkanlar, arkada surlar. Çabuk olun, ordugâh uy

## Belirsizler (5)
- `D26_G_WAVE1` (GIUST): betikte bulunamadı: scripts/ altında D26_G_WAVE1 geçmiyor (yalnız D26_G_WAVE2/3 ve D26O_S_WAVE1); eski sürüm kalıntısı olabilir
- `D26_S_WATER_1` (SOLDIER): betikte bulunamadı: aynı metinler D26_S_ARROWS_n olarak chapter26.gd:2014 _deliver'da kullanılıyor (su→ok değişimi); anahtar kullanılmıyor görünüyor
- `D26_S_WATER_2` (SOLDIER): betikte bulunamadı: aynı metinler D26_S_ARROWS_n olarak chapter26.gd:2014 _deliver'da kullanılıyor (su→ok değişimi); anahtar kullanılmıyor görünüyor
- `D26_S_WATER_3` (SOLDIER): betikte bulunamadı: aynı metinler D26_S_ARROWS_n olarak chapter26.gd:2014 _deliver'da kullanılıyor (su→ok değişimi); anahtar kullanılmıyor görünüyor
- `D21_M_LEB` (MUFIDE): betikte bulunamadı: scripts/ altında D21_M_LEB geçmiyor (D21_M_LEB2 var, Novominer); konuşmacı MUFIDE görünüyor, yanlış etiket olabilir

## Diğer notlar
- Aynı anahtar birden çok yerde kullanılıyorsa ilk/en sık kullanım alındı (ör. `D20_L_WARN_1` hem Bölüm 0, 20 hem arena/26'da: gözcü kuleden, hepsinde `uzak`).
- `hud.say` ve `hud.bark` ayrımı mesafe sınıfını tek başına belirlemedi; sahnedeki konum esas alındı.
- Tolga'nın `_T_` anlatı satırları (`D12_T_ENTER*`, `D13_T_ALONE_*` vb.) ve `hud.think` / parantezli betimlemeler `ic_ses`.
