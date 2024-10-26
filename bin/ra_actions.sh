#!/usr/bin/env bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files
# shellcheck disable=SC2155  # Masking is no issues within application

# Actions
function setup_action {
    if [ -z "${1}" ]; then
        screen_name="Arrow 2.0"        
    else
        screen_name=${1}
    fi

    clear
    header "center" "${screen_name}"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Press ESC to return to the menu"

    hosts_no_connect=()
    counter=0
    host_counter=1
}

function finish_action {
    [ "${counter}" -eq 1 ] && counted_hosts="host" || counted_hosts="hosts"
    printf "%b%s%b connected, %b%s %b%s%b could not connect\n\n" "${light_red}" "${host_counter}" "${white}" "${light_red}" "${counter}" "${white}" "${counted_hosts}" "${default}"

    if [ ! ${#hosts_no_connect[@]} -eq 0 ]; then
        echo -e "${light_red}Could not connect to: ${default}"
        for no_connects in "${hosts_no_connect[@]}"; do
            echo -e "${light_blue}${no_connects}${default}"
        done
    fi
}

function filter_cmd_action {
    local forbidden_chars='[&<>()|;]'

    if [[ -z "${1}" ]]; then
        return
    else
        debug "Filtering command: ${1}"
        local filtered_cmd=$(echo "${1}" | grep -vqE "${forbidden_chars}" && echo "${1}")
        echo "${filtered_cmd}"
    fi
}

function reboot_host_server {
    start_action "Rebooting ${hostname}"
    info "Rebooting ${hostname} server"
    echo "To be implimented"
    finish_action
}

function shutdown_host_server {
    start_action "Powering Down ${hostname}"
    info "Shutting down ${hostname} server"
    echo "To be implimented"
    finish_action
}
