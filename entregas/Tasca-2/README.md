# Tasca 2 · Equips i perifèrics

**Objetivo:** sacar la ficha técnica del PC de clase y del de casa, compararlos, encontrar qué los frena (cuellos de botella) y comprobarlo con tests de memoria, disco y red.

Evidencias de esta tarea: [../../evidencias/tasca2/](../../evidencias/tasca2/)

## Actividades de la rúbrica

| ID | Nivel | RA | Actividad (texto de la rúbrica) | Estado |
|---|---|---|---|---|
| a19 | Apte | FDM-RA1 | Inventariar l’equip de classe i el de casa. | ✅ hecha |
| a20 | Apte | FDM-RA1 | Comparar els equips i identificar colls de botella. | ✅ hecha |
| a21 | Apte | FDM-RA1 | Proposar solucions ajustades al maquinari disponible. | ✅ hecha |
| a27 | Apte+ | FDM-RA1 | Executar tests de memòria, disc i xarxa en l’equip de classe i en el de casa. | ✅ hecha |
| a28 | Apte+ | FDM-RA1 | Registrar l’eina, les condicions i els resultats dels tests. | ✅ hecha |
| a29 | Apte+ | FDM-RA1 | Confirmar o descartar amb dades els colls de botella previstos. | ✅ hecha |

## En pocas palabras

Pasé los mismos scripts de inventario y de tests en los dos PCs. Lo que más frena es el **disco**: las VMs van en un SSD externo por USB que en los dos PCs va a 5 Gbit/s.
Como el disco es el mismo en casa y en clase, cambiar de PC no lo arregla. La RAM marca cuántas VMs caben a la vez.

**Mis predicciones:**
- Antes de investigar: «Ejecutaría comandos que me enseñen las características del equipo y una prueba de rendimiento». **Resultado:** es lo que hice, en los dos PCs.
- Antes de ver los datos de casa: «El disco irá igual en los dos PCs porque es el mismo». **Resultado:** acertada. Lectura 386 / 332 MB/s y escritura 409 / 382 MB/s (clase / casa).

## a19 · Inventario de los dos equipos

**Qué pedía:** la ficha técnica del PC de clase y del de casa.

**Qué hice y por qué:** un script que saca CPU, RAM, discos, red, firmware y periféricos con las herramientas de Linux (`dmidecode`, `lscpu`, `lsblk`, `lsusb`, `smartctl`…). El mismo script en los dos PCs, para poder compararlos.
Los números de serie y las MAC salen como `[OCULTO]`, porque el repositorio es público.

**Cómo lo comprobé**

Evidencias: [`inventario-clase.txt`](../../evidencias/tasca2/inventario-clase.txt) y [`inventario-casa.txt`](../../evidencias/tasca2/inventario-casa.txt).
Demuestran: el hardware completo de cada PC, sacado con el mismo script.

```
sudo ./scripts/01-inventario-hw.sh clase
```

**Resultado / dato clave:** clase = portátil ASUS, Core Ultra 5 125H, 32 GB DDR5. Casa = sobremesa, Ryzen 5 5600X, 32 GB DDR4. El disco de las VMs es **el mismo** en los dos: un SSD KIOXIA de 1 TB por USB.

## a20 · Comparar y encontrar los cuellos de botella

**Qué pedía:** comparar los dos PCs y decir qué puede frenar las VMs.

**Qué hice y por qué:** comparé solo lo que afecta a las VMs. Si un dato sale igual en los dos PCs, el problema no es del PC, sino de lo que comparten (el disco y su cable).

| Componente | PC de clase | PC de casa | ¿Qué implica para las VMs? |
|---|---|---|---|
| CPU | Core Ultra 5 125H · **18 hilos** · VT-x | Ryzen 5 5600X · **12 hilos** · AMD-V | Los dos sirven para VMs y Proxmox anidado. Casa tiene menos hilos |
| RAM | **32 GB** DDR5 5600 · ranuras llenas | **32 GB** DDR4 2400 · **2 ranuras libres** | Misma cantidad. Casa se puede ampliar sin tirar nada |
| Disco de las VMs | SSD USB a **5000M** (puerto de 20 Gbit/s) | El mismo SSD a **5000M** (puerto de 10 Gbit/s) | Todas las VMs leen y escriben aquí |
| Internet | Cable · **3,7 MB/s** · el aula bloquea el ping | Wi-Fi · **11,9 MB/s** | Solo afecta a las descargas |
| Refrigeración | Portátil · 59–65 °C casi en reposo | Sobremesa · 36 °C al acabar los tests | El sobremesa aguanta mejor la carga larga |

Evidencia: el apartado «Velocidad negociada de los discos USB» de los dos inventarios ([clase](../../evidencias/tasca2/inventario-clase.txt) · [casa](../../evidencias/tasca2/inventario-casa.txt)).
Demuestra: el disco de las VMs pone `Driver=uas, 5000M` en los dos PCs.

**Cuellos de botella previstos:** 1) el disco USB, 2) la RAM, 3) la CPU (más en casa) y 4) Internet en el aula.

**Resultado / dato clave:** el disco va a **5 Gbit/s en los dos PCs**, aunque los puertos dan 10 y 20. El límite está en el disco o en su cable, no en el PC.

## a21 · Soluciones con el hardware que tengo

**Qué pedía:** soluciones que se puedan hacer con lo que hay, sin comprar.

| Cuello de botella | Solución sin comprar | Si se pudiera comprar |
|---|---|---|
| Disco USB | No instalar varias VMs a la vez; discos dinámicos; VMs sin escritorio donde se pueda. En casa, no usar el disco Seagate a la vez (comparte el USB). Probar otro cable USB-C Gen2 | Disco NVMe interno o caja USB de 10 Gbit/s |
| RAM | Trabajar **por escenarios** (solo las VMs de cada prueba) y cerrar el navegador con VMs encendidas | Casa: 2 × 16 GB más en las ranuras libres (64 GB) |
| CPU | Máximo 2 vCPU por VM | — |
| Internet del aula | Hacer en casa las descargas grandes (ISOs, actualizaciones) | — |

Evidencia: [`rendimiento-M-maximo-con-winserver.txt`](../../evidencias/tasca7/rendimiento-M-maximo-con-winserver.txt) (Tasca 7).
Demuestra: la solución de trabajar por escenarios funciona: con 8 VMs encendidas (28 GiB) el PC no se bloquea.

**Conclusión:** uso el **PC de casa** para el trabajo pesado (instalar, descargar, varias VMs a la vez): más RAM libre, más fresco e Internet 3 veces más rápido. El **PC de clase**, para enseñar las tareas y el examen.

**Qué he aprendido:** comparar dos PCs con el mismo disco me dejó ver que el problema no era el PC, sino el disco.

## a27 · Tests de memoria, disco y red en los dos equipos

**Qué pedía:** pasar tests de memoria, disco y red en clase y en casa.

**Qué hice y por qué:** otro script con los mismos tests en los dos PCs, con **0 VMs encendidas** para que nada estorbe.

**Cómo lo comprobé**

Evidencias: [`tests-clase.txt`](../../evidencias/tasca2/tests-clase.txt) y [`tests-casa.txt`](../../evidencias/tasca2/tests-casa.txt).
Demuestran: la salida completa de cada test en cada PC, con la hora y la carga del equipo.

**Resultado / dato clave:** memoria **18/18 «ok»** en los dos; disco ~**330–410 MB/s** en los dos; Internet **3,7 MB/s** en clase y **11,9 MB/s** en casa.

## a28 · Herramienta, condiciones y resultado de cada test

**Qué pedía:** apuntar con qué herramienta, en qué condiciones y qué salió.

Condiciones comunes: 0 VMs encendidas, el mismo disco USB y los mismos scripts.

| Test | Herramienta | Clase | Casa | Qué quiere decir |
|---|---|---|---|---|
| Memoria | memtester (512 MB, 1 pasada) | 18/18 ok | 18/18 ok | La RAM probada no tiene fallos |
| Disco secuencial | `hdparm -t` (leer) · `dd` 1 GB (escribir) | 386 / 409 MB/s | 332 / 382 MB/s | Cerca del máximo útil de USB a 5 Gbit/s |
| Disco aleatorio 4K | `fio` (bloques pequeños, 30 s) | 38 700 IOPS · 0,41 ms | 42 800 IOPS · 0,36 ms | Muy bien para arrancar VMs (un disco mecánico da ~100) |
| Salud del disco | `smartctl` | N/C | N/C | El adaptador USB no deja leer la salud |
| Red local | `ping` a la puerta de enlace | 0,59 ms, 0 % pérdida | 13,8 ms (Wi-Fi), 0 % pérdida | Sin pérdidas en los dos |
| Internet | `curl` (descarga de 50 MB) | 3,7 MB/s | 11,9 MB/s | Casa, unas 3 veces más rápida |
| Red entre dos PCs | `iperf3` | N/C | N/C | No había otro PC. Prueba: `iperf3 -s` en uno y `iperf3 -c <IP>` en el otro |

IOPS = operaciones de lectura por segundo. N/C = no comprobado, con la prueba que lo confirmaría.

Evidencia: [`tests-casa.txt`](../../evidencias/tasca2/tests-casa.txt). Demuestra: delante de cada resultado, el script apunta la herramienta, su versión y las condiciones (VMs encendidas, carga y RAM libre).

**Resultado / dato clave:** cada test con su herramienta, sus condiciones y su número, en los dos PCs.

## a29 · Confirmar o descartar con datos

**Qué pedía:** decir, con números, qué cuellos de botella eran reales.

| Previsto | Dato | ¿Confirmado? |
|---|---|---|
| Disco USB | 5000M y ~330–410 MB/s en **los dos** PCs | **Confirmado.** Es el techo de USB a 5 Gbit/s |
| ¿Culpa del puerto del PC? | Puertos de 10 y 20 Gbit/s, y los dos negocian 5000M | **Descartado.** Es el disco o el cable (cuál: N/C; prueba: otro cable Gen2) |
| RAM | 32 GB en los dos; el laboratorio entero no cabe | **Confirmado** como límite de VMs a la vez (en la Tasca 7: máximo 8 VMs) |
| CPU | En la Tasca 7, con 8 VMs, la CPU no se llenó | **Descartado** |
| Internet del aula | 3,7 MB/s frente a 11,9 MB/s en casa | **Confirmado en clase, descartado en casa** |

Evidencia: [`rendimiento-0-linea-base-sin-vms.txt`](../../evidencias/tasca7/rendimiento-0-linea-base-sin-vms.txt) y los de la Tasca 7 con carga. Demuestra: con 8 VMs la CPU del anfitrión no pasa del ~22 %, mientras que la RAM sí se acaba.

**Resultado / dato clave:** cuello principal = **disco USB a 5 Gbit/s**; segundo = **RAM**; CPU descartada.

**Qué he aprendido:** sin el test de casa habría culpado al portátil del aula. El mismo número en dos PCs distintos señala lo que comparten.

## Problemas que tuve

- **Los primeros tests salían absurdos (incidencia 3):** descarga a «2 bytes/s», ping a 1.1.1.1 con 100 % de pérdida y SMART vacío.
  Causa: el servidor rechazaba descargas de 100 MB, el aula bloquea el ping hacia fuera (pero no Internet) y el SMART por USB necesita otra opción.
  Solución: descarga de 50 MB de un mirror de Debian, prueba HTTPS además del ping y `smartctl -d sat`. Repetí todos los tests.

Lista completa de incidencias: [10-incidencies](../../docs/10-incidencies.md).

Más detalle técnico: [02-inventari](../../docs/02-inventari.md) (comparativa completa y todos los tests).
