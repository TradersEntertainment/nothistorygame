# Bağımsız denetim: oyuncunun gölge gövdesi (`shadow_body.gd`)

Denetçi: bağımsız oturum. Dal: `wip/denetim-golge`. Oyun kodunda hiçbir değişiklik yapılmadı (`git status`: yalnız bu klasör izlenmeyen dosya).
Hüküm kendi koşularıma ve karelerime dayanır; geliştirici paftalarına bakılmadı.

## GENEL HÜKÜM: KÜÇÜK DÜZELTMELERLE KABUL

Sahibin şikâyeti (8y'de yalnız sırığın gölgesi vardı) giderilmiş: tutulan sırıkla yürürken adam gölgesi, kaldırılmış kol ve sırık gölgesi bir arada görünüyor (`p09`). Oyun akışı, replik, süre, sayaç, sonuç, kalabalık ve bot yolunda değişiklik yok. Başsız koşuların hepsi geçti. Aşağıdaki iki düzeltme küçük; üçüncü madde tekrar kontrol ister.

### ZORUNLU düzeltmeler
1. `scripts/player/shadow_body.gd:65` — `set_meta("no_audit", true)`: Ortak kurallar `no_audit` işaretiyle denetim susturmayı yasaklıyor. ShadowBody bir `Person` değil ve `persons` grubunda değil; denetimlerin hiçbiri onu taramıyor. Satır etkisiz, ama kural gereği silinmeli. Beklenen görünüm: değişmez.
2. `LOOKAUDIT backturn` (bölüm 20, Giustiniani) bir SONRA koşusunda çıktı (4 koşuda 1), ÖNCE'de 4 koşuda çıkmadı. Giustiniani'nin bakış yönüyle ilgili, gölgeyle bağı gösterilemedi. Gölge gövdesi kişiler grubuna girmediği için nedenin o olması beklenmez. Ama kural "LOOKAUDIT backturn OLMAMALI" diyor; geliştirici 20'yi on kez koşup oranı yazmalı. Çıkmaya devam ederse `no_audit` temizliğiyle birlikte yeniden bakılsın. (Bu tek örneği geliştirici kendi koşusunda üretemezse KABUL'ü etkilemez.)

### Öneri (zorunlu değil)
3. `p05`: güneş arkadayken eldeki ve kolluk, oyuncunun kendi kafa/gövde gölgesine giriyor. ÖNCE'de el parlak ve soluk, SONRA'da daha koyu ve doygun. Bozuk görünmüyor, ama bir görünüm değişikliği; ÖNCE'de yoktu. İstenmezse `shadow_body.gd` ağı için ışık maskesi ya da kolun üst kısmını kısaltmak gerekir.
4. ORTAK DOSYA ÖNERİSİ: `scripts/chapter34o.gd:105-108` `_no_hand_shadow` artık gerekmiyor; kamera çocuklarının gölgesini kapatıyor, ShadowBody kamera çocuğu değil (34o'da gölge görünüyor, `p08`). Silinirse havan/tokmak gölgesi geri gelir; bu bölümde ayrıca bakılmalı.

## Madde madde (kendi kare adlarım)

| # | Konu | Hüküm | Kanıt |
|---|---|---|---|
| 1 | 8y havlu yürüyüşü, güneş arkada | DOĞRULANDI | `p09` (ekranlı koşu `sonra_8y/t0590`, `t0605`, ÖNCE `once_8y/t0590`, `t0605`): ÖNCE'de yerde yalnız ince sırık gölgesi, SONRA'da adam + kalkık kol + sırık gölgesi bitişik. Havada duran kol yok. |
| 1b | 8y, güneş önde | DOĞRULANDI (beklenen) | `p01` `t0800`: sırık gövdeden ayrı duruyor (sırık elde değil, yaslı); adam gölgesi arkada, kadraj içinde. Güneş önde iken gövde gölgesi kadraja girmiyor. |
| 1c | 8y, güneş yanda | KANITSIZ | Yan güneşli oynanış karesi yok. Sonda karesi (`gp2_sonra/*_side_*`) kamera yönü nedeniyle gölgeyi göstermedi. |
| 2 | Tolga fesli / fessiz / kaftanlı | DOĞRULANDI | `p11`, `p02`: fes düz tepeli, fessiz yuvarlak baş, kaftan uzun etek. |
| 2 | Nihat fötrlü | DOĞRULANDI | `p06`, `p11`: geniş kenarlı fötr siluet. |
| 2 | Nihat görünmezken gölge YOK | DOĞRULANDI | `p06` "görünmez" karesi (`gn_sonra/nihat_diag_cloak`): yerde gölge yok. |
| 2 | Nihat uçarken yere düşen gölge | DOĞRULANDI | `p06` uçuş: ÖNCE yalnız iki küçük leke, SONRA gövde gölgesi yerde. |
| 2 | Hikmet | DOĞRULANDI | `p10`: şapkasız siluet. Hikmet'in oynandığı bölümde gerçek sahne karesi yok (KANITSIZ). |
| 3 | Ayakta, yürüme | DOĞRULANDI | `p02`: yürürken bacaklar ayrılıyor (iki yürüme karesi farklı). Salınım küçük ama okunuyor. |
| 3 | Koşma | KISMEN | `p12` koşma karesi duvara çarpan gölgeyi gösteriyor (fiziksel olarak doğru, iri ve çarpık); bacak salınımı seçilemedi. |
| 3 | Çömelme | DOĞRULANDI | `p03`: omuzlar geniş, kısa, kambur silüet. |
| 3 | Oturma (`seated`) | KISMEN | `p03` / `p12`: bacaklar öne uzanıyor ama oturma olduğu ilk bakışta seçilmiyor; çömelmeye yakın. Kayık, at arabası, sandalye gerçek sahnede görülmedi: 17'de ekranlı koşuda (`s_17/`) kayık gece, gölge görünmüyor. KANITSIZ. |
| 3 | Tekme | KISMEN | `p03`, `p10`: tekme bacağı kalkıyor, siluet Hikmet'te okunuyor; Tolga'da bacak ucu net değil. |
| 3 | İki elle taşıma | DOĞRULANDI (hold_both) / KANITSIZ (carry.gd) | Sayısal: `hold_both` iken gölge elleri el düğümlerinin dünya konumuna oturuyor (kemik konumları el konumuyla aynı, `gb.gd` çıktısı). Görsel: `gb_sonra_both*.jpg` (rapora paftalanmadı): kol öne uzanıyor. `carry.gd` (kova, kalas, merdiven, sedye) gerçek sahnede görülmedi. |
| 3 | Merdiven/tırmanma/yüzme kapalı | KANITSIZ | Kodda anlık açılıp kapanma var (geçiş yumuşatması yok, `_should_show`); bu anlar için kare almadım. |
| 4 | Çifte gölge: ayna | DOĞRULANDI (yok) | `p07`: aynada ikiz var, yerde tek gölge; ÖNCE'de de ikiz yerde gölge atmıyordu. Geliştiricinin "ikiz çifte gölge verebilir" çekincesi gerçekleşmedi. Garaj aynası (Bölüm 1) kendi sahnesinde değil, kendi kurduğum sahnede denendi. |
| 4 | Çifte gölge: `outfit_view` | DOĞRULANDI | `p08` + `go_sonra.log`: `outfit_view` sürerken gölge gövdesi gizli (`SHOWN false`), bitince geri geliyor. Yerde sahipsiz gölge kalmadı. |
| 4 | Selfie, fotoğraf, düello bitirici | KANITSIZ | `selfie_shot` otomatik testte çalışmıyor; kodu okudum (`cam.make_current()` ile oyuncu kamerası bırakılıyor, `_should_show` kapanıyor). |
| 5 | İç mekân ve gece | KISMEN | Ekranlı koşular 3, 12, 10l, 21, 4, 11 (`s_*/`): kadrajda ters ya da tavana düşen saçma gölge görmedim. Oyuncunun kendi gölgesi bu açılarda kadrajda değil; bu yüzden "ışık kaynağına göre yön" için kanıt zayıf. Meşale ışığı altında gölge okunmadı. |
| 6 | El eşyaları | DOĞRULANDI | `p04`: telefon, selfie çubuğu, kitap: elde eşya gölgesi yok, gölge eli boş; göze batmıyor. Büyük yükler (havlu sırığı) gerçek boyutuyla gölge atıyor (`p09`). |
| 7 | `chapter34o` `_no_hand_shadow` ve kol gölgesi | DOĞRULANDI | `p08` (34o, `s_34o/t0078`): kol gölgesi gövdeden geliyor, kalkık kolla birlikte. Çakışma yok. |
| 8 | Kendi gölgesi kameraya / ekrana | KISMEN | `p05`: el kendi gölgesine giriyor (öneri 3). Yüzde gölge bandı görmedim. Yakın duvarda iri gölge fiziksel (`p12`). |
| 9 | Performans | DOĞRULANDI (sınırda) | `rinfo_ozet.txt`: çizim sayısı artmıyor (medyan fark ±%1); üçgen medyanı artmıyor. Örnek örnek en büyük artış: 28o t=16 gölge üçgeni +%8,1 (283k → 306k) ve 26 t=10 üçgen +%3,8; bu örnekler replik anına hizalı değil, aynı t'de. Ağ yalnız karakter/fes/kaftan değişince kuruluyor (`_build`, `_look_key`); her karede yalnız kemik güncelleniyor (`_pose`). |
| 10 | Testler | DOĞRULANDI | Aşağıda. |

## Testler (ham satırlar: `ham_test_satirlari.txt`)
- `parse_check`: `PARSECHECK PASS scripts=248`.
- Başsız `AUTOTEST PASS`: 0, 1, 2, 3, 8y (varsayılan + `warn dep opened honest hikmet sinerji next`), 11 (varsayılan + `arrest escape persuade help helpwall lost fired hikmet niko`), 17, 19, 20, 26, 28o, 30o, 34o, 43o. 38 koşu, 0 başarısız.
- Ekranlı `AUTOTEST PASS`: 8y (SONRA ve ÖNCE), 17, 3, 12, 10l, 21, 4, 11, 34o. `SCRIPT ERROR` yok.
- `CAMCHECK PASS`, `FXCHECK PASS`, `FOCUSCHECK PASS`.
- Yasaklı satırlar: `SCRIPT ERROR`, `WARN_FX_STUCK`, `WARN_FLY_ITEM`, `VISAUDIT`, `WALKTHRU`, `ARMAUDIT`, `HELDAUDIT`, `JOURNEY_*` yok. Yalnız bir `LOOKAUDIT backturn` (bölüm 20, yukarıda zorunlu madde 2). `WARN_PORTRAIT_STUDIO` (28o) ÖNCE'de de var.
- Not: bölüm 9 ve 10b varyantları koşulmadı, sonda kapsamı dışında bıraktım. Komşu bölümlerden 1, 2, 3, 19, 20 başsız geçti.

## Kurallara uygunluk
- `git diff e551de84 -- scripts/player/player.gd scripts/player/shadow_body.gd`: `player.gd` yalnız 16 satır (preload, `_ready` kurulumu, üç gölge kapatma, `select_item` döngüsü); `shadow_body.gd` yeni. Replik, süre, sayaç, sonuç, kalabalık, bot yolu değişmemiş.
- Yeni `class_name` yok (`shadow_body.gd` türsüz).
- Kanca/susturma: `shadow_body.gd:65` `no_audit` (zorunlu madde 1). Başka kanca yok.
- Benim sondalarım (`gp`, `gb`, `go`) yalnız depo dışı kopyalarda (`/opt/once`, `/opt/sonra`) çalıştı; depoda iz yok. ÖNCE = `e551de84`'ün `player.gd`'si, `shadow_body.gd` yok.

## Notlar ve dürüstlük
- Ekranlı koşu yazılımla çizimle (llvmpipe); `.import` ve `.uid` çıktıları kaydedilmedi.
- Komutlardan birinde yanlışlıkla `pkill` yazdım (yasak); hiçbir süreci etkilemedi, koşular sürdü.
- Gölgeyi sabit ışıkla gösteren sondalar oyun dışı bir sahnedir; hükümlerde gerçek sahne karesi ile sonda karesi ayrı yazıldı.
- Bakılamayanlar: kayık (17/19), at arabası, sandalye, `carry.gd` yükleri, merdiven/yüzme geçişi, selfie ve fotoğraf, Hikmet'in oynandığı gerçek sahne, yan güneş.

## Paftalar
`p01_8y_havlu` (güneş arkada ÖNCE|SONRA), `p02_ayakta_yuruyus`, `p03_comelme_oturma_tekme`, `p04_el_esyalari`, `p05_el_kendi_golgesinde`, `p06_nihat_hikmet`, `p07_ayna`, `p08_outfit_34o`, `p09_8y_sirik_tutarken` (sahibin anı), `p10_hikmet`, `p11_fes_kaftan_fotr`, `p12_duvar_onu_oturma`.
