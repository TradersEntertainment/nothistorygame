#!/usr/bin/env python3
"""Uçtan uca güncelleme sınaması için yerel dosya sunucusu (yalnız 127.0.0.1).
   python3 tests/_guncelleme/sunucu.py KLASOR PORT [HIZ_BAYT_SN] [aralik_yok]
HIZ verilirse gövde bu hızda gönderilir (indirme yarıda kesilsin diye sunucu `kill <pid>` ile durdurulabilir).
G24: "Range: bytes=a-b" isteğine 206 + Content-Range ile yanıt verir (GitHub sürüm indirmeleri gibi); dördüncü argüman
"aralik_yok" ise Range'i yok sayar ve bütün dosyayı 200 ile yollar (parça yolunun tam indirmeye düşmesi sınanır)."""
import functools, http.server, os, re, sys, time

klasor, port = sys.argv[1], int(sys.argv[2])
hiz = int(sys.argv[3]) if len(sys.argv) > 3 else 0
aralik_yok = len(sys.argv) > 4 and sys.argv[4] == "aralik_yok"


class Yavas(http.server.SimpleHTTPRequestHandler):
    def copyfile(self, kaynak, hedef):
        if hiz <= 0:
            return super().copyfile(kaynak, hedef)
        parca = max(1, hiz // 10)
        while True:
            b = kaynak.read(parca)
            if not b:
                break
            hedef.write(b)
            time.sleep(0.1)

    def do_GET(self):
        r = self.headers.get("Range")
        m = re.fullmatch(r"bytes=(\d+)-(\d+)", r.strip()) if r else None
        if aralik_yok or m is None:
            return super().do_GET()
        yol = self.translate_path(self.path)
        if not os.path.isfile(yol):
            return super().do_GET()
        n = os.path.getsize(yol)
        a, b = int(m.group(1)), int(m.group(2))
        if a > b or b >= n:
            self.send_error(416)
            return
        with open(yol, "rb") as f:
            f.seek(a)
            govde = f.read(b - a + 1)
        self.send_response(206)
        self.send_header("Content-Type", "application/octet-stream")
        self.send_header("Content-Range", "bytes %d-%d/%d" % (a, b, n))
        self.send_header("Content-Length", str(len(govde)))
        self.end_headers()
        self.wfile.write(govde)

    def log_message(self, fmt, *args):
        sys.stderr.write("SUNUCU " + (fmt % args) + " UA=" + str(self.headers.get("User-Agent"))
                         + " basliklar=" + ",".join(self.headers.keys()) + "\n")


http.server.ThreadingHTTPServer(("127.0.0.1", port), functools.partial(Yavas, directory=klasor)).serve_forever()
