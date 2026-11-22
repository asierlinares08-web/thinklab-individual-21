#!/bin/bash
# 50-medir-rendimiento.sh <escenario> <segundos> · P17/P18 (a22, a23, a119, a120, a125)
# Mide el ANFITRIÓN mientras hay VMs encendidas: CPU, RAM, swap, disco, red y «bloqueo».
# Muestra cada 5 s con vmstat, iostat -x (disco donde están las VMs) y sar -n DEV (tarjeta de red real).
# «Bloqueo» = latencia del anfitrión: cuánto se retrasa un «sleep 0.1» (si la CPU está saturada, se retrasa).
# Uso: scripts/50-medir-rendimiento.sh B-cluster 120   → evidencias/tasca7/AAAA-MM-DD_rendimiento-B-cluster.txt
# No necesita sudo. Herramientas: procps (vmstat), sysstat (iostat, sar).
set -euo pipefail
ESC=${1:?escenario}; SEG=${2:-60}; INT=5; N=$(( SEG / INT ))
cd "$(dirname "$0")/.."
OUT="evidencias/tasca7/$(date +%F)_rendimiento-$ESC.txt"; mkdir -p evidencias/tasca7
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
DISCO=$(lsblk -no PKNAME "$(df --output=source "$HOME/VirtualBox VMs" | tail -1)")
RED=$(ip route show default | awk '{print $5; exit}')

LC_ALL=C vmstat -w $INT $((N+1)) > "$TMP/vmstat" &
LC_ALL=C iostat -dxy $INT $N "$DISCO" > "$TMP/iostat" &
LC_ALL=C sar -n DEV $INT $N > "$TMP/sar" 2>/dev/null &
for i in $(seq 1 $N); do   # latencia: ms de más que tarda «sleep 0.1»
    a=$(date +%s%N); sleep 0.1; b=$(date +%s%N); echo $(( (b - a) / 1000000 - 100 )) >> "$TMP/lat"; sleep $((INT - 1))
done
wait

set +e   # el resumen sigue aunque falte algún dato
{
echo "# Rendimiento del anfitrión · escenario $ESC · $(date '+%F %T') · ${SEG} s (muestras cada ${INT} s)"
echo "Anfitrión: $(nproc) hilos de CPU · $(free -g | awk '/^Mem/{print $2}') GiB de RAM · disco de las VMs: /dev/$DISCO · red: $RED"
echo "VMs encendidas:"; VBoxManage list runningvms | cut -d'"' -f2 | sed 's/^/  - /'
echo "RAM asignada a las VMs encendidas: $(for v in $(VBoxManage list runningvms | awk '{print $NF}'); do VBoxManage showvminfo "$v" --machinereadable | sed -n 's/^memory=//p'; done | awk '{s+=$1} END{printf "%.1f GiB", s/1024}')"
echo
awk '$1 ~ /^[0-9]+$/ && ++k>1 {n++; us+=$13; sy+=$14; id+=$15; wa+=$16; r+=$1; if($1>rm)rm=$1; fr=$4; if(min==""||$4<min)min=$4; sw=$3; if($3>swm)swm=$3; si+=$7; so+=$8}
     END {printf "CPU: usuario %.0f %% · sistema %.0f %% · libre %.0f %% · espera de disco (wa) %.0f %%\n", us/n, sy/n, id/n, wa/n;
          printf "Procesos esperando CPU (r): media %.1f · máximo %d (hay %d hilos)\n", r/n, rm, '"$(nproc)"';
          printf "RAM libre (free): mínimo %.1f GiB · swap usada: máx %.2f GiB · swap in/out: %d / %d KB/s de media\n", min/1048576, swm/1048576, si/n, so/n}' "$TMP/vmstat"
awk -v d="$DISCO" '$1==d {n++; u+=$NF; if($NF>um)um=$NF; rk+=$3; wk+=$9; ra+=$6; wa+=$12}
     END {if(n) printf "Disco /dev/%s: uso (%%util) media %.0f %% · máx %.0f %% · lectura %.1f MB/s · escritura %.1f MB/s · espera media r/w %.1f / %.1f ms\n", d, u/n, um, rk/n/1024, wk/n/1024, ra/n, wa/n}' "$TMP/iostat"
awk -v i="$RED" '$0 ~ /^Average|^Media/ && $2==i {printf "Red %s: recibe %.1f kB/s · envía %.1f kB/s (media)\n", i, $5, $6}' "$TMP/sar"
sort -n "$TMP/lat" | awk '{a[NR]=$1; s+=$1} END {printf "Latencia del anfitrión («bloqueo»): media %.0f ms · máxima %d ms de retraso sobre 100 ms\n", s/NR, a[NR]}'
echo; echo "--- vmstat (cada ${INT} s)"; cat "$TMP/vmstat"
echo; echo "--- iostat -dxy /dev/$DISCO"; grep -E "^Device|^$DISCO" "$TMP/iostat"
} | tee "$OUT"
