#!/usr/bin/env bash

# Function Name:
#   bytes_to_human
#
# Description:
#   Converts a given byte count to human-readable form.
#
# Globals Modified:
#   - None
#
# Parameters:
#   - bytes: The byte count to convert (integer)
#
# Returns:
#   - Outputs the byte count in human-readable form (B, KiB, MiB, GiB).
#
# Example:
#   bytes_to_human "1024" => "1.00 KiB"
#
function bytes_to_human() {
    local bytes="$1"
    if [[ "$bytes" -lt 1024 ]]; then
        echo "$(add_commas "${bytes}").00 B"
    elif [[ "$bytes" -lt 1048576 ]]; then
        echo "$(add_commas "$(awk "BEGIN { printf \"%.2f\", ${bytes}/1024 }")") KiB"
    elif [[ "$bytes" -lt 1073741824 ]]; then
        echo "$(add_commas "$(awk "BEGIN { printf \"%.2f\", ${bytes}/1048576 }")") MiB"
    elif [[ "$bytes" -lt 1099511627776 ]]; then  # Less than 1 TiB
        echo "$(add_commas "$(awk "BEGIN { printf \"%.2f\", ${bytes}/1073741824 }")") GiB"
    elif [[ "$bytes" -lt 1125899906842624 ]]; then  # Less than 1 PiB
        echo "$(add_commas "$(awk "BEGIN { printf \"%.2f\", ${bytes}/1099511627776 }")") TiB"
    else  # Greater than or equal to 1 PiB
        echo "$(add_commas "$(awk "BEGIN { printf \"%.2f\", ${bytes}/1125899906842624 }")") PiB"
    fi
}