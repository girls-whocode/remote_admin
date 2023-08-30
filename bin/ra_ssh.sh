#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files
# shellcheck disable=SC2120  # variables may or maynot be used

# Description: Open the ssh config file, look for any includes, and include each file, seperate
#              all hosts, place them into an array.
CONFILES=$(shopt -s nullglob; echo ~/.ssh/{config,config*[!~],config*[!~]/*})

# Function: do_ssh
#
# Description:
# Execute SSH commands to connect to a remote host. This function establishes an SSH connection based on the provided parameters,
# including hostname, username, port, identity file, and jump host configuration.
#
# Parameters:
#   $1 - Command to be executed on the remote host
#
# Globals Used:
#   - connection_result: Holds the result of a previous connection attempt
#   - port: Port number for SSH connection (if set)
#   - identity_file: Identity file for SSH connection (if set)
#   - identity_file_location: Location of identity files directory
#   - jump_host: Jump host configuration (if set)
#   - username: Username for SSH connection
#   - hostname: Hostname of the remote system
#
# Dependencies:
#   - filter_cmd_action: A function to filter and process the provided command action
#   - debug: A function to output debug messages
#   - info: A function to display information messages
#   - clear: A function to clear the screen
#   - header: A function to display header content
#   - footer: A function to display footer content
#   - show_message: A function to display a message
#   - handle_input: A function to handle user input and navigation
#
# Notes:
#   - The function checks the value of $connection_result to determine if the SSH connection attempt was successful.
#   - If the connection was successful, the function constructs and executes an SSH command with the provided parameters.
#   - If the connection failed, an error message is displayed, and the user is prompted to return to the menu.
#
# Example Usage:
#   do_ssh "ls -l"
#   - This would execute the "ls -l" command on the remote host using the established SSH connection.
function do_ssh {
    if [ "$connection_result" == "true" ]; then
        [ -n "${port+x}" ] && cmd_port="-p ${port}" || cmd_port=""
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
        footer "right" "${app_logo_color} v.${app_ver}" "left" "Press ESC to return to the menu"
        show_message "${hostname} was unable to connect."
        while $keep_running; do
            handle_input "remote_menu"
        done
    fi
}

# Function: copy_ssh_key
#
# Description:
# Copy the local SSH key to a remote host, enabling passwordless authentication.
# This function constructs and executes an SSH command using the provided parameters.
# It copies the local SSH public key to the remote host's authorized_keys file.
#
# Globals Used:
#   - port: Port number for SSH connection (if set)
#   - identity_file: Identity file for SSH connection (if set)
#   - identity_file_location: Location of identity files directory
#   - jump_host: Jump host configuration (if set)
#   - username: Username for SSH connection
#   - hostname: Hostname of the remote system
#
# Dependencies:
#   - debug: A function to output debug messages
#
# Example Usage:
#   copy_ssh_key
function copy_ssh_key {
    [ -n "${port+x}" ] && cmd_port="-p ${port}" || cmd_port=""
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