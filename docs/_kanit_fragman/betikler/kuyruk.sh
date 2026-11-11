#!/bin/bash
# kuyruk.sh "AD:SET:ONLY[:ek]" ...
F=/tmp/fragman2
for j in "$@"; do
  IFS=: read AD S O EK <<< "$j"
  SET=$S $F/kaydet.sh $AD 1920x1080 only=$O $EK > $F/kayit/$AD.run 2>&1
  echo "- $(date +%H:%M) kayıt $AD (set=$S only=$O $EK): $(head -1 $F/kayit/$AD.run) $(grep -o 'id=[a-z_0-9]*' $F/kayit/$AD.log | head -1)" >> $F/liste.md
done
echo HEPSI_BITTI >> $F/liste.md
