#!/usr/bin/env bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files
# shellcheck disable=SC2181  # mycmd #? is used for return value of commands
# shellcheck disable=SC2319  # mycmd #? is used for return value of conditions
# shellcheck disable=SC2155  # declare and assign no longer issue in BASH 14+

function local_updates {
    info "Local System Updates Started"

    # Get the terminal height and width
    term_height=$(tput lines)
    term_width=$(tput cols)-2
    local width=$((term_width * 7 / 10))

    # ANSI escape sequences
    ESC="\033"
    cursor_to_start="${ESC}[H"
    cursor_to_second_row="${ESC}[2;1H"  # Move to 2nd row, 1st column
    keep_running=true

    clear
    echo -ne "${cursor_to_start}"
    header "center" "System Diagnostics"
    footer "right" "${app_logo_color} v.${app_ver}"

    # Hide the cursor
    echo -ne "\033[?25l"
    draw_center_line_with_info

    # Check for available updates
    if command -v apt &>/dev/null; then
        updates=$(apt list --upgradable 2>/dev/null | wc -l)
    elif command -v yum &>/dev/null; then
        updates=$(yum check-update --quiet | wc -l)
    elif command -v dnf &>/dev/null; then
        updates=$(dnf check-update --quiet | wc -l)
    elif command -v zypper &>/dev/null; then
        updates=$(zypper list-updates | wc -l)
    elif command -v pacman &>/dev/null; then
        updates=$(pacman -Qu | wc -l)
    elif command -v brew &>/dev/null; then
        updates=$(brew outdated | wc -l)
    else
        echo "Unknown"
    fi

    # Move the cursor to the third row
    echo -ne "${cursor_to_second_row}"

    # Fetching system information
    if command -v lsb_release &>/dev/null; then
        os_name=$(lsb_release -d | awk -F ':' '{print $2}' | xargs)
    elif [ -f /etc/redhat-release ]; then
        os_name=$(cat /etc/redhat-release)
    elif [ -f /etc/os-release ]; then
        os_name=$(grep '^PRETTY_NAME' /etc/os-release | cut -d '=' -f 2 | sed 's/"//g')
    else
        os_name="Unknown"
    fi

    [[ ${updates} -eq 1 ]] && updates_text="update" || updates_text="updates"
    echo -ne "${default} There are ${light_red}${updates}${default} ${updates_text} available for ${white}${os_name}. Preparing for installation"

    puase
}

function deploy_updates {
    setup_action
    if [ "${hostname}" = "" ]; then
        # More than one host, create the hostname variable and loop through the array
        for hostname in "${host_array[@]}"; do
            if [ ! "${hostname}" = "" ]; then
                # Test if the hostname is accessable this does not work with prod and dmz servers
                do_connection_test
                if [[ $? -eq 0 ]]; then
                    do_ssh "sudo yum --security check-update > ${hostname}_security_check_update_$(date +"%Y-%m-%d").log && sudo yum --security update -y > ${hostname}_security_updates_installed_$(date +"%Y-%m-%d").log"
                    [ ! -d ./reports/updates/$(date +"%Y-%m-%d")/${hostname} ] && mkdir -p ./reports/updates/$(date +"%Y-%m-%d")/${hostname}
                    do_scp "~/${hostname}_security_check_update_$(date +"%Y-%m-%d").log" "./reports/updates/$(date +"%Y-%m-%d")/${hostname}"
                    do_scp "~/${hostname}_security_updates_installed_$(date +"%Y-%m-%d").log" "./reports/updates/$(date +"%Y-%m-%d")/${hostname}"
                    ((host_counter++))
                else
                    hosts_no_connect+=("${hostname}")
                    ((counter++))
                fi
            fi
        done
    else
        # Test if the hostname is accessable
        do_connection_test
        if [[ $? -eq 0 ]]; then      
            do_ssh "sudo yum --security check-update > ${hostname}_security_check_update_$(date +"%Y-%m-%d").log && sudo yum --security update -y > ${hostname}_security_updates_installed_$(date +"%Y-%m-%d").log"
            [ ! -d ./reports/updates/$(date +"%Y-%m-%d")/${hostname} ] && mkdir -p ./reports/updates/$(date +"%Y-%m-%d")/${hostname}
            do_scp "~/${hostname}_security_check_update_$(date +"%Y-%m-%d").log" "./reports/updates/$(date +"%Y-%m-%d")/${hostname}"
            do_scp "~/${hostname}_security_updates_installed_$(date +"%Y-%m-%d").log" "./reports/updates/$(date +"%Y-%m-%d")/${hostname}"
        else
            hosts_no_connect+=("${hosts_no_connect}")
            ((counter++))
        fi
    fi
    finish_action
}

function check_updates {
    setup_action
    if [[ $host_count -gt 0 ]]; then
        # More than one host, loop through them
        for hostname in "${host_array[@]}"; do
            if [ ! "${hostname}" = "" ]; then
                # do_connection_test
                if [[ $? -eq 0 ]]; then
                    [ ! -d ./reports/updates/"$(date +"%Y-%m-%d")"/"${hostname}" ] && mkdir -p ./reports/updates/"$(date +"%Y-%m-%d")"/"${hostname}"
                    do_ssh "sudo yum --security check-update > ${hostname}_security_check_update_$(date +"%Y-%m-%d").log"
                    do_scp "${HOME}/${hostname}_security_check_update_$(date +"%Y-%m-%d").log" "./reports/updates/$(date +"%Y-%m-%d")/${hostname}/"
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
            [ ! -d ./reports/updates/"$(date +"%Y-%m-%d")"/"${hostname}" ] && mkdir -p ./reports/updates/"$(date +"%Y-%m-%d")"/"${hostname}"
            do_ssh "sudo yum --security check-update > ${hostname}_security_check_update_$(date +"%Y-%m-%d").log"
            do_scp "${HOME}/${hostname}_security_check_update_$(date +"%Y-%m-%d").log" "./reports/updates/$(date +"%Y-%m-%d")/${hostname}/"
        else
            hosts_no_connect+=("${hosts_no_connect[@]}")
            ((counter++))
        fi
    fi
    finish_action
}

function refresh_supscription {
    setup_action
    if [[ $host_count -gt 0 ]]; then
        # More than one host, loop through them
        for hostname in "${host_array[@]}"; do
            if [ ! "${hostname}" = "" ]; then
                # # do_connection_test
                # if [[ $? -eq 0 ]]; then
                    ssh ${username}@${hostname} "sudo subscription-manager refresh"
                    ((host_counter++))
                # else
                #     printf "%bUnable to reach %b%s%b\n" "${light_red}" "${white}" "${hostname}" "${default}"
                #     ((counter++))
                # fi
            fi
        done
    else
        # do_connection_test
        # if [[ $? -eq 0 ]]; then
            ssh  ${username}@${hostname} "sudo subscription-manager refresh"
        # else
        #     printf "%bUnable to reach %b%s%b\n" "${light_red}" "${white}" "${hostname}" "${default}"
        #     ((counter++))
        # fi
    fi
    finish_action
}