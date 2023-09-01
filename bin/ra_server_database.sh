#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

# Function Name:
#   load_database
#
# Description:
#   This function is designed to load server databases by identifying 
#   all files in a specified directory that match a particular pattern,
#   then loading these databases into an array for further operations.
#
# Steps:
#   1. Clears the screen and displays headers and footers.
#   2. Initializes an array 'db_files' to hold database file paths.
#   3. Checks if the specified directory exists.
#   4. Iterates through the directory, adding file names to 'db_files'.
#   5. Checks whether any files were found.
#   6. If files were found, calls the 'get_host_file' function for each file.
#
# Globals:
#   - db_files: An array that stores the paths of the database files.
#   - search_dir: The directory where the script searches for database files.
#   - app_logo_color: Color code for the app logo.
#   - app_ver: Version of the application.
#   - keep_running: A flag to control the loop.
#   - files_found: A flag to indicate whether any files were found.
#
# Parameters:
#   None.
#
# Returns:
#   None. Modifies global variable 'db_files' and calls other functions
#   like 'get_host_file' for further operations.
#
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
        error "Database directory does not exist."
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
        notice "No database files exist."
        echo -e "${yellow}No database files exist.${default}"
        pause
    else
        debug "Processing found files"
        get_host_file "${db_files[@]}"
    fi
}

# Function Name:
#   add_server_to_database
#
# Description:
#   This function is responsible for gathering server information from the user
#   and appending it to a specified database file. The function first asks for a
#   required hostname and then collects optional server attributes like User, 
#   Identity File, IP Address, Jump Host, and Port.
#
# Steps:
#   1. Receives a database file path as an argument.
#   2. Reads the hostname from the user. If none is given, returns an error message and exits.
#   3. Reads other optional fields like User, Identity File, IP Address, Jump Host, and Port.
#   4. Appends the collected information as a comma-separated line to the specified database file.
#
# Globals Modified:
#   None. However, it writes to the file specified by the argument.
#
# Globals Read:
#   None.
#
# Parameters:
#   db_file - The file path to the database where the server information will be appended.
#
# Returns:
#   1 - if the required 'HostName' field is empty.
#   Otherwise, implicitly returns 0 after appending information to the database file.
#
# Called By:
#   Main program or another function requiring the addition of a server to a database.
#
# Calls:
#   - read: Built-in bash command to read user input.
#   - echo: Built-in bash command to write to the standard output or file.
#
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

# Function Name:
#   create_database
#
# Description:
#   This function creates a new server database with a user-defined name.
#   It sanitizes the name for file system safety, checks for duplicates, 
#   and gives the user an option to populate the newly created database
#   with server information.
#
# Steps:
#   1. Display header and footer with information.
#   2. Prompt the user to input a database name.
#   3. Sanitize the database name for file system safety.
#   4. Add a "radb_" prefix to the sanitized database name.
#   5. Check if the database name is empty or already exists. If so, return with an error message.
#   6. Create a new file with the prefixed and sanitized database name.
#   7. Offer the user an option to add server entries to the newly created database.
#
# Globals Modified:
#   - New database file created in the "search_dir" directory.
#
# Globals Read:
#   - search_dir: The directory where the database will be created.
#
# Parameters:
#   None.
#
# Returns:
#   1 - if the database name is empty or already exists.
#   Otherwise, implicitly returns 0 after successful database creation.
#
# Called By:
#   Main program or other functions that require database creation.
#
# Calls:
#   - touch: Unix command to create an empty file.
#   - add_server_to_database: A function to add server information to a database.
#   - read: Built-in bash command to read user input.
#   - echo: Built-in bash command to display output.
#
#
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

# Function Name:
#   update_server_record
#
# Description:
#   This function updates an existing server record in a specified database file.
#   It reads the database line-by-line, compares the hostname, and updates the
#   corresponding record with new values provided by the user.
#
# Steps:
#   1. Accepts the database file and the hostname to be updated as arguments.
#   2. Creates a temporary file to store the updated records.
#   3. Iterates through each line in the database file.
#   4. Compares each hostname with the search_hostname.
#   5. If a match is found, prompts the user to enter new values for each field.
#   6. Writes the updated or existing record to the temporary file.
#   7. Replaces the original database file with the updated temporary file.
#
# Globals Modified:
#   - A temporary file is created and later replaces the original database file.
#
# Globals Read:
#   - None.
#
# Parameters:
#   db_file - The database file in which the server record exists.
#   search_hostname - The hostname of the server record to be updated.
#
# Returns:
#   None. Replaces the original database file with updated information.
#
# Called By:
#   Functions or sections of the script that require server record updates.
#
# Calls:
#   - mktemp: Unix command to create a temporary file.
#   - read: Built-in bash command to read user input.
#   - mv: Unix command to move/rename files.
#   - echo: Built-in bash command to display output.
#
#
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

# Function Name:
#   delete_server_record
#
# Description:
#   This function deletes a specific server record identified by its hostname 
#   in a given database file.
#
# Steps:
#   1. Accepts the database file and the hostname to be deleted as arguments.
#   2. Creates a temporary file to store the updated records.
#   3. Iterates through each line of the database file.
#   4. Writes each record to the temporary file unless the hostname matches 
#      the hostname to be deleted.
#   5. Replaces the original database file with the temporary file, thus
#      effectively deleting the specified server record.
#
# Globals Modified:
#   - A temporary file is created and later replaces the original database file.
#
# Globals Read:
#   - None.
#
# Parameters:
#   db_file - The database file from which the server record will be deleted.
#   search_hostname - The hostname of the server record to delete.
#
# Returns:
#   None. Replaces the original database file without the deleted record.
#
# Called By:
#   Functions or portions of the script that require server record deletions.
#
# Calls:
#   - mktemp: Unix command to create a temporary file.
#   - read: Built-in bash command to read user input (through file redirection).
#   - mv: Unix command to move/rename files.
#   - echo: Built-in bash command to display output.
#
#
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
