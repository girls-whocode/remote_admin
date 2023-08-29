#!/bin/bash
# shellcheck disable=SC2154  # variables are sourced from other files

# Description: Open the ssh config file, look for any includes, and include each file, seperate
#              all hosts, place them into an array.
CONFILES=$(shopt -s nullglob; echo ~/.ssh/{config,config*[!~],config*[!~]/*})

function do_ssh {
    if [ "$connection_result" == "true" ]; then
        [ -n ${port+x} ] && cmd_port="-p ${port}" || cmd_port=""
        [ -n "${identity_file+x}" ] && cmd_identity="-i ${identity_file_location}/${identity_file}" || cmd_identity=""
        [ -n "${jump_host+x}" ] && cmd_jump_host="-A -J ${username}@qaspvpilnxjmp01" || cmd_jump_host=""

        # Filter out any bad characters by enclosing it in quotes
        cmd=$(filter_cmd_action "${1}")

        local ssh_command="ssh -q -o StrictHostKeyChecking=no -o ConnectTimeout=5 ${cmd_port} ${cmd_identity} ${cmd_jump_host} ${username}@${hostname} ${cmd}"
        debug "ssh command: ${ssh_command}"
        eval "${ssh_command}"
    else
        info "ssh to ${hostname} failed with no connection"
        clear
        header "center" "There was an error"
        footer "right" "${app_name} v.${app_ver}" "left" "Press ESC to return to the menu"
        show_message "${hostname} was unable to connect."
        while $keep_running; do
            handle_input "remote_menu"
        done
    fi
}

function copy_ssh_key {
    [ -n ${port+x} ] && cmd_port="-p ${port}" || cmd_port=""
    [ -n "${identity_file+x}" ] && cmd_identity="-i ${identity_file_location}/${identity_file}" || cmd_identity=""
    [ -n "${jump_host+x}" ] && cmd_jump_host="-A -J ${username}@qaspvpilnxjmp01" || cmd_jump_host=""

    local scp_command="ssh-copy-id -f -o StrictHostKeychecking=no -o ConnectTimeout=5 ${cmd_port} ${cmd_identity} ${username}@${hostname}"
    debug "scp command: ${scp_command}"
    eval "${scp_command}"
}

function generate_ssh_key {
    debug "Generate SSH Key command"

}

function backup_ssh_keys {
    debug "Backup SSH Keys command"
}

function shell_hosts {
    setup_action
   
    if [ ${#host_array[@]} -gt 1 ]; then
        # More than one host, loop through them
        debug "Shell into multiple hosts"
        for hostname in "${host_array[@]}"; do
            if [ -n "${hostname}" ]; then
                do_ssh
                ((host_counter++))
            fi
        done
    else
        debug "Shell into single host: ${hostname}"
        clear
        do_ssh
    fi

    finish_action
}