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
                    clear
                    printf "Testing connection to %b%s%b using port %b%s%b \nIdentity file %b%s%b with user %b%s%b\n" "${light_red}" "${hostname}" "${default}" "${light_cyan}" "${port}" "${default}" "${light_blue}" "${ssh_identity}" "${default}" "${white}" "${username}" "${default}"
                    printf "%b═════════════════════════════════════════════════════════════════════════════════════════════════════%b\n" "${dark_gray}" "${default}"
                    printf "%s to %b%s%b (%b%s%b of %b%s%b)\n" "${action_options[$action_choice]}" "${light_red}" "${hostname}" "${default}" "${yellow}" "${host_counter}" "${default}" "${yellow}" "${host_count}" "${default}"
                    printf "%b═════════════════════════════════════════════════════════════════════════════════════════════════════%b\n\n" "${dark_gray}" "${default}"
                    ((host_counter++))
                else
                    hosts_no_connect+=("${hostname}")
                    ((counter++))
                fi
                
                # if [[ $? -eq 0 ]]; then
                #     clear
                #     printf "Testing connection to %b%s%b using port %b%s%b \nIdentity file %b%s%b with user %b%s%b\n" "${light_red}" "${hostname}" "${default}" "${light_cyan}" "${port}" "${default}" "${light_blue}" "${ssh_identity}" "${default}" "${white}" "${username}" "${default}"
                #     printf "%b═════════════════════════════════════════════════════════════════════════════════════════════════════%b\n" "${dark_gray}" "${default}"
                #     printf "%s to %b%s%b (%b%s%b of %b%s%b)\n" "${action_options[$action_choice]}" "${light_red}" "${hostname}" "${default}" "${yellow}" "${host_counter}" "${default}" "${yellow}" "${host_count}" "${default}"
                #     printf "%b═════════════════════════════════════════════════════════════════════════════════════════════════════%b\n\n" "${dark_gray}" "${default}"
                #     ((host_counter++))
                # else
                #     hosts_no_connect+=("${hostname}")
                #     ((counter++))
                # fi
            fi
        done
    else
        # Test if the hostname is accessable
        do_connection_test
        if [[ $? -eq 0 ]]; then      
            clear
            printf "Testing connection to %b%s%b using port %b%s%b \nIdentity file %b%s%b with user %b%s%b\n" "${light_red}" "${hostname}" "${default}" "${light_cyan}" "${port}" "${default}" "${light_blue}" "${ssh_identity}" "${default}" "${white}" "${username}" "${default}"
            printf "%b═════════════════════════════════════════════════════════════════════════════════════════════════════%b\n" "${dark_gray}" "${default}"
            printf "%s to %b%s%b (%b%s%b of %b%s%b)\n" "${action_options[$action_choice]}" "${light_red}" "${hostname}" "${default}" "${yellow}" "${host_counter}" "${default}" "${yellow}" "${host_count}" "${default}"
            printf "%b═════════════════════════════════════════════════════════════════════════════════════════════════════%b\n\n" "${dark_gray}" "${default}"
        else
            hosts_no_connect+=("${hosts_no_connect}")
            ((counter++))
        fi
    fi
    finish_action
}