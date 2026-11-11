#!/bin/bash
# kurgu.sh CIKTI [--dry] : fragman_tr_v2 kurgusu (sıra ve kırpmalar rapor.md'deki tabloyla aynı)
K=/tmp/fragman2/kayit
P=${PATLAMA:-b12v}
cd /home/user/nothistorygame
python3 tools/trailer/story_cut.py "$@" \
  "$K/a0.avi:$K/a0.log:kanca_bu_benim:0.866:0.35" \
  "$K/b13.avi:$K/b13.log:kizak_kayis_uzun:5.016:0.7" \
  "$K/b14.avi:$K/b14.log:havlu_ok3:1.096:0.567" \
  "$K/a3.avi:$K/a3.log:vlad_kazik:1.216:5.183:::D17E_T_POL_2=Prim, teminat, muafiyet." \
  "$K/b4.avi:$K/b4.log:sahi_hey:0.016:3.0" \
  "$K/b8v.avi:$K/b8v.log:buro_atisma2:3.466:0.867::Zaman Bürosu:BUR_FG_NAP_3=Yazdım mı? Yazdım. Moskova'dan yürüyerek döndüm; ayaklarımla yazdım!" \
  "$K/b9.avi:$K/b9.log:kurek17:0.766:1.8" \
  "$K/a5.avi:$K/a5.log:otag_sali:2.066:4.367:::D12_F_KEY=Bu şehir alınacak mı?¦D12_T_KEY_B_NOBOOK=Evet. 29 Mayıs'ta. Salı günü." \
  "$K/b5.avi:$K/b5.log:fren_ipi:0.0:5.0" \
  "$K/$P.avi:$K/$P.log:patlama:${PK0:-0.0}:${PK1:-0.65}" \
  "$K/a4.avi:$K/a4.log:hikmet_1977:0.666:0.567:::D15_S7_YH_5=İleride bir garajım olacak. İçine bir makine yapacağım. Onu da sigortalar mısın?" \
  "$K/a7v.avi:$K/a7v.log:flight:0.5:0.3:sessiz" \
  "$K/a6.avi:$K/a6.log:card"
