#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

function end_time() {
    endtime_sec=$(date +%s)
    endtime_millis=$(date +%3N)
    ra_start_time_sec=${1%.*}
    ra_start_time_millis=${1#*.}

    elapsed_sec=$(( endtime_sec - ra_start_time_sec ))
    elapsed_millis=$(( endtime_millis - ra_start_time_millis ))

    if (( elapsed_millis < 0 )); then
        elapsed_sec=$(( elapsed_sec - 1 ))
        elapsed_millis=$(( elapsed_millis + 1000 ))
    fi

    # Calculate hours, minutes, and remaining seconds
    elapsed_hours=$(( elapsed_sec / 3600 ))
    elapsed_minutes=$(( (elapsed_sec % 3600) / 60 ))
    remaining_seconds=$(( elapsed_sec % 60 ))

    # Build the time string
    elapsed_time_formatted=$(printf "%02dh %02dm %02d.%03ds" $elapsed_hours $elapsed_minutes $remaining_seconds $elapsed_millis)
}

function pause() {
    read -rp "Press Enter to continue..."
}

function handle_input() {
    esc_key=$(printf "\033")
    read -rs -t 0.75 -n 3 key
    if [[ "${key}" == "q" || "${key}" == "Q" || "${key}" == "${esc_key}" ]]; then
        echo -ne "\033[?25h"
        stty -icanon sane
        eval "${1}"
        keep_running=false
    fi
    unset key
}

function show_message() {
  local message=$1
  local lines=$(tput lines)
  local cols=$(tput cols)

  local half_message_length=$((${#message} / 2))
  local middle_line=$((lines / 2))
  local middle_col=$((cols / 2))

  tput cup $middle_line $((middle_col - half_message_length))
  printf "\e[1;31m$message\e[0m"
}

function wrap_text() {
    local text="$1"
    local wrap_at=$(tput cols)

    local wrapped_text=""
    local line_length=0
    local word=""
    local ansi_escape=""
    local in_ansi_escape=false

    text+=" "

    for (( i=0; i<${#text}; i++ )); do
        char="${text:$i:1}"

        if [ "$char" == $'\033' ]; then
            in_ansi_escape=true
        fi

        if [ "$in_ansi_escape" == true ]; then
            ansi_escape+="$char"
            if [ "$char" == "m" ]; then
                in_ansi_escape=false
                continue
            fi
        else
            word+="$ansi_escape$char"
            ansi_escape=""
            local word_length=$(echo -n "$word" | strip_ansi | wc -c)

            if [[ "$char" == " " || "$char" == $'\n' ]]; then
                if (( line_length + word_length > wrap_at )); then
                    wrapped_text+="\n"
                    line_length=0
                fi

                wrapped_text+="$word"
                line_length=$((line_length + word_length))
                word=""
            fi
        fi
    done

    echo -e "$wrapped_text"
}

function pad_to_width() {
    local text="$1"
    local width="$2"
    local stripped_text=$(strip_ansi "$text")
    local stripped_length=${#stripped_text}
    local num_spaces=$(($width - $stripped_length))
    printf "%b" "$text"
    printf "%${num_spaces}s" " "
}

function add_commas() {
    echo "${1}" | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'
}

function bytes_to_human() {
    local bytes=${1}
    if [[ bytes -lt 1024 ]]; then
        echo "$(add_commas ${bytes}).00 B"
    elif [[ bytes -lt 1048576 ]]; then
        echo "$(add_commas $(awk "BEGIN { printf \"%.2f\", ${bytes}/1024 }")) KiB"
    elif [[ bytes -lt 1073741824 ]]; then
        echo "$(add_commas $(awk "BEGIN { printf \"%.2f\", ${bytes}/1048576 }")) MiB"
    else
        echo "$(add_commas $(awk "BEGIN { printf \"%.2f\", ${bytes}/1073741824 }")) GiB"
    fi
}

function draw_bar() {
    local value=$1
    local max_value=$2
    local bar_length=$3

    # Calculate the ratio as an integer
    local ratio=$(( value * 100 / max_value ))
    local bar_count=$(( bar_length * ratio / 100 ))
    
    # Draw the bar using hash symbols
    local bar=$(printf "%-${bar_count}s" "" | tr ' ' '#')

    echo -n "$bar"
}

function draw_center_line_with_info() {
    tput sc
    # Get terminal dimensions
    local width=$(tput cols)
    local height=$(tput lines)

    # Calculate the column at which the '|' should be drawn
    local middle_col=$((width * 75 / 100))

    # Loop through each row to draw the '|'
    for (( row=1; row<height-3; row++ )); do
        # Position the cursor
        tput cup $row $middle_col

        # Print the '|' character
        echo -ne "${dark_gray}│${default}"

        # Insert text at specified rows
        case $row in
        1)
            tput cup $row $((middle_col + 2))
            echo -ne "${cyan}User: ${light_green}${username}${default}"
            ;;
        2)
            tput cup $row $((middle_col + 2))
            echo -ne "${cyan}Identity: ${light_green}${identity_file}${default}"
            ;;
        3)
            tput cup $row $((middle_col + 2))
            echo -ne "${cyan}SSH Port: ${light_green}${port}${default}"
            ;;
        4)
            tput cup $row $((middle_col + 2))
            echo -ne "${cyan}Logging Level: ${light_green}${logging}${default}"
            ;;
        5)
            tput cup $row $((middle_col + 2))
            echo ""
            ;;
        6)
            tput cup $row $((middle_col + 2))
            if [[ ${hostname} != "" ]]; then
                echo -ne "${cyan}Hostname: ${light_green}${hostname}${default}"
            fi
            ;;
        7)
            tput cup $row $((middle_col + 2))
            if [[ $hostname != "" ]]; then
                do_connection_test "${hostname}"
                if [ "$connection_result" == "true" ]; then
                    connect_test="${light_green}OK${default}"
                else
                    connect_test="${light_red}FAILED${default}"
                fi
                echo -ne "${cyan}Connection: ${connect_test}"
                
            fi
            ;;
        8)
            tput cup $row $((middle_col + 2))
            echo ""
            ;;
        9)
            tput cup $row $((middle_col + 2))
            echo ""
            ;;
        10)
            tput cup $row $((middle_col + 2))
            echo ""
            ;;
        11)
            tput cup $row $((middle_col + 2))
            echo ""
            ;;
        12)
            tput cup $row $((middle_col + 2))
            echo ""
            ;;
        13)
            tput cup $row $((middle_col + 2))
            echo ""
            ;;
        14)
            tput cup $row $((middle_col + 2))
            echo ""
            ;;
        15)
            tput cup $row $((middle_col + 2))
            echo ""
            ;;
        16)
            tput cup $row $((middle_col + 2))
            echo ""
            ;;
        17)
            tput cup $row $((middle_col + 2))
            echo ""
            ;;
        18)
            tput cup $row $((middle_col + 2))
            echo ""
            ;;
        19)
            tput cup $row $((middle_col + 2))
            echo ""
            ;;
        20)
            tput cup $row $((middle_col + 2))
            echo ""
            ;;
        21)
            tput cup $row $((middle_col + 2))
            echo ""
            ;;
        22)
            tput cup $row $((middle_col + 2))
            echo ""
            ;;
        23)
            tput cup $row $((middle_col + 2))
            echo ""
            ;;
        24)
            tput cup $row $((middle_col + 2))
            echo ""
            ;;
        25)
            tput cup $((height - 6)) $((middle_col + 2))
            echo -ne "${dark_gray}$(find ${ra_script_location} -type f -name "*.sh" -exec cat {} + | wc -l) lines of code"
            ;;
        26)
            tput cup $((height - 5)) $((middle_col + 2))
            echo -ne "${light_cyan}[I]: ${dark_gray}${#info} - ${yellow}[W]: ${dark_gray}${#warnings} - ${light_red}[E]: ${dark_gray}${#errors}${default}"
        esac
    done
    tput rc
}

function enter_username() {
    read -p "Enter the username: " custom_option
    username="$custom_option"
    echo -en "${default}Do you wish to save to the configuration? ${light_blue}(${light_red}y${default}/${light_green}N${light_blue})${default} "
    read save_username
    info "Username was changed to ${username}" >> "${ra_log_file}"
    if [[ ${save_username} == "y" ]]; then
        debug "Username ${username} was written to config file" >> "${ra_log_file}"
        save_config
    fi
    return
}

function enter_identityfile() {
    # User chose the "Type in Hostname" option
    old_identity=${identity_file}
    read -p "Enter the identity file path and name: " custom_option
    identity_file="$custom_option"
    if [ -f ${identity_file} ]; then
        echo -en "${default}Do you wish to save to the configuration? ${light_blue}(${light_red}y${default}/${light_green}N${light_blue})${default} "
        read save_identity
        info "Identity file was changed from ${old_identity} to ${identity_file}" >> "${ra_log_file}"
        if [[ ${save_identity} == "y" ]]; then
            debug "Identity file ${identity_file} was written to config file" >> "${ra_log_file}"
            save_config
        fi
    else
        echo "The identity file ${identity_file} was not found"
        identity_file=${old_identity}
        pause
    fi
    return
}

function line() {
    local percentage=$1  # Get the desired percentage from the function argument
    local char=$2  # Get the character to be used for the line

    # Get the width of the terminal in columns
    local term_width=$(tput cols)

    # Calculate the line length based on the percentage
    local line_length=$((term_width * percentage / 100))

    # Create and print the line using the specified character and length
    printf -v line_str "%-${line_length}s"
    printf -- "${line_str// /$char}\n"
}

function save_tmp(){
    echo "$1" > "$tmpfile"
    chmod 600 "$tmpfile"
}

function new_list() {
    list=(); match=
    for item in "${selected_list[@]}" "${fullist[@]}"; {
        case         $item:$match    in
                 *{\ *\ }*:1) break  ;;
           *{\ $filter\ }*:*) match=1;;
        esac
        [[ $match ]] && list+=( "$item" )
    }
    [[ $filter =~ Selected ]] && return
    [[ ${list[*]} ]] && save_tmp "filter='$filter'" || { list=( "${fullist[@]}" ); rm "$tmpfile"; }
}

function get_user {
    # The user is specified in the config file, use it, if not then get current user
    if [[ ${username} == "" ]]; then
        username=${USER}
    fi
    return
}

function get_identity {
    # The identity is specified in the config file, use it
    echo "Get Identity"
    return
}

function strip_ansi() {
    local text="$1"
    echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g'
}

function header() {
    cols=$(tput cols)
    text="$2"
    text_length=${#text}
    decorative_length=12  # Length of ----][---- characters

    # Get components of the date
    year=$(date +%Y)
    month=$(date +%b)  # Abbreviated month name
    day=$(date +%d)    # Zero-padded day

    # Combine them into the desired format
    fixed_date="${day}, ${month}. ${year}"
    fixed_date_length=${#fixed_date}

    case "$1" in
        "left")
            # Prepare the prefix with title
            echo -ne "${dark_gray}----${white}] ${light_cyan}${text} ${white}[${dark_gray}----${default}"
            
            # Prepare the suffix with date
            suffix_length=$((cols - text_length - fixed_date_length - (decorative_length * 2)))
            printf '%b%*s%b' "${dark_gray}" "${suffix_length}" | tr ' ' "-"
            echo -ne "${dark_gray}----${white}] ${light_green}${fixed_date} ${white}[${dark_gray}----${default}"
            echo  # Add a newline at the end
            ;;
        "center")
            padding_length=$(( (cols - text_length - fixed_date_length - (decorative_length * 2)) / 2 ))
            
            # Prepare the prefix with title
            printf '%b%*s%b' "${dark_gray}" "${padding_length}" | tr ' ' "-"
            echo -ne "${dark_gray}----${white}] ${light_cyan}${text} ${white}[${dark_gray}----${default}"
            
            # Prepare the suffix with date
            suffix_length=$((cols - text_length - fixed_date_length - padding_length - (decorative_length * 2)))
            printf '%b%*s%b' "${dark_gray}" "${suffix_length}" | tr ' ' "-"
            echo -ne "${dark_gray}----${white}] ${light_green}${fixed_date} ${white}[${dark_gray}----${default}"
            echo  # Add a newline at the end
            ;;
        "right")
            # Prepare the prefix with date
            prefix_length=$((cols - text_length - fixed_date_length - (decorative_length * 2)))
            printf '%b%*s%b' "${dark_gray}" "${prefix_length}" | tr ' ' "-"
            echo -ne "${dark_gray}----${white}] ${light_green}${fixed_date} ${white}[${dark_gray}----${default}"
            
            # Prepare the title
            echo -ne "${dark_gray}----${white}] ${light_cyan}${text} ${white}[${dark_gray}----${default}"
            echo  # Add a newline at the end
            ;;
        *)
            echo "Invalid alignment specified"
            return 1
            ;;
    esac
}

function save_cursor_position() {
    echo -ne "\033[s"
}

function restore_cursor_position() {
    echo -ne "\033[u"
}

function footer() {
    cols=$(tput cols)
    text1="$2"
    align1="$1"
    text2="$4"
    align2="$3"
    text1_stripped=$(strip_ansi "$text1")
    text1_length=${#text1_stripped}
    text2_stripped=$(strip_ansi "$text2")
    text2_length=${#text2_stripped}
    decorative_length=12  # Length of --][-- characters

    # Save the current cursor position
    save_cursor_position

    # Move to the line where the footer starts, taking into account the optional second line
    starting_line=$(( $(tput lines) - 2 - (${text2:+1}) ))
    tput cup $starting_line 0

    case "${align1}" in
        "left")
            echo -ne "${dark_gray}----${white}[ ${light_cyan}${text1}${white} ]${dark_gray}----${default}"
            suffix_length=$((cols - text1_length - decorative_length))
            echo -ne "${dark_gray}"
            printf '%*s' "${suffix_length}" | tr ' ' '-'
            echo -ne "${default}"
            echo
            ;;
        "center")
            padding_length=$(( (cols - text1_length - decorative_length) / 2 ))
            echo -ne "${dark_gray}"
            printf '%*s' "${padding_length}" | tr ' ' '-'
            echo -ne "----${white}[ ${light_cyan}${text1}${white} ]${dark_gray}----${default}"
            suffix_length=$((cols - text1_length - padding_length - decorative_length))
            echo -ne "${dark_gray}"
            printf '%*s' "${suffix_length}" | tr ' ' '-'
            echo -ne "${default}"
            echo
            ;;
        "right")
            prefix_length=$((cols - text1_length - decorative_length))
            echo -ne "${dark_gray}"
            printf '%*s' "${prefix_length}" | tr ' ' '-'
            echo -ne "----${white}[ ${light_cyan}${text1}${white} ]${dark_gray}----${default}"
            echo
            ;;
        *)
            echo "Invalid alignment specified"
            return 1
            ;;
    esac


    # Optional second line
    if [ ! -z "$text2" ]; then
        case "$align2" in
            "left")
                prefix_length=0
                ;;
            "center")
                prefix_length=$(( (cols - text2_length) / 2 ))
                ;;
            "right")
                prefix_length=$(( cols - text2_length ))
                ;;
            *)
                echo "Invalid second line alignment specified"
                return 1
                ;;
        esac

        echo -ne "${white}"
        printf '%*s' "${prefix_length}" | tr ' ' ' '
        echo -ne "${text2}${default}"
        echo
    fi

    # Restore the cursor to its original position
    restore_cursor_position
}
