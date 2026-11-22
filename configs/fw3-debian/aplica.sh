#!/bin/bash
# aplica.sh · FW3-Debian-NFT (P7). Uso (dentro de la VM, como root o con sudo):
#   wget -qO- https://raw.githubusercontent.com/asierlinares08-web/thinklab-individual-21/main/configs/fw3-debian/aplica.sh | sudo bash
set -e   # si un comando falla, el script se para
URL=https://raw.githubusercontent.com/asierlinares08-web/thinklab-individual-21/main/configs/fw3-debian

# nftables viene en la instalación estándar de Debian; si faltara, se instala
command -v nft >/dev/null || apt-get install -y nftables

# 1) Copia una seguridad de los ficheros originales (solo la primera vez)
for f in /etc/network/interfaces /etc/nftables.conf; do [ -e "$f.orig" ] || cp "$f" "$f.orig" 2>/dev/null || true; done

# 2) Descarga los 3 ficheros del repo a su sitio
wget -qO /etc/network/interfaces      $URL/interfaces
wget -qO /etc/sysctl.d/99-forward.conf $URL/99-forward.conf
wget -qO /etc/nftables.conf           $URL/nftables.conf

# 3) Comprueba la sintaxis de las reglas ANTES de cargarlas (-c = solo comprobar)
nft -c -f /etc/nftables.conf

# 4) nftables: que arranque siempre con el sistema y cargarlo ya
systemctl enable nftables
systemctl restart nftables

# 5) Aplica el reenvío de paquetes (ip_forward) sin reiniciar
sysctl --system >/dev/null
echo "ip_forward = $(cat /proc/sys/net/ipv4/ip_forward)   (1 = activado)"

# 6) Reinicia la red para que coja la IP de la LAN
systemctl restart networking

# 7) Comprobaciones
echo "== ip -br a =="; ip -4 -br a
echo "== ip route =="; ip route
echo "== nft list ruleset =="; nft list ruleset
