#!/bin/bash


function do_connection_test {
    ssh_result=$(do_ssh ${username}@${hostname} echo "true" 2>&1)
    #ssh nasvc_orion@qaspvpilnxjmp01 ping -c 1 ${hostname} >/dev/null 2>&1
}

function test_connections {
    setup_action
    if [ "${hostname}" = "" ]; then
        # More than one host, loop through them
        for hostname in "${host_array[@]}"; do
            if [ ! "${hostname}" = "" ]; then
                # Test if the hostname is accessable
                do_connection_test
                if [[ "${ssh_result}" == "true" ]]; then
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
            ((host_counter++))
        else
            hosts_no_connect+=("${hosts_no_connect}")
            ((counter++))
        fi
    fi
    finish_action
}