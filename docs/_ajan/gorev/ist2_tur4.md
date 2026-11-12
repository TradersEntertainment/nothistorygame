# İstanbul v2 — DÖRDÜNCÜ TUR (12 Kasım, 15:50 UTC)

Hepsi önce okur ve uyar: `docs/_ajan/gorev/_ist2_ortak.md`, `docs/_ajan/gorev/ist2_kalite_notlari.md` (0, 0b, 0c ve
1–31: TAMAMI bağlayıcı; 20–31 üçüncü turun karelerinden ve sahibinin sözlerinden), `docs/_ajan/gorev/_ortak2.md`
(kurulum, yasaklar, izin kutusu), `docs/_ajan/gorev/_istanbul_ortak.md`, üçüncü turun raporları
(`docs/_kanit_ist2_sehir3/rapor.md`, `docs/_kanit_ist2_doku3/rapor.md`, `docs/_kanit_ist2_baglama/rapor.md`).
Taban dal: `wip/ist2-taban4` (üçüncü turun üç dalı birleşik). Şehir BUGÜN bitecek: ilk gönderim (kareli) 90 dakika
içinde, son rapor en geç 3 saatte.

## Sahibinin bu tura yol açan sözleri (hepsi bağlayıcı)

`docs/_kanit_ist2_sehir3/sahip_03_sur_disi_30m.jpg` karesine bakarak: **"bu görüntü kötü değil mi sence"**. Evet, kötü:
- Sur taş gibi değil, **tahta kaplama gibi**: eşit kalınlıkta açık-koyu şeritler kereste yığını okunuyor.
- Kuleler **kutu** ve **kopuk**: aralarında beden duvarı yok ("surların arası boş, tam değil bazı yerlerde").
- Hendek ve setler **keskin kenarlı yeşil bloklar**; toprak, taş kaplı hendek, çiğnenmiş zemin okunmuyor.
- Sur dışı **bomboş çimen**: kuşatma var ama siper, top, asker yok ("çadırlar böyle mi normalde, ona da çalıştın mı,
  askerler nerde, eksik bir şeyler var mı yok mu").
Önceki sözler de geçerli: "boş alan istemiyorum", "yaşam dolu olacak sokaklar", "ayasofya yakın olsun sura", "tüm
tarihi eserlere özen", "yerler hep yeşil … taştan yol yok" (şehir içinde düzeldi; koru).

## Bu turun ortak kuralları

1. **Kabul ölçütü karedir.** Her oturum, kendi konusundaki "kötü" karelerin AYNI kamera ile yenisini alır ve raporun
   en başına ÖNCE | SONRA paftası koyar. Kare kötüyse madde TAMAM yazılmaz. Rapordaki her "TAMAM" için kare adı
   yazılır; karesiz madde KANITSIZ'dır. Kendi karene sahibinin gözüyle bak: "bu görüntü kötü mü?" sorusuna dürüst cevap
   yaz (raporun ikinci başlığı: "Kendi karelerime bakınca hâlâ kötü olanlar").
2. Dosyalar AYRIK (aşağıda); başkasının dosyasına dokunma, ORTAK İSTEK yaz. `sehir.gd` ve `sehir_eser.gd`'nin sahibi
   ÇEVRE-4'tür; SUR-4 bu iki dosyada YALNIZ surla ilgili işlevlere (uzak sur pişirmesi, `sur_uzak_mat`, `mazgal`,
   `_kapi_gecit`, sur dilimi akışı) dokunur; başka satıra dokunmaz.
3. Her 30–45 dakikada kendi dalına gönder; öbür dört dalı çek ve birleştir (çakışmada karşı tarafın dosyasında onun
   hâli geçerli). Son teslimde beş dal birleşik olarak çalışmalı.
4. Son teslimde DÜNYA-2'nin sabit 14 "sahip karesi" (`tests/_ist/gezi.tscn`, `gezi_sahip.txt`) yeniden alınır:
   `docs/_kanit_<dalın>/sahip_<n>_<ad>.jpg`. Ayrıca raporun sonunda "SAHİBİNE GÖSTERİLECEK 8 KARE" listesi (dosya adı +
   bir satır: karede ne var).
5. Bütçe (oyunun kendi RINFO'su): uçuşta ≤ 1 500 çizim / 3,5 M üçgen, yerde ≤ 1 200 / 2,5 M; kurulumda tek iş ≤ 6 ms
   hedef (aşılanı ölç ve yaz). Kalabalık AZALTILMAZ; bütçe pişirme/MultiMesh/LOD ile tutturulur.
6. Dönem kuralı: Nisan–Mayıs 1453. Minare, hilalli bayrak, Osmanlı camisi şehrin içinde YOK. Tabela/yazı yok.
7. Var olan replik, süre, sayaç, denge, test beklentisi değişmez; denetim susturulmaz.

## SUR-4 (Opus; dal `wip/ist2-sur4`; kanıt `docs/_kanit_ist2_sur4/`)

Dosyaların: `scripts/world/ist/surlar*.gd`, `marmara*.gd`, `halic*.gd`, `galata_sur.gd`, `galata_kule.gd`, YENİ
`sur_*.gd` yardımcıların; `sehir.gd`/`sehir_eser.gd`'de yalnız sur işlevleri (ortak kural 2); sonda
`tests/_ist/sur4_kare.*` (yeni).

1. **Süreklilik (kalite notu 30; en önemli madde).** Kara suru Mermer Kule'den Haliç'e TEK kesintisiz üçlü hat:
   iç sur (beden ~12 m, kuleler 18–20 m, ~55 m arayla, kule bedene GÖMÜLÜ, öne çıkıntılı), peribolos, dış sur (beden
   ~8 m, kuleleri iç kulelerin aralarına denk), parateikhion, mazgallı hendek duvarı, hendek (~18–20 m geniş).
   Blakherna'da tek kalın sur. Deniz surları (Marmara, Haliç) ve Galata suru tek hat, kesintisiz. Dilimler arasında
   boşluk, basamak sıçraması, havada kalan kule, bedensiz kule sırası OLMAYACAK; yamaçta beden eğimi izler ya da kule
   yanında kademelenir (kademe kulede gizlenir). YAKIN, ORTA ve UZAK katmanın üçünde de aynı süreklilik.
   **Ölçüt (sen yazarsın, `--set=surekli`):** her hat boyunca 5 m adımla, hattın dış yanından içe yatay ışın (iç sur için
   yürüme yolu yüksekliğinin 2 m altından; dış sur için ayrı): beden yoksa "boşluk". Çıktı satırı hat başına
   `ISTSURSUREKLI hat=<ad> katman=<yakin|orta|uzak> ornek=N bosluk=K`. Kapılar boşluk değildir (kapı yapısı vardır);
   belgeli gedikler (kuşatma hasarı: Mesoteikhion'da 2–3 yer, moloz + fıçı/kazık tahkimatlı) ayrıca listelenir.
   Hedef: bütün hatlarda, üç katmanda `bosluk=0`.
2. **Taş gibi (kalite notu 27).** Theodosius suru opus mixtum: kalın kireçtaşı blok sıraları (blok derzleri şaşırtmalı,
   ~2 m'lik bant) arasında İNCE kırmızı tuğla şeritleri (5 sıra tuğla, ~0,4 m). Şimdiki eşit kalınlıkta bej-kahve
   şerit "tahta" okunuyor: oranı düzelt, taşın rengi soluk gri-krem (sıcak), tuğla mat kiremit; yer yer yosun/is/akıntı
   lekesi, dip tarafta koyulaşma, bazı kulelerde çatlak ve eksik mazgal (bin yıllık sur). Deniz surları daha kaba, daha
   gri, yamalı. Galata suru Ceneviz: daha düzgün kesme taş, tuğla şeritsiz. Kule tepeleri: mazgal dişi oranı insan
   boyuna göre (diş ~1 m × 1,6 m), kule kapısı/mazgal delikleri, bazılarında ahşap çatı/sundurma, sancak direği.
   Uzak katmanda da aynı oran (uzaktan "çizgili kutu" değil, taş sur silüeti).
3. **Sur dibi arazisi.** `sahip_03` ve `sahip_04`'teki keskin kenarlı yeşil bloklar gitsin: hendeğin iki yanı taş
   kaplı (iç yanda mazgallı alçak duvar), tabanı kuru çamur + yer yer su birikintisi + saz; peribolos ve parateikhion
   çiğnenmiş toprak; sur dışında hendeğe kadar 150–200 m "ateş alanı": ağaçsız, çiğnenmiş, top güllesi çukurlu, kırık
   kalkan/ok/merdiven parçalı toprak (parlak çimen değil; solgun ot + toprak yamaları). Arazi yaması yumuşak eğimli;
   düz renkli tek parça yeşil levha görünmeyecek.
4. **Uzak deniz surları (kalite notu 24):** beyaz blok yığını değil; madde 1–2'nin uzak karşılığı.
5. **Sur üstü yürüyüş** (üçüncü turdan devreden; ikincil): kara ≥ %97, Blakherna ≥ %95, Marmara/Haliç/Galata ≥ %90.
   Süreklilik düzeltmesi bunu bozmasın; ölç ve yaz.
6. **Kapılar:** Altın Kapı (mermer, iki kule, örülü), Pege, Rhegion, Romanos, Kharisios (Edirnekapı), Kaligaria; deniz
   kapıları. Her biri kendi kimliğiyle okunur, kapı kanadı kapalı (kuşatma), önünde hendek köprüsü yıkık/kaldırılmış.
7. Kanıt: aynı kamerayla `sahip_03`, `sahip_04` ÖNCE | SONRA; kara suru boyunca her ~180 m'de (≥ 12 nokta) iki kare:
   dışarıdan 30 m yükseklikten ve yerden 60 m uzaktan; sur üstünden iki yöne; Marmara, Haliç, Galata için dörder kare;
   gece ikişer; uzak katman için 400 m ve 1 km'den dörder kare. Süreklilik satırları raporda tablo.

## ORDUGÂH-4 (Opus; dal `wip/ist2-ordugah4`; kanıt `docs/_kanit_ist2_ordugah4/`)

Dosyaların: `scripts/world/ist/ordugah*.gd` ve YENİ `ordugah_*.gd` yardımcıların; sonda `tests/_ist/ordugah4_kare.*`.
Kaynak: `docs/ORDUGAH_1453.md` (TAMAMINI oku; §2 çadırlar, §3 insanlar ve hayvanlar, §4 toplar, §7a–7e). §7c
"KESİNLİKLE OLMASIN" listesi bağlayıcıdır; raporda madde madde işaretle.

1. §7e'nin 1–9. işleri sırayla (1: ızgara yerine obalar/kümeler, yol koridorları, çap 3–7 m dağılımı; 2: kırmızı bant
   kalkar, ana kitle krem/bej/koyu kıl, kırmızı yalnız otağ ve paşalar; 3: insan ve hayvan; 4: otağ kompleksi; 5: ön
   hat; 6: eksik yerleşkeler; 7: kule ve lağım (tarih kapılı; varsayılan görünüm Nisan sonu); 8: fıçı köprüsü ve Galata
   yamacı bataryası; 9: sancak/tuğ). 10 (ses): yeni ses dosyası ÜRETME; var olan ortam sesleriyle yapılabiliyorsa yap,
   yoksa YAPILMADI yaz.
2. **"Askerler nerde?"** Oyuncunun/kameranın 60–90 m çevresinde oyunun GERÇEK kişi modeli (şehirde `IstHayatYakin`'in
   yaptığı gibi; onun dosyalarına dokunmadan aynı kişi kurucularını çağır), ötesinde hafif figür (MultiMesh), geçişte
   belirme/kaybolma görünmez. Sayılar §3.5: ön hatta 30 m'den görünen ≥ 40 kişi, çadır alanında 30 m yarıçapta 15–25;
   70 m'den karede ≥ 150 figür seçilir. Ne yapıyorlar (§3.3): ocak başında oturan, kazan karıştıran, silah bileyen,
   nöbet tutan, top doldurma ekibi, toprak taşıyanlar, namaz safı, at tımarı, su taşıyan saka, yürüyen bölükler.
   Hayvanlar (§3.4): at kazıkları, deve katarı, öküz arabaları, koyun sürüsü, köpekler. Kişi çadırın içinde, havada,
   hendekte durmaz (say: `ISTORDUKISI icinde=0 havada=0`).
3. **Ön hat sur dışını doldurur:** hendek kenarına kadar siperler, sepet tabyalar, top mevzileri (ana yük Mesoteikhion:
   Şahi + çevresinde batarya), ahşap perdeler, toprak yığınları, merdiven/kalas istifleri, gülle yığınları, barut
   fıçıları (uzakta, çukurda). SUR-4'ün "ateş alanı" zemini ile çakışma: hendekten itibaren ilk 60 m SUR-4'ün zemini,
   ötesi senin; öğe yerleşimini bu sınıra göre yap, ORTAK BİLGİ yaz.
4. **BAĞLAMA uyumu (bozma):** `IstOrdugah.plan` öğe kimlikleri ve `wpt` arayüzü aynı kalır (BAĞLAMA, bölümün kendi
   ordugâh alanındaki öğeleri kimlikle süzüyor: otağ, mescit, pazar, mutfak, kanatlar). Değişen her kimliği/arayüzü
   raporda "ARAYÜZ DEĞİŞİKLİĞİ" başlığında yaz. Bölüm 7 ve 11 başsız varyantları PASS kalır (koş, satırı yaz).
5. **Bütçe (şimdi aşılıyor):** bölümün ordugâhının üstünde 60 m'den v2 payı 8 956 çizim. Hedef: ordugâhın her
   yerinde uçuşta v2 payı ≤ 1 000 çizim, gece dâhil; yerde ≤ 900. Ölç (ÖNCE | SONRA tablo, ≥ 6 nokta).
6. Kanıt: `pafta_ordugah.jpg`'deki altı kameranın aynısı ÖNCE | SONRA; yerden yürüyüş 12 kare (otağ önü, yeniçeri
   obası, Anadolu kanadı, Rumeli kanadı, ordu pazarı, top mevzii, Şahi, siper, at bağları, mutfak, mescit, Zağanos
   yakası); 30 m ve 70 m'den sekiz kare; gece dört kare; her karede sayılan kişi/hayvan sayısı.

## ÇEVRE-4 (Opus; dal `wip/ist2-cevre4`; kanıt `docs/_kanit_ist2_cevre4/`)

Dosyaların: `scripts/world/ist/sehir.gd`, `sehir_eser.gd` (sur işlevleri hariç), `kiliseler*.gd`, `hipodrom*.gd`,
`forumlar*.gd`, `kemer*.gd`, `kuzeybati*.gd`, `guneybati*.gd`, `galata.gd`, `galata_yapi.gd`, `galata_ortak.gd`,
`tests/_ist/sehir2_kare.*`.

1. **Kalite notu 20: Ayasofya'nın dört yanı.** Augustaion (döşeli, Iustinianus Sütunu), atrium ve batı avlusu,
   patrikhane yapıları, Milion, Khalke'ye uzanan revak, kuzeyde Aya İrini'ye bağlanan avlu duvarı, güneyde Zeuksippos;
   aralar döşeli sokak ve avlu, çıplak çayır YOK. 15 m, tepe ve yer karelerinin üçünde de dolu.
2. **Kalite notu 21: eser paleti.** Oyuncak doygunluğu gitsin: tuğla mat kiremit-kızıl (doygunluk ≤ 0,55), kurşun kubbe
   mavi-gri, mermer sıcak kırık beyaz, taş gri-krem; bütün eserlerde tek palet tablosu (`sehir_eser.gd` başında sabitler)
   ve her eserin hangi tonu kullandığı raporda. Ayasofya 1453'te sıvasız tuğla + kurşun kubbe, payandalı, MİNARESİZ.
3. **Kalite notu 22–23:** Aya İrini (düz kutu değil: bazilika gövdesi, kasnaklı kubbe, apsis, atrium), Büyük Saray
   harabeleri (ham basamak blokları değil: yıkık kemer dizileri, yarı ayakta duvarlar, ot bürümüş teraslar, devrik
   sütunlar), Hipodrom (1453'te harap: sphendone ayakta, spina'da Dikilitaş + Yılanlı Sütun + Örme Sütun, oturma
   sıralarının çoğu sökük, içinde otlayan hayvan).
4. **Kalite notu 26, 28, 29:** kırık kareler (`eser_hipodrom_yer`, `eser_halic_eugenios_yer`, hub yer karesi) düzelsin;
   döşeme tonu her meydanda aynı sıcak gri-krem (Tauri'deki nane-beyaz/camgöbeği gölge gitsin); forum döşemesindeki
   düzenli yeşil küreler kalksın (seyrek ot, derz aralarında).
5. **Bütün yan görev eserleri (28) için** `eser_<id>_15m.jpg`, `_tepe.jpg`, `_yer.jpg` yeniden; her eser için bir
   satır hüküm (iyi / orta / kötü + neden) ve "kötü" kalan olmayacak. Forum ovallerinin içi boş kalmasın (anıt, çeşme,
   tezgâh, kişi DOKU-4'ten).
6. Blakherna'daki 128 hücrelik kapalı cep (kare al, çöz); Galata: Ceneviz kolonisi olarak okunur (kule, loca, kiliseler,
   iskeleler, dar sokaklar; dönem kuralı).
7. Kanıt: 28 eserin üç karesi + Ayasofya çevresi için 8 ek kare (dört yandan 15 m ve yerden); ÖNCE | SONRA paftaları.

## DOKU-4 (Opus; dal `wip/ist2-doku4`; kanıt `docs/_kanit_ist2_doku4/`)

Dosyaların: `scripts/world/ist/sokak.gd`, `evler.gd`, `mahalle_doku.gd`, `hayat*.gd`, `hayat_yakin*.gd`,
`ayrinti*.gd`, `bitki*.gd`, `gemiler*.gd`, `tests/_ist/doku2_kare.*`.

1. **Yükleme ve takılma (BAĞLAMA raporu §3 ve ORTAK İSTEK 1–2):** v2 kurulumu bölüm açılışında ~21 sn (doku 14,3).
   Hedef: bölüm açılışından ilk kareye ≤ 10 sn (eski dünya 7 sn), uçuşta > 50 ms kare sayısı ≤ 3. Yol: ilk kareden
   sonraya zaman dilimli kurulum, ağ/doku önbelleği, ortak ağlar. ÖNCE | SONRA ölç (aynı komut, üç koşu ortancası).
2. **Çatıdan çatıya 1/5 → 5/5:** komşu evlerin çatıları arasındaki sırtta oyuncu takılıyor (`IstEvler`); sokaktan
   çatıya çıkış her mahallede ≥ %25 (merdiven, sundurma, sandık istifi, alçak duvar).
3. **Gece Galata'dan şehir karanlık:** pencere ışıkları, kandiller, meşaleler uzak katmanda da (ışık kaynağı değil,
   ışıyan nokta/MultiMesh); surlarda nöbet ateşleri; ordugâh ufku ateşli (ORDUGÂH-4'ün uzak ateşleriyle çakışma: yaz).
4. **Sokak dokusu ikinci geçiş:** Mese ve ana caddeler döşeli ve revaklı; ara sokaklar sıkışık toprak/kaldırım taşı
   karışık; avlular, bostanlar (1453'te sur içinin büyük kısmı bostan, bağ, harabe: boş çayır değil, taş duvarlı
   bostan, kuyu, dut/incir, çardak, yıkık ev). Hub'ın (Romanos iç yanı) çevresindeki v2 sokakları hub'ın caddesiyle
   birleşir (yeşil boşluk kalmaz).
5. **Yaşam:** üçüncü turdaki sayılar korunur; ek: sur dibinde savunmaya taş/su taşıyan halk, kilise önlerinde dua
   edenler, limanda yük indirenler, çocuklar, kediler/köpekler; kuşatma havası (kapalı dükkânlar, yığılmış taş, fıçı).
6. Forum ve meydan içleri (ÇEVRE-4 ile sınır: yapı onun, doku ve kişi senin; ORTAK BİLGİ yaz).
7. Kanıt: 14 sahip karesi + yerden 16 sokak karesi (dört mahalle × dört) + gece sekiz + yükleme tablosu.

## BAĞLAMA-4 (Opus; dal `wip/ist2-baglama4`; kanıt `docs/_kanit_ist2_baglama4/`)

Dosyaların: `scripts/world/ist/geo.gd`, `dunya.gd`, `baglama.gd`, `tests/_ist/gezi.*`, ve yalnız bağlantı için gereken
kadar bölüm dosyaları (aşağıda), `scripts/world/world_flight.gd`, `world1453.gd` (ekleme), `nihat_powers.gd` (ekleme),
harita (`MapView`) için ekleme; ilgili testler. v2 parçalarında YALNIZ "izleyici konumunu okuma" satırları (dönüşümlü
bağlama için `to_local`); başka satıra dokunma, dokunduğun her satırı raporda listele.

1. **Dönüşümlü bağlama (bilinen kusur 1–2):** hub'ın kendi sur parçası v2 kara suruna GÖMÜLÜR (şehrin içinde ikinci
   sur kalmaz); CampDay'in "sura doğru" ekseni v2'de gerçekten sura bakar; yükseklikler v2 arazisine oturur (çanak
   yok). 7 ve 11'in 20 varyantı v2'de, 20'si eski dünyada PASS kalır.
2. **Mini harita v2** (bilinen kusur 3): `MapView` v2'de v2 haritasını gösterir.
3. **Tolga'nın şehir bölümleri v2'ye:** önce 12b (mektup; üçüncü turdaki görsel kusurları listele ve gider), sonra
   sırayla 6b, 7b, 10h, 23, 24, 25, 26, 31o. Her bölüm için: oyun alanı `IstSehir.oyun_alanlari()` yerinde, çevrede v2
   şehri; bütün varyantlar başsız PASS (iki yol: v2 ve `--eski-dunya`); oyun içi 6 kare ÖNCE (eski dünya) | SONRA.
   Bir bölüm YALNIZ kareleri temizse (çifte sur yok, boşluk yok, kişi havada/duvarda yok, ufukta eski dünya yok)
   varsayılan AÇIK olur; değilse KAPALI kalır ve nedeni yazılır. Yarım bırakma yok.
4. Ordugâhta geçen bölümler için döküm (hangi bölüm hangi `CampDay` alanını kullanıyor, v2'de nereye oturur); kod yok.
5. Kanıt: bölüm başına pafta; `rinfo.md` (çizim/üçgen, yükleme süresi, takılma sayısı) ÖNCE | SONRA.
