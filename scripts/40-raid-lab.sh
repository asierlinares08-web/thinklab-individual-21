#!/bin/bash
# 40-raid-lab.sh · P15 (a102, a103): laboratorio RAID 0, 1 y 5 con mdadm en Server-Monitorizacion.
# Se ejecuta como root. Usa los 7 discos virtuales de 1 GB (sdb…sdh), que son SOLO de prueba:
#   RAID 0 → sdb sdc · RAID 1 → sdd sde · RAID 5 → sdf sdg sdh
# Para cada RAID: crear → formatear → montar → fichero de prueba con su SHA-256 → velocidad de escritura.
# Verificación: en RAID 1 y 5 se marca un disco como fallido, se ve el estado degradado, se comprueba que
# el fichero sigue igual y se reconstruye. En RAID 0 se quita un disco y se ve que el RAID ya no arranca.
# Al final RAID 1 y RAID 5 quedan en /etc/mdadm/mdadm.conf (arrancan solos); sdb y sdc quedan libres (P19).
set -euo pipefail
export LC_ALL=C
t() { echo; echo "=================== $* ($(date +%T))"; }
espera() { while grep -qE 'resync|recovery' /proc/mdstat; do sleep 2; done; }   # espera a que acabe la sincronización

t "0. Preparación"
command -v mdadm >/dev/null || DEBIAN_FRONTEND=noninteractive apt-get install -y -qq mdadm >/dev/null
mdadm --version 2>&1
for d in sdb sdc sdd sde sdf sdg sdh; do
    [ "$(lsblk -no SIZE /dev/$d | tr -d ' ')" = "1G" ] || { echo "/dev/$d no es un disco de 1 GB: paro"; exit 1; }
    findmnt -S /dev/$d >/dev/null && { echo "/dev/$d está montado: paro"; exit 1; }
done
lsblk -o NAME,SIZE,TYPE /dev/sd[b-h]

crear() {   # crear <md> <nivel> <discos…>
    local md=$1 nivel=$2; shift 2
    t "Crear /dev/$md (RAID $nivel) con $*"
    mdadm --create /dev/$md --level=$nivel --raid-devices=$# --run "${@/#//dev/}" </dev/null 2>&1 | grep -v '^$' || true
    espera
    mkfs.ext4 -q -L raid$nivel /dev/$md
    mkdir -p /mnt/raid$nivel && mount /dev/$md /mnt/raid$nivel
    head -c 50M /dev/urandom > /mnt/raid$nivel/prueba.bin
    ( cd /mnt/raid$nivel && sha256sum prueba.bin > prueba.sha256 )
    cat /proc/mdstat | grep -A2 "^$md"
    mdadm --detail /dev/$md | grep -E 'Raid Level|Array Size|Raid Devices|State :|Chunk Size'
    df -h /mnt/raid$nivel | tail -1
    echo -n "Escritura 200 MB (oflag=direct): "
    dd if=/dev/zero of=/mnt/raid$nivel/velocidad.tmp bs=1M count=200 oflag=direct 2>&1 | tail -1
    rm /mnt/raid$nivel/velocidad.tmp
}

t "Referencia: velocidad de un disco solo (sdh, antes de usarlo)"
dd if=/dev/zero of=/dev/sdh bs=1M count=200 oflag=direct 2>&1 | tail -1

crear md0 0 sdb sdc
crear md1 1 sdd sde
crear md5 5 sdf sdg sdh

fallo() {   # fallo <md> <nivel> <disco>
    local md=$1 nivel=$2 d=$3
    t "Fallo controlado en /dev/$md (RAID $nivel): se marca /dev/$d como fallido"
    mdadm /dev/$md --fail /dev/$d 2>&1
    grep -A2 "^$md" /proc/mdstat
    mdadm --detail /dev/$md | grep -E 'State :|Failed Devices'
    echo "¿Los datos siguen bien con el RAID degradado?"; ( cd /mnt/raid$nivel && sha256sum -c prueba.sha256 )
    t "Reconstrucción de /dev/$md: quitar $d y volver a añadirlo (como si fuera un disco nuevo)"
    mdadm /dev/$md --remove /dev/$d 2>&1
    mdadm --zero-superblock /dev/$d
    local ini=$(date +%s)
    mdadm /dev/$md --add /dev/$d 2>&1
    sleep 1; grep -A3 "^$md" /proc/mdstat
    espera
    echo "Reconstrucción terminada en $(( $(date +%s) - ini )) s"
    grep -A2 "^$md" /proc/mdstat
    mdadm --detail /dev/$md | grep -E 'State :|Active Devices|Failed Devices'
    ( cd /mnt/raid$nivel && sha256sum -c prueba.sha256 )
}
fallo md1 1 sde
fallo md5 5 sdg

t "Fallo en RAID 0: no tiene redundancia"
echo "mdadm no deja marcar un disco como fallido en RAID 0:"
mdadm /dev/md0 --fail /dev/sdc 2>&1 || true
echo "Simulamos que el disco sdc se rompe: se desmonta, se para el RAID y se borra sdc."
umount /mnt/raid0; mdadm --stop /dev/md0 2>&1
mdadm --zero-superblock /dev/sdc; wipefs -qa /dev/sdc
echo "Intento de volver a montar el RAID 0 solo con sdb:"
mdadm --assemble /dev/md0 /dev/sdb 2>&1 || true
mdadm --assemble --run /dev/md0 /dev/sdb 2>&1 || true
grep -q '^md0' /proc/mdstat && { cat /proc/mdstat; mdadm --stop /dev/md0; } || echo "md0 no existe: el RAID 0 y sus datos se han perdido."
mdadm --zero-superblock /dev/sdb 2>/dev/null || true; wipefs -qa /dev/sdb
echo "sdb y sdc quedan libres (se usarán en el P19)."

t "Persistencia: RAID 1 y RAID 5 arrancan solos"
sed -i '/^ARRAY/d' /etc/mdadm/mdadm.conf
mdadm --detail --scan | grep -E 'md1|md5' >> /etc/mdadm/mdadm.conf
grep ^ARRAY /etc/mdadm/mdadm.conf | sed -E 's/UUID=[0-9a-f:]+/UUID=…/'
grep -q raid1 /etc/fstab || printf 'LABEL=raid1 /mnt/raid1 ext4 defaults,nofail 0 2\nLABEL=raid5 /mnt/raid5 ext4 defaults,nofail 0 2\n' >> /etc/fstab
update-initramfs -u 2>&1 | tail -1

t "Estado final"
cat /proc/mdstat
df -h /mnt/raid1 /mnt/raid5 | sed 1d
