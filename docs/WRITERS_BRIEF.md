# Yazar Brifi: Dışarıda (başka bir yapay zekâ ya da insan) metin yazanlar için

Bu belge, oyunun koduna dokunmadan **metin** üretecek bir yardımcıya olduğu gibi verilir. Kod, test, seslendirme ve sürüm
bu depoda yapılır; dışarıdan yalnız yazı gelir, buraya bir dosya olarak bırakılır ve içeride bağlanır.

## Neden yalnız metin

`i18n/strings.csv` (~8000 satır) ve `scripts/` aynı anda iki yerden düzenlenirse çakışır. Bir repliği oyuna sokmak da
yalnız satır eklemek değildir: kimin söylediği (ses), hangi bayrağa bağlı olduğu, testlerin onu bulması gerekir. Bu yüzden
dışarıdan gelen her şey **ayrı bir CSV dosyası** olarak `docs/incoming/` altına konur; ana dosyaya içeride taşınır.

## Teslim biçimi

`docs/incoming/<konu>.csv`, UTF-8, başlık satırı:

```
anahtar,tr,en,konusmaci,bolum,kosul,not
```

- **anahtar**: `D<bölüm>_<KISALTMA>_<AD>` (ör. `D37O_HZ_SALLY`). Kısaltmalar: `T` Tolga, `N` Nihat, `H` Hikmet,
  `HZ` Hızır, `LN` Leon, `AB` Azap Bölükbaşı Turgut, `GIUST` Giustiniani. Yeni karakterse `not`ta söyle.
- **tr / en**: ikisi de dolu. İngilizce çeviri değil, aynı espriyi İngilizcede yeniden kur.
- **konusmaci**: `SPK_TOLGA`, `SPK_NIHAT`, `SPK_AZAP` (Hızır), `SPK_DEFENDER` (Leon), `SPK_AZAPBASI` (Turgut)...
- **kosul**: replik hangi durumda söylenir (ör. "41O.1 ise", "hizir_fell", "Bizans tarafı").
- **not**: sahne, ton ([shouting], [whispers] gibi ses etiketleri buraya, metnin içine değil).

## Kurallar (testler bunları zaten yakalar; baştan uymak zaman kazandırır)

1. **Rota tutarlılığı.** Replik, oyuncunun o rotada yaşamadığı bir olayı, tanışmayı ya da eşyayı varsaymaz. Bir şeyi
   hatırlatan replik her zaman bir `kosul` taşır.
2. **Uzunluk.** Bir altyazı en çok ~160 karakter. Daha uzunsa iki replik yaz.
3. **Tarihî kişiler ciddidir** (GDD §3, sütun 2). Fatih, Konstantinos, Giustiniani, Halil Paşa aklı başında konuşur;
   komedi Tolga'dan ve durumdan çıkar.
4. **Tarih.** Tarih, yer ve olay kaynaklı olsun (Runciman, Sphrantzes, Barbaro, Tursun Bey, Kritovulos). Uydurma bir
   ayrıntıysa `not`ta "uydurma" yaz.
5. **Tolga'nın sesi.** Kendinden emin, yarı bilgili, belgesel bağımlısı; 2026 göndermeleri (telefon, kargo, dizi) yapar
   ama 1453'teki herkes ondan zekidir. Küfür yok.
6. **Tuş adı yazma** ("F'ye bas" değil, "tekmele"); tuşlar ayarlardan değişebilir, ipucu arayüzde ayrıca çıkar.

## Okunacaklar

- `docs/GDD.md`: ton, karakterler, tasarım sütunları
- `docs/CHAPTERS.md`, `docs/SIEGE.md`: bölümler ve kuşatma takvimi
- `docs/BRANCHING_V2.md`, `docs/BRANCHING_V3.md`: bayraklar, sonuçlar, akıbet sayfaları
- Her bölümün betiğinin başındaki yorum (`scripts/chapterXX.gd`, ilk 20 satır): o bölümün akışı ve sonuçları

## İyi iş paketleri

- Bir bölümün yeni dallarına replik taslakları (koşullarıyla birlikte)
- Bölüm 15 "İnsanların Akıbeti" ve "Eşyaların Akıbeti" için yeni kişi/eşya satırları ve 2026 izleri
- İngilizce sütunun okunması: doğal olmayan, espriyi kaçıran satırlar (`anahtar,en_onerilen,neden`)
- Tarih denetimi: bölüm başlıklarındaki tarih/yer/olay iddiaları ve kaynakları
- Mağaza sayfası, site ve fragman metinleri
