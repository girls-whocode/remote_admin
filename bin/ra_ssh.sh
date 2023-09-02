#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files
# shellcheck disable=SC2120  # variables may or maynot be used

# Description: Open the ssh config file, look for any includes, and include each file, seperate
#              all hosts, place them into an array.
CONFILES=$(shopt -s nullglob; echo ~/.ssh/{config,config*[!~],config*[!~]/*})

# Function: 
#   do_ssh
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

# Function:
#   copy_ssh_key
#
# Overview:
#   Copies the SSH key to the selected host or hosts.
#
# Usage:
#   copy_ssh_key
#
# Globals Modified:
#   host_array - Array of hostnames to copy the SSH key to.
#   port - SSH port number.
#   identity_file - SSH identity file.
#   host_counter - Counter to keep track of the number of hosts processed.
#
# Dependencies:
#   Calls 'setup_action' and 'finish_action' for pre and post action setup.
#   Calls 'debug' for debugging information.
#
# Side Effects:
#   1. Copies the SSH key to all the selected hosts.
#   2. Updates the host_counter.
#
# Note:
#
function copy_ssh_key {
    setup_action  # Pre-action setup
    clear
    header "center" "Copy SSH Key to ${hostname}"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Press ESC to return to the menu"

    if [ ${#host_array[@]} -gt 1 ]; then  # If multiple hosts are selected
        debug "Copy SSH key to multiple hosts"
        
        for hostname in "${host_array[@]}"; do  # Loop through each host
            if [ -n "${hostname}" ]; then
                debug "Attempting to copy SSH key to host: ${hostname}"
                debug "Port is: ${port}"
                debug "Identity File is: ${identity_file}"
                
                ssh_copy_command="ssh-copy-id -i ${identity_file_location}/${identity_file} -p ${port} ${username}@${hostname}"
                debug "SSH Copy Command: ${ssh_copy_command}"
                
                eval "${ssh_copy_command}"  # Execute the SSH key copy
                
                ((host_counter++))  # Increment the counter
            fi
        done
    else  # If a single host is selected
        debug "Copy SSH key to single host: ${hostname}"
        debug "Port is: ${port}"
        debug "Identity File is: ${identity_file}"
        
        ssh_copy_command="ssh-copy-id -i ${identity_file_location}/${identity_file} -p ${port} ${username}@${hostname}"
        debug "SSH Copy Command: ${ssh_copy_command}"
        
        eval "${ssh_copy_command}"  # Execute the SSH key copy
    fi

    finish_action  # Post-action finish
    while $keep_running; do
        handle_input "remote_menu"
    done
}

# Function: 
#   generate_ssh_key
#
# Overview:
#   Generates an RSA SSH key and appends the identity configuration to the SSH config file.
#
# Usage:
#   generate_ssh_key
#
# Globals Modified:
#   term_height - Stores the terminal height.
#   term_width  - Stores the terminal width.
#   ssh_folder  - Path to the .ssh folder in the user's home directory.
#   ssh_key_file - Name of the generated SSH key file.
#   ssh_config_file - Path to the SSH config file.
#   keep_running - Control flag for input handling loop.
#
# Dependencies:
#   Calls 'header' and 'footer' for visual UI elements.
#   Calls 'handle_input' for handling user input.
#
# Side Effects:
#   1. Checks if .ssh folder exists and creates one if it doesn't.
#   2. Generates an RSA SSH key.
#   3. Checks if the SSH config file exists and creates one if it doesn't.
#   4. Appends identity configuration to the SSH config file.
#   5. Checks for duplicate entries in the SSH config file.
#   6. Optionally deletes generated key if the user chooses not to overwrite existing entry.
#
# Example:
#   generate_ssh_key
#
# Note:
#
function generate_ssh_key() {
    # Get the terminal height and width
    term_height=$(tput lines)
    term_width=$(tput cols)

    # Hide the cursor
    echo -ne "\033[?25l"

    # Initialize screen and place cursor at the beginning
    clear
    header "center" "Generating SSH Key"
    footer "right" "${app_logo_color} v.${app_ver}"

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

# Function: 
#   shell_hosts
#
# Overview:
#   Initiates SSH sessions into hosts provided in the host_array.
#   Depending on the number of hosts, it either shells into a single host or multiple hosts.
#
# Usage:
#   shell_hosts
#
# Globals Modified:
#   host_array    - Array containing the hostnames to SSH into.
#   hostname      - Stores the current hostname being processed.
#   port          - Stores the port number for the SSH connection.
#   identity_file - Stores the identity file used for authentication.
#   host_counter  - Counter to keep track of the number of hosts processed.
#
# Dependencies:
#   Calls the 'do_ssh' function to initiate the SSH connection.
#   Calls 'setup_action' and 'finish_action' for pre and post action setups.
#
# Side Effects:
#   1. Logs debugging information about what the function is attempting to do.
#   2. Calls 'do_ssh' to initiate the SSH connection.
#   3. If multiple hosts are present, the function will loop through each host in the host_array.
#   4. Increments host_counter after successfully processing each host.
#
# Example:
#   shell_hosts
#
# Note:
#   Assumes that 'host_array', 'port', and 'identity_file' have been set prior to calling this function.
#
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

# Function: 
#   read_ssh_config
#
# Overview:
#   This function reads the SSH configuration file for the current user
#   and extracts the IdentityFile path corresponding to the generic 'Host *'.
#
# Usage:
#   read_ssh_config
#
# Globals Modified:
#   ssh_config_file       - Stores the path to the user's SSH configuration file.
#   identity_file         - Stores the IdentityFile specified for 'Host *' in the SSH config.
#   identity_file_location- Stores the directory where the IdentityFile is located.
#
# Side Effects:
#   1. Checks if the SSH config file exists in the user's HOME directory.
#   2. If found, it uses awk to read the file and extract the IdentityFile corresponding to 'Host *'.
#   3. The function then processes this file path, replacing any %d with $HOME and $(username) with the actual username.
#   4. It then extracts the folder and file from the path and stores them in the respective variables.
#
# Example:
#   read_ssh_config
#
# Note:
#   The function expects that the SSH config file is formatted according to standard conventions,
#   particularly with the 'IdentityFile' line indented and appearing after 'Host *'.
#
function read_ssh_config() {
    ssh_config_file="${HOME}/.ssh/config"

    # Check if the SSH config file exists
    if [ -f "${ssh_config_file}" ]; then
        debug "SSH config file exists"
        # Find the IdentityFile corresponding to 'Host *'
        identity_file=$(awk '/^Host \*/{flag=1; next} flag && /^    IdentityFile /{print $2; flag=0}' "${ssh_config_file}")

        # If an IdentityFile is found
        if [ -n "$identity_file" ]; then
            debug "An identity has been found, let's process it"
            # Replace %d with $HOME and $(username) with the username
            identity_file=$(echo "${identity_file}" | sed "s|%d|${HOME}|g;s|\\${username}|$(whoami)|g")

            # Extract folder and file from the path
            identity_file_location=$(dirname "$identity_file")
            identity_file=$(basename "$identity_file")
            debug "Identity File: ${identity_file}"
            debug "Identity Location: ${identity_file_location}"
        fi
    fi
}

function do_scp() {
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
            local scp_command="scp -q -o StrictHostKeyChecking=no -o ConnectTimeout=3 ${cmd_port} ${cmd_identity} ${cmd_jump_host} \"${username}@${hostname}\" ${cmd}"
        fi

        info "scp command: ${scp_command}"
        set -x  # Enable debugging
        # eval "${scp_command}"
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