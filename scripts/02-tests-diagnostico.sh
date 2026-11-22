#!/usr/bin/env bash
# =============================================================================
# 02-tests-diagnostico.sh — Fase 1 / Tasca 2 Apte+ (a27, a28, a29)
# Tests de diagnóstico de MEMORIA, DISCO y RED. Registra herramienta,
# condiciones y resultado para poder confirmar o descartar cuellos de botella.
# Uso:  sudo ./scripts/02-tests-diagnostico.sh casa|clase [ip_servidor_iperf3]
# Salida: evidencias/tasca2/AAAA-MM-DD_tests-<equipo>.txt
# Duración aproximada: 5-10 minutos. Cierra programas pesados antes.
# =============================================================================
set -u
export LC_ALL=C
EQUIPO="${1:-}"; IPERF="${2:-}"
if [[ "$EQUIPO" != "casa" && "$EQUIPO" != "clase" ]]; then
  echo "Uso: sudo $0 casa|clase [ip_servidor_iperf3]"; exit 1
fi
[[ $EUID -ne 0 ]] && { echo "Hace falta sudo (memtester bloquea RAM, smartctl lee discos)."; exit 1; }
# RAIZ_FIJA se rellena SOLO en la copia de root de /usr/local/lib/thinklab-asier/ (ver scripts/sudoers-thinklab-asier)
RAIZ_FIJA=""
RAIZ="${RAIZ_FIJA:-$(cd "$(dirname "$0")/.." && pwd)}"
SALIDA="$RAIZ/evidencias/tasca2/$(date +%F)_tests-$EQUIPO.txt"
mkdir -p "$(dirname "$SALIDA")"
hay() { command -v "$1" >/dev/null; }
sec() { echo; echo "################ $* ################"; }

# Disco donde está /home (es donde irán las VMs)
PART=$(df --output=source "$HOME" "${SUDO_USER:+/home/$SUDO_USER}" 2>/dev/null | tail -1)
DISCO=/dev/$(lsblk -no PKNAME "$PART" 2>/dev/null | head -1)
[ "$DISCO" = "/dev/" ] && DISCO=$PART
DIR_PRUEBA="${SUDO_USER:+/home/$SUDO_USER}"; DIR_PRUEBA="${DIR_PRUEBA:-$HOME}"
# Carpeta temporal con nombre aleatorio (mktemp): como root, nunca escribir en un nombre fijo
# dentro del /home de un usuario (podría ser un enlace a un fichero del sistema).
TMPD=$(mktemp -d "$DIR_PRUEBA/.thinklab-test.XXXXXX") || { echo "No se pudo crear la carpeta temporal"; exit 1; }
trap 'rm -rf "$TMPD"' EXIT

{
echo "TESTS DE DIAGNÓSTICO — equipo: $EQUIPO ($(hostname)) — $(date '+%F %T')"
echo "CONDICIONES: uptime $(uptime -p) · carga $(cut -d' ' -f1-3 /proc/loadavg) · RAM libre $(free -h | awk '/Mem/{print $7}')"
echo "             VMs en marcha: $(pgrep -c VBoxHeadless 2>/dev/null || echo 0) headless / $(pgrep -fc 'VirtualBoxVM' 2>/dev/null || echo 0) con ventana"
hay sensors && echo "             Temperatura CPU al empezar: $(sensors 2>/dev/null | grep -m1 -E 'Package|Tctl|Core 0' | xargs)"

sec "1. MEMORIA — memtester (prueba en caliente de 512 MB, 1 pasada)"
echo "Herramienta: memtester $(dpkg-query -W -f='${Version}' memtester 2>/dev/null)"
echo "Limitación: solo prueba la RAM libre que el sistema le deja. Prueba completa = memtest86+ desde GRUB (fuera del SO)."
if hay memtester; then
  T0=$(date +%s); memtester 512M 1 2>&1 | col -b | grep -aE ':|Loop|Done' | sed -E 's/: (ok|FAILURE).*/: \1/' | tr -s '\t ' ' '   # col -b quita las animaciones (retrocesos); echo "Duración: $(( $(date +%s)-T0 )) s"
else echo "N/C — falta memtester"; fi

sec "2. DISCO — salud SMART + velocidad"
echo "Disco analizado: $DISCO (el de /home, donde irán las VMs)"
echo "Conexión (lsusb -t; 5000M = USB 3.2 Gen1, 10000M = Gen2): $(lsusb -t 2>/dev/null | grep 'Mass Storage' | xargs || echo 'no es USB')"
if hay smartctl; then
  OPC=""   # disco USB: se prueban -d sat y -d auto
  if ! smartctl -i "$DISCO" 2>/dev/null | grep -qE 'Model'; then
    for t in sat auto; do
      smartctl -d $t -i "$DISCO" 2>/dev/null | grep -qE 'Model' && { OPC="-d $t"; echo "(leído con smartctl $OPC)"; break; }
    done
  fi
  smartctl $OPC -H "$DISCO" 2>/dev/null | grep -iE 'overall|result|Health' || echo "SMART: N/C (el puente USB no deja pasar SMART)"
  smartctl $OPC -A "$DISCO" 2>/dev/null | grep -iE 'Reallocated|Pending|Uncorrect|Power_On|Wear|Percentage Used|Media and Data|Available Spare|Temperature' | head -12
fi
if hay hdparm && [[ "$DISCO" == /dev/sd* || "$DISCO" == /dev/nvme* ]]; then
  echo "-- Lectura (hdparm -Tt): caché y disco"; hdparm -Tt "$DISCO" 2>&1 | grep -E 'Timing'
fi
echo "-- Escritura secuencial 1 GB sin caché (dd oflag=direct)"
dd if=/dev/zero of="$TMPD/ddtest" bs=1M count=1024 oflag=direct 2>&1 | tail -1
rm -f "$TMPD/ddtest"
if hay fio; then
  echo "-- Lectura aleatoria 4K (fio, 30 s, típico de VMs arrancando)"
  fio --name=rand4k --filename="$TMPD/fiotest" --size=512M --rw=randread --bs=4k \
      --direct=1 --ioengine=libaio --iodepth=16 --runtime=30 --time_based --group_reporting 2>/dev/null \
      | grep -E 'IOPS=|lat \(usec\): min|lat \(msec\): min' | head -3
  rm -f "$TMPD/fiotest"
else echo "-- fio no instalado: sin prueba aleatoria 4K (N/C)"; fi

sec "3. RED"
GW=$(ip route show default | awk '{print $3; exit}')
IF=$(ip route show default | awk '{print $5; exit}')
echo "Interfaz: $IF · Puerta de enlace: $GW"
hay ethtool && echo "Velocidad de enlace negociada: $(ethtool "$IF" 2>/dev/null | awk -F: '/Speed/{print $2}' | xargs) (Wi-Fi no la muestra)"
echo "-- Latencia y pérdida a la puerta de enlace (red local)"
ping -c 10 -q "$GW" 2>&1 | tail -2
echo "-- Latencia y pérdida a Internet (1.1.1.1, ICMP)"
ping -c 10 -q 1.1.1.1 2>&1 | tail -2
echo "   (si sale 100 % de pérdida, puede ser que la red bloquee el ping hacia fuera: se mira la prueba HTTPS)"
echo "-- Tiempo de conexión HTTPS a deb.debian.org (TCP + TLS)"
curl -s -o /dev/null -m 15 -w 'HTTP %{http_code} · conexión %{time_connect} s · TLS %{time_appconnect} s\n' https://deb.debian.org/debian/ || echo "N/C — sin acceso"
echo "-- Descarga de 50 MB del mirror oficial de Debian (sigue redirecciones)"
R=$(curl -sL -o /dev/null -m 90 -r 0-52428799 -w '%{http_code} %{speed_download} %{time_total}' \
  https://cdimage.debian.org/cdimage/archive/13.1.0/amd64/iso-cd/debian-13.1.0-amd64-netinst.iso)
set -- $R
if [[ "${1:-0}" == 20[06] ]]; then awk -v b="$2" -v t="$3" 'BEGIN{printf "Velocidad media: %.1f MB/s (%.0f Mbit/s) · tiempo %.1f s\n", b/1e6, b*8/1e6, t}'
else echo "N/C — HTTP ${1:-?} (la descarga no se completó)"; fi
if [ -n "$IPERF" ] && hay iperf3; then
  echo "-- iperf3 contra $IPERF (red local, 10 s)"; iperf3 -c "$IPERF" -t 10 2>&1 | tail -4
else
  echo "-- iperf3 entre dos equipos: N/C (no se indicó servidor). Comando: iperf3 -s en otro PC y volver a lanzar con su IP."
fi

hay sensors && { echo; echo "Temperatura CPU al terminar: $(sensors 2>/dev/null | grep -m1 -E 'Package|Tctl|Core 0' | xargs)"; }
echo; echo "FIN DE LOS TESTS"
} 2>&1 | tee "$SALIDA"

chown --reference="$RAIZ" "$SALIDA" 2>/dev/null
echo; echo "Guardado en: ${SALIDA#$RAIZ/}"
