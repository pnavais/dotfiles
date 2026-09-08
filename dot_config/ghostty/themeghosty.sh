#!/usr/bin/env bash

set -o pipefail

mode='light'
mode_set=0
for argument in "$@"; do
    case "$argument" in
        --light|--dark|--both)
            if [ "$mode_set" -eq 1 ]; then
                printf 'themeghosty: choose only one of --light, --dark, or --both\n' >&2
                exit 2
            fi
            mode=${argument#--}
            mode_set=1
            ;;
        --help|-h)
            printf 'Usage: %s [--light|--dark|--both]\n' "$0"
            exit 0
            ;;
        *)
            printf 'themeghosty: unknown option: %s\n' "$argument" >&2
            exit 2
            ;;
    esac
done

if ! command -v ghostty >/dev/null 2>&1; then
    printf 'themeghosty: ghostty not found in PATH\n' >&2
    exit 127
fi

if ! command -v fzf >/dev/null 2>&1; then
    printf 'themeghosty: fzf not found in PATH\n' >&2
    exit 127
fi

theme_file="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty/auto/theme.conf"

selection=$(ghostty +list-themes --plain |
    fzf --prompt '🎨 Ghostty theme  ' --layout=reverse --border --exit-0)

if [ -n "$selection" ]; then
    case "$selection" in
        *\ \(resources\)) selection=${selection% (resources)} ;;
        *\ \(user\)) selection=${selection% (user)} ;;
        *\ \(builtin\)) selection=${selection% (builtin)} ;;
    esac
    selection="${selection%"${selection##*[![:space:]]}"}"

    mkdir -p "${theme_file%/*}"

    current_value=''
    if [ -f "$theme_file" ]; then
        current_value=$(awk '
            /^[[:space:]]*theme[[:space:]]*=/ {
                value = $0
                sub(/^[[:space:]]*theme[[:space:]]*=[[:space:]]*/, "", value)
                sub(/[[:space:]]+$/, "", value)
                last = value
            }
            END { print last }
        ' "$theme_file")
    fi

    light_present=0
    dark_present=0
    if [ -n "$current_value" ]; then
        IFS=',' read -r -a theme_parts <<< "$current_value"
        for part in "${theme_parts[@]}"; do
            part="${part#"${part%%[![:space:]]*}"}"
            case "$part" in
                light:*) light_present=1 ;;
                dark:*) dark_present=1 ;;
            esac
        done
    fi

    if [ "$light_present" -eq 0 ] && [ "$dark_present" -eq 0 ]; then
        case "$mode" in
            light) new_value="light:$selection" ;;
            dark) new_value="$current_value,dark:$selection" ;;
            both) new_value="light:$selection,dark:$selection" ;;
        esac
    else
        new_value=''
        IFS=',' read -r -a theme_parts <<< "$current_value"
        for part in "${theme_parts[@]}"; do
            part="${part#"${part%%[![:space:]]*}"}"
            case "$part" in
                light:*)
                    [ "$mode" = 'light' ] || [ "$mode" = 'both' ] && part="light:$selection"
                    ;;
                dark:*)
                    [ "$mode" = 'dark' ] || [ "$mode" = 'both' ] && part="dark:$selection"
                    ;;
            esac
            if [ -n "$new_value" ]; then
                new_value="$new_value,$part"
            else
                new_value="$part"
            fi
        done

        case "$mode" in
            light)
                [ "$light_present" -eq 1 ] || new_value="light:$selection,$new_value"
                ;;
            dark)
                [ "$dark_present" -eq 1 ] || new_value="$new_value,dark:$selection"
                ;;
            both)
                [ "$light_present" -eq 1 ] || new_value="light:$selection,$new_value"
                [ "$dark_present" -eq 1 ] || new_value="$new_value,dark:$selection"
                ;;
        esac
    fi

    temporary_file=$(mktemp "${theme_file}.tmp.XXXXXX") || exit 1
    trap 'rm -f "$temporary_file"' EXIT

    if [ -f "$theme_file" ]; then
        awk -v replacement="$new_value" '
            BEGIN { replaced = 0 }
            /^[[:space:]]*theme[[:space:]]*=/ {
                if (!replaced) {
                    print "theme = " replacement
                    replaced = 1
                }
                next
            }
            { print }
            END {
                if (!replaced) print "theme = " replacement
            }
        ' "$theme_file" > "$temporary_file"
    else
        printf 'theme = %s\n' "$new_value" > "$temporary_file"
    fi
    mv "$temporary_file" "$theme_file"

    printf '%s\n' "$selection"
fi
