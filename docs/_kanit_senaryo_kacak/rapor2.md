# Rapor 2: hükümdara el kaldırmak → VURAMAZ → SÜRGÜN (karşı taraftan aynı tarihten devam)

Dal: `wip/senaryo-kacak` (önceki tur `db6e50dd` üstüne). Senaryo belgesi: `docs/SENARYO_KURAL_CIGNEME.md` §6 (6.1 fırsat
tablosu ilk hâl · 6.2 VURAMAZ · 6.3 SÜRGÜN · 6.4 kuşatma öncesi · 6.5 tekrar ve karşı hükümdar · 6.6 iki taraf
tarih eşlemesi ve "sürgünden sonra hangi bölüm" · 6.7 ölçülen fırsat tablosu ve sahibin sorusunun cevabı).

**Denetçi raporu:** iş başında yoktu ("couldn't find remote ref"); bitişte geldi (`origin/wip/denetim-senaryo` `f1fd7e94`,
`docs/_kanit_denetim_senaryo/rapor.md`, önceki turun paketini denetliyor): **KÜÇÜK DÜZELTMELERLE KABUL**, 6 ZORUNLU madde.
Hepsi bu turda kapatıldı (§9).

## 0. Sahibin sorusunun cevabı (ölçülmüş)
"Hangi bölümlerde elimizde kılıç vs varken hükümdara yaklaşma şansımız var?" Bu turdan önce: **hiçbirinde** (kılıç yalnız
dövüşte elde, o sırada Kural kapalı; hükümdarlı anların çoğu diyalog kilidinde; eski "Büro acil iadesi" yalnız 6'nın
Bizans yolunda tetiklenebiliyordu). Ölçüm (bütün eski varyantlar, `HUZUR summary`, §6.7): kılıç elde ve hükümdar
sahnede yalnız **30**'da (İmparator 6,3 m, 6 sn). 26'da hükümdarlar 2,4 m'ye kadar geliyor ama kılıç o anlarda kınında;
Mehmed'e kılıçla yaklaşılan an oyunda **hiç yok**. Bu tur fırsat bilerek açıldı (replik sırasında F ile atılış 7,5 m).
Yöneticinin ön bulgusu doğrulandı; düzeltmeler: kuşatma sayfalarında Sultan hep **atlı** (28o, 34o, 26 sonu: onu
muhafızlar karşılar, hükmü yeniçeri aktarır; Mehmed'in kendi karşı hamlesi yalnız Perde II'de, 10 ve 10z'de yaya), 10g'de Fatih
varsayılan yolda 53 m uzakta (yalnız `fatih`/`late` yolunda 3,2 m), 7'de İmparator hep 9 m'den uzak (açılamadı), 32o'da
Sultan botun yolundan 23 m.

## 1. Ne yapıldı (dosya:satır)
| Madde | Durum | Nerede |
|---|---|---|
| Fırsat tablosu (ilk hâl + ölçülen) | DÜZELDİ | `docs/SENARYO_KURAL_CIGNEME.md` §6.1, §6.7 |
| Hükümdar izleyicisi: serbestte tekme, replikte/arada F ile atılış, sert eşya, kılıç | DÜZELDİ | `scripts/level/huzur.gd` `_physics_process`, `_input_kind`, `_target` |
| Sol tık replik ilerletir: replik açıkken yalnız F saldırı | DÜZELDİ | `huzur.gd` `_input_kind` (`advancing`) |
| Bölümün sıradaki repliği sahne bitene kadar sırada (Hud replik yeri tutulur) | DÜZELDİ | `huzur.gd` `_hold_dialogue`, `_say` |
| Mehmed karşı hamlesi (bilek/ayak bileği havada, yarım adım, çevirip yere); atlı/oturan hükümdarı muhafız karşılar, atlı Sultan'ın hükmünü yeniçeri aktarır | DÜZELDİ | `huzur.gd` `_counter_mehmed`, `_grip` |
| Konstantinos karşı hamlesi (göğse el, çelme; kılıçlıyı kolla süpürür) | DÜZELDİ | `huzur.gd` `_counter_konstantinos`, `_grip_chest` |
| Kılıç düşer (oyuncunun kılıcı yere iner, sürgünsüz sonuçta geri verilir) | DÜZELDİ | `huzur.gd` `_disarm`, `_restore_blade` |
| Muhafızlar (sahnedeki iki asker, yoksa görüş dışından koşarak; kararmada yerlerine döner) | DÜZELDİ | `huzur.gd` `_guards`, `_nearest_guards`, `_put_out` |
| Kamera sarsılıp yere iner, bakış 1,2 sn sonra serbest; iniş noktasından hükümdarın yüzü görünür | DÜZELDİ | `huzur.gd` `_fall`, `_land_spot`, `_face_lock` |
| Hüküm: sürgün / bekleyen / geri itilme / ban | DÜZELDİ | `huzur.gd` `attempt`, `_verdict_mode` |
| Sürgün yürüyüşü (bayraksız, iki yön, eller havada, uyarı oku, sıyırma + geri dönüş noktası, siper) | DÜZELDİ | `scripts/chapter8s.gd` (8y'yi genişletir), `scenes/chapter8s.tscn` |
| Karşılama (Niko / Hasan-Hüseyin; tanışmış/tanışmamış; "seni karşıdan yolladılar") | DÜZELDİ | `chapter8s.gd` `_trench_b2o`, `_gate_o2b` |
| Karşı tarafın sıradaki bölümü (aynı tarih çizgisi) | DÜZELDİ | `huzur.gd` `next_on`, `prepare_walk`; `chapter8s.gd` `_end_walk` |
| Kuşatma öncesi: Perde II → Büro tarafı zorlar; 34o → iki taraflı günlere geçerken yürüyüş | DÜZELDİ | `huzur.gd` `bureau_side`, `pending_walk`; `scripts/chapter17.gd` `_prologue_side`; `scripts/siege.gd` `next_path` |
| Sürgünlü yolda bölüm listesi/numara iki tarafı tek sırada sayar | DÜZELDİ | `scripts/siege.gd` `chapters`, `has_route`, `side_at`, `number_of` |
| Akış şeması (sürgün sahnesinin kendi şeması) | DÜZELDİ | `chapter8s.gd` `_make_chart_s` |
| Akıbet sayfası: "İki hükümdar" satırı | DÜZELDİ (birim testi; kare yok) | `scripts/ui/people_fates.gd` `people()` sonu |
| Eski davranış (bölüm baştan) kaldırıldı; Kural hükümdarı Huzur'a verir | DÜZELDİ | `scripts/level/kural.gd` `_ruler`, `_on_kick` (çocuk Mehmed hükümdar sayılmaz) |
| `ACH_TARIHE_TEKME` karşı hamle anında; yeni `ACH_SURGUN` | DÜZELDİ | `huzur.gd` `attempt` (`tarihe_tekme`), `prepare_walk`/`bureau_side` (`surgun`); `scripts/achievements.gd`; `docs/STEAM_ACHIEVEMENTS.md`; `tests/ach_check.gd` |
| Bölümlere tek satır bağlantı | DÜZELDİ | `scripts/chapter{6:77,7:66,10:64,10b:59,10g:39,10h:42,10z:44,12:44,12b:36,23:48,25:66,26:75,28o:87,30:50,30o:82,32o:112,34o:67}.gd` |
| Yeni replikler TR+EN, konuşmacı, okuma notu | DÜZELDİ | `docs/_kanit_senaryo_kacak/yeni_replikler2.txt` (84 anahtar; 55 seslendirilecek), `i18n/strings.csv`, `docs/voice/VOICE_MAP.csv`. Ses ÜRETİLMEDİ |
| Birim testi (hedefler, bekleyen sürgün, yol/numara, hüküm, Büro, akıbet) | DÜZELDİ | `tests/huzur_check.gd/.tscn` |

**Başarım önerisi:** `ACH_SURGUN` **"Bayraksız Geçiş" / "The Flagless Crossing"**: "Hükümdarına el kaldır, karşı tarafa
sürül." / "Raise your hand to your own sovereign and be exiled to the other side." (gizli; sayaç `surgun`).

## 2. Ayar sabitleri (sahibin kararı; sayılar burada)
`scripts/level/huzur.gd`: `FREE_REACH` 2,4 m · `LUNGE_REACH` 7,5 m · `LUNGE_STOP` 1,45 m · `DASH_SPEED` 8 m/sn ·
`SWORD_REACH` 3,0 m · `CONE` 0,86 (~30°) · `COUNTER_DIST` 3,4 m · `BEHIND_DOT` −0,25 · `LOOK_BACK` 1,2 sn (şart ≤ 1,5)
· `BAN_DIST` 3,0 m · `EXILE_LIMIT` 2 · `HOLD_LINE_MAX` 1,6 sn · `HARD_ITEMS` (telefon, küp, termos, powerbank, çakmak,
kitap, kolonya, bant) · `TWO_SIDED_FROM` 42 (7 Nisan).
`scripts/chapter8s.gd`: `WARN_GRACE` 2,5 sn · `HIT_AFTER` 3 · `STREAK_CALM` 6 sn · `COVER_DIST` 1,6 m · `HANDS_L/R`
(el kadrajın üstünde) · `O_HALT_Z` 40 · `O_GATE_Z` 17,5. 8y'den devralınan: `WARN_GAP` 5 sn, `LANE_HALF` 13,8 m.

## 3. Kareler (gerçek oyuncu kamerası, ekranlı PACE oynanış koşuları; paftalar bu klasörde, JPEG ≤ 300 KB)
| Pafta | İçerik | Kaynak koşu |
|---|---|---|
| `pafta2_01_mehmed_bos_el.jpg` | **ÖNCE | SONRA**: 10z'de replik arasında F ile Sultan'a atılış. ÖNCE (özgün kod `db6e50dd`, depo dışı kopya + yalnız kare alan sonda): hiçbir şey olmaz, bölüm sürer. SONRA: Mehmed bileği havada yakalar, yarım adım, Tolga yerde, "Elini indir, kâtip. O el kalem tutmak için." | 10z `huzur` (iki kopya) |
| `pafta2_02_konstantin.jpg` | Konstantinos boş elle (23: göğse el, çelme, "Otuz yıldır kılıç taşırım...") ve kılıçla (30: kolla süpürür, kılıç düşer, "O kılıç sana Şehir için verildi...") | 23 `huzur`, 30 `huzur_sword` |
| `pafta2_03_muhafiz.jpg` | Muhafızlar: 12b (arkadan gelince, "Basileus'a el! Yere, yabancı!", iki muhafız iki yanda) ve 34o (atlı Sultan, yeniçeri "Huzurda el kalkmaz, kâtip!") | 12b, 34o `huzur` |
| `pafta2_04_kapidan_cikis.jpg` | Hüküm ve kapı dışarı: 28o Sultan'ın hükmü, Hüseyin/Hasan siperden salar (O2B); nöbetçi, kapı açılır, gözcü (B2O) | 28o zinciri, 8s `b2o_warn` |
| `pafta2_05_gecis.jpg` | Bayraksız geçiş iki yön: eller havada, gözcü durdurur, eller inikken uyarı oku, ok sıyırır → son siperde kalkış | 28o zinciri, 8s `hit`, 8s `b2o_warn` |
| `pafta2_06_karsilama_sonraki.jpg` | Karşılama (Niko "Seni karşıdan yolladılar"; Hasan "Bre, bizim Frenk kâtip!", Hüseyin "İmparator'una el kaldırmışsın") ve karşı tarafın sıradaki bölümünün (29) açılışı | 28o zinciri, 8s `b2o_warn` |
| `pafta2_08_kural_kart.jpg` | Denetim ZORUNLU 6: tutuklanma kartı karede (24 `krl_hit`) | 24 `krl_hit` |
| `pafta2_07_akis_semasi.jpg` | Sürgünün akış şeması: taraf, uyarı/sıyırma, sıradaki bölüm ve tarihi; numaralar sürgünlü yola göre (16 → 17) | 8s varsayılan |

Zayıf/eksik kareler (dürüstçe): 28o'daki ilk karşı hamle kareleri atlı Sultan düzeltmesinden ÖNCEki koddan (Sultan atlıyken
kaydırılıyordu: düzeltildi, o kareler paftaya alınmadı); 34o "yerde" karesinde atlı Sultan kadrajda değil (Tolga topun
yanına iner): KISMEN. Yerdeyken Tolga'nın eli kadrajın kenarında kalabiliyor (`stow_hands` eli tam indirmiyor):
KISMEN. Mehmed'in **kılıçlı** karşı hamlesinin karesi yok (oyunda anı yok): KANITSIZ. Akıbet sayfasının karesi yok
(satır `tests/huzur_check.gd` ile denetlendi): KISMEN. ÖNCE | SONRA çifti yalnız pafta 1'de (öbür maddeler bugün hiç
yoktu: sürgün sahnesi yeni).

## 4. Testler (ham satırlar: `testler2.txt`)
- `parse_check` PASS (251 betik). `tests/check_*.py` hepsi PASS (keys 0 sorun, speakers, voice_rules, inline,
  consequences, outcomes, export_refs, tween_await). `tests/huzur_check.tscn` HUZURCHECK PASS. `ach_check`: §6.
- **Yeni varyantlar (üçer kez, son kodla):** 28o `huzur` (O2B → 29), 25 `huzur` (B2O → 32o), 30 `huzur_sword`
  (kılıçla, B2O → 21o), 23 `huzur` (B2O → 24o), 25 `huzur2` (ikinci sürgün, geri), 25 `huzur3` (üçüncü: ban, bölüm
  sürer), 34o `huzur` (kuşatma öncesi: bekleyen sürgün), 12b `huzur` (Perde II: bekleyen), 6 `byz` + `huzur_bot`
  (Perde II, muhafız), 28o `huzur_save` (sürgünden sonra kaydet-yükle), 28o `huzur_guard` (muhafız), 26 `huzur`
  (karşı hükümdar: geri itilme), 12/10h `huzur` (eşyayla atılış), 8s doğrudan: varsayılan, `b2o`, `hit`, `b2o_warn`,
  `save`, `b2o_save`, `b2o_next` (21o'nun kendi testi PASS). **Son kodla tam koşu: 76/76 PASS, yasak satır 0**
  (yeni varyantlar üçer kez + 10/10z/10b/12/10h/23 `huzur` üçer kez + bağlı 17 bölümün varsayılanı).
- **Dokunulan bölümlerin bütün eski varyantları** (122 koşu; 6, 7, 10, 10b, 10g, 10h, 10z, 12, 12b, 23, 25, 26, 28o,
  30, 30o, 32o, 34o + `next` zincirleri): 122/122 PASS (ayrıştırma penceresinde başlayan 6 `y`/`letter` ve hükümdar
  düğümü kusuru düzeltilmeden koşan 32o yeniden koşuldu: PASS, yasak 0).
- **Aralıklı, önceden var olan** yasak satırlar (bu turla ilgisi ölçüldü): 26 `hold`/`hold_box` VISAUDIT sunk/overlap
  (dalga savaşının Duelist'i; SONRA 1/3, ÖNCE 0/2; Huzur o koşularda hiç tetiklenmedi) · 12 `next` zincirinde 17'nin
  LOOKAUDIT backturn (kind=grip) satırı: **ÖNCE kopyasında da 1/4**, SONRA 1/3. Önceden var: bu turun işi değil.
- Yol boyunca bulunup düzeltilenler: sahnenin sildiği hükümdar düğümü (32o SCRIPT ERROR) · sürgünde eski bölümün bekleyen
  replik eşyordamları ağaçsız uyanıyordu (28o SCRIPT ERROR; eski sahne kare sonunda anında silinir, `swap_scene`) ·
  atılış hükümdarın gövdesine giriyordu, bölümün akışı kamerayı topa çeviriyordu (28o kareleri) · hükümdarın kopuk kılıcı,
  yerde kadraja kalkan eşya (30 kareleri) · Fatih atlıyken atın boynu arkasında kalıyordu (26 VISAUDIT) · ödünç muhafız
  sonra Fatih'i örtüyordu (26 VISAUDIT personhidden) · sürgünde 8y'nin "havluya saklanıyorum" yorumu · eller havadayken
  "Ellerini kaldır" ipucu · test koşucusunun aynı varyantın üç kopyasını aynı dosyaya yazması (sonuçlar yeniden alındı).

## 5. Ortak dosyalara dokunuş (ayrı başlık)
- `scripts/siege.gd`: `next_path` içinde 6 satır (bekleyen sürgün → yürüyüş), `chapters` içinde rota dalı ve iki yeni
  işlev (`has_route`, `side_at`), `number_of` içinde 2 satır. Sürgünsüz oyunda davranış aynı (`huzur_check`: sürgünsüz
  yol = eski yol).
- `scripts/chapter17.gd` `_prologue_side`: taraf seçiminden önce 4 satır (bekleyen sürgün tarafı zorlar).
- `scripts/ui/people_fates.gd` `people()` sonunda 10 satır.
- `scripts/achievements.gd` (+2), `tests/ach_check.gd` (+1), `docs/STEAM_ACHIEVEMENTS.md` (+1).
- `scripts/level/kural.gd` (önceki turun dosyası): `_ruler` Huzur'a verir; çocuk Mehmed hükümdar sayılmaz.
- Hud'a dokunulmadı; Huzur Hud'un `line_open`, `cut_voice`, `_sub_box`, `_mesh_between`, `_is_mounted`'ını kullanır
  (özel adlar: ORTAK DOSYA ÖNERİSİ: Hud'a `hold_line(on)` ve `speaker_visible(eye, who)` diye iki açık işlev).
- Kare noktaları (`_cshot`, yalnız `--dialogshots` ile ve ekranlıyken; 8y'deki gibi kalıcı denetim yolu, sonda değil).

## 6. Performans
Varsayılan yolda yeni ağ, ışık, kişi yok: bölüme bir `Node` (0,2 sn'de bir "persons" grubunda hükümdar taraması, her
karede birkaç karşılaştırma). RINFO ölçülmedi: **BAKILMADI**. Sürgün sahnesi 8y'nin aynı dünyası (WORLDWALK tris ~280k,
8y ile aynı).

## 7. SAHİBİNE SORULAR
1. Replikte atılış menzili 7,5 m (huzurda Sultan 6 m'de): fazla mı? (Kısarsak 12, 10b, 6'da fırsat kapanır.)
2. Hükümdarın kendisi mi karşılasın, muhafız mı: eşik 3,4 m. Daha çok "hükümdar hamlesi" görmek için büyütülebilir.
3. Mehmed'e kılıçla yaklaşılan bir an oyunda yok: bir sahne (ör. 28o'da Sultan'ın kılıç kuşanıp talimi izlemesi) ister misin?
4. Ovada üç üst üste uyarıda ok sıyırır, geri dönüş son siper sırası: sert mi?
5. Perde II'deki saldırı sürgünü Büro'ya bırakıyor (taraf seçilemez). Yoksa yürüyüş Büro'dan hemen sonra mı olsun?
6. Üçüncü kezde "bir daha huzuruma getirmeyin": hükümdara 3 m'den fazla yaklaşamamak yeterli mi, yoksa sahnelere
   "muhafız arasından uzaktan" ayrı yerleşim mi (bölüm bölüm iş)?
7. Eski `KRL_RULER_*` replikleri (Büro acil iadesi) artık kullanılmıyor: silinsin mi?
8. Başarım adı: "Bayraksız Geçiş".

## 8. YAPILAMAYAN / BAKILMADI (dürüstçe)
- 7 (İmparator hep 9 m+ uzakta ve oyuncu donuk), Edirne ara bölümü (çocuk Mehmed), 32o ve 30o (botun yolunda erişilmez):
  bağlı ama varyantla **KANITSIZ**. 10, 10b, 10g, 10z: bağlı, varyant koşulmadı: **KANITSIZ**.
- Mehmed'in kılıçlı karşı hamlesi: oyunda doğal anı yok: **KANITSIZ**. Hükümdarın kendi kılıcını çekmesi kaldırıldı
  (karede kopuk duruyordu); kılıçlıya karşı hamle elle/kolla.
- "Muhafız arasından uzaktan katılma" sahne yerleşimi yapılmadı; yerine 3 m'lik yasak çember (muhafız önünü keser).
- Sürgün yürüyüşünün ortasında kayıt yok (çıkılırsa hükümdarlı bölümün başı açılır).
- Akıbet sayfasının ekran karesi yok (birim testi var). RINFO yok. Ekranlı koşular yük altında yavaş: 30 → 8s B2O
  zinciri PACE'te süre sınırına takıldı; B2O kareleri doğrudan 8s koşusundan.
- ÖNCE | SONRA çifti yalnız Mehmed karşı hamlesinde (özgün kod + depo dışı sonda); öbür maddelerin ÖNCE'si yok (bugün
  o sahneler hiç yok: sürgün sahnesi yeni).

## 9. Denetçinin ZORUNLU listesi (bu turda kapatıldı; `scripts/level/kural.gd`)
| # | Madde | Durum | Nerede · kanıt |
|---|---|---|---|
| 1 | Vurulana `look_target` verilmesin, baş çevirme | DÜZELDİ | `_civilian` ve `_guard_run` → `_look()` (Rig.stare_t). 24/6/10g/24o `krl_hit` (24 üç kez, 6 ve 10g iki kez): `LOOKAUDIT raw` **0** (krl2). |
| 2 | `kacak_iade` zeminsiz noktaya ışınlanmasın | DÜZELDİ | `_bot_tick` + `_has_ground` (yukarıdan inen ışın, oyuncunun boşluk denetimiyle aynı ölçüt). 41o `kacak_iade` **10 koşu**, 42b 2 koşu: `WARN_VOID_TELEPORT` **0** (ilk denemede 5'te 3 vardı, düzeltildi). |
| 3 | `firar` 2 sn çıkıp dönende sayılmasın | DÜZELDİ | `_count_firar()` yalnız seslenme basamağında (kovalayan koşarken); lafta dönende `escapes` geri alınır (`_area_tick`). |
| 4 | Tık başına bütün ağaç taranmasın; tırmanma tıkı tekme sayılmasın | DÜZELDİ | Hayvan listesi 10 sn'de bir (`_animals`); `_hits_tick`: `traversal.wall_ahead()` doluysa çıkar. RINFO ölçülmedi: KANITSIZ. |
| 5 | Muhafız gelince kamera sıçramasın | DÜZELDİ | `_turn_to()` 0,45 sn yumuşak dönüş (`_guard_run`). Ekranlı karede seçilmedi: KISMEN. |
| 6 | Kart karesi; 31o'ya `krl_hit` | DÜZELDİ | Kart anında `_cshot` (`c_kural_kart_*`): `pafta2_08_kural_kart.jpg` (24 zindan kartı). 31o `krl_hit` varyantı (`chapter31o.gd`: `bot_window` + rapor) 3/3 PASS, `tests/run_tests.sh`'e eklendi. 39o'ya varyant eklenmedi (sokakta rol taşıyan kişi yok: önceki turdaki gibi). |

Denetçinin K7'si (24'te "Lambda capture" ERROR, 41o VISAUDIT offview) ve 31o varsayılanındaki derviş/Kadri `LOOKAUDIT raw`
satırları ÖNCE kopyasında da var (31o: özgün kodla 2/2): bu turun işi değil.
Kural düzeltmelerinden sonra koşulanlar (son kod): 41o `kacak_iade` ×10, 42b `kacak_iade` ×2, 24 `krl_hit` ×3, 6 ve 10g
`krl_hit` ×2, 24o `krl_hit`, 31o `krl_hit` ×3, 41o/42b `kacak`, 24 `krl_soft`, 6 `krl_soldier`/`krl_animal`, bağlı
bölümlerin varsayılanları (41o, 42b, 24, 31o, 6, 10g, 24o, 36b, 37o, 39o) ve 41o/42b `lose`, 31o `late`: **52/52 PASS**,
yasak satır 0.
