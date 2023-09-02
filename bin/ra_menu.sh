#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

# Function:
#   menu
# Description:
#   Provides the main menu interface for system administration tasks.
#
# Parameters:
#   None
#
# Returns:
#   None; navigates to different menus or functionalities based on user selection.
#
# Dependencies:
#   - Calls `header`, `footer`, `draw_center_line_with_info`, `select_option`, and various other menu functions like `remote_menu`, `local_menu`, `ssh_key_menu`, `app_menu`, `display_help`, and `bye`.
#
# Interactivity:
#   - Provides a list of options for the user to select using arrow keys and enter.
#   - Outputs directly to the terminal.
#
# Example:
#   Will present the user with a menu having options like "Remote Systems", "Local System", "SSH Key Management", etc., and navigate based on user selection.
#
function menu() {
    clear
    header "center" "System Administration Menu"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and ${white}[${light_blue}ENTER${white}] to select. Press ${white}[${light_blue}ESC${white}] ${default}for ESC menu."
    draw_center_line_with_info
    menu_help="main_menu"
    unset menu_choice
    
    menu=(
        "☁️ Remote Systems" #0
        "🏣 Local System" #1
        "🔑 SSH Key Management" #2
        "⚙️ Settings" #2
        "❓${light_blue} Help Manual${default}" #3
        "⏹️${light_red} Exit ${app_name}${default}" #4
    )
    
    select_option "${menu[@]}"
    menu_choice=$?

   case "${menu_choice}" in
        0) # Completed
            clear
            debug "\"Remote Systems\" was selected"
            remote_menu
            ;;
        1) # Completed
            clear
            debug "\"Local System\" was selected"
            local_menu
            ;;
        2) # Completed
            clear
            debug "\"SSH Key Management\" was selected"
            ssh_key_menu
            ;;
        3) # Completed
            clear
            debug "\"Settings\" was selected"
            app_menu
            ;;
        4) # Completed
            clear
            debug "\"Help Manual\" was selected"
            display_help "${menu_help}"
            ;;
        5) # Completed
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}

# Function:
#   remote_menu
#
# Description:
#   Provides a sub-menu interface for handling remote systems.
#
# Parameters:
#   None
#
# Returns:
#   None; navigates to different sub-menus or functionalities based on user selection.
#
# Dependencies:
#   - Calls `header`, `footer`, `draw_center_line_with_info`, `select_option`, and various other menu functions like `action_menu`, `type_host`, `database_menu`, `display_help`, and `bye`.
#   - Uses the global variable "$connection_result" to determine menu options.
#
# Interactivity:
#   - Provides a list of options for the user to select using arrow keys and enter.
#   - Outputs directly to the terminal.
#
# Example:
#   Will present the user with a menu having options like "Action Menu", "Enter a Host", "Server Databases", etc., and navigate based on user selection.
#
function remote_menu() {
    clear
    header "center" "Remote Systems Menu"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and ${white}[${light_blue}ENTER${white}] to select. Press ${white}[${light_blue}ESC${white}] ${default}for ESC menu."
    draw_center_line_with_info
    menu_help="remote_menu"
    unset menu_choice

    # Dynamic part of the menu
    dynamic_menu=()

    if [ "$connection_result" == "true" ]; then
        dynamic_menu+=("🔜 Action Menu")
    fi

    # Constant part of the menu
    constant_menu=(
        "🆎 Enter a Host"
        "📂 Server Databases"
        "🗳️ Load from SSH Config"
        "🔙${light_green} Return to System Menu${default}"
        "❓${light_blue} Help Manual${default}"
        "⏹️${light_red} Exit ${app_name}${default}"
    )

    # Combine the dynamic and constant parts
    menu=("${dynamic_menu[@]}" "${constant_menu[@]}")

    select_option "${menu[@]}"
    menu_choice=$?

    # Calculate the offset for the case options
    offset=${#dynamic_menu[@]}

    case $((menu_choice - offset)) in
        -1)
            clear
            debug "\"Action Menu\" was selected"
            action_menu
            ;;
        0)
            clear
            debug "\"Enter a Host\" was selected"
            type_host
            action_menu
            ;;
        1)
            clear
            debug "\"Server Databases\" was selected"
            database_menu
            ;;
        2)
            clear
            debug "\"Load from SSH Config\" was selected"
            action_menu
            ;;
        3)
            clear
            debug "\"Return to System Menu\" was selected"
            menu
            ;;
        4)
            clear
            debug "\"Help Manual\" was selected"
            display_help "${menu_help}"
            ;;
        5)
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}

# Function:
#   local_menu
#
# Description:
#   Provides a sub-menu interface for managing tasks on the local system.
#
# Parameters:
#   None
#
# Returns:
#   None; navigates to different sub-menus or functionalities based on user selection.
#
# Dependencies:
#   - Calls utility functions like `header`, `footer`, `draw_center_line_with_info`, and `select_option`.
#   - Calls other specific menu functions for executing various local system tasks such as `local_diagnostics_main`, `local_resources`, `snapshot`, `local_system_info`, `local_check_errors`, `local_check_updates`, `menu`, `display_help`, and `bye`.
#
# Interactivity:
#   - Provides a list of options for the user to select using arrow keys and enter.
#   - Outputs directly to the terminal.
#
# Example:
#   Will present the user with a menu having options like "Run a diagnostic", "Check Resources", "Create a Snapshot", etc., and will navigate based on user selection.
#
function local_menu() {
    clear
    header "center" "Local Systems Menu"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and ${white}[${light_blue}ENTER${white}] to select. Press ${white}[${light_blue}ESC${white}] ${default}for ESC menu."
    draw_center_line_with_info
    menu_help="local_menu"
    unset menu_choice
    
    menu=(
        "🏥 Run a diagnostic" #0
        "💻 Check Resources" #1
        "📷 Create a Snapshot" #2
        "💡 System Information" #3
        "🛠️ Check for Errors" #4
        "🔄 Check for Updates" #5
        "🔙${light_green} Return to System Menu${default}" #6
        "❓${light_blue} Help Manual${default}" #7
        "⏹️${light_red} Exit ${app_name}${default}" #8
    )

    select_option "${menu[@]}"
    menu_choice=$?

    case "${menu_choice}" in
        0) # Completed
            clear
            debug "\"Run a diagnostic\" was selected"
            local_diagnostics_main
            local_menu
            ;;
        1) # Completed
            clear
            debug "\"Check Resources\" was selected"
            local_resources
            local_menu
            ;;
        2)
            clear
            debug "\"Create a Snapshot\" was selected"
            snapshot
            local_menu
            ;;
        3) # Completed
            clear
            debug "\"System Information\" was selected"
            local_system_info
            local_menu
            ;;
        4)
            clear
            debug "\"Check for Errors\" was selected"
            local_check_errors
            local_menu
            ;;
        5)
            clear
            debug "\"Check for Updates\" was selected"
            local_check_updates
            local_menu
            ;;
        6) 
            clear
            debug "\"Return to System Menu\" was selected"
            menu
            ;;
        7)
            clear
            debug "\"Help Manual\" was selected"
            display_help "${menu_help}"
            ;;
        8)
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}

# Function:
#   app_menu
#
# Description:
#   Provides a sub-menu interface for managing application-level settings.
#
# Parameters:
#   None
#
# Returns:
#   None; navigates to different sub-menus or functionalities based on user selection.
#
# Dependencies:
#   - Calls utility functions like `header`, `footer`, `draw_center_line_with_info`, and `select_option`.
#   - Calls other specific menu functions for editing configurations and changing application settings such as `interactive_config`, `config`, `enter_username`, `enter_identityfile`, `menu`, `display_help`, and `bye`.
#
# Interactivity:
#   - Provides a list of options for the user to select using arrow keys and enter.
#   - Outputs directly to the terminal.
#
# Example:
#   Will present the user with a menu having options like "Interactive Config", "Edit Config", "Edit SSH Config", etc., and will navigate based on user selection.
#
function app_menu() {
    clear
    header "center" "Application Settings Menu"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and ${white}[${light_blue}ENTER${white}] to select. Press ${white}[${light_blue}ESC${white}] ${default}for ESC menu."
    draw_center_line_with_info
    menu_help="app_menu"
    unset menu_choice
    
    menu=(
        "🧠 Interactive Config" #0
        "📝 Edit Config" #1
        "📝 Edit SSH Config" #2
        "🧖 Change Username" #3
        "🆔 Change Identity" #4
        "🎛️ Change Logging Mode" #5
        "🔙${light_green} Return to System Menu${default}" #6
        "❓${light_blue} Help Manual${default}" #7
        "⏹️${light_red} Exit ${app_name}${default}" #8
    )

    select_option "${menu[@]}"
    menu_choice=$?

    case "${menu_choice}" in
        0)
            clear
            debug "\"Interactive Config\" was selected"
            interactive_config
            ;;
        1)
            clear
            debug "\"Edit Config\" was selected"
            ${default_editor} "${config_path}"/"${config_file}"
            config
            app_menu
            ;;
        2)
            clear
            debug "\"Edit SSH Config\" was selected"
            ${default_editor} "${HOME}"/.ssh/config
            app_menu
            ;;
        3)
            clear
            debug "\"Change Username\" was selected"
            enter_username
            app_menu
            ;;
        4)
            clear
            debug "\"Change Identity\" was selected"
            enter_identityfile
            app_menu
            ;;
        5)
            clear
            debug "\"Change Logging Mode\" was selected"
            logging_menu
            ;;
        6) 
            clear
            debug "\"Return to System Menu\" was selected"
            menu
            ;;
        7)
            clear
            debug "\"Help Manual\" was selected"
            display_help "${menu_help}"
            ;;
        8)
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}

# Function: 
#   action_menu
#
# Description:
#   This function provides an action-oriented sub-menu interface to perform various
#   remote operations on a specific host. Actions include running shell commands, diagnostics,
#   subscription refresh, file operations, and more.
#
# Parameters:
#   None
#
# Returns:
#   None; the function is procedural and leads to different operations based on user choices.
#
# Dependencies:
#   Calls utility functions like header, footer, draw_center_line_with_info, and select_option.
#   Utilizes other functions for the actual operations like shell_hosts, do_connection_test,
#   copy_ssh_key, refresh_subscription, local_diagnostics_main, remote_resources, snapshot,
#   local_system_info, deploy_updates, copy_file, get_file, vulnerability_scan, reboot_host_server,
#   shutdown_host_server, remote_menu, display_help, and bye.
#
# Interactivity:
#   Presents the user with a list of options to select using arrow keys and the Enter key.
#   Outputs directly to the terminal.
#
# Preconditions:
#   A hostname or host group must be specified (${hostname} must be non-empty). If not,
#   the user will be redirected to the remote_menu.
#
# Notes:
#   The function contains conditional logic to redirect to remote_menu if no hostname is provided.
#   action_choice is used to capture the user's menu selection.
#
# Example:
#   Upon calling action_menu, the user will see a menu with options such as "Shell into Systems",
#   "Test Connection", "Copy SSH Key", etc. The selected option will trigger a corresponding action or another sub-menu.
#
function action_menu {
    # To get to this menu, a hostname or hostgroup must be specified.
    if [ "${hostname}" == "" ]; then
        remote_menu
    fi
    clear
    header "center" "Application Settings Menu"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and ${white}[${light_blue}ENTER${white}] to select. Press ${white}[${light_blue}ESC${white}] ${default}for ESC menu."
    draw_center_line_with_info
    menu_help="action_menu"
    unset menu_choice

    menu=(
        "🐚 Shell into Systems" #0
        "📶 Test Connection" #1
        "🔑 Copy SSH Key" #2
        "🔄 Refresh Subscription Manager" #3
        "🏥 Run a diagnostic" #4
        "💻 Check Resources" #5
        "📷 Create a Snapshot" #6
        "💡 System Information" #7
        "🛠️ Check for Errors" #8
        "🔄 Check for Updates" #9
        "🚀 Deploy Updates" #10
        "📋 Copy File" #11
        "📥 Get File" #12
        "🛡️ Vulnerability Scan" #13
        "🔃 Reboot Host" #14
        "⏹️ Shutdown Host" #15
        "🔙${light_green} Return to Remote Menu${default}" #17
        "❓${light_blue} Help Manual${default}" #18
        "⏹️${light_red} Exit ${app_name}${default}" #19
    )

    select_option "${menu[@]}"
    action_choice=$?

    case "$action_choice" in
        0) # Shell to host - Completed
            info "SSH to ${hostname}"
            shell_hosts
            action_menu
            ;;
        1) # Test Connection - Completed
            debug "Test connection to ${hostname}"
            do_connection_test
            action_menu
            ;;
        2) # Copy SSH Key - Completed
            debug "Copy SSH Key to ${hostname}"
            copy_ssh_key
            action_menu
            ;;
        3) # Refresh Subscription Manager
            debug "Refresh subscription on ${hostname}"
            refresh_supscription
            action_menu
            ;;
        4)
            clear
            debug "\"Run a diagnostic\" was selected"
            local_diagnostics_main
            action_menu
            ;;
        5)
            clear
            debug "\"Check Resources\" was selected"
            remote_resources
            action_menu
            ;;
        6)
            clear
            debug "\"Create a Snapshot\" was selected"
            snapshot
            action_menu
            ;;
        7)
            clear
            debug "\"System Information\" was selected"
            local_system_info
            action_menu
            ;;
        8)
            clear
            debug "\"Check for Errors\" was selected"
            action_menu
            ;;
        9)
            clear
            debug "\"Check for Updates\" was selected"
            action_menu
            ;;
        10) # Deploy Security Patches
            debug "Deploy updates on ${display_host}"
            deploy_updates
            action_menu
            ;;
        11) # Copy File
            debug "Copy a file to ${display_host}"
            copy_file
            action_menu
            ;;
        12) # Get File
            debug "Get a file from ${display_host}"
            get_file
            action_menu
            ;;
        13)
            debug "Run a vulnerability scan on ${display_host}"
            vulnerability_scan
            action_menu
            ;;
        14) # Reboot Host
            debug "Reboot ${display_host}"
            reboot_host_server
            action_menu
            ;;
        15) # Shutdown Host
            debug "Shutdown ${display_host}"
            shutdown_host_server
            action_menu
            ;;
        16) 
            clear
            debug "\"Return to Remote Menu\" was selected"
            remote_menu
            ;;
        17)
            clear
            debug "\"Help Manual\" was selected"
            display_help "${menu_help}"
            ;;
        18)
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}

# Function: database_menu
#
# Description:
#   This function displays a menu for database management tasks. Users can load, create, modify, or delete databases.
#
# Parameters:
#   None
#
# Returns:
#   None; this function operates in a procedural manner to guide the user through the database management process.
#
# Dependencies:
#   This function relies on utility functions like header, footer, draw_center_line_with_info, and select_option.
#   When a menu option is selected, the corresponding database management function is called.
#
# Interactivity:
#   Presents a menu-based UI where users can use arrow keys to navigate and make selections using the Enter key.
#   Outputs are sent directly to the terminal.
#
# Preconditions:
#   Assumes that all dependencies for database operations are correctly configured and installed.
#
#
# Example:
#   The function will display a menu with options like "Load a Database", "Create a Database", "Modify a Database", etc.
#   Upon selection, the corresponding operation will be initiated.
function database_menu() {
    clear
    header "center" "Server Database Menu"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and ${white}[${light_blue}ENTER${white}] to select. Press ${white}[${light_blue}ESC${white}] ${default}for ESC menu."
    draw_center_line_with_info
    menu_help="database_menu"
    unset menu_choice
    
    menu=(
        "📂 Load a Database" #0
        "✨ Create a Database" #1
        "✏️ Modify a Database" #2
        "🗑️ Delete a Database" #3
        "🔙${light_green} Return to System Menu${default}" #4
        "❓${light_blue} Help Manual${default}" #5
        "⏹️${light_red} Exit ${app_name}${default}" #6
    )

    select_option "${menu[@]}"
    menu_choice=$?

    case "${menu_choice}" in
        0) # Completed
            clear
            debug "\"Load a Database\" was selected"
            load_database
            action_menu
            ;;
        1)
            clear
            debug "\"Create a Database\" was selected"
            create_database
            database_menu
            ;;
        2)
            clear
            debug "\"Modify a Database\" was selected"
            modify_db_menu
            ;;
        3)
            clear
            debug "\"Delete a Database\" was selected"
            database_menu
            ;;
        4) # Completed
            clear
            debug "\"Return to Remote Menu\" was selected"
            remote_menu
            ;;
        5)
            clear
            debug "\"Help Manual\" was selected"
            display_help "${menu_help}"
            ;;
        6) # Completed
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}

# Function: 
#   modify_db_menu
#
# Description:
#   This function displays a sub-menu for database modification tasks. 
#   It allows the user to add, remove, or modify server entries as well as directly edit a database file.
#
# Parameters:
#   None
#
# Returns:
#   None; this function is procedural and relies on user choices to call other functions.
#
# Dependencies:
#   Utilizes utility functions like header, footer, draw_center_line_with_info, and select_option.
#   Also, expected to call relevant database modification functions when they are selected by the user.
#
# Interactivity:
#   Uses a menu-based interface where the user can navigate with arrow keys and make selections with the Enter key.
#   Outputs directly to the terminal.
#
# Preconditions:
#   Assumes that relevant database files and configuration are already available.
#
#
# Example:
#   When called, the function shows the user a menu with options like "Add a Server", "Remove a Server",
#   "Modify a Server", "Edit a DB File", etc. Selecting an option is expected to initiate the corresponding operation.
function modify_db_menu() {
    clear
    header "center" "Database Modification Menu"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and ${white}[${light_blue}ENTER${white}] to select. Press ${white}[${light_blue}ESC${white}] ${default}for ESC menu."
    draw_center_line_with_info
    menu_help="modify_db_menu"
    unset menu_choice
    
    menu=(
        "Add a Server" #0
        "Remove a Server" #1
        "Modify a Server" #2
        "Edit a DB File" #3
        "🔙${light_green} Return to System Menu${default}" #4
        "❓${light_blue} Help Manual${default}" #5
        "⏹️${light_red} Exit ${app_name}${default}" #6
    )

    select_option "${menu[@]}"
    menu_choice=$?

    case "${menu_choice}" in
        0)
            clear
            debug "\"Add a Server\" was selected"
            modify_db_menu
            ;;
        1)
            clear
            debug "\"Remove a Server\" was selected"
            modify_db_menu
            ;;
        2)
            clear
            debug "\"Modify a Server\" was selected"
            modify_db_menu
            ;;
        3)
            clear
            debug "\"Edit a DB File\" was selected"
            modify_db_menu
            ;;
        4)
            clear
            debug "\"Return to Database Menu\" was selected"
            database_menu
            ;;
        5)
            clear
            debug "\"Help Manual\" was selected"
            display_help "${menu_help}"
            ;;
        6)
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}

# Function: ssh_key_menu
#
# Description:
#   This function presents a menu for managing SSH keys. It provides options to generate an SSH key,
#   copy it to a remote host, and delete it from the local system.
#
# Parameters:
#   None
#
# Returns:
#   None; this function is procedural and designed to take user input for further action.
#
# Dependencies:
#   Utilizes utility functions like header, footer, draw_center_line_with_info, and select_option.
#   Also, expected to call relevant SSH key management functions when selected by the user.
#
# Interactivity:
#   Provides a menu-based interface where the user can navigate with arrow keys and confirm choices with the Enter key.
#   Outputs directly to the terminal.
#
# Preconditions:
#   Assumes that the SSH server and client are correctly set up, and that any necessary dependencies for SSH key management are installed.
#
# Example:
#   When called, the function displays a menu with options like "Generate Key", "Copy Key to Remote Host", 
#   "Delete Key from Local System", etc. Selecting an option initiates the corresponding operation.
function ssh_key_menu() {
    clear
    header "center" "SSH Key Management Menu"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and ${white}[${light_blue}ENTER${white}] to select. Press ${white}[${light_blue}ESC${white}] ${default}for ESC menu."
    draw_center_line_with_info
    menu_help="key_menu"
    unset menu_choice

    menu=(
        "🔐 Generate Key" #0
        "📤 Copy Key to Remote Host" #1
        "🗑️ Delete Key from Local System" #2
        "🔙${light_green} Return to System Menu${default}" #3
        "❓${light_blue} Help Manual${default}" #4
        "⏹️${light_red} Exit ${app_name}${default}" #5
    )

    select_option "${menu[@]}"
    menu_choice=$?

    case "${menu_choice}" in
        0)
            clear
            debug "\"Generate Key\" was selected"
            generate_ssh_key
            menu
            ;;
        1)
            clear
            debug "\"Copy Key to Remote Host\" was selected"
            copy_key="true"
            remote_menu
            ;;
        2)
            clear
            debug "\"Delete Key from Local System\" was selected"
            ssh_key_menu
            ;;
        3) # Completed
            clear
            debug "\"Return to System Menu\" was selected"
            menu
            ;;
        4)
            clear
            debug "\"Help Manual\" was selected"
            display_help "${menu_help}"
            ;;
        5)
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}

function logging_menu() {
    clear
    header "center" "Logging Level Menu"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and ${white}[${light_blue}ENTER${white}] to select. Press ${white}[${light_blue}ESC${white}] ${default}for ESC menu."
    draw_center_line_with_info
    menu_help="logging_menu"
    unset menu_choice

    menu=(
        "🐛 Debug Mode" #0
        "📖 Information Mode" #1
        "🔔 Notice Mode" #2
        "⚠️ Warning Mode" #3
        "🚫 Error Mode" #4
        "🛑 Turn off Logging" #5
        "📄 View logs" #6
        "🔙${light_green} Return to System Menu${default}" #7
        "❓${light_blue} Help Manual${default}" #8
        "⏹️${light_red} Exit ${app_name}${default}" #9
    )

    select_option "${menu[@]}"
    menu_choice=$?

    case "${menu_choice}" in
        0)
            clear
            debug "\"Debug Level Turned on\" was selected"
            info "Debug Level Turned on"
            logging=debug
            save_config
            logging_menu
            ;;
        1)
            clear
            debug "\"Info Level Turned on\" was selected"
            info "Info Level Turned on"
            logging=info
            save_config
            logging_menu
            ;;
        2)
            clear
            debug "\"Notice Level Turned on\" was selected"
            info "Notice Level Turned on"
            logging=notice
            save_config
            logging_menu
            ;;
        3)
            clear
            debug "\"Warning Level Turned on\" was selected"
            info "Warning Level Turned on"
            logging=warning
            save_config
            logging_menu
            ;;
        4)
            clear
            debug "\"Error Level Turned on\" was selected"
            info "Error Level Turned on"
            logging=error
            save_config
            logging_menu
            ;;
        5)
            clear
            debug "\"Logging Level Turned off\" was selected"
            info "Logging Level Turned off"
            logging=0
            save_config
            logging_menu

            ;;
        6)
            clear
            debug "\"View Logs\" was selected"
            view_logs
            ;;
        7) # Completed
            clear
            info "\"Return to System Menu\" was selected"
            menu
            ;;
        8)
            clear
            debug "\"Help Manual\" was selected"
            display_help "${menu_help}"
            ;;
        9)
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}
