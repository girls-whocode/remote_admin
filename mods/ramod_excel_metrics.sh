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
    total_processes=$((total_processes - 1))

    echo ${total_processes}
}

function local_system_metrics() {
    # Define the CSV file to store the metrics
    metrics_file="./data/system_data.csv"

    if [ ! -d "./data" ]; then
        mkdir ./data
    fi

    # Check if the metrics file exists, if not, create and initialize it with headers
    if [ ! -f "$metrics_file" ]; then
        echo "Date,Time,Uptime,CPU_Status,CPU_Usage(%),Memory_Status,Memory_Usage(%),Disk_Status,Disk_Usage(%),Swap_Status,Swap_Usage(%),Processes_Total" > "$metrics_file"
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
    echo "$timestamp_date,$timestamp_time,$uptime,$cpu_status,$check_cpu_usage,$mem_status,$check_memory_usage,$disk_status,$check_disk_usage,$swap_status,$check_swap_usage,$check_processes" >> "$metrics_file"

    # Sleep for a desired interval (e.g., 5 minutes)
    # sleep 300  # Adjust the interval as needed
}
