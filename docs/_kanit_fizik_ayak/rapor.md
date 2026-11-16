# FİZİK-AYAK — ayaklar yere bassın (oyun geneli ayak yerleştirme)

Dal `wip/fizik-ayak` (taban `wip/ist2-birlesik` 5203a40e). Yöntemin ayrıntısı: [`yontem.md`](yontem.md).
Sahibin sözü (37o an_04): "ayaklar havada falan duruyor … ayaklar hep yere bassın; karakter çapraz mı durur artık, bir
ayağı eğik mi durur".

## Özet

| # | İstek | Durum | Not |
|---|---|---|---|
| 1 | Ayak yerleştirme, bütün insanlar (IK, kalça alçak ayağa, taban eğime, gövde dik, yürürken basan ayak kilitli) | **TAMAM** | `scripts/npc/ayak.gd`; Person, Soldier, Hikmet ve LimbAnim'le oynatılan düellocu gövdesi. Yürüyüş, koşu, merdiven/basamak, rampa, moloz, sur yolu, kalas. Kadans hızdan (ayak kayması bitti). |
| 2 | Kapsam dışı durumlar bozulmasın | **TAMAM** | Oturan, yatan/ölü, tırmanan, binen, taşınan, uçan/yüzen, DurusKit duruşları, kilitli iskelet (LimbAnim'li ayaktaki klip hariç: onun duruşunda izdüşüm), meşgul (sahne betiğinin oynattığı iş), devrilen, çarpışmasız döşemedeki: IK kapalı, duruş aynen. |
| 3 | Hayvanlar | **TAMAM** (basit) | At, öküz, keçi: ön/arka zemin farkından gövde eğimi (≤ 17°) ve yüksekliği, bacaklar dik. Tavuk, kedi: yükseklik. Toynak başına IK yok. |
| 4 | Bütçe (LOD, seyrek ışın, ölçüm ≤ %5) | **TAMAM** (aşağıdaki ölçüm yöntemiyle) | LOD 28 m + görüş konisi, düzde duranda yazma yok, ışın adım başına. IK otomatik testin karesinde %0,0–1,5; 60 kişilik en kötü durum (hepsi yakında, eğimde/yürüyor) gerçek zamanda %6–8 (aşağıda). |
| 5 | AYAKAUDIT, ÖNCE\|SONRA 15+ bölüm | **KISMEN** | 20 koşu (15 istenen bölüm + ordugâh 24o + şehir 24 + 3 kalabalık çeşit). Yakın satır **87 → 5**; hedef 0'dı: kalan 5'in 3'ü IK kapsamı dışındaki meşgul iş pozu (26), 2'si dik molozda burun/topuk gömüklüğü (37o =trespass). |
| 6 | Kanıt kareleri ÖNCE\|SONRA | **KISMEN** | Aşağıda; kimi sahnede yan kamera kalabalıkta iyi açı bulamadı (yazıldı). |

## Yöntem (kısa)
- **IK**: iki kemikli (uyluk L1, baldır L2 CharKit.leg'den; diz kosinüs yasası, uyluk FK düzlemini koruyan en kısa dönüş).
  Kalça kök uzayında her ayağın erişim sınırına göre iner (en çok 0,5 m), gövde yalnız kaydırılır (dik). Taban
  zemin normaline döner (ileri eğim bilek x'i, yanal eğim bilek z'si).
- **Yürüyüş**: Rig'in evresinden basma/salınım (basma payı 0,56 → koşuda 0,25); basan ayak ebeveyn uzayında kilitli;
  salınan ayak bir sonraki basma noktasına (hızdan öngörü) kalçaya göre sarkaç + yay. Adım boyu hızdan
  (0,2 + 0,2·v m): eski kadans (3 + 1,6·v rad/sn) ayağı gövdenin yarı hızında geri götürüyordu.
- **Işın sıklığı**: dururken ayak başına bir (ayak 6 cm kayınca ya da 1–1,3 sn'de bir yeniden); yürürken adım başına
  iki (basma + iniş öngörüsü). Işın Unclip.floor_y ölçüsü: yalnız görünen/basılabilir çarpışma.
- **LOD**: ≤ 28 m ve görüş konisinde (koni testi her karede, ucuz). Kamera kesmesinde görüşe giren kişide anında,
  yürüyerek sınırı geçende 0,25 sn'de yumuşak. Uzaktakiler eski yol (kök `Unclip.rest_settle` ile zemine).
- **Denetim (AYAKAUDIT)**: yarım saniyede bir, kameranın gördüğü 40 m içinde, o an basması gereken her ayak;
  tabanın topuk/orta/burun noktalarından biri zemine ≤ 6 cm değilse "havada", biri 6 cm'den derinse "gömük"; iki
  ardışık ölçümde süren bir kez yazılır. Ayrıntı `yontem.md`.

## AYAKAUDIT ÖNCE | SONRA (bölüm bölüm)
ÖNCE: aynı kod `--ayak-ik=0` (IK ve yeni kadans kapalı = tabanın davranışı). `--max-fps 20`, ekransız, `--autotest`.
Günlükler (süzülmüş): [`gunluk/`](gunluk/). Satır: kişi-ayak başına bir kez.

TABLO1

**Kalan 5 satır (SONRA, yakın)**
- 26 =hold, `act=hammer` (d 1,4) ve `act=chop` (d 5,4), burun 11–13 cm gömük: kişi Stage'in iş tutuşunda (`_busy`),
  bacakları sahne betiğinin pozu; IK kapsam dışı (ik=w0). Pozun kendisi (öne basan ayağın burnu yere giriyor) — **kötü**,
  benim dosyam değil (Stage), istek olarak yazıldı.
- 26 =hold, duran kişi (d 1,8) sağ ayak −0,09: sur kenarında, tabanın bir ucu taşın içinde.
- 37o =trespass, molozda duran asker (d 6,1) iki ayak −0,10/−0,12: kalça 0,40 inmiş, ayaklar zeminde ama dik moloz
  yüzünde taban düz (normal dik yüzde düz sayılıyor) → burun/topuk taşa giriyor.

## Kare süresi (ÖNCE | SONRA)
Otomatik testte kareler çok uzun (kare başı 40–500 ms işlem: test botu, ekransız) ve koşudan koşuya ±%20 oynuyor:
iki koşunun işlem süresi farkı gürültü. Daha sağlam ölçü **IK'nın kendi süresi** (`Time.get_ticks_usec`, kare başı)
ve bunun SONRA işlem süresine oranı (`--ayak-olc`, `AYAKPERF` satırları).

TABLO2

**Gerçek zamanlı en kötü durum** (deney sahnesi `tests/_fizik/ayak_sahne.tscn --ayak-kalabalik=60`, ekransız, kare
sınırı yok; 60 kişi + 9 denek hepsi kameranın 25 m içinde ve görüşte, yarısı yürüyor, çoğu eğimde/molozda):

TABLO3

Kişi başı IK ~21 µs/kare (iki bacak + kalça + taban; ışınsız), ışın ~30–60 µs (sahnenin karmaşıklığına göre) ama kişi
başı saniyede ~1–5. Düz zeminde duran kişide IK hiçbir şey yazmaz. Çizim çağrısı ve üçgen değişmez (yalnız mevcut
düğümlerin dönüşümü değişir; yeni ağ yok) — 37o `=kare` bütçe satırları (TASIMA37OKARE çizim/ilkel) ÖNCE|SONRA aşağıda.

TABLO4

## Kareler (oyuncu kamerası + yandan; 1280×720, jpg 85) — [`kare/`](kare/)

KARELER

## Hayvanlar
Deney sahnesinde 25° yokuşta at ve 15° yokuşta öküz: ÖNCE gövde yatay, arka toynaklar havada/ön toynaklar gömük;
SONRA gövde yokuşa göre eğik (en çok 17°), dört toynak yamaçta (`kare/sahne_at_yokus_*.jpg`, `kare/sahne_okuz_*`).
Keçinin kökü betikte hep y = 0 (düz ağıl varsayımı): yokuşta kök zeminin altında kalıyor, ışın üstündeki zemini görmüyor
→ keçi yokuşta düzelmez (bölümlerde keçi düz ağılda; **hâlâ kötü**: keci yokuşa konursa).

## Hâlâ kötü olanlar
1. **Meşgul iş pozları** (Stage.grip_hold: çekiç, balta; 26): öne basan ayağın burnu 11–13 cm yere giriyor; IK bu
   pozlarda kapalı (sahne betiği bacakları sürüyor). Stage'e (benim dosyam değil) istek: tutuşta `rig.ayak` izdüşümü.
2. **Dik moloz yüzü** (> 56°): taban düz kalıyor, burun/topuk taşa giriyor (37o =trespass, 2 satır). Topuk-burun iki
   ışınla taban eğimi verilebilir (ışın ×2).
3. **Görünen ama çarpışmasız döşeme** (26'da sur içi döşeme ağı): ışın görmediği için IK kapalı; ayaklar o zemine kökün
   yüksekliğiyle (Rig'in eski yolu) basıyor — denetim de VISAUDIT gibi orayı zemin sayıyor.
4. **Uzaktakiler** (> 28 m, görüş dışı): eski yol; eğimde iki ayak aynı yükseklikte (AYAKAUDIT "uzak" satırları).
5. **Kalabalık (Crowd) çoklu ağ figürleri**: donmuş, pişmiş kopya: IK yok (tek ağ); kökleri yerleştirenin verdiği yerde.
6. **Koşuda basma**: kısa (0,25) ve kalça topuk/burun yuvarlanması için az iner; hızlı yokuş aşağı koşuda adımın
   uçlarında ayak 3–5 cm havada kalabiliyor (denetim penceresi dışında).
7. Keçi yokuşta (yukarıda).

## run_tests.sh isteği (yönetici için; dosyaya dokunulmadı)
Süzgece `AYAKAUDIT` eklenmesi önerisi (testi düşürmesin, bilgi): satırın biçimi
`AYAKAUDIT yakin|uzak scene=… who=… ayak=L|R fark=±… d=… at=… durum=… act=… ik=…`. Düşürmesi istenirse yalnız
`AYAKAUDIT yakin` satırları (kameraya ≤ 25 m) sayılmalı; uzaktakiler bilerek ucuz yolda.
Önerilen satır (run() içinde, VISAUDIT'in yanına): `grep -E "…|AYAKAUDIT yakin"`.

## Dokunulan dosyalar
`scripts/npc/ayak.gd` (yeni), `ayak_denet.gd` (yeni), `ayak_hayvan.gd` (yeni), `rig.gd` (kanca, kadans, bilek ek eğimi),
`limb_anim.gd` (kanca), `horse.gd`, `ox.gd`, `goat.gd`, `chicken.gd`, `cat.gd` (eğim düğümü, bacak açısına eğim);
`tests/_fizik/` (deney sahnesi, koşu/kare betikleri, kare aracı, tablo). `scripts/combat/` değişmedi (düellocu LimbAnim
kancasıyla geliyor). Çarpışma, yol, replik, ses, denge, sayaç değişmedi; `unclip.gd` ara sürümde değişip geri alındı.

## Notlar
- 10h'de bir koşuda (SONRA, ara sürüm) çökme: paralel süreçlerin ortak disk önbelleğine (`user://ist_onbellek/ev`)
  aynı anda yazması ("Unrecognized binary resource file"); tek başına iki kez PASS, son tabloda PASS. Kodla ilgisiz.
- Kalabalık pişirme önbelleği (`Crowd._cache_path`) rig.gd'nin içeriğiyle tuzlandığından ilk açılışta yeniden pişer.
