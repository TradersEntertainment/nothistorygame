# Replik MESAFE haritası (seslendirme için): kim, kime, ne kadar uzaktan söylüyor?

Sahibin sözü (12 Kasım, yeni ses denemelerini dinleyince): "Attığın sesler hep aynı tonda. Bağırması lazım uzağa;
yakındayken normal konuşması lazım." Seslendirme motoruna her replik için doğru okuma yönergesi verebilmek için her
seslendirilen repliğin MESAFE/ŞİDDET sınıfı gerekiyor. `docs/voice/VOICE_MAP.csv`'deki `ton` sütunundaki `[shouting]`
"yüksek ses" demek; mesafe demek değil ve eksik. Senin işin bunu sahneye bakarak doğru çıkarmak.

Dilimin: `python3 docs/_ajan/gorev/ceviri_dilim.py N [a|b]` çıktısındaki satırlardan KONUŞMACISI DOLU olanlar
(ikinci sütun `SPK_…`; boş olanlar arayüz metni, atla). Grubun oturum isteminde.

Her replik için betikte geçtiği yeri bul (`grep -rn "ANAHTAR" scripts/`) ve çevresini oku: konuşan nerede duruyor
(surun üstü, gemi, karşı kıyı, kule, çadırın içi, oyuncunun yanı), `hud.say` mi `hud.bark` mı, konuşana `afar`/`cameo`
işareti verilmiş mi, o an savaş/top/kalabalık gürültüsü var mı, konuşan oyuncuya mı başkasına mı sesleniyor, telsiz/
kulaklık mı, Tolga'nın iç sesi mi. Sonra sınıfla:
- `uzak`: konuşan dinleyene yaklaşık 8 m'den uzak ya da arada engel var (surdan aşağı, gemiden gemiye, meydanın öbür
  ucu, kuleden): GERÇEKTEN BAĞIRIR, sesi taşır.
- `yakin_yuksek`: yanında ama sesini yükseltir: emir, öfke, panik, savaş/top gürültüsünü bastırma, kalabalığa hitap.
- `yakin`: yanındakine NORMAL konuşma sesiyle (ünlem olsa da bağırmaz).
- `fisilti`: gizlenerek, kulağa, nöbetçi duymasın diye.
- `telsiz`: kulaklık/telsiz/telefon üzerinden (Hikmet, Nihat, Müfide…): mikrofona yakın, normal ses; heyecanlansa da
  bağırmaz (cızırtıyı oyun ekler).
- `ic_ses`: Tolga'nın kendi kendine söylediği / anlatı (kimseye seslenmiyor): alçak, kendi kendine.
- `seslenme_kendi`: Tolga'nın birine uzaktan seslendiği replikler `uzak` sayılır; yanındakine konuştuğu `yakin`.
Aynı anahtar birden çok yerde farklı mesafede kullanılıyorsa en sık/ilk kullanımı al ve `not`a yaz. Bulamadıysan
(`kod`da dolaylı kullanılıyor: tablo, sözlük, döngü) tabloyu/sözlüğü izle; yine bulunamazsa `belirsiz` + neden.

Teslim: `docs/voice/_mesafe/mesafe_<GRUP>.csv`: `anahtar,konusmaci,mesafe,metre,kanit,not` (`metre`: tahmini uzaklık,
bilinmiyorsa boş; `kanit`: `dosya:satır` + üç beş kelime, ör. "chapter4.gd:212 surdan, oyuncu zincirde, bark").
`docs/voice/_mesafe/mesafe_<GRUP>_rapor.md`: sınıf sayıları, `ton` sütunuyla çelişenler (ör. `[shouting]` ama yakın
ve sakin; etiketsiz ama surdan sesleniyor) listesi, belirsizler.
Her 100 replikte ara kayıt gönder. Oyun dosyalarına DOKUNMA (VOICE_MAP.csv dahil). Dalın: `wip/mesafe-<GRUP>`.
