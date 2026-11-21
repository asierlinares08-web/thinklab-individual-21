#!/usr/bin/env bash
# =============================================================================
# captura.sh — Evidencias gráficas (todas las tareas)
# Hace una captura PNG y la guarda en evidencias/tascaN/AAAA-MM-DD_descripcion.png
# sin sobrescribir nunca nada (si ya existe, añade _2, _3...).
#
# Uso:
#   ./scripts/captura.sh <tasca> <descripcion> vm <nombre_vm>
#       → captura la pantalla de una VM de VirtualBox (VBoxManage screenshotpng).
#         No hace falta tocar nada; la VM tiene que estar encendida.
#   ./scripts/captura.sh <tasca> <descripcion> ventana
#       → espera 3 segundos y captura la ventana activa del anfitrión
#         (da tiempo a poner el navegador delante).
#
# Ejemplos:
#   ./scripts/captura.sh 5 opnsense-version vm FW2-OPNsense
#   ./scripts/captura.sh 5 truenas-dataset-copias ventana
#
# Al final escribe la ruta del PNG, para revisarlo e insertarlo en el .md.
# =============================================================================
set -u
TASCA="${1:-}"; DESC="${2:-}"; MODO="${3:-}"; VM="${4:-}"

uso() { sed -n '8,16p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }
[[ "$TASCA" =~ ^[0-9]+$ ]] || { echo "ERROR: <tasca> tiene que ser un número (0-8)."; uso; }
[ -n "$DESC" ] || { echo "ERROR: falta <descripcion>."; uso; }
[[ "$MODO" == "vm" || "$MODO" == "ventana" ]] || { echo "ERROR: <modo> tiene que ser 'vm' o 'ventana'."; uso; }

# Descripción segura para un nombre de fichero: minúsculas, espacios → guiones
DESC=$(echo "$DESC" | tr '[:upper:] ' '[:lower:]-' | tr -cd 'a-z0-9_-')
[ -n "$DESC" ] || { echo "ERROR: la descripción solo puede llevar letras sin tilde, números, '-' y '_'."; exit 1; }

RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
DIR="$RAIZ/evidencias/tasca$TASCA"; mkdir -p "$DIR"
BASE="$DIR/$(date +%F)_$DESC"
FICH="$BASE.png"; n=2
while [ -e "$FICH" ]; do FICH="${BASE}_$n.png"; n=$((n+1)); done   # nunca sobrescribe

case "$MODO" in
  vm)
    [ -n "$VM" ] || { echo "ERROR: en modo 'vm' hay que indicar el nombre de la VM."; exit 1; }
    command -v VBoxManage >/dev/null || { echo "ERROR: VBoxManage no está instalado."; exit 1; }
    INFO=$(VBoxManage showvminfo "$VM" --machinereadable 2>/dev/null) \
      || { echo "ERROR: no existe la VM '$VM'."; exit 1; }
    # Regla del proyecto: solo VMs del grupo /ThinkLab-asier
    echo "$INFO" | grep -q '^groups="/ThinkLab-asier' \
      || { echo "ERROR: '$VM' no está en el grupo /ThinkLab-asier; no se toca."; exit 1; }
    echo "$INFO" | grep -q '^VMState="running"' \
      || { echo "ERROR: la VM '$VM' no está encendida."; exit 1; }
    VBoxManage controlvm "$VM" screenshotpng "$FICH" || { echo "ERROR: falló la captura."; exit 1; }
    ;;
  ventana)
    if command -v gnome-screenshot >/dev/null; then
      echo "Pon delante la ventana que quieres capturar: en 3 segundos se hace la captura..."
      gnome-screenshot -w -d 3 -f "$FICH" 2>/dev/null
    elif command -v scrot >/dev/null; then
      echo "Pon delante la ventana que quieres capturar: en 3 segundos se hace la captura..."
      scrot -u -d 3 "$FICH"
    else
      echo "ERROR: no hay gnome-screenshot ni scrot (no se instala nada solo)."; exit 1
    fi
    [ -s "$FICH" ] || { echo "ERROR: no se ha creado la captura."; exit 1; }
    ;;
esac

echo "Captura guardada: ${FICH#$RAIZ/}"
echo "Ahora: revisar que se ve lo que hay que demostrar y que NO sale ninguna contraseña."
