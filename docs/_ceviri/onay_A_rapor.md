# Çeviri ikinci okuma + denetim · Grup A (dilim 1 + dilim 2)

Kapsam: `python3 docs/_ajan/gorev/ceviri_dilim.py 1` (718 satır) ve `… 2` (532 satır) = **1250 anahtar**.
İlk turun teslimleri: `wip/ceviri-1` (`dilim_1.csv`, 45 öneri) ve `wip/ceviri-2` (`dilim_2.csv`, 20 öneri).
Oyun dosyalarına (i18n/strings.csv, VOICE_MAP.csv, INLINE.json, betikler, sesler) dokunulmadı; ses üretilmedi.

Teslimler:
- `docs/_ceviri/onay_A.csv`: uygulanacak son liste (`kabul` + `duzelt`), `ret` satırları gerekçesiyle aynı dosyada.
- `docs/_ceviri/kapsam_A.csv`: 1250 anahtarın her biri tr ve en ayrı satır = **2500 satır** (boş en yok).
- Bu rapor.

## 1. Okunan satır (kapsam dosyasından)

| | iyi | oneri | supheli | toplam |
|---|---|---|---|---|
| tr | 1188 | 54 | 8 | 1250 |
| en | 1234 | 16 | 0 | 1250 |

Satırlar 50'lik öbeklerle sahne sırasında okundu; ilk turun her önerisi, betiğe bakılarak (`chapter6.gd` `_T` mantığı, `hud.gd` `show_reaction`, `chapter6.gd` seçenek düğmeleri) komşularıyla birlikte değerlendirildi.

## 2. İlk turun denetimi: 65 öneri

| | kabul | duzelt | ret | toplam |
|---|---|---|---|---|
| dilim 1 (45) | 37 | 6 | 2 | 45 |
| dilim 2 (20) | 18 | 2 | 0 | 20 |
| **toplam** | **55** | **8** | **2** | **65** |

İlk turun önerileri genel olarak isabetli. Yanlış "uygun" denebilecek yer azdı; düzeltmelerin çoğu yönü doğru ama metni kusurlu öneriler.

### Ret (2)
- **D4A_T_WIN_TAPE** ("Hikmet Amca gurur duyardı" → "görse göğsü kabarırdı"): eskisi Türkçede yerleşik ve Tolga'nın 2026 ağzında doğal. Yenisi çeviri izini gidermiyor, yalnız Tolga'yı yaşlı bir ağza çekiyor.
- **D6_URBAN_POWERBANK_T** tr ("Lütfen koymayalım." → "Aman, koymayalım!"): eskisi Tolga'nın kibar ve telaşlı plaza ağzına uygun, Türkçede doğal. Asıl kusur İngilizcedeydi ("Let's please not."); onu ikinci okumada ayrıca önerdim.

### Düzelt (8): ilk turun metni → denetçinin metni
| anahtar | ilk tur | son | neden |
|---|---|---|---|
| D1_T_05 tr | Dalga geçiyorsun, **di mi**? | Dalga **mı** geçiyorsun? | Altyazıda "di mi" yazımı olmaz. "değil mi" eklemek de İngilizce soru ekini ("right?") geri getirirdi. |
| D2_H_RADIO_YES tr | sesin geldi ya, **gerisi kolay** | sesin geliyor ya | "Gerisi kolay" metne yeni bir iddia ekliyordu; hemen ardından kovalamaca başlıyor. |
| D2_T_FALL en | The hill's running out... The hill's run out! | Running out of hill... Out of hill! | "the hill runs out" İngilizcede kalıp değil. "Running out of road" kalıbı bark boyunu koruyor. |
| D4A_ITEM_LIGHTER_2 tr | Ufak ama **çevik**. | Ufak, **çabuk çakanından**. | Taş için "çevik" oturmuyor. Yenisi hem "hızlı" bilgisini koruyor hem çakmak/çakmaktaşı ses oyununu kuruyor. |
| D4A_ITEM_TAPE_1 en | Tie what with it? | What do you tie with that? | İlk turun metninde kırpık söz dizimi duruyordu. |
| D6_KADRI_CHICKPEAS tr | Bu düpedüz **keramet**! | Bu ne **icat** böyle! | "Keramet" evliya mucizesi çağrışımı taşıyor (EVREN: kutsal değer espri malzemesi değil). Kadri'nin derdi yemek icat etmek. |
| D7_N_HOT tr | Şüphelinin yeri burası. Ya hâlâ burada ya da **çok yakında**. | Şüpheli buradan kopmamış. Ya hâlâ burada ya da **hemen yakınlarda**. | İlk tur D2_H_09'da yakaladığı "yakında" (= soon) belirsizliğini burada kaçırmıştı. |
| D7_N_TEA_DONE en | I'll file it away **up here**. | I'll make a mental note. | "Up here" baş işaretine dayanıyor; altyazıda da seste de yarım kalıyor. |

## 3. İkinci okuma: yeni öneriler (15)

| dilim | tr | en | anahtarlar |
|---|---|---|---|
| 1 | 1 | 2 | D6_URBAN_ASK (tr), D4B_N_THROW_CHICKEN_3 (en), D6_URBAN_POWERBANK_T (en) |
| 2 | 4 | 0 | D7_N_DELAYED, D9_T_KADRI_YES, D9_MINER_TR2, D8_C_HINT_END (yazım) |
| varyant/alıntı (dilim 8–9 anahtarları) | 5 | 3 | aşağıda §4 |

Gerçek çeviri kokusu ilk turdan sonra seyrek kaldı. Kalanlar, ilk turun bir yerde düzeltip başka yerde atladığı aynı kalıplar: "Beni etkile…", "Bir tür.", "Sorun değil. Sorun değil.", "tavanın altında kalır".

## 4. Varyant ve alıntı eşlemeleri

İlk turun en önemli açığı bu. **Eşya tepkilerinin `REACT_*` kopyaları** ana replikleri tırnak içinde aynen taşıyor ve oyunda bark olarak çıkıyor (`scripts/ui/hud.gd` `show_reaction`: `REACT_%s_%s`). Bir seçenek düğmesi de repliği alıntılıyor. Ana anahtar değişip bunlar değişmezse aynı sahne iki farklı metinle görünür. Hepsini `onay_A.csv`'ye `kaynak=ikinci` olarak ekledim:

| ana anahtar | birlikte değişmesi gereken |
|---|---|
| D4A_ITEM_LIGHTER_2 | REACT_GUARDS_LIGHTER (tr) |
| D4A_ITEM_BOOK_3 + _4 | REACT_GUARDS_BOOK (en) |
| D4A_ITEM_TAPE_1 + _3 | REACT_GUARDS_TAPE (en) |
| D6_KADRI_CHICKPEAS | REACT_KADRI_CHICKPEAS (tr) |
| D6_KADRI_COLOGNE | REACT_KADRI_COLOGNE (tr) |
| D6_KADRI_SELFIE | REACT_KADRI_SELFIE (tr) |
| D6_URBAN_POWERBANK_T | REACT_URBAN_POWERBANK (en) |
| D6B_T_SILENT | UI_CH6B_SILENT (tr, seçenek düğmesi `chapter6.gd:1104`; 36 karakter, 60 sınırının altında) |

Birlikte değişen eşler (ikisi de listede): D2_H_AFTER_WARRANTY ↔ D4A_H_02 · D3_N_EAVES_CALL ↔ _KIND · D8_H_FAIL_LATE ↔ _HEIST ↔ _PARTS · D0_T_FREEZE_1 ↔ _2 · D4A_ITEM_BOOK_3 ↔ _4 · D4A_ITEM_TAPE_1 ↔ _3 · D6_LUTFI_ASK ↔ D6_URBAN_ASK · D6B_T_E_02 ↔ D7_N_DELAYED (aynı "Bir tür." kalıbı) · D9_MINER_TR2 tr ↔ en.

Cevap veren replikler bozulmuyor: D4B_T_HIT_2_SHIELD ("Hektor kim?!"), D6B_G_SILENT ("Dikkatli olmak benim mesleğim"), D6_KADRI_CHICKPEAS_T ("Leblebi."), D1_T_20, D4A_ITEM_TAPE_2.

**Grup dışı, uygulanırken bakılacak:** **D10Z_K_LEBLEBI** (dilim 3) Kadri'ye yine "Bu... bu bir devrim yamak." dedirtiyor. D6'daki "devrim" sözünün geri dönüşü olabilir. D6 "icat"a çekilirse bunun da "Bu... bu ne icat, yamak!" gibi hizalanması gerekir. Dilim 3'ün denetçisine iletilmeli.

## 5. Metne bakan testler ve seslendirme tuzağı

- **`tests/check_inline.py`** INLINE.json'daki duygu etiketli seslendirme metni altyazıyla aynı değilse FAIL veriyor. Listeyi ev klasöründeki bir kopyada uyguladım: `check_inline` **10 sorunla FAIL** verdi. Aşağıdaki INLINE girdileri yeni metinle birlikte güncellenmeli; yoksa ses eski cümleyi okur (CLAUDE.md'deki uyarı). D4A_HU_FEZ_3'ün INLINE'ında yalnız en var, o yüzden testi bozmuyor.
- **`tests/check_voice_rules.py`** (Hristiyan karaktere İslami yemin yok, Niko "lan" demez, UI_C* ≤ 60 karakter): uygulanmış kopyada **PASS** (0 sorun).
- `tests/` içinde değişen anahtarlardan birini adıyla ya da eski metniyle arayan başka test yok. `scripts/` içindeki eşleşmeler yalnız yorum satırları (`chapter23.gd:226`, `chapter7.gd:704`, `chapter0.gd:6`).

Etiketler korunarak INLINE.json için önerilen metin:

| anahtar | önerilen INLINE (tr / en) |
|---|---|
| D1_T_05 | `[skeptical] Dur dur dur. Dalga mı geçiyorsun? [whispers] Bu alet cidden çalışıyor mu?` |
| D1_H_06 | `[serious] Makinenin tek bir arızası var evlât: [baffled] çalışıyor. Valla ben de şaştım kaldım.` |
| D1_H_21 | `[as if it's obvious] Acil olursa bas, acil değilse basma. Bunda anlamayacak ne var evlât?` |
| D2_H_RADIO_YES | `[relieved] [exhales] Oh be, [warm] sesin geliyor ya. [urgent] Şimdi koş.` |
| D2_H_WARRANTY_END | `[sighs] Garanti bitti. [firm] [urgent] Koş artık, koş!` |
| D2_H_AFTER_WARRANTY | `[flustered] Garanti bitti. [determined] Ben bir çaresine bakacağım, bekle.` |
| D2_H_09 | `[calm] [thinking] Yakınlarda kıyı var [worried] ama askerler de var. [squinting] Uzakta bir zincir görüyorum... [pause] [sheepish] Yani sen görüyorsun.` |
| D2_T_ARROW_3 | `[nervous laugh] Uyarı atışı herhalde. [shaky] [sarcastic] Uyarıyı aldık, sağ olun.` |
| D2_T_FALL (en) | `[nervous] [out of breath] Running out of hill... [terrified] [shouting] Out of hill!` |
| D3_H_RESIST | `[nervous] [hurried] O tavuk bizim değil! [pause] ...O ok da bizim değil. [innocent] Ben hiçbirini tanımam!` |
| D4A_HU_FEZ_3 | en değişmedi; tr INLINE'da yok. Ses tr'yi strings.csv'den okuyacak, işlem gerekmez. |

## 6. Sahibine sorulacaklar (en çok on)

1. **D0_T_FREEZE_1/2 (açılış donmuş karesi):** Dilini Türkçeleştirdim, ama "Evet, o benim… Ne işim var diye düşünüyorsunuzdur" kurgusunun kendisi bilinen bir film klişesi (kural 3). Sahne kurgusu kalsın mı?
2. **'Fwump' (D3_N_02 ve BUR_TUBE):** Türkçe altyazıda İngilizce bir yansıma sesi duruyor ve BUR_TUBE onu geri çağırıyor. "Pof" gibi Türkçe bir sese ikisi birlikte mi çekilsin?
3. **VOICE_MAP hatası:** D6_URBAN_POWERBANK_T'yi betikte Tolga söylüyor (`chapter6.gd:401` `key + "_T"` → `_t()`), ama VOICE_MAP'te `SPK_URBAN` yazıyor. Ses Urban'ın ağzından üretilmiş olabilir.
4. **D10Z_K_LEBLEBI "devrim":** D6'daki "icat" düzeltmesiyle hizalansın mı (§4)?
5. **Niko varyantları:** `wip/niko-yeniden` D4B_N_01'i yeniden yazıyor, ama D4B_N_01_NOFEZ, D4B_N_03_NOFEZ ve "Annen de mi ayna?" (D4B_NIKO_PHONE) o dalın 12 anahtarında yok. O dal uygulanırken bunlar da birlikte değişmeli.
6. **D7_EMP_FORM:** İlk turun "Formlar imparatorun adıyla başlar"ını kabul ettim. Daha Türkçe bir ses oyunu seçeneği de var: "İmparatorlar form doldurmaz. Doldurtur." Bu, İmparator'u biraz daha buyurgan gösterir. Hangisi?
7. **D4A_T_WIN_TAPE:** "gurur duyardı"yı ret ettim. Sahibi Tolga'nın ağzında daha deyimli bir söz isterse ilk turun "görse göğsü kabarırdı"sı hazır.
8. **[Yunanca] etiketi (çeviri dışı):** D7_AWE_EMPEROR ve D7_AWE_THEODOROS'ta etiket yok. İmparator'un ve Theodoros'un öbür repliklerinde var.
9. **Şiddet 1 şüpheliler** (dokunmadım): ITEM_SELF_CUBE_2 "İlerleme." (D7_NIKO_HELLO'daki aynı kalıp düzeltildi), D9_LUTFI_YES "Harika!" (1453 tercümanında), ITEM_SELF_TAPE "Bu bir hastalık mı?", D3_H_21 "Genel olarak.", D4B_T_CELL, D4B_NIKO_TAPE.
10. **INLINE.json:** §5'teki on girdi strings.csv ile aynı işlemde güncellensin. Yoksa `check_inline` FAIL verir ve ses eski cümleyi okur.

## 7. En iyi on: önce | sonra

| anahtar | önce | sonra |
|---|---|---|
| D7_EMP_FORM (tr/en) | Formlar imparatorları doldurur. / Forms fill in emperors. | Formlar imparatorun adıyla başlar. / Forms begin with an emperor's name. |
| D2_H_09 | **Yakında** kıyı var ama askerler de var. | **Yakınlarda** kıyı var ama askerler de var. |
| D7_N_HOT | Şüpheli buraya bağlı. Hâlâ burada ya da çok yakında. | Şüpheli buradan kopmamış. Ya hâlâ burada ya da hemen yakınlarda. |
| D5_H_HATCH_EMPTY (tr/en) | Bodrum boş bir şey istemez. / The cellar doesn't want nothing. | Bodruma eli boş inilmez. / No use going down empty-handed. |
| D6_KADRI_CHICKPEAS | ...ama çıtır! Bu bir devrim. Adı ne? | ...ama çıtır! Bu ne icat böyle! Adı ne? |
| D4A_ITEM_LIGHTER_2 | Büyücü değil, çakmaktaşı bu. Sadece küçük ve hızlı. | Büyücü ne be, çakmaktaşı bu. Ufak, çabuk çakanından. |
| D9_T_LUTFI_Q | Ve bu beni neden ilgilendiriyor? | Eee, bunun benimle ne alakası var? |
| D9_T_KADRI_YES | Ben evde makarnayı yakıyorum. Sorun değil. Sorun değil. | Ben evde makarnayı yakıyorum. Hallederiz. Hallederiz. |
| D3_H_VANISH | Garajım hayaletli oldu. | Garajı cin mi bastı ne? |
| D8_H_FAIL_LATE (+_HEIST, _PARTS) en | Opening time. | Bus time. |

## 8. Genel gözlem
- Dilim 1 ile dilim 2'nin büyük kısmı Türkçe düşünülmüş. Hasan ile Hüseyin, Büro, Cemil, Theodoros ve D8Y'nin havlu yürüyüşü en temiz bölümler.
- İlk turun önerileri isabetli. Asıl eksikleri **kopya metinler** (REACT_*, seçenek düğmesi) ve **INLINE.json**. Bunlar atlanırsa düzeltme oyunda yarım görünür ve ses eski kalır.
- Kalan çeviri izi en çok **kısa bağlantı repliklerinde** ve **tek kelimelik ironik ünlemlerde** ("İlerleme.", "Bir tür.", "Ciddi misin?").
