#!/bin/bash
# 30-copia-firewall.sh · P14a / P14c (a208, a215, a222, a105)
# Copia la configuración del firewall que esté encendido (siempre es 192.168.21.1)
# y la guarda con fecha en TrueNAS: /mnt/copias/<equipo>/AAAA-MM-DD_HHMM_*
#
# Se ejecuta en Server-Monitorizacion como asier. No lleva contraseñas:
#  - FW1 y FW3: SSH con clave (~/.ssh/config: hosts fw1 y fw3, cada uno con su HostKeyAlias).
#    Si la clave de host no coincide (está encendido otro firewall), SSH se niega y se prueba el siguiente.
#  - FW2 (OPNsense): API HTTPS con el usuario «copias» (solo privilegios de copias).
#    La clave de la API está en ~/.config/copias/opnsense-api.txt (permisos 600), fuera del repo.
#  - TrueNAS: SSH con clave (host nas, usuario asier).
set -euo pipefail

DEST=/mnt/copias
FECHA=$(date +%F_%H%M)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
LOG=~/copias.log
s() { ssh -o BatchMode=yes -o ConnectTimeout=5 "$@"; }

if s fw3 true 2>/dev/null; then
    EQ=fw3-debian
    # Ficheros de configuración (los demás se reinstalan desde la ISO) + lista de paquetes
    s fw3 'tar czf - /etc/nftables.conf /etc/network/interfaces /etc/sysctl.d 2>/dev/null' > "$TMP/${FECHA}_fw3-config.tar.gz"
    s fw3 'dpkg --get-selections' > "$TMP/${FECHA}_fw3-paquetes.txt"
elif s fw1 '/system identity print' >/dev/null 2>&1; then
    EQ=fw1-mikrotik
    # Texto legible (sin datos sensibles) + copia binaria completa
    s fw1 '/export terse' > "$TMP/${FECHA}_fw1-export.rsc"
    s fw1 "/system backup save name=copia-$FECHA" >/dev/null
    sleep 3
    scp -q -o BatchMode=yes "fw1:copia-$FECHA.backup" "$TMP/${FECHA}_fw1.backup"
    s fw1 "/file remove copia-$FECHA.backup"
else
    EQ=fw2-opnsense
    API=~/.config/copias/opnsense-api.txt
    # La clave va en un fichero de configuración de curl (-K), no en la línea de órdenes (no sale en «ps»)
    curl -sf -k --max-time 20 -K <(printf 'user = "%s:%s"\n' "$(sed -n 's/^key=//p' "$API")" "$(sed -n 's/^secret=//p' "$API")") \
        https://192.168.21.1/api/core/backup/download/this -o "$TMP/${FECHA}_fw2-config.xml"
    grep -q '<opnsense>' "$TMP/${FECHA}_fw2-config.xml"   # que sea un config.xml de verdad
fi

# Huella de cada fichero, para comprobar después que la copia no ha cambiado
( cd "$TMP" && sha256sum -- * > "${FECHA}_sha256.txt" )
scp -q -o BatchMode=yes "$TMP"/* "nas:$DEST/$EQ/"
s nas "chmod 700 $DEST/$EQ && cd $DEST/$EQ && sha256sum -c --quiet ${FECHA}_sha256.txt"

echo "$(date '+%F %T') OK $EQ $(cd "$TMP" && ls | tr '\n' ' ')" | tee -a "$LOG"
