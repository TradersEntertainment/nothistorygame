# Çeviri kokusu taraması · Dilim 4b · Rapor

Komut: `python3 docs/_ajan/gorev/ceviri_dilim.py 4 b` · Teslim: `docs/_ceviri/dilim_4b.csv` · Dal: `wip/ceviri-4b`

## Sayılar
- **Okunan satır: 483 / 483** (hepsi, TR ve EN sütunu birlikte). Dağılım: D_ (tırmanma, Nihat uçuşu, tanıklar, simgeler) 97 · D12 16 · D12B 11 · D13 13 · D14 15 · D15 78 · D16 3 · D17 49 · D17E (Edirne 1444 arası) 162 · D18 23 · D18B 16.
- **Öneri: 34 satır (34 anahtar), yaklaşık %7.**
  - TR: 29 (şiddet 3: 1 · şiddet 2: 20 · şiddet 1: 8)
  - EN: 5 (şiddet 2: 4 · şiddet 1: 1)
- Kalıp tekrarı: tanık sözlerinden üç cümle (kuş, melek, yüzüne bakmayın) dört ayrı anahtarda aynen geçtiği için 10 satır bu üç düzeltmeden geliyor. Gerçekte **24 ayrı düzeltme** var.
- Bağlam: önerilen her repliği geçtiği betikte komşularıyla birlikte okudum (`chapter12b.gd` _k = İmparator, `nihat_powers.gd` WIT_KEYS, `interlude_edirne.gd`, `chapter17.gd`, `chapter18b.gd`). Süreli replikler (tanık, tırmanma, top) uzatılmadı. Yeni rakam, kısaltma ya da parantez eklenmedi.

## En iyi on (önce → sonra)
| Anahtar | Önce | Sonra |
|---|---|---|
| D14_N_W2_ARREST | Bir ay tanık oldunuz, **Bay Tolga**. Sıranız **hâlâ** gelmeyecek. | Bir ay tanık oldunuz, **Tolga Bey**. Sıranız **yine de** gelmeyecek. |
| D_WIT_9 / AZ_4 / WMN_2 / GEN_4 | O... o bir kuş değil. Kuşlar kravat takmaz. | O... o kuş değil. Kuş kravat takar mı hiç? |
| D_WIT_2 / TWN_2 / WMN_1 / MNK_2 | Melek mi o? Neden şapkası var? | Melek mi o? Meleğin şapkası mı olur? |
| D17E_V_POL_2 / V_POL_3 / T_WHAT_POLICY (EN) | A stake. … A stake. Through the purse. I like it. I'll stake everyone. | Leeching. … Leeching. I like it. I'll bleed everyone dry. |
| D17E_G_01 (EN) | knowledge taken standing stays standing | learning taken standing up never settles in |
| D17E_T_BRUTUS_2 | Bunu **kesinlikle** söylememeliydim. | **Hiç ama hiç** söylememeliydim. |
| D12B_K_DONE_GEDIK | Theodoros bana dün gece surdaki gediği yapışkan bezle sağlamlaştırdığını söyledi. | Theodoros anlattı: dün gece surdaki gediği yapışkan bir bezle sarmışsın. |
| D18B_G_HIT_2 | Yarın yine yaparlar ama bugün yaptık! | Yarın yine kurarlar ama bugün bizimdi! |
| D17E_M_TO_AVLU | Biri çok **ilginçtir**. | Biri pek **acayiptir**. |
| D_CLIMB_TIRED_3 | Kollarım kalem tutmak için yapılmış, duvar için değil. | Benim kollarım kalem tutar, duvar tutmaz ki. |

Espri notları (kural 5):
- **Kazık / Leeching:** Türkçede "kazık" hem dolandırmak hem Kazıklı Voyvoda olduğu için komik ve TR aynen kalıyor. İngilizcede "stake" dolandırmak demek değil. "Leeching / bleed dry" hem para sızdırmak hem kan emmek demek, böylece aynı sahnedeki Drakula esprisine bağlanıyor.
- **Kuş / melek:** Türkçede şaşkın köylü düz bir gözlem yapmaz, karşısındakine soru atar ("takar mı hiç?"). İngilizce "Birds don't wear ties" kendi ritminde zaten komik, ona dokunmadım.
- **Kalem/duvar:** Türkçede "tutmak" fiilinin iki anlamıyla kurulan bir ikileme. İngilizce "built for holding pens, not walls" kendi dilinde iyi duruyor, dokunmadım.

## Bağlı anahtarlar (dilim 4a'da, dokunmadım; 4a yazarına ya da sahibine)
- `D12_END_12_1_3` ve `D12_END_12_4_3`: `_NONAME` eşleriyle aynı cümleler ("sadece dedikodu olur", "Tam doğru zamana"). Birlikte değişmeleri gerekiyor.
- `D14_N_W2`: "Bay Tolga" burada da geçiyor. `D14_N_W4`: "Bu farklı." burada da geçiyor.
- `D12B_K_DONE_1`: GEDIK ile aynı cümle.

## Dokunmadığım ama komşusu değişen replikler
- `D17E_T_POL_3` ("No, a policy."): değişmedi. Yeni "Leeching." repliğine de cevap olarak oturuyor.
- `D17E_N_WHAT_POLICY` (EN "Its logo is a stake."): Kazıklı Voyvoda göndermesi olarak doğru kalıyor.
- `D17E_R_KEB_2` ("Abim gülümsedi!"): "…Güzelmiş." repliğine cevap olarak aynen oturuyor.
- `D12B_K_DONE_OMUZ`, `_UYARI`, `_NOBET`, `_SON`: GEDIK'ten sonra parça parça söylenen cümleler. Yeni GEDIK cümlesi "Garip bir hediye." ile bittiği için zincir bozulmuyor.

## Şüpheli (dokunmadım; sahibine sorulabilir)
- `D_NIHAT_FLY_FIRST`: "Yerçekimi başvurum geçici olarak askıya alındı" (EN "My application for gravity"). Mantık iki dilde de biraz ters. Öneri: "Yerçekiminden geçici muafiyetim onaylandı" / "My temporary exemption from gravity has been approved."
- `D_WIT_5`: 1453'teki bir tanığın ağzında "Evliya Çelebi". Bilerek yapılmış bir anakronizm mi, yoksa EN'deki gibi "bir vakanüvis" mi olmalı?
- `D_WIT_10`, `D_WIT_TWN_1`, `D_WIT_GRD_3`: "Vergi memuru uçuyor!" 1453 için "tahsildar" daha yerinde olabilir, ama "vergi memuru" esprisi de çalışıyor.
- `D15_S7_T_OFF`: "sigortacı gibi hissediyorum". "I feel like" kalıbı, ama Tolga'nın bugünkü ağzında doğal.
- `D17E_M_DUNNO`: "'Bilmiyorum' diyebilen ödülü hak eder". "deserves" kalıbı hafif çeviri kokuyor, ama Fatih'in ödüllendirme yayına bağlı.
- `D12B_K_DONE_OMUZ`: "Bir komutanın omzu ısınmış" (bayrak `giust_armored`, yani zırh). İki dilde de belirsiz: "omzu ısınmak" Türkçede deyim değil. Öneri: "Bir komutanın omzu zırha kavuşmuş."
- `D16_H_GONE_HUFEZ` (EN "the Frank on our shoulders"): TR "omzumuzdaki" sorumluluk anlamında okunuyorsa EN "the Frank we were minding" olmalı.

## Genel gözlemler
- Dilimin çoğu temiz. **D15 (1977 acente, ofis, Hikmet)** ve **D18/D18B (köprü)** neredeyse hiç çeviri kokmuyor; "Fesliye veresiye", "Babaannen de iyiymiş", "Seç bakalım, kâtip" gibi yerli replikler bol.
- Çeviri izi en çok **tanık sözlerinde** (`D_WIT_*`). Kısa, İngilizce gözlem esprisi olarak kurulmuşlar ("X değil. Y'ler Z yapmaz.", "Neden ... var?") ve dört konuşmacı sınıfında aynen tekrar ediyorlar.
- İkinci sırada **D17E (Edirne 1444)** geliyor. Şehzade ve Vlad'ın ağzında "ilginç", "merak ediyorum", "Bu iyi" gibi bugünün çeviri Türkçesi kalıpları var. İngilizce sütunda iki Türkçe vecize ve cinas harfiyen aktarılmış (ayakta ilim, kazık).
- Nihat'ın sesi genelde sağlam. Tek kırık yer `D14_N_W2_ARREST`/`D14_N_W2`'deki "Bay Tolga"; başka her yerde "Tolga Bey" diyor.
- **Konuşmacı etiketi hatası (çeviri değil, VOICE_MAP için not):** dilim betiği `D12B_K_DONE_*` satırlarını SPK_KADRI gösteriyor, ama `chapter12b.gd` bu satırları `_k()` ile, yani **SPK_EMPEROR** olarak söyletiyor. İçerik de İmparator'un (EN "the breach in our wall"). Seslendirmeden önce düzeltilmeli. `D18_HA_01*`, `D18_N_01_CAPTIVE`, `D17E_CAP_*` satırlarında da konuşmacı "?".
