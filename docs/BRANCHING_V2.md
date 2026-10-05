# Dallanma v2: Çanta ve eylemlerle dallanan hikâye

> Kullanıcı isteği (v0.75 sonrası): *"Hikâye akışına odaklan. Envanter ve yaptığımız eylemler hikâyeyi etkileyecek şekilde dallanıp budaklanmalı."*
> Bu belge mevcut durumu ölçer, kuralları koyar ve işi dört kilometre taşına böler. Önceki dal tasarımı: [STORY_BRANCHES.md](STORY_BRANCHES.md), bölüm yapısı: [CHAPTERS.md](CHAPTERS.md).

## 0. Tespit (v0.75.0, koddan otomatik tarama)

| Ölçüm | Değer | Ne anlama geliyor |
|---|---:|---|
| Bayrak (flags) | 169 | Oyunun hatırladığı her şey |
| Kurulup başka hiçbir bölümde okunmayan bayrak | ≈ 90 | Seçim yapılıyor ama sonraya taşınmıyor (keçi yakalandı, Urban'la dost olundu, Çandarlı'yla tanışıldı, mutfak yandı, kuşatmadaki kararların çoğu...) |
| Çanta değişikliği | Yalnız garaj | Eşya verilmiyor, harcanmıyor, kaybedilmiyor, kazanılmıyor |
| Çakmak, kitap, termos, selfie, kolonya | Bölüm 4, 6, 7, 12 | Kuşatmada (17–39) hiçbir etkileri yok |
| Seçimsiz bölüm | 25 / 57 | Kuşatma bölümlerinin çoğu tek hatlı |
| Hikâye deliği | 3 + 2 | Küp Hüseyin'de kalıyor (Bölüm 7 öyle anlatıyor) ama çantada da duruyor; termos Kadri'ye kaftanla takas ediliyor ama çantada kalıyor; leblebi Kadri'ye veriliyor ama hiç azalmıyor (üçü v0.76'da kapandı). Giustiniani 6b'de çakmak için "Ama alırım." diyor ama çakmak çantada kalıyor; 7'de ikizler "Bize termos vermedi" derken arkalarında termos parlıyor ama 4a'da termostan yalnız bir bardak eksiliyordu (ikisi v0.77'de kapandı) |

## 1. Kurallar

1. **Eşya bir kaynaktır.** Bandın şeridi, leblebinin avucu, termosun bardağı, kolonyanın fısı, powerbank'in dolumu vardır. Kullanınca azalır, bitince o seçenek kapanır. Bir eşyayı bir yerde harcamak, başka bir yerde o yolu kapatır.
2. **Verilen eşya gider ama kaybolmaz.** Birine verilen eşya çantadan çıkar ve o kişide kalır. Sonraki bölümlerde o kişi onu kullanır: yardım eder, yolu değiştirir, sonu değiştirir.
3. **Her eylem bir iz bırakır, her iz bir yerde okunur.** Kurulup hiç okunmayan bayrak test hatasıdır (izin verilen yerel bayraklar listelenir).
4. **Oyuncu sonucu görür.** Biten eşya için Tolga son kullanıldığı yeri söyler ("Bant bitti. Sonuncusu Urban'ın topunda."). Finalde her eşyanın yolculuğu ve 2026'daki izi gösterilir.
5. **Kuşatmada tarih aynı kalır, Tolga'nın sayfası değişir.** Tanık sözleşmesi geçerli: büyük olaylar değişmez (26.3 gibi açıkça tasarlanmış istisnalar dışında). Ama kimin yanında olduğu, kimi kurtardığı, hangi eşyasının tarihe karıştığı değişir ve finali besler.

## 2. Sistemler

### 2.1 Eşya kaynakları (GameState)
- `flags["charges"]`: kalan şarj. Şarjlı eşyalar: 📦 bant **3 şerit**, 🥜 leblebi **4 avuç**, ☕ termos **3 bardak**, 🍋 kolonya **3 fıs**, 🔋 powerbank **2 dolum**. Öbürleri tektir (verilene ya da el konulana kadar).
- `GameState.has_item(id)`: çantada ve şarjı var.
- `GameState.spend(id, use)`: bir şarj harcar, deftere yazar; biterse eşya çantadan çıkar.
- `GameState.give(id, to, use)`: eşya o kişiye geçer (`flags["given"][id] = to`).
- `GameState.gain(id, src)`: 1453'te eşya kazanılır (çanta 5 doluysa ne bırakılacağı sorulur).
- `GameState.item_log()`: `flags["item_log"]` = `[eşya, kullanım, bölüm]` sırası. Anlık görüntüyle saklanır, bölüm yeniden oynanınca geri sarılır.

### 2.2 HUD
- Çanta şeridinde şarj rozeti (×3), açık çantada "3 şerit" yazısı.
- Harcama bildirimi: "📦 Koli bandı · 2 şerit kaldı", biterken "📦 Koli bandı bitti · sonuncusu: Urban'ın topu".
- Verilen eşya: "☕ Termos artık Kadri'de".

### 2.3 Cep (v0.77, v0.78)
Çantanın beş gözüne girmeyen, 1453'te bulunan ya da Tolga'nın eline tutuşturulan küçük şeyler: Haliç'te yüzerken bulunan
**yedek fes** (2), Theodoros'un tek mühürlü **Misafir İzni** (6b), Fatih'in **tezkiresi** (12).
`GameState.pocket_add / pocket_give / pocket_use / in_pocket / holds`. Açık çantada "Cep: …" satırında görünür; defterde öbür
eşyalar gibi yazılır, Akıbet sayfasına girer ("cebinde kaldı"). Gösterilen kâğıt (`pocket_use`) cepte kalır ama her
gösterilişi yolculuğuna bir adım olarak yazılır; elde kendi modeliyle görünür (`Items.POCKET_IDS`).
Verilen bir eşya sahibinin elinde işe yararsa `GameState.note_use` deftere yazar (Kadri'deki termos 10Z'de tabağı, 24o'da
çorbayı kurtarır): Akıbet sayfası "orada kaldı" der ama orada ne işe yaradığını da gösterir.

### 2.4 Replik izleri (v0.77)
`GameState.line_variant` bir replikte eşya izi eki arar (`ITEM_VARIANTS`): bir anahtarın `_HUFEZ` (yedek fes Hüseyin'de),
`_HUCUBE` (küp Hüseyin'de), `_KTHERMOS` (termos Kadri'de), `_GLIGHTER` (çakmak Giustiniani'de), `_GBOOK` (kitap
Giustiniani'de), `_ULIGHTER` (çakmak Urban'da) sürümü varsa ve eşya gerçekten o kişideyse o okunur. Bölüm kodu değişmeden her sahnede verilen eşyayı anan
satır yazılabilir: ikizlerin "Ben Hasan'ım. Değilim." şakası fes Hüseyin'deyken "Ben Hüseyin'im. Fesli olan." olur.

### 2.5 Akıbet (Bölüm 15)
Final kartlarından önce **Eşyaların Akıbeti** sayfası: garajda seçilen her eşyanın yolculuğu (her şerit, her avuç, kime verildiği) ve son akıbetine göre 2026'da kimsenin fark etmediği bir iz (Matris 6'nın eşya karşılığı).

## 3. Kaynaklar: nerede harcanır

| Eşya | Şarj | Harcandığı yerler (M1) | Bitince |
|---|:-:|---|---|
| 📦 Bant | 3 | 4a nöbetçileri sırt sırta · 6a Urban'ın topu · 10B çatlak · 10H barikat · 20 gedik | 10B'de çatlak bantsız → risk +1 (Büyük Patlama yakınlaşır) · 20'de 20.2 yok (Uzun Bekleyiş zayıflar) |
| 🥜 Leblebi | 4 | 4a nöbetçiler · 6a Kadri · 6b martı · 10O ilk soru · 10H zincir nöbetçileri · 10Z gizli malzeme · 10L Tünel Sulhu · 11 ikna · 21 Mirko · 32o Hasan'ın ateşi | 10L'de yalnız poliçe · 21'de sus işareti leblebisiz · 11'de ikna +15 yok |
| ☕ Termos | 3 | 4a ikizlerin molası (**termosun tamamı gider**, 9'da bir bardağıyla döner) · 6a Kadri takası (**termosun tamamı gider**) · 6a Lütfi · 10O Ağa · 12 Fatih · 24o ateş başlarında çay (her ateşe bir bardak) | Kadri'deyse: 10Z'de bir tabağı kurtarır, 24o'da çorbayı sıcak tutar (mutfağa en yakın ateş kendiliğinden sakinleşir) |
| 🍋 Kolonya | 3 | 4a nöbetçiler · 6a Lütfi | M3'te kuşatmada yara ve yangın |
| 🔋 Powerbank | 2 | 10B iki katı barut · 10H Giustiniani'ye zırh ısıtıcısı (**verilir**) · 21 deprem uygulaması | 21'de uygulama yok, kaplar elle |
| 🧊 Küp | — | 4a Hüseyin'e kalır (**verilir**); 9'da kapıda geri verilir (bir yüzü çözülmüş) | Geri alınmazsa 10B/12'de küp yolu yok |

## 4. Hediye zincirleri (M2)
| Zincir | Verildiği yer | Sonra | Durum |
|---|---|---|---|
| Yedek fes → Hüseyin | 2'de Haliç'te bulunur (cebe), 4a'da nöbetçilere: yeni bir geçiş yolu (4a.2) | Hüseyin 7, 9, 10O, 10B ve 16'da fesle görünür; ikizler artık kim kim biliyor (_HUFEZ); 10O'da Hüseyin kefil olur, Sorucu Ağa'nın ilk sorusu atlanır | v0.77 |
| Küp → Hüseyin | 4a | 7'de çözmeye çalışır (_HUCUBE), 9'da kapıda bir yüzü çözülmüş geri gelir; gelmezse 10O ve 16'da hâlâ elinde | v0.76 + v0.77 |
| Termos → ikizler | 4a ("Beş dakika mola") | 7'de "Bize termos vermedi" derken arkalarında parlar; 9'da kapıda bir bardağı kalmış geri gelir. Burada veren 6a'da Kadri'yle kaftan takasını yapamaz | v0.77 |
| Termos → Kadri | 6a takas | 10Z'de "sihirli testi" taşan bir tabağı kurtarır (yanmaz); 24o'da Kadri termosla mutfağa en yakın ateşe gider, o ateş ay dönmeden sakinleşir | 10Z v0.77 · 24o v0.78 |
| Çakmak → Giustiniani | 6b ("Ama alırım.") | 20'de topçuları onunla fitil yakar (_GLIGHTER); 26'da yaralanırsa çakmağı Tolga'nın avucuna bırakır (G harfi kazınmış) | v0.77 |
| Kitap → Giustiniani | 6b (göster, sonra "Sende kalsın. Oku.") | 20'de bir sayfası uykusunu kaçırır; 26'da 29 Mayıs'ı bilerek konuşur (_GBOOK). Kitap gidince 12'de anahtar sahnesi kitapsız oynanır | v0.77 |
| Misafir İzni (6b, Theodoros) | cebe girer (6b.3'te martıyla gider) | 10H'de Theodoros kendi mührünü tanır, Frenk'e kefil olur (doğruluk +1: Lütfi hiç düzeltilmese de mektup verilir) · 23'te (Bizans) ikinci mührü basar: "saray tercümanı" · 25'te son ayinde Tolga saray halkının arasında durur, İmparator helalliği ona ayrıca söyler (23'te sözlerini yumuşattıysa bildiğini de söyler) · 39o'da (Osmanlı) Petrion'daki Rum komşu mührü tanır, çavuşu kendisi koşup getirir | v0.78 |
| Çakmak → Urban | 6a ("fitil kutusu, bende kalsın") | 7'de Nihat'a gösterir · 10B'de Tolga'ya meşale kalır, fitili Urban Tolga'nın çakmağıyla yakar · 20o'da (Osmanlı) Urban hâlâ çakar | v0.78 |
| Sultan'ın tezkiresi (12) | 12.1/12.2/12.4/12.6'da Fatih kâtibin uzattığı tuğralı kâğıdı okur, Tolga'ya verir (cebe) | 25'te (Osmanlı) ilk yakalanışta nöbetçi tuğrayı görür, yamağı mutfağa göndermez · 26'da (Bizans) şehir düşünce esir kafilesinden Kardinal Isidoros'u "kâtibim" diye çıkarır → 27'de Galata rıhtımında gemi kuyruğunda teşekkür eder · 39o'da baltalılara üçüncü kez gösterilir | v0.78 |
| ~~Küp → 16 devriyesi~~ | — | 16 yalnız 4b'de (Sinerji) açılır, küp 4a'da verilir: iki yol kesişmez. Kaldırıldı. | — |

## 5. Kuşatma (M3)
Seçimsiz kuşatma bölümlerine iki tür dal eklenir:
- **Müttefik:** Perde II'de yardım edilen kişi kuşatmada ortaya çıkar (Kadri'nin yamakları kova zincirine, Niko küreğe, Hasan merdivene). Kötü davranılan engel olur.
- **Eşya taktiği:** Elindeki kaynakla sahnenin bir zorluğunu başka yoldan aşmak (bant: merdiven/halat, çakmak: fitil, kolonya: yara, termos: soğuk gece). Sonuçlar mevcut finallere (Saçaktaki Çocuk, Sakabaşı, Uzun Bekleyiş, Bir Akşam) yeni yollardan bağlanır.

### 5.1 Zaman kuralı
Kuşatma bölümleri tarih sırasıyla oynanmaz: Perde II 22–26 Nisan 1453'tedir, kuşatmanın bir kısmı ondan öncedir
(33o–37o, 28o, 29: Ağustos 1452 – 20 Nisan 1453). **26 Nisan'dan önceki bir bölümde Perde II'nin hiçbir tanıdığı
Tolga'yı tanıyamaz** (Tolga oraya ikinci kez, Büro'nun tanığı olarak gelir; ilk ziyareti onların geleceğidir). Bu
yüzden 29'un Cenevizli müttefiki (10G, 25 Nisan) yazılmadı. Eşya taktiği her bölümde olur: çanta Perde II'nin sonundaki
çantadır.

### 5.2 M3a (v0.79)
| Bölüm | Koşul | Dal | Sonra |
|---|---|---|---|
| 17o Kundak (28 Nis.) | Kadri'ye iyilik: 6a.1 yamaklık, 6a.4 kaftan takası, 10Z.1 ziyafet ya da termos Kadri'de (10Z.2'de mutfak yandıysa gelmez) | Kadri iki yamağıyla kovalarla gelir, zincir hızlanır: iki kovayla da yangın vaktinde söner (17O.1) | Sakabaşı'na (17O.1 + 22O.1 + 24O.1) yeni yol · şafakta Kadri'nin repliği |
| 18 Fıçı Köprü (Mayıs başı) | 4a'da nöbetçilerle dost (guards_like_tolga) | Hasan ile Hüseyin fıçıları tutar: bağın yeşil bandı 0,16 → 0,23 (fes Hüseyin'deyse _HUFEZ) | 18.1 kolaylaşır |
| 18 | Çantada bant | Kaçan bağ bantla sarılır (bir şerit): bölüm doğrulur, kaçan sayılmaz | 18.1'e bantla dönüş · Akıbet: "Haliç'in dibinden çıkan fıçı" |
| 19 Brigantin (3 May.) | Cepte Sultan'ın tezkiresi (12) | Devriyeye dördüncü cevap: tuğra fenere tutulur, reis eğilir, şüphe doğmaz. Ama kaptan ve tayfa görür (brig_tezkire): oylamada tayfa kâğıdı tartar, dönüşte Niko "şehir düşerse o kâğıt bir can kurtarır" der (26'daki Isidoros'un habercisi), Nihat'ın dipnotu uzar | 27'de kaptan anar · Akıbet: Venedik arşivinde tayfa ifadesi |
| 20o Gedik, ordugâh (7 May.) | Soğutulmayan namlu | Çatlayan namluya Urban yarım barut koyar: sonraki gülle kısa düşer (nişan yükseltilmeli) | Kalan çatlaklar 32o'da: iki çatlakta büyük top o gün susar |
| 20o | 6a/10B'de top bantlandı (cannon_taped) | Eski şerit ilk çatlağı tutar | 32o'da Ali "belinde hâlâ senin şeridin" der |
| 20o | Çantada bant | Çatlak yeniden sarılır (bir şerit) | Akıbet: "Askerî Müze'deki dev topun şeridi" |
| 24 Alametler (24 May.) | Niko dost (niko_friend: 4, 6b, 7, 11) | Niko alayda Tolga'nın yanında yürür, sert rüzgârda sırığa omuz verir (rüzgârın etkisi 0,55 → 0,3); selde saçağın önüne kapı kanadı yatırır: çocuğa yetişme süresi 22 → 29 sn | 24.1'e (Saçaktaki Çocuk) yeni yol |
| 27 Ahitname (1 Haz.) | Bizans yolu: 19 oynandı (brig_vote) | Brigantinin kaptanı iskelenin dibinde. "Dönelim" dendiyse Galata'da kalır ve kalanlara sayılır; "kurtulalım" dendiyse gemiye biner | 27.1'e (Saçaktaki Çocuk) yeni yol: 19'daki oy 27'yi değiştirir |

## 6. Ölü izler (M4)
Okunmayan ≈ 90 bayraktan anlamlı olanlar sonraki bölümlere bağlanır; geri kalanı yerel olarak işaretlenir. `tests/check_consequences.py` her yeni okunmayan bayrağı hata sayar.

## 7. Test
- Her bölümün autotest'i varsayılan çantayla şarj harcar; `--bag=` ve `--flag=charges...` ile boş/dolu durumlar denenir.
- `tests/check_consequences.py`: okunmayan bayrak listesi (izinli yerel bayraklar hariç).
- Akıbet sayfası için Bölüm 15 autotest'i eşya defterini basar.

## 8. Kilometre taşları
| Sürüm | İçerik |
|---|---|
| v0.76 (M1) | Eşya kaynakları, defter, HUD, mevcut kancaların şarja bağlanması, 3 hikâye deliğinin kapanması, Akıbet sayfası |
| v0.77 (M2a) | Cep, replik izleri, yedek fes / küp / termos / çakmak / kitap zincirleri, iki hikâye deliği daha |
| v0.78 (M2b) | Misafir İzni (10H, 23, 25, 39o), Sultan'ın tezkiresi (12, 25, 26 → 27, 39o), 24o termos (Kadri'de / çantada), Urban'ın çakmağı (6a, 7, 10B, 20o) |
| v0.79 (M3a) | 17o Kadri ve yamakları, 18 ikizler ve bant, 19 tezkire → 27 brigantinin kaptanı, 20o çatlak/bant → 32o, 24 Niko |
| v0.80 (M3b) | Kalan kuşatma bölümleri (20, 21, 22, 22o, 26, 26o, 30, 38o) |
| v0.81 (M4) | Ölü izler, tüketim testi |
