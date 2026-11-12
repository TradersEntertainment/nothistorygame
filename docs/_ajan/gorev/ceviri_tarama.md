# Çeviri kokusu taraması: bütün oyun metni (YAZAR oturumları)

Sahibin sözü (12 Kasım): "Türkçe esprilere falan dikkat et, translate olduğu belli olmasın. Türkçeye Türkçe düşün,
İngilizceye İngilizce düşün." ve ardından: **"tüm metni ara, oyunun içindeki çevirme gibi duran replikleri düzelt."**
Bu, "var olan replik metni değişmez" kuralının sahibi tarafından BU İŞ İÇİN kaldırılmasıdır: yalnız çeviri kokan
replikler, yalnız bu kurala göre.

Önce oku: `docs/_ajan/gorev/_yazim_kurali.md` (bağlayıcı), `docs/EVREN.md` (canon, karakter sesleri), `docs/NIKO_YENIDEN.md`
varsa (teşhis örneği; `wip/niko-yeniden` dalında).

## Senin dilimin
`python3 docs/_ajan/gorev/ceviri_dilim.py N [a|b]` → dilimindeki satırlar: anahtar, konuşmacı, Türkçe, İngilizce (sekmeli).
Dilim numaran (ve varsa yarın) oturum isteminde yazıyor. Başka dilime dokunma.

## Ne aranıyor
**Türkçe sütunda:** İngilizce düşünülüp çevrilmiş gibi duran replik: İngilizce söz dizimi ("Bu, ... olan şeydir"),
Türkçede kimsenin demeyeceği kalıp ("iyi bir gün geçir", "bunu yapabilirsin", "ne bekliyordun ki"nin kelime kelime
hâlleri), İngilizce espri iskeletinin Türkçe kelimelerle doldurulması (kelime oyunu İngilizcede işliyor, Türkçede
işlemiyor), gereksiz özne/iyelik ("senin elin", "benim kılıcım" her cümlede), edilgen yığılması, "-mekte/-maktadır"
resmîliği konuşmada, "sadece/gerçekten/aslında/kesinlikle" dolgu zarfları, ünlem ve hitabın İngilizce yerinde durması,
deyimin çevirisi ("kedi çantadan çıktı" türü), bilinen film/skeç repliği uyarlaması. Arayüz metinlerinde: "X'i etkinleştir",
"Devam etmek için ... basın" gibi yazılım çevirisi kalıpları (oyunun kendi sıcak diline çekilir).
**İngilizce sütunda:** Türkçenin kelime kelime çevirisi olduğu belli olan, İngilizcede espri olarak çalışmayan ya da
kimsenin demeyeceği replik (Türkçe deyimin harfiyen çevirisi, Türkçe söz dizimi, hitapların çevirisi "my brother"/
"my lion" türü). İngilizce karşılık, aynı işi gören İngilizce düşünülmüş replikle değiştirilir.

## Ne ARANMIYOR (dokunma)
- İyi duran replik. Beklenen oran dilime göre %5–20; "her şeyi biraz iyileştireyim" YOK. Emin değilsen dokunma, `supheli`
  diye listele.
- Tolga'nın plaza/sigorta jargonu ve bilerek kullandığı İngilizce kelimeler ("agresif zaman çizelgesi", "risk azaltıcı
  önlem", "CV"): karakter gereği, çeviri kokusu değil. Nihat'ın resmî daire dili, Urban'ın bozuk Türkçesi, Giustiniani'nin
  tüccar ağzı, [Yunanca]/[Macarca] gibi köşeli sahne etiketleri, parantez içi sahne notları: aynen kalır.
- Özel adlar, tarihler, sayılar, eşya adları, arayüz tuş adları, yer tutucular (`%s`, `%d`, `{0}`, BBCode).

## Yeniden yazarken
- Anahtar değişmez. Replik oyundaki İŞİNİ görmeye devam eder: yön veriyorsa aynı yönü verir, bilgi veriyorsa aynı
  bilgiyi, bir sonraki repliğin cevap verdiği sözü (ör. Tolga "Hektor kim?!" diyorsa önceki replikte Hektor geçer)
  taşır. Bunun için repliğin geçtiği betiğe bak (`grep -rn "ANAHTAR" scripts/`) ve komşu repliklerle birlikte oku;
  karşılıklı espriler, tekrar eden şakalar (running gag), başka bölümden geri dönen sözler bozulmaz. Bir repliği
  düzeltmek komşusunu da değiştirmeyi gerektiriyorsa ikisini birlikte öner ve `bagli` sütununa yaz.
- Uzunluk eskisinin %70–130'u (seslendirme süresi ve altyazı kutusu); süreli/oynanış sırasında çalan kısa replikler
  (bark) kısalabilir, uzayamaz.
- Konuşmacının sesi korunur (EVREN ve o karakterin öbür replikleri ölçü).
- Seslendirilebilir kalır: yeni rakam, kısaltma, parantez içi not eklenmez.

## Teslim (oyun dosyalarına DOKUNMA: `i18n/strings.csv`, `VOICE_MAP.csv`, betikler değişmez)
`docs/_ceviri/dilim_<N>[a|b].csv` (UTF-8, başlıklı, virgüllü, çift tırnaklı):
`anahtar,konusmaci,dil,eski,yeni,neden,siddet,bagli,islev`
- `dil`: `tr` ya da `en` (aynı anahtar iki dilde de düzeltilecekse iki satır).
- `neden`: bir cümle: hangi çeviri izi, yenisi neden yerli.
- `siddet`: 3 = açıkça çeviri/ödünç, herkes fark eder · 2 = kulak tırmalıyor · 1 = küçük pürüz.
- `bagli`: birlikte değişmesi gereken ya da bu repliğe cevap veren anahtarlar (yoksa boş).
- `islev`: repliğin oyundaki işi, iki üç kelime (yön, bilgi, şaka, tepki, arayüz…).
`docs/_ceviri/dilim_<N>[a|b]_rapor.md`: kaç satır okundu, kaç tr / kaç en düzeltme önerildi (şiddete göre), en iyi on
önce | sonra örneği, `supheli` listesi (dokunmadıkların, sahibine sorulabilir), dokunmadığın ama komşusu değişen
replikler, genel gözlemler (bu dilimde hangi karakter/bölüm en çok çeviri kokuyor).
İlk 20 dakikada ilk 15–20 düzeltmeyi içeren CSV'yi gönder (yönetici ayarı sahibine gösterecek); sonra her 30 dakikada.
Dalın: `wip/ceviri-<N>[a|b]`.
