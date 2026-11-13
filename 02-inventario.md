# Inventario de Hardware, Benchmarks y Análisis de Cuellos de Botella

- **Módulo / RA:** FDM-RA1 (Tasca 2 — Ítems `a19`, `a20`, `a21` y ampliación `a27`, `a28`, `a29`)
- **Objetivo:** Comparar el hardware real del **equipo de clase** frente al **equipo de casa**, registrar pruebas empíricas de rendimiento (CPU, RAM, disco y red) y confirmar o descartar los cuellos de botella previstos.

---

## 1. Inventario Comparativo de Hardware (Clase vs. Casa) — `a19`

| Subsistema | Equipo de Clase (Portátil / Estación Aula) | Equipo de Casa (Sobremesa Linux) | Diferencia Técnica Relevante |
| :--- | :--- | :--- | :--- |
| **Procesador (CPU)** | **Intel Core Ultra 5 125H** (`x86_64`)<br>• **14 núcleos físicos** / **18 hilos lógicos**<br>• Frecuencia máx.: `4,50 GHz` \| Caché L3: `18 MiB`<br>• Virtualización: **Intel VT-x** activa | **AMD Ryzen 5 5600X** (`x86_64`)<br>• **6 núcleos físicos** / **12 hilos lógicos**<br>• Frecuencia: `2,20 GHz` mín. – `4,65 GHz` máx.<br>• Virtualización: **AMD-V** activa | El equipo de clase ofrece un **+50 % más de hilos** simultáneos (18 vs. 12) para paralelizar VMs; el de casa tiene mayor reloj sostenido por núcleo. |
| **Memoria RAM** | **32 GB DDR5 Kingston** (`2 × 16 GB` SODIMM)<br>• Velocidad: `5600 MT/s` (máx. placa: `64 GB`)<br>• Reconocida por Debian: `30 GiB`<br>• Swap: `15 GiB` disco + `7,6 GiB` `zram` | **32 GB DDR4** (`31 GiB` reconocidos por Linux)<br>• Swap configurada: `15 GiB` disco + `7,8 GiB` `zram0` | Capacidad idéntica (`32 GB`), pero el equipo de clase cuenta con bus **DDR5 a 5600 MT/s** de mayor ancho de banda. |
| **Almacenamiento Principal (SO Host)** | **SSK Portable SSD 500GB** (`465,8 GiB`)<br>• Tecnología: SSD externo (`ROTA=0`)<br>• Interfaz: **USB** (particiones `/boot/efi`, `/`, `/home`) | **Kioxia/Toshiba EXCERIA PLUS** (`931,5 GB`)<br>• Tecnología: SSD externo (`ROTA=0`)<br>• Interfaz: **USB** (partición `/` en `/dev/sda2` de `58 GB`, **`18 GB` libres** — 69 % uso) | En **casa**, la partición raíz `/` donde reside `/home` tiene un límite crítico de **18 GB libres**. |
| **Almacenamiento Secundario** | **Samsung MZVMA1T0HCLD-00BTW** (`953,9 GiB`)<br>• Tecnología: SSD interno (`ROTA=0`)<br>• Interfaz: **NVMe** (PCIe) | **1) GIGABYTE GP-GM30512G-G** (`476,9 GB`, SSD interno **NVMe**, `ROTA=0`)<br>**2) PS4 Game Drive** (`1,8 TB`, HDD externo **USB**, `ROTA=1`) | Ambos equipos disponen de un **SSD NVMe interno** de alto rendimiento infrautilizado para las VMs, y en casa hay un HDD mecánico lento (`ROTA=1`). |
| **Interfaz de Red Activa** | **Ethernet Gigabit cableada** integrada<br>• Conectada a la red del aula (`172.16.222.0/24`) | **Realtek RTL8111/8168 Gigabit Ethernet** (`eno1` — **`DOWN`**)<br>• **Realtek RTL8812AE Wi-Fi 5 802.11ac** (`wlp14s0` — **`UP`**, `192.168.1.67/24`) | En clase se trabaja por cable Gigabit estable; en casa el puerto Ethernet está desconectado y se opera por Wi-Fi. |

---

## 2. Registro de Pruebas de Diagnóstico y Rendimiento (Línea Base) — `a27`, `a28`

### 2.1 Metodología y Condiciones de Ejecución
- **Condiciones:** Pruebas ejecutadas en estado de reposo (*baseline*), cerrando navegadores y máquinas virtuales activas para aislar el rendimiento real del hardware anfitrión.
- **Herramientas empleadas:**
  - **Clase:** `lscpu`, `free -h`, `top`, `lsblk` y **`fio 3.36`** (pruebas de lectura/escritura secuencial y aleatoria en bloques de `4 KiB` durante `30 segundos`).
  - **Casa:** `lscpu`, `free -h`, `lsblk`, `df -h`, `lspci`, `ip -br a`, **`dd`** (escritura directa de `1 GiB` en `/dev/shm` para RAM y con bandera `oflag=direct` sobre `/dev/sda2` para evitar caché del kernel en disco) y **`ping`** (`5` paquetes ICMP hacia `1.1.1.1`).
- **Evidencias guardadas:** Salidas completas registradas en `evidencies/benchmark-clase.txt` y `evidencies/benchmark-casa.txt`.

### 2.2 Resultados Numéricos Obtenidos

| Métrica Evaluada | Equipo de Clase | Equipo de Casa | Interpretación Técnica |
| :--- | :--- | :--- | :--- |
| **RAM usada en reposo** | `5,7 GiB` (`24 GiB` disponibles) | `4,8 GiB` (`26 GiB` disponibles) | Excelente margen libre en ambos equipos (`> 75 %` disponible). |
| **Uso de Swap en reposo** | `0 B` (de `15 GiB` + `7,6 GiB` zram) | `0 B` (de `15 GiB` + `7,8 GiB` zram0) | Ausencia total de presión de memoria en línea base. |
| **Velocidad copia en RAM** | DDR5 5600 MT/s (bus hardware) | **`3,1 GB/s`** (`0,3418 s` para `1 GiB` en `/dev/shm` mono-hilo) | Ancho de banda de memoria muy superior al de cualquier disco. |
| **Lectura secuencial SSD** | **`999 MiB/s`** (latencia `16,01 ms` con `fio`) | N/A (medida escritura directa) | El SSD externo SSK de clase aprovecha casi al límite el bus USB 3.2 Gen 2 (10 Gbps). |
| **Escritura secuencial SSD** | **`847 MiB/s`** (latencia `18,88 ms` con `fio`) | **`385 MB/s`** (`2,7905 s` para `1 GiB` con `oflag=direct`) | El SSD USB de clase duplica en escritura secuencial al SSD USB de casa (`847` vs `385 MB/s`). |
| **Operaciones aleatorias 4K** | **`35.862 IOPS`** lectura / **`49.634 IOPS`** escritura (`0,32–0,44 ms`) | Limitado por puente USB-SATA/NVMe | Las bajas latencias en 4K permiten arrancar varias VMs sin bloqueos prolongados. |
| **Uso de CPU en reposo** | `0,6 %` (`99,4 %` inactiva) | `< 2 %` (frecuencia escalada a `2,20 GHz`) | Procesadores prácticamente ociosos antes de arrancar VirtualBox. |
| **Latencia de red (`1.1.1.1`)** | Cableado Gigabit aula (`< 2 ms` estable) | Min: `1,19 ms` \| Media: **`4,59 ms`** \| Máx: **`16,19 ms`** \| Jitter (`mdev`): **`5,85 ms`** | En casa, la conexión Wi-Fi (`wlp14s0`) introduce picos de hasta `16 ms` y variación de latencia. |

---

## 3. Confirmación o Descarte de Cuellos de Botella — `a20`, `a29`

| Subsistema | Hipótesis Inicial (Predicción) | Resultado Empírico (Clase vs. Casa) | Veredicto |
| :--- | :--- | :--- | :--- |
| **Memoria RAM** | Podría saturarse al levantar varias VMs simultáneas y forzar *swapping*. | `24 GiB` disponibles en clase y `26 GiB` en casa (`0 B` swap). Nuestro escenario activo consume `10–16 GB`. | **DESCARTADO** (en línea base y operación modular de 4–5 VMs). |
| **Almacenamiento (Capacidad y Bus USB)** | La ejecución sobre SSD externos USB podría ralentizar las VMs o quedarse sin espacio. | **Clase:** `847 MiB/s` escritura (alto rendimiento, pero susceptible de contención USB bajo carga múltiple).<br>**Casa:** `385 MB/s` escritura y **solo `18 GB` libres en `/`** (`/dev/sda2`). | **CONFIRMADO EN CASA** (límite crítico de capacidad en `/` y menor ancho de banda USB). **RIESGO MODERADO EN CLASE** bajo I/O concurrente. |
| **Procesador (CPU)** | Podría haber contención si se asignan más vCPUs que núcleos físicos. | **Clase:** 18 hilos (`0,6 %` uso base).<br>**Casa:** 12 hilos (`AMD Ryzen 5 5600X`). | **DESCARTADO** (siempre que no superemos 8–10 vCPUs activas simultáneas). |
| **Red Física** | Posible limitación de ancho de banda o estabilidad en el enlace externo. | **Clase:** Cable Gigabit activo.<br>**Casa:** Puerto Gigabit `eno1` caído (`DOWN`); operando por Wi-Fi con jitter de `5,85 ms`. | **CONFIRMADO EN CASA** (inestabilidad inalámbrica frente a cable). |

---

## 4. Soluciones Técnicas Propuestas Ajustadas al Hardware — `a21`

1. **Reubicación del almacenamiento de VirtualBox en Casa (`nvme0n1`):**
   - **Problema:** La partición raíz `/` (`/dev/sda2`) solo dispone de `18 GB` libres y opera a `385 MB/s` por USB.
   - **Solución:** Configurar en VirtualBox (`Archivo > Preferencias > General > Carpeta predeterminada de máquinas`) una ruta alojada en el **SSD interno NVMe (`nvme0n1` — GIGABYTE 476,9 GB)** o en una partición dedicada amplia de `sda` fuera de `/`. De este modo se eliminan tanto el límite de espacio como el cuello de botella del bus USB, multiplicando las IOPS.
2. **Aislamiento del disco mecánico USB (`sdb` — PS4 Game Drive 1,8 TB):**
   - **Problema:** Al tratarse de un disco rotacional (`ROTA=1`) conectado por USB, su alta latencia mecánica bloquearía cualquier VM ejecutada desde él.
   - **Solución:** Utilizar `sdb` exclusivamente como repositorio de almacenamiento frío para exportar copias de seguridad (`.ova`) e imágenes ISO descargadas.
3. **Ubicación estratégica de VMs críticas en Clase (`NVMe Samsung 953,9 GiB`):**
   - **Solución:** Aunque el SSD externo SSK ofrece `847 MiB/s`, en pruebas intensivas de clúster (Proxmox VE + migraciones) o carga simultánea se recomienda alojar los discos `.vdi` más pesados en el **SSD interno NVMe Samsung** para evitar saturar el controlador USB.
4. **Activación del enlace Ethernet Gigabit (`eno1`) en Casa:**
   - **Solución:** Conectar un cable de red RJ-45 Cat5e/Cat6 al puerto `eno1` del PC de casa para pasar de Wi-Fi (`wlp14s0`, jitter `5,85 ms`) a conexión cableada de `1 Gbps` full-duplex (`< 1 ms` sin pérdida ni fluctuación).
5. **Política de encendido escalonado y exclusión de cortafuegos:**
   - **Solución:** Mantener encendido **únicamente 1 cortafuegos a la vez** (`FW1`, `FW2` o `FW3`) y arrancar las máquinas virtuales de forma escalonada (esperando 15–20 segundos entre arranques) para evitar picos simultáneos de lectura en disco y CPU.
