#!/usr/bin/env bash
# =============================================================================
# 00-comprobar-host.sh — Fase 0 / Tasca 0
# Comprueba si el anfitrión (Linux Mint + VirtualBox) está listo para el
# entorno de pruebas. SOLO LEE: no instala ni cambia nada.
# Uso:  ./scripts/00-comprobar-host.sh
# Salida: pantalla + evidencias/tasca0/AAAA-MM-DD_comprobacion-host.txt
# =============================================================================
set -u
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
SALIDA="$RAIZ/evidencias/tasca0/$(date +%F)_comprobacion-host.txt"
mkdir -p "$(dirname "$SALIDA")"

ok()    { echo "  [OK]    $*"; }
aviso() { echo "  [AVISO] $*"; }
mal()   { echo "  [FALLA] $*"; }
titulo(){ echo; echo "=== $* ==="; }

{
echo "Comprobación del anfitrión — $(date '+%F %T') — equipo: $(hostname)"

titulo "Sistema operativo"
. /etc/os-release 2>/dev/null && echo "  $PRETTY_NAME" || echo "  (sin /etc/os-release)"
echo "  Kernel: $(uname -r)"

titulo "CPU y virtualización por hardware"
echo "  Modelo: $(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)"
echo "  Núcleos físicos: $(lscpu -p=CORE 2>/dev/null | grep -v '^#' | sort -u | wc -l) · Hilos: $(nproc)"
if grep -qE 'vmx|svm' /proc/cpuinfo; then
  ok "La CPU expone VT-x/AMD-V (necesario para VMs de 64 bits y Proxmox anidado)."
else
  mal "No se ve VT-x/AMD-V: actívalo en la BIOS/UEFI (Intel VT-x / AMD SVM)."
fi
if lsmod | grep -qE '^kvm'; then
  aviso "Módulos KVM cargados ($(lsmod | awk '/^kvm/{print $1}' | xargs)). Pueden impedir arrancar VMs en VirtualBox (VERR_VMX_IN_VMX_ROOT_MODE)."
else
  ok "Sin módulos KVM cargados (no chocan con VirtualBox)."
fi

titulo "Memoria RAM"
free -h | sed 's/^/  /'
RAM_GB=$(awk '/MemTotal/{printf "%.1f", $2/1024/1024}' /proc/meminfo)
echo "  Total: ${RAM_GB} GB"
awk -v r="$RAM_GB" 'BEGIN{ if (r<12) print "  [AVISO] Menos de 12 GB: habrá que arrancar pocas VMs a la vez."; else if (r<24) print "  [OK]    RAM suficiente para escenarios de 3-5 VMs a la vez."; else print "  [OK]    RAM holgada."}'

titulo "Disco"
df -h "$HOME" | sed 's/^/  /'
if command -v VBoxManage >/dev/null; then
  CARPETA_VMS=$(VBoxManage list systemproperties | awk -F: '/Default machine folder/{print $2}' | xargs)
  echo "  Carpeta de VMs de VirtualBox: $CARPETA_VMS"
  df -h "$CARPETA_VMS" 2>/dev/null | sed 's/^/  /'
fi
echo "  (Estimación del proyecto: ~150 GB ocupados en discos dinámicos + ~25 GB de ISOs)"
lsblk -d -o NAME,SIZE,ROTA,TRAN,MODEL | sed 's/^/  /'
echo "  (ROTA=1 disco mecánico · ROTA=0 SSD/NVMe)"

titulo "VirtualBox"
if command -v VBoxManage >/dev/null; then
  ok "VirtualBox $(VBoxManage --version)"
  VBoxManage list extpacks | grep -E 'Pack no|Version' | sed 's/^/  /'
  id -nG | grep -qw vboxusers && ok "El usuario está en el grupo vboxusers." || aviso "El usuario NO está en vboxusers (solo afecta a USB)."
  echo "  Redes solo-anfitrión existentes:"
  VBoxManage list hostonlyifs | grep -E '^(Name|IPAddress|NetworkMask):' | sed 's/^/    /'
  echo "  VMs registradas: $(VBoxManage list vms | wc -l)"
else
  mal "VirtualBox no está instalado."
fi
if [ -f /etc/vbox/networks.conf ]; then
  echo "  /etc/vbox/networks.conf:"; sed 's/^/    /' /etc/vbox/networks.conf
  grep -q '192.168.21' /etc/vbox/networks.conf && ok "Permite 192.168.21.0/24." || aviso "No incluye 192.168.21.0/24 (habrá que añadirlo en la Fase 2)."
else
  aviso "No existe /etc/vbox/networks.conf: VirtualBox solo deja usar 192.168.56.0/21 en solo-anfitrión (se arregla en la Fase 2)."
fi

titulo "Git y GitHub"
command -v git >/dev/null && ok "git $(git --version | awk '{print $3}') · usuario: $(git config --global user.name || echo 'SIN CONFIGURAR')" || mal "git no instalado."
if command -v gh >/dev/null; then
  gh auth status >/dev/null 2>&1 && ok "gh autenticado en GitHub." || aviso "gh instalado pero sin login (gh auth login)."
else
  aviso "gh (GitHub CLI) no instalado: se puede crear el repo desde la web."
fi

titulo "Herramientas para Tasca 2 y Tasca 7"
FALTAN=()
for par in "dmidecode:dmidecode" "smartctl:smartmontools" "lshw:lshw" "inxi:inxi" "sensors:lm-sensors" \
           "iostat:sysstat" "sar:sysstat" "memtester:memtester" "hdparm:hdparm" "fio:fio" \
           "iperf3:iperf3" "ethtool:ethtool" "nvme:nvme-cli" "mokutil:mokutil" "traceroute:traceroute"; do
  cmd=${par%%:*}; pkg=${par##*:}
  if command -v "$cmd" >/dev/null; then ok "$cmd"; else aviso "falta $cmd (paquete $pkg)"; FALTAN+=("$pkg"); fi
done
if [ ${#FALTAN[@]} -gt 0 ]; then
  echo; echo "  Para instalar lo que falta (NO se ejecuta solo):"
  echo "  sudo apt update && sudo apt install $(printf '%s\n' "${FALTAN[@]}" | sort -u | xargs)"
fi
echo; echo "Fin de la comprobación."
} 2>&1 | tee "$SALIDA"

echo; echo "Guardado en: ${SALIDA#$RAIZ/}"
