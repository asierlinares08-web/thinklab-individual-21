# Tasca 1 · Necessitats i sistemes

Es una **tarea de grupo**. La rúbrica individual **no tiene actividades** de esta tarea.

**Trabajo del grupo:** [Documentación OS](https://github.com/Trox-gm/Proyecto_ISO/tree/main/Documentaci%C3%B3n%20OS) (repositorio del grupo, privado).

## Qué hizo el grupo

- Un estudio comparativo por cada rol del sistema, con alternativas, criterios y una decisión justificada.
- Firewall: **OPNsense**, elegido frente a firewalls comerciales (licencias caras), MikroTik y Debian con nftables configurado a mano.
- Virtualización: **Proxmox VE** (gratuito, con clúster y migración) y LVM-thin para el almacenamiento local, porque gasta poca RAM. Almacenamiento: **TrueNAS SCALE**.
- Identidades: **Windows Server 2025 con Active Directory**, frente a Samba 4 y FreeIPA.
- Debate de clientes («todo Windows, todo Linux o mixto»): se eligió un **modelo híbrido**, con Windows 11 Pro en oficinas y GNU/Linux en Producción y SAT ([`Clientes.md`](https://github.com/Trox-gm/Proyecto_ISO/blob/main/Documentaci%C3%B3n%20OS/Clientes.md), apartado 5).

**Mi aportación:** lo hicimos entre todos; el trabajo está en el repositorio del grupo.

## Mis predicciones (escritas antes de investigar)

| Pregunta | Lo que predije | Lo que pasó |
|---|---|---|
| Sistema para un **cliente** | Windows o Linux según el trabajador: Windows para ofimática y dominio, Linux para administrar | Puse los dos: Client-Win11 para el usuario de oficina y Client-Linux como mi puesto de gestión |
| Sistema para el **servidor de datos** | TrueNAS | Acertada: TrueNAS guarda las copias de todos los equipos |
| Sistema de **comunicaciones** | Cualquiera de los tres; yo prefería Debian con nftables | Los tres funcionan. El más cómodo fue OPNsense (web, registros y DNS); MikroTik gratis va limitado a 1 Mbit/s de subida |

Evidencia: [`chequeo-final.txt`](../../evidencias/tasca8/chequeo-final.txt). Demuestra: con cada uno de los tres firewalls, Client-Linux sale a Internet pasando por el .1.

## Relación con la parte individual

Los sistemas elegidos por el grupo son los que instalé en mi laboratorio en la [Tasca 5](../Tasca-5/). La versión, la fuente oficial y el hash de cada uno están en [03-sistemes](../../docs/03-sistemes.md).
