#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

function menu() {
    clear
    header "center" "System Administration Menu"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and enter to select."
    draw_center_line_with_info
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
            display_help "main_menu"
            ;;
        5) # Completed
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}

function remote_menu() {
    clear
    header "center" "Remote Systems Menu"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and enter to select."
    draw_center_line_with_info
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
            display_help "remote_menu"
            ;;
        5)
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}

function local_menu() {
    clear
    header "center" "Local Systems Menu"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and enter to select."
    draw_center_line_with_info
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
            display_help "local_menu"
            ;;
        8)
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}

function app_menu() {
    clear
    header "center" "Application Settings Menu"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and enter to select."
    draw_center_line_with_info
    unset menu_choice
    
    menu=(
        "🧠 Interactive Config" #0
        "📝 Edit Config" #1
        "📝 Edit SSH Config" #2
        "🧖 Change Username" #3
        "🆔 Change Identity" #4
        "🔙${light_green} Return to System Menu${default}" #5
        "❓${light_blue} Help Manual${default}" #6
        "⏹️${light_red} Exit ${app_name}${default}" #7
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
            debug "\"Return to System Menu\" was selected"
            menu
            ;;
        6)
            clear
            debug "\"Help Manual\" was selected"
            display_help "app_menu"
            ;;
        7)
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}

# Function: get_action
# Description: This function prompts the user to select an action to perform on the 
#              host(s) and performs the selected action.
function action_menu {
    # To get to this menu, a hostname or hostgroup must be specified.
    if [ "${hostname}" == "" ]; then
        remote_menu
    fi
    clear
    header "center" "Application Settings Menu"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and enter to select."
    draw_center_line_with_info
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
        0) # Shell to host
            info "SSH to ${hostname}"
            shell_hosts
            action_menu
            ;;
        1) # Test Connection - Completed
            debug "Test connection to ${hostname}"
            do_connection_test
            action_menu
            ;;
        2) # Copy SSH Key
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
            display_help "action_menu"
            action_menu
            ;;
        18)
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}

function database_menu() {
    clear
    header "center" "Server Database Menu"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and enter to select."
    draw_center_line_with_info
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
        0)
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
        2)
            clear
            debug "\"Delete a Database\" was selected"
            database_menu
            ;;
        4)
            clear
            debug "\"Return to System Menu\" was selected"
            remote_menu
            ;;
        5)
            clear
            debug "\"Help Manual\" was selected"
            display_help "database_menu"
            ;;
        6)
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}

function modify_db_menu() {
    clear
    header "center" "Database Modification Menu"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and enter to select."
    draw_center_line_with_info
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
        2)
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
            display_help "database_menu"
            ;;
        6)
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}

function ssh_key_menu() {
    clear
    header "center" "SSH Key Management Menu"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and enter to select."
    draw_center_line_with_info
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
            local_menu
            ;;
        2)
            clear
            debug "\"Delete Key from Local System\" was selected"
            ssk_key_menu
            ;;
        3) # Completed
            clear
            debug "\"Return to System Menu\" was selected"
            menu
            ;;
        4)
            clear
            debug "\"Help Manual\" was selected"
            display_help "key_menu"
            ;;
        5)
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}