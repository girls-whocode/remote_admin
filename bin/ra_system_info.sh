#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

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

function local_resources() {
    # Get the terminal height and width
    term_height=$(tput lines)
    term_width=$(tput cols)

    # Hide the cursor
    echo -ne "\033[?25l"

    # ANSI escape sequences
    ESC="\033"
    cursor_to_start="${ESC}[H"
    keep_running=true

    # Initialize screen and place cursor at the beginning
    clear
    echo -ne "${cursor_to_start}"

    header "center" "System Status Report"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Press 'ESC' to return to the menu"

    # Initial reading for total bytes in and out
    prev_total_bytes_in=0
    prev_total_bytes_out=0

    while $keep_running; do
        # Initialize screen and place cursor at the beginning
        echo -ne "${cursor_to_start}"
        header "center" "System Status Report"
        footer "right" "${app_logo_color} v.${app_ver}" "left" "Press 'ESC' to return to the menu"

        total_bytes_in=0
        total_bytes_out=0

        # Store the system checks in variables
        check_cpu_output=$(check_cpu_usage)
        check_memory_output=$(check_memory_usage)
        check_disk_output=$(check_disk_usage)

        # Capture network stats
        while read -r line; do
            bytes_in=$(echo "$line" | awk '{print $2}')
            bytes_out=$(echo "$line" | awk '{print $3}')
            total_bytes_in=$((total_bytes_in + bytes_in))
            total_bytes_out=$((total_bytes_out + bytes_out))
        done < <(awk 'NR > 2 {print $1, $2, $10}' /proc/net/dev)

        # Calculate bytes transmitted and received since last sample
        bytes_in_interval=$((total_bytes_in - prev_total_bytes_in))
        bytes_out_interval=$((total_bytes_out - prev_total_bytes_out))

        # Update previous total bytes for the next cycle
        prev_total_bytes_in=$total_bytes_in
        prev_total_bytes_out=$total_bytes_out

        # Convert to human-readable format
        human_bytes_in=$(bytes_to_human $bytes_in_interval)
        human_bytes_out=$(bytes_to_human $bytes_out_interval)

        # Concatenate the gathered information
        complete_info="${white}CPU Usage: ${check_cpu_output}\nMemory Usage: ${check_memory_output}\nDisk Usage: ${check_disk_output}\n\n${white}Network Bytes In: ${light_green}${human_bytes_in}/sec        \n${white}Network Bytes Out: ${light_green}${human_bytes_out}/sec        ${default}"

        # Print all the gathered info in one go
        echo -e "$complete_info"

        # Sleep for 1 second before the next cycle
        sleep 1

        # Check for user input
        handle_input "local_menu"
    done
}

function local_system_info() {
    info "Local System Information Started"

    # Get the terminal height and width
    term_height=$(tput lines)
    term_width=$(tput cols)-2

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
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Press 'ESC' to return to the menu"

    while $keep_running; do
        # Move the cursor to the third row
        echo -ne "${cursor_to_third_row}"

        # Fetching system information
        if command -v lsb_release &>/dev/null; then
            os_name=$(lsb_release -d | awk -F ':' '{print $2}' | xargs)
        elif [ -f /etc/redhat-release ]; then
            os_name=$(cat /etc/redhat-release)
        elif [ -f /etc/os-release ]; then
            os_name=$(grep '^PRETTY_NAME' /etc/os-release | cut -d '=' -f 2 | sed 's/"//g')
        else
            os_name="Unknown"
        fi
        kernel_version=$(uname -r)
        si_hostname=$(hostname)
        ip_address=$(hostname -I | awk '{print $1}')
        uptime=$(uptime -p)
        total_cpus=$(lscpu | grep '^CPU(s):' | awk '{print $2}')
        cpu_model=$(lscpu | grep 'Model name:' | awk -F ':' '{print $2}' | sed -r 's/(Intel|AMD|Ryzen|Core|CPU)//g' | awk -F '@' '{print $1}' | xargs)
        load_avg=$(uptime | awk -F 'load average:' '{print $2}' | xargs)
        total_mem=$(free -m | grep Mem | awk '{print $2}')
        used_mem=$(free -m | grep Mem | awk '{print $3}')
        disk_space=$(df -h --total | grep 'total' | awk '{print $2}')
        used_disk_space=$(df -h --total | grep 'total' | awk '{print $3}')
        num_active_network_cards=$(ip link | grep 'state UP' -c)
        open_tcp_ports=$(ss -tuln | grep 'LISTEN' | wc -l)

        # Column width calculation based on terminal width
        col_width=$((term_width / 3))

        # Function to print the column data
        print_columns() {
            local col1=$1
            local col2=$2
            local col3=$3

            col1_len=$(strip_ansi "$col1" | wc -c)
            col2_len=$(strip_ansi "$col2" | wc -c)
            col3_len=$(strip_ansi "$col3" | wc -c)
            max_col_width=$(($col1_len > $col2_len ? $col1_len : $col2_len))
            max_col_width=$(($max_col_width > $col3_len ? $max_col_width : $col3_len))

            printf "%-${max_col_width}b %-${max_col_width}b %-${max_col_width}b\n" "$col1" "$col2" "$col3"
        }

        # Create colored text for each column and print
        print_columns "${white}Hostname:${default} ${light_green}$si_hostname${default}"
        print_columns "${white}IP Address:${default} ${light_green}$ip_address${default}" 
        print_columns "${white}Uptime:${default} ${light_green}$uptime${default}"
        line 100 "-"
        print_columns "${white}OS Name:${default} ${light_green}$os_name${default}" "${white}Kernel Version:${default} ${light_green}$kernel_version${default}"
        print_columns "${white}CPU:${default} ${light_green}$total_cpus${default} cores ${light_green}$cpu_model${default}" "${white}Load Average:${default} ${light_green}$load_avg${default}"
        print_columns "${white}Disk Space:${default} ${light_green}$disk_space${default} (Used: $used_disk_space)" "${white}Total Memory:${default} ${light_green}${total_mem}MB${default} (Used: ${used_mem}MB)"
        line 100 "-"
        print_columns "${white}Active Network Cards:${default} ${light_green}$num_active_network_cards${default}" "${white}Open TCP Ports:${default} ${light_green}$open_tcp_ports${default}"

        # Check for user input
        handle_input "local_menu"
    done
}

function local_system_info_ver() {
    info "Local System Information Started"

    # Get the terminal height and width
    term_height=$(tput lines)
    term_width=$(tput cols)-2

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
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Press 'ESC' to return to the menu"

    while $keep_running; do
        # Move the cursor to the third row
        echo -ne "${cursor_to_third_row}"

        # Fetching system information
        os_name=$(lsb_release -d | awk -F ':' '{print $2}' | xargs)
        kernel_version=$(uname -r)
        hostname=$(hostname)
        ip_address=$(hostname -I | awk '{print $1}')
        uptime=$(uptime -p)
        total_cpus=$(lscpu | grep '^CPU(s):' | awk '{print $2}')
        cpu_model=$(lscpu | grep 'Model name:' | awk -F ':' '{print $2}' | sed -r 's/(Intel|AMD|Ryzen|Core|CPU)//g' | awk -F '@' '{print $1}' | xargs)
        load_avg=$(uptime | awk -F 'load average:' '{print $2}' | xargs)
        total_mem=$(free -m | grep Mem | awk '{print $2}')
        used_mem=$(free -m | grep Mem | awk '{print $3}')
        disk_space=$(df -h --total | grep 'total' | awk '{print $2}')
        used_disk_space=$(df -h --total | grep 'total' | awk '{print $3}')
        num_active_network_cards=$(ip link | grep 'state UP' -c)
        open_tcp_ports=$(ss -tuln | grep 'LISTEN' | wc -l)

        # Column width calculation based on terminal width
        col_width=$((term_width / 3))

        # Displaying the information
        printf "%-${col_width}s %-${col_width}s %-${col_width}s\n" "Hostname: $hostname" "IP Address: $ip_address" "Uptime: $uptime"
        printf "%-${col_width}s %-${col_width}s %-${col_width}s\n" "OS Name: $os_name" "Kernel Version: $kernel_version" "Total Memory: ${total_mem}MB (Used: ${used_mem}MB)"
        printf "%-${col_width}s %-${col_width}s %-${col_width}s\n" "CPU: $total_cpus cores $cpu_model" "Load Average: $load_avg" "Disk Space: $disk_space (Used: $used_disk_space)"
        printf "%-${col_width}s %-${col_width}s %-${col_width}s\n" "Active Network Cards: $num_active_network_cards" "Open TCP Ports: $open_tcp_ports" "Reserved for future metrics"

        # Check for user input
        handle_input "local_menu"
    done
}

function local_check_errors() {
    info "Local Check Errors Started"
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
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Press 'ESC' to return to the menu"  

    while $keep_running; do
        # Move the cursor to the third row
        echo -ne "${cursor_to_third_row}"
       
        # Check for user input
        handle_input "local_menu"
    done
}

function local_check_updates() {
    info "Local Check Updates Started"
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
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Press 'ESC' to return to the menu"  

    while $keep_running; do
        # Move the cursor to the third row
        echo -ne "${cursor_to_third_row}"
       
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
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Press 'ESC' to return to the menu"  

    while $keep_running; do
        # Move the cursor to the third row
        echo -ne "${cursor_to_third_row}"
        
        # Perform diagnostics
        local_diagnostics
        
        # Check for user input
        handle_input "local_menu"
    done
}

function get_osver {
    setup_action
    if [ "${hostname}" = "" ]; then
        # More than one host, loop through them
        for hostname in "${host_array[@]}"; do
            if [ ! "${hostname}" = "" ]; then
                # Test if the hostname is accessable
                # do_connection_test
                if [[ $? -eq 0 ]]; then
                    [ ! -d "./reports/systems/$(date +"%Y-%m-%d")/${hostname}" ] && mkdir "./reports/systems/$(date +"%Y-%m-%d")/${hostname}/"
                    do_scp "/etc/os-release" "./reports/systems/$(date +"%Y-%m-%d")/${hostname}/${hostname}-os-version-$(date +"%Y-%m-%d").txt"
                    ((host_counter++))
                else
                    hosts_no_connect+=("${hosts_no_connect[@]}")
                    ((counter++))
                fi
            fi
        done
    else
        # do_connection_test
        if [[ $? -eq 0 ]]; then      
            clear
            [ ! -d "./reports/systems/$(date +"%Y-%m-%d")/${hostname}" ] && mkdir -p "./reports/systems/$(date +"%Y-%m-%d")/${hostname}/"
            do_scp "/etc/os-release" "./reports/systems/$(date +"%Y-%m-%d")/${hostname}/${hostname}-os-version-$(date +"%Y-%m-%d").txt"
        else
            hosts_no_connect+=("${hosts_no_connect[@]}")
            ((counter++))
        fi
    fi
    echo -e "All OS Version information is stored in ./reports/systems/{HOSTNAME}"
    finish_action
}

