#!/bin/bash

STATE_FILE="$HOME/.local/state/bluetooth_state"
mkdir -p "${STATE_FILE%/*}" # Más rápido que dirname

# Asegura DBUS para bluetoothctl
[ -z "$DBUS_SESSION_BUS_ADDRESS" ] && export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

is_bluetooth_active() {
    [[ "$(rfkill list bluetooth 2>/dev/null)" != *"Soft blocked: yes"* ]] &&
    bluetoothctl show 2>/dev/null | grep -q "Powered: yes"
}

toggle_bluetooth() {
    if is_bluetooth_active; then
        bluetoothctl power off >/dev/null 2>&1
        sleep 0.2
        rfkill block bluetooth
        echo off > "$STATE_FILE"
    else
        rfkill unblock bluetooth
        sleep 0.2
        bluetoothctl power on >/dev/null 2>&1
        echo on > "$STATE_FILE"
    fi
    # pkill -SIGRTMIN+8 waybar
}

get_status_json() {
    local icon=""
    local tooltip=""
    local class="disabled"

    local rfkill_output
    rfkill_output=$(rfkill list bluetooth 2>/dev/null)

    if [[ "$rfkill_output" != *"Soft blocked: yes"* ]]; then
        if bluetoothctl show 2>/dev/null | grep -q "Powered: yes"; then
            class="enabled"
            tooltip="Bluetooth encendido"

            local connected
            connected=$(bluetoothctl devices Connected | cut -d' ' -f3- | head -n1)

            if [ -n "$connected" ]; then
                class="connected"
                tooltip="Conectado a: $connected"
            fi
        else
            tooltip="Bluetooth apagado (controlador)"
        fi
    else
        tooltip="Bluetooth bloqueado (rfkill)"
    fi

    printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$icon" "$tooltip" "$class"
}

case "$1" in
    --toggle) toggle_bluetooth ;;
    *) get_status_json ;;
esac
