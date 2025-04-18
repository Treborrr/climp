#!/bin/bash

# Config
IMAGE_URL="URL_HERE"
VOLUME_STEP=0.05

# Colors
GREEN="\e[32m"
BLUE="\e[34m"
RED="\e[31m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

# Convert microseconds to mm:ss
convert_us_to_time() {
    local microseconds=$1
    local total_sec=$(echo "$microseconds / 1000000" | bc)
    local min=$(echo "$total_sec / 60" | bc)
    local sec=$(echo "$total_sec % 60" | bc)
    printf "%02d:%02d" $min $sec
}

# Prepare image as lines
prepare_custom_image() {
    local tmp_file="/tmp/music_center_image.png"
    local lines=()

    if curl --silent --fail --output "$tmp_file" "$IMAGE_URL"; then
        mapfile -t lines < <(chafa -s 20x10 -f symbols -c full "$tmp_file")
    else
        lines=("[ ⚠️ Image not available ]")
    fi

    printf '%s\n' "${lines[@]}"
}

# Prepare track info as lines
prepare_track_info() {
    local player="$1"
    local status artist title album volume position length

    status=$(playerctl --player="$player" status 2>/dev/null)
    artist=$(playerctl --player="$player" metadata artist 2>/dev/null)
    title=$(playerctl --player="$player" metadata title 2>/dev/null)
    album=$(playerctl --player="$player" metadata album 2>/dev/null)
    volume=$(playerctl --player="$player" volume 2>/dev/null)
    position=$(playerctl --player="$player" position 2>/dev/null | awk '{print $1}')
    length=$(playerctl --player="$player" metadata mpris:length 2>/dev/null)

    local pos_formatted="00:00"
    local len_formatted="00:00"
    local vol_percent="N/A"

    if [[ -n "$position" && -n "$length" ]]; then
        pos_formatted=$(convert_us_to_time "$position")
        len_formatted=$(convert_us_to_time "$length")
    fi

    if [[ -n "$volume" ]]; then
        vol_percent=$(awk "BEGIN {printf \"%.0f\", $volume * 100}")
    fi

    printf "${YELLOW}🎵 Status: %s${RESET}\n" "$status"
    printf "${CYAN}🎶 Title: %s${RESET}\n" "${title:-Unknown}"
    printf "${CYAN}👤 Artist: %s${RESET}\n" "${artist:-Unknown}"
    printf "${CYAN}💿 Album: %s${RESET}\n" "${album:-Unknown}"
    printf "${BLUE}⏱️ Time: %s / %s${RESET}\n" "$pos_formatted" "$len_formatted"
    printf "${BLUE}🔊 Volume: %s%%%s\n" "$vol_percent" "$RESET"
    printf "${BLUE}       🍳\n"
    printf "    🍚 🔥 🥢\n"
}

# Print UI
print_status() {
    clear
    echo -e "${CYAN}🍚🥢 CLIMP Chaufa Music Control 🍚🥢${RESET}"
    echo "-----------------------------------------------------------"

    local player="$1"
    mapfile -t image_lines < <(prepare_custom_image)
    mapfile -t info_lines < <(prepare_track_info "$player")

    local max_lines=${#image_lines[@]}
    if [[ ${#info_lines[@]} -gt $max_lines ]]; then
        max_lines=${#info_lines[@]}
    fi

    for ((i=0; i<max_lines; i++)); do
        img="${image_lines[i]}"
        info="${info_lines[i]}"
        printf " %-40s %b\n" "${img:- }" "${info:- }"
    done

    echo "-----------------------------------------------------------"
    echo -e "${GREEN}🥢 Controls:${RESET}"
    echo "🍳 [P] Play/Pause   🔥 [N] Next   🍚 [B] Previous"
    echo "➕ [+] Vol+   ➖ [-] Vol-   🔇 [S] Mute   ❌ [Q] Quit"
    echo "-----------------------------------------------------------"
}

# Get active player
get_active_player() {
    for player in $(playerctl -l 2>/dev/null); do
        local status
        status=$(playerctl --player="$player" status 2>/dev/null)
        if [[ "$status" == "Playing" || "$status" == "Paused" ]]; then
            echo "$player"
            return
        fi
    done
}

# Track change monitor
dynamic_monitor() {
    local player="$1"
    playerctl --player="$player" --follow metadata --format "{{artist}} - {{title}}" | while read -r track; do
        print_status "$player"
    done
}

# Main program
main() {
    player=$(get_active_player)

    if [[ -z "$player" ]]; then
        echo -e "${RED}❌ No active player found.${RESET}"
        exit 1
    fi

    print_status "$player"
    dynamic_monitor "$player" &
    monitor_pid=$!

    while true; do
        read -rsn1 input
        case "$input" in
            [Pp]) playerctl --player="$player" play-pause ;;
            [Nn]) playerctl --player="$player" next ;;
            [Bb]) playerctl --player="$player" previous ;;
            "+")
                current_volume=$(playerctl --player="$player" volume)
                if [[ -n "$current_volume" ]]; then
                    new_volume=$(echo "$current_volume + $VOLUME_STEP" | bc)
                    playerctl --player="$player" volume "$new_volume"
                fi
                ;;
            "-")
                current_volume=$(playerctl --player="$player" volume)
                if [[ -n "$current_volume" ]]; then
                    new_volume=$(echo "$current_volume - $VOLUME_STEP" | bc)
                    playerctl --player="$player" volume "$new_volume"
                fi
                ;;
            [Ss]) playerctl --player="$player" volume 0 ;;
            [Qq])
                kill $monitor_pid
                echo -e "\nExiting Chaufa. Enjoy your music! 🍳🔥🍚🥢"
                exit 0
                ;;
        esac
        print_status "$player"
    done
}

main