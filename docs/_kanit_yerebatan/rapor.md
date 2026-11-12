# Bölüm 44 — Sarnıç (Yerebatan) · rapor

Dal: `wip/bolum-yerebatan`. Tasarım ve araştırma: `docs/BOLUM_YEREBATAN.md` (ilk teslim, kaynaklı).
Sahibin isteği: "hem manzara hayranlık yaratsın hem de heyecanlı bi bölüm olsun"; "ne bizans ne osmanlı bilmiyordu …
tolga kazara bulacak ya da halktan birisi bir şey isterken ona yardım ederken oraya varacak".

## 1. Araştırma notu (özet; tablo ve kaynaklar `docs/BOLUM_YEREBATAN.md` §1)

- **Kesin (birincil kaynak):** Gyllius, *De Topographia Constantinopoleos* II.20 (J. Ball çevirisi, 1729, Project Gutenberg
  #53083): "Ahali, içine açılmış kuyulardan her gün su çektiği hâlde ondan en küçük bir şüphe duymuyordu"; "üstü
  tamamen evlerle kaplıydı"; tesadüfen girdiği bir evden inip küçük bir kayığa biner, ev sahibi meşale yakıp onu
  sütunların arasında küreklerken balık zıpkınlar; "kuyunun ağzından inen küçük bir ışık suya vurur, balıklar hava
  almaya oraya gelir"; 336 sütun, 12 sıra × 28; başlıkların bir kısmı Korint, bir kısmı işlenmemiş; her başlığın üstünde
  ikinci bir yastık taşı; kışın büyük bir borudan gürültüyle dolar.
- **Tutarlı:** Iustinianus, Stoa Basilika'nın altı; ~138 × 65 m, ~80.000 m³, sütun ~9 m (İBB, Kültür Bakanlığı,
  Wikipedia). Medusa başları kuzeybatı köşede iki sütunun kaidesi; 1985–87 İBB temizliğinde 50.000 ton çamur
  çıkarılırken ortaya çıktılar (Milliyet/C. Sadiç; İBB Atatürk Kitaplığı). 1723 III. Ahmed onarımı.
- **Çelişkili / BELİRSİZ:** yapım yılı (527–542); su yolu (Valens kemeri mi, Hadrianus su yolu mu); fetihten sonra
  Topkapı bahçelerine su verdiği (kaynaksız siteler) ile "yerlilerden başka herkesçe unutuldu" (Tonguç & Yale) /
  Gyllius'un "kimse bilmiyordu"su; Gyllius'un keşif yılı (1544, 1545, 1544–47). 1453'te sarnıcı kimin bildiğine dair
  doğrudan kaynak YOK: oyunun "unutulmuş" kurgusu Gyllius'tan geriye çıkarımdır.
- **Uydurma (oyun için, böyle işaretli):** Eudokia, Yakovos ve "cin"; 26 Mayıs'ta sarsıntıyla tuğla düşmesi;
  sarnıçtaki su düzeyi (2,2 m); Medusa'ların suyun ~0,7 m altında görülebilmesi (gerçekte çamura gömülüydüler).

## 2. Tasarım kararları

| Karar | Ne yapıldı | Neden |
|---|---|---|
| Yer | Kimlik 44, `chapter44b` (yalnız Bizans), `Siege.ORDER`'da 43'ün ardı: Bizans sırası 24 → 44 → 25 | 24'ün seli kuyuları taşırdı (balık bahanesi); 24 ve 25 Ayasofya çevresinde; takvim 25 → 26 → 27 Mayıs |
| Giriş | Eudokia'nın kuyusu: "selden beri kovam balıkla çıkıyor, cin var"; Tolga ipe tutunur, ip kopar | Sahibin "halktan birine yardım ederken / kazara" isteği ikisi birden |
| Kulaktaki ses | Hikmet değil Nihat | Kanonda Perde IV zamanın dışında; hiçbir kuşatma sayfasında Hikmet konuşmaz (sahibinin kararına açık) |
| Hayranlık anı | Karanlık → fener (F) → ortam ışığı 2,5 sn'de açılır, müzik "tender"; denetim oyuncuda, kamera çevrilmez | Görevdeki "oyuncu durup bakmalı" |
| Heyecan | Kürek ritmi + dümen, ışık bütçesi (pil %14, çakmak 6 sn), toz-halka uyarılı düşen tuğlalar, kemer çöküşü (meşale söner), süre (95 sn) | Var olan düzenekler: RowMeter/OarGrip (17), set_chase, TespitCam |
| Sonuçlar | 44.1 sırrı korudu · 44.2 ağzından kaçırdı (Paradoks +5) · `cistern_rescued` (süre doldu, Yakovos çekti) | "Keşif SIR kalmalı" ekseni; başarısızlık oyunu kesmez |
| Etkiler | Bölüm 25 son ayin: Eudokia'nın tek repliği (44.1/44.2); Bölüm 15 İnsanların Akıbeti: Yakovos (Gyllius izi / taşla doldurulmuş kuyu); `ACH_CISTERN` | `tests/check_outcomes.py` iki sonucun da okunduğunu doğrular |
| Konuşmacılar | Eudokia `SPK_WOMAN_BYZ`, Yakovos `SPK_FISHMONGER`, Marco `SPK_KID`, komşu `SPK_TOWNSMAN` | Yeni ses kimliği/portre açmamak için var olanlar |

## 3. Teslim edilenler (dosyalar)

(aşağıda doldurulacak)
