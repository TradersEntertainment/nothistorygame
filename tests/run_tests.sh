#!/usr/bin/env bash
# Bölüm 1-15'i bütün yollardan kendi kendine oynatır (ekransız).
# Kullanım: GODOT=/path/to/godot tests/run_tests.sh
# Hızlı mod (sürüm yayınında): QUICK=1 — her bölüm bir kez (varsayılan yol) + iki tarafın kilit yolları
# (6/7/10 Bizans, 17/23/25 Osmanlı), kuşatma kapısı (12 → 17) ve merdiven/arena/hareket testleri. ~15 dk.
set -u
GODOT="${GODOT:-godot}"
cd "$(dirname "$0")/.."
"$GODOT" --headless --path . --import >/dev/null 2>&1
fail=0
# Takılma denetimi: bitmiş tweeni bekleyen akışlar (replik uzun okununca oyun kilitlenir)
python3 tests/check_tween_await.py || fail=1
# Metni yazılmamış replik/arayüz anahtarı (ekranda anahtarın kendisi görünür)
python3 tests/check_keys.py >/dev/null || { python3 tests/check_keys.py | grep -v "^anahtar"; fail=1; }
run() {
  if [ "${QUICK:-0}" = "1" ]; then
    case " $* " in
      *" --autotest "*|*" --autotest=byz "*|*" --autotest=osm "*|*"--chapter=12 --autotest=next "*|*"--chapter=12b --autotest=next "*) ;;
      *) return ;;
    esac
  fi
  # Her koşu en fazla 5 dakika: takılan bir yol bütün paketi kilitlemesin
  out=$(timeout 300 "$GODOT" --headless --path . -- "$@" 2>&1)
  [ $? -eq 124 ] && echo "AUTOTEST TIMEOUT $*"
  echo "$out" | grep -E "AUTOTEST|SCRIPT ERROR|Parse Error|WARN_|VISAUDIT" | awk '!seen[$0]++'
  echo "$out" | grep -q "AUTOTEST PASS" || fail=1
  echo "$out" | grep -q "SCRIPT ERROR" && fail=1
  # Ağır çekim/donma takılı kaldıysa (Fx bekçisi sıfırladı) bu bir hata
  echo "$out" | grep -q "WARN_FX_STUCK" && fail=1
}
run --chapter=0 --autotest
for v in "" "=kick" "=red"; do run --autotest$v; done
for v in "" "=perfect" "=chain" "=chainfail" "=red" "=swimshore" "=swimchain"; do run --chapter=2 --autotest$v; done
for v in "" "=tea" "=confiscate" "=seal" "=lie" "=radio"; do run --chapter=3 --autotest$v; done
for v in "" "=item" "=caught" "=market" "=chain" "=nofez" "=fall"; do run --chapter=4 --autotest$v; done
for v in "" "=call" "=confiscated" "=sealed" "=noradio"; do run --chapter=5 --autotest$v; done
for v in "" "=b" "=c" "=y" "=letter" "=byz" "=byzmistake" "=byzfail" "=byzclimb"; do run --chapter=6 --autotest$v; done
for v in "" "=tea" "=lost" "=form" "=wall" "=wallkeep" "=byz" "=byzniko" "=byzcell"; do run --chapter=7 --autotest$v; done
for v in "" "=ride" "=caught" "=late" "=heist" "=call" "=rulefree" "=tea"; do run --chapter=8 --autotest$v; done
for v in "" "=b" "=c" "=y" "=arch" "=none" "=fatih" "=cell" "=hikmet" "=lagim"; do run --chapter=9 --autotest$v; done
for v in "" "=fail" "=honest" "=selfie" "=byz" "=retry"; do run --chapter=10 --autotest$v; done
for v in "" "=arrest" "=escape" "=persuade" "=help" "=helpwall" "=lost" "=fired" "=hikmet" "=niko"; do run --chapter=11 --autotest$v; done
for v in "" "=leblebi" "=twokings" "=repair" "=kitchen" "=retry" "=hikmet" "=nihat"; do run --chapter=12 --autotest$v; done
for v in "" "=miss" "=wrong" "=depot" "=together" "=stay" "=w4" "=meclis" "=kitchen" "=city"; do run --chapter=13 --autotest$v; done
for v in "" "=eye" "=boom" "=untaped" "=tape"; do run --chapter=10b --autotest$v; done
for v in "" "=fire" "=noleb"; do run --chapter=10z --autotest$v; done
for v in "" "=fatih" "=late"; do run --chapter=10g --autotest$v; done
for v in "" "=refuse"; do run --chapter=10a --autotest$v; done
for v in "" "=collapse" "=retreat" "=leb"; do run --chapter=10l --autotest$v; done
for v in "" "=leb" "=late"; do run --chapter=16 --autotest$v; done
for v in "" "=shame" "=save" "=save1" "=honest" "=open"; do run --chapter=10h --autotest$v; done
for v in "" "=lie" "=year" "=d2" "=d3"; do run --chapter=12b --autotest$v; done
for v in "" "=forge" "=recruit" "=resign" "=newmodel"; do run --chapter=14 --autotest$v; done
for v in "" "=missed" "=wrong" "=recruit" "=w4" "=forge" "=resign" "=newmodel" "=pyjama" "=stay" "=leblebi" "=fixed" "=liar" "=boom" "=gunner" "=w6" "=w7" "=w8" "=founder" "=w13" "=w10" "=w11" "=w12" "=sealed" "=evening" "=eaves" "=water"; do run --chapter=15 --autotest$v; done
# Perde IV · Hasar Tespit
for v in "" "=two" "=fall" "=nophoto"; do run --chapter=17 --autotest$v; done
for v in "" "=crooked"; do run --chapter=18 --autotest$v; done
for v in "" "=miss"; do run --chapter=18b --autotest$v; done
for v in "" "=flee"; do run --chapter=19 --autotest$v; done
for v in "" "=tape" "=late" "=hit" "=lose"; do run --chapter=20 --autotest$v; done
for v in "" "=grant" "=fight"; do run --chapter=21 --autotest$v; done
for v in "" "=brow" "=miss"; do run --chapter=22 --autotest$v; done
for v in "" "=creative"; do run --chapter=23 --autotest$v; done
run --chapter=23 --autotest=osm
for v in "" "=late"; do run --chapter=24 --autotest$v; done
for v in "" "=caught"; do run --chapter=25 --autotest$v; done
for v in "=osm" "=osm_caught"; do run --chapter=25 --autotest$v; done
for v in "" "=nophoto" "=hold" "=hold_box" "=hold23" "=hold3" "=warn_notrust" "=hold_lose"; do run --chapter=26 --autotest$v; done
# Perde IV · Osmanlı tarafı (Büro'da "O" seçilince)
run --chapter=17 --autotest=osm
for v in "" "=slow"; do run --chapter=17o --autotest$v; done
for v in "" "=silent"; do run --chapter=19o --autotest$v; done
for v in "" "=wide" "=lose"; do run --chapter=20o --autotest$v; done
for v in "" "=smoke" "=lose"; do run --chapter=21o --autotest$v; done
for v in "" "=late" "=lose"; do run --chapter=22o --autotest$v; done
for v in "" "=late"; do run --chapter=24o --autotest$v; done
for v in "" "=nophoto" "=lose"; do run --chapter=26o --autotest$v; done
for v in "" "=lose"; do run --chapter=28o --autotest$v; done
for v in "" "=lose"; do run --chapter=29 --autotest$v; done
for v in "" "=lose"; do run --chapter=30 --autotest$v; done
for v in "" "=lose"; do run --chapter=30o --autotest$v; done
for v in "" "=late"; do run --chapter=32o --autotest$v; done
for v in "" "=lose"; do run --chapter=37o --autotest$v; done
for v in "" "=lose"; do run --chapter=38o --autotest$v; done
for v in "" "=late"; do run --chapter=39o --autotest$v; done
for v in "" "=late"; do run --chapter=31o --autotest$v; done
for v in "" "=wide" "=fall"; do run --chapter=33o --autotest$v; done
for v in "" "=bad"; do run --chapter=34o --autotest$v; done
for v in "" "=slip"; do run --chapter=35o --autotest$v; done
for v in "" "=lose"; do run --chapter=29o --autotest$v; done
run --chapter=17 --autotest=route
# Zorluk: kolay ve zor (parry penceresi, rakip hasarı) — bölüm 20 her ikisinde de geçmeli
run --chapter=20 --autotest --difficulty=0
run --chapter=20 --autotest --difficulty=2
for v in "" "=leave"; do run --chapter=27 --autotest$v; done
# Merdiven: yürü, tutun, tırman, tepeye çık
out=$(timeout 120 "$GODOT" --headless --path . res://tests/ladder_test.tscn -- --autotest 2>&1)
echo "$out" | grep -E "AUTOTEST|SCRIPT ERROR|Parse Error"
echo "$out" | grep -q "AUTOTEST PASS" || fail=1
# Sonsuz Kuşatma (kılıç dövüşü): bot üç dalga oynar
for v in "" "=osm" "=mods" "=cannon" "=osm_cannon" "=gun" "=osm_gun" "=gunner" "=osm_gunner"; do
  out=$(timeout 300 "$GODOT" --headless --path . res://scenes/arena.tscn -- --autotest$v 2>&1)
  echo "$out" | grep -E "AUTOTEST|SCRIPT ERROR|Parse Error|WARN_"
  echo "$out" | grep -q "AUTOTEST PASS" || fail=1
  echo "$out" | grep -q "SCRIPT ERROR" && fail=1
done
# Vuruş hissi (Fx): donma ve ağır çekim zaman ölçeğini tabana (3× test hızı dahil) geri döndürür
out=$(timeout 60 "$GODOT" --headless --path . res://tests/fx_check.tscn 2>&1)
echo "$out" | grep -E "FXCHECK|SCRIPT ERROR|Parse Error"
echo "$out" | grep -q "FXCHECK PASS" || fail=1
# Başarımlar ve savaş karnesi: yeni başarımların koşulları, karne puanı ve derecesi
out=$(timeout 60 "$GODOT" --headless --path . res://tests/ach_check.tscn 2>&1)
echo "$out" | grep -E "ACHCHECK|SCRIPT ERROR|Parse Error"
echo "$out" | grep -q "ACHCHECK PASS" || fail=1
# Kuşatma yönlendirmesi: iki tarafın bölüm sırası, ekran numaraları, "{N}" başlıkları
out=$(timeout 60 "$GODOT" --headless --path . res://tests/siege_route.tscn 2>&1)
echo "$out" | grep -E "ROUTE|SCRIPT ERROR|Parse Error"
echo "$out" | grep -q "ROUTECHECK PASS" || fail=1
# Hareket: tırmanma, kenardan çıkma, atlama, nefes, sınır
out=$(timeout 300 "$GODOT" --headless --path . res://tests/traversal_test.tscn -- --autotest 2>&1)
echo "$out" | grep -E "AUTOTEST|SCRIPT ERROR|Parse Error"
echo "$out" | grep -q "AUTOTEST PASS" || fail=1
# Bölüm geçişleri: 1 -> 2 (çanta ve Telsiz Bağı taşınır), 2 -> 3
run --autotest=next
run --chapter=2 --autotest=next
run --chapter=3 --autotest=next
run --chapter=4 --autotest=next
run --chapter=5 --autotest=next
run --chapter=6 --autotest=next
run --chapter=7 --autotest=next
run --chapter=8 --autotest=next
run --chapter=9 --autotest=next
run --chapter=10 --autotest=next
run --chapter=11 --autotest=next
run --chapter=12 --autotest=next
run --chapter=10b --autotest=next
run --chapter=10h --autotest=next
run --chapter=10z --autotest=next
run --chapter=10g --autotest=next
run --chapter=10a --autotest=next
run --chapter=10l --autotest=next
run --chapter=12b --autotest=next
run --chapter=13 --autotest=next
run --chapter=13 --autotest=gidak
run --chapter=16 --autotest=next
run --chapter=14 --autotest=next
# Titreşen yüzey denetimi (aynı düzlemde çakışan kutu yüzleri): tam koşuda bütün bölüm sahneleri
if [ "${QUICK:-0}" != "1" ]; then
  for f in scenes/chapter*.tscn; do
    zout=$(timeout 150 "$GODOT" --headless --path . -s tests/zfight_check.gd -- "res://$f" 2>&1 | grep "^ZFIGHT")
    if [ -n "$zout" ]; then echo "$zout"; fail=1; fi
  done
fi
# Fizik denetimi (PHYS=1; sanal ekran gerekir, bkz. docs/PHYSICS_AUDIT.md): her bölümün her evresinde oyuncunun
# gidebildiği yer ile görünen dünya karşılaştırılır. Dünyanın dışına düşülen yer (VOID), katının içinde başlama
# (SPAWN), hiçbir yöne gidememe (STUCK) ve yürüyerek varılamayan hedef (TARGET) testi düşürür; ötekiler rapordur.
if [ "${PHYS:-0}" = "1" ]; then
  pdir=$(mktemp -d)
  for f in scenes/chapter*.tscn; do
    pout=$(timeout 1200 xvfb-run -a "$GODOT" --path . --resolution 320x180 -s tests/phys_audit.gd -- "$pdir" "res://$f" "" 20 2>&1)
    echo "$pout" | grep -E "^PHYSSUM|SCRIPT ERROR"
    if echo "$pout" | grep -E "^PHYS (VOID|SPAWN|STUCK|TARGET) " | grep -E " d=( |[0-9] |1[0-9] |2[0-9] )"; then fail=1; fi
  done
  echo "Fizik haritaları: $pdir"
fi
exit $fail
