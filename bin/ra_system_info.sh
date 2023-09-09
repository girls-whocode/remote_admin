#!/usr/bin/env bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files
# shellcheck disable=SC2181  # mycmd #? is used for return value of commands
# shellcheck disable=SC2319  # mycmd #? is used for return value of conditions
# shellcheck disable=SC2155  # declare and assign no longer issue in BASH 14+

declare -A issues       # Associative array to hold current issues
declare -A last_issues  # Associative array to hold last known issues
declare -A prev_total prev_idle
declare had_issues_last_run=false

# Function:
#   local_top_processes
# 
# Description:
#   Fetches and formats the top 5 processes on the local machine sorted by CPU usage.
#   The information is displayed directly to the console and includes the Process ID (PID),
#   CPU usage percentage (%CPU), Memory usage percentage (%MEM), and the command that 
#   started the process (CMD).
#
# Parameters:
#   None
#
# Returns:
#   Outputs a formatted string to the console, each row representing one process.
#   The fields include PID, %CPU, %MEM, and CMD.
#
# Dependencies:
#   Requires 'ps', 'awk', and 'head' utilities.
#
# Example:
#   When called, the function might output something like:
#   1234     10.0     2.0      /usr/bin/some_command
#   5678     9.0      3.0      /usr/bin/another_command
#
function local_top_processes() {
    # Fetch and format top 10 processes sorted by %CPU or %Memory
    if [ "${2}" = "" ]; then
        num=10
    else
        num=${2}
    fi

    if [ "${1}" = "memory" ]; then
        ps -eo pid,%cpu,%mem,cmd --sort=-%mem | head -n $((num+1)) | awk -v green="${green}" -v yellow="${yellow}" -v cyan="${cyan}" -v lblue="${light_blue}" -v mag="${light_magenta}" -v reset="${default}" 'NR==1{ printf green "%-8s %-8s %-8s %-30s\n" reset, $1, $2, $3, $4 } NR>1 { split($4, arr, "/"); cmd=arr[length(arr)]; printf cyan "%-8s " lblue "%-8s " mag "%-8s " yellow "%-30s\n" reset, $1, $2, $3, cmd }'
        line 75 " "
    else
        ps -eo pid,%cpu,%mem,cmd --sort=-%cpu | head -n $((num+1)) | awk -v green="${green}" -v yellow="${yellow}" -v cyan="${cyan}" -v lblue="${light_blue}" -v mag="${light_magenta}" -v reset="${default}" 'NR==1{ printf green "%-8s %-8s %-8s %-30s\n" reset, $1, $2, $3, $4 } NR>1 { split($4, arr, "/"); cmd=arr[length(arr)]; printf cyan "%-8s " lblue "%-8s " mag "%-8s " yellow "%-30s\n" reset, $1, $2, $3, cmd }'
        line 75 " "
    fi
}


# Function Name:
#   get_active_cores
#
# Description:
#   This function calculates the number of active CPU cores based on a threshold value.
#   It reads CPU statistics from the /proc/stat file twice, at two different times,
#   to find the change in CPU utilization for each core.
#
# Steps:
#   1. Initialize variables and arrays for holding CPU statistics.
#   2. Read the first set of CPU statistics from /proc/stat.
#   3. Wait for a short time (0.1 seconds).
#   4. Read the second set of CPU statistics from /proc/stat.
#   5. Calculate the change in total time for each CPU core.
#   6. Count the cores with a change in total time greater than the threshold.
#   7. Return the count of active cores.
#
# Globals Modified:
#   - None
#
# Globals Read:
#   - Reads from the /proc/stat file.
#
# Parameters:
#   - None
#
# Returns:
#   - Outputs the number of active cores to stdout.
#
# Called By:
#   Any part of the script that requires information on the number of active CPU cores.
#
# Calls:
#   - /proc/stat: for CPU statistics.
#   - awk: for parsing CPU statistics.
#   - sleep: to pause execution between readings.
#
# Example:
#   active_cores=$(get_active_cores)
#
function get_active_cores() {
    # Initialize count of active cores
    active_cores_count=0
    
    # Your threshold for considering a CPU core active (percentage)
    threshold=5
    
    # Take the first snapshot
    declare -A cpu_stat_t1
    while read -r line; do
        if [[ $line =~ ^cpu([0-9]+)\ .+ ]]; then
            cpu_stat_t1[${BASH_REMATCH[1]}]=$(awk '{print $2+$3+$4+$5+$6+$7+$8}' <<< "$line")
        fi
    done < /proc/stat

    # Wait for 1 second
    sleep .1

    # Take the second snapshot
    declare -A cpu_stat_t2
    while read -r line; do
        if [[ $line =~ ^cpu([0-9]+)\ .+ ]]; then
            cpu_stat_t2[${BASH_REMATCH[1]}]=$(awk '{print $2+$3+$4+$5+$6+$7+$8}' <<< "$line")
        fi
    done < /proc/stat

    # Calculate the usage for each core
    for core in "${!cpu_stat_t1[@]}"; do
        total_t1=${cpu_stat_t1[$core]}
        total_t2=${cpu_stat_t2[$core]}
        
        # Calculate the CPU usage since the last check.
        let "delta_total = total_t2 - total_t1"
        
        # Check if usage is greater than threshold
        if (( delta_total >= threshold )); then
            ((active_cores_count++))
        fi
    done

    echo "${active_cores_count}"
}

function get_cpu_usage_integer() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    cpu_usage_integer=${cpu_usage%.*}
}

function get_memory_usage_integer() {
    # Get memory data in megabytes
    total_memory=$(free -m | awk '/Mem:/ { print $2 }')
    used_memory=$(free -m | awk '/Mem:/ { print $3 }')

    # Calculate usage percentage
    memory_percentage=$(( 100 * used_memory / total_memory ))
}

function get_disk_usage_integer() {
    # Initialize variables for total and used disk space
    total_space=0
    used_space=0
    
    # Loop over each filesystem
    while read -r line; do
        this_total=$(echo "$line" | awk '{print $2}' | sed 's/[A-Za-z]*//g')
        this_used=$(echo "$line" | awk '{print $3}' | sed 's/[A-Za-z]*//g')
        
        # Skip if empty (sometimes happens with sed)
        [ -z "$this_total" ] && continue
        [ -z "$this_used" ] && continue

        # Convert to bytes
        this_total=$(( this_total * 1024 ))
        this_used=$(( this_used * 1024 ))

        total_space=$(( total_space + this_total ))
        used_space=$(( used_space + this_used ))
    done < <(df -P | awk 'NR>1 {print}')

    # Calculate percentage (integer math, may have rounding errors)
    disk_usage=$(( (used_space * 100) / total_space ))
}

function get_total_processes() {
    total_processes=$(ps -e | wc -l)

    # Subtracting 1 to exclude the header line.
    total_processes=$((total_processes - 1))
    # echo "$total_processes"
}

function get_cpu_load() {
    echo $(awk -v a="$(awk '/cpu /{print $2+$4,$2+$4+$5}' /proc/stat; sleep 1)" '/cpu /{split(a,s); print int(100*($2+$4-s[1])/($2+$4+$5-s[2]))}' /proc/stat)
}

function get_memory_usage() {
    echo $(free | grep Mem | awk '{print int($3/$2 * 100.0)}')
}

function get_disk_usage() {
    echo $(df / | grep / | awk '{ print $5}' | sed 's/%//g')
}

function get_total_processes() {
    echo $(ps aux | wc -l)
}

function get_swap_activity() {
    echo $(free | grep Swap | awk '{if ($2 == 0) print 0; else print $3/$2 * 100}')
}

function get_firewall_status() {
    # Check for ufw
    if hash ufw 2>/dev/null; then
        status=$(sudo ufw status | grep -i "active" && echo "${light_green}Enabled ${light_blue}(${white}ufw${light_blue})${default}" || echo "${light_red}Disabled ${light_blue}(${white}ufw${light_blue})${default}")
    # Check for firewalld
    elif hash firewall-cmd 2>/dev/null; then
        status=$(sudo firewall-cmd --state && echo "${light_green}Enabled ${light_blue}(${white}firewalld${light_blue})${default}" || echo "${light_red}Disabled ${light_blue}(${white}firewalld${light_blue})${default}")
    # Check for SuSEfirewall2 (mostly for older SuSE versions)
    elif hash SuSEfirewall2 2>/dev/null; then
        status=$(sudo systemctl is-active SuSEfirewall2 && echo "${light_green}Enabled ${light_blue}(${white}SuSEfirewall2${light_blue})${default}" || echo "${light_red}Disabled ${light_blue}(${white}SuSEfirewall2${light_blue})${default}")
    # Check for iptables as a fallback
    else
        status=$(sudo iptables -L > /dev/null 2>&1 && echo "${light_green}Enabled ${light_blue}(${white}iptables${light_blue})${default}" || echo "${light_red}Disabled ${light_blue}(${white}iptables${light_blue})${default}")
    fi
    echo "$status"
}

function get_pending_updates() {
    # Check for available updates
    if command -v apt &>/dev/null; then
        echo $(apt list --upgradable 2>/dev/null | wc -l)
    elif command -v yum &>/dev/null; then
        echo $(yum check-update --quiet 2>/dev/null | wc -l)
    elif command -v dnf &>/dev/null; then
        echo $(dnf check-update --quiet 2>/dev/null | wc -l)
    elif command -v zypper &>/dev/null; then
        echo $(zypper list-updates | wc -l)
    elif command -v pacman &>/dev/null; then
        echo $(brew outdated | wc -l)
    elif command -v brew &>/dev/null; then
        echo $(brew outdated | wc -l)

    else
        echo "Unknown"
    fi
    
}

function get_raid_health() {
    if [ -e /dev/md0 ]; then
        echo $(sudo mdadm --detail /dev/md0 | grep "State :" | awk '{print $3}')
    else
        echo "N/A"
    fi
}

function get_service_health() {
    echo $(systemctl is-active sshd)
}

# Function:
#   local_check_cpu_usage
#
# Description:
#   Measures the current CPU usage of the local machine and displays it along with a colored ASCII bar graph.
#   The CPU usage is color-coded: red for high usage (>80%), yellow for moderate usage (>50%), and green for low usage.
#   The bar graph extends horizontally, filling with colored bars that represent 10% CPU increments.
#
# Parameters:
#   None
#
# Returns:
#   Outputs a right-aligned string to the console indicating the CPU usage percentage, color-coded based on the level of usage.
#   Additionally, an ASCII bar graph is displayed next to the CPU usage, extending horizontally based on the usage.
#
# Dependencies:
#   Requires 'top', 'grep', 'sed', and 'awk' utilities.
#   Uses global color variables: ${light_red}, ${yellow}, ${light_green}, ${dark_gray}, ${white}, and ${default}.
#
# Example:
#   When CPU usage is high, the function might output something like:
#   CPU Usage:     90.20% |||||||||||||||||||||
#   When CPU usage is low, the function might output something like:
#   CPU Usage:     10.20% |
#
function local_check_cpu_usage() {
    # Get total number of CPU cores
    total_cores=$(grep -c "^processor" /proc/cpuinfo)

    # Get current number of active cores
    active_cores=$(grep "processor" /proc/cpuinfo | awk '{print $3}' | wc -l)

    # Get CPU usage and extract integer part
    get_cpu_usage_integer

    # Determine the color based on the CPU usage
    if [ "${cpu_usage_integer}" -gt 90 ]; then
        color="${light_red}"
    elif [ "${cpu_usage_integer}" -gt 70 ]; then
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
        if [ "${cpu_usage_integer}" -gt 90 ]; then
            bar+="${light_red}|${default}"
        elif [ "${cpu_usage_integer}" -gt 70 ]; then
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
    if [ "${cpu_usage_integer}" -gt 90 ]; then
        echo -ne " ${light_red}$bar${default}"
        cpu_status="${light_red}High${default}"
    elif [ "${cpu_usage_integer}" -gt 70 ]; then
        echo -ne " ${yellow}$bar${default}"
        cpu_status="${yellow}Moderate${default}"
    else
        echo -ne " ${light_green}$bar${default}"
        cpu_status="${light_green}Normal${default}"
    fi

    active_cores=$(get_active_cores)
    
    # Add total cores and active cores after the bar
    printf "${dark_gray} Total Cores:${white}%3d${default} ${dark_gray}Active Cores:${white}%3d${default}" $total_cores $active_cores
}

# Function:
#   local_check_memory_usage
#
# Description:
#   Measures the current memory usage of the local machine and displays it along with a colored ASCII bar graph.
#   The memory usage is color-coded: red for high usage (>75%), yellow for moderate usage (>50%), and green for low usage.
#   The bar graph extends horizontally, filling with colored bars that represent 10% memory increments.
#
# Parameters:
#   None
#
# Returns:
#   Outputs a right-aligned string to the console indicating the memory usage percentage, color-coded based on the level of usage.
#   Additionally, an ASCII bar graph is displayed next to the memory usage, extending horizontally based on the usage.
#
# Dependencies:
#   Requires the 'free' and 'awk' utilities.
#   Uses global color variables: ${light_red}, ${yellow}, ${light_green}, ${dark_gray}, ${white}, and ${default}.
#
# Example:
#   When memory usage is high, the function might output something like:
#   Memory Usage:  90.00% |||||||||||||||||||||
#   When memory usage is low, the function might output something like:
#   Memory Usage:  10.00% |
#
function local_check_memory_usage() {
    get_memory_usage_integer

    # Determine color
    if [ $memory_percentage -gt 90 ]; then
        color="${light_red}"
    elif [ $memory_percentage -gt 70 ]; then
        color="${yellow}"
    else
        color="${light_green}"
    fi

    # Print memory usage percentage
    printf "\r${white}Memory Usage: ${color}%6.2f%%${default}" $memory_percentage

    # Initialize bar string
    bar=""

    # Fill bar according to memory usage
    for (( i=0; i<$memory_percentage+1; i+=10 )); do
        if [ "${memory_percentage}" -gt 90 ]; then
            bar+="${light_red}|${default}"
        elif [ "${memory_percentage}" -gt 70 ]; then
            bar+="${yellow}|${default}"
        else
            bar+="${light_green}|${default}"
        fi
    done

    # Fill the rest of the bar with dark gray
    for (( i=$memory_percentage; i<100; i+=10 )); do
        bar+="${dark_gray}|${default}"
    done

    # Display bar
    echo -ne " $bar"

    # Convert to gigabytes for readability
    total_memory_gb=$(awk "BEGIN { printf \"%.2f\", ${total_memory}/1024 }")
    used_memory_gb=$(awk "BEGIN { printf \"%.2f\", ${used_memory}/1024 }")

    # Add total and used memory after the bar
    printf "${dark_gray} Total Memory:${default} ${total_memory_gb}G  ${dark_gray}Used Memory:${default} ${used_memory_gb}G"
}

# Function:
#   local_check_disk_usage
#
# Description:
#   Measures the current disk usage of the root partition on the local machine and displays it along with a colored ASCII bar graph.
#   The disk usage is color-coded based on thresholds: red for high usage (>80%), yellow for moderate usage (>60%), and green for low usage.
#   The bar graph fills horizontally with colored bars representing 10% disk usage increments.
#
# Parameters:
#   None
#
# Returns:
#   Outputs a right-aligned string to the terminal showing the disk usage percentage, color-coded based on the level of usage.
#   An ASCII bar graph is also displayed next to the disk usage, extending horizontally based on the usage.
#
# Dependencies:
#   Requires the 'df' and 'awk' utilities.
#   Uses global color variables: ${light_red}, ${yellow}, ${light_green}, ${dark_gray}, ${white}, and ${default}.
#
# Example:
#   When disk usage is high, the function might output something like:
#   Disk Usage:  90.00% |||||||||||||||||||||
#   When disk usage is low, the function might output something like:
#   Disk Usage:  10.00% |
#
function local_check_disk_usage() {
    get_disk_usage_integer
    
    # Determine color
    if [ "$disk_usage" -gt 90 ]; then
        color="${light_red}"
        disk_status="${light_red}High${default}"
    elif [ "$disk_usage" -gt 70 ]; then
        color="${yellow}"
        disk_status="${yellow}Moderate${default}"
    else
        color="${light_green}"
        disk_status="${light_green}Normal${default}"
    fi

    printf "\r${white}Overall Disk Usage: ${color}%d%%${default}" "$disk_usage"

    # Bar representation
    bar=""
    for (( i=0; i<=disk_usage; i+=10 )); do
        if [ "$disk_usage" -gt 90 ]; then
            bar+="${light_red}|${default}"
        elif [ "$disk_usage" -gt 70 ]; then
            bar+="${yellow}|${default}"
        else
            bar+="${light_green}|${default}"
        fi
    done

    for (( i=disk_usage; i<100; i+=10 )); do
        bar+="${dark_gray}|${default}"
    done

    human_total_space=$(bytes_to_human "${total_space}")
    human_used_space=$(bytes_to_human "${used_space}")

    echo -ne " $bar${dark_gray} Total Disk Space: ${default}${human_total_space}${dark_gray} Used Disk Space: ${default}${human_used_space}"
}

function local_system_info() {
    info "Local System Information Started"

    # Get the terminal height and width
    term_height=$(tput lines)
    term_width=$(tput cols)-2
    local width=$((term_width * 7 / 10))

    # Calculate the number of processes that can be displayed depending on the terminal height
    if [ "$term_height" -gt 44 ]; then
        num_processes=10
    elif [ "$term_height" -le 44 ] && [ "$term_height" -gt 43 ]; then
        num_processes=9
    elif [ "$term_height" -le 43 ] && [ "$term_height" -gt 40 ]; then
        num_processes=5
    elif [ "$term_height" -le 40 ] && [ "$term_height" -gt 37 ]; then
        num_processes=4
    else
        num_processes=1
    fi

    # ANSI escape sequences
    ESC="\033"
    cursor_to_start="${ESC}[H"
    cursor_to_second_row="${ESC}[2;1H"  # Move to 2nd row, 1st column
    keep_running=true

    # Initial reading for total bytes in and out
    prev_total_bytes_in=0
    prev_total_bytes_out=0

    clear
    echo -ne "${cursor_to_start}"
    header "center" "System Diagnostics"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "${white}Press ${light_blue}[${white}ESC${light_blue}]${white} or ${light_blue}[${white}Q${light_blue}]${white} to exit screen.${default}"
    loading=true
    system_info=true
    draw_center_line_with_info

    # Check for available updates
    if command -v apt &>/dev/null; then
        updates=$(apt list --upgradable 2>/dev/null | wc -l)
    elif command -v yum &>/dev/null; then
        updates=$(yum check-update --quiet | wc -l)
    elif command -v dnf &>/dev/null; then
        updates=$(dnf check-update --quiet | wc -l)
    elif command -v zypper &>/dev/null; then
        updates=$(zypper list-updates | wc -l)
    elif command -v pacman &>/dev/null; then
        updates=$(pacman -Qu | wc -l)
    elif command -v brew &>/dev/null; then
        updates=$(brew outdated | wc -l)
    else
        echo "Unknown"
    fi

    while $keep_running; do
        # Hide the cursor
        echo -ne "\033[?25l"

        # Move the cursor to the third row
        echo -ne "${cursor_to_second_row}"

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

        # Store the system checks in variables
        check_cpu_output=$(local_check_cpu_usage)
        check_memory_output=$(local_check_memory_usage)
        check_disk_output=$(local_check_disk_usage)

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
        cpu_info="${white}CPU Usage: ${check_cpu_output}\nMemory Usage: ${check_memory_output}\n${white}Overall Disk Usage: ${light_green}${check_disk_output}"
        network_activity_info="${white}Network Bytes In: ${light_green}${human_bytes_in}/sec        \n${white}Network Bytes Out: ${light_green}${human_bytes_out}/sec        ${default}"
        total_bytes_in=0
        total_bytes_out=0

        # Create colored text for each column and print
        echo -e "${white}Hostname:${default} ${light_blue}$si_hostname${default} ${white}IP Address:${default} ${light_blue}$ip_address${default} ${white}Network Interfaces:${default} ${light_blue}$num_active_network_cards${default}" "${white}Open TCP Ports:${default} ${light_blue}$open_tcp_ports${default}" 
        echo -e "${cpu_info}"
        echo -e "${dark_gray}$(line 75 "-")${default}"
        echo -e "${white}Uptime:${default} ${light_blue}$uptime${default}"
        echo -e "${white}OS Name:${default} ${light_blue}$os_name${default}" "${white}Kernel Version:${default} ${light_blue}$kernel_version${default}"
        echo -e "${white}CPU:${default} ${light_blue}$total_cpus${default} cores ${light_blue}$cpu_model${default}" "${white}Load Average:${default} ${light_blue}$load_avg${default}"
        echo -e "${white}Updates Available: ${light_blue}${updates}${default}"
        echo -e "${dark_gray}$(line 75 "-")${default}"
        echo -e "${network_activity_info}"

        # Print top active processes
        echo -e "${dark_gray}$(line 75 "-")${default}"
        echo -e "${white}Top Processes (by CPU):${default}"
        echo -e "$(local_top_processes "cpu" ${num_processes} | fold -w $width -s)"
        echo -e "${dark_gray}$(line 75 "-")${default}"
        echo -e "${white}Top Processes (by Memory):${default}"
        echo -e "$(local_top_processes "memory" ${num_processes} | fold -w $width -s)"

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

        # Check for user input
        handle_input "local_menu"
        loading=false
    done
}

# Function: 
#   local_check_errors
#
# Description:
#   This function is a real-time diagnostic tool that reports various types of system errors.
#   It lists issues related to disk space, out-of-memory problems, failed SSH attempts, zombie processes,
#   and processes that are high in CPU and memory usage.
#
# Parameters:
#   None
#
# Returns:
#   None; The function prints all the acquired information directly to the terminal.
#
# Dependencies:
#   - Utilizes various system commands: `df`, `dmesg`, `grep`, `ps`, `awk`, `wc`
#   - Calls the following local functions: `info`, `header`, `footer`
#
# Interactivity:
#   - The function keeps running until the user presses the 'ESC' key.
#     Listens for user input through the `handle_input` function.
#
# Example:
#   Provides a terminal-based dashboard for monitoring system error metrics in real-time.
#
function local_check_errors() {
    local sudo_granted=$1  # $1 argument is true or false representing sudo access status
    info "Local Check Errors Started"

    # Screen dimensions
    local total_width=$(tput cols)
    local total_height=$(tput lines)
    local width=$((total_width * 7 / 10))
    local max_height=$((total_height - 6))

    # Determine Linux distribution
    local distro=$(awk -F= '/^ID=/{print $2}' /etc/*-release | tr -d '"')

    # Hide the cursor
    echo -ne "\033[?25l"

    # ANSI escape sequences
    ESC="\033"
    cursor_to_start="${ESC}[H"
    keep_running=true

    # Initialize screen
    clear
    tput cup 0 0  # Move cursor to top left

    local current_line=2  # Start at line 2 (0-based)

    while $keep_running; do
        # Print header and footer
        echo -ne "${cursor_to_start}"
        header "center" "System Error Diagnostics"
        footer "right" "${app_logo_color} v.${app_ver}" "left" "${white}Press ${light_blue}[${white}ESC${light_blue}]${white} or ${light_blue}[${white}Q${light_blue}]${white} to exit screen.${default}"
        draw_center_line_with_info

        # Fetching system error-related information
        
        # Perform operations that require sudo here
        if [ "$sudo_granted" == "true" ]; then
            if [ "$distro" == "debian" ] || [ "$distro" == "ubuntu" ]; then
                # Debian/Ubuntu specific logs and metrics
                if [ -e "/var/log/auth.log" ]; then
                    auth_failures=$(sudo grep -i 'authentication failure' /var/log/auth.log | wc -l)
                elif [ -e "/var/log/syslog" ]; then
                    auth_failures=$(sudo grep -i 'authentication failure' /var/log/syslog | wc -l)
                else
                    auth_failures=0
                fi
            elif [ "$distro" == "rhel" ] || [ "$distro" == "centos" ] || [ "$distro" == "fedora" ]; then
                failed_auth=$(sudo grep -i 'failed' /var/log/auth.log | wc -l)
            fi

            # Common metrics requiring sudo
            disk_space_critical=$(sudo df -h | awk '($5 ~ /[0-9]+%/) && int($5) >= 90 {print $6 " " $5}')
            oom_issues=$(sudo dmesg | grep -i 'Out of memory' | wc -l)
            zombie_processes=$(sudo ps aux | awk '$8=="Z" {print $0}' | wc -l)
            critical_journal=$(sudo journalctl -p 0..2 | grep -v ' -- ' | wc -l)
            critical_journal_list=$(sudo journalctl -p 0..2 -n 5 --output=short-iso | logview | fold -w $width -s)
            failed_services=$(sudo systemctl list-units --state=failed --no-legend | wc -l)
            failed_services_list=$(sudo systemctl list-units --state=failed --no-legend)

        else
            disk_space_critical=$(df -h | awk '($5 ~ /[0-9]+%/) && int($5) >= 90 {print $6 " " $5}')
            failed_ssh=$(grep -i 'Permission denied' ~/.bash_history | wc -l)
            zombie_processes=$(ps aux | awk '$8=="Z" {print $0}' | wc -l)
        fi

        # Print gathered information
        echo -e "${white}Failed Auth Attempts: ${light_blue}${failed_auth}${default}"
        echo -e "${white}Disk Space Critical: ${light_blue}${disk_space_critical}${default} ${white}Out Of Memory Issues: ${light_blue}${oom_issues}${default} ${white}Zombie Processes: ${light_blue}${zombie_processes}${default}"
        echo -e "${white}Critical Journal Entries: ${light_blue}${critical_journal}${default} ${white}Failed Services: ${light_blue}${failed_services}${default}"
        echo -e "${dark_gray}$(line 75 "-")${default}"
        echo -e "${white}Critical Journal:\n${default}${critical_journal_list}${default}"
        echo -e "${dark_gray}$(line 75 "-")${default}"
        echo -e "${white}Failed Services:\n${default}${failed_services_list}${default}"
        echo -e "${dark_gray}$(line 75 "-")${default}"
        echo -e "${white}High CPU Processes:\n${default}$(local_top_processes "cpu" 1)${default}"
        echo -e "${dark_gray}$(line 75 "-")${default}"
        echo -e "${white}High Memory Processes:\n${default}$(local_top_processes "memory" 1)${default}"

        # Check for user input
        handle_input "local_menu"
    done
}

# Function: 
#   local_hardware_diagnostics
#
# Description:
#   Monitors CPU load and flags it if it crosses a certain threshold.
#
# Parameters:
#   None
#
# Returns:
#   None; Fills the `issues` associative array with a hardware-related issue if detected.
#
# Dependencies:
#   - Utilizes system command `uptime` and text processing tools `awk` and `cut`.
#
# Interactivity:
#   None
#
# Example:
#   Will populate the `issues` array with a "High CPU load" message if CPU load crosses the threshold.
#
function local_hardware_diagnostics() {
    cpu_load=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1)

    # For simulation purposes
    # cpu_load=2.5

    if [ "$(awk -v n="$cpu_load" 'BEGIN{ print int(n*10) }')" -gt 20 ]; then
        issues["Hardware"]="High CPU load: ${cpu_load}"
    fi
}

# Function:
#   local_software_diagnostics
#
# Description:
#   Checks for any failed systemd services on the machine.
#
# Parameters:
#   None
#
# Returns:
#   None; Fills the `issues` associative array with a software-related issue if detected.
#
# Dependencies:
#   - Utilizes the system command `systemctl`.
#
# Interactivity:
#   None
#
# Example:
#   Will populate the `issues` array with "Failed services" if any systemd services are in a failed state.
#
function local_software_diagnostics() {
    failed_services=$(systemctl list-units --state=failed --no-legend)

    # For simulation purposes
    # failed_services=3

    if [ -n "$failed_services" ]; then
        issues["Software"]="Failed services: \n${failed_services}"
    fi
}

# Function:
#   local_network_diagnostics
#
# Description:
#   Checks for network connectivity by attempting to ping Google.
#
# Parameters:
#   None
#
# Returns:
#   None; Fills the `issues` associative array with a network-related issue if detected.
#
# Dependencies:
#   - Utilizes the system command `ping`.
#
# Interactivity:
#   None
#
# Example:
#   Will populate the `issues` array with "Unable to reach external network" if the Google ping fails.
#
function local_network_diagnostics() {
    if ! ping -c 1 google.com &> /dev/null; then
        issues["Network"]="Unable to reach external network"
    fi
}

# Function:
#   local_diagnostics_run
#
# Description:
#   Wrapper function that runs all the diagnostic functions (hardware, software, network).
#
# Parameters:
#   None
#
# Returns:
#   None; Outputs the results directly to the terminal.
#
# Dependencies:
#   - Calls `local_hardware_diagnostics`, `local_software_diagnostics`, `local_network_diagnostics`.
#
# Interactivity:
#   None
#
# Example:
#   It will print and log the diagnostics result. Will only log if the state changed from the last run.
#
function local_diagnostics_run() {
    # Reset the issues array
    declare -A issues=()

    # Hardware Diagnostics
    local_hardware_diagnostics

    # Software Diagnostics
    local_software_diagnostics

    # Network Diagnostics
    local_network_diagnostics

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

# Function:
#   local_diagnostics_main
#
# Description:
#   The main loop for system diagnostics. It continuously runs diagnostic checks until the user presses 'ESC'.
#
# Parameters:
#   None
#
# Returns:
#   None; Outputs the results directly to the terminal.
#
# Dependencies:
#   - Calls `local_diagnostics_run`, `header`, `footer`, and `handle_input`.
#
# Interactivity:
#   - Keeps running until the user presses the 'ESC' key.
#   - Listens for user input through the `handle_input` function.
#
# Example:
#   Provides a real-time terminal dashboard for system diagnostics.
#
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
    footer "right" "${app_logo_color} v.${app_ver}" "left" "${white}Press ${light_blue}[${white}ESC${light_blue}]${white} or ${light_blue}[${white}Q${light_blue}]${white} to exit screen.${default}"

    BLA::start_loading_animation "${BLA_growing_dots[@]}"
    local_diagnostics_run
    BLA::stop_loading_animation

    while $keep_running; do
        # Move the cursor to the third row
        echo -ne "${cursor_to_third_row}"
        
        # Perform diagnostics
        local_diagnostics_run
        
        # Check for user input
        handle_input "local_menu"
    done
}

# Remote Diagnostics
function remote_diagnostics_main() {
    echo "Need built"
}

function check_remote_cpu_usage() {
    remote_cpu_usage=$(do_ssh "top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print 100 - \$1}'")
    cpu_usage=$remote_cpu_usage  # Replace the local CPU reading with the remote one
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

function check_remote_memory_usage() {
  remote_memory_info=$(do_ssh "free -m")
  total_memory=$(echo "$remote_memory_info" | awk '/Mem:/ { print $2 }')
  used_memory=$(echo "$remote_memory_info" | awk '/Mem:/ { print $3 }')
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
    if [ $memory_percentage -gt 80 ]; then
        bar+="${light_red}|${default}"
    elif [ $memory_percentage -gt 50 ]; then
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

function remote_resources() {
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
    footer "right" "${app_logo_color} v.${app_ver}" "left" "${white}Press ${light_blue}[${white}ESC${light_blue}]${white} or ${light_blue}[${white}Q${light_blue}]${white} to exit screen.${default}"

    # Initial reading for total bytes in and out
    prev_total_bytes_in=0
    prev_total_bytes_out=0

    # Store the system checks in variables
    check_cpu_output=$(check_remote_cpu_usage)
    check_memory_output=$(check_remote_memory_usage)
    check_disk_output=$(local_check_disk_usage)

    while $keep_running; do
        total_bytes_in=0
        total_bytes_out=0

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
        complete_info="${white}CPU Usage: ${check_cpu_output}\nMemory Usage: ${check_memory_output}\n${white}Disk Usage: ${light_green}${check_disk_output}\n\n${white}Network Bytes In: ${light_green}${human_bytes_in}/sec        \n${white}Network Bytes Out: ${light_green}${human_bytes_out}/sec        ${default}"

        # Print all the gathered info in one go
        echo -e "$complete_info"

        # Print top active processes
        line 100 "-"
        echo -e "${white}Top Processes (by CPU):${default}"
        echo -e "$(top_processes)"

        # Check for user input
        handle_input "local_menu"
    done
}