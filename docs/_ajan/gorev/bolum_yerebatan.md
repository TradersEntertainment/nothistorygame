# Yeni bölüm: Yerebatan Sarnıcı (Bizans tarafı) — TASARIMCI + YAZAR + GELİŞTİRİCİ (Opus)

Önce `docs/_ajan/gorev/_ortak2.md` (kurulum, testler, yasaklar, izin kutusu), `CLAUDE.md`, `docs/WRITERS_BRIEF.md`,
`docs/EVREN.md`, `docs/CHAPTERS.md`, `docs/STORY_BRANCHES.md`, `docs/BYZANTINE_MIRROR.md`, `docs/SIEGE.md`,
`docs/EGLENCE.md`, `docs/COMBAT_FEEL.md`, `docs/QA_DERSLER.md` (son dersler), `docs/_ajan/ajan_kurallari.md` oku.
Dalın: `wip/bolum-yerebatan`. Kanıt: `docs/_kanit_yerebatan/`.

## Sahibin sözü (12 Kasım, aynen)
"bizansa yerebatan sarnıcı bölümü ekleyelim hem manzara hayranlık yaratsın hem de heyecanlı bi bölüm olsun"

## İki hedef (ikisi de şart)
1. **Hayranlık:** oyuncu sarnıca girdiği an durup bakmalı: 336 sütunluk orman (12 sıra × 28; ~9 m yükseklik; 138 × 65 m:
   oyunda gerçeğe yakın boyda kur), tuğla çapraz tonozlar, sütun başlıkları (Korint/İon/yalın karışık, devşirme),
   "gözyaşı" (tavus gözü) sütunu, iki Medusa başı (biri yan, biri ters), sütunların durgun suda yansıması, tavandaki
   kuyu ağızlarından inen ışık huzmeleri ve toz, damlalar ve halkaları, sudaki balıklar (sazan), yosun/kireç izleri,
   su çizgisi, yankı, uzaklaşan karanlık. 1453'te sarnıç DOLU ve kullanımda (saray ve çevre su alıyor; üstteki evlerin
   zeminindeki kuyulardan kovayla su ve balık çekilir): araştır (WebSearch: Basilica Cistern, Gyllius'un anlatısı,
   Bizans'ta kullanımı), kaynaklı kısa not yaz. Işık kaynakları: kuyu huzmeleri, meşale/kandil, Tolga'nın telefon
   ışığı ve çakmağı (oyunda var), suyun tavana vuran kıpırtılı yansıması (kostik: gölgelendirici).
2. **Heyecan:** oynanış tempolu ve gerilimli; oyunun var olan düzeneklerinden kur (sandal/kürek: Bölüm 17, 19, 38o;
   tırmanma ve dar yerde yürüme: 6b labirent, Ayasofya tırmanışı; gizlenme/kaçış; zamanlı işler; `Handover`; telefon/
   çakmak ışığı). Örnek omurga (daha iyisini bulursan onu yaz): Tolga bir işi için (mesaj, kaçış, bir şeyi saklama ya da
   kurtarma, surlara gizli su yolu, Bizanslıların sakladığı bir emanet…) sarnıca iner → sandalla sütunların arasında
   karanlıkta yol bulma (ışık yönetimi) → top atışlarının sarsıntısıyla tonozdan parçalar düşmesi, su baskını ya da
   kovalamaca → Medusa başlarının orada bir bulmaca/geçit → çıkış: bir kuyudan yukarı, beklenmedik bir yere (bir evin
   mutfağı, saray kileri, Ayasofya'nın bodrumu). En az iki sonuç (başarı/başarısız ya da iki farklı çıkış) ve bunların
   sonraki bölümlere etkisi (var olan dallanma düzeniyle: `GameState` bayrakları; `docs/STORY_BRANCHES.md`).
   Komedi oyunun dilinde: Tolga 2020'lerden geliyor ("burası müze, girişi şu kadar lira", selfie çubuğu, Medusa'nın
   neden ters durduğuna dair herkesin başka bir teorisi, Hikmet'in telsiz yorumları).

## Yer ve zaman (karar ver, gerekçesiyle yaz)
Bizans tarafı akışında nereye girer? (aday: Tolga'nın şehir içi bölümlerinin arası: 12b mektup, 23, 24 Ayasofya
çevresi; ya da 10'un Bizans dalı; kuşatma takvimi `docs/CHAPTERS.md`.) Var olan bölüm sırasını ve bağlantılarını bozma:
yeni bölüm ya bir bölümün içinden açılan yan yol, ya iki bölüm arasına eklenen yeni halka (bağlantı ve kayıt uyumu:
eski kayıtlar çalışmaya devam eder). Bölüm kimliği için var olan adlandırmaya uy (ör. `24y` ya da boş bir numara);
`tests/run_tests.sh`, bölüm seçme/harita ekranı, başarımlar, `docs/CHAPTERS.md` güncellenir.

## Teslimler (sırayla)
1. **İlk 45–60 dakika: tasarım belgesi** `docs/BOLUM_YEREBATAN.md` (sahibi okuyacak: 1–2 sayfa): hikâyedeki yeri,
   akış (vuruş vuruş), oynanış düzenekleri, sonuçlar ve etkileri, replik taslağı (tr), "hayranlık anı"nın tarifi,
   riskler. Dalına gönder (yönetici sahibine özetleyecek), beklemeden uygulamaya geç.
2. **Mekân** (`scripts/level/cistern.gd` ya da uygun ad): gerçek boyda, akışla/pişirilmiş (336 sütun MultiMesh; tonoz
   tek ağ; ışık sayısı sınırlı: gl_compatibility'de ışık bütçesine dikkat, huzmeler ışık değil ağ/gölgelendirici),
   su (yansıma: düzlem yansıması pahalıysa sahte yansıma: ters çevrilmiş sütun ağı + saydam su), çarpışma (oyuncu suya
   düşerse yüzer/çıkar: var olan yüzme düzeni; içine düşüp sıkışma yok), bütçe: çizim ≤ 600, üçgen ≤ 1,5 M, 60 fps hedefi.
3. **Bölüm betiği** (`scripts/chapter<kimlik>.gd` + sahne): akış, replikler (tr/en `i18n/strings.csv`; `docs/voice/
   VOICE_MAP.csv` konuşmacı/ton), otomatik test (`--autotest` + her sonuç için varyant), kare kancaları oyunun var olan
   düzeniyle (`--dialogshots`). SES ÜRETME: yeni anahtarları `docs/_kanit_yerebatan/yeni_replikler.txt` olarak ver.
   Müzik/ortam sesi: var olan ses dosyalarından (yankı için var olan efekt düzeni; yeni ses dosyası üretme).
4. **Kanıt:** giriş anı (hayranlık karesi) üç açıdan; sandaldan sütun ormanı; Medusa başları yakın; ışık huzmesi;
   gerilim sahnesinin kare dizisi; iki sonucun son kareleri; karanlıkta telefon ışığıyla ve çakmakla. RINFO tablosu.
   Başsız: yeni bölümün bütün varyantları + komşu bölümler PASS; yasak satır yok; `parse_check`; `tests/check_*.py`.
5. **Rapor:** araştırma notu (kaynaklı), tasarım kararları, yeni replik sayısı, bağlanan bölümler, kayıt uyumu,
   bilinen kusurlar, sahibin karar vermesi gereken yerler (bölümün yeri, sonuçların ağırlığı, süre).

## Sınırlar
Var olan replik metinlerine, dengeye, öteki bölümlerin akışına dokunma (yalnız bağlantı noktası). Şehir haritası şu an
yeniden kuruluyor (İstanbul v2): bölümün iç mekânı haritadan bağımsız olsun; yeryüzündeki giriş/çıkış sahneleri var
olan Ayasofya çevresi (`ByzCity(part="aya")`) ya da kapalı iç mekânlarla çözülsün.
