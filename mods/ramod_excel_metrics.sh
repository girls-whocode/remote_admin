#!/bin/bash

function metrics_cpu_usage() {
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    cpu_usage_integer=${cpu_usage%.*}
    echo "$cpu_usage_integer"
}

# Function to collect memory usage metric
function metrics_memory_usage() {
    total_memory=$(free -m | awk '/Mem:/ { print $2 }')
    used_memory=$(free -m | awk '/Mem:/ { print $3 }')
    memory_percentage=$(( 100 * used_memory / total_memory ))
    echo "$memory_percentage"
}

# Function to collect disk usage metric
function metrics_disk_usage() {
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
    echo "$disk_usage"
}

# Function to collect swap usage metric
function metrics_swap_usage() {
    swap_details=$(free -b | grep Swap)
    total_swap=$(echo $swap_details | awk '{print $2}')
    used_swap=$(echo $swap_details | awk '{print $3}')

    if [ $total_swap -eq 0 ]; then
        swap_usage=0
    else
        # Multiply by 100 to convert to integer
        swap_usage=$(( (used_swap * 100) / total_swap ))
    fi

    # Convert the integer percentage back to float for display
    swap_usage_float=$(awk "BEGIN { printf \"%.2f\", $swap_usage/100 }")

    total_swap_human=$(bytes_to_human $total_swap)
    used_swap_human=$(bytes_to_human $used_swap)

    echo "$swap_usage"
}

# Function to collect processes metric
function metrics_processes() {
    total_processes=$(ps aux | wc -l)
    total_processes=$((total_processes - 2))
    echo ${total_processes}
}

function metrics_load() {
    if [[ ${1} == "5" ]]; then
        echo $(uptime | awk '{print $10}' | tr -d ',')
    elif [[ ${1} == "10" ]]; then
        echo $(uptime | awk '{print $11}' | tr -d ',')
    elif [[ ${1} == "15" ]]; then
        echo $(uptime | awk '{print $12}' | tr -d ',')
    fi
}

function metrics_firewall() {
    # Check for ufw
    if hash ufw 2>/dev/null; then
        status=$(sudo ufw status > /dev/null | grep -i "active" && echo "Enabled (ufw)" || echo "Disabled (ufw)")
    # Check for firewalld
    elif hash firewall-cmd 2>/dev/null; then
        status=$(sudo firewall-cmd --state > /dev/null && echo "Enabled (firewalld)" || echo "Disabled (firewalld)")
    # Check for SuSEfirewall2 (mostly for older SuSE versions)
    elif hash SuSEfirewall2 2>/dev/null; then
        status=$(sudo systemctl is-active SuSEfirewall2 > /dev/null && echo "Enabled (SuSEfirewall2)" || echo "Disabled (SuSEfirewall2)")
    # Check for iptables as a fallback
    else
        status=$(sudo iptables -L > /dev/null 2>&1 && echo "Enabled (iptables)" || echo "Disabled (iptables)")
    fi
    echo "$status"
}

function metrics_service_health() {
    echo $(systemctl is-active sshd)
}

function metrics_pending_updates() {
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

function check_nfs_health() {
    local unhealthy_status=false
    
    # Dynamically discover NFS mounts
    local discovered_mounts=$(grep ' nfs ' /proc/mounts | awk '{print $2}')
    
    for mount in $discovered_mounts; do
        # Check if it's really a mountpoint
        if ! mountpoint -q "$mount"; then
            error_mgs="$mount is not mounted."
            unhealthy_status=true
        else
            # Check if it's readable
            if ! [ -r "$mount" ]; then
                error_mgs="$mount is not readable."
                unhealthy_status=true
            fi
            
            # Checking latency to the NFS server
            local server=$(grep "$mount" /proc/mounts | awk -F':' '{ print $1 }')
            if [[ ! -z "$server" ]]; then
                local latency_output=$(ping -c 1 "$server")
                if [[ $? -eq 0 ]]; then
                    local latency=$(echo "$latency_output" | awk -F'/' 'END {print int($5)}')
                    if (( latency > 200 )); then
                        error_mgs="High network latency to NFS server: $latency ms"
                        unhealthy_status=true
                    fi
                else
                    error_mgs="Unable to ping NFS server: $server"
                    unhealthy_status=true
                fi
            fi

        fi
    done

    # Final Health Status
    if $unhealthy_status; then
        echo "${error_mgs}"
        return 1
    else
        echo "NFS Healthy"
        return 0
    fi
}

function local_system_metrics() {
    # Define the CSV file to store the metrics
    metrics_file="./data/system_data.csv"

    if [ ! -d "./data" ]; then
        mkdir ./data
    fi

    # Check if the metrics file exists, if not, create and initialize it with headers
    if [ ! -f "$metrics_file" ]; then
        echo "Date,Time,Uptime,CPU_Status,CPU_Usage(%),Memory_Status,Memory_Usage(%),NFS_Status,Disk_Status,Disk_Usage(%),Swap_Status,Swap_Usage(%),Total_Processes,Load_5m,Load_10m,Load_15m,Firewall_Status,Service_Status,Pending_Updates" > "$metrics_file"
    fi

    # Get the current timestamp
    timestamp_date=$(date +"%Y-%m-%d")
    timestamp_time=$(date +"%H:%M:%S")

    # Fetching system information and store in variables
    uptime=$(uptime -p | tr -d ',')
    check_cpu_usage=$(metrics_cpu_usage)
    check_memory_usage=$(metrics_memory_usage)
    check_disk_usage=$(metrics_disk_usage)
    check_swap_usage=$(metrics_swap_usage)
    check_processes=$(metrics_processes)
    check_5m_load=$(metrics_load 5)
    check_10m_load=$(metrics_load 10)
    check_15m_load=$(metrics_load 15)
    check_filewall=$(metrics_firewall)
    check_service=$(metrics_service_health)
    check_updates=$(metrics_pending_updates)
    check_nfs=$(check_nfs_health)

    if [[ ${check_cpu_usage} -ge 95 ]]; then
        cpu_status="Critical"
    elif [[ ${check_cpu_usage} -ge 80 ]]; then
        cpu_status="High"
    elif [[ ${check_cpu_usage} -ge 70 ]]; then
        cpu_status="Warning"
    elif [[ ${check_cpu_usage} -ge 50 ]]; then
        cpu_status="Notice"
    else
        cpu_status="Normal"
    fi

    if [[ ${check_memory_usage} -ge 95 ]]; then
        mem_status="Critical"
    elif [[ ${check_memory_usage} -ge 80 ]]; then
        mem_status="High"
    elif [[ ${check_memory_usage} -ge 70 ]]; then
        mem_status="Warning"
    elif [[ ${check_memory_usage} -ge 50 ]]; then
        mem_status="Notice"
    else
        mem_status="Normal"
    fi

    if [[ ${check_disk_usage} -ge 95 ]]; then
        disk_status="Critical"
    elif [[ ${check_disk_usage} -ge 80 ]]; then
        disk_status="High"
    elif [[ ${check_disk_usage} -ge 70 ]]; then
        disk_status="Warning"
    elif [[ ${check_disk_usage} -ge 50 ]]; then
        disk_status="Notice"
    else
        disk_status="Normal"
    fi

    if [[ ${check_swap_usage} -ge 95 ]]; then
        swap_status="Critical"
    elif [[ ${check_swap_usage} -ge 80 ]]; then
        swap_status="High"
    elif [[ ${check_swap_usage} -ge 70 ]]; then
        swap_status="Warning"
    elif [[ ${check_swap_usage} -ge 50 ]]; then
        swap_status="Notice"
    else
        swap_status="Normal"
    fi

    # Append metrics to the CSV file
    echo "$timestamp_date,$timestamp_time,$uptime,$cpu_status,$check_cpu_usage,$mem_status,$check_memory_usage,$check_nfs,$disk_status,$check_disk_usage,$swap_status,$check_swap_usage,$check_processes,$check_5m_load,$check_10m_load,$check_15m_load,$check_filewall,$check_service,$check_updates" >> "$metrics_file"
}
