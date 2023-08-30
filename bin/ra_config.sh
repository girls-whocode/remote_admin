#!/bin/bash
# shellcheck disable=SC2154  # variables are sourced from other files

function build_config() {
    info "Building configuration file ${config_path}/${config_file}"
    declare -a config_lines=(
        "# ${app_name} v${app_ver} automated configurations"
        "default_editor=${default_editor}"
        "color_output=${color_output}"
        "username=${username}"
        "identity_file_location=\"${identity_file_location}\""
        "identity_file=\"${identity_file}\""
        "port=${port}"
        "# logging levels can be [critical, error, warning, notice, info, debug]"
        "# debug shows all messages"
        "# info shows all information, notices, warnings, errors, and critical"
        "# notice shows all notices, warnings, errors, and critical"
        "# warning shows all warnings, errors, and critical"
        "# error shows all errors and criticals"
        "# critical shows only critical"
        "# none will disable logging"
        "logging=${logging}"
    )

    printf "%s\n" "${config_lines[@]}" > "${config_path}/${config_file}"
}

# Function: config
# Description: This function checks for the existence of a configuration file.
#              If the file exists, it sources it to load the configuration settings.
#              If the file does not exist, it creates a new configuration file with
#              default settings.
function config() {
    if [ -f "${config_path}/${config_file}" ]; then
        # shellcheck source=/dev/null
        source "${config_path}/${config_file}"

        # Initalize the log levels
        logging_level
        info "Configuration file found loading ${config_path}/${config_file}"
    else
        default_editor="nano"
        color_output="true"
        username=${USER}
        identity_file_location="${HOME}/.ssh"
        identity_file=""
        port=22
        logging="info"
        build_config

        # shellcheck source=/dev/null
        source "${config_path}/${config_file}"

        # Initalize the log levels
        logging_level
        info "Created and loaded configuration file ${config_path}/${config_file}"
    fi
}

function save_config() {
    build_config

    # shellcheck source=/dev/null
    source "${config_path}${config_file}"
    
    # Initalize the log levels
    logging_level
    info "Saved configuration file ${config_path}/${config_file}"
}

# Allow the user to build a config file with specified answers
function rebuild_config() {
    build_config

    # shellcheck source=/dev/null
    source "${config_path}${config_file}"
    
    # Initalize the log levels
    logging_level
    info "Rebuilding configuration file ${config_path}/${config_file}"
}
