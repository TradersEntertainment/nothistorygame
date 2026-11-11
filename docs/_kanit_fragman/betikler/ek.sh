#!/bin/bash
while pgrep -f "kuyruk.sh|sonra.sh" >/dev/null; do sleep 20; done
/tmp/fragman2/kuyruk.sh "$@"
