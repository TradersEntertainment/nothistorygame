# İstanbul v2 — yöneticinin kalite notları (tur 5 karelerinden; 2. dalga görevlerine girecek)

Kaynak kareler: `docs/_kanit_ist2_sehir/tur_5_*.jpg`, `yer_5_*.jpg` (dal `wip/ist2-sehir`).

1. **Surlar cılız.** Kara surları dışarıdan alçak kahverengi bir çit gibi (k = 0,5 ile iç sur ~6 m; evlerden alçak).
   Oyunun var olan surları gerçek yükseklikte (`Blachernae.WALL_H` ~11–12 m). Karar: bütün surların KESİTİ gerçek boyda
   (k = 1,0: iç sur ~12 m, kuleler ~18–20 m, dış sur ~8,5 m, hendek ~18 m), yalnız UZUNLUK hat boyunca yarı ölçek
   (kule sayısı azalır, aralık gerçek kalır). Sur dışından bakınca üçlü hat ve kuleler ufku kesmeli.
2. **Evler serpiştirilmiş oyuncak gibi.** Havadan (70 m) ev sırası/sokak/ada okunmuyor: aynı pembe-krem duvar ve aynı
   turuncu çatı her yerde, sokak zemini yok (çayırın üstünde evler). İstenen: (a) sokak ZEMİNİ görünür (Mese ve
   forumlar taş döşeme; ara sokaklar sıkışmış toprak/kaldırım; basamaklı yokuşlar), (b) adalar: bitişik sıra + avlu
   duvarı + bahçe/ağaç, (c) çeşitlilik mahalleye göre: taş-tuğla şeritli, kireç badanalı, ahşap çıkmalı, harap; çatı
   kiremidi tonları, yer yer düz dam/teras, sundurma, (d) evlerin çoğu 1–2 katlı (4–6,5 m; 1453'ün yoksul şehri), üç
   katlılar yalnız çarşıda ve Latin mahallelerinde, (e) uzak katmanda evler beyaza dönüyor: uzak/orta/yakın renkleri aynı.
3. **Anıtlar ufukta kaybolmuş.** Galata'dan bakışta Ayasofya ve kubbeler seçilmiyor. Evler alçalınca (2d) düzelir;
   ayrıca kurşun kubbelerin rengi/parlaması, sütunlar ve kemer silüette okunmalı; hafif pus uzak şehri yumuşatsın ama
   silmesin.
4. **Tam tepeden kusurlar:** (a) batıda dikdörtgen MAVİ göl: açık sarnıç (Mokios/Aetios/Aspar) ya da dolmuş liman su
   olarak çizilmiş: 1453'te bostan çukuru, su değil; (b) siyah kareler/dikdörtgenler (uzak katmanda kararan ya da
   malzemesiz yapılar); (c) kıyı çizgisi merdiven gibi basamaklı (arazi ızgarası kaba): kıyı yumuşak eğri olmalı;
   (d) Mese'nin bir kolu düz beyaz çizgi (döşeme mi, kusur mu?).
5. **Sur dışı boş.** Nisan 1453'te sur dışında Osmanlı ordugâhı, bataryalar, hendekler var (parça: `wip/ist-ordugah`).
   Su boş: zincirin arkasında filo, iskelelerde gemiler, Osmanlı donanması (parça: `wip/ist-gemiler`). Sokaklar boş:
   yaşam katmanı (parça: `wip/ist-hayat`).
6. **Zemin:** Mese'de döşeme yok (çayır); Ayasofya meydanı düz çayır: Augustaion döşemesi, meydan taşları, yol izleri.
7. **Ayasofya'nın çevresi boş:** patrikhane ek yapıları, Augustaion, Milion, Aya İrini ile arası; batı avlusu (atrium).
8. **Zaman dilimi:** tek iş 6 ms'yi aşıyor (kuzeybati_semt 148 ms, forumlar 78–104 ms…): yaklaşırken takılma. Ağır
   parçaların lod 0/1 kurulumu bölünmeli (alt parçalara) ya da açılışta ön-pişirilmeli.
9. **Denetim eksikleri:** zeminde delik/kapalı cep ışın ızgarası v2'de koşulmadı; sur üstünde gerçek oyuncuyla yürüyüş;
   çatıdan çatıya geçiş oyuncuyla; kapıların üstünde sur yürüme yolu kesik (kara surunda %9 boşluk).
10. **Halic parçasının konumları yanlıştı** (hepsi Sarayburnu'nda kümelenmiş; şehir oturumu düzeltti): parça kaydı da
    düzeltilmeli. Kiliseler parçasının adlı kiliseleri konumsuz: mahalle kilisesi olarak kullanılıyor (uygun).
