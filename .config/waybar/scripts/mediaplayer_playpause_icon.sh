#!/bin/bash

# Obtener estado y nombre en UNA sola llamada
# Formato: "STATUS||PLAYERNAME"
raw=$(playerctl metadata --format '{{status}}||{{playerName}}' 2>/dev/null) || raw=""

if [[ -z $raw ]]; then
    # Sin reproductor activo
    printf '{"text":"","tooltip":"No player active","class":"noplayer"}\n'
    exit
fi

# Separar estado y nombre
STATUS=${raw%%||*}
NAME=${raw#*||}

# Elegir icono, tooltip y clase
case $STATUS in
    Playing)
        ICON=''
        TOOLTIP="Pause ($NAME)"
        CLASS='playing'
        ;;
    Paused)
        ICON=''
        TOOLTIP="Play ($NAME)"
        CLASS='paused'
        ;;
    *)
        ICON=''
        TOOLTIP="Play ($NAME) - $STATUS"
        CLASS='stopped'
        ;;
esac

# Salida JSON optimizada
printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
    "$ICON" "$TOOLTIP" "$CLASS"
