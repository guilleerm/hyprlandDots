#!/bin/bash

# Define el archivo que mantiene el estado actual
STATE_FILE="$HOME/.config/waybar/clock_state"

# Comprueba si el archivo existe y lee el estado
if [ -f "$STATE_FILE" ]; then
    STATE=$(cat "$STATE_FILE")
else
    STATE="time"
fi

# Acción para el clic izquierdo
if [ "$STATE" == "time" ]; then
    gnome-clocks
else
    gnome-calendar
fi