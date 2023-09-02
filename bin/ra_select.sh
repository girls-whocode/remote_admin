#!/bin/bash

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
                continue
                ;;
        esac
    done

    # cursor position back to normal
    cursor_to "$lastrow"
    printf "\n"
    cursor_blink_on

    return $selected
}