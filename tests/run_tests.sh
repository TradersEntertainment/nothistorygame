#!/usr/bin/env bash
# Bölüm 1-15'i bütün yollardan kendi kendine oynatır (ekransız).
# Kullanım: GODOT=/path/to/godot tests/run_tests.sh
set -u
GODOT="${GODOT:-godot}"
cd "$(dirname "$0")/.."
"$GODOT" --headless --path . --import >/dev/null 2>&1
fail=0
run() {
  # Her koşu en fazla 5 dakika: takılan bir yol bütün paketi kilitlemesin
  out=$(timeout 300 "$GODOT" --headless --path . -- "$@" 2>&1)
  [ $? -eq 124 ] && echo "AUTOTEST TIMEOUT $*"
  echo "$out" | grep -E "AUTOTEST|SCRIPT ERROR|Parse Error"
  echo "$out" | grep -q "AUTOTEST PASS" || fail=1
  echo "$out" | grep -q "SCRIPT ERROR" && fail=1
}
for v in "" "=kick" "=red"; do run --autotest$v; done
for v in "" "=perfect" "=chain" "=chainfail" "=red"; do run --chapter=2 --autotest$v; done
for v in "" "=tea" "=confiscate" "=seal" "=lie"; do run --chapter=3 --autotest$v; done
for v in "" "=item" "=caught" "=market" "=chain" "=nofez" "=fall"; do run --chapter=4 --autotest$v; done
for v in "" "=call" "=confiscated" "=sealed" "=noradio"; do run --chapter=5 --autotest$v; done
for v in "" "=b" "=c" "=y" "=letter" "=byz" "=byzmistake" "=byzfail"; do run --chapter=6 --autotest$v; done
for v in "" "=tea" "=lost" "=form" "=wall" "=wallkeep" "=byz" "=byzniko" "=byzcell"; do run --chapter=7 --autotest$v; done
for v in "" "=ride" "=caught" "=late" "=heist" "=call" "=rulefree"; do run --chapter=8 --autotest$v; done
for v in "" "=b" "=c" "=y" "=arch" "=none" "=fatih" "=cell" "=hikmet"; do run --chapter=9 --autotest$v; done
for v in "" "=fail" "=honest" "=selfie" "=byz" "=retry"; do run --chapter=10 --autotest$v; done
for v in "" "=arrest" "=escape" "=persuade" "=help" "=helpwall" "=lost" "=fired" "=hikmet" "=niko"; do run --chapter=11 --autotest$v; done
for v in "" "=leblebi" "=twokings" "=repair" "=kitchen" "=retry" "=hikmet" "=nihat"; do run --chapter=12 --autotest$v; done
for v in "" "=miss" "=wrong" "=depot" "=together" "=stay" "=w4" "=meclis" "=kitchen"; do run --chapter=13 --autotest$v; done
for v in "" "=eye" "=boom" "=untaped" "=tape"; do run --chapter=10b --autotest$v; done
for v in "" "=forge" "=recruit" "=resign" "=newmodel"; do run --chapter=14 --autotest$v; done
for v in "" "=missed" "=wrong" "=recruit" "=w4" "=forge" "=resign" "=newmodel" "=pyjama" "=stay" "=leblebi" "=fixed" "=liar" "=boom" "=gunner"; do run --chapter=15 --autotest$v; done
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
run --chapter=13 --autotest=next
run --chapter=14 --autotest=next
exit $fail
