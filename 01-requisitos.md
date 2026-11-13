# Requisitos de Hardware de la Infraestructura Virtualizada (Puesto 21)

- **Módulo / RA:** FDM-RA1 (Tasca 2 — Equipos y periféricos)
- **Alcance:** Dimensionamiento de requisitos mínimos y recomendados del equipo anfitrión para sostener el laboratorio individual del Puesto 21 (`192.168.21.0/24`).

---

## 1. Demanda de Recursos de la Infraestructura (11 VMs)

El entorno individual de pruebas en Oracle VM VirtualBox replica la infraestructura completa de la empresa mediante **11 máquinas virtuales**:

| Perfil de Máquina Virtual | Cantidad | vCPU por VM | RAM por VM | Disco Virtual | Escenario de Ejecución |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **Cortafuegos / Router** (`FW1`, `FW2`, `FW3`) | 3 | 1 – 2 | 512 MB – 2 GB | 16 GB (o VDI CHR) | **Excluyentes** (solo 1 activo a la vez) |
| **Almacenamiento NAS** (`NAS-TrueNAS`) | 1 | 2 | 4 GB | 16 GB SO + 20 GB Datos | Activo en pruebas de red y copias |
| **Clúster Virtualización** (`Proxmox-Node1..3`) | 3 | 2 | 2 GB | 32 GB (Nested Virt ON) | Activos en pruebas de clúster/migración |
| **Controlador de Dominio** (`WinServer-2025`) | 1 | 2 | 4 GB | 40 GB | Activo en pruebas de identidad/dominio |
| **Servidor Monitorización** (`Server-Monitorizacion`) | 1 | 1 | 1 GB | 16 GB | Activo en análisis de rendimiento |
| **Cliente Departamental Win** (`Client-Win11`) | 1 | 2 | 4 GB | 32 GB (UEFI) | Activo en pruebas de conectividad/usuario |
| **Cliente Departamental Linux** (`Client-Linux`) | 1 | 1 | 2 GB | 16 GB | Activo en pruebas de conectividad/usuario |
| **TOTAL TEÓRICO (Todas encendidas)** | **11** | **18 vCPUs** | **24,5 GB** | **~268 GB máx. dinámico** | **No aplicable** (ejecución modular) |
| **TOTAL OPERATIVO (Escenario habitual 4–5 VMs)** | **4–5** | **6–10 vCPUs** | **10–16 GB** | **~60–90 GB reales en disco** | **Carga real de trabajo** |

---

## 2. Requisitos del Equipo Anfitrión (Mínimos vs. Recomendados)

Para garantizar que el hipervisor de Tipo 2 (VirtualBox) ejecute las máquinas virtuales sin sufrir intercambio de memoria a disco (*swapping*) ni bloqueos de entrada/salida (I/O), se establecen los siguientes umbrales:

| Componente | Requisito Mínimo Viable | Requisito Recomendado (Óptimo) | Justificación Técnica |
| :--- | :--- | :--- | :--- |
| **Procesador (CPU)** | 6 núcleos / 12 hilos con extensiones de virtualización por hardware activadas (**Intel VT-x** / **AMD-V**) y soporte **SLAT** (EPT/RVI). | 8–14 núcleos / 12–18 hilos con frecuencia turbo $\ge 4,0\text{ GHz}$. | Necesario para evitar contención de hilos al ejecutar varios sistemas invitados y soportar **virtualización anidada** en los 3 nodos Proxmox VE. |
| **Memoria RAM** | **16 GB** DDR4/DDR5 (permite arrancar 2–3 VMs ligeras simultáneamente). | **32 GB** DDR4/DDR5 en doble canal (*Dual Channel*). | Con 32 GB se cubren los 10–16 GB de un escenario completo (Firewall + TrueNAS + Servidor + Cliente) dejando más de 15 GB libres para el sistema anfitrión. |
| **Almacenamiento** | **256 GB** libres en unidad **SSD** (SATA o USB 3.2 Gen 2 $\ge 500\text{ MB/s}$). | **512 GB – 1 TB** en **SSD NVMe PCIe** interno ($\ge 1500\text{ MB/s}$ y altas IOPS). | Las operaciones aleatorias 4K de varias VMs arrancando a la vez saturan cualquier disco mecánico (HDD). El SSD NVMe evita colas de latencia I/O. |
| **Interfaz de Red** | Adaptador Ethernet **Gigabit (1000BASE-T)** o Wi-Fi 5 (802.11ac). | Adaptador **Ethernet Gigabit cableado** full-duplex. | Aunque la red `LAN_21` es interna en VirtualBox, una conexión cableada elimina pérdida de paquetes y *jitter* al descargar ISOs, paquetes y respaldar en Git. |
| **Firmware / SO Host** | BIOS/UEFI con VT-x/AMD-V habilitado; SO anfitrión de 64 bits (GNU/Linux o Windows 10/11). | GNU/Linux 64 bits con soporte KVM/VirtualBox y partición amplia para VMs. | Un anfitrión Linux ligero consume menos RAM base (~4,8–5,7 GiB) que Windows, maximizando la memoria disponible para las VMs. |

---

## 3. Verificación de Cumplimiento en Nuestros Dos Entornos

Tanto el **equipo de clase** (Intel Core Ultra 5 125H, 32 GB DDR5, SSD NVMe + SSD USB) como el **equipo de casa** (AMD Ryzen 5 5600X, 32 GB RAM, SSD NVMe + SSD USB) cumplen o superan los **requisitos recomendados** en CPU y memoria RAM. No obstante, las auditorías físicas revelan diferencias críticas en el subsistema de almacenamiento y red que se detallan en `docs/02-inventari.md`.
