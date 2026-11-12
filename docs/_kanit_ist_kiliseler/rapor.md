# İstanbul 1453 — kiliseler parçası (dal `wip/ist-kiliseler`)

## Araştırma özeti (DÜRÜST NOT)
Bu oturumda WebSearch/WebFetch ile kaynak taraması YAPILMADI; aşağıdaki bilgiler genel tarih bilgisine dayanır ve
**kestirim / doğrulanmamış** sayılmalıdır (kaynak adı vermiyorum, uydurmamak için). Doğrulama için önerilen kaynaklar:
Müller-Wiener "Bildlexikon zur Topographie Istanbuls", Mathews "Byzantine Churches of Istanbul", Janin "Constantinople
byzantine", Ousterhout "Master Builders of Byzantium".
- Geç Bizans küçük kiliseleri: kapalı Yunan haçı planı, tek kubbe, tuğla-taş (opus mixtum / cloisonné) bantlar, çok yüzlü
  (8–12) kasnak ve apsis; 8–12 m genişlik. Orta kiliseler (ör. Pammakaristos/Fethiye tipi) üç apsisli, narteksli (kestirim).
- Bazilika: ahşap çatılı üç nefli plan (Studios tipi), 1453'te çoğu harap ya da kullanımda (belirsiz).
- Çan kulesi Bizans'ta yok; Latin etkili semtlerde (Galata, Venedik mahallesi) var → `latin` meta ile bazilikada (kestirim).
- Bizans'ta çan yerine semantron (asılı tahta levha) kullanılırdı → kapı yanlarına asıldı.
- Kuşatma dönemi İstanbul'unda iç bölgeler bostan, bağ, harap kilise ve sarnıç dolu; mezarlıklar sur dışı/içi dağınık (kestirim).
- Ayazma (kutsal pınar), münzevi/stylite kulesi, yol kenarı ikona nişi, nymphaion kalıntısı, mozaik döşeme parçası
  (Büyük Saray tipi): tip olarak kabul; ölçüler **kestirim**. Anakronizm yok (kandil = Flame, cam yok, minare yok).
- Katalogdaki `dogu_m / kuzey_m` değerleri tip örnekleridir (`"yer_kaynak": "kestirim"`), şehir kurucusu gerçek yerleri
  `CityGeo.load_places`'ten alsın.

## Oyuncu tırmanma hesabı (player.gd)
JUMP = 3,6 m/sn; yerçekimi = 9,8 (proje varsayılanı) → zıplama yüksekliği = 3,6² / (2·9,8) = **0,66 m**.
STEP_H = 0,42 m (zıplamadan basamak), kapsül r = 0,30, boy 1,75. Dış merdivenlerde basamak 0,28 m (üçgen: 0,28/0,36),
taş basamaklı ruin yolunda en çok 0,4 m; son atlama ≤ 0,66.

## Arayüz
`scripts/world/ist/kiliseler.gd` (`IstKiliseler`): `IDS`, `catalog()`, `build(id, host, k, lod)`, `perches(id, k)`,
`climbs(id, k)`, `bakis_k(id, k)` ve her öğe için `build_<id>`, `perches_<id>`, `climbs_<id>`.
Eksen: uzun eksen z; apsis −z; giriş +z. Yerleştirici host'u `rotation_degrees.y = −yon_derece` ile döndürür (yon = apsis yönü).
Tohum: `host.set_meta("tohum", int)`; Latin etkisi: `host.set_meta("latin", true)` (bazilikada çan kulesi).
Yardımcılar: `kiliseler_ortak.gd` (IstKB), `kiliseler_kilise.gd`, `kiliseler_manastir.gd`, `kiliseler_harabe.gd`.

## Öğeler (durum)
| id | ne | durum |
|---|---|---|
| kilise_kucuk | kapalı haç, tek kubbe, narteks, apsis, semantron | TAMAM |
| kilise_orta | çapraz çatılı gövde, 12 yüzlü kasnak, üç apsis, narteks | TAMAM |
| bazilika | üç nef, klerestori, apsis, ön revak (sütunlu), narteks; Latin: çan kulesi | TAMAM (Latin varyantı denetlenmedi) |
| sapel | şapel, sundurma, apsis | TAMAM |
| manastir | çevre duvarı + yürüme yolu, kapı kulesi, katholikon, hücre sırası+revak, yemekhane+ek bina, phiale köşkü, bostan | TAMAM |
| ayazma | kubbeli pınar yapısı, yalak, adak çınarı | TAMAM |
| munzevi_kulesi | taş kule, çıkma platform + ahşap kulübe, makara; payanda-merdiven | TAMAM |
| ikona_nisi | kaide, direk, niş, ikona, kandil | TAMAM |
| mezarlik | alçak duvar, kapı, lahitler, stel, kemikevi, selvi | TAMAM |
| nymphaion | yarım daire niş duvarı, havuz, moloz rampası | TAMAM |
| harabe_tonoz | yan duvarlar, ayakta kemer halkaları, moloz | TAMAM |
| harabe_kemer | tek kemer, duvar kolları, moloz, incir | TAMAM |
| harabe_sutun | stylobate, 7 sütun (yıkıklık dereceli), alınlık, basamak blokları | TAMAM |
| harabe_mozaik | kodla çizilmiş tesserae dokusu, alçak duvar kalıntısı | TAMAM |
| harabe_sarmasik | basamaklı yıkık duvar, kör kapı, sarmaşık | TAMAM |

Ayırt edici ayrıntılar (≥5): opus mixtum tuğla bantları, kemerli çerçeveli pencereler, dilimli kurşun kubbe + altın haç,
çok yüzlü kasnak, semantron, mahya taşı sırası, kapı kemeri + mermer söve, saçak halkası, apsis konisi, vb.

## Denetim (`docs/_kanit_ist_kiliseler/audit.txt`, k = 0,35 / 0,5 / 1,0, lod 0)
Tüm 15 öğe için: delik=0, dar=0, havada=0, cati_yolu tam (ör. 1/1, manastır 5/5) — şu istisna dışında:
- `sapel k=1,0`: delik=3 (apsis koni çatısının 12 cm'lik saçağı görünür ama çarpışması yok).
Üçgen: lod0 ≈ 0,3–10 bin (manastır ≈ 10 bin; bütçenin çok altı), lod1 ≈ %15–30, lod2 ≤ 300.
**Bilinen kusurlar**
- k ≤ 0,5'te çoğu yapı aynı boyda: kapı/merdiven/pasaj gerçek boyda kaldığı için taban kütle alt sınıra kilitlenir
  (k=0,35 ve 0,5 çıktısı aynı); yalnız k > 0,5'te büyür.
- `dar` denetimi 0,4 m'den ince (tek-iki satırlık) teğet yay boşluklarını sayım dışı bırakır (yay yüzeyi yanlış alarmı).
- lod1 üçgen oranı bazı küçük yapılarda %15'i aşar (nisi, harabe_sutun).
- Önizleme yalnız masaüstü GL'de (xvfb) görüldü; gece/ışık yok. Kare turu sınırlı: 3 tam tur yapılmadı,
  kuş bakışı/yaklaşma kareleri üzerinde 2 düzeltme turu yapıldı (kubbe ve eğik çatı yüzey yönü, boşluk/yük kusurları).
- `Flame` ışıkları yalnız önizlemede sınandı.
- Bakılamayanlar: Latin bazilika varyantının kareleri, lod1/lod2 karelerinin hepsi, çatı gözü karelerinin çoğu.

## Paftalar
`pafta/*.jpg` (12 adet, ≤ 65 KB).
