# F02_bolum0-5 düzeltme notları

Değişen kod dosyaları (git commit yok):
- scripts/chapter1.gd: _slipper_demo (terlik teslimi), UI_CH1_SUB ve D1_T_MIRROR metinleri
- scripts/chapter2.gd: _to_shore, _to_chain (2.4), yeni _land_on_shore, _shore_guards
- scripts/chapter3.gd: _interrogation (kind yolu), _end_chapter (rapor anahtarı), _make_chart (3.4 düğüm anahtarı)
- scripts/chapter4.gd: _gate, _dishes (Kadri), _act_end (4b vista)
- scripts/chapter5.gd: _knock, _drop_part, _start_tuning, _confession
- scripts/level/*.gd ve bölüm dışı dosyalar: değiştirilmedi (bedroom, garage, slipway, sea_walls dahil; yalnız okundu)

Metin: fix/F02_bolum0-5_strings.csv (i18n/strings.csv'ye dokunulmadı)
Ses: fix/F02_bolum0-5_voice.txt (ses servisine bağlanılmadı)

## Bulgular

1. [YÜKSEK] Samimi yolda kurutma makinesi yalanı -> DÜZELTİLDİ. chapter3.gd: kind_lie bayrağı. Samimi yolda (kind) EAVES_CALL atlanır (rastgele yola düşer), trace kolunda HIKMET yerine D3_N_EVIDENCE_HIKMET_KIND, çift yalanda D3_H_DOUBLE_DOWN_KIND, 3.4 sonunda D3_N_END_34_KIND ve D3_H_END_34B_KIND (Antalya). 3.4 raporu UI_CH3_REPORT_3_4_KIND, akış şeması düğümü FLOW_3_4_KIND. Kural yolu aynen kaldı.
2. [ORTA] Zaman kartı 03:12 -> DÜZELTİLDİ. UI_CH1_SUB "03:00" (strings). Yatak odası komodin saati 03:00 ile tutarlı.
3. [ORTA] Garanti uyarısı ~5 sn -> DÜZELTİLDİ (metin). D2_H_WARRANTY süresiz yazıldı ("Garanti bitiyor! Dönmek istersen şimdi bas!"). Zamanlama (36 / 70 m) değiştirilmedi, testleri etkilememek için.
4. [ORTA] Zincirden düşüş -> kıyı ışınlanması -> KISMEN/DÜZELTİLDİ. _to_chain 2.4: kararmada UI_CH2_CURRENT_BACK kartı ("Akıntı seni Kasımpaşa kıyısına geri sürükledi."). Kıyıya oturma _land_on_shore ile. Zincir yakınından kayık gösterimi yapılmadı (büyük iş).
5. [ORTA] Terlik teslimi yok -> DÜZELTİLDİ. _slipper_demo: terlik Tolga'nın önünden Hikmet'in sağ kol ucuna (rig.elbow_r, "hand" meta) süzülür, reparent edilir; sonra D1_H_DEMO_1 çalışır; atış öncesi garage'a geri reparent. Yeni replik yok (mevcut D1_H_DEMO_1 kullanıldı).
6. [ORTA] Kostüm görsel ve ayna repliği -> KISMEN. D1_T_MIRROR metni değiştirildi (Hikmet'e "dönem kıyafeti" atfı ve henüz giyilmemiş kostümün tarifi kaldırıldı). GÖRSEL kısım düzeltilmedi, player.gd (F01) gerekiyor: ORTAK İSTEK aşağıda.
7. [ORTA] Niko surdan ışınlanıyor -> DÜZELTİLDİ (karartma geçişi). _gate: fade out -> konum -> fade in. Merdiven animasyonu yapılmadı (sea_walls dokunulmadı).
8. [ORTA] Perde I kapanışında fes -> DÜZELTİLDİ. _act_end: 4b rotalarında kamp ateşi, kırmızı fes ve çadırlar yerine şehir yönünde sıcak bir fener (OmniLight + küçük kutu). 4a aynen.
9. [ORTA] Makine yapım süresi -> DÜZELTİLDİ. D2_H_24 "Makineyi kırk yılda yaptım." (TR/EN). D3_H_KIND, D5_H_DISMANTLE, D5_H_CONF_3 zaten kırk yıl diyor.
10. [ORTA, şüpheli] Kapı çalma çakışması -> DÜZELTİLDİ. _knock: 3.6 sn sonra _busy false olana kadar bekler, sonra kilidi alır. _drop_part: _busy iken dönmez.
11. [ORTA] Garanti uyarısı -> aynı düzeltme #3.
12. [ORTA] Kadri sahnede yok -> DÜZELTİLDİ. _dishes: önlüklü Kadri (camp_day.gd ile aynı Person tanımı) bulaşık dağının yanına eklendi; kazan eklenmedi.
13. [ORTA] Nihat çıkmıyor, Hikmet fısıldıyor -> DÜZELTİLDİ (karartma). 3.4'te D3_N_END_34 ve D3_H_END_34 sonrası fade_to(1.0) ile Nihat çıkmış sayılır, fısıltı karartma sırasında; player.face kaldırıldı. Zaman Perdesi'yle görünmez dinleme tercih edilmedi.
14. [ORTA] Kıyı yakalanma kamerası -> KISMEN/DÜZELTİLDİ. _land_on_shore: landing.y = level.surface_h(x,z)+0.05, gravity_on = true (2.2 ve 2.1/2.4 için). _shore_guards: iki asker oyuncunun 2.6 m önünde, ±0.9 m yanda, yüzleri oyuncuya dönük; 2.1 ve 2.4 sonunda silinir. Yakın bir sandığa (kutu) çarpma riski render ile doğrulanmadı.
15. [ORTA, şüpheli] Ok teslim kalabalık -> DÜZELTİLMEDİ. Teslim eşiği 3.0 m (chapter0 _process), kalabalık avoid [LINE, 2.4] ve avoid_lines [START, LINE, 1.6]. Kalabalığın kamera içine girmesi kısmen mümkün görünüyor ama render yapılmadan ayar değiştirilmedi. Öneri: render ile doğrula; gerekirse chapter0.gd chaos.avoid LINE yarıçapını 3.4 civarına çıkar.
16. [ORTA, şüpheli] "Bodruma kondu 3/3" istemi kalıyor -> DÜZELTİLDİ. _drop_part 3. parçada, _start_tuning ve _confession başında hud.set_prompt("").

## Testler

- PARSE: PARSECHECK PASS scripts=230 (son düzenlemeden sonra)
- Bölüm varyantları (tests/run_tests.sh'taki 0-5 listesi, 31 koşu): hepsi "AUTOTEST PASS"; SCRIPT ERROR / VISAUDIT / FAIL yok.
  - ch0: "" | ch1 (run --autotest): "", kick, red | ch2: "", perfect, chain, chainfail, red, swimshore, swimchain
  - ch3: "", tea, confiscate, seal, lie, radio | ch4: "", item, caught, market, chain, nofez, fall, fez, wet
  - ch5: "", call, confiscated, sealed, noradio
  - Çıktılar: scratchpad/audit/fix/F02_test/out_*.txt

## ORTAK İSTEKLER

- F01 (scripts/player/player.gd): #6 görsel kısmı. Birinci şahıs kol (_build_hand, redingot 2b2f38) ve _me_person (ayna modeli, 23262d ceket) kostüm öncesi ile sonrası aynı görünüyor; kostüm öncesi kıyafet pijama/takım olmalı ve kostüm giyildikten sonra redingota geçmeli. Chapter1 tarafı (D1_T_MIRROR) buna göre yazıldı: "Ceket, saçlar dağınık..." (ceket ayna modeline uyuyor, ayrıca değişince D1_T_MIRROR de güncellenmeli).
- F12 veya ses ekibi: UI dışı yeni/değişen seslendirilmiş anahtarlar fix/F02_bolum0-5_voice.txt içinde (D3_N_EVIDENCE_HIKMET_KIND, D3_H_DOUBLE_DOWN_KIND, D3_N_END_34_KIND, D3_H_END_34B_KIND, D1_T_MIRROR, D2_H_WARRANTY, D2_H_24).
- scripts/ui/hud.gd DARK_OK / voice_gain.gd: değişiklik gerekmiyor; D2_H_24 metni değişti, ses kazancı tablosu (voice_gain.gd) aynı anahtarla kalır.
