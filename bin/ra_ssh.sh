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
        [ -n "${port}" ] && cmd_port="-p ${port}" || cmd_port=""
        [ -n "${identity_file}" ] && cmd_identity="-i \"${identity_file_location}/${identity_file}\"" || cmd_identity=""
        [ -n "${jump_host}" ] && cmd_jump_host="-A -J \"${username}@qaspvpilnxjmp01\"" || cmd_jump_host=""

        cmd=$(filter_cmd_action "${1}")

        if [ -z "$cmd_identity" ]; then
            show_message "No identity file was provided. ${hostname} was unable to connect."
            while $keep_running; do
                handle_input "remote_menu"
            done
        else
            local ssh_command="ssh -q -o StrictHostKeyChecking=no -o ConnectTimeout=3 ${cmd_port} ${cmd_identity} ${cmd_jump_host} \"${username}@${hostname}\" ${cmd}"
        fi

        info "ssh command: ${ssh_command}"
        set -x  # Enable debugging
        eval "${ssh_command}"
        set +x  # Disable debugging
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
    [ -n "${port}" ] && cmd_port="-p ${port}" || cmd_port=""
    [ -n "${identity_file}" ] && cmd_identity="-i ${identity_file_location}/${identity_file}" || cmd_identity=""
    [ -n "${jump_host}" ] && cmd_jump_host="-A -J ${username}@qaspvpilnxjmp01" || cmd_jump_host=""

    local scp_command="ssh-copy-id -f -o StrictHostKeychecking=no -o ConnectTimeout=5 ${cmd_port} ${cmd_identity} ${username}@${hostname}"
    debug "scp command: ${scp_command}"
    eval "${scp_command}"
}

# Allow the user to generate an SSH key and add it to the config file
function generate_ssh_key() {
    # Get the terminal height and width
    term_height=$(tput lines)
    term_width=$(tput cols)

    # Hide the cursor
    echo -ne "\033[?25l"

    # Initialize screen and place cursor at the beginning
    clear
    header "center" "Generating SSH Key"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Press 'ESC' to return to the menu"

    ssh_folder="${HOME}/.ssh"

    # Check if the .ssh folder exists, create if it doesn't
    [ -d "${ssh_folder}" ] || mkdir -p "${ssh_folder}"

    # Generate the SSH key
    ssh_key_file="${ssh_folder}/ra.${username}"
    ssh-keygen -t rsa -f "${ssh_key_file}"

    # Create or append identity configuration to SSH config file
    ssh_config_file="${ssh_folder}/config"
    identity_config="Host *\n    IdentityFile %d/.ssh/ra.${username}"
    
    # Check if the SSH config file exists, create if it doesn't
    [ -f "${ssh_config_file}" ] || touch "${ssh_config_file}"

    # Check if the identity is already there to avoid duplicate
    if grep -q "IdentityFile %d/.ssh/ra.${username}" "${ssh_config_file}"; then
        read -p "The identity file already exists in the config. Do you want to overwrite? (y/n): " choice
        case "$choice" in
            y|Y)
                # Logic to overwrite the identity; you can use sed or awk to replace the existing line
                ;;
            *)
                echo "Aborting operation. Cleaning up..."
                rm -f "$ssh_key_file"  # remove the newly generated key file
                return
                ;;
        esac
    else
        echo -e "$identity_config" >> "${ssh_config_file}"
    fi

    keep_running=true
    echo -e "${light_green}Your SSH key has been generated.${default}"

    while $keep_running; do
        handle_input "menu"
    done
}

function backup_ssh_keys {
    debug "Backup SSH Keys command"
}

function shell_hosts {
    setup_action

    if [ ${#host_array[@]} -gt 1 ]; then
        debug "Shell into multiple hosts"
        for hostname in "${host_array[@]}"; do
            if [ -n "${hostname}" ]; then
                debug "Attempting to shell into host: ${hostname}"
                debug "Port is: ${port}"
                debug "Identity File is: ${identity_file}"
                do_ssh
                ((host_counter++))
            fi
        done
    else
        debug "Shell into single host: ${hostname}"
        debug "Port is: ${port}"
        debug "Identity File is: ${identity_file}"
        clear
        do_ssh
    fi

    finish_action
}

function read_ssh_config() {
    ssh_config_file="${HOME}/.ssh/config"

    # Check if the SSH config file exists
    if [ -f "${ssh_config_file}" ]; then
        # Find the IdentityFile corresponding to 'Hostname *'
        identity_file=$(awk '/^Host \*/{flag=1; next} flag && /^    IdentityFile /{print $2; flag=0}' "${ssh_config_file}")

        # If an IdentityFile is found
        if [ -n "$identity_file" ]; then
            # Replace %d with $HOME and $(username) with the username
            identity_file=$(echo "${identity_file}" | sed "s|%d|${HOME}|g;s|\\${username}|$(whoami)|g")

            # Extract folder and file from the path
            identity_file_location=$(dirname "$identity_file")
            identity_file=$(basename "$identity_file")
        fi
    fi
}