#!/usr/bin/env bash

set -o pipefail

mode='light'
mode_set=0
auto_accept=0
requested_theme=''
requested_theme_set=0
while [ "$#" -gt 0 ]; do
    argument=$1
    case "$argument" in
        --light|--dark|--both)
            if [ "$mode_set" -eq 1 ]; then
                printf 'themeghosty: choose only one of --light, --dark, or --both\n' >&2
                exit 2
            fi
            mode=${argument#--}
            mode_set=1
            shift
            if [ "$#" -gt 0 ] && [[ $1 != -* ]]; then
                requested_theme=$1
                requested_theme_set=1
                shift
            fi
            ;;
        --light=*|--dark=*|--both=*)
            if [ "$mode_set" -eq 1 ]; then
                printf 'themeghosty: choose only one of --light, --dark, or --both\n' >&2
                exit 2
            fi
            mode=${argument%%=*}
            mode=${mode#--}
            requested_theme=${argument#*=}
            requested_theme_set=1
            mode_set=1
            shift
            ;;
        -y)
            auto_accept=1
            shift
            ;;
        --help|-h)
            printf 'Usage: %s [-y] [--light|--dark|--both] [THEME]\n' "$0"
            printf '  -y  Automatically accept a single fuzzy-match suggestion\n'
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

strip_theme_source() {
    local name=$1
    case "$name" in
        *\ \(resources\)) name=${name% (resources)} ;;
        *\ \(user\)) name=${name% (user)} ;;
        *\ \(builtin\)) name=${name% (builtin)} ;;
    esac
    name="${name%"${name##*[![:space:]]}"}"
    printf '%s\n' "$name"
}

theme_output=$(ghostty +list-themes --plain) || exit 1
theme_names=()
while IFS= read -r theme_line; do
    [ -n "$theme_line" ] || continue
    theme_names+=("$(strip_theme_source "$theme_line")")
done <<< "$theme_output"

selection=''
if [ "$requested_theme_set" -eq 1 ]; then
    requested_lower=${requested_theme,,}
    for theme_name in "${theme_names[@]}"; do
        if [ "${theme_name,,}" = "$requested_lower" ]; then
            selection=$theme_name
            break
        fi
    done

    if [ -z "$selection" ]; then
        suggestions=$(printf '%s\n' "${theme_names[@]}" |
            fzf --filter="$requested_theme" | awk 'NR <= 5')
        if [ -n "$suggestions" ]; then
            suggestion_count=$(printf '%s\n' "$suggestions" | awk 'END { print NR }')
            if [ "$auto_accept" -eq 1 ] && [ "$suggestion_count" -eq 1 ]; then
                selection=$suggestions
            else
                printf '\033[31mthemeghosty: theme not found: %s\033[0m\n' "$requested_theme" >&2
                printf '\033[31mPossible matches:\033[0m\n' >&2
                while IFS= read -r suggestion; do
                    printf '  %s\n' "$suggestion" >&2
                done <<< "$suggestions"
                exit 1
            fi
        fi
        if [ -z "$selection" ]; then
            suggestion=$(printf '%s\n' "${theme_names[@]}" | awk -v requested="$requested_theme" '
            function minimum(a, b) { return a < b ? a : b }
            function distance(a, b,    i, j, cost, previous, current) {
                for (j = 0; j <= length(b); j++) previous[j] = j
                for (i = 1; i <= length(a); i++) {
                    current[0] = i
                    for (j = 1; j <= length(b); j++) {
                        cost = substr(a, i, 1) == substr(b, j, 1) ? 0 : 1
                        current[j] = minimum(previous[j] + 1,
                            minimum(current[j - 1] + 1, previous[j - 1] + cost))
                    }
                    for (j = 0; j <= length(b); j++) previous[j] = current[j]
                }
                return previous[length(b)]
            }
            BEGIN {
                requested = tolower(requested)
                limit = int(length(requested) / 3)
                if (limit < 2) limit = 2
                best = limit + 1
            }
            {
                candidate = $0
                current = distance(requested, tolower(candidate))
                if (current < best) {
                    best = current
                    suggestion_match = candidate
                }
            }
            END {
                if (suggestion_match != "") print suggestion_match
            }
            ')
            if [ "$auto_accept" -eq 1 ] && [ -n "$suggestion" ]; then
                selection=$suggestion
            else
                printf '\033[31mthemeghosty: theme not found: %s\033[0m\n' "$requested_theme" >&2
                if [ -n "$suggestion" ]; then
                    printf '\033[31mDid you mean: %s?\033[0m\n' "$suggestion" >&2
                fi
                exit 1
            fi
        fi
    fi
else
    selection=$(printf '%s\n' "${theme_names[@]}" |
        fzf --prompt '🎨 Ghostty theme  ' --layout=reverse --border --exit-0)
fi

if [ -n "$selection" ]; then
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
