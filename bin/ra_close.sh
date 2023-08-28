#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

# The code defines a function called bye which is used to gracefully exit the script or application. 

# Here's a breakdown of what the code does:
# Calls the end_time function with the value of a variable ra_start_time as an argument. It calculates 
# and records the end time. Prints an informational message indicating that the application is closing 
# and displays the total run time in a formatted manner using the elapsed_time_formatted variable.

# Prints a debug message indicating that used variables are being unset. Defines an array variable 
# assigned_vars containing a list of variable names that need to be unset. Loops through each variable 
# in the assigned_vars array and unsets them using the unset command.

# Prints a message indicating successful exit using green color. Exits the script or application with a 
# status code of 0, indicating successful termination. 

# Overall, this code defines a function that performs cleanup tasks, unsetting variables, and printing 
# messages before exiting the script or application.

# Function: bye
# Description: Close remote-admin and clean up any set variables left behind. Display exit message.
function bye {
    end_time "${ra_start_time}"
    info "${app_name} closing - total run time: ${elapsed_time_formatted}"
    debug "Unsetting used variables"

    assigned_vars=(
        "app_name" "script_name" "app_ver" "config_file" "config_path" "tmpfile" "sshconfig_file" 
        "search_dir" "black" "red" "green" "yellow" "blue" "magenta" "cyan" "light_gray" "dark_gray"
        "light_red" "light_green" "light_yellow" "light_blue" "light_magenta" "light_cyan" "white"
        "default" "config_lines" "cmd_color_output" "color_output" "option_padding" "color_selection" 
        "username_option" "username" "host_options" "host_choice" "last_index" "hostname" "line"
        "host_count" "display_host" "action_options" "counter" "port" "counter" "host_counter" "ESC"
        "key" "lastrow" "startrow" "host_type_choice" "idx" "opt" "LINES" "COLS" "CONFILES" "jetpatch_hc"
        "non_interactive" "ra_script_location" "ra_start_time" "reports_path" "elapsed_time_formatted"
        "server_list_path" "filename" "log_level" "logging" "ra_log_path" "ra_log_file"
    )

    for vars in "${assigned_vars[@]}"; do
        unset "${vars}"
    done

    echo -e "${green}Exiting successfully!${default}"
    exit 0
}