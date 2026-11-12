# Çeviri kokusu taraması · Dilim 8 raporu

## Sayılar
- **Okunan satır: 688** (anahtar başına TR + EN, hepsi; atlama yok). İçerik: eşya tepkileri `REACT_*` (Hikmet'ten çocuğa 32 karakter, `_REPLAY` dahil), mini oyunlar `MG_*` (Kadri'nin Kazanı, Galata pazarlığı, Mangala, okçuluk), ortam lafları `DST_*` (Bizans ve ordugâh halkı, `AGAIN`, `ODD`, `WARN`, Tolga'nın cevapları).
- **Önerilen düzeltme: 43 satır, 42 anahtar** (`docs/_ceviri/dilim_8.csv`).
  - **TR: 36** · şiddet 3: 1 · şiddet 2: 21 · şiddet 1: 14
  - **EN: 7** · şiddet 2: 2 · şiddet 1: 5
- Oran yaklaşık %6. Dilim genel olarak temiz: çoğu replik kısa, Türkçe kurulmuş ve espri ritmi yerinde.
- Her önerinin `eski` metni `i18n/strings.csv` ile birebir karşılaştırıldı. Uzunluk eskisinin %70–130'u arasında. Yeni rakam, kısaltma ya da parantez notu eklenmedi.

## En iyi on (önce | sonra)
| Anahtar | Önce | Sonra |
|---|---|---|
| `REACT_KID_POWERBANK` | Kaç **mermer** eder? | Kaç **misket** eder? *(marbles = misket; tek şiddet 3)* |
| `REACT_CALLIGRAPHER_SELFIE` | Resim yasak değil ama **elimi çek**. | Resim yasak değil ama **elimi dürtme**. *(eskisi ters anlam veriyordu)* |
| `MG_ARC_H_BULL_2` | Hüseyin'e söyleyeceğim, kıskançlıktan **çayını soğutacak**. | Hüseyin'e söyleyeceğim, **kıskançlıktan çatlasın**. *(EN: green with envy)* |
| `REACT_NOTARY_BOOK` | Tarih kitabının tarihi belli değil. **İroni.** | ... **Şu işe bak.** |
| `DST_CIVB_AGAIN_2` | **Biz artık dedikoduyuz.** | **Dillere düştük artık.** |
| `DST_OSMSOL_IDLE_4` | Sonra çavuşu duymuyorum. **Çifte kazanç.** | ... **Bir taşla iki kuş.** |
| `REACT_TAILOR_LIGHTER` | Bu ipek Venedik'ten geldi, **ateşle tanışması gerekmiyor**. | ... **ateş yüzü görmeyecek**. |
| `REACT_CANDARLI_PHONE` | Işığı söndür. **Kukuletanın bir anlamı kalmıyor.** | Işığı söndür. **Yoksa bu kukuletayı niye taktım?** |
| `DST_JAN_IDLE_4` | Börkünü düz tut diyorlar. **Rüzgâr başka türlü düşünüyor.** | ... **Rüzgâra söylesinler.** |
| `REACT_GUARDS_LIGHTER` | Hüseyin: "Büyücü değil, çakmaktaşı bu. **Sadece küçük ve hızlı.**" | Hüseyin: "**Ne büyücüsü be**, çakmaktaşı bu. **Ufağı, o kadar.**" |

## Şüpheli (dokunmadım, sahibine sorulabilir)
- `REACT_EMPEROR_CUBE` TR "Şu an bulmacaya ihtiyacım yok." "I don't need a puzzle right now" kalıbı. Ama EVREN'de (GDD §8 #10) kanon alıntı olarak geçiyor, o yüzden dokunmadım. Öneri: "Benim bulmacam zaten yeterince var." (EN zaten öyle: "I have enough puzzles at present.")
- `REACT_HIKMET_PHONE` "...Adil yani." "Fair's fair" kokusu hafif. Hikmet'in ağzında "Ödeştiniz yani." olabilir ama kime karşı ödeşildiği belirsizleşiyor.
- `REACT_KADRI_REPLAY_4` "Seni üç kere unutmadım." / "I've not forgotten you three times." İki dilde de İngilizce espri iskeleti gibi duruyor, ama tekrar oynama esprisi olarak çalışıyor da olabilir.
- `REACT_LUTFI_TAPE` "İsmi zaten mükemmel." Lütfi'nin kelime kelime çeviri yapan karakteri yüzünden bilerek mi bırakılmış, emin değilim.
- `REACT_FISHMONGER_BOOK` "Kitap mı bu, çarşı mı?" TR ve EN ikisi de anlamsız ama çeviri izi değil, mantık sorunu.
- `DST_T_ODD_4` (Tolga) "Selfie çekerken izlenmek ayrı bir duygu." Plaza ağzı, karakter gereği diye bıraktım.
- EN tarafında `REACT_DERVISH_TAPE` "My brother." Dervişin tasavvufi hitabı olarak bıraktım. Öbür "brother"ları "friend"e çektim.

## Dokunmadığım ama bağlı olan replikler (başka dilimde)
Aynı metin oyunda ikinci bir anahtarla da geçiyor. Tutarlılık için aynı düzeltme önerilir:
- `D4A_ITEM_LIGHTER_2` = `REACT_GUARDS_LIGHTER`
- `D6_KADRI_TAPE` = `REACT_KADRI_TAPE`, `D6_KADRI_SELFIE` = `REACT_KADRI_SELFIE`
- `D12_F_ITEM_TAPE` = `REACT_FATIH_TAPE`
- `MG_HAG_NIKO_FAIR` aynı "Biraz daha in / Come down a bit more" yön hatasını taşıyor (bkz. aşağıda).

## Niko satırları
`REACT_NIKO_*` (11), `REACT_NIKO_REPLAY_1…5` ve `MG_HAG_NIKO_*` (8) `wip/niko-yeniden` dalındaki `docs/NIKO_YENIDEN.md` kapsamında, orada baştan yazılıyor. Çakışma olmasın diye bu dilimde hiçbirine öneri yazmadım. Not: `REACT_NIKO_PHONE` "Annen de mi ayna?", yazım kuralı 3'ün yasakladığı ödünç hakaret kalıbı. NIKO_YENIDEN bunu zaten "BAŞTAN" diye işaretlemiş.

## Genel gözlemler
- **En çok koku nerede:** eşya tepkilerinin yan karakterleri (hattat, terzi, noter, Çandarlı, ressam) ve ortam lafları. Kalıp hep aynı: İngilizce espri kapanışı tek kelimeyle ya da bir yüklemle çevrilmiş ("İroni.", "Ortaklık?", "Çifte kazanç.", "Fakir bir krallık.", "Adalet bu.", "Bu bir hakaret."). Türkçede bu kapanışlar deyimle ya da sitemle yapılır.
- **İkinci kalıp:** İngilizce kişileştirme ve deyimlerin çevirisi ("rüzgâr başka türlü düşünüyor", "ateşle tanışması", "bıyığı taşımıyor", "sabır bir erdemdir... sınanıyor", "bu konuşmayı yaptık").
- **Anlam kayması** (çeviri hatası sonucu): `REACT_CALLIGRAPHER_SELFIE` ("elimi çek"), `REACT_DOUBLE_THERMOS` ("biri sana değil" ↔ "neither"), `REACT_KID_POWERBANK` ("mermer").
- **Pazarlık yön hatası:** `MG_HAG_WINE_FAIR` ve `MG_HAG_NIKO_FAIR` "Biraz daha in" / "Come down a bit more". `minigame_haggle.gd` içinde FAIR, oyuncunun makul teklifine satıcının verdiği cevap. Satıcının alıcıya "in" demesi iki dilde de ters. Wine için "Biraz daha çık, düşünürüm." / "Go up a bit." önerdim. Niko'nunki Niko yeniden yazımına bırakıldı.
- **EN tarafı** büyük ölçüde İngilizce düşünülmüş, hatta çoğu yerde Türkçesinden daha esprili (Kadri'nin "Dates! Now there's a fruit." eklemesi gibi). Türkçe kokan tek iz `brother` hitabı (Hasan, hamal, Osmanlı askeri) ve harfiyen aktarılmış birkaç cümle (`REACT_HIKMET_CUBE`, `REACT_KID_LIGHTER`).
- **Temiz kalanlar:** Hasan ile Hüseyin, Sorucu Ağa, Urban (bozuk Türkçe bilerek), Theodoros ve Bizans kâtibi, Kadri'nin kazan replikleri, Tolga'nın plaza cevapları (`DST_T_*`), Bizans kadını ve azap lafları. Bunlar Türkçe düşünülmüş, dokunmadım.
- Oynanış sırasında çalan kısa replikler (`DST_*`, `MG_ARC_*`) uzatılmadı. Hepsi eski uzunluğun %70–130'u arasında, çoğu eşit ya da daha kısa.
