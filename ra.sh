#!/bin/bash
# shellcheck disable=SC2034  # Unused variables left for readability
# shellcheck disable=SC2162  # Backslashes are used for ESC characters
# shellcheck disable=SC2181  # mycmd #? is used for return value of ping
# shellcheck disable=SC2154  # variables are sourced from other files

# Description: Open the ssh config file, look for any includes, and include each file, seperate
#              all hosts, place them into an array.
CONFILES=$(shopt -s nullglob; echo ~/.ssh/{config,config*[!~],config*[!~]/*})
app_name="Remote Admin"
script_name="ra.sh"
app_ver="2.0"
ra_start_time=$(date +%s.%3N)
org_prompt=${PS1}
ra_script_location="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ra_log_path="${ra_script_location}/var/logs"
ra_log_file="${ra_log_path}/ra_$(date +"%Y-%m-%d").log"
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

config
assign_colors
debug "${app_name} v.${app_ver} configuration file loaded from ${config_path}/${config_file}"
debug "${app_name} is located in ${ra_script_location} and started at ${ra_start_time}"
debug "${app_name} is reporting ${LINES} lines and ${COLS} columns"
info "${app_name} v.${app_ver} startup completed"
menu
