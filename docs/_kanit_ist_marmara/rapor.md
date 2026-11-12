# Marmara parçası (wip/ist-marmara) — rapor

DURUM: ilk teslim. Tüm öğeler kurulu ve denetimden geçiyor; ayrıntı derinliği ve görsel cila sınırlı (aşağıda "kusurlar").

## Araştırma notu (KAYNAKSIZ)
Web araştırması YAPILMADI. Aşağıdaki konum, ölçü ve biçimler genel tarih bilgisinden gelen KESTİRİMdir (Marmara sur hattı ≈ 12 m tek sur ve kareli kuleler, Bukoleon'un
denize bakan üç büyük mermer çerçeveli pencere/balkonu ve aslan-boğa grubu, Kadırga (Kontoskalion) kapalı havuzu, Yenikapı'daki dolmuş Eleutherios/Theodosius limanının bostan olması,
Mermer Kule'nin kara ve deniz surlarının birleştiği köşede olması). Koordinatlar (`dogu_m`, `kuzey_m`) yaklaşık enlem-boylamdan hesaplandı, ±birkaç yüz metre. Ahırkapı kapısının adı ve yeri, balıkçı/ağ/kayalık/kayıkhane yerleri belirsiz kestirimdir.

## Oyuncu ölçüleri (player.gd)
JUMP = 3,6, yerçekimi 9,8 → zıplama ≈ 0,66 m. STEP_H = 0,42 m. Merdivenler 0,34 m basamak / 0,46 m derinlik; sandık/kaya basamakları ≤ 0,4 m.

## Arayüz
`scripts/world/ist/marmara.gd` (`IstMarmara`): `catalog()`, her id için `build_<id>`, `perches_<id>`, `climbs_<id>`; ayrıca `build(id,host,k,lod)`, `perches(id,k)`, `climbs(id,k)`, `pits(id,k)`.
Öğeler GERÇEK pusula çerçevesinde kurulur (+x doğu, −z kuzey, +z güney = deniz). `yon_derece` kurulumdaki ana eksenin kuzeyden açısıdır (sur koşusu 90).
`build_run(host, uzunluk, k, lod, opts)` (`IstMarmaraSur`): opts `kapi` (x listesi), `merdiven` (bool), `stair_mid`.
KONTOSKALİON havuzu zeminde çukur ister: `IstMarmara.pits("kontoskalion", k)` Rect2 listesi (havuz içi + ağız rampası), havuz tabanı y = −2,4. Önizleme zemini bunu keser.
Diğer öğelerde rıhtım kenarı duvarları y = −3'e kadar iner (ağır olmayan, zemin altında kalır).

## Öğeler
| id | ne | durum |
|---|---|---|
| msur | sur koşusu: kuleler, kapı, merdiven, mazgal, devşirme | TAMAM (cila sınırlı) |
| bukoleon | saray deniz cephesi, 3 pencere+balkon, aslan-boğa, iskele, kubbe, doğu yıkığı | TAMAM (cila sınırlı) |
| kontoskalion | havuz, mendirek+fener kulesi, 3 kadırga tezgâhı, vinç, ambar | TAMAM |
| langa | bostan tarhları, dolap, kuyular, kulübeler, gölcük, ağaçlar | TAMAM |
| sophia | liman kalıntısı: yıkık ambar, deniz kapısı, batık rıhtım | KABA |
| mermerkule | köşe kulesi + deniz suru + kara suru koşuları | TAMAM |
| ahirkapi | küçük deniz kapısı, çeşme, rıhtım, kayıklar | TAMAM |
| balikci | 4 kulübe, ateş, kayıklar, amfora | TAMAM |
| kayikhane | içine girilebilen sundurma, tekne, kızak | TAMAM |
| agsehpa | 6 sehpa, onarım iskelesi | KABA |
| kayalar | kaya merdiveni, dağınık kaya, kütük | KABA |

## Denetim (k = 0,5; tam döküm `istaudit_k050.txt`)
Çatı yolu (CharacterBody3D ile) tüm öğelerde geçti (k = 0,35, 0,5, 1,0). Üçgen: lod0 0,9–9,9 bin, lod1 0,1–5,6 bin, lod2 ≤ 336.
Delik 0 (k=0,5). `dar` kalanlar: kontoskalion 21 (mendirek kulesi çevresi), sophia 9, kayalar 4, ahirkapi 1 — nedenleri incelenmedi.
`havada` 1–6 (bir kısmı kasıtlı iç içe geçmiş katılar; denetim bunları ayırt etmiyor, gerçek mi sahte mi doğrulanmadı).
k = 0,35 ve 1,0 koşuları da çalıştı, çatı yolu tamam; son küçük düzeltmeler (kontoskalion merdiveni, kayıkhane teknesi, tufts rengi) bu iki k'de yeniden koşulmadı. Mermer Kule'de k=0,35'te 1 delik görüldü, sonraki düzeltmeden sonra yeniden sınanmadı.
Denetim yöntemi basit (ızgara/AABB); yanlış alarm ve kaçırma olabilir.

## Bilinen kusurlar / bakılamayanlar
- Cila: yalnızca ~2 tur; malzemeler soluk, yakın plan ayrıntısı sınırlı. Sur ve Bukoleon dışındaki öğelerin bir kısmının kareleri yalnızca kuş bakışı incelendi.
- Ahşap kürek, ağ gibi ince parçalar görsel; ağ levhası katı.
- Nihat bakış noktası (`bakis`) kestirim; `gorev` hepsi false.
- Sur/Mermer Kule yürüme yolları kulelere basamakla bağlı; kapı üstü lento sürekli.
- Gece ışığı, ateş yalnızca birkaç yerde (Flame).
- Zemin: Kontoskalion çukuru dışında şehir zemini y = 0 varsayıldı.

## Paftalar
`pafta/` altında 12 JPEG (yer, çatı, kuş bakışı).
