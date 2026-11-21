# 07 · RAID (Tasca 6)

> **En pocas palabras:** un RAID junta varios discos para que funcionen como uno. He probado tres formas: una que suma espacio y velocidad pero lo pierde todo si falla un disco (RAID 0), una que guarda todo dos veces (RAID 1) y una que reparte los datos con una «pieza de control» para aguantar la pérdida de un disco gastando menos espacio (RAID 5). He estropeado un disco a propósito en cada uno y he visto cuáles siguen funcionando y cómo se reparan. Por último, he hecho un espejo con un disco de **otro equipo** (el NAS) a través de la red.

## 1. RAID 0, 1 y 5 con mdadm en Server-Monitorizacion — a102, a103
> P15 (19/11/2026, PC de clase). Con `scripts/40-raid-lab.sh` (como root en srv-mon; la contraseña de `sudo` se pasó por la entrada del SSH, no en la orden).

**Predicción (Asier):** no indicada (respondió «paso» el 21/11). **Resultado:** sin predicción, no se puede valorar si acertó o falló.

**Montaje:** 7 discos virtuales de 1 GB (`sdb`…`sdh`), solo de prueba. RAID 0 → 2 discos · RAID 1 → 2 · RAID 5 → 3. Cada RAID se formatea en ext4, se monta en `/mnt/raidN` y se le pone un fichero de 50 MB con su SHA-256 para comprobar después que los datos no cambian.

| Tipo | Discos | Capacidad útil | ¿Aguanta un fallo? | Qué gano | Prueba realizada | Evidencia |
|---|---|---|---|---|---|---|
| RAID 0 (*striping*) | 2 × 1 GB | **2044 MiB** (100 %) | **No**: con un disco menos, el RAID no arranca y se pierde **todo** | Capacidad y velocidad (escribe en los 2 discos a la vez) | `mdadm --fail` se niega («array will be failed»); se borra `sdc` y `--assemble` dice «not enough to start the array» | [txt](../evidencias/tasca6/2026-11-19_raid-0-1-5-mdadm.txt) |
| RAID 1 (espejo) | 2 × 1 GB | **1022 MiB** (50 %) | **Sí**, 1 disco (con 2 discos) | Seguridad: cada dato está escrito 2 veces. Lectura que se puede repartir | `--fail sde` → `[U_]` *clean, degraded*, el SHA-256 sigue **OK** → `--remove` + `--add` → reconstruido en **7 s** → `[UU]` y SHA-256 **OK** | ídem |
| RAID 5 (paridad) | 3 × 1 GB | **2044 MiB** (66 %: n−1 discos) | **Sí**, 1 disco | Seguridad con menos espacio perdido que RAID 1: un disco de paridad repartida | `--fail sdg` → `[U_U]` degradado, SHA-256 **OK** → reconstruido en **7 s** → `[UUU]`, SHA-256 **OK** | ídem |

**Persistencia:** RAID 1 y RAID 5 se guardan en `/etc/mdadm/mdadm.conf` (por **UUID**) y en `/etc/fstab` (por **etiqueta**, `LABEL=raid1/raid5`, con `nofail` para que el sistema arranque aunque falle el RAID), y se actualiza el `initramfs`. Después de reiniciar srv-mon se montan solos y los SHA-256 coinciden. **Detalle visto en la prueba:** después de reiniciar, los discos cambiaron de nombre (`md5` usaba `sdh` y ahora usa `sdc`). Como `mdadm` reconoce los discos por el UUID que escribe en cada uno, no pasa nada. Por eso **nunca** se usan los nombres `sdX` en la configuración (incidencia 26). Quedan libres 2 discos para el P19.

**Velocidad (escritura de 200 MB con `oflag=direct`):** disco solo 1,9 GB/s · RAID 0 **2,7 GB/s** · RAID 1 1,0 GB/s · RAID 5 1,0 GB/s. **Ojo, N/C:** los 7 discos son ficheros del **mismo SSD** del anfitrión y VirtualBox usa la caché de escritura del anfitrión, así que estas cifras **no** son las de discos reales. Lo que sí se ve es la tendencia que dice la teoría: RAID 0 escribe más rápido (reparte) y RAID 1/5 más lento (escribe 2 veces o calcula la paridad). Para medirlo bien harían falta discos físicos distintos (o desactivar la caché del anfitrión: `VBoxManage storagectl … --hostiocache off`).

**Qué aporta cada RAID (a103):**
- **RAID 0:** suma la capacidad y la velocidad de los discos, pero **multiplica el riesgo**: si falla cualquiera de los discos, se pierde todo. Sirve para datos temporales que se pueden volver a generar (una caché, un disco de trabajo para vídeo), **nunca** para copias.
- **RAID 1:** el más simple y seguro. Pierde la mitad del espacio. Es el típico para el disco del **sistema** de un servidor: si falla un disco, el servidor sigue funcionando y se cambia el disco en caliente.
- **RAID 5:** equilibrio entre espacio y seguridad. Con *n* discos se usan *n−1*. Aguanta 1 fallo, pero la reconstrucción con discos grandes tarda horas y, mientras tanto, otro fallo lo pierde todo (por eso con discos grandes se usa RAID 6 o RAIDZ2). Escribir es más lento por la paridad. Es el típico de un **NAS** de datos.
- **Ningún RAID es una copia de seguridad:** si se borra un fichero o entra un *ransomware*, el RAID copia el error a todos los discos al momento. Por eso, además del RAID, están las copias del P14 en otro equipo.

## 2. Espejo entre discos de dos equipos (Apte+) — a107, a108, a109
> P19 (19/11/2026). Scripts: `scripts/41-espejo-iscsi.sh` (montaje), `scripts/42-espejo-prueba.sh` (pruebas) y `scripts/espejo-readd.service` (arranque).

**Predicción (Asier):** no indicada (respondió «paso» el 21/11). **Resultado:** sin predicción, no se puede valorar si acertó o falló.

### Investigación y justificación (a107)
**Qué se quiere:** que un dato escrito en un equipo esté **a la vez** en el disco de **otro equipo**, para que si se pierde el primero (disco o equipo entero), el dato siga en el segundo. Es un RAID 1 en el que cada disco está en una máquina distinta.

| Opción | Cómo funciona | A favor | En contra | ¿Elegida? |
|---|---|---|---|---|
| **iSCSI + mdadm RAID 1** | TrueNAS presenta un volumen (zvol) como **disco de bloques** por la red (iSCSI). srv-mon lo ve como un disco más (`sdi`) y hace RAID 1 con su disco local | Reutiliza lo del P15 (`mdadm`); TrueNAS trae iSCSI de serie; solo hace falta `open-iscsi` en srv-mon. Se entiende y se defiende | Si la red va lenta, las escrituras van lentas (RAID 1 espera a los dos discos). Un solo servidor monta el espejo | ✅ **Sí** |
| DRBD | Módulo del kernel que replica un dispositivo de bloques entre 2 Linux | Hecho para esto; modo asíncrono para redes lentas | Dos equipos Debian con DRBD (TrueNAS no lo trae), otro software más que aprender y configurar | No: más complejo |
| GlusterFS / Ceph | Almacenamiento **distribuido** entre varios nodos (réplica 2 o 3) | Escala y no depende de un solo servidor (Ceph viene con Proxmox) | Necesitan 3 nodos y mucha RAM (Ceph: ~4 GB por OSD como mínimo). No cabe en este PC (08 §4) | No: demasiado pesado |
| ZFS `send/receive` o `rsync` periódico | Copia de un equipo a otro cada cierto tiempo | Muy simple | **No es un espejo:** entre copia y copia se pueden perder datos. Eso ya lo hacen las copias del P14 | No: no cumple «espejo» |

**Decisión:** iSCSI + `mdadm`, porque es la solución **más simple** que hace un espejo **de verdad** (escritura síncrona en los dos equipos) con lo que ya tenemos (TrueNAS + `mdadm`). Fuentes: documentación de TrueNAS (*Block Shares (iSCSI)*), `man mdadm` (`--bitmap`, `--re-add`) y `man iscsiadm` / `iscsid.conf` (`replacement_timeout`).

### Implementación (a108)
| Dónde | Qué | Cómo |
|---|---|---|
| TrueNAS | zvol `copias/espejo-srv-mon` de 1 GiB (*sparse*) | `pool.dataset.create` (GUI: *Datasets → Add Zvol*) |
| TrueNAS | iSCSI: portal **192.168.21.20:3260**, iniciador permitido **`iqn.2026-11.local.thinklab:srv-mon`**, red permitida **192.168.21.40/32**, target `espejo`, extent = el zvol, LUN 0; servicio iSCSI activo y con arranque automático | API `iscsi.*` (GUI: *Shares → Block (iSCSI) → Wizard*) |
| srv-mon | `open-iscsi` con IQN fijo, `discovery` + `login`, `node.startup = automatic` | `iscsiadm` |
| srv-mon | **`md2` = RAID 1** entre `sdb` (disco local, puerto SATA 3) y `sdi` (disco iSCSI de TrueNAS) con **bitmap interno**, ext4 `LABEL=espejo` en `/mnt/espejo` | `mdadm --create … --bitmap=internal`; los discos se nombran por `/dev/disk/by-path` (incidencia 26) |
| srv-mon | Arranque: `mdadm.conf` (UUID), `fstab` con **`_netdev,nofail`** y el servicio **`espejo-readd`**, que vuelve a añadir el disco iSCSI cuando llega por la red | `scripts/espejo-readd.service` |
| srv-mon | `replacement_timeout` de iSCSI de **120 s → 15 s** | Si TrueNAS cae, el disco remoto se da por fallido en 15 s y el espejo sigue con el local, en vez de quedarse 2 min colgado |

**Qué se guarda en el espejo (caso de uso):** los **scripts de las copias** de srv-mon (`scripts-copias/`) y datos de prueba (100 MB + ficheros escritos durante las pruebas), todos con su SHA-256.

Texto de la creación: [`2026-11-19_espejo-iscsi-creacion.txt`](../evidencias/tasca6/2026-11-19_espejo-iscsi-creacion.txt). Demuestra: el *login* al target, que srv-mon ve el disco remoto como `TrueNAS iSCSI Disk` de 1 GiB, y `md2` en `[UU]` con *Intent Bitmap: Internal*, montado (988 MB).

### Verificación y caso de uso (a109)
| Prueba | Qué se hizo | Resultado |
|---|---|---|
| 1 · Cae el equipo **remoto** | Se para el servicio iSCSI de TrueNAS y se escribe en `/mnt/espejo` | A los ~14 s el disco remoto pasa a *faulty* → `[U_]` *clean, degraded*. **Se sigue escribiendo** y los SHA-256 coinciden. Al volver TrueNAS: `--re-add` → resincronizado en **2,0 s** (el bitmap solo copia lo que cambió) → `[UU]` |
| 2 · Cae el disco **local** | `mdadm --fail /dev/sdb` y se escribe | `[_U]`: los datos se leen y escriben **desde el disco de TrueNAS**. `--re-add` → **1 s** → `[UU]`, SHA-256 OK |
| 3 · **Caso de uso:** srv-mon pierde su disco | Se para `md2` y se monta **solo con el disco de TrueNAS** | «started with 1 drive (out of 2)», montado en solo lectura: **los 11 ficheros están y sus SHA-256 coinciden**, incluidos los scripts de copias |
| 4 · Reinicio de srv-mon | `systemctl reboot` | `md2` arranca **degradado** `[U_]`: se monta con el disco local antes de que llegue el iSCSI por la red (no se pierde nada, pero falta la copia remota) |
| 5 · Reinicio con `espejo-readd.service` | Servicio que espera al disco iSCSI y lo re-añade | Tras reiniciar: **`[UU]`** solo, SHA-256 OK |

Texto completo de las 5 pruebas: [`2026-11-19_espejo-iscsi-pruebas.txt`](../evidencias/tasca6/2026-11-19_espejo-iscsi-pruebas.txt). Demuestra: el estado de `/proc/mdstat` y `mdadm --detail` antes y después de cada fallo, los tiempos de resincronización y que los SHA-256 coinciden en todos los pasos.

**Caso de uso explicado:** srv-mon es el equipo que **lanza todas las copias** (P14c). Si su disco se rompe, sus scripts, su configuración y sus registros no se pierden: están **en el mismo momento** en TrueNAS (otro equipo). Se monta otro Debian, se conecta al target iSCSI y se monta el espejo con un solo disco (prueba 3): en minutos se recupera el «cerebro» de las copias. En una empresa se usaría para lo mismo: un servidor de ficheros o una base de datos cuyo disco tiene un gemelo en otro equipo, a ser posible en otro edificio.

**Límites (honestos):**
- **No es una copia de seguridad:** si se borra un fichero en el espejo, se borra en los dos discos al momento. Por eso sigue habiendo copias fechadas (P14).
- **Rendimiento:** RAID 1 espera a que escriban los dos discos, así que el espejo va a la velocidad de la red. Aquí la red es interna (12 Gbit/s con virtio, 08 §5); con una red real de 1 Gbit/s irá como mucho a ~110 MB/s. N/C: no se ha medido la velocidad de escritura de `md2`.
- **Seguridad:** el target solo acepta el IQN y la IP de srv-mon, **sin CHAP** (sin contraseña). En una red no controlada habría que activar CHAP (N/C, no configurado).
- **Los dos discos virtuales están en el mismo SSD del anfitrión:** en el laboratorio el espejo demuestra el **funcionamiento**, no protege de que se rompa el PC (eso solo lo haría otro equipo físico).
