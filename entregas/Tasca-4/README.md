# Tasca 4 · Disseny físic i lògic

**Objetivo:** dibujar la red de mi puesto (192.168.21.0/24, puesto 21) y decir cómo va configurada cada interfaz.
Después, montarla en VirtualBox y comprobar con ping, traceroute y la tabla de rutas que funciona.

Evidencias de esta tarea: [../../evidencias/tasca4/](../../evidencias/tasca4/)

## Actividades de la rúbrica

| ID | Nivel | RA | Actividad (texto de la rúbrica) | Estado |
|---|---|---|---|---|
| a128 | Apte | ISO-RA1 | Dibuixar l’esquema de xarxa individual, el muntatge virtual i les adreces previstes. | ✅ hecha |
| a148 | Apte | ISO-RA1 | Indicar la configuració de cada interfície i la LAN 192.168.XX.0/24 segons el lloc a l’aula; la WAN pot obtindre la IP per DHCP (adaptador pont o millor NAT). | ✅ hecha |
| a129 | Apte+ | ISO-RA1 | Implementar la xarxa individual i comprovar la connectivitat amb ping, traceroute i taules d’encaminament. | ✅ hecha |
| a149 | Apte+ | ISO-RA1 | Aportar evidències de ping, traceroute, taula d’encaminament i configuració de les interfícies entre les VM i cap a l’exterior. | ✅ hecha |

## En pocas palabras

He montado una red para la empresa, LAN_21, separada del aula. Todos los equipos están dentro y solo salen a Internet pasando por un firewall con la IP .1.
Cada equipo tiene una IP fija, ordenada por bloques. Lo comprobé con ping, traceroute y la tabla de rutas: el tráfico siempre pasa por el firewall.

En esta tarea no apunté predicciones antes de empezar.

## a128 · Esquema, montaje virtual y direcciones

**Qué pedía:** dibujar mi red, cómo la monto en VirtualBox y qué IP lleva cada equipo.

**Qué hice y por qué:** usé dos redes de VirtualBox:
- **WAN:** es un **NAT** (VirtualBox traduce las direcciones y saca el tráfico por mi PC). Solo la usan los firewalls, y reciben la IP por DHCP (reparto automático de IP).
- **LAN_21:** es una **red interna** (como un switch virtual que solo ven las VMs). Tiene la 192.168.21.0/24, todo con IP fija y sin DHCP.

El anfitrión no está en LAN_21. Así, todo lo que entra o sale de la empresa pasa por el firewall, como en una empresa de verdad.

Los tres firewalls tienen **la misma IP, 192.168.21.1**, para poder cambiar uno por otro sin tocar los demás equipos. Por eso **solo puede haber uno encendido**: con dos, habría dos máquinas con la misma IP y la red fallaría a ratos.

| VM | IP | Para qué sirve | Adaptadores |
|---|---|---|---|
| FW1-MikroTik · FW2-OPNsense · FW3-Debian-NFT | **.1** | Firewall y salida a Internet (uno cada vez) | WAN (NAT) + LAN_21 |
| Proxmox-Node1 / 2 / 3 | **.10 / .11 / .12** | Clúster de virtualización | LAN_21 |
| NAS-TrueNAS | **.20** | Copias de seguridad | LAN_21 |
| WinServer-2025 | **.30** | Servidor Windows (centralización) | LAN_21 |
| Server-Monitorizacion | **.40** | Copias automáticas y RAID | LAN_21 + NAT de gestión |
| Client-Win11 | **.50** | Cliente Windows | LAN_21 |
| Client-Linux | **.60** | Cliente Linux y puesto de gestión web | LAN_21 |
| VM y contenedor de la migración | **.150 / .151** | Prueba de migración (dentro de Proxmox) | LAN_21 (a través de Proxmox) |

Ordené las IPs **por bloques** (.1 enlace, .10 virtualización, .20 almacenamiento, .30 identidades, .40 supervisión, .50–.60 clientes). No va más rápido, pero al ver una IP en un log sé qué equipo es, y puedo hacer reglas de firewall por rangos.

**Cómo lo comprobé**

![Esquema de red LAN_21](../../diagramas/red-lan21.png)

Demuestra: cómo se conecta cada VM. Los 3 firewalls tienen un pie en el NAT (WAN) y otro en LAN_21. Todos los demás solo están en LAN_21, y el anfitrión queda fuera. Fuente del esquema: [`red-lan21.mmd`](../../diagramas/red-lan21.mmd).

Evidencia: [`vms-creadas.txt`](../../evidencias/tasca0/vms-creadas.txt). Demuestra: las 11 VMs existen con los adaptadores de la tabla (NAT y red interna `LAN_21`).

**Resultado / dato clave:** LAN **192.168.21.0/24**, máscara **255.255.255.0**, puerta de enlace **.1** y 11 VMs creadas.

**Qué he aprendido:** separar la LAN del aula obliga a que todo pase por el firewall, y eso es lo que hace que las reglas sirvan de algo.

## a148 · Configuración de cada interfaz

**Qué pedía:** decir cómo va cada interfaz, con la LAN de mi puesto y la WAN por DHCP (mejor con NAT).

**Qué hice y por qué:** en la LAN, todo con IP fija, para que nada cambie al reiniciar. La WAN de los firewalls va por DHCP del NAT, como permite la rúbrica.

| Equipo | WAN (NAT, por DHCP) | LAN (LAN_21, fija) | Puerta de enlace | DNS |
|---|---|---|---|---|
| FW1-MikroTik | `ether1` 10.0.2.15/24 | `ether2` 192.168.21.1/24 | 10.0.2.2 | el del DHCP |
| FW2-OPNsense | `em0` 10.0.2.15/24 | `em1` 192.168.21.1/24 | 10.0.2.2 | el del DHCP |
| FW3-Debian-NFT | `enp0s3` 10.0.2.15/24 | `enp0s8` 192.168.21.1/24 | 10.0.2.2 | el del DHCP |
| Resto de equipos (.10 a .151) | — | su IP de la tabla de a128, /24 | 192.168.21.1 | 192.168.21.1 y 1.1.1.1 |

El DNS (lo que traduce nombres a IPs) es primero el firewall. El Debian con nftables no tiene DNS, así que con él se usa el segundo, 1.1.1.1. Con cualquier firewall, los nombres funcionan.

**Red de gestión.** Server-Monitorizacion tiene un segundo adaptador NAT, sin puerta de enlace, que solo sirve para que yo entre desde mi PC por SSH (`127.0.0.1:2222`).
Desde ahí llego al resto de equipos con clave SSH, sin saltarme el firewall.
Evidencia: [`gestion-fuera-banda-srv-mon.txt`](../../evidencias/tasca4/gestion-fuera-banda-srv-mon.txt). Demuestra que srv-mon sigue saliendo a Internet por el .1 y que no pasa tráfico de una red a otra (`ip_forward = 0`).

**Cómo lo comprobé**

Evidencia: [`fw2-opnsense-interfaces-wan-lan.png`](../../evidencias/tasca5/fw2-opnsense-interfaces-wan-lan.png). Demuestra: en OPNsense, la WAN `em0` tiene 10.0.2.15/24 por DHCP (pasarela 10.0.2.2) y la LAN `em1` tiene 192.168.21.1/24 fija.

**Resultado / dato clave:** WAN **10.0.2.15/24** por DHCP; LAN **192.168.21.1/24** en el firewall; resto de equipos con gateway **192.168.21.1** y DNS **192.168.21.1 + 1.1.1.1**.

**Qué he aprendido:** el nombre de la interfaz cambia según el sistema (`ether2`, `em1`, `enp0s8`). Hay que mirarlo después de instalar, no suponerlo.

## a129 · Montar la red y comprobar que funciona

**Qué pedía:** montar la red y comprobar la conexión con ping, traceroute y la tabla de rutas.

**Qué hice y por qué:** desde Client-Linux (.60) miré su IP y su ruta, hice ping al firewall y un traceroute (enseña por qué routers pasa un paquete) hasta Internet.
Esperaba ver **dos NAT seguidos**: primero el del firewall (.1) y después el de VirtualBox (10.0.2.2).

**Cómo lo comprobé:** el traceroute por TCP al puerto 443, porque el aula bloquea el ping hacia fuera:
```
traceroute -T -p 443 deb.debian.org
```

![IP, ruta, ping y traceroute](../../evidencias/tasca4/client-linux-ip-ruta-ping-traceroute.png)

Demuestra: el primer salto es el firewall (**192.168.21.1**), el segundo el NAT de VirtualBox (**10.0.2.2**) y luego el destino. La tabla de rutas tiene `default via 192.168.21.1`.

**Resultado / dato clave**

| Prueba | Resultado |
|---|---|
| IP y ruta de Client-Linux | `enp0s3` 192.168.21.60/24 · `default via 192.168.21.1` |
| Ping a la puerta de enlace | 3/3 · 0 % de pérdida · 0,76 ms |
| Traceroute a deb.debian.org | 1 → 192.168.21.1 · 2 → 10.0.2.2 · 3 → 199.232.34.132 |
| HTTPS a Internet | `HTTP/1.1 200 OK` ([captura](../../evidencias/tasca5/client-linux-prueba-http-bloqueado-https-ok.png)) |

**Qué he aprendido:** un traceroute dice más que un ping. El ping solo dice «llego»; el traceroute dice por dónde.

## a149 · Evidencias entre VMs y hacia fuera

**Qué pedía:** pruebas de ping, traceroute, rutas e interfaces, entre VMs y hacia el exterior.

**Qué hice y por qué:** hacia fuera, usé las pruebas de a129. Entre VMs, usé servicios que solo funcionan si las máquinas se ven entre ellas.

**Cómo lo comprobé**

| Qué | Entre | Resultado | Evidencia |
|---|---|---|---|
| Ruta y traceroute hacia fuera | Client-Linux (.60) → .1 → Internet | 1.er salto .1, 2.º 10.0.2.2, HTTPS 200 | [captura de a129](../../evidencias/tasca4/client-linux-ip-ruta-ping-traceroute.png) |
| Ruta y traceroute hacia fuera | srv-mon (.40) → .1 → Internet | `default via 192.168.21.1`, 1.er salto .1 | [`gestion-fuera-banda-srv-mon.txt`](../../evidencias/tasca4/gestion-fuera-banda-srv-mon.txt) |
| Clúster Proxmox | .10 ↔ .11 ↔ .12 | `Quorate: Yes`, 3 votos | [`chequeo-final.txt`](../../evidencias/tasca8/chequeo-final.txt) |
| Disco por red del espejo | srv-mon (.40) → NAS (.20) | el disco del NAS está dentro del espejo | [`chequeo-final.txt`](../../evidencias/tasca8/chequeo-final.txt) |
| Windows hacia fuera | .30 y .50 → .1 | IP /24, GW .1, ping 3 de 3, `tracert` por el .1 | [`chequeo-final.txt`](../../evidencias/tasca8/chequeo-final.txt) |

Demuestra: las VMs se ven entre ellas (el clúster se forma y el NAS sirve un disco por la red) y todas salen a Internet por el firewall .1.

**Resultado / dato clave:** con cualquiera de los tres firewalls, el primer salto es **192.168.21.1** y el segundo **10.0.2.2**.

**Qué he aprendido:** la mejor prueba de que dos VMs se ven es un servicio que necesita a las dos.

## Problemas que tuve

- **No entraba por SSH a srv-mon desde mi PC (incidencia 24).** El segundo NAT de VirtualBox usa otra red, la **10.0.3.0/24**, y yo había puesto una de la 10.0.2.0/24. Solución: IP fija **10.0.3.15/24 sin puerta de enlace**.
- **Al cambiar de firewall, el primer ping al .1 fallaba (incidencia 28).** El cliente recordaba la tarjeta del firewall anterior (caché ARP, la lista que une IPs y tarjetas). Solución: esperar unos 10 s o vaciarla con `sudo ip neigh flush dev enp0s3`.

Lista completa de incidencias: [10-incidencies](../../docs/10-incidencies.md).

Más detalle técnico: [04-disseny](../../docs/04-disseny.md) (red e interfaces) · [05-recursos](../../docs/05-recursos.md) (máquinas y RAM).
