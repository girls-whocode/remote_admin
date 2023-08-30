#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

# Function: select_file
# Description: This function allows the user to select a file from the list of files
#              in the current directory
function select_file() {
    # Prompt the user to select a host file
    select_option "${db_files[@]}"
    file_choice=$?
}

# Function: copy_file
# Description: This function gathers a list of files, displays them in a list and copies
#              that file to the host.
function copy_file() {
    select_file
    cp_file_name="${search_dir[$file_choice]}"
    return
}

function get_file {
    start_action
    echo "To be implimented"
    finish_action
}
