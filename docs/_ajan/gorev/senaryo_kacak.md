# Kuralı çiğneyen oyuncuya senaryo: talimden kaçmak, halka vurmak — YAZAR + GELİŞTİRİCİ (Opus)

Önce `docs/_ajan/gorev/_ortak2.md` (kurulum, testler, yasaklar, izin kutusu), `CLAUDE.md`, `docs/WRITERS_BRIEF.md`,
`docs/EVREN.md`, `docs/CITY_LIFE.md`, `docs/ITEM_REACTIONS.md`, `docs/EGLENCE.md` (oyunun dili ve mizahı) oku.
Dalın: `wip/senaryo-kacak`. Kanıt: `docs/_kanit_senaryo_kacak/`.

## Sahibin sözü (12 Kasım, aynen)
"tolgayla savaş eğitiminden kaçtım ne. geçen halka vurmaya çalıştım vurulmadı öyle bir şeye karşı senaryo yazabilriisn"

## Ne demek
Sahibi oyunu oynarken iki şey denedi ve oyun TEPKİSİZ kaldı:
1. **Savaş eğitiminden (talim) kaçtı**: görev alanını bırakıp gitti; kimse bir şey demedi, hiçbir şey olmadı.
2. **Halka vurmaya çalıştı**: vuruş sivillere işlemedi; kimse tepki vermedi.
İstenen: bu tür "kuralı çiğneyen / inat eden oyuncu" davranışlarına oyunun dünyasına ve mizahına uygun SENARYO:
tepki, tırmanma, sonuç. Oyun bir komedi; ceza da komik olmalı, ama dünyanın kuralları ciddiye alınmalı.

## 1. Önce bul ve yeniden üret (rapora yaz)
- Talim hangi bölümlerde? (`scripts/level/training_yard.gd`: `chapter41o.gd`, `chapter42b.gd`; ayrıca Tolga'nın ordugâhtaki
  eğitim/görev sahneleri: `grep -rn "talim\|eğitim\|drill\|train" scripts/ i18n/strings.csv`). Her birinde oyuncu alanı
  terk edince ne oluyor (sınır, görünmez duvar, hiçbir şey)? Ekranlı koşuda dene, kareyle yaz.
- Oyuncu bugün kime, neyle vurabiliyor (`scripts/player/player.gd` `kick`, el eşyaları, yumruk var mı; `Person.kick_hit`;
  savaş bölümlerindeki vuruş düzeni `docs/COMBAT_FEEL.md`)? Sivillere (`CityLife`, `Person`, `Crowd`) vurunca ne oluyor?
- Var olan düzenekler (KULLAN, yeniden yazma): inatçı oyuncu sayaçları ve gizli başarımlar (`GameState` içinde kalıcı
  sayaçlar, tırmanan replikler; `docs/STEAM_ACHIEVEMENTS.md`), "tuhaflığa tepki" ve "herkesle konuşma" düzeni
  (`docs/CITY_LIFE.md`, `scripts/world/city_life.gd`), eşya tepkileri (`docs/ITEM_REACTIONS.md`), Bizans zindanı ve
  tutuklanma sahneleri (Bölüm 7 `byzcell` varyantı, 11 `arrest`), Büro'nun "Kural Sadakati" göstergesi (Nihat),
  paradoks sayacı.

## 2. Senaryoyu yaz (`docs/SENARYO_KURAL_CIGNEME.md`; sahibi okuyacak: kısa, somut, komik)
Her durum için: tetik → 1. tepki → tırmanma (2–4 basamak) → sonuç(lar) → kalıcı iz (sayaç, başarım, sonraki
bölümlerde bir gönderme). En az şu durumlar:
- **Talimden kaçmak** (Osmanlı tarafı talim alanı; varsa Bizans tarafı eşdeğeri): çavuşun/ağanın seslenmesi, arkadan
  koşan nefer, "firari" muamelesi, komik ceza (angarya: kazan karıştırma, at tımarı, hendek kazma: kısa bir mini iş ya
  da ara sahne), ısrar edenler için alternatif sonuç (ör. talimi tamamlamadan cepheye sürülmek ve bunun bedeli;
  ya da zaman yolcusu olduğu için Büro'nun/Hikmet'in devreye girmesi). Kaçış başarılıysa DA bir şey olmalı (kaçtığı
  yerde onu bekleyen bir sahne: boş bir oyun alanı değil).
- **Halka vurmak / tekmelemek** (şehirde ve ordugâhta): ilk vuruşta şaşkınlık ve laf, ikincide kalabalığın tepkisi
  (kaçışma, bağırma, biri karşılık verir: Tolga yere serilir), üçüncüde muhafız/subaşı gelir, sonuç: tutuklanma →
  zindan/falaka/kadı huzuru gibi kısa komik sahne ve bölüme geri dönüş; kalıcı iz: o mahallede Tolga'yı görenler
  söylenir/kaçar (var olan tepki düzeniyle), paradoks ya da "Kural Sadakati" etkisi. Kadına, çocuğa, yaşlıya, din
  adamına vurma girişimi: vuruş HİÇ işlemez (Tolga vazgeçer / araya biri girer / Hikmet telsizden paylar), mizah
  Tolga'nın rezilliği üzerinden; şiddet gösterilmez. Hayvana vurma: hayvan karşılık verir (eşek çiftesi, kaz kovalar).
- **Askere / komutana vurmak**, **Fatih'e ya da İmparator'a el kaldırmak**: anında ve unutulmaz bir sonuç (komik ama
  kesin); varsa var olan sahnelere bağla.
- **Görev vereni bırakıp gitmek / sıradan çıkmak / nöbeti terk** gibi genel "görevden kaçma": bölüm betiklerinin
  kullanabileceği ORTAK bir düzenek (aşağıda).
Yeni replikler: Türkçe ve İngilizce, oyunun üslubunda, kısa. VAR OLAN repliklerin metnine dokunma. Her yeni replik
`i18n/strings.csv`'ye (anahtar, tr, en) ve `docs/voice/VOICE_MAP.csv`'ye (konuşmacı, ton) eklenir; SES ÜRETME (yönetici
üretecek): yeni anahtarların listesini `docs/_kanit_senaryo_kacak/yeni_replikler.txt` olarak ver (satır başına anahtar).

## 3. Uygula
- **Ortak düzenek** (yeni dosya, ör. `scripts/level/kural.gd`): (a) "görev alanını terk" izleyicisi: bölüm bir alan ve
  bir "görev veren" bildirir; oyuncu çıkınca basamaklı tepkiler ve bölümün verdiği sonuç geri çağrısı; (b) "sivile
  vuruş" yakalayıcısı: oyuncunun vuruşu/tekmesi bir kişiye değince (ya da değecekken) kişinin türüne göre tepki,
  kalabalık tepkisi, muhafız çağrısı, sonuç sahnesi; kalıcı sayaçlar. Var olan vuruş/tekme girdisini kullan; yeni tuş yok.
- En az: talim bölümlerinin hepsi + şehir sokakları (`CityLife`'ın çalıştığı bölümler: hub, Ayasofya çevresi, Petrion,
  Galata) + ordugâh (gündüz/gece). Öteki bölümler için düzeneği bağlamanın tek satırlık yolunu belgeye yaz.
- Dengeye ve ana akışa dokunma: bu davranışları YAPMAYAN oyuncu için hiçbir şey değişmez (test botunun yolu, süreler,
  sonuçlar aynı). Yeni sonuçlar için otomatik test varyantları ekle (`tests/run_tests.sh` + bölümün autotest dalı).
- Görsel kurallar: `docs/_ajan/ajan_kurallari.md` (el eşyası elde, vuruş hedefe iner, havada duran nesne yok, birden
  beliren kişi yok: muhafız görüş dışından koşarak gelir).

## 4. Kanıt ve testler
- Her durum için ekranlı kare dizisi (tetik → tepkiler → sonuç), ÖNCE (tepkisiz) | SONRA.
- Değişen bölümlerin bütün eski varyantları + yeni varyantlar başsız PASS; yasak satır yok; `parse_check`,
  `python3 tests/check_keys.py` (ya da eşdeğeri: `tests/check_*.py` hepsi) PASS.
- Rapor: bulduğun bugünkü davranış, senaryonun özeti, yeni replik sayısı, eklenen sayaç/başarım, bağlanan bölümler,
  bağlanmayanlar, sahibin karar vermesi gereken yerler (ceza sahnelerinin sertliği, başarım adları).
- İlk 60 dakikada senaryo belgesinin ilk hâlini gönder (yönetici sahibine özetleyecek); sonra uygulama.
