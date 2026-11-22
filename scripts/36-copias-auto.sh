#!/bin/bash
# 36-copias-auto.sh · P14c (a105, Apte+): copias automáticas que lanza cron en Server-Monitorizacion.
#   1) Firewall activo (30-copia-firewall.sh)      → TrueNAS copias/fw*/
#   2) Server-Monitorizacion (32-copia-srv-mon.sh)  → TrueNAS copias/srv-mon/
#   3) Configuración de los nodos Proxmox (si están encendidos) → TrueNAS copias/proxmox/config/ (por su NFS)
#   4) Configuración de TrueNAS por su API          → FUERA del NAS: ~/copias-truenas/ en srv-mon
#   5) Limpieza: se borran las copias de más de DIAS días (en el NAS y en ~/copias-truenas)
# Las VMs de Proxmox las copia el propio Proxmox (tarea «copias-semanal», domingo 02:00).
# Si una parte falla, se apunta en el log y se sigue con las demás. Sin contraseñas (claves SSH y de API).
set -uo pipefail
umask 077   # las copias (llevan configuración) solo las puede leer asier

DIAS=30
LOG=~/copias.log
BIN=~/bin
ERR=0
log() { echo "$(date '+%F %T') $*" >> "$LOG"; }
paso() {   # paso <nombre> <orden…>: ejecuta y apunta OK/ERROR
    local n=$1; shift
    if "$@" >/dev/null 2>>"$LOG.err"; then log "OK    $n"; else log "ERROR $n (ver $LOG.err)"; ERR=1; fi
}
s() { ssh -o BatchMode=yes -o ConnectTimeout=5 "$@"; }

log "=== Inicio de las copias automáticas"
paso firewall "$BIN/30-copia-firewall.sh"
paso srv-mon  "$BIN/32-copia-srv-mon.sh"

for n in pve1 pve2 pve3; do
    if s "$n" true 2>/dev/null; then
        paso "proxmox-$n" s "$n" 'tar czf /mnt/pve/copias-nas/config/$(date +%F_%H%M)_$(hostname)-config.tar.gz /etc/pve /etc/network/interfaces /etc/hosts /etc/hostname /etc/apt/sources.list.d 2>/dev/null'
    else
        log "--    proxmox-$n apagado: no se copia"
    fi
done

truenas() {
    local k; k=$(sed -n 's/^key=//p' ~/.config/copias/truenas-api.txt)
    mkdir -p ~/copias-truenas
    curl -sfk --max-time 60 -X POST -K <(printf 'header = "Authorization: Bearer %s"\n' "$k") \
        -H 'Content-Type: application/json' -d '{"secretseed": false}' \
        https://192.168.21.20/api/v2.0/config/save -o ~/copias-truenas/"$(date +%F_%H%M)"_truenas-config.db
}
paso truenas-config truenas

# Limpieza (rotación): así el pool de 18 GB no se llena
paso limpieza-nas s nas "find /mnt/copias/fw1-mikrotik /mnt/copias/fw2-opnsense /mnt/copias/fw3-debian /mnt/copias/srv-mon -type f -mtime +$DIAS -delete"
find ~/copias-truenas -type f -mtime +$DIAS -delete

log "=== Fin ($([ $ERR -eq 0 ] && echo 'todo OK' || echo 'CON ERRORES'))"
exit $ERR
