# İstanbul, Nisan 1453: araştırma ve yer dizini — ARAŞTIRMACI (Sonnet)

Türkçe çalış. Soru sorma, plan sunma, onay bekleme: başla, bitir, gönder. Dalın: `wip/istanbul-arastirma`.
Oyun kodunu DEĞİŞTİRME; yalnız aşağıdaki iki belgeyi yaz. İzin kutusu çıkaracak komut yazma (rm -rf / mv / cp -r
hedefinde kabuk değişkeni yok; `bash -c` içinde bekleme döngüsü yok; sudo yok). Alt ajan ya da başka oturum başlatma.
PR açma, main'e dokunma.

## Sahibin sözü (12 Kasım, aynen)
"kanka bence sen önce 1453 nisanda istanbul nasılmış ona çalış sonra bence bölümleri içine sığdırırız, peter çok
detaylı istanbul yapmış ya günümüz o promtpları örnek al bunu 1453 nisan yap ve şekiller vs bizim oyna uysun tolganın
tırmanabileceği içinden düşmeyeceğimiz şekilde falan olsun bizim şu anki tolganın mektup bölümündeki evleri
kullanabilirsin şekil olarak galiba"

Oyun: "Gerçek Tarih Bu Değil", Godot 4.4.1, 1453 kuşatmasında geçen birinci şahıs komedi; her şey kodla çizilir
(düşük poligonlu, çizgi film görünümü). Şehir tek haritadır (`scripts/world/world1453.gd`); şimdi o haritayı Nisan
1453'ün gerçek Konstantinopolis'ine dayandıracağız. Günümüz İstanbul'u için yazılmış ayrıntı örneği:
`docs/_ajan/istanbul_prompt.txt` (ayrıntı YOĞUNLUĞUNU al; içindeki 1453'te olmayan her şeyi ayıkla).

## Teslim 1: `docs/ISTANBUL_1453.md` (kalıcı belge; kaynaklı, taranabilir)
WebSearch / WebFetch ile araştır (Bizans topografyası: Müller-Wiener, Janin, Mango, Magdalino, Kuban; kuşatma
tanıkları: Barbaro, Kritovulos, Sphrantzes, Leonardo, Tursun Bey; Buondelmonti 1422 haritası; Byzantium 1200 projesi;
Vikipedi maddeleri başlangıç için uygun). Her bölümde kaynak adı ver; emin olmadığını "BELİRSİZ" yaz, uydurma.
1. **Genel görünüş, Nisan 1453:** nüfus (yaklaşık 40–50 bin), surların içinde köy köy dağılmış mahalleler, aralarda
   tarla, bağ, bostan, harabe; hangi kesimler sık, hangileri boş. Mevsim: bitki örtüsü, çiçek, hava, ışık.
2. **Yeryüzü:** yedi tepe, Lykos (Bayrampaşa) deresi vadisi, Haliç, Marmara, Boğaz girişi; yükseklikler (m).
3. **Surlar ve kapılar:** Theodosius kara surları (iç sur, dış sur, peribolos, hendek; kule sayısı, yükseklikler,
   taş-tuğla şerit örgü), Blakhernai suru, Haliç ve Marmara deniz surları; kapıların hepsi kuzeyden güneye adlarıyla
   (Bizans adı, bugünkü adı, 1453'teki durumu, kim savundu). Mesoteikhion. Zincir (Eugenios kulesi–Galata).
4. **Anıtlar, 1453'teki hâliyle (her biri: yeri, ölçüsü, malzemesi, rengi, durumu):** Ayasofya (minare YOK), Augustaion
   ve Iustinianus Sütunu, Hipodrom (harap; dikilitaşlar, Yılanlı Sütun, sphendone), Büyük Saray (harabe), Bukoleon,
   Konstantin Forumu ve Sütunu, Theodosius/Tauri Forumu, Arkadius Sütunu, Bozdoğan (Valens) Kemeri, Havariyun
   (harap), Pantokrator, Khora, Pammakaristos, Studios, Peribleptos, Lips, Myrelaion, Blakhernai Sarayı ve Tekfur
   Sarayı, Anemas zindanları, Altın Kapı ve Yedikule'nin öncülü, açık sarnıçlar (Aetios, Aspar, Mokios: bostan),
   kapalı sarnıçlar, Mese ve kolları, limanlar (Kontoskalion, dolmuş Eleutherios/Langa bostanları, Neorion,
   Prosphorion), Haliç kıyısındaki Venedik/Ceneviz/Pisa/Amalfi mahalleleri ve iskeleleri, Yahudi mahallesi.
5. **Galata (Pera):** Ceneviz kolonisi, surları, Christea Turris (kule), kiliseler, iskeleler, tarafsızlık.
6. **Sıradan yapılar:** geç Bizans evi (taş/tuğla zemin kat, ahşap çıkmalı üst kat, kiremit çatı, avlu, kuyu), dükkân,
   han, fırın, değirmen, hamam, manastır avlusu, küçük kilise tipleri (haç planlı, kubbeli), çeşme, mezarlık, bağ
   duvarı, harabe türleri. Ölçü aralıkları (cephe genişliği, kat yüksekliği, sokak genişliği).
7. **Sokak hayatı ve ayrıntı dizini (en az 150 madde, mahalle türüne göre):** tezgâh, tente, amfora, fıçı, balık ağı,
   çamaşır ipi, kümes, güvercinlik, eşek, el arabası, ikona nişi, haç, kandil, sur onarım iskelesi, taş yığını,
   mülteci çadırı, ayin alayı… Peter'in metnindeki her ayrıntının 1453 karşılığı ya da "YOK" notu.
8. **Kuşatma, Nisan 1453 günlüğü:** 2 Nisan zincir, 5–7 Nisan ordunun yerleşmesi, 12 Nisan donanma, 18 Nisan ilk
   hücum, 20 Nisan deniz savaşı, 22 Nisan gemilerin karadan yürütülmesi, köprü, top bataryalarının yerleri (Şahi,
   kapılara göre), ordugâh düzeni (otağ, Rumeli/Anadolu kanatları, Zağanos Paşa'nın Haliç ötesindeki kolu), Çifte
   Sütunlar (Diplokionion) donanma üssü, Rumeli Hisarı (1452) ve Anadolu Hisarı.
9. **OLMAYANLAR (anakronizm listesi):** minare, Osmanlı camileri (Sultanahmet, Süleymaniye, Fatih…), Galata Köprüsü,
   Topkapı Sarayı, Kapalıçarşı, vapur, bugünkü Kız Kulesi biçimi, lale, domates/mısır/patates/tütün, vb.
10. **Oyunun bilerek tarihe uymadığı yerler** (komedi): yalnız not et, düzeltme önerme.

## Teslim 2: `docs/ISTANBUL_YERLER.csv` (yer dizini; makine okur)
Sütunlar: `ad_tr, ad_bizans, tur (kapi|kule|kilise|manastir|saray|forum|sutun|sarnic|liman|mahalle|iskele|kopru|
ordugah|batarya|diger), enlem, boylam, dogu_m, kuzey_m (Ayasofya kubbesi 0,0 kabul edilerek metre), olcu_m (en x boy
x yükseklik), durum_1453, kaynak, not`. En az 120 satır: bütün kapılar, bütün anıtlar, mahalle merkezleri, limanlar,
iskeleler, Galata, kuşatma mevzileri. Koordinatı bilinmeyeni komşularına göre kestir ve `not` sütununa "kestirim" yaz.

## Çalışma düzeni
İlk 40 dakikada belgenin iskeletini ve yer dizininin ilk 60 satırını kaydedip gönder (başka bir oturum bunları
bekliyor); sonra derinleştir, her 30–40 dakikada bir kaydet ve gönder. Bitince son hâli gönder ve
`docs/ISTANBUL_1453.md`'nin başına "DURUM: TAMAM" yaz.
