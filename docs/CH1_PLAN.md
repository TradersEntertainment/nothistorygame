# Bölüm 1 — Hikmet'in Garajı: geliştirme planı

Bugünkü hâl: 8 × 6 m boş, mavi ışıklı bir oda; iki halkalı sade bir makine; replik sırası ve çanta seçimi. Oyuncu soğuk
açılıştaki savaştan buraya düşüyor ve fark çok büyük: bölüm sönük kalıyor. Hedef, bölümü "gece üçte, yağmurlu İstanbul'da
çılgın bir mucidin atölyesi" hissine taşımak ve makinenin çalıştığını gözle göstermek.

## B1 · Dışarısı: yağmurlu İstanbul gecesi (03.00)
- Garaj kapısı yarıya kadar açık: kapının altından sokak görünür (kapıdan çıkılmaz, görünmez engel).
- Sokak: ıslak parlak asfalt, kaldırım, su birikintileri, turuncu sokak lambası, brandası yarım Tofaş Şahin, karşıda
  ışıkları yanan apartman pencereleri, üstte uzak minare silueti.
- Yağmur: kapının dışında damlalar ve yerde sıçramalar; ambiyans yağmur ve uzak trafik.
- Arada geçen bir arabanın farları kapının altından garaja süpürülür.

## B2 · İçerisi: dolu, yaşanmış bir atölye
- Sol duvarda alet panosunun üstünde mantar pano: 1453 çizimleri, kâğıtlar, kırmızı iplerle bağlanmış notlar.
- Tezgâhın dibinde uzatma kabloları ve çoklu priz yumağı; priz arada kıvılcım atar.
- Rafta osiloskop (ekranında yeşil dalga oynar), eski radyo, CRT monitör.
- Köşede semaver ve ince belli çay bardakları; lastik yığını; tavanda asılı bisiklet ve açık borular.
- "YÜKSEK GERİLİM" levhası, açık kapaklı sigorta kutusu, yangın söndürücü, pizza kutusu.
- Havada ışıkta süzülen toz zerreleri.

## B3 · Işık
- Soğuk-sıcak zıtlığı: titreşen floresan (mavi-beyaz), tezgâh lambası (sarı), makinenin camgöbeği parıltısı,
  kapının altından turuncu sokak ışığı.
- Makine ısındıkça odanın ışığı makineye göre değişir (floresan titrer, makine ışığı güçlenir).

## B4 · Zamanatör 3000 (bölümün yıldızı)
- İki sütun: bakır bobin sargıları, cam tüpler, ibreli saatler; üstte köprü ve Tesla bobini topu.
- Üç halka jiroskop gibi üç ayrı eksende döner; ortada parlayan çekirdek.
- Sarı-siyah tehlike şeritli taban, yerde kalın kablo demetleri, her yerde koli bandı.
- Durumlar: rölanti (hafif uğultu) → ısınma (halkalar hızlanır, bobinden kıvılcım ve elektrik arkları) → takılma
  (duman, kırmızı alarm ışığı) → kalkış (halkaların ortasında girdap açılır, kâğıtlar ve küçük eşyalar içine çekilir,
  ekran sarsılır, zaman tüneli).

## B5 · Kanıt sahnesi: Hikmet'in terliği
- "Makinede tek sorun var: çalışıyor" repliğinden sonra Hikmet terliğini platforma koyar, kolu çeker; girdap, flaş,
  terlik yok olur. İki saniye sonra geri gelir: içinde bir ok saplıdır. Merak kancası ve makinenin çalıştığının kanıtı.
- Yeni replikler (seslendirme: docs/voice/REGEN_CH1.txt): D1_H_DEMO_1, D1_H_DEMO_2, D1_T_DEMO_3, D1_H_DEMO_4.

## B6 · Açılış ve kalkış sineması
- Açılış: kamera sokaktan, yağmurun içinden yarı açık kapının altından garaja süzülür, Hikmet'e varınca oyuncuya geçer.
- Kalkış: takılma ve tekmeden sonra girdap büyür, eşyalar uçuşur, beyaz patlama, zaman tüneli (2026 → 1453).

## B7 · Doğrulama
- Otomatik testler (Bölüm 1 bütün varyantları, 0 → 1 → 2 zinciri), ekran görüntüleri, 1050 Ti ölçüsünde ışık sayısı
  (gölgeli ışık en çok iki), sürüm ve push.
