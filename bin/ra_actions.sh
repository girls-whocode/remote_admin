#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

# Actions
function setup_action {
    clear
    hosts_no_connect=()
    counter=0
    host_counter=1
}

function finish_action {
    [ ${counter} -eq 1 ] && counted_hosts="host" || counted_hosts="hosts"
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
        local filtered_cmd=$(echo "${1}" | grep -vqE "${forbidden_chars}" && echo "${1}")
        echo "${filtered_cmd}"
    fi
}

function vulnerability_scan {
    setup_action
    if [[ $host_count -gt 0 ]]; then
        # More than one host, loop through them
        for hostname in "${host_array[@]}"; do
            if [ ! "${hostname}" = "" ]; then
                # do_connection_test
                if [[ $? -eq 0 ]]; then
                    [ ! -d "./reports/systems/$(date +"%Y-%m-%d")/${hostname}" ] && mkdir -p "./reports/systems/$(date +"%Y-%m-%d")/${hostname}/"

                    # Check to see if openscap-utils is install
                    if do_ssh "rpm -q openscap-utils" >/dev/null 2>&1; then
                        openscap=true
                    # if not, install it
                    else
                        if do_ssh "sudo yum install openscap-utils bzip2 -y" >/dev/null 2>&1; then
                            openscap=true
                        else
                            openscap=false
                        fi
                    fi

                    host_version=$(do_ssh "cat /etc/os-release | sed -n 's/^VERSION=//p' | tr -d '\042'")
                    host_scan_version=${host_version:0:1}

                    if [[ ${openscap} == true ]]; then
                        # Start the CAP scan
                        SSH_ADDITIONAL_OPTIONS=''
                        oscap-ssh ${username}@${hostname} ${port} oval eval --fetch-remote-resources --report "./reports/systems/$(date +"%Y-%m-%d")/${hostname}/${hostname}_oscap_rhel${host_scan_version}_$(date +"%Y-%m-%d").html" rhel-${host_scan_version}.oval.xml
                    else
                        echo "OpenSCAP could not install"
                        pause
                    fi

                    # do_scp "${HOME}/${hostname}-load-$(date +"%Y-%m-%d").txt" "./reports/systems/${hostname}/${hostname}-load-$(date +"%Y-%m-%d").txt"
                    # do_ssh "rm ${HOME}/${hostname}-load-$(date +"%Y-%m-%d").txt"
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
            [ ! -d "./reports/systems/$(date +"%Y-%m-%d")/${hostname}" ] && mkdir -p "./reports/systems/$(date +"%Y-%m-%d")/${hostname}/"

            # Check to see if openscap-utils is install
            if do_ssh "rpm -q openscap-utils" >/dev/null 2>&1; then
                openscap=true
            # if not, install it
            else
                if do_ssh "sudo yum install openscap-utils bzip2 -y" >/dev/null 2>&1; then
                    openscap=true
                else
                    openscap=false
                fi
            fi

            host_version=$(do_ssh "cat /etc/os-release | sed -n 's/^VERSION=//p' | tr -d '\042'")
            host_scan_version=${host_version:0:1}

            if [[ ${openscap} == true ]]; then
                # Start the CAP scan
                SSH_ADDITIONAL_OPTIONS=''
                oscap-ssh ${username}@${hostname} ${port} oval eval --fetch-remote-resources --report "./reports/systems/$(date +"%Y-%m-%d")/${hostname}/${hostname}_oscap_rhel${host_scan_version}_$(date +"%Y-%m-%d").html" rhel-${host_scan_version}.oval.xml
            else
                echo "OpenSCAP could not install"
                pause
            fi

            # do_scp "${HOME}/${hostname}-load-$(date +"%Y-%m-%d").txt" "./reports/systems/${hostname}/${hostname}-load-$(date +"%Y-%m-%d").txt"
            # do_ssh "rm ${HOME}/${hostname}-load-$(date +"%Y-%m-%d").txt"
            ((host_counter++))
        else
            hosts_no_connect+=("${hosts_no_connect[@]}")
            ((counter++))
        fi
    fi
    finish_action
}

function reboot_host_server {
    start_action
    echo "To be implimented"
    finish_action
}

function shutdown_host_server {
    start_action
    echo "To be implimented"
    finish_action
}
