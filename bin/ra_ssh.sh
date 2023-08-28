#!/bin/bash
# shellcheck disable=SC2154  # variables are sourced from other files

function do_ssh {
    # Filter out any bad characters by enclosing it in quotes
    cmd=$(filter_cmd_action "${1}")
    local ssh_command="ssh -q -o StrictHostKeyChecking=no -o ConnectTimeout=5 -p ${port} -i ${identity_file} -A -J ${username}@qaspvpilnxjmp01 ${username}@${hostname} '${cmd}'"
    
    debug "ssh command: ${ssh_command}"
    eval "${ssh_command}"
}

function copy_ssh_key {
    debug "Copy SSH Key command: ssh-copy-id -f -o StrictHostKeychecking=no -o ConnectTimeout=5 -p ${port} -i ${identity_file} ${username}@${hostname}"
    ssh-copy-id -f -o StrictHostKeychecking=no -o ConnectTimeout=5 -p ${port} -i ${identity_file} ${username}@${hostname}
}

function generate_ssh_key {
    debug "Generate SSH Key command"

}

function backup_ssh_keys {
    debug "Backup SSH Keys command"
}

function shell_hosts {
    setup_action
    if [ "${hostname}" = "" ]; then
        # More than one host, loop through them
        for hostname in "${host_array[@]}"; do
            if [ ! "${hostname}" = "" ]; then
                # Test if the hostname is accessable
                # # do_connection_test
                if [[ $? -eq 0 ]]; then
                    clear
                    printf "Connecting to %b%s%b using port %b%s%b \nIdentity file %b%s%b with user %b%s%b\n" "${light_red}" "${hostname}" "${default}" "${light_cyan}" "${port}" "${default}" "${light_blue}" "${ssh_identity}" "${default}" "${white}" "${username}" "${default}"
                    printf "%b═════════════════════════════════════════════════════════════════════════════════════════════════════%b\n" "${dark_gray}" "${default}"
                    printf "%s to %b%s%b (%b%s%b of %b%s%b)\n" "${action_options[$action_choice]}" "${light_red}" "${hostname}" "${default}" "${yellow}" "${host_counter}" "${default}" "${yellow}" "${host_count}" "${default}"
                    printf "%b═════════════════════════════════════════════════════════════════════════════════════════════════════%b\n\n" "${dark_gray}" "${default}"
                    do_ssh
                    ((host_counter++))
                else
                    hosts_no_connect+=("${hostname}")
                    ((counter++))
                fi
            fi
        done
    else
        # Test if the hostname is accessable
        # # do_connection_test
        if [[ $? -eq 0 ]]; then      
            clear
            printf "Connecting to %b%s%b using port %b%s%b and identity file %b%s%b with user %b%s%b\n" "${light_red}" "${hostname}" "${default}" "${light_cyan}" "${port}" "${default}" "${light_blue}" "${ssh_identity}" "${default}" "${white}" "${username}" "${default}"
            printf "%b═════════════════════════════════════════════════════════════════════════════════════════════════════%b\n" "${dark_gray}" "${default}"
            printf "%s to %b%s%b (%b%s%b of %b%s%b)\n" "${action_options[$action_choice]}" "${light_red}" "${hostname}" "${default}" "${yellow}" "${host_counter}" "${default}" "${yellow}" "${host_count}" "${default}"
            printf "%b═════════════════════════════════════════════════════════════════════════════════════════════════════%b\n\n" "${dark_gray}" "${default}"
            do_ssh
        else
            hosts_no_connect+=("${hosts_no_connect[@]}")
            ((counter++))
        fi
    fi
    finish_action
}