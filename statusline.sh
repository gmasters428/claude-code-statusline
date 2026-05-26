#!/usr/bin/env bash
BLUE="\e[38;2;137;180;250m"
TEAL="\e[38;2;137;220;235m"
GREEN="\e[38;2;166;227;161m"
PEACH="\e[38;2;250;179;135m"
RED="\e[38;2;243;139;168m"
DIM="\e[2m"
RESET="\e[0m"

input=$(cat)
output=$(echo "$input" | python3 ~/.claude/statusline_parse.py 2>/dev/null)
IFS='|' read -r model ctx cost dir effort fh_pct fh_reset wk_pct wk_reset <<< "$output"

# Pick a color based on a usage percentage (green < 50, peach < 80, red >= 80)
pct_color() {
    local p=$1
    if   (( p >= 80 )); then printf '%b' "$RED"
    elif (( p >= 50 )); then printf '%b' "$PEACH"
    else                     printf '%b' "$GREEN"
    fi
}

# Render a 10-segment bar for a percentage, colored by threshold
bar() {
    local p=$1 width=10 i filled
    (( p < 0 )) && p=0; (( p > 100 )) && p=100
    filled=$(( (p * width + 50) / 100 ))
    printf '%b' "$(pct_color "$p")"
    for ((i=0; i<filled; i++)); do printf '█'; done
    printf '%b' "$DIM"
    for ((i=filled; i<width; i++)); do printf '░'; done
    printf '%b' "$RESET"
}

# Line 1: location + model + effort
printf "${BLUE}%s${RESET}  ${TEAL}%s${RESET}" "$dir" "$model"
[[ -n "$effort" && "$effort" != "none" ]] && printf " ${DIM}[%s]${RESET}" "$effort"
printf "\n"

# Line 2: context + cost + usage windows
printf "${GREEN}Ctx %s%%${RESET}  ${PEACH}\$%s${RESET}" "$ctx" "$cost"
if [[ -n "$fh_pct" ]]; then
    printf "  ${DIM}5h${RESET} "; bar "$fh_pct"
    printf " $(pct_color "$fh_pct")%s%%${RESET}" "$fh_pct"
    [[ -n "$fh_reset" ]] && printf " ${DIM}\xe2\x9f\xb3%s${RESET}" "$fh_reset"
fi
if [[ -n "$wk_pct" ]]; then
    printf "  ${DIM}Wk${RESET} "; bar "$wk_pct"
    printf " $(pct_color "$wk_pct")%s%%${RESET}" "$wk_pct"
    [[ -n "$wk_reset" ]] && printf " ${DIM}\xe2\x9f\xb3%s${RESET}" "$wk_reset"
fi
printf "\n"
