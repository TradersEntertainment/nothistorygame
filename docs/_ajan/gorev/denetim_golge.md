# Bağımsız denetim: oyuncunun gölge gövdesi — DENETÇİ

Önce `docs/_ajan/gorev/_ortak2.md` dosyasını oku ve uy. Rapor dalın: `wip/denetim-golge`, klasör `docs/_kanit_denetim_golge/`.
Geliştirici raporu: `docs/_ajan/rapor/golge.md`. Denetlenen dosyalar: `scripts/player/shadow_body.gd` (yeni),
`scripts/player/player.gd` (`git diff e551de84 -- scripts/player/player.gd`).

Sahibin şikâyeti: Bölüm 8y'de beyaz havluyla yürürken yerde yalnız sırığın/bayrağın gölgesi vardı, adamın gölgesi yoktu
("gölgede sadece bayrak var"). İstenen: oyunun her yerinde oyuncunun kendi gölgesi; eşya gölgesi gövdeye bağlı görünsün.

## Sına (kendi ÖNCE | SONRA karelerinle; ÖNCE = iki dosya e551de84 hâlinde, depo dışı kopyada)
1. 8y havlu yürüyüşü (sahibin anı): güneş arkadayken ve yandayken adam + kol + sırık gölgesi tek parça mı? Kopukluk,
   havada duran kol, sırığa uzanmayan el var mı?
2. Karakterler: Tolga (fesli / fessiz / kaftanlı), Nihat (fötrlü; görünmezken gölge YOK olmalı; uçarken yere düşen
   gölge), Hikmet oynanan bölüm varsa.
3. Duruşlar: ayakta, yürürken (bacak salınımı), koşarken, çömelme, oturma (kayık 17/19, at arabası, sandalye), tekme,
   iki elle taşıma (`hold_both`, `carry.gd`: kova, kalas, merdiven, sedye), merdiven/tırmanma/yüzme (bilerek kapalı:
   gölge birden kaybolup beliriyor mu, göze batıyor mu?).
4. ÇİFTE GÖLGE ve hayalet: üçüncü şahıs anları (ara sahne, selfie, fotoğraf, `outfit_view`, ayna `mirror.gd` Bölüm 1 ve
   Büro), oyuncu modelinin göründüğü her an; ara sahnede kamera oyuncudan ayrılınca yerde sahipsiz gölge kalıyor mu?
5. İç mekân ve gece: Büro (3, 13, 14), otağ (12), tünel (10l, 21), gece ordugâhı (4, 11), meşale ışığı: gölge duvara /
   tavana saçma biçimde düşüyor mu, ışık kaynağına göre ters mi?
6. El eşyaları: geliştirici telefon, kitap, termos, selfie çubuğunun gölgesini kapattı. Elde eşya varken gölgenin eli
   boş mu görünüyor; bu göze batıyor mu? Büyük yükler (havlu sırığı, kova, kalas) gölge atıyor mu?
7. `chapter34o.gd:_no_hand_shadow` ile etkileşim; birinci şahıs kolunun (kolluk) gölgesi kapatıldı: kol gölgesi
   gövdeden mi geliyor?
8. Kendi gölgesi kameraya/ekrana düşüyor mu (yakın duvar önünde dev gölge, yüzünde gölge bandı)?
9. Performans: 8y, 20, 26, 28o, 2: RINFO çizim/üçgen/gölge üçgeni ÖNCE | SONRA (aynı an, üçer örnek). Her karede ağ
   yeniden kuruluyor mu (kodu oku)?
10. Testler: 0, 1, 2, 3, 8y, 11 (bütün varyantlar), 17, 19, 20, 26, 28o, 30o, 34o, 43o + `tests/` altındaki kamera/odak
    denetim sahneleri (CAMCHECK, FXCHECK, FOCUSCHECK).
