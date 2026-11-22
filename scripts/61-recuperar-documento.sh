#!/bin/bash
# 61-recuperar-documento.sh · Revisión final · "recuperar una función" (enunciado, Tasca 5).
# Se ejecuta en Client-Linux como asier. Crea un documento, lo copia a TrueNAS, lo BORRA,
# lo restaura desde la copia y comprueba que es idéntico (SHA-256) y con los mismos permisos.
# La salida se guarda también en TrueNAS para recogerla desde srv-mon. Sin contraseñas.
set -u
NAS=asier@192.168.21.20
DEST=/mnt/copias/cliente-linux
DOC=$HOME/documento-prueba.txt
LOG=/tmp/recuperar-documento.txt
SSHO="-o BatchMode=yes"
{
  echo "### Recuperar un documento · Client-Linux · $(date '+%F %T')"
  echo "--- 1. Crear el documento (permisos 640: lectura y escritura solo para asier, lectura para su grupo)"
  printf 'Documento de prueba de la revisión final.\nCreado: %s\nUsuario: %s\n' "$(date '+%F %T')" "$USER" > "$DOC"
  chmod 640 "$DOC"
  ls -l "$DOC"; ANTES=$(sha256sum "$DOC" | cut -d' ' -f1); echo "SHA-256 antes:   $ANTES"
  echo "--- 2. Copiarlo a TrueNAS (scp -p conserva permisos y fecha)"
  scp -q -p $SSHO "$DOC" "$NAS:$DEST/" && ssh $SSHO $NAS "ls -l $DEST/documento-prueba.txt; sha256sum $DEST/documento-prueba.txt"
  echo "--- 3. Pérdida: se borra el original"
  T0=$(date +%s.%N); rm -f "$DOC"; ls -l "$DOC" 2>&1
  echo "--- 4. Restaurar desde la copia de TrueNAS"
  scp -q -p $SSHO "$NAS:$DEST/documento-prueba.txt" "$DOC"; T1=$(date +%s.%N)
  echo "--- 5. Comprobar: se abre, mismo contenido y mismos permisos"
  cat "$DOC"; ls -l "$DOC"; DESPUES=$(sha256sum "$DOC" | cut -d' ' -f1); echo "SHA-256 después: $DESPUES"
  [ "$ANTES" = "$DESPUES" ] && echo "RESULTADO: SHA-256 IGUAL" || echo "RESULTADO: SHA-256 DISTINTO"
  echo "Tiempo desde el borrado hasta tenerlo restaurado: $(awk -v a="$T0" -v b="$T1" 'BEGIN{printf "%.2f", b-a}') s"
} > "$LOG" 2>&1
scp -q $SSHO "$LOG" "$NAS:$DEST/" && echo "ENVIADO $LOG"
