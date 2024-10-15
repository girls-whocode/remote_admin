#!/usr/bin/env bash

# Trap to handle Ctrl+C gracefully
trap "tput cnorm; exit" SIGINT

# Hide cursor
tput civis

function local_inet_speedtest() {
    # Get terminal height and width
    term_height=$(tput lines)
    term_width=$(tput cols)

    # Hide the cursor
    echo -ne "\033[?25l"

    # ANSI escape sequences
    ESC="\033"
    cursor_to_start="${ESC}[H"
    keep_running=true

    # Header and Footer
    header "center" "Real-Time Internet Speed Test"
    footer "right" "${app_logo_color} v.${app_ver}" "left" "${white}Press ${light_blue}[${white}ESC${light_blue}]${white} or ${light_blue}[${white}Q${light_blue}]${white} to exit.${default}"

    # Function to plot graph (visualize network performance)
    plot_graph() {
        local value=$1
        local max_value=$2
        local width=30  # Graph width
        local filled=$((value * width / max_value))
        local empty=$((width - filled))

        # Using echo -e instead of printf
        echo -ne "${white}[${default}"
        for ((i=1; i<=filled; i++)); do
            echo -ne "${blue}#${default}"
        done

        for ((i=1; i<=empty; i++)); do
            echo -ne "${dark_gray}-${default}"
        done
        echo -e "${white}] ${green} ${value} Mbps ${default}"
    }

    # Function to handle the ping test
    run_ping_test() {
        pings=()
        for i in {1..5}; do
            ping_result=$(ping -c 1 google.com | grep 'time=' | awk -F'time=' '{print $2}' | awk '{print $1}')
            pings+=("$ping_result")
            sleep 0.5
        done

        # Calculate average ping and jitter
        avg_ping=$(echo "${pings[@]}" | awk '{sum=0; for(i=1;i<=NF;i++) sum+=$i; print sum/NF}')
        jitter=$(echo "${pings[@]}" | awk -v avg=$avg_ping '{sum=0; for(i=1;i<=NF;i++) sum+=($i-avg)^2; print sqrt(sum/NF)}')

        echo -e "${white}Average Ping: ${light_green}${avg_ping} ms${default}   ${white}Jitter: ${light_green}${jitter} ms${default}"
        plot_graph "${avg_ping%%.*}" 200  # Plot ping graph (assuming max ping of 200ms)
        echo ""
    }

    # Function to measure download speed
    run_download_test() {
        start_time=$(date +%s.%N)
        # Use Cloudflare's speed test
        curl -o /dev/null -s https://testmy.net/download/200MB
        end_time=$(date +%s.%N)

        elapsed=$(echo "$end_time - $start_time" | bc)
        download_speed=$(echo "scale=2; (10 * 8) / $elapsed" | bc)  # Assume 10MB download

        echo -e "${white}Download Speed: ${light_green}${download_speed} Mbps${default}"
        plot_graph "${download_speed%%.*}" 1000  # Assuming max speed of 1000 Mbps
        echo ""
    }

    # Function to measure upload speed
    run_upload_test() {
        head -c 5M </dev/urandom > /tmp/upload_test.bin
        start_time=$(date +%s.%N)
        curl -X POST -F "file=@/tmp/upload_test.bin" https://httpbin.org/post -o /dev/null -s
        end_time=$(date +%s.%N)

        elapsed=$(echo "$end_time - $start_time" | bc)
        upload_speed=$(echo "scale=2; (5 * 8) / $elapsed" | bc)  # 5MB * 8 (bits)

        echo -e "${white}Upload Speed: ${light_green}${upload_speed} Mbps${default}"
        plot_graph "${upload_speed%%.*}" 100  # Assuming max speed of 100 Mbps
        echo ""
        rm /tmp/upload_test.bin
    }

    # Main loop for continuous processing and updating display
    while $keep_running; do
        # Clear screen and reset cursor
        echo -ne "${cursor_to_start}"

        # Display header and footer
        header "center" "Real-Time Internet Speed Test"
        footer "right" "${app_logo_color} v.${app_ver}" \
               "left" "${white}Press ${light_blue}[${white}ESC${light_blue}]${white} or ${light_blue}[${white}Q${light_blue}]${white} to exit.${default}"

        # Run the tests and display real-time results
        BLA::start_loading_animation "${BLA_earth}"
        run_ping_test
        BLA::stop_loading_animation

        BLA::start_loading_animation "${BLA_earth}"
        run_download_test
        BLA::stop_loading_animation

        BLA::start_loading_animation "${BLA_earth}"
        run_upload_test
        BLA::stop_loading_animation

        # Check for user input to exit
        read -t 1 -n1 key  # Wait for 1 second for input
        if [[ "$key" == $'\e' ]] || [[ "$key" == "q" ]]; then
            keep_running=false
        fi

        sleep 1  # Delay to avoid rapid updates
    done

    # Restore cursor before exiting
    echo -ne "\033[?25h"
}
