#!/bin/bash
# 42-espejo-prueba.sh <fase> · P19 (a108, a109): pruebas del espejo md2 (disco local + disco iSCSI de TrueNAS).
# Se ejecuta como root en srv-mon. El servicio iSCSI de TrueNAS se para y arranca desde fuera (API de TrueNAS).
#   estado     → cómo está el espejo y si los datos coinciden con sus SHA-256
#   escribir   → escribe un fichero nuevo (para ver que se puede trabajar con el espejo degradado)
#   readd      → vuelve a conectar el disco iSCSI y lo añade al espejo (solo copia lo cambiado: bitmap)
#   falla-local / repara-local → marca el disco LOCAL como fallido y lo vuelve a añadir
#   solo-remoto → para el espejo y lo monta SOLO con el disco de TrueNAS (¿están ahí los datos?)
#   normal     → vuelve a montar el espejo con los dos discos
set -uo pipefail
export LC_ALL=C
NAS=192.168.21.20; TARGET=iqn.2005-10.org.freenas.ctl:espejo
LOCAL=$(readlink -f /dev/disk/by-path/pci-0000:00:0d.0-ata-3)
REMOTO() { readlink -f /dev/disk/by-path/ip-$NAS:3260-iscsi-$TARGET-lun-0 2>/dev/null; }
t() { echo; echo "=================== $* ($(date +%T))"; }
estado() {
    grep -A3 '^md2' /proc/mdstat
    mdadm --detail /dev/md2 2>/dev/null | grep -E 'State :|Active Devices|Failed Devices|faulty|active sync|removed'
    if mountpoint -q /mnt/espejo; then ( cd /mnt/espejo && sha256sum -c --quiet sumas.sha256 && echo "Datos: todos los SHA-256 coinciden ($(wc -l < sumas.sha256) ficheros)" ); fi
}
case ${1:?fase} in
preparar)
    t "Si TrueNAS deja de responder, iSCSI espera 120 s por defecto antes de dar error (y mientras, el espejo se queda colgado)."
    echo "Para un disco de un RAID es mejor fallar rápido: 15 s (en la sesión actual y para las siguientes)."
    iscsiadm -m node -T $TARGET -p $NAS -o update -n node.session.timeo.replacement_timeout -v 15
    for f in /sys/class/iscsi_session/session*/recovery_tmo; do echo 15 > "$f"; echo "$f = $(cat "$f")"; done ;;
estado) t "Estado del espejo"; estado ;;
escribir)
    t "Escribir con el espejo como esté (así md detecta si falta un disco)"
    echo "Escrito el $(date)" > /mnt/espejo/escrito-$(date +%H%M%S).txt
    dd if=/dev/urandom of=/mnt/espejo/nuevo-$(date +%H%M%S).bin bs=1M count=20 oflag=direct status=none; sync
    ( cd /mnt/espejo && find . -type f ! -name sumas.sha256 -exec sha256sum {} + > sumas.sha256 )
    sleep 2; estado ;;
readd)
    t "Volver a conectar el disco iSCSI y añadirlo al espejo"
    iscsiadm -m session -r 1 --rescan >/dev/null 2>&1 || iscsiadm -m node -T $TARGET -p $NAS --login
    sleep 5; R=$(REMOTO); echo "Disco remoto: $R"
    mdadm /dev/md2 --remove failed 2>&1; mdadm /dev/md2 --remove detached 2>&1
    ini=$(date +%s.%N)
    mdadm /dev/md2 --re-add "$R" 2>&1 || mdadm /dev/md2 --add "$R" 2>&1
    sleep 1; grep -A3 '^md2' /proc/mdstat
    while grep -qE 'resync|recovery' /proc/mdstat; do sleep 0.5; done
    echo "Resincronización terminada en $(awk -v a=$ini -v b=$(date +%s.%N) 'BEGIN{printf "%.1f", b-a}') s"
    estado ;;
falla-local)
    t "Fallo del disco LOCAL ($LOCAL)"
    mdadm /dev/md2 --fail "$LOCAL" 2>&1; sleep 1; estado ;;
repara-local)
    t "Cambiar el disco local: quitarlo y volverlo a añadir"
    mdadm /dev/md2 --remove "$LOCAL" 2>&1; ini=$(date +%s)
    mdadm /dev/md2 --re-add "$LOCAL" 2>&1 || mdadm /dev/md2 --add "$LOCAL" 2>&1
    sleep 1; grep -A3 '^md2' /proc/mdstat
    while grep -qE 'resync|recovery' /proc/mdstat; do sleep 0.5; done
    echo "Reconstrucción terminada en $(( $(date +%s) - ini )) s"; estado ;;
solo-remoto)
    t "Caso de uso: srv-mon pierde su disco. ¿Se pueden recuperar los datos SOLO con el disco de TrueNAS?"
    umount /mnt/espejo; mdadm --stop /dev/md2 2>&1
    R=$(REMOTO); echo "Montar el espejo solo con el disco remoto $R:"
    mdadm --assemble --run /dev/md2 "$R" 2>&1
    mount -o ro /dev/md2 /mnt/espejo && echo "Montado en solo lectura"
    estado; ls /mnt/espejo /mnt/espejo/scripts-copias ;;
normal)
    t "Volver a la normalidad: espejo con los dos discos"
    umount /mnt/espejo; mdadm --stop /dev/md2 2>&1
    mdadm --assemble /dev/md2 "$LOCAL" "$(REMOTO)" 2>&1
    mount /mnt/espejo; estado ;;
esac
