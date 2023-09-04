#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files
declare -A host_to_ip

# Function Name: 
#   select_hosts
#
# Description: 
#   Allows the user to select hostnames from a list. The selected hostnames
#   are then added to the "host_array" global variable for further processing.
#
# Steps:
#   1. Initialize local variables including 'target' array for selected hosts,
#      'colmax' for maximum columns, and 'offset' for UI layout.
#   2. Call the 'multiselect' function to display available host options.
#   3. Iterate through 'host_options' to find out which hosts have been selected.
#   4. Populate 'target' array with the selected hosts.
#   5. Update the 'host_array' global variable with the selected hosts.
#   6. If no hosts are selected, call the 'remote_menu' function and inform the user.
#
# Globals:
#   - host_options: An array containing the list of available hostnames.
#   - host_array: An array to store the selected hostnames.
#   - COLS: The terminal width, used to calculate the 'offset'.
#
# Parameters:
#   None.
#
# Returns:
#   None. Modifies the global 'host_array' variable and optionally calls 'remote_menu'.
#
function select_hosts() {
    debug "select_hosts function with ${#host_options[@]} hosts"
    clear
    header "center" "Select Hosts from the Database"
    footer "right" "${app_logo_color} v.${app_ver}"
    target=()
    colmax=3
    # Calculate 70% of the total screen width
    max_width=$(awk "BEGIN { printf \"%d\", ($COLS * 0.7) }")
    # Calculate the width of each column
    offset=$(( max_width / colmax ))
    idx=0
    dbg=0
    status=1

    # Add the "Type in Hostname" option to the host_options array
    multiselect result $colmax $offset host_options preselection "SELECT HOSTNAMES" 

    # display all of the choices
    for option in "${host_options[@]}"; do
        if  [[ ${result[idx]} == true ]]; then
            if [ $dbg -eq 1 ]; then
                echo "$option"
                pause
            fi
            target+=("${option}")
            status=0
        fi  
        ((idx++))
    done

    if [ $status -eq 0 ] ; then
        hostname=("${target[@]}")
        host_array=("${target[@]}")
    else
        echo -e "${light_green} No items selected... ${default}"
        remote_menu
    fi
}

# Function Name: 
#   type_host
#
# Description: 
#   Allows the user to manually enter a hostname for further diagnostics.
#   The function also displays headers and footers on the terminal.
#
# Steps:
#   1. Clears the terminal screen.
#   2. Uses ANSI escape sequences to navigate the terminal cursor.
#   3. Displays a header and footer using 'header' and 'footer' functions.
#   4. Prompts the user to enter a hostname.
#   5. Logs the entered hostname.
#
# Globals:
#   - app_logo_color: Color code for displaying the application version.
#   - app_ver: Application version number.
#
# Parameters:
#   None.
#
# Returns:
#   None. Sets the user-provided hostname for further operations.
#
function type_host() {
    debug "type_host function"
    # ANSI escape sequences
    ESC="\033"
    cursor_to_start="${ESC}[H"
    cursor_to_third_row="${ESC}[3;1H"  # Move to 3rd row, 1st column
    keep_running=true

    clear
    echo -ne "${cursor_to_start}"
    header "center" "System Diagnostics"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "${white}Press ${light_blue}[${white}ESC${light_blue}]${white} or ${light_blue}[${white}Q${light_blue}]${white} to exit screen.${default}" 

    echo -en "${light_blue}🌐 Enter a Host:${default} "
    read -r hostname
    info "Hostname changed to ${hostname}"
    return
}

# Function Name: 
#   get_host
#
# Description: 
#   Fetches a list of hostnames and their corresponding descriptors from a 
#   configured SSH file, allowing the user to select a host for further actions.
#
# Steps:
#   1. Declare variables and arrays.
#   2. Use gawk to parse the SSH configuration files.
#   3. Fill an array with hostnames.
#   4. Handle special cases for group names and comments.
#   5. Populate the 'host_options' array with the hostnames.
#   6. Set 'preselection' to false.
#   7. Call the 'select_hosts' function to allow user to select hosts.
#
# Globals:
#   - CONFILES: Path to the SSH configuration files.
#   - host_options: An array to store the host options for selection.
#   - preselection: A flag to indicate whether hosts are pre-selected.
#   - search_dir: Array to hold file choices for searching.
#
# Parameters:
#   None.
#
# Returns:
#   None. Modifies the 'host_options' global variable for further use.
#
function get_host() {
    desclength=20
    declare -A hostnames

    while read -r name hostname desc; do
        case    ${name,,} in
            'group_name') name="{ $desc }"
                name_length=${#name}
                name_left=$(( (40 - name_length) / 2 ))
                name_right=$(( 40 - name_left + name_length ))
                printf -v tmp "%${name_left}s_NAME_%${name_right}s"
                tmp=${tmp// /-}  name=${tmp//_NAME_/$name}
                content+=( "$desc" );  desc='_LINE_';;
            '#'*) continue;;
        esac

        hostnames["$name"]=$hostname #Create host-hostname pairs in hostnames array
        fullist+=("$name")   #Add Host and Description to the list
    done < <(gawk '
    BEGIN{IGNORECASE=1}
    /^Host /{
        strt=1
        host=$2
        next
    }
    strt && /HostName /{
        hostname=$2
        print host, hostname, desc
        strt=0
    }' "$CONFILES")

    # Assign all hosts found to a variable
    host_options=( "${fullist[@]}" )
    preselection=false
    search_dir[file_choice]="ssh config file"

    select_hosts
    return
}

# Function Name:
#   get_host_file
#
# Description:
#   This function is responsible for selecting a file from the available choices,
#   parsing it to extract hostnames, and then passing those hostnames to the 
#   'select_hosts' function for further action.
#
# Steps:
#   1. Declare an associative array named 'preselection'.
#   2. Calls 'select_file' function to select a database file.
#   3. Reads the selected file line by line.
#   4. Filters out empty lines and comments.
#   5. Extracts hostnames from valid lines.
#   6. Appends the hostnames to the 'host_options' array.
#   7. Sets preselection for all hostnames.
#   8. Calls 'select_hosts' function to allow the user to select hosts.
#
# Globals:
#   - db_files: An associative array holding the paths to the database files.
#   - host_options: An array to store hostnames for user selection.
#   - file_choice: The selected file from the list of database files.
#   - host_count: The total number of hostnames available for selection.
#
# Parameters:
#   None.
#
# Returns:
#   None. Modifies the 'host_options' and 'preselection' global variables for
#   further use.
function get_host_file() {
    # Assume the first argument passed to get_host_file is the filename
    file_choice=$1  # This will now be just the filename, not the full path
    full_path=${db_files["$file_choice"]}  # Look up the full path using the associative array

    declare -A preselection
    host_options=()
    select_file  # If this function uses file_choice or full_path, make sure to update it accordingly
    debug "get_host_file function started with select_file function '${full_path}' database"

    # Read each non-empty line from the selected file and extract the hostname
    while IFS= read -r line; do
        if [[ -n $line ]] && [[ ${line:0:1} != "#" ]]; then
            hostname=$(echo "$line" | cut -d ',' -f 1)
            ip=$(echo "$line" | cut -d ',' -f 4)
            
            # Add hostname to array for selection
            host_options+=("$hostname")

            # If IP exists, map it to the hostname
            if [[ -n $ip ]]; then
                host_to_ip["$hostname"]=$ip
            fi
        fi
    done < "$full_path"

    host_count=${#host_options[@]}

    # Further code...
    select_hosts  # If this function uses host_options or host_count, no further modification is needed
}

