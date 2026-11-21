#!/bin/bash
# 60-chequeo-cliente.sh · Revisión final (21/11) · se ejecuta en Client-Linux como asier.
# Uso: bash 60-chequeo-cliente.sh <fw1|fw2|fw3>
# Comprueba la salida a Internet a través del firewall activo (siempre el .1) y deja el
# resultado en TrueNAS (por SSH con la clave de Client-Linux), donde lo recoge srv-mon.
# Sin contraseñas. Con "ip -4" para no publicar la IPv6 de enlace local (lleva la MAC).
ETQ=${1:?Uso: $0 fw1|fw2|fw3}
F=/tmp/chequeo-$ETQ.txt
{
  echo "### Client-Linux · firewall activo: $ETQ · $(date '+%F %T')"
  echo "--- ip -4 -br a / ip route";   ip -4 -br a; ip route
  echo "--- ping -c 3 192.168.21.1";    ping -c 3 -W 2 192.168.21.1 | tail -2
  echo "--- wget https://deb.debian.org (código HTTP)"
  wget -S --spider -T 10 https://deb.debian.org/ 2>&1 | grep -m1 'HTTP/'
  echo "--- traceroute -n -m 4 1.1.1.1 (el primer salto tiene que ser el .1)"
  traceroute -n -m 4 -w 2 1.1.1.1 2>&1
} > "$F" 2>&1
scp -q -o BatchMode=yes "$F" asier@192.168.21.20:/mnt/copias/cliente-linux/ && echo "ENVIADO $F"
