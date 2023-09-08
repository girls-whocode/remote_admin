#!/usr/bin/env bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

# Function: assign_colors
# Description: This function assigns color codes to variables based on the value of 
#              the 'color_output' variable. The color codes are ANSI escape sequences 
#              for terminal color formatting.
function assign_colors() {
    # Check the value of 'cmd_color_output' to determine the value of 'color_output'
    if [ "$cmd_color_output" = "false" ]; then
        color_output=false
    elif [ "$cmd_color_output" = "true" ]; then
        color_output=true
    fi

    # Assign color codes to variables based on the value of 'color_output'
    if [ "$color_output" = "true" ]; then
        # Color codes for colored output
        black='\033[0;30m'
        red='\033[0;31m'
        green='\033[0;32m'
        yellow='\033[0;33m'
        blue='\033[0;34m'
        magenta='\033[0;35m'
        cyan='\033[0;36m'
        light_gray='\033[0;37m'
        dark_gray='\033[1;30m'
        light_red='\033[1;31m'
        light_green='\033[1;32m'
        light_yellow='\033[1;33m'
        light_blue='\033[1;34m'
        light_magenta='\033[1;35m'
        light_cyan='\033[1;36m'
        white='\033[1;37m'
        default='\033[0m'
        debug "ANSI Colors loaded"
    else
        # Color codes for non-colored output
        black='\033[0m'
        red='\033[0m'
        green='\033[0m'
        yellow='\033[0m'
        blue='\033[0m'
        magenta='\033[0m'
        cyan='\033[0m'
        light_gray='\033[0m'
        dark_gray='\033[0m'
        light_red='\033[0m'
        light_green='\033[0m'
        light_yellow='\033[0m'
        light_blue='\033[0m'
        light_magenta='\033[0m'
        light_cyan='\033[0m'
        white='\033[0m'
        default='\033[0m'
        debug "ANSI Colors not loaded"
    fi
}