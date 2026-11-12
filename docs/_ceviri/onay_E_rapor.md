# Çeviri onay raporu — Grup E (dilim 9 + dilim 10)

Bağımsız denetçi / ikinci yazar. Dal: `wip/ceviri-onay-E`. Oyun dosyalarına (i18n/strings.csv, VOICE_MAP.csv, betikler) dokunulmadı.
Teslimler: `docs/_ceviri/onay_E.csv` (uygulanacak liste: `kabul` + `duzelt`), `docs/_ceviri/kapsam_E.csv`, bu rapor.

## 1. Okunan satır (kapsam dosyasından)

| | anahtar | tr+en satır |
|---|---|---|
| Dilim 9 (UI_A–H, ACH_, PHOTO_, PF) | 1.546 | |
| Dilim 10 (kalanlar: UI_I–Z, LORE, SIEGE, FATE, FLOW, LM, SPK…) | 2.145 | |
| **Toplam** | **3.691** | **7.382** (iyi 7.318 · öneri 46 · şüpheli 18) |

Her anahtar tr ve en sütunuyla (en boşsa atlandı) sahnesindeki yerine bakılarak okundu; adı geçen kalıp listesi
(“Belki …-meli”, “Endişelenme”, “sadece/aslında/gerçekten”, “tarafından”, “sahip olmak”, “my lion/my soul/health to your hands”…)
ayrıca bütün sütunlarda tarandı. Bu iki dilim neredeyse tamamen arayüz, tutanak, bilgi kartı ve akıbet metni; koku oranı gerçekten çok düşük
(ilk turun “%1” tespitine katılıyorum). Tuş adları, yer tutucular (`%s %d %.1f %%%d {N}`), BBCode ve tarihî olgular değişmedi.

## 2. İlk turun denetimi (47 öneri satırı)

| Dilim | kabul | düzelt | ret | toplam |
|---|---|---|---|---|
| 9a | 17 | 2 | 0 | 19 |
| 9b | 4 | 2 | 2 | 8 |
| 10a | 6 | 2 | 1 | 9 |
| 10b | 8 | 2 | 1 | 11 |
| **Hepsi** | **35** | **8** | **4** | **47** |

### Ret (4 satır) ve gerekçeleri
1. **`D6A_C_01_NOFEZ` tr** — “Ben kimseyim. Kimse gönderdi.” bir ŞAKA: Çandarlı kendini “Kimse” adıyla tanıtıyor. Tolga’nın cevabı `D6A_T_C_02`
   “…Kimse kim?”, `D6A_C_03` “Çandarlı Paşa. …Kimse yani.” buna bağlı. “Ben kimse değilim” cevap şakasını yıkar. Ayrıca ilk tur yalnız
   `_NOFEZ`i değiştiriyor, `D6A_C_01` ile varyant ayrışıyordu.
2. **`UI_HAUL_GOOD` tr** — “Hey-yap” bir çeviri izi değil, Urban’ın çekme nidası ve geri dönen söz: `D28O_U_HAUL` (“Hey-yap dediğimde hep birlikte!”),
   `D35O_U_HEAVE` (“Hey-yap! Bir daha!”), `UI_OBJ35O_HEAVE` (“Hey-yap! Çek”). Ekran geri bildirimi Urban’ın çağrısının yankısı; “Hep beraber!” bağı koparır.
3. **`UI_HAUL_GOOD` en** — “Heave!” zaten `D28O_U_HAUL` EN’deki “When I say heave, all together!” ile aynı; “Heave-ho!” bağı koparır.
4. **`UI_MENU_SAVED` tr** — “bir koli bandıyla”daki “bir” sayı değil, halk ağzındaki belirsizlik (“şöyle bir koli bandıyla”). Atılınca cümle resmîleşir; eski zaten iyi.

### Düzelt (8 satır; yön doğru, metin kusurlu)
| anahtar | ilk tur | benim son metnim | neden |
|---|---|---|---|
| `UI_CH15_THANKS` tr | “Başka bir yol dene” | “Başka bir yoldan dene” | “yoldan dene” yerleşik kalıp |
| `UI_CHOICE_KICK_HIKMET` en | “Hikmet, you kick it. You’ve had the practice!” (45 k.) | “Your foot’s used to it, Hikmet!” | DÜĞME etiketi, 5 sn süreli seçim; 45 karakter düğmeyi uzatır |
| `UI_ARENA_RESULT` tr | “…Düşürdüğün: %d” | “…Yere serdiğin: %d” | “düşürdüğün” nesnesiz, “elinden düşürdüğün” gibi okunur; ayrıca `UI_ARENA_TABLE_ROW`daki “düşen” oyuncunun kendi düşüşü |
| `UI_ARENA_CANNON_DONE` tr | “ıskaladıkların kılıcına gelecek” | “ıskaladıkların kılıca kalır” | “-e kalmak” iş devri kalıbı |
| `UI_LOADTIP_8` tr | “…üç hatlıydı: hendek, dış sur, iç sur.” (%65) | “…üç hatlıydı: önce hendek, sonra dış sur, en arkada iç sur.” | uzunluk %70’in altındaydı |
| `HIKMET_ITEM_LIGHTER` tr | “…taş çarpmış; sen hazıra konuyorsun.” | “…çakmaktaşı çaktı; sen hazıra konuyorsun.” | “taş çarpmak” diye söz yok; “hazıra konmak” korundu |
| `SIEGE_NOTE_26_3` tr | “Tarih kendi kaydına yeniden kalkışacak.” | “Tarih rekor denemesine yeniden girişecek.” | “kendi kaydına kalkışmak” kalıbı yok; şakanın iskeleti “rekor denemesi” |
| `UI_RECAP_21O_PREV` en | “…carried … out on your back” | “…carried … back on your shoulders” | “out” anlamı kaydırıyor; çift “back” sorunu “shoulders” ile çözülür |

Kalan 35 satır `kabul` (gerekçeler `onay_E.csv` `denetci_notu` sütununda).

## 3. İkinci okuma: yeni öneriler (7 satır; dilim 9: 3, dilim 10: 4)

Tüm şiddet 1; ilk tur gibi bu dilimlerde hiçbir şiddet-2/3 çeviri izi bulamadım. “Her şeyi iyileştireyim” yapılmadı.
| anahtar | dilim | önce | sonra |
|---|---|---|---|
| `UI_CH15_FINAL_SULTANS_REPAIR_SUB` tr | 9 | …Fatih’in, makineyi elinde tutarken yapılmış portresi. | …makineyi elinde tutan Fatih’in portresi. |
| `UI_CREDITS_GODOT_THIRD` tr | 9 | Godot’nun içerdiği… | Godot’un içerdiği… (yazım hatası) |
| `UI_CH15_FINAL_ORDINARY_MONDAY_SUB_PLAIN` tr | 9 | …Sadece Tolga artık her pazartesi biraz erken kalkıyor. | …Tolga artık her pazartesi biraz erken kalkıyor, o kadar. (kardeş satırla tutarlılık) |
| `UI_PHONE_MSG_1` en | 10 | Mom: Where are you, son? Dinner is getting cold. | Mum: Where are you, son? Dinner’s getting cold. (EN’nin geri kalanı İngiliz yazımı; Tolga mektubunda “Mum” der) |
| `D1P_T_01` en | 10 | Mmh… Hello? Who died? | Mmh… Hello? At this hour? Who died? (“bu saatte” şakanın dayanağı düşmüştü) |
| `UI_RECAP_26O_NEXT` tr | 10 | …01.30, Haliç. Haliç’teki gemilerle… | …01.30, Haliç; gemilerle… (yan yana aynı sözcük) |
| `LM_FORUM_CONSTANTINE_INFO` tr | 10 | …kurucusunun yuvarlak forumu… | …kurucusunun oval forumu… (EN “oval” diyor, Konstantin Forumu oval; iki dil tutmuyordu) |

Bunların dışında bilerek dokunmadıklarım (karakter ağzı, bilinçli şaka): Tolga’nın plaza dili (“Aslında kiralamaya da açığız”, “gelişmeye açık”),
Nihat/Saniye tutanak dili, Urban’ın “Hey-yap”ı, “Ben kimseyim” şakası, “Kleopatra/Sezar salata” gibi şakalar, bilgi kartlarının düz anlatısı.

## 4. Varyant ve alıntı eşlemeleri

- Seçenek ↔ söylenen replik çiftleri ilk turda doğru eşlenmiş, ikisi birlikte `kabul`: `UI_CH10G_W_ASK`↔`D10G_T_W_3`, `UI_CH11_T_HONEST`↔`D11_T_HONEST`,
  `UI_CH10H_FRANK_3`↔`D10H_T_FRANK_3`, `UI_CH6B_SILENT`↔`D6B_T_SILENT`.
- `UI_CH6B_OPEN_SURE`: aynı kalıp `D6B_T_PECK`te (“Bu bir imparatorun mektubu, Sinerji!”) tavuğa seslenme şakası; ona dokunulmadı.
- `SIEGE_NOTE_28O_1` / `_28O_1M`: iki varyant birlikte değişiyor (ikisi de ilk turda var). `_28O_2` / `_2M` “sadece” içermiyor.
- `UI_CH15_FINAL_ORDINARY_MONDAY_SUB`: kardeşleri `_SUB_H3` (“sadece” yok) ve `_SUB_PLAIN` (vardı) → `_PLAIN` için ikinci okuma önerisi eklendi.
- `D6A_C_01` / `D6A_C_01_NOFEZ`: ikisi birlikte DEĞİŞMİYOR (ret, yukarıda).
- `HIKMET_ITEM_*`, `D6A_S_LETTER_R1–R3`: R1–R3 yeni `D6A_S_LETTER` ile uyumlu, değiştirilmedi.
- `UI_ARENA_OVER` / `UI_ARENA_RESULT`: aynı kartta (arena.gd:399), ikisi de “sen”e çekildi.

## 5. Metne bakan test / betik

Kodda yürüyen hiçbir test bu dilimlerdeki önerilen eski metinlere bakmıyor (`tests/`, `scripts/`, `tools/` tarandı).
Yalnız yorum satırları metni anıyor: `scripts/chapter12.gd:6` (“Aslında hiçbir şey bilmiyorum”), `scripts/stubborn.gd:5` (“yürümeye devam etmek”).
**Bakılması gereken kural:** `tests/check_voice_rules.py` Hristiyan konuşmacılara OATH sözcükleri (valla, Allah…) yasaklıyor.
`D6A_M_KAFTAN` (“Allah razı olsun!”) konuşmacısı `SPK_MERCHANT` (Osmanlı ordugâhı pazar tüccarı), listede değil → geçer; `UI_CH12_WHO_C`
(“Valla…”) konuşmacısız seçenek satırı → taranmaz.

## 6. Uygulayanın bilmesi gerekenler

- **Seslendirilmiş satırlar (kabul/düzelt edilirse ElevenLabs’te yeniden üretim gerekir):** `D10G_T_W_3`, `D11_T_HONEST`, `D10H_T_FRANK_3`,
  `D6B_T_SILENT`, `D6A_S_LETTER`, `HIKMET_ITEM_POWERBANK`, `HIKMET_ITEM_LIGHTER`, `D6A_M_KAFTAN`, ve (yalnız EN) `D1P_T_01`.
- **`docs/voice/INLINE.json` tuzağı:** `D1P_T_01` bu dosyada geçiyor; `tools/voice_gen.py` çalışırsa EN düzeltmesini eski metinle ezer. Önce INLINE.json güncellenmeli.
- `docs/voice/VOICE_MAP.csv` bu anahtarlar için tr/en metnin kopyasını tutuyor; `i18n/strings.csv` ile eşitlenmeli. `CONSISTENCY*.csv` aynı.
- `yeni_diyaloglar_dogal.txt` / `yeni_diyaloglar_elevenlabs_tts.txt` bu anahtarları içeriyor; onlardaki fonetik metin de yeni cümlelere göre yenilenmeli (rakamsız kural).

## 7. Sahibine sorulacaklar

1. “Ben kimseyim. Kimse gönderdi.” şakası bilerek mi? (Cevap şakaları buna bağlı olduğu için ret verdim; yanlışsa `D6A_T_C_02`/`D6A_C_03` de yeniden yazılmalı.)
2. “Hey-yap” Urban’ın imza nidası mı kalsın, yoksa üç yerden birden “Hep beraber”e mi çekilsin? (Şimdi dört yerde tutarlı.)
3. Seslendirilmiş sekiz satırın yeniden üretimi kredi harcar; hepsi mi, yalnız şiddet-2 olanlar mı (`D11_T_HONEST`, `D10G_T_W_3`, `D6A_M_KAFTAN`)?
4. `UI_CHOICE_KICK_HIKMET` EN düğmesi (31 k.) eskisinden uzun; 5 sn süreli seçim düğmesine sığıyor mu?
5. TR “Gerçek Tarih Bu Değil” ↔ EN oyun adı “Not a History Game” ama `ACH_FINALS_ALL_T` EN “This Is Not History”: başarım başlığı da oyun adıyla hizalansın mı?
6. `ACH_CHICKEN_WHISPERER_T` “Tavuk Fısıldayan” (At Fısıldayan göndermesi, başlık parodisi): kalsın mı, “Tavuğun Dilinden Anlayan” mı?
7. `UI_CH12_WHO_C` Sultan huzurunda “Valla” demeye Tolga’nın ağzı yetiyor mu? (Ben karaktere uygun buldum.)
8. `UI_CH12_CONFESS` (“Ben açtım. Okudum. Özür dilerim.”) kopuk cümleler bilerek mi? (dokunmadım)
9. `UI_C24O_JOKE` EN: “ay” (ay/ay) kelime oyunu İngilizcede kayıp; “moon/month” kurulabilir ama zorlama, bırakıldı.
10. Dev menüsü metinleri (`UI_DEV_*`) okundu, dokunulmadı; oyuncuya görünmüyorsa denetim dışı bırakılabilir.

## 8. En iyi on (önce | sonra)

1. `D11_T_HONEST`: Ben sadece evime dönmek istiyorum. … ben orada olmak istiyorum. | Tek istediğim eve dönmek. … orada olmak istiyorum.
2. `UI_CH10G_W_ASK`: ‘Sadece soruyorum.’ | ‘Sormanın zararı yok.’
3. `HIKMET_ITEM_LIGHTER`: …binlerce yıl taş vurdu; sen hazırını götür. | …binlerce yıl çakmaktaşı çaktı; sen hazıra konuyorsun.
4. `D6A_S_LETTER`: Sen yazı biliyor musun? … ben yazı bilmiyorum. Söyle, sen yaz. | Yazı bilir misin? … ben bilmem. Ben söylerim, sen yaz.
5. `UI_MENU_NEW_CONFIRM`: Yeni oyun başlarsa… Kayıt yuvaların durur. Başlasın mı? | Yeni oyunda otomatik kayıt silinir; yuvalardaki kayıtlara dokunulmaz. Başlayalım mı?
6. `UI_CH10O_Q2_D` (en): the Sultan Çandarlı’s secret letter | a secret letter from Çandarlı
7. `UI_CHOICE_KICK_HIKMET` (en): You kick it, Hikmet! | Your foot’s used to it, Hikmet!
8. `UI_ARENA_RESULT`: Dayanılan dalga · Yere serilen | Dayandığın dalga · Yere serdiğin
9. `D6A_M_KAFTAN`: Teşekkür ederim! | Allah razı olsun!
10. `LM_HIPPODROME_INFO`: araba yarışı | at arabası yarışı
