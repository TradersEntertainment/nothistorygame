#!/bin/bash
# sirali.sh ONEK COZ SET "i j k" : her çekimi ayrı kayda alır (kayit/ONEK_i), bitince liste.md'ye yazar
F=/tmp/claude-0/-home-user-mstrbought/30127caa-76dd-5459-81fb-4bbd5156d7e0/scratchpad/fragman2
P=$1; RES=$2; SETN=$3; shift 3
for i in $1; do
  SET=$SETN TMO=${TMO:-2400} $F/kaydet.sh ${P}_$i $RES only=$i $EXTRA > $F/kayit/${P}_$i.run 2>&1
  echo "- kayıt ${P}_$i ($RES, set=$SETN only=$i) bitti: $(head -1 $F/kayit/${P}_$i.run) $(grep -o 'id=[a-z_0-9]*' $F/kayit/${P}_$i.log | head -1)" >> $F/liste.md
  echo "BITTI ${P}_$i"
done
echo HEPSI_BITTI
