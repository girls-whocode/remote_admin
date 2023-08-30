#!/bin/bash
# shellcheck disable=SC2034  # variables are used in other files
# shellcheck disable=SC2154  # variables are sourced from other files

# Function: select_hosts function
# Description: Prompts the user to select hostnames from the host_options array and 
#              assigns the selected hostnames to the host_array variable. # If the
#              user selects the "Type in # Hostname" option, it prompts the user to 
#              enter a custom hostname.
function select_hosts() {
    debug "select_hosts function"
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

# Function: type_host function
# Description: Prompts the user to type in a hostname to
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
    footer "right" "${app_logo_color} v.${app_ver}" "left" "Press 'ESC' to return to the menu"  

    echo -en "${light_blue}🌐 Enter a Host:${default} "
    read -r hostname
    info "Hostname changed to ${hostname}"
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
    }' "$CONFILES")

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