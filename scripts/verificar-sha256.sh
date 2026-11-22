#!/usr/bin/env bash
# =============================================================================
# verificar-sha256.sh — Fase 0 / Tasca 5 (a78)
# Comprueba que una imagen descargada no está corrupta ni manipulada,
# comparando su SHA256 con el que publica el fabricante en su web oficial.
# Uso:  ./scripts/verificar-sha256.sh isos/fichero.iso <hash_oficial> "<URL donde se publica el hash>"
# Registro: evidencias/tasca5/verificacion-isos.txt (se va acumulando)
# =============================================================================
set -u
FICHERO="${1:-}"; ESPERADO="${2:-}"; FUENTE="${3:-sin indicar}"
if [ ! -f "$FICHERO" ] || [ -z "$ESPERADO" ]; then
  echo "Uso: $0 <fichero> <sha256_oficial> \"<url_fuente_del_hash>\""; exit 1
fi
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
REG="$RAIZ/evidencias/tasca5/verificacion-isos.txt"; mkdir -p "$(dirname "$REG")"

echo "Calculando SHA256 de $(basename "$FICHERO") ($(du -h "$FICHERO" | cut -f1))..."
CALC=$(sha256sum "$FICHERO" | awk '{print $1}')
ESPERADO=$(echo "$ESPERADO" | tr 'A-F' 'a-f' | xargs)
if [ "$CALC" = "$ESPERADO" ]; then RES="CORRECTO"; else RES="NO COINCIDE — NO USAR, volver a descargar"; fi

{
echo "$(date '+%F %T') · $(basename "$FICHERO")"
echo "  Calculado: $CALC"
echo "  Oficial:   $ESPERADO"
echo "  Fuente:    $FUENTE"
echo "  Resultado: $RES"
} | tee -a "$REG"
[ "$RES" = "CORRECTO" ]
