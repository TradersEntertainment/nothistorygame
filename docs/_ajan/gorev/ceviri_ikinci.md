# Çeviri taraması: İKİNCİ OKUMA + DENETİM (bağımsız; ilk turu yazan sen değilsin)

Önce oku: `docs/_ajan/gorev/ceviri_tarama.md` (kurallar aynı), `docs/_ajan/gorev/_yazim_kurali.md`, `docs/EVREN.md`.
İlk tur 14 dilimi beşer dakikada bitirdi (toplam 415 öneri). Öneriler iyi görünüyor ama bu hızda her satır sahnesinde
okunmuş olamaz. Senin işin iki parça; ikisi de senin dilim grubun için (grubun oturum isteminde yazıyor).

İlk turun teslimleri: her dilim kendi dalında: `git fetch origin wip/ceviri-<N>:refs/remotes/origin/wip/ceviri-<N>` sonra
`git show origin/wip/ceviri-<N>:docs/_ceviri/dilim_<N>.csv` ve `…/dilim_<N>_rapor.md`.

## A. İlk turun her önerisini DENETLE (hata bul; yanlış "uygun" tek kabul edilmeyen şeydir)
Her öneri için repliği geçtiği betikte komşularıyla oku (`grep -rn "ANAHTAR" scripts/ tests/`) ve karar ver:
- `kabul`: yenisi gerçekten daha yerli, işlev ve bilgi aynı, bağlı replikler bozulmuyor, uzunluk %70–130, konuşmacının
  sesi doğru, seslendirilebilir.
- `duzelt`: yön doğru ama yeni metin kusurlu (fazla argo/yazım: altyazıda "di mi" gibi yazımlar yerine "değil mi";
  karaktere uymayan deyim: Rum/Latin karakterin ağzında "Allah razı olsun" gibi; anakronizm; şaka kaçmış; uzun): kendi
  düzeltilmiş metnini yaz.
- `ret`: eskisi zaten iyiydi, ya da yenisi işlevi/bilgiyi/şakayı/geri dönen sözü bozuyor, ya da bilerek yapılmış bir
  şakayı "düzeltiyor" (ör. totoloji, karakterin bozuk Türkçesi, resmî dil şakası). Gerekçesini yaz.
Ayrıca: aynı repliğin VARYANTLARI (`_NOFEZ`, `_HEN`, `_ALT`, `_B`, `_PLAIN`, `_WET`…) ve repliği aynen alıntılayan
seçenek/arayüz metinleri (`UI_CH…`) birlikte değişiyor mu? Değişmeyeni sen ekle. Testlerin metne baktığı yer var mı
(`grep -rn "eski metnin ayırt edici parçası" tests/ scripts/`): varsa yaz.

## B. İKİNCİ OKUMA: dokunulmamış satırlar, SATIR SATIR, kapsam kaydıyla
Grubundaki dilimlerin BÜTÜN satırları için (ilk turun dokunmadıkları dahil) bir kapsam dosyası tut:
`docs/_ceviri/kapsam_<GRUP>.csv`: `anahtar,dil,hukum` (hukum: `iyi` / `oneri` / `supheli`); her anahtar için tr ve en
ayrı satır (en boşsa atla). Satırları 50'lik öbekler hâlinde işle; her öbekten sonra kapsam dosyasını kaydet. Kapsam
dosyasında grubunun satır sayısı × 2'ye yakın satır olmalı; eksikse iş bitmemiştir.
İlk turun kaçırdığı çeviri kokan replikler için yeni öneri yaz (aynı ölçütler; "her şeyi iyileştireyim" yok; şiddet 1
olanları ancak gerçekten kulak tırmalıyorsa). Özellikle bak: "Belki …-meli" (maybe they should), "…, değil mi?"
(isn't it) yığılması, "Endişelenme", "Bu … hakkında değil", "…-mek zorunda değilsin", "ne demek istediğimi biliyorsun",
"iyi iş", "sorun değil", "üzgünüm" (özür yerine), "tebrikler" (alay olarak), "tahmin et ne oldu", "sonunda!", "aman
Tanrım", "ciddi misin", "bu çılgınca", "harika", "kesinlikle", "tam olarak", "aslında", "sadece", "gerçekten" dolguları,
"bir şey yapmak" kalıpları ("bir yürüyüş yap", "bir konuşma yap"), "sahip olmak" ("bir fikrim var" yerine "bir fikre
sahibim"), "tarafından" edilgenleri, özne zamirinin gereksiz tekrarı, İngilizce noktalama alışkanlıkları.
İngilizce sütunda: Türkçe deyimin harfiyen çevirisi, Türkçe söz dizimi, "my lion/my brother/my soul" hitapları,
"May it be easy", "health to your hands", "it happened to pass" türü kalıplar, espri İngilizcede çalışmıyor.

## Teslim (oyun dosyalarına DOKUNMA)
- `docs/_ceviri/onay_<GRUP>.csv`: `anahtar,konusmaci,dil,eski,yeni,neden,siddet,bagli,islev,kaynak,karar,denetci_notu`
  (`kaynak`: `ilk` = ilk turun önerisi, `ikinci` = senin yeni önerin; `karar`: kabul / duzelt / ret; `duzelt` ise `yeni`
  sütununda SENİN son metnin, `denetci_notu`nda ilk turun metni ve neden değiştirdiğin). Uygulanacak son liste budur:
  `kabul` + `duzelt` satırları oyuna girecek.
- `docs/_ceviri/kapsam_<GRUP>.csv` (yukarıda).
- `docs/_ceviri/onay_<GRUP>_rapor.md`: ilk turdan kaç kabul / düzelt / ret (ret gerekçeleriyle), ikinci okumada kaç yeni
  öneri (dilime göre), okunan satır sayısı (kapsam dosyasından), varyant/alıntı eşlemeleri, metne bakan testler,
  sahibine sorulacaklar (en çok on), en iyi on önce | sonra.
- Her 30 dakikada ara kayıt; kapsam dosyası tamamlanmadan durma. Dalın: `wip/ceviri-onay-<GRUP>`.
