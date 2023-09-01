#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files
# shellcheck disable=SC2155  # variables may be declared and assigned together

# Function Name:
#   end_time
#
# Description:
#   This function calculates the elapsed time between a provided start time and the current time.
#   Both the start time and end time are in the format of seconds and milliseconds since the Unix epoch.
#   The function takes into account edge cases like millisecond rollovers.
#
# Steps:
#   1. Retrieve the current time in seconds and milliseconds since the Unix epoch.
#   2. Extract the start time in seconds and milliseconds passed as an argument.
#   3. Typecast the variables to ensure they are treated as base-10 integers.
#   4. Calculate the elapsed time in seconds and milliseconds.
#   5. Handle the edge case where elapsed milliseconds go negative due to rollover.
#   6. Calculate the elapsed time in hours, minutes, and seconds.
#   7. Build a formatted time string representing the elapsed time.
#
# Globals Modified:
#   - None
#
# Globals Read:
#   - Reads system time via the `date` command.
#
# Parameters:
#   - Takes the start time as a parameter, in the format of seconds.milliseconds since Unix epoch (e.g., 1622524800.123).
#
# Returns:
#   - It doesn't return any value in the function as written, but the calculated elapsed time is stored in the variable `elapsed_time_formatted`.
#
# Called By:
#   Any part of the script that requires calculation of elapsed time between two points.
#
# Calls:
#   - date: to get the current time in seconds and milliseconds.
#   - printf: to format the elapsed time string.
#
# Example:
#   end_time 1622524800.123
#
function end_time() {
    endtime_sec=$(date +%s)
    endtime_millis=$(date +%3N)
    ra_start_time_sec=${1%.*}
    ra_start_time_millis=${1#*.}

    # Explicitly typecasting as integers, although this should not be necessary
    endtime_sec=$((10#$endtime_sec))
    endtime_millis=$((10#$endtime_millis))
    ra_start_time_sec=$((10#$ra_start_time_sec))
    ra_start_time_millis=$((10#$ra_start_time_millis))

    debug "endtime_sec=$endtime_sec, ra_start_time_sec=$ra_start_time_sec"
    debug "endtime_millis=$endtime_millis, ra_start_time_millis=$ra_start_time_millis"

    elapsed_sec=$(( 10#$endtime_sec - 10#$ra_start_time_sec ))
    elapsed_millis=$(( 10#$endtime_millis - 10#$ra_start_time_millis ))

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

# Function Name:
#   pause
#
# Description:
#   This function halts the execution of the script and waits for the user to press the Enter key.
#   It displays a prompt message to inform the user to press Enter to continue.
#
# Steps:
#   1. Display a prompt message "Press Enter to continue..." on the terminal.
#   2. Wait for the user to press the Enter key.
#
# Globals Modified:
#   - None
#
# Globals Read:
#   - None
#
# Parameters:
#   - None
#
# Returns:
#   - None. It resumes the script execution after the user presses Enter.
#
# Called By:
#   Any part of the script that requires user intervention to continue.
#
# Calls:
#   - read: to wait for user input.
#
# Example:
#   pause
#
function pause() {
    read -rp "Press Enter to continue..."
}

# Function Name:
#   handle_input
#
# Description:
#   This function listens for specific key inputs from the user, namely 'q', 'Q', or the 'ESC' key.
#   If one of these keys is pressed, it resets terminal settings to sane values and then runs a specified command.
#
# Steps:
#   1. Initialize the ASCII code for the ESC key.
#   2. Listen for a keypress for 0.75 seconds.
#   3. Compare the keypress to predefined exit keys ('q', 'Q', or 'ESC').
#   4. If an exit key is pressed, reset terminal visibility and behavior.
#   5. Execute the command passed as an argument to the function.
#   6. Set the variable `keep_running` to `false`.
#
# Globals Modified:
#   - Modifies the `keep_running` variable to control script loop behavior.
#
# Globals Read:
#   - None
#
# Parameters:
#   - The command to be executed when an exit key is pressed (passed as the first positional parameter).
#
# Returns:
#   - None. Modifies global variables and runs the passed command.
#
# Called By:
#   Any part of the script that needs to handle user input for quitting or executing a specific command.
#
# Calls:
#   - read: to capture user input.
#   - echo: to modify terminal settings.
#   - stty: to restore terminal settings to default.
#   - eval: to execute the passed command.
#   - printf: to get the ASCII code for the ESC key.
#
# Example:
#   handle_input "exit_script_function"
#
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

# Function Name:
#   show_message
#
# Description:
#   This function displays a message at the center of the terminal screen.
#   It calculates the center based on terminal dimensions and then uses tput to position the cursor.
#   The message is displayed in light red color and is also logged using the `info` function.
#
# Steps:
#   1. Take the message as a local variable.
#   2. Get the terminal dimensions (lines and columns) using tput.
#   3. Calculate the half length of the message string.
#   4. Find the middle line and column of the terminal.
#   5. Position the cursor to the calculated middle position.
#   6. Display the message in light red color.
#   7. Log the message using the `info` function.
#
# Globals Modified:
#   - None
#
# Globals Read:
#   - Reads terminal dimensions using tput.
#
# Parameters:
#   - The message to be displayed (passed as the first positional parameter).
#
# Returns:
#   - None. Outputs the message to the terminal and logs it.
#
# Called By:
#   Any part of the script that needs to display a centralized message on the terminal.
#
# Calls:
#   - tput: for getting terminal dimensions and positioning the cursor.
#   - printf: for displaying the message.
#   - info: for logging the message.
#
# Example:
#   show_message "Operation Completed Successfully"
#
function show_message() {
  local message=$1
  local lines=$(tput lines)
  local cols=$(tput cols)

  local half_message_length=$((${#message} / 2))
  local middle_line=$((lines / 2))
  local middle_col=$((cols / 2))

  tput cup $middle_line $((middle_col - half_message_length))
  printf "%b${message}%b" "${light_red}" "${default}"
  info "${message}"
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
    debug "Padded text: $text - Width: $width - Length: $stripped_length - Spaces: $num_spaces"
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
            tput cup $((height - 7)) $((middle_col + 2))
            echo -ne "${dark_gray}Screen (WxH): ${width}x${height}${default}"
            ;;
        25)
            tput cup $((height - 6)) $((middle_col + 2))
            echo -ne "${dark_gray}$(find ${ra_script_location} -type f -name "*.sh" -exec cat {} + | wc -l) lines of code"
            ;;
        26)
            tput cup $((height - 5)) $((middle_col + 2))
            echo -ne "${light_yellow}[N]: ${dark_gray}${note_count} - ${yellow}[W]: ${dark_gray}${warn_count} - ${light_red}[E]: ${dark_gray}${error_count}${default}"
        esac
    done
    tput rc
}

function enter_username() {
    read -p "Enter the username: " custom_option
    username="$custom_option"
    echo -en "${default}Do you wish to save to the configuration? ${light_blue}(${light_red}y${default}/${light_green}N${light_blue})${default} "
    read save_username
    success "Username was changed to ${username}"
    if [[ ${save_username} == "y" ]]; then
        debug "Username ${username} was written to config file"
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
        success "Identity file was changed from ${old_identity} to ${identity_file}"
        if [[ ${save_identity} == "y" ]]; then
            debug "Identity file ${identity_file} was written to config file"
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
    debug "$tmpfile Temporary file created"
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
        debug "No user was found assigning to Linux user ${username}"
    fi
    debug "User was found assigning to ${username}"
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
