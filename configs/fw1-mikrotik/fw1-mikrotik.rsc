# fw1-mikrotik.rsc · FW1-MikroTik (P8) · RouterOS 7 (CHR) · SIN contraseñas
# Se aplica en la consola del router con:
#   /tool fetch url="https://raw.githubusercontent.com/asierlinares08-web/thinklab-individual-21/main/configs/fw1-mikrotik/fw1-mikrotik.rsc"
#   /import file-name=fw1-mikrotik.rsc
# Interfaces: ether1 = WAN (adaptador 1, NAT de VirtualBox) · ether2 = LAN (adaptador 2, red interna LAN_21)
# En RouterOS el "#" solo vale al principio de una línea: cada comentario explica la orden de debajo.

# Nombre del router (sale en el prompt y en los logs)
/system identity set name=FW1-MikroTik

# WAN: cliente DHCP en ether1 (el CHR ya trae uno de fábrica); solo se crea si no existe, para no duplicarlo
:if ([:len [/ip dhcp-client find where interface=ether1]] = 0) do={ /ip dhcp-client add interface=ether1 disabled=no comment="WAN por DHCP (NAT de VirtualBox)" }

# LAN: IP fija 192.168.21.1/24 en ether2 (puerta de enlace de LAN_21); solo si no está ya puesta
:if ([:len [/ip address find where address="192.168.21.1/24"]] = 0) do={ /ip address add address=192.168.21.1/24 interface=ether2 comment="LAN_21" }

# NAT: lo que sale por la WAN cambia su IP de origen (192.168.21.x) por la IP de ether1 (masquerade)
:if ([:len [/ip firewall nat find where comment="P8 NAT de la LAN hacia Internet"]] = 0) do={ /ip firewall nat add chain=srcnat out-interface=ether1 action=masquerade comment="P8 NAT de la LAN hacia Internet" }

# Bloqueo de prueba: HTTP (TCP 80) que entra por la LAN y atraviesa el router (cadena forward). Se registra en el log
# El CHR no trae reglas de filtro, así que queda la primera (RouterOS lee de arriba abajo y aplica la primera que coincide)
# Lo que no coincide con ninguna regla pasa (forward acepta por defecto): el resto del tráfico LAN -> Internet sale
:if ([:len [/ip firewall filter find where comment="P8 bloqueo HTTP desde la LAN"]] = 0) do={ /ip firewall filter add chain=forward in-interface=ether2 protocol=tcp dst-port=80 action=drop log=yes log-prefix="P8-BLOQUEO-HTTP" comment="P8 bloqueo HTTP desde la LAN" }

# Sin servidor DNS en el router (allow-remote-requests=no, el valor de fábrica): los clientes usan 1.1.1.1 de secundario, como con FW3
/ip dns set allow-remote-requests=no
