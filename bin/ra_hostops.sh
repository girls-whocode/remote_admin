#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

# Function: select_hosts function
# Description: Prompts the user to select hostnames from the host_options array and 
#              assigns the selected hostnames to the host_array variable. # If the
#              user selects the "Type in # Hostname" option, it prompts the user to 
#              enter a custom hostname.
function select_hosts() {
    target=()
    colmax=5
    offset=$(( COLS / colmax ))
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
        host_array=("${target[@]}")
    else
        echo -e "${light_green} No items selected... ${default}"
        exit 0
    fi

    return
}

function check_host_exists() {
    local host=$1
    # Ping the host with a timeout of 1 second
    if ping -c 1 -W 1 "${host}" &> /dev/null; then
        echo "Host exists and is reachable."
        return 0
    else
        echo "Could not reach host."
        return 1
    fi
}

# Function: type_host function
# Description: Prompts the user to type in a hostname to
function type_host() {
    info "System Diagnostics Started"
    # ANSI escape sequences
    ESC="\033"
    cursor_to_start="${ESC}[H"
    cursor_to_third_row="${ESC}[3;1H"  # Move to 3rd row, 1st column
    keep_running=true

    clear
    echo -ne "${cursor_to_start}"
    header "center" "System Diagnostics"
    footer "right" "${app_name} v.${app_ver}" "left" "Press 'ESC' to return to the menu"  

    echo -en "${light_blue}🌐 Enter a Host:${default} "
    read -r remote_host
    check_host_exists "${remote_host}"
    hostname="$remote_host"
    return
}

# Function: get_host
# Description: This function checks if the ${HOME}/.ssh/config file exists and displays 
#              a list of hosts from it. If the file does not exist, it prompts the user 
#              to enter a hostname manually.
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
    }' $CONFILES)

    # Assign all hosts found to a variable
    host_options=( "${fullist[@]}" )
    preselection=false
    search_dir[file_choice]="ssh config file"

    select_hosts
    return
}

# Function: get_host_file
# Description: This function prompts the user to select a host file from a list and 
#              reads the selected file. It reads each line from the file and adds it 
#              to the `host_array` array.
function get_host_file() {
    declare -A preselection
    select_file

    # Read each non-empty line from the selected file and add it to the host_options array
    while IFS= read -r line; do
        if [[ -n $line ]]; then
            if [[ ${line:0:1} != "#" ]]; then
                host_options+=("$line")
            fi
        fi
    done < "${search_dir[$file_choice]}"
    host_count=${#host_options[@]}
    
    for ((i=0; i<host_count; i++)); do
        preselection[$i]=true
        echo $i
    done

    select_hosts
}

# Function: load_database
# Description: This function checks for the existence of database files in a specified
#              directory. If files are found, it loads them; otherwise, it prints a 
#              message indicating that no database files exist.
function load_database() {
    # Initialize an array to hold the names of found database files
    db_files=()
    keep_running=true

    # Check if the directory exists
    if [[ ! -d "${search_dir}" ]]; then
        error "Database directory does not exist."
        echo -e "${red}Error: Database directory does not exist.${default}"
    fi

    # Read through the directory and add file names to the db_files array
    for file in "$search_dir"/???_*; do
        # Check if the directory is empty; if so, break out of the loop
        if [[ -e "$file" ]]; then 
            echo -e "${yellow}No database files exist.${default}"
            pause
        else
            get_host_file
        fi
        
        # You can add further checks here to verify that the file meets your criteria
        # for being a "database file", for example, checking its file extension.
        db_files+=("$file")
    done
}

# Function: add_server_to_database
# Description: Adds server information to an existing database
function add_server_to_database() {
    local db_file=$1  # File to which server information will be appended

    # Read user input for each field
    read -p "Enter HostName (required): " hostname
    if [[ -z "$hostname" ]]; then
        echo "HostName is required. Exiting."
        return 1
    fi

    read -p "Enter User (optional): " user
    read -p "Enter Identity File (optional): " identity_file
    read -p "Enter IP Address (optional): " ip
    read -p "Enter Jump Host (optional): " jump_host
    read -p "Enter Port (optional): " port

    # Append the server information to the database file
    echo "$hostname,$user,$identity_file,$ip,$jump_host,$port" >> "$db_file"
}

# Function: create_database
# Description: This function prompts the user to enter a name for the new database.
#              It then creates an empty file with that name in the specified directory,
#              prefixed with "radb_".
function create_database() {
    header "center" "Server Database Menu"
    footer "right" "${app_name} v.${app_ver}" "left" "Use the arrow keys to move curson, and enter to select."
    draw_center_line_with_info
    echo -en "${light_blue}📦 Enter the name of the new database:${default}"
    read -r db_name

    # Removing any dangerous characters from user input
    safe_db_name=$(echo "$db_name" | tr -d './\\:')

    # Add "radb_" prefix to database name
    prefixed_db_name="radb_${safe_db_name}"

    # Check if database name is empty or if file already exists
    if [[ -z "$safe_db_name" ]]; then
        echo -e "${red}Database name cannot be empty.${default}"
        return 1
    elif [[ -e "${search_dir}/${prefixed_db_name}" ]]; then
        echo -e "${yellow}A database with that name already exists.${default}"
        return 1
    fi

    # Create the database file
    touch "${search_dir}/${prefixed_db_name}"

    if [[ $? -eq 0 ]]; then
        echo -e "${light_green}Database '$prefixed_db_name' successfully created.${default}"

        # Let the user add server(s) to the new database
        read -p "Would you like to add server(s) to the database now? (y/n): " add_choice
        if [[ "$add_choice" == "y" || "$add_choice" == "Y" ]]; then
            while :; do
                add_server_to_database "${search_dir}/${prefixed_db_name}"
                read -p "Add another server? (y/n): " another
                [[ "$another" == "y" || "$another" == "Y" ]] || break
            done
        fi
    else
        echo -e "${red}Failed to create the database.${default}"
    fi
}

# Function: update_server_record
# Description: Updates an existing server record in the database file
function update_server_record() {
    local db_file=$1
    local search_hostname=$2
    local temp_file=$(mktemp)

    while IFS=',' read -r hostname user identity_file ip jump_host port; do
        if [[ "$hostname" == "$search_hostname" ]]; then
            # This is the record to update
            read -p "Enter new User (optional): " user
            read -p "Enter new Identity File (optional): " identity_file
            read -p "Enter new IP Address (optional): " ip
            read -p "Enter new Jump Host (optional): " jump_host
            read -p "Enter new Port (optional): " port
        fi
        echo "$hostname,$user,$identity_file,$ip,$jump_host,$port" >> "$temp_file"
    done < "$db_file"

    mv "$temp_file" "$db_file"
}

# Function: delete_server_record
# Description: Deletes a server record from the database
function delete_server_record() {
    local db_file=$1
    local search_hostname=$2
    local temp_file=$(mktemp)

    while IFS=',' read -r hostname user identity_file ip jump_host port; do
        if [[ "$hostname" != "$search_hostname" ]]; then
            echo "$hostname,$user,$identity_file,$ip,$jump_host,$port" >> "$temp_file"
        fi
    done < "$db_file"

    mv "$temp_file" "$db_file"
}
