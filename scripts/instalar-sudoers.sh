#!/usr/bin/env bash
# =============================================================================
# instalar-sudoers.sh — Fase 1 (P1/P5)
# Instala la regla de sudoers que deja ejecutar SIN contraseña SOLO las copias
# de root de 01-inventario-hw.sh y 02-tests-diagnostico.sh (clase|casa).
# Uso:  sudo ./scripts/instalar-sudoers.sh
# Se vuelve a lanzar cada vez que cambien esos dos scripts del repo.
# Para quitarlo (P20): sudo rm /etc/sudoers.d/thinklab-asier && sudo rm -r /usr/local/lib/thinklab-asier
# =============================================================================
set -e
paso() { echo; echo ">>> PASO $1: $2"; }
trap 'echo; echo "!!! FALLO en el paso anterior (línea $LINENO). No se ha completado la instalación."' ERR

[ "$EUID" -eq 0 ] || { echo "Hay que lanzarlo con sudo: sudo $0"; exit 1; }
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
DEST=/usr/local/lib/thinklab-asier
REGLA="$RAIZ/scripts/sudoers-thinklab-asier"
echo "Proyecto: $RAIZ"

paso 1 "Crear $DEST (propiedad de root, 755)"
install -d -o root -g root -m 755 "$DEST"

paso 2 "Copiar los 2 scripts como root (755): el usuario no podrá modificarlos"
install -o root -g root -m 755 "$RAIZ/scripts/01-inventario-hw.sh" "$RAIZ/scripts/02-tests-diagnostico.sh" "$DEST/"

paso 3 "Poner RAIZ_FIJA=$RAIZ en las copias (para que guarden las evidencias en el repo)"
sed -i "s|^RAIZ_FIJA=.*|RAIZ_FIJA=\"$RAIZ\"|" "$DEST/01-inventario-hw.sh" "$DEST/02-tests-diagnostico.sh"
grep -H '^RAIZ_FIJA=' "$DEST"/*.sh

paso 4 "Validar la regla con visudo -cf"
visudo -cf "$REGLA"

paso 5 "Instalar la regla en /etc/sudoers.d/thinklab-asier (root, 440) y validar todo sudoers"
install -o root -g root -m 440 "$REGLA" /etc/sudoers.d/thinklab-asier
visudo -c

paso 6 "apt update + instalar iperf3 nvme-cli traceroute"
apt-get update
apt-get install -y iperf3 nvme-cli traceroute

paso 7 "Comprobar lo que puede hacer el usuario ${SUDO_USER:-?} sin contraseña"
[ -n "${SUDO_USER:-}" ] && sudo -l -U "$SUDO_USER" | sed -n '/NOPASSWD/,$p'

echo; echo "=== TODO CORRECTO: instalación terminada ==="
