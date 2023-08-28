#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

function menu() {
    clear
    header "center" "System Administration Menu"
    footer "right" "${app_name} v.${app_ver}" "left" "Use the arrow keys to move curson, and enter to select."
    draw_center_line_with_info
    unset menu_choice
    
    menu=(
        "☁️ Remote Systems" #0
        "🏣 Local System" #1
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
        1) # COmpleted
            clear
            debug "\"Local System\" was selected"
            local_menu
            ;;
        2) # Completed
            clear
            debug "\"Settings\" was selected"
            app_menu
            ;;
        3) # Completed
            clear
            debug "\"Help Manual\" was selected"
            display_help "main_menu"
            ;;
        4) # Completed
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}

function remote_menu() {
    clear
    header "center" "Remote Systems Menu"
    footer "right" "${app_name} v.${app_ver}" "left" "Use the arrow keys to move curson, and enter to select."
    draw_center_line_with_info
    unset menu_choice
    
    menu=(
        "🆎 Enter a Host" #0
        "📂 Load Server Database" #1
        "🗳️ Load from SSH Config" #2
        "📇 Create a New Database" #3
        "🔙${light_green} Return to System Menu${default}" #4
        "❓${light_blue} Help Manual${default}" #5
        "⏹️${light_red} Exit ${app_name}${default}" #6
    )

    select_option "${menu[@]}"
    menu_choice=$?

    case "${menu_choice}" in
        0)
            clear
            debug "\"Enter a Host\" was selected"
            type_host
            action_menu
            ;;
        1)
            clear
            debug "\"Load Server Database\" was selected"
            get_host_file
            action_menu
            ;;
        2)
            clear
            debug "\"Load from SSH Config\" was selected"
            action_menu
            ;;
        3)
            clear
            debug "\"Create a New Database\" was selected"
            remote_menu
            ;;
        4)
            clear
            debug "\"Return to System Menu\" was selected"
            menu
            ;;
        5)
            clear
            debug "\"Help Manual\" was selected"
            display_help "remote_menu"
            ;;
        6)
            clear
            debug "\"Exit ${app_name}\" was selected"
            bye
            ;;
    esac
}

function local_menu() {
    clear
    header "center" "Local Systems Menu"
    footer "right" "${app_name} v.${app_ver}" "left" "Use the arrow keys to move curson, and enter to select."
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
        0)
            clear
            debug "\"Run a diagnostic\" was selected"
            local_diagnostics_main
            local_menu
            ;;
        1)
            clear
            debug "\"Check Resources\" was selected"
            check_resources
            local_menu
            ;;
        2)
            clear
            debug "\"Create a Snapshot\" was selected"
            snapshot
            local_menu
            ;;
        3)
            clear
            debug "\"System Information\" was selected"
            local_system_info
            local_menu
            ;;
        4)
            clear
            debug "\"Check for Errors\" was selected"
            local_menu
            ;;
        5)
            clear
            debug "\"Check for Updates\" was selected"
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
    footer "right" "${app_name} v.${app_ver}" "left" "Use the arrow keys to move curson, and enter to select."
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
    clear
    header "center" "Application Settings Menu"
    footer "right" "${app_name} v.${app_ver}" "left" "Use the arrow keys to move curson, and enter to select."
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
        "🔙${light_green} Return to System Menu${default}" #16
        "❓${light_blue} Help Manual${default}" #17
        "⏹️${light_red} Exit ${app_name}${default}" #18
    )

    printf "%b%s%b\n" "${light_yellow}" "${display_host}" "${default}"
    printf "%b════════════════════════════════════════════════════════════════════════════════════════════════════════%b\n\n" "${dark_gray}" "${default}"

    select_option "${menu[@]}"
    action_choice=$?

    if [ "${username}" = "" ]; then
        username=${USER}
    fi

    case "$action_choice" in
        0) # Shell to host
            debug "SSH to ${display_host}"
            shell_hosts
            action_menu
            ;;
        1) # Test Connection
            debug "Test connection to ${display_host}"
            test_connections
            ;;
        2) # Copy SSH Key
            debug "Copy SSH Key to ${display_host}"
            copy_sshkey
            action_menu
            ;;
        3) # Refresh Subscription Manager
            debug "Refresh subscription on ${display_host}"
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
            check_resources
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
            debug "\"Return to System Menu\" was selected"
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

        # "Modify a Database" #2
        # "Delete a Database"

