#!/bin/bash

# Function: select_file
# Description: This function allows the user to select a file from the list of files
#              in the current directory
function select_file() {
    # Prompt the user to select a host file
    select_option "${search_dir[@]}"
    file_choice=$?
}

# Function: copy_file
# Description: This function gathers a list of files, displays them in a list and copies
#              that file to the host.
function copy_file() {
    select_file
    cp_file_name="${search_dir[$file_choice]}"
    return
}

function copy_file {
    start_action
    echo "To be implimented"
    finish_action
}

function get_file {
    start_action
    echo "To be implimented"
    finish_action
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
                    clear
                    printf "Connecting to %b%s%b using port %b%s%b \nIdentity file %b%s%b with user %b%s%b\n" "${light_red}" "${hostname}" "${default}" "${light_cyan}" "${port}" "${default}" "${light_blue}" "${ssh_identity}" "${default}" "${white}" "${username}" "${default}"
                    printf "%b═════════════════════════════════════════════════════════════════════════════════════════════════════%b\n" "${dark_gray}" "${default}"
                    printf "%s from %b%s%b (%b%s%b of %b%s%b) results will be in the %b./reports%b folder by host name\n" "${action_options[$action_choice]}" "${light_red}" "${hostname}" "${default}" "${yellow}" "${host_counter}" "${default}" "${yellow}" "${host_count}" "${default}" "${light_yellow}" "${default}"
                    printf "%b═════════════════════════════════════════════════════════════════════════════════════════════════════%b\n\n" "${dark_gray}" "${default}"
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
            printf "Connecting to %b%s%b using port %b%s%b and identity file %b%s%b with user %b%s%b\n" "${light_red}" "${hostname}" "${default}" "${light_cyan}" "${port}" "${default}" "${light_blue}" "${ssh_identity}" "${default}" "${white}" "${username}" "${default}"
            printf "%b═════════════════════════════════════════════════════════════════════════════════════════════════════%b\n" "${dark_gray}" "${default}"
            printf "%s from %b%s%b (%b%s%b of %b%s%b) results will be in the %b./reports%b folder by host name\n" "${action_options[$action_choice]}" "${light_red}" "${hostname}" "${default}" "${yellow}" "${host_counter}" "${default}" "${yellow}" "${host_count}" "${default}" "${light_yellow}" "${default}"
            printf "%b═════════════════════════════════════════════════════════════════════════════════════════════════════%b\n\n" "${dark_gray}" "${default}"
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