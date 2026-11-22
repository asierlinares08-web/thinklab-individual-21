# 01 · Requisitos

## 1. Requisitos del entorno individual (Tasca 0)
Lo que pide el enunciado para la parte individual (resumen con mis palabras):
- Preparar un entorno de pruebas en mi equipo que simule «más o menos» el del grupo (no todo ni exactamente igual).
- Según el hardware, no todas las VMs podrán arrancar a la vez → hay que justificarlo (ver [05-recursos](05-recursos.md)).
- LAN `192.168.21.0/24` (puesto 21). La WAN del servidor de comunicaciones puede ir por DHCP (NAT en VirtualBox).
- Mismos sistemas operativos que el grupo (Tasca 5 individual).

## 2. Requisitos de cada sistema (mínimos oficiales vs asignados en el laboratorio)
> Versiones y URLs de descarga en [03-sistemes](03-sistemes.md). Lo que la fuente oficial no dice → **N/C** + cómo comprobarlo.
> La columna «Asignado» es la propuesta inicial; se ajusta en la Fase 2 con la RAM real del PC.

| Sistema | CPU mín. oficial | RAM mín. oficial | Disco mín. oficial | Firmware / TPM | Asignado en mi lab | ¿Por debajo del mínimo? Justificación |
|---|---|---|---|---|---|---|
| OPNsense 26.7 | 1 GHz, 2 núcleos | **3 GB** (4 GB razonable); el instalador necesita 3 GB | 4 GB (imagen *nano*); 40 GB SSD razonable | UEFI soportado (no obligatorio) | 1 vCPU · 1 GB · 16 GB | **Sí, en CPU y RAM.** Para la instalación hay que dar 3 GB y después probar a bajarlo; en el laboratorio solo pasan 1–2 clientes. Que funcione bien con 1 GB está **N/C**: se comprueba en la Tasca 7 con `top` en la consola de OPNsense y con la RAM libre del panel. |
| MikroTik CHR 7.25.1 | CPU de 64 bits con virtualización | 256 MB (se recomienda 1024 MB). En v7: 256 + 8 × nº CPU × (nº interfaces − 1) | 128 MB | — | 1 vCPU · 256 MB | **Un poco.** Con 1 CPU y 2 interfaces la fórmula da 256 + 8 × 1 × 1 = **264 MB**, así que conviene asignar 288 MB. Se ajusta en la Fase 2. |
| Debian 13 sin escritorio (`FW3-Debian-NFT`) | N/C (la guía solo da CPU para escritorio) | 512 MB (recomendado 1 GB). Con menos de 780 MB, usar el instalador de texto | 4 GB | BIOS o UEFI | 1 vCPU · 512 MB · 8 GB | No: está en el mínimo. Hay que elegir el instalador de **texto** («Install», no «Graphical install»). CPU N/C: se comprueba instalándolo y midiendo con `top`. |
| Proxmox VE 9.2 | 64 bits con Intel VT/AMD-V (en la VM: VT-x anidada) | 1 GB (solo pruebas); 2 GB + RAM de las VMs para producción | 1 disco (la web no da tamaño → N/C) | VT-x anidada | 2 vCPU · 2–3 GB · 32 GB | No, para pruebas. Ojo: la VM y el contenedor de la migración salen de esos 2–3 GB. Tamaño de disco N/C: se comprueba con el espacio que pide el instalador. |
| TrueNAS CE 25.10 | 2 núcleos x86_64 | **8 GB** | Arranque: 16 GB (mejor SSD). Datos: 2 discos iguales para un *pool* | — | 2 vCPU · 4 GB · 16 GB + 20 GB | **Sí, en RAM** (la mitad) y con **un solo disco de datos** (sin redundancia). Es un laboratorio con pocos datos; ZFS usa la RAM sobre todo como caché. El rendimiento con 4 GB se mide en la Tasca 7 (N/C hasta entonces). |
| Windows Server 2025 (escritorio) | 1,4 GHz 64 bits, NX/DEP, SLAT (EPT/NPT), SSE4.2, POPCNT | 2 GB (4 GB recomendado con escritorio); en VM, ≥ 1280 MB para que funcione el instalador | 32 GB | UEFI + Secure Boot y TPM 2.0 solo para algunas funciones (BitLocker) | 2 vCPU · 2–4 GB · 50 GB | No. **Atención:** Microsoft no admite discos IDE/PATA para arranque → la VM tiene que llevar controlador **SATA** (o NVMe). |
| Debian 13 sin escritorio (`Server-Monitorizacion`) | N/C | 512 MB (recomendado 1 GB) | 4 GB | BIOS o UEFI | 1 vCPU · 1 GB · 10 GB + 7 × 1 GB | No: tiene la RAM recomendada. |
| Windows 11 25H2 | 1 GHz, 2 núcleos, 64 bits (CPU compatible) | 4 GB | 64 GB | UEFI con Secure Boot + **TPM 2.0**; gráficos DirectX 12 / WDDM 2.0 | 2 vCPU · 4 GB · 64 GB | No, en CPU, RAM y disco. Lo de DirectX 12 en VirtualBox está **N/C**: se comprueba si el instalador lo deja pasar y se mira `dxdiag` después de instalar. |
| Debian 13 + escritorio (`Client-Linux`) | Pentium 4 a 1 GHz (mínimo recomendado para escritorio) | 1 GB (recomendado 2 GB) | 10 GB | BIOS o UEFI | 2 vCPU · 3 GB · 25 GB | No: tiene 1 GB más de lo recomendado (es el puesto de gestión web, con el navegador abierto). |

**Fuentes oficiales** (detalle en [03-sistemes](03-sistemes.md)):
- OPNsense: https://docs.opnsense.org/manual/hardware.html
- MikroTik CHR: https://help.mikrotik.com/docs/spaces/ROS/pages/18350234/Cloud+Hosted+Router+CHR
- Debian 13: https://www.debian.org/releases/trixie/amd64/ch03s04.en.html
- Proxmox VE: https://www.proxmox.com/en/products/proxmox-virtual-environment/requirements
- TrueNAS 25.10: https://www.truenas.com/docs/scale/25.10/gettingstarted/scalehardwareguide/
- Windows Server: https://learn.microsoft.com/en-us/windows-server/get-started/hardware-requirements
- Windows 11: https://www.microsoft.com/en-us/windows/windows-11-specifications
