#!/bin/bash

# check_single_app.sh
# Uso: ./script NombreAmigable NombreProceso Icono

[ "$#" -lt 4 ] && { echo '{}'; exit 1; }

APP_NAME="$1"
PROCESS_NAME="$2"
ICON="$3"

if pgrep -x "$PROCESS_NAME" >/dev/null; then
    css_class="${APP_NAME,,}"
    css_class="${css_class// /-}"
    printf '{"text":"%s","tooltip":"<b>%s</b>\\nLeft-click: Open\\nRight-click: Close","class":"custom-bg-app custom-bg-%s"}\n' \
        "$ICON" "$APP_NAME" "$css_class"
else
    echo '{}'
fi
