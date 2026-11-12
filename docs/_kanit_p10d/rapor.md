# P10 düzeltme turu raporu (iç mekânlar ve tüneller)

Dal: `wip/yardimci-p10`. ÖNCE = `a5e8111d` (depo dışı kopya, ayrı proje). Kareler ekranlı PACE koşusundan
(`--dialogshots --shotevery=1 --snapevery=0.5`, 1280×720), ÖNCE | SONRA aynı replik anından, 640 px.
Düzenlenen dosyalar: `chapter1.gd`, `chapter10l.gd`, `chapter13.gd`, `chapter15.gd`, `chapter21o.gd`, `level/otag_hall.gd`.
74 ses `.import` kaydı `git rm --cached` ile dizinden çıkarıldı.

## Madde durumu (denetçi tablosuna göre)

| # | Madde | Durum | Kanıt / not |
|---|---|---|---|
| 1 | Bölüm 1 kumanda elden ele | **DÜZELDİ** | P01. Hikmet bir adım (30 cm) yaklaşır, kumanda avucundayken Tolga'nın sol eli oraya uzanır, temas karesinde (satır 2-3) iki el aynı yerde; kumanda temastan sonra Tolga'nın elinde geri çekilir, havada süzülme yok. Not: Hikmet'in kendi eli kumandanın arkasında kalıp seçilmiyor. Süre: D1_H_16→D1_H_17 boşluğu ÖNCE 5,9 sn, SONRA 5,7 sn (+0,4 sn tween kaldırıldı). |
| 2 | 13 kol tutuşu | **DÜZELDİ** | P02. Kol 3,6 m öteden tutulamıyordu: oyuncu replik sürerken (1,3 sn, yumuşak) kola yaklaşır; QTE karesinde sol el kırmızı topuzun üstünde, kol inerken el topuzun gerçek konumunu her karede izler (D13_H_OPEN'da el inmiş). Topuz 70°'de yalnız ~16 cm düşer, ~43 cm yana gider: "≥20 cm iniş" dikey değil yol olarak sağlandı. Süre değişmedi (D13_H_OPEN her iki koşuda t=32,5). |
| 4 | 12 kâtip kalemi / dizler | **KISMEN** | Kadrajda değil, oynanış karesi YOK. `sonda_` ölçümü: kalem ucu x −4,26…−4,15, z −2,29, y 0,51–0,58; kâğıt x∈[−4,45;−3,95], z∈[−2,575;−2,225], üst yüz y 0,53 → kalem kâğıdın üstünde. Kâtip z −1,65: dizler masa ön yüzünün (−2,10) gerisinde (hesap, AABB ölçülmedi). |
| 5 | 21o kazmacı kazması gömülmesin | **KISMEN** | `_place_crew` fz+1,0 → fz+1,5. Sonda: kazma başı en fazla 1,31 m ileri; yüz ön yüzü fz+0,2 → uç yüze değer, içine girmez. Oynanış karesinde kazmacı kadrajda değil: **DURUYOR, KANITSIZ (karede)**. |
| 6 | 21o oyuncu kazmasını el tutsun | **DÜZELDİ** | P05. Sol el sapı tutar, T başı ekranda yatay seçilir (ÖNCE düz levha, elden 20 cm yanda). Tutuş açısı Player'ın el formülünden hesaplandı; parmak sarışı gerçek bir sapa göre yaklaşık. |
| 7 | 10l Dragan kazması T baş | **DÜZELDİ** | P03 (D10L_T_04): baş yana döndü, mızrak gibi okunmuyor. |
| 8 | 10l oyuncu kazması | **DOĞRULANDI** | P03 alt satır (değişmedi, tek ağ). |
| 9 | 10l yan kazmacılar | **DÜZELDİ** | P04. Konum −1,6 → −1,0 (kazma ucu iç duvar yüzünün ~5 cm önünde: hesap). Kazmalar sahne açılınca kurulur; D10L_T_MEET_1'de vurmayı bırakıp 0,5 sn'de oyuncuya döner, kazma elde sarkık; MEET_2'de yüzleri oyuncuya dönük (ÖNCE'deki duruş). Duvara vuruş anı karede yakalanmadı. |
| 10 | 15 baş sallama RNG | **DÜZELDİ (kod)** | `_nod_later` yerel `RandomNumberGenerator`; kare yok. |
| 11, 13 | vezir idle_vary, 5/8/14/10a kare gezisi | **BAKILMADI** | Yalnız testler. |

## Çizim sayısı (RINFO, PACE hizalı, ÖNCE | SONRA)
- **10l**: t=5–9: 610 | 611; t=11: 468 | 469; t=13: 508 | 509; t=15: 548 | 549; t=19–21: 566 | 567. **+1 çizim (+%0,2) tutarlı: KISMEN** (kural "artmaz"). Kazma parçaları tek ağda birleştirildi (ilk turda +14, ara turda +7, şimdi +1); kalan +1 büyük olasılıkla Dragan'ın kazması, kaynağı ayrıca doğrulanmadı. Üçgen: 96k | 96k.
- **21o**: t=3–5: 496 | 494; t=7–11: 512 | 512; t=15–23: 560 | 560. Artış yok. Üçgen +%0 (33–38k).
- 1, 13: RINFO ayrıca ölçülmedi (kod bu bölümlerde yalnız sahne devinimi ekledi).

## Testler (başsız, `--max-fps 20`)
63 koşu, 63 `AUTOTEST PASS`; SCRIPT ERROR, WARN_FX_STUCK, WARN_FLY_ITEM, VISAUDIT, WARN_VOID_TELEPORT, WALKTHRU, ARMAUDIT,
HELDAUDIT, JOURNEY_MISS/OVERLAP: 0. Kapsam: 1 (`""`, kick, red), 10l (5), 13 (13), 21o (4), 10a (2), 12, 14, 21,
15 (33 varyant). Ekranlı PASS: 1, 13, 10l, 21o, 12. Çıkışta "resources still in use" ÖNCE'de de var.

## Kurallara uygunluk
Replik metni/sırası, sayaç, sonuç, kalabalık, bot yolu değişmedi. Süre: ch1 −0,2 sn, ch13 aynı; 10l/21o aynı akış.
Hikmet'in adımı ve oyuncunun 1,3 sn'lik kola yaklaşması replik sürerken, ek bekleme yok. Kare kancası/sonda depoda yok
(`tests/_tmp` izlenmiyor, `.git/info/exclude`). Ortak dosyaya dokunulmadı. Kazma birleştirme yardımcısı (`_merge_tool`) iki bölümde kopya.

## Açık kalanlar
Kâtip ve 21o kazmacı oynanış karesi (kadrajda değil); 10l +1 çizim; Hikmet'in elinin kumandada seçilmemesi (P01).
