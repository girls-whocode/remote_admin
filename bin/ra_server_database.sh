#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

# Function: load_database
# Description: This function checks for the existence of database files in a specified
#              directory. If files are found, it loads them; otherwise, it prints a 
#              message indicating that no database files exist.
function load_database() {
    clear
    header "center" "Loading a Server Database"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and enter to select."

    # Initialize an array to hold the names of found database files
    db_files=()
    keep_running=true
    debug "Loading load_database function"

    # Check if the directory exists
    if [[ ! -d "${search_dir}" ]]; then
        debug "Database directory does not exist."
        echo -e "${red}Error: Database directory does not exist.${default}"
        return
    fi

    # Initialize a flag to check if any files were found
    files_found=false

    # Read through the directory and add file names to the db_files array
    for file in "${search_dir}"/ra_*; do
        debug "Checking file: $file"
        if [[ -e "$file" ]]; then 
            debug "Found file: $file"
            db_files+=("$file")
            files_found=true
        else
            debug "Skipping file: $file (not found)"
        fi
    done

    # Show count of found files for debugging
    debug "Number of files found: ${#db_files[@]}"

    # If no files were found, display a message
    if [[ "$files_found" == false ]]; then
        debug "No database files exist."
        echo -e "${yellow}No database files exist.${default}"
        pause
    else
        debug "Processing found files"
        for db_file in "${db_files[@]}"; do
            debug "Loading get_host_file function for $db_file"
            get_host_file "$db_file"
        done
    fi
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
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Use the arrow keys to move curson, and enter to select."
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
