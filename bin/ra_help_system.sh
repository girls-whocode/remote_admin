#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

# Define the function display_help
function display_help() {
  # Check the argument passed to the function
  keep_running=true
  case "$1" in
    "main_menu")
        header "center" "Main Menu Help"
        footer "right" "${app_logo_color} v.${app_ver}" "left" "Press 'ESC' to return to the menu"
        mm_p1="What is ${light_blue}${app_name}${default}? ${app_name} stands for '${app_acronym}'. The name was derived from the application's focus on remote systems. Its primary function is to simplify the execution of various operations across one or more servers. It achieves this by offering a user-friendly menu interface designed for handling repetitive and multiple tasks."
        mm_p2="In addition to its interactive menus, ${light_blue}${app_name}${default} offers command-line arguments that can be utilized for automating tasks via cron jobs. These automation features enable the generation of reports, which can be accessed either from the command line or directly within the application."
        mm_p3="Each menu within ${light_blue}${app_name}${default} is crafted to enable a range of actions with minimal user input. Comprehensive descriptions for each available action are provided upon navigating through the respective menus."
        mm_p4="The Main Menu presents you with three primary choices: ${light_magenta}Remote Administration${default}, ${light_magenta}Local Administration${default}, and ${light_magenta}Settings${default}. Each menu option has it's own help system for more detailed information."
        echo ""
        wrap_text "${mm_p1}"
        echo ""
        wrap_text "${mm_p2}"
        echo ""
        wrap_text "${mm_p3}"
        echo ""
        wrap_text "${mm_p4}"
        while $keep_running; do
            handle_input "menu"
        done
        ;;
    "remote_menu")
        header "center" "Remote Menu Help"
        footer "right" "${app_logo_color} v.${app_ver}" "left" "Press 'ESC' to return to the menu"
        echo ""
        echo -e "Enter a Host: Manually input the hostname or IP address of a single server."
        echo -e "Load Server Database: Choose from a pre-defined list of servers, stored in selectable database files."
        echo -e "Load from SSH Config: Automatically populate the host list based on the SSH configurations found in the user's home directory."
        echo -e "Create a New Database: Compile a new list of servers, which can later be accessed via the "Load Server Database" option."
        while $keep_running; do
            handle_input "remote_menu"
        done
        ;;
    "local_menu")
        header "center" "Local Menu Help"
        footer "right" "${app_logo_color} v.${app_ver}" "left" "Press 'ESC' to return to the menu"
        lm_p1="The ${light_blue}${app_name}${default} Local Menu focuses on providing a suite of utilities aimed at diagnosing and managing the server on which the application is running. This menu serves as a one-stop solution for your local server management needs."
        lm_p2="Here are the built-in options you can avail of:"
        lm_p3="  🏥 ${magenta}Run a Diagnostic${default}: Execute a comprehensive diagnostic to identify potential issues affecting the server. This includes checking hardware status, software configurations, and network connectivity."
        lm_p4="  💻 ${magenta}Check Resources${default}: View the current utilization of system resources such as CPU, RAM, Disk, and Network to evaluate performance metrics."
        lm_p5="  📷 ${magenta}Create a Snapshot${default}: Generate a snapshot of the server's current state, useful for backup or to serve as a baseline for performance comparisons."
        lm_p6="  💡 ${magenta}System Information${default}: Retrieve detailed information about the server's hardware and software configuration."
        lm_p7="  🛠️ ${magenta}Check for Errors${default}: Scan system logs and active processes for potential errors or misconfigurations that could lead to instability."
        lm_p8="  🔄 ${magenta}Check for Updates${default}: Verify if the server and the ${app_name} application are up-to-date and check for available updates."
        echo ""
        wrap_text "${lm_p1}"
        echo ""
        wrap_text "${lm_p2}"
        echo ""
        wrap_text "${lm_p3}"
        echo ""
        wrap_text "${lm_p4}"
        echo ""
        wrap_text "${lm_p5}"
        echo ""
        wrap_text "${lm_p6}"
        echo ""
        wrap_text "${lm_p7}"
        echo ""
        wrap_text "${lm_p8}"
        while $keep_running; do
            handle_input "local_menu"
        done
        ;;
    "app_menu")
        header "center" "Settings Menu Help"
        footer "right" "${app_logo_color} v.${app_ver}" "left" "Press 'ESC' to return to the menu"
        am_p1="🧠 ${light_magenta}Interactive Config${default}"
        am_p2="This feature launches an interactive session designed to assist you in configuring the ${light_blue}${app_name}${default} v${light_blue}${app_ver}${default} settings effortlessly. Upon selecting this option, you'll be guided through a series of questions that enable you to set your preferred text editor, color output, username, SSH identity file and location, port number, and logging level. By adjusting the granularity of log messages. The available levels range from ${light_red}critical${default} to ${dark_gray}debug${default}, and each level includes messages from the levels above it in severity. For example, setting this to ${light_blue}info${default} will display log messages flagged as ${light_blue}info${default}, ${cyan}notice${default}, ${yellow}warning${default}, ${red}error${default}, and ${light_red}critical${default}."
        echo ""
        wrap_text "${am_p1}"
        wrap_text "${am_p2}"
        ec_p1="📝 ${light_magenta}Edit Config${default}"
        ec_p2="Choosing this option opens your primary configuration file for manual editing using your default text editor. This allows for detailed customization but requires familiarity with the configuration syntax and options."
        echo ""
        wrap_text "${ec_p1}"
        wrap_text "${ec_p2}"
        esc_p1="📝 ${light_magenta}Edit SSH Config${default}"
        esc_p2="This option lets you directly edit your SSH configuration file. This is useful for adding new SSH keys, specifying hosts, or changing connection settings. Ensure you understand SSH configurations before modifying the file."
        echo ""
        wrap_text "${esc_p1}"
        wrap_text "${esc_p2}"
        cu_p1="🧖 ${light_magenta}Change Username${default}"
        cu_p2="This feature allows you to change your current system username. Note that doing so might affect other system configurations and permissions. Exercise caution and ensure that you update other system settings accordingly."
        echo ""
        wrap_text "${cu_p1}"
        wrap_text "${cu_p2}"
        ci_p1="🆔 ${light_magenta}Change Identity${default}"
        ci_p2="This option enables you to update identity settings, such as SSH keys and user details. Useful when you need to refresh keys or update identification metadata without changing the entire user profile."
        echo ""
        wrap_text "${ci_p1}"
        wrap_text "${ci_p2}"
        while $keep_running; do
            handle_input "app_menu"
        done
        ;;
    "action_menu")
        ;;
    "snapshot")
        header "center" "Snapshot Help"
        footer "right" "${app_logo_color} v.${app_ver}" "left" "Press 'ESC' to return to the menu"
        ss_p1="Choice of Snapshot Technology\nFilesystem: Check whether you are using LVM, ZFS, or Btrfs, as each has its own snapshotting method.\nVirtual Machines: If you're running a VM, then the hypervisor may have its own snapshot capabilities.\nSimple Backup: If you're not using any of the above, rsync or dd can also be used, although they may not provide true snapshot functionality."
        ss_p2="Pre-Snapshot Preparations\nQuiesce the Filesystem: Some filesystems may need to be made read-only or applications may need to be paused to ensure data consistency.\nCheck for Existing Snapshots: Too many snapshots can fill up your storage or even make subsequent snapshots impossible.\nResource Check: Ensure that there is enough disk space and that the system load is not too high to carry out the snapshot operation."
        ss_p3="Script Workflow\nParameter Parsing: Process command-line options or configuration files.\nLogging: Decide on a logging mechanism to capture the success or failure of different steps.\nNotification: Add email notifications or system alerts in case of success/failure.\nError Handling: Implement robust error checking after each operation to make sure each step succeeds before proceeding to the next."
        ss_p4="Cleanup and Post-Snapshot Actions\nVerification: Once the snapshot is done, verify its integrity.\nRetention Policy: Define and implement a snapshot retention policy.\nApplication State: Restore application or filesystem state if they were paused or set to read-only."
        echo ""
        wrap_text "${ss_p1}"
        echo ""
        wrap_text "${ss_p2}"
        echo ""
        wrap_text "${ss_p3}"
        echo ""
        wrap_text "${ss_p4}"
        while $keep_running; do
            handle_input "app_menu"
        done
        ;;
    *)
      echo "Invalid argument. Accepted arguments are 'main_menu', 'remote_menu', 'local_menu', or 'app_menu'."
      ;;
  esac
}


# Function: display_help
# Description: This function displays the help information for the script, including 
#              available options and examples.
function display_arg_help() {
    # Define the padding size for option descriptions
    local option_padding=25

    # Display the application name, version, and header for arguments and examples
    printf "%b%s %bv%s %b- Arguments and Examples\n" "${light_red}" "${app_name}" "${light_blue}" "${app_ver}" "${default}"
    printf "%b------------------------------------------\n\n" "${dark_gray}"

    # Display the script usage information
    printf "${light_cyan}Usage: ${light_green}%s ${light_blue}[options]\n\n${default}" "${script_name}"
    printf "%bNOTE: %bIf no options are provided, %b%s%b will prompt the user\n" "${light_red}" "${light_magenta}" "${white}" "${app_name}" "${light_magenta}"
    printf "%bwith relevant questions to gather the necessary arguments. The options\n" "${light_magenta}"
    printf "%bserve as an alternative way to provide the required information, but\n" "${light_magenta}"
    printf "%bthey are not mandatory.\n\n" "${light_magenta}"

    # Display the available options
    printf "%bOptions:%b\n" "${light_cyan}" "${default}"
    printf "%b  -a%b" "${light_blue}" "${default}"
    printf "%*s${light_gray}Invoke action${default}\n" $((option_padding - 2))
    printf "%b  -h%b" "${light_blue}" "${default}"
    printf "%*s${light_gray}Display help${default}\n" $((option_padding - 2))
    printf "%b  -H <hostname>%b" "${light_blue}" "${default}"
    printf "%*s${light_gray}Set the hostname${default}\n" $((option_padding - 13))
    printf "%b  --hostfile <file>%b" "${light_blue}" "${default}"
    printf "%*s${light_gray}Load hosts from a file${default}\n" $((option_padding - 17))
    printf "%b  -u, --user <username>%b" "${light_blue}" "${default}"
    printf "%*s${light_gray}Set the username${default}\n" $((option_padding - 21))
    printf "%b  -i, --identity <keyfile>%b" "${light_blue}" "${default}"
    printf "%*s${light_gray}Set the SSH key identity${default}\n" $((option_padding - 24))
    printf "%b  -p%b" "${light_blue}" "${default}"
    printf "%*s${light_gray}Specify port${default}\n" $((option_padding - 2))
    printf "%b  -c=<true|false>%b" "${light_blue}" "${default}"
    printf "%*s${light_gray}Set color output (default: ${light_blue}true${light_gray})${default}\n\n" $((option_padding - 15))

    # Exit the script with a success status code
    exit 0
}