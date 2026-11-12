# Haliç güney kıyısı — rapor (dal `wip/ist-halic`)

## 1. Araştırma özeti (kaynaklı)
- **Kapı sırası ve mahalleler** (A. van Millingen, *Byzantine Constantinople: the walls of the city*, "Walls along the Golden Horn",
  biblioteca.scriptorium.ro): batıdan doğuya Xylo Porta → Porta Platea/Mese → Drungarii kapısı (Venedik mahallesinin batı ucu, Vigla
  yanı) → Prodromos (Yuhanna) kapısı → **Perama / Porta Hebraica** (Venedik doğu ucu, karşıya geçiş iskelesi) → Porta San Marci
  (Perama'nın ~23 m doğusu, 1229 belgesi) → Hicanatissa kapısı (Pisa mahallesinin batı sınırı) → **Neorion / Horaia Pyle** → Porta Bonu
  (Ceneviz iskelesi) → **Eugenios kapısı** (Haliç surlarının doğu ucu). Mahalle sırası: Venedik (Drungarii–Perama), Amalfi (Perama–
  Hicanatissa), Pisa (Hicanatissa'dan doğuya, Neorion'u aşar), Ceneviz (Neorion'un doğusu, 12. yy). Kodda bu sıra korunur.
- **Zincir**: Eugenios (Kentenarion) kulesi güney ucu tutar, Galata kuleciği/Kastellion kuzey ucu; zincir kütükler (yüzdürücüler) üstünde
  (Ancient-Origins "Great Chain of the Golden Horn"; Sanidopoulos "Roman Chain of Golden Horn"; Genç 2023 pdf). 1204'te yalnız bir kez
  kırılmış; halkalar ~60 cm. Anlatılarda kule adı/bağlama yeri kaynaklar arasında çelişir: **BELİRSİZ**.
- **Limanlar**: Neorion ve Prosphorion Orta Çağ boyunca kumlandı (Wikipedia "Neorion Harbour"). 1453'te kısmen kumlu: kestirim.
- **Yahudi/Vigla**: debbağlar Vigla/Vlanga'da (Theodosios limanı yanı); 1453 ayrıntısı yok → **BELİRSİZ**, debbağ avlusu kestirimdir.
- **Ceneviz'in eski yeri**: 1453'te Ceneviz Galata'dadır; İstanbul yakası eski mahalle terk/harap: kestirim (harap ambar).
- Bulunamayan: Petrion ve Fener (Phanarion) kapılarının ayrıntısı; konumları kestirim. Sur yüksekliği/kalınlığı ve kule biçimi kaynakta
  yok: **KESTİRİM** (tuğla bantlı kesme taş, kareli kule, mazgallı parapet, benzer bölgelerle uyumlu `sea_walls.gd`).
- Anakronizm: minare/cami/cam/asfalt yok; çan kuleleri Latin kiliselerinde var (Venedik San Marco, Pisa San Pietro).

## 2. Oyuncu hareket sınırları (hesap)
`player.gd`: `JUMP = 3.6`, `gravity = 9.8` → zıplama yüksekliği = 3.6² / (2·9.8) = **0,66 m**; `STEP_H = 0,42 m` (zıplamadan çıkılan
basamak); `traversal.gd`: `REACH = 2,3`, `VAULT_MAX = 1,1`. Buna göre: merdiven basamağı **0,26 m**; sandık basamağı **0,5 m**
(zıplamayla); iskele/rıhtım kenarı 0,4 m; alçak sundurma çatıları yok, çatıya dış taş merdiven (yan/alın yüzde) çıkar.
Tırmanılmaz sayılan düz sur yüzü (9 m) hiçbir basamaksız bırakıldı; çıkışlar tek bir merdivenle.

## 3. Öğe listesi
| id | ne | durum |
|---|---|---|
| halic_sur | Haliç deniz suru: 96 m hat (kk), 4 kule, ana kemerli kapı (Perama tipi) + yan kapı, rıhtım, suya iniş basamakları, parapet, sur üstü yürüme yolu, 3 merdiven | TAMAM (derinleşebilir) |
| halic_eugenios | Eugenios kulesi, sur kolları, zincir (kütükler + halkalar), manivela kulübesi, rıhtım | TAMAM |
| halic_venedik | bailo evi, San Marco (kubbe, kasnak, çan kulesi), loca, ambarlar, evler, meydan | TAMAM (kaba+) |
| halic_pisa_amalfi | siyah-beyaz bantlı Pisa kilisesi + çan kulesi, Amalfi kubbeli şapel, evler, ambar | TAMAM (kaba+) |
| halic_ceneviz | terk edilmiş iki ambar (kırık duvar, moloz, ot, çökmüş kiriş) | KABA |
| halic_yahudi | debbağ küvetleri, kurutma çerçeveleri, havra, evler, iskele | KABA+ |
| halic_neorion | kumlanmış liman: kum yarısı, sığ su yarısı, tersane ayakları, tekneler, tomruk yığını | KABA+ |
| halic_iskele | 5 skala, 2 ahşap çıkrıklı vinç, demirli nao, fıçı/balya yığınları, babalar | TAMAM |
| halic_balik | balık pazarı: 6 tentelik tezgâh, taş tezgâh, kurutma ağları | KABA+ |
| halic_petrion | Petrion kapısı: iki kule, kemer, ikon nişi, sur kolları | TAMAM |
| halic_fener | Fener kapısı: aynı yapı, tepede ışık ocağı | TAMAM |
| Yapılmadı | Prosphorion limanı ayrı yapı olarak; Amalfi/Pisa ambar ayrıntısı; gemi tersanesi içi | YAPILMADI |

## 4. Denetim (k = 0,5; ayrıca k = 0,35 ve 1,0'da koşuldu, bkz. denetim.txt)
ISTAUDIT satırları `docs/_kanit_ist_halic/denetim.txt` dosyasında. Özet: delik 0; çatı/üst yüzey yolu her öğede çalışıyor (gerçek
CharacterBody3D, STEP_H ve zıplama benzetimiyle); dar aralık yalnız birkaç hücre (kuleler arası basamak yanları); "havada" uyarıları
kapı lentoları (iki ayağa oturur), tek yüzü destekli iskele tahtaları (suyun üstünde), sur kulesi lentosu — yanlış pozitif.
Üçgen sayısı lod 0/1/2 denetim.txt içinde (örn. sur 5750/362/60, Venedik 12100/1748/12). lod 1 oranı balık pazarında ~%39, Ceneviz ~%25 (hedef %15 üstü).

## 5. Ayırt edici ayrıntılar (en az beş)
- **Sur**: tuğla bantlı kesme taş, mazgal sırası (MultiMesh), kemerli kapı + lento kitabesi + haç, açık kapı kanatları, fenerler, bayrak.
- **Eugenios**: 4 köşe kulecik + kiremit başlık, konsol sırası, zincir halkası + zincir halkaları, kütükler üstünde zincir, manivela.
- **Venedik**: San Marco kubbesi (kasnak pencereleri, kurşun dilimler, haç), çan kulesi, aslanlı sütun, bailo balkonu + bayrak, loca.
- **Pisa**: siyah-beyaz bantlı mermer cephe, kör kemer galerisi, çan kulesi. **Amalfi**: sarı-yeşil dilimli küçük kubbe.
- **İskele**: iki çıkrıklı vinç, demirli nao (direk, seren, yelken, halat), skala sırası, fıçı/balya.

## 6. Bilinen kusurlar
- Mahalle öğeleri k ile kütleyi yalnız yatay açıklıkta ölçekler; yapı yükseklikleri sabit (insan ölçeği önceliği).
- Sur tepesi gerçekçi değil: parapet içi merdiven biçimleri tek sıra kutuyla (kapalı basamak blokları; lod 1'de rampa).
- Su düz yarı saydam düzlem; kıyı çizgisi doğrusal (şehir kurucusu bükebilir).
- `halic_iskele` ve `halic_neorion` suya inen basamaklar kısa; derin suya düşen çıkabilir (deniz tabanı 1,6 m, basamak var).
- Gerçek GPU/ışık denetimi yok; kareler yazılımsal (llvmpipe) GL ile alındı.

## 7. Bakamadıklarım
Bütün öğelerin gece/meşale görünümü; şehir kurucusu içindeki yerleşim; gerçek oyuncu betiğiyle (`traversal.gd`) tırmanma.

## 8. Paftalar
`docs/_kanit_ist_halic/pafta_*.jpg`
