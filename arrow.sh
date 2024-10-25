#!/usr/bin/env bash
# shellcheck disable=SC2162  # Backslashes are used for ESC characters
# shellcheck disable=SC2181  # mycmd #? is used for return value of ping
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

# Test if Arrow is already running
if [ "$(lsof -t "$0" | wc -l)" -gt 1 ]; then
    echo "Another instance of $0 is running. Stopping."
    exit 1
fi

# Assign default variables
metrics_flag=false
ra_start_time=$(date +%s.%3N)
org_prompt=${PS1}
ra_script_location="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ra_log_path="${ra_script_location}/var/logs"
ra_log_file="${ra_log_path}/ra_$(date +"%Y-%m-%d")_${USER}.log"
config_file="ra.${USER}.conf"
config_path="${ra_script_location}/var/conf"
tmpfile=sshtorc-${USER}
reports_path="${ra_script_location}/reports"
server_list_path="${ra_script_location}/var/server_lists"
search_dir=("${server_list_path}")
ra_snapshot_dir="${ra_script_location}/snapshots"
LINES=$( tput lines )
COLS=$( tput cols )
non_interactive="false"
log_level=0
info_count=0
warn_count=0
note_count=0
error_count=0
critical_count=0
environment="production"
chg_env_mode="development"

export ra_script_location
export org_prompt

# Test for directories
ra_sys_dirs=("bin" "mods" "var" "snapshots" "var/conf" "var/logs" "var/server_lists")
for sys_dirs in "${ra_sys_dirs[@]}"; do
    if [[ ! -d ${sys_dirs} ]]; then
        mkdir -p "${ra_script_location}/${sys_dirs}"
    fi
done

# Create the log file
[ ! -f "${ra_log_file}" ] && touch "${ra_log_file}"

# Open and source each file located in the bin directory
# that starts with ra_
for filename in "${ra_script_location}"/bin/ra_*; do
    if [[ -f ${filename} ]]; then
        # shellcheck source=/dev/null # The source is dynamically generated from the for loop
        source "${filename}"
    fi
done

for filename in "${ra_script_location}"/mods/ramod_*; do
    if [[ -f ${filename} ]]; then
        # shellcheck source=/dev/null # The source is dynamically generated from the for loop
        source "${filename}"
    fi
done

# Load the config and assign colors based on the option set
config
assign_colors

# Assign the basic variables for the application
app_name="A.R.R.O.W."
app_acronym="Advanced Remote Resource and Operations Workflow"
app_emoji="🏹"
script_name="arrow.sh"
app_logo=" --/A.R.R.O.W./==>"
app_logo_color="${app_emoji}${dark_gray}--${light_blue}/${green}A.R.R.O.W.${light_blue}/${dark_gray}=>${default}"
app_ver="2.0"
release="2.0.$(git rev-list --all --count)"
trap BLA::stop_loading_animation SIGINT

# Look for HostName * and read the identityfile
if [ -z "${identity_file}" ]; then
    read_ssh_config
    dbg_identity="${identity_file} Loaded from SSH Config file"
elif [ -n "${identity_file}" ]; then
    dbg_identity="${identity_file} Loaded from ${app_name} Config file"
else
    dbg_identity="No identity found"
fi

# Check if the --metrics option is provided
if [[ "$1" == "--metrics" ]]; then
    metrics_flag=true
fi

if $metrics_flag; then
    notice "-------------------------------] ${app_name} started system metics $(LC_ALL=C date +"%Y-%m-%d %H:%M:%S") [-------------------------------"
    debug "${app_name} v.${app_ver} configuration file loaded from ${config_path}/${config_file}"
    debug "${app_name} is located in ${ra_script_location} and started at ${ra_start_time}"
    info "${app_name} v.${app_ver} startup completed"
    debug "Username: ${username}"
    debug "${dbg_identity}"

    local_system_metrics
    success "System metrics collected successfully."
    exit 0  # Exit with success status
fi

# Start logging and load the main menu
notice "-------------------------------] ${app_name} started $(LC_ALL=C date +"%Y-%m-%d %H:%M:%S") [-------------------------------"
debug "${app_name} v.${app_ver} configuration file loaded from ${config_path}/${config_file}"
debug "${app_name} is located in ${ra_script_location} and started at ${ra_start_time}"
debug "${app_name} is reporting ${LINES} lines and ${COLS} columns"
info "${app_name} v.${app_ver} startup completed"
debug "Username: ${username}"
debug "${dbg_identity}"

if [ "${COLS}" -lt 125 ]; then
    error "Terminal columns must be at least 125 characters"
    echo -e "${RED}Please resize your terminal to at least 125 characters wide (130 Recommended). ${default} Current size is ${COLS}"
    exit 1
elif [ "${COLS}" -lt 130 ]; then
    notice "Terminal columns are less than 130 characters wide, screen may not render successfully.${default} Current size is ${COLS}"
fi

if [ "${LINES}" -lt 32 ]; then
    error "Terminal lines must be at least 32 characters"
    echo -e "${RED}Please resize your terminal to at least 32 characters tall (40 Recommended).${default} Current size is ${LINES}"
    exit 1
elif [ "${LINES}" -lt 40 ]; then
    notice "Terminal lines are less than 40 characters, screen may not render successfully.${default} Current size is ${LINES}"
fi

menu
