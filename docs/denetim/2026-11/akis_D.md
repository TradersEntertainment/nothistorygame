# Akis denetimi D: bolum 15, 16, 17, 17o, 18, 18b

Yontem: kod okundu (scripts/chapterN.gd, ui/hud.gd, ui/gun_drill.gd, combat/cannon_crew.gd, ui/row_meter.gd,
ui/tespit_cam.gd, player/carry.gd, i18n/strings.csv). flowall/ch15..ch18b.txt izleri BU CALISMADA YOKTU (klasorde
yalniz ch4..ch12 var), bu yuzden dondurulmus sure tahminleri kodun dedigi satir uzunluklarindan:
hud.say suresi = ses uzunlugu x0.85, kabaca 14 karakter/sn (UNSURE, +/-%30). Gercek izle dogrulanmali.

Genel bulgular (6 bolum icin ortak):
- Bu bolumlerin hicbirinde hud.show_controls yok (yalniz ch0-2'de var). Tus bilgisi hedef metninde ya da yakinlik
  isteminde ([E] ...) veriliyor; hud.set_prompt/set_objective kolda otomatik GameState.pad_text ile cevriliyor,
  yani *_PAD anahtari gerekmiyor.
- Isaretci (marker) oyuncu donukken ve konusma acikken gizleniyor (objective_marker.gd:116,139); hide_near
  varsayilan 4 m (objective_marker.gd:150).
- Top bolumlerinde (17o, 18b) CannonCrew adim adim hedef + isaret + ipucu veriyor (cannon_crew.gd:261-275): iyi.

---------------------------------------------------------------------------------------------------
## Bolum 15 (Pazartesi, final)

Akis: kart > garaj (1 replik) > Nihat masasi (1-2) > durak/ofis (tek replikler) > esya kagidi > insan kagidi >
final karti > Journey > Review. Oyuncu cogunlukla izleyici (tasarim bu). Tek oynanis T3'te: 1977 sokagi.
Normal yolda (T1) tek satirlik bloklar var, 25 sn'yi gecen kesintisiz donuk blok yok.

[MED] chapter15.gd:1223-1245 (_paper), cagrilar 643, 654, 875, 1168. Esya/insan kagidi `_wait(hold)` ile SABIT 9 sn
  (ads 5, policy 5) bekler; tus ile gecilemez, uzatilamaz. ItemFates.rows() ve PeopleFates.pages() (item_fates.gd:77,
  people_fates.gd:261) satir satir 10+ kayit ve 2026 izi iceriyor; 9 sn'de okunmaz. Oyuncu ne zaman bitecegini
  bilmiyor, ne de yavaslatabiliyor. Cozum: `_wait(hold)` yerine "en az 3 sn, sonra E/Space ile gec, en cok
  hold = max(9, 0.05*karakter) sn" ve kagidin altinda kucuk ipucu (UI_JOURNEY_CONTINUE benzeri metin). Yalniz
  kontrol; metin kesilmiyor.

[MED] chapter15.gd:924-927 + 975-1007. 1977 karari: secenek metni "Kirmizi dugmeye bas: 2026'ya don"
  (UI_CH15_C_RECALL) hangi tusa basilacagini soylemiyor. Secimden hemen sonra 5 sn'lik pencere (RECALL_WINDOW,
  satir 739; kadran tutturulmadiysa 9 sn degil, 5 sn) ve 1,2 sn basili tutma baslar; tus ancak QTE metninde
  gorunuyor (UI_CH13_PRESS "[R] basili tut: KIRMIZI DUGME", satir 980). Fare ile secen oyuncunun eli klavyede
  degil; kacirinca "Baska Bir Yil" sonuna (stay) dusuyor, ilerleme kaybi geri alinamaz. Hikmet'in
  D15_Y_H_RADIO_CALL satiri ("Kirmizi dugme! Basili tut!") tusu soylemiyor. Cozum: secenek metnine tus ekle
  (ornek "[R] Kirmizi dugmeye bas...") ya da QTE'yi 1,5 sn gecikmeyle baslat ve pencereyi 7 sn yap;
  hud.set_qte zaten kolda tusu ceviriyor.
  Ek: `hud.choose(..., 12.0, ...)` (924): "Sureli kararlar" ayari aciksa sure dolunca -1 doner, kod bunu "kal"
  sayar (`pick == 0` degil). 12 sn sayaci gorunur, ayar varsayilan kapali: LOW, ama dolan sure sessizce
  geri donusu kapatiyor; -1 icin "Radyo sessiz kaldi" satiri/kart yok.

[LOW] chapter15.gd:776-777 vs 976. Frekans tutturulmazsa (D15_G_T3_DRIFT) geri cagri penceresi 9 sn'den 5 sn'e
  iner (satir 976), ama bunu anlatan hicbir sey yok; oyuncu kadran oyununun sonucunu hissetmiyor.
  Cozum: DRIFT replikine bagli bir ipucu zaten var ("izi var"); hud.bark ile "Pencere kisa olacak" benzeri
  oyuncuya donuk uyari (yeni metin) ya da kadran basarisizliginda hud.set_chase'e etiket.

[LOW] chapter15.gd:844-846. 1977 sokaginda ilk serbest yuruyus; yurume/etkilesim tusu hic gosterilmiyor
  (yalniz kiosk yaninda "E . Gazete al"). Bolum baslangici 3+ dk sinematik; menuden baslayan oyuncu icin
  `hud.show_controls(true, "UI_CONTROLS")` ile 8 sn'lik yuruyus ipucu yeterli.

[LOW/KABUL] chapter15.gd:896-922 gorusme ~13 replik, tahmini 80-90 sn donuk. Oyuncu ziyaretci
  sandalyesinde (sit_view), kamera Ferit'e kilitli; serbest birakmak anlam tasimaz (yurunecek yer yok).
  Say-zinciri onerisi YOK. Sadece kararin geldigini bildiren bir sey yok: T_RADIO'dan sonra secenek birden
  cikiyor (Hikmet'in "Kirmizi dugme" satiri hazirliyor, yeterli).

[LOW] chapter15.gd:1345 `_stage` 3,6 sn sabit kart, atlanamaz (D15_S_T2, D15_G_H3 vb.). Kabul.

Hedef bosluklari: 1977'de kiosk (845-848) ve acente (879-889) icin hedef + isaretci var; arada `_free_walk(false)`
ile donuyor, "(yok)" yok. Kahve radyosu serbest yururken akiyor (hud.bark): iyi. Bolum sonu: final karti (6 sn),
"GERCEK TARIH BU DEGIL", Journey/Review (atla ipucu var, journey.gd:594). Net.

---------------------------------------------------------------------------------------------------
## Bolum 16 (Gidak, 90 sn)

Akis: 2 replik (D16_S_01 + D16_S_02, ~9 sn donuk) > serbest, hedef UI_OBJ16 + isaretci REMOTE+0.6
(chapter16.gd:338-343) > gaga/leblebi/yakalanma > 90 sn sayac (set_chase "Pencere: N sn").
Hedef metni: "Kirmizi dugmeyi gagala (3 kez) . Hasan ile Huseyin'e yakalanma . Leblebiye bakma" (UI_OBJ16).
Tus: yakinlikta "E . Gagala (n)" (1,1 m, satir 230) ve "E . Leblebiye dal..." (1,6 m); kick tusu da gagalar (234).
Sayac donukken akmiyor (kayip/yakalanma sirasinda `_respawn` donar ama sayac akar, ~0,6 sn).

[MED yok]. Bolum akici; sorunlar LOW:

[LOW] chapter16.gd:207-216. Yakalanma: -8 sn ceza + basa donus. Hicbir yerde soylenmiyor (hedef "yakalanma"
  diyor, replik D16_G_CATCH_n yalniz komik). Oyuncu sayacin 8 sn atladigini gorur ama nedenini baglayamaz.
  Cozum: yakalanma barkina ek satir yok (replik kesilmez), onun yerine `hud.set_chase` etiketini 2 sn
  "-8 sn" ile goster ya da UI_OBJ16'ya "(yakalanirsan -8 sn)" ekle (metin degisikligi, replik degil).

[LOW] chapter16.gd:341. Kumanda 16 cm; isaretci 4 m'de gizleniyor (varsayilan hide_near) ama istem 1,1 m'de
  cikiyor. 1,1-4 m arasinda yalniz yanip sonen isik ve bip (174-175) var. Cozum: sahne baslangicinda
  `hud.marker.hide_near = 1.2` (chapter1.gd:160 ile ayni kalip).

[LOW] chapter16.gd:341 / hic show_controls yok. Tavuk bakisi ilk kez; yurume/gagalama tusu yalniz yakinda. Cozum:
  `hud.show_controls(true, "UI_CONTROLS")` 8 sn, ya da D16_S_02 sonrasi "E: gagala" 1 satir.

[LOW] chapter16.gd:480-484. Sure bitince ("late") kart yok, yalniz D16_S_LATE satiri; "leb" yolunda
  UI_CH16_LEB karti var. Tutarsiz ama sonuc anlasiliyor (akis semasi 13.2/13.6 gosteriyor).

Kilitlenme yok: sayac her halde bitiyor. Yeniden deneme: bolumun kendisi tekrar oynanabilir ("replay").

---------------------------------------------------------------------------------------------------
## Bolum 17 (Kundak, Bizans: kurek + kurtarma)

Akis: Buro onsozu > Edirne ara bolumu > taraf secimi > Halic: brif (5 replik) > kurek (Space) > Galata isigi
(foto, 22 sn) > kurek 2 > toplar > Coco vurulur > kurtarma (40 sn) > safak.

[MED] chapter17.gd:479-552 + 1216-1225 + interlude_edirne.gd. Oyuncu ilk gercek kontrolden (kurek) once uzun
  donuk bloklardan geciyor (tahmin):
  a) 479-492 (N_01 ... N_BACK, T_PRO_1, T_WINDOW) ~55 sn kesintisiz donuk, ardindan secim (493).
  b) 501-507 + 1216-1225 (N_05, T_05, N_06, N_CAM_1, T_CAM_1, N_CAM_2, N_CAM_3) ~40 sn donuk; kamera
     verme animasyonu gerekli, burasi donuk kalmali.
  c) 516-526 (N_SIDE, N_SUGGEST, N_CLAIM, T_CLAIM) 15-40 sn, secim 529; sonra 531-552 (T_SIDE, FEZ_ISSUE,
     PHONE_ISSUE, N_07, T_07, N_08, N_FIRST, N_RULE, T_RULE) ~55-80 sn donuk.
  d) Arada EdirneInterlude (457) ayrica onlarca replik (denetim disi, UNSURE).
  Toplam: kurek ilk basisina kadar tahminen 4-8 dk, bunun cogu donuk.
  Serbest birakilabilir (kimsenin sabit durmasi gerekmiyor, Nihat yerinde, kamera kesmesi yok):
  - a) replikler 479-492 (D17_N_01/_NOAUD/_WALLS, D17_N_02, D17_T_PRO_1(_NOLEB), D17_N_03, D17_N_04,
       D17_T_WINDOW, D17_N_BACK) `hud.say_chain([...])` + `while hud.chain_busy()` ile; oyuncu serbest,
       hedef `hud.set_objective(tr("UI_OBJ17_LISTEN"), nihat'in_basi)` ("Nihat'i dinle"; yeni metin).
       Secim (493) zincir bitince.
  - c2) 543-552 (D17_N_07/_07O, D17_T_07, D17_N_08, D17_N_FIRST_xx, D17_N_RULE, D17_T_RULE) say_chain; telefon
       teslimi (540) ve fes (533-536) once kalsin (Handover oyuncu yakinligi ister).
  - c1) 516-526 (N_SIDE, N_SUGGEST_x, N_CLAIM*, T_CLAIM) say_chain, ardindan secim.
  Dikkat: say_chain sirasinda `player.face(nihat)` (513) cagrilari oyuncunun bakisini cekmesin; yalniz bir kez.

[MED] chapter17.gd:663-688 + 1015-1016 + 1078-1080. Kurtarma sayaci yanlis zamanda calisiyor. `_rescue()` phase=
  "rescue" yapar (663); `_process` hemen `_rescue_tick` calistirir ama `_rescue_t` ilk deger 0.0 (satir 67) ve
  ancak 688'de `_rescue_total`a esitlenir. Aradaki replikler (D17_TR_RESCUE 674, 29O/10H yolunda D17_L_CHAIN +
  D17_T_CHAIN 683-684, D17_G_HELP 727; toplam ~5 sn, en cok ~30 sn) boyunca HUD "Toplar yeniden dolduruluyor . 0 sn"
  ve dolu cubuk gosterir, sonra 40'a zipliyor; hedef "" (667) ve oyuncu serbest. Yuzlerce sn'lik duplike: oyuncu
  bu sirada yuzenleri cekebilir (phase "rescue" _pull'a izin veriyor), ya da dusebilir (`_fell` -6 sn).
  Cozum: `_rescue_t = _rescue_total` ve hedefi (UI_OBJ17_RESCUE, 0/3) replikler BASLAMADAN ata, `_rescue_tick`
  basina `if not _rescue_live: return` bayragi (688'de true) koy; replikleri `say_chain` ile serbest ver (hedef
  gorunsun) ya da sayaci replikten sonra baslat.

[MED] chapter17.gd:686, 817 (set_objective bos hedefli). Yuzen denizcilere dunya isaretcisi yok; tek yardim
  4 sn'lik bark D17_HINT_RESCUE ("Korkuluga git, asagi bak, uzan", 687) ve yakinda "[E] Uzan, cek" istemi
  (UI_PROMPT17_PULL, 1130). Gece, 40 sn sayac isliyor. Yuzenler korkulugun 1,2-1,5 m disinda ve deck'ten 2,2 m
  asagida. Cozum: hedef olarak Callable ver: `hud.set_objective(tr("UI_OBJ17_RESCUE") % [...], func(): return
  nearest_unsaved_swimmer_pos + Vector3(0,1.0,0))` (hud destekliyor, hud.gd:708); 817'de de ayni.

[MED] chapter17.gd:985-988. Kurek durunca tek hatirlatma: `_idle_warned` bir kez D17_TR_IDLE (bark gostergesi
  bitince, ~5 sn sonra); basmayan oyunda kayik 0,25 m/s suzuluyor (984) ve yeniden uyari yok. Kurek yolu ~150 m:
  hic basmayan oyuncu ~7 dk bekler, kimse "Space'e bas" demez (hedef metni "ibre yesile gelince Space" kalir
  ama ibre atlanabilir). Ayrica basis tek tek tekrarlanmali (basili tutmak sayilmaz) - bunu anlatan yok.
  Cozum: idle suresi 12 sn'yi gecince ikinci bark (D17_HINT_ROW tekrar) + `hud.show_controls(true,
  "UI_ROW_HINT")` ("Space: tek tek bas, basili tutma"); 25 sn'de minimum hiz 0,25 -> 1,2.

[MED] chapter17.gd:398 -> 667 (hedef) ve 390-400, 619-659. "Kurek cek: ibre yesile gelince Space" hedefi,
  Coco vurulunca (`_coco_hit` meter.enabled=false, 621) kurtarmanin basladigi 667'ye kadar ekranda kaliyor
  (kayik 3 m/s ile geri durur: ~5-10 sn + 1,2 + D17_T_HIT). Gosterge yok, Space islevsiz: celisik. Ayrica
  `_light()` baslarken (584-593) hedef 1,6 sn eski "kurek" kalip sonra foto hedefine geciyor.
  Cozum: 621'de `hud.set_objective("")` ya da bos hedef yerine Tolga'ya "Bekle..." hedefi yok; sadece temizle.

[LOW] chapter17.gd:609-616. Foto sonrasi (hedef "" 609) D17_T_SHOT, D17_N_SHOT, D17_CO_GO (veya N_MISSED)
  ~15 sn oyuncu serbest (pinned) ve hedefsiz; kurek tusu yok sayiliyor. Cozum: 609'u kaldir, hedefi
  UI_OBJ17_ROW'a dogrudan gec (meter.enabled=true 399 zaten sonra); ya da konusmayi say_chain ile ver.

[LOW] chapter17.gd:379-386 brif ~23 sn donuk (TR_01, T_01, TR_02, T_02, CO_01): kabul.

[LOW] chapter17.gd:1234 UI_OBJ17_TEST "Nihat'i kadraja al, deneme karesini cek": deklansor tusu hedefte yok
  (UI_OBJ17_LIGHT "(bak ve E)" var). Nihat 0,9 m yakinda, isaretci hide_near ile gizli. Istem "[E] Tespit et"
  ancak kadraja girince cikiyor (tespit_cam.gd:130). Kamerayi ilk kez burada kullanan oyuncu icin metne
  "(E)" ekle. 20 sn sonra basarisiz: N_CAM_4_NOSHOT aciklayici, adil.

Dusme / adalet: ilk dusus -6 sn ve ~2 sn kararma (1098-1101); uyari D17_TR_WARN ancak ilk dususten 3,2 sn sonra
(1117-1119). Ikinci dusus kalici sapma (17.3, esir, Osmanli tarafi): sonuc D17_TR_LOST + UI_CH17_CAPTIVE karti
ile aciklaniyor. Uyari ilk dususten ONCE yok. LOW: D17_HINT_RESCUE barkina "kenara fazla egilme" eklemek
yerine 674 Trevisano satirindan sonra tek bark.

Bolum sonu: sayfa + akis sasesi; net. 17.3'te kaybetme anlasilir.

---------------------------------------------------------------------------------------------------
## Bolum 17o (Kundak, Osmanli kiyisi: top + kova zinciri)

Akis: 3 replik (A_01, T_01, A_02) > A_LIGHT (donuk) > serbest foto (22 sn, isaretci Galata) > "gor" > 2 atis
(CannonCrew) > yangin (kova zinciri 40 sn) > safak.

[HIGH?] chapter17o.gd:452-460. "Karanlikta yaklasan gemiyi gor (bak ve E)" (UI_OBJ17O_WATCH) adiminda DUNYA ISARETCISI
  YOK (set_objective yalniz metin), D17O_A_WATCH da yon vermiyor ("Sudaki bir golge..."), dongu
  `while not _spotted` (457) sonsuz: zaman asimi, hatirlatma, otomatik gecis yok. Foto adiminin hemen
  ardindan oyuncunun bakisi Galata isigina (-70, 38, 30) dogru, gemi (30, 0, 120 -> 55) sag onde; aradaki aci
  100 dereceyi asar. Gemi fenersiz koyu govde. E yalniz 10 derecelik konide kabul (459, 483). Gorus UNSURE
  (Night.environment 0.008 sis), ama hint/timeout olmamasi dogrulandi: gormeyen oyuncu bolumde sonsuza dek
  takilir (soft lock).
  Cozum: hedefe Callable ver: `hud.set_objective(GameState.tr_pad("UI_OBJ17O_WATCH"), func(): return
  coco_boat.global_position + Vector3(0,2,0))` (kenar oku yon verir); 20 sn sonra Topcubasi bark'i ("Saginda!")
  ve 40 sn'de `_spot()` zorla (kod: `if _t_watch > 40: _spot()`).

[MED] chapter17o.gd:424-430. Acilis ~30 sn donuk (A_01 ~125 kr, T_01 ~85, A_02 ~125, A_LIGHT ~90; basliktan sonra).
  Kamera kesmesi yok, kimse sabit durmuyor. Serbest verilebilir: A_01, T_01, A_02 `hud.say_chain` ile, hedef
  "Topcubasini dinle / bataryayi tani" (yeni metin) ve topcu baslarina isaretci; isik (428) A_LIGHT'ten once
  zincir bitince. Not: foto adimi serbestligi 432'de zaten basliyor.

[LOW] chapter17o.gd:469 vs cannon_crew.gd:261-275, 509-517. "aim" durumunda `_start_aim` (513) isaretciyi
  gizliyor ama hedef metni "Topun arkasina gec, nisan al" olarak kaliyor; nisan sirasinda hint cizimi
  (UI_CREW_AIM_KEYS, gun_drill.gd:179) yeterli. Cozum: `_start_aim` sonunda `hud.set_objective(tr("UI_GUN_AIM"))`.

[LOW] chapter17o.gd:620-625, 892-893. Kova tasimada denge (carry.gd:112) kosmak/sert donmek suyu dokuyor
  (fill azalir, her tasma ~1/3). Gosterge ancak %45'ten sonra cikiyor (carry.gd:134) ve hedef bunu soylemiyor.
  UI_OBJ17O_POUR/BUCKET'e "(kosma)" eklemek yeterli.

[LOW] chapter17o.gd:665-669 + 857. Sure bitince oyuncu yardim etmediyse bile 17O.2 ile devam (kilitlenme yok);
  askerlerin kendi doldurusu ~7,5 kova (NPC_POUR 0.28/1,5 sn) < 10; oyuncu >=3 kovada yetisiyor: adil.

Kontroller: top: CannonCrew adim adim (E al, E sur, ritim E, W-S/A-D/fare, E ates) hepsi ekranda. Kova: [E] istemi var.
Bolum sonu: D17O_A_OUT/BURNED + safak karti + Nihat satiri; 17O.1/2 anlasiliyor.

---------------------------------------------------------------------------------------------------
## Bolum 18 (Ficis Kopru, Osmanli)

Akis: 4 replik (5-8 ikizlerle) > her bolum: ficilari yuvarla (E) > hali bagla (E ile baslat, E ile bas, yesil)
> kalas (E); x6 > top cekilir > foto (40 sn) > son replikler.
Hedef/isaretci her adimda var (UI_OBJ18_BARRELS/LASH/PLANKS %d/6), istemler "[E] ..." ve "[E] DUGUMLE! (yesilde)"
(satir 503). Gosterge 1,1/sn, yesil +-0,16 (ikizlerle +-0,23), sure siniri yok, kacan bag eguk kopru + usta
bark'i (D18_U_MISS_n), banta secenek (556). Adil.

[MED] chapter18.gd:421-443. Acilis donuk: normal ~35 sn (N_01 ~155 kr, U_01 ~80, T_01 ~80, U_02 ~190), ikizli
  yolda ~53 sn (+HA_01, HU_01, U_TWINS), esir yolunda ~48 sn (N_01_CAPTIVE ~210). Kamera kesmesi yok; oyuncunun
  usta/ikizler icin `player.face(...)` (429, 436, 438, 440) dismindaki sabit durusu gerekmiyor.
  Serbest ver: 428-441 bloku `hud.say_chain([...])`, hedef `set_objective(tr("UI_OBJ18_LISTEN"), usta_basi)`
  ("Ustayi dinle", yeni metin), `player.face` cagrilari kaldir (kamera zorlamasi serbest oyuncuda rahatsiz eder),
  zincirden sonra `while hud.chain_busy()` ve `phase = "build"`.

[LOW] chapter18.gd:605-606 + 465. `_move_piles` (605) fici yiginini 1,3 sn'de kaydirir (`_glide` 351-356), hemen
  ardindan `_update_objective` (606) o anki (eski) konumu sabit Vector3 olarak isaretciye verir; "ficilari yuvarla"
  isaretcisi 3 m geride, bos yerde kalir (yigin ve usta ilerlemis). Cogu zaman oyuncu 4 m icinde oldugu
  icin hide_near gizliyor, ama uzaktaysa yanlis yere bakar. Cozum: hedef olarak Callable:
  `func(): return _pile_barrel.global_position + Vector3(0,1.4,0)` (hud.gd:708).

[LOW] chapter18.gd:519-525. Kacan bag sayaci (misses) HUD'da yok; ancak "D18_U_MISS_3" ile 3. kacagin kopruyu egrilestirdigi
  (esik: >2, 683) hic soylenmiyor. Bolum sonu istatistigi (UI_CH18_STATS) var. Cozum: kacirmada hedef metnine
  "(kacan bag: n)" ekle ya da hud.bark'e sayi.

[LOW] chapter18.gd:659-672, 683. Foto hedefi UI_OBJ18_PHOTO ("Tespit et: koprunun ustundeki top") tus icermiyor
  (17'deki gibi "(bak ve E)" yok); 40 sn sonra sessizce gecer, kacirildi bilgisi yok (17o'da T_MISSED var).
  Cozum: metne "(bak ve E)" ekle; `cam.done` false ise bir bark (mevcut D17O_T_MISSED benzeri yeni satir).

[LOW] chapter18.gd:647-682. Bitis ~25 sn donuk (D18_T_CANNON, U_END, T_END, N_END); Stage.walk_player ile
  yuruyor. Kabul.

Soft lock: yok (suya dusme `_swim_back` 689-704 ile kiyiya donuyor). Wander: hedef kalici, hatirlatma yok; sure
siniri olmadigi icin sorun degil. Bolum sonu: kart + akis; `captive` yolunda UI_CH18_CAPTIVE karti net.

---------------------------------------------------------------------------------------------------
## Bolum 18b (Ficis Kopru, surlardan)

Akis: 4 replik (N_01, G_01, T_01, G_02) > 3 atis: [secim az/cok barut] > hedef + CannonCrew > sonuc replikleri >
yanit topu (3,2 sn) > foto > 3 replik.
Secim: UI_C18B_SMALL "Az barut: sur saglam kalsin." / UI_C18B_BIG "Cok barut: koprüye yetissin." (sonuc ipucu
secenekte ve D18B_G_02'de acik); gizli sayac yok (choose timeout 0.0, 197). Az barutla gulle fiziksel olarak
koprüye yetismiyor (power 0.72, max egim 20 derece, hedef ~28 m; hesap: menzil ~26 m, UNSURE) - secenekle uyumlu.

[MED] chapter18b.gd:189-192. Acilis ~40 sn donuk (N_01 ~175 kr, G_01 ~150, T_01 ~40, G_02 ~210; yalniz 4 satir ama
  uzun). Serbest verilebilir: topun yerinde bekler, oyuncu zaten topun 1,7 m yaninda; 195-196 yerlestirmesi
  zincirden sonra. Cozum: `hud.say_chain` + hedef "Topcuyu dinle" (isaretci gunner basinda); secim (197)
  zincir bitince.

[LOW] chapter18b.gd:198 (+cannon_crew.gd:261). Her atistan once teleport (195) + secim; secimde hedef/isaretci yok
  (normal: kutu acik). Atis arasi `_reply` (3,2 sn) ve sonuc replikleri donuk; kabul.

[LOW] chapter18b.gd:310, 326 UI_OBJ18B_PHOTO tus icermiyor; kacirma geri bildirimi yok (D18B_G_END_HIT/MISS yalniz
  atislara bagli). Cozum 18 ile ayni.

[LOW] chapter18b.gd:285-289. Cok barut her atista sur catlagi (cracks) ve D18B_G_CRACK_n; sonuc istatistik karti.
  Sinir yok; adil.

Soft lock: yok. Top: CannonCrew (hata sinirsiz, ceza yok).

---------------------------------------------------------------------------------------------------
## Ozet tablo

HIGH (1, gorus UNSURE): 17o:452-460 (gemiyi gor, isaretci/hatirlatma/zaman asimi yok, sonsuz dongu).
MED: 17:479-552/1216-1225 (donuk onsoz blogu); 17:663-688 (kurtarma sayaci/0 sn + hedefsiz); 17:686,817 (yuzenlere
isaretci yok); 17:985-988 (tek hatirlatma, 0,25 m/s); 17:398-667 (bayat kurek hedefi); 15:1223-1245 (kagit 9 sn sabit);
15:924+975-1007 (dugme karari tus soylemiyor, 5 sn); 17o:424-430; 18:421-443; 18b:189-192 (donuk acilislar).
Diger tum maddeler LOW.
16: akici, yalniz LOW (ceza anlatilmiyor, isaretci hide_near, kontrol ipucu yok).
