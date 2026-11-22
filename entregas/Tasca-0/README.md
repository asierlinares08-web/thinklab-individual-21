# Tasca 0 · Muntatge de l’entorn de proves

**Objetivo:** preparar mi propio laboratorio en el PC del aula, ver qué recursos tiene y hasta dónde llega, y dejarlo documentado en Markdown y Git.

Evidencias de esta tarea: [../../evidencias/tasca0/](../../evidencias/tasca0/)

## Actividades de la rúbrica

| ID | Nivel | RA | Actividad (texto de la rúbrica) | Estado |
|---|---|---|---|---|
| a17 | Apte | FDM-RA1 | Preparar l’entorn propi de proves. | ✅ hecha |
| a18 | Apte | FDM-RA1 | Identificar-ne els recursos físics i justificar-ne les limitacions. | ✅ hecha |
| a127 | Apte+ | FDM-RA1 | Documentar l’entorn propi en Markdown i Git: esquema de VM, recursos i problemes resolts. | ✅ hecha |

## En pocas palabras

Mi laboratorio es un solo PC con VirtualBox (el programa que crea máquinas virtuales, VMs). Dentro viven las 11 VMs de la empresa simulada.
Antes de montarlo comprobé que el PC podía con ello y apunté su límite: la RAM. Por eso no enciendo todas a la vez, sino por grupos.

**Mi predicción (antes de investigar):** «Ejecutaría unos comandos que me enseñen las características del equipo y una prueba de rendimiento».
**Resultado:** es lo que hice (a18). Lo que no esperaba: el límite real es la RAM y el disco USB, no el PC.

## a17 · Preparar el entorno de pruebas

**Qué pedía:** tener mi propio entorno de pruebas, parecido al del grupo.

**Qué hice y por qué:** creé las 11 VMs con un script (un fichero con los comandos de VirtualBox), para no equivocarme a mano y poder repetirlo.
Las metí todas en un grupo de VirtualBox, `/ThinkLab-asier`, para no tocar otras VMs del PC.
Los discos son **dinámicos**: solo ocupan lo que se usa de verdad.

| VM | Sistema | vCPU | RAM | Para qué |
|---|---|---|---|---|
| FW1-MikroTik · FW2-OPNsense · FW3-Debian-NFT | RouterOS · OPNsense · Debian | 1 | 288 MB · 1 GB · 512 MB | Firewall (uno encendido cada vez) |
| Proxmox-Node1/2/3 | Proxmox VE 9.2 | 2 | 3 GB cada uno | Clúster de virtualización |
| NAS-TrueNAS | TrueNAS 25.10 | 2 | 8 GB | Copias de seguridad |
| WinServer-2025 | Windows Server 2025 | 2 | 4 GB | Servidor Windows |
| Server-Monitorizacion | Debian 13 | 1 | 1 GB | Copias automáticas y RAID |
| Client-Win11 | Windows 11 | 2 | 4 GB | Cliente Windows |
| Client-Linux | Debian 13 + escritorio | 2 | 3 GB | Cliente y puesto de gestión web |

La RAM de cada una sale del mínimo oficial de cada sistema (detalle en [03-sistemes](../../docs/03-sistemes.md) y [05-recursos](../../docs/05-recursos.md)).

**Cómo lo comprobé**

Evidencia: [`vms-creadas.txt`](../../evidencias/tasca0/vms-creadas.txt).
Demuestra: las 11 VMs están en `/ThinkLab-asier` con la CPU, la RAM, los discos y la red de la tabla. Al lanzar el script otra vez dice «Creadas (0) · Saltadas (11)»: se puede repetir sin romper nada.

![FW2-OPNsense arrancando el instalador](../../evidencias/tasca0/fw2-opnsense-arranca-instalador.png)

Demuestra: la primera VM arranca bien y llega al `login:` del instalador de OPNsense 26.7. Era la duda principal (ver el problema 1 de abajo).

Después las instalé todas (Tasca 5). Al final, cada VM tiene una **instantánea** (una copia de su estado para volver atrás si una prueba sale mal).

**Resultado / dato clave:** **11 VMs** creadas en `/ThinkLab-asier`; recién creadas ocupaban solo **53 MB**.

**Qué he aprendido:** hacerlo con un script me ahorró errores, y si tengo que montar el laboratorio en otro PC, es un solo comando.

## a18 · Recursos físicos y sus límites

**Qué pedía:** saber qué tiene el PC y explicar por qué no da para todo.

**Qué hice y por qué:** antes de crear nada, pasé un script de comprobación del anfitrión (el PC real donde corre VirtualBox). Mira CPU, RAM, disco y VirtualBox.

| Recurso | Dato | ¿Es un límite? |
|---|---|---|
| CPU | Intel Core Ultra 5 125H · 14 núcleos / 18 hilos · **VT-x** | No. VT-x es la ayuda del procesador para virtualizar; sin ella no hay VMs de 64 bits |
| RAM | **30,6 GB** usables | **Sí, el principal.** Reservo 6 GB para el anfitrión → quedan **26 GB** para VMs |
| Disco | SSD externo por **USB** (5 Gbit/s) · 693 GB libres | Espacio sobra. La velocidad del USB es el segundo límite |
| VirtualBox | 7.0.20 con Extension Pack | No |

**El límite, con números:** con todas encendidas (un solo firewall) suman unos **32 GB** de RAM. No caben en 26 GB.
Por eso trabajo **por escenarios**: enciendo solo las VMs de cada prueba. Por ejemplo, para el clúster: firewall + 3 nodos Proxmox + Client-Linux.
En la Tasca 7 lo medí: aguanta **8 VMs (28 GiB) a la vez** sin bloquearse.

**Cómo lo comprobé**

Evidencia: [`comprobacion-host.txt`](../../evidencias/tasca0/comprobacion-host.txt).
Demuestra: la CPU tiene VT-x, hay 30,6 GB de RAM, el disco de las VMs es USB (`TRAN usb`) y avisa de que KVM (la virtualización del propio Linux) está cargado.

Evidencia: [`inventario-clase.txt`](../../evidencias/tasca2/inventario-clase.txt). Demuestra: el modelo de CPU y los 2 × 16 GB de RAM DDR5.

**Resultado / dato clave:** **30,6 GB** de RAM → **26 GB** para VMs; todo encendido pide **32 GB** → se trabaja por escenarios; máximo medido, **8 VMs**.

**Qué he aprendido:** en virtualización lo primero que se acaba es la RAM, no la CPU. La CPU se reparte, pero la RAM que le das a una VM ya no la tiene otra.

## a127 · Documentarlo en Markdown y Git

**Qué pedía:** documentar el entorno en Markdown y Git: esquema de las VMs, recursos y problemas resueltos.

**Qué hice y por qué:** todo el proyecto está en un repositorio Git público. Cada cosa tiene su sitio:

| Qué pide | Dónde está |
|---|---|
| Esquema de las VMs | [esquema de red](../../diagramas/red-lan21.png) y la tabla de a17 |
| Recursos | tabla de a18 · detalle en [05-recursos](../../docs/05-recursos.md) |
| Problemas resueltos | [10-incidencies](../../docs/10-incidencies.md): **28 incidencias**, con síntoma → causa → prueba → solución |
| Scripts | [`scripts/`](../../scripts/) (crear VMs, comprobar el anfitrión, inventario) |

Uso Git para guardar cada paso con un commit. Las contraseñas van en un fichero aparte que **no se sube** (`.gitignore`).

**Cómo lo comprobé**

![Esquema de red LAN_21](../../diagramas/red-lan21.png)

Demuestra: el esquema de las VMs que pide la rúbrica: qué VMs hay, su IP y a qué red está conectada cada una.

Evidencia: la portada del repositorio, [README](../../README.md). Demuestra: resume las VMs, los recursos medidos y los problemas resueltos, y enlaza al detalle.

**Resultado / dato clave:** repositorio público con esquema, tabla de recursos y **28 incidencias** documentadas.

**Qué he aprendido:** apuntar los problemas en el momento me sirvió después: cuando algo volvía a fallar, ya tenía la solución escrita.

## Problemas que tuve

- **KVM cargado en el anfitrión.** El aviso del script decía que VirtualBox podía fallar (`VERR_VMX_IN_VMX_ROOT_MODE`). Lo probé arrancando solo FW2-OPNsense: arrancó con VT-x y sin errores. No hizo falta tocar nada.
- **La descarga de MikroTik se cortaba (incidencia 1).** La reanudé donde se quedaba (`curl -C -`) y comprobé el tamaño exacto y que el zip estaba sano.
- **Contraseñas en el historial de Git (incidencia 2).** Las había escrito como ejemplo en dos documentos. Las borré de todo el historial y desde entonces solo están en el fichero privado.

Lista completa de incidencias: [10-incidencies](../../docs/10-incidencies.md).

Más detalle técnico: [01-requisits](../../docs/01-requisits.md) (requisitos) · [05-recursos](../../docs/05-recursos.md) (máquinas, RAM y escenarios).
