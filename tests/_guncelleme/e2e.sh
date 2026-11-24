#!/usr/bin/env bash
# Oyunun kendini güncellemesi: uçtan uca kanıt (Linux, gerçek dışa aktarılmış paket). CI'a girmez.
#   tests/_guncelleme/e2e.sh            → çıktı docs/_kanit_guncelleyici/testler/e2e.log
# Gerekenler: ~/is/godot/godot (4.4.1), ~/.local/share/godot/export_templates/4.4.1.stable/linux_release.x86_64,
# ~/is/proj (projenin .git'siz TEK kopyası; VERSION yalnız orada değiştirilir, depodaki VERSION'a dokunulmaz).
# Aynı anda en çok iki ikili tutulur: A (eski sürüm, ~/is/e2e/A/) ve B (yeni sürüm, ~/is/e2e/sunucu/).
# Sıra: önce hata durumları (A değişmez), en son başarılı güncelleme (A → B).
set -u
DEPO="$(cd "$(dirname "$0")/../.." && pwd)"
GODOT="${GODOT:-$HOME/is/godot/godot}"
PROJ="$HOME/is/proj"
E2E="$HOME/is/e2e"
ADIR="$E2E/A"
SDIR="$E2E/sunucu"
AD="GercekTarihBuDegil.x86_64"
PORT="${PORT:-18731}"
USERDIR="$HOME/.local/share/godot/app_userdata/Gerçek Tarih Bu Değil"
sonuc=0

kanit() { echo "$*"; }
hata() { echo "E2E HATA: $*"; sonuc=1; }

if [ "${ATLA_DISA:-0}" != "1" ]; then
  mkdir -p "$ADIR" "$SDIR"
  echo "0.99.900" > "$PROJ/VERSION"
  "$GODOT" --headless --path "$PROJ" --export-release "Linux" "$ADIR/$AD" > "$E2E/disa_A.log" 2>&1
  echo "0.99.901" > "$PROJ/VERSION"
  "$GODOT" --headless --path "$PROJ" --export-release "Linux" "$SDIR/$AD" > "$E2E/disa_B.log" 2>&1
fi
test -s "$ADIR/$AD" || { echo "A dışa aktarılamadı"; exit 1; }
test -s "$SDIR/$AD" || { echo "B dışa aktarılamadı"; exit 1; }
A_SHA=$(sha256sum "$ADIR/$AD" | cut -d' ' -f1)
B_SHA=$(sha256sum "$SDIR/$AD" | cut -d' ' -f1)
B_BOY=$(stat -c %s "$SDIR/$AD")
kanit "A sha256=$A_SHA boyut=$(stat -c %s "$ADIR/$AD")"
kanit "B sha256=$B_SHA boyut=$B_BOY"
kanit "A sürümü: $("$ADIR/$AD" --headless -- --guncelleme-surum-yaz 2>/dev/null | grep '^GUNCELLEME')"

# Bildirim: CI'daki satırların aynısı (release.yml), yalnız linux girdisi gerçek; motor/sha256 senaryoya göre
manifest() {  # $1 motor, $2 sha256
  printf '{"surum":"%s","motor":"%s","windows":{"ad":"GercekTarihBuDegil.exe","boyut":%s,"sha256":"%s"},"linux":{"ad":"%s","boyut":%s,"sha256":"%s"}}\n' \
    "0.99.901" "$1" "$B_BOY" "$2" "$AD" "$B_BOY" "$2" > "$SDIR/guncelleme.json"
}
echo '{"0.99.901":{"tr":"Sınama sürümü B.","en":"Test build B."}}' > "$SDIR/changelog.json"

SUNUCU_PID=""
sunucu_ac() {  # $1 hız (bayt/sn, 0 = sınırsız)
  python3 "$DEPO/tests/_guncelleme/sunucu.py" "$SDIR" "$PORT" "${1:-0}" 2>> "$E2E/sunucu.log" &
  SUNUCU_PID=$!
  for _ in $(seq 50); do
    curl -s -o /dev/null "http://127.0.0.1:$PORT/guncelleme.json" && return 0
    sleep 0.2
  done
  hata "sunucu açılmadı"
}
sunucu_kapat() {
  [ -n "$SUNUCU_PID" ] && kill "$SUNUCU_PID" 2>/dev/null
  wait "$SUNUCU_PID" 2>/dev/null
  SUNUCU_PID=""
}

# Kullanıcı verisi: önceden yazılmış sınama kaydı ve ayarlar güncellemeden sonra aynı kalmalı
mkdir -p "$USERDIR"
echo "sinama kaydi $(date +%s)" > "$USERDIR/gunc_sinama_kaydi.dat"
[ -f "$USERDIR/settings.cfg" ] || printf '[settings]\n\nmaster=0.75\n' > "$USERDIR/settings.cfg"
U_ONCE=$(cat "$USERDIR/gunc_sinama_kaydi.dat" "$USERDIR/settings.cfg" | sha256sum | cut -d' ' -f1)

# A sağlam ve klasör temiz mi (yalnız ikili; .yeni/.eski/yazma denemesi kalmamış)
a_saglam() {  # $1 senaryo adı
  local s
  s=$(sha256sum "$ADIR/$AD" | cut -d' ' -f1)
  local icerik
  icerik=$(ls -A "$ADIR" | tr '\n' ' ')
  if [ "$s" = "$A_SHA" ] && [ "$icerik" = "$AD " ]; then
    kanit "SENARYO $1: A sağlam, klasör temiz ($icerik)"
  else
    hata "SENARYO $1: A bozuldu ya da klasör kirli: sha=$s klasör=[$icerik]"
  fi
}

oto() {  # $1 log adı
  timeout 600 "$ADIR/$AD" --headless -- --guncelleme-kaynak="http://127.0.0.1:$PORT/guncelleme.json" --guncelleme-oto \
    > "$E2E/$1.log" 2>&1
  echo "  çıkış=$? | $(grep '^GUNCELLEME' "$E2E/$1.log" | tr '\n' '|')"
}

# --- 1. bozuk sha256 → değiştirme yok
manifest "4.4.1" "0000000000000000000000000000000000000000000000000000000000000000"
sunucu_ac 0
kanit "SENARYO bozuk_sha256:"; oto bozuk_sha
grep -q "sayfa neden=UI_GUNC_N_BOZUK" "$E2E/bozuk_sha.log" || hata "bozuk sha256 sayfa yoluna düşmedi"
a_saglam bozuk_sha256
sunucu_kapat

# --- 2. motor uyuşmazlığı → sayfa yolu (indirme bile yok)
manifest "4.5.0" "$B_SHA"
sunucu_ac 0
kanit "SENARYO motor_uyusmazligi:"; oto motor
grep -q "sayfa neden=UI_GUNC_N_MOTOR" "$E2E/motor.log" || hata "motor uyuşmazlığı sayfa yoluna düşmedi"
grep -q "indiriliyor" "$E2E/motor.log" && hata "motor uyuşmazlığında indirme başladı"
a_saglam motor_uyusmazligi
sunucu_kapat

# --- 3. yazılamaz klasör → sayfa yolu
manifest "4.4.1" "$B_SHA"
sunucu_ac 0
chmod a-w "$ADIR"
kanit "SENARYO yazilamaz_klasor:"; oto yazilamaz
chmod u+w "$ADIR"
grep -q "sayfa neden=UI_GUNC_N_YAZMA" "$E2E/yazilamaz.log" || hata "yazılamaz klasör sayfa yoluna düşmedi"
a_saglam yazilamaz_klasor
sunucu_kapat

# --- 4. indirme yarıda kesilir (yavaş sunucu, birkaç saniye sonra kill <pid>) → A sağlam
sunucu_ac 20000000
kanit "SENARYO indirme_kesildi:"
timeout 600 "$ADIR/$AD" --headless -- --guncelleme-kaynak="http://127.0.0.1:$PORT/guncelleme.json" --guncelleme-oto \
  > "$E2E/kesildi.log" 2>&1 &
OYUN_PID=$!
for _ in $(seq 100); do
  [ -f "$ADIR/$AD.yeni" ] && [ "$(stat -c %s "$ADIR/$AD.yeni")" -gt 50000000 ] && break
  sleep 0.2
done
kanit "  kesilmeden önce .yeni=$(stat -c %s "$ADIR/$AD.yeni" 2>/dev/null || echo yok) bayt; sunucu kill $SUNUCU_PID"
sunucu_kapat
wait "$OYUN_PID"
echo "  çıkış=$? | $(grep '^GUNCELLEME' "$E2E/kesildi.log" | tr '\n' '|')"
grep -qE "sayfa neden=UI_GUNC_N_(INDIRME|BOZUK|TAKILDI)" "$E2E/kesildi.log" || hata "kesilen indirme sayfa yoluna düşmedi"
a_saglam indirme_kesildi

# --- 5. başarılı güncelleme: A → B, yeniden başlayan süreç B sürümünü yazar
manifest "4.4.1" "$B_SHA"
sunucu_ac 0
kanit "SENARYO basarili:"
oto basarili
for _ in $(seq 150); do
  grep -q "GUNCELLEME surum=" "$E2E/basarili.log" && break
  sleep 0.2
done
sleep 1
grep '^GUNCELLEME' "$E2E/basarili.log" | sed 's/^/  /'
grep -q "GUNCELLEME surum=0.99.901" "$E2E/basarili.log" || hata "yeniden başlayan süreç B sürümünü yazmadı"
S=$(sha256sum "$ADIR/$AD" | cut -d' ' -f1)
[ "$S" = "$B_SHA" ] && kanit "  klasördeki ikili sha256 = B ($S)" || hata "klasördeki ikili B değil ($S)"
[ -x "$ADIR/$AD" ] && kanit "  ikili çalıştırılabilir: $(stat -c %A "$ADIR/$AD")" || hata "ikili çalıştırılabilir değil"
sunucu_kapat
kanit "  sonraki açılış: $("$ADIR/$AD" --headless -- --guncelleme-surum-yaz 2>/dev/null | grep '^GUNCELLEME')"
[ -e "$ADIR/$AD.eski" ] && hata ".eski sonraki açılışta silinmedi" || kanit "  .eski silinmiş; klasör: $(ls -A "$ADIR" | tr '\n' ' ')"
U_SONRA=$(cat "$USERDIR/gunc_sinama_kaydi.dat" "$USERDIR/settings.cfg" | sha256sum | cut -d' ' -f1)
[ "$U_ONCE" = "$U_SONRA" ] && kanit "  user:// sınama kaydı + settings.cfg aynı ($U_SONRA)" || hata "user:// değişti"
# Yeni sürümde (B) bildirimdeki sürüm artık yeni değil
sunucu_ac 0
kanit "  B ile yeniden denetim: $("$ADIR/$AD" --headless -- --guncelleme-kaynak="http://127.0.0.1:$PORT/guncelleme.json" --guncelleme-yalniz-denetle 2>/dev/null | grep '^GUNCELLEME')"
sunucu_kapat
kanit "Sunucunun gördüğü istek başlıkları (yalnız User-Agent + HTTP'nin zorunluları):"
grep -o "UA=.*" "$E2E/sunucu.log" | sort | uniq -c | sed 's/^/  /'
rm -f "$USERDIR/gunc_sinama_kaydi.dat"
echo "E2E $([ $sonuc -eq 0 ] && echo PASS || echo FAIL)"
exit $sonuc
