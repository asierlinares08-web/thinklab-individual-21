#!/bin/bash
# 31-vigila-parada.sh <fichero> · P14a: mide el tiempo de parada de una errada controlada.
# Cada segundo apunta si el firewall (.1) responde y si hay salida a Internet a través de su NAT
# (ping a 1.1.1.1: no depende del DNS, que FW3 no tiene). Se ejecuta en Server-Monitorizacion.
while true; do
  f=$(ping -c1 -W1 192.168.21.1 >/dev/null 2>&1 && echo OK || echo --)
  i=$(ping -c1 -W1 1.1.1.1 >/dev/null 2>&1 && echo OK || echo --)
  echo "$(date +%T) ping_fw=$f internet=$i"
  sleep 1
done >> "$1"
