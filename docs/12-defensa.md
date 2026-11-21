# 12 · Preparación de la defensa y del examen individual (Tasca 8)

Se va completando en cada fase. Respuestas **con mis palabras** y señalando la evidencia que lo demuestra.

## FDM-RA1 · Hardware, rendimiento y diagnóstico
- ¿Cuál es el cuello de botella de tu PC de clase? ¿Y del de casa? ¿Qué dato lo demuestra?
  - **Clase (17/11):** el **disco USB**. `lsusb -t` dice que negocia a **5000M** (USB 3.2 Gen1) en un puerto de 20000M, y mide 386 MB/s de lectura y 409 MB/s de escritura. Eso está cerca del máximo útil de USB 5 Gbit/s (unos 500 MB/s), y todas las VMs y el propio Mint usan ese disco. El segundo es la **RAM**: 32 GB con las dos ranuras ocupadas, y solo unos 20 GB libres con el escritorio abierto. Evidencias: `evidencias/tasca2/2026-11-17_*-clase.txt`.
- **¿Por qué tu disco va a 5 Gbit/s si el puerto admite 20?** El enlace USB va a la velocidad del elemento **más lento**: disco, cable o puerto. El puerto admite 20 Gbit/s, así que el límite está en el cable o en el disco. Lo compruebo en casa con el mismo disco y probando otro cable o puerto. La solución es que `lsusb -t` marque 10000M.
- **¿Qué diferencia hay entre velocidad secuencial e IOPS?** La **secuencial** (MB/s) es para ficheros grandes: copiar una ISO o instalar. Las **IOPS** cuentan operaciones pequeñas por segundo, como cuando arranca un sistema y lee muchos ficheros pequeños. Mi SSD da 38 700 IOPS de 4K, y un disco mecánico da unas 100. Por eso, aunque el USB limite los MB/s, las VMs arrancan bien.
- **¿Por qué el ping a 1.1.1.1 falla y aun así tienes Internet?** La red del aula **bloquea el ICMP** (el ping) hacia fuera, pero deja pasar HTTPS (`curl` da HTTP 200) y DNS (`dig @1.1.1.1` responde). Que un ping falle no quiere decir que no haya conexión: hay que probar con el protocolo que se va a usar.
- **¿Qué demuestra memtester y qué no?** Demuestra que los 512 MB que probó no tienen errores (18 de 18 pruebas «ok»). **No** prueba toda la RAM, porque la que usa el sistema no se puede probar con el sistema encendido. Para eso está memtest86+, que se arranca desde GRUB.
- ¿Qué diferencia hay entre UEFI y BIOS? ¿Por qué Windows 11 pide TPM 2.0 y Secure Boot?
- Si un PC no arranca, ¿qué comprobarías y en qué orden?
- ¿Qué te dice SMART de un disco? ¿Qué atributo mirarías primero?
- ¿Cuántas VMs puedes tener encendidas y qué recurso se acaba antes?

- **¿Por qué dices que el cuello de botella es el disco y no el PC?** Porque probé **el mismo disco en dos PCs distintos** con los mismos scripts: en los dos negocia 5000M (USB 3.2 Gen1) aunque los puertos dan 10 y 20 Gbit/s, y mide casi lo mismo (lectura 386 / 332 MB/s, escritura 409 / 382 MB/s). Si fuera culpa del puerto, cambiaría de un PC a otro. Lo que se repite es el disco y su cable; cuál de los dos limita es N/C (se probaría con otro cable Gen2).
- **¿Qué PC usas para qué?** El de casa para casi todo (más RAM libre, más fresco, Internet unas 3 veces más rápido: 11,9 frente a 3,7 MB/s). El de clase para enseñar y para el examen. El disco es el mismo, así que las VMs van igual en los dos.
- **¿Por qué el disco hace 40.000 IOPS y aun así es el cuello de botella?** Para accesos pequeños (arrancar una VM) va muy bien. Donde se nota es en lo **secuencial**: instalar sistemas, copiar discos o hacer copias grandes, que topan con los ~500 MB/s útiles de USB 5 Gbit/s, y todas las VMs se reparten ese disco.
- **El PC de casa tiene menos hilos (12) que el de clase (18). ¿Es un problema?** Puede serlo con todo encendido (~16 vCPU), pero aún no está medido (N/C): se comprueba en la Tasca 7 con `top`/`vmstat`. Por eso se trabaja por escenarios y con 2 vCPU como máximo por VM.

## FDM-RA4 · Equipos empresariales, CPD y cableado (se evalúa entero el día 25)
- Diferencias entre un PC personal y un servidor (ECC, redundancia de fuentes, gestión remota, rack…).
- ¿Qué elementos necesita una sala de servidores pequeña? (rack, SAI, ventilación, patch panel, etiquetado, seguridad física)
- ¿Cómo ordenarías y etiquetarías el cableado? ¿Por qué separar alimentación y datos?
- ¿Para qué sirve un SAI y qué datos mirarías al elegirlo (VA/W, autonomía)?

## ISO-RA1 · Instalación, red e incidencias
- ¿Por qué verificas el SHA256 de una ISO? ¿Qué te protege y qué no?
- Explica el camino de un paquete desde Client-Linux hasta Internet.
- ¿Qué es el NAT/masquerade y por qué lo necesita la LAN?
- ¿Qué diferencia hay entre un clúster, la migración y la alta disponibilidad?
- ¿Qué es un dominio y qué aporta a la empresa?
- Contenedor vs máquina virtual: ¿cuándo cada uno?

### Respuestas del P11a · Proxmox (18/11)
- **¿Por qué los nodos se llaman `pveN.thinklab.local`?** El instalador de Proxmox exige un nombre completo (nombre + dominio). `thinklab.local` es un dominio interno que no existe en Internet. El plan decía `.lan`, pero en la instalación se puso `.local` y lo dejé así, porque cambiarlo en 3 nodos antes del clúster era más trabajo y más riesgo que beneficio.
- **¿`.local` da algún problema?** `.local` está reservado para **mDNS** (RFC 6762, el «Bonjour/Avahi» que descubre equipos sin servidor DNS). Si en la red hubiera mDNS, un equipo podría intentar resolver `pve1.thinklab.local` por multidifusión en vez de preguntar al DNS. En LAN_21 no hay servicios mDNS y los nodos se resuelven por `/etc/hosts` e IP, así que no debería afectar. **N/C.** Prueba que lo confirmaría: desde Client-Linux, `getent hosts pve1.thinklab.local` y comprobar si `avahi-daemon` está activo (`systemctl is-active avahi-daemon`). En una empresa real usaría un subdominio del dominio propio (p. ej., `lab.empresa.es`) o `home.arpa` (RFC 8375).
- **¿Por qué cambiaste el repositorio de Proxmox a no-subscription?** El *enterprise* necesita una suscripción de pago: sin ella, `apt` da error 401 y no actualiza. El *no-subscription* es gratuito y tiene los mismos paquetes, pero se publican antes. Para un laboratorio vale; Proxmox lo desaconseja en producción.
- **¿Por qué hay que reiniciar después del upgrade?** Se instaló un **kernel nuevo** (7.0.2-6 → 7.0.14-29), pero el que está en memoria sigue siendo el antiguo hasta que se arranca otra vez. Se comprueba con `uname -r` o en *Summary → Kernel Version*. Los demás paquetes (pve-manager 9.2.2 → 9.2.28) ya funcionan sin reiniciar, porque se reinician solo sus servicios.
- **¿Por qué actualizar antes de montar el clúster?** Para que los 3 nodos tengan **la misma versión**. Si tienen versiones distintas, el clúster y la migración pueden fallar o avisar. Y en producción no se entra con fallos de seguridad ya corregidos.
- **¿Por qué `asier@pve` y no `asier@pam`?** `@pam` usa los usuarios de Linux del propio nodo: habría que crear el usuario en el sistema de **cada** nodo. `@pve` es la base de usuarios **de Proxmox**, que se guarda en `/etc/pve`. Al montar el clúster, `/etc/pve` se comparte y el usuario vale para los 3 nodos. Por eso solo lo creé en pve1.
- **¿Qué significa el rol Administrator en `/` con Propagate?** `/` es la raíz de todo (Datacenter, nodos, VMs, almacenamiento). *Propagate* hace que el permiso se herede hacia abajo. Así, `asier@pve` lo administra todo sin ser root. Root (`root@pam`) queda para emergencias.
- **¿Por qué `asier@pve` no entraba al principio?** En el login estaba elegido el realm «Linux PAM», que busca el usuario en Linux, donde no existe. Con el realm «Proxmox VE authentication server» entró a la primera.
- **¿Qué pasa si hay dos `apt` a la vez?** El segundo da *Could not get lock /var/lib/dpkg/lock-frontend*. Es un bloqueo para que dos instalaciones no rompan la base de datos de paquetes. No hay que borrar el fichero de bloqueo, sino esperar a que acabe el otro (incidencias 14 y 15).

### Respuestas del P13 · Windows 11 y actualizaciones (18–19/11)
- **¿Por qué Windows 11 pide TPM 2.0, Secure Boot y UEFI?** El TPM guarda claves (BitLocker, Windows Hello) en un chip del que no se pueden sacar. Secure Boot solo deja arrancar código firmado, y así frena los *bootkits*. Secure Boot solo existe con UEFI. En la VM lo comprobé con `Get-Tpm`, `Confirm-SecureBootUEFI`, `msinfo32` y `tpm.msc` (06 §8.2).
- **¿Por qué Pro y no Home?** Home no se puede unir a un dominio. Pro sí, y además tiene BitLocker, Escritorio remoto como servidor y directivas de grupo. En una empresa es lo mínimo.
- **¿Está activado tu Windows 11?** No. Instalé con la clave genérica de instalación que publica Microsoft: sirve para instalar (es lo mismo que «No tengo clave»), no para activar. Para un laboratorio vale; en una empresa haría falta licencia (OEM, retail o por volumen). Incidencia 23.
- **¿Por qué Windows 11 aceptó la contraseña corta y Windows Server no?** Server trae la directiva de complejidad activada (`PasswordComplexity = 1`); Windows 11, como equipo suelto sin dominio, no. Si se une a un dominio, manda la directiva del dominio.
- **¿Qué significa «actualizar antes de producción» (a79)?** Que cada sistema tenga la última versión estable de su rama **y** que después siga funcionando. Lo hice con la herramienta oficial de cada uno (WebUI de OPNsense, Proxmox y TrueNAS, `apt`, `/system package update`, Windows Update) y lo comprobé con la versión antes/después y una prueba de que funciona (tabla de 06 §10).
- **¿Por qué TrueNAS decía «al día» si había una versión nueva?** Porque el perfil de actualizaciones era MISSION_CRITICAL y la 25.10.8 está marcada como GENERAL. Al cambiar al perfil por defecto (GENERAL) apareció. Lo vi por consola con `midclt call update.status` (incidencia 22). «Al día» siempre es «al día **en un canal**».
- **¿Por qué no actualizaste el MikroTik?** Porque `check-for-updates` dice que la 7.25.1 instalada es la última del canal *stable*. No hay nada que instalar. Comprobarlo también es parte de actualizar.
- **¿Cómo sabes que una actualización no ha roto nada?** Antes, una instantánea de la VM; después, versión nueva + la prueba de funcionamiento del servicio (en TrueNAS: WebUI y *uptime* tras reiniciar; en FW3: interfaces *UP*). Si falla, vuelvo a la instantánea.

### Respuestas del P12 · Windows Server 2025 (18/11)
- **¿Qué edición instalaste y por qué?** *Standard Evaluation con experiencia de escritorio* (imagen 2 de la ISO). Standard porque no necesitamos lo de Datacenter (máquinas virtuales ilimitadas, almacenamiento definido por software). Con escritorio para poder administrarlo por GUI. Server Core gasta menos y tiene menos que actualizar, pero solo tiene consola.
- **¿Cómo lo instalaste?** Con `VBoxManage unattended install`: un fichero de respuestas (`autounattend.xml`) contesta todas las preguntas del instalador. En una empresa se hace lo mismo para que todos los servidores salgan iguales.
- **¿Por qué no te aceptó la contraseña sin mayúscula?** Porque Windows Server trae activada la directiva «La contraseña debe cumplir los requisitos de complejidad» (`PasswordComplexity = 1`): pide 3 de estos 4 tipos de carácter: mayúsculas, minúsculas, números y símbolos. Lo probé: sin mayúscula, `InvalidPasswordException`; con mayúscula, se crea. Se ve en `secpol.msc`.
- **¿Para qué dos administradores?** `asier`, para el día a día (se sabe quién hizo qué), y el Administrador integrado de reserva. En producción se le cambia el nombre o se deshabilita, porque es el primero que se ataca.
- **¿Por qué IP fija y no DHCP?** Es un servidor: los demás tienen que encontrarlo siempre en la misma IP (.30, bloque de identidades), y si fuera controlador de dominio también sería DNS. Además, en LAN_21 no hay DHCP.
- **¿Por qué el DNS secundario es 1.1.1.1?** Para resolver nombres aunque el firewall activo sea el Debian, que no tiene DNS. Si un día fuera controlador de dominio, su DNS sería él mismo (127.0.0.1 o .30).
- **¿Cómo se pone la IP por GUI?** `ncpa.cpl` → Ethernet → Propiedades → Protocolo de Internet versión 4 → Propiedades → «Usar la siguiente dirección IP».
- **¿Por qué el reloj iba 1 h atrasado?** VirtualBox daba el reloj en UTC (`rtcuseutc`) y Windows lo lee como hora local. Se arregla con «Sincronizar ahora» (`w32tm /resync`) y quitando «Reloj de hardware en tiempo UTC» en la VM.
- **¿Qué cambió Windows Update?** De la build 26100.1742 (la de la ISO, 2024) a la **26100.33438** con la acumulada KB5122871 y la de .NET. Hay que actualizar antes de poner el servidor «en producción», porque la ISO tiene dos años de fallos de seguridad sin corregir.
- **¿Por qué quitaste el inicio de sesión automático?** La instalación desatendida lo deja activo: quien encienda el servidor entra como `asier`, que es administrador. Un servidor tiene que pedir usuario y contraseña (`netplwiz`).
- **¿Qué es un dominio?** Ver 06-installacions §6: usuarios y normas en un solo servidor (Active Directory). Se crea el usuario una vez, se le quita el acceso una vez y se aplican directivas (GPO) a todos los equipos.

### Respuestas del P11c · VM, contenedor y migración (18/11)
- **¿Qué diferencia hay entre la VM 150 y el CT 151?** La VM emula un ordenador entero (BIOS, disco, kernel propio de Debian). El CT comparte el kernel del nodo Proxmox y solo aísla procesos, red y ficheros (LXC). Por eso el CT se crea en 7 s y arranca en 1 s, y la VM necesita instalar Debian (22 min).
- **¿Por qué la migración es *offline*?** Porque el disco está en `local-lvm`, en cada nodo. Para moverla hay que copiar el disco entero por la red y eso se hace con la VM apagada. La migración en caliente necesita almacenamiento compartido (o copiar también la RAM mientras funciona).
- **¿Por qué tardó el doble la VM?** Porque se copia el disco **asignado** (8 GiB), no lo usado (~1,4 GB), y el CT tenía 4 GiB. A la misma velocidad (~240 MB/s), el doble de tamaño supone el doble de tiempo.
- **Si copió 8 GB, ¿por qué en pve2 ocupa 1,4 GB?** `local-lvm` es LVM-Thin, que solo guarda los bloques con datos: los ceros no ocupan.
- **¿Cómo lo mejorarías?** Con almacenamiento compartido (NFS en TrueNAS): no se copia el disco y se puede migrar en caliente. También con discos más ajustados y una red dedicada a migraciones.
- **¿Por qué root no tiene contraseña en la VM 150?** Si se deja vacía en el instalador, Debian **bloquea** root y mete al usuario en `sudo`. Así se trabaja con `sudo`, queda registrado quién hizo qué y no hay una cuenta root con contraseña que atacar (`passwd -S root` → `L`).
- **¿Por qué el instalador salió en inglés?** Con 768 MiB entra en *low memory mode* y no carga los idiomas (incidencia 18). El sistema instalado funciona igual.

### Respuestas del P11b · Clúster Proxmox (18/11)
- **¿Qué es un clúster de Proxmox y qué ganas?** Varios nodos que se gestionan como **uno solo**: desde la WebUI de cualquiera se ven y se administran todos. Comparten la configuración (`/etc/pve`, con usuarios, permisos y definiciones de VMs) y permiten **migrar** VMs y contenedores de un nodo a otro (P11c). No es lo mismo que la alta disponibilidad: la HA necesita además almacenamiento compartido y reglas de HA.
- **¿Qué es el quórum y por qué 3 nodos?** Es la mayoría de votos (cada nodo, 1). Con 3 nodos hacen falta 2. Con 2 nodos, si se corta la red entre ellos, ninguno tiene mayoría y se bloquean los dos. Por eso lo mínimo recomendado es 3.
- **¿Qué es *split-brain*?** Dos partes del clúster que no se ven y creen que son «el clúster», así que podrían arrancar la misma VM dos veces y corromper los datos. El quórum lo evita: la parte sin mayoría se queda en solo lectura.
- **¿Por qué el nombre y la IP de los nodos no se pueden cambiar después?** Corosync (`/etc/pve/corosync.conf`) identifica cada nodo por su nombre y por la IP del enlace. Cambiarlos rompe la comunicación del clúster. Por eso los dejamos fijos antes (P11a).
- **¿Por qué se unen los nodos de uno en uno?** Cada unión cambia la configuración de corosync (*Config Version* sube) y reinicia `pve-cluster` en el nodo que entra. Si se hacen dos a la vez, pueden chocar.
- **¿Qué es `knet` y Secure auth?** `knet` es el transporte de corosync (Kronosnet) que usan los nodos para hablar entre ellos. *Secure auth on* quiere decir que ese tráfico va autenticado y cifrado con la clave `/etc/corosync/authkey`.

### Respuestas del P6 · OPNsense WebUI, reglas y log (17/11)
- **¿Por qué la regla de bloqueo tiene que ir encima de la «allow»?** OPNsense lee las reglas de arriba abajo y aplica la **primera que coincide**. Si la «allow LAN to any» va antes, el tráfico HTTP ya está permitido y la de bloqueo nunca se llega a mirar. Me pasó: al crearla quedó abajo y hubo que subirla.
- **¿Qué diferencia hay entre *Block* y *Reject*?** *Block* descarta el paquete en silencio: el cliente espera y reintenta, por eso el `wget` se quedaba colgado. *Reject* contesta «rechazado» y el cliente falla enseguida. *Block* da menos información a un atacante.
- **¿Para qué sirve marcar «Log» en una regla?** Para que cada paquete que coincida quede en el registro con su hora, origen, destino y el nombre de la regla. Así se puede demostrar y diagnosticar qué se bloquea y por qué.
- **¿Por qué hay muchas líneas en el log para un solo intento?** Como el firewall no contesta, el cliente reintenta la conexión TCP varias veces (cada 1–2 s). Cada reintento es un paquete nuevo y sale en el log.
- **¿Por qué en el traceroute sale 10.0.2.2 y luego ya el destino?** 192.168.21.1 es mi firewall y 10.0.2.2 la pasarela del NAT de VirtualBox. Ese NAT no es un router: abre la conexión desde mi PC, y por eso no aparecen los saltos del aula ni de Internet.
- **¿Por qué creaste el usuario `asier` si ya tenías root?** Cada administrador con su usuario: queda registrado quién hace cada cambio y root se reserva para emergencias. Además, si alguien se va de la empresa, se borra su usuario sin cambiar la contraseña de root.
- **¿Qué tiene la copia `config-….xml` y dónde la guardas?** Toda la configuración de OPNsense: interfaces, reglas, usuarios con el *hash* de su contraseña y certificados. Por eso **no** va al repositorio público. Ahora está en Client-Linux y en el P14 irá a TrueNAS.

### Respuestas del P4 · Client-Linux (17/11)
- **¿Por qué el instalador de Debian dio error de red?** Porque intenta configurar la red por **DHCP**, y en LAN_21 no hay servidor DHCP (lo desactivé en OPNsense). No es un fallo: se elige «configurar la red manualmente» y se pone la IP estática.
- **¿Cómo sabes que Client-Linux sale a Internet a través del firewall?** La ruta por defecto (`ip route`) va a 192.168.21.1, que es OPNsense, y `wget --spider https://deb.debian.org` responde 200. Además, el instalador descargó 900 MB de paquetes por esa ruta. No toqué ninguna regla: funcionan el NAT de salida y la regla «allow LAN» que trae OPNsense.
- **¿Por qué tienes Debian 13.7 si la ISO era la 13.1?** Con la netinst, el instalador descarga casi todo de la réplica, y la réplica tiene los paquetes al día. Por eso queda instalado ya actualizado.
- **¿Por qué Xfce y no GNOME?** Xfce gasta mucha menos RAM y CPU, y este equipo solo sirve para abrir el navegador y las WebUI.
- **¿Por qué no tiene servidor SSH?** Porque es un cliente: nadie tiene que entrar en él desde fuera. Lo que no se necesita no se instala; es menos superficie de ataque.
- **¿Por qué `asier` no puede usar `sudo`?** Si en el instalador de Debian le pones contraseña a root, el primer usuario no entra en el grupo `sudo`. Se administra con `su` (contraseña de root).
- **La descarga fue a 728 kB/s. ¿El firewall es lento?** No lo sé todavía (N/C). El anfitrión descargaba a 3,7–5,8 MB/s, así que puede ser el aula, la réplica o OPNsense con 1 vCPU. Lo comprobaré midiendo la CPU de OPNsense mientras descargo (P17).

### Respuestas del P3 · OPNsense por consola (17/11)
- **¿UFS o ZFS? ¿Por qué UFS?** UFS es el sistema de ficheros clásico de FreeBSD: sencillo y con poco consumo de memoria. ZFS protege mejor los datos (sumas de comprobación, instantáneas, RAID por software), pero usa mucha RAM como caché. Mi firewall va a funcionar con 1 GB y sus datos importantes se guardan en las copias, así que UFS es suficiente.
- **¿Por qué tuviste que reasignar las interfaces?** El instalador puso por su cuenta LAN = em0 y WAN = em1. En mi VM, el adaptador 1 (em0) es el NAT, o sea, la salida a Internet. Lo comprobé comparando la MAC de em0 con la del adaptador 1 de VirtualBox, y puse WAN = em0 y LAN = em1.
- **¿Por qué la LAN del firewall no tiene puerta de enlace?** Porque la puerta de enlace de la LAN **es el propio firewall** (192.168.21.1). Su salida es la WAN, que la recibe por DHCP (10.0.2.2).
- **¿Por qué desactivaste el DHCP de la LAN?** Todo el laboratorio usa IP estática, y los tres firewalls comparten la .1. Si dos tuvieran DHCP, habría servidores DHCP repartiendo a la vez cuando se cambia de firewall. Sin DHCP no hay sorpresas.
- **¿Por qué la LAN sale a Internet sin crear ninguna regla?** OPNsense trae por defecto el **NAT de salida automático** (la LAN sale con la IP de la WAN) y la regla **«allow LAN to any»**.
- **El ping a 1.1.1.1 falla. ¿Tu firewall no tiene Internet?** El ping falla también desde el anfitrión: es la red del aula, que bloquea el ICMP. En cambio, OPNsense resolvió debian.org, así que el DNS sí sale por la WAN. Y lo demostré con HTTPS: `curl -sI https://deb.debian.org` desde el shell de OPNsense responde `HTTP/2 200`. Que el ping falle no quiere decir que no haya Internet.
- **¿Por qué quitaste la ISO apagando la VM y no en caliente?** El instalador se ejecuta **desde** la ISO. Quitarla con él funcionando podría romper el último paso. Con *Halt now* se apaga limpio, se quita la ISO y arranca desde el disco (se ve «/dev/gpt/rootfs»).
- **¿Para qué sirve la instantánea `P3-opnsense-base`?** Es una foto del estado bueno. Si en el P14 rompo algo a propósito, puedo comparar o volver atrás en segundos.

### Respuestas sobre el diseño de red (17/11)
- **¿Por qué «Red interna» y no «Solo-anfitrión» o «Adaptador puente»?**
  - Con **red interna**, la LAN_21 solo la ven las VMs: es como un switch aislado, y la única salida es el firewall. Así es la LAN de una empresa.
  - Con **solo-anfitrión**, mi PC también estaría dentro de la LAN.
  - Con **puente**, las VMs aparecerían en la red del aula con IPs que pueden chocar con las de mis compañeros.
  - Además, la red interna es más simple: no hay que crear `vboxnet0` ni tocar `/etc/vbox/networks.conf`.
- **Si el anfitrión no está en la LAN, ¿cómo gestionas las WebUI?** Desde el navegador de **Client-Linux (.60)**, como haría un administrador desde su PC de la empresa. Las capturas las hago desde fuera con `VBoxManage controlvm <VM> screenshotpng`.
- **¿Por qué los tres firewalls tienen la misma IP .1? ¿No da problemas?**
  - Así cualquiera sirve de puerta de enlace **sin tocar los clientes**.
  - El problema aparece si hay **dos encendidos**: dos MAC contestan por la misma IP (conflicto **ARP**) y los clientes van saltando de una a otra, con cortes.
  - Por eso la regla es **uno solo**, y antes de arrancar uno compruebo con `VBoxManage list runningvms` que no hay otro.
- **¿Por qué las IPs van por bloques (.10 virtualización, .20 almacenamiento…)?** Por **orden**, no por rendimiento. Con ver la IP en un log ya sé qué tipo de equipo es, puedo escribir reglas por rangos y queda hueco para crecer en cada bloque.
- **¿Por qué el DNS secundario es 1.1.1.1?** El primario es el firewall (.1), pero el Debian con nftables no tiene servidor DNS. Con 1.1.1.1 de secundario los nombres se resuelven sea cual sea el firewall encendido.
- **¿Cuántos NAT atraviesa un paquete hasta Internet?** Dos: el del firewall (192.168.21.x → 10.0.2.15) y el de VirtualBox (10.0.2.15 → la IP de mi PC). Se ve con `traceroute`: primero .1 y después 10.0.2.2.
- **¿Por qué el adaptador de Proxmox va en promiscuo «Permitir todo»?** Las VM y contenedores de dentro de Proxmox usan sus propias MAC. Si no, VirtualBox solo deja pasar las tramas de la MAC del adaptador, y las de dentro se quedarían sin red.

- **¿Es seguro el sudoers sin contraseña que usaste?** Solo permite **dos scripts concretos con argumentos concretos**. Además, apunta a **copias propiedad de root**: si apuntara a un fichero que puedo editar, cualquiera con mi usuario metería ahí cualquier comando y lo ejecutaría como root. Lo validé con `visudo -cf` y se borra al terminar el proyecto.

### Respuestas preparadas en la Fase 0 (17/11)
- **¿Por qué verificas el SHA256 de una ISO? ¿Qué te protege y qué no?**
  - Si el hash que calculo coincide con el que publica el fabricante en su web, la imagen **no está corrupta** (descarga cortada, disco USB con errores) y **no la han cambiado** respecto a la oficial.
  - **No** me protege si la propia web del fabricante está comprometida, porque el hash vendría del mismo sitio. Para eso existen las firmas GPG. Tampoco dice nada de si el sistema tiene fallos de seguridad: eso se arregla actualizando (a79).
  - Evidencia: `evidencias/tasca5/verificacion-isos.txt`.
- **¿Por qué la de Windows Server sale N/C?** Microsoft no publica el hash en el Evaluation Center. Lo indico como N/C en vez de inventarlo, y guardo el SHA256 calculado como referencia.
- **¿Cómo garantizas que tu ISO de Windows 11 es fiable si no tienes hash oficial?**
  - **Al 100 % no puedo garantizarlo**, y por eso lo marco **N/C**. La rúbrica pide verificar la integridad «cuando el fabricante publique el mecanismo», y Microsoft solo publica el hash de la versión actual (26H2), no el de la 25H2.
  - Lo que sí hice:
    1. **Origen:** la descargué de la web oficial de Microsoft, no de una web de terceros.
    2. **Contenido coherente:** la ISO se abre sin errores y dentro tiene la *build* 26200.6584 en todas las ediciones, que es la 25H2 de Microsoft.
    3. **Hash guardado:** apunté su SHA256 (`5f53774d…48cd6de`) con la fecha, para compararlo si se publica el oficial o si otra persona del grupo tiene la misma ISO.
    4. **Actualización:** después de instalar pasaré Windows Update, que descarga actualizaciones **firmadas** por Microsoft.
  - Si necesitara la máxima seguridad, descargaría la 26H2, que sí tiene hash oficial.
- **¿Cómo sabes qué versión es una ISO sin fiarte del nombre?** Leo su contenido: la etiqueta del volumen (`blkid`), el fichero `.cd-info` en Proxmox y la *build* de `install.wim` en Windows. Así descubrí que `w11.iso` era una versión **sin soporte** y que las ISO de MikroTik eran el instalador x86 y no la CHR.
- **¿Por qué usas Debian 13.1 si ya existe la 13.7?** Es la misma versión mayor (trixie, con soporte hasta 2028), está verificada, y al hacer `apt full-upgrade` queda igual que la 13.7. Bajarla de nuevo no aporta nada.
- **¿Por qué hay algunas VMs por debajo del mínimo oficial (TrueNAS 4 GB de 8, OPNsense 1 GB de 3)?** Por la RAM del anfitrión y porque es un laboratorio con poca carga. Está justificado en `01-requisits.md` y se comprueba midiendo en la Tasca 7 (hasta entonces es N/C).
- **¿Qué riesgos viste en tu PC?** KVM cargado, que puede chocar con VirtualBox, y que `/home` (donde van las VMs) está en un **disco USB**, que es el posible cuello de botella de disco. Evidencia: `evidencias/tasca0/2026-11-17_comprobacion-host.txt`.
- **Tu repo es público. ¿Qué hiciste cuando viste contraseñas en el historial?**
  - Hice una **copia de seguridad** del repo con `git bundle` y **reescribí el historial** con `git filter-branch`, cambiando las contraseñas por `[CONTRASEÑA]`.
  - Comprobé con `git log -p --all | grep` que no quedaba ninguna y subí los cambios con `git push --force-with-lease`. Ese push solo machaca el remoto si está como yo lo vi por última vez, así que no borra el trabajo de otra persona.
  - Las contraseñas no las cambié porque son la convención del laboratorio, que es una red interna aislada.
  - **Límite:** si alguien ya había copiado el repo, o tiene el enlace exacto de un commit antiguo, aún podría verlas. Por eso, en un sistema real, una contraseña publicada **se cambia siempre**.
  - Para que no se repita, añadí una regla de trabajo (nunca contraseñas fuera del fichero privado). Es la incidencia nº 2 de `10-incidencies.md`.
- **¿Por qué ocultas números de serie y MAC en el inventario?** Identifican **un equipo concreto**: la MAC identifica la tarjeta de red y el número de serie identifica el aparato para la garantía, para inventarios y también para un posible robo. Para comparar rendimiento no hacen falta, así que en un repo público se ponen como `[OCULTO]`.

- **(FW3) ¿Qué hace cada cadena de tu `nftables.conf`?** `input` = lo que va al propio firewall (solo dejo lo establecido, loopback, ping y SSH desde la LAN). `forward` = lo que lo atraviesa (LAN → Internet permitido, menos HTTP). `postrouting` en la tabla `nat` = `masquerade`: cambia la IP de origen de la LAN (192.168.21.x, privada) por la de la WAN para que las respuestas sepan volver.
- **(FW3) ¿Por qué `policy drop`?** Porque es una lista blanca: lo que no permito explícitamente se tira. Si me olvido de algo, falla «cerrado» (no funciona) en vez de «abierto» (inseguro).
- **(FW3) ¿Por qué la regla del puerto 80 va antes del `accept`?** nftables lee las reglas de arriba abajo y se queda con la primera que coincide (`drop` y `accept` son finales). Si el `accept` LAN→WAN fuera primero, el HTTP pasaría y la regla de bloqueo nunca se usaría. Es el mismo error que tuve en OPNsense (incidencia 5).
- **(FW3) ¿Para qué sirve `ct state established,related accept`?** Para dejar pasar las **respuestas**. Sin ella, la LAN podría enviar la petición pero la respuesta de Internet llegaría al `forward` y la tiraría la `policy drop`.
- **(FW3) ¿Por qué `ip_forward=1`?** Por defecto Linux es un equipo final: si le llega un paquete que no es para él, lo tira. Con `ip_forward=1` lo reenvía por otra interfaz, es decir, hace de router.
- **(FW3) ¿Por qué la LAN no tiene `gateway`?** Solo puede haber una ruta por defecto, la que lleva a Internet (WAN, 10.0.2.2). La LAN es una red conectada directamente; no hace falta pasarela para llegar a ella.
- **(FW3) Explica el log.** `IN=enp0s8 OUT=enp0s3` (de la LAN hacia Internet), `SRC=192.168.21.60` (Client-Linux), `DST=…` (neverssl.com), `PROTO=TCP DPT=80` (HTTP, lo que coincide con la regla), `SYN` (primer paquete: la conexión ni empieza), mismo `SPT` en varias líneas (reintentos de la misma conexión), `TTL=63` (el router ya le restó 1).
- **(FW3) ¿Por qué el `wget` bloqueado tarda en fallar en vez de fallar enseguida?** Porque uso `drop` (tirar sin contestar). Con `reject` el firewall contestaría «no» y fallaría al momento. `drop` no da pistas a un atacante, pero hace esperar al usuario.
- **(FW3) ¿Por qué hay que hacer `ip neigh flush all` al cambiar de firewall?** Los tres firewalls usan la misma IP (.1) pero cada uno tiene su MAC. El cliente guarda en la caché ARP «.1 = MAC de OPNsense»; hasta que caduque, mandaría los paquetes a una MAC que ya no está.
- **(FW3) ¿Cómo resuelven DNS los clientes si este firewall no tiene DNS?** Con el secundario, 1.1.1.1, que está en todos los equipos justo para eso.

- **(MikroTik) ¿Por qué el CHR no se instala como los demás?** Porque MikroTik lo publica como imagen de disco ya instalada (VDI). Se arranca y se configura; no hay instalador.
- **(MikroTik) ¿Qué limita la licencia gratuita y cómo lo comprobaste?** 1 Mbit/s de lo que el router envía por cada interfaz. Lo medí descargando 15 s desde Client-Linux: 2 MB, unos 1.083 kbit/s, cuando el anfitrión baja a 95 Mbit/s. Por eso las descargas grandes las hago con FW2 o FW3.
- **(MikroTik) ¿Cómo sabes que `ether1` es la WAN?** Comparé la MAC de `ether1` en `/interface ethernet print` con la del adaptador 1 (NAT) en `VBoxManage showvminfo`. Coinciden. Además, `ether1` recibe 10.0.2.15 por DHCP, que es la red del NAT de VirtualBox.
- **(MikroTik) ¿Por qué en el MikroTik no hay `policy drop` como en nftables?** En RouterOS, si ninguna regla coincide, el paquete pasa. Con la tabla vacía, todo se permite y solo bloqueo el HTTP. En una empresa añadiría reglas `input` (aceptar lo establecido, la gestión solo desde la LAN, y `drop` al final), como hice con FW3. Aquí la WAN es el NAT de VirtualBox, al que no se llega desde fuera.
- **(MikroTik) ¿Para qué sirven los `:if … find` del script?** Para que se pueda importar dos veces sin duplicar el DHCP, la IP, el NAT o la regla. Por ejemplo, el CHR ya traía un cliente DHCP en `ether1`, y no se creó otro.
- **(MikroTik) ¿Cómo pusiste las contraseñas sin que quedaran escritas?** `admin` con `/password` y `asier` con `/user add` sin `password=`: RouterOS las pide de forma interactiva y salen como `****`. No quedan en el script (el repo es público) ni en el historial.
- **(MikroTik) ¿Por qué la hora del log no cuadra?** El router va en UTC (sin zona horaria ni NTP). Para correlacionar logs de varios equipos todos deberían tener la hora sincronizada (NTP) y la misma zona.
- **(MikroTik vs Debian) ¿Qué log es más fácil de leer?** El de RouterOS, porque usa frases (`in:ether2 out:ether1, connection-state:new`). El de nftables da más detalle técnico (TTL, ID, ventana TCP).

- **(Srv-mon) ¿Por qué root sin contraseña?** Si en el instalador de Debian se deja vacía, root queda **bloqueado** y el primer usuario entra en el grupo `sudo`. Así no hay una cuenta root con contraseña que atacar por SSH, y cada orden con `sudo` queda registrada con el nombre de quien la lanzó.
- **(Srv-mon) ¿Por qué el instalador no encontraba la réplica?** Porque los tres firewalls bloquean HTTP (puerto 80) desde la LAN, y el instalador usa `http://deb.debian.org`. El error «Réplica inválida» era nuestro propio firewall haciendo su trabajo.
- **(Srv-mon) ¿Por qué no quitaste la regla del firewall?** Porque abrir un agujero para salir del paso es mala práctica. Cambié apt a **HTTPS** (puerto 443, permitido): funciona igual y además va cifrado. Se adapta el cliente a la política de seguridad, no al revés.
- **(Srv-mon) Si apt ya comprueba firmas GPG, ¿qué aporta HTTPS?** Las firmas garantizan que el paquete es auténtico; HTTPS además **oculta qué paquetes descargas** (privacidad) y permite pasar por firewalls que solo dejan 443.
- **(Srv-mon) ¿Por qué hubo que reiniciar después de actualizar?** `full-upgrade` instaló un kernel nuevo (6.12.117), pero el que está en marcha sigue siendo el viejo (6.12.43) hasta reiniciar. Lo comprobé con `uname -r` antes y después.
- **(Srv-mon) ¿Por qué solo SSH y utilidades estándar?** La rúbrica dice «de momento ningún programa adicional». SSH es lo mínimo para administrar un servidor sin escritorio y para las copias. Cada paquete de más es algo más que actualizar y que puede fallar; `mdadm` se instalará cuando haga falta (P15).
- **(Srv-mon) ¿Cómo te aseguraste de no instalar el sistema en un disco del RAID?** En el particionado y en GRUB elegí **sda (10,7 GB)**; los siete de 1,1 GB son sdb–sdh. `lsblk` lo confirma: solo sda tiene particiones.
- **(Srv-mon) ¿Por qué no arrancaba la VM al principio?** La ISO estaba en el puerto SATA 9 y la BIOS de VirtualBox no arranca desde los últimos puertos. La pasé al puerto 1.

## ISO-RA3 · Almacenamiento, RAID y copias
- RAID 0, 1 y 5: capacidad útil, fallos que aguanta y para qué sirve cada uno.
- ¿Un RAID es una copia de seguridad? ¿Por qué no?
- ¿Qué copias de cada equipo y qué no? ¿Dónde y cómo?
- ¿Cómo recuperaste el firewall tras la errada y cuánto tardaste?

- **(TrueNAS) ¿Por qué dos discos?** TrueNAS ocupa entero el disco donde se instala y no deja guardar datos en él. Por eso hay uno de 16 GB para el sistema y otro de 20 GB para el pool `copias`. Así, reinstalar TrueNAS no borra las copias: se importa el pool y listo.
- **(TrueNAS) ¿Por qué un pool de un solo disco, sin redundancia?** Porque en el laboratorio todos los discos virtuales están en el mismo SSD USB: un espejo de dos VDI en el mismo disco físico no protege de una avería real. Las copias son la **segunda** copia de cada equipo. Una empresa pondría un espejo o RAIDZ con discos físicos distintos y además una copia fuera (3-2-1).
- **(TrueNAS) ¿Por qué 20 GB se quedan en 18,89 GiB?** ZFS reserva espacio para sus metadatos y un margen (*slop space*) para no llenarse nunca del todo. Además, GB (fabricante) y GiB (sistema) no son lo mismo.
- **(TrueNAS) ¿Qué es un dataset y por qué uno por equipo?** Es un sistema de ficheros dentro del pool con sus propias opciones: permisos, cuota, compresión, instantáneas y recurso compartido. Con uno por equipo puedo limitar lo que ocupa cada uno, dar permisos por separado y restaurar uno sin tocar los demás.
- **(TrueNAS) ¿Por qué preset SMB en `winserver` y `win11`?** Prepara los permisos al estilo Windows (ACL NFSv4) y hace que los nombres no distingan mayúsculas, que es como trabaja Windows. Los demás son *Generic* (permisos Unix).
- **(TrueNAS) ¿Qué servicios activaste y por qué solo esos?** SMB (Windows), NFS (Proxmox) y SSH (Linux, firewalls y el `cron`). FTP no, porque manda las contraseñas en texto claro; iSCSI todavía no, porque solo hace falta para el espejo del P19. Cada servicio parado es una puerta menos.
- **(TrueNAS) ¿Por qué `asier` no tiene SSH todavía?** TrueNAS exige una clave pública o permitir el login SSH con contraseña. Nuestra regla es solo clave, y la clave se crea en el P14 en Server-Monitorizacion.
- **(Copias) ¿Qué copias y qué no?** La configuración y los datos, no el sistema operativo: el sistema se reinstala desde la ISO oficial en minutos; la configuración y los datos no se pueden volver a generar. Así las copias son pequeñas y rápidas de restaurar. Tabla completa en `09-copies-contingencia.md` §1.
- **(Copias) ¿Dónde guardas la configuración del propio TrueNAS?** Fuera del NAS (en Client-Linux y en el anfitrión), nunca en el repositorio público, porque lleva datos sensibles. Si se pierde el NAS, su configuración no puede estar dentro de él.
- **(TrueNAS) ¿Por qué cambiaste la zona horaria?** Venía con la de EE. UU. (9 horas de diferencia). Las copias y los logs tienen que llevar la hora real para saber cuándo pasó algo y para cuadrar logs de varios equipos.
- **(OPNsense) ¿Por qué desactivaste la regla de bloqueo HTTP y no la borraste?** La prueba ya estaba hecha y documentada, y los instaladores de Debian/Proxmox usan réplicas `http://`. Desactivada, se reactiva con un clic para enseñarla. Antes hice una instantánea (`antes-desactivar-http`).
- **(OPNsense) Si neverssl.com aún fallaba a veces, ¿cómo sabes que no era el firewall?** `pfctl -sr` ya no tenía regla del puerto 80, el log marcaba el tráfico como `pass` y en `tcpdump` por la WAN se veía el `200 OK`. El fallo era intermitente y fuera del firewall (incidencia 13, N/C dónde).

## ISO-RA6 · Rendimiento, registros y optimización
- ¿Cómo interpretaste el registro de la conexión bloqueada?
- ¿Qué optimizaciones aplicaste y qué datos demuestran que mejoró?
- ¿Qué miras en `vmstat`/`iostat` para saber si el disco está saturado?

## P14a · Copias y recuperación de los firewalls (19/11)
- **¿Cómo sabe el script qué firewall está encendido si los tres son el .1?** Cada uno tiene una **clave de host SSH** distinta y en `~/.ssh/config` de srv-mon hay un alias por firewall (`HostKeyAlias`). Si está encendido otro, SSH se niega (la clave no coincide) y el script prueba el siguiente; si ninguno responde por SSH, es OPNsense (API).
- **¿Por qué la API en OPNsense y no SSH?** Porque así no hay que abrir SSH en el firewall, y el usuario `copias` **solo** tiene el privilegio de copias: si le roban la clave, no puede cambiar nada (la API de firmware le devuelve 403).
- **¿Cómo sabes que lo que restauras es lo que copiaste?** Por la huella SHA-256: se calcula al copiar, se comprueba en el NAS y se vuelve a mirar antes de restaurar. Y al final se compara la configuración recuperada con la copia (`diff` = 0, mismo SHA-256).
- **¿Cuánto tiempo estuvo parado cada uno y por qué tan distinto?** FW2: 2 min 47 s (2 reinicios; la recuperación, 50 s). FW3: 39 s y FW1: 25 s, pero la recuperación en sí es de 1 s: solo se restaura **la parte afectada** (reglas o NAT), sin reiniciar. Lo medí con una sonda cada segundo (`31-vigila-parada.sh`).
- **¿Qué falta para que eso sea el tiempo real en una empresa?** El tiempo de **detección**: aquí sabía cuándo provocaba el fallo. Con monitorización y alertas se reduce.
- **¿Por qué en FW1 restauras solo una línea y no el backup entero?** Porque la errada solo afectaba al NAT. Cargar el `.backup` entero reinicia el router y deshace todos los cambios posteriores a la copia. El `.backup` es para un desastre total (N/C: no probado en una CHR nueva).

## P14b · Copias del resto de equipos (19/11)
- **¿Por qué NFS para Proxmox y SMB para Windows?** Cada uno usa el protocolo **nativo** de su sistema: Proxmox monta NFS como almacenamiento (`vzdump` escribe directamente ahí) y Windows abre SMB sin instalar nada. Linux usa SSH, que además va cifrado.
- **¿Por qué el NFS tiene `maproot root` y solo 3 IPs?** `vzdump` escribe como root; sin `maproot`, NFS lo convierte en `nobody` y no podría escribir. Como eso da mucho poder, solo se permite a las IPs de los 3 nodos.
- **¿Cómo copiaste una VM encendida?** Con el modo *snapshot* de `vzdump`: Proxmox congela un momento del disco y lo copia mientras la VM sigue funcionando. El contenedor estaba apagado y se usó el modo *stop*.
- **¿Por qué la VM de 8 GiB ocupa 568 MB?** Porque solo se copian los bloques usados y luego se comprimen con zstd. El disco está casi vacío (Debian mínimo).
- **¿Por qué no copias el *System State* de Windows Server?** Porque no hay dominio ni roles con datos: con la configuración exportada en texto se vuelve a montar igual. Con Active Directory sí haría falta (N/C, no medido).
- **¿Dónde está la copia de la configuración de TrueNAS?** Fuera del NAS (en srv-mon): si se pierde el NAS, su configuración no puede estar dentro de él.
- **¿Cómo envía Client-Linux su copia si no tiene servidor SSH?** Es el cliente quien **envía** (`scp` con su clave). La clave pública se añadió al usuario `asier` de TrueNAS.

## P14c · Copias automáticas (19/11)
- **¿Qué se ejecuta, cuándo y dónde?** `cron` de `asier` en srv-mon, cada día a las 02:30, lanza `36-copias-auto.sh`: firewall activo, srv-mon, configuración de Proxmox y de TrueNAS. Las VMs las copia Proxmox con su propia tarea (domingo 02:00).
- **¿Cómo sabes que funciona sin estar tú delante?** Puse una línea de prueba para dos minutos después; `cron` lo lanzó solo y el log acabó con «todo OK». Los ficheros nuevos estaban en TrueNAS con la hora de esa ejecución.
- **¿Qué pasa si un equipo está apagado?** El script lo apunta (`--` o `ERROR`) y sigue con los demás. No para todo por un fallo.
- **¿Cómo evitas que se llene el NAS?** Rotación: se borran las copias de más de 30 días; Proxmox guarda solo las 3 últimas.
- **¿Qué mejorarías?** Un aviso por correo si el script acaba con error, y una prueba de restauración periódica (una copia que no se ha probado a restaurar no es una copia segura).

## P15 · RAID 0/1/5 (19/11)
- **¿Qué diferencia hay entre RAID 1 y RAID 5?** RAID 1 copia todo en 2 discos (50 % útil, el más simple). RAID 5 reparte datos + paridad en 3 o más discos (n−1 útil). Los dos aguantan 1 fallo; RAID 5 desperdicia menos espacio pero escribe más lento y su reconstrucción es más delicada.
- **¿Cómo demostraste que aguanta un fallo?** `mdadm --fail` → `/proc/mdstat` sale `[U_]`/`[U_U]` (degradado) y el SHA-256 del fichero de prueba sigue **OK**. Después `--remove` + `--add` y se reconstruye en 7 s.
- **¿Y el RAID 0?** `mdadm` ni siquiera deja marcar un disco como fallido. Al quitar uno, el RAID no arranca: se pierde todo.
- **¿Un RAID es una copia de seguridad?** No. Protege de que se rompa **un disco**, no de borrar un fichero o de un *ransomware*: el error se copia a todos los discos al momento.
- **Después de reiniciar los discos cambiaron de nombre, ¿se rompió algo?** No: `mdadm` usa el UUID de cada disco y `fstab` la etiqueta. Por eso no se usan nombres `sdX` en la configuración.
- **¿Las velocidades medidas valen?** Solo como tendencia: los 7 discos son ficheros del mismo SSD y pasan por la caché del anfitrión (N/C para discos reales).

## P16 · Incidencia de arranque (19/11)
- **¿Qué incidencia provocaste y cómo la resolviste?** Un `fstab` con un disco que no existe y sin `nofail`: el servidor entra en modo de emergencia. Como root está bloqueado, no deja entrar: arranqué desde GRUB con `systemd.mask=mnt-raid5.mount`, remonté `/` en escritura, corregí la línea y reinicié.
- **¿Cuánto tardaste?** 2 min 10 s desde que lo vi; 4 min en total, de los que 90 s son la espera fija de systemd.
- **¿Cómo lo evitarías?** `nofail` en los discos que no son imprescindibles y `findmnt --verify` antes de reiniciar.
- **¿No es un agujero de seguridad poder entrar por GRUB?** Sí: en un servidor real GRUB lleva contraseña y la consola está bajo llave. Aquí no se ha configurado (N/C).
- **¿Qué configuraciones son críticas en cada sistema?** La IP de LAN y el NAT de los firewalls, el quórum y `/etc/hosts` de Proxmox, el pool y los recursos de TrueNAS, la red y el DNS de Windows, y `fstab`/`mdadm.conf` en Linux. Por eso son lo que se copia en el P14.

## P17 · Rendimiento (19/11)
- **¿Qué recurso se satura primero?** La **RAM** marca cuántas VMs caben (con 28 GiB asignados quedan ~2 GiB). El **disco** es el segundo (picos del 91 %, todas las VMs en el mismo SSD). La CPU del anfitrión nunca pasa del ~22 %.
- **¿Cuántas VMs puedes tener a la vez sin que se bloquee?** Medido: **8 VMs (28 GiB)**, con latencia del anfitrión de 2 ms y sin swap. La novena no cabe en la RAM física (no lo probé para no colgar el PC; N/C).
- **¿Cómo sabes si el equipo «se bloquea»?** Por la swap (`si/so` de `vmstat`), la espera de disco (`wa`) y la latencia del anfitrión (lo que se retrasa un `sleep 0.1`). Ninguna se movió.
- **¿Por qué mediste con carga y no en reposo?** Porque en reposo todo «cabe»: las VMs casi no usan CPU ni disco. El límite real se ve cuando trabajan (copias, `vzdump`, arranque de Windows).
- **Si la red física casi no se usa, ¿por dónde van las copias?** Por la red interna `LAN_21`, que está dentro de VirtualBox (en memoria). Por eso llega a 131 MB/s sin tocar la Wi-Fi.
- **¿Qué miras en `iostat`?** `%util` (cuánto tiempo está ocupado el disco) y `r_await`/`w_await` (cuánto espera cada operación). Con un SSD, `%util` alto pero esperas bajas (5–7 ms) quiere decir que va cargado pero sin cola.

## P18 · Optimizaciones (19/11)
- **¿Qué optimizaciones aplicaste y qué datos lo demuestran?** 1) FW2 de 3 a 1 GB: gasta 1,7 GiB menos en el anfitrión con el mismo arranque (28 s) y el mismo servicio. 2) virtio-net en srv-mon y TrueNAS: iperf3 de 7,2 a 12,5 Gbit/s (y de 6,0 a 12,4 al revés) con menos CPU.
- **¿Por qué virtio va más rápido?** La e1000 emula un chip real paquete a paquete; virtio es un dispositivo pensado para VMs: el invitado sabe que es virtual y le pasa los datos a VirtualBox con mucho menos trabajo.
- **¿Por qué en una copia real solo mejoró un 14 %?** Porque el cuello de botella era la CPU de srv-mon (cifrado SSH, 94 %), no la red. Optimizar lo que no es el cuello de botella mejora poco.
- **¿Por qué no pusiste virtio en Windows?** Windows no trae el driver; habría que instalar los drivers VirtIO. Linux y FreeBSD sí lo traen.
- **¿Qué riesgo tiene bajar OPNsense a 1 GB?** Para actualizaciones grandes o reinstalar hay que volver a subirlo (el instalador pide 3 GB). Y OPNsense no tiene swap.

## P19 · Espejo entre dos equipos (19/11)
- **¿Qué es iSCSI?** Un protocolo que presenta un disco **por la red** como si fuera un disco local: srv-mon ve el volumen de TrueNAS como `/dev/sdi` («TrueNAS iSCSI Disk»).
- **¿Por qué iSCSI + mdadm y no DRBD o Ceph?** Es lo más simple que hace un espejo **síncrono** con lo que ya teníamos (TrueNAS trae iSCSI; `mdadm` ya lo usé en el P15). DRBD es otro software y Ceph pide 3 nodos y mucha RAM, que no hay.
- **¿Qué pasa si se cae TrueNAS?** A los ~15 s el disco remoto se marca como fallido, el espejo sigue con el local (`[U_]`) y se puede trabajar. Al volver, `--re-add` y en 2 s está otra vez `[UU]`: el **bitmap** solo copia lo que cambió.
- **¿Por qué bajaste el `replacement_timeout` a 15 s?** Con los 120 s por defecto, el espejo se queda colgado 2 minutos esperando a TrueNAS. Para un disco que forma parte de un RAID es mejor que falle rápido y que el RAID siga con el otro.
- **¿Qué pasó al reiniciar srv-mon?** El espejo arrancó solo con el disco local, porque el disco iSCSI llega más tarde por la red. Lo arreglé con un servicio de systemd que lo vuelve a añadir cuando iSCSI ya está conectado.
- **Caso de uso:** si se rompe el disco de srv-mon (el que lanza las copias), sus scripts y registros están en TrueNAS al mismo tiempo. Lo demostré montando el espejo **solo** con el disco de TrueNAS: los 11 ficheros estaban y sus SHA-256 coincidían.
- **¿Esto sustituye a las copias?** No: si borro un fichero, se borra en los dos discos. El espejo protege de un **fallo de hardware**; las copias, de **errores y borrados**.

## Revisión final (21/11)
- **¿Por qué al cambiar de firewall falla el primer ping al .1?** Porque mi PC recuerda la MAC del firewall de antes (caché ARP) y le sigue mandando los paquetes a una tarjeta que ya está apagada. A los pocos segundos vuelve a preguntar y aprende la nueva. Se arregla al momento con `sudo ip neigh flush dev enp0s3` (incidencia 28).
- **¿Cómo sabes que el documento recuperado es el mismo?** El SHA-256 de antes de borrarlo y el de después de restaurarlo son iguales, y `ls -l` muestra los mismos permisos (640), dueño y fecha. Usé `scp -p` para que se conservaran (09 §2.1).

## Una decisión que una respuesta genérica no resolvía
El diseño de la red lo propuse yo. La IA proponía una red «solo-anfitrión», pero yo decidí usar una **red interna (LAN_21)** y poner la **misma IP, la .1, en los tres firewalls**.
Así el PC del aula no está dentro de la red de la empresa: todo lo que entra o sale tiene que pasar por el firewall, como en una empresa de verdad.
Y como los tres firewalls usan la misma puerta de enlace, puedo cambiar uno por otro sin tocar nada en los demás equipos; la única regla es tener solo uno encendido.
La prueba es el `traceroute`: con cada firewall, el primer salto es 192.168.21.1 y el segundo el NAT de VirtualBox ([`2026-11-21_chequeo-final.txt`](../evidencias/tasca8/2026-11-21_chequeo-final.txt)).
Y el aislamiento se ve en que el anfitrión no tiene IP en LAN_21: la única entrada de gestión es un puerto que solo escucha en `127.0.0.1` del propio PC ([04 §6](04-disseny.md)).

## Glosario (en palabras sencillas)
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

---
## Chuleta para el examen individual (Tasca 8, miércoles 25/11)
El examen es un **caso práctico sobre mi entorno**. Antes de empezar: enchufar el PC (incidencia del 18/11: iba con batería), `VBoxManage list runningvms` (**un solo firewall**), y arrancar el escenario que pida el caso ([05-recursos](05-recursos.md) §3). Hay instantáneas `P20-final` de todas las VMs por si algo se rompe.

| Si piden… | IDs | Cómo lo hago (y dónde está explicado) |
|---|---|---|
| **Incidencia de hardware** | a25, a26 | `sudo -n /usr/local/lib/thinklab-asier/01-inventario-hw.sh clase` y `02-tests-diagnostico.sh clase` (inventario y tests), `sensors`, `dmesg -T \| grep -iE 'error\|fail'`, `smartctl -H`. Síntoma → hipótesis → prueba → solución → **comprobar** ([02-inventari](02-inventari.md), [10-incidencies](10-incidencies.md)) |
| **Equipos, conexiones, puertos, alimentación, cableado, esquema** | a50–a53 | Esquema `diagramas/red-lan21.png` + tabla de IPs e interfaces ([04-disseny](04-disseny.md)); puertos: 22 SSH, 80/443 WebUI, 3260 iSCSI, 445 SMB, 2049 NFS, 8006 Proxmox. Alimentación/ventilación/cableado: [02-inventari](02-inventari.md) |
| **Incidencia de instalación, actualización o arranque** | a80 | Consola de la VM (`captura.sh … vm`) para ver el mensaje. `fstab` → GRUB «e» + `systemd.mask=<unidad>.mount` o `init=/bin/bash`, `mount -o remount,rw /`, `findmnt --verify` ([06](06-installacions.md) §11). Windows que no arranca del DVD → pulsar tecla (incidencia 19). Actualizaciones: §10 |
| **Recuperar información o un sistema** | a104 | Copias en TrueNAS `copias/<equipo>/` con SHA-256. Firewall: `30-copia-firewall.sh` y los procedimientos de [09](09-copies-contingencia.md) §2 (FW2: `fetch` + `/conf/config.xml`; FW3: `tar` + `nft -c`; FW1: `/import`). Proxmox: *Backup → Restore* desde `copias-nas`. Linux: `tar xzf`. Windows: `robocopy` desde el recurso SMB. Disco: RAID `mdadm --re-add`; espejo `md2` solo con el disco de TrueNAS ([07](07-raid.md) §2) |
| **Problema de rendimiento** | a122 | `scripts/50-medir-rendimiento.sh <caso> 60` en el anfitrión y `vmstat 5` / `iostat -x 5` / `top` dentro de la VM. Mirar: `si/so` (swap), `wa` (disco), `r` frente a los hilos, `%util` y `await`. Causas típicas: poca RAM (swap), demasiadas VMs, 1 vCPU saturada, tarjeta e1000 en vez de virtio ([08](08-rendiment.md)) |
| **Cuestionario por RA** | a30, a57, a84, a110, a126 | Repasar este documento entero (preguntas por fase) y los «Análisis» de cada `.md` |

**Regla para el examen:** cada afirmación con su prueba (una salida de comando o una captura), y lo que no dé tiempo a comprobar, decirlo como **N/C** con la prueba que lo confirmaría.
