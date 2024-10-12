#!/usr/bin/env bash

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