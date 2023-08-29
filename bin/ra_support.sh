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

# Function: pause
# Description: This function allows the script to stop running and wait for the user
#              to press the enter key before continuing.
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

# Function to draw a simple border
function draw_border() {
  printf "\e[47;30m" # Set background to white and text to black
  printf "\e[H" # Move to the top-left corner

  for i in $(seq 1 $(tput lines)); do
    for j in $(seq 1 $(tput cols)); do
      if [ $i -eq 1 ] || [ $i -eq $(tput lines) ] || [ $j -eq 1 ] || [ $j -eq $(tput cols) ]; then
        printf "#"
      else
        printf " "
      fi
    done
    printf "\n"
  done
  printf "\e[0m" # Reset the terminal
}

# Function to display a message in the center of the screen
function show_message() {
  local message=$1
  local lines=$(tput lines)
  local cols=$(tput cols)

  local half_message_length=$((${#message} / 2))
  local middle_line=$((lines / 2))
  local middle_col=$((cols / 2))

  tput cup $middle_line $((middle_col - half_message_length))
  printf "\e[47;30m$message\e[0m"
}

# Function to wrap text by spaces and preserve ANSI colors
function wrap_text() {
  local text="$1"

  # Get the terminal width
  local wrap_at=$(tput cols)

  # Initialize empty wrapped text string and other variables
  local wrapped_text=""
  local line_length=0
  local word_length=0
  local word=""
  local ansi_escape=""
  local in_ansi_escape=false

  # Add a space at the end of the text to catch the last word
  text+=" "

  # Process each character in the input string
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
      # Calculate word length without ANSI escape codes
      word_length=$(echo -e "$word" | sed 's/\x1b\[[0-9;]*m//g' | wc -c)

      if [[ "$char" == " " || "$char" == $'\n' ]]; then
        if (( line_length + word_length > wrap_at )); then
          wrapped_text+="\n"
          line_length=0
        fi

        wrapped_text+="$word"
        line_length=$((line_length + word_length))
        word=""
        word_length=0
      fi
    fi
  done

  # Print the wrapped text
  echo -e "$wrapped_text"
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
        echo -ne "${dark_gray}|${default}"

        # Insert text at specified rows
        case $row in
        1)
            tput cup $row $((middle_col + 2))
            echo -ne "${cyan}User: ${light_green}${username}${default}"
            ;;
        2)
            tput cup $row $((middle_col + 2))
            echo -ne "${cyan}Identity: ${light_green}${identity_file##*/}${default}"
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
            if [[ $hostname != "" ]]; then
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
    printf -v _L %$2s; printf -- "${_L// /$1}";
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

# Get the user from the config file, and ask if it needs to
# change
function get_user {
    # The user is specified in the config file, use it, if not then get current user
    if [[ ${username} == "" ]]; then
        username=${USER}
    fi
    return
}

# Get the identity from the config file, if it is empty, ask
# if they want to use on, else ask if they want to use the
# identity in the config file
function get_identity {
    # The identity is specified in the config file, use it
    echo "Get Identity"
    return
}

# Function to create a header with alignment
function header() {
    cols=$(tput cols)
    text="$2"
    text_length=${#text}
    decorative_length=8  # Length of --][-- characters

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
            echo -ne "--] ${text} [--"
            
            # Prepare the suffix with date
            suffix_length=$((cols - text_length - fixed_date_length - (decorative_length * 2)))
            printf '%*s' "${suffix_length}" | tr ' ' '-'
            echo -ne "--] ${fixed_date} [--"
            echo  # Add a newline at the end
            ;;
        "center")
            padding_length=$(( (cols - text_length - fixed_date_length - (decorative_length * 2)) / 2 ))
            
            # Prepare the prefix with title
            printf '%*s' "${padding_length}" | tr ' ' '-'
            echo -ne "--] ${text} [--"
            
            # Prepare the suffix with date
            suffix_length=$((cols - text_length - fixed_date_length - padding_length - (decorative_length * 2)))
            printf '%*s' "${suffix_length}" | tr ' ' '-'
            echo -ne "--] ${fixed_date} [--"
            echo  # Add a newline at the end
            ;;
        "right")
            # Prepare the prefix with date
            prefix_length=$((cols - text_length - fixed_date_length - (decorative_length * 2)))
            printf '%*s' "${prefix_length}" | tr ' ' '-'
            echo -ne "--] ${fixed_date} [--"
            
            # Prepare the title
            echo -ne "--] ${text} [--"
            echo  # Add a newline at the end
            ;;
        *)
            echo "Invalid alignment specified"
            return 1
            ;;
    esac
}

# Save the current cursor position
function save_cursor_position() {
    echo -ne "\033[s"
}

# Restore the cursor to the previously saved position
function restore_cursor_position() {
    echo -ne "\033[u"
}

# Function to create a footer with alignment
function footer() {
    cols=$(tput cols)
    text1="$2"
    align1="$1"
    text2="$4"
    align2="$3"
    text1_length=${#text1}
    text2_length=${#text2}
    decorative_length=8  # Length of --][-- characters

    # Save the current cursor position
    save_cursor_position

    # Move to the line where the footer starts, taking into account the optional second line
    starting_line=$(( $(tput lines) - 2 - (${text2:+1}) ))
    tput cup $starting_line 0

    case "${align1}" in
        "left")
            echo -ne "${dark_gray}--${white}[ ${light_cyan}${text1}${white} ]${dark_gray}--${default}"
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
            echo -ne "--${white}[ ${light_cyan}${text1}${white} ]${dark_gray}--${default}"
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
            echo -ne "--${white}[ ${light_cyan}${text1}${white} ]${dark_gray}--${default}"
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
