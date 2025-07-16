#!/bin/bash

# Define el archivo que mantiene el estado actual
STATE_FILE="$HOME/.config/waybar/clock_state"

# Cambia el estado
if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" == "time" ]; then
    echo "date" > "$STATE_FILE"
else
    echo "time" > "$STATE_FILE"
fi

# Aquí deberías también actualizar la forma en que se muestra el módulo "clock"
# Esto podría implicar enviar una señal a waybar para que se actualice o
# modificar directamente el formato en el archivo de configuración, si es posible