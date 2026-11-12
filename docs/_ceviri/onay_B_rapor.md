# Çeviri ikinci okuma + denetim · Grup B (dilim 3 ve dilim 4)

Denetçi: bağımsız ikinci yazar. Kaynak: ilk turun `wip/ceviri-3`, `wip/ceviri-4a`, `wip/ceviri-4b` teslimleri.
Her satır geçtiği betikte, komşularıyla, sahne sırasına göre okundu (`scripts/chapter10a…18b.gd`, `chapter29.gd`,
`interlude_edirne.gd`, `side_events.gd`, `level/`, `player/`, `npc/`, `ui/hud.gd`). Anahtarı betikte harfi harfine
geçmeyen satırlar (`"D10G_T_W_%d"`, `"D11_N_ITEM_" + pick`, `DSET_*` vb.) kurulduğu yerde okundu.

Teslim dosyaları:
- `docs/_ceviri/onay_B.csv`: uygulanacak son liste (127 satır; **117'si `kabul`/`duzelt`, oyuna girecek**; 10'u `ret`).
- `docs/_ceviri/kapsam_B.csv`: 2.898 satır = 1.449 anahtar × 2 dil (dilim 3: 484 anahtar / 968 satır; dilim 4: 965 anahtar / 1.930 satır). Hüküm: `iyi` 2.770 · `oneri` 115 · `supheli` 13.

Oyun dosyalarına dokunulmadı. Öneriler `i18n/strings.csv`in geçici bir kopyasına uygulanıp metin testleri çalıştırıldı (aşağıda).

## 1. İlk turun denetimi: 117 öneri

| Dilim | Öneri | kabul | duzelt | ret |
|---|---|---|---|---|
| 3 | 45 | 39 | 3 | 3 |
| 4a | 38 | 33 | 2 | 3 |
| 4b | 34 | 27 | 3 | 4 |
| **Toplam** | **117** | **99** | **8** | **10** |

İlk tur iyi iş çıkarmış: önerilerin çoğu gerçekten çeviri kokusunu gideriyor ve sahnede işini görüyor. Asıl kusurlar
iki yerde: (1) birkaç önerinin gerekçesi yanlış (Türkçede doğal olan kalıp "çeviri" sanılmış), (2) **varyant ve alıntı
eşlemesi atlanmış**: aynı cümleyi taşıyan kardeş anahtar ya da repliği aynen alıntılayan seçenek değişmeden kalıyordu.

### Ret (10) ve gerekçeleri
| Anahtar | İlk turun önerisi | Neden ret |
|---|---|---|
| D11_M_LOST, D11_M_LOST_HEN | 'Yukarısı gülmedi' → 'Yukarıda gülen olmadı' | 'Yukarısı' Büro'nun kişileştirilmiş, tekrar eden adı: D14_M_02 'Yukarısı bekliyor', D14_N_03 'Yukarısı hep bekler', D14_M_SICIL, D14_M_FIXED 'Yukarısı sever'. Bu ilk geçişi; değiştirmek tekrar eden sözü koparır. |
| D11_N_BOOM | 'tavanı deldi' → 'tavan yaptı' | 'Tavanı delmek' Türkçede yerleşik; 'deldi' sınırın aşıldığını (Paradoks 90+) söylüyor, 'tavan yaptı' yalnız zirveyi. |
| D13_T_1977_3 | 'SEN dans ediyorsun' → 'Dansı SEN edeceksin' | Gerekçe yanlış: Türkçede şimdiki zaman kesin emir işi görür ('Hemen yatıyorsun!'). Genç Hikmet'in 'Dans mı ediyorsun?' sorusuna aynı fiille dönen bilinçli yankı. |
| D14_N_W4_ARREST | 'Bu farklı' → 'Bu başka' | 'Bu farklı' doğal Türkçe; kardeşi D14_N_W4 da 'Bu farklı.' diye açılıyor, yalnız bir kolu değiştirmek iki kolu ayırır. |
| D15_S_W5 | 'Ne pazarlama ama' → 'Pazarlamaya bak sen' | 'Ne X ama!' Türkçenin kendi ünlemi; zevk farkı. |
| D15_S_W5B | 'Tarih ne tuhaf' → 'Tuhaf iş şu tarih' | Doğal ünlem, kulak tırmalamıyor (şiddet 1 ölçütü karşılanmıyor). |
| D_WIT_TWN_5 | 'Önce vergiyi uçurdular' → 'Vergiler göğe çıkmıştı' | 'Fiyatları uçurdular' yerleşik; 'uçan memur / vergiyi uçurdular' ses oyunu eskisinde daha güçlü. |
| D17E_V_POL_2 (en) | 'A stake.' → 'Leeching.' | İngilizcede 'stake' hem 'pay, yatırım' hem 'kazık': sigorta konuşmasında çift anlamlı, Kazıklı Voyvoda bağını taşıyor. 'Leeching' bağı koparıyor ve D17E_N_WHAT_POLICY 'Its logo is a stake' ile çelişiyor. |
| D17E_T_WHAT_POLICY (en) | 'liked the stake' → 'liked the leeching' | Yukarıdakinin geri dönüşü; 'stake' kalınca bu da kalır. |

### Düzelt (8)
| Anahtar | İlk tur | Son metin | Neden |
|---|---|---|---|
| D10G_T_W_3 | Laf olsun diye soruyorum… | Öylesine soruyorum. Şarap içmem, sigortacıyım. | Seçenek UI_CH10G_W_ASK bu sözü alıntılıyor; 'Laf olsun diye' kutuda %142 oluyordu. |
| D10H_T_G_WARN | …Bir gün... siz yine de dikkat edin. | …Bir gün... neyse, siz dikkat edin. | 'Yine de' olmayan bir karşıtlık katıyordu; Tolga söyleyemeyeceğini yutuyor. |
| D10Z_K_MAIN_OK_1 | …Tencere kapağını buldu. | …Tam ona göre. | Deyim 'birbirine layık' alayı taşır; Sultan'ı yahninin kapağı yapmak Fatih sınırına giriyor (EVREN §1). |
| D12_F_WHO_A | …olmadan parayı peşin toplayan… | …olmadan önce parayı toplayan… Tuhaf bir zanaat. Cüretli de. | D12_F_CANNON_D 'olduktan sonra gelen adam' bu sözün aynası; 'önce' düşünce ayna zayıflıyordu. |
| D18B_G_HIT_2 | …ama bugün bizimdi! | …Yarın yine kurarlar ama bugün yıktık! | 'Bugün bizimdi' de hazır kalıp; 'kurarlar / yıktık' eskisinin 'yaparlar / yaptık' oyununu Türkçe kuruyor. |
| D17E_V_POL_3 (en) | Leeching. … bleed everyone dry. | A stake. I like it. I'll give everyone a stake. | Sorun gerçek ama çözüm 'stake' üstünde: 'give everyone a stake' = herkese pay / herkese kazık. |
| D_PERCH_AYA | …şöyle bir bakayım. | …öylece bakıyorum. | 'Şöyle bir bakayım' = hızlıca göz atayım; Nihat'ın seyre daldığı an kayboluyordu. |
| DSET_T_FX_OFF_2 | …lafta kaldı, kâğıt üstünde. | Patlamalar artık kâğıt üstünde kaldı. | İki deyim üst üste yığılmıştı. |

Bir not: D14_N_W2_ARREST `kabul` edildi ama gerekçesi kısmen yanlış. Nihat Perde I–III'te bilerek 'Bay Tolga' der
(26 replik), Perde IV'ten sonra 'Tolga Bey' (151 replik). Bu replik kuşatma ayından sonra çaldığı için 'Tolga Bey'
yaya uygun; **ama ilk turun `bagli`de andığı D14_N_W2 'Bay Tolga' olarak kalmalı.**

## 2. İkinci okuma: yeni öneriler (10)

| Dilim | Yeni | Anahtarlar |
|---|---|---|
| 3 | 1 | D10H_K_CANT_SAY (en) |
| 4 | 7 | D12_END_12_1_3, D12_END_12_4_3, D12B_K_DONE_1 (varyant eşlemesi); D17_N_CAM_4_NOSHOT, D_DOWNED_N_3 (Nihat'ın 'siz'den 'sen'e kayması); D_CLIMB_FALL_2; D17E_R_LEG_0 (en) |
| dış (dilim 9, bağlı) | 2 | UI_CH10G_W_ASK, UI_CH10H_G_NOTHING (repliği alıntılayan seçenekler) |

İlk turun kaçırdığı gerçek çeviri izleri azdı; bu iki dilim ilk turda iyi taranmış. Yeni bulunanların ortak deseni:
**İngilizce 'you'nun ayrımsız çevrilmesi** (Nihat Tolga'ya her yerde 'siz' derken iki barkta 'Kalk', 'Çekmedin mi'),
**Türkçe hitabın İngilizceye harfiyen geçmesi** (Radu: 'Abi!' → 'Brother!'; İmparator: 'yolun açık olsun' → 'may God
keep your road open').

## 3. Varyant ve alıntı eşlemeleri
- D10G_T_W_3 ↔ seçenek UI_CH10G_W_ASK ('Sadece soruyorum.'): ikisi birlikte 'Öylesine soruyorum'.
- D10H_G_NOTHING ('Öylesine mi uğradın?') ↔ seçenek UI_CH10H_G_NOTHING ('Sadece uğradım'): seçenek 'Öylesine uğradım'.
- D10H_T_G_WARN ↔ UI_CH10H_G_WARN ve PF_GIUST_WARNED: yalnız ilk iki cümleyi alıntılıyorlar, değişmez.
- D12_T_CONFESS ↔ UI_CH12_CONFESS; D11_T_HONEST ↔ UI_CH11_T_HONEST: alıntılanan kısım değişmiyor.
- D12_END_12_1_3_NONAME ↔ D12_END_12_1_3; D12_END_12_4_3_NONAME ↔ D12_END_12_4_3; D12B_K_DONE_GEDIK ↔ D12B_K_DONE_1: ilk tur (4b) yalnız birini değiştirmişti, kardeşi eklendi.
- Birlikte giden gruplar (hepsi onayda): D11_N_03 ×4; D11_T_BYZ ×2; D11_N_KNOWN ×2 (tr+en); D11_T_HELP_4 ×2; D14_M_FIXED ↔ D14_N_FIXED; D16_G_CATCH_2 ↔ _3; D_WIT 'kuş' ×4 (D_WIT_9, _AZ_4, _WMN_2, _GEN_4); D_WIT 'melek' ×4 (D_WIT_2, _TWN_2, _WMN_1, _MNK_2); D_WIT 'sakın' ×2 (D_WIT_8, _TWN_3); Vlad 'stake' zinciri (D17E_V_POL_2/3, D17E_T_WHAT_POLICY, D17E_N_WHAT_POLICY).
- Değişmemesi gerekenler: D14_N_W2 ('Bay Tolga'), D14_N_W4 ('Bu farklı'), D11_M_LOST ailesi ve 'Yukarısı' geçen D14 replikleri.

## 4. Metne bakan testler ve araçlar
- `tests/check_voice_rules.py` (Hristiyan karaktere İslami yemin yok, seçenek ≤ 60 karakter): değişiklikler uygulanmış kopyada **PASS** (9.665 anahtar, 0 sorun).
- `tests/check_inline.py`: **16 anahtar `docs/voice/INLINE.json`'da da var**; altyazıyla birlikte güncellenmezse test FAIL verir ve `tools/voice_gen.py` eski cümleyi okur (CLAUDE.md'deki uyarı). Etiketleri korunmuş önerilen INLINE metinleri:
  - D17E_G_01 en: `[stern] Mehmed. Sit. [dry] The guest too; [wise] learning taken standing up never settles in.`
  - D17E_M_TO_AVLU tr: `[eager] Gel, seni arkadaşlarımla tanıştıracağım. Biri pek acayiptir.`
  - D17E_R_KEB en: `[eager] I'll get lamb from the kitchen. [grinning] The head cook grumbles, but he hands it over.`
  - D17E_R_LEG_0 en: `[scared] [squeaky] Vlad! There's a bat on the wall!`
  - D17E_T_BRUTUS_2 tr: `[whispers] [horrified] Bunu söylememeliydim. [panicked] Hiç ama hiç söylememeliydim.`
  - D17E_T_NONE_2 tr: `[nervous] Yok. [forced compliment] Sopan… güzelmiş.`
  - D17E_V_02 tr: `[bitter] [flat] Babam bizi burada bıraktı. Şimdi duyduk ki Haçlılarla birlik oluyormuş. [darkly] Sultan bizi kestirir mi acaba?`
  - D17E_V_KEB tr: `[chewing] [surprised] [reluctantly] …Güzelmiş.`
  - D17E_V_POL_3 en: `[deadpan] A stake. [slow smile] I like it. [darkly amused] I'll give everyone a stake.`
  - D_CLIMB_FALL_2 tr: `[groaning] [wry] Yerçekimi bugün fazla mesai yapıyor.`
  - D_CLIMB_TIRED_3 tr: `[straining] [whining] Benim kollarım kalem tutar, duvar tutmaz ki.`
  - D_LM_ZINCIR tr: `[thoughtful] Haliç'in zinciri. Kütüklerin üstünde demir halkalar. [grave] Yakında gemiler karadan yürüyecek; zincir buna hazır değil. [quietly] Hazır olan da yok.`
  - D_PERCH_AYA tr: `[awed] [softly] Kubbenin tepesindeyim. Dokuz yüz yıllık kurşun, altımda ılık. [whispers] Bir dakika... öylece bakıyorum.`
  - D_WIT_2 tr: `[awed] [confused] Melek mi o? Meleğin şapkası mı olur?`
  - D_WIT_8 tr: `[nervous] [whispers] Kimse bir şey demesin. Sakın yüzüne bakmayın.`
  - D_WIT_9 tr: `[stammering] O... o kuş değil. [baffled] Kuş kravat takar mı hiç?`
- `tools/trailer/trailer.gd`: D10B_T_B3_2 fragmanda. Satır 10 ve 185'teki yorumlar eski cümleyi alıntılıyor; `LEAD_SILENCE["tr:D10B_T_B3_2"] = 2.05` eski kaydın baştaki sessizliğine göre ölçülmüş, satır 1181'deki süre (3.2 sn) de. Yeni ses üretilirse ikisi yeniden ölçülmeli.
- `tests/` altında bu dilimlerin metnine harfi harfine bakan başka test yok (ayırt edici parçalar `tests/ scripts/ tools/` içinde arandı; diğer eşleşmeler 'ya da' gibi rastlantı).
- Uzunluk: bütün `kabul`/`duzelt` metinleri eskisinin %70–130'u içinde. Yeni rakam, kısaltma ya da parantez notu eklenmedi.

## 5. Sahibine sorulacaklar
1. **VOICE_MAP hatası:** D12B_K_DONE_GEDIK, _OMUZ, _UYARI, _UYARI_1, _NOBET, _NOBET_1, _SON_1 İmparator'un replikleri (`chapter12b.gd`, `_k` = SPK_EMPEROR), ama `VOICE_MAP.csv`'de SPK_KADRI (kaynak 'ad': anahtardaki `_K_`den tahmin). Böyle seslendirilirse İmparator'un sözlerini Kadri okur. Düzeltilsin mi?
2. VOICE_MAP'te konuşmacısı olmayan seslendirilecek replikler: D18_N_01, D18_N_01_CAPTIVE (Nihat), D18_HA_01, D18_HA_01_NOFEZ (Hasan).
3. D13_H_BACK_DEPOT: Hikmet 'Rıza Bey' diyor; depo memurunun adı her yerde 'Asır' (SPK_RIZA = Depo Memuru Asır, D3_N_12, D_NIHAT_EXPLORE). Eski ad mı kalmış?
4. Lütfi'nin 'güçlü bir belki'si (D10H_L_ANSWER, _L_SHAME, _E_MAYBE, _E_FIXED_2, _T_RADIO_SHAME): İngilizce 'a strong maybe'den geliyor ama Lütfi deyimleri birebir çevirir (EVREN) ve beş replikte dönen bir şaka. Kalsın mı?
5. Nihat'ın hitabı: Perde I–III 'Bay Tolga', Perde IV'ten sonra 'Tolga Bey'. Bilinçli bir yay mı? (Denetim bunu varsayıp D14_N_W2'yi korudu.)
6. D_WIT_5: 1453'teki bir tanık 'Evliya Çelebi bunu yazsa…' diyor (Evliya 1611 doğumlu); EN 'a chronicler' diyerek kaçınmış. Bilinçli anakronizm şakası mı, düzeltilsin mi?
7. D11_N_ITEM_PHONE ('Artık form yok. Formlar bitti. Siz bitirdiniz.'): telefonla bağı anlaşılmıyor (ilk tur da sordu).
8. Vlad'ın 'kazık' cinası İngilizcede 'stake' (pay/kazık) üstünde tutuldu; ilk turun 'leeching' önerisi reddedildi. Onay?
9. İngilizcede 'koli bandı' çoğunlukla 'duct tape' (29), beş yerde 'packing tape' (D15_O_EVENING_A, D18_U_MISS_3, UI_C20_TAPE, UI_C26_WOUND_TAPE, SIEGE_NOTE_20_2). Birleştirilsin mi?
10. D10A_F_3 EN 'Will you sign it, you with the fez?': Fatih'in 'fesli' hitabı. İngilizcede 'you in the fez' ya da düz 'Will you sign it?' daha doğal; dokunulmadı, `supheli`.

`supheli` listesinin geri kalanı (kapsamda işaretli): D10H_N_DONE (Niko'nun sesi, NIKO_YENIDEN'e bırakıldı), D10L_D_DIG_2 ('Kalbine vurur gibi' iki dilde de bulanık), D11_T_04_SINERJI ('Kendini evlat edindi', Türkçede de güldürüyor).

## 6. En iyi on (önce | sonra)
| Anahtar | Önce | Sonra |
|---|---|---|
| D11_T_HELP_4 | Bir Denetçi ve bir sigortacı Fatih'in huzurunda. Bu fıkra gibi başlıyor. | Bir denetçiyle bir sigortacı Fatih'in huzuruna çıkmış... Valla fıkra gibi. |
| D12_F_KITCHEN | Yeterince merak etmedim. … | Merakımı yeterince uyandırmadın. … (EN: You haven't made me curious enough.) |
| D10H_T_03 | Bu cümlenin hiçbir kısmı beni rahatlatmadı. | Bu cümlenin neresi beni rahatlatacak? |
| D16_G_CATCH_3 | Tavuğun bir planı var Hasan. Gözlerinden anlıyorum. | Bu tavuk bir iş çeviriyor Hasan. Gözünden belli. |
| D15_G_EAVES | …Yağmurda kalmış birini sokmuş gibi. | …Yağmurda kalmış birini saçak altına almış gibi. |
| D_CLIMB_TIRED_3 | Kollarım kalem tutmak için yapılmış, duvar için değil. | Benim kollarım kalem tutar, duvar tutmaz ki. |
| D18B_G_HIT_2 | …Yarın yine yaparlar ama bugün yaptık! | …Yarın yine kurarlar ama bugün yıktık! |
| DSET_T_FPS_OFF_1 | Sayaç kapalı. Bilmediğin şey seni üzmez. | Sayaç kapalı. Göz görmeyince gönül katlanır. |
| D10H_K_CANT_SAY (en) | Go, and may God keep your road open. | Go, and may God guide your steps. |
| D_DOWNED_N_3 | …Kalk da sileyim. | …Kalkın da sileyim. (Nihat'ın 'siz'i) |

## 7. Uygulama notu
Uygulanacak liste `onay_B.csv`'deki `karar` = `kabul` ya da `duzelt` satırlarıdır (117); `yeni` sütunu son metindir.
Her satırın `eski` sütunu bugünkü `strings.csv` ile birebir eşleşiyor (geçici kopyada doğrulandı). Uygularken aynı
işlemde `INLINE.json`'daki 16 anahtar (bölüm 4) güncellenmeli ve D10B_T_B3_2 yeniden seslendirilirse fragmanın
sessizlik ölçüsü yenilenmeli.
