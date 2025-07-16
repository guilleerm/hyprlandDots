#!/bin/bash

# Define el archivo que mantiene el estado actual
STATE_FILE="$HOME/.config/waybar/clock_state"

# Comprueba si el archivo existe y lee el estado
if [ -f "$STATE_FILE" ]; then
    STATE=$(cat "$STATE_FILE")
else
    STATE="time"
    echo "$STATE" > "$STATE_FILE"
fi

# Genera la salida según el estado
if [ "$STATE" == "time" ]; then
    date "+%H:%M"
else
    date "+%A, %d %B %Y"
fi