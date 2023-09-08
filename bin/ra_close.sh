#!/usr/bin/env bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

# Function Name: 
#   bye
#
# Description: 
#   This function is responsible for finalizing the script execution 
#   and cleaning up resources.
#
# Steps:
#   1. Calculates and displays the total runtime of the script.
#   2. Logs debugging, informational, and critical events.
#   3. Unsets all the variables used during the script execution.
#   4. Exits the script successfully.
#
# Globals:
#   - ra_start_time: The time the script started, used to calculate runtime.
#   - app_name: The name of the application or script.
#   - elapsed_time_formatted: Formatted string of total runtime.
#   - critical_count, error_count, warn_count, note_count, info_count: Counters 
#     for various types of log events.
#   - assigned_vars: An array of variable names that should be unset.
#
# Returns:
#   None. Exits the script with status 0.
function bye {
    end_time "${ra_start_time}"
    info "${app_name} closing - total run time: ${elapsed_time_formatted}"
    debug "Unsetting used variables"
    notice "---------] ${app_name} closed $(LC_ALL=C date +"%Y-%m-%d %H:%M:%S") ${critical_count} Critical/${error_count} Error/${warn_count} Warning/${note_count} Notice/${info_count} Information Events [---------"

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

    echo -e "${green}Exiting successfully!${default}"
    for vars in "${assigned_vars[@]}"; do
        unset "${vars}"
    done
    exit 0
}