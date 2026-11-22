#!/usr/bin/env bash
# =============================================================================
# diagrama-png.sh — Convierte un esquema Mermaid (.mmd) en PNG.
# Usa Google Chrome/Chromium sin ventana (--headless) y Mermaid 10.9.1 desde
# el CDN jsdelivr (versión fija). No instala nada.
# Uso:  ./scripts/diagrama-png.sh diagramas/red-lan21.mmd [ancho] [alto]
# Salida: el mismo nombre con .png (p. ej., diagramas/red-lan21.png)
# =============================================================================
set -u
MMD="${1:-}"; ANCHO="${2:-1600}"; ALTO="${3:-1300}"
[ -f "$MMD" ] || { echo "Uso: $0 <fichero.mmd> [ancho] [alto]"; exit 1; }
CHROME=$(command -v google-chrome || command -v chromium || command -v chromium-browser) \
  || { echo "ERROR: hace falta Google Chrome o Chromium."; exit 1; }
PNG="${MMD%.mmd}.png"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT

# Página HTML mínima con el diagrama dentro (se escapan < y & para el HTML)
{
cat <<'HTML'
<!doctype html><html><head><meta charset="utf-8">
<style>body{margin:0;padding:20px;background:#fff;font-family:sans-serif}</style>
<script src="https://cdn.jsdelivr.net/npm/mermaid@10.9.1/dist/mermaid.min.js"></script>
</head><body><pre class="mermaid">
HTML
sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g' "$MMD"
cat <<'HTML'
</pre><script>mermaid.initialize({startOnLoad:true,theme:'default',flowchart:{htmlLabels:true}});</script>
</body></html>
HTML
} > "$TMP/diagrama.html"

"$CHROME" --headless=new --disable-gpu --no-sandbox --hide-scrollbars \
  --user-data-dir="$TMP/perfil" --window-size="${ANCHO},${ALTO}" \
  --virtual-time-budget=15000 --screenshot="$PNG" "file://$TMP/diagrama.html" >/dev/null 2>&1
[ -s "$PNG" ] && echo "PNG generado: $PNG" || { echo "ERROR: no se generó el PNG."; exit 1; }
