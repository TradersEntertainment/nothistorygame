# F03 düzeltme notu: Bölüm 6–9 (15 bulgu)

Değişen kod dosyaları (git diff ile doğrula; ortak çalışma ağacı):
- /home/user/nothistorygame/scripts/chapter6.gd
- /home/user/nothistorygame/scripts/chapter7.gd
- /home/user/nothistorygame/scripts/chapter8.gd
- /home/user/nothistorygame/scripts/chapter9.gd
- /home/user/nothistorygame/scripts/chapter10b.gd (yalnız 13. bulgu: barut bloğu `powder_key`; bu dosya F04 aralığında. Düzenleme sırasında dosya başka bir ajan tarafından da değiştirildi; kendi düzenlemem o güncel içerik üzerinden yapıldı, o değişiklik korundu.)
- /home/user/nothistorygame/scripts/level/byz_city.gd (ORTAK seviye dosyası: yalnız eklemeler. `with_cell` bayrağı (varsayılan false, yalnız Bölüm 6 açar), `_build_cell()`, `CELL_START` ve yeni `NIKO_CELL` sabitleri. CELL_START yalnız chapter6.gd kullanıyor.)
- /home/user/nothistorygame/scripts/level/camp_day.gd (ORTAK seviye dosyası: yalnız eklemeler. `with_merchant` bayrağı (varsayılan false), `MERCHANT_POS`, `merchant` düğümü ve etkileşimi; yalnız Bölüm 6 açar.)

Metin ve ses: `fix/F03_bolum6-9_strings.csv` (22 anahtar), `fix/F03_bolum6-9_voice.txt` (19 seslendirilen anahtar). strings.csv'ye dokunulmadı.

## Bulgular

1. [YÜKSEK] Zindan hücresi yok, Tolga açık caddede. **Düzeltildi.** `byz_city.gd` `_build_cell()`: kançılaryanın batı köşesinde duvarlı hücre, doğu yüzünde demir parmaklık (kapı aralığı Niko'ya bakar), saman, kova, lamba. `CELL_START` = (-19.4, 0, -26), eski (-7, 0, 14) değil. `chapter6.gd` `_labyrinth_fail` Niko'yu `NIKO_CELL`'e koyar. Not: hücre kançılaryanın altında değil, yanında (batı köşe). Görsel kontrol yapılmadı, ekran görüntüsü alınmadı.
2. [YÜKSEK] Mutfakta (4a.3) çakmak hiç gösterilmeden "Ocağı tek hamlede yakan sensin". **Düzeltildi.** `chapter6.gd` `_kadri_done_key()`: leblebi verildiyse `D6_KADRI_DONE`, çakmak gösterildiyse `D6_KADRI_DONE_FIRE`, hiçbiri yoksa yeni `D6_KADRI_DONE_KITCHEN` ("bulaşığı bitiren sensin").
3. [ORTA] 4b.3'te "Kalk" diyen Niko 40 m uzakta. **Düzeltildi.** `_run_6b`: `cell` ise Niko `NIKO_CELL` (parmaklığın önü) başlar.
4. [ORTA] Çakmakla A tamamlanınca yol satırı "leblebi tepsisi" diyor. **Düzeltildi.** `_complete`: `leblebi_given` yoksa `D6A_T_ROAD_A_FIRE` ("Elimde bir tepsi").
5. [ORTA] Pazar tüccarı yok, kaftan bir anda giyiliyor, hedefte yalnız "Y 0/3". **Düzeltildi (orta ölçekli).** `camp_day.gd` (bayrakla) pazarın doğu ucunda tüccar (`MERCHANT_POS` = (10.5, 0, 12.5), `speaker` `SPK_MERCHANT`). `chapter6.gd` `_merchant()`: üç iş bitmeden `D6A_M_JOBS` (işleri anlatır); üç iş bitince tüccara dönülünce `D6A_M_KAFTAN` + `D6A_T_KAFTAN` ve Y tamamlanır. Üçüncü işten sonra artık otomatik tamamlanmıyor, `D6A_T_THREE` ("tüccara dönmeliyim"). Hedef satırı: "Pazar: tüccarın üç işi %d/3" / "Pazar: tüccara dön". Kadri'ye termos yoluyla Y tamamlanması aynen korundu. Kısmi: yüzük fiziksel olarak tüccara teslim edilmiyor (bulunca tamam sayılıyor, mevcut davranış).
6. [ORTA] İmparator sahnesinde ışınlanma kararmadan. **Düzeltildi.** `_emperor()`: `fade_to(1.0)` ve `fade_to(0.0)` ile sarıldı.
7. [ORTA] Martı kaçırma repliği CHASE repliğiyle eziliyor. **Düzeltildi.** `_gull_chase`: `hud.bark(MISS)` artık `await` ediliyor; sonraki CHASE bark'ı MISS bitince başlıyor.
8. [ORTA] "Kancadaki fes" sahnede yok. **Düzeltildi.** `chapter7.gd` `_build_camp`: `_route == "A"` iken Kadri'nin arkasında kanca ve kırmızı fes (Person'daki fes modeli ile aynı ölçü).
9. [ORTA] İkizlerin arkasında termos/küp/bant yok. **Düzeltildi.** `_build_camp`: yalnız 4a.2 yolunda, `guards_distracted` ise küp, `guards_taped` ise bantlı kalkan (`Blades.shield` + gri bant), aksi halde termos. Hüseyin'in arkasında (≈0.6 m) yerleştirildi, görsel doğrulanmadı.
10. [ORTA] Theodoros "dört hata" diyor. **Düzeltildi (metin).** `D7_THEO_TRUTH_CELL` yeniden yazıldı ("izni aldı, bir martıya kaptırdı, izinsiz yakalandı"). Eski `D6B_THEO_FAIL`, `D6B_THEO_DONE`, `D6B_C_OK_*` anahtarları koda bağlı değil; dokunulmadı (ölü metin, zararsız).
11. [ORTA] Cemil bandı "az önce iki adam aldı" derken ajanlar henüz girmemiş. **Düzeltildi.** `chapter8.gd` `_enter_store`: `D8_C_TAPE` ajanlar girdikten (`D8_A1_ENTER`) sonra söyleniyor; metin "Son ruloyu bu beyler aldı..." olarak yeniden yazıldı.
12. [ORTA] Paşa, 6a'da alınmış mektubu ilk kez veriyormuş gibi anlatıyor. **Kısmi.** `chapter9.gd` `_pasha`: `candarli_letter` bayrağı varsa `D9_P_LETTER_1` (mektup cepte, otağa götürülmedi, adres Galata), `D9_P_LETTER_3`, tekrarda `D9_P_AGAIN_LETTER`, reddedince `D9_P_NO_LETTER` ("mektubumu geri ver"). Kısmi: mektubu fiziksel olarak geri alan oyun durumu yok; geri verme yalnız metin.
13. [ORTA] Büyük Atış günü tutmuyor. **Düzeltildi (kısmen farklı yoldan).** Bölüm 10'un tüm dalları (10B, 10H, 10Z, 10G, 10A, 10L, 11) 25 Nisan olduğu için 10B'yi 26'ya almadım. Bunun yerine: `D9_URBAN_OFFER_2` (ve `_PLAIN`) "Bu öğleden sonra büyük atış var", `D9_URBAN_YES` "Öğlene kadar". `D10B_U_01` "Uyandın mı?" → "Geldin mi?", `D10B_U_NAME(_PLAIN)` "Dün söz verdin" → "Az önce söz verdin". Powerbank: `chapter10b.gd` `_powder == 2` ve `showed("urban","powerbank")` değilse `D10B_U_POWDER_3_NEW` (yeni metin); gösterildiyse eski `D10B_U_POWDER_3` ("dün" çıkarıldı). Ayrı risk: Bölüm 9'un 9.6 sonu ("Yarın huzura çıkılacak", UI_CH9_END_9_6_SUB) ve `D9_G_WAIT` ("Sultan yarın kabul ediyor") hâlâ "yarın" diyor; bunlar Bölüm 9 sahibine ait, dokunmadım.
14. [ORTA] Niko'nun veda repliği kapkara ekranda. **Düzeltildi.** `chapter6.gd` `_exit`: kart sonrası Tolga Romanos kapısının iç yanında (beyaz bayrak direği eklendi), Niko yanında, `fade_to(0.0)` ile açılıyor, sonra `D6B_N_BYE`. Denetimin (WARN_SAY_ON_FADE) bunu yakalayamaması hud.gd'de: ORTAK İSTEK.
15. [ORTA] Büro ajanları "yoldan geçen" olarak konuşulabiliyor. **Düzeltildi.** `chapter8.gd` `_spawn_agents`: ajanlara `no_talk` meta. Eski `speaker` meta'sı korundu (chapter8'in kendi aramaları onu kullanıyor). Hırdavatçıda "BYZ" kalabalık çıkışı ise `side_events.gd` (crowd_set) kaynaklı; ORTAK İSTEK.

## Testler (gtest.sh)

- PARSE: PARSECHECK PASS (scripts=230).
- Tween kuralı: `tests/check_tween_await.py` temiz (yeni tween bekleme eklenmedi).
- Bölüm 6: "", b, c, y, letter, byz, byzmistake, byzfail, byzclimb, byzgive, next → PASS. (y ilk koşuda TIMEOUT verdi: o koşu bot yolu düzeltilmeden önce başlamıştı; `_auto_6a` düzeltildikten sonra tam çıktılı tekrar koşusunda "AUTOTEST PASS chapter=6 variant=y outcome=6a.4".)
- Bölüm 7: "", tea, lost, form, wall, wallkeep, byz, byzniko, byzcell, fez, next → PASS.
- Bölüm 8: "", ride, caught, late, heist, call, rulefree, tea, known, unknown, next → PASS.
- Bölüm 9: "", b, c, y, arch, none, fatih, cell, hikmet, lagim, cube, gifts, next → PASS (fatih = mektup cepte yolu).
- Tüm koşularda SCRIPT ERROR yok. Tek ERROR: "String formatting error" x3 (yalnız y yolunda): `UI_OBJ6A_Y` anahtarı henüz strings.csv'de yok, `tr()` anahtarı geri döndürüyor ve `% n` hata veriyor. strings.csv birleştirildikten sonra kaybolur. Bu, beklenen "anahtar görünür" durumunun bir yan etkisi.
- Görsel kontrol (hücre, tüccar, fes, termos, bayrak) yapılmadı.

## ORTAK İSTEKLER

- ORTAK İSTEK (F01, scripts/ui/hud.gd): WARN_SAY_ON_FADE denetimi, `_card.get_child_count() > 0` kontrolünde `clear_card()` sonrası `queue_free` bekleyen çocukları sayıyor (hud.gd ~1484 ve ~2918-2920). Kuyruğa alınmış (`is_queued_for_deletion()`) çocuklar sayılmamalı.
- ORTAK İSTEK (scripts/side_events.gd, sahibi belirsiz): `crowd_set()` tanınmayan sahnede (hırdavatçı, Galata dışı modern sahneler) "BYZ" döndürüyor, bu yüzden 'npc:crowd' konuşmaları Bizanslı kasaba lafları çıkarıyor. Öneri: tanınmayan sahnede "" döndürüp konuşmayı kapat (bu, bütün modern bölümleri etkiler; bilinçli karar gerekiyor).
- ORTAK İSTEK (Bölüm 9 / 10 sahibi): Bölüm 9 sonu "Yarın huzura çıkılacak" ve D9_G_WAIT "Sultan yarın" ile Bölüm 10'un 25 Nisan olması çelişiyor. Bu F03 kapsamı dışında.
- strings.csv birleştirme: `fix/F03_bolum6-9_strings.csv` içindeki 22 anahtar (özellikle `UI_OBJ6A_Y`, `SPK_MERCHANT`) birleştirilmeli; birleştirilmeden kodun yeni yolları ekranda anahtar gösterir.
- Ses: `fix/F03_bolum6-9_voice.txt` içindeki 19 anahtar yeniden seslendirilmeli.
