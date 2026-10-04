# 27 final ve onları açan kararlar (v0.40)

Her finalin kendine ait bir kararı var. Oyunda bu tablo, final sonrası **Vaka Dosyası**'ndaki rotalardır
(`scripts/ui/final_review.gd` `ROUTES`). Öncelik sırası `scripts/chapter15.gd` `_named_final`'dadır: birden
fazla finalin koşulu tutarsa listede üstte olan kazanır.

Bölüm numaraları oyunda görünen numaralardır (oynanış sırası). Dosyalar ve sonuç kimlikleri eski numaralarla kalır:
kuşatma dosyada 17–27, ekranda 13–23; dönüş dosyada 13–15, ekranda 24–26; Gıdak (dosyada 16) gizli bölümdür.

## Yanlış yıl (T3) artık oynanır

Dönüş penceresinde frekans kaçarsa (24.3) Tolga 1977'deki mahalle düğününe düşer. Eskiden final yalnız bir karttı
("Bölüm 2 yakında") ve garajda Hikmet "Evlât servise yetişti" diyordu. Şimdi Bölüm 26'da (dosya 15):

- Garaj: Hikmet duvardaki düğün fotoğrafında kuyruktaki fesliyi görür, frekansı 1977'ye ayarlar (oynanır: A/D, E;
  kilitlenirse geri çağrı penceresi uzar).
- Nihat'ın masası: Vaka 1977-T ("Halay"). Raporda (Bölüm 25) Müfide Hanım şüphelinin 1977'de olduğunu söyler.
- 1977, düğünün ertesi sabahı (Kurtuluş): gazete kulübesinden gazete, iş ilanları, kahvehanede cızırdayan telsiz,
  Emniyet Sigorta'da Ferit Bey'le mülakat (2026'daki müdürün babası). Telsiz net çeker: karar.
  - **Geri Çağrı → 49 Yıl Geç:** kırmızı düğme basılı tutulur; garaja inilir, servis gitmiştir, toplantının sonuna
    yetişilir. Müdür babasının hikâyesini anlatır. Fotoğraf duvarda kalır. Pencere kaçarsa Başka Bir Yıl.
  - **Kal → Başka Bir Yıl:** Tolga acentede işe başlar; bir hafta sonra genç Hikmet sarı elbiseli kızla gelir, ilk
    poliçeyi Tolga yazar. 2026'da Hikmet tezgâhın çekmecesinde o poliçeyi bulur: "Acente: T. Kırmızı düğmeye basma."

## Kuşatma artık finali belirler

Eskiden Heyet'te Bizans'a yardım edince 12B'de dünya doğrudan "1454 / 1455 / Ertelendi" oluyordu. Hemen ardından
kuşatma yine tarihteki gibi oynanıp 29 Mayıs 1453'te fetihle bitiyordu. Bu bir çelişkiydi.

Şimdi 12B yalnız soruyu sorar ("Yaptığın şey yetecek mi?"). Cevabı 29 Mayıs şafağı verir (Bölüm 22 / dosya 26,
`Siege.resolve`):

- Gediğin ağzında bir tüfekçi Giustiniani'ye nişan alır.
  - ⏱ Tolga "Komutan, eğilin!" diye uyarır ya da susar.
  - Uyarı, Heyet'te İmparator'un güvenini kazanan Tolga'yı dinletir (Direniş ≥ 1, Bizans tarafı).
  - Powerbank "zırh ısıtıcısı" komutanın omzundaysa kurşunu tutar.
- Giustiniani ayakta kalırsa hücum püskürtülür ve şehir o sabah düşmez (22.3). Ahitname (Bölüm 23) yazılmaz.
- Ertelemenin türünü kuşatmadaki kararlar belirler:
  - Yaratıcı tercüme (19.2) → **Evrak Eksik**
  - Gedik (16.1/16.2), lağım (17.1) ve kule (18.1) Tolga'nın eliyle → **Uzun Bekleyiş**
  - Yalnız şafak tuttu → **Bir Yıl Daha**
- Şafak tutmazsa (ya da Tolga Osmanlı tarafından tanıklık ettiyse) fetih 1453'te olur → **Bir Akşam**.

## Tablo

| # | Final | Onu açan karar(lar) |
|--:|-------|---------------------|
| 1 | İki Komşu 1453'te | Bölüm 8'de Hikmet makineye biner + Bölüm 24'te pencere kaçar |
| 2 | Mühürlü Garaj | Bölüm 3'te makineye el konur + pencere kaçar |
| 3 | Boş Masa | Pencere kaçar (ya da tutuklanıp Büro'ya katılmaz) |
| 4 | 49 Yıl Geç | Makine yarım tamirle çalıştırılır (24.3) + 1977'de Hikmet'in telsizine cevap verilir, kırmızı düğme (26) |
| 5 | Başka Bir Yıl | Makine yarım tamirle çalıştırılır (24.3) + 1977'de telsiz kapatılır: Tolga Emniyet Sigorta'da işe girer (26) |
| 6 | Kurucu Üye | Arşivde Form Z-1 imzalanır (10A.1) + Büro'ya katılır (25.3) |
| 7 | Gece Mesaisi | Büro'ya katılır (25.3) |
| 8 | Sultan'ın Tamiri | Huzurda Fatih makineyi ister (12.4/12.6) |
| 9 | Evrak Eksik | Heyette yardım + yaratıcı tercüme (19.2) + şafakta Giustiniani ayakta (22.3) |
| 10 | Uzun Bekleyiş | Heyette yardım + gedik, lağım, kule Tolga'nın eliyle + şafak (22.3) |
| 11 | Bir Yıl Daha | Heyette yardım + şafak (22.3) |
| 12 | Bir Akşam | Heyette yardım ama şafak tutmadı: fetih 1453'te |
| 13 | Sultan'ın Sofrası | Ziyafet başarılı (10Z.1) |
| 14 | Venedik'e Elçi | Çandarlı'nın mektubu Venedik gemisine yetişir (10G.1) |
| 15 | Büronun Kuruluşu | Form Z-1'in aslı imzalanır (10A.1) |
| 16 | Tünel Sulhu | Lağımlar karanlıkta barışır (10L.1) |
| 17 | Büyük Patlama | Urban'ın topu patlar (10B.3) |
| 18 | Topçubaşı | Top dökülüp atılır (10B.1/10B.2) |
| 19 | Zaman Tamir Servisi | Nihat istifa eder (25.4) |
| 20 | Yeni Model | Nihat'ın yerine yeni model gelir (25.5) |
| 21 | Pijamalı Kurtarma | Hikmet pijamasıyla gelir (24.4) |
| 22 | Kimse Fark Etmedi | Huzurda Leblebipolis ya da İki Hükümdar (12.2/12.3), düzeltilmez |
| 23 | Saçaktaki Çocuk | Bizans tarafında: üç denizci (13.1) + seldeki çocuk (20.1) + Galata'da "kal" (23.1) |
| 24 | Sakabaşı | Osmanlı tarafında: kadırga yangını (13O.1) + kuledeki marangozlar (18O.1) + kanlı ay çorbası (20O.1) |
| 25 | Kuralsız | Nihat raporu tahrif eder (25.2) |
| 26 | Düzeltildi Ama... | Nihat tarihi düzeltir (25.1), ama dünya değişmişti |
| 27 | Sıradan Bir Pazartesi | Hiçbiri: tarih yerinde |

Test: `--chapter=26 --autotest=hold|hold_box|hold23|hold3|warn_notrust` (hüküm),
`--chapter=15 --autotest=<varyant>` (27 finalin her biri için bir varyant, `tests/run_tests.sh`; T3 için `wrong_recall` ve `wrong_stay`).
