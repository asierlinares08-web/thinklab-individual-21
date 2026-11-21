#!/bin/bash
# =====================================================================
# P11a · Preparar un nodo Proxmox VE 9 (Debian 13 «trixie») del laboratorio
# ---------------------------------------------------------------------
# Qué hace (en este orden):
#   1. Muestra la versión de Proxmox ANTES (pveversion).
#   2. Desactiva los repositorios «enterprise» de pve y de ceph
#      (necesitan suscripción de pago; sin ella apt da error 401).
#   3. Añade el repositorio gratuito «pve-no-subscription» para trixie.
#   4. Añade 1.1.1.1 como DNS secundario (el instalador solo deja poner uno).
#   5. apt update + apt full-upgrade.
#   6. Muestra la versión DESPUÉS y avisa si hace falta reiniciar.
#
# Se puede ejecutar dos veces: cada paso mira antes si ya está hecho
# y no duplica nada.
#
# Uso (como root, dentro del nodo):
#   wget -qO- https://raw.githubusercontent.com/asierlinares08-web/thinklab-individual-21/main/configs/proxmox/p11a-nodo.sh | bash
# No lleva contraseñas: el repositorio es público.
# =====================================================================

# Todo va dentro de una función que se llama al final. Así bash lee el
# script ENTERO antes de ejecutar nada, y si apt lee de la entrada
# estándar no se «come» las líneas que faltan (pasa con «wget | bash»).
principal() {
  set -u
  DIR=/etc/apt/sources.list.d

  echo "===== 1. Versión ANTES ($(hostname -f)) ====="
  pveversion

  echo "===== 2. Repositorios enterprise (pve y ceph) → desactivados ====="
  for f in "$DIR/pve-enterprise.sources" "$DIR/ceph.sources"; do
    [ -f "$f" ] || { echo "  $f no existe: nada que hacer"; continue; }
    # Solo se toca si el fichero es del repositorio enterprise
    grep -q 'enterprise.proxmox.com' "$f" || { echo "  $f no es enterprise: no se toca"; continue; }
    if grep -qiE '^Enabled:[[:space:]]*(no|false)' "$f"; then
      echo "  $f ya estaba desactivado"
    elif grep -qi '^Enabled:' "$f"; then
      sed -i -E 's/^Enabled:.*/Enabled: no/I' "$f"      # cambia el valor que hubiera
      echo "  $f desactivado (Enabled: no)"
    else
      echo "Enabled: no" >> "$f"                         # añade la línea si no existía
      echo "  $f desactivado (Enabled: no)"
    fi
  done

  echo "===== 3. Repositorio pve-no-subscription ====="
  if grep -qs 'pve-no-subscription' "$DIR"/*.sources; then
    echo "  Ya estaba (lo puso la WebUI o una ejecución anterior)"
  else
    # Formato deb822 (el de Debian 13 / Proxmox 9). Clave oficial que ya trae Proxmox.
    cat > "$DIR/proxmox.sources" <<'EOF'
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: trixie
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF
    echo "  Creado $DIR/proxmox.sources"
  fi

  echo "===== 4. DNS secundario 1.1.1.1 ====="
  # Proxmox guarda el DNS en /etc/resolv.conf (lo mismo que enseña System → DNS)
  if grep -q '^nameserver 1\.1\.1\.1' /etc/resolv.conf; then
    echo "  Ya estaba"
  else
    echo "nameserver 1.1.1.1" >> /etc/resolv.conf
    echo "  Añadido"
  fi
  cat /etc/resolv.conf

  echo "===== Repositorios ACTIVOS ====="
  apt-get update -qq </dev/null && echo "  apt update sin errores"
  apt-cache policy </dev/null | grep -E '^ *[0-9]+ http' | sort -u

  echo "===== 5. Actualizar (apt full-upgrade) ====="
  # noninteractive + confold: no pregunta nada y conserva los ficheros de config actuales
  DEBIAN_FRONTEND=noninteractive apt-get -y \
    -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold \
    full-upgrade </dev/null
  echo "  Paquetes que quedan por actualizar: $(apt list --upgradable 2>/dev/null </dev/null | grep -c upgradable)"

  echo "===== 6. Versión DESPUÉS ====="
  pveversion
  NUEVO=$(ls /boot/vmlinuz-* 2>/dev/null | sed 's|/boot/vmlinuz-||' | sort -V | tail -1)
  if [ "$NUEVO" != "$(uname -r)" ]; then
    echo ">>> Kernel nuevo instalado ($NUEVO, ahora corre $(uname -r)): REINICIA con «reboot»"
  else
    echo ">>> Mismo kernel: no hace falta reiniciar"
  fi
}

principal 2>&1 | tee "/root/p11a-$(hostname)-$(date +%F_%H%M).log"
