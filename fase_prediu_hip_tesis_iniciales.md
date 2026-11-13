# Tasca 0 — Fase PREDIU: Hipótesis y Criterios Iniciales

* **Módulo / RA asociado:** FDM-RA1 (Metodología *ThinkLoop* — Fase 1: Predice)
* **Puesto escolar:** Puesto 21 (`192.168.21.0/24`)
* **Escenario:** Empresa de nueva creación en Alcoi (25–30 trabajadores repartidos en Dirección, Administración, Comercial, Producción y SAT) con presupuesto ajustado.

---

## 1. Elección de Sistemas Operativos por Función

Antes de instalar nada en el laboratorio, analizo qué sistema operativo encaja mejor en cada rol según las necesidades reales de la empresa y el principio de *"primero la necesidad; después, la tecnología"*:

* **Puestos cliente (Estaciones de trabajo):**
  * **Windows 11:** Lo elegiría para los departamentos de **Dirección, Administración y Comercial**. En estos puestos se utilizan herramientas de gestión empresarial, facturación y ofimática estándar (como Microsoft 365), además de aplicaciones específicas de proveedores que suelen estar desarrolladas únicamente para Windows. También reduce la curva de aprendizaje porque los usuarios ya están acostumbrados a su entorno.
  * **GNU/Linux (Debian / Ubuntu):** Lo implantaría en puestos más técnicos o de consulta controlada, como el departamento de **SAT** o terminales de planta en **Producción**. Al ser software libre nos ahorra costes de licencias, consume menos memoria RAM en equipos más sencillos, ofrece un control muy alto desde terminal y es menos vulnerable al malware habitual de oficina.

* **Servidor de almacenamiento de datos (NAS):**
  * Elegiría un sistema operativo especializado en gestión de almacenamiento en red, como **TrueNAS SCALE**. A diferencia de un sistema operativo de escritorio, está pensado exclusivamente para compartir archivos de forma segura (mediante protocolos como SMB para Windows o NFS para Linux) y centralizar las copias de seguridad. Su punto fuerte es el uso del sistema de ficheros **ZFS**, que protege la integridad de los datos detectando y corrigiendo errores silenciosos en los discos, además de permitir instantáneas (*snapshots*) rápidas.

* **Equipo de comunicaciones (Router / Cortafuegos):**
  * Utilizaría un sistema ligero, estable y dedicado exclusivamente al enrutamiento y filtrado de paquetes, como **RouterOS (MikroTik)**, **OPNsense (basado en FreeBSD)** o un **Debian GNU/Linux mínimo sin entorno gráfico con `nftables`**. Un cortafuegos no necesita interfaz gráfica de escritorio ni programas de usuario, ya que eso consumiría memoria RAM innecesaria y aumentaría la superficie de ataque frente a fallos de seguridad. Estos sistemas arrancan rápido, consumen muy pocos recursos y permiten gestionar reglas de red, NAT y cortafuegos con total precisión.

---

## 2. Comprobaciones de Hardware Previas al Despliegue

Antes de crear las máquinas virtuales e instalar los sistemas operativos en el equipo anfitrión, comprobaría los siguientes puntos físicos y de firmware:

1. **Soporte de virtualización en BIOS/UEFI:** Verificar que las extensiones de virtualización por hardware (**Intel VT-x** o **AMD-V**) estén activadas en la placa base. Sin esta opción habilitada, VirtualBox no permite ejecutar máquinas virtuales de 64 bits o el rendimiento cae drásticamente. También es clave que soporte virtualización anidada (*Nested Virtualization*) para poder probar Proxmox VE dentro de VirtualBox.
2. **Memoria RAM física total y disponible:** Comprobar cuánta memoria RAM tiene instalada el PC anfitrión (en mi caso, $32\text{ GB}$) y cuánta queda libre con el sistema operativo base arrancado. Esto marca el límite real de máquinas virtuales que podré mantener encendidas a la vez sin agotar la memoria.
3. **Procesador (núcleos e hilos):** Revisar el número de núcleos físicos y lógicos ($12$ núcleos en mi equipo) para repartir las vCPU de forma equilibrada y dejar siempre capacidad libre al sistema anfitrión para que no se congele.
4. **Almacenamiento (tipo de unidad, espacio libre y salud SMART):** Asegurarme de que las máquinas virtuales se guardan en un **SSD** y no en un disco duro mecánico (HDD), ya que arrancar varios sistemas a la vez genera muchas operaciones de lectura/escritura simultáneas. Además, revisaría los parámetros **SMART** del SSD para confirmar que no presenta desgaste crítico ni sectores defectuosos, y comprobaría que hay espacio libre suficiente para los discos virtuales `.vdi` y las imágenes ISO.
5. **Conectividad de red física:** Verificar que la tarjeta de red del equipo anfitrión funciona correctamente para poder descargar las imágenes ISO, actualizar los paquetes de los sistemas y mantener el entorno individual aislado de la red del aula (`172.16.222.0/24`).

---

## 3. Consecuencias de la Pérdida o Rotura de un Disco Duro

Si un disco duro se rompe físicamente o deja de responder, el impacto depende directamente de cómo esté diseñada la arquitectura de almacenamiento:

* **Escenario 1: Disco único sin redundancia ni copias de seguridad:**
  * Se produce una **pérdida total e irreversible de los datos** almacenados en esa unidad (documentos departamentales, bases de datos, configuraciones o máquinas virtuales completas) y la **caída inmediata del servicio** (*indisponibilidad*). En una empresa real de 25–30 empleados, esto paralizaría la facturación, la atención al cliente y la producción hasta reinstalar todo desde cero.
* **Escenario 2: Sistema con redundancia RAID (RAID 1, RAID 5 o RAID-Z), pero sin copias externas:**
  * El sistema **sigue funcionando sin interrupción** (*alta disponibilidad*), ya que los datos se leen o reconstruyen a partir de los discos restantes del conjunto. Sin embargo, el sistema queda en estado degradado hasta que se sustituye el disco averiado y se reconstruye el array. Además, es muy importante tener claro que **un RAID no es una copia de seguridad**: si un usuario borra una carpeta por error o entra un *ransomware* que cifra los archivos, ese borrado o cifrado se replica al instante en todos los discos del RAID.
* **Conclusión preventiva:**
  * Para proteger realmente la empresa hacen falta **dos barreras complementarias**: por un lado, **redundancia de discos (RAID)** en los servidores críticos para evitar paradas de servicio ante averías físicas; y por otro, **copias de seguridad periódicas y externas** en otro dispositivo separado (como nuestro servidor TrueNAS), verificando de vez en cuando que se pueden restaurar correctamente.