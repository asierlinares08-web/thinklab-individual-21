# Scripts

Todos en bash, comentados en castellano. Guardan su salida en `evidencias/` para que sirva de prueba.

| Script | Fase / Tarea | Qué hace | Necesita sudo |
|---|---|---|---|
| `instalar-sudoers.sh` | F1 | Instala con `sudo` las copias de root de 01 y 02 y la regla de sudoers (paso a paso, para ver dónde falla) | Sí |
| `sudoers-thinklab-asier` | F1 | Regla de sudoers: sin contraseña SOLO para las copias de root de 01 y 02 (`clase`/`casa`). Se borra en el P20 | — |
| `00-comprobar-host.sh` | F0 · T0 | Comprueba CPU (VT-x), KVM, RAM, disco, VirtualBox, Git y herramientas. Solo lee | No |
| `verificar-sha256.sh` | F0 · T5 (a78) | Compara el SHA256 de una imagen con el oficial y lo registra | No |
| `diagrama-png.sh <fichero.mmd> [ancho] [alto]` | F2 · T4 | Convierte un esquema Mermaid en PNG con Chrome sin ventana (Mermaid 10.9.1 desde jsdelivr) | No |
| `captura.sh <tasca> <descripcion> vm\|ventana [vm]` | Todas | Captura PNG de una VM (`VBoxManage screenshotpng`) o de la ventana activa del anfitrión (3 s de espera) en `evidencias/tascaN/`, sin sobrescribir | No |
| `01-inventario-hw.sh casa\|clase` | F1 · T2 | Inventario de hardware completo | Sí |
| `02-tests-diagnostico.sh casa\|clase [ip_iperf]` | F1 · T2 Apte+ | Tests de memoria, disco y red | Sí |
| `30-copia-firewall.sh` | srv-mon · P14a/P14c | Copia la configuración del firewall activo en TrueNAS con fecha y SHA-256 (FW1/FW3 por SSH con clave, FW2 por su API). Se copia a srv-mon con `scp` por la red de gestión (srv-mon no tiene `git`) | No (asier) |
| `31-vigila-parada.sh <log>` | srv-mon · P14a | Sonda cada segundo (ping al .1 y a 1.1.1.1) para medir el tiempo de parada de una errada | No |
| `32-copia-srv-mon.sh` | srv-mon · P14b/P14c | Copia la configuración de srv-mon (sin secretos) en TrueNAS | No (asier) |
| `33-copia-win11.bat <recurso> <contraseña SMB>` | Client-Win11 · P14b | `net use` + `robocopy` de Escritorio, Documentos e Imágenes a `\\192.168.21.20\win11` | No |
| `34-copia-winserver.ps1 <contraseña SMB>` | WinServer · P14b | Exporta la configuración en texto (roles, red, usuarios, directivas…) y la copia con los datos a `\\192.168.21.20\winserver` | Administrador |
| `35-copia-cliente-linux.sh` | Client-Linux · P14b | `tar` de `/home/asier` (sin caché ni secretos) → TrueNAS por SSH con clave, SHA-256 comprobado | No |
| `36-copias-auto.sh` | srv-mon · P14c (a105) | Lo que lanza `cron` cada día a las 02:30: firewall activo, srv-mon, Proxmox, configuración de TrueNAS y limpieza (+30 días) | No (asier) |
| `40-raid-lab.sh` | srv-mon · P15 | RAID 0, 1 y 5 con `mdadm`: crear, fallo, degradado, reconstrucción y persistencia | Sí (root) |
| `41-espejo-iscsi.sh` | srv-mon · P19 | Conecta el disco iSCSI de TrueNAS y crea el espejo `md2` con el disco local | Sí (root) |
| `42-espejo-prueba.sh <fase>` | srv-mon · P19 | Pruebas del espejo: cae el remoto, cae el local, montar solo con el remoto… | Sí (root) |
| `espejo-readd.service` | srv-mon · P19 | Servicio de systemd: al arrancar, vuelve a añadir el disco iSCSI al espejo | — |
| `50-medir-rendimiento.sh <escenario> <s>` | Anfitrión · P17/P18 | `vmstat` + `iostat` + `sar` + latencia del anfitrión → `evidencias/tasca7/` | No |

