#!/bin/bash

# Generate a random CPU load: between 70% and 95%
target_load=$(shuf -i 70-95 -n 1)

# Generate a random duration for which to maintain the load: between 5s and 15s
duration=$(shuf -i 5-15 -n 1)

echo "Generating ${target_load}% CPU load for ${duration} seconds."

end=$((SECONDS+$duration))

# Calculate number of cores
cores=$(nproc)

# Create an array to hold background process IDs
pids=()

# Start 'yes' commands in background processes
for ((i=1; i<=cores; i++))
do
  yes > /dev/null &
  pids+=($!)
done

# Sleep for the random duration
sleep $duration

# Kill the CPU-intensive processes
for pid in "${pids[@]}"; do
  kill -9 $pid
done

echo "Load generation complete."
