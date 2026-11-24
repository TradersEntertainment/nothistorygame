#!/usr/bin/env bash
# Oyunun kendini güncellemesi: Windows yolu, wine altında (kanıt; CI'a girmez).
#   tests/_guncelleme/e2e_wine.sh
# Gerekenler: wine, ~/is/godot/godot, windows_release_x86_64.exe şablonu, ~/is/proj (projenin .git'siz tek kopyası).
# A (0.99.900) ~/is/e2ew/A/'ya, B (0.99.901) ~/is/e2ew/sunucu/'ya dışa aktarılır; aynı anda iki ikili.
set -u
DEPO="$(cd "$(dirname "$0")/../.." && pwd)"
GODOT="${GODOT:-$HOME/is/godot/godot}"
PROJ="$HOME/is/proj"
E2E="$HOME/is/e2ew"
ADIR="$E2E/A"
SDIR="$E2E/sunucu"
AD="GercekTarihBuDegil.exe"
PORT="${PORT:-18732}"
export WINEDEBUG=-all
export WINEPREFIX="$HOME/is/wineprefix"
sonuc=0
hata() { echo "E2EW HATA: $*"; sonuc=1; }

if [ "${ATLA_DISA:-0}" != "1" ]; then
  mkdir -p "$ADIR" "$SDIR"
  echo "0.99.900" > "$PROJ/VERSION"
  "$GODOT" --headless --path "$PROJ" --export-release "Windows Desktop" "$ADIR/$AD" > "$E2E/disa_A.log" 2>&1
  echo "0.99.901" > "$PROJ/VERSION"
  "$GODOT" --headless --path "$PROJ" --export-release "Windows Desktop" "$SDIR/$AD" > "$E2E/disa_B.log" 2>&1
  rm -f "$ADIR"/*.console.exe "$SDIR"/*.console.exe
fi
test -s "$ADIR/$AD" && test -s "$SDIR/$AD" || { echo "dışa aktarım yok"; exit 1; }
A_SHA=$(sha256sum "$ADIR/$AD" | cut -d' ' -f1)
B_SHA=$(sha256sum "$SDIR/$AD" | cut -d' ' -f1)
B_BOY=$(stat -c %s "$SDIR/$AD")
echo "A sha256=$A_SHA"
echo "B sha256=$B_SHA boyut=$B_BOY"
wine wineboot -i > /dev/null 2>&1
echo "A sürümü (wine): $(timeout 300 wine "$ADIR/$AD" --headless -- --guncelleme-surum-yaz 2>/dev/null | tr -d '\r' | grep '^GUNCELLEME')"

printf '{"surum":"0.99.901","motor":"4.4.1","windows":{"ad":"%s","boyut":%s,"sha256":"%s"}}\n' "$AD" "$B_BOY" "$B_SHA" \
  > "$SDIR/guncelleme.json"
python3 "$DEPO/tests/_guncelleme/sunucu.py" "$SDIR" "$PORT" 0 2> "$E2E/sunucu.log" &
SPID=$!
sleep 1
timeout 900 wine "$ADIR/$AD" --headless -- --guncelleme-kaynak="http://127.0.0.1:$PORT/guncelleme.json" --guncelleme-oto \
  > "$E2E/oto.log" 2>&1
echo "oto çıkış=$?"
for _ in $(seq 300); do
  grep -q "GUNCELLEME surum=" "$E2E/oto.log" && break
  sleep 0.5
done
sleep 2
tr -d '\r' < "$E2E/oto.log" | grep '^GUNCELLEME' | sed 's/^/  /'
S=$(sha256sum "$ADIR/$AD" | cut -d' ' -f1)
[ "$S" = "$B_SHA" ] && echo "klasördeki exe sha256 = B" || hata "klasördeki exe B değil ($S)"
echo "klasör: $(ls -A "$ADIR" | tr '\n' ' ')"
echo "sonraki açılış: $(timeout 300 wine "$ADIR/$AD" --headless -- --guncelleme-surum-yaz 2>/dev/null | tr -d '\r' | grep '^GUNCELLEME')"
[ -e "$ADIR/$AD.eski" ] && hata ".eski kaldı" || echo ".eski silinmiş; klasör: $(ls -A "$ADIR" | tr '\n' ' ')"
kill "$SPID" 2>/dev/null
echo "E2EW $([ $sonuc -eq 0 ] && echo PASS || echo FAIL)"
exit $sonuc
