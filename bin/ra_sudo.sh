#!/usr/bin/env bash

# Define the function to request sudo access
request_sudo_access() {
    local attempts=0
    local max_attempts=3

    # Check if user already has sudo without a password or if it's cached
    if sudo -n true 2>/dev/null; then
        debug "Sudo access is already granted or cached."
        sudo_access="true"
        return 0
    fi

    while (( attempts < max_attempts )); do
        read -s -p "Enter your sudo password: " password
        echo  # Move to a new line after the user enters the password

        if echo $password | sudo -Sv >/dev/null 2>&1; then
            debug "Sudo access granted."
            sudo_access="true"
            return 0
        else
            echo "Invalid password, please try again."  # Replacing 'warn' with 'echo'
            ((attempts++))
        fi
    done

    echo "Sudo access denied after $max_attempts attempts. Exiting."  # Replacing 'warn' with 'echo'
    pause
    return 1
}

