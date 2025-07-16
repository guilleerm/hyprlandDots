#!/bin/bash

STATE_FILE="$HOME/.local/state/bluetooth_state"

# Asegurarse de que DBUS_SESSION_BUS_ADDRESS esté configurado
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
fi

if [ -f "$STATE_FILE" ]; then
    desired_state=$(cat "$STATE_FILE")
    echo "Estado de Bluetooth deseado al inicio: $desired_state" >&2

    if [ "$desired_state" = "on" ]; then
        echo "Restaurando Bluetooth a: on" >&2
        rfkill unblock bluetooth
        sleep 0.5 # Dar tiempo a rfkill
        bluetoothctl power on
    elif [ "$desired_state" = "off" ]; then
        echo "Restaurando Bluetooth a: off" >&2
        bluetoothctl power off
        sleep 0.5 # Dar tiempo
        rfkill block bluetooth
    else
        echo "Estado desconocido en $STATE_FILE: $desired_state. Dejando Bluetooth como está o apagado por defecto." >&2
        # Por seguridad, o como fallback, podrías apagarlo si el estado es inválido
        bluetoothctl power off
        rfkill block bluetooth
    fi
else
    echo "Archivo de estado $STATE_FILE no encontrado. Dejando Bluetooth apagado por defecto." >&2
    bluetoothctl power off  # Apagado por defecto si no hay estado guardado
    rfkill block bluetooth
fi

# (Opcional) Refrescar Waybar si es necesario después de restaurar el estado
# sleep 2 # Esperar un poco más
# pkill -SIGRTMIN+8 waybar