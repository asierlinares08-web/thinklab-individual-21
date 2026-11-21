#!/usr/bin/env bash
# =============================================================================
# 01-inventario-hw.sh — Fase 1 / Tasca 2 (FDM-RA1)
# Inventario del hardware del equipo: placa, firmware y arranque, CPU,
# RAM (módulos y ampliación), discos y su salud, red, gráfica, periféricos,
# alimentación y temperaturas. SOLO LEE.
# Uso:  sudo ./scripts/01-inventario-hw.sh casa     (o: clase)
# Salida: evidencias/tasca2/AAAA-MM-DD_inventario-<equipo>.txt
# =============================================================================
set -u
export LC_ALL=C   # salida de lscpu, free… en inglés: así los grep encuentran siempre lo mismo
EQUIPO="${1:-}"
if [[ "$EQUIPO" != "casa" && "$EQUIPO" != "clase" ]]; then
  echo "Uso: sudo $0 casa|clase"; exit 1
fi
if [[ $EUID -ne 0 ]]; then
  echo "Hace falta sudo (dmidecode y smartctl leen la placa y los discos)."; exit 1
fi
# RAIZ_FIJA se rellena SOLO en la copia de root de /usr/local/lib/thinklab-asier/ (ver scripts/sudoers-thinklab-asier)
RAIZ_FIJA=""
RAIZ="${RAIZ_FIJA:-$(cd "$(dirname "$0")/.." && pwd)}"
SALIDA="$RAIZ/evidencias/tasca2/$(date +%F)_inventario-$EQUIPO.txt"
mkdir -p "$(dirname "$SALIDA")"
hay() { command -v "$1" >/dev/null; }
sec() { echo; echo "################ $* ################"; }
# Privacidad (el repo es público): nada de números de serie, identificadores únicos de disco ni MACs.
# Se aplica a TODA la salida antes de guardarla, así no se escapa nada aunque se añadan comandos.
ocultar() {
  sed -E \
    -e 's/^([[:space:]]*(Serial( Number)?|Número de serie|UUID|Asset Tag|LU WWN Device Id|IEEE OUI Identifier)[^:]*:[[:space:]]*).*/\1[OCULTO]/I' \
    -e 's/(serial|uuid)[:=][[:space:]]*[^[:space:]]+/\1: [OCULTO]/Ig' \
    -e 's/\b([0-9a-fA-F]{2}[:-]){5}[0-9a-fA-F]{2}\b/[OCULTO]/g'
}

{
echo "INVENTARIO DE HARDWARE — equipo: $EQUIPO ($(hostname)) — $(date '+%F %T')"
echo "Condiciones: uptime $(uptime -p) · carga $(cut -d' ' -f1-3 /proc/loadavg)"

sec "1. Equipo y placa base"
if hay dmidecode; then
  dmidecode -t system    | grep -E 'Manufacturer|Product Name|Version|Serial' | sed 's/^\s*/  /'
  dmidecode -t baseboard | grep -E 'Manufacturer|Product Name|Version'        | sed 's/^\s*/  /'
  echo "  Chasis: $(dmidecode -s chassis-type)"
else echo "  (falta dmidecode)"; fi

sec "2. Firmware y arranque"
[ -d /sys/firmware/efi ] && echo "  Modo de arranque: UEFI" || echo "  Modo de arranque: BIOS/Legacy"
hay mokutil && echo "  Secure Boot: $(mokutil --sb-state 2>/dev/null)"
hay dmidecode && dmidecode -t bios | grep -E 'Vendor|Version|Release Date' | sed 's/^\s*/  /'
hay systemd-analyze && { echo "  Tiempo de arranque:"; systemd-analyze 2>/dev/null | sed 's/^/    /';
  echo "  Servicios que más tardan:"; systemd-analyze blame 2>/dev/null | head -5 | sed 's/^/    /'; }

sec "3. CPU"
lscpu | grep -E 'Model name|Architecture|Socket|Core\(s\) per|Thread\(s\) per|^CPU\(s\)|max MHz|L2|L3|Virtualization' | sed 's/^/  /'

sec "4. Memoria RAM"
free -h | sed 's/^/  /'
if hay dmidecode; then
  echo "  Capacidad máxima y ranuras:"
  dmidecode -t 16 | grep -E 'Maximum Capacity|Number Of Devices' | sed 's/^\s*/    /'
  echo "  Módulos (ranura · tamaño · tipo · velocidad):"
  dmidecode -t 17 | awk -F: '/Locator:/&&!/Bank/{l=$2} /^[[:space:]]*Size:/{s=$2} /^[[:space:]]*Type:/{t=$2} /Configured Memory Speed|^[[:space:]]*Speed:/{v=$2} /^[[:space:]]*$/{if(s!=""){print "    "l" ·"s" ·"t" ·"v}; s=""}'
fi

sec "5. Discos"
lsblk -o NAME,SIZE,TYPE,ROTA,TRAN,MODEL,FSTYPE,MOUNTPOINT | sed 's/^/  /'
echo "  (ROTA=1 mecánico · ROTA=0 SSD/NVMe)"
echo "  Velocidad negociada de los discos USB (lsusb -t: 480M=USB 2.0 · 5000M=USB 3.2 Gen1 · 10000M=Gen2 · 20000M=Gen2x2):"
lsusb -t 2>/dev/null | grep -E 'root_hub|Mass Storage' | sed 's/^/    /'
if hay smartctl; then
  for d in $(lsblk -dno NAME,TYPE | awk '$2=="disk"{print $1}' | grep -vE '^(loop|zram|sr)'); do
    echo "  --- /dev/$d ---"
    # Discos USB: el puente USB-SATA/NVMe necesita «-d sat» para pasar los datos SMART
    # (disco USB: se prueban -d sat y -d auto; si no, N/C)
    OPC=""
    if ! smartctl -i "/dev/$d" 2>/dev/null | grep -qE 'Model'; then
      for t in sat auto; do
        smartctl -d $t -i "/dev/$d" 2>/dev/null | grep -qE 'Model' && { OPC="-d $t"; echo "    (leído con smartctl $OPC)"; break; }
      done
    fi
    smartctl $OPC -i "/dev/$d" 2>/dev/null | grep -E 'Model|Capacity|Rotation|Form Factor|SATA Version|NVMe Version' | sed 's/^/    /'
    smartctl $OPC -H "/dev/$d" 2>/dev/null | grep -iE 'overall|result|SMART Health' | sed 's/^/    /' \
      || echo "    SMART: N/C (el puente USB no deja pasar SMART)"
  done
else echo "  (falta smartmontools para la salud de los discos)"; fi

sec "6. Red"
ip -br addr | sed 's/^/  /'
echo "  Ruta por defecto: $(ip route show default | head -1)"
lspci 2>/dev/null | grep -iE 'ethernet|network' | sed 's/^/  /'
if hay ethtool; then
  for i in $(ls /sys/class/net | grep -vE '^(lo|vboxnet|docker|virbr)'); do
    v=$(ethtool "$i" 2>/dev/null | awk -F: '/Speed/{print $2}' | xargs)
    [ -n "$v" ] && echo "  Velocidad de enlace $i: $v"
  done
fi
hay iw && iw dev 2>/dev/null | grep -E 'Interface|ssid|type' | sed 's/^\s*/  /'

sec "7. Gráfica, USB y periféricos"
lspci 2>/dev/null | grep -iE 'vga|3d|display' | sed 's/^/  /'
lsusb 2>/dev/null | sed 's/^/  /'

sec "8. Alimentación"
for b in /sys/class/power_supply/*; do
  [ -e "$b/type" ] || continue
  echo "  $(basename "$b"): tipo $(cat "$b/type")$( [ -e "$b/capacity" ] && echo ", carga $(cat "$b/capacity")%")$( [ -e "$b/energy_full" ] && [ -e "$b/energy_full_design" ] && awk -v f="$(cat "$b/energy_full")" -v d="$(cat "$b/energy_full_design")" 'BEGIN{printf ", salud batería %.0f%%", 100*f/d}')"
done
echo "  (La potencia de la fuente de un sobremesa no se lee por software: mirar la etiqueta → anotar o N/C)"

sec "9. Temperaturas"
hay sensors && sensors 2>/dev/null | grep -E '°C' | sed 's/^/  /' || echo "  (falta lm-sensors)"

sec "10. Resumen inxi (si está)"
hay inxi && inxi -Fxz -c0 2>/dev/null | sed 's/^/  /'
echo; echo "FIN DEL INVENTARIO"
} 2>&1 | ocultar | tee "$SALIDA"

chown --reference="$RAIZ" "$SALIDA" 2>/dev/null   # el fichero queda del usuario dueño del repo, no de root
echo; echo "Guardado en: ${SALIDA#$RAIZ/}"
