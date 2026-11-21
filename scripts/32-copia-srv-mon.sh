#!/bin/bash
# 32-copia-srv-mon.sh · P14b / P14c (a245, a105)
# Copia la configuración de Server-Monitorizacion (el propio equipo) en TrueNAS:
#   /mnt/copias/srv-mon/AAAA-MM-DD_HHMM_srv-mon.tar.gz + su SHA-256
# Se ejecuta como asier (sin sudo): /etc se copia entero MENOS lo que solo puede leer root
# (shadow, claves de host…), que es justo lo que no conviene sacar del equipo.
# NO se copian la clave privada SSH ni la clave de la API de OPNsense: se regeneran si hace falta.
set -euo pipefail

DEST=/mnt/copias/srv-mon
FECHA=$(date +%F_%H%M)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
F="${FECHA}_srv-mon.tar.gz"

crontab -l > "$TMP/crontab-asier.txt" 2>/dev/null || echo "(sin crontab)" > "$TMP/crontab-asier.txt"
dpkg --get-selections > "$TMP/paquetes.txt"
cat /proc/mdstat > "$TMP/mdstat.txt" 2>/dev/null || true

# tar avisa de los ficheros que no puede leer (los de root): se ignoran a propósito
tar czf "$TMP/$F" --ignore-failed-read \
    /etc ~/bin ~/.ssh/config ~/.ssh/id_ed25519.pub ~/.ssh/authorized_keys \
    -C "$TMP" crontab-asier.txt paquetes.txt mdstat.txt 2>/dev/null || [ $? -eq 1 ]

( cd "$TMP" && sha256sum "$F" > "${FECHA}_sha256.txt" )
scp -q -o BatchMode=yes "$TMP/$F" "$TMP/${FECHA}_sha256.txt" "nas:$DEST/"
ssh -o BatchMode=yes nas "chmod 700 $DEST && cd $DEST && sha256sum -c --quiet ${FECHA}_sha256.txt"

echo "$(date '+%F %T') OK srv-mon $F $(du -h "$TMP/$F" | cut -f1)" | tee -a ~/copias.log
