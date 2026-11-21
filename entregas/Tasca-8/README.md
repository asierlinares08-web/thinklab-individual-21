# Tasca 8 · Prova final

Evidencias de esta tarea: [../../evidencias/tasca8/](../../evidencias/tasca8/)

> Entrega individual · Asier · puesto 21 · proyecto «Naix un sistema» V2.0. Documento autocontenido: el contenido sale de [`docs/`](../../docs/) y las evidencias están en [`evidencias/`](../../evidencias/). Uso de IA declarado en [11-us-ia](../../docs/11-us-ia.md).

**Objetivo:** Resolver de forma individual un caso práctico sobre mi entorno el día del examen (25/11/2026) y responder el cuestionario teórico-práctico. Aquí está la preparación y la comprobación de que el entorno funciona.

**En pocas palabras:** El examen es un caso práctico sobre mi propio laboratorio, así que lo importante es que todo funcione y que sepa explicarlo. El 21/11 encendí todo por escenarios y comprobé que, con cada firewall, los equipos salen a Internet pasando por él y que el clúster, el NAS, los RAID y las copias siguen bien. También preparé las respuestas probables, un glosario y una chuleta con qué hacer según lo que pidan.

## 1. Actividades de la rúbrica

| ID | Nivel | RA | Actividad (texto de la rúbrica) | Estado |
|---|---|---|---|---|
| a25 | Apte | FDM-RA1 | Diagnosticar i resoldre la incidència de maquinari del cas final. | ⏳ el día del examen (25/11) |
| a26 | Apte | FDM-RA1 · ISO-RA1 · ISO-RA3 · ISO-RA6 | Justificar la solució i comprovar el resultat. | ⏳ el día del examen (25/11) |
| a50 | Apte | FDM-RA4 | Identificar els equips empresarials i la seua funció en el cas final. | ⏳ el día del examen (25/11) |
| a51 | Apte | FDM-RA4 | Inventariar les connexions i els ports del cas assignat. | ⏳ el día del examen (25/11) |
| a52 | Apte | FDM-RA4 | Analitzar alimentació, ventilació i ordre del cablejat. | ⏳ el día del examen (25/11) |
| a53 | Apte | FDM-RA4 | Aportar l’esquema i l’explicació individual de la solució. | ⏳ el día del examen (25/11) |
| a80 | Apte | ISO-RA1 | Resoldre la incidència d’instal·lació, actualització o arrencada del cas final. | ⏳ el día del examen (25/11) |
| a104 | Apte | ISO-RA3 | Recuperar la informació o el sistema previst en el cas final. | ⏳ el día del examen (25/11) |
| a122 | Apte | ISO-RA6 | Diagnosticar el problema de rendiment del cas final. | ⏳ el día del examen (25/11) |
| a30 | Apte+ | FDM-RA1 | Respondre el bloc del qüestionari teòric/pràctic corresponent a FDM RA1, justificant les respostes. El bloc ha d’estar identificat per RA; complementa les evidències pràctiques. | ⏳ el día del examen (25/11) |
| a57 | Apte+ | FDM-RA4 | Respondre el bloc del qüestionari teòric/pràctic corresponent a FDM RA4, justificant les respostes. El bloc ha d’estar identificat per RA; complementa les evidències pràctiques. | ⏳ el día del examen (25/11) |
| a84 | Apte+ | ISO-RA1 | Respondre el bloc del qüestionari teòric/pràctic corresponent a ISO RA1, justificant les respostes. El bloc ha d’estar identificat per RA; complementa les evidències pràctiques. | ⏳ el día del examen (25/11) |
| a110 | Apte+ | ISO-RA3 | Respondre el bloc del qüestionari teòric/pràctic corresponent a ISO RA3, justificant les respostes. El bloc ha d’estar identificat per RA; complementa les evidències pràctiques. | ⏳ el día del examen (25/11) |
| a126 | Apte+ | ISO-RA6 | Respondre el bloc del qüestionari teòric/pràctic corresponent a ISO RA6, justificant les respostes. El bloc ha d’estar identificat per RA; complementa les evidències pràctiques. | ⏳ el día del examen (25/11) |

## 2. Cómo leer esta entrega
Cada apartado sigue el ThinkLoop: **predicción → decisión → implementación → verificación → análisis**. Cada evidencia va con una línea «Demuestra: …».

## 3. Chequeo funcional final (21/11)

### 12. Chequeo funcional final (21/11/2026)
> Revisión antes de la entrega: ¿sigue funcionando todo lo montado? Un solo firewall encendido cada vez (misma IP .1). Client-Linux ejecuta `scripts/60-chequeo-cliente.sh` y deja la salida en TrueNAS; srv-mon la recoge por la red de gestión. Windows, con `VBoxManage guestcontrol`.

| Escenario | Comprobación | Resultado |
|---|---|---|
| 1 · FW2-OPNsense | Client-Linux: ping .1, `wget` HTTPS → 200, `traceroute` (1.er salto .1, 2.º 10.0.2.2 = NAT de VirtualBox) | ✅ OK |
| 1 | Proxmox: `pvecm status` → clúster `thinklab`, **Quorate: Yes**, 3 votos; VM150 (pve2) y CT151 (pve3) arrancan y responden | ✅ OK |
| 1 | TrueNAS: pool `copias` **ONLINE**, 0 errores, 3,9 GB usados de 19,5 GB; copias en los 8 datasets | ✅ OK |
| 1 | srv-mon: `md1` [UU], `md5` [UUU], espejo `md2` [UU] (sdb local + sdi iSCSI, sesión `LOGGED_IN`); `crontab` 02:30; copias automáticas lanzadas a mano → «Fin (todo OK)», ahora también con los 3 nodos | ✅ OK |
| 2 · FW3-Debian-NFT | Client-Linux: ping .1, HTTPS 200, traceroute por .1 | ✅ OK (el primer ping falló por la caché ARP: incidencia 28) |
| 3 · FW1-MikroTik | Client-Linux: ping .1, HTTPS 200, traceroute por .1; RouterOS 7.25.1 | ✅ OK |
| 4 · FW1 + Windows | WinServer-2025 (.30) y Client-Win11 (.50): IP/24, GW .1, DNS .1 + 1.1.1.1, ping .1 3/3, HTTPS 200, `tracert` por .1 | ✅ OK |

Texto completo: [`2026-11-21_chequeo-final.txt`](../../evidencias/tasca8/2026-11-21_chequeo-final.txt). Demuestra: con cada uno de los 3 firewalls los equipos de la LAN salen a Internet **pasando por el .1**, y los servicios (clúster, NAS, RAID, espejo, copias automáticas) siguen en marcha dos días después de montarlos. Única falla: el ping justo después de cambiar de firewall, que se arregla solo (incidencia 28).

## 4. Preparación: decisión propia, glosario y chuleta

### Revisión final (21/11)
- **¿Por qué al cambiar de firewall falla el primer ping al .1?** Porque mi PC recuerda la MAC del firewall de antes (caché ARP) y le sigue mandando los paquetes a una tarjeta que ya está apagada. A los pocos segundos vuelve a preguntar y aprende la nueva. Se arregla al momento con `sudo ip neigh flush dev enp0s3` (incidencia 28).
- **¿Cómo sabes que el documento recuperado es el mismo?** El SHA-256 de antes de borrarlo y el de después de restaurarlo son iguales, y `ls -l` muestra los mismos permisos (640), dueño y fecha. Usé `scp -p` para que se conservaran (09 §2.1).

### Una decisión que una respuesta genérica no resolvía
El diseño de la red lo propuse yo. La IA proponía una red «solo-anfitrión», pero yo decidí usar una **red interna (LAN_21)** y poner la **misma IP, la .1, en los tres firewalls**.
Así el PC del aula no está dentro de la red de la empresa: todo lo que entra o sale tiene que pasar por el firewall, como en una empresa de verdad.
Y como los tres firewalls usan la misma puerta de enlace, puedo cambiar uno por otro sin tocar nada en los demás equipos; la única regla es tener solo uno encendido.
La prueba es el `traceroute`: con cada firewall, el primer salto es 192.168.21.1 y el segundo el NAT de VirtualBox ([`2026-11-21_chequeo-final.txt`](../../evidencias/tasca8/2026-11-21_chequeo-final.txt)).
Y el aislamiento se ve en que el anfitrión no tiene IP en LAN_21: la única entrada de gestión es un puerto que solo escucha en `127.0.0.1` del propio PC ([04 §6](../../docs/04-disseny.md)).

### Glosario (en palabras sencillas)
| Término | Qué es |
|---|---|
| **RAID** | Juntar varios discos para que funcionen como uno: más espacio, más velocidad o aguantar que se rompa uno, según el tipo. |
| **RAID 0 / 1 / 5** | 0: reparte los datos (rápido, pero si cae un disco se pierde todo). 1: copia todo en dos discos. 5: reparte con una «pieza de control» y aguanta la pérdida de un disco. |
| **NAT** | El firewall cambia la IP privada del equipo por la suya al salir a Internet, para que las respuestas vuelvan a él. |
| **Firewall** | Equipo que decide qué tráfico pasa y cuál no entre la red de la empresa e Internet. |
| **Puerta de enlace** | La dirección a la que un equipo manda todo lo que no es de su red (aquí, el .1). |
| **LAN / VLAN** | LAN: la red local de la empresa. VLAN: varias redes separadas sobre el mismo switch (aquí no se usan; separamos con una red interna). |
| **Red interna (VirtualBox)** | Un switch virtual que solo ven las VMs conectadas a él; el anfitrión no está dentro. |
| **DHCP** | Servicio que reparte IPs automáticamente. En LAN_21 no hay: todas las IPs son fijas. |
| **DNS** | Traduce nombres (deb.debian.org) a direcciones IP. |
| **ARP** | Cómo un equipo averigua la MAC (la tarjeta) que corresponde a una IP de su red. |
| **Clúster** | Varios servidores que trabajan juntos y se gestionan como uno (los 3 nodos Proxmox). |
| **Quórum** | Mayoría de votos del clúster (2 de 3). Sin quórum, el clúster no deja hacer cambios para no estropear nada. |
| **Migración** | Mover una VM o un contenedor de un nodo a otro. |
| **Contenedor (LXC)** | Una «VM ligera» que comparte el núcleo del sistema anfitrión: arranca más rápido y gasta menos. |
| **Virtualización anidada** | Una VM que a su vez crea VMs (Proxmox dentro de VirtualBox). |
| **iSCSI** | Usar por la red un disco de otro equipo como si estuviera enchufado en el tuyo. |
| **Instantánea (snapshot)** | Foto del estado de una VM o un disco a la que se puede volver si algo sale mal. |
| **Copia de seguridad** | Duplicado guardado en **otro** equipo para recuperar datos o configuración si se pierden. |
| **fstab** | Fichero de Linux con los discos que se montan al arrancar. Si está mal, el sistema puede no arrancar. |
| **GRUB** | El programa que arranca Linux; permite cambiar opciones de arranque para reparar el sistema. |
| **initramfs** | Mini-sistema que carga Linux al principio para encontrar el disco y poder arrancar el sistema de verdad. |
| **SHA-256** | «Huella» de un fichero: si cambia un solo bit, la huella cambia. Sirve para comprobar que una copia o una ISO están intactas. |
| **cron** | El programador de tareas de Linux: lanza un script solo a una hora fija. |
| **SSH con clave** | Entrar a otro equipo por la red cifrada sin escribir contraseña, con un par de claves (pública y privada). |
| **UEFI / BIOS** | El firmware que arranca el ordenador. UEFI es el moderno (lo exige Windows 11 con Secure Boot y TPM). |

### Chuleta para el examen individual (Tasca 8, miércoles 25/11)
El examen es un **caso práctico sobre mi entorno**. Antes de empezar: enchufar el PC (incidencia del 18/11: iba con batería), `VBoxManage list runningvms` (**un solo firewall**), y arrancar el escenario que pida el caso ([05-recursos](../../docs/05-recursos.md) §3). Hay instantáneas `P20-final` de todas las VMs por si algo se rompe.

| Si piden… | IDs | Cómo lo hago (y dónde está explicado) |
|---|---|---|
| **Incidencia de hardware** | a25, a26 | `sudo -n /usr/local/lib/thinklab-asier/01-inventario-hw.sh clase` y `02-tests-diagnostico.sh clase` (inventario y tests), `sensors`, `dmesg -T \| grep -iE 'error\|fail'`, `smartctl -H`. Síntoma → hipótesis → prueba → solución → **comprobar** ([02-inventari](../../docs/02-inventari.md), [10-incidencies](../../docs/10-incidencies.md)) |
| **Equipos, conexiones, puertos, alimentación, cableado, esquema** | a50–a53 | Esquema `diagramas/red-lan21.png` + tabla de IPs e interfaces ([04-disseny](../../docs/04-disseny.md)); puertos: 22 SSH, 80/443 WebUI, 3260 iSCSI, 445 SMB, 2049 NFS, 8006 Proxmox. Alimentación/ventilación/cableado: [02-inventari](../../docs/02-inventari.md) |
| **Incidencia de instalación, actualización o arranque** | a80 | Consola de la VM (`captura.sh … vm`) para ver el mensaje. `fstab` → GRUB «e» + `systemd.mask=<unidad>.mount` o `init=/bin/bash`, `mount -o remount,rw /`, `findmnt --verify` ([06](../../docs/06-installacions.md) §11). Windows que no arranca del DVD → pulsar tecla (incidencia 19). Actualizaciones: §10 |
| **Recuperar información o un sistema** | a104 | Copias en TrueNAS `copias/<equipo>/` con SHA-256. Firewall: `30-copia-firewall.sh` y los procedimientos de [09](../../docs/09-copies-contingencia.md) §2 (FW2: `fetch` + `/conf/config.xml`; FW3: `tar` + `nft -c`; FW1: `/import`). Proxmox: *Backup → Restore* desde `copias-nas`. Linux: `tar xzf`. Windows: `robocopy` desde el recurso SMB. Disco: RAID `mdadm --re-add`; espejo `md2` solo con el disco de TrueNAS ([07](../../docs/07-raid.md) §2) |
| **Problema de rendimiento** | a122 | `scripts/50-medir-rendimiento.sh <caso> 60` en el anfitrión y `vmstat 5` / `iostat -x 5` / `top` dentro de la VM. Mirar: `si/so` (swap), `wa` (disco), `r` frente a los hilos, `%util` y `await`. Causas típicas: poca RAM (swap), demasiadas VMs, 1 vCPU saturada, tarjeta e1000 en vez de virtio ([08](../../docs/08-rendiment.md)) |
| **Cuestionario por RA** | a30, a57, a84, a110, a126 | Repasar este documento entero (preguntas por fase) y los «Análisis» de cada `.md` |

**Regla para el examen:** cada afirmación con su prueba (una salida de comando o una captura), y lo que no dé tiempo a comprobar, decirlo como **N/C** con la prueba que lo confirmaría.


## 5. Preguntas de defensa por RA

Todas las preguntas y respuestas preparadas por fase: [12-defensa](../../docs/12-defensa.md).

## 6. Incidencias de esta tarea
Formato: síntoma → hipótesis → comprobación → solución → tiempo. Lista completa en [10-incidencies](../../docs/10-incidencies.md).

| # | Fecha | Sistema | Síntoma | Hipótesis | Comprobación | Solución | Tiempo |
|---|---|---|---|---|---|---|---|
| 28 | 21/11 | Client-Linux (chequeo final, cambio de firewall) | Nada más cambiar de FW2 a FW3 (y de FW3 a FW1), `ping 192.168.21.1` da **0 de 3**, pero el HTTPS y el `traceroute` sí funcionan unos segundos después | El cliente guarda en su **caché ARP** la MAC del firewall anterior (los tres tienen la misma IP .1) y le sigue enviando los paquetes a una tarjeta que ya no existe | Al pasar a FW1, `ip neigh show 192.168.21.1` muestra la MAC de **FW3** en estado `STALE` → ping 0/3 → la entrada pasa a `DELAY` y se renueva sola. Comparada con `VBoxManage showvminfo` (MAC no publicada) | Esperar ~10 s (Linux vuelve a preguntar por ARP) o vaciar la caché con `sudo ip neigh flush dev enp0s3`. Para la defensa: al cambiar de firewall, vaciar la caché ARP del cliente. Evidencia: `evidencias/tasca8/2026-11-21_chequeo-final.txt` | ~10–30 s (sola) |

## 7. Evidencias de esta tarea
- [2026-11-21_chequeo-final.txt](../../evidencias/tasca8/2026-11-21_chequeo-final.txt)
