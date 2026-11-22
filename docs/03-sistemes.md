# 03 · Sistemas elegidos, origen e integridad

Mismos sistemas que el grupo (Tasca 5 individual). Cada imagen sale de la **web oficial del fabricante** y se verifica su **SHA256** con `scripts/verificar-sha256.sh`. El registro está en [`evidencias/tasca5/verificacion-isos.txt`](../evidencias/tasca5/verificacion-isos.txt).
Las imágenes se guardan fuera del repositorio, en `~/Descargas` (pesan GB y están en `.gitignore`).

| Función | Sistema | Versión (fichero) | Arquitectura | Licencia | URL oficial | Hash SHA256 publicado | Verificado |
|---|---|---|---|---|---|---|---|
| Comunicaciones | OPNsense | 26.7 (`OPNsense-26.7-dvd-amd64.iso.bz2`) | amd64 | BSD 2 cláusulas | https://opnsense.org/download/ · hash: https://pkg.opnsense.org/releases/26.7/OPNsense-26.7-checksums-amd64.sha256 | `95cafedda6d5b22ce832e249dc2309110fbee19f813ad78cf28bb3d387186bfb` (del `.bz2`) | ✅ |
| Comunicaciones | MikroTik RouterOS CHR | 7.25.1 stable (`chr-7.25.1.vdi.zip`) | x86_64 | Gratuita (free): 1 Mbit/s de subida por interfaz | https://mikrotik.com/download · fichero: https://download.mikrotik.com/routeros/7.25.1/chr-7.25.1.vdi.zip · hash: https://download.mikrotik.com/routeros/7.25.1/chr-7.25.1.vdi.zip.sha256 | `27709f919c484b6c18512f12f298e42ac274c6ef08164938abeab55246a0a0c1` (del `.vdi.zip`) | ✅ |
| Comunicaciones | Debian + nftables (`FW3-Debian-NFT`) | 13.1 «trixie» (`debian-13.1.0-amd64-netinst.iso`) | amd64 | Libre (DFSG) | https://cdimage.debian.org/cdimage/archive/13.1.0/amd64/iso-cd/ | `658b28e209b578fe788ec5867deebae57b6aac5fce3692bbb116bab9c65568b3` | ✅ |
| Virtualización | Proxmox VE | 9.2-1 (`proxmox-ve_9.2-1.iso`) | amd64 | AGPLv3 (suscripción opcional) | https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso | `4e88fe416df9b527624a175f24c9aa07c714d3332afb1ee3dbf3879573ef2c6c` | ✅ |
| NAS / copias | TrueNAS Community Edition | 25.10.7 «Goldeye» (`TrueNAS-SCALE-25.10.7.iso`) | amd64 | Libre (código abierto) | https://www.truenas.com/download-truenas-community-edition/ · hash: https://download.truenas.com/TrueNAS-SCALE-Goldeye/25.10.7/TrueNAS-SCALE-25.10.7.iso.sha256 | `54ce9441ce66966a392e28f63604ca3c2c083d0bec4db7bb5af2f74f7a007c8e` | ✅ |
| Centralización | Windows Server 2025 Evaluation | 26100.1742, es-ES (`w2k25.iso`) | x64 | Evaluación 180 días (activar por Internet en los 10 primeros días) | https://www.microsoft.com/es-es/evalcenter/download-windows-server-2025 | **N/C**: Microsoft no publica hash en el Evaluation Center. SHA256 calculado: `b73c9688a4b8d165cadc8bf9a52d86d6483b397801b791ffd5e7d1be6cbd5d56` | N/C |
| Infraestructura | Debian (`Server-Monitorizacion`) | 13.1 (la misma ISO que `FW3-Debian-NFT`) | amd64 | Libre (DFSG) | (igual que arriba) | (igual que arriba) | ✅ |
| Cliente | Windows 11 | **25H2** (26200.6584), Español x64 (`win11.iso`) | x64 | Comercial | https://www.microsoft.com/es-es/software-download/windows11 | **N/C**: Microsoft solo publica el hash de la versión actual (26H2). SHA256 calculado: `5f53774dcadf7f0aea1c6424a937fcfffe79b4d00aea83e17a5c5accd48cd6de` | N/C |
| Cliente | Debian 13 + escritorio (`Client-Linux`) | 13.1 (la misma netinst; el escritorio se elige en el instalador) | amd64 | Libre (DFSG) | (igual que arriba) | (igual que arriba) | ✅ |

## Cómo se han identificado las imágenes
No me he fiado solo del nombre del fichero. He leído la etiqueta del volumen y el contenido de cada ISO. Evidencia: [`evidencias/tasca5/identificacion-isos.txt`](../evidencias/tasca5/identificacion-isos.txt), que demuestra la versión y la arquitectura reales de cada imagen.
- **Proxmox:** el fichero `.cd-info` de la ISO dice `RELEASE='9.2'`, `ISORELEASE='1'`.
- **Windows:** he leído la rama y la *build* en `sources/idwbinfo.txt` y en el XML de `install.wim`.
- **MikroTik:** dentro de las ISO hay paquetes `routeros-7.x.npk`. Es el **instalador para PC x86**, no la imagen CHR para máquinas virtuales.

## Notas por sistema (soporte, actualización, decisiones)
- **OPNsense 26.7:** es la versión actual. El fabricante publica el hash del `.bz2`, no el de la ISO. He verificado el `.bz2` y después he comprobado que la ISO descomprimida es idéntica a su contenido (mismo SHA256: `1efd5dc9…5d4dcd`). La web avisa de que el fichero de hashes de un *mirror* no prueba la autenticidad; por eso el hash se ha sacado de `pkg.opnsense.org`, el servidor del proyecto. Se actualiza desde la WebUI (*System → Firmware*).
  - ⚠️ El manual oficial pide **3 GB de RAM como mínimo para que funcione el instalador**. Lo tenemos en cuenta en la Fase 2.
- **MikroTik CHR 7.25.1:** es la *stable* actual (la *long-term* es la 7.24.6). Lo he comprobado en el canal oficial de actualizaciones: `upgrade.mikrotik.com/routeros/NEWESTa7.stable`. Las ISOs `mikrotik-7.24.5.iso` y `mikrotik-7.25.iso` **no se usan** porque son el instalador x86, no CHR. La licencia gratuita limita a **1 Mbit/s de subida por interfaz** (fuente: help.mikrotik.com, página «Cloud Hosted Router»). Por eso el MikroTik no es la puerta de enlace principal. Se actualiza con `/system package update`.
- **Debian 13.1:** la estable actual es la **13.7**, de la misma versión mayor «trixie», con soporte vigente según el fabricante (fuente: debian.org/releases/stable). **Decisión:** uso la 13.1 ya verificada y la actualizo con `apt update && apt full-upgrade` antes de ponerla en producción (actividad a79). El hash de una versión antigua está en el **archivo** de Debian (`cdimage/archive/13.1.0`).
- **Proxmox VE 9.2-1:** es la ISO más reciente para amd64. Se actualiza con `apt` (repositorio *no-subscription*).
- **TrueNAS 25.10.7:** la más reciente de la rama estable es la **25.10.8** (la 27.0.0 todavía es RC, no apta). **Decisión:** instalo la 25.10.7 verificada y la actualizo desde la WebUI (a79).
- **Windows Server 2025 Evaluation:** contiene Standard y Datacenter, en Server Core y con Experiencia de escritorio. La *build* 26100.1742 coincide con la ISO de evaluación que publica Microsoft; las actualizaciones llegan por Windows Update. **Hash N/C** porque Microsoft no lo publica en el Evaluation Center.
  - Cómo se podría comprobar: descargar la ISO otra vez de la web oficial y comparar los dos SHA256 (demuestra que la descarga no está corrupta, pero no su autenticidad).
- **Windows 11 (`win11.iso`, 25H2, *build* 26200.6584):** es la que uso. **No** uso `w11.iso`, que es la 22H2/23H2 (*build* 22621) y está **sin soporte** en Home/Pro.
  - **Soporte de la 25H2** (Microsoft Lifecycle): Home/Pro y Enterprise/Education, **con soporte vigente según el fabricante**. Fuentes: https://learn.microsoft.com/en-us/lifecycle/products/windows-11-home-and-pro y https://learn.microsoft.com/en-us/lifecycle/products/windows-11-enterprise-and-education
  - **Hash: N/C.** La rúbrica (a78) pide verificar la integridad «quan el fabricant publique el mecanisme». Microsoft solo publica en su web de descarga el SHA256 de la versión actual (26H2, `98287037…14F9A`), y el de la 25H2 ya no aparece. Por eso no hay nada oficial con qué comparar.
  - **Datos guardados para comprobarla si algún día se publica el hash:**
    - SHA256 calculado: `5f53774dcadf7f0aea1c6424a937fcfffe79b4d00aea83e17a5c5accd48cd6de`.
    - Origen: web oficial de Microsoft (https://www.microsoft.com/es-es/software-download/windows11).
    - Registro: [`evidencias/tasca5/verificacion-isos.txt`](../evidencias/tasca5/verificacion-isos.txt).
  - **Qué sí se ha comprobado:** la ISO se abre sin errores y su contenido es coherente: etiqueta `CCCOMA_X64FRE_ES-ES_DV9`, rama `ge_release`, *build* 26200.6584 en las 11 ediciones de `install.wim`. Eso es la 25H2 publicada por Microsoft (ver `identificacion-isos.txt`). Después de instalar se actualizará con Windows Update (a79).
  - **Decisión:** usar la 25H2 y **no** descargar la 26H2. Tiene soporte y está ya descargada; repetir una descarga de 7 GB no aporta nada a la práctica.
- **Cliente Linux:** el grupo usa **Debian 13 con escritorio**. Se instala con la misma netinst marcando un entorno de escritorio en el paso «Selección de programas». No hace falta otra imagen.
