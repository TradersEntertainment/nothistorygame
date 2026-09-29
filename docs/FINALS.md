# 26 final ve onları açan kararlar (v0.40)

Her finalin kendine ait bir kararı var. Oyunda bu tablo, final sonrası **Vaka Dosyası**'ndaki rotalardır
(`scripts/ui/final_review.gd` `ROUTES`). Öncelik sırası `scripts/chapter15.gd` `_named_final`'dadır: birden
fazla finalin koşulu tutarsa listede üstte olan kazanır.

Bölüm numaraları oyunda görünen numaralardır (oynanış sırası). Dosyalar ve sonuç kimlikleri eski numaralarla kalır:
kuşatma dosyada 17–27, ekranda 13–23; dönüş dosyada 13–15, ekranda 24–26; Gıdak (dosyada 16) gizli bölümdür.

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
| 4 | Başka Bir Yıl | Makine yarım tamirle çalıştırılır (24.3) |
| 5 | Kurucu Üye | Arşivde Form Z-1 imzalanır (10A.1) + Büro'ya katılır (25.3) |
| 6 | Gece Mesaisi | Büro'ya katılır (25.3) |
| 7 | Sultan'ın Tamiri | Huzurda Fatih makineyi ister (12.4/12.6) |
| 8 | Evrak Eksik | Heyette yardım + yaratıcı tercüme (19.2) + şafakta Giustiniani ayakta (22.3) |
| 9 | Uzun Bekleyiş | Heyette yardım + gedik, lağım, kule Tolga'nın eliyle + şafak (22.3) |
| 10 | Bir Yıl Daha | Heyette yardım + şafak (22.3) |
| 11 | Bir Akşam | Heyette yardım ama şafak tutmadı: fetih 1453'te |
| 12 | Sultan'ın Sofrası | Ziyafet başarılı (10Z.1) |
| 13 | Venedik'e Elçi | Çandarlı'nın mektubu Venedik gemisine yetişir (10G.1) |
| 14 | Büronun Kuruluşu | Form Z-1'in aslı imzalanır (10A.1) |
| 15 | Tünel Sulhu | Lağımlar karanlıkta barışır (10L.1) |
| 16 | Büyük Patlama | Urban'ın topu patlar (10B.3) |
| 17 | Topçubaşı | Top dökülüp atılır (10B.1/10B.2) |
| 18 | Zaman Tamir Servisi | Nihat istifa eder (25.4) |
| 19 | Yeni Model | Nihat'ın yerine yeni model gelir (25.5) |
| 20 | Pijamalı Kurtarma | Hikmet pijamasıyla gelir (24.4) |
| 21 | Kimse Fark Etmedi | Huzurda Leblebipolis ya da İki Hükümdar (12.2/12.3), düzeltilmez |
| 22 | Saçaktaki Çocuk | Bizans tarafında: üç denizci (13.1) + seldeki çocuk (20.1) + Galata'da "kal" (23.1) |
| 23 | Sakabaşı | Osmanlı tarafında: kadırga yangını (13O.1) + kuledeki marangozlar (18O.1) + kanlı ay çorbası (20O.1) |
| 24 | Kuralsız | Nihat raporu tahrif eder (25.2) |
| 25 | Düzeltildi Ama... | Nihat tarihi düzeltir (25.1), ama dünya değişmişti |
| 26 | Sıradan Bir Pazartesi | Hiçbiri: tarih yerinde |

Test: `--chapter=26 --autotest=hold|hold_box|hold23|hold3|warn_notrust` (hüküm),
`--chapter=15 --autotest=<varyant>` (26 finalin her biri için bir varyant, `tests/run_tests.sh`).
