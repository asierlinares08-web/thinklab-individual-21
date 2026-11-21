# Tasca 0 · Muntatge de l’entorn de proves

Evidencias de esta tarea: [../../evidencias/tasca0/](../../evidencias/tasca0/)

> Entrega individual · Asier · puesto 21 · proyecto «Naix un sistema» V2.0. Documento autocontenido: el contenido sale de [`docs/`](../../docs/) y las evidencias están en [`evidencias/`](../../evidencias/). Uso de IA declarado en [11-us-ia](../../docs/11-us-ia.md).

**Objetivo:** Montar el entorno de pruebas propio (un PC del aula con VirtualBox), identificar sus recursos físicos y sus límites, y documentarlo en Markdown y Git.

**En pocas palabras:** Mi laboratorio es un solo PC con VirtualBox en el que viven todas las máquinas virtuales de la empresa simulada. Antes de montarlo comprobé que el PC aguanta (procesador con virtualización, unos 30 GB de RAM, disco) y anoté sus límites. Todo queda documentado en este repositorio: qué máquinas hay, cuántos recursos usa cada una y qué problemas se resolvieron.

## 1. Actividades de la rúbrica

| ID | Nivel | RA | Actividad (texto de la rúbrica) | Estado |
|---|---|---|---|---|
| a17 | Apte | FDM-RA1 | Preparar l’entorn propi de proves. | ✅ hecha |
| a18 | Apte | FDM-RA1 | Identificar-ne els recursos físics i justificar-ne les limitacions. | ✅ hecha |
| a127 | Apte+ | FDM-RA1 | Documentar l’entorn propi en Markdown i Git: esquema de VM, recursos i problemes resolts. | ✅ hecha |

## 2. Cómo leer esta entrega
Cada apartado sigue el ThinkLoop: **predicción → decisión → implementación → verificación → análisis**. Cada evidencia va con una línea «Demuestra: …».

## 3. Requisitos del entorno

### 1. Requisitos del entorno individual (Tasca 0)
Lo que pide el enunciado para la parte individual (resumen con mis palabras):
- Preparar un entorno de pruebas en mi equipo que simule «más o menos» el del grupo (no todo ni exactamente igual).
- Según el hardware, no todas las VMs podrán arrancar a la vez → hay que justificarlo (ver [05-recursos](../../docs/05-recursos.md)).
- LAN `192.168.21.0/24` (puesto 21). La WAN del servidor de comunicaciones puede ir por DHCP (NAT en VirtualBox).
- Mismos sistemas operativos que el grupo (Tasca 5 individual).

## 4. Recursos, tabla de máquinas y entorno terminado

### 1. Recursos del anfitrión
PC de clase: Intel Core Ultra 5 125H (14 núcleos / 18 hilos) y **32 GB de RAM DDR5** (2 × 16 GB, 30,6 GB usables). Las VMs van en un SSD externo por **USB**, a 5 Gbit/s.
Fuente: [`evidencias/tasca2/2026-11-17_inventario-clase.txt`](../../evidencias/tasca2/2026-11-17_inventario-clase.txt); detalle en [02-inventari](../../docs/02-inventari.md).

Reserva para el propio anfitrión (Mint + navegador + VirtualBox): **6 GB de RAM** → quedan **26 GB para las VMs**.

### 2. Tabla de máquinas (P2 · revisada por Asier el 17/11 y creada con `scripts/11-crear-vms.sh`)
Valores **reales**, comprobados con `VBoxManage showvminfo` después de crearlas: [`evidencias/tasca0/2026-11-17_vms-creadas.txt`](../../evidencias/tasca0/2026-11-17_vms-creadas.txt). Esa evidencia demuestra que las 11 VMs están en `/ThinkLab-asier` con la CPU, la RAM, los discos, la red, la VT-x anidada, el promiscuo, EFI, TPM 2.0 y las claves de Secure Boot de la tabla. La segunda ejecución del script salta las 11, así que el script es repetible.

Para todas las VMs:
- Grupo VirtualBox `/ThinkLab-asier`, en `~/VirtualBox VMs/ThinkLab-asier/` (en el disco USB).
- Discos **VDI dinámicos**: solo ocupan lo que se usa.
- Controlador **SATA (AHCI)**, porque Windows Server no arranca desde IDE.
- Tarjeta de red **Intel PRO/1000 MT** (82540EM), para que las interfaces se llamen `em0/em1`, `enp0s3/enp0s8` y `ether1/ether2`.
- Sin audio ni USB.

| VM | Tipo VBox | vCPU | RAM | Disco(s) | Adaptadores | Extras | Justificación |
|---|---|---|---|---|---|---|---|
| FW1-MikroTik | Linux26_64 | 1 | 288 MB | `chr-7.25.1.vdi` (imagen oficial descomprimida, 128 MB) | 1 NAT · 2 LAN_21 | Arranca del disco, sin ISO | CHR se distribuye ya instalado como disco VDI. RAM: la fórmula oficial de RouterOS v7 es 256 + 8 × CPU × (interfaces − 1) = **264 MB** con 1 CPU y 2 interfaces. Se redondea a **288 MB** para no quedar por debajo del mínimo |
| FW2-OPNsense | FreeBSD_64 | 1 | 3 GB → **1 GB** (P18) | 16 GB | 1 NAT · 2 LAN_21 | ISO OPNsense 26.7 | El manual oficial pide **3 GB para que funcione el instalador**. Después se baja a 1 GB como optimización candidata del **P18**, midiendo antes y después |
| FW3-Debian-NFT | Debian12_64 ¹ | 1 | 512 MB | 8 GB | 1 NAT · 2 LAN_21 | ISO Debian 13.1 | Mínimo oficial de Debian sin escritorio: 512 MB y 4 GB de disco. Se instala con el instalador de **texto** (con < 780 MB el gráfico no va) |
| Proxmox-Node1/2/3 | Debian12_64 ¹ | 2 | 3 GB c/u | 32 GB c/u | 1 LAN_21 (promiscuo «permitir todo») | **VT-x anidada** · ISO Proxmox 9.2 | Mínimo oficial: 1 GB para pruebas. Con 3 GB caben dentro la VM .150 (512 MB) y el contenedor .151 (256 MB). El promiscuo deja pasar las MAC de las VM internas; la VT-x anidada deja a Proxmox virtualizar |
| NAS-TrueNAS | Debian12_64 ¹ | 2 | 8 GB | 16 GB sistema + **20 GB copias** | 1 LAN_21 (virtio desde el P18) | ISO TrueNAS 25.10.7 | **Mínimo oficial de TrueNAS: 8 GB** y 2 núcleos. TrueNAS necesita un disco solo para el sistema y otro aparte para el pool de copias (Tasca 5) |
| WinServer-2025 | Windows2022_64 ¹ | 2 | 4 GB | 50 GB | 1 LAN_21 | **EFI** · VBoxSVGA 128 MB de vídeo · ISO `w2k25.iso` | Oficial: 2 GB, y **4 GB recomendado con escritorio**; disco mínimo 32 GB. EFI como en un servidor actual |
| Server-Monitorizacion | Debian12_64 ¹ | 1 | 1 GB | 10 GB + **7 × 1 GB** | 1 LAN_21 (virtio desde el P18) · 2 NAT de gestión (04 §6) | ISO Debian 13.1 | RAM recomendada de Debian sin escritorio: 1 GB. Los 7 discos de 1 GB son para RAID 0, 1 y 5 y la prueba de fallo (P15) |
| Client-Win11 | Windows11_64 | 2 | 4 GB | 64 GB | 1 LAN_21 | **EFI + Secure Boot + TPM 2.0** · VBoxSVGA 128 MB de vídeo · ISO `win11.iso` (25H2) | **Mínimos oficiales exactos** de Windows 11: 2 núcleos, 4 GB, 64 GB, UEFI con Secure Boot y TPM 2.0 |
| Client-Linux | Debian12_64 ¹ | 2 | 3 GB | 25 GB | 1 LAN_21 | VMSVGA 128 MB de vídeo · ISO Debian 13.1 (el escritorio se elige al instalar) | Debian con escritorio recomienda 2 GB. Se da 1 GB más porque es la **consola de gestión** con navegador (WebUI de OPNsense, Proxmox y TrueNAS) |

¹ VirtualBox 7.0.20 no tiene los tipos «Debian 13» ni «Windows Server 2025». Se usan los más cercanos (`Debian12_64`, `Windows2022_64`), que solo ponen valores por defecto y no limitan nada.

**Disco:** como mucho 312 GB si los discos dinámicos se llenaran del todo. Hay 693 GB libres. Recién creadas, las 11 VMs ocupan **53 MB** (VDI dinámicos vacíos + la CHR).

**RAM con todo encendido** (un solo firewall, OPNsense a 3 GB): 3 + 9 + 8 + 4 + 1 + 4 + 3 = **32 GB** → **no cabe** en los 26 GB disponibles. Por eso se trabaja por escenarios.

**Estado final (19/11, después del P18):** FW2 tiene **1 GB** y srv-mon y TrueNAS usan la tarjeta **virtio-net** (más rápida, 08 §5). Con todo encendido: 1 + 9 + 8 + 4 + 1 + 4 + 3 = **30 GB**, todavía por encima de lo que cabe sin swap (~27–28 GiB). **Medido en el P17:** hasta **8 VMs (28 GiB)** a la vez sin bloquear el equipo; el límite es la RAM y después el disco ([08-rendiment](../../docs/08-rendiment.md) §4).

### 3. Escenarios de arranque (RAM total según la propuesta P2)
Todos llevan **1 firewall** (regla de oro: nunca dos a la vez) y **Client-Linux**, que es el puesto de gestión web.

| Escenario | VMs encendidas | RAM total | ¿Cabe en 26 GB? | Para qué |
|---|---|---|---|---|
| A · Comunicaciones | 1 firewall + Client-Linux | MikroTik: **3,3 GB** · Debian: **3,5 GB** · OPNsense: **6 GB** | ✅ | Instalar y probar cada firewall: NAT, reglas, logs |
| B · Clúster | FW2-OPNsense + Proxmox-Node1/2/3 + Client-Linux | **15 GB** (13 GB con OPNsense a 1 GB) | ✅ | Clúster y migración |
| C · Copias | FW2-OPNsense + NAS-TrueNAS + Server-Monitorizacion + Client-Linux | **15 GB** (+ el equipo que se copia, hasta 4 GB → **19 GB**) | ✅ | Copias y recuperación |
| D · Windows | FW2-OPNsense + WinServer-2025 + Client-Win11 + Client-Linux | **14 GB** | ✅ | Instalación y copias de Windows |

En los escenarios B, C y D va FW2-OPNsense porque no tiene el límite de 1 Mbit/s de la CHR gratuita y tiene DNS propio.
Las RAM son de diseño. Lo que de verdad aguanta el equipo se mide en la Tasca 7 (P17).

### 4. Comprobación de arranque con KVM cargado (P2, 17/11)
Comprobación previa del anfitrión: [`2026-11-17_comprobacion-host.txt`](../../evidencias/tasca0/2026-11-17_comprobacion-host.txt). Demuestra: la CPU tiene VT-x, hay ~30 GB de RAM, las VMs van en un disco **USB** (`/home` en `sda`) y está el **aviso de KVM cargado** que se comprueba en este apartado.

El anfitrión tiene cargados `kvm_intel` y `kvm` (riesgo nº 1 previsto en el plan: `VERR_VMX_IN_VMX_ROOT_MODE`). Se arrancó **solo FW2-OPNsense**:
- `VBoxManage startvm` → «successfully started», y el estado se mantiene en `running`.
- `VBox.log`: «HM: HMR3Init: VT-x w/ nested paging and unrestricted guest execution hw support», sin ningún `VERR_`.

![FW2-OPNsense arrancando el instalador](../../evidencias/tasca0/2026-11-17_fw2-opnsense-arranca-instalador.png)

Demuestra: con KVM cargado, VirtualBox sí puede usar VT-x. OPNsense 26.7 (amd64) arranca desde la ISO en modo *live* y llega al `login:` del instalador.
⚠️ Para el P3: OPNsense ha puesto por su cuenta **LAN = em0** y **WAN = em1**, al revés de nuestro diseño (em0 = WAN por NAT, em1 = LAN_21). Hay que **reasignar las interfaces** en la consola.


### 5. Entorno de pruebas terminado (a17 · P13, 19/11/2026)
Con el P13, **las 11 VMs del diseño (§2) están instaladas, configuradas y probadas**, cada una con su instantánea de base para volver atrás si una prueba sale mal:

| VM | Estado | Última instantánea | Dónde está documentada |
|---|---|---|---|
| FW1-MikroTik | RouterOS 7.25.1 (al día) | `P8-fw1-base` | 06 §1 |
| FW2-OPNsense | 26.7.9_3 | `antes-desactivar-http` (+ `P3`, `P6`) | 06 §2 |
| FW3-Debian-NFT | Debian 13.7, nftables | `P13-fw3-actualizado` | 06 §3 |
| Proxmox-Node1/2/3 | PVE 9.2.28, clúster `thinklab`, VM 150 + CT 151 | `P11c-migracion` | 06 §5 |
| NAS-TrueNAS | 25.10.8, pool `copias` | `P13-truenas-25.10.8` | 06 §4 |
| WinServer-2025 | 26100.33438 | `P12-winserver-base` | 06 §6 |
| Server-Monitorizacion | Debian 13.7 + 7 discos para el RAID | `P10-srv-mon-base` | 06 §7 |
| Client-Win11 | Win11 Pro 25H2 (Windows Update pendiente) | `P13-win11-base` | 06 §8 |
| Client-Linux | Debian 13.7 + XFCE (puesto de gestión) | `P4-client-linux-base` | 06 §9 |

Todas en el grupo `/ThinkLab-asier`, en la red interna `LAN_21` y arrancadas por escenarios (§3), con un solo firewall encendido. Las instantáneas se listan con `VBoxManage snapshot <VM> list`.

## 5. Documentación en Markdown y Git

El repositorio es la documentación del entorno: la portada ([README](../../README.md)) resume las VMs, los recursos medidos y los problemas resueltos; el detalle está en [`docs/`](../../docs/), las salidas y capturas en [`evidencias/`](../../evidencias/), los scripts en [`scripts/`](../../scripts/) y los esquemas en [`diagramas/`](../../diagramas/). Todas las incidencias: [10-incidencies](../../docs/10-incidencies.md).

## 6. Incidencias de esta tarea
Formato: síntoma → hipótesis → comprobación → solución → tiempo. Lista completa en [10-incidencies](../../docs/10-incidencies.md).

| # | Fecha | Sistema | Síntoma | Hipótesis | Comprobación | Solución | Tiempo |
|---|---|---|---|---|---|---|---|
| 1 | 17/11 | Anfitrión (descarga de MikroTik CHR) | `curl` corta la descarga a medias: errores 92 (HTTP/2 *stream not closed cleanly*) y 18 (*transfer closed with … bytes remaining*) | Conexión inestable o el servidor corta las conexiones largas | Repetir con HTTP/1.1: vuelve a cortarse, así que no es cosa del protocolo | Reanudar la descarga donde se quedó (`curl -C -`) en un bucle de reintentos; después comprobar el tamaño exacto (45 329 245 bytes) y la integridad del zip con `7z t` | ~10 min |
| 2 | 17/11 | Repositorio GitHub (público) | **Síntoma:** al revisar el historial con `git log -p` aparecen las contraseñas del laboratorio en 2 ficheros de documentación (5 commits publicados) | **Causa:** se escribieron como ejemplo al explicar la complejidad de contraseñas de Windows Server (propuesta registrada en `11-us-ia.md`) | `git log -S'<contraseña>'` y `git grep`: 2 ficheros y 5 commits. Las contraseñas no se cambian porque son la convención del laboratorio (red interna aislada) | **Solución:** copia de seguridad con `git bundle create ../backup-antes-limpieza.bundle --all` → `git filter-branch --tree-filter` con `sed` (cambia las contraseñas por `[CONTRASEÑA]` en todo el historial) → `git log -p --all \| grep` da 0 → `git push --force-with-lease`. Prevención: regla de trabajo nueva (nunca contraseñas, ni de ejemplo, fuera del fichero privado). Nota: GitHub puede seguir mostrando un tiempo los commits antiguos si alguien tiene su enlace exacto | ~20 min |
| 6 | 17/11 | Anfitrión (control de las VMs) | No se puede hacer clic dentro de Client-Linux desde un script: `python3` con `vboxapi` (`IMouse.putMouseEventAbsolute`) da **violación de segmento** | Fallo de las *bindings* XPCOM de VirtualBox 7.0 con el Python de Mint | Se repite con `VBOX_PROGRAM_PATH`/`VBOX_SDK_PATH`: el mismo `exit 139` | Manejar la WebUI **solo con teclado** (Ctrl+F para situarse, Tab / Mayús+Tab, espacio, Intro), con una captura después de cada tecla para ver dónde está el foco | ~10 min |

## 7. Evidencias de esta tarea
- [2026-11-17_comprobacion-host.txt](../../evidencias/tasca0/2026-11-17_comprobacion-host.txt)
- [2026-11-17_fw2-opnsense-arranca-instalador.png](../../evidencias/tasca0/2026-11-17_fw2-opnsense-arranca-instalador.png)
- [2026-11-17_vms-creadas.txt](../../evidencias/tasca0/2026-11-17_vms-creadas.txt)
- [2026-11-17_inventario-clase.txt](../../evidencias/tasca2/2026-11-17_inventario-clase.txt)
