#!/bin/bash

# Function: multiselect
# Description: 
function multiselect {
    ESC=$(printf "\033")
    cursor_blink_on()   { printf "%b" "${ESC}[?25h"; }
    cursor_blink_off()  { printf "%b" "${ESC}[?25l"; }
    cursor_to()         { printf "%b" "${ESC}[$1;${2:-1}H"; }
    print_inactive()    { printf "%b   %b " "$2" "$1"; }
    print_active()      { printf "%b  %b %b %b" "$2" "${ESC}[7m" "$1" "${ESC}[27m"; }
    get_cursor_row()    { IFS=';' read -sdR -r -p $'\E[6n' ROW COL; echo "${ROW#*[}"; }
    get_cursor_col()    { IFS=';' read -sdR -r -p $'\E[6n' ROW COL; echo "${COL#*[}"; }

    local return_value=$1
    local colmax=$2
    local offset=$3
    local -n options=$4
    local -n defaults=$5
    local title=$6

    clear

    local selected=()
    for ((i=0; i<${#options[@]}; i++)); do
        if [[ ${defaults[i]} = "true" ]]; then
            selected+=("true")
        else
            selected+=("false")
        fi
        printf "\n"
    done

    cursor_to $(( LINES - 2 ))
    printf "_%.s" $(seq "$COLS")
    echo -e "${light_blue} ${title} | ${white}[space]${light_green} select | (${white}[n]${light_green})${white}[a]${light_green} (un)select all | ${white}up/down/left/right${light_green} or ${white}k/j/l/h${light_green} move" | column 

    # determine current screen position for overwriting the options
    local lastrow=$(get_cursor_row)
    local lastcol=$(get_cursor_col)
    local startrow=1
    local startcol=1

    # ensure cursor and input echoing back on upon a ctrl+c during read -s
    trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
    cursor_blink_off

    key_input() {
        local key
        IFS= read -rsn1 key 2>/dev/null >&2
        if [[ $key = "" ]]; then echo enter; fi;
        if [[ $key = $'\x20' ]]; then echo space; fi;
        if [[ $key = "k" ]]; then echo up; fi;
        if [[ $key = "j" ]]; then echo down; fi;
        if [[ $key = "h" ]]; then echo left; fi;
        if [[ $key = "l" ]]; then echo right; fi;
        if [[ $key = "a" ]]; then echo all; fi;
        if [[ $key = "n" ]]; then echo none; fi;
        if [[ $key = $'\x1b' ]]; then
            read -rsn2 key
            if [[ $key = [A || $key = k ]]; then echo up;    fi;
            if [[ $key = [B || $key = j ]]; then echo down;  fi;
            if [[ $key = [C || $key = l ]]; then echo right; fi;
            if [[ $key = [D || $key = h ]]; then echo left;  fi;
        fi
    }

    toggle_option() {
        local option=$1
        if [[ ${selected[option]} == true ]]; then
            selected[option]=false
        else
            selected[option]=true
        fi
    }

    toggle_option_multicol() {
        local option_row=$1
        local option_col=$2

        if [[ $option_row -eq -10 ]] && [[ $option_row -eq -10 ]]; then
            for ((option=0; option<${#selected[@]}; option++)); do
                selected[option]=true
            done
        else
            if [[ $option_row -eq -100 ]] && [[ $option_row -eq -100 ]]; then
                for ((option=0; option<${#selected[@]}; option++)); do
                    selected[option]=false
                done
            else
                option=$(( option_col + option_row * colmax ))

                if [[ ${selected[option]} == true ]]; then
                    selected[option]=false
                else
                    selected[option]=true
                fi
            fi
        fi
    }

    print_options_multicol() {
        # print options by overwriting the last lines
        local curr_col=$1
        local curr_row=$2
        local curr_idx=0

        local idx=0
        local row=0
        local col=0

        curr_idx=$(( curr_col + curr_row * colmax ))

        for option in "${options[@]}"; do
            local prefix="${dark_gray}[ ]${default}"
            if [[ ${selected[idx]} == true ]]; then
              prefix="${light_green}[${light_green}✔${default}${light_green}]${default}"
            fi

            row=$(( idx/colmax ))
            col=$(( idx - row * colmax ))

            cursor_to $(( startrow + row + 1)) $(( offset * col + 1))
            if [ $idx -eq $curr_idx ]; then
                print_active "${option}" "${prefix}"
            else
                print_inactive "${option}" "${prefix}"
            fi
            ((idx++))
        done
    }

    local active_row=0
    local active_col=0

    while true; do
        print_options_multicol $active_col $active_row

        # user key control
        case $(key_input) in
            space)  
                    toggle_option_multicol $active_row $active_col
                    ;;
            enter)  
                    print_options_multicol -1 -1
                    break
                    ;;
            up)     
                    ((active_row--))
                    if [ $active_row -lt 0 ]; then 
                        active_row=0
                    fi;;
            down)   
                    ((active_row++))
                    if [ $active_row -ge $(( ${#options[@]} / colmax )) ]; then 
                        active_row=$(( ${#options[@]} / colmax ))
                    fi
                    ;;
            left)   
                    ((active_col=active_col - 1))
                    if [ $active_col -lt 0 ]; then 
                        active_col=0; 
                    fi
                    ;;
            right)  
                    ((active_col=active_col + 1))
                    if [ $active_col -ge "$colmax" ]; then 
                        active_col=$(( colmax - 1 ))
                    fi
                    ;;
            all)    
                    toggle_option_multicol -10 -10
                    ;;
            none)   
                    toggle_option_multicol -100 -100
                    ;;
        esac
    done

    # cursor position back to normal
    cursor_to "$lastrow"
    printf "\n"
    cursor_blink_on

    eval "$return_value"='("${selected[@]}")'
    clear
}
