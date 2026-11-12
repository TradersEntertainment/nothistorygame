# Dilim 10b raporu (çeviri kokusu taraması)

**Okunan satır:** 1073 (Türkçe ve İngilizce sütunların ikisi de). Dal: `wip/ceviri-10b`.
**Önerilen düzeltme:** 11 satır = 9 tr + 2 en. Şiddet: 3 → 0, 2 → 4, 1 → 7.
Oran %1 civarı, beklenen %5–20'nin altında. Sebebi dilimin yapısı: çoğu satır menü, tuş istemi, konuşmacı adı, tarih/mekân kartı ve akıbet notu. Bunlar kısa ve zaten oyunun kendi dilinde yazılmış. "Emin değilsen dokunma" kuralıyla yalnız kulağa gerçekten takılanlara dokundum.

## En iyi örnekler (önce | sonra)
1. D6A_C_01_NOFEZ: "Ben kimseyim. Kimse gönderdi." | "Ben kimse değilim. Beni de kimse göndermedi." ("Ben kimseyim" Türkçede 'somebody' gibi okunuyor, 'nobody'nin düz çevirisi.)
2. D6A_M_KAFTAN: "Teşekkür ederim!" | "Allah razı olsun!" (pazar tüccarının ağzı)
3. LORE_9_2: "Surların içindeki tanıklar gece gündüz duyulan bu sesleri ... yazdı." | "Surların içindekiler bu sesleri gece gündüz duyduklarını ... yazdı."
4. SIEGE_NOTE_26_3: "Tarih kendi kaydını yeniden deneyecek." | "Tarih kendi kaydına yeniden kalkışacak."
5. SIEGE_NOTE_28O_1 ve 1M: "Not: Bu sadece ilk gün." | "Not: Daha ilk gün." (dolgu "sadece")
6. UI_RECAP_30O_NEXT tr: "Surun üstünden olmadı." | "Üstten geçilmedi, bakalım altından."
7. UI_RECAP_30O_NEXT en: "Over the wall didn't work." | "Over the wall didn't work out."
8. UI_TRESPASS_CAUGHT: "dövüp geri, kendi tarafına attı" | "dövüp kendi tarafına geri attı"
9. LM_HIPPODROME_INFO: "araba yarışı" | "at arabası yarışı"
10. UI_RECAP_21O_PREV en: "carried ... back on your back" | "carried ... out on your back"

## Bağlı değişenler
- D6A_M_KAFTAN, D6A_M_JOBS ile aynı sahnede (chapter6.gd:538). JOBS'a dokunulmadı; "Allah razı olsun" ile uyumlu.
- SIEGE_NOTE_28O_1 / 28O_1M birlikte değişir.
- Tr ve en ayrı satırlar, en tarafındaki iki düzeltme Türkçe satırdan bağımsız.

## Şüpheli (dokunulmadı, sahibine sorulabilir)
- SIEGE_NOTE_29_1 "Not: Yükseklik bir avantajdır, sigortada da." Espri biraz zorlama ama Tolga'nın tutanak şakası olarak çalışıyor.
- UI_MENU_H_T3_BACK "Ayağın hâlâ yanlış." Hikmet'in dans esprisi olabilir. EN "wrong foot" deyim olarak daha doğal.
- LORE_23_2 "yıllık yüksek bir haraç" ("ağır haraç" daha yerli olurdu, küçük pürüz).
- LORE_6B_4 "altı yüz yıl önceki nüfusun küçük bir parçası" akıcı değil ama anlam açık.
- SIEGE_NOTE_29O_2: "ben de denizdeydim, o kadar yakın değildik" mantık biraz dolambaçlı, espri olarak bırakıldı.
- EN LORE_33O_1 / LORE_35O_2: "Saruja Pasha", "Karaja Bey" (TR: Saruca, Karaca). Özel ad yazımı olduğu için dokunulmadı; EN içi tutarlılık kontrol edilmeli.

## Genel gözlemler
- Bilgi kartları (LORE_*, LM_*_INFO) ansiklopedi çevirisi gibi durmuyor; kısa, düz anlatı. Tarihî olgulara dokunulmadı.
- En kokan yer yok. Küçük pürüzler düşük şiddette dağınık: dolgu zarfları ("sadece"), edilgen yığılması, karakter ağzına uymayan resmî teşekkür.
- Akıbet satırları (FATE26_*) ve tutanak notları (SIEGE_NOTE_*) dilimin en iyi yazılmış kısmı; Tolga'nın sigorta jargonu bilerek bırakıldı.
- Tuş adları, yer tutucular, BBCode ve uzunluk sınırlarına dokunulmadı; yeni metinler eskisinin %70–130'u içinde.
