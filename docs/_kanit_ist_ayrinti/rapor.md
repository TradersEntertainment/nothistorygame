# İstanbul 1453, ayrıntı kitaplığı — rapor

Dal: `wip/ist-ayrinti`. Dosyalar: `scripts/world/ist/ayrinti*.gd` (kayıt/kurucu `ayrinti.gd`, öğeler `ayrinti_a..d.gd`, köşeler `ayrinti_set.gd`,
arayüz yönlendirmeleri `ayrinti_api.gd`), önizleme `tests/_ist/ayrinti_onizleme.*`. Var olan hiçbir dosya değiştirilmedi.

## Araştırma özeti (kaynaklı, kısa)
- 1453'te şehir nüfusu yaklaşık 40–50 bin; kara surlarının içi "surlarla çevrili köyler ve geniş bostan/tarlalar" biçimindeydi
  ([medievalists.net](https://www.medievalists.net/2026/01/daily-life-in-constantinople/), [istanbulclues](https://istanbulclues.com/byzantine-constantinople/)) → bostan, ağaç, kümes, kuyu, saman öğeleri.
- Pazarlarda Boğaz balığı, bahçe sebzesi, zeytinyağı ve şarap satılırdı → tezgâh, amfora, pithos, balık kasası/kurutma, şarap fıçısı.
- Kuşatmada savunmacılar gündüz yıkılan sur kesimlerini geceleri onardı; Giustiniani gedik ardına ikinci duvar yaptı
  ([worldhistory.org](https://www.worldhistory.org/article/1180/the-fall-of-constantinople-in-1453/), [thecollector](https://www.thecollector.com/fall-constantinople-1453-changed-world/)) → sur onarım şantiyesi, fıçı-toprak tahkimat, gabyon, barikat.
- Urban'ın dökme bombardı ve taş güllelerle kuşatma topçusu (ağır taş gülleler) → `top`, `gulle_yigini`, mancınık/balista.
- BELİRSİZ / kestirim: Osmanlı otağının renk/şerit düzeni, mülteci çadırının biçimi, tabela yazıları (Yunanca "ΑΡΤΟΣ" = ekmek) kestirimdir. Cam, minare, asfalt, çanak anten vb. kullanılmadı.

## Ölçek ve tırmanma değerleri (player.gd / traversal.gd'den)
- Zıplama: JUMP = 3.6, yerçekimi 9.8 → 3.6² / (2×9.8) ≈ **0,66 m**. Alçak basamak (STEP_H) **0,42 m**. Tutunma erişimi (REACH) **2,3 m**, atlama-aşma (VAULT_MAX) **1,1 m**.
- Öğeler her zaman gerçek boyda; `k` yalnız köşe gruplarında öğeler arası aralığı 1,0–1,3 kat açar (`build_set_*`).
- Standart basamaklar: sandık yığını 0,5 + 1,0 m; yıkık duvar 0,45/0,9/1,35/1,8 m; sokak basamakları 0,3 m aralıklı; iskele girişi 0,5/1,0 m blok sonra 1,6 m platform.

## Kapsam
- **155 öğe + 11 köşe grubu**, hepsi `catalog()` içinde `"tur": "ayrinti"` (konum alanları 0; ek alanlar `grup`, `carpisma`).
- Arayüz: `Ayrinti.build(id, host, k, lod)`, `Ayrinti.perches(id,k)`, `Ayrinti.climbs(id,k)`; kalıba uygun `AyrintiApi.build_<id>(host,k,lod)`, `perches_<id>`, `climbs_<id>`.
- lod 0 tam ayrıntı + çarpışma, lod 1 küçük parçalar atılmış (çarpışmasız), lod 2 tek siluet kutusu (12 üçgen).
- Çarpışma: "kutu" öğelerde sınır kutusu katı; "ozel" öğelerde direkler/duvarlar/çatı tek tek; "yok" düşük/yürünür (su birikintisi, hasır, hayvanlar, bostan).
- Işık: kamp ateşi, demirci ocağı, meşale `Flame` ile.

## Öğeler (TAMAM = lod0/1/2 + çarpışma kuruldu; görsel turlarda gözden geçirildi)
- `tezgah` — Çarşı tezgâhı (2.0×1.0×0.8 m, kutu, carsi): TAMAM
- `tente` — Bez tente (3.0×2.6×2.4 m, ozel, carsi): TAMAM
- `amfora` — Amfora (0.4×0.95×0.4 m, kutu, kap): TAMAM
- `pithos` — Pithos (büyük küp) (0.9×1.3×0.9 m, kutu, kap): TAMAM
- `fici` — Fıçı (0.6×0.85×0.6 m, kutu, kap): TAMAM
- `sepet` — Hasır sepet (0.55×0.45×0.55 m, kutu, kap): TAMAM
- `cuval` — Çuval (0.5×0.7×0.4 m, kutu, kap): TAMAM
- `terazi` — Kefeli terazi (0.6×1.0×0.3 m, yok, carsi): TAMAM
- `balik_agi` — Balık ağı (2.4×0.9×1.0 m, yok, liman): TAMAM
- `ag_sehpasi` — Ağ sehpası (2.2×1.6×0.6 m, ozel, liman): TAMAM
- `kayik` — Çekilmiş kayık (4.2×1.1×1.6 m, kutu, liman): TAMAM
- `kurek` — Kürek (0.15×2.0×0.15 m, yok, liman): TAMAM
- `capa` — Çapa (0.9×1.2×0.3 m, yok, liman): TAMAM
- `camasir_ipi` — Çamaşır ipi (3.4×2.2×0.2 m, ozel, ev): TAMAM
- `kumes` — Kümes (1.4×1.3×1.0 m, kutu, ciftlik): TAMAM
- `guvercinlik` — Güvercinlik (1.0×2.8×1.0 m, ozel, ciftlik): TAMAM
- `ari_kovani` — Arı kovanı (0.5×0.75×0.5 m, kutu, ciftlik): TAMAM
- `yalak` — Yalak (1.6×0.6×0.5 m, kutu, ciftlik): TAMAM
- `kuyu` — Kuyu ve çıkrık (1.4×2.0×1.0 m, ozel, su): TAMAM
- `su_dolabi` — Su dolabı (2.2×2.4×0.8 m, ozel, su): TAMAM
- `el_arabasi` — El arabası (1.5×0.8×0.6 m, kutu, tasima): TAMAM
- `kagni` — Kağnı (3.0×1.6×1.6 m, ozel, tasima): TAMAM
- `esek_semeri` — Eşek semeri yükü (1.1×0.9×0.6 m, kutu, tasima): TAMAM
- `odun_yigini` — Odun yığını (2.0×1.2×0.9 m, kutu, yigin): TAMAM
- `tas_yigini` — Taş yığını (1.6×0.9×1.4 m, kutu, yigin): TAMAM
- `kirec_ocagi` — Kireç ocağı (2.2×1.5×2.2 m, kutu, yapi): TAMAM
- `iskele` — Ahşap iskele (6.0×0.9×1.6 m, ozel, liman): TAMAM
- `merdiven` — Ahşap merdiven (0.5×3.0×0.9 m, ozel, yapi): TAMAM
- `sandik_yigini` — Sandık yığını (basamak) (1.4×1.0×1.9 m, ozel, yigin): TAMAM
- `firin` — Ekmek fırını (2.0×2.0×1.6 m, kutu, mutfak): TAMAM
- `tandir` — Tandır (1.0×0.9×1.0 m, kutu, mutfak): TAMAM
- `degirmen_tasi` — Değirmen taşı (1.2×0.5×1.2 m, kutu, mutfak): TAMAM
- `zeytin_presi` — Zeytin presi (1.8×1.8×1.0 m, ozel, mutfak): TAMAM
- `sarap_fici` — Şarap fıçısı (kızakta) (1.2×1.3×0.9 m, kutu, kap): TAMAM
- `uzum_teknesi` — Üzüm teknesi (1.8×0.7×1.4 m, kutu, kap): TAMAM
- `tezgah_kepengi` — Tezgâh kepengi (2.2×2.2×0.15 m, kutu, carsi): TAMAM
- `tabela` — Yunanca harfli tabela (1.2×2.4×0.3 m, ozel, carsi): TAMAM
- `ikona_nisi` — İkona nişi (0.8×1.9×0.5 m, kutu, kutsal): TAMAM
- `kandil` — Asma kandil (direkli) (0.7×2.4×0.4 m, ozel, kutsal): TAMAM
- `mum_sehpasi` — Mum sehpası (0.7×1.2×0.5 m, kutu, kutsal): TAMAM
- `hacli_tas` — Haçlı taş (0.6×1.5×0.3 m, kutu, kutsal): TAMAM
- `lahit` — Lahit (2.2×1.0×1.0 m, kutu, kutsal): TAMAM
- `sutun_baslik` — Devrik sütun başlığı (1.2×0.8×1.2 m, kutu, harabe): TAMAM
- `mermer_parca` — Mermer parçaları (1.8×0.4×1.4 m, yok, harabe): TAMAM
- `cit` — Çit (3.0×1.2×0.2 m, kutu, bahce): TAMAM
- `bahce_kapisi` — Bahçe kapısı (1.6×1.8×0.2 m, ozel, bahce): TAMAM
- `asma_cardagi` — Asma çardağı (3.0×2.6×3.0 m, ozel, bahce): TAMAM
- `saksi` — Saksı (0.4×0.7×0.4 m, kutu, bahce): TAMAM
- `cicekli_pencere` — Çiçekli pencere (1.2×1.9×0.5 m, kutu, ev): TAMAM
- `kedi` — Kedi (0.25×0.3×0.55 m, yok, hayvan): TAMAM
- `kopek` — Sokak köpeği (0.3×0.55×0.9 m, yok, hayvan): TAMAM
- `tavuk` — Tavuk (0.22×0.35×0.35 m, yok, hayvan): TAMAM
- `keci` — Keçi (0.4×0.8×1.0 m, yok, hayvan): TAMAM
- `esek` — Eşek (0.5×1.2×1.5 m, kutu, hayvan): TAMAM
- `at` — At (0.6×1.6×2.2 m, kutu, hayvan): TAMAM
- `okuz` — Öküz (0.8×1.4×2.0 m, kutu, hayvan): TAMAM
- `koyun` — Koyun (0.5×0.8×1.0 m, yok, hayvan): TAMAM
- `kaz` — Kaz (0.3×0.55×0.6 m, yok, hayvan): TAMAM
- `marti` — Martı (kondurulmuş) (0.25×0.4×0.5 m, yok, hayvan): TAMAM
- `cop` — Çöp ve atık (1.2×0.4×1.0 m, yok, yigin): TAMAM
- `su_birikintisi` — Su birikintisi (1.6×0.03×1.2 m, yok, yigin): TAMAM
- `mancinik` — Mancınık (3.0×3.6×7.0 m, ozel, savas): TAMAM
- `gulle_yigini` — Taş gülle yığını (1.2×0.8×1.2 m, kutu, savas): TAMAM
- `ok_sandigi` — Ok sandığı (1.0×0.6×0.45 m, kutu, savas): TAMAM
- `kalkan_askisi` — Kalkan askısı (1.6×1.8×0.3 m, ozel, savas): TAMAM
- `mizraklik` — Mızraklık (1.0×2.4×0.5 m, ozel, savas): TAMAM
- `nobetci_kulubesi` — Nöbetçi kulübesi (2.4×2.6×2.4 m, ozel, savas): TAMAM
- `barikat` — Barikat (3.4×1.7×1.0 m, kutu, savas): TAMAM
- `fici_toprak` — Fıçı-toprak tahkimat (3.0×1.5×1.2 m, kutu, savas): TAMAM
- `top` — Top (dövme demir) (1.4×1.2×3.4 m, kutu, savas): TAMAM
- `balista` — Balista (1.2×1.4×2.0 m, kutu, savas): TAMAM
- `kazan_yag` — Kaynar yağ kazanı (1.2×1.3×1.2 m, kutu, savas): TAMAM
- `okcu_siperi` — Hasır siper (mantlet) (1.4×1.8×0.4 m, kutu, savas): TAMAM
- `kusatma_merdiveni` — Dayalı kuşatma merdiveni (0.9×5.0×1.6 m, ozel, savas): TAMAM
- `sancak_diregi` — Sancak direği (0.6×4.0×0.2 m, ozel, savas): TAMAM
- `hendek_kazigi` — Hendek kazıkları (3.0×1.2×1.6 m, yok, savas): TAMAM
- `gabyon` — Toprak dolu sepet (gabyon) (0.6×0.9×0.6 m, kutu, savas): TAMAM
- `ordu_cadiri` — Osmanlı ordu çadırı (4.6×3.2×4.6 m, ozel, kamp): TAMAM
- `multeci_cadiri` — Mülteci çadırı (3.0×1.7×2.6 m, ozel, kamp): TAMAM
- `yer_yatagi` — Yer yatağı (0.8×0.2×1.9 m, yok, kamp): TAMAM
- `kamp_atesi` — Kamp ateşi (1.2×1.1×1.2 m, yok, kamp): TAMAM
- `kazan` — Kazan ve üç ayak (1.2×1.4×1.2 m, ozel, kamp): TAMAM
- `mangal` — Mangal (0.6×0.9×0.6 m, kutu, kamp): TAMAM
- `mesale_diregi` — Meşale direği (0.3×2.4×0.3 m, ozel, kamp): TAMAM
- `saman_balyasi` — Saman balyası (1.0×0.5×0.6 m, kutu, ciftlik): TAMAM
- `saman_yigini` — Saman yığını (2.6×2.2×2.6 m, kutu, ciftlik): TAMAM
- `ot_demeti` — Ot demeti (0.6×0.7×0.5 m, yok, ciftlik): TAMAM
- `yun_balyasi` — Yün balyası (0.9×0.8×0.6 m, kutu, zanaat): TAMAM
- `demir_ocagi` — Demirci ocağı ve körük (1.8×1.5×1.4 m, kutu, zanaat): TAMAM
- `ors` — Örs (0.5×0.85×0.5 m, kutu, zanaat): TAMAM
- `soguma_teknesi` — Demirci su teknesi (1.0×0.7×0.6 m, kutu, zanaat): TAMAM
- `dokuma_tezgahi` — Dokuma tezgâhı (1.6×1.9×1.2 m, ozel, zanaat): TAMAM
- `boya_kazani` — Boya kazanı (1.0×1.0×1.0 m, kutu, zanaat): TAMAM
- `boya_askisi` — Boyalı kumaş askısı (3.2×2.4×0.4 m, ozel, zanaat): TAMAM
- `kumas_topu` — Kumaş topları (1.0×0.6×0.6 m, kutu, carsi): TAMAM
- `deri_gerdirme` — Deri germe çerçevesi (1.4×1.8×0.2 m, ozel, zanaat): TAMAM
- `balik_kasasi` — Balık kasası (0.7×0.35×0.5 m, kutu, liman): TAMAM
- `balik_kurutma` — Balık kurutma askısı (2.2×1.9×0.6 m, ozel, liman): TAMAM
- `halat_rulo` — Halat rulosu (0.8×0.45×0.8 m, kutu, liman): TAMAM
- `palamar_babasi` — Palamar babası (0.3×0.6×0.3 m, kutu, liman): TAMAM
- `yelken_bezi` — Katlanmış yelken bezi (1.3×0.6×0.9 m, kutu, liman): TAMAM
- `masa` — Ahşap masa (1.6×0.8×0.8 m, kutu, ev): TAMAM
- `tabure` — Tabure (0.4×0.45×0.4 m, kutu, ev): TAMAM
- `bank` — Sokak bankı (1.6×0.9×0.5 m, kutu, ev): TAMAM
- `sandik` — Ahşap sandık (0.9×0.55×0.55 m, kutu, ev): TAMAM
- `kutuk` — Kütük (0.5×0.45×0.5 m, kutu, yigin): TAMAM
- `kutuk_kutugu` — Odun kütüğü ve balta (0.7×0.9×0.7 m, kutu, yigin): TAMAM
- `kazma_kurek` — Dayalı kazma ve kürek (0.8×1.7×0.4 m, ozel, yapi): TAMAM
- `tugla_yigini` — Tuğla yığını (1.4×0.9×1.0 m, kutu, yapi): TAMAM
- `kiremit_yigini` — Kiremit yığını (1.4×0.7×0.8 m, kutu, yapi): TAMAM
- `harc_teknesi` — Harç teknesi (1.2×0.5×0.8 m, kutu, yapi): TAMAM
- `yapi_iskelesi` — Sur onarım iskelesi (4.6×4.4×1.6 m, ozel, yapi): TAMAM
- `cikrik_vinc` — Çıkrıklı taş vinci (1.6×3.6×1.4 m, ozel, yapi): TAMAM
- `yikik_duvar` — Yıkık duvar (basamaklı) (3.2×1.8×0.7 m, ozel, harabe): TAMAM
- `saban` — Saban (1.8×0.9×0.5 m, yok, ciftlik): TAMAM
- `testi` — Testi ve çömlekler (1.0×0.5×0.6 m, yok, kap): TAMAM
- `kase_tezgahi` — Kâse tezgâhı (1.4×0.9×0.6 m, kutu, carsi): TAMAM
- `tas_havuz` — Taş havuz (2.4×0.8×2.4 m, kutu, su): TAMAM
- `cesme` — Duvar çeşmesi (1.6×2.2×0.8 m, kutu, su): TAMAM
- `sarnic_agzi` — Sarnıç ağzı (1.4×0.9×1.4 m, kutu, su): TAMAM
- `sutun_govdesi` — Sütun gövdesi (yatık) (2.8×0.8×0.8 m, kutu, harabe): TAMAM
- `mezar_tasi` — Mezar taşı (0.6×1.1×0.25 m, kutu, mezar): TAMAM
- `can_cercevesi` — Çan çerçevesi (1.8×2.8×0.8 m, ozel, kutsal): TAMAM
- `vaftiz_kurnasi` — Vaftiz kurnası (1.0×1.0×1.0 m, kutu, kutsal): TAMAM
- `ayin_bayragi` — Ayin sancağı (1.0×3.0×0.2 m, ozel, ayin): TAMAM
- `ikon_sehpasi` — İkona taşıma sedyesi (1.4×1.2×1.0 m, kutu, ayin): TAMAM
- `buhurdan` — Buhurdan sehpası (0.5×1.2×0.5 m, kutu, ayin): TAMAM
- `bostan_sirasi` — Bostan sırası (3.0×0.5×1.0 m, yok, bahce): TAMAM
- `korkuluk` — Bostan korkuluğu (1.2×2.0×0.4 m, ozel, bahce): TAMAM
- `meyve_agaci` — Meyve ağacı (2.8×3.4×2.8 m, ozel, bitki): TAMAM
- `zeytin_agaci` — Zeytin ağacı (3.0×4.0×3.0 m, ozel, bitki): TAMAM
- `selvi` — Selvi (1.2×6.0×1.2 m, ozel, bitki): TAMAM
- `cali` — Çalı (1.4×0.9×1.4 m, yok, bitki): TAMAM
- `cicek_tarhasi` — Çiçek tarhası (2.0×0.5×1.0 m, yok, bahce): TAMAM
- `tas_kemer` — Taş kemer geçidi (3.0×3.0×1.0 m, ozel, yapi): TAMAM
- `sokak_basamagi` — Sokak basamakları (1.6×1.2×2.4 m, ozel, yapi): TAMAM
- `direk_fener` — Direk kandil (0.4×3.0×0.4 m, ozel, yapi): TAMAM
- `sundurma` — Alçak sundurma (3.0×2.8×2.2 m, ozel, ev): TAMAM
- `agac_govde_kutugu` — Devrilmiş ağaç gövdesi (3.0×0.7×0.7 m, kutu, bitki): TAMAM
- `kuru_ot_yigini` — Kuru ot ve dikenli çalı (1.4×0.7×1.2 m, yok, bitki): TAMAM
- `kilise_kapi_sundurmasi` — Ayin kapısı sundurması (2.6×3.2×1.4 m, ozel, kutsal): TAMAM
- `tahta_yigini` — Tahta yığını (2.0×0.8×0.6 m, kutu, yapi): TAMAM
- `baglama_kazigi` — At bağlama kazığı (1.6×1.3×0.3 m, ozel, tasima): TAMAM
- `su_kovasi` — Su kovası ve sırık (0.5×0.45×0.5 m, kutu, su): TAMAM
- `toprak_yigini` — Toprak yığını (1.8×0.7×1.4 m, kutu, yigin): TAMAM
- `cuval_yigini` — Çuval yığını (1.4×1.0×0.9 m, kutu, yigin): TAMAM
- `firin_kuregi` — Fırın küreği (0.3×2.2×0.3 m, ozel, mutfak): TAMAM
- `tas_oturak` — Taş oturak (1.2×0.5×0.5 m, kutu, ev): TAMAM
- `hasir` — Hasır serili zemin (1.6×0.05×1.2 m, yok, ev): TAMAM
- `hasir_perde` — Hasır perde (1.8×2.0×0.1 m, ozel, ev): TAMAM
- `yol_tasi` — Mil taşı (0.5×1.2×0.5 m, kutu, yapi): TAMAM
- `tas_kaide` — Heykel kaidesi (boş) (1.2×1.6×1.2 m, kutu, harabe): TAMAM
- `balik_sepeti_yuk` — Balık sepeti yükü (0.9×0.7×0.5 m, kutu, liman): TAMAM
- `tulum_yigini` — Su tulumları (1.0×0.5×0.8 m, kutu, tasima): TAMAM
- `tas_havan` — Taş havan (0.5×0.45×0.5 m, kutu, mutfak): TAMAM

Köşe grupları (TAMAM): `set_pazar_kosesi`, `set_firin_onu`, `set_balikci_iskelesi`, `set_bostan_kosesi`, `set_sur_onarim_santiyesi`,
`set_manastir_avlusu`, `set_meyhane_onu`, `set_demirci`, `set_dokumaci_boyaci`, `set_multeci_cadirlari`, `set_ayin_alayi`.

## ISTAUDIT (otomatik; tris lod0/1/2, draws lod0)
`delik=na`: öğeler yapı değil, sınır kutusu/ayrı direkler katı; ızgara-ışın denetimi uygulanmadı. `dar`: ortak yüksekliği ≥1 m olan, arasında başka katı bulunmayan kutu çiftleri
arasında 0,2–1,4 m boşluk. `havada`: yer bağlantısı olmayan parça (AABB'lerin 3 cm şişirilmiş bağlantısı; asılı iplik/kumaş ve dönük çubuklarda yanlış pozitif olabilir). `cati_yolu`: climbs_ kaydı olan yolların adımının oyuncu sınırına uyması.
```
ISTAUDIT id=tezgah tris=370/320/12 draws=15 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=tente tris=216/216/12 draws=12 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=amfora tris=240/184/12 draws=7 dar=0 havada=1 cati_yolu=0/0
ISTAUDIT id=pithos tris=300/190/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=fici tris=300/190/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=sepet tris=392/280/12 draws=8 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=cuval tris=120/94/12 draws=4 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=terazi tris=224/156/12 draws=8 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=balik_agi tris=150/150/12 draws=11 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=ag_sehpasi tris=144/84/12 draws=12 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kayik tris=168/168/12 draws=14 dar=0 havada=1 cati_yolu=1/1
ISTAUDIT id=kurek tris=24/24/12 draws=2 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=capa tris=72/72/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=camasir_ipi tris=180/120/12 draws=11 dar=0 havada=2 cati_yolu=0/0
ISTAUDIT id=kumes tris=104/104/12 draws=9 dar=0 havada=1 cati_yolu=0/0
ISTAUDIT id=guvercinlik tris=320/296/12 draws=19 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=ari_kovani tris=288/184/12 draws=8 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=yalak tris=96/96/12 draws=8 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kuyu tris=224/200/12 draws=11 dar=0 havada=1 cati_yolu=0/0
ISTAUDIT id=su_dolabi tris=396/330/12 draws=14 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=el_arabasi tris=228/190/12 draws=12 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kagni tris=336/282/12 draws=16 dar=0 havada=1 cati_yolu=0/0
ISTAUDIT id=esek_semeri tris=168/128/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=odun_yigini tris=588/564/12 draws=20 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=tas_yigini tris=132/132/12 draws=11 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kirec_ocagi tris=80/80/12 draws=7 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=iskele tris=612/540/12 draws=27 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=merdiven tris=144/144/12 draws=12 dar=0 havada=0 cati_yolu=1/1
ISTAUDIT id=sandik_yigini tris=132/132/12 draws=11 dar=0 havada=0 cati_yolu=2/2
ISTAUDIT id=firin tris=348/262/12 draws=11 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=tandir tris=216/142/12 draws=5 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=degirmen_tasi tris=144/102/12 draws=4 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=zeytin_presi tris=228/180/12 draws=9 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=sarap_fici tris=304/214/12 draws=9 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=uzum_teknesi tris=472/392/12 draws=14 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=tezgah_kepengi tris=222/210/12 draws=17 dar=0 havada=2 cati_yolu=0/0
ISTAUDIT id=tabela tris=84/66/12 draws=5 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=ikona_nisi tris=118/96/12 draws=7 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kandil tris=194/154/12 draws=7 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=mum_sehpasi tris=564/168/12 draws=16 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=hacli_tas tris=60/60/12 draws=5 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=lahit tris=140/104/12 draws=12 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=sutun_baslik tris=120/102/12 draws=7 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=mermer_parca tris=96/96/12 draws=8 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=cit tris=72/72/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=bahce_kapisi tris=132/120/12 draws=11 dar=0 havada=1 cati_yolu=0/0
ISTAUDIT id=asma_cardagi tris=994/580/12 draws=31 dar=0 havada=8 cati_yolu=0/0
ISTAUDIT id=saksi tris=404/130/12 draws=8 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=cicekli_pencere tris=418/348/12 draws=15 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kedi tris=160/104/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kopek tris=280/224/12 draws=10 dar=0 havada=1 cati_yolu=0/0
ISTAUDIT id=tavuk tris=180/92/12 draws=7 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=keci tris=288/236/12 draws=10 dar=0 havada=1 cati_yolu=0/0
ISTAUDIT id=esek tris=292/252/12 draws=11 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=at tris=292/252/12 draws=11 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=okuz tris=288/248/12 draws=10 dar=0 havada=3 cati_yolu=0/0
ISTAUDIT id=koyun tris=316/240/12 draws=9 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kaz tris=168/92/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=marti tris=180/104/12 draws=7 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=cop tris=204/184/12 draws=13 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=su_birikintisi tris=138/90/12 draws=3 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=mancinik tris=288/268/12 draws=20 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=gulle_yigini tris=660/520/12 draws=13 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=ok_sandigi tris=216/132/12 draws=18 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kalkan_askisi tris=624/444/12 draws=16 dar=1 havada=0 cati_yolu=0/0
ISTAUDIT id=mizraklik tris=156/156/12 draws=13 dar=0 havada=1 cati_yolu=0/0
ISTAUDIT id=nobetci_kulubesi tris=128/128/12 draws=11 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=barikat tris=264/224/12 draws=14 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=fici_toprak tris=648/412/12 draws=14 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=top tris=336/228/12 draws=10 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=balista tris=180/174/12 draws=13 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kazan_yag tris=354/268/12 draws=10 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=okcu_siperi tris=144/144/12 draws=12 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kusatma_merdiveni tris=228/228/12 draws=19 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=sancak_diregi tris=170/136/12 draws=6 dar=0 havada=2 cati_yolu=0/0
ISTAUDIT id=hendek_kazigi tris=282/282/12 draws=10 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=gabyon tris=288/180/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=ordu_cadiri tris=408/304/12 draws=11 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=multeci_cadiri tris=264/252/12 draws=12 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=yer_yatagi tris=48/48/12 draws=4 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kamp_atesi tris=402/318/12 draws=14 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kazan tris=300/226/12 draws=12 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=mangal tris=402/210/12 draws=10 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=mesale_diregi tris=114/90/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=saman_balyasi tris=60/60/12 draws=5 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=saman_yigini tris=210/150/12 draws=4 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=ot_demeti tris=120/82/12 draws=3 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=yun_balyasi tris=96/76/12 draws=4 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=demir_ocagi tris=150/138/12 draws=13 dar=0 havada=1 cati_yolu=0/0
ISTAUDIT id=ors tris=84/66/12 draws=4 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=soguma_teknesi tris=84/84/12 draws=7 dar=0 havada=1 cati_yolu=0/0
ISTAUDIT id=dokuma_tezgahi tris=288/288/12 draws=24 dar=4 havada=1 cati_yolu=0/0
ISTAUDIT id=boya_kazani tris=180/126/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=boya_askisi tris=144/132/12 draws=8 dar=0 havada=3 cati_yolu=0/0
ISTAUDIT id=kumas_topu tris=216/180/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=deri_gerdirme tris=168/156/12 draws=10 dar=1 havada=0 cati_yolu=0/0
ISTAUDIT id=balik_kasasi tris=310/260/12 draws=10 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=balik_kurutma tris=432/372/12 draws=17 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=halat_rulo tris=240/162/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=palamar_babasi tris=96/72/12 draws=3 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=yelken_bezi tris=60/60/12 draws=5 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=masa tris=168/126/12 draws=10 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=tabure tris=60/60/12 draws=5 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=bank tris=72/72/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=sandik tris=60/48/12 draws=5 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kutuk tris=96/60/12 draws=2 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kutuk_kutugu tris=120/84/12 draws=4 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kazma_kurek tris=48/48/12 draws=4 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=tugla_yigini tris=456/456/12 draws=38 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kiremit_yigini tris=408/408/12 draws=34 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=harc_teknesi tris=84/84/12 draws=7 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=yapi_iskelesi tris=264/264/12 draws=22 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=cikrik_vinc tris=144/126/12 draws=9 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=yikik_duvar tris=170/160/12 draws=11 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=saban tris=60/60/12 draws=5 dar=0 havada=1 cati_yolu=0/0
ISTAUDIT id=testi tris=216/132/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kase_tezgahi tris=300/258/12 draws=11 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=tas_havuz tris=96/96/12 draws=8 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=cesme tris=128/122/12 draws=9 dar=0 havada=1 cati_yolu=0/0
ISTAUDIT id=sarnic_agzi tris=168/114/12 draws=5 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=sutun_govdesi tris=216/144/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=mezar_tasi tris=108/88/12 draws=5 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=can_cercevesi tris=188/168/12 draws=12 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=vaftiz_kurnasi tris=204/120/12 draws=5 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=ayin_bayragi tris=168/162/12 draws=12 dar=0 havada=2 cati_yolu=0/0
ISTAUDIT id=ikon_sehpasi tris=168/148/12 draws=10 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=buhurdan tris=230/130/12 draws=5 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=bostan_sirasi tris=762/532/12 draws=14 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=korkuluk tris=228/178/12 draws=8 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=meyve_agaci tris=596/454/12 draws=13 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=zeytin_agaci tris=318/226/12 draws=8 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=selvi tris=144/100/12 draws=3 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=cali tris=510/240/12 draws=9 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=cicek_tarhasi tris=432/372/12 draws=17 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=tas_kemer tris=108/108/12 draws=9 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=sokak_basamagi tris=48/48/12 draws=4 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=direk_fener tris=134/118/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=sundurma tris=108/108/12 draws=9 dar=1 havada=0 cati_yolu=0/0
ISTAUDIT id=agac_govde_kutugu tris=168/112/12 draws=4 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kuru_ot_yigini tris=132/112/12 draws=7 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=kilise_kapi_sundurmasi tris=140/140/12 draws=12 dar=2 havada=2 cati_yolu=0/0
ISTAUDIT id=tahta_yigini tris=72/72/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=baglama_kazigi tris=108/96/12 draws=5 dar=1 havada=0 cati_yolu=0/0
ISTAUDIT id=su_kovasi tris=180/102/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=toprak_yigini tris=192/132/12 draws=4 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=cuval_yigini tris=372/252/12 draws=7 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=firin_kuregi tris=24/24/12 draws=2 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=tas_oturak tris=36/36/12 draws=3 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=hasir tris=96/96/12 draws=8 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=hasir_perde tris=180/168/12 draws=11 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=yol_tasi tris=44/44/12 draws=4 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=tas_kaide tris=72/60/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=balik_sepeti_yuk tris=216/144/12 draws=6 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=tulum_yigini tris=276/160/12 draws=7 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=tas_havan tris=108/72/12 draws=3 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=set_pazar_kosesi tris=5346/4132/288 draws=199 dar=2 havada=2 cati_yolu=1/1
ISTAUDIT id=set_firin_onu tris=3140/2460/156 draws=104 dar=0 havada=1 cati_yolu=1/1
ISTAUDIT id=set_balikci_iskelesi tris=3366/2730/180 draws=151 dar=1 havada=1 cati_yolu=0/0
ISTAUDIT id=set_bostan_kosesi tris=6452/4270/216 draws=167 dar=2 havada=2 cati_yolu=0/0
ISTAUDIT id=set_sur_onarim_santiyesi tris=2290/2224/144 draws=178 dar=0 havada=0 cati_yolu=2/2
ISTAUDIT id=set_manastir_avlusu tris=2750/1676/180 draws=111 dar=0 havada=0 cati_yolu=0/0
ISTAUDIT id=set_meyhane_onu tris=3752/2404/180 draws=137 dar=0 havada=10 cati_yolu=0/0
ISTAUDIT id=set_demirci tris=1270/1056/120 draws=66 dar=0 havada=3 cati_yolu=0/0
ISTAUDIT id=set_dokumaci_boyaci tris=2264/1810/132 draws=92 dar=6 havada=4 cati_yolu=0/0
ISTAUDIT id=set_multeci_cadirlari tris=2462/2074/156 draws=112 dar=0 havada=2 cati_yolu=0/0
ISTAUDIT id=set_ayin_alayi tris=2634/1510/144 draws=105 dar=0 havada=4 cati_yolu=0/0
```

Üçgen bütçesi (≤ 400/öğe): aşanlar (sınırda, MultiMesh'e geçirilmedi — önizleme öğesi başına birkaç yüz üçgen, sahneye çok örnekli serpiştirmede kabul edilebilir):
- odun_yigini tris=588/564/12
- iskele tris=612/540/12
- uzum_teknesi tris=472/392/12
- mum_sehpasi tris=564/168/12
- asma_cardagi tris=994/580/12
- saksi tris=404/130/12
- cicekli_pencere tris=418/348/12
- gulle_yigini tris=660/520/12
- kalkan_askisi tris=624/444/12
- fici_toprak tris=648/412/12
- ordu_cadiri tris=408/304/12
- kamp_atesi tris=402/318/12
- mangal tris=402/210/12
- balik_kurutma tris=432/372/12
- tugla_yigini tris=456/456/12
- kiremit_yigini tris=408/408/12
- bostan_sirasi tris=762/532/12
- meyve_agaci tris=596/454/12
- cali tris=510/240/12
- cicek_tarhasi tris=432/372/12

## Bilinen kusurlar
- Öğeler MultiMesh ile örneklenmedi; şehir kurucusu aynı öğeyi çok kez kurarsa her örnek ayrı ağ ve çarpışma olur (`Props.share_meshes` kapalı). Önce `Ayrinti.build` ile kurup çoğaltma önerilir.
- `havada` sayacı bazı asılı/dönük parçalarda yanlış pozitif verir (kandil teli, kumaş askıları, dönük çubuklar); görsel turlarda havada duran yapı görülmedi, düzeltilenler: kağnı oku, top kızağı, balista, hasır siper, mızraklık uçları, fırın küreği, tabela.
- Hayvanlar durağan ve çok basit (≤ 350 üçgen); çarpışmaları yalnız at/eşek/öküzde var.
- Mancınık kolu ve ordu çadırı ip/direk ayrıntısı sade; çıkrık vinci tekeri düz elips görünür.
- Nihat'ın yan görevi (kubbe/anıt) bu parçanın kapsamı dışında: `bakis` alanları yok.
- Yürüyen oyuncu ile gerçek CharacterBody3D adım sınaması yapılmadı (yalnız `climbs_` adım yüksekliği denetimi); bakamadıklarım: oyun içi ışıkta renk dengesi, k=0,35 köşe yoğunluğu.

## Paftalar
`pafta_*.jpg`: öğe ızgaraları, köşe grupları ve yakın kareler.
