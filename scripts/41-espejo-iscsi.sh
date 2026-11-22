#!/bin/bash
# 41-espejo-iscsi.sh · P19 (a107, a108, a109, Apte+): espejo (RAID 1) entre un disco de srv-mon y un disco de TrueNAS.
# Se ejecuta como root en Server-Monitorizacion.
#   Disco local : el de 1 GB que quedó libre del laboratorio RAID (puerto SATA ata-3, por by-path: el nombre sdX cambia)
#   Disco remoto: LUN 0 del target iqn.2005-10.org.freenas.ctl:espejo de TrueNAS (192.168.21.20:3260), por iSCSI
# Resultado: /dev/md2 (RAID 1 con bitmap interno) montado en /mnt/espejo.
set -euo pipefail
export LC_ALL=C
t() { echo; echo "=================== $* ($(date +%T))"; }
NAS=192.168.21.20
TARGET=iqn.2005-10.org.freenas.ctl:espejo
LOCAL=$(readlink -f /dev/disk/by-path/pci-0000:00:0d.0-ata-3)   # puerto SATA 3 (controlador AHCI 00:0d.0)

t "1. Iniciador iSCSI (open-iscsi) con un nombre fijo"
command -v iscsiadm >/dev/null || DEBIAN_FRONTEND=noninteractive apt-get install -y -qq open-iscsi >/dev/null
echo "InitiatorName=iqn.2026-11.local.thinklab:srv-mon" > /etc/iscsi/initiatorname.iscsi
systemctl restart iscsid
cat /etc/iscsi/initiatorname.iscsi

t "2. Descubrir y conectar el target de TrueNAS (y que se conecte solo al arrancar)"
iscsiadm -m discovery -t sendtargets -p $NAS
iscsiadm -m node -T $TARGET -p $NAS --login
iscsiadm -m node -T $TARGET -p $NAS -o update -n node.startup -v automatic
systemctl enable iscsid open-iscsi >/dev/null 2>&1
sleep 3
REMOTO=$(readlink -f /dev/disk/by-path/ip-$NAS:3260-iscsi-$TARGET-lun-0)
iscsiadm -m session
echo "Disco local : $LOCAL ($(lsblk -dno SIZE,MODEL "$LOCAL"))"
echo "Disco remoto: $REMOTO ($(lsblk -dno SIZE,VENDOR,MODEL "$REMOTO"))"
[ "$(lsblk -no FSTYPE "$LOCAL")" = "" ] || { echo "El disco local no está vacío: paro"; exit 1; }

t "3. RAID 1 entre los dos (bitmap interno: si el remoto se va un rato, al volver solo se copia lo que ha cambiado)"
mdadm --create /dev/md2 --level=1 --raid-devices=2 --bitmap=internal --run "$LOCAL" "$REMOTO" </dev/null 2>&1 | grep -v '^$' | grep -v 'boot'
while grep -qE 'resync|recovery' /proc/mdstat; do sleep 2; done
mkfs.ext4 -q -L espejo /dev/md2
mkdir -p /mnt/espejo && mount /dev/md2 /mnt/espejo
cp -a /home/asier/bin /mnt/espejo/scripts-copias
head -c 100M /dev/urandom > /mnt/espejo/datos.bin
( cd /mnt/espejo && find . -type f ! -name sumas.sha256 -exec sha256sum {} + > sumas.sha256 )
grep -A3 '^md2' /proc/mdstat
mdadm --detail /dev/md2 | grep -E 'Raid Level|Array Size|State :|Active Devices|Intent Bitmap|/dev/'
df -h /mnt/espejo | tail -1

t "4. Persistencia: el disco remoto llega por la red, así que el montaje espera a la red (_netdev) y no bloquea el arranque (nofail)"
grep -q 'md2' /etc/mdadm/mdadm.conf || mdadm --detail --scan | grep md2 >> /etc/mdadm/mdadm.conf
grep -q 'LABEL=espejo' /etc/fstab || echo 'LABEL=espejo /mnt/espejo ext4 defaults,_netdev,nofail 0 0' >> /etc/fstab
grep -E 'md2' /etc/mdadm/mdadm.conf | sed -E 's/UUID=[0-9a-f:]+/UUID=…/'; grep espejo /etc/fstab
update-initramfs -u 2>&1 | tail -1
findmnt --verify 2>&1 | tail -1
