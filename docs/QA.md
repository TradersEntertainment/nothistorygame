# Kalite denetimleri

Oyun testlerinde tek tek görülen hatalar birer "sınıf"a indirgendi; her sınıf için ya oyunun kendisinde
genel bir önlem ya da otomatik bir denetim var. Yeni bölüm yazarken bunlar kendiliğinden devreye girer.

| Hata sınıfı | Örnek | Genel önlem | Denetim |
|---|---|---|---|
| Kara/beyaz ekranda konuşma | 1977 düğünü bembeyaz, zindan ve mutfak karanlıkta | Karanlıkta telsiz repliği otomatik telsiz kartı gösterir | `WARN_SAY_ON_FADE` (tests/run_tests.sh çıktısı) |
| Asılı kalan ipucu | Denize düşünce "A/D" yazısı hücrede kaldı | Kararma ve kartta istem/QTE/kovalama/kırmızı çubuk temizlenir | — |
| Kontrol verilince yön/hedef yok | Surlara girince duvara dönük, ne yapacağı belli değil | Kararmadan sonra ilk serbest anda duvara bakıyorsa hedefe döner | `WARN_FREE_NO_OBJECTIVE` |
| Replikte geçen eşya görünmüyor | "Kartvizitim", "Buyurun çay", "Rubik küpünü çıkarır" | `Hud.LINE_PROPS` → `Player.show_prop()` | Yeni replikte eşya geçiyorsa tabloya ekle |
| Oyuncu sormadan eşya kullanılıyor | Giustiniani'ye kitap "gösterilmiş" | Çantadaki eşya repliği seçimle bağlanır | `grep -A2 "in GameState.bag"` |
| Yapılmamış şeyi anan replik | Açılmamış mühür "kırık", T'yi bilen Nihat "merak ederim" | Replik bayrağa bağlı (`_trace_key`, `_z1_key`), soğuk iz kanıt anlatmaz | — |
| Karakter eğik | Nihat arşivde yatık yürüyor | `face_toward()` (yalnız yatay); biri takip edilirken dikleşir | — |
| Karakter nesnenin içinde | Kadri tezgâhta, çadırlar geçilebilir | `Unclip.settle` en yakın boş noktaya kaydırır, çadırlar katı | `tests/_tmp/overlap.gd` |
| Ses tutarsızlığı | Hikmet'in sesi bir replikte gençleşiyor | Seviye düzeltme tablosu (`VoiceGain`), mekân yankısı (`Audio.voice_space`) | `tools/voice_consistency.py`, `tools/voice_asr_check.py` |
| Elle yazılmış sayılar | "13 final" | `Achievements.FINALS_TOTAL` tek kaynak | — |
| Fark edilmeden dala girme | Theodoros'u kabul edip fetih günlerini kaçırmak | İşaret ana yolu gösterir, dal teklifleri onay ister | — |
| Takılma (sonsuz bekleme) | Tutulma, gemi | Bekleme süreye/geçişe bağlı | Oynanış |
| Dünyanın dışına düşme | Ordugâh kenarında tepelerin içinden aşağı, iç sur kapısının geçidi, lağım kuyusunun yanları | Görünmez sınır / zemin | `tests/reach_check.gd` (her hedef evresinde yürünebilir alanın haritası; `voids` 0 olmalı) |
| Oyuncunun içinden geçen kişi | Yürüyen halk kameranın içine giriyordu; oyuncu da herkesin içinden yürüyordu | Walker oyuncudan kaçar; oyuncu kişilerden yumuşakça itilir (`Player._separate_from_persons`) | `tests/visual_tour.gd` |
| HUD öğeleri üst üste | Seçenekler konuşanın yüzünde, göstergeler hedef kutusunda, uzun hedef sağ üst ipucunda, kürek göstergesi altyazıda | Seçenekler altta; göstergeler hedefin altında; hedef 540 px'de bölünür | `tests/visual_tour.gd` (her hedefte ve her 4. replikte kare) |
| Metni yazılmamış replik | `D21O_T_FACE` ekranda anahtar olarak görünüyordu | — | `python3 tests/check_keys.py` |
