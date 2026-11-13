# Tasca 4 — Diseño Lógico de Red y Direccionamiento IP (Puesto 21)

* **Módulo / RA asociado:** ISO-RA1 (Ítems `a128` y `a148` — Esquema de red individual, montaje virtual en VirtualBox y configuración de interfaces)

* **Puesto escolar:** Puesto 21

* **Subred interna asignada:** `192.168.21.0/24` (Máscara `255.255.255.0` — $2^8 - 2 = 254$ direcciones IP útiles para hosts)

* **Nombre de la Red Interna en VirtualBox:** `LAN_21`

## 1. Topología Lógica de la Red Individual

```
                       [ INTERNET / RED AULA ]
                                  │
                     (Adaptador 1: NAT - DHCP)
                                  ▼
         ┌─────────────────────────────────────────────────┐
         │    SERVIDOR DE COMUNICACIONES ACTIVO (1 a la vez)│
         │  FW1-MikroTik  |  FW2-OPNsense  |  FW3-Debian   │
         │            IP LAN: 192.168.21.1 /24             │
         └────────────────────────┬────────────────────────┘
                     (Adaptador 2: Red Interna LAN_21)
                                  │
  ════════════════════════════════╧═════════════════════════════════
                     SUBRED INTERNA: 192.168.21.0/24
  ════════════════════════════════╤═════════════════════════════════
     │            │               │               │             │
     ▼            ▼               ▼               ▼             ▼
┌─────────┐ ┌───────────┐ ┌───────────────┐ ┌───────────┐ ┌──────────┐
│Proxmox 1│ │ NAS       │ │ WinServer     │ │ Server    │ │ Clientes │
│ .10/24  │ │ TrueNAS   │ │ 2025          │ │ Monitor.  │ │ Win11 .50│
│Proxmox 2│ │ .20/24    │ │ .30/24        │ │ .40/24    │ │ Linux .60│
│ .11/24  │ └───────────┘ └───────────────┘ └───────────┘ └──────────┘
│Proxmox 3│
│ .12/24  │
└─────────┘

```

## 2. Tabla Oficial de Direccionamiento IP (Puesto 21)

Todas las direcciones estáticas se han organizado por bloques funcionales dentro de la red `192.168.21.0/24` para facilitar la administración, el diagnóstico y las reglas de filtrado:

| Equipo (VM) | Interfaz | Modo Red VirtualBox | Dirección IP / Máscara | Puerta de Enlace (Gateway) | DNS Primario | 
| ----- | ----- | ----- | ----- | ----- | ----- | 
| **FW1 / FW2 / FW3** *(Solo 1 activo)* | `eth0` / `wan` | **NAT** | DHCP (`10.0.2.15/24`) | `10.0.2.2` (VirtualBox) | `1.1.1.1` / `8.8.8.8` | 
| **FW1 / FW2 / FW3** *(Solo 1 activo)* | `eth1` / `lan` | **Red Interna (`LAN_21`)** | `192.168.21.1/24` | *No lleva (es el router)* | *No lleva* | 
| **Proxmox-Node1** | `vmbr0` | **Red Interna (`LAN_21`)** | `192.168.21.10/24` | `192.168.21.1` | `192.168.21.1` | 
| **Proxmox-Node2** | `vmbr0` | **Red Interna (`LAN_21`)** | `192.168.21.11/24` | `192.168.21.1` | `192.168.21.1` | 
| **Proxmox-Node3** | `vmbr0` | **Red Interna (`LAN_21`)** | `192.168.21.12/24` | `192.168.21.1` | `192.168.21.1` | 
| **NAS-TrueNAS** | `enp0s3` | **Red Interna (`LAN_21`)** | `192.168.21.20/24` | `192.168.21.1` | `192.168.21.1` | 
| **WinServer-2025** | `Ethernet` | **Red Interna (`LAN_21`)** | `192.168.21.30/24` | `192.168.21.1` | `127.0.0.1` / `192.168.21.1` | 
| **Server-Monitorizacion** | `enp0s3` | **Red Interna (`LAN_21`)** | `192.168.21.40/24` | `192.168.21.1` | `192.168.21.1` | 
| **Client-Win11** | `Ethernet` | **Red Interna (`LAN_21`)** | `192.168.21.50/24` | `192.168.21.1` | `192.168.21.1` *(o `.30`)* | 
| **Client-Linux** | `enp0s3` | **Red Interna (`LAN_21`)** | `192.168.21.60/24` | `192.168.21.1` | `192.168.21.1` *(o `.30`)* | 

## 3. Reglas de Diseño y Seguridad de la Red

### A. Aislamiento respecto a la red del aula (`172.16.222.0/24`)

* Todos los servidores internos y puestos cliente disponen únicamente de **un adaptador de red** conectado en modo **Red Interna (`LAN_21`)**. Esto crea un segmento de capa 2 completamente aislado dentro de VirtualBox, impidiendo que ningún servicio de pruebas (como DHCP, DNS o Active Directory) se filtre hacia la red real del aula (`172.16.222.0/24`).

* La salida hacia Internet para descargar paquetes y actualizaciones se canaliza únicamente a través del cortafuegos activo, cuyo **Adaptador 1 (`WAN`)** está en modo **NAT** de VirtualBox (recibiendo por DHCP la IP `10.0.2.15/24` con salida por `10.0.2.2`) y realiza traducción de direcciones (*Source NAT / Masquerade*) para los equipos de `192.168.21.0/24`.

### B. Regla de Oro: Solo UN cortafuegos encendido a la vez

* En la Tasca 5 debemos instalar, configurar y evaluar tres alternativas de servidor de comunicaciones: **FW1-MikroTik**, **FW2-OPNsense** y **FW3-Debian-NFT**.

* Los tres comparten exactamente la misma configuración en su interfaz interna (`192.168.21.1/24`) para que el resto de servidores y clientes puedan cambiar de cortafuegos sin necesidad de reconfigurar su puerta de enlace predeterminada.

* **Consecuencia de encender dos a la vez:** Si se arrancaran simultáneamente dos cortafuegos conectados a `LAN_21`, se produciría un **conflicto de direcciones IP duplicadas** (`192.168.21.1`). Las tablas ARP de los equipos internos recibirían respuestas contradictorias de dos direcciones MAC distintas reclamando la misma IP, provocando pérdida intermitente de paquetes y cortes totales de salida a Internet.

### C. Criterio de organización del direccionamiento

* **`.1`:** Puerta de enlace predeterminada (cortafuegos activo).

* **`.10` – `.12`:** Nodos del clúster de virtualización Proxmox VE (ips consecutivas para facilitar la comunicación interna del clúster y las migraciones).

* **`.20`:** Almacenamiento centralizado y repositorio de copias de seguridad (`NAS-TrueNAS`).

* **`.30`:** Controlador de dominio e identidades (`WinServer-2025`), preparado también para ofrecer resolución DNS interna si se requiere.

* **`.40`:** Servidor dedicado a supervisión, métricas y alertas (`Server-Monitorizacion`).

* **`.50` – `.60`:** Estaciones de trabajo cliente (`Client-Win11` y `Client-Linux`).
