#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

# end_time: Calculates the time elapsed from a given start time to the current time.
# The function expects one parameter: the start time in the 'seconds.milliseconds' format.
# The elapsed time is calculated in hours, minutes, and seconds, and then formatted as a string.
# The function stores the formatted elapsed time string in the variable 'elapsed_time_formatted'.
#
# Usage:
#     end_time Start_Time
# Where:
#     "Start_Time" is the start time in 'seconds.milliseconds' format.
#
# Example:
#     ra_start_time=$(date +%s.%3N)
#     end_time "${ra_start_time}"
#     echo $elapsed_time_formatted  # Output will be in HH MM SS.mmm format
#
declare -A issues       # Associative array to hold current issues
declare -A last_issues  # Associative array to hold last known issues
declare -A prev_total prev_idle
declare had_issues_last_run=false

# Function to color code CPU Usage
function check_cpu_usage() {
    # Get CPU usage and extract integer part
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    cpu_usage_integer=${cpu_usage%.*}

    # Determine the color based on the CPU usage
    if [ "${cpu_usage_integer}" -gt 80 ]; then
    color="${light_red}"
    elif [ "${cpu_usage_integer}" -gt 50 ]; then
    color="${yellow}"
    else
    color="${light_green}"
    fi

    # Right-align the CPU value in a 9-character field, colored accordingly
    printf "\r${white}CPU Usage: ${color}%9.2f%%${default}" "$cpu_usage"
    
    # Create a simple ASCII bar graph for used CPU
    bar=""
    for (( i=0; i<cpu_usage_integer+1; i+=10 )); do
        # Determine the color based on the CPU usage
        if [ "${cpu_usage_integer}" -gt 80 ]; then
            bar+="${light_red}|${default}"
        elif [ "${cpu_usage_integer}" -gt 50 ]; then
            bar+="${yellow}|${default}"
        else
            bar+="${light_green}|${default}"
        fi
    done
    
    # Create a simple ASCII bar graph for remaining CPU
    for (( i=cpu_usage_integer; i<100; i+=10 )); do
        bar+="${dark_gray}|${default}"
    done

    # Display the CPU usage and bar graph
    if [ $cpu_usage_integer -gt 80 ]; then
        echo -ne " ${light_red}$bar${default}"
    else
        echo -ne " ${light_green}$bar${default}"
    fi
}

function check_memory_usage() {
  total_memory=$(free -m | awk '/Mem:/ { print $2 }')
  used_memory=$(free -m | awk '/Mem:/ { print $3 }')
  memory_percentage=$(( 100 * used_memory / total_memory ))

  if [ $memory_percentage -gt 75 ]; then
    color="${light_red}"
  elif [ $memory_percentage -gt 50 ]; then
    color="${yellow}"
  else
    color="${light_green}"
  fi

  printf "\r${white}Memory Usage: ${color}%6.2f%%${default}" $memory_percentage
  bar=""
  for (( i=0; i<$memory_percentage+1; i+=10 )); do
    if [ "${memory_percentage}" -gt 80 ]; then
        bar+="${light_red}|${default}"
    elif [ "${memory_percentage}" -gt 50 ]; then
        bar+="${yellow}|${default}"
    else
        bar+="${light_green}|${default}"
    fi
  done
  
  for (( i=$memory_percentage; i<100; i+=10 )); do
    bar+="${dark_gray}|${default}"
  done
  
  echo -ne " $bar"
}

function check_disk_usage() {
  disk_usage=$(df -h / | awk '/\// {print $(NF-1)}' | sed 's/%//g')
  if [ $disk_usage -gt 80 ]; then
    color="${light_red}"
  elif [ $disk_usage -gt 60 ]; then
    color="${yellow}"
  else
    color="${light_green}"
  fi

  printf "\r${white}Disk Usage: ${color}%8.2f%%${default}" $disk_usage

  bar=""
  for (( i=0; i<$disk_usage+1; i+=10 )); do
    if [ "${disk_usage}" -gt 80 ]; then
        bar+="${light_red}|${default}"
    elif [ "${disk_usage}" -gt 50 ]; then
        bar+="${yellow}|${default}"
    else
        bar+="${light_green}|${default}"
    fi
  done
  
  for (( i=$disk_usage; i<100; i+=10 )); do
    bar+="${dark_gray}|${default}"
  done
  
  echo -ne " $bar"
}

function local_system_info() {
    # Get the terminal height
    term_height=$(tput lines)

    # Hide the cursor
    echo -ne "\033[?25l"

    # ANSI escape sequences
    ESC="\033"
    cursor_to_start="${ESC}[H"
    cursor_to_third_row="${ESC}[3;1H"  # Move to 3rd row, 1st column
    keep_running=true

    # Initialize screen and place cursor at the beginning
    clear
    echo -ne "${cursor_to_start}"

    header "center" "System Status Report"
    footer "right" "${app_name} v.${app_ver}" "left" "Press 'ESC' to return to the menu"  
    while $keep_running; do
        # Move the cursor to the third row
        echo -ne "${cursor_to_third_row}"
        
        # Store the system checks in variables
        check_cpu_output=$(check_cpu_usage)
        check_memory_output=$(check_memory_usage)
        check_disk_output=$(check_disk_usage)

        # Print all the gathered info in one go
        echo -e "${white}CPU Usage: ${check_cpu_output}\nMemory Usage: ${check_memory_output}\nDisk Usage: ${check_disk_output}${default}"

        # Check for user input
        handle_input "local_menu"
    done
}

# Function to run hardware diagnostics
function hardware_diagnostics() {
    cpu_load=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1)

    # For simulation purposes
    # cpu_load=2.5

    if [ $(awk -v n="$cpu_load" 'BEGIN{ print int(n*10) }') -gt 20 ]; then
        issues["Hardware"]="High CPU load: ${cpu_load}"
    fi
}

# Function to run software diagnostics
function software_diagnostics() {
    failed_services=$(systemctl list-units --state=failed --no-legend)

    # For simulation purposes
    # failed_services=3

    if [ -n "$failed_services" ]; then
        issues["Software"]="Failed services: \n${failed_services}"
    fi
}

# Function to run network diagnostics
function network_diagnostics() {
    if ! ping -c 1 google.com &> /dev/null; then
        issues["Network"]="Unable to reach external network"
    fi
}

# Main function
function local_diagnostics() {
    # Reset the issues array
    declare -A issues=()

    # Hardware Diagnostics
    hardware_diagnostics

    # Software Diagnostics
    software_diagnostics

    # Network Diagnostics
    network_diagnostics

    # Check if any issues were found
    if [ ${#issues[@]} -eq 0 ]; then
        echo "No issues found. Your system is running smoothly."
        # Only log if the last run had issues
        if [ "$had_issues_last_run" = true ]; then
            info "No issues found"
            had_issues_last_run=false
        fi
    else
        had_issues_last_run=true

        # Display and log only the changed issues
        for key in "${!issues[@]}"; do
            if [ "${issues[$key]}" != "${last_issues[$key]}" ]; then
                info "${issues[$key]}"
                echo -e "${issues[$key]}" # Display to screen
            fi
        done

        # Update last_issues to current issues
        last_issues=("${issues[@]}")
    fi
}

# Main function
function local_diagnostics_main() {
    declare -A last_issues # Create an associative array to keep track of last issues
    info "System Diagnostics Started"
    # ANSI escape sequences
    ESC="\033"
    cursor_to_start="${ESC}[H"
    cursor_to_third_row="${ESC}[3;1H"  # Move to 3rd row, 1st column
    keep_running=true

    # Hide the cursor
    echo -ne "\033[?25l"

    clear
    echo -ne "${cursor_to_start}"
    header "center" "System Diagnostics"
    footer "right" "${app_name} v.${app_ver}" "left" "Press 'ESC' to return to the menu"  

    while $keep_running; do
        # Move the cursor to the third row
        echo -ne "${cursor_to_third_row}"
        
        # Perform diagnostics
        local_diagnostics
        
        # Check for user input
        handle_input "local_menu"
    done
}


