#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

function select_menu_esc() {
    screen_width=$(tput cols)
    spaces=""
    esc_key=$(printf "\033")
    # Create a for loop to fill the string with spaces
    for ((i=0; i<$screen_width; i++)); do
        spaces+=" "
    done
    footer "right" "${app_logo_color} v.${app_ver}" "left" "${spaces}"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "${light_green}: ${light_blue}[${white}ESC${light_blue}] ${default}to return ${light_blue}[${white}H${light_blue}] ${default}Help System ${light_blue}[${white}Q${light_blue}] ${default}Exit System ${light_blue}[${white}L${light_blue}] ${default}Logging System ${light_blue}[${white}E${light_blue}] ${default}Environment: Change to ${light_cyan}${chg_env_mode}${default} mode"

    while true; do
        read -rs -t 0.5 -n 3 key 2>/dev/null >&2
        if [[ "${key}" == "${esc_key}" ]]; then
            echo -ne "\033[?25h"
            stty -icanon sane
            footer "right" "${app_logo_color} v.${app_ver}" "left" "${spaces}"
            footer "right" "${app_logo_color} v.${app_ver}" "left" "${default}Use the arrow keys to move curson, and ${light_blue}[${white}ENTER${light_blue}] ${default}to select. Press ${light_blue}[${white}ESC${light_blue}] ${default}for ESC menu.${default}"
            return
        elif [[ "${key}" == "q" || "${key}" == "Q" ]]; then
            clear
            bye
        elif [[ "${key}" == "h" || "${key}" == "H" ]]; then
            clear
            display_help "${menu_help}"
        elif [[ "${key}" == "l" || "${key}" == "L" ]]; then
            clear
            logging_menu
        elif [[ "${key}" == "e" || "${key}" == "E" ]]; then
            clear
            if [[ $environment == "production" ]]; then
                environment="development"
                chg_env_mode="production"
            else
                environment="production"
                chg_env_mode="development"
            fi
            menu
        fi
    done
}

# Function: select_option
# Description: This function displays a menu of options and allows the user to select 
#              one option. It handles the user's key inputs and returns the index of 
#              the selected option.
function select_option {
    local ESC=$(printf "\033")

    cursor_blink_on()  {
        printf "%b" "\033[?25h";
    }

    cursor_blink_off() {
        printf "%b" "\033[?25l";
    }
    
    cursor_to() {
        printf "%b" "\033[$1;${2:-1}H";
    }
    
    print_option() {
        printf "%b" "   $1 ";
    }
    
    print_selected() {
        printf "%b" "  \033[7m $1 ${ESC}[27m";
    }
    
    get_cursor_row() {
        IFS=';' read -sdR -r -p $'\E[6n' ROW COL; 
        echo "${ROW#*[}";
    }
    
    key_input() {
        read -s -r -n1 key 2>/dev/null >&2
        if [[ $key = $ESC ]]; then
            read -s -r -n2 -t 0.1 key2 2>/dev/null >&2 # Read two more chars, timeout 0.1
            key+="$key2"  # append to existing key
        fi
        if [[ $key = ${ESC}[A ]]; then echo up; fi
        if [[ $key = ${ESC}[B ]]; then echo down; fi
        if [[ $key = "" ]]; then echo enter; fi
        if [[ $key = $ESC ]]; then echo escape; fi
    }

    # initially print empty new lines (scroll down if at bottom of screen)
    for opt; do printf "\n"; done

    # determine current screen position for overwriting the options
    local lastrow=$(get_cursor_row)
    local startrow=$((lastrow - $#))

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    local selected=0
    while true; do
        # print options by overwriting the last lines
        local idx=0
        for opt; do
            cursor_to $((startrow + idx))
            if [ $idx -eq $selected ]; then
                print_selected "$opt"
            else
                print_option "$opt"
            fi
            ((idx++))
        done

        # user key control
        case $(key_input) in
            enter)
                break
                ;;
            up)
                ((selected--));
                if [ $selected -lt 0 ]; then 
                    selected=$(($# - 1)); 
                fi
                ;;
            down)
                ((selected++));
                if [ $selected -ge $# ]; then 
                    selected=0; 
                fi;;
            escape)
                select_menu_esc
                ;;
        esac
    done

    # cursor position back to normal
    cursor_to "$lastrow"
    printf "\n"
    cursor_blink_on

    return $selected
}