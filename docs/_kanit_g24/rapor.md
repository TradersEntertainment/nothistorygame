# G24 — Parçalı oyun içi güncelleme (bütün oyunu yeniden indirmez)

## Sorun

Güncelleyici (`scripts/ui/guncelleyici.gd`, G16) her sürümde platformun ham ikilisinin tamamını indiriyordu. İkili, gömülü
pck ile birlikte bütün sesleri ve varlıkları içeriyor: Linux 1 263 MB, Windows 1 291 MB. Çoğu sürümde değişen kısım
birkaç MB.

## Çözüm

1. **CI (`release.yml`).** `tools/guncelleme_parca.py`, her ham ikili için bir parça listesi yazar:
   `<ad>.parca.json` = [konum, boy, md5]. Bölme kuralı:
   - motor kısmı 1 MiB'lik sabit bloklar;
   - gömülü pck'nin başlığı ve dizini;
   - pck içindeki her dosyanın verisi ayrı parça;
   - sondaki iz.

   `guncelleme.json`'da platform girdisine `"parca"` alanı eklenir. Eski istemciler bu alanı yok sayar.
2. **Oyun (`scripts/ui/guncelleme_parca.gd` + `guncelleyici.gd`).** "Güncelle" denince:
   - Parça listesi indirilir.
   - Kendi ikilisi aynı kuralla bölünür ve MD5'leri çıkarılır (iş parçacığında; ekranda "Doğrulanıyor").
   - Aynı MD5'li parçalar yerelden kopyalanır; değişen aralıklar HTTP Range ile `<exe>.parcalar`'a indirilir.
   - `<exe>.yeni` birleştirilir ve bildirimdeki **aynı sha256** ile doğrulanır.
   - Sonraki adımlar (yer değiştirme, yeniden başlatma, geri alma) G16'daki gibi.
3. **Güvenli düşüş.** Şu durumlarda sessizce eski tam indirmeye dönülür:
   - parça listesi yok ya da bozuk;
   - sunucu Range vermiyor (gövde sınırıyla hemen kesilir, bellek dolmaz);
   - fark ikilinin %80'ini aşıyor;
   - birleşen dosyanın sha256'sı tutmuyor.

   Oyun hiçbir durumda bozuk dosya ile kalmaz. `--guncelleme-tam` parça yolunu kapatır.

## Ölçümler (gerçek dışa aktarılmış ikililer, Godot 4.4.1)

| | tam indirme | parçalı indirme | parça sayısı |
|---|---|---|---|
| Linux (0.99.129 → sınama 0.99.130: VERSION + bir betik) | 1 263 MB | **3,5 MB** (3 aralık) | 49 522 |
| Windows (aynı, sürüm bilgisi de değişmiş) | 1 291 MB | **2,5 MB** (2 aralık) | 49 549 |

- GDScript ve Python bölmesi 49 522/49 522 aynı. Birleşen dosya B ile bit bit aynı (`tests/_guncelleme/parca_check.tscn`,
  gerçek ikililerle).
- Uçtan uca (dışa aktarılmış paket, yerel Range sunucusu, `e2e.txt`):
  - 4,0 MB indirildi, toplam 15 sn;
  - yer değiştirdi, yeni sürüm açıldı, klasör temiz.
- Range vermeyen sunucuda tam indirmeye düştü ve yine doğru kuruldu.
- Gerçek GitHub sürüm adresi (release-assets.githubusercontent.com'a yönlendirme) Range'e 206 veriyor (curl ile
  denendi). Godot HTTPRequest yönlendirmede özel başlıkları yeniden gönderiyor (4.4.1 kaynağı, `http_request.cpp`).

## Testler

- `GUNCELLEMECHECK PASS denetim=196` (bildirimdeki `parca` alanı: okunur, yoksa ya da bozuksa düşer).
- `PARCACHECK PASS`: yapay ikililer, `run_tests.sh`'e eklendi; gerçek A/B ikilileriyle de PASS.

## Bilinmesi gereken

- **Bir kerelik tam indirme.** Bu sürüme geçen oyuncular son kez tam indirme yapar, çünkü kurulu eski istemci parça yolunu
  bilmiyor. Ondan sonraki her güncelleme parçalı.
- **Yerel işlem süresi.** Oyuncunun makinesinde ~1,3 GB okunur ve yazılır (MD5, birleştirme, sha256): sınama makinesinde
  ~15 sn.
- **Disk.** Gereken boş yer önceki gibi ikili boyu × 1,1; `.parcalar` küçüktür.
