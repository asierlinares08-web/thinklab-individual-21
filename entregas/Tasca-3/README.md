# Tasca 3 · Rack i interconnexió

Es una **tarea de grupo**. La rúbrica individual **no tiene actividades** de esta tarea, así que aquí solo resumo lo que hizo el grupo.

En esta tarea no apunté predicciones antes de empezar.

**Trabajo del grupo:**
- Rack y CPD: [ESTRUCTURA](https://github.com/Trox-gm/Proyecto_ISO/tree/main/ESTRUCTURA) (repositorio del grupo, privado).
- Interconexión: [Red](https://github.com/Trox-gm/Proyecto_ISO/tree/main/Red).

## Qué hizo el grupo

- Una propuesta de CPD pequeño con un **rack de 19″**. De arriba abajo van el panel de parcheo, el switch gestionable de 24 puertos, el router/firewall, el servidor Proxmox, el TrueNAS y el SAI.
- Las condiciones de la sala: acceso restringido, ventilación, SAI, cableado ordenado y etiquetado, y protección contra incendios.
- El montaje físico: cables RJ-45 crimpados para unir los clientes con el switch, y el switch con el clúster. También un inventario del hardware y del firmware.
- El informe de red: la LAN del grupo (192.168.20.0/24), la IP y la interfaz de cada equipo, y un esquema en draw.io.

**Mi aportación:** lo hicimos entre todos; el trabajo está en el repositorio del grupo.

## Relación con la parte individual

- La idea de la interconexión (Internet → firewall → switch → servidores y clientes) es la misma que monté en virtual con la red interna LAN_21 en la [Tasca 4](../Tasca-4/) ([04-disseny](../../docs/04-disseny.md)).
- El repaso de rack y CPD (equipos, puertos, alimentación, ventilación y cableado) es lo que preparo para el examen de la [Tasca 8](../Tasca-8/) (actividades a50–a53 de FDM-RA4).
