# Tırmanma denetimi — ARA KAYIT 1 (devam ediyor)

Denetçi koşusu: Godot 4.4.1, xvfb 1280×720, `--rendering-driver opengl3`, `PACE=1`, `-s tests/_tmp_denetim/probe.gd` (kayda eklenmedi).
Oyun dosyalarına dokunulmadı. Bu kayıt yalnız 38o oyuncu kamerası karelerini içerir; sürüm hükmü sonraki kayıtta.

## 38o — tutma evresi, oyuncu kamerası, 0,6–0,7 sn arayla 8 kare (`p01_38o_oyuncu_8kare.jpg`, tekil: `k38o_oyuncu_00..07.jpg`)
Günlük: probe_log START t=51,98; kareler t=52,11 … 56,78 (≈0,66 sn aralık), tutma sayacı 45→42 sn.
- k00: tutma henüz başlamadı (güvertede replik, tayfalar görünmüyor).
- k01: iki tayfa merdivenin en üst ucunda, mazgal siperinin hizasında. Üstteki (bordo) öne eğik, bacakları merdivende; ayaklar basamaklarda görünüyor (yakın kesit `p02`, sol üst). Eller kadrajda DEĞİL (gövdenin arkasında/üstte), seçilemiyor. Boşlukta asılı uzuv yok. Ucun üstünde havada duran yok (kalça siper hizasında).
- k02–k07: tayfalar "2 · MERDİVENİN AYAĞINI TUT" bandının ARKASINDA, yalnız bacak/ayak uçları seçiliyor (baş-gövde bandın altında). Ayaklar basamakta gibi, ama bu karelerde el ve gövde değerlendirilemez. Kareler arası hareket: 6 karede (≈4 sn) belirgin yükselme yok; tayfa tepede bekliyor (üstteki zaten tepenin iki basamak altında).
- Dürüst hüküm (ara): "gökyüzüne/boşluğa tırmanıyor" izlenimi k01'de YOK (basamaklarda, merdivene yaslı); ama 6 karede okunmuyor çünkü görev bandı tayfayı kapatıyor (rapor 3 zaten bildirmişti; bant HUD'un işi). Alt tayfa bu karelerde görünmüyor ya da üsttekinin arkasında.
- Not: tayfa t=52'de başlangıçta zaten merdivenin tepesinde; "3,5 m'den başla" beklentisi oyuncu bakışından görünmüyor (merdiven bakış çizgisine paralel).

---
# ARA KAYIT 2 — yandan (sonda kamerası) kareler

Yöntem: `tests/_tmp_denetim/probe.gd` (kayda eklenmedi) oyunu kendi ana döngüsünden açar, tırmanış başlayınca `Engine.time_scale=0,25` ile
her karede (≈0,1 oyun sn) 1280×720 kare alır; yan kamera tırmananın merdiven yerelinde (`_r` yönünde 4,2 m, HUD gizli). Ham günlük satırları (`probe_log`) için kareler `k_*` adlarıyla.
Her pafta içindeki kare numarası `side_NN`; 00 numaralı kare her koşuda oyuncu kamerasıdır (sonda henüz kamerayı almamış) — tırmanış karesi sayılmaz.

## 38o — yan, 11 kare (`p03_38o_yandan_12kare_sonda.jpg`, `k_38o_side_01..11.jpg`), günlük: s=9,30→10,00, 1 adım ≈1,4 sn
Tüm karelerde (01–11): ellerden biri basamakta/dikmede (kare 05, 07, 08: sağ el bir üst basamağa uzanmış; 01–03, 09–11: dikme/basamak üstünde); diz bükük, ayak basamağın üstünde (01, 04, 06 net); gövde yatık merdivene yaslı, göğüs ile merdiven arası dar; boşlukta asılı uzuv yok; merdivenin ucundan yukarıda havada duran yok (tayfa orta boyda, ucun çok altında); uzuv gövdeden geçmiyor (kollar gövde önünde); dirsek/diz ters kırılmıyor. Kareler arası sıçrama yok (konum her karede ≤0,09 m, günlük `who=`). Börk 08–11'de hafif öne devriliyor, dikmeye değip değmediği seçilemiyor. Yok olma/belirme yok. Merdiven sallanması bu pencerede ≈0 (ibre sabit) → "sallanınca birlikte döner" bu karelerde KANITSIZ.
HÜKÜM: bu kamera açısından "boşluğa tırmanma" yok; gerçekten merdivende.

## 20 hücum (assault) — yan, 10 kare (`p05_20_hucum_yandan_11kare.jpg`)
Üstteki asker (kahverengi kaftan, günlük s=10,8→12,9) 01–10'da: baş ve omuz merdiven dikmesinde, gövde merdivene yaslı, alttaki sarıklı yalnız baş+kol görünüyor (2 asker aynı merdivende, ≈0,8 m görünüş aralığı). **Kaftan etek bacakları ve ayakları tamamen örtüyor: ayakların basamakta olup olmadığı KARELERDE SEÇİLMİYOR (KANITSIZ).** El: yalnız bir el dikmede seçiliyor, öbürü gövdenin arkasında. Kamera orta-yakın; tırmananın bacağı ve basamak teması denetim ölçüsüyle (CLIMBAUDIT 0) doğrulanıyor, gözle değil.
Oyuncu kamerası 20'de (`p09_...`): tırmanan yok; oyuncu bot ok sandığı peşinde, kare tırmanışı kapsamıyor → **oyuncu bakışından hücum tırmanışı KANITSIZ**.

## 30o (Blakherna arka plan tırmananı; azap/peek DEĞİL) — yan, 11 kare (`p04_30o_blakherna_arkaplan_yandan_12kare.jpg`)
Fesli tırmanan: sol/sağ el dikme ve basamakta (02, 05, 07, 10 net uzanma), dizler bükük, ayaklar basamakta, gövde yatık merdivene yaslı; hareket akıcı. En iyi kareler bunlar. 30o'nun kendi geç kalan azabı (`peek`) ve 30 askeri bu koşuda yakalanmadı (günlük `tag=blachernae`; `tag=30o` hiç belirmedi) → **peek KANITSIZ**. 30 (`s30_side`): yalnız `tag=blachernae` arka plan; bölümün kendi askeri yakalanmadı → **KANITSIZ**.

## 42b — yan, 11 kare (`p06_42b_gonullu_yandan_12kare.jpg`)
Beyaz önlüklü gönüllü: sol el basamakta üst, sağ el dikmede (02, 04, 08 uzanmış), bacak bükük, ayak basamakta (06, 07, 11 net), gövde merdivene yaslı. Boşlukta asılı uzuv yok; hareket akıcı. Önceki raporun "42b KANITSIZ (üstten)" yan karede doğrulandı.

## 33o — yan, 4 kare (`p07_33o_isci_yandan_4kare.jpg`)
Tırmanan işçi iskele kafesinin ardında kısmen kapalı, merdiven üstünde yaslı görünüyor; hedef 4. karede bitti (1,2 sn). Ayak/el ayrıntısı seçilmiyor → **KISMEN/KANITSIZ**.

## Oyuncunun kendi tırmanışı (`p08_oyuncu_kendi_tirmanisi_8kare.jpg`, `tests/ladder_test.tscn`)
Ana oyun yerine merdiven test sahnesi (bot tırmanıyor). 8 karede yalnız SOL kol kadrajda (diğeri kadrajın altında); sol el her karede bir basamağın üstünde/hizasında, bir üst basamağa yükseliyor. Sağ el hiç görünmüyor (önceki raporun "bir el kadrajın altında" notu doğrulandı: KISMEN).
