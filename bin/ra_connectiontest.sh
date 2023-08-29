#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

function do_connection_test {
    if ping -c 1 "$hostname" > /dev/null 2>&1; then
        connection_result="true"
    else
        connection_result="false"
    fi
}