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