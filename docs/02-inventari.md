# 02 · Inventario y comparativa de equipos (Tasca 2)

**Predicción de Asier (P5, antes de ver los datos de casa):** «El disco irá igual en los dos PCs porque es el mismo».
**Resultado:** acertada. Negocia 5000M en los dos y mide casi lo mismo (lectura 386 / 332 MB/s, escritura 409 / 382 MB/s).

**Evidencias:**
- PC de clase (17/11/2026, 11:11): [`inventario-clase`](../evidencias/tasca2/2026-11-17_inventario-clase.txt) y [`tests-clase`](../evidencias/tasca2/2026-11-17_tests-clase.txt).
- PC de casa (17/11/2026, 17:43): [`inventario-casa`](../evidencias/tasca2/2026-11-17_inventario-casa.txt) y [`tests-casa`](../evidencias/tasca2/2026-11-17_tests-casa.txt).

Demuestran: el hardware de cada PC y lo que mide cada uno en memoria, disco y red, con las **mismas herramientas y en las mismas condiciones** (0 VMs encendidas, el mismo disco USB y los mismos scripts).

Los números de serie y las MAC salen como `[OCULTO]` y las IPv6 de enlace local como `[IPv6 OCULTA]`, porque el repositorio es público.

**Herramientas:**
- Inventario: dmidecode, lscpu, lsblk, `lsusb -t`, smartctl, ip, ethtool, sensors, systemd-analyze, inxi.
- Tests: memtester, smartctl, hdparm, dd, fio, ping, curl.

**Ojo:** el **disco es el mismo aparato en casa y en clase**, un SSD externo KIOXIA EXCERIA PLUS de 1 TB con Linux Mint y las VMs. Lo que puede cambiar es **cómo se conecta** (tipo de puerto USB), así que su velocidad se compara entre los dos PCs.

## 1. Comparativa
| Componente | PC de clase | PC de casa | ¿Qué implica para las VMs? |
|---|---|---|---|
| Placa / modelo | Portátil ASUS ExpertBook B3605CCA | **Sobremesa**, placa Gigabyte B450 GAMING X | El sobremesa refrigera mejor cuando se carga mucho rato |
| Firmware y arranque | UEFI · Secure Boot **desactivado** · BIOS B3605CCA.303 (06/11/2025) | UEFI · Secure Boot **activado** · BIOS F62d (13/10/2021) | En casa los módulos de VirtualBox tienen que estar firmados. Comprobado: `vboxdrv` carga bien (`lsmod`) |
| CPU | Intel Core Ultra 5 125H: **14 núcleos / 18 hilos** (4 rendimiento con HT + 10 eficientes), hasta 4,5 GHz, L3 18 MiB | AMD Ryzen 5 5600X: **6 núcleos / 12 hilos**, todos iguales, hasta 4,65 GHz, L3 32 MiB | Casa tiene **menos hilos** (12 frente a 18), pero todos son núcleos «grandes». Con todo el laboratorio encendido (~16 vCPU) en casa habría más vCPU que hilos |
| Virtualización | **VT-x** activado (flag `vmx`) | **AMD-V** activado (flag `svm`) | Las dos sirven para VMs de 64 bits y Proxmox anidado. `kvm_amd` está cargado en casa: que VirtualBox arranque bien con él es **N/C** (se ve al encender la primera VM en casa) |
| RAM | **32 GB DDR5 5600** (2 × 16 GB). **Las 2 ranuras ocupadas**, máximo 64 GB. Usables 30,6 GB; con el escritorio abierto, ~20 GB disponibles | **32 GB DDR4 a 2400 MT/s** (2 × 16 GB). **2 de 4 ranuras libres**, máximo 128 GB. Con el escritorio abierto, **~24 GB disponibles** | Misma cantidad. Casa deja ~4 GB más libres y **se puede ampliar sin tirar nada**. La RAM de casa es más lenta (DDR4 2400 frente a DDR5 5600) |
| Disco del sistema y de las VMs | SSD externo **USB** KIOXIA EXCERIA PLUS 1 TB (`sda`, `/home` 872 GB). Negocia **5000M (USB 3.2 Gen1)** en un puerto de **20 Gbit/s**. SMART: N/C | **El mismo disco.** Negocia **5000M (USB 3.2 Gen1)** en un controlador de **10 Gbit/s** (`lsusb -t`, bus 004). `/home` 16,3 % usado. SMART: N/C | **Todas las VMs** leen y escriben en este disco. En los dos PCs se queda en 5 Gbit/s aunque el puerto da más |
| Otros discos | NVMe Samsung 1 TB, SMART **PASSED**. Windows y Linux del aula; **no se usa** | NVMe Gigabyte 512 GB (NVMe 1.3), SMART **PASSED**, con Windows (NTFS). Disco duro USB Seagate 2 TB (mecánico, NTFS) **en el mismo bus USB** que el KIOXIA | En casa el disco Seagate comparte el controlador de 10 Gbit/s con el KIOXIA: si se usan los dos a la vez se reparten el ancho de banda |
| Red | Cable Intel (e1000e) a **1 Gbit/s**, full duplex; Wi-Fi sin usar | **Wi-Fi** Realtek RTL8812AE (802.11ac). La tarjeta de cable Realtek (1 Gbit/s) está **desconectada** | Solo afecta a las descargas; la LAN de las VMs es interna |
| Gráfica | Intel Arc integrada, 2 pantallas | NVIDIA GeForce RTX 3060, 2 pantallas 1920×1080 | Ninguna influye: VirtualBox no usa la GPU para cálculo |
| Periféricos | Webcam USB 2.0, lector de tarjetas, ratón Dell, auriculares USB-C, Bluetooth | Teclado, ratón y auriculares Logitech; controlador RGB | Ninguno influye en las VMs |
| Alimentación | Cargador conectado + batería al 100 % (salud **93,9 %**) | Fuente de sobremesa: la potencia **no se lee por software** (N/C, mirar la etiqueta de la fuente) | En casa no hay batería que baje el rendimiento |
| Tiempo de arranque del SO | **44,2 s** (firmware 18,7 s + cargador 5,8 s + kernel 4,2 s + usuario 15,4 s) | **37,7 s** (firmware 11,9 s + cargador 7,1 s + kernel 4,9 s + usuario 13,7 s) | En los dos lo que más tarda es `NetworkManager-wait-online` (7,9 s / 5,6 s). No influye en las VMs |
| Temperatura CPU | 59–65 °C casi en reposo (límite 110 °C) | 54 °C al empezar los tests y **36 °C** al acabar (Tctl) | El sobremesa va mucho más fresco. Con carga se mide en la Tasca 7 |

## 2. Cuellos de botella: ¿se confirman o se descartan?
Se compara **lo mismo en los dos PCs**. Si un dato es igual en los dos, el problema no es del PC sino de lo que comparten (el disco USB y su cable).

| # | Cuello de botella previsto | Clase (dato) | Casa (dato) | ¿Confirmado o descartado? | Solución con el hardware que hay | Si se pudiera comprar |
|---|---|---|---|---|---|---|
| 1 | **Disco USB** (el principal) | 5000M · lectura **386 MB/s** · escritura **409 MB/s** · 38,7k IOPS 4K | 5000M · lectura **332 MB/s** · escritura **382 MB/s** · 42,8k IOPS 4K (latencia 0,36 ms) | **Confirmado en los dos PCs.** En ambos el techo es el enlace USB a 5 Gbit/s (~500 MB/s útiles como mucho) y las cifras son casi iguales | No instalar varias VMs a la vez; discos dinámicos; VMs sin escritorio donde se pueda; en casa **no usar el disco Seagate** mientras haya VMs (comparte el bus). Probar **otro cable USB-C 3.2 Gen2** y mirar con `lsusb -t` si pasa a 10000M | Caja/disco USB 3.2 Gen2 o NVMe interno propio |
| 1b | ¿La culpa es **del puerto USB del PC**? | Puerto de 20 Gbit/s → 5000M | Controlador de 10 Gbit/s → 5000M | **Descartado.** Dos PCs distintos con puertos rápidos dan la misma velocidad. Lo que comparten es el **disco + el cable**: uno de los dos limita a 5 Gbit/s (cuál de los dos: **N/C**; prueba: otro cable Gen2 o la ficha de KIOXIA) | (la de arriba) | — |
| 2 | **RAM** | 32 GB, ~20 GB disponibles, sin ranuras libres | 32 GB, ~24 GB disponibles, **2 ranuras libres** | **Confirmado como límite de cuántas VMs caben** (igual en los dos: 32 GB). El laboratorio entero (~25 GB) no cabe a la vez en ninguno | Trabajar por **escenarios** ([05-recursos](05-recursos.md)); cerrar navegador y parar Docker con VMs encendidas. En casa, mirar en la BIOS si los módulos admiten más de 2400 MT/s (perfil XMP/DOCP): **N/C** | Casa: añadir 2 × 16 GB en las ranuras libres (64 GB). Clase: cambiar a 2 × 32 GB |
| 3 | **CPU** | 18 hilos (10 núcleos eficientes) | **12 hilos** (6 núcleos iguales) | **No confirmado aún (N/C).** Más probable en casa por tener menos hilos. Se confirma o descarta en la Tasca 7 con `top`/`vmstat` y varias VMs encendidas | Máximo 2 vCPU por VM; no encender los 3 Proxmox mientras se instala Windows | — |
| 4 | **Red a Internet** (para descargas) | Descarga **3,7 MB/s** (30 Mbit/s); ping hacia fuera **bloqueado** | Descarga **11,9 MB/s** (95 Mbit/s), unas **3 veces más**; ping a 1.1.1.1 en 3,9 ms | **Confirmado en clase, descartado en casa** | Hacer en casa las descargas grandes (ISOs, actualizaciones, `git clone` dentro de las VMs) | — |
| 5 | Red local de casa (Wi-Fi) | Cable: 0,59 ms, sin pérdidas | Wi-Fi: 0 % pérdida, media **13,8 ms** con picos de 51 ms | **Descartado** para las VMs (su red es interna y no pasa por aquí). Solo hace más irregulares las descargas | Conectar el cable de red (la tarjeta de 1 Gbit/s ya está) si alguna descarga va mal | — |

## 3. Tests de diagnóstico (Apte+): herramienta, condiciones y resultado
| Test | Equipo | Herramienta | Condiciones | Resultado | Interpretación | Cuello de botella confirmado / descartado |
|---|---|---|---|---|---|---|
| Memoria | Clase | memtester 4.6.0 (512 MB, 1 pasada) | 17/11 11:12, 0 VMs, carga 0,6, 20 GB libres | **18/18 pruebas «ok»** | No hay fallos en la RAM probada. Solo prueba la RAM libre; la prueba completa sería memtest86+ desde GRUB | RAM **sin fallos** |
| Memoria | Casa | memtester 4.6.0 (512 MB, 1 pasada) | 17/11 17:44, 0 VMs, carga 3,0 (recién encendido, 5 min), 25 GB libres | **18/18 pruebas «ok»** | Igual que en clase | RAM **sin fallos**. Que sea poca se mide en la Tasca 7 |
| Disco · salud | Clase y casa | smartctl (`-d sat` y `-d auto`) | Disco USB | **N/C** en los dos: el puente USB no deja pasar SMART. Los NVMe internos: **PASSED** | No se puede leer la salud del SSD por USB | — |
| Disco · secuencial | Clase | hdparm -t · dd 1 GB `oflag=direct` | Mismas condiciones | Lectura **386 MB/s** · escritura **409 MB/s** | Cerca del máximo útil de USB 5 Gbit/s | **Confirmado** |
| Disco · secuencial | Casa | hdparm -t · dd 1 GB `oflag=direct` | Mismas condiciones; el disco Seagate conectado pero sin usar | Lectura **332 MB/s** · escritura **382 MB/s** | Un poco menos que en clase, pero del mismo orden: el techo sigue siendo USB 5 Gbit/s | **Confirmado** (y descartado que sea culpa del puerto del PC) |
| Disco · aleatorio 4K | Clase | fio randread 4K, iodepth 16, 30 s | Mismas condiciones | **38,7k IOPS** · 151 MiB/s · latencia **0,41 ms** | Muy bueno para arrancar VMs (un disco mecánico da ~100 IOPS) | Para accesos pequeños el disco **no** es el problema |
| Disco · aleatorio 4K | Casa | fio randread 4K, iodepth 16, 30 s | Mismas condiciones | **42,8k IOPS** · 167 MiB/s · latencia **0,36 ms** | Algo mejor que en clase | Igual: el problema son las copias grandes e instalaciones, no los accesos pequeños |
| Red · LAN | Clase | ping a la puerta de enlace + ethtool | Cable, 1 Gbit/s | 0 % pérdida · **0,59 ms** | Red local perfecta | Descartado |
| Red · LAN | Casa | ping a la puerta de enlace | Wi-Fi (la velocidad de enlace no se muestra) | 0 % pérdida · media **13,8 ms**, máx. 51 ms | Wi-Fi: sin pérdidas pero con más retardo y más irregular | Descartado para las VMs |
| Red · Internet | Clase | ping 1.1.1.1 · curl HTTPS · descarga de 50 MB del mirror de Debian | Red del aula | ping **100 % pérdida** (ICMP bloqueado) · HTTPS 200 en 1,2 s · descarga **3,7 MB/s** (otra medida: 5,8 MB/s) | El aula filtra el ping y sale lenta a Internet | **Confirmado** para descargas |
| Red · Internet | Casa | Las mismas | Wi-Fi de casa, 17:45 | ping **0 % pérdida, 3,9 ms** · HTTPS 200 (TLS en 0,06 s) · descarga **11,9 MB/s** (95 Mbit/s) | Unas 3 veces más rápida que el aula | **Descartado** en casa |
| Red · entre dos PCs | Clase y casa | iperf3 | — | **N/C**: no había otro PC con `iperf3 -s` | Prueba que lo confirmaría: `iperf3 -s` en otro PC de la misma red y `iperf3 -c <IP>` | — |

## 4. Conclusión
*(Redactada a partir de las respuestas de Asier.)*

Voy a usar **el PC de casa para casi todo** el trabajo pesado: instalar los sistemas, las descargas y las pruebas con varias VMs encendidas. Tiene unos 4 GB más de RAM libre, va más fresco (sobremesa) y su Internet es unas 3 veces más rápido que el del aula. El **PC de clase** lo usaré para enseñar las tareas al profesor y para el examen.

El **cuello de botella principal es el disco USB**: todas las VMs están en él y va a 5 Gbit/s (unos 330–410 MB/s) en los dos PCs, aunque los puertos dan más. Como el disco es el mismo, **cambiar de PC no lo arregla**. Para notarlo menos: no instalar varias VMs a la vez, no usar el disco Seagate mientras haya VMs y probar otro cable USB-C Gen2.
