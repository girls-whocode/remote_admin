#!/usr/bin/env bash

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