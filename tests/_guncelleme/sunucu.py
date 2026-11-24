#!/usr/bin/env python3
"""Uçtan uca güncelleme sınaması için yerel dosya sunucusu (yalnız 127.0.0.1).
   python3 tests/_guncelleme/sunucu.py KLASOR PORT [HIZ_BAYT_SN]
HIZ verilirse gövde bu hızda gönderilir (indirme yarıda kesilsin diye sunucu `kill <pid>` ile durdurulabilir)."""
import functools, http.server, sys, time

klasor, port = sys.argv[1], int(sys.argv[2])
hiz = int(sys.argv[3]) if len(sys.argv) > 3 else 0


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

    def log_message(self, fmt, *args):
        sys.stderr.write("SUNUCU " + (fmt % args) + " UA=" + str(self.headers.get("User-Agent"))
                         + " basliklar=" + ",".join(self.headers.keys()) + "\n")


http.server.ThreadingHTTPServer(("127.0.0.1", port), functools.partial(Yavas, directory=klasor)).serve_forever()
