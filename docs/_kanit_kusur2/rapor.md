# Fragman kusurları 2 — yardımcı oturum raporu (wip/yardimci-kusur2)

Taban: `fe1ef427` (wip/yardimci-kusur). Godot 4.4.1, xvfb + yazılım çizimi. Değişen dosyalar: `scripts/interlude_edirne.gd`,
`scripts/chapter10b.gd`, `scripts/level/slipway.gd`. `chapter8y.gd` ve ortak dosyalara (npc/player/autoload/ui/stage) dokunulmadı.
Kare almak için konan kanca/sonda yok (`grep -rn "DBG\|BARK8" scripts/` boş); 8y probları yalnız /tmp'deki kopyada.
Replik metni/sırası, süre, sayaç, kalabalık sayısı, botun yolu değişmedi.

| # | Kusur | Durum |
|---|-------|-------|
| 1 | B17 Edirne: Vlad "Hayır, poliçe." sonrası arkasını dönüp geri dönüyor | **DÜZELDİ** (ÖNCE/SONRA kare dizisi) |
| 2 | B10b: Urban "...Hmm." kadrajın sağ kenarında, kol kesik | **DÜZELDİ** (ÖNCE/SONRA); diğer Urban anları taranıp sorunsuz |
| 3 | B2: kızak yolunun ortasında duran asker | **KISMEN** (işçinin kimliği çıkarımla; SONRA karesi var) |
| 4 | B8y: uyarı oku keçi repliğini kesiyor | **YENİDEN ÜRETİLDİ (probla), düzeltme önerisi aşağıda; dosyaya dokunulmadı** |

## 1. Vlad sıçraması — DÜZELDİ
**Yeniden üretim:** `PACE=1 xvfb-run … --chapter=17 --autotest=edirne_policy --dialogshots=… --shotevery=1 --snapevery=0.1`.
Kare dizisi `k1_edirne_vlad_once_sonra.jpg` (üst satır ÖNCE t2169-2174; alt SONRA t2206-2211, aynı an: D17E_T_POL_3 → D17E_V_POL_3).
ÖNCE'de replik biter bitmez Vlad sırtını/yan profilini dönüp (kütüğe) birkaç kare sonra geri dönüyor.
(Not: ÖNCE koşusu sürerken dosyayı düzenledim; Godot betiği koşu başında yüklediği için ÖNCE kareleri özgün kodla alındı.)
**Kök neden:** `interlude_edirne.gd` `_policy()` (eski satır ~1331): `vlad.face_toward(sheet.global_position)` anlık döndürüyor;
`Vlad.look_target` hâlâ oyuncu olduğundan `Person._process` (`person.gd:846-850`, `delta*4` lerp) onu ~8 karede geri çeviriyor;
ardından eski satır 1336 `face_toward(player)` tekrar anlık. Yani replik arasında "bakış hedefi" iki kez çelişiyor.
**Düzeltme:** `face_toward(sheet)` ve sondaki `face_toward(player)` kaldırıldı; `vlad.look_target = player` sabit (mühür vurma
oturduğu yerde, yüz konuştuğu kişide). SONRA'da Vlad'ın yüzü bütün karelerde Tolga'ya dönük.
**Öbür konuşmacılar:** aynı mekanizma (look_target doluyken `face_toward`) tek yerde daha: `_kebab()` Radu
`radu.face_toward(BRAZIER)` (eski satır 1181) → ~1 sn sıçrayıp geri dönüyordu; satır kaldırıldı. **KANITSIZ:** hiçbir autotest
varyantı kebap yolunu seçmiyor (`edirne_policy/none/legend`), ekranlı kare alınmadı. Mehmed (554/664/854/879) ve Gürânî (715) için
`face_toward` çağrısı ya look_target'ı sıfırladıktan sonra ya da hemen peşinden aynı hedefe verilerek yapılıyor: sıçrama yok (kodla).

## 2. Urban kadrajı — DÜZELDİ
**Yeniden üretim:** `--chapter=10b --autotest=boom` ekranlı. `k2_b10b_urban_once_sonra.jpg` (üst ÖNCE t0339-0344, alt SONRA t0345-0350):
ÖNCE'de "...Hmm." anında Tolga Fatih'e/yeşil-kırmızı ikiliye bakıyor, Urban ekranın sağ kenarında kolu kesik (4. kare: hiç görünmüyor).
**Kök neden:** `chapter10b.gd` `_explosion()` ilk satırı Urban'ı konuştururken oyuncunun bakışı öncekinden (Fatih) kalıyor.
**Düzeltme:** `_explosion()` başında `player.face(urban + 1.0 m)` (bölümde zaten her yerde kullanılan yardımcı; Urban/bot/çarpışma yerleri
değişmedi). SONRA'da Urban tam kadrajda ("...Hmm." karesi). Sonraki repliklerde mevcut `player.face(...)` çağrıları bakışı geri alıyor.
**Öbür Urban anları (boom koşusunda 18 replik karesi taranmış):** kalıp başında/arkasında Urban tam kadrajda ya da top yakın planında hiç
görünmüyor; kenarda kesik olan başka an yok.

## 3. Kızak işçisi — KISMEN
**Bulgu:** rayın üstünde duran tek canlı figür `Slipway._build_obstacles` "block" askerleri (s=47 şerit 2, s=80 şerit 0, s=114 şerit 1;
yeşil kaftanlı). Taranan diğer adaylar elendi: `Crowd` figürleri (iş kümeleri) parkurun ±5,6 m'sinde yok (geçici sonda), halat ekipleri
yolun kenarında, kadırga mürettebatı gemide. Kareler (ÖNCE, `--chapter=2 --autotest=perfect`): s=114'teki asker şeridin ortasında dimdik duruyor,
oyuncu yanından geçiyor, geçince bile yerinde ("ezilecek gibi"). Kök neden `slipway.gd` `_tick_track` blockers döngüsü: asker yalnız
kadırga 7 m'ye gelince sıçrıyor (`bow > s - 7`); oyuncu başka şeritten geçerken tepkisiz.
**Düzeltme (`slipway.gd` ~3018):** oyuncu 7 m kala ve başka şeritteyse (|dx| > 1,4 m; çarpışma yok) asker, mevcut `_leap_aside` ile oyuncudan
UZAK yana kızağın dışına sıçrıyor. Aynı şeritten gelen oyuncuda eski davranış (yakalama + tökezleme) aynen. Engel yerleşimi, `resolved`, sayaç, bot yolu aynı;
kalabalık sayısı değişmedi. Kare: `k3_b2_kizak_isci_once_sonra.jpg` (üst ÖNCE t0172-0181, alt SONRA aynı anlar): SONRA'da asker oyuncu varmadan
şeridin dışına çekiliyor. **Neden KISMEN:** işçinin kimliği kare+kodla çıkarım (kullanıcı hangi işçiyi kastettiğini söylemedi); s=47 ve s=80 askerlerini ayrıca karelemedim
(aynı kod yolu).

## 4. B8y Beyaz Havlu — yalnız inceleme (dosyaya dokunulmadı)
**Yeniden üretim (kopyada, /tmp/kusur2/wt):** doğal botla üretilemedi (bot çok hızlı: keçi yorumu `_queue`'da `z0 < pz-25` budanıyor; başsız
koşuda ekran altyazısı yok). Kopyaya yalnız prob koydum: keçi repliği + 0,6 sn sonra `_warn("run")` zorlandı, ekranlı `PACE=1`:
`BARK8 t=460.09 D8Y_T_GOAT int=false voice=false sub=true` → `t=461.33 D8Y_WALL_WARN_2 int=true voice=true sub=true`: uyarı, keçi sesi/altyazısı
1,2 sn sürerken `voice=true` iken kesiyor. Oyunda koşul: oyuncu keçiye <12 m, z ≥ 72 ve keçi repliğinin ilk saniyesinde koşuyor (koşu 0,35 sn sonra uyarı).
**Kök neden:** `chapter8y.gd:865` `_warn_lines`: `hud.bark(line[0], line[1], 3.6, true)` — `interrupt=true` (`hud.gd:2964`) devam eden barksesini
bekletmeden keser; keçi yorumu `chapter8y.gd:1261` `hud.bark("SPK_TOLGA", it[0], 4.5)` ile çalıyor, uyarı bunun bitmesini beklemiyor.
**En küçük düzeltme önerisi** (metin/akışa dokunmaz; Tolga'nın hikâye yorumları uyarı süresince bekler, atmosfer repliklerini kesmeye devam):
```gdscript
# chapter8y.gd: değişken
var _yorum_until := 0.0
# _events(): hud.bark("SPK_TOLGA", it[0], 4.5) satırından hemen sonra
_yorum_until = Time.get_ticks_msec() / 1000.0 + 4.5
# _warn_lines():
func _warn_lines(line: Array, answer: Array) -> void:
	while Time.get_ticks_msec() / 1000.0 < _yorum_until and hud.is_talking() and phase == "field":
		await get_tree().process_frame      # keçi/hikâye yorumu bitene dek ertele (ok yine saplanır, söz sonra gelir)
	hud.bark(line[0], line[1], 3.6, true)
	...
```
(Ok `_shoot_arrow` ayrı çalıştığı için görsel uyarı gecikmez; yalnız söz ertelenir.)

## Testler (hepsi tek koşuda, `--headless --max-fps 20`, kötü satırlar: SCRIPT ERROR, WARN_FX_STUCK, WARN_FLY_ITEM, VISAUDIT,
WARN_VOID_TELEPORT, WALKTHRU, ARMAUDIT, HELDAUDIT, JOURNEY_MISS, JOURNEY_OVERLAP — hiçbiri çıkmadı)
- `parse_check`: PARSECHECK PASS scripts=247
- Bölüm 17: 13/13 AUTOTEST PASS (`""`, two, fall, nophoto, chain, ship_ok, ship_bad, lost, edirne_policy, edirne_none, edirne_legend(--bag), osm, route)
- Bölüm 10b: 8/8 PASS (`""`, eye, boom, untaped, tape, ulighter, cube, next)
- Bölüm 2: 8 varyant × 2 = 16/16 PASS (`""`, perfect, chain, chainfail, red, swimshore, swimchain, next)
Ham günlük: `/tmp/kusur2/suite.log` (depoda değil).

## Ortak dosya önerileri
Gerekmedi. (Kök neden Kusur 1'de bir kez daha: `Person.face_toward` look_target doluyken anlık dönüş bırakıp lerp ile geri alınıyor;
kalıcı çözüm `face_toward` içinde `look_target`'ı yok saymak değil, sahne betiğinde look_target'ı yönetmek — `person.gd` değişmedi.)

## Kanıt paftaları
`k1_edirne_vlad_once_sonra.jpg`, `k2_b10b_urban_once_sonra.jpg`, `k3_b2_kizak_isci_once_sonra.jpg` (JPEG, hepsi ≤ 300 KB).
