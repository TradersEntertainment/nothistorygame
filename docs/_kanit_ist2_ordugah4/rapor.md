# ORDUGÂH-4 raporu (dal `wip/ist2-ordugah4`, taban `wip/ist2-taban4`)

## 1. ÖNCE | SONRA paftası

`pafta_once_sonra.jpg`: `pafta_ordugah.jpg`'deki kameraların aynısı (sonda `tests/_ist/ordugah4_kare.gd`, ŞEHİR-3'ün `s3_*`
kameralarıyla aynı hesap). Sol ÖNCE (taban kodu, depo dışı kopya), sağ SONRA. Satırlar: 30 m, 70 m, otağ, sur dışı (kara_disi), hendek.
Altıncı kamera (gece) bu gönderimde YOK: gece koşusu sürüyor (bkz. §9, BAKILMADI). Tek kareler `once/`, `sonra/`.

| kamera | ÖNCE çizim / üçgen | SONRA çizim / üçgen | SONRA: karede kişi (≤400 m) / hayvan |
|---|---|---|---|
| ordu_30 | 1 069 / 3,70 M | 1 282 / 3,32 M | 1 148 / 36 |
| ordu_70 | 1 163 / 4,10 M | 1 396 / 3,46 M | 1 363 / 42 |
| otag_yakin | 256 / 2,39 M | 503 / 1,44 M | 1 189 / 62 |
| kara_disi | 856 / 2,74 M | 1 003 / 2,88 M | 781 / 19 |
| hendek | 1 305 / 2,85 M | 1 369 / 3,13 M | 455 / 8 |

(Çizim/üçgen: sondanın v2'nin TAMAMI (şehir + dünya + ordugâh + hayat); ÖNCE'de ordugâhta kişi/hayvan sayacı 0, çünkü yoktu.)

## 2. Kendi karelerime bakınca hâlâ kötü olanlar

- **Bütçe:** ordugâhın üstünde v2 toplamı 1 282–1 396 çizim (ÖNCE 1 069–1 163). Kişi ve gereç eklendi; çizim ARTTI. Hedef (v2
  payı ≤ 1 000 uçuşta) TUTMADI → madde 5 KISMEN/YAPILMADI. Üçgen düştü (4,10 → 3,46 M).
- **`hendek` karesi** hâlâ kötü ama karedeki kötülük SUR-4'ün zemini (parlak yeşil prizma, keskin bloklar); benim öğelerim bu
  kameranın arkasında (siper d ≈ 112). Bu karede ön hat okunmuyor: bu kamera ön hattın kanıtı değil.
- **Uzak katman (lod 2) koyu:** 70 m karesinin üst yarısında pişmiş uzak hücreler koyu kahve bir halı gibi (koyu kıl çadırlar +
  çamur lekesi); yakındaki obalardan daha koyu ve düz. Ton geçişi görünür.
- **Şahi'nin öküzleri** eski `_okuz` kutu modeli (kutu gibi). 20 öküz var ama "hayvan" değil "kahve kutu" okunuyor.
- **Yer karelerinde zemin** obanın çamur lekesi dışında yine düz yeşil çimen (dünya katmanı; benim lekelerim yalnız obaların altı
  ve yollar).
- **Otağ zokakı** düz, perdesiz kutu duvar; mazgal dişleri var ama kumaş kıvrımı/gerginliği yok. Otağın içi seyrek.
- **Kişiler donuk:** yakında gerçek model (Soldier, Crowd'un pişirdiği birebir kopya) ama Rig ile canlı oynamıyor (nefes/yürüyüş
  yok); "yürüyen bölük" duruyor. Belirme/kaybolma: lod 0 ↔ 1 geçişinde (≈120 m + öğe yarıçapı) gerçek model ↔ hafif figür
  değişimi var; karede gözle seçilmedi ama KANITSIZ (geçiş videosu alınmadı).
- `yer_otag_onu` ve `yer_sahi`: 30 m içinde 4 ve 7 kişi (hedef 15–25 ve ön hatta ≥ 40): KISMEN.

## 3. §7e işleri (madde madde)

1. **Izgara yerine obalar — TAMAM** (`sonra/ordu_70.jpg`, `sonra/ordu_30.jpg`). `ordugah_oba.gd` (yeni): alan kenarlarında 11 m'lik
   ortak yol, ortada sura koşut ve dik ara yol (çamur şeridi), dart atışıyla oba merkezleri (aralık 19–23 m), obada ortada bey/oda
   çadırı (6–8 m), önünde ocak/kazan ve oturanlar, çevresinde 13–24 çadır; aralara tekil/ikili dağınık çadır ve barınak. Çap
   dağılımı §2.5 (3,0–3,6 %35; 4,2–5,0 %45; 5,5–7,0 %20; bey 6–8,2), üç biçim (konik, çatma, başıbozukta barınak), boy ±.
   Eski ızgara `build_kanat_izgara` adıyla duruyor, çağrılmıyor.
2. **Kırmızı bant kalktı — TAMAM** (`sonra/otag_yakin.jpg`, `sonra/yer_anadolu.jpg`). `ordugah_kit.gd:tent_mesh("yuvarlak")` kırmızı
   bant → koyu kıl şerit; palet §2.5 (krem/bej/kıl/gri-kahve, ağırlıklı seçim). Kırmızı yalnız otağ, divan, sayebân, paşa çadırları,
   sancakların bir kısmı.
3. **İnsan ve hayvan — KISMEN** (§4). Yakında gerçek model, ötede hafif figür; at kazıkları, deve çökeği, koyun sürüsü, köpek, öküz.
   Sayılar kısmen tutuyor; canlı canlandırma yok.
4. **Otağ kompleksi — TAMAM (görünüş) / KISMEN (ayrıntı)** (`sonra/otag_yakin.jpg`, `sonra/ordu_30.jpg`). `ordugah_otag.gd` (yeni):
   76 × 60 m kumaş zokak (ağartılmamış keten, lacivert bant, mazgallı üst, ön kapı 7 m), sayebân (şemseli), iki divan, hazine,
   kilar, kurba, turuncu mutfak (duman deliği, üç kazan, aşçılar), namazgâh (safta oturanlar), gözcü kulesi, kapı önünde 7 tuğ ve
   mehterhane (davullar), dışında 22 çeşitli boy yeniçeri orta çadırı ve önlerinde kazan + oturanlar. Konma noktaları korundu.
5. **Ön hat — KISMEN** (`sonra/yer_siper.jpg`, `sonra/yer_top_mevzii.jpg`, `sonra/kara_disi.jpg`). `ordugah_cephe.gd` (yeni): siper boyunca
   perde ardında okçu/mızraklı kümeleri (4,5–7,5 m'de bir), sedde arkasında kazan/taşıyan işçi, merdiven istifi, çalı-tomruk
   (hendek doldurma), gülle yığını, kalas, meşale direkleri, perde önünde saplanmış ok ve kırık kalkan; her topun başında
   tokmakçı + manivelacı + nöbetçi + saka, sedde arkasında okçular, Şahi'de +14 öküz (toplam 20) ve seyisler. Bataryaların %50'si
   Mesoteikhion'da (u 1000–1700: 17 top + Şahi / 36; §4.1 ≥ %45). Ahşap perdedeki ateş deliği ve sepet tabya mevcut koddan
   (`build_siper`, `build_batarya`); yeni bir perde biçimi YAPILMADI.
6. **Eksik yerleşkeler — TAMAM (kare: `sonra/yer_pazar.jpg`; ötekiler KANITSIZ: kendi karesi alınmadı)**. `ordugah_yerleske.gd` (yeni):
   Halil, İshak, Karaca Paşa çadırları (bordo çatma, tuğ 2–3, sayebân, kâtip), dökümhane (üç ocaklı sundurma, körük, örs, top
   kalıbı, kömür), iki barut çukuru (otağdan/çadırdan uzak, fıçı + ıslak deri), esir çadırı (kazıklı çit, oturan esirler), tercüman
   çadırı (yazan kâtipler), üç ağıl (koyun, manda/öküz, çoban, köpek); mescide namaz safı, pazara tüccar ve gezen asker, at bağına seyis.
7. **Kule ve lağım (tarih kapılı) — TAMAM (kod) / KANITSIZ (kare)**. `IstOrdugah.tarih` (varsayılan 428 = 28 Nisan). Kule 18 Mayıs'tan
   (518) önce YOK: yerinde kereste istifi + yarım iskelet + marangozlar (`build_kule_hazirlik`). Yerler: `kule_1585` → u 1935
   (Pempton), `kule_1300` → u 900 (Pege/Üçüncü Askerî Kapı), `kule_2300` kereste yeri. Lağım ağızları (`lagim_*`) 516'dan sonra,
   Edirnekapı–Tekfur arası, siperin arkasında.
8. **Fıçı köprüsü üst Haliç'e, Galata yamacı bataryası — TAMAM (kod) / KANITSIZ (kare)**. `_fici_yeri` Ayvansaray/Cynegion ↔ karşı kıyı;
   `batarya_galata` Aziz Theodoros tepesinde (41.0301, 28.9812), namlu zincir gemilerine.
9. **Sancak/tuğ — TAMAM** (`sonra/yer_anadolu.jpg`, `sonra/otag_yakin.jpg`). Hilalsiz çatallı flama, oran kırmızı %45, yeşil %25,
   beyaz %15, sarı %10, lacivert %5; ortasında okunmaz hat çizgisi; tuğlar (siyah/beyaz/kırmızı at kuyruğu, küre alem).
   `ISTHILAL`: `grep -i "hilal\|crescent" scripts/world/ist/ordugah*.gd` → yalnız "hilal YOK" yorumları, çizen satır 0.
10. **Ses — YAPILMADI.** Var olan ortam sesleriyle bağlamaya vakit kalmadı; yeni ses üretilmedi.

Ek: mancınık 4 → 2 (arka hat, d 235). Ateşler TOPLU (`K.ateslar`: host başına 1 alev + yakında 1 hale çoklu ağı; önce ateş başına 3
çizim: Bölüm 11'deki 8 956'nın asıl kaynağı). Kalan tek `Flame.add`: `ordugah_donanma.gd` (1 adet) ve eski otağ kurucusu (çağrılmıyor).

## 4. Kişi ve hayvan sayıları

| kare | 30 m içinde karede kişi | karede kişi (≤ 400 m) | hayvan (yakın / karede) |
|---|---|---|---|
| ordu_70 (70 m) | 31 | 1 363 | 0 / 42 |
| ordu_30 | 2 | 1 148 | 0 / 36 |
| yer_anadolu | 23 | 965 | 1 / 11 |
| yer_pazar | 25 | 447 | 0 / 6 |
| yer_top_mevzii | 25 | 81 | 1 / 1 |
| yer_siper | 23 | 625 | 1 / 9 |
| yer_yeniceri_obasi | 11 | 1 229 | 0 / 36 |
| yer_rumeli | 10 | 1 407 | 2 / 36 |
| yer_sahi | 7 | 94 | 8 / 8 |
| yer_otag_onu | 4 | 938 | 0 / 36 |

Sayım: kurulmuş öğelerin kişi noktaları, kamera konisinde ve ekranda (`_karede`); örtülme hesaba katılmadı (ekranda olup tepe
ardında kalan da sayılır). Ölçütler: 70 m'den karede ≥ 150 figür TUTTU (1 363); çadır alanında 30 m'de 15–25: anadolu, pazar
TUTTU, yeniçeri/rumeli/otağ önü TUTMADI; ön hatta 30 m'den ≥ 40: TUTMADI (23–25).
`ISTORDUKISI` (çadırın içinde / havada, fizik ışını): ilk koşu `icinde=45 havada=43 toplam=622` (havada sayılanların çoğu batarya
terasındaki ekip: ölçüt araziye göreydi, ışınla düzeltildi; ekip ve istif yerleri sedde/yığın gövdesinden çıkarıldı). Düzeltilmiş
sondanın sonucu: §9'a bakın (koşu sürüyor). Şimdilik KANITSIZ.

Kişi türleri (`ordugah_kisi.gd` TIP): nöbetçi, okçu, azap, sipahi, ocak başında oturan, aşçı (kepçe), kazan işçi (kürek), saka (kova),
tokmakçı, manivelacı, odun kesen (balta), silah bileyen/demirci (çekiç), uyuklayan, namaz safı, seyis, yürüyen bölük, kâtip,
esir (sivil), tüccar (sivil), alıcı. Başlık: yeniçeri beyaz börk, öbürleri kırmızı keçe (azap börkü) ya da sarık; fes YOK.

## 5. §7c "KESİNLİKLE OLMASIN" listesi

- [x] Hilal/yıldız bayrak, alem, çadır tepesi yok (alemler küre).
- [x] Modern fes yok (börk, azap börkü, sarık).
- [x] Kırmızı çadır ordusu yok (kırmızı: otağ, divan, sayebân, 3 paşa; bant kalktı).
- [x] Tüfekli yeniçeri hattı yok (silah: mızrak, yay, kılıç-kalkan, iş aleti).
- [x] Kuka/kaşıklı külah: kullanılmadı ("bork" Person modelinin beyaz keçe börkü; yatırtmalı — ayrıntı belirsiz).
- [x] Tekerlekli sahra topu / zigzag siper / tabya yıldızı yok (toplar tomruk yatakta; mevcut kod).
- [x] Modern çadır yok; **parlak beyaz bez**: zokak `ddd2b4`, en açık çadır `efe6cc` (§2.5 paletindeki "soluk beyaz").
- [x] Çok renkli karnaval / ızgara / eş boy / aynı ton yok (karede).
- [x] Minare/ezan şehirde: benim dosyalarımda yok.
- [x] 18. yy mehter bandosu yok (yalnız davullar ve oturan dört kişi).
- [x] Tuğra bayrak yok.
- [x] Pazarda çay/kahve/tütün/domates yok (çuval, küp, kumaş).
- [x] Çocuk/kadın kalabalığı yok.
- [x] Orhan bayrağı yok.

## 6. Bütçe

| nokta | ÖNCE v2 çizim / üçgen | SONRA v2 çizim / üçgen | SONRA ordugâh payı |
|---|---|---|---|
| ordu_30 | 1 069 / 3,70 M | 1 282 / 3,32 M | §9 |
| ordu_70 | 1 163 / 4,10 M | 1 396 / 3,46 M | §9 |
| otag_yakin | 256 / 2,39 M | 503 / 1,44 M | §9 |
| kara_disi | 856 / 2,74 M | 1 003 / 2,88 M | §9 |
| hendek | 1 305 / 2,85 M | 1 369 / 3,13 M | §9 |
| yer (8 nokta) | — | 362–1 169 / 1,04–4,42 M | §9 |

Hüküm: **KISMEN / hedef tutmadı.** Gece: ateşler artık host başına 1–2 çizim (önce ateş başına 3); gece ölçümü BAKILMADI (§9).
Yapılan: orta katmanda gereçler tek ağ (önce 6 ağ), hafif figür 2 çoklu ağ, çadır gölgesi yalnız yakında, kişiler tür başına tek
çoklu ağ. Sıradaki (yapılmadı): lod 1 eşiğini 450 → 350 m, yakın katmanda gereç ağlarını birleştirmek, uzak hücreyi yarıya bölmek.
Kurulum: ordugâh uzak hücreleri 3,6–4,5 sn (ÖNCE 3,6 sn); tek öğe kurulum süresi (`ISTORDUKURMS`) §9.

## 7. ARAYÜZ DEĞİŞİKLİĞİ

- **Korunan:** `IstOrdugah.plan()` öğe yapısı ve öteki kimlikler (otag, sahi_top, batarya_01–13, mescit*, pazar*, mutfak_*, ahir_*,
  siper_*, kanat hücreleri anadolu_/yeniceri_/rumeli_/basibozuk_/zaganos_, diplokionion, kizak_*, fici_kopru), `wpt/wn/at/yaw_sura/band`,
  `attach`, `catalog`, `build_x/perches_x/climbs_x` imzaları, `perches_otag` noktaları (alem, gözcü kulesi, kapı sancağı).
- **Kalkan kimlik:** `mancinik_1460`, `mancinik_1700`. **Yeri değişen:** `mancinik_1180/1930` (d 150 → 235), `kule_1300` (u 900),
  `kule_1585` (u 1935), `kule_2300` (d 230; hazırlık), `fici_kopru` (üst Haliç). Kule öğelerinin `args.hazirlik` alanı yeni.
- **Yeni kimlikler:** `halil_pasa`, `ishak_pasa`, `karaca_pasa`, `dokumhane`, `barutcu`, `barutcu_rumeli`, `esir_cadiri`, `tercuman`,
  `agil_anadolu`, `agil_rumeli`, `agil_otag`, `batarya_galata`; tarih ≥ 516 ise `lagim_2120/2230/2330`. Yeni türler: pasa, dokumhane,
  barutcu, esir, tercuman, agil, lagim.
- **Yeni durağan:** `IstOrdugah.tarih` (428). Plan önbelleklidir; değiştiren `_plan = []` yapmalı (BAĞLAMA `_onbellek_sifirla` zaten yapıyor).
- **Yeni sınıflar** (düzen `IstOrdugah<Ad>`): `IstOrdugahOba`, `IstOrdugahKisi`, `IstOrdugahOtag`, `IstOrdugahCephe`, `IstOrdugahYerleske`.
  Kodda bunlara sınıf adıyla değil `preload` ile erişiliyor (sınıf önbelleği yenilenmeden de çalışsın).
- `IstOrdugahYonetici.kur_ms` (tür_lod → en uzun kurulum ms) yeni, okunur.
- Bölüm 7 ve 11 (BAĞLAMA): 20/20 başsız PASS (§8), `ordugah_oge=27` süzülüyor (camp), otağ kimliği aynı yerde.

## 8. Testler (başsız, yasak satır taraması: SCRIPT ERROR, WARN_FX_STUCK, WARN_FLY_ITEM, VISAUDIT, WARN_VOID_TELEPORT, WALKTHRU, ARMAUDIT, HELDAUDIT, LOOKAUDIT backturn, JOURNEY_*)

- `parse_check`: PARSECHECK PASS scripts=332.
- Bölüm 7: "" tea lost form wall wallkeep byz byzniko byzcell fez → 10/10 AUTOTEST PASS, yasak=0 (camp: `ISTBAGLAMA temizle
  bolge=camp ordugah_oge=27`, byz: `bolge=byz_walls`).
- Bölüm 11: "" arrest escape persuade help helpwall lost fired hikmet niko → 10/10 AUTOTEST PASS, yasak=0.
- Not: koşu sırasında betikler değişiyordu (yoğunluk/birleşik ağ düzeltmeleri); Bölüm 11'in tamamı ve 7'nin son yedisi son koda
  yakın hâlle koştu, ilk üçü bir önceki işlemeyle. Son işlemeyle yeniden koşu: BAKILMADI.
- Komşu bölümler (6, 12b, 24): BAKILMADI.

## 9. Süren koşular / bakamadıklarım

- Gece kareleri (pafta 6. kamera, gece dört kare) ve gece bütçesi: BAKILMADI (sıradaki ekranlı koşu).
- Bütçe ayrımı (ordugâh payı, `ISTORDUBUTCE`) ve düzeltilmiş `ISTORDUKISI`: gündüz koşusunun sonunda; bu rapora girmediyse KANITSIZ.
- 30 m / 70 m'den sekiz kare (`hava` seti): koşulmadı. Yerden 12 kareden 8'i alındı (`pafta_yer.jpg`); at bağı, mutfak, mescit,
  Zağanos yakası karesi: süren koşuda.
- 14 sahip karesi (`gezi_sahip.txt`): YAPILMADI (süre).
- Öbür dört dal (`wip/ist2-sur4`, `-cevre4`, `-doku4`, `-baglama4`): uzakta henüz yoktu (`git fetch`: couldn't find remote ref),
  birleştirilecek bir şey yoktu.

## 10. ORTAK İSTEK / BİLGİ

- **SUR-4 (BİLGİ):** surlar.gd kesitine göre hendeğin dış kenarı kara suru çizgisinden ≈ 52 m; +60 m = ≈ 112 m. Benim siper hattım
  d = 112'de (sınırda), bütün ön hat öğelerim (kişi, istif, batarya) onun ARKASINDA (d ≥ 112); perdenin önünde yalnız saplanmış ok ve
  kırık kalkan (d 120–124). Ateş alanında benim çadırım yok.
- **DOKU-4 (İSTEK):** `hayat_veri.gd:_ordugah()` ordugâh yerlerine (`IstGeo.yerler` tur=ordugah) ikinci bir kırmızı otağ
  (`Color(0.78,0.2,0.16)`, 2,4× çadır) ve 60–70 çadır + asker koyuyor; artık ordugâhın kendi otağı ve kişileri var: o katman
  ordugâh sınırları içinde kapatılsın ya da yalnız uzak (> 450 m) ateş/duman bıraksın (çifte otağ/çadır riski; karede seçmedim: KANITSIZ).
- **DOKU-4 (BİLGİ):** ordugâhın uzak ateşleri IstHayat `ordu_ates`te; benim alevlerim yalnız lod 0–1'de (kameraya ≤ 450 m + öğe).
- **DÜNYA/ÇEVRE (İSTEK):** ordugâh kuşağının zemini (dunya.gd "ordugah" türü) düz parlak yeşil; çiğnenmiş toprak/solgun ot tonu
  gerekli. Ben yalnız obaların altına ve yollara leke koydum.
- **BAĞLAMA-4 (BİLGİ):** `IstOrdugah.tarih` ile bölümün tarihi verilebilir (örn. 18 Mayıs sonrası bölümde `IstOrdugah.tarih = 518`,
  `_plan = []`, sonra `attach`).

## 11. Kurallar

- Yalnız `scripts/world/ist/ordugah*.gd` ve `tests/_ist/ordugah4_kare.*` değişti (`git diff wip/ist2-taban4 --stat`). Kanca/denetim
  susturma yok. ÖNCE kareleri depo dışı kopyada (`git worktree`, ev dizini) alındı.
- Ses üretilmedi, PR açılmadı, `main`e dokunulmadı.

## SAHİBİNE GÖSTERİLECEK 8 KARE

1. `pafta_once_sonra.jpg` — beş kamerada ÖNCE (ızgara, tek tip çadır, insansız) | SONRA (obalar, yollar, kişiler).
2. `sonra/ordu_70.jpg` — 70 m'den ordugâh: obalar, çamur yollar, ocak başı kümeleri, ortada kumaş zokaklı otağ.
3. `sonra/ordu_30.jpg` — 30 m'den otağ kompleksi: zokak, divan, hazine, mutfak, kurba, yeniçeri halkası.
4. `sonra/otag_yakin.jpg` — otağ kapısı: tuğ grubu, kapı nöbetçileri, sayebân, mehterhane.
5. `sonra/yer_anadolu.jpg` — yerden Anadolu kanadı: kırmızı börklü azaplar, yürüyen kol, sancaklar, çeşitli çadırlar.
6. `sonra/yer_yeniceri_obasi.jpg` — yerden yeniçeri obası: beyaz börklü yeniçeriler, çatma ve konik çadırlar.
7. `sonra/yer_top_mevzii.jpg` — top mevzii: top başında ekip, okçular, gülle yığınları, fıçılar.
8. `sonra/kara_disi.jpg` — sur dışı: siper hattı boyunca asker sırası, bataryalar, arkada obalar.
