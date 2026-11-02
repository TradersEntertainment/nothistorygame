# Bölüm bölüm eğlence niyeti

Eğlenceyi ölçmenin tek yolu gerçek oyuncu; neyin eğlenceli olması gerektiğine oyunun sahibi karar verir.
Bu tablo ikisini yan yana koyar:

- **Niyet** (sahibi yazar): bu bölümde oyuncu neye gülmeli, ne hissetmeli? Tek cümle.
- **Test** (tools/playtest_report.py doldurur): ortalama eğlence puanı (1-5), ortalama süre, yarıda bırakılma.
- **Karar** (sahibi verir): tut / kısalt / birleştir / yeniden yaz. Claude, niyeti tutmayan ya da puanı düşük
  bölümler için somut öneri (hangi sahne, kaç dakika, ne kesilir) yazar; uygulama onaydan sonra.

Oyun testi: Ayarlar → Oyun testi → "Oyun testine katıl". Dosyalar: Ayarlar → "Test verisini klasörde göster".
Toplama: `python3 tools/playtest_report.py DOSYALAR_KLASÖRÜ -o docs/OYUN_TESTI_SONUC.md`

| Sahne | Başlık | Niyet (sahibi) | Puan | Süre (dk) | Bırakılma | Karar |
|---|---|---|---|---|---|---|
| chapter0 | Soğuk açılış (29 Mayıs 1453, gedik) |  |  |  |  |  |
| chapter1 | BÖLÜM 1 — ZAMANATÖR · Tolga · Pazar gecesi, 03:00 |  |  |  |  |  |
| chapter2 | BÖLÜM 2 — YAĞLI KIZAKLAR · Tolga · 22 Nisan 1453, sabah |  |  |  |  |  |
| chapter3 | BÖLÜM 3 — VAKA 1453-T · Nihat · Zaman Bürosu, zamanın dışında |  |  |  |  |  |
| chapter4 | BÖLÜM 4 — İLK GECE |  |  |  |  |  |
| chapter5 | BÖLÜM 5 — GARAJDA GECE · Hikmet · 2026, pazar gecesi 04:00 |  |  |  |  |  |
| chapter6 | BÖLÜM 6 — ORDUGÂH |  |  |  |  |  |
| chapter7 | BÖLÜM 7 — SAHA ÇALIŞMASI · Denetçi Nihat · 24 Nisan 1453, öğle |  |  |  |  |  |
| chapter8 | BÖLÜM 8 — HIRDAVATÇI · Hikmet · 2026, pazartesi 05:00 · servise iki buçuk saat |  |  |  |  |  |
| chapter9 | BÖLÜM 9 — TEKLİFLER · Tolga · 25 Nisan 1453, sabah |  |  |  |  |  |
| chapter10 | BÖLÜM 10 — ARŞİV |  |  |  |  |  |
| chapter10a | BÖLÜM 10 — ARŞİV · Tolga · 25 Nisan 1453, Bizans arşivi |  |  |  |  |  |
| chapter10b | BÖLÜM 10 — BÜYÜK ATIŞ · Tolga · 25 Nisan 1453, topçu sahası |  |  |  |  |  |
| chapter10g | BÖLÜM 10 — GALATA · Tolga · 25 Nisan 1453, Haliç'in öbür yakası |  |  |  |  |  |
| chapter10h | BÖLÜM 10 — HEYET · Tolga · 25 Nisan 1453, beyaz bayrak altında |  |  |  |  |  |
| chapter10l | BÖLÜM 10 — LAĞIM · Tolga · 25 Nisan 1453, toprağın altında |  |  |  |  |  |
| chapter10z | BÖLÜM 10 — ZİYAFET · Tolga · 25 Nisan 1453, ordugâh mutfağı |  |  |  |  |  |
| chapter11 | BÖLÜM 11 — YÜZLEŞME · Nihat ve Tolga · 25 Nisan 1453, gece |  |  |  |  |  |
| chapter12 | BÖLÜM 12 — HUZUR · Tolga · 26 Nisan 1453, sabah · Padişah'ın otağı |  |  |  |  |  |
| chapter12b | BÖLÜM 12 — SON AKŞAM · Tolga · 26 Nisan 1453, surlarda gün batımı |  |  |  |  |  |
| chapter13 | BÖLÜM {N} — DÖNÜŞ PENCERESİ · Hikmet · 2026, pazartesi 07:15 · servise 15 dakika |  |  |  |  |  |
| chapter14 | BÖLÜM {N} — SON FORM · Nihat · Zaman Bürosu, zamanın dışında |  |  |  |  |  |
| chapter15 | BÖLÜM {N} — PAZARTESİ · Final |  |  |  |  |  |
| chapter16 | GİZLİ BÖLÜM — GIDAK · Sinerji · 90 saniye |  |  |  |  |  |
| chapter17 | BÖLÜM {N} — KUNDAK · 28 Nisan 1453 · Haliç · şafaktan iki saat önce |  |  |  |  |  |
| chapter17o | BÖLÜM {N} — KUNDAK (ORDUGÂH) · 28 Nisan 1453 · Haliç'in kuzey kıyısı · kıyı topları |  |  |  |  |  |
| chapter18 | BÖLÜM {N} — FIÇI KÖPRÜ · Mayıs başı 1453 · Haliç'in iç ucu · Osmanlı kıyısı |  |  |  |  |  |
| chapter18b | BÖLÜM {N} — FIÇI KÖPRÜ (SURLAR) · Mayıs başı 1453 · Haliç surları · öğle |  |  |  |  |  |
| chapter19 | BÖLÜM {N} — BRİGANTİN · 3 Mayıs 1453 · Haliç · gece yarısı |  |  |  |  |  |
| chapter19o | BÖLÜM {N} — DEVRİYE (ORDUGÂH) · 3 Mayıs 1453 gecesi · Haliç'in ağzı, zincirin dışı |  |  |  |  |  |
| chapter20 | BÖLÜM {N} — GEDİK · 7 Mayıs 1453 · Kara surları, Lykos vadisi · gece |  |  |  |  |  |
| chapter20o | BÖLÜM {N} — GEDİK (ORDUGÂH) · 7 Mayıs 1453 · Urban'ın büyük topu · gündüz |  |  |  |  |  |
| chapter21 | BÖLÜM {N} — LAĞIM · 16 Mayıs 1453 · Mesoteichion · gece |  |  |  |  |  |
| chapter21o | BÖLÜM {N} — LAĞIM (ORDUGÂH) · 16 Mayıs 1453 · Zağanos Paşa'nın lağımı · toprağın altı |  |  |  |  |  |
| chapter22 | BÖLÜM {N} — KULE · 18 Mayıs 1453 · Mesoteichion · şafak |  |  |  |  |  |
| chapter22o | BÖLÜM {N} — KULE (ORDUGÂH) · 17 Mayıs 1453 gecesi · hendeğin önü |  |  |  |  |  |
| chapter23 | BÖLÜM {N} — ELÇİ · 21 Mayıs 1453 · Blakherna Sarayı |  |  |  |  |  |
| chapter24 | BÖLÜM {N} — ALAMETLER · 24 Mayıs 1453 · Konstantinopolis · Hodegetria alayı |  |  |  |  |  |
| chapter24o | BÖLÜM {N} — ALAMETLER (ORDUGÂH) · 22 Mayıs 1453 gecesi · ordugâh |  |  |  |  |  |
| chapter25 | BÖLÜM {N} — SON AKŞAM · 27 Mayıs 1453 · Osmanlı ordugâhı · gece |  |  |  |  |  |
| chapter26 | BÖLÜM {N} — ŞAFAK · 29 Mayıs 1453 · Mesoteichion · gece 01.30 |  |  |  |  |  |
| chapter26o | BÖLÜM {N} — ŞAFAK (ORDUGÂH) · 29 Mayıs 1453 · hendeğin önü · gece 01.30 |  |  |  |  |  |
| chapter27 | BÖLÜM {N} — AHİTNAME · 1 Haziran 1453 · Galata · öğleden sonra |  |  |  |  |  |
| chapter28o | BÖLÜM {N} — İLK ATIŞ (ORDUGÂH) · 6 Nisan 1453 · Kara surlarının önü · Urban'ın bataryası |  |  |  |  |  |
| chapter29 | BÖLÜM {N} — ZİNCİRİN ÖNÜ · 20 Nisan 1453 · Haliç'in ağzı · Ceneviz karakası |  |  |  |  |  |
| chapter29o | BÖLÜM {N} — ZİNCİRİN ÖNÜ (DONANMA) · 20 Nisan 1453 · Haliç'in ağzı · öğleden sonra |  |  |  |  |  |
| chapter30 | BÖLÜM {N} — BLAKHERNA · 12 Mayıs 1453 · saray önündeki surun yürüyüş yolu · gece yarısı |  |  |  |  |  |
| chapter30o | BÖLÜM {N} — BLAKHERNA (ORDUGÂH) · 12 Mayıs 1453 · Blakherna sarayı önündeki sur · gece yarısı |  |  |  |  |  |
| chapter31o | BÖLÜM {N} — CUMA · 30 Mayıs – 1 Haziran 1453 · şehir, Eyüp, Ayasofya |  |  |  |  |  |
| chapter32o | BÖLÜM {N} — SON GÜN · 28 Mayıs 1453 · Lykos vadisi, hendeğin önü · oruç günü |  |  |  |  |  |
| chapter33o | BÖLÜM {N} — BOĞAZKESEN · 31 Ağustos 1452 · Boğaziçi, Rumeli kıyısı · yeni hisar |  |  |  |  |  |
| chapter34o | BÖLÜM {N} — TUNCUN SESİ · Ocak 1453 · Edirne, Tunca kıyısı · Urban'ın döküm yeri |  |  |  |  |  |
| chapter35o | BÖLÜM {N} — EDİRNE YOLU · Mart 1453 · Trakya, taşkın bir derenin kıyısı · konvoyun önü |  |  |  |  |  |
| chapter36b | BÖLÜM {N} — HURUÇ · 9 Nisan 1453 · Mesoteichion'un önü · şafaktan önce |  |  |  |  |  |
| chapter37o | BÖLÜM {N} — İLK HÜCUM · 18 Nisan 1453 · Mesoteichion, barikatın önü · gece |  |  |  |  |  |
| chapter38o | BÖLÜM {N} — HALİÇ SURLARI (DONANMA) · 29 Mayıs 1453 · Haliç, Petrion önü · gece 01.30 → öğle |  |  |  |  |  |
| chapter39o | BÖLÜM {N} — EMANET · 29 Mayıs 1453 · Petrion mahallesi, Haliç kıyısı · akşam |  |  |  |  |  |
| chapter41o | BÖLÜM {N} — TALİM · 17 Nisan 1453 · Ordugâhın talim meydanı · öğleden sonra |  |  |  |  |  |
| chapter42b | BÖLÜM {N} — TALİM · 7 Nisan 1453 · Surların içi, Mesoteichion'un ardındaki meydan · sabah |  |  |  |  |  |
| chapter43o | BÖLÜM {N} — KUŞBAKIŞI · 25 Mayıs 1453 · Sultan'ın otağı · öğleden sonra |  |  |  |  |  |
