# Tasca 6 · Emmagatzematge i recuperació

**Objetivo:** crear y probar tres tipos de RAID, explicar qué aporta cada uno y montar un espejo entre discos de dos equipos distintos.

Evidencias de esta tarea: [../../evidencias/tasca6/](../../evidencias/tasca6/)

## Actividades de la rúbrica

| ID | Nivel | RA | Actividad (texto de la rúbrica) | Estado |
|---|---|---|---|---|
| a102 | Apte | ISO-RA3 | Crear i verificar almenys tres tipus de RAID. | ✅ hecha |
| a103 | Apte | ISO-RA3 | Explicar què aporta cada tipus de RAID. | ✅ hecha |
| a107 | Apte+ | ISO-RA3 | Investigar i justificar l’espill entre discos de dos equips diferents. | ✅ hecha |
| a108 | Apte+ | ISO-RA3 | Implementar l’espill entre dos discos de dos equips mitjançant la solució de replicació o emmagatzematge distribuït seleccionada. | ✅ hecha |
| a109 | Apte+ | ISO-RA3 | Verificar el funcionament i explicar un cas d’ús. | ✅ hecha |

## En pocas palabras

Un **RAID** junta varios discos para que funcionen como uno. Probé tres: RAID 0 (suma espacio, pero si falla un disco lo pierde todo), RAID 1 (guarda todo dos veces) y RAID 5 (aguanta un fallo gastando menos espacio).
Rompí un disco a propósito en cada uno y vi cuáles seguían funcionando. Después hice un espejo con un disco de **otro equipo** (el NAS), a través de la red.

**Mis predicciones (antes de investigar):**
- «Si se pierde un disco, se podría perder información si no hay medidas de seguridad». **Resultado:** lo concreté: con RAID 0 se pierde todo; con RAID 1 y 5, no.
- «Elegiría RAID 1: escribe lo mismo en los 2 discos, pero pierdes el 50 % del espacio». **Resultado:** acertada para el sistema. Para datos, RAID 5 aprovecha más (66 %).

## a102 · Crear y probar tres tipos de RAID

**Qué pedía:** crear al menos tres tipos de RAID y comprobar que funcionan.

**Qué hice y por qué:** en Server-Monitorizacion (srv-mon) añadí 7 discos virtuales de 1 GB, solo para pruebas. Usé `mdadm`, la herramienta de Linux para RAID por software.
En cada RAID guardé un fichero de 50 MB con su **SHA-256** (su «huella»: si cambia un solo bit, cambia la huella). Así compruebo que los datos no se estropean.
Para probar, marqué un disco como roto y miré `/proc/mdstat` (el fichero que enseña el estado de los RAID).

**Cómo lo comprobé**

```
mdadm /dev/md1 --fail /dev/sde
```

| Tipo | Discos | Espacio útil | Al romper un disco | Reparación |
|---|---|---|---|---|
| RAID 0 | 2 × 1 GB | **2044 MiB** (100 %) | **No arranca**: se pierde todo | Imposible |
| RAID 1 | 2 × 1 GB | **1022 MiB** (50 %) | `[U_]` degradado, el SHA-256 sigue bien | **7 s** → `[UU]` |
| RAID 5 | 3 × 1 GB | **2044 MiB** (66 %) | `[U_U]` degradado, el SHA-256 sigue bien | **7 s** → `[UUU]` |

En `/proc/mdstat`, cada `U` es un disco que funciona y cada `_` uno que falta.

Evidencia: [`raid-0-1-5-mdadm.txt`](../../evidencias/tasca6/raid-0-1-5-mdadm.txt).
Demuestra: los tres RAID creados, el estado degradado al romper un disco, la reconstrucción y que el SHA-256 coincide antes y después. También que RAID 1 y 5 se montan solos después de reiniciar.

**Resultado / dato clave:** RAID 1 y RAID 5 aguantan un disco roto **sin perder datos** y se reparan en **7 s**; RAID 0 lo pierde todo.

## a103 · Qué aporta cada RAID

**Qué pedía:** explicar para qué sirve cada tipo.

| RAID | Qué aporta | Precio | Para qué lo usaría |
|---|---|---|---|
| 0 | Suma espacio y velocidad (escribe en los dos discos a la vez) | Si falla **cualquier** disco, se pierde todo | Datos temporales que se pueden volver a generar. **Nunca** para copias |
| 1 | Seguridad: cada dato está en dos discos | Pierdes la mitad del espacio | Disco del sistema de un servidor |
| 5 | Aguanta un disco roto y solo pierdes un disco de espacio (*n−1*) | Escribir es más lento (calcula la **paridad**, un dato de control para rehacer lo que falta). Mientras se repara, otro fallo lo pierde todo | Un NAS de datos |

**Ningún RAID es una copia de seguridad:** si borro un fichero o entra un virus, el RAID copia el error a todos los discos al momento. Por eso, además, hago copias en otro equipo (Tasca 5).

Velocidad medida al escribir: RAID 0 **2,7 GB/s**, un disco solo 1,9 GB/s, RAID 1 y RAID 5 **1,0 GB/s**. Sale lo que dice la teoría, pero las cifras no son de discos reales: los 7 discos están en el mismo SSD (N/C con discos físicos).

Evidencia: la parte de velocidad y la de «RAID 0 sin un disco» de [`raid-0-1-5-mdadm.txt`](../../evidencias/tasca6/raid-0-1-5-mdadm.txt).
Demuestra: con números lo que aporta cada uno. RAID 0 escribe más rápido y no arranca con un disco menos («not enough to start the array»); RAID 1 y 5 escriben más lento, pero siguen funcionando.

**Resultado / dato clave:** RAID 0 = velocidad sin seguridad · RAID 1 = seguridad con 50 % de espacio · RAID 5 = seguridad con 66 %.

**Qué he aprendido:** el RAID protege de que se rompa un disco, no de mis errores. Para eso están las copias.

## a107 · Investigar el espejo entre dos equipos

**Qué pedía:** buscar cómo hacer un espejo con discos de dos equipos distintos y justificar la elección.

**Qué se quiere:** que lo que escribo en un equipo esté **en ese mismo momento** en el disco de otro. Si se pierde el primero, los datos siguen en el segundo. Es un RAID 1 con cada disco en una máquina.

| Opción | Cómo funciona | ¿Elegida? |
|---|---|---|
| **iSCSI + mdadm** | El NAS presta un disco por la red con **iSCSI** (un protocolo que hace que un disco remoto se vea como uno local). srv-mon hace RAID 1 entre su disco y ese | ✅ **Sí.** Repite lo de a102 y TrueNAS ya trae iSCSI |
| DRBD | Copia un disco entre dos Linux | No: TrueNAS no lo trae y es otro programa que aprender |
| Ceph / GlusterFS | Reparte los datos entre 3 o más equipos | No: necesitan mucha RAM y no caben en mi PC |
| `rsync` cada X tiempo | Copia de un equipo a otro de vez en cuando | No: **no es un espejo**, entre copia y copia se pierden datos |

Fuentes: documentación de TrueNAS (*Block Shares (iSCSI)*) y `man mdadm`.

**Resultado / dato clave:** elijo **iSCSI + mdadm RAID 1**: la opción más simple que escribe en los dos equipos a la vez.

## a108 · Montar el espejo

**Qué pedía:** montar el espejo con la solución elegida.

**Qué hice:**
1. En TrueNAS (.20), un disco virtual de 1 GiB y un recurso iSCSI que **solo acepta a srv-mon** (.40).
2. En srv-mon, me conecté a ese disco. Linux lo ve como un disco más (`sdi`).
3. Creé el RAID 1 `md2` entre el disco local (`sdb`) y el de TrueNAS (`sdi`), con un **bitmap** (una lista de qué partes han cambiado, para reparar solo eso).
4. Lo dejé para que se monte solo al arrancar.

Ahí guardo los scripts de las copias de srv-mon y datos de prueba, todos con su SHA-256.

Evidencia: [`espejo-iscsi-creacion.txt`](../../evidencias/tasca6/espejo-iscsi-creacion.txt).
Demuestra: srv-mon ve el disco remoto como `TrueNAS iSCSI Disk` de 1 GiB, y `md2` está en `[UU]` (los dos discos funcionando) y montado.

**Resultado / dato clave:** `md2` = **RAID 1 entre srv-mon (.40) y TrueNAS (.20)**, estado `[UU]`.

## a109 · Comprobar que funciona y un caso de uso

**Qué pedía:** demostrar que el espejo funciona y explicar para qué sirve.

**Cómo lo comprobé:** rompí cada lado y seguí escribiendo.

| Prueba | Resultado |
|---|---|
| Apago el iSCSI de TrueNAS | En ~14 s queda `[U_]` y **sigo escribiendo**. Al volver: reparado en **2 s** |
| Rompo el disco local | `[_U]`: leo y escribo **desde el disco de TrueNAS**. Reparado en **1 s** |
| Monto el espejo **solo con el disco de TrueNAS** | Los **11 ficheros** están y sus SHA-256 coinciden |
| Reinicio srv-mon | Vuelve solo a `[UU]` |

Evidencia: [`espejo-iscsi-pruebas.txt`](../../evidencias/tasca6/espejo-iscsi-pruebas.txt).
Demuestra: el estado del espejo antes y después de cada fallo, los tiempos de reparación y que los SHA-256 coinciden en todos los pasos.

**Caso de uso:** srv-mon es el equipo que lanza todas las copias automáticas. Si se rompe su disco, sus scripts no se pierden: están también en TrueNAS. Monto otro Debian, me conecto al disco iSCSI y lo tengo todo en minutos (prueba 3). En una empresa sería lo mismo con un servidor de ficheros cuyo disco tiene un gemelo en otro edificio.

**Límites:** si borro un fichero, se borra en los dos discos (no es una copia). Y en mi laboratorio los dos discos están en el mismo PC, así que demuestra cómo funciona, pero no protege si se rompe el PC.

**Resultado / dato clave:** con cualquiera de los dos equipos caído, los datos siguen ahí; la reparación tarda **1–2 s** gracias al bitmap.

**Qué he aprendido:** un espejo entre equipos es el mismo RAID 1 de siempre. Lo único nuevo es que un disco llega por la red.

## Problemas que tuve

- **Los discos cambiaron de nombre al reiniciar (incidencia 26).** El RAID 5 se creó con `sdf`, `sdg` y `sdh`, y al reiniciar salía con `sdc`, `sdf` y `sdg`.
  No pasó nada: `mdadm` reconoce los discos por un identificador (UUID) que escribe en cada uno. Lección: en la configuración nunca uso los nombres `sdX`.
- **Al reiniciar, el espejo arrancaba con un solo disco.** El disco de TrueNAS llega por la red más tarde que el local. Lo arreglé con un pequeño servicio que espera al disco remoto y lo vuelve a añadir.

Lista completa de incidencias: [10-incidencies](../../docs/10-incidencies.md).

Más detalle técnico: [07-raid](../../docs/07-raid.md) (RAID, espejo y scripts).
