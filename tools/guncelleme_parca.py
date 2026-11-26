#!/usr/bin/env python3
"""Oyun içi parçalı güncelleme (G24): ham ikilinin parça listesi.

    python3 tools/guncelleme_parca.py IKILI CIKTI.json

İkili (pck gömülü exe / x86_64) parçalara bölünür; her parçanın konumu, boyu ve MD5'i yazılır. Oyun
(scripts/ui/guncelleme_parca.gd) kendi ikilisini AYNI kuralla böler: aynı MD5'li parçaları yerel dosyadan kopyalar,
yalnız değişenleri HTTP Range ile indirir. Sonuç dosyası guncelleme.json'daki sha256 ile doğrulanır (bölme kuralı
uyuşmasa bile en kötü durumda daha çok indirilir, bozuk dosya oluşmaz).

Bölme kuralı (guncelleme_parca.gd ile aynı):
  - Sonda gömülü pck (son 4 bayt "GDPC", önündeki u64 pck boyu, pck başında "GDPC", sürüm 2, dizin şifresiz) varsa:
    kesimler = {0, pck başı, her dosya verisinin başı ve sonu, sondaki 12 baytlık iz başı, dosya sonu}
    + motor kısmında (0 … pck başı) 1 MiB'lik sabit bloklar.
  - Yoksa bütün dosya 1 MiB'lik sabit bloklar.
"""
import hashlib
import json
import struct
import sys

BLOK = 1024 * 1024
MAGIC = b"GDPC"


def kesimler(yol):
    with open(yol, "rb") as f:
        f.seek(0, 2)
        n = f.tell()
        kes = {0, n}
        ps = None
        if n >= 16:
            f.seek(n - 4)
            if f.read(4) == MAGIC:
                f.seek(n - 12)
                ds = struct.unpack("<Q", f.read(8))[0]
                aday = n - 12 - ds
                if 0 <= aday < n - 12:
                    f.seek(aday)
                    bas = f.read(100)
                    if len(bas) == 100 and bas[0:4] == MAGIC:
                        surum, = struct.unpack("<I", bas[4:8])
                        bayrak, = struct.unpack("<I", bas[20:24])
                        taban, = struct.unpack("<Q", bas[24:32])
                        sayi, = struct.unpack("<I", bas[96:100])
                        if surum == 2 and (bayrak & 1) == 0:
                            ps = aday
                            if bayrak & 2:
                                taban += ps
                            dosyalar = []
                            for _ in range(sayi):
                                sl, = struct.unpack("<I", f.read(4))
                                f.read(sl)
                                ofs, boy = struct.unpack("<QQ", f.read(16))
                                f.read(20)
                                dosyalar.append((taban + ofs, boy))
                            kes.update({ps, n - 12})
                            for a, b in dosyalar:
                                if b > 0 and ps <= a and a + b <= n:
                                    kes.add(a)
                                    kes.add(a + b)
        ust = ps if ps is not None else n
        k = BLOK
        while k < ust:
            kes.add(k)
            k += BLOK
    s = sorted(kes)
    return [(s[i], s[i + 1] - s[i]) for i in range(len(s) - 1) if s[i + 1] > s[i]], ps is not None


def main():
    yol, cikti = sys.argv[1], sys.argv[2]
    parcalar, pck = kesimler(yol)
    out = []
    with open(yol, "rb") as f:
        for o, b in parcalar:
            f.seek(o)
            out.append([o, b, hashlib.md5(f.read(b)).hexdigest()])
    toplam = sum(p[1] for p in out)
    with open(cikti, "w") as f:
        json.dump({"bicim": 1, "boyut": toplam, "pck": pck, "parcalar": out}, f, separators=(",", ":"))
    print("PARCA %s parca=%d boyut=%d pck=%s" % (yol, len(out), toplam, pck))


if __name__ == "__main__":
    main()
