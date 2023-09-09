#!/usr/bin/env bash
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
        keep_running=false
        system_info=false

        eval "${1}"
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

# Function Name:
#   wrap_text
#
# Description:
#   This function wraps a given text at the terminal's column width.
#   It also handles ANSI escape sequences to ensure that text formatting
#   (like colors) is retained after the wrap.
#
# Steps:
#   1. Accept the text to be wrapped as a local variable.
#   2. Get the terminal column width using `tput`.
#   3. Initialize local variables for line length, word, and ANSI escape sequences.
#   4. Loop through each character in the text.
#       a. Detect ANSI escape sequences and handle them separately.
#       b. Add characters to the current word, keeping track of its length.
#       c. Wrap text at terminal column width, respecting word boundaries.
#   5. Output the wrapped text.
#
# Globals Modified:
#   - None
#
# Globals Read:
#   - Reads terminal column width using `tput`.
#
# Parameters:
#   - The text to be wrapped (passed as the first positional parameter).
#
# Returns:
#   - Outputs the wrapped text to stdout.
#
# Called By:
#   Any part of the script that needs to wrap text to fit terminal dimensions.
#
# Calls:
#   - tput: for getting terminal column width.
#   - echo: for outputting the wrapped text.
#   - strip_ansi: custom function for removing ANSI escape sequences (not shown in the code snippet).
#   - wc: for counting the number of characters in a string.
#
# Example:
#   wrapped_output=$(wrap_text "This is a long text that needs to be wrapped.")
#
function wrap_text() {
    local text="$1"
    local wrap_at=$(( $(tput cols) - 2 ))
    local current_line=""
    local word=""
    local ansi_escape=""
    local in_ansi_escape=false

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
        if [[ "$char" == " " || "$char" == $'\n' ]]; then
        word_stripped=$(strip_ansi "$word")
        line_stripped=$(strip_ansi "$current_line")
        if (( ${#line_stripped} + ${#word_stripped} > wrap_at )); then
            echo -n -e "$current_line\n"
            current_line=""
        fi
        current_line+="$word"
        word=""
        fi
    fi
    done

    # Output the last line if it's not empty
    if [ -n "$current_line" ]; then
    echo -e "$current_line"
    fi
}


# Function Name:
#   pad_to_width
#
# Description:
#   Pads the given text with spaces until it reaches a specified width.
#
# Globals Modified:
#   - None
#
# Globals Read:
#   - strip_ansi: Assumed to be a utility function to remove ANSI escape sequences.
#
# Parameters:
#   - text: The text to be padded (string)
#   - width: The final width that the text should be padded to (integer)
#
# Returns:
#   - Outputs the padded text to stdout.
#
# Debugging:
#   - Outputs debug logs with details like text width, length, and the number of spaces added.
#
# Example:
#   pad_to_width "Hello" 10
#
function pad_to_width() {
    local text="$1"
    local width="$2"
    local stripped_text=$(strip_ansi "$text")
    local stripped_length=${#stripped_text}
    local num_spaces=$((width - stripped_length))
    printf "%b" "$text"
    printf "%${num_spaces}s" " "
    debug "Padded text: $text - Width: $width - Length: $stripped_length - Spaces: $num_spaces"
}

# Function Name:
#   add_commas
#
# Description:
#   Adds commas to a numerical string for easier readability.
#
# Globals Modified:
#   - None
#
# Parameters:
#   - A numerical string
#
# Returns:
#   - Outputs the numerical string with commas added for every three digits.
#
# Example:
#   add_commas "1000000" => "1,000,000"
#
function add_commas() {
    echo "${1}" | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta'
}

# Function Name:
#   draw_bar
#
# Description:
#   Draws a progress bar based on a given value and max value.
#
# Globals Modified:
#   - None
#
# Parameters:
#   - value: Current value (integer)
#   - max_value: Maximum value (integer)
#   - bar_length: Length of the bar (integer)
#
# Returns:
#   - Outputs a '#' character-based progress bar.
#
# Example:
#   draw_bar 50 100 10 => "#####     "
#
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

# Function Name:
#   draw_center_line_with_info
#
# Description:
#   Draws a vertical line on the terminal screen and adds info text next to it.
#
# Globals Modified:
#   - Various, such as username, identity_file, port, logging, etc.
#
# Globals Read:
#   - Uses tput to fetch terminal dimensions
#
# Parameters:
#   - None
#
# Returns:
#   - Alters the terminal display with lines and information.
#
# Called By:
#   - Likely called by a main UI loop or event loop.
#
# Example:
#   draw_center_line_with_info
#
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
        tput cup "$row" $middle_col

        # Print the '|' character
        echo -ne "${dark_gray}│${default}"

        # Insert text at specified rows
        case $row in
        1)
            tput cup "${row}" $((middle_col + 2))
            echo -ne "${cyan}User: ${light_green}${username}${default}"
            ;;
        2)
            tput cup "${row}" $((middle_col + 2))
            echo -ne "${cyan}Identity: ${light_green}${identity_file}${default}"
            ;;
        3)
            tput cup "${row}" $((middle_col + 2))
            echo -ne "${cyan}SSH Port: ${light_green}${port}${default}"
            ;;
        4)
            tput cup "${row}" $((middle_col + 2))
            echo ""
            ;;
        5)
            tput cup "${row}" $((middle_col + 2))
            echo ""
            ;;
        6)
            tput cup "${row}" $((middle_col + 2))
            if [[ ${hostname} != "" ]]; then
                if [[ ${#host_array[*]} -gt 1 ]]; then
                    echo -ne "${cyan}Selected Hosts: ${light_green}${#host_array[*]}${default}"
                else
                    echo -ne "${cyan}Hostname: ${light_green}${hostname}${default}"
                fi
            fi
            ;;
        7)
            tput cup "${row}" $((middle_col + 2))
            if [[ ${hostname} != "" ]]; then
                if [[ ${#host_array[*]} -gt 1 ]]; then
                    echo -ne "${cyan}Selected Hosts: ${light_green}${#host_array[*]}${default}"
                else
                    ip_display=${host_to_ip["$hostname"]}
                    host_ip=${ip_display}
                    if [[ -n $ip_display ]]; then
                        echo -ne "${cyan}IP: ${light_green}${ip_display}${default}"
                    fi
                fi
            fi
            ;;
        8)
            tput cup "${row}" $((middle_col + 2))
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
        9)
            tput cup "${row}" $((middle_col + 2))
            echo ""
            ;;
        10)
            tput cup "${row}" $((middle_col + 2))
            if [[ ${system_info} = true ]]; then
                echo -ne "${white}SYSTEM OVERVIEW${default}"
            else
                echo ""
            fi
            ;;
        11)
            tput cup "${row}" $((middle_col + 2))
            echo ""
            ;;
        12)
            tput cup "${row}" $((middle_col + 2))
            if [[ ${system_info} = true ]]; then
                cpu_status="${light_green}Normal${default}"
                cpu_load=$(get_cpu_load | awk '{print int($1+0.5)}')  # Round to nearest integer

                if (( cpu_load > 80 )); then
                    cpu_status="${light_red}High${default}"
                elif (( cpu_load > 40 )); then
                    cpu_status="${yellow}Moderate${default}"
                fi

                echo -ne "${cyan}CPU Status: ${cpu_status}"
            else
                echo ""
            fi
            ;;
        13)
            tput cup "${row}" $((middle_col + 2))
            if [[ ${system_info} = true ]]; then
                memory_status="${light_green}Normal${default}"
                memory_usage=$(get_memory_usage | awk '{print int($1+0.5)}')  # Round to nearest integer
                if (( memory_usage > 80 )); then
                    memory_status="${light_red}High${default}"
                elif (( memory_usage > 40 )); then
                    memory_status="${yellow}Moderate${default}"
                fi

                echo -ne "${cyan}Memory Status: ${memory_status}"
            else
                echo ""
            fi
            ;;
        14)
            tput cup "${row}" $((middle_col + 2))
            if [[ ${system_info} = true ]]; then
                disk_usage=$(get_disk_usage)
                disk_status="${light_green}Normal${default}"
                if (( $disk_usage > 80 )); then
                    disk_status="${light_red}High${default}"
                elif (( $disk_usage > 40 )); then
                    disk_status="${yellow}Moderate${default}"
                fi

                echo -ne "${cyan}Disk Status: ${disk_status}"
            else
                echo ""
            fi
            ;;
        15)
            tput cup "${row}" $((middle_col + 2))
            if [[ ${system_info} = true ]]; then
                swap_status="${light_green}Normal${default}"
                swap_activity=$(get_swap_activity | awk '{print int($1+0.5)}')  # Round to nearest integer
                if (( swap_activity > 80 )); then
                    swap_status="${light_red}High${default}"
                elif (( swap_activity > 40 )); then
                    swap_status="${yellow}Moderate${default}"
                fi

                echo -ne "${cyan}Swap Status: ${swap_status}"
            else
                echo ""
            fi
            ;;
        16)
            tput cup "${row}" $((middle_col + 2))
            if [[ ${system_info} = true ]]; then
                total_processes=$(get_total_processes)
                process_status="${light_green}Normal${default}"
                if (( $total_processes > 1000 )); then
                    process_status="${light_red}High${default}"
                elif (( $total_processes > 500 )); then
                    process_status="${yellow}Moderate${default}"
                fi

                echo -e "${cyan}Process Status: ${process_status}"
            else
                echo ""
            fi
            ;;
        17)
            tput cup "${row}" $((middle_col + 2))
            if [[ ${system_info} = true ]]; then
                echo -ne "${cyan}Total Processes: ${white}$(add_commas "${total_processes}")${default}"
            else
                echo ""
            fi
            ;;
        18)
            tput cup "${row}" $((middle_col + 2))
            if [[ ${system_info} = true ]]; then
                firewall_status_indicator="${light_red}Disabled${default}"
                firewall_status=$(get_firewall_status)
                if [[ "$firewall_status" == "active" ]]; then
                    firewall_status_indicator="${light_green}Enabled${default}"
                fi

                echo -ne "${cyan}Firewall Status: ${firewall_status_indicator}"
            else
                echo ""
            fi
            ;;
        19)
            tput cup "${row}" $((middle_col + 2))
            if [[ ${system_info} = true ]]; then
                pending_updates_status="${light_green}Compliant${default}"
                pending_updates=$(get_pending_updates)
                if (( $pending_updates > 2 )); then
                    pending_updates_status="${light_red}High${default}"
                elif (( $pending_updates > 1 )); then
                    pending_updates_status="${yellow}Moderate${default}"
                fi

                echo -ne "${cyan}Update Status: ${pending_updates_status}"
            else
                echo ""
            fi
            ;;
        20)
            tput cup "${row}" $((middle_col + 2))
            if [[ ${system_info} = true ]]; then
                raid_status="${light_green}Healthy${default}"
                raid_health=$(get_raid_health)
                if [[ "$raid_health" == "N/A" ]]; then
                    raid_status="${light_green}No RAID found${default}"
                elif [[ "$raid_health" != "clean" ]]; then
                    raid_status="${light_red}Degraded${default}"
                fi

                echo -ne "${cyan}RAID Status: ${raid_status}"
            else
                echo ""
            fi
            ;;
        21)
            tput cup "${row}" $((middle_col + 2))
            if [[ ${system_info} = true ]]; then
                service_status="${light_green}Active${default}"
                service_health=$(get_service_health)
                if [[ "$service_health" != "active" ]]; then
                    service_status="${light_red}Inactive${default}"
                fi

                echo -ne "${cyan}Service Status: ${service_status}"
            else
                echo ""
            fi
            ;;
        22)
            tput cup $((height - 9)) $((middle_col + 2))
            if [[ ${environment} = "development" ]]; then
                echo -ne "${dark_gray}Environment: ${white}${environment}"
            fi
            ;;
        23)
            tput cup $((height - 8)) $((middle_col + 2))
            if [[ ${environment} = "development" ]]; then
                echo -ne "${dark_gray}Release: ${white}${release}"
            fi
            ;;
        24)
            tput cup $((height - 7)) $((middle_col + 2))
            if [[ ${environment} = "development" ]]; then
                echo -ne "${dark_gray}Screen (WxH): ${width}x${height}${default}"
            fi
            ;;
        25)
            tput cup $((height - 6)) $((middle_col + 2))
            if [[ ${environment} = "development" ]]; then
                echo -ne "${dark_gray}$(find "${ra_script_location}" -type f -name "*.sh" -exec cat {} + | wc -l) lines of code"
            fi
            ;;
        26)
            tput cup $((height - 5)) $((middle_col + 2))
            if [[ ${environment} = "development" ]]; then
                echo -ne "${light_yellow}[N]: ${dark_gray}${note_count} - ${yellow}[W]: ${dark_gray}${warn_count} - ${light_red}[E]: ${dark_gray}${error_count}${default}"
            fi
            ;;
        27)
            tput cup $((height - 4)) $((middle_col + 2))
            if [[ ${environment} = "development" ]]; then
                echo -ne "${dark_gray}Logging Level: ${white}${logging}${default}"
            fi
            ;;
        esac
    done
    tput rc
}

# Function Name:
#   enter_username
#
# Description:
#   This function prompts the user to enter a username and offers an option to save it.
#
# Steps:
#   1. Prompt the user to enter a username.
#   2. Save the input to the `username` variable.
#   3. Ask the user if they want to save the username to the configuration file.
#   4. If the user wants to save, call `save_config`.
#
# Globals Modified:
#   - `username`
#   - Calls `save_config` which likely modifies a config file.
#
# Globals Read:
#   - None
#
# Parameters:
#   - None
#
# Returns:
#   - None, but may update global `username` and a config file.
#
# Called By:
#   Various parts of the script that require user input for username.
#
# Calls:
#   - save_config
#
# Example:
#   enter_username
#
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

# Function Name:
#   enter_identityfile
#
# Description:
#   Prompts the user to input the path and name for an identity file, offers an option to save it.
#
# Steps:
#   1. Prompt the user for the path of the identity file.
#   2. Validate if the identity file exists.
#   3. If the file exists, offer to save it in the configuration.
#
# Globals Modified:
#   - `identity_file`
#
# Globals Read:
#   - `old_identity`
#
# Parameters:
#   - None
#
# Returns:
#   - None, but may update `identity_file` and the configuration file.
#
# Called By:
#   Various parts of the script that require identity file input.
#
# Calls:
#   - save_config
#
# Example:
#   enter_identityfile
#
function enter_identityfile() {
    # User chose the "Type in Hostname" option
    old_identity=${identity_file}
    read -p "Enter the identity file path and name: " custom_option
    identity_file="$custom_option"
    if [ -f "${identity_file}" ]; then
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

# Function Name:
#   line
#
# Description:
#   Prints a line of specified length and character to the terminal.
#
# Steps:
#   1. Calculate terminal width.
#   2. Calculate line length based on the specified percentage.
#   3. Print the line.
#
# Globals Modified:
#   - None
#
# Globals Read:
#   - None
#
# Parameters:
#   - percentage (e.g., 50 for 50% of the terminal width)
#   - char (character to fill the line with)
#
# Returns:
#   - Outputs the line to stdout.
#
# Called By:
#   Various parts of the script that require a visual line.
#
# Calls:
#   - tput: to get terminal width.
#
# Example:
#   line 50 "-"
#
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

# Function Name:
#   save_tmp
#
# Description:
#   Saves a string to a temporary file and sets its permissions.
#
# Steps:
#   1. Write the input string to a temporary file.
#   2. Set permissions of the temporary file to 600.
#
# Globals Modified:
#   - `tmpfile`
#
# Globals Read:
#   - None
#
# Parameters:
#   - The string to be saved in `tmpfile`.
#
# Returns:
#   - None, but a temporary file is created or updated.
#
# Called By:
#   Any part of the script that requires creating or modifying a temporary file.
#
# Calls:
#   - chmod: to set file permissions.
#
# Example:
#   save_tmp "example_content"
#
function save_tmp(){
    echo "$1" > "$tmpfile"
    chmod 600 "$tmpfile"
    debug "$tmpfile Temporary file created"
} 

# Function Name:
#   new_list
#
# Description:
#   Filters items from `fullist` based on `selected_list` and a global filter condition, saving the filtered items into `list`.
#
# Steps:
#   1. Initialize local list and match variables.
#   2. Iterate over `selected_list` and `fullist` to filter items.
#   3. Save filtered items to `list`.
#
# Globals Modified:
#   - `list`
#
# Globals Read:
#   - `selected_list`
#   - `fullist`
#   - `filter`
#
# Parameters:
#   - None
#
# Returns:
#   - None, but may update `list` and a temporary file if needed.
#
# Called By:
#   Any part of the script that requires filtering from a list of items.
#
# Calls:
#   - save_tmp: for saving filter criteria to a temporary file.
#
# Example:
#   new_list
#
function new_list() {
    list=(); match=
    for item in "${selected_list[@]}" "${fullist[@]}"; do
        case "$item:$match" in
            *"{\\ }"*:1) break  ;;
            *"{\\ $filter\\ }"*) match=1;;
        esac
        [[ $match ]] && list+=( "$item" )
    done
    [[ $filter =~ Selected ]] && return
    [[ ${list[*]} ]] && save_tmp "filter='$filter'" || { list=( "${fullist[@]}" ); rm "$tmpfile"; }
}

# Function Name:
#   strip_ansi
#
# Description:
#   Removes ANSI escape sequences from a given text string.
#
# Parameters:
#   - text: String that may contain ANSI escape sequences.
#
# Returns:
#   - The text string without ANSI escape sequences.
#
# Called By:
#   Any function that requires text without ANSI codes for correct functionality.
#
# Example:
#   strip_ansi "\033[1;32mHello World\033[0m"
#
function strip_ansi() {
    local text="$1"
    echo -e "$text" | sed 's/\x1b\[[0-9;]*m//g'
}

# Function Name:
#   header
#
# Description:
#   Displays a header in the terminal with flexible alignment options for text and date.
#
# Parameters:
#   - Alignment: "left", "center", or "right".
#   - text: Text to be displayed as a title.
#
# Globals Read:
#   - dark_gray, white, light_cyan, light_green, default: ANSI color codes.
#
# Returns:
#   - Outputs the generated header to the terminal.
#
# Called By:
#   Any function that requires a header display in the terminal.
#
# Example:
#   header "left" "My Header"
#
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
            echo -ne "${dark_gray}"
            printf '%*s' "${suffix_length}" | tr ' ' '-'
            echo -ne "${default}"
            echo -ne "${dark_gray}----${white}] ${light_green}${fixed_date} ${white}[${dark_gray}----${default}"
            echo  # Add a newline at the end
            ;;
        "center")
            padding_length=$(( (cols - text_length - fixed_date_length - (decorative_length * 2)) / 2 ))
            
            # Prepare the prefix with title
            echo -ne "${dark_gray}"
            printf '%*s' "${padding_length}" | tr ' ' '-'
            echo -ne "${default}"
            echo -ne "${dark_gray}----${white}] ${light_cyan}${text} ${white}[${dark_gray}----${default}"
            
            # Prepare the suffix with date
            suffix_length=$((cols - text_length - fixed_date_length - padding_length - (decorative_length * 2)))
            echo -ne "${dark_gray}"
            printf '%*s' "${suffix_length}" | tr ' ' '-'
            echo -ne "${default}"
            echo -ne "${dark_gray}----${white}] ${light_green}${fixed_date} ${white}[${dark_gray}----${default}"
            echo  # Add a newline at the end
            ;;
        "right")
            # Prepare the prefix with date
            prefix_length=$((cols - text_length - fixed_date_length - (decorative_length * 2)))
            echo -ne "${dark_gray}"
            printf '%*s' "${prefix_length}" | tr ' ' '-'
            echo -ne "${default}"
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

# Function Name:
#   save_cursor_position
#
# Description:
#   Saves the current cursor position in the terminal.
#
# Parameters:
#   - None
#
# Returns:
#   - None
#
# Called By:
#   Any function that requires the cursor position to be restored later.
#
# Example:
#   save_cursor_position
#
function save_cursor_position() {
    echo -ne "\033[s"
}

# Function Name:
#   restore_cursor_position
#
# Description:
#   Restores the cursor to a previously saved position.
#
# Parameters:
#   - None
#
# Returns:
#   - None
#
# Called By:
#   Any function that has previously saved the cursor position and needs to restore it.
#
# Example:
#   restore_cursor_position
#
function restore_cursor_position() {
    echo -ne "\033[u"
}

# Function Name:
#   footer
#
# Description:
#   Displays a footer in the terminal with alignment options.
#
# Parameters:
#   - align1: Alignment for the first line ("left", "center", or "right").
#   - text1: Text for the first line of the footer.
#   - align2: Optional alignment for the second line.
#   - text2: Optional text for the second line of the footer.
#
# Globals Read:
#   - dark_gray, white, light_cyan, default: ANSI color codes.
#
# Returns:
#   - Outputs the generated footer to the terminal.
#
# Called By:
#   Any function that requires a footer display in the terminal.
#
# Example:
#   footer "left" "My Footer" "right" "Page 1"
#
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
    if [ -z "$text2" ]; then
        starting_line=$(( $(tput lines) - 2 ))
    else
        starting_line=$(( $(tput lines) - 2 - 1 ))
    fi

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
