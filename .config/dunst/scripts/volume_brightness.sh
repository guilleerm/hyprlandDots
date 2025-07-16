#!/usr/bin/env bash

# === CONFIGURACIÓN ===
# Ajusta estos valores según tus preferencias
volume_step=2
brightness_step=5
max_volume=100
notification_timeout=1000

# Opciones de carátulas de álbum
download_album_art=true
show_album_art=true

# Mostrar información de la música en el indicador de volumen
show_music_in_volume_indicator=true


# === FUNCIONES OPTIMIZADAS ===

# Usa awk para obtener el volumen de pactl. Es más eficiente que encadenar grep y head.
function get_volume {
    pactl get-sink-volume @DEFAULT_SINK@ | awk -F'/' '/Volume:/ {print $2; exit}' | tr -d ' %'
}

# Usa awk para obtener el estado de silencio de pactl. Más eficiente que grep.
function get_mute {
    pactl get-sink-mute @DEFAULT_SINK@ | awk '/Mute:/ {print $2; exit}'
}

# Obtiene el brillo actual como un porcentaje.
function get_brightness {
  current=$(brightnessctl get)
  max=$(brightnessctl max)
  percent=$(( 100 * current / max ))
  echo "$percent"
}

# Devuelve un icono según el volumen y el estado de silencio (pasados como argumentos para evitar llamadas extra).
function get_volume_icon {
    local vol=$1
    local mute_status=$2
    if [ "$vol" -eq 0 ] || [ "$mute_status" == "yes" ] ; then
        volume_icon=" " # Icono de silencio o volumen cero
    elif [ "$vol" -lt 33 ]; then
        volume_icon="" # Icono de volumen bajo
    elif [ "$vol" -lt 66 ]; then
        volume_icon=" " # Icono de volumen medio
    else
        volume_icon=" " # Icono de volumen alto
    fi
}

# Siempre devuelve el mismo icono de brillo.
function get_brightness_icon {
    brightness_icon=""
}

# Obtiene la carátula del álbum usando expansión de parámetros (más rápido que sed) y wget más silencioso.
function get_album_art {
    url=$(playerctl -f "{{mpris:artUrl}}" metadata)
    if [[ $url == "file://"* ]]; then
        album_art="${url/file:\/\//}"
    elif [[ ($url == "http://"* || $url == "https://"*) && $download_album_art == "true" ]]; then
        # Extrae el nombre del archivo de la URL de forma más eficiente
        filename="${url##*/}"
        album_art_path="/tmp/$filename"

        # Descarga el archivo solo si no existe localmente
        if [ ! -f "$album_art_path" ]; then
            wget -qO "$album_art_path" "$url" # -q (quiet) reduce la sobrecarga
        fi
        album_art="$album_art_path"
    else
        album_art=""
    fi
}

# Muestra una notificación de volumen. Obtiene el estado de volumen/silencio una sola vez.
function show_volume_notif {
    local volume=$(get_volume)
    local mute_status=$(get_mute)
    get_volume_icon "$volume" "$mute_status"

    if [[ $show_music_in_volume_indicator == "true" && $(playerctl status 2>/dev/null) != "No players found" ]]; then
        current_song=$(playerctl -f "{{title}}" metadata)
        if [[ $show_album_art == "true" ]]; then
            get_album_art
        fi
        notify-send -t "$notification_timeout" -h "string:x-dunst-stack-tag:volume_notif" -h "int:value:$volume" -i "$album_art" "$volume_icon $volume%" "$current_song"
    else
        notify-send -t "$notification_timeout" -h "string:x-dunst-stack-tag:volume_notif" -h "int:value:$volume" "$volume_icon $volume%"
    fi
}

# Muestra una notificación de música. Comprueba si hay un reproductor activo para evitar errores.
function show_music_notif {
    # Sale si no hay ningún reproductor activo para ahorrar recursos
    [[ $(playerctl status 2>/dev/null) = "No players found" ]] && exit

    song_title=$(playerctl -f "{{title}}" metadata)
    song_artist=$(playerctl -f "{{artist}}" metadata)
    song_album=$(playerctl -f "{{album}}" metadata)

    if [[ $show_album_art == "true" ]]; then
        get_album_art
    fi

    notify-send -t "$notification_timeout" -h "string:x-dunst-stack-tag:music_notif" -i "$album_art" "$song_title" "$song_artist - $song_album"
}

# Muestra una notificación de brillo.
function show_brightness_notif {
    brightness=$(get_brightness)
    get_brightness_icon
    notify-send -t "$notification_timeout" -h "string:x-dunst-stack-tag:brightness_notif" -h "int:value:$brightness" "$brightness_icon $brightness%"
}

# === FUNCIÓN PRINCIPAL ===
# Procesa la entrada del usuario

case $1 in
    volume_up)
    # Sube el volumen, desactiva el silencio y muestra la notificación.
    pactl set-sink-mute @DEFAULT_SINK@ 0
    current_volume=$(get_volume)
    if [ $(( current_volume + volume_step )) -gt $max_volume ]; then
        pactl set-sink-volume @DEFAULT_SINK@ "$max_volume%"
    else
        pactl set-sink-volume @DEFAULT_SINK@ "+$volume_step%"
    fi
    show_volume_notif
    ;;

    volume_down)
    # Baja el volumen y muestra la notificación.
    pactl set-sink-volume @DEFAULT_SINK@ "-$volume_step%"
    show_volume_notif
    ;;

    volume_mute)
    # Alterna el silencio y muestra la notificación.
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    show_volume_notif
    ;;

    brightness_up)
    # Aumenta el brillo y muestra la notificación.
    brightnessctl set -s "+$brightness_step%"
    show_brightness_notif
    ;;

    brightness_down)
    # Disminuye el brillo y muestra la notificación.
    brightnessctl set -s "$brightness_step%-"
    show_brightness_notif
    ;;

    next_track)
    # Salta a la siguiente canción y muestra la notificación.
    playerctl next
    sleep 0.5 && show_music_notif
    ;;

    prev_track)
    # Salta a la canción anterior y muestra la notificación.
    playerctl previous
    sleep 0.5 && show_music_notif
    ;;

    play_pause)
    # Pausa/reanuda la reproducción y muestra la notificación.
    playerctl play-pause
    show_music_notif
    ;;
esac