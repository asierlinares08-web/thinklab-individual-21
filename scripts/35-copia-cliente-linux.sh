#!/bin/bash
# 35-copia-cliente-linux.sh · P14b (a255)
# Copia /home/asier de Client-Linux en TrueNAS: /mnt/copias/cliente-linux/AAAA-MM-DD_HHMM_home-asier.tar.gz
# Se ejecuta en Client-Linux como asier. Client-Linux no tiene servidor SSH: es él quien ENVÍA la copia,
# por SSH con su clave (la pública está en el usuario asier de TrueNAS). Sin contraseñas.
# NO se copian: ~/.cache (se regenera), la papelera, las descargas de ISOs ni la clave privada SSH.
set -euo pipefail

NAS=asier@192.168.21.20
DEST=/mnt/copias/cliente-linux
F="$(date +%F_%H%M)_home-asier.tar.gz"
INI=$(date +%s)

tar czf "/tmp/$F" -C "$HOME" \
    --exclude=.cache --exclude=.local/share/Trash --exclude='*.iso' --exclude=.ssh/id_ed25519 .
SUMA=$(cd /tmp && sha256sum "$F")
scp -q -o BatchMode=yes "/tmp/$F" "$NAS:$DEST/"
ssh -o BatchMode=yes "$NAS" "cd $DEST && echo '$SUMA' > ${F%.tar.gz}.sha256 && sha256sum -c ${F%.tar.gz}.sha256"
echo "Copia $F: $(du -h "/tmp/$F" | cut -f1) en $(( $(date +%s) - INI )) s"
rm -f "/tmp/$F"
