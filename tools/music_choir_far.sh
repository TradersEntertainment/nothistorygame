#!/usr/bin/env bash
# Müzikteki koroyu (ör. mehterin "hey hoy" naraları) uzaklaştırır: demucs ile vokali ayırır, kısar, tizini keser,
# yankı ve sağ-sol bağımsız dalgalanma verir (ordu uzakta, ses rüzgârla gelip gider), çalgıyla yeniden karıştırır.
#   tools/music_choir_far.sh docs/music/takes/march_heavy_2.mp3 assets/audio/music/march_ottoman.mp3
# Gerekir: python -m demucs (pip install demucs; torch CPU yeterli, 2 dk'lık parça birkaç dakika sürer)
set -euo pipefail
src=$1; dst=$2; py=${DEMUCS_PY:-python3}
w=$(mktemp -d)
$py -m demucs --two-stems=vocals -n htdemucs -o "$w" "$src" >/dev/null
d="$w/htdemucs/$(basename "${src%.*}")"
VL="max(0.06,0.27+0.12*sin(2*PI*0.09*t)+0.08*sin(2*PI*0.23*t+1.3)+0.05*sin(2*PI*0.51*t+2.1))"
VR="max(0.06,0.27+0.12*sin(2*PI*0.07*t+2.4)+0.08*sin(2*PI*0.29*t+0.4)+0.05*sin(2*PI*0.47*t+4.0))"
ffmpeg -loglevel error -y -i "$d/vocals.wav" -i "$d/no_vocals.wav" -filter_complex \
"[0:a]highpass=f=240,lowpass=f=2600,adelay=70|110,aecho=0.8:0.55:90|170|260:0.32|0.22|0.14,channelsplit=channel_layout=stereo[l][r];\
[l]volume='$VL':eval=frame[l2];[r]volume='$VR':eval=frame[r2];[l2][r2]join=inputs=2:channel_layout=stereo[v];\
[1:a][v]amix=inputs=2:normalize=0:duration=first[m]" -map "[m]" "$w/mix.wav"
m=$(ffmpeg -hide_banner -i "$w/mix.wav" -af loudnorm=I=-16:TP=-1:LRA=11:print_format=json -f null - 2>&1 | sed -n '/{/,/}/p' |
  python3 -c "import json,sys;d=json.load(sys.stdin);print(':'.join(f'{k}={d[v]}' for k,v in [('measured_I','input_i'),('measured_TP','input_tp'),('measured_LRA','input_lra'),('measured_thresh','input_thresh'),('offset','target_offset')]))")
ffmpeg -loglevel error -y -i "$w/mix.wav" -af "loudnorm=I=-16:TP=-1:LRA=11:$m:linear=true" -ar 44100 -c:a libmp3lame -b:a 192k "$dst"
rm -rf "$w"
echo "yazıldı: $dst"
