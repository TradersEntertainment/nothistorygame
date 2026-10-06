# Dallanma v3: Kötü işin bedeli

> Kullanıcı isteği (v0.87 sonrası): *"Hikâye akışını değiştiren, finalde başka bölüme götüren kaç bölüm var? Yoksa o da
> eksiklik değil mi? Bir akışta bir işi kötü yaparsak diğer hikâyeyi etkilemeli, diyaloğa da geçmeli."*
> Önceki tasarımlar: [BRANCHING_V2.md](BRANCHING_V2.md) (eşya ve eylem izleri), [SIEGE.md](SIEGE.md) (kuşatma çerçevesi).

## 0. Tespit (v0.87–v0.88, koddan)

| Ölçüm | Değer | Ne anlama geliyor |
|---|---:|---|
| Bölüm sonucu (bütün oyun) | 160 | |
| Rotayı değiştiren sonuç | 22 | Hepsi Perde I–III'te. Kuşatmada tek istisna: Şafak'ta "şehir düşmedi" (26.3) |
| Kuşatma sonucu | 66 | `tests/check_outcomes.py` sayar |
| Kendi bölümü dışında hiç okunmayan kuşatma sonucu | 23 | İyi de yapsan kötü de yapsan sonraki sayfa aynı (26.3 sayılmaz: `siege_held` ile okunur) |
| Hiç iz bırakmayan kuşatma bölümü | 9 | Bizans: 29, 30 · Osmanlı: 34o, 35o, 28o, 37o, 29o, 30o, 31o |
| Yalnız bayrakla iz bırakan (sonucu okunmayan) | 3 | 25 (25.2), 38o, 39o |

Kuşatma bugün düz bir çizgi: tarih değişmez (tanık sözleşmesi), ama Tolga'nın sayfası da değişmiyor.

## 1. Kurallar

1. **Kötü iş unutulmaz.** Her kuşatma sonucu sonraki ilgili sayfada hem bir replikte hem oynanışta geri döner: biri
   hatırlatır, iş zorlaşır ya da kolaylaşır, bir yardımcı gelir ya da gelmez. İyi iş de aynı kuralla hatırlanır.
2. **Tarih aynı kalır, Tolga'nın yeri değişir.** Büyük olaylar değişmez (26.3 gibi tasarlanmış istisnalar dışında);
   değişen, Tolga'nın kiminle, nerede ve ne kadar zorlukla olduğu.
3. **Büyük hata rotayı değiştirir.** Bir sayfada kontrolü kaybetmek (suya düşmek, surdan atılmak) Tolga'yı öbür
   tarafın eline düşürür: bir sayfa esir olarak karşı tarafta oynanır, sonra Büro onu geri alır (§3).
4. **Sicil finale yansır.** Son Form'da (Bölüm 14) Nihat'ın raporu dosyadaki iyi ve kötü işleri sayar (§4).
5. **Ölçülür.** `tests/check_outcomes.py`: kendi bölümü dışında okunmayan kuşatma sonucu test hatasıdır (izin listesi
   gerekçesiyle). Okunma yolları: sonuç kimliği başka bir betikte geçer, başka bir betik o bölümün sonucunu sorar ya da
   bölümün bayrağı başka yerde okunur.

## 2. Zincirler

Her satır: kaynak sonuç → hedef sayfa: replik · oynanış. "İyi" ve "kötü" ikisi de bir şey değiştirir.

### 2.1 Osmanlı topu (34o → 35o → 28o → 20o → 32o)
| Kaynak | Hedef | Replik | Oynanış |
|---|---|---|---|
| 34O.2 deneme güllesi kısa düştü | 28o İlk Atış | Urban: "Edirne'de kısa düşmüştü. Bu sefer barutu artırıyorum; arkadan çekilin." | İlk atışta geri tepme büyük: kızak bir kütük geri kaçar, öne taşınacak kütük bir fazla |
| 34O.2 | 20o Gedik | Urban: "Tunç Edirne'de yorulmuştu." | Top bir çatlakla başlar (10B'deki kötü dökümle aynı düzenek, `ch10b_quality < 2` ya da 34O.2) |
| 34O.1 gülle direğin dibine | 28o | Urban Tolga'ya nişanı bırakır: "Edirne'deki gibi." | Nişan bandı geniş (ilk atış) |
| 35O.2 köprü kırıldı / araba kaydı | 28o | Karaca Bey: "Edirne yolunda iki gün kaybettik; batarya yerinde değil." | Kazık evresi yarıya iner (siper yarım: 6 Nisan'da surdan düşen gülleler bir kez daha) |
| 35O.1 | 28o | Öküzcü Tolga'yı tanır, öküzleri ona verir | Kızak çekişinde hey-yap bandı geniş |
| 28O.2 kızak kaydı | 20o | Urban: "Kızak o gün kaydığından beri yatak eğri; nişanı sola al." | Gülle sağa kayar (nişanda sabit sapma) |
| 20o çatlaklar (`gun_cracks`) | 32o | (var) Ali: büyük top o gün susar | (var) |

### 2.2 Osmanlı donanması (29o → 19o → 38o)
| Kaynak | Hedef | Replik | Oynanış |
|---|---|---|---|
| 29O.2 kancalar tutmadı | 19o Devriye | Reis: "Zincirin önünde kancan tutmamıştı. Bu gece kürekte kal." | Gece yanaşmada Tolga'ya kanca verilmez; brigantinin şafak kovalamasında ritim bandı dar |
| 29O.1 kancalar tuttu | 19o | Reis: "Baltaoğlu'nun kadırgasında kanca atan sen miydin?" | Tolga'nın ihbarı (19O.1) yarım inanılır: reis bir kayık yollar, geç kalır (tarih aynı) |
| 29O.x | 38o Haliç Surları | Kadırgadaki tayfa 20 Nisan'ı anar (azledilen Baltaoğlu) | 29O.1: merdiveni tutan biri daha (ibre bandı geniş) · 29O.2: yok |

### 2.3 Bizans Haliç (29 → 17 → 19)
| Kaynak | Hedef | Replik | Oynanış |
|---|---|---|---|
| 29.2 gemi yaralı girdi | 17 Kundak | Cattaneo'nun tayfası karakayı onarıyor, kayıkta yok | Kurtarma kayığında bir kürekçi eksik: suya düşenlere yetişme süresi kısa |
| 29.1 gemi bütün girdi | 17 | Cattaneo'nun iki denizcisi Trevisano'nun kayığında | Kurtarma süresi uzun (fenerli zincir nöbetçileri gibi, 10H) |
| 29.x | 19 Brigantin | Tayfadan biri 20 Nisan'daki karakada Tolga'yı gördü: "Kanca kesen adam" ya da "Ateşi söndüremeyen adam" | Oylamada o tayfa Tolga'nın oyuna göre konuşur |

### 2.4 Bizans karasurları (18b → 30 → 22)
| Kaynak | Hedef | Replik | Oynanış |
|---|---|---|---|
| 18B.2 gülleler suya düştü | 30 Blakherna | Topçu: "Haliç'teki topçu sen misin? Burada tüfek ver ona." | Tüfek atışında nişan bandı dar (merdiven taşıyanlara) |
| 30.2 sur yoluna çıkıldı | 22 Kule | Giustiniani'nin adamı: "Blakherna'da yorgun düştük." | Fıçıları oluğa getiren bir yardımcı eksik (fıçılar arası süre uzun) |
| 30.1 sur yolu tutuldu | 22 | İmparator'un muhafızı Tolga'yı tanır | Kuleye bakan mazgalda kalkan tutan biri (ok yaylımı yok) |

### 2.5 Tek kalan sayfalar
| Kaynak | Hedef | Replik | Oynanış |
|---|---|---|---|
| 37O.1 barikat söküldü / 37O.2 çizik almadı | 26o Şafak | Turgut (azap bölükbaşı) 18 Nisan'ı anar | 37O.1: Turgut'un bölüğü Tolga'nın merdiveninin yanında (tırmanışta taş bir kez az) |
| 31O.x | 14 Son Form | Nihat'ın raporunda Cuma satırı | Sicile sayılır (§4) |
| 25.2, 26.3, 38O.x, 39O.x | 14 Son Form, 27 Galata | Bayrakları okunuyor; sonuçları sicile sayılır | |

## 3. Kaza rotaları: büyük hata öbür tarafa düşürür

| Kaynak | Rota | Sonra |
|---|---|---|
| 17.3 Tolga da suya düştü (Bizans tarafı) | Osmanlı kayıkçıları çeker; bir sayfa esir işçi olarak **18 Fıçı Köprü**'de (Osmanlı tarafı) çalışır | Büro onu geri alır, Bizans sırasına 19'dan döner. 18'in sonucu sicile girer; köprücü usta 26'da anar |
| 30O.2 surdan atıldın (Osmanlı tarafı) | Bizanslılar yakalar; bir sayfa esir olarak **21 Lağım**'ı Grant'in yanında oynar (Türkçe bilen esir: tercüman) | Büro geri alır, Osmanlı sırasına 22o'dan döner. Kasım'ın sorgusunda tercüman Tolga'dır |

Düzenek: `Siege.next_path` bölümün sonucuna bakar (`DETOUR = {"17.3": 18, "30O.2": 21}`); sapma sayfasında
`siege_side` geçici olarak karşı taraftır, kart ve tespit dosyası "esir" etiketi taşır. Sapma bir kez olur.

## 4. Sicil (Son Form)

- Dosyadaki her sayfa iyi (X.1) ya da kötü (X.2, X.3) sayılır; bazı sonuçların ağırlığı farklıdır (26.3 iki iyi).
- Bölüm 14'te Nihat'ın raporuna bir satır: "Tanığın sicili: 9 iyi, 4 kötü." ve bir yorum (üç kademe). Raporun
  daktiloda yazdığı cümle de sicile göre değişir (14.3'te "öneririm" ya da "çekinceyle öneririm").
- Finallerin açılma koşulları değişmez; sicil onların metnine ve Nihat'ın sesine girer.

## 5. Test
- `tests/check_outcomes.py`: kuşatma sonuçlarının okunduğu yerler (çıkış kodu: izin listesi dışında okunmayan varsa 1).
- Her zincirin hedef bölümü autotest'te `--outcome=34O.2` gibi bir kaynakla denenir; replik ve oynanış farkı
  AUTOTEST satırına yazılır.
- Kaza rotaları `siege_route.gd`'de: sapma bir kez, doğru sayfaya, doğru tarafa döner; numaralar kesintisiz.

## 6. Kilometre taşları
| Sürüm | İçerik |
|---|---|
| v0.88 | Büro'nun tespit makinesi (kareler artık makineyle), `check_outcomes.py` |
| v0.89 | Osmanlı topu (34o, 35o, 28o → 28o, 20o) ve 37o → 26o |
| v0.90 | Donanma (29o → 19o, 38o) ve Bizans Haliç (29 → 17, 19) |
| v0.91 | Bizans karasurları (18b → 30 → 22), sicil (Bölüm 14) |
| v0.92 | Kaza rotaları (17.3 → 18, 30O.2 → 21), `check_outcomes.py` paket testine bağlanır |
