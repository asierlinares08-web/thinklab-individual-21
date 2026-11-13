# Tasca 0 y 4 — Dimensionamiento de Recursos y Limitaciones del Hardware

* **Módulo / RA asociado:** FDM-RA1 (Ítems `a17`, `a18` y `a127` — Entorno individual, identificación de recursos físicos y justificación de limitaciones)
* **Hipervisor utilizado:** Oracle VM VirtualBox (Tipo 2) sobre sistema anfitrión Linux (`/home/batoi/VirtualBox VMs`)
* **Hardware físico del equipo anfitrión:** $32\text{ GB}$ de memoria RAM, $12$ núcleos de CPU y almacenamiento principal en SSD.
* **Método de despliegue:** Automatización reproducible mediante script en Bash con `VBoxManage` (controladora virtual `SATA IntelAhci` y discos dinámicos `.vdi`).

---

## 1. Tabla de Dimensionamiento de las Máquinas Virtuales (Puesto 21)

Para replicar la infraestructura completa de la empresa en el entorno individual de pruebas, se han desplegado **11 máquinas virtuales** conectadas a la red interna `LAN_21` (`192.168.21.0/24`) con los siguientes parámetros exactos:

| Máquina Virtual | Sistema Operativo (`--ostype`) | vCPU | RAM Asignada | Almacenamiento Virtual (`.vdi`) | Red VirtualBox | Rol en la Infraestructura |
| :--- | :--- | :---: | :---: | :--- | :--- | :--- |
| **FW1-MikroTik** | RouterOS CHR 7.16.1 (`Linux_64`) | 1 | $512\text{ MB}$ | `mikrotik_chr.vdi` (Preinstalado, $\approx 128\text{ MB}$) | `nic1`: NAT<br>`nic2`: `LAN_21` | Cortafuegos / Router (Alternativa 1) |
| **FW2-OPNsense** | OPNsense 26.7 (`FreeBSD_64`) | 2 | $2048\text{ MB}$ | `opnsense.vdi` ($16\text{ GB}$ / $16384\text{ MB}$) | `nic1`: NAT<br>`nic2`: `LAN_21` | Cortafuegos / Router (Alternativa 2) |
| **FW3-Debian-NFT** | Debian + `nftables` (`Debian_64`) | 1 | $1024\text{ MB}$ | `debian_nft.vdi` ($16\text{ GB}$ / $16384\text{ MB}$) | `nic1`: NAT<br>`nic2`: `LAN_21` | Cortafuegos / Router (Alternativa 3) |
| **NAS-TrueNAS** | TrueNAS SCALE 25.10 (`Debian_64`) | 2 | $4096\text{ MB}$ | `truenas_so.vdi` ($16\text{ GB}$)<br>`truenas_datos.vdi` ($20\text{ GB}$) | `nic1`: `LAN_21` | Almacenamiento centralizado y Backups |
| **Proxmox-Node1** | Proxmox VE (`Debian_64`) | 2 | $2048\text{ MB}$ | `pve1.vdi` ($32\text{ GB}$ / $32768\text{ MB}$) | `nic1`: `LAN_21` | Nodo 1 del clúster (`Nested Virt ON`) |
| **Proxmox-Node2** | Proxmox VE (`Debian_64`) | 2 | $2048\text{ MB}$ | `pve2.vdi` ($32\text{ GB}$ / $32768\text{ MB}$) | `nic1`: `LAN_21` | Nodo 2 del clúster (`Nested Virt ON`) |
| **Proxmox-Node3** | Proxmox VE (`Debian_64`) | 2 | $2048\text{ MB}$ | `pve3.vdi` ($32\text{ GB}$ / $32768\text{ MB}$) | `nic1`: `LAN_21` | Nodo 3 del clúster (`Nested Virt ON`) |
| **WinServer-2025** | Windows Server 2025 (`Windows2022_64`) | 2 | $4096\text{ MB}$ | `winserver.vdi` ($40\text{ GB}$ / $40960\text{ MB}$) | `nic1`: `LAN_21` | Controlador de Dominio e Identidades |
| **Server-Monitorizacion** | Debian GNU/Linux (`Debian_64`) | 1 | $1024\text{ MB}$ | `monitor.vdi` ($16\text{ GB}$ / $16384\text{ MB}$) | `nic1`: `LAN_21` | Supervisión de red y alertas |
| **Client-Win11** | Windows 11 (`Windows11_64`, UEFI) | 2 | $4096\text{ MB}$ | `win11.vdi` ($32\text{ GB}$ / $32768\text{ MB}$) | `nic1`: `LAN_21` | Puesto cliente departamental Windows |
| **Client-Linux** | Debian GNU/Linux (`Debian_64`) | 1 | $2048\text{ MB}$ | `linux_client.vdi` ($16\text{ GB}$ / $16384\text{ MB}$) | `nic1`: `LAN_21` | Puesto cliente departamental Linux |

---

## 2. Análisis Técnico: Suma Teórica vs. Realidad Operativa

Al sumar la totalidad de los recursos definidos en las 11 máquinas virtuales del script de despliegue, obtenemos:

* **Memoria RAM total configurada:**
  $$512 + 2048 + 1024 + 4096 + (3 \times 2048) + 4096 + 1024 + 4096 + 2048 = 25088\text{ MB} = 24,5\text{ GB}$$
* **Procesadores virtuales totales (vCPU):**
  $$1 + 2 + 1 + 2 + (3 \times 2) + 2 + 1 + 2 + 1 = 18\text{ vCPUs}$$
* **Capacidad máxima de disco virtual aprovisionada:**
  $$16 + 16 + (16 + 20) + (3 \times 32) + 40 + 16 + 32 + 16 = 268\text{ GB} \text{ (+ } 128\text{ MB CHR)}$$

### Justificación de viabilidad frente a las limitaciones del hardware físico ($32\text{ GB}$ RAM / $12$ núcleos)

1. **Exclusión mutua de los 3 cortafuegos (`FW1`, `FW2` y `FW3`):**
   * Los tres cortafuegos comparten la misma dirección IP de puerta de enlace (`192.168.21.1/24`) en `LAN_21` para evaluar tres tecnologías equivalentes (RouterOS, FreeBSD/OPNsense y Debian/`nftables`). **Nunca se ejecutan simultáneamente**, lo que descuenta automáticamente entre $1,5\text{ GB}$ y $3\text{ GB}$ de RAM y entre $1$ y $3$ vCPUs en cualquier escenario real.
2. **Operación modular por escenarios de prueba (sin *swapping*):**
   * En sesiones normales de laboratorio tendremos arrancadas entre **3 y 5 máquinas virtuales simultáneas** (por ejemplo: $1\text{ cortafuegos} + \text{NAS-TrueNAS} + 1\text{ servidor} + 1\text{ cliente}$).
   * El consumo real en ejecución oscila entre **$10\text{ GB}$ y $15\text{ GB}$ de RAM**, dejando siempre **más de $16\text{ GB}$ libres** para el sistema operativo anfitrión Linux. De este modo evitamos que el *kernel* tenga que volcar páginas de memoria a la partición de intercambio (*swap* en disco), fenómeno que dispararía la latencia de E/S y bloquearía las VMs.
3. **Gestión controlada de sobreasignación de CPU (*CPU Overcommitment*):**
   * Aunque la suma estática es de $18\text{ vCPUs}$ sobre $12$ núcleos físicos, al operar por escenarios activos nunca superamos entre $6$ y $10$ vCPUs simultáneas. Esto garantiza que cada hilo virtual disponga de tiempo de procesador físico sin colas de planificación (*CPU steal* o *ready time* elevado).

---

## 3. Justificación de Decisiones Específicas de Arquitectura Virtual

* **Doble disco en `NAS-TrueNAS` (`truenas_so.vdi` de $16\text{ GB}$ + `truenas_datos.vdi` de $20\text{ GB}$):**
  * TrueNAS SCALE utiliza el sistema de ficheros **ZFS** y exige dedicar por completo la unidad donde se instala el sistema operativo (*boot pool* en el puerto SATA 0). Por diseño, no permite crear *pools* de datos compartidos ni almacenar copias de seguridad en la misma unidad de arranque. Añadir `truenas_datos.vdi` en el puerto SATA 1 permite crear un *storage pool* independiente para los *backups* del resto de servidores y facilita reinstalar el sistema operativo sin pérdida de información.
* **Virtualización anidada en el clúster Proxmox (`--nested-hw-virt on`):**
  * Habilitada en `Proxmox-Node1`, `Proxmox-Node2` y `Proxmox-Node3` (cada uno con $2\text{ vCPUs}$, $2048\text{ MB}$ de RAM y disco `pveX.vdi` de $32\text{ GB}$). Permite trasladar las instrucciones de virtualización por hardware del procesador físico hacia el interior de las VMs, requisito indispensable para que Proxmox VE ejecute máquinas virtuales KVM (como la VM Debian/Ubuntu sin entorno gráfico requerida en la Tasca 5) y contenedores LXC.
* **Firmware UEFI en `Client-Win11` (`--firmware efi`):**
  * Configurado con $4096\text{ MB}$ de RAM, $2\text{ vCPUs}$, disco `win11.vdi` de $32\text{ GB}$ y arranque en modo **UEFI**, cumpliendo los requisitos oficiales de arquitectura moderna de Windows 11.
* **Aprovisionamiento dinámico en discos `.vdi`:**
  * Aunque el espacio virtual declarado suma $268\text{ GB}$, el formato `.vdi` dinámico de VirtualBox asigna espacio en el SSD físico únicamente a medida que los sistemas invitados escriben bloques reales, optimizando el almacenamiento del equipo anfitrión.