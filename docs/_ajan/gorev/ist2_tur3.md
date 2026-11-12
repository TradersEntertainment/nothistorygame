# İstanbul v2 — ÜÇÜNCÜ TUR (12 Kasım, 11:00 UTC)

Hepsi önce okur ve uyar: `docs/_ajan/gorev/_ist2_ortak.md` (sondaki "İKİNCİ TUR" ve "SON AYAR": S = 0,35, ünlü eserler
k = 0,75, sur kesiti 1:1, 9–12 bin ev), `docs/_ajan/gorev/ist2_kalite_notlari.md` (0, 0b, 0c ve 1–19: TAMAMI bağlayıcı;
11–19 ikinci turun karelerinden), `docs/_ajan/gorev/_ortak2.md` (kurulum, yasaklar, izin kutusu),
`docs/_ajan/gorev/_istanbul_ortak.md` (oynanış kuralları, Nihat'ın yan görevi), ikinci turun raporları
(`docs/_kanit_ist2_dunya2/rapor.md`, `docs/_kanit_ist2_sehir2/rapor.md`, `docs/_kanit_ist2_doku2/rapor.md`).
Taban dal: `wip/ist2-taban3` (ikinci turun üç dalı + bütün parçalar birleşik). Şehir BUGÜN bitecek.
Sahibin sözleri (hepsi geçerli): "boş alan istemiyorum", "yaşam dolu olacak sokaklar", "ayasofya yakın olsun sura",
"dengeli git: ev sayısı arttır, sur içini küçült, ayasofyayı falan büyüt", "tüm tarihi eserlere özen: nihat hepsinin
üstüne uçup bakma yan görevi var", "yerler hep yeşil … taştan yol yok" (ikinci turda düzeldi; koru).
Dosyalar AYRIK; başkasının dosyasına dokunma (ORTAK İSTEK yaz). Her 30–45 dakikada kendi dalına gönder, öbür dalları
çek ve birleştir; her turda DÜNYA-2'nin sabit 14 "sahip karesi"ni (`tests/_ist/gezi.tscn`, `gezi_sahip.txt`) yeniden
al: `docs/_kanit_<dalın>/sahip_<n>_<ad>.jpg`.

## BAĞLAMA-3 (Opus; dal `wip/ist2-baglama`; kanıt `docs/_kanit_ist2_baglama/`)
Amaç: yeni şehir OYUNDA görünsün. Sahibi oyunu açıp Nihat'la uçtuğunda yeni İstanbul'u görmeli.
Dosyaların: `scripts/world/ist/geo.gd`, `dunya.gd`, `tests/_ist/gezi.*`, YENİ `scripts/world/ist/baglama.gd`, ve yalnız
bağlantı için gereken kadar: `scripts/chapter7.gd`, `scripts/chapter11.gd`, `scripts/world/world_flight.gd`,
`scripts/world/world1453.gd` (ekleme), `scripts/player/nihat_powers.gd` (ekleme), ilgili testler.
1. DÜNYA-2 raporundaki "uçuş bölümleri (7, 11) v2 dökümü"nü uygula: Bölüm 11 (gece uçuşu) ve Bölüm 7'nin uçuş
   kısımları v2 dünyasında oynansın: başlangıç noktaları, tarayıcı hedefleri, ordugâh (IstOrdugah) ve otağ, Tolga'nın
   bulunduğu yer, yan görev işaretleri/formlar/konma noktaları (`IstSehir.flight_data_v2`), uçuş zemini ve su
   yakalayıcıları, tavan, sınırlar (harita dışına çıkınca yumuşak geri çevirme). Replik, süre, sayaç, sonuç, bot
   akışı aynı kalır (konumlar v2 karşılıklarına taşınır); bütün varyantlar başsız PASS (7: on varyant; 11: on varyant),
   `flight_check` v2 için de PASS (yeni eserler dâhil).
2. Güvenlik anahtarı: `IstBaglama.acik` (varsayılan AÇIK; `--eski-dunya` komut satırı ya da ayarla kapatılır): kapalıyken
   bölümler eski `World1453` ile aynen çalışır (iki yol da testte).
3. Bölüm yerde başlıyor/bitiyorsa (7'nin yürüme kısımları, 11'in sonu) o kısımların v2'deki yerleri: ya v2'de (zemin,
   çarpışma, kişiler doğru), ya da açıkça eski dünyada bırakılıp geçiş karartmayla (hangisi olduğunu raporla; yarım
   bırakma: oyuncu boşluğa düşmesin, kişi havada kalmasın).
4. Performans (oyunun kendi RINFO'su, gerçek bölüm içinde): uçuşta ≤ 1 500 çizim / 3,5 M üçgen; yükleme süresi
   (bölüm açılışından ilk kareye) ÖNCE (eski dünya) | SONRA; kurulum takılması (kare süresi > 50 ms sayısı).
5. Kanıt: Bölüm 11 ve 7'den OYUN İÇİ kareler (HUD ile): kalkış, şehrin üstü, her yan görev eserine yaklaşma (en az 12
   eser), Galata'dan dönüş, ordugâhın üstü, gece; ÖNCE (eski dünya) | SONRA. Bir de 60 sn'lik uçuş güzergâhından 20 kare.
6. Sonra (zaman kalırsa): Tolga'nın şehir bölümlerinin (hub: 6b, 7b, 10h, 12b, 23, 24; Ayasofya: 24, 25, 26, 31o) v2'ye
   bağlanması için döküm ve İLK bölüm (12b, mektup) denemesi: oyun alanı `IstSehir.oyun_alanlari()` yerinde, çevrede
   v2 şehri. Tam test PASS olmadan açık bırakma.

## ŞEHİR-3 (Opus; dal `wip/ist2-sehir3`; kanıt `docs/_kanit_ist2_sehir3/`)
Dosyaların: `scripts/world/ist/sehir.gd` (+ yardımcıların), `tests/_ist/sehir2_kare.*`, VE artık parça dosyaları:
`surlar*.gd`, `marmara*.gd`, `halic*.gd`, `galata*.gd`, `hipodrom*.gd`, `forumlar*.gd`, `kemer*.gd`, `kuzeybati*.gd`,
`guneybati*.gd`, `kiliseler*.gd`, `ordugah*.gd`, `gemiler*.gd` (parça oturumları bitti; kusurlarını sen düzeltirsin).
1. Kalite notu 11: uzak sur katmanı (şeritli taş rengi, mazgal silüeti, kule ritmi; gece de doğru).
2. Kalite notu 16: tam tepeden ve uzaktan siyah düz yüzeyler: kök nedeni bul, bitir (rapordaki "elenen nedenler"den devam).
3. Kalite notu 15: sur dışı: ordugâh "çadır denizi" (otağdan Marmara'ya ve Haliç'e; binlerce çadır MultiMesh),
   toplar ve tabyalar, hendek/siperler, sancaklar, at/deve bağları, mutfaklar; kara suru önünde hendek ve dış sur
   okunur; büyük beyaz kutu çadır düzelsin (otağ: kırmızı-altın, dokulu). 30 m ve 70 m'den karede dolu görünmeli.
4. Kalite notu 14: Romanos'un iç yanındaki hub oyun alanına Tolga'nın mektup bölümünün şehri (`ByzCity.far_hub` /
   aynı kurucular; var olan dosyayı değiştirmeden çağır) yerleşsin; Ayasofya meydanı oyun alanı da boş çayır kalmasın
   (döşeme + bölümün uzak görünüşü).
5. Sur üstü yürüyüş: deniz surlarında kule merdiveni (`IstMarmaraSur._tower`: oyuncu 7. basamakta kalıyor) düzelsin;
   gerçek oyuncuyla geçiş: kara ≥ %97, Blakherna ≥ %95, Marmara/Haliç/Galata ≥ %90.
6. Eserler: her yan görev eseri ve ünlü anıt için İRİ kareler (eser başına 15 m üstünden + tam tepe + yerden kapı önü;
   1280×720, tek tek dosya: `eser_<id>_15m.jpg`, `_tepe.jpg`, `_yer.jpg`) ve kendi bakışınla kusur listesi; kusurları
   parça dosyalarında düzelt. Bilinenler: Blakherna Sarayı düz kutu (saray gibi: kemerli pencere sıraları, balkon,
   çatı, avlu), Khora/Pammakaristos küçük ve yalın, Büyük Saray ~ Zeuksippos ~ Nea iç içe, forum sütunu ölçeği,
   halic/Eugenios deniz plakası karanın üstünde, kuzeybati_semt ve forumlar uzak katmanı pahalı.
7. Zaman dilimi: sur dilimi lod 0 (7–34 ms) ve kalan yavaş işler ≤ 6 ms.
8. Denetimler: zeminde delik/kapalı cep (beş mahalle), çatıdan çatıya geçiş oyuncuyla, `flight_data_v2` formları.

## DOKU-3 (Opus; dal `wip/ist2-doku3`; kanıt `docs/_kanit_ist2_doku3/`)
Dosyaların: `scripts/world/ist/sokak.gd`, `evler.gd`, `mahalle_doku.gd`, `hayat*.gd`, `hayat_yakin*.gd`, `ayrinti*.gd`,
`bitki*.gd` (+ yeni yardımcıların), `tests/_ist/doku2_kare.*`.
1. Kalite notu 0c ve 12: SOKAKLAR YAŞAM DOLU. Oyuncunun 60–90 m çevresinde oyunun gerçek kişi modeli
   (`IstHayatYakin`: `wip/ist-hayat-yakin` parçası tabanda; bağla, eksiklerini tamamla), küp figürler yalnız 90 m
   ötesinde ve havadan; geçişte belirme/kaybolma görünmesin. Çarşıda 25+, sık mahallede 10–15 kişi; tezgâhlar dolu,
   hayvanlar, baca dumanı, çamaşır/sancak dalgalanması, martılar; gece pencere ışıkları, kandiller, meşaleler.
   Kişi evin/duvarın içinde, havada, suda durmasın (say).
2. Kalite notu 13: Ayasofya'nın dört yanı, Augustaion, Milion çevresi, Mese'nin iki yanı: taş döşeli meydan, avlu
   duvarları, patrikhane ekleri, mumcu/ikona tezgâhları, ağaçlı avlular; evler bitişik adalar hâlinde (aralıklı tek
   evler kalmasın). Bütün ünlü eserlerin çevresi için aynısı (eser çevresi meydan/avlu + tezgâh + insan).
3. Kalite notu 17 ve 18: döşeme rengi ve dokusu (sıcak gri-krem kireçtaşı/Prokonnesos, düzensiz derz, yer yer kırık
   ve otlu; nane-beyaz dev karo değil); ev ve çatı renklerinde son ayar (ışık altında doygunluk).
4. Kalite notu 19: ISTBOS şehir içi %0 (DÜNYA sayımıyla da); sur dışı 600 m kuşak ve Galata dâhil.
5. Ayrıntı yoğunluğu (Peter'in metnindeki "milyar parça" duygusu, 1453'e uyarlanmış): her sokakta `IstAyrinti`
   öğeleri (fıçı, sepet, amfora, tezgâh, tente, çamaşır ipi, odun yığını, el arabası, kuyu, saksı, kedi…), her
   meydanda bir köşe grubu; iskelelerde ağ, halat, balya; sur dibinde onarım şantiyesi ve mülteci çadırları.
   MultiMesh ile; bütçe içinde (uçuşta ≤ 1 500 çizim / 3,5 M üçgen; yerde ≤ 900 / 2,5 M: ölç).
6. Kanıt: yerden 10 sokak karesi (çarşı, sık mahalle, sur dibi, iskele, Galata, bostan adası; gündüz ve gece), havadan
   30 m ve 70 m, ÖNCE (ikinci tur) | SONRA; `ISTKISI` ve `ISTBOS` sayımları.
